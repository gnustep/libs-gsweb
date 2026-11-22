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
/* Module skeleton: the hook registrations and the module definition.  All  */
/* the implementation lives in the gsw_*.c files listed in GSW_SRCS and is  */
/* declared in gsw_private.h.                                               */
/*                                                                          */
/*--------------------------------------------------------------------------*/

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
