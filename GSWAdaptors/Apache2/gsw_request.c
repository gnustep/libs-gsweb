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
#include "gsw_compat.h"   /* apr_parse_int64 fallback, used by get_content_len() */

/*--------------------------------------------------------------------------*/
/*                                                                          */
/* The request/response exchange with a backend application: building the   */
/* forwarded request, sending it, reading the reply headers and body, and   */
/* buffering an incoming POST body.                                         */
/*                                                                          */
/*--------------------------------------------------------------------------*/

/*
HTTP/1.0 200 OK NeXT WebObjects
x-webobjects-loadaverage: 1
content-length: 3315
content-type: text/html
x-webobjects-adaptorstats: applicationThreadCreation=+0.000s applicationThreadRun=+0.000s applicationBeginDispatchRequest=+1.368s applicationEndDispatchRequest=+1.387s applicationDispatchRequest=0.019s applicationBeginSendResponse=+1.387s applicationTimeSpent=1.387s

*/

const char * fixRequestString(request_rec *r, gsw_app_conf *app)
{
  char            * newString = NULL;

  // GET /wo/PBX HTTP/1.1
  //
  // The URI part is parsed with the same gsw_parse_uri() that find_app()
  // uses, so the two cannot drift apart.  The instance number in the
  // rewritten request line is always the app's own instance_number (the one
  // the request was routed to), even when the client's URI carried no
  // instance number or carried 0 ("any") — the backend emits session links
  // with instance 0, and follow-ups must reach the instance that created
  // the session.
  {
    char   uri_part[512];
    char   app_name[MAX_NAME_LENGTH];
    char   rest[MAX_URL_LENGTH];
    int    instance_nr = -1;
    const char * uri = r->uri ? r->uri : "/";

    if (gsw_parse_uri(uri, app_name, sizeof(app_name),
                      &instance_nr, rest, sizeof(rest))) {
      /* Always rewrite the instance number to the one this request was
       * routed to.  The backend emits session links with instance 0
       * (meaning "any"), and a follow-up request for such a link must reach
       * the same instance that created the session — so even an explicit 0
       * (or -1) in the client's URI is replaced by app->instance_number.
       * (find_app() resolves instance <= 0 to the app's own instance, so
       * the two cannot drift apart.) */
      snprintf(uri_part, sizeof(uri_part), "%s%s.woa/%d/%s",
               ADAPTOR_PREFIX, app_name, app->instance_number, rest);
    } else {
      // not a /wo/<App>.woa/... URI; leave it untouched
      snprintf(uri_part, sizeof(uri_part), "%s", uri);
    }

    newString = apr_psprintf(r->pool, "%s %s HTTP/1.1\r\n", r->method, uri_part);
  }

//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "newString:'%s'", newString);

  
  return newString;
}

static int send_headers(int soc, gsw_app_conf *app, request_rec *r)
{
  apr_array_header_t    * hdrs_arr = NULL;
  apr_table_entry_t     * hdrs = NULL;
  int                     retval = 0;
  int                     i = 0;
  char                   * hdrBuf = NULL;
  size_t                  bufLen = 0;
  size_t                  bufSize = 0;
  const char            * ap_str;
  server_rec            * s = r->server;
  conn_rec              * c = r->connection;

  hdrs_arr = (apr_array_header_t*) apr_table_elts(r->headers_in);
  hdrs = (apr_table_entry_t *) hdrs_arr->elts;

  // GET /wo/PBX HTTP/1.1

  // write the request line directly: it can be longer than any fixed buffer
  // (it embeds the full URI path + query)
  {
    const char * reqLine = fixRequestString(r,app);
    retval = write_sock(soc, reqLine, strlen(reqLine), r);
  }

  if (retval != 0) {
    return retval;
  }

  // build the entire header block in one buffer and send it in a single
  // call, instead of one write_sock() per header
  bufSize = 4096;
  hdrBuf = apr_palloc(r->pool, bufSize);
  hdrBuf[0] = '\0';
  bufLen = 0;

#define APPEND_HDR(key, value) \
  do { \
    int _n; \
    while ((size_t) (_n = snprintf(NULL, 0, "%s: %s\r\n", (key), (value))) >= (bufSize - bufLen)) { \
      size_t _newSize = bufSize * 2; \
      char  *_newBuf  = apr_palloc(r->pool, _newSize); \
      memcpy(_newBuf, hdrBuf, bufLen);   /* keep what we already appended */ \
      hdrBuf  = _newBuf; \
      bufSize = _newSize; \
    } \
    _n = snprintf(hdrBuf + bufLen, bufSize - bufLen, "%s: %s\r\n", (key), (value)); \
    bufLen += (size_t) _n; \
  } while (0)

  for (i = 0; i < hdrs_arr->nelts; ++i) {
    if (!hdrs[i].key || !hdrs[i].val)
      continue;
    // drop headers with CR/LF in key or value: they would let a client
    // inject extra headers into the request we forward to the backend
    if (!gsw_header_is_safe(hdrs[i].key, hdrs[i].val)) {
      ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                     "dropping header with CR/LF in key or value: '%s'", hdrs[i].key);
      continue;
    }
    APPEND_HDR(hdrs[i].key, hdrs[i].val);
  }
  // write x-webobjects-adaptor-version to the app
  {
    int _n = snprintf(NULL, 0, "%s", X_WO_VERSION_HEADER);
    while ((size_t) _n >= (bufSize - bufLen)) {
      size_t _newSize = bufSize * 2;
      char  *_newBuf  = apr_palloc(r->pool, _newSize);
      memcpy(_newBuf, hdrBuf, bufLen);
      hdrBuf  = _newBuf;
      bufSize = _newSize;
    }
    _n = snprintf(hdrBuf + bufLen, bufSize - bufLen, "%s", X_WO_VERSION_HEADER);
    bufLen += (size_t) _n;
  }

  if ((s != NULL) && (s->server_hostname != NULL)) {
    APPEND_HDR(SERVER_NAME, s->server_hostname);
  }

  // SERVER_PORT
  {
    char portStr[16];
    snprintf(portStr, sizeof(portStr), "%hu", ap_get_server_port(r));
    APPEND_HDR(SERVER_PORT, portStr);
  }

#if (AP_SERVER_MAJORVERSION_NUMBER == 2) && (AP_SERVER_MINORVERSION_NUMBER < 4)
  if ((c != NULL) && (c->remote_ip != NULL)) {
    APPEND_HDR(REMOTE_ADDR, c->remote_ip);
  }
#else
  if ((c != NULL) && (c->client_ip != NULL)) {
    APPEND_HDR(REMOTE_ADDR, c->client_ip);
  }
#endif

  if (r->user != NULL) {
    if (gsw_header_is_safe(REMOTE_USER, r->user)) {
      APPEND_HDR(REMOTE_USER, r->user);
    }
  }

  if (r->ap_auth_type != NULL) {
    if (gsw_header_is_safe(AUTH_TYPE, r->ap_auth_type)) {
      APPEND_HDR(AUTH_TYPE, r->ap_auth_type);
    }
  }

  ap_str = (char *)ap_get_remote_logname(r);

  if (ap_str != NULL) {
    if (gsw_header_is_safe(REMOTE_IDENT, ap_str)) {
      APPEND_HDR(REMOTE_IDENT, ap_str);
    }
  }

  // the_request  (guard the pointer we actually format, not unparsed_uri)
  if (r->the_request != NULL) {
    if (gsw_header_is_safe("the_request", r->the_request)) {
      APPEND_HDR("the_request", r->the_request);
    }
  }

  /*
   *    Apache custom responses.  If we have redirected, add special headers
   */

  if (r->prev) {
    if (r->prev->args) {
      if (gsw_header_is_safe(REDIRECT_QUERY_STRING, r->prev->args)) {
        APPEND_HDR(REDIRECT_QUERY_STRING, r->prev->args);
      }
    }
    if (r->prev->uri) {
      if (gsw_header_is_safe(REDIRECT_URL, r->prev->uri)) {
        APPEND_HDR(REDIRECT_URL, r->prev->uri);
      }
    }
  }

#undef APPEND_HDR

  return write_sock(soc, hdrBuf, bufLen, r);
}

uint32_t get_content_len(request_rec *r)
{
  const char * ap_str;
  uint32_t     len = 0;

  // apr_table_get() does the case-insensitive lookup for us; the old
  // version walked the whole header table by hand
  ap_str = apr_table_get(r->headers_in, CONTENT_LENGTH);
  if (ap_str) {
    apr_int64_t  v;
    char        * end;

    // apr_parse_int64: no wrap-around like atoi, and it tells us
    // when the value does not fit
    if (apr_parse_int64(&v, (char *)ap_str, 10, &end) == APR_SUCCESS) {
      if ((v >= 0) && (v <= UINT32_MAX)) {
        len = (uint32_t) v;
      }
    }
  }
  return len;
}

// Reads the request body into a pool buffer and returns it via *postdata
// (set to NULL when there is no body).  Returns:
//   GSW_BODY_OK        - body read in full, or no body to read
//   GSW_BODY_TOO_LARGE - Content-Length exceeds WOMaxBodySize
//   GSW_BODY_ABORTED   - the client went away mid-body
//
// The old version returned the buffer (or NULL on every failure), which made
// the handler unable to tell an oversize body (413) apart from a client
// abort (400).
int read_post_data(request_rec *r, apr_off_t clength, apr_pool_t * pool,
                   gsw_app_conf * app, void ** postdata)
{
  char * postbuf = NULL;
  char * tmpbuf = NULL;
  gsw_cfg * cfg = our_dconfig(r);

  *postdata = NULL;

  if ((r->method_number == M_POST) && (ap_should_client_block(r))) {
    apr_off_t     bytesread = 0;
    apr_off_t   len_read = 0;

    if (!clength) {
      return GSW_BODY_OK;
    }

    // refuse to buffer more than WOMaxBodySize (client-controlled value)
    if ((cfg->max_body_size > 0) && (clength > cfg->max_body_size)) {
      ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                     "POST body of %lld bytes exceeds WOMaxBodySize (%lld)",
                     (long long) clength, (long long) cfg->max_body_size);
      return GSW_BODY_TOO_LARGE;
    }

    postbuf = apr_palloc(pool,clength+1);
    tmpbuf = postbuf;

    while (bytesread < clength) {
      len_read = ap_get_client_block(r, tmpbuf, clength - bytesread);
      if (len_read < 0) {
        return GSW_BODY_ABORTED;
      }
      bytesread += len_read;
      tmpbuf += len_read;
    }
    postbuf[clength] = '\0';
    *postdata = postbuf;
  }

  return GSW_BODY_OK;
}

int handle_request(request_rec *r, gsw_app_conf * app, void * postdata, uint32_t contentLen)
{
    gsw_cfg               * cfg = our_dconfig(r);
    int                     soc = -1;
    char                  * newBuf = NULL;
    apr_pool_t            * sub_pool = NULL;
    int                     refusing_seen = 0;
    int                     load_avr_seen = 0;
    int                     length_seen = 0;
    u_int32_t               newload = 0;
    size_t                  content_length = 0;
    char                  * content_type = NULL;
    char                  * content_encoding = NULL;
    char                  * location = NULL;
    int                     http_status = DECLINED;
    char                    tmpStr[512];
    apr_time_t              request_time;
    apr_time_t              done_time;
    gsw_line_reader       * reader = NULL;
    
    apr_pool_create(&sub_pool, r->pool);
    reader = (gsw_line_reader *) gsw_line_reader_init(sub_pool);
    if (reader == NULL) {
        apr_pool_destroy(sub_pool);
        return INTERNAL_ERROR;
    }
    
    
    soc = connect_host(app->host_name, app->port, cfg->connect_timeout);
      
    if (soc != -1) {
        int sh_rval = send_headers(soc, app, r);
        if (sh_rval == 0) {
            int   headers_done = 0;
            
            request_time = apr_time_now();
            // check if we are on a POST trip...
            if (postdata) {
                if ((write_sock(soc, CRLF, 2, r) != 0) ||
                    (write_sock(soc, postdata, contentLen, r) != 0)) {
                    // the backend closed the connection mid-body-send
                    ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "gsw: POST body send failed");
                    goto unreachable;
                }
            }
            if (write_sock(soc, CRLF, 2, r) != 0) {
                ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "gsw: final CRLF send failed");
                goto unreachable;
            }
            
            // HTTP/1.0 200 OK NeXT WebObjects
            newBuf = read_sock_line(soc, r, sub_pool, cfg->wait_timeout, reader);
            if (newBuf == NULL) {
                // timeout / read error / backend closed before responding
                ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "gsw: status-line read failed");
                goto unreachable;
            }
            if ((strncasecmp(newBuf,"HTTP/",5) != 0) || (strlen(newBuf) < 15)) {
                ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "Got '%s' but no 'HTTP/...'", newBuf);
                apr_pool_destroy(sub_pool);
                return DECLINED;
            } else {
                // parse the status code properly instead of assuming
                // a fixed position in the status line
                if (sscanf(newBuf, "HTTP/%*d.%*d %d", &http_status) != 1) {
                    ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "Got '%s' but no status code", newBuf);
                    apr_pool_destroy(sub_pool);
                    return DECLINED;
                }
                // map the backend status onto the client response.  The old
                // code only handled 200 and 302; anything else (404, 500,
                // 301, ...) left r->status at 200 and the client got a
                // 200 with the app's error page.
                if (http_status == 200) {
                    http_status = OK;
                } else if (http_status >= 100) {
                    r->status = http_status;
                }
            }
            
            while (headers_done == 0) {
                newBuf = read_sock_line(soc, r, sub_pool, cfg->wait_timeout, reader);
                int copy_header = 1;
                
                if (newBuf == NULL) {
                    // the socket died mid-headers: bail out as unreachable
                    // rather than pretending we saw the terminating blank line
                    ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "gsw: header read failed mid-headers");
                    goto unreachable;
                }
                if (newBuf[0] == '\0') {
                    // a blank line terminates the header block
                    headers_done = 1;
                    continue;
                }
                {
                    if (load_avr_seen == 0) {
                        if (strncasecmp(newBuf, "x-webobjects-loadaverage: ", 26) == 0) {
                            load_avr_seen = 1;
                            newload = atoi(newBuf+26);
                            copy_header = 0;
                        }
                    }
                    if (refusing_seen == 0) {
                        if (strncasecmp(newBuf, REFUSING_SESSIONS_HEADER, 32) == 0) {
                            refusing_seen = 1;
                            copy_header = 0;
                        }
                    }
                    if (length_seen == 0) {
                        if (strncasecmp(newBuf, "content-length: ", 16) == 0) {
                            length_seen = 1;
                            content_length = atol(newBuf+16);
                            snprintf(tmpStr, sizeof(tmpStr), "%zu", content_length);
                            apr_table_set(r->headers_out, "Content-Length", tmpStr);
                            copy_header = 0;
                        }
                    }
                    if (content_type == NULL) {
                        if (strncasecmp(newBuf, "content-type: ", 14) == 0) {
                            content_type = newBuf+14;
                            // a CR/LF in the value would let the backend
                            // inject headers into our response
                            if (!gsw_header_is_safe("content-type", content_type)) {
                                ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                                               "dropping backend content-type with CR/LF: '%s'", content_type);
                                content_type = NULL;
                            }
                            copy_header = 1;
                        }
                    }
                    if (content_encoding == NULL) {
                        if (strncasecmp(newBuf, "content-encoding: ", 18) == 0) {
                            content_encoding = newBuf+18;
                            if (!gsw_header_is_safe("content-encoding", content_encoding)) {
                                ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                                               "dropping backend content-encoding with CR/LF: '%s'", content_encoding);
                                content_encoding = NULL;
                            }
                            if (content_encoding != NULL) {
                                apr_table_set(r->headers_out, "Content-Encoding", content_encoding);
                            }
                            copy_header = 0;
                        }
                    }
                    if (location == NULL) {
                        // Apple has a bug, giving us a 'L', so we do that too but accept a 'l' too -- dw
                        if (strncasecmp(newBuf, "location: ", 10) == 0) {
                            location = newBuf+10;
                            if (!gsw_header_is_safe("location", location)) {
                                ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                                               "dropping backend location with CR/LF: '%s'", location);
                                location = NULL;
                            }
                            if (location != NULL) {
                                apr_table_set(r->headers_out, "Location", location);
                            }
                            //ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "location '%s'", location);
                            copy_header = 0;
                        }
                    }
                    if (copy_header == 1) {
                        char * hdrValue = index(newBuf, ':');
                        
                        if (hdrValue) {
                            *hdrValue = '\0';
                            hdrValue++; // space
                            hdrValue++; // first pos.
                            
                            // drop headers with CR/LF in key or value: they
                            // would let the backend inject headers into our
                            // response (response splitting)
                            if (!gsw_header_is_safe(newBuf, hdrValue)) {
                                ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                                               "dropping backend header with CR/LF: '%s'", newBuf);
                                copy_header = 0;
                            } else {
                                apr_table_set(r->headers_out, newBuf, hdrValue);
                            }
                        }
                    }
                }
            } // while
            
            // do the request.  204/304 responses never carry a body, and
            // a zero Content-Length means there is nothing to relay; the old
            // code also skipped those, but it did so by accident (a 204 with
            // a spurious Content-Length would have stalled the worker in the
            // body loop).
            if ((content_length > 0) && (http_status != 204) && (http_status != 304)) {
                size_t    bytesDone = 0;
                size_t    blockSize = 65536;   // 64 KiB
                ssize_t   rval = 1;
                char      * transferBuf = NULL;
                struct pollfd pfd;
                
                if (content_type != NULL) {
                    ap_set_content_type(r, content_type);
                }
                
                if (content_length < blockSize) {
                    blockSize = content_length;
                }
                transferBuf = apr_palloc(sub_pool, blockSize);
                if (! transferBuf) {
                    goto internal_error;
                }
                
                pfd.fd      = soc;
                pfd.events  = POLLIN;
                pfd.revents = 0;
                
                // The buffered line reader may have already read past the
                // header terminator into the body.  Hand those bytes to the
                // client before touching the socket again, otherwise they are
                // lost and the relay stalls waiting for data we consumed.
                {
                  char   * pendData  = NULL;
                  size_t   pendCount = 0;
                  
                  if (gsw_line_reader_pending(reader, &pendData, &pendCount)) {
                    size_t need = content_length - bytesDone;
                    size_t take = (pendCount < need) ? pendCount : need;
                    
                    if (ap_rwrite(pendData, (apr_size_t) take, r) < 0) {
                      ap_log_rerror(APLOG_MARK, APLOG_INFO, 0, r,
                                    "gsw: pending write to client failed");
                      rval = -1;
                      goto body_done;
                    }
                    bytesDone += take;
                    // advance the reader past what we just consumed
                    reader->len -= take;
                    if (reader->len > 0) {
                      memmove(reader->buffer, reader->buffer + take, reader->len);
                    }
                  }
                }
                
                while ((bytesDone < content_length) && (rval > 0)) {
                    // poll with a timeout before each read: a backend that
                    // stalls mid-body must not hang the worker forever
                    apr_time_t remaining = cfg->wait_timeout - (apr_time_now() - request_time);
                    int        rs;

                    if (remaining <= 0) {
                        ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                                       "body read: exceeded WOWaitTimeout");
                        rval = -1;
                        break;
                    }

                    do {
                        rs = poll(&pfd, 1, (int) (remaining / 1000));
                    } while ((rs < 0) && (errno == EINTR));
                    if (rs < 0) {
                        ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                                       "body read: poll failed: '%s'", strerror(errno));
                        rval = -1;
                        break;
                    }
                    if (rs == 0) {
                        ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                                       "body read: timeout waiting for data");
                        rval = -1;
                        break;
                    }
                    
                    rval = read(soc, transferBuf, blockSize);
                    if (rval < 0) {
                        if ((errno == EAGAIN) || (errno == EWOULDBLOCK) || (errno == EINTR)) {
                            continue;
                        }
                        ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                                       "body read: '%s'", strerror(errno));
                        rval = -1;
                        break;
                    }
                    if (rval == 0) {
                        // the backend closed the connection mid-body
                        ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                                       "body read: connection closed by backend after %d of %d bytes",
                                       (int) bytesDone, (int) content_length);
                        break;
                    }
                    if (ap_rwrite(transferBuf, rval, r) < 0) {
                        // the client went away; stop reading
                        ap_log_rerror(APLOG_MARK, APLOG_INFO, 0, r,
                                      "gsw: body write to client failed after %d of %d bytes",
                                      (int) bytesDone, (int) content_length);
                        rval = -1;
                        break;
                    }
                    bytesDone += (size_t) rval;
                }
                
            body_done:
                if ((rval < 0) || (bytesDone < content_length)) {
                    ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                                  "gsw: body relay incomplete (%d of %d bytes)",
                                  (int) bytesDone, (int) content_length);
                    if (bytesDone > 0) {
                        // We already streamed part of the body to the client,
                        // so retrying on another instance would emit a second,
                        // interleaved response.  Close what we have and report
                        // success; Apache will fix up the truncated length.
                        rval = 0;
                    } else {
                        // nothing sent yet: safe to mark unreachable and retry
                        goto unreachable;
                    }
                }
            }
        } else {
            ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                          "gsw: send_headers failed (%d)", sh_rval);
        }
        
        close(soc);
        
        done_time = apr_time_now();
        ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "Request took %ld ms", apr_time_msec(done_time - request_time));
        
        if ((http_status==302) && (refusing_seen==1)) {
            mark_refusing(app);
        } else {
            update_app_statistics(app, request_time, done_time, newload);
        }
        
    } else { // -1
        ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "gsw: connect to %s:%u failed",
                      app->host_name, (unsigned) app->port);
        http_status = UNREACHABLE;
    }
    
    apr_pool_destroy(sub_pool);

    return http_status;

internal_error:
    close(soc);
    apr_pool_destroy(sub_pool);
    return INTERNAL_ERROR;

unreachable:
    // the backend socket failed mid-request: close it, mark the app
    // unreachable, and let gsw_handler() retry on another instance
    close(soc);
    apr_pool_destroy(sub_pool);
    mark_unreachable(r, app);
    return UNREACHABLE;
}

