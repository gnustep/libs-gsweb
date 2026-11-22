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
/* The content handler: dispatch /wo/<App>.woa/<instance>/... to a backend  */
/* instance, or render the status page for /wo/showapps.                    */
/*                                                                          */
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

