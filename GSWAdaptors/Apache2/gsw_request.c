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

static int send_header_string(int soc, const char * key, const char * value, request_rec *r)
{
    int                     retval = 0;
    char tmpStr[512];
    
    snprintf(tmpStr, sizeof(tmpStr)-1, "%s: %s\r\n",key, value);
    retval = write_sock(soc, tmpStr, strlen(tmpStr), r);
    return retval;
    
}

const char * fixRequestString(request_rec *r, gsw_app_conf *app)
{
  char            * req_str = r->the_request;
  size_t            len = strlen(req_str);
  char            * appName = apr_palloc(r->pool,len+5);
  char            * spaceStr;
  char            * instanceStr;
  char            * restStr = NULL;
  int               instance_nr = -1;
  char            * newString = NULL;

  strncpy(appName, req_str, len);

  // GET /wo/PBX HTTP/1.1
  
  if ((appName = index(appName, '/'))) {
    appName++;
    if ((appName = index(appName, '/'))) {
      appName++;
      if ((spaceStr = index(appName, ' '))) {
        *spaceStr = '\0';
        instanceStr = appName;
        instanceStr++;
        if ((instanceStr = index(appName, '/'))) {
          *instanceStr = '\0';
          instanceStr++;
          if ((spaceStr = index(instanceStr, '/'))) {
            *spaceStr = '\0';
            restStr = spaceStr;
            restStr++;
          }
//          ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "instanceStr:'%s'", instanceStr);
        }
//        ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "appName:'%s'", appName);
//        ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "restStr:'%s'", restStr);
      }
    }
  }
  
  if (!restStr) {
    restStr = "";
  }
  
  if ((spaceStr = index(appName, '.'))) {
    *spaceStr = '\0';
  }
  
  
  newString = apr_psprintf(r->pool, "%s %s%s.woa/%d/%s HTTP/1.1\r\n", r->method, ADAPTOR_PREFIX, appName, app->instance_number
,restStr);

//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "newString:'%s'", newString);

  
  return newString;
}

static int send_headers(int soc, gsw_app_conf *app, request_rec *r)
{
  apr_array_header_t    * hdrs_arr = NULL;
  apr_table_entry_t     * hdrs = NULL;
  int                     retval = 0;
  int                     i = 0;
  char tmpStr[512];
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
//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "send_headers:'%s'", tmpStr);

  if (retval != 0) {
    return retval;
  }
  
  for (i = 0; i < hdrs_arr->nelts; ++i) {
    if (!hdrs[i].key)
      continue;
    snprintf(tmpStr, sizeof(tmpStr), "%s: %s\r\n", hdrs[i].key, hdrs[i].val);
    retval = write_sock(soc,tmpStr,strlen(tmpStr), r);
    if (retval != 0) {
      return retval;
    }
  }
  // write x-webobjects-adaptor-version to the app
  snprintf(tmpStr, sizeof(tmpStr), X_WO_VERSION_HEADER);

  retval = write_sock(soc, tmpStr, strlen(tmpStr), r);
  
  retval = send_header_string(soc, SERVER_NAME, s->server_hostname, r);

  // SERVER_PORT
  snprintf(tmpStr, sizeof(tmpStr), "SERVER_PORT: %hu\r\n",ap_get_server_port(r));
  retval = write_sock(soc, tmpStr, strlen(tmpStr), r);

#if (AP_SERVER_MAJORVERSION_NUMBER == 2) && (AP_SERVER_MINORVERSION_NUMBER < 4)
    retval = send_header_string(soc, REMOTE_ADDR, c->remote_ip, r);
#else
    retval = send_header_string(soc, REMOTE_ADDR, c->client_ip, r);
#endif

  if (r->user != NULL) {
    retval = send_header_string(soc, REMOTE_USER, r->user, r);
  }
  
  if (r->ap_auth_type != NULL) {
    retval = send_header_string(soc, AUTH_TYPE, r->ap_auth_type, r);
  }
  
  ap_str = (char *)ap_get_remote_logname(r);
  
  if (ap_str != NULL) {
    retval = send_header_string(soc, REMOTE_IDENT, ap_str, r);
  }

  // the_request
  if (r->unparsed_uri != NULL) {
    retval = send_header_string(soc, "the_request", r->the_request, r);
  }
  
  /*
   *    Apache custom responses.  If we have redirected, add special headers
   */

  if (r->prev) {
    if (r->prev->args) {
      retval = send_header_string(soc, REDIRECT_QUERY_STRING, r->prev->args, r);
    }
    if (r->prev->uri) {
      retval = send_header_string(soc, REDIRECT_URL, r->prev->uri, r);
    }
  }
  
  return retval;
}

uint32_t get_content_len(request_rec *r)
{
  apr_array_header_t    * hdrs_arr = NULL;
  apr_table_entry_t     * hdrs = NULL;
  int                     i = 0;
  const char            * ap_str;
  uint32_t                len = 0;
  
  hdrs_arr = (apr_array_header_t*) apr_table_elts(r->headers_in);
  hdrs = (apr_table_entry_t *) hdrs_arr->elts;
  
  for (i = 0; i < hdrs_arr->nelts; ++i) {
    if (!hdrs[i].key)
      continue;
    if (strcasecmp(hdrs[i].key, CONTENT_LENGTH) == 0) {
      apr_int64_t  v;
      char        * end;

      // apr_parse_int64: no wrap-around like atoi, and it tells us
      // when the value does not fit
      if (apr_parse_int64(&v, (char *)hdrs[i].val, 10, &end) == APR_SUCCESS) {
        if ((v >= 0) && (v <= UINT32_MAX)) {
          len = (uint32_t) v;
        }
      }
      break;
    }
  }
  return len;
}

void * read_post_data(request_rec *r, apr_off_t clength, apr_pool_t * pool, gsw_app_conf * app)
{
  char * postbuf = NULL;
  char * tmpbuf = NULL;
  gsw_cfg * cfg = our_dconfig(r);
  if ((r->method_number == M_POST) && (ap_should_client_block(r))) {
    apr_off_t     bytesread = 0;
    apr_off_t   len_read = 0;
    
    if (!clength) {
      return NULL;
    }
    
    // refuse to buffer more than WOMaxBodySize (client-controlled value)
    if ((cfg->max_body_size > 0) && (clength > cfg->max_body_size)) {
      ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                     "POST body of %lld bytes exceeds WOMaxBodySize (%lld)",
                     (long long) clength, (long long) cfg->max_body_size);
      return NULL;
    }
    
    postbuf = apr_palloc(pool,clength+1);
    tmpbuf = postbuf;

    while (bytesread < clength) {
      len_read = ap_get_client_block(r, tmpbuf, clength - bytesread);
      if (len_read < 0) {
        return NULL;
      }
      bytesread += len_read;
      tmpbuf += len_read;
    }
    postbuf[clength] = '\0';
  }

  return postbuf;
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
    
    apr_pool_create(&sub_pool, r->pool);
    
    
    soc = connect_host(app->host_name, app->port, cfg->connect_timeout);
      
    if (soc != -1) {
        if (send_headers(soc, app, r)  == 0) {
            int   headers_done = 0;
            
            request_time = apr_time_now();
            // check if we are on a POST trip...
            if (postdata) {
                write_sock(soc, CRLF, 2, r);
                write_sock(soc, postdata, contentLen, r);
            }
            write_sock(soc, CRLF, 2, r);
            
            // HTTP/1.0 200 OK NeXT WebObjects
            if ((newBuf = read_sock_line(soc, r, sub_pool, cfg->wait_timeout))) {
                if ((strncasecmp(newBuf,"HTTP/",5) != 0) || (strlen(newBuf) < 15)) {
                    ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "Got '%s' but no 'HTTP/...'", newBuf);
                    apr_pool_destroy(sub_pool);
                    return DECLINED;
                } else {
                    // parse the status code properly instead of assuming
                    // a fixed position in the status line
                    if (sscanf(newBuf, "HTTP/%*d.%*d %d", &http_status) != 1) {
                        ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "Got '%s' but no status code", newBuf);
                        apr_pool_destroy(sub_pool);
                        return DECLINED;
                    }
                    if (http_status==200) {
                        http_status=OK;
                    }
                    if (http_status == 302) {
                        r->status = http_status;
                    }
                }
            }
            
            while (headers_done == 0) {
                newBuf = read_sock_line(soc, r, sub_pool, cfg->wait_timeout);
                int copy_header = 1;
                
                if (newBuf != NULL) {
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
                            copy_header = 1;
                        }
                    }
                    if (content_encoding == NULL) {
                        if (strncasecmp(newBuf, "content-encoding: ", 18) == 0) {
                            content_encoding = newBuf+18;
                            apr_table_set(r->headers_out, "Content-Encoding", content_encoding);
                            copy_header = 0;
                        }
                    }
                    if (location == NULL) {
                        // Apple has a bug, giving us a 'L', so we do that too but accept a 'l' too -- dw
                        if (strncasecmp(newBuf, "location: ", 10) == 0) {
                            location = newBuf+10;
                            apr_table_set(r->headers_out, "Location", location);
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
                            
                            apr_table_set(r->headers_out, newBuf, hdrValue);
                        }
                    }
                } else {
                    headers_done = 1;
                }
            } // while
            
            // do the request
            if ((content_length > 0)) {
                size_t    bytesDone = 0;
                size_t    blockSize = 1024;
                size_t    rval=1;
                char      * transferBuf = NULL;
                
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
                
                while ((bytesDone < content_length) && (rval > 0)) {
                    rval= read(soc, transferBuf, blockSize);
                    if (rval > 0) {
                        ap_rwrite(transferBuf, rval, r);
                        bytesDone += rval;
                    }
                }
            }
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
        http_status = UNREACHABLE;
    }
    
    //apr_pool_destroy(sub_pool);
    
    return http_status;
    
internal_error:
    close(soc);
    return INTERNAL_ERROR;
}

