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
#include "gsw_compat.h"   /* apr_parse_int64 fallback, mutex-perms shim */


/*--------------------------------------------------------------------------*/
/*                                                                          */
/* Data definitions.  The types, constants and their extern declarations live */
/* in gsw_private.h.  Each of these cells is defined in exactly one source   */
/* file; they stay here until the code that owns them moves out.             */
/*                                                                          */
/*--------------------------------------------------------------------------*/


// sample-module trace state  (moves to gsw_hooks_stub.c)
const char *trace = NULL;
apr_table_t *static_calls_made = NULL;
apr_pool_t *gsw_pool = NULL;
apr_pool_t *gsw_subpool = NULL;







/*--------------------------------------------------------------------------*/
/*                                                                          */
/* These routines are strictly internal to this module, and support its     */
/* operation.  They are not referenced by any external portion of the       */
/* server.                                                                  */
/*                                                                          */
/*--------------------------------------------------------------------------*/


/*
 * This routine sets up some module-wide cells if they haven't been already.
 */
void setup_module_cells(void)
{
    /*
     * If we haven't already allocated our module-private pool, do so now.
     */
    if (gsw_pool == NULL) {
        apr_pool_create(&gsw_pool, NULL);

    };
    /*
     * Likewise for the table of routine/environment pairs we visit outside of
     * request context.
     */
    if (static_calls_made == NULL) {
        static_calls_made = apr_table_make(gsw_pool, 16);
    };
}










/*--------------------------------------------------------------------------*/
/*                                                                          */
/* Now we declare our content handlers, which are invoked when the server   */
/* encounters a document which our module is supposed to have a chance to   */
/* see.  (See mod_mime's SetHandler and AddHandler directives, and the      */
/* mod_info and mod_status gsws, for more details.)                     */
/*                                                                          */
/* Since content handlers are dumping data directly into the connection     */
/* (using the r*() routines, such as rputs() and rprintf()) without         */
/* intervention by other parts of the server, they need to make             */
/* sure any accumulated HTTP headers are sent first.  This is done by       */
/* calling send_http_header().  Otherwise, no header will be sent at all,   */
/* and the output sent to the client will actually be HTTP-uncompliant.     */
/*--------------------------------------------------------------------------*/
/*
 * Sample content handler.  All this does is display the call list that has
 * been built up so far.
 *
 * The return value instructs the caller concerning what happened and what to
 * do next:
 *  OK ("we did our thing")
 *  DECLINED ("this isn't something with which we want to get involved")
 *  HTTP_mumble ("an error status should be reported")
 */
int gsw_handler(request_rec *r)
{
  gsw_app_conf   * app = NULL;
  gsw_cfg        * dcfg;
  char             data1[1024];
  char             data[1024];
  void           * user_data;
  int              handle_status = OK;
  void           * postdata = NULL;
  uint32_t         contentLen = 0;

  
//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "xx handler uri: %s", r->uri);

  if (strncmp(r->uri, "/wo/",4) != 0) {
//      ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "xx handler DECLINED");
      return DECLINED;
  }


  dcfg = our_dconfig(r);

    if (strncmp(r->uri, "/wo/showapps",12) == 0) {
        showApps(r, dcfg);
        return OK;
    }

  /*
    * We're about to start sending content, so we need to force the HTTP
    * headers to be sent at this point.  Otherwise, no headers will be sent
    * at all.  We can set any we like first, of course.  **NOTE** Here's
    * where you set the "Content-type" header, and you do so by putting it in
    * r->content_type, *not* r->headers_out("Content-type").  If you don't
    * set it, it will be filled in with the server's default type (typically
    * "text/plain").  You *must* also ensure that r->content_type is lower
    * case.
    *
    * We also need to start a timer so the server can know if the connexion
    * is broken.
    */
    
  
  app = find_app(r);
    
  if (app != NULL) {
    int i;
    handle_status = OK;
    
    if (ap_setup_client_block(r, REQUEST_CHUNKED_ERROR) != OK) {
      ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "handle_request: DECLINED");
    } else {
      if (r->method_number == M_POST) {
        contentLen = get_content_len(r);
        postdata = read_post_data(r, contentLen, r->pool, app);
        if (postdata == NULL) {
          // the body exceeds WOMaxBodySize (or the client aborted)
          return 413; // HTTP_PAYLOAD_TOO_LARGE
        }
      }
      
      
      for (i = 0; ((i < RETRY_COUNT) && (handle_status <= OK)); i++) {
        handle_status = handle_request(r, app, postdata, contentLen);
        
        switch (handle_status) {
          case UNREACHABLE:
            mark_unreachable(r,app);
            app = find_app(r);
            break;
          case DECLINED:
            break;
          case OK:
            return handle_status;
          case HTTP_MOVED_TEMPORARILY:
            return OK;                  // otherwise, we get a apache error doc!
          default:
            break;
        }
      }
      
      if ((handle_status > OK)) {
        return handle_status;
      }
      
    }
  }
    
    /*
     * If we're only supposed to send header information (HEAD request), we're
     * already there.
     */
//    if (r->header_only) {
////        return OK;
//        return 504;
//    }

    /*
     * We're all done, so cancel the timeout we set.  Since this is probably
     * the end of the request we *could* assume this would be done during
     * post-processing - but it's possible that another handler might be
     * called and inherit our outstanding timer.  Not good; to each its own.
     */
    /*
     * We did what we wanted to do, so tell the rest of the server we
     * succeeded.
     */
    return 504;
}

/*--------------------------------------------------------------------------*/
/*                                                                          */
/* Now let's declare routines for each of the callback phase in order.      */
/* (That's the order in which they're listed in the callback list, *not     */
/* the order in which the server calls them!  See the command_rec           */
/* declaration near the bottom of this file.)  Note that these may be       */
/* called for situations that don't relate primarily to our function - in   */
/* other words, the fixup handler shouldn't assume that the request has     */
/* to do with "gsw" stuff.                                              */
/*                                                                          */
/* With the exception of the content handler, all of our routines will be   */
/* called for each request, unless an earlier handler from another module   */
/* aborted the sequence.                                                    */
/*                                                                          */
/* Handlers that are declared as "int" can return the following:            */
/*                                                                          */
/*  OK          Handler accepted the request and did its thing with it.     */
/*  DECLINED    Handler took no action.                                     */
/*  HTTP_mumble Handler looked at request and found it wanting.             */
/*                                                                          */
/* What the server does after calling a module handler depends upon the     */
/* handler's return value.  In all cases, if the handler returns            */
/* DECLINED, the server will continue to the next module with an handler    */
/* for the current phase.  However, if the handler return a non-OK,         */
/* non-DECLINED status, the server aborts the request right there.  If      */
/* the handler returns OK, the server's next action is phase-specific;      */
/* see the individual handler comments below for details.                   */
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


/*
 * XXX: This routine is called XXX
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, the
 * server will still call any remaining modules with an handler for this
 * phase.
 */
void gsw_insert_filter(request_rec *r)
{
    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * Log the call and exit.
     */
}

/*
 * XXX: This routine is called XXX
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, the
 * server will still call any remaining modules with an handler for this
 * phase.
 */
int gsw_quick_handler(request_rec *r, int lookup_uri)
{
    return DECLINED;
}

/*
 * This routine is called just after the server accepts the connection,
 * but before it is handed off to a protocol module to be served.  The point
 * of this hook is to allow modules an opportunity to modify the connection
 * as soon as possible. The core server uses this phase to setup the
 * connection record based on the type of connection that is being used.
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, the
 * server will still call any remaining modules with an handler for this
 * phase.
 */
int gsw_pre_connection(conn_rec *c, void *csd)
{
    gsw_cfg *cfg;

    cfg = our_cconfig(c);

    return OK;
}

/* This routine is used to actually process the connection that was received.
 * Only protocol modules should implement this hook, as it gives them an
 * opportunity to replace the standard HTTP processing with processing for
 * some other protocol.  Both echo and POP3 modules are available as
 * gsws.
 *
 * The return VALUE is OK, DECLINED, or HTTP_mumble.  If we return OK, no
 * further modules are called for this phase.
 */
 
 // FIXME: remove??
int gsw_process_connection(conn_rec *c)
{
    return DECLINED;
}

/*
 * This routine is called after the request has been read but before any other
 * phases have been processed.  This allows us to make decisions based upon
 * the input header fields.
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, no
 * further modules are called for this phase.
 */
 // FIXME: remove??
int gsw_post_read_request(request_rec *r)
{
  return DECLINED;
}

/*
 * This routine gives our module an opportunity to translate the URI into an
 * actual filename.  If we don't do anything special, the server's default
 * rules (Alias directives and the like) will continue to be followed.
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, no
 * further modules are called for this phase.
 */
int gsw_translate_handler(request_rec *r)
{
  if (strncmp(r->uri, "/wo/",4) != 0) {
    return DECLINED;
  }
  
  return OK;
}

/*
 * This routine maps r->filename to a physical file on disk.  Useful for
 * overriding default core behavior, including skipping mapping for
 * requests that are not file based.
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, no
 * further modules are called for this phase.
 */
int gsw_map_to_storage_handler(request_rec *r)
{
  if (strncmp(r->uri, "/wo/",4) != 0) {
    return DECLINED;
  }
  
  return OK;
}

/*
 * this routine gives our module another chance to examine the request
 * headers and to take special action. This is the first phase whose
 * hooks' configuration directives can appear inside the <Directory>
 * and similar sections, because at this stage the URI has been mapped
 * to the filename. For gsw this phase can be used to block evil
 * clients, while little resources were wasted on these.
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK,
 * the server will still call any remaining modules with an handler
 * for this phase.
 */
int gsw_header_parser_handler(request_rec *r)
{
  return DECLINED;
}


/*
 * This routine is called to check the authentication information sent with
 * the request (such as looking up the user in a database and verifying that
 * the [encrypted] password sent matches the one in the database).
 *
 * The return value is OK, DECLINED, or some HTTP_mumble error (typically
 * HTTP_UNAUTHORIZED).  If we return OK, no other modules are given a chance
 * at the request during this phase.
 */
int gsw_check_user_id(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * Don't do anything except log the call.
     */

    return DECLINED;
}

/*
 * This routine is called to check to see if the resource being requested
 * requires authorisation.
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, no
 * other modules are called during this phase.
 *
 * If *all* modules return DECLINED, the request is aborted with a server
 * error.
 */
int gsw_auth_checker(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * Log the call and return OK, or access will be denied (even though we
     * didn't actually do anything).
     */

    return DECLINED;
}

/*
 * This routine is called to check for any module-specific restrictions placed
 * upon the requested resource.  (See the mod_access module for an gsw.)
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  All modules with an
 * handler for this phase are called regardless of whether their predecessors
 * return OK or DECLINED.  The first one to return any other status, however,
 * will abort the sequence (and the request) as usual.
 */
int gsw_access_checker(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);

    return DECLINED;
}

/*
 * This routine is called to determine and/or set the various document type
 * information bits, like Content-type (via r->content_type), language, et
 * cetera.
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, no
 * further modules are given a chance at the request for this phase.
 */
int gsw_type_checker(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * Log the call, but don't do anything else - and report truthfully that
     * we didn't do anything.
     */

    return DECLINED;
}

/*
 * This routine is called to perform any module-specific fixing of header
 * fields, et cetera.  It is invoked just before any content-handler.
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, the
 * server will still call any remaining modules with an handler for this
 * phase.
 */
int gsw_fixer_upper(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);

    return OK;
}

/*
 * This routine is called to perform any module-specific logging activities
 * over and above the normal server things.
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, any
 * remaining modules with an handler for this phase will still be called.
 */
int gsw_logger(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);

    return DECLINED;
}

/*--------------------------------------------------------------------------*/
/*                                                                          */
/* Which functions are responsible for which hooks in the server.           */
/*                                                                          */
/*--------------------------------------------------------------------------*/
/*
 * Each function our module provides to handle a particular hook is
 * specified here.  The functions are registered using
 * ap_hook_foo(name, predecessors, successors, position)
 * where foo is the name of the hook.
 *
 * The args are as follows:
 * name         -> the name of the function to call.
 * predecessors -> a list of modules whose calls to this hook must be
 *                 invoked before this module.
 * successors   -> a list of modules whose calls to this hook must be
 *                 invoked after this module.
 * position     -> The relative position of this module.  One of
 *                 APR_HOOK_FIRST, APR_HOOK_MIDDLE, or APR_HOOK_LAST.
 *                 Most modules will use APR_HOOK_MIDDLE.  If multiple
 *                 modules use the same relative position, Apache will
 *                 determine which to call first.
 *                 If your module relies on another module to run first,
 *                 or another module running after yours, use the
 *                 predecessors and/or successors.
 *
 * The number in brackets indicates the order in which the routine is called
 * during request processing.  Note that not all routines are necessarily
 * called (such as if a resource doesn't have access restrictions).
 * The actual delivery of content to the browser [9] is not handled by
 * a hook; see the handler declarations below.
 */
static void gsw_register_hooks(apr_pool_t *p)
{
  instance_count = DEFAULT_APP_COUNT; // default value
  last_app_index = 0;

    ap_hook_pre_config(gsw_pre_config, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_post_config(gsw_post_config, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_open_logs(gsw_open_logs, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_child_init(gsw_child_init, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_handler(gsw_handler, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_quick_handler(gsw_quick_handler, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_pre_connection(gsw_pre_connection, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_process_connection(gsw_process_connection, NULL, NULL, APR_HOOK_MIDDLE);
    /* [1] post read_request handling */
    ap_hook_post_read_request(gsw_post_read_request, NULL, NULL,
                              APR_HOOK_MIDDLE);
    ap_hook_log_transaction(gsw_logger, NULL, NULL, APR_HOOK_MIDDLE);
#if 0
    ap_hook_http_scheme(gsw_http_scheme, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_default_port(gsw_default_port, NULL, NULL, APR_HOOK_MIDDLE);
#endif
    ap_hook_translate_name(gsw_translate_handler, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_map_to_storage(gsw_map_to_storage_handler, NULL,NULL, APR_HOOK_MIDDLE);
    ap_hook_header_parser(gsw_header_parser_handler, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_check_user_id(gsw_check_user_id, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_fixups(gsw_fixer_upper, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_type_checker(gsw_type_checker, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_access_checker(gsw_access_checker, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_auth_checker(gsw_auth_checker, NULL, NULL, APR_HOOK_MIDDLE);
    ap_hook_insert_filter(gsw_insert_filter, NULL, NULL, APR_HOOK_MIDDLE);
}

/*--------------------------------------------------------------------------*/
/*                                                                          */
/* Finally, the list of callback routines and data structures that provide  */
/* the static hooks into our module from the other parts of the server.     */
/*                                                                          */
/*--------------------------------------------------------------------------*/
/*
 * Module definition for configuration.  If a particular callback is not
 * needed, replace its routine name below with the word NULL.
 */
module AP_MODULE_DECLARE_DATA gsw_module =
{
    STANDARD20_MODULE_STUFF,
    gsw_create_dir_config,    /* per-directory config creator */
    gsw_merge_dir_config,     /* dir config merger */
    gsw_create_server_config, /* server config creator */
    gsw_merge_server_config,  /* server config merger */
    gsw_cmds,                 /* command table */
    gsw_register_hooks,       /* set up other request processing hooks */
};
