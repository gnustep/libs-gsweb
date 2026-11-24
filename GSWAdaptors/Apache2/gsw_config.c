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
/* Configuration records: locating them for a request or connection, and     */
/* creating / merging the per-directory and per-server ones.                */
/*                                                                          */
/*--------------------------------------------------------------------------*/

/*
 * Locate our directory configuration record for the current request.
 */
gsw_cfg *our_dconfig(const request_rec *r)
{
    return (gsw_cfg *) ap_get_module_config(r->per_dir_config, &gsw_module);
}

/*
 * Likewise for our configuration record for a connection.
 */
gsw_cfg *our_cconfig(const conn_rec *c)
{
    return (gsw_cfg *) ap_get_module_config(c->conn_config, &gsw_module);
}


/*
 * This function gets called to create a per-directory configuration
 * record.  This will be called for the "default" server environment, and for
 * each directory for which the parser finds any of our directives applicable.
 * If a directory doesn't have any of our directives involved (i.e., they
 * aren't in the .htaccess file, or a <Location>, <Directory>, or related
 * block), this routine will *not* be called - the configuration for the
 * closest ancestor is used.
 *
 * The return value is a pointer to the created module-specific
 * structure.
 */
void *gsw_create_dir_config(apr_pool_t *p, char *dirspec)
{
    gsw_cfg *cfg;
    char *dname = dirspec;

    /*
     * Allocate the space for our record from the pool supplied.
     */
    cfg = (gsw_cfg *) apr_pcalloc(p, sizeof(gsw_cfg));
    /*
     * Now fill in the defaults.  If there are any `parent' configuration
     * records, they'll get merged as part of a separate callback.
     */
    cfg->local = 0;
    cfg->congenital = 0;
    cfg->cmode = CONFIG_MODE_DIRECTORY;
    /*
     * Finally, add our trace to the callback list.
     */

   cfg->app_table = apr_table_make(p, 1);   // default
    cfg->connect_timeout = DEFAULT_CONNECT_TIMEOUT;
    cfg->wait_timeout = DEFAULT_WAIT_TIMEOUT;
    cfg->max_body_size = DEFAULT_MAX_BODY_SIZE;


    dname = (dname != NULL) ? dname : "";
    cfg->loc = apr_pstrcat(p, "DIR(", dname, ")", NULL);
    return (void *) cfg;
}

/*
 * This function gets called to merge two per-directory configuration
 * records.  This is typically done to cope with things like .htaccess files
 * or <Location> directives for directories that are beneath one for which a
 * configuration record was already created.  The routine has the
 * responsibility of creating a new record and merging the contents of the
 * other two into it appropriately.  If the module doesn't declare a merge
 * routine, the record for the closest ancestor location (that has one) is
 * used exclusively.
 *
 * The routine MUST NOT modify any of its arguments!
 *
 * The return value is a pointer to the created module-specific structure
 * containing the merged values.
 */
void *gsw_merge_dir_config(apr_pool_t *p, void *parent_conf,
                                      void *newloc_conf)
{

    gsw_cfg *merged_config = (gsw_cfg *) apr_pcalloc(p, sizeof(gsw_cfg));
    gsw_cfg *pconf = (gsw_cfg *) parent_conf;
    gsw_cfg *nconf = (gsw_cfg *) newloc_conf;
    char *note;

    /*
     * Some things get copied directly from the more-specific record, rather
     * than getting merged.
     */
    merged_config->local = nconf->local;
    merged_config->loc = apr_pstrdup(p, nconf->loc);

// dave
    merged_config->showApps = nconf->showApps;
//    snprintf(merged_config->appInfo, 1000, nconf->appInfo);
   merged_config->app_table = apr_table_copy(p, nconf->app_table);


    /*
     * Others, like the setting of the `congenital' flag, get ORed in.  The
     * setting of that particular flag, for instance, is TRUE if it was ever
     * true anywhere in the upstream configuration.
     */
    merged_config->congenital = (pconf->congenital | pconf->local);
    /*
     * If we're merging records for two different types of environment (server
     * and directory), mark the new record appropriately.  Otherwise, inherit
     * the current value.
     */
    merged_config->cmode =
        (pconf->cmode == nconf->cmode) ? pconf->cmode : CONFIG_MODE_COMBO;
    /*
     * Now just record our being called in the trace list.  Include the
     * locations we were asked to merge.
     */
    note = apr_pstrcat(p, "gsw_merge_dir_config(\"", pconf->loc, "\",\"",
                   nconf->loc, "\")", NULL);

    return (void *) merged_config;
}

/*
 * This function gets called to create a per-server configuration
 * record.  It will always be called for the "default" server.
 *
 * The return value is a pointer to the created module-specific
 * structure.
 */
void *gsw_create_server_config(apr_pool_t *p, server_rec *s)
{
  
  gsw_cfg *cfg;
  char *sname = s->server_hostname;
    
  /*
   * As with the gsw_create_dir_config() reoutine, we allocate and fill
   * in an empty record.
   */
  cfg = (gsw_cfg *) apr_pcalloc(p, sizeof(gsw_cfg));
  cfg->local = 0;
  cfg->congenital = 0;
  cfg->cmode = CONFIG_MODE_SERVER;
  /*
   * Note that we were called in the trace list.
   */
  sname = (sname != NULL) ? sname : "";
  cfg->loc = apr_pstrcat(p, "SVR(", sname, ")", NULL);
  
  cfg->app_table = apr_table_make(p, 1);   // default, like gsw_create_dir_config
  cfg->connect_timeout = DEFAULT_CONNECT_TIMEOUT;
  cfg->wait_timeout = DEFAULT_WAIT_TIMEOUT;
  cfg->max_body_size = DEFAULT_MAX_BODY_SIZE;
  
  return (void *) cfg;
}

/*
 * This function gets called to merge two per-server configuration
 * records.  This is typically done to cope with things like virtual hosts and
 * the default server configuration  The routine has the responsibility of
 * creating a new record and merging the contents of the other two into it
 * appropriately.  If the module doesn't declare a merge routine, the more
 * specific existing record is used exclusively.
 *
 * The routine MUST NOT modify any of its arguments!
 *
 * The return value is a pointer to the created module-specific structure
 * containing the merged values.
 */
void *gsw_merge_server_config(apr_pool_t *p, void *server1_conf,
                                         void *server2_conf)
{

    gsw_cfg *merged_config = (gsw_cfg *) apr_pcalloc(p, sizeof(gsw_cfg));
    gsw_cfg *s1conf = (gsw_cfg *) server1_conf;
    gsw_cfg *s2conf = (gsw_cfg *) server2_conf;
    char *note;

    /*
     * Our inheritance rules are our own, and part of our module's semantics.
     * Basically, just note whence we came.
     */
    merged_config->cmode =
        (s1conf->cmode == s2conf->cmode) ? s1conf->cmode : CONFIG_MODE_COMBO;
    merged_config->local = s2conf->local;
    merged_config->congenital = (s1conf->congenital | s1conf->local);
    merged_config->loc = apr_pstrdup(p, s2conf->loc);

    /*
     * The app table and the tuning knobs must be inherited the same way the
     * dir-config merge does it.  The old code left them at their pcalloc
     * zero/NULL values, so a vhost that inherited the default server config
     * (the normal case: apps configured globally, no per-vhost directives)
     * had an empty app table and the default timeouts.
     */
    merged_config->app_table = apr_table_copy(p, s2conf->app_table);
    merged_config->connect_timeout = s2conf->connect_timeout;
    merged_config->wait_timeout = s2conf->wait_timeout;
    merged_config->max_body_size = s2conf->max_body_size;
    merged_config->showApps = s2conf->showApps;
    /*
     * Trace our call, including what we were asked to merge.
     */
    note = apr_pstrcat(p, "gsw_merge_server_config(\"", s1conf->loc, "\",\"",
                   s2conf->loc, "\")", NULL);

    return (void *) merged_config;
}

/*
 * Returns the number of instances configured
 */

static int app_count(server_rec *s)
{
  gsw_cfg                  * cfg = (gsw_cfg *) ap_get_module_config(s->module_config, &gsw_module);
  const apr_array_header_t * tarr = NULL;

  if (cfg) {
    tarr = apr_table_elts((apr_table_t *)cfg->app_table);
    if (tarr) {
      return tarr->nelts;
    }
  }
  
  return 0;
}

