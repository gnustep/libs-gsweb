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
  const char  * p = (const char *) data;
  size_t        sent = 0;
  struct pollfd pfd;
  int           rs;
  // the socket is blocking (connect_host restores O_NONBLOCK), so send()
  // normally performs its own flow control; this deadline only bounds the
  // defensive writability waits below, so a backend that stops reading
  // cannot wedge the worker indefinitely
  apr_time_t    deadline = apr_time_now() + DEFAULT_WAIT_TIMEOUT;

//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "sending '%s' len:%d", data, len);

  pfd.fd      = socket;
  pfd.events  = POLLOUT;
  pfd.revents = 0;

  // loop until every byte is sent: a single send() may write only part
  // of the buffer, and EAGAIN/EINTR must not be reported as success
  while (sent < len) {
    ssize_t rval = send(socket, p + sent, len - sent, 0);
    apr_time_t remaining;

    if (rval > 0) {
      sent += (size_t) rval;
      continue;
    }

    remaining = deadline - apr_time_now();
    if (remaining <= 0) {
      ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                     "cannot write to socket (sent %d of %d): timed out waiting for writability",
                     (int) sent, (int) len);
      return -1;
    }

    if (rval == 0) {
      // send() returning 0 for a non-zero length is not an error, but it makes
      // no progress; treat it like EAGAIN and wait for writability
    } else if (errno == EINTR) {
      // note: on some platforms EWOULDBLOCK is defined as EAGAIN (same value),
      // so these must not be separate cases in a switch
      continue;
    } else if ((errno == EAGAIN) || (errno == EWOULDBLOCK)) {
      // should not happen on a blocking socket; wait for writability and retry
    } else {
      /*
       * Anything else (EPIPE, ECONNRESET, ...) means we've lost the
       * backend connection permanently.
       */
      ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                     "cannot write to socket (sent %d of %d): %s",
                     (int) sent, (int) len, strerror(errno));
      return -1;
    }

    do {
      rs = poll(&pfd, 1, (int) (remaining / 1000));
    } while ((rs < 0) && (errno == EINTR));

    if (rs < 0) {
      ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                     "cannot write to socket (sent %d of %d): %s",
                     (int) sent, (int) len, strerror(errno));
      return -1;
    }
    if (rs == 0) {
      ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                     "cannot write to socket (sent %d of %d): timed out waiting for writability",
                     (int) sent, (int) len);
      return -1;
    }
  }
  return 0;
}

// Allocate a per-connection line reader from pool.  Call once per backend
// socket, before the first read_sock_line() on that socket.
void * gsw_line_reader_init(apr_pool_t * pool)
{
  gsw_line_reader * reader = apr_palloc(pool, sizeof(gsw_line_reader));
  reader->len = 0;
  return reader;
}

int gsw_line_reader_pending(gsw_line_reader * reader, char ** data, size_t * count)
{
  if ((reader == NULL) || (reader->len == 0)) {
    *data  = NULL;
    *count = 0;
    return 0;
  }
  *data  = reader->buffer;
  *count = reader->len;
  return 1;
}

// Read one CRLF-terminated line from a blocking backend socket, using the
// caller-supplied per-connection reader for buffering so bytes are never
// shared across connections.
//
// Returns:
//   "" (empty pool string)  -> a blank line was read (end of headers)
//   non-empty pool string   -> the line, with CR/LF stripped
//   NULL                    -> timeout, read error, or connection closed
void * read_sock_line(int socket, request_rec *r, apr_pool_t * pool,
                      apr_time_t timeout, gsw_line_reader * reader)
{
  char    * buffer = reader->buffer;
  size_t    len    = reader->len;   // bytes currently held, all valid
  size_t    scan   = 0;             // how far we have already searched
  char     * nl;
  ssize_t   rval;
  struct pollfd pfd;
  int       rs;
  apr_time_t deadline = apr_time_now() + timeout;

  pfd.fd      = socket;
  pfd.events  = POLLIN;
  pfd.revents = 0;

  // Read in chunks and scan for the newline in userspace, instead of one
  // poll()+read() per byte.  We only ever search [scan, len): bytes before
  // `scan` were already examined and contain no '\n'.
  for (;;) {
    nl = memchr(buffer + scan, '\n', len - scan);
    if (nl != NULL) {
      break;
    }
    scan = len;   // everything up to here is known to have no '\n'

    if (len >= GSW_LINE_BUF_SIZE - 1) {
      // A single line longer than the buffer.  Keep the newest half and drop
      // the oldest; the line will be reported truncated, but we must not
      // overflow the buffer nor spin forever.
      size_t keep = len / 2;
      memmove(buffer, buffer + (len - keep), keep);
      len  = keep;
      scan = keep;   // the retained tail was already searched
    }

    {
      apr_time_t remaining = deadline - apr_time_now();

      if (remaining <= 0) {
        // the WOWaitTimeout deadline has passed
        ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "read_sock_line: timeout waiting for data");
        reader->len = 0;
        return NULL;
      }

      do {
        rs = poll(&pfd, 1, (int) (remaining / 1000));
      } while ((rs < 0) && (errno == EINTR));

      if (rs < 0) {
        ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "read_sock_line: poll failed: '%s'", strerror(errno));
        reader->len = 0;
        return NULL;
      }
      if (rs == 0) {
        // timeout: the backend accepted the connection but never responded
        ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "read_sock_line: timeout waiting for data");
        reader->len = 0;
        return NULL;
      }
    }

    rval = read(socket, buffer + len, GSW_LINE_BUF_SIZE - 1 - len);
    if (rval < 0) {
      if ((errno == EAGAIN) || (errno == EWOULDBLOCK) || (errno == EINTR)) {
        continue;
      }
      ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r, "read_sock_line:'%s'", strerror(errno));
      reader->len = 0;
      return NULL;
    }
    if (rval == 0) {
      // the backend closed the connection with no more data.
      // NOTE: anything already buffered is lost here by design -- the
      // response was truncated, so we treat the whole exchange as failed.
      ap_log_rerror(APLOG_MARK, APLOG_WARNING, 0, r,
                    "read_sock_line: connection closed by backend (%d bytes were buffered)",
                    (int) len);
      reader->len = 0;
      return NULL;
    }
    len += (size_t) rval;
  }

  // nl points at the terminating '\n'; everything before it is this line.
  {
    size_t lineLen = (size_t) (nl - buffer);
    char  * out;

    // strip a trailing CR
    if ((lineLen > 0) && (buffer[lineLen - 1] == '\r')) {
      lineLen--;
    }

    // copy the line out before reusing the buffer for the leftover shift
    out = apr_palloc(pool, lineLen + 1);
    memcpy(out, buffer, lineLen);
    out[lineLen] = '\0';

    // keep any bytes read past the newline for the next call
    {
      size_t leftover = (size_t) ((buffer + len) - (nl + 1));
      memmove(buffer, nl + 1, leftover);
      reader->len = leftover;
    }

    // an empty string means a blank line (end of headers); it is NOT an error
    return out;
  }
}

static int contains_encoded_crlf(const char * s)
{
  // returns 1 if s contains %0d or %0a (case-insensitive), i.e. a
  // percent-encoded CR or LF
  for (; *s != '\0'; s++) {
    if ((*s == '%') && (s[1] == '0')) {
      char c = s[2];
      if ((c == 'd') || (c == 'D') || (c == 'a') || (c == 'A')) {
	return 1;
      }
    }
  }
  return 0;
}

static int header_part_is_safe(const char * part)
{
  size_t len = strlen(part);

  if (memchr(part, '\r', len) != NULL) {
    return 0;
  }
  if (memchr(part, '\n', len) != NULL) {
    return 0;
  }
  if (contains_encoded_crlf(part)) {
    return 0;
  }
  return 1;
}

int gsw_header_is_safe(const char * key, const char * value)
{
  // CR or LF in a header key or value would let the sender inject extra
  // headers or split the message (response splitting, cf. CVE-2016-4975).
  // The attack mostly comes from the internet-facing side, so this checks
  // both directions: client headers we forward to the backend, and backend
  // headers we copy into the client response.
  //
  // Percent-encoded CR/LF (%0d / %0a) is rejected as well: the adaptor
  // forwards values verbatim, and the receiving side may decode them,
  // which would reintroduce the raw CR/LF after this check.
  if (!header_part_is_safe(key)) {
    return 0;
  }
  if ((value != NULL) && !header_part_is_safe(value)) {
    return 0;
  }
  return 1;
}

