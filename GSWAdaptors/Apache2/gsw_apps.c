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

// callback function for looping the table

int print_app(void *rec, const char *key, gsw_app_conf *appconf)
{

  request_rec  *r       = rec;
//  gsw_app_conf *appconf = (gsw_app_conf *) value;

  if (!appconf) {
    ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "print_app: got a NULL conf");
    return 0;
  }
  
 // ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "Key:'%s'", key);
  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "app_name:'%s'", appconf->app_name);
  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "host_name:'%s'", appconf->host_name);
 // ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "instance_number:'%u'", appconf->instance_number);
//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "load:'%d'", appconf->load);
  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "port:'%u'", appconf->port);
//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "unreachable:'%d'", appconf->unreachable);
  
  return 1; // continue loop
}


/*
 *
 */

gsw_app_conf * find_app_by_name(char * name, gsw_cfg *cfg, request_rec *r)
{
    
    if (((name) && (strlen(name))) && (cfg->app_table))
    {
        
        const        apr_array_header_t *tarr = apr_table_elts(cfg->app_table);
        const        apr_table_entry_t *telts = (const apr_table_entry_t*)tarr->elts;
        int          i;
        apr_time_t   t;
        exipc_data * mem;
        int          appcount = tarr->nelts;
        u_int32_t    lastload = UINT32_MAX;
        int          lastindex = -1;
        int          lastUnreachableIndex = -1;
        
        if (!appcount) {
            return NULL;
        }
        
        mem = read_shared_mem(r->pool,  appcount);
        if (!mem) {
            return NULL;
        }
        
        
        // current time
        t = apr_time_now();
        // substract 300 sec / 5 min
        t = t - apr_time_from_sec(300);
        
        for (i = 0; i < tarr->nelts; i++) {
            gsw_app_conf *appconf = (gsw_app_conf *) telts[i].val;
            
            if ((strcasecmp(appconf->app_name, name) == 0)) {
                // enable unreachable instances after some time
                if (mem[i].last_request_time < t) {
                    mem[i].unreachable = 0;
                    mem[i].refusing = 0;
                }
                
                if ((mem[i].unreachable == 0) && (mem[i].refusing == 0)) {
                    if (mem[i].load <= lastload) {
                        lastindex = i;
                        lastload = mem[i].load;
                    }
                } else {
                    // if there is only one app, we have to hit it anyways.
                    if (appcount == 1) {
                        if (mem[i].unreachable == 1) {
                            lastUnreachableIndex = i;
                        }
                    }
                }
                
            }
        }
        if (lastindex >= 0) {
            return (gsw_app_conf *) telts[lastindex].val;
        }
        if (lastUnreachableIndex >= 0) {
            return (gsw_app_conf *) telts[lastUnreachableIndex].val;
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

  // the instance segment is optional
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
      if (*end != '\0' || v < 0 || v > 65535) {
        return 0;
      }
      *instance_nr = (int) v;
    }
    if (slash != NULL) {
      p = slash + 1;
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
  //ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "app_name '%s'", app_name);

  cfg = our_dconfig(r);

  if (instance_nr != -1) {
    char   tmp_key[128];

    // gsw_parse_uri() already stripped the ".woa" extension from app_name,
    // so the key matches the bare-name key built by set_App (gsw_cmds.c)
    snprintf(tmp_key, sizeof(tmp_key), "%s:%d", app_name, instance_nr);

    app_conf = (gsw_app_conf *) apr_table_get(cfg->app_table, (const char  *)tmp_key);

    return app_conf;

  }

  app_conf = find_app_by_name(app_name, cfg, r);

  //print_app(r, NULL, app_conf);

  return app_conf;
}

