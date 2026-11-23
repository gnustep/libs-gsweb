# mod_gsw (Apache2 adaptor) — Phase 2 Changes

Phase 2 of the fix plan (`~/.opencode/plan/mod_gsw-fixes.md`): the I/O path
rewrite. All changes are confined to `GSWAdaptors/Apache2/gsw_net.c`,
`gsw_request.c`, `gsw_private.h`, and a small guard in `gsw_handler.c`.

Unlike Phase 1, this phase was not a set of isolated fixes. Rewriting the socket
reader to batch its I/O invalidated two assumptions the byte-at-a-time version
never violated, and those surfaced as a hang and a segfault rather than at build
time. They are documented below alongside the planned items because they are the
part most likely to bite a future reader.

## Summary table

| Item | Change |
|------|--------|
| **3.1** | `read_sock_line()` reads in 8 KiB chunks and scans for `\n` with `memchr`, instead of one `poll()`+`read()` per byte. A ~10-line header went from ~200 syscalls to ~5 |
| **3.2** | `write_sock()` loops until every byte is sent; `EINTR` retries, `EAGAIN` polls for writability, real errors return -1. Previously a partial `send()` or an `EAGAIN` returned 0 — i.e. silent data loss |
| **3.3** | `send_headers()` batches the whole header block into one growable pool buffer and sends it in a single `write_sock()`. `send_header_string()` deleted |
| **2.6** | The three unchecked `write_sock()` calls for POST body + CRLF now check their result and fail over to retry |
| **2.7 / 3.9** | Body relay chunk size 1024 → 64 KiB |
| **1.5 gap** | The body-read loop polls against `WOWaitTimeout` before each `read()`, so a backend that stalls mid-body can no longer wedge the worker |
| **1.11** | New: CR/LF injection hardening, both directions (see below) |
| **2.17** | New: drain the buffered reader's over-read bytes before polling the socket for the body |
| **2.18** | New: `ap_rwrite()` returns a byte count, not a status |
| **2.19** | New: never retry once part of a body has been streamed |
| **2.20** | New: per-connection line-reader state (a file-scope static leaked across requests) |

## Planned items

### 3.1 — Buffered line reads

The old reader polled and read one byte at a time, so every response-header byte
cost two syscalls. It now fills an 8 KiB buffer with a single `read()` per poll
and locates the newline in userspace. Bytes after the `\n` are retained for the
next call, which is what makes the batching safe but also what introduced 2.17
and 2.20.

`WOWaitTimeout` semantics from Phase 1 are preserved: the deadline is computed
once per call, remaining time is recomputed before each poll, and NULL is
returned on timeout, read error, or EOF. Timeout (`poll()` returning 0) and
error (`poll()` returning -1) are now logged distinctly rather than sharing one
message, and an expired deadline is detected *before* polling — the previous
formulation clamped the wait to 0 ms, turning a passed deadline into a
non-blocking poll and a misleading instant-timeout log line.

### 3.2 — Full-send loop in `write_sock()`

```c
/* before */
rval = send(socket, data, len, 0);
if (rval < 0) {
    switch (errno) {
        case EAGAIN: break;      /* falls out of the switch ... */
        case EINTR:  break;      /* ... */
        default:     return -1;
    }
}
return 0;                        /* ... and reports SUCCESS */
```

A single `send()` may transmit less than requested, and `EAGAIN`/`EINTR` were
treated as success — so headers could be silently truncated on the wire. The
rewrite loops until `sent == len`, retries on `EINTR`, waits for writability on
`EAGAIN`/`EWOULDBLOCK`, and returns -1 only for genuine errors (EPIPE,
ECONNRESET). Callers must check the result; 2.6 does.

Two portability notes:

- On FreeBSD `EWOULDBLOCK` is defined as `EAGAIN` (same value), so they cannot
  be separate `case`s in a `switch`. The errno handling is `if`/`else if`.
- The backend socket is blocking (`connect_host()` restores `O_NONBLOCK`), so
  `send()` normally applies its own flow control and the writability wait is
  purely defensive. It is nevertheless bounded by a `DEFAULT_WAIT_TIMEOUT`
  deadline: without one, a backend that stops reading would hang the worker on
  the *send* path, which Phase 1 had only addressed on the receive path.

### 3.3 — Header batching in `send_headers()`

Headers accumulate into a `apr_palloc(r->pool, …)` buffer starting at 4096 bytes
and doubling on overflow, appended through an `APPEND_HDR(key, value)` macro,
then written once. The request line is still sent directly and unbounded,
preserving 1.1.

The growth path must copy existing contents — `apr_palloc` returns fresh,
uninitialized memory, so resizing without `memcpy` discards every header
appended so far. That bug was caught during review, not at runtime; it would have
corrupted any request with more than 4 KiB of headers (cookies, auth).

`APPEND_HDR` takes the key as a `%s` argument rather than pasting it into the
format string. The paste form (`key ": %s\r\n"`) compiles only when `key` is a
string literal and breaks on expressions like `hdrs[i].key`.

### 2.6 — Checked writes for the POST body

Three `write_sock()` calls (CRLF, body, final CRLF) ignored their return values,
so a backend closing mid-send led to reading a response from a dead socket. All
three now fail over to the shared `unreachable:` label.

### 2.7 / 3.9 — 64 KiB body chunks

At 1024 bytes, a 1 MB response cost 1024 `read()` + 1024 `ap_rwrite()` cycles.
The buffer is allocated from `sub_pool`, so this raises per-request allocation,
not peak resident memory.

### 1.5 gap — Timeout on the body read

Phase 1 added `WOWaitTimeout` to header reads only; the body loop was a bare
blocking `read()`, so a backend that sent headers and then stalled hung the
worker indefinitely. Each iteration now polls against the same deadline, and
timeout, poll error, read error, and EOF are handled separately.

### 1.11 — CRLF injection / response splitting (CVE-2016-4975 class)

The module relays header values verbatim in both directions: client headers to
the backend, backend headers into the client response via `apr_table_set`. A
patched host Apache (≥ 2.4.25) strips CR/LF from outbound headers, so the module
was not directly vulnerable — but on an unpatched host a malicious backend or a
malicious client could split the message. Since the attack vector is overwhelmingly
the internet-facing side, the check is applied in both directions.

`gsw_header_is_safe(key, value)` rejects raw CR/LF and percent-encoded
`%0d`/`%0a`. The encoded forms matter because the adaptor forwards values
verbatim and the receiving side may decode them, reintroducing raw CR/LF after
the adaptor's own check. Unsafe headers are dropped with an `APLOG_WARNING`.

Implementation note: `strcasestr()` was used first and replaced with a manual
scan. It is not POSIX and requires `_GNU_SOURCE` on glibc, so it would have
broken non-FreeBSD builds.

## Emergent fixes

These were not in the plan. Each is a consequence of moving from byte-at-a-time
to buffered reads, and each presented as a runtime failure rather than a compile
error.

### 2.17 — Over-read bytes were swallowed

A buffered line reader necessarily consumes data past the header terminator. When
GNUstep Web sends headers and body in one segment, the body lands in the
line buffer while the socket drains. The body relay then polled the socket, got
nothing useful, and reported 0 of N bytes — three retries, then 504.

The byte-at-a-time reader physically could not over-read, which is why this never
appeared before. `gsw_line_reader_pending()` exposes the retained bytes, and
`handle_request()` writes them to the client before touching the socket again.

### 2.18 — `ap_rwrite()` returns a byte count

```c
if (ap_rwrite(transferBuf, rval, r) != 0) {   /* WRONG */
    /* "client went away" */
}
```

`http_protocol.h`: *"Write a buffer for the current request … @return The number
of bytes sent."* Negative means error. So a successful 396-byte write returned
396, tripped the check, and discarded the body — producing exactly the
`body relay incomplete (0 of 396 bytes)` in the logs while `read()` had already
succeeded. The original code did not check the return value at all, so there was
no precedent to copy. `< 0` is correct at both call sites.

### 2.19 — No retry after a partial body

An incomplete relay jumped to `unreachable:` and let `gsw_handler()` try another
instance. Once any body byte has been streamed, that emits a second, interleaved
response on the same request. Now: retry only if `bytesDone == 0`; otherwise log
and report success with the truncated length.

### 2.20 — Line-reader state leaked across connections

3.1 initially used file-scope `static char buffer[8192]` and `static size_t len`,
on the reasoning that prefork handles one request at a time per process and each
request opens a fresh socket. Both premises were insufficient:

- `len` was never reset per connection, so request #2 started with request #1's
  unread tail.
- The scan window was computed as `buffer + len` for `GSW_LINE_BUF_SIZE - 1 - len`
  bytes — searching *past* valid data into uninitialized memory instead of
  searching `[0, len)`. A `\n` in retained bytes was therefore invisible, and
  `memchr` could return a pointer outside the live region. Line extraction then
  `memcpy`'d that many bytes out of bounds and segfaulted the worker.

The trace that exposed it showed `nl = buffer + 7840` while `len == 0`, followed
by `child pid … exit signal Segmentation fault (11)`.

Fix: a per-connection `gsw_line_reader` allocated from `sub_pool`, created once
per attempt, with an explicit `scan` offset so only `[scan, len)` is examined.

## Debugging infrastructure kept

Several latent issues were fixed while chasing the above. They are not Phase 2
items but are in this commit:

- **NULL guards.** `s->server_hostname`, `c->client_ip` / `c->remote_ip`,
  `r->the_request`, and `hdrs[i].val` are checked before being handed to
  `snprintf`. `send_headers()` previously tested `r->unparsed_uri` but formatted
  `r->the_request` — guarding the wrong pointer.
- **`fixRequestString()` NUL termination.** `strncpy(appName, req_str, len)`
  never terminates when the source has exactly length `len`, leaving `index()`
  scanning uninitialized memory. Replaced with `memcpy` + explicit `'\0'`, plus a
  fallback when `r->the_request` is NULL (subrequests).
- **Handler retry loop.** Guarded against `find_app()` returning NULL (all
  instances unreachable) and removed a double `mark_unreachable()` —
  `handle_request()`'s `unreachable:` path already marks it.
- **Failure-path fd leak.** All mid-request failures route through one
  `unreachable:` label that closes the socket. Individual early returns skipped
  `close(soc)`.
- **`%p` → `%pp`.** Apache's APR-based logger does not support plain `%p`; it
  consumed the literal text and shifted every subsequent vararg, printing
  `reader=bogus %plen=0` and making pointer values in the log untrustworthy.

Logging policy after cleanup: `APLOG_WARNING` for backend and protocol failures,
`APLOG_INFO` only for client-abort cases, `APLOG_DEBUG` for timing. Two
status-parsing messages were promoted from DEBUG to WARNING, since a malformed
backend response is worth seeing at default verbosity.

## Verification

Built clean on FreeBSD with Apache 2.4.69 (`gmake clean && gmake`, no warnings).

Verified end-to-end:

| Check | Result |
|---|---|
| `/wo/HControl.woa/1/wa/config` | 200, 396 bytes, JSON intact, `Request took 1 ms`, no retries |
| `/wo/showapps` | 200, 1010 bytes |

Confirmed by log trace: five header lines parsed individually from one 110-byte
segment, blank line terminated the block, single 396-byte body read relayed.

**Not yet exercised:**

- Responses larger than 8 KiB — the multi-chunk path where the pending buffer
  drains and the loop continues reading from the socket. Logic is unchanged in
  shape from Phase 1, but it is untested here.
- POST uploads — the checked `write_sock()` body-send path (2.6).

Both need an app endpoint with a large response or a form handler. This is the
main residual risk of the phase.

Also observed incidentally: an unrelated scanner request appeared in the access
log as `"MGLNDD_108.162.165.126_80\n" 400` — Apache rejected it correctly, no
action needed.

## Not covered in Phase 2

Phases 3–5 remain: the correctness sweep (1.7–1.9, 1.6 caveat, 2.2–2.3, 2.5,
2.8–2.10, 2.12–2.16, 3.6, 3.7), config/balancing (3.4, 3.5, 2.13, 4.1, 4.2), and
enhancements/build/docs.
