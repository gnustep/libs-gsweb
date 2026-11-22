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
#include "gsw_compat.h"   /* ap_unixd_set_global_mutex_perms shim, MOD_EXIPC_SET_MUTEX_PERMS */

/*--------------------------------------------------------------------------*/
/*                                                                          */
/* Server-lifecycle hooks: pre/post configuration, log opening, and the     */
/* per-child initialisation.  This is where the shared-memory segment and   */
/* the global mutex are created (parent) and re-attached (child).           */
/*                                                                          */
/*--------------------------------------------------------------------------*/

/*
 * This function is called during server initialisation.  Any information
 * that needs to be recorded must be in static cells, since there's no
 * configuration record.
 *
 * There is no return value.
 */

/*
 * This function is called when an heavy-weight process (such as a child) is
 * being run down or destroyed.  As with the child initialisation function,
 * any information that needs to be recorded must be in static cells, since
 * there's no configuration record.
 *
 * There is no return value.
 */

/*
 * This function is called during server initialisation when an heavy-weight
 * process (such as a child) is being initialised.  As with the
 * module initialisation function, any information that needs to be recorded
 * must be in static cells, since there's no configuration record.
 *
 * There is no return value.
 */

/*
 * This routine is called before the server processes the configuration
 * files.  There is no return value.
 */
int gsw_pre_config(apr_pool_t *pconf, apr_pool_t *plog,
                        apr_pool_t *ptemp)
{
    /*
     * Log the call and exit.
     */

    return OK;
}

/*
 * This routine is called to perform any module-specific fixing of header
 * fields, et cetera.  It is invoked just before any content-handler.
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, the
 * server will still call any remaining modules with an handler for this
 * phase.
 */
int gsw_post_config(apr_pool_t *pconf, apr_pool_t *plog,
                          apr_pool_t *ptemp, server_rec *s)
{
  void          * data; /* These two help ensure that we only init once. */
  const char    * userdata_key = "gsw_init_module";
  apr_status_t    rs;
  void          * base;
  const char    * temp_dir;
  int             appcount = 0;
  gsw_cfg       * cfg;
  
  //openlog("www", LOG_PID,LOG_USER);
  
  /*
   * The following checks if this routine has been called before.
   * This is necessary because the parent process gets initialized
   * a couple of times as the server starts up, and we don't want
   * to create any more mutexes and shared memory segments than
   * we're actually going to use.
   */

  apr_pool_userdata_get(&data, userdata_key, s->process->pool);
  if (!data) {
    apr_pool_userdata_set((const void *) 1, userdata_key,
                          apr_pool_cleanup_null, s->process->pool);

    return OK;
  }
  
  /* Create the shared memory segment */
  
  /*
   * Create a unique filename using our pid. This information is
   * stashed in the global variable so the children inherit it.
   * TODO get the location from the environment $TMPDIR or somesuch.
   */
  
  cfg = ap_get_module_config(s->module_config, &gsw_module);

  appcount = instance_count;
  
  apr_temp_dir_get(&temp_dir, pconf);

  apr_filepath_merge(&shmfilename, temp_dir,
                     apr_psprintf(pconf, "gsw_shm.%ld", (long int)getpid()), 0, pconf);

  /* Now create that segment */

  rs = apr_shm_create(&exipc_shm, (sizeof(exipc_data) * appcount),
                      (const char *) shmfilename, pconf);
  if (rs != APR_SUCCESS) {
    ap_log_error(APLOG_MARK, APLOG_ERR, rs, s,
                 "Failed to create shared memory segment on file %s",
                 shmfilename);
    return HTTP_INTERNAL_SERVER_ERROR;
  }
  
  
  /* Create global mutex */
  
  /*
   * Create another unique filename to lock upon. Note that
   * depending on OS and locking mechanism of choice, the file
   * may or may not be actually created.
   */

  apr_filepath_merge(&mutexfilename, temp_dir,
                     apr_psprintf(pconf, "gsw_mutex.%ld", (long int)getpid()), 0, pconf);
  
  rs = apr_global_mutex_create(&exipc_mutex, (const char *) mutexfilename,
                               APR_LOCK_DEFAULT, pconf);
  if (rs != APR_SUCCESS) {
    ap_log_error(APLOG_MARK, APLOG_ERR, rs, s,
                 "Failed to create mutex on file %s",
                 mutexfilename);

    return HTTP_INTERNAL_SERVER_ERROR;
  }
  
#ifdef MOD_EXIPC_SET_MUTEX_PERMS
  rs = ap_unixd_set_global_mutex_perms(exipc_mutex);
  if (rs != APR_SUCCESS) {
    ap_log_error(APLOG_MARK, APLOG_CRIT, rs, s,
                 "Parent could not set permissions on Example IPC "
                 "mutex: check User and Group directives");
    return HTTP_INTERNAL_SERVER_ERROR;
  }
#endif /* MOD_EXIPC_SET_MUTEX_PERMS */

  apr_global_mutex_lock(exipc_mutex);
  
  /* Created it, now let's zero it out */
  init_shared_mem(exipc_shm, appcount, s);

  apr_global_mutex_unlock(exipc_mutex);
  
  
  return OK;
}

/*
 * This routine is called to perform any module-specific log file
 * openings. It is invoked just before the post_config phase
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, the
 * server will still call any remaining modules with an handler for this
 * phase.
 */
int gsw_open_logs(apr_pool_t *pconf, apr_pool_t *plog,
                        apr_pool_t *ptemp, server_rec *s)
{
    /*
     * Log the call and exit.
     */
    return OK;
}

/*
 * All our process-death routine does is add its trace to the log.
 */
static apr_status_t gsw_child_exit(void *data)
{
    char *note;
    server_rec *s = data;
    char *sname = s->server_hostname;

    /*
     * The arbitrary text we add to our trace entry indicates for which server
     * we're being called.
     */
    sname = (sname != NULL) ? sname : "";
    note = apr_pstrcat(s->process->pool, "gsw_child_exit(", sname, ")", NULL);

    return APR_SUCCESS;
}

/*
 * This routine gets called when a child inits. We use it to attach
 * to the shared memory segment, and reinitialize the mutex.
 */

void gsw_child_init(apr_pool_t *p, server_rec *s)
{
  apr_status_t rs;
  
  /*
   * Set up any module cells that ought to be initialised.
   */
  setup_module_cells();
  
  /*
   * Re-open the mutex for the child. Note we're reusing
   * the mutex pointer global here.
   */

  rs = apr_global_mutex_child_init(&exipc_mutex,
                                   (const char *) mutexfilename,
                                   p);
  if (rs != APR_SUCCESS) {
    ap_log_error(APLOG_MARK, APLOG_CRIT, rs, s,
                 "Failed to reopen mutex on file %s",
                 mutexfilename);
    /* There's really nothing else we can do here, since
     * This routine doesn't return a status. */
    exit(1); /* Ugly, but what else? */
  }
  
  apr_pool_cleanup_register(p, s, gsw_child_exit, gsw_child_exit);
  
  
}

