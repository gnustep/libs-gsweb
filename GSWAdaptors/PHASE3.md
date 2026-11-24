# mod_gsw (Apache2 adaptor) — Phase 3 Changes

Phase 3 of the fix plan (`~/.opencode/plan/mod_gsw-fixes.md`): the correctness
sweep. All changes are confined to `GSWAdaptors/Apache2/`: `gsw_apps.c`,
`gsw_shm.c`, `gsw_config.c`, `gsw_handler.c`, `gsw_status.c`, `gsw_request.c`,
`gsw_cmds.c`, `gsw_lifecycle.c`, and `gsw_private.h` (new shared prototype and
body-status defines).

## Summary table

| Item | Change |
|------|--------|
| **1.7** | `set_App` rejects `App Name=` / `Host=` values ≥ 64 chars with a config error instead of silently truncating them (truncation broke the table key lookup); also rejects hosts without a `:port` |
| **1.8** | `showApps` HTML-escapes app and host names before printing them into the table |
| **1.9** | The shm backing file is `fchmod`'d to 0600 after `apr_shm_create()` (was world-readable/writable 0644) |
| **1.6 caveat** | `read_post_data()` now returns a status (`GSW_BODY_OK` / `GSW_BODY_TOO_LARGE` / `GSW_BODY_ABORTED`) and hands the buffer back via a `void ** postdata` out-param, so the handler can tell 413 from 400 while still relaying the body |
| **2.2** | Instance `0` is accepted (the old `atoi` + `> 0` check rejected a valid instance number) |
| **2.3 / 3.6** | New shared `gsw_parse_uri()` in `gsw_apps.c`, used by both `find_app()` and `fixRequestString()` so the two parsers cannot drift apart. **Behaviour change:** the app segment must end in `.woa` (the old `index()`-based parse accepted any name) |
| **2.5** | `handle_request()` destroys `sub_pool` on every exit path (was leaked on the success path) |
| **2.8** | `fixRequestString()` rewrites the request line as `"%s %s HTTP/1.1\r\n"` using the parsed URI; non-matching URIs pass through untouched |
| **2.9** | Any backend status ≥ 100 (except 200 → OK) is copied to `r->status` instead of the old fixed mapping |
| **2.10** | Retry loop documented (which failures retry, which do not) |
| **2.12** | `update_app_statistics()` also clears `refusing = 0` (a recovered app was left refusing forever) |
| **2.14** | `gsw_merge_server_config` copies `app_table` (via `apr_table_copy`) plus `connect_timeout` / `wait_timeout` / `max_body_size` / `showApps` from the vhost config, mirroring `gsw_merge_dir_config` |
| **2.16** | `gsw_handler()`: `find_app()` returning NULL now yields **404** (was 504) |

## Details

### 1.7 — `set_App` silently truncated long names (`gsw_cmds.c`)

`App Name=... Host=...` values were copied with `strncpy` into
`MAX_NAME_LENGTH` (64) buffers without a length check. A name ≥ 64 chars was
silently truncated, and the truncated string then failed the `apr_table` key
lookup — i.e. the app was registered under a key that no request URI would ever
match, and the misrouting was invisible. `set_App` now rejects over-long
`app_name` / `host_name` with a config error, rejects hosts without a `:` port,
and NUL-terminates explicitly after the `strncpy`.

### 1.8 — `showApps` HTML injection (`gsw_status.c`)

App and host names come from the Apache config file and were printed verbatim
into the status table. A name containing `<` or a quote would break out of the
table markup. New static `html_escape()` escapes `& < > " '`; the names are
escaped into `MAX_NAME_LENGTH * 6` buffers before printing.

### 1.9 — shm file permissions (`gsw_lifecycle.c`)

`apr_shm_create()` leaves the backing file at the default 0644: any local user
could read or write the live per-app statistics. After creation the file is
`open()`'d and `fchmod(fd, 0600)`'d.

### 1.6 caveat — 413 vs 400 in `read_post_data()` (`gsw_request.c`, `gsw_private.h`)

`read_post_data()` previously returned the buffer pointer and signalled
"too large" by returning NULL — indistinguishable from a client abort. It now
returns an `int` status (`GSW_BODY_OK` / `GSW_BODY_TOO_LARGE` /
`GSW_BODY_ABORTED`) and returns the buffer through a `void ** postdata`
out-param. The buffer is still handed back because `handle_request()` relays it
to the backend on every retry; the status is only used by `gsw_handler()` to
choose **413** (too large) vs **400** (aborted).

### 2.2 — Instance 0 rejected (`gsw_apps.c`)

The old parse used `atoi()` and required the result to be `> 0`, so instance
`0` — a valid number — was treated as "no instance". The new parser uses
`strtol` and accepts 0–65535.

### 2.3 / 3.6 — one shared URI parser (`gsw_apps.c`)

`find_app()` and `fixRequestString()` each had their own hand-rolled parse of
`/wo/<App>.woa/<instance>/<rest>`, and they had drifted apart. Both now call a
single `gsw_parse_uri()` (declared in `gsw_private.h`), which:

- requires the URI to start with the configured location prefix;
- requires the app segment to end in `.woa` — **this is a behaviour change**:
  the old `index()`-based parse accepted any app name, so a config with a
  non-`.woa` app name will stop matching. All documented usage is `.woa`;
- parses the optional instance segment with `strtol` (0–65535);
- accepts `/wo/<App>.woa` with no trailing path (empty rest);
- fails (rather than silently truncating) if the rest does not fit the
  caller's buffer;
- does not mutate the caller's string.

**Bug found in testing:** the first version located the `.woa` dot with
`strrchr(p, '.')`, which searches the *entire remainder* of the URI, not just
the app segment. Any dot in a later path component (e.g.
`/wo/DynamicElements.woa/1/wo/<session>/0.1.6.1`) made the parse fail and the
request 404. The dot search is now bounded to the app segment with
`memchr(p, '.', slash - p)`.

`fixRequestString()` rebuilds the request line from the parsed parts, with the
instance number of the app the request was actually routed to (not the client's).

### 2.5 — Pool leak on the success path (`gsw_request.c`)

`handle_request()` created a `sub_pool` per attempt but only destroyed it on
the error paths. It is now destroyed on every exit path (normal, internal
error, unreachable, and the `reader == NULL` guard).

### 2.8 — Request-line rewrite (`gsw_request.c`)

`fixRequestString()` now uses `gsw_parse_uri()` on `r->uri` and rebuilds the
request line as `"%s %s HTTP/1.1\r\n"`. URIs that do not match the grammar pass
through untouched.

### 2.9 — Status mapping (`gsw_request.c`)

Any backend status ≥ 100 (except 200 → `HTTP_OK`) is copied to `r->status`
instead of the old fixed mapping, so a 503 from the backend is a 503 to the
client.

### 2.10 — Retry loop documented (`gsw_handler.c`)

The retry loop is now documented: which failures retry (connect refused /
unreachable) and which do not (a completed response, a body read failure).

### 2.12 — Stuck `refusing` flag (`gsw_shm.c`)

`update_app_statistics()` now also clears `refusing = 0`. A recovered app was
otherwise left refusing forever after a single refusal.

### 2.14 — VirtualHost merge lost the app table (`gsw_config.c`)

`gsw_merge_server_config` copied only `local` / `loc`. It now also copies
`app_table` (via `apr_table_copy`) plus `connect_timeout` / `wait_timeout` /
`max_body_size` / `showApps` from the vhost config, mirroring
`gsw_merge_dir_config`. An `App` directive inside a `<VirtualHost>` is no
longer silently dropped.

### 2.16 — 504 vs 404 (`gsw_handler.c`)

`find_app()` returning NULL (no such app) now yields **404** instead of 504.
504 is reserved for "app exists but did not answer".

## Build fixes (surfaced on the FreeBSD box)

- **`HTTP_PAYLOAD_TOO_LARGE` undeclared** — `httpd.h` does not include
  `http_status.h`, and the 413 macro was renamed between Apache 2.2
  (`HTTP_REQUEST_ENTITY_TOO_LARGE`) and 2.4 (`HTTP_PAYLOAD_TOO_LARGE`).
  `gsw_private.h` now defines the three status macros we use, each
  `#ifndef`-guarded so it is harmless if a future Apache provides them.
- **`fchmod` implicitly declared** — on FreeBSD an Apache header un-`#define`s
  a standard-library feature macro (e.g. `_POSIX_C_SOURCE`), which silently
  drops `fchmod()` from `<unistd.h>` even though `gsw_private.h` includes it;
  re-including `<unistd.h>` does not help because its include guard is already
  set. `gsw_lifecycle.c` now includes `<sys/stat.h>` (the canonical home of
  `fchmod()` per the FreeBSD man page, and not feature-gated) after the Apache
  headers. The original single-file `mod_gsw.c` had the same include order but
  never called `fchmod()`, so this only surfaced with the 1.9 fix.

## Verification

Build on the FreeBSD box:

```sh
cd GSWAdaptors/Apache2
gmake clean && gmake
apachectl configtest
```

Then exercise:

- `/wo/<App>.woa/...` — normal request path (2.3/2.8/2.9/2.16)
- `/wo/<App>.woa/0/...` — instance 0 (2.2)
- `/wo/<App>.woa` — no trailing path (2.3)
- `/wo/<App>.woa/<instance>/.../0.1.6.1` — a dot in the rest of the path must
  not break the parse (the `strrchr` bug above)
- `/wo/showapps` — escaped table (1.8)
- a POST larger than `WOMaxBodySize` — expect **413**, not 400 (1.6 caveat)
- an `App` directive inside a `<VirtualHost>` — expect it to be honoured (2.14)
- `ls -l` the shm file in the temp dir — expect `-rw-------` (1.9)
