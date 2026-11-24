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

#ifndef GSW_PRIVATE_H
#define GSW_PRIVATE_H

/*--------------------------------------------------------------------------*/
/*                                                                          */
/* Private declarations shared by the mod_gsw source files.  This header is */
/* NOT part of the public interface: it must only be included by the        */
/* gsw adaptor sources (mod_gsw.c, gsw_*.c, gsw_compat.h).                  */
/*                                                                          */
/*--------------------------------------------------------------------------*/

/* Apache */
#include "httpd.h"
#include "http_config.h"
#include "http_core.h"
#include "http_log.h"
#include "http_main.h"
#include "http_protocol.h"
#include "http_request.h"
#include "util_script.h"
#include "http_connection.h"

/* APR.  The baseline mod_gsw.c relied on httpd.h pulling these in
 * transitively; they are listed explicitly (only headers that certainly
 * exist in every APR release) because this header is now included by
 * several files.  The global-mutex API (apr_global_mutex_t and friends)
 * still arrives via the httpd headers, exactly as it did before the split.
 */
#include "apr_pools.h"
#include "apr_tables.h"
#include "apr_strings.h"
#include "apr_lib.h"
#include "apr_time.h"
#include "apr_shm.h"

/* HTTP status codes.  httpd.h does not include http_status.h, and the
 * 413 macro name changed across Apache releases (HTTP_REQUEST_ENTITY_TOO_LARGE
 * in 2.2, HTTP_PAYLOAD_TOO_LARGE in 2.4), so define what we use ourselves.
 */
#ifndef HTTP_PAYLOAD_TOO_LARGE
#define HTTP_PAYLOAD_TOO_LARGE 413
#endif
#ifndef HTTP_BAD_REQUEST
#define HTTP_BAD_REQUEST 400
#endif
#ifndef HTTP_NOT_FOUND
#define HTTP_NOT_FOUND 404
#endif

/* POSIX */
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netdb.h>
#include <arpa/inet.h>
// needed on FreeBSD at least
#include <unistd.h>
#include <poll.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <ctype.h>

/*--------------------------------------------------------------------------*/
/*                                                                          */
/* Data declarations.                                                       */
/*                                                                          */
/* Here are the types, constants and external cells private to our module.  */
/*                                                                          */
/*--------------------------------------------------------------------------*/

/*
 * Sample configuration record.  Used for both per-directory and per-server
 * configuration data.
 *
 * It's perfectly reasonable to have two different structures for the two
 * different environments.  The same command handlers will be called for
 * both, though, so the handlers need to be able to tell them apart.  One
 * possibility is for both structures to start with an int which is 0 for
 * one and 1 for the other.
 *
 * Note that while the per-directory and per-server configuration records are
 * available to most of the module handlers, they should be treated as
 * READ-ONLY by all except the command and merge handlers.  Sometimes handlers
 * are handed a record that applies to the current location by implication or
 * inheritance, and modifying it will change the rules for other locations.
 */


typedef struct gsw_cfg {
  int cmode;                  /* Environment to which record applies
   * (directory, server, or combination).
   */
#define CONFIG_MODE_SERVER 1
#define CONFIG_MODE_DIRECTORY 2
#define CONFIG_MODE_COMBO 3     /* Shouldn't ever happen. */
  int local;                  /* Boolean: "Example" directive declared
   * here?
   */
  int congenital;             /* Boolean: did we inherit an "Example"? */
  char *trace;                /* Pointer to trace string. */
  char *loc;                  /* Location to which this record applies. */
  int  showApps;
  apr_table_t * app_table;
  apr_pool_t  * pool;             // the pool this cfg was allocated from
  apr_time_t   connect_timeout;   // WOConnectTimeout, default 5 sec
  apr_time_t   wait_timeout;      // WOWaitTimeout, default 60 sec
  apr_off_t    max_body_size;     // WOMaxBodySize, default 8 MiB
  int          retry_count;       // WORetryCount, default 3
  int          balancer;          // WOBalancer, default BALANCER_LOWEST_LOAD
  int          instance_count;    // InstanceCount, default 10
  int          last_app_index;    // running counter while App directives are read
  apr_table_t * app_index;        // lower-cased app name -> apr_array of gsw_app_conf *
  int          app_index_built;   // set once gsw_build_app_index() has run for this cfg
  int          rr_counter;        // round-robin position, per config (WOBalancer round-robin)
} gsw_cfg;

#define MAX_URL_LENGTH        256
#define MAX_NAME_LENGTH        64
#define UNREACHABLE       -10
#define INTERNAL_ERROR    500

// CRLF ("\015\012") comes from httpd.h; do not redefine it here.

// load-balancing strategies for unpinned requests (WOBalancer)
#define BALANCER_LOWEST_LOAD  0
#define BALANCER_ROUND_ROBIN  1

typedef struct gsw_app_conf {
  char        app_name[MAX_NAME_LENGTH];
  char        host_name[MAX_NAME_LENGTH];
  u_int16_t   instance_number;
  u_int16_t   port;
  u_int16_t   total_index;                  // index in shared memory
  char        redirect_url[MAX_URL_LENGTH];    /* in case of error */

} gsw_app_conf;


#define GSW_INST_CACHE          "gsw_inst_cache"
#define X_WO_VERSION_HEADER     "x-webobjects-adaptor-version: 20130612\r\n"
#define SERVER_SOFTWARE         "SERVER_SOFTWARE"
#define SERVER_NAME             "SERVER_NAME"
#define SERVER_PORT             "SERVER_PORT"
#ifndef REMOTE_HOST
#define REMOTE_HOST             "REMOTE_HOST"
#endif
#define DOCUMENT_ROOT           "DOCUMENT_ROOT"
#define SERVER_ADMIN            "SERVER_ADMIN"
#define SCRIPT_FILENAME         "SCRIPT_FILENAME"
#define REMOTE_PORT             "REMOTE_PORT"
#define REMOTE_ADDR             "REMOTE_ADDR"
#define REMOTE_USER             "REMOTE_USER"
#define AUTH_TYPE               "AUTH_TYPE"
#define REMOTE_IDENT            "REMOTE_IDENT"
#define REDIRECT_QUERY_STRING   "REDIRECT_QUERY_STRING"
#define REDIRECT_URL            "REDIRECT_URL"
#define CONTENT_LENGTH          "content-length"
#define DEFAULT_APP_COUNT       10
#define REFUSING_SESSIONS_HEADER "x-webobjects-refusenewsessions: "
#define DEFAULT_CONNECT_TIMEOUT  apr_time_from_sec(5)
#define DEFAULT_WAIT_TIMEOUT     apr_time_from_sec(60)
#define DEFAULT_MAX_BODY_SIZE    (8 * 1024 * 1024)   // 8 MiB
#define DEFAULT_RETRY_COUNT      3
#define DEFAULT_BALANCER         BALANCER_LOWEST_LOAD

// header validation for CRLF injection / response splitting (cf.
// CVE-2016-4975): returns 0 if key or value contains a raw CR/LF or a
// percent-encoded one (%0d / %0a, case-insensitive).  Used both for
// headers copied from the backend into the client response and for
// client headers forwarded to the backend.
int gsw_header_is_safe(const char * key, const char * value);

// read_post_data() results (gsw_request.c)
#define GSW_BODY_OK        0
#define GSW_BODY_TOO_LARGE 1
#define GSW_BODY_ABORTED   2

typedef struct exipc_data {
  apr_time_t    last_response_time; // in sec since January 1, 1970
  apr_time_t    last_request_time;  // in sec since January 1, 1970
  u_int32_t load;
  u_int8_t unreachable;             // 0=online 1=unreachable
  u_int8_t refusing;                // 0=serving new sessions 1=refusing
} exipc_data;

#define ADAPTOR_PREFIX "/wo/"
// xx handler uri: wo/TCWebMail.woa/1/wo/xxxx
//                 PREFIX/APPNAME.woa/INSTANCE/...

/*
 * Declare ourselves so the configuration routines can find and know us.
 * The definition lives in mod_gsw.c, at the end of the module.
 */
extern module AP_MODULE_DECLARE_DATA gsw_module;

/*
 * Shared cells.  Each one is *defined* in exactly one source file, which is
 * noted after the declaration.
 */

/*
 * Let's set up a module-local static cell to point to the accreting callback
 * trace.  As each API callback is made to us, we'll tack on the particulars
 * to whatever we've already recorded.  To avoid massive memory bloat as
 * directories are walked again and again, we record the routine/environment
 * the first time (non-request context only), and ignore subsequent calls for
 * the same routine/environment.
 *
 * These are sample-module leftovers (defined in gsw_hooks_stub.c).
 */
extern const char *trace;
extern apr_table_t *static_calls_made;

/*
 * To avoid leaking memory from pools other than the per-request one, we
 * allocate a module-private pool, and then use a sub-pool of that which gets
 * freed each time we modify the trace.  That way previous layers of trace
 * data don't get lost.
 */
extern apr_pool_t *gsw_pool;
extern apr_pool_t *gsw_subpool;

// shared memory  (defined in gsw_shm.c)
extern apr_shm_t *exipc_shm;
extern char *shmfilename;
extern apr_global_mutex_t *exipc_mutex;
extern char *mutexfilename;

/*--------------------------------------------------------------------------*/
/*                                                                          */
/* Prototypes of the functions that are used from another source file.      */
/* They are grouped by the file that defines them.  Functions used only     */
/* inside their own file stay static there and are not listed here.         */
/*                                                                          */
/*--------------------------------------------------------------------------*/

/* gsw_cmds.c */
extern const command_rec gsw_cmds[];

/* gsw_config.c */
gsw_cfg * our_dconfig(const request_rec *r);
gsw_cfg * our_cconfig(const conn_rec *c);
void * gsw_create_dir_config(apr_pool_t *p, char *dirspec);
void * gsw_merge_dir_config(apr_pool_t *p, void *parent_conf,
                            void *newloc_conf);
void * gsw_create_server_config(apr_pool_t *p, server_rec *s);
void * gsw_merge_server_config(apr_pool_t *p, void *server1_conf,
                               void *server2_conf);

/* gsw_shm.c */
// Copies the exipc_data entries for the given app instances (by their
// total_index) into a pool-allocated array; the mutex is held only for the
// copy.  Returns NULL if the mutex cannot be taken.
void * read_shared_mem(apr_pool_t * pool, int count, const u_int16_t * indexes);
void mark_unreachable(request_rec *r, gsw_app_conf * app);
void mark_refusing(gsw_app_conf * app);
void update_app_statistics(gsw_app_conf * app, apr_time_t last_request_time,
                           apr_time_t last_response_time, u_int32_t load);
void init_shared_mem(const apr_shm_t * xxx, int count, server_rec * s);

/* gsw_apps.c */
int print_app(void *rec, const char *key, gsw_app_conf *appconf);
// Builds cfg->app_index (name -> instance list) from cfg->app_table; called
// once at config time, after all App directives have been read.
void gsw_build_app_index(gsw_cfg *cfg);
gsw_app_conf * find_app_by_name(char * name, gsw_cfg *cfg, request_rec *r);
gsw_app_conf * find_app(request_rec *r);
int gsw_parse_uri(const char * uri,
                  char * app_name, size_t app_name_size,
                  int * instance_nr,
                  char * rest, size_t rest_size);

/* gsw_net.c */
int connect_host(char * hostname, u_int16_t port, apr_time_t timeout);
int write_sock(int socket, const void *data, size_t len, request_rec *r);

// Per-connection buffered-line reader.  One instance is created per backend
// socket (see gsw_line_reader_init) and passed to every read_sock_line() call
// for that connection, so leftover bytes never leak across connections.
#define GSW_LINE_BUF_SIZE 8192

typedef struct gsw_line_reader {
  char    buffer[GSW_LINE_BUF_SIZE];
  size_t  len;      // valid bytes currently held in buffer
} gsw_line_reader;

void * gsw_line_reader_init(apr_pool_t * pool);
// Exposes bytes the buffered reader already read past the last line header.
// Sets *data to the pending bytes and *count to how many; the pointer is valid
// until the next read_sock_line() on this reader.  Returns 0 if none pending.
int gsw_line_reader_pending(gsw_line_reader * reader, char ** data, size_t * count);
void * read_sock_line(int socket, request_rec *r, apr_pool_t * pool,
                      apr_time_t timeout, gsw_line_reader * reader);

/* gsw_request.c */
const char * fixRequestString(request_rec *r, gsw_app_conf *app);
uint32_t get_content_len(request_rec *r);
// Reads the request body into a pool buffer and returns it via *postdata
// (NULL when there is no body).  Returns:
//   GSW_BODY_OK        - body read in full, or no body to read
//   GSW_BODY_TOO_LARGE - Content-Length exceeds WOMaxBodySize
//   GSW_BODY_ABORTED   - the client went away mid-body
int read_post_data(request_rec *r, apr_off_t clength, apr_pool_t * pool,
                   gsw_app_conf * app, void ** postdata);
int handle_request(request_rec *r, gsw_app_conf * app, void * postdata,
                   uint32_t contentLen);

/* gsw_status.c */
void showApps(request_rec * r, gsw_cfg *dcfg);

/* gsw_handler.c */
int gsw_handler(request_rec *r);

/* gsw_lifecycle.c */
int gsw_pre_config(apr_pool_t *pconf, apr_pool_t *plog, apr_pool_t *ptemp);
int gsw_post_config(apr_pool_t *pconf, apr_pool_t *plog, apr_pool_t *ptemp,
                   server_rec *s);
int gsw_open_logs(apr_pool_t *pconf, apr_pool_t *plog, apr_pool_t *ptemp,
                  server_rec *s);
void gsw_child_init(apr_pool_t *p, server_rec *s);

/* gsw_hooks_stub.c */
void setup_module_cells(void);
void gsw_insert_filter(request_rec *r);
int gsw_quick_handler(request_rec *r, int lookup_uri);
int gsw_pre_connection(conn_rec *c, void *csd);
int gsw_process_connection(conn_rec *c);
int gsw_post_read_request(request_rec *r);
int gsw_translate_handler(request_rec *r);
int gsw_map_to_storage_handler(request_rec *r);
int gsw_header_parser_handler(request_rec *r);
int gsw_check_user_id(request_rec *r);
int gsw_auth_checker(request_rec *r);
int gsw_access_checker(request_rec *r);
int gsw_type_checker(request_rec *r);
int gsw_fixer_upper(request_rec *r);
int gsw_logger(request_rec *r);

#endif /* GSW_PRIVATE_H */
