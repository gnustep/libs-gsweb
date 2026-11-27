/*
   Copyright (C) 2007-2008 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de>
   Based on Apache2 Sample Module
      
   This file is part of the GNUstep Web Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#include "gsw_private.h"

/*--------------------------------------------------------------------------*/
/*                                                                          */
/* Application lookup: resolving the request URI to one configured gsw_app  */
/* conf, choosing the least-loaded reachable instance when the URI does not */
/* pin a specific one.                                                      */
/*                                                                          */
/*--------------------------------------------------------------------------*/

/*
 * Build the name -> instance list index that find_app_by_name() uses.
 *
 * The old code walked the whole app table on every unpinned request and
 * compared every entry's name; with many apps that is O(apps) per request
 * even when only one app is involved.  The index maps an app name (case
 * insensitive) to the list of its instances, so the per-request work is
 * O(instances of that app) only.
 *
 * The table is built once per cfg, after all App directives have been
 * read.  gsw_post_config() builds it for the server-level config; the
 * per-directory configs (which requests actually see) are merged copies
 * whose index is built lazily on first use by find_app_by_name().  It is
 * keyed by the lower-cased name and holds pointers into cfg->app_table,
 * so it is valid for the lifetime of the config pool.
 */
/*
 * Choose one instance of the named app for an unpinned request.
 *
 * The instance list comes from the name index built at config time, so
 * only this app's instances are considered.  The shared-memory statistics
 * for exactly those instances are copied under the mutex (one entry each,
 * not the whole segment).
 *
 * Balancing strategy (WOBalancer):
 *   lowest-load  - pick the reachable instance with the lowest load
 *   round-robin  - pick the next instance in rotation, skipping
 *                  unreachable/refusing ones
 *
 * An unreachable instance is retried once it has not been touched for
 * five minutes.  If the app has a single instance and it is unreachable,
 * it is used anyway (there is nothing else to try).
 */
gsw_app_conf * find_app_by_name(char * name, gsw_cfg *cfg, request_rec *r)
{
    // Linear scan of app_table with case-insensitive name matching.
    // The apr_table index approach doesn't work correctly for storing
    // pointers (apr_table stores values as const char*, and the
    // retrieved entry's val is NULL).  A linear scan is O(n) but n is
    // small (number of apps), so it's fine.
    if (((name) && (strlen(name))) && (cfg->app_table))
    {
        const apr_array_header_t *tarr;
        const apr_table_entry_t  *telts;
        int                i;
        int                n;
        apr_time_t         t;
        exipc_data       *mem;
        u_int16_t        *indexes;
        gsw_app_conf    **chosen = NULL;
        gsw_app_conf    *matches[64];  // stack-allocated, max 64 instances per app

        tarr = apr_table_elts(cfg->app_table);
        telts = (const apr_table_entry_t *) tarr->elts;

        // collect all instances of this app (case-insensitive match)
        n = 0;
        for (i = 0; i < tarr->nelts && n < 64; i++) {
            gsw_app_conf *appconf = (gsw_app_conf *) telts[i].val;
            if (appconf && strcasecmp(appconf->app_name, name) == 0) {
                matches[n++] = appconf;
            }
        }

        if (!n) {
            return NULL;
        }

        // copy the statistics for exactly this app's instances
        indexes = (u_int16_t *) apr_palloc(r->pool, sizeof(u_int16_t) * n);
        for (i = 0; i < n; i++) {
            indexes[i] = matches[i]->total_index;
        }

        mem = read_shared_mem(r->pool, n, indexes);
        if (!mem) {
            return NULL;
        }

        // current time minus 300 sec / 5 min: the age-out for
        // unreachable instances
        t = apr_time_now() - apr_time_from_sec(300);

        if (cfg->balancer == BALANCER_ROUND_ROBIN) {
            // rotate through the instances, skipping the ones that are
            // unreachable or refusing; the counter is per config, so each
            // vhost/location balances independently
            for (i = 0; i < n; i++) {
                int  j = (cfg->rr_counter + i) % n;

                if (mem[j].last_request_time < t) {
                    mem[j].unreachable = 0;
                    mem[j].refusing = 0;
                }
                if ((mem[j].unreachable == 0) && (mem[j].refusing == 0)) {
                    cfg->rr_counter = (j + 1) % n;
                    chosen = &matches[j];
                    break;
                }
            }
            if (!chosen) {
                // no reachable instance: fall back to the single-instance
                // case, like the lowest-load path
                if (n == 1) {
                    chosen = &matches[0];
                }
            }
        } else {
            // BALANCER_LOWEST_LOAD: the reachable instance with the
            // lowest load
            u_int32_t lastload = UINT32_MAX;

            for (i = 0; i < n; i++) {
                if (mem[i].last_request_time < t) {
                    mem[i].unreachable = 0;
                    mem[i].refusing = 0;
                }
                if ((mem[i].unreachable == 0) && (mem[i].refusing == 0)) {
                    if (mem[i].load <= lastload) {
                        lastload = mem[i].load;
                        chosen = &matches[i];
                    }
                } else if (n == 1) {
                    // if there is only one instance, we have to hit it
                    // anyways
                    if (mem[i].unreachable == 1) {
                        chosen = &matches[i];
                    }
                }
            }
        }

        if (chosen) {
            return *chosen;
        }
    }
    return NULL;
}

/*
 * Parse the /wo/<App>.woa/<instance>/<rest> URI grammar.  Shared by
 * find_app() and fixRequestString() so the two cannot drift apart.
 *
 * Returns 1 on success, 0 if the URI does not match the grammar.
 */
int gsw_parse_uri(const char * uri,
                  char * app_name, size_t app_name_size,
                  int * instance_nr,
                  char * rest, size_t rest_size)
{
  const char * p;
  const char * dot;
  const char * slash;
  const char * inst;
  size_t      len;

  if (app_name_size < 1 || rest_size < 1) {
    return 0;
  }
  app_name[0] = '\0';
  rest[0] = '\0';
  *instance_nr = -1;

  if (uri == NULL) {
    return 0;
  }

  // skip the /wo/ prefix
  if (strncmp(uri, ADAPTOR_PREFIX, strlen(ADAPTOR_PREFIX)) != 0) {
    return 0;
  }
  p = uri + strlen(ADAPTOR_PREFIX);

  // the app name runs to the next '/'
  slash = strchr(p, '/');
  if (slash == NULL) {
    // no trailing path: accept "/wo/<App>.woa" as an empty rest
    slash = p + strlen(p);
  }
  len = (size_t) (slash - p);
  if (len == 0 || len >= app_name_size) {
    return 0;
  }

  // the name must carry a ".woa" extension; the app name is the part
  // before the last dot.  The search is bounded to the app segment:
  // strrchr() would run past the segment into the rest of the URI,
  // where a dot in a path component (e.g. "/.../0.1.6.1") would
  // otherwise make the parse fail
  dot = memchr(p, '.', (size_t) (slash - p));
  if (dot == NULL) {
    return 0;
  }
  len = (size_t) (dot - p);
  if (len == 0 || len >= app_name_size) {
    return 0;
  }
  memcpy(app_name, p, len);
  app_name[len] = '\0';

  // the instance segment is optional.  It must be a non-negative integer
  // (0 means "any instance"); a non-numeric segment (e.g. "/wo/.../wo/")
  // means there is no instance and the segment is part of the rest of the
  // path that is forwarded to the backend
  p = slash + 1;
  if (*p != '\0') {
    inst = p;
    slash = strchr(p, '/');
    len = (size_t) ((slash ? slash : p + strlen(p)) - inst);
    if (len == 0 || len >= 32) {
      return 0;
    }
    {
      char   num[32];
      char  * end;
      long   v;

      memcpy(num, inst, len);
      num[len] = '\0';
      v = strtol(num, &end, 10);
      if (*end == '\0' && v >= 0 && v <= 65535) {
        *instance_nr = (int) v;
        // the segment was consumed as the instance number
        if (slash != NULL) {
          p = slash + 1;
        } else {
          p = p + len;
        }
      }
      // else: not a number; instance_nr stays -1 and p still points at
      // the segment, so it is included in the rest of the path
    }
  }

  // the remainder of the path (may be empty).  A rest that does not fit is
  // a parse failure, not a silent truncation: the truncated path would be
  // forwarded to the backend and produce a bogus 404 there
  len = strlen(p);
  if (len >= rest_size) {
    return 0;
  }
  memcpy(rest, p, len);
  rest[len] = '\0';

  return 1;
}

gsw_app_conf * find_app(request_rec *r)
{
  char           app_name[MAX_NAME_LENGTH];
  char           rest[MAX_URL_LENGTH];
  int            instance_nr = -1;
  gsw_cfg      * cfg          = NULL;
  gsw_app_conf * app_conf     = NULL;

  if (!gsw_parse_uri(r->uri, app_name, sizeof(app_name),
                     &instance_nr, rest, sizeof(rest))) {
    return NULL;
  }

  cfg = our_dconfig(r);

  if (instance_nr > 0) {
    char   tmp_key[128];

    // gsw_parse_uri() already stripped the ".woa" extension from app_name,
    // so the key matches the bare-name key built by set_App (gsw_cmds.c)
    snprintf(tmp_key, sizeof(tmp_key), "%s:%d", app_name, instance_nr);

    app_conf = (gsw_app_conf *) apr_table_get(cfg->app_table, (const char  *)tmp_key);

    return app_conf;

  }

  // instance_nr <= 0 means "any instance": 0 is what the backend emits in
  // session links, and -1 is treated the same way.  Both are balanced like
  // unpinned requests: the request must reach the instance that created the
  // session, which the balancer picks.
  app_conf = find_app_by_name(app_name, cfg, r);

  return app_conf;
}

