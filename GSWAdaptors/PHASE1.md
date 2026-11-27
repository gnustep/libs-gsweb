# mod_gsw (Apache2 adaptor) — Phase 1 Changes

Phase 1 of the fix plan (`~/.opencode/plan/mod_gsw-fixes.md`): the low-risk,
isolated security and correctness bugs. All changes are in
`GSWAdaptors/Apache2/mod_gsw.c`, plus a documentation update in
`GSWAdaptors/README.txt`.

## Summary table

| Item | Fix |
|------|-----|
| **1.1** | `send_headers()` now writes the `fixRequestString()` result directly — no more 512-byte `strncpy` truncation of the request line |
| **1.2** | `connect_host()` checks the actual `socket()` return value (was testing the literal `0`); every failure path closes the fd |
| **1.3** | Replaced `gethostbyname()`/`inet_aton` with `getaddrinfo()` (`AF_UNSPEC`); iterates all results so IPv6-only hosts work |
| **1.4** | Non-blocking connect + `apr_poll` with a timeout; checks `SO_ERROR` for deferred failures; falls back to a plain blocking connect if `fcntl` fails. New directive **`WOConnectTimeout`** (default 5 s) |
| **1.5** | `read_sock_line()` polls with a deadline before each byte read. New directive **`WOWaitTimeout`** (default 60 s) |
| **1.6** | `WOMaxBodySize` (default 8 MiB): `read_post_data()` refuses to buffer larger bodies, `gsw_handler()` returns **413**. `get_content_len()` uses `apr_parse_int64` with range check instead of `atoi` |
| **2.1** | `find_app()`: `strncpy` now NUL-terminates (`sizeof-1` + explicit `'\0'`) |
| **2.4** | Status line parsed with `sscanf(newBuf, "HTTP/%*d.%*d %d", ...)` instead of truncating at byte 12 |
| **2.11** | `mark_unreachable` / `mark_refusing` / `update_app_statistics` all check `apr_shm_baseaddr_get()` for NULL before dereferencing |
| **2.15** | `gsw_create_server_config()` creates `app_table` (and the new timeout/size defaults), like the dir-config creator |

## Details

### 1.1 — Request-line truncation in `send_headers()`

The old code copied the request line into a 512-byte stack buffer with
`strncpy`. `fixRequestString()` returns a heap string of unbounded length
(it embeds the full URI path + query), so any request line longer than 512
bytes was silently truncated before being sent to the backend — a
request-smuggling / path-manipulation surface.

The fix writes the `fixRequestString()` result directly with
`write_sock(soc, reqLine, strlen(reqLine), r)`. No fixed buffer.

### 1.2 — `connect_host()` never checked `socket()`

```c
sock = socket(AF_INET, SOCK_STREAM, 0);
if (socket < 0) { ... }   // BUG: tests the literal 0, never the fd
```

The condition tested the literal `0`, so a failed `socket()` call
(`sock == -1`) flowed on into `setsockopt`/`connect`. The rewrite checks
`sock < 0` and closes the fd on every failure path.

### 1.3 — `gethostbyname()` → `getaddrinfo()`

`gethostbyname()` is deprecated, not thread-safe, and IPv4-only (an
IPv6-only backend host was silently broken). The rewrite uses
`getaddrinfo()` with `AF_UNSPEC` and iterates all returned addresses,
trying each with `socket()`/`connect()` until one succeeds. This makes
IPv6 backend hosts work.

### 1.4 — Connect timeout (`WOConnectTimeout`)

`connect()` previously blocked indefinitely; a blackholed backend IP
(SYN dropped) hung the worker forever — a DoS vector under prefork.

The connect is now done non-blocking (`O_NONBLOCK` via `fcntl`) and
completed by `apr_poll()` with a timeout. After the socket becomes
writable, `SO_ERROR` is checked for a deferred connect failure. If
`fcntl` itself fails, the code falls back to a plain blocking connect
(same behaviour as before, so nothing regresses on exotic platforms).

New directive:

```
WOConnectTimeout <seconds>   # default 5
```

### 1.5 — Read timeout (`WOWaitTimeout`)

`read_sock_line()` (and the body-read loop that follows it) blocked
forever if the app accepted the connection but never responded. Each byte
read is now preceded by an `apr_poll()` against a per-call deadline
(`apr_time_now() + timeout`), so a silent backend aborts the request
instead of hanging the worker.

New directive:

```
WOWaitTimeout <seconds>      # default 60
```

### 1.6 — Bounded POST body buffering (`WOMaxBodySize`)

`read_post_data()` allocated `clength + 1` bytes from a client-controlled
`Content-Length`; a client could send `Content-Length: 500000000` and
exhaust worker memory before the app was ever contacted.

- `read_post_data()` now compares the length against `WOMaxBodySize`
  (default 8 MiB) and returns NULL above it.
- `gsw_handler()` returns **413 Payload Too Large** in that case.
- `get_content_len()` now parses with `apr_parse_int64()` and a range
  check instead of `atoi()` (which wraps huge values to negative).

New directive:

```
WOMaxBodySize <bytes>        # default 8388608 (8 MiB)
```

### 2.1 — `find_app()` `strncpy` without NUL termination

```c
strncpy(app_name, appName, sizeof(app_name));   // 128 bytes
```

If the app name was ≥ 128 chars, `app_name` was left without a NUL
terminator, so the later `strcasecmp`/`snprintf` reads ran out of bounds.
Now: `strncpy(app_name, appName, sizeof(app_name) - 1);
app_name[sizeof(app_name) - 1] = '\0';`

### 2.4 — Status-line parsing

The old code truncated the status line at byte 12 and did
`atoi(newBuf + 9)`, which only works for 3-digit statuses in a
`HTTP/1.x NNN` line. A `100`-continue or `HTTP/1.0` response was
misparsed. Now parsed with:

```c
sscanf(newBuf, "HTTP/%*d.%*d %d", &http_status)
```

A line that does not yield a status code is treated as an error
(DECLINED), same as before.

### 2.11 — NULL checks on the shared-memory base address

`mark_unreachable()`, `mark_refusing()` and `update_app_statistics()`
dereferenced the result of `apr_shm_baseaddr_get()` without checking it.
If the shm segment was gone, `mem` was NULL → segfault. All three now
check `if (mem)` before writing.

### 2.15 — `app_table` never created for server-level config

`gsw_create_server_config()` left `cfg->app_table` NULL. If `App` was
declared at server level (RSRC_CONF), `apr_table_elts(NULL)` crashed.
The table is now created there, exactly like in
`gsw_create_dir_config()`.

## Configuration plumbing

- Three new fields in `gsw_cfg`: `connect_timeout` (`apr_time_t`),
  `wait_timeout` (`apr_time_t`), `max_body_size` (`apr_off_t`).
- Defaults (`DEFAULT_CONNECT_TIMEOUT` = 5 s, `DEFAULT_WAIT_TIMEOUT` = 60 s,
  `DEFAULT_MAX_BODY_SIZE` = 8 MiB) are set in **both**
  `gsw_create_dir_config()` and `gsw_create_server_config()`.
- Three new `AP_INIT_TAKE1` command handlers
  (`set_connect_timeout`, `set_wait_timeout`, `set_max_body_size`), all
  `RSRC_CONF`. Values are validated with `apr_parse_int64()` (whole
  seconds / plain bytes, no suffixes, no negatives) and rejected with a
  config error otherwise.
- Registered in `gsw_cmds` next to the existing `ShowApps`, `App` and
  `InstanceCount` directives.
- `connect_host()` and `read_sock_line()` gained a `timeout` parameter,
  passed from the per-request config in `handle_request()`.

## Documentation

`GSWAdaptors/README.txt` was updated (the only documentation file changed):
the original content (LoadModule line, `App` example, app launch,
`/wo/showapps`, 504 behaviour) is kept, and a **Directives** section was
added documenting `ShowApps`, `App`, `InstanceCount` and the three new
`WO*` directives with their defaults.

## Not covered in Phase 1

The remaining plan items (I/O-path rewrites 3.x, the other correctness
bugs 2.2–2.3, 2.5–2.10, 2.12–2.14, 2.16, the remaining security items
1.7–1.10, new directives `WORetryCount`/`WOBalancer`, build fixes, and
the full README rewrite) are Phases 2–5.
