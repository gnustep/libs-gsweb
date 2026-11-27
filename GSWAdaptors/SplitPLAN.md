# PLAN: Split `mod_gsw.c` into smaller files

Goal: break the 2500-line `Apache2/mod_gsw.c` into focused source files and
one shared private header, **with no behavior change**. This is a pure
move-code refactor. Do not fix bugs, rename things or clean up in the same
step (see "Later cleanups" at the end).

Read `AGENTS.md` first and follow it where it conflicts with this plan.

## Ground rules

1. **Never hand-edit generated files**: `GNUmakefile`, `config.status`,
   `config.log`, `configure`. The sources of truth are `GNUmakefile.in`,
   `configure.ac`. Edit those, then regenerate (see "Build system").
2. **Build artifacts** (`mod_gsw.o/.lo/.la/.slo`, `.libs/`) are not sources.
   Run `gmake clean` before starting and after each step.
3. **Move one file at a time and build after every move.** If the build
   breaks, the last move is the culprit.
4. Move code verbatim. Only add `#include`s, remove `static` where a function
   is now used from another file, and add prototypes to the header.
5. Line numbers below refer to the current `mod_gsw.c` and will shift as code
   is removed. Locate code by **function name**, not line number.
6. Keep the license header from the top of `mod_gsw.c` on every new `.c`/`.h`.
7. Compiler is clang on FreeBSD: no GCC-only extensions, build must stay clean
   under `-Wall`.

## Target layout (all in `GSWAdaptors/Apache2/`)

| File | Contents (current function / lines) |
|---|---|
| `gsw_compat.h` | `apr_parse_int64` fallback (lines ~41-84); `MOD_EXIPC_SET_MUTEX_PERMS` define (~98-101); `ap_unixd_set_global_mutex_perms` shim for Apache < 2.4 (~1928-1934) |
| `gsw_private.h` | All includes (httpd, apr, POSIX), types `gsw_cfg`, `gsw_app_conf`, `exipc_data`, all `#define` constants (~105-237, `ADAPTOR_PREFIX` ~241), `extern` declarations of shared globals, **prototypes of every function used across files** |
| `gsw_config.c` | `our_dconfig`, `our_cconfig` (~284-298); `gsw_create_dir_config`, `gsw_merge_dir_config`, `gsw_create_server_config`, `gsw_merge_server_config` (~1710-1879); `app_count` (~1894) |
| `gsw_cmds.c` | `cmd_gsw`, `set_ShowApps`, `set_inst_count`, `set_connect_timeout`, `set_wait_timeout`, `set_max_body_size`, `set_App` (~1168-1338); the `gsw_cmds[]` table (~2460-2511); the `instance_count` / `last_app_index` globals |
| `gsw_shm.c` | globals `exipc_shm`, `shmfilename`, `exipc_mutex`, `mutexfilename` (~219-225); `read_shared_mem`, `mark_unreachable`, `mark_refusing`, `update_app_statistics` (~319-405); `init_shared_mem` (~1909) |
| `gsw_apps.c` | `print_app` (~249); `find_app_by_name`, `find_app` (~406-542) |
| `gsw_net.c` | `connect_host`, `write_sock`, `read_sock_line` (~543-738). Pure socket code, no Apache config dependencies except `request_rec` for logging |
| `gsw_request.c` | `send_header_string`, `fixRequestString`, `send_headers`, `read_post_data`, `handle_request` (~739-1167) |
| `gsw_status.c` | `print_image`, `print_css`, `showApps` (~1339-1533): the `showApps` status page |
| `gsw_handler.c` | `gsw_handler` (~1534-1709) |
| `gsw_lifecycle.c` | `gsw_pre_config`, `gsw_post_config`, `gsw_open_logs`, `gsw_child_exit`, `gsw_child_init` (~1880-2123), incl. the shared-memory/mutex creation inside `gsw_post_config` |
| `gsw_hooks_stub.c` | Leftover sample-module hooks that do nothing useful: `gsw_insert_filter`, `gsw_quick_handler`, `gsw_pre_connection`, `gsw_process_connection`, `gsw_post_read_request`, `gsw_translate_handler`, `gsw_map_to_storage_handler`, `gsw_header_parser_handler`, `gsw_check_user_id`, `gsw_auth_checker`, `gsw_access_checker`, `gsw_type_checker`, `gsw_fixer_upper`, `gsw_logger` (~2124-2400), plus the sample "trace" state (`trace`, `static_calls_made`, `gsw_pool`, `gsw_subpool`, `setup_module_cells`) |
| `mod_gsw.c` | **Only**: `#include "gsw_private.h"`, `gsw_register_hooks` (~2402), the `module AP_MODULE_DECLARE_DATA gsw_module = {...}` definition (~2512) |

Resulting sizes are roughly 100-450 lines each; `gsw_request.c` is the
biggest because of `handle_request` (~200 lines), which is fine.

## Shared-state rules

These are the traps in this particular file:

- **`gsw_module`**: currently forward-declared at ~239 and defined at the end.
  In `gsw_private.h` declare `extern module AP_MODULE_DECLARE_DATA gsw_module;`
  and define it **only** in `mod_gsw.c`.
- **Globals** (`exipc_shm`, `exipc_mutex`, `shmfilename`, `mutexfilename`,
  `instance_count`, `last_app_index`): define each in exactly one `.c`
  (see table), declare `extern` in `gsw_private.h`. Currently some are
  `static`, others not. Drop `static` only on the ones used from another file.
  - `instance_count` is written in `gsw_cmds.c`, read in `gsw_lifecycle.c`
    (`gsw_post_config`) and reset in `gsw_register_hooks`.
  - `last_app_index` is used in `set_App` and reset in `gsw_register_hooks`.
- **`trace` / `static_calls_made` / `gsw_pool` / `gsw_subpool`**: sample-module
  leftovers. `trace` is also a struct field name in `gsw_cfg` and is touched in
  the create/merge config functions, `cmd_gsw` and `gsw_child_exit`. Don't
  untangle that now. Keep the globals in `gsw_hooks_stub.c`, `extern` them in
  the header, and just make it compile.
- **`static` functions called across files** must lose `static` and get a
  prototype in `gsw_private.h`. Expected list: `our_dconfig`, `our_cconfig`,
  `write_sock`, `send_header_string`, `handle_request`, `showApps`,
  `app_count`, all `set_*`/`cmd_*` handlers (only if `gsw_cmds[]` lives in a
  different file than the handlers; with the layout above they don't, so
  they can stay `static`), the hook functions and the config
  create/merge functions (referenced from the module struct and
  `gsw_register_hooks` in `mod_gsw.c`).
- Functions that are only used inside their new file **stay `static`**.
- `#if (AP_SERVER_MAJORVERSION_NUMBER == 2) && (AP_SERVER_MINORVERSION_NUMBER < 4)`
  blocks (in `send_headers` and the mutex-perms shim) move together with the
  function they belong to. Keep the preprocessor conditions unchanged.
- `apr_parse_int64` fallback is `static`. If it goes in a header it must be
  `static` there and is only needed by whichever file calls it (likely
  `gsw_cmds.c`). Include `gsw_compat.h` only from that file to avoid
  unused-function warnings.

## Steps

### Step 0: baseline
1. `gmake clean && gmake` and confirm the current `mod_gsw.c` builds with the
   `poll()` patch. Save the resulting `mod_gsw.la` size/`nm -D` output of
   exported symbols for later comparison:
   `nm -g .libs/mod_gsw.so | grep ' T ' | sort > /tmp/symbols_before.txt`
2. Commit / back up the tree (`git` if used, otherwise `tar`).

### Step 1: build system first (still one source file)
Teach the build about multiple sources **before** moving any code, so each
later step is just "add file, move code".

1. Open `GNUmakefile.in` (not `GNUmakefile`). The `mod_gsw.la` rule currently
   runs `apxs -c -o mod_gsw.la <flags> ../Apache2/mod_gsw.c`. Introduce a
   variable and use it in the rule and in any clean/dependency lines:
   ```make
   GSW_SRCS = mod_gsw.c
   GSW_HDRS = gsw_private.h gsw_compat.h

   mod_gsw.la: $(GSW_SRCS) $(GSW_HDRS)
   	$(APXS) -c -o mod_gsw.la <existing flags> $(GSW_SRCS)
   ```
   `apxs -c` accepts several `.c` files and links them into one module.
   Keep the existing `-I.` so `#include "gsw_private.h"` resolves.
   (Mind the existing `../Apache2/mod_gsw.c` path style: keep whatever
   relative-path convention the rule uses today.)
2. Extend the `clean` target to remove `*.o *.lo *.slo *.la .libs`.
3. Regenerate: `./config.status` (re-creates `GNUmakefile` from
   `GNUmakefile.in`). Only rerun `./configure` if `configure.ac` changed.
4. `gmake clean && gmake` must still succeed with the unchanged single file.

### Step 2: headers
1. Create `gsw_compat.h` and `gsw_private.h` from the code listed above.
   Use include guards. Put `extern` declarations and prototypes in
   `gsw_private.h`.
2. In `mod_gsw.c` replace the moved declarations with
   `#include "gsw_private.h"`. Build.

### Step 3: move leaf modules first (least dependencies → most)
Move in this order, building after each:
1. `gsw_net.c` (no module state)
2. `gsw_shm.c`
3. `gsw_apps.c`
4. `gsw_status.c`
5. `gsw_request.c`
6. `gsw_cmds.c`
7. `gsw_config.c`
8. `gsw_handler.c`
9. `gsw_lifecycle.c`
10. `gsw_hooks_stub.c`

For each: create the file with the license header and
`#include "gsw_private.h"`, cut the functions out of `mod_gsw.c`, paste them
in, add the file to `GSW_SRCS` in `GNUmakefile.in`, run `./config.status`,
`gmake`. Fix "undeclared"/"undefined" errors by adding prototypes/externs to
the header or removing `static`. Do not "fix" them any other way.

### Step 4: verify
1. `mod_gsw.c` should contain only the includes, `gsw_register_hooks` and the
   module struct.
2. Build with `-Wall -Wextra` once and compare warnings against Step 0.
   No new warnings except possibly unused-parameter ones.
3. Compare exported symbols:
   `nm -g .libs/mod_gsw.so | grep ' T ' | sort > /tmp/symbols_after.txt;
   diff /tmp/symbols_before.txt /tmp/symbols_after.txt`
   Expect identical (apart from functions that were `static` and had to be
   un-`static`ed, which will appear).
4. Smoke test on the FreeBSD box: install the module, `apachectl configtest`,
   start httpd, request an app URL through `/wo/<App>.woa/...` and the
   `showApps` status page; check the error log for startup errors
   (shared memory + mutex creation is in `gsw_post_config`, the riskiest move).
5. `gmake clean && gmake` from scratch and `gmake install` (if the makefile
   has it) still work.

## Later cleanups (separate commits, not part of this refactor)

- Prefix the non-static helpers with `gsw_` (`print_app`, `find_app`,
  `find_app_by_name`, `connect_host`, `read_sock_line`, `read_shared_mem`,
  `mark_unreachable`, `mark_refusing`, `update_app_statistics`,
  `init_shared_mem`, `read_post_data`, `fixRequestString`, ...) so they cannot
  collide with symbols from other Apache modules loaded into the same process.
  Alternatively compile with `-fvisibility=hidden` and export only `gsw_module`.
- Delete the unused sample-module hook stubs and the `trace` machinery from
  `gsw_hooks_stub.c`, and remove the unused hooks from `gsw_register_hooks`.
- Move the shared-memory/mutex setup out of `gsw_post_config` into functions in
  `gsw_shm.c` (`gsw_shm_create()` / `gsw_shm_attach()`), so `gsw_lifecycle.c`
  only orchestrates.
- Consider a small `gsw_net.h` if `gsw_net.c` is ever reused by the other
  adaptors in `../common`.
