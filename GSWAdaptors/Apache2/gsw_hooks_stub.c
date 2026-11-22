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
/* Leftovers from the Apache2 sample module this adaptor was derived from:   */
/* phase callbacks that only fetch our configuration record and return,      */
/* plus the callback-trace machinery they were part of.  They are registered */
/* in gsw_register_hooks(), so they must keep existing; untangling them is   */
/* a separate cleanup.                                                      */
/*                                                                          */
/* This file *defines* the four trace cells declared extern in              */
/* gsw_private.h.                                                           */
/*                                                                          */
/*--------------------------------------------------------------------------*/

/*
 * Let's set up a module-local static cell to point to the accreting callback
 * trace.  As each API callback is made to us, we'll tack on the particulars
 * to whatever we've already recorded.  To avoid massive memory bloat as
 * directories are walked again and again, we record the routine/environment
 * the first time (non-request context only), and ignore subsequent calls for
 * the same routine/environment.
 */
const char *trace = NULL;
apr_table_t *static_calls_made = NULL;

/*
 * To avoid leaking memory from pools other than the per-request one, we
 * allocate a module-private pool, and then use a sub-pool of that which gets
 * freed each time we modify the trace.  That way previous layers of trace
 * data don't get lost.
 */
apr_pool_t *gsw_pool = NULL;
apr_pool_t *gsw_subpool = NULL;


/*
 * These routines are strictly internal to this module, and support its
 * operation.  They are not referenced by any external portion of the
 * server.
 */

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

