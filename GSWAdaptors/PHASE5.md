# mod_gsw (Apache2 adaptor) — Phase 5 Changes

Phase 5 of the fix plan (`~/.opencode/plan/mod_gsw-fixes.md`): the
enhancements + build + docs phase. All changes are confined to
`GSWAdaptors/Apache2/` (`gsw_private.h`, `gsw_cmds.c`, `gsw_config.c`,
`gsw_apps.c`, `gsw_lifecycle.c`, `gsw_handler.c`, `gsw_status.c`,
`gsw_request.c`, `mod_gsw.c`, `GNUmakefile.in`, `configure.ac`, and the
deletion of `gsw_hooks_stub.c`), plus documentation updates in
`GSWAdaptors/README.txt` and `GSWAdaptors/Doc/ConfigurationFile.html`.

## Summary table

| Item | Change |
|------|--------|
| **4.3** | New machine-readable status endpoint **`/wo/status`** answering JSON (`showStatusJson()` in `gsw_status.c`, dispatched from `gsw_handler.c`); the `?format=json` query argument is accepted but not required. Proper JSON string escaping (the old code ran the names through `html_escape()`, which emits HTML entities like `&amp;` verbatim in JSON) |
| **4.4** | Connection pooling/reuse to the backend: **deliberate non-goal** — documented in code (`gsw_request.c`) and in `README.txt`; may be revisited in a future version |
| **4.5** | The one-shot backend connection is now made explicit: `send_headers()` appends `Connection: close` to the backend request, and the client's own `Connection` header is never forwarded (a client `keep-alive` would contradict it). Documented in `README.txt` |
| **4.6** | Dead code removed: `gsw_hooks_stub.c` deleted (14 sample-module hook stubs + trace machinery); hook registrations in `mod_gsw.c` trimmed to the 5 that are used; 14 stub prototypes, the trace-cell externs, the stale `gsw_build_app_index` prototype, the sample-record `gsw_cfg` fields (`cmode`/`local`/`congenital`/`trace`/`loc` + `CONFIG_MODE_*` macros), `cmd_gsw`, and `print_app` all removed; `gsw_hooks_stub.c` dropped from `GSW_SRCS` |
| **4.7** | DEBUG logging for load-balancing diagnostics: routing line before connect (`gsw: routing %s %s to %s:%u (instance %u)`), end-of-request line extended with backend host:port + instance + status, and a 504-outcome line after the retry loop in `gsw_handler.c` |
| **4.8** | Symbol prefixing via `-fvisibility=hidden` in `GSW_CFLAGS` (`GNUmakefile.in`); `gsw_module` is the only exported symbol (explicit `__attribute__((visibility("default")))` on the definition, so it works on both Apache 2.2 and 2.4) |
| **5.1** | `configure.ac`: `==` → `=` in the `SERVERAPI` test (POSIX sh) |
| **5.3** | `GNUmakefile.in`: missing backslash in the `install` recipe fixed (the `echo` lines never ran); `clean` also removes `*.la` |
| **6.1** | `README.txt`: documents `/wo/status`, VirtualHost guidance (everything works per-vhost since 2.13/2.14), the 413/`LimitRequestBody` interaction, and the one-shot backend connection |
| **6.2** | `Doc/ConfigurationFile.html`: NOTE added at the top that it describes the legacy Apache 1.3 property-list format and is outdated; rest untouched |
| **bonus** | `apr_time_t` unit fix: `exipc_data.last_request_time` / `last_response_time` are microseconds but were passed directly to `apr_ctime()` (which wants seconds) and emitted raw in the JSON — both paths now divide by 1000000 |

## Details

### 4.3 — Machine-readable status endpoint (`gsw_status.c`, `gsw_handler.c`, `gsw_private.h`)

`showStatusJson()` serves the same data as the HTML `/wo/showapps` page as
JSON, at `/wo/status`:

```json
{
  "showApps": true,
  "apps": [
    {
      "name": "MyApp",
      "instance": 1,
      "host": "127.0.0.1",
      "port": 8080,
      "load": 3,
      "unreachable": false,
      "refusing": false,
      "lastRequest": 1699999999,
      "lastResponse": 1699999999
    }
  ]
}
```

- `lastRequest` / `lastResponse` are epoch seconds; `0` means "never"
  (matching the HTML page's "never").
- Like the HTML page, the app list is only included when `ShowApps` is on;
  otherwise `"showApps"` is `false` and `"apps"` is `[]`.
- The `?format=json` query argument is accepted for symmetry with other
  status endpoints but is not required — the endpoint always answers JSON.
- Dispatch: `gsw_handler.c` checks `/wo/status` right after the
  `/wo/showapps` branch.
- JSON escaping: `app_name` and `host_name` come from the Apache config
  file, so the characters that can break a JSON string are `"`, `\`, and
  control characters. The old code ran them through `html_escape()` (which
  emits HTML entities like `&amp;` that would appear verbatim in the JSON)
  and then replaced `"` with `'`. The new code escapes `"`/`\` with a
  backslash and control characters as `\u00XX`.

### 4.4 — Connection reuse to the backend: deliberate non-goal

A per-worker pool of backend sockets (keyed by host:port) would eliminate
the per-request TCP handshake, but it is a much larger change: pool
lifetime management, backend-side keepalive timeouts, and interaction with
the retry/unreachable logic. It is documented as a deliberate non-goal in
`gsw_request.c` (where the socket is closed after every response) and in
`README.txt`; it may be revisited in a future version.

### 4.5 — `Connection: close` to the backend (`gsw_request.c`)

The module always sends `HTTP/1.1` to the backend and always closes the
socket after the response. This is now made explicit:

- `send_headers()` appends `Connection: close` to the header block sent to
  the backend. This saves the backend from keeping the socket open waiting
  for a follow-up request that will never come, and makes the one-shot
  nature of the connection visible in the backend's own logs.
- The client's own `Connection` header is skipped in the forwarding loop
  (case-insensitive match) — a client `keep-alive` would contradict the
  `close` we send.

### 4.6 — Dead code removal

- **`gsw_hooks_stub.c` deleted.** All 14 sample-module hook stubs
  (`gsw_insert_filter`, `gsw_quick_handler`, `gsw_pre_connection`,
  `gsw_process_connection`, `gsw_post_read_request`, `gsw_translate_handler`,
  `gsw_map_to_storage_handler`, `gsw_header_parser_handler`,
  `gsw_check_user_id`, `gsw_auth_checker`, `gsw_access_checker`,
  `gsw_type_checker`, `gsw_fixer_upper`, `gsw_logger`) plus the sample trace
  state (`trace`, `static_calls_made`, `gsw_pool`, `gsw_subpool`,
  `setup_module_cells`) lived in this one file after the split.
- **`mod_gsw.c`**: `gsw_register_hooks()` now registers only the 5 hooks the
  module actually uses: `pre_config`, `post_config`, `open_logs`,
  `child_init`, `handler`.
- **`gsw_private.h`**: the 14 stub prototypes, the trace-cell externs, and
  the stale `gsw_build_app_index` prototype are gone; the sample-record
  `gsw_cfg` fields (`cmode`, `local`, `congenital`, `trace`, `loc`) and the
  `CONFIG_MODE_*` macros are gone.
- **`gsw_cmds.c`**: `cmd_gsw` (the "Example" directive handler, never
  declared in `gsw_cmds[]`) removed.
- **`gsw_apps.c`**: `print_app` (only called from a commented-out line)
  removed.
- **`gsw_config.c`**: both config creators and both merge functions cleaned
  of the removed sample-record fields.
- **`gsw_lifecycle.c`**: the `setup_module_cells()` call removed.
- **`GNUmakefile.in`**: `gsw_hooks_stub.c` dropped from `GSW_SRCS`.

### 4.7 — Logging (`gsw_request.c`, `gsw_handler.c`)

All at `APLOG_DEBUG` (no change to the default log level):

- Before connect: `gsw: routing %s %s to %s:%u (instance %u)` — which
  backend instance a request is being routed to.
- End of request (the existing timing line, extended):
  `gsw: %s %s -> %s:%u (instance %u) status %d, took %ld ms` — backend
  host:port, instance, the backend's HTTP status, and the elapsed time.
- After the retry loop in `gsw_handler.c` falls through:
  `gsw: %s %s failed after %d attempt(s), returning 504` — so the 504 is
  explainable in the log.
- In `mark_unreachable()` (`gsw_shm.c`): `gsw: marking %s instance %u
  (%s:%u) unreachable` — which instance was just flagged, and from which
  request.

### 4.8 — Symbol prefixing (`GNUmakefile.in`, `mod_gsw.c`, `gsw_private.h`)

The split made previously-`static` helpers globally exported, so they could
collide with symbols from other Apache modules in the same process. The
smaller fix (vs. renaming everything with a `gsw_` prefix) is:

- `-fvisibility=hidden` added to `GSW_CFLAGS` in `GNUmakefile.in` — every
  symbol of the module is hidden from the dynamic symbol table.
- `gsw_module` (the one symbol Apache looks up by name) is exported with an
  explicit `__attribute__((visibility("default")))` on the definition in
  `mod_gsw.c`. The attribute is written out rather than using
  `AP_MODULE_DECLARE_DATA` so the symbol is exported on Apache 2.2 as well.
- The extern in `gsw_private.h` is a plain `extern module gsw_module;` —
  the visibility attribute must be on the definition, not the declaration.

### 5.1 — `configure.ac` POSIX sh fix

```sh
if test x${SERVERAPI} == xApache2 ; then   # BUG: == is not POSIX sh
```

→

```sh
if test x${SERVERAPI} = xApache2 ; then
```

(`==` is a bashism; the neighbouring test at line 100 already used `=`.)
`configure` must be regenerated on the build box (see Verification).

### 5.3 — `GNUmakefile.in` install/clean fixes

- The `install` recipe was missing a trailing backslash after the
  `$(APXS) -i -n gsw $(ADAPTOR)` line, so the `echo` lines that follow were
  separate (empty) recipe lines and never ran. Fixed.
- `clean` now also removes `*.la` (it already removed `*.o *.lo *.slo` and
  `.libs`).

### 6.1 — `README.txt`

- `/wo/status` documented next to `/wo/showapps` (JSON, same data, app list
  only when `ShowApps` is on).
- VirtualHost guidance: since 2.13/2.14 (Phases 3/4) everything works
  per-vhost — the usual setup is to configure apps and timeouts once in the
  main config and let vhosts inherit; per-vhost directives override for
  that vhost only.
- `WOMaxBodySize` note: if Apache's own `LimitRequestBody` is smaller,
  Apache rejects the request before the adaptor ever sees it.
- One-shot backend connection: the adaptor opens a fresh connection per
  request, sends `Connection: close`, and closes it after the response; no
  connection pooling (see 4.4/4.5).

### 6.2 — `Doc/ConfigurationFile.html`

A NOTE was added at the top of the `<body>`: the page describes the legacy
Apache 1.3 adaptor (GNUstep property-list config via
`GSWeb_ConfigFilePath`); the current Apache 2.x adaptor is configured with
ordinary Apache directives in httpd.conf — see `README.txt`. The rest of
the file is untouched, per the plan.

### Bonus — `apr_time_t` unit fix (`gsw_status.c`, `gsw_private.h`)

Found while writing 4.3: `exipc_data.last_request_time` /
`last_response_time` are `apr_time_t` (microseconds since the epoch), but
the HTML status page passed them directly to `apr_ctime()` (which wants
seconds) and the new JSON emitted them raw. Both paths now divide by
1000000 (with a `> 0` guard in the HTML path so `0` prints "never"). The
`gsw_private.h` comment on the fields now says "microseconds since the
epoch" (it said "in sec since January 1, 1970"), and `gsw_private.h`
includes `<time.h>` for the `time_t` cast.

## Build / configuration plumbing

- `GNUmakefile.in`: `GSW_SRCS` no longer lists `gsw_hooks_stub.c`;
  `GSW_CFLAGS` gained `-fvisibility=hidden`; `install` backslash fixed;
  `clean` removes `*.la`.
- `configure.ac`: the `==` → `=` fix (5.1).
- `gsw_status.c`: the JSON `lastRequest`/`lastResponse` fields are formatted
  with `snprintf()` into small buffers and emitted with `ap_rprintf("%s")`
  instead of passing the number directly with `%lld` — `ap_rprintf()` does
  not reliably process `%lld` on every Apache/APR build (surfaced on the
  FreeBSD box: the literal `%ld` appeared in the output). `apr_time_t` is a
  signed 64-bit integer on every platform we build for, so the `long long`
  cast is safe.
- `gsw_request.c`: the client `Connection` header is matched with POSIX
  `strcasecmp()` (`<strings.h>` in `gsw_private.h`) instead of
  `apr_strcasecmp()` — the APR function is not declared on every APR
  release, and the implicit declaration would have assumed an `int` return
  (wrong on 64-bit).
- No new directives in this phase.

## Verification

Build on the FreeBSD box (both `configure.ac` and `GNUmakefile.in` changed,
so regenerate before building):

```sh
cd GSWAdaptors/Apache2
autoreconf -fi          # or: aclocal && autoconf  (regenerates configure)
./configure
./config.status         # regenerates GNUmakefile from GNUmakefile.in
gmake clean && gmake
apachectl configtest
```

Functional tests to run on the FreeBSD box (Apache 2.4):

| Test | Expect | Status |
|------|--------|--------|
| `gmake clean && gmake` after `autoreconf` + `./configure` + `./config.status` | builds clean, no warnings about `gsw_hooks_stub.c` | ✅ done (one warning fixed: `apr_strcasecmp` not declared on the box's APR → POSIX `strcasecmp`) |
| `apachectl configtest` | `Syntax OK` | ✅ done (module loads, Apache starts) |
| `apachectl -t -DAP_LOG_LEVEL=debug` (or `LogLevel debug` for the module) then one request | DEBUG log shows `gsw: routing ...` and `gsw: ... status ... took ... ms` lines | ⏳ pending (needs `LogLevel debug` in the config) |
| `curl http://.../wo/status` | 200, `Content-Type: application/json`, valid JSON (check with `python3 -m json.tool`) | ✅ done — valid JSON; `lastReq`/`lastResp` are real epoch seconds after a request |
| `curl http://.../wo/status` with `ShowApps off` | `"showApps": false`, `"apps": []` | ⏳ pending (needs a config change) |
| `curl http://.../wo/status?format=json` | same as `/wo/status` | ✅ done |
| `/wo/showapps` after the `apr_time_t` fix | "Last Request"/"Last Response" columns show plausible times (not 1970 / not year ~29200) | ✅ done — 200, plausible times |
| `/wo/<App>.woa/1/wo/` — pinned request | 200, unchanged behaviour (regression check for the `Connection: close` header + visibility flag) | ✅ done — 200 in ~10 ms |
| `/wo/<App>.woa/wo/` — unpinned request | 200, balanced (regression check) | ✅ done — 200 |
| Backend logs after a request | backend sees `Connection: close` in the request headers | ✅ done — `Connection: close` present in the client response |
| Stop a backend instance, send a request | 504 after `WORetryCount` attempts; DEBUG log shows the `failed after N attempt(s)` line | ✅ done — 504 in 15 ms; other app unaffected |
| `nm -D mod_gsw.so` (or `readelf --dyn-syms`) | only `gsw_module` (and standard C runtime symbols) exported; `find_app`, `connect_host`, etc. not in the dynamic symbol table | ✅ done — `readelf -s` shows `.dynsym` = `_init`, `_fini`, `gsw_module` only |

## Not covered in Phase 5

- **4.4** (connection pooling/reuse to the backend) is a deliberate
  non-goal for now — documented in code and in `README.txt`; it would be a
  much larger change (per-worker socket pool, lifetime management,
  backend-side keepalive timeouts) and may be revisited in a future version.
- **5.2** was already resolved (no dangling `mod_gsw.conf` reference).
- **5.4** / **5.5** were already resolved / n/a (see plan §5).

## Follow-up fix (found during verification)

**Failed connect never marked the instance unreachable.**  The
`unreachable` flag in shared memory was only set from the `unreachable:`
label in `handle_request()`, which is reached when the socket dies
*mid-request*.  A **failed connect** (port closed, timeout) logged a
WARNING, set `http_status = UNREACHABLE`, but never called
`mark_unreachable()` — so `find_app()` kept re-selecting the same dead
instance on every retry, and the `unreachable`/`refusing` flags in
`/wo/status` were effectively dead for the common "port closed" case.

Fixed:

- `gsw_request.c`: the connect-failure branch now calls
  `mark_unreachable(r, app)` and returns a new `BACKEND_DOWN` status
  (the old `UNREACHABLE` macro was removed; `BACKEND_DOWN` is the single
  status for "backend socket failed before any response was relayed").
- `gsw_handler.c`: the retry loop matches `BACKEND_DOWN` and re-resolves
  the app, so the next attempt lands on a live instance.
- `gsw_shm.c`: `mark_unreachable()` now always refreshes
  `last_request_time` (it is the age-out clock for the flag in
  `find_app_by_name()`; the old code only set it on the 0→1 transition,
  which would have left a permanently-down instance flagged forever).
  It also logs at DEBUG which instance was flagged.

**Verified on the box (rebuild with this fix):** with DynamicElements
down, the first request returns 504 in 9 ms and `/wo/status` shows
`"unreachable": true` for it.  After restarting the app, the next request
returns 200 in 13 ms and the flag clears to `"unreachable": false`.
