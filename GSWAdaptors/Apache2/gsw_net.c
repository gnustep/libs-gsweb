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
/* Socket level helpers.  Pure network code: no module configuration         */
/* dependencies beyond the request_rec used for logging.                     */
/*                                                                          */
/*--------------------------------------------------------------------------*/

// returns the socket or <0 on error

int connect_host(char * hostname, u_int16_t port, apr_time_t timeout)
{
  int                  sock = -1;
  int                  flag = 1;
  struct addrinfo      hints;
  struct addrinfo     * res = NULL;
  struct addrinfo     * ai;
  int                  gai;
  char                 portstr[8];

  memset(&hints, 0, sizeof(hints));
  hints.ai_family   = AF_UNSPEC;   // IPv4 and IPv6
  hints.ai_socktype = SOCK_STREAM;

  snprintf(portstr, sizeof(portstr), "%u", (unsigned) port);

  gai = getaddrinfo(hostname, portstr, &hints, &res);
  if (gai != 0) {
    return -1;
  }

  for (ai = res; ai != NULL; ai = ai->ai_next) {
    int flags;

    sock = socket(ai->ai_family, ai->ai_socktype, ai->ai_protocol);
    if (sock < 0) {
      continue;
    }

    setsockopt(sock, IPPROTO_TCP, TCP_NODELAY,
               (char *) &flag, sizeof(int));

    // non-blocking connect + poll with timeout
    flags = fcntl(sock, F_GETFL, 0);
    if ((flags >= 0) && (fcntl(sock, F_SETFL, flags | O_NONBLOCK) == 0)) {
      if (connect(sock, ai->ai_addr, ai->ai_addrlen) != 0) {
        struct pollfd pfd;
        int           rs;
        int           so_error = 0;
        socklen_t     len = sizeof(so_error);
        int           timeout_ms = (int) (timeout / 1000);  // apr_time_t is microseconds

        if (errno != EINPROGRESS) {
          close(sock);
          sock = -1;
          continue;
        }

        pfd.fd      = sock;
        pfd.events  = POLLOUT;   // a connecting socket becomes writable when done
        pfd.revents = 0;

        do {
          rs = poll(&pfd, 1, timeout_ms);
        } while ((rs < 0) && (errno == EINTR));

        if (rs <= 0) {
          // timeout or poll error: try the next address
          close(sock);
          sock = -1;
          continue;
        }

        // check the result of the connect
        if ((getsockopt(sock, SOL_SOCKET, SO_ERROR, &so_error, &len) != 0) ||
            (so_error != 0)) {
          close(sock);
          sock = -1;
          continue;
        }
      }

      // restore blocking mode
      fcntl(sock, F_SETFL, flags);
      break;
    }

    // fcntl failed: fall back to a plain blocking connect
    if (connect(sock, ai->ai_addr, ai->ai_addrlen) == 0) {
      break;
    }

    close(sock);
    sock = -1;
  }

  freeaddrinfo(res);

  return sock;
}

int write_sock(int socket, const void *data, size_t len, request_rec *r)
{
  int        rval = 0;

//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "sending '%s' len:%d", data, len);

    rval = send(socket, data, len, 0);

    if (rval < 0) {

        /*
         * Anything except EAGAIN or EWOULDBLOCK is trouble. If it's
         * EPIPE or ECONNRESET, assume we've lost the backend
         * connection permanently.
         */
        switch (errno) {
            case EAGAIN:
                break;
            case EINTR:
                break;
            default:
        ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "cannot write to socket (len %d)", (int)len);
        return -1;
                break;
        }
    }
  return 0;
}

void * read_sock_line(int socket, request_rec *r, apr_pool_t * pool, apr_time_t timeout)
{
  size_t        rval = 1;
  int   i = 0;
  int   done = 0;
  char  buffer[1024];
  char  b;
  struct pollfd pfd;
  int           rs;
  apr_time_t    deadline = apr_time_now() + timeout;
  
  
  pfd.fd      = socket;
  pfd.events  = POLLIN;
  pfd.revents = 0;
  
  while (((done == 0) && (i < sizeof(buffer) -1)) && (rval >0)) {
    apr_time_t remaining = deadline - apr_time_now();
    int        wait_ms   = (remaining > 0) ? (int) (remaining / 1000) : 0;

    rs = poll(&pfd, 1, wait_ms);
    if ((rs < 0) && (errno == EINTR)) {
      continue;
    }
    if ((rs <= 0) || (pfd.revents == 0)) {
      // timeout: the backend accepted the connection but never responded
      ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "read_sock_line: timeout waiting for data");
      return NULL;
    }
    
    rval= read(socket, &b, 1);
    
    if (rval == -1) {
      if ((errno == EAGAIN) || (errno == EWOULDBLOCK)) {
        continue;
      }
      ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "read_sock_line:'%s'", strerror(errno));

      return NULL;
    }
    
    buffer[i] = b;
    
    if (b == '\n') {
      done = 1;
      buffer[i] = '\0';
      if ((i>0) && (buffer[i-1] == '\r')) {
        buffer[i-1] = '\0';
      }
    }
    i++;
  }
  
  buffer[i] = '\0';
     
    // in case we got a \0 in the string?
  i = strlen(buffer);
  if (i > 0) {
    void * newBuf = apr_palloc(pool,i+1);
    strncpy(newBuf, buffer, i+1);
    //   ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "read_sock_line:'%s'", newBuf);
    return newBuf;
  }
  return NULL;
}

