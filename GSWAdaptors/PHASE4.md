# mod_gsw (Apache2 adaptor) — Phase 4 Changes

Phase 4 of the fix plan (`~/.opencode/plan/mod_gsw-fixes.md`): the
config/balancing phase. All changes are confined to `GSWAdaptors/Apache2/`:
`gsw_private.h`, `gsw_cmds.c`, `gsw_config.c`, `gsw_apps.c`, `gsw_shm.c`,
`gsw_lifecycle.c`, `gsw_handler.c`, `gsw_status.c`, and `mod_gsw.c`, plus a
documentation update in `GSWAdaptors/README.txt`.

## Summary table

| Item | Change |
|------|--------|
| **3.4** | `read_shared_mem()` no longer copies the entire shared-memory segment under the global mutex on every request. New signature `(pool, count, indexes)` copies only the requested `exipc_data` entries; the mutex is held only for the copy |
| **3.5** | `find_app_by_name()` no longer linearly scans every configured app per request. A name → instance-list index (`gsw_cfg->app_index`, an `apr_table` of lower-cased names) is built once at config time; per-request lookup is O(instances of that app) |
| **2.13** | The process-global `instance_count` / `last_app_index` are now fields of the server-level `gsw_cfg`, so multiple module configs (vhosts) cannot clobber each other |
| **4.1** | New directives: **`WORetryCount`** (default 3) and **`WOBalancer`** (`lowest-load` \| `round-robin`, default `lowest-load`) |
| **4.2** | Round-robin balancing: unpinned requests rotate through an app's instances, skipping unreachable/refusing ones; the counter lives in `gsw_cfg` so each vhost/location balances independently |
| **bonus** | `set_App` rejects two `App` directives on the same `Host:port` with a config error (the shared-memory slot would have been silently shared) |
| **bonus** | `gsw_merge_dir_config` / `gsw_merge_server_config` now copy the tuning knobs (`connect_timeout`, `wait_timeout`, `max_body_size`, `retry_count`, `balancer`) from the child config — previously a `<VirtualHost>` or `<Location>` override of e.g. `WOMaxBodySize` was silently dropped |

## Details

### 3.4 — Per-request shared-memory copy (`gsw_shm.c`)

The old `read_shared_mem()` copied the *entire* shm segment (sized by
`InstanceCount`) into a pool buffer while holding the global mutex, on every
request that needed statistics. With a large `InstanceCount` that is a
multi-megabyte copy per request, serialized on one mutex.

It now takes the list of entries actually needed:

```c
void * read_shared_mem(apr_pool_t * pool, int count, const u_int16_t * indexes);
```

and copies exactly those `exipc_data` slots (by `total_index`) into a
pool-allocated array. The mutex is still held for the copy, but the critical
section is `count * sizeof(exipc_data)` instead of the whole segment.

Callers:

- `gsw_apps.c` builds the index array from the app's own instances before
  reading (one entry per instance of *that* app).
- `gsw_status.c` (`showApps`) builds the index array in table order, one
  entry per configured instance.

### 3.5 — Name index (`gsw_apps.c`, `gsw_lifecycle.c`)

`find_app_by_name()` scanned the whole `app_table` with `strcasecmp` on every
unpinned request — O(all configured instances) per request. A new
`gsw_build_app_index(gsw_cfg *)` (called from `gsw_post_config` after the shm
is initialized) builds `gsw_cfg->app_index`: an `apr_table` mapping
lower-cased app name → `apr_array_header_t` of `gsw_app_conf *`. The lookup
now lower-cases the request's app name and does one `apr_table_get`, then
iterates only that app's instances.

### 2.13 — Bookkeeping in the config, not in globals (`gsw_private.h`, `gsw_cmds.c`, `gsw_lifecycle.c`, `mod_gsw.c`)

`instance_count` and `last_app_index` were file-scope globals in
`gsw_cmds.c`, reset in `gsw_register_hooks()`. With more than one `gsw_cfg`
(vhosts) they could not be per-config. They are now fields of `gsw_cfg`,
initialized in both config creators (`gsw_create_dir_config` /
`gsw_create_server_config`), and deliberately *not* copied by the merge
functions — they are bookkeeping cells of the server-level config, not
user-settable knobs. `gsw_register_hooks()` no longer resets anything.

### 4.1 — `WORetryCount` and `WOBalancer` (`gsw_cmds.c`, `gsw_private.h`, `gsw_config.c`)

- `WORetryCount <number>` — how many times the handler retries a request whose
  backend was unreachable (re-resolving the app between attempts). Parsed with
  `apr_parse_int64`, validated to 1–100. Default 3 (the old hard-coded value).
- `WOBalancer lowest-load|round-robin` — case-insensitive. Default
  `lowest-load` (the existing behaviour).

Both are `RSRC_CONF` `AP_INIT_TAKE1` handlers registered in `gsw_cmds` next to
the existing directives, with `DEFAULT_RETRY_COUNT` / `DEFAULT_BALANCER`
defines beside the other `DEFAULT_*` macros in `gsw_private.h` and defaults set
in **both** config creators.

### 4.2 — Round-robin (`gsw_apps.c`)

With `WOBalancer round-robin`, unpinned requests rotate through the app's
instances in table order via `gsw_cfg->rr_counter` (one counter per config, so
each vhost/location balances independently). Instances marked unreachable or
refusing are skipped; if none is reachable the single best candidate is used
as before. Pinned requests (instance number in the URL) bypass balancing
entirely, per the load-balancing semantics in `Doc/LoadBalancing.md` —
including pinned requests to a refusing instance, which must still go through.

### Bonus — duplicate `Host:port` rejected (`gsw_cmds.c`)

`set_App` now scans the existing table for an entry with the same `host_name`
and `port` and returns a config error. Two `App` directives on the same
host:port would have been assigned the same shared-memory slot and silently
corrupted each other's statistics.

### Bonus — merge functions copy the tuning knobs (`gsw_config.c`)

`gsw_merge_dir_config` previously copied only `showApps` and `app_table`; a
`WOMaxBodySize` (or any other knob) set in a `<Location>` or `<VirtualHost>`
was silently dropped. It now copies all knobs from the child config, and
`gsw_merge_server_config` likewise copies `retry_count` / `balancer`.

## Configuration plumbing

- New `gsw_cfg` fields: `retry_count` (int), `balancer` (int,
  `BALANCER_LOWEST_LOAD` / `BALANCER_ROUND_ROBIN`), `rr_counter` (int),
  `app_index` (`apr_table_t *`). The old `RETRY_COUNT` define is replaced by
  the two `BALANCER_*` values.
- `gsw_private.h` includes `<ctype.h>` for `tolower` (used by the name index).
- `set_inst_count` now validates `v > 0` and enforces "only allowed once" by
  checking `cfg->instance_count != DEFAULT_APP_COUNT` instead of a global.
- `set_App` casts the parsed port: `appConf->port = (u_int16_t) atoi(portStr);`

## Documentation

`GSWAdaptors/README.txt` (the only documentation file changed): the Directives
section gained `WORetryCount` and `WOBalancer` with their defaults.

## Build fixes (surfaced on the FreeBSD box)

- **`no member named 'pool' in 'struct gsw_cfg'`** — `gsw_build_app_index()`
  allocates the name index from the pool the cfg was created from, but
  `gsw_cfg` did not keep a pointer to it. `gsw_cfg` now has a `pool` field,
  set in both config creators.
- **`expression is not assignable`** on `apr_array_push(list) = …` —
  `apr_array_push()` returns a `void *`, which is not assignable; the
  element is now assigned through a dereference
  (`*(gsw_app_conf **) apr_array_push(list) = appconf;`).

## Runtime fix (surfaced in live testing)

- **Unpinned requests returned 404** — `find_app_by_name()` looks up
  `cfg->app_index`, but requests see the *per-directory* config
  (`our_dconfig`), and `gsw_build_app_index()` only ran on the server-level
  config in `gsw_post_config()`. The per-dir cfg's index was never built, so
  every unpinned request (`/wo/<App>.woa/...` without an instance number)
  failed to resolve. Pinned requests bypass the index (direct `app_table`
  lookup), which is why they worked. The index is now built lazily on first
  use in `find_app_by_name()` (the cfg's pool is the config pool, so the
  index and the `app_table` entries it points into share a lifetime); an
  `app_index_built` flag in `gsw_cfg` makes it a one-time cost per config.

## Verification

Build on the FreeBSD box:

```sh
cd GSWAdaptors/Apache2
gmake clean && gmake
apachectl configtest
```

Functional tests to run on the FreeBSD box (Apache 2.4):

| Test | Expect |
|------|--------|
| `/wo/<App>.woa/1/wo/` — pinned request | 200, unchanged behaviour |
| `/wo/<App>.woa/wo/` — unpinned, default balancer | 200, lowest-load selection |
| `WOBalancer round-robin` in config, then several unpinned requests | 200, requests rotate across instances (check `/wo/showapps` "Last Request" columns) |
| `WORetryCount 1` in config, backend instance stopped | request fails after one attempt (504), no extra retries in the log |
| Two `App` directives with the same `Host=host:port` | `apachectl configtest` fails with a duplicate host:port error |
| `WOBalancer bogus` | config error (invalid value) |
| `WORetryCount 0` / `WORetryCount 101` | config error (out of range) |
| `/wo/showapps` | 200, table intact (exercises the new `read_shared_mem` path) |

## Not covered in Phase 4

Phase 5 remains: the sample-module leftovers in `gsw_cfg` (`cmode`, `local`,
`congenital`, `trace`, `loc`), the remaining build/docs items, and the full
README rewrite.
