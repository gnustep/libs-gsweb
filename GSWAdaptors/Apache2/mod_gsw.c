/*
   Copyright (C) 1999, 2000 Free Software Foundation, Inc.
   
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

#include "httpd.h"
#include "http_config.h"
#include "http_core.h"
#include "http_log.h"
#include "http_main.h"
#include "http_protocol.h"
#include "http_request.h"
#include "util_script.h"
#include "http_connection.h"
#include "apr_tables.h"

#include "apr_strings.h"

#include <stdio.h>

#include <sys/socket.h> 
#include <netinet/in.h> 
#include <netdb.h> 
#include <arpa/inet.h> 

/*--------------------------------------------------------------------------*/
/*                                                                          */
/* Data declarations.                                                       */
/*                                                                          */
/* Here are the static cells and structure declarations private to our      */
/* module.                                                                  */
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
} gsw_cfg;


typedef struct gsw_app_conf {
  char      app_name[64];
  char      host_name[64];
  u_int16_t instance_number;
  time_t    last_response_time;  // in sec since January 1, 1970
  u_int8_t  load;                // 0..255
  u_int16_t port;
  u_int8_t  unreachable;         // 0=online 1=unreachable
} gsw_app_conf;

#define GSW_INST_CACHE "gsw_inst_cache"
//#define CRLF           "\r\n"

/*
 * Let's set up a module-local static cell to point to the accreting callback
 * trace.  As each API callback is made to us, we'll tack on the particulars
 * to whatever we've already recorded.  To avoid massive memory bloat as
 * directories are walked again and again, we record the routine/environment
 * the first time (non-request context only), and ignore subsequent calls for
 * the same routine/environment.
 */
static const char *trace = NULL;
static apr_table_t *static_calls_made = NULL;

/*
 * To avoid leaking memory from pools other than the per-request one, we
 * allocate a module-private pool, and then use a sub-pool of that which gets
 * freed each time we modify the trace.  That way previous layers of trace
 * data don't get lost.
 */
static apr_pool_t *gsw_pool = NULL;
static apr_pool_t *gsw_subpool = NULL;

/*
 * Declare ourselves so the configuration routines can find and know us.
 * We'll fill it in at the end of the module.
 */
module AP_MODULE_DECLARE_DATA gsw_module;

#define ADAPTOR_PREFIX "/wo/"
// xx handler uri: wo/TCWebMail.woa/1/wo/xxxx
//                 PREFIX/APPNAME.woa/INSTANCE/...



// callback function for looping the table

int print_app(void *rec, const char *key, const char *value)
{

  request_rec  *r       = rec;
  gsw_app_conf *appconf = (gsw_app_conf *) value;

  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "Key:'%s'", key);
  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "app_name:'%s'", appconf->app_name);
  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "host_name:'%s'", appconf->host_name);
  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "instance_number:'%u'", appconf->instance_number);
  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "load:'%d'", appconf->load);
  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "port:'%u'", appconf->port);
  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "unreachable:'%d'", appconf->unreachable);
  
  return 1; // continue loop
}



/*--------------------------------------------------------------------------*/
/*                                                                          */
/* The following pseudo-prototype declarations illustrate the parameters    */
/* passed to command handlers for the different types of directive          */
/* syntax.  If an argument was specified in the directive definition        */
/* (look for "command_rec" below), it's available to the command handler    */
/* via the (void *) info field in the cmd_parms argument passed to the      */
/* handler (cmd->info for the example below).                              */
/*                                                                          */
/*--------------------------------------------------------------------------*/

/*
 * Command handler for a NO_ARGS directive.  Declared in the command_rec
 * list with
 *   AP_INIT_NO_ARGS("directive", function, mconfig, where, help)
 *
 * static const char *handle_NO_ARGS(cmd_parms *cmd, void *mconfig);
 */

/*
 * Command handler for a RAW_ARGS directive.  The "args" argument is the text
 * of the commandline following the directive itself.  Declared in the
 * command_rec list with
 *   AP_INIT_RAW_ARGS("directive", function, mconfig, where, help)
 *
 * static const char *handle_RAW_ARGS(cmd_parms *cmd, void *mconfig,
 *                                    const char *args);
 */

/*
 * Command handler for a FLAG directive.  The single parameter is passed in
 * "bool", which is either zero or not for Off or On respectively.
 * Declared in the command_rec list with
 *   AP_INIT_FLAG("directive", function, mconfig, where, help)
 *
 * static const char *handle_FLAG(cmd_parms *cmd, void *mconfig, int bool);
 */

/*
 * Command handler for a TAKE1 directive.  The single parameter is passed in
 * "word1".  Declared in the command_rec list with
 *   AP_INIT_TAKE1("directive", function, mconfig, where, help)
 *
 * static const char *handle_TAKE1(cmd_parms *cmd, void *mconfig,
 *                                 char *word1);
 */

/*
 * Command handler for a TAKE2 directive.  TAKE2 commands must always have
 * exactly two arguments.  Declared in the command_rec list with
 *   AP_INIT_TAKE2("directive", function, mconfig, where, help)
 *
 * static const char *handle_TAKE2(cmd_parms *cmd, void *mconfig,
 *                                 char *word1, char *word2);
 */

/*
 * Command handler for a TAKE3 directive.  Like TAKE2, these must have exactly
 * three arguments, or the parser complains and doesn't bother calling us.
 * Declared in the command_rec list with
 *   AP_INIT_TAKE3("directive", function, mconfig, where, help)
 *
 * static const char *handle_TAKE3(cmd_parms *cmd, void *mconfig,
 *                                 char *word1, char *word2, char *word3);
 */

/*
 * Command handler for a TAKE12 directive.  These can take either one or two
 * arguments.
 * - word2 is a NULL pointer if no second argument was specified.
 * Declared in the command_rec list with
 *   AP_INIT_TAKE12("directive", function, mconfig, where, help)
 *
 * static const char *handle_TAKE12(cmd_parms *cmd, void *mconfig,
 *                                  char *word1, char *word2);
 */

/*
 * Command handler for a TAKE123 directive.  A TAKE123 directive can be given,
 * as might be expected, one, two, or three arguments.
 * - word2 is a NULL pointer if no second argument was specified.
 * - word3 is a NULL pointer if no third argument was specified.
 * Declared in the command_rec list with
 *   AP_INIT_TAKE123("directive", function, mconfig, where, help)
 *
 * static const char *handle_TAKE123(cmd_parms *cmd, void *mconfig,
 *                                   char *word1, char *word2, char *word3);
 */

/*
 * Command handler for a TAKE13 directive.  Either one or three arguments are
 * permitted - no two-parameters-only syntax is allowed.
 * - word2 and word3 are NULL pointers if only one argument was specified.
 * Declared in the command_rec list with
 *   AP_INIT_TAKE13("directive", function, mconfig, where, help)
 *
 * static const char *handle_TAKE13(cmd_parms *cmd, void *mconfig,
 *                                  char *word1, char *word2, char *word3);
 */

/*
 * Command handler for a TAKE23 directive.  At least two and as many as three
 * arguments must be specified.
 * - word3 is a NULL pointer if no third argument was specified.
 * Declared in the command_rec list with
 *   AP_INIT_TAKE23("directive", function, mconfig, where, help)
 *
 * static const char *handle_TAKE23(cmd_parms *cmd, void *mconfig,
 *                                  char *word1, char *word2, char *word3);
 */

/*
 * Command handler for a ITERATE directive.
 * - Handler is called once for each of n arguments given to the directive.
 * - word1 points to each argument in turn.
 * Declared in the command_rec list with
 *   AP_INIT_ITERATE("directive", function, mconfig, where, help)
 *
 * static const char *handle_ITERATE(cmd_parms *cmd, void *mconfig,
 *                                   char *word1);
 */

/*
 * Command handler for a ITERATE2 directive.
 * - Handler is called once for each of the second and subsequent arguments
 *   given to the directive.
 * - word1 is the same for each call for a particular directive instance (the
 *   first argument).
 * - word2 points to each of the second and subsequent arguments in turn.
 * Declared in the command_rec list with
 *   AP_INIT_ITERATE2("directive", function, mconfig, where, help)
 *
 * static const char *handle_ITERATE2(cmd_parms *cmd, void *mconfig,
 *                                    char *word1, char *word2);
 */



/*--------------------------------------------------------------------------*/
/*                                                                          */
/* These routines are strictly internal to this module, and support its     */
/* operation.  They are not referenced by any external portion of the       */
/* server.                                                                  */
/*                                                                          */
/*--------------------------------------------------------------------------*/

/*
 * Locate our directory configuration record for the current request.
 */
static gsw_cfg *our_dconfig(const request_rec *r)
{
    return (gsw_cfg *) ap_get_module_config(r->per_dir_config, &gsw_module);
}

#if 0
/*
 * Locate our server configuration record for the specified server.
 */
static gsw_cfg *our_sconfig(const server_rec *s)
{
    return (gsw_cfg *) ap_get_module_config(s->module_config, &gsw_module);
}

/*
 * Likewise for our configuration record for the specified request.
 */
static gsw_cfg *our_rconfig(const request_rec *r)
{
    return (gsw_cfg *) ap_get_module_config(r->request_config, &gsw_module);
}
#endif

/*
 * Likewise for our configuration record for a connection.
 */
static gsw_cfg *our_cconfig(const conn_rec *c)
{
    return (gsw_cfg *) ap_get_module_config(c->conn_config, &gsw_module);
}

/*
 * This routine sets up some module-wide cells if they haven't been already.
 */
static void setup_module_cells(void)
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
 * This routine is used to add a trace of a callback to the list.  We're
 * passed the server record (if available), the request record (if available),
 * a pointer to our private configuration record (if available) for the
 * environment to which the callback is supposed to apply, and some text.  We
 * turn this into a textual representation and add it to the tail of the list.
 * The list can be displayed by the gsw_handler() routine.
 *
 * If the call occurs within a request context (i.e., we're passed a request
 * record), we put the trace into the request apr_pool_t and attach it to the
 * request via the notes mechanism.  Otherwise, the trace gets added
 * to the static (non-request-specific) list.
 *
 * Note that the r->notes table is only for storing strings; if you need to
 * maintain per-request data of any other type, you need to use another
 * mechanism.
 */

#define TRACE_NOTE "gsw-trace"

static void trace_add(server_rec *s, request_rec *r, gsw_cfg *mconfig,
                      const char *note)
{
    const char *sofar;
    char *addon;
    char *where;
    apr_pool_t *p;
    const char *trace_copy;

    /*
     * Make sure our pools and tables are set up - we need 'em.
     */
    setup_module_cells();
    /*
     * Now, if we're in request-context, we use the request pool.
     */
    if (r != NULL) {
        p = r->pool;
        if ((trace_copy = apr_table_get(r->notes, TRACE_NOTE)) == NULL) {
            trace_copy = "";
        }
    }
    else {
        /*
         * We're not in request context, so the trace gets attached to our
         * module-wide pool.  We do the create/destroy every time we're called
         * in non-request context; this avoids leaking memory in some of
         * the subsequent calls that allocate memory only once (such as the
         * key formation below).
         *
         * Make a new sub-pool and copy any existing trace to it.  Point the
         * trace cell at the copied value.
         */
        apr_pool_create(&p, gsw_pool);
        if (trace != NULL) {
            trace = apr_pstrdup(p, trace);
        }
        /*
         * Now, if we have a sub-pool from before, nuke it and replace with
         * the one we just allocated.
         */
        if (gsw_subpool != NULL) {
            apr_pool_destroy(gsw_subpool);
        }
        gsw_subpool = p;
        trace_copy = trace;
    }
    /*
     * If we weren't passed a configuration record, we can't figure out to
     * what location this call applies.  This only happens for co-routines
     * that don't operate in a particular directory or server context.  If we
     * got a valid record, extract the location (directory or server) to which
     * it applies.
     */
    where = (mconfig != NULL) ? mconfig->loc : "nowhere";
    where = (where != NULL) ? where : "";
    /*
     * Now, if we're not in request context, see if we've been called with
     * this particular combination before.  The apr_table_t is allocated in the
     * module's private pool, which doesn't get destroyed.
     */
    if (r == NULL) {
        char *key;

        key = apr_pstrcat(p, note, ":", where, NULL);
        if (apr_table_get(static_calls_made, key) != NULL) {
            /*
             * Been here, done this.
             */
            return;
        }
        else {
            /*
             * First time for this combination of routine and environment -
             * log it so we don't do it again.
             */
            apr_table_set(static_calls_made, key, "been here");
        }
    }
    addon = apr_pstrcat(p,
                        "   <li>\n"
                        "    <dl>\n"
                        "     <dt><samp>", note, "</samp></dt>\n"
                        "     <dd><samp>[", where, "]</samp></dd>\n"
                        "    </dl>\n"
                        "   </li>\n",
                        NULL);
    sofar = (trace_copy == NULL) ? "" : trace_copy;
    trace_copy = apr_pstrcat(p, sofar, addon, NULL);
    if (r != NULL) {
        apr_table_set(r->notes, TRACE_NOTE, trace_copy);
    }
    else {
        trace = trace_copy;
    }
    /*
     * You *could* change the following if you wanted to see the calling
     * sequence reported in the server's error_log, but beware - almost all of
     * these co-routines are called for every single request, and the impact
     * on the size (and readability) of the error_log is considerable.
     */
#define EXAMPLE_LOG_EACH 0
    if (EXAMPLE_LOG_EACH && (s != NULL)) {
        ap_log_error(APLOG_MARK, APLOG_DEBUG, 0, s, "mod_gsw: %s", note);
    }
}


gsw_app_conf * find_app(request_rec *r)
{
  char         * appName;
  char         * instance_str = NULL;
  char           app_name[128];
  int            instance_nr = -1;
  gsw_cfg      * cfg          = NULL;
  gsw_app_conf * app_conf     = NULL;

  if (appName = index(r->uri, '/')) {
    appName++;
    if (appName = index(appName, '/')) {
      appName++;
    } else {
     return NULL;
    }   
  } else {
    return NULL;
  }


  strncpy(app_name, appName, sizeof(app_name));
    
  if ((appName = index(app_name, '.'))) {
    *appName = '\0';    
  } else {
    return NULL;
  }
  
  // now get the instance number if any
  appName++;

  if ((instance_str = index(appName, '/'))) {
    instance_str++;
    if (appName = index(instance_str, '/')) {
      *appName = '\0';
      instance_nr = atoi(instance_str);
      // parse error?
      if (instance_nr == 0) {
        instance_nr = -1;
      }    
    }
  }


  cfg = our_dconfig(r);

  if (instance_nr != -1) {
    char   tmp_key[128];

    snprintf(tmp_key, sizeof(tmp_key), "%s:%d", app_name, instance_nr);
  
    app_conf = apr_table_get(cfg->app_table, (const char *)tmp_key); 	
   	
   	if (app_conf != NULL) {
   	  return app_conf;
   	}
    
  }

  if (((app_name) && (strlen(app_name))) && (cfg->app_table)) {
    const          apr_array_header_t *tarr = apr_table_elts(cfg->app_table);
    const          apr_table_entry_t *telts = (const apr_table_entry_t*)tarr->elts;
    int            i;
	  time_t         t;

    // current time
	  time(&t);
    // substract 300 sec / 5 min
    t = t - 300;
    
    for (i = 0; i < tarr->nelts; i++) {
      gsw_app_conf *appconf = (gsw_app_conf *) telts[i].val;
  
      if ((strcasecmp(appconf->app_name, app_name) == 0)) {
        if (app_conf == NULL) {
          app_conf = appconf;
        } else {
          // enable unreachable instances after some time
          if ((appconf->unreachable == 1) && (appconf->last_response_time < t)) {
            appconf->unreachable = 0;
          }
          
          if (appconf->unreachable == 0) {
            if (appconf->load <= app_conf->load) {
               app_conf = appconf;              
            }
          }
        }
      }    
    }
  }

  return app_conf;        
}


// returns the socket or <0 on error

int connect_host(char * hostname, u_int16_t port)
{
  int 					       ok;
  struct sockaddr_in 	 socketAddress;
  in_addr_t            in_addr;
  int                  sock;

  socketAddress.sin_addr.s_addr = 0;

  sock = socket(AF_INET, SOCK_STREAM, 0);

  if (socket < 0) {
    return -1;
  }

  if (inet_aton(hostname, &socketAddress.sin_addr) == 0) {
    // failure
    struct hostent * host = NULL;
         
    host = gethostbyname((const char *)hostname);
    if (host != NULL) {
      memcpy(&socketAddress.sin_addr, host->h_addr_list[0], host->h_length);
    }

  }
  
  socketAddress.sin_family = AF_INET;
  socketAddress.sin_port = htons(port);

  if (socketAddress.sin_addr.s_addr != 0) {   
    ok = connect(sock, (struct sockaddr *)&socketAddress, sizeof(struct sockaddr_in));
  
    if (ok == 0) {
      return sock;
    }
  }

  close(sock);  
  return -1;
}

static int write_sock(int socket, const void *data, size_t len, request_rec *r)
{
  int		rval = 0;

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
        ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "cannot write to socket '%s'", data);
        return -1;
				break;
		}
	}
  return 0;
}

void * read_sock_line(int socket, request_rec *r, apr_pool_t * pool)
{
  size_t		rval = 1;
  int   i = 0;
  int   done = 0;
  char  buffer[1024];
  char  b;


  while (((done == 0) && (i < sizeof(buffer) -1)) && (rval >0)) {
     rval= read(socket, &b, 1);
    buffer[i] = b;

    if (b == '\n') {
        done = 1;
        buffer[i] = '\0';
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

void * read_sock(int socket, size_t size, apr_pool_t * pool)
{
  size_t		rval = 1;

	char * newBuf = apr_palloc(pool,size+1);


  rval= read(socket, newBuf, size);
  newBuf[size+1] = '\0';
	
	return newBuf;

}



/*
HTTP/1.0 200 OK NeXT WebObjects
x-webobjects-loadaverage: 1
content-length: 3315
content-type: text/html
x-webobjects-adaptorstats: applicationThreadCreation=+0.000s applicationThreadRun=+0.000s applicationBeginDispatchRequest=+1.368s applicationEndDispatchRequest=+1.387s applicationDispatchRequest=0.019s applicationBeginSendResponse=+1.387s applicationTimeSpent=1.387s

*/



static int handle_request(request_rec *r, gsw_app_conf * app)
{
  int             soc = -1;
  char          * newBuf = NULL;
  apr_pool_t    * sub_pool = NULL;
  int             load_avr_seen = 0;
  int             length_seen = 0;
  u_int8_t        newload = 0;
  size_t          content_length = 0;
  char            * content_type = NULL;
  char            * content_encoding = NULL;
  char            * location = NULL;
  int               http_status = DECLINED;

  apr_pool_create(&sub_pool, r->pool);

  //print_app(r, NULL, app);

  soc = connect_host(app->host_name, app->port);
  
  if (soc != -1) {
    if (write_sock(soc, (const void *) r->the_request, strlen(r->the_request), r) == 0) {
      int   headers_done = 0;
      int   i=0;
      const apr_array_header_t *hdrs_arr = apr_table_elts(r->headers_in);
      const apr_table_entry_t *hdrs = (const apr_table_entry_t *) hdrs_arr->elts;
      char tmpStr[512];

      write_sock(soc, CRLF, 2, r);

    
      for (i = 0; i < hdrs_arr->nelts; ++i) {
          if (!hdrs[i].key)
              continue;
          snprintf(tmpStr, sizeof(tmpStr), "%s: %s\r\n", hdrs[i].key, hdrs[i].val);
          write_sock(soc, tmpStr, strlen(tmpStr), r);
      }

      if (ap_setup_client_block(r, REQUEST_CHUNKED_ERROR) != OK) {
              ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "handle_request: DECLINED");
        return DECLINED;
      }
      
      // check if we are on a POST trip...
      if ((r->method_number == M_POST) && (ap_should_client_block(r))) {
        size_t bytescopied = 0;
        size_t bytesread = 1;
        char * postbuf = NULL;


//        if ((r->content_type) && strlen(r->content_type)) {
//          snprintf(tmpStr, sizeof(tmpStr), "content-type: %s", r->content_type);
//          write_sock(soc, tmpStr, strlen(tmpStr), r);
//          write_sock(soc, CRLF, 2, r);
////        }
//        
//        snprintf(tmpStr, sizeof(tmpStr), "content-length: %d", r->remaining);
//        write_sock(soc, tmpStr, strlen(tmpStr), r);
//        write_sock(soc, CRLF, 2, r);
        
        write_sock(soc, CRLF, 2, r);

        postbuf = apr_palloc(sub_pool,1024*8+1);
        
        // TODO: check if we need to transfer the last CR / NL from the POST data.
        while (bytesread > 0) {
          bytesread = ap_get_client_block(r, postbuf, 1024*8);

          bytescopied += bytesread;
          if (bytesread == 0) {
            break;
          }
          postbuf[bytesread]='\0';
          write_sock(soc, postbuf, bytesread, r);
        }
//        postbuf[0]='\0';
//        write_sock(soc, postbuf, 1, r);
      }        

      write_sock(soc, CRLF, 2, r);

      // HTTP/1.0 200 OK NeXT WebObjects
      if (newBuf = read_sock_line(soc, r, sub_pool)) {
        if ((strncasecmp(newBuf,"HTTP/",5) != 0) || (strlen(newBuf) < 15)) {
          ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "Got '%s' but no 'HTTP/...'", newBuf);
          apr_pool_destroy(sub_pool);
          return DECLINED;
        } else {
          newBuf[12] = '\0';
          http_status = atoi(newBuf+9);
          ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "http_status '%s' (%d)", newBuf+9, http_status);
          if (http_status==200) {            
            http_status=OK;
          }
        }
      }
     
      while (headers_done == 0) {
        newBuf = read_sock_line(soc, r, sub_pool);
        
        if (newBuf != NULL) {
//          ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "newBuf:'%s' len:%d", newBuf, strlen(newBuf));
          
          if (load_avr_seen == 0) {
            if (strncmp(newBuf, "x-webobjects-loadaverage: ", 26) == 0) {
              load_avr_seen = 1;
              newload = atoi(newBuf+26);
              ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "newload:%d", newload);
            }
          }
          if (length_seen == 0) {
            if (strncmp(newBuf, "content-length: ", 16) == 0) {
              length_seen = 1;
              content_length = atol(newBuf+16);
              snprintf(tmpStr, sizeof(tmpStr), "%d", content_length);
              ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "content-length: %s", tmpStr);
              apr_table_set(r->headers_out, "content-length", tmpStr);
            }
          }
          if (content_type == NULL) {
            if (strncmp(newBuf, "content-type: ", 14) == 0) {
              content_type = newBuf+14;
              ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "content_type: %s", content_type);
            }
          }
          if (content_encoding == NULL) {
            if (strncmp(newBuf, "content-encoding: ", 18) == 0) {
              content_encoding = newBuf+18;
              ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "content-encoding: %s", content_encoding);
              apr_table_set(r->headers_out, "content-encoding", content_encoding);
             }
          }
          if (location == NULL) {
            if (strncmp(newBuf, "location: ", 10) == 0) {
              location = newBuf+10;
              ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "location: %s", location);
              apr_table_set(r->headers_out, "location", location);
             }
          }
        } else {
          headers_done = 1;
          ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "#########");
        }
      } // while
      
      // do the request
      if ((content_type != NULL) && (content_length > 0)) {
        size_t    bytesDone = 0;
        size_t    blockSize = 1024;
        size_t    rval=1;
      	char      * transferBuf = NULL;
        
        ap_set_content_type(r, content_type);
        
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
        ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "copied %d bytes", bytesDone);
      }
    }
    
    close(soc);
//    apr_pool_destroy(sub_pool); 

    time(&app->last_response_time);
  }
  
  //apr_pool_destroy(sub_pool);

  return http_status;

  internal_error:
      close(soc);
      return 500;  
}



/*--------------------------------------------------------------------------*/
/* We prototyped the various syntax for command handlers (routines that     */
/* are called when the configuration parser detects a directive declared    */
/* by our module) earlier.  Now we actually declare a "real" routine that   */
/* will be invoked by the parser when our "real" directive is               */
/* encountered.                                                             */
/*                                                                          */
/* If a command handler encounters a problem processing the directive, it   */
/* signals this fact by returning a non-NULL pointer to a string            */
/* describing the problem.                                                  */
/*                                                                          */
/* The magic return value DECLINE_CMD is used to deal with directives       */
/* that might be declared by multiple modules.  If the command handler      */
/* returns NULL, the directive was processed; if it returns DECLINE_CMD,    */
/* the next module (if any) that declares the directive is given a chance   */
/* at it.  If it returns any other value, it's treated as the text of an    */
/* error message.                                                           */
/*--------------------------------------------------------------------------*/
/*
 * Command handler for the NO_ARGS "Example" directive.  All we do is mark the
 * call in the trace log, and flag the applicability of the directive to the
 * current location in that location's configuration record.
 */
static const char *cmd_gsw(cmd_parms *cmd, void *mconfig)
{
    gsw_cfg *cfg = (gsw_cfg *) mconfig;

    /*
     * "Example Wuz Here"
     */
    cfg->local = 1;
    trace_add(cmd->server, NULL, cfg, "cmd_gsw()");
    return NULL;
}


static const char *set_ShowApps(cmd_parms *cmd, void *mconfig, int bool)
{
    gsw_cfg *cfg = (gsw_cfg *) mconfig;
    
    cfg->showApps = bool;
    
    return NULL;
}


static const char * set_App(cmd_parms *cmd, void *mconfig,
                                 char *word1, char *word2, char *word3)
{
  const command_rec *thiscmd = cmd->cmd;
  
  gsw_cfg *cfg = (gsw_cfg *) mconfig;
  gsw_app_conf * appConf      = NULL;
  char           tmpStr[128];
  char         * appName      = NULL;
  char         * instanceStr = NULL;
  char         * hostName     = NULL;  
  char         * portStr      = NULL;  
  char         * keyStr       = NULL;
  int            len          = 0;  

//App Name=TCWebMail Instance=1 Host=10.1.0.1:9901
//App Name=PBX Instance=1 Host=10.1.0.1:9001

  appName = strrchr(word1, '=');
  instanceStr = strrchr(word2, '=');
  hostName = strrchr(word3, '=');
  
  if ((!appName) || (!instanceStr) || (!hostName)) {
    return "App is invalid!";
  }
  
  appConf = apr_pcalloc(cmd->pool, sizeof(gsw_app_conf));

  appName++;
  hostName++;
  instanceStr++;

  strncpy(appConf->app_name, appName, sizeof(appConf->app_name));

  portStr = strrchr(hostName, ':');
  
  // remove port from string
  *portStr = '\0';
  portStr++;
  
  appConf->port = atoi(portStr);

  
  strncpy(appConf->host_name, hostName, sizeof(appConf->host_name));

  appConf->instance_number = atoi(instanceStr);
  appConf->load = 0;
  appConf->unreachable = 0;
  appConf->last_response_time = 0;

  snprintf(tmpStr, sizeof(tmpStr), "%s:%d", appName, appConf->instance_number);

  len = strlen(tmpStr)+1;
  keyStr = apr_pcalloc(cmd->pool,len);
  strncpy(keyStr, tmpStr, len);

  apr_table_addn(cfg->app_table, (const char *) keyStr, (const char *) appConf);			
              
  return NULL;
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
static int gsw_handler(request_rec *r)
{
  gsw_app_conf   * app = NULL;
  gsw_cfg *dcfg;
  char data1[1024];
  char data[1024];
  void *user_data;
  int     handle_status = OK;
  extern char *tzname[2];
  
//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "xx handler uri: %s", r->uri);

  if (strncmp(r->uri, "/wo/",4) != 0) {
//      ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "xx handler DECLINED");
      return DECLINED;
  }


  dcfg = our_dconfig(r);

//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "xx the_request: %s", r->the_request);
//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "xx protocol: %s (%d)", r->protocol, r->proto_num);
//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "xx content_type: %s", r->content_type);
//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "xx handler: %s", r->handler);
//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "xx content_encoding: %s", r->content_encoding);
//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "xx user: %s", r->user);
//
//  apr_table_do(print_app,(void *) r, dcfg->app_table, NULL);

  // some testing dave
//  strncpy(data1, "hallo welt", sizeof(data1));
//
//  apr_pool_userdata_set(data1, GSW_INST_CACHE, NULL, gsw_pool);
//
//
//  apr_pool_userdata_get(&user_data, GSW_INST_CACHE, gsw_pool);
//  ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "apr_pool_userdata_get ok:%s", user_data);



  trace_add(r->server, r, dcfg, "gsw_handler()");
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
    handle_status = handle_request(r, app);
    if (handle_status != DECLINED) {
      return handle_status;
    }
  } 
     
    ap_set_content_type(r, "text/html");
    /*
     * If we're only supposed to send header information (HEAD request), we're
     * already there.
     */
    if (r->header_only) {
        return OK;
    }

    /*
     * Now send our actual output.  Since we tagged this as being
     * "text/html", we need to embed any HTML.
     */
    ap_rputs(DOCTYPE_HTML_3_2, r);
    ap_rputs("<html>\n", r);
    ap_rputs("<head>\n", r);
    ap_rputs("<title>GNUstepWeb Status</title>\n", r);
    ap_rputs("<meta name=\"robots\" content=\"NOODP\">\n", r);
    ap_rputs("</head>\n", r);
    ap_rputs("<body>\n", r);
    ap_rputs("<h1>GNUstepWeb Status</h1><br>\n", r);

    if ((dcfg->showApps)) {
      if ((dcfg->app_table)) {
        const apr_array_header_t *tarr = apr_table_elts(dcfg->app_table);
        const apr_table_entry_t *telts = (const apr_table_entry_t*)tarr->elts;
        int i;
  
          ap_rputs("<table border=1>\n",r);
          ap_rputs("<tr><td>Name</td><td>Instance</td><td>Host</td><td>Port</td><td>Load</td><td> Unreachable</td><td>Last Response</td></tr>\n",r);
  
        
        for (i = 0; i < tarr->nelts; i++) {
          gsw_app_conf *appconf = (gsw_app_conf *) telts[i].val;
  
          ap_rprintf(r, "<tr><td><a href=\"%s%s.woa/%d/\">%s</a></td>", ADAPTOR_PREFIX, 
                                                           appconf->app_name,
                                                           appconf->instance_number,
                                                           appconf->app_name);
          ap_rprintf(r, "<td>%u</td>", appconf->instance_number);
          ap_rprintf(r, "<td>%s</td>", appconf->host_name);
          ap_rprintf(r, "<td>%u</td>", appconf->port);
          ap_rprintf(r, "<td>%u</td>", appconf->load);
          ap_rprintf(r, "<td>%s</td>", (appconf->unreachable == 1) ? "YES": "NO");
          ap_rprintf(r, "<td>%s</td></tr>\n", ctime(&appconf->last_response_time));
        }
  
        ap_rputs("</table><br>\n",r);
        
       
      }
    } else {
      ap_rputs("<p>Application list hidden. Set <samp>ShowApps on</samp> in your Apache config to list.</p>\n",r);

    }

      ap_rputs("<p>Powered by <a href=\"http://wiki.gnustep.org/index.php/GNUstepWeb\">GNUstep Web</a></p>\n",r);
    
    ap_rputs(" </body>\n", r);
    ap_rputs("</html>\n", r);
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
    return OK;
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
 * This function gets called to create a per-directory configuration
 * record.  This will be called for the "default" server environment, and for
 * each directory for which the parser finds any of our directives applicable.
 * If a directory doesn't have any of our directives involved (i.e., they
 * aren't in the .htaccess file, or a <Location>, <Directory>, or related
 * block), this routine will *not* be called - the configuration for the
 * closest ancestor is used.
 *
 * The return value is a pointer to the created module-specific
 * structure.
 */
static void *gsw_create_dir_config(apr_pool_t *p, char *dirspec)
{
    gsw_cfg *cfg;
    char *dname = dirspec;

    /*
     * Allocate the space for our record from the pool supplied.
     */
    cfg = (gsw_cfg *) apr_pcalloc(p, sizeof(gsw_cfg));
    /*
     * Now fill in the defaults.  If there are any `parent' configuration
     * records, they'll get merged as part of a separate callback.
     */
    cfg->local = 0;
    cfg->congenital = 0;
    cfg->cmode = CONFIG_MODE_DIRECTORY;
    /*
     * Finally, add our trace to the callback list.
     */

   cfg->app_table = apr_table_make(p, 1);   // default 


    dname = (dname != NULL) ? dname : "";
    cfg->loc = apr_pstrcat(p, "DIR(", dname, ")", NULL);
    trace_add(NULL, NULL, cfg, "gsw_create_dir_config()");
    return (void *) cfg;
}

/*
 * This function gets called to merge two per-directory configuration
 * records.  This is typically done to cope with things like .htaccess files
 * or <Location> directives for directories that are beneath one for which a
 * configuration record was already created.  The routine has the
 * responsibility of creating a new record and merging the contents of the
 * other two into it appropriately.  If the module doesn't declare a merge
 * routine, the record for the closest ancestor location (that has one) is
 * used exclusively.
 *
 * The routine MUST NOT modify any of its arguments!
 *
 * The return value is a pointer to the created module-specific structure
 * containing the merged values.
 */
static void *gsw_merge_dir_config(apr_pool_t *p, void *parent_conf,
                                      void *newloc_conf)
{

    gsw_cfg *merged_config = (gsw_cfg *) apr_pcalloc(p, sizeof(gsw_cfg));
    gsw_cfg *pconf = (gsw_cfg *) parent_conf;
    gsw_cfg *nconf = (gsw_cfg *) newloc_conf;
    char *note;

    /*
     * Some things get copied directly from the more-specific record, rather
     * than getting merged.
     */
    merged_config->local = nconf->local;
    merged_config->loc = apr_pstrdup(p, nconf->loc);

// dave
    merged_config->showApps = nconf->showApps;
//    snprintf(merged_config->appInfo, 1000, nconf->appInfo);
   merged_config->app_table = apr_table_copy(p, nconf->app_table);


    /*
     * Others, like the setting of the `congenital' flag, get ORed in.  The
     * setting of that particular flag, for instance, is TRUE if it was ever
     * true anywhere in the upstream configuration.
     */
    merged_config->congenital = (pconf->congenital | pconf->local);
    /*
     * If we're merging records for two different types of environment (server
     * and directory), mark the new record appropriately.  Otherwise, inherit
     * the current value.
     */
    merged_config->cmode =
        (pconf->cmode == nconf->cmode) ? pconf->cmode : CONFIG_MODE_COMBO;
    /*
     * Now just record our being called in the trace list.  Include the
     * locations we were asked to merge.
     */
    note = apr_pstrcat(p, "gsw_merge_dir_config(\"", pconf->loc, "\",\"",
                   nconf->loc, "\")", NULL);
    trace_add(NULL, NULL, merged_config, note);
    return (void *) merged_config;
}

/*
 * This function gets called to create a per-server configuration
 * record.  It will always be called for the "default" server.
 *
 * The return value is a pointer to the created module-specific
 * structure.
 */
static void *gsw_create_server_config(apr_pool_t *p, server_rec *s)
{

    gsw_cfg *cfg;
    char *sname = s->server_hostname;

    /*
     * As with the gsw_create_dir_config() reoutine, we allocate and fill
     * in an empty record.
     */
    cfg = (gsw_cfg *) apr_pcalloc(p, sizeof(gsw_cfg));
    cfg->local = 0;
    cfg->congenital = 0;
    cfg->cmode = CONFIG_MODE_SERVER;
    /*
     * Note that we were called in the trace list.
     */
    sname = (sname != NULL) ? sname : "";
    cfg->loc = apr_pstrcat(p, "SVR(", sname, ")", NULL);
    trace_add(s, NULL, cfg, "gsw_create_server_config()");
    return (void *) cfg;
}

/*
 * This function gets called to merge two per-server configuration
 * records.  This is typically done to cope with things like virtual hosts and
 * the default server configuration  The routine has the responsibility of
 * creating a new record and merging the contents of the other two into it
 * appropriately.  If the module doesn't declare a merge routine, the more
 * specific existing record is used exclusively.
 *
 * The routine MUST NOT modify any of its arguments!
 *
 * The return value is a pointer to the created module-specific structure
 * containing the merged values.
 */
static void *gsw_merge_server_config(apr_pool_t *p, void *server1_conf,
                                         void *server2_conf)
{

    gsw_cfg *merged_config = (gsw_cfg *) apr_pcalloc(p, sizeof(gsw_cfg));
    gsw_cfg *s1conf = (gsw_cfg *) server1_conf;
    gsw_cfg *s2conf = (gsw_cfg *) server2_conf;
    char *note;

    /*
     * Our inheritance rules are our own, and part of our module's semantics.
     * Basically, just note whence we came.
     */
    merged_config->cmode =
        (s1conf->cmode == s2conf->cmode) ? s1conf->cmode : CONFIG_MODE_COMBO;
    merged_config->local = s2conf->local;
    merged_config->congenital = (s1conf->congenital | s1conf->local);
    merged_config->loc = apr_pstrdup(p, s2conf->loc);
    /*
     * Trace our call, including what we were asked to merge.
     */
    note = apr_pstrcat(p, "gsw_merge_server_config(\"", s1conf->loc, "\",\"",
                   s2conf->loc, "\")", NULL);
    trace_add(NULL, NULL, merged_config, note);
    return (void *) merged_config;
}

/*
 * This routine is called before the server processes the configuration
 * files.  There is no return value.
 */
static int gsw_pre_config(apr_pool_t *pconf, apr_pool_t *plog,
                        apr_pool_t *ptemp)
{
    /*
     * Log the call and exit.
     */
    trace_add(NULL, NULL, NULL, "gsw_pre_config()");

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
static int gsw_post_config(apr_pool_t *pconf, apr_pool_t *plog,
                          apr_pool_t *ptemp, server_rec *s)
{
    /*
     * Log the call and exit.
     */
    trace_add(NULL, NULL, NULL, "gsw_post_config()");
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
static int gsw_open_logs(apr_pool_t *pconf, apr_pool_t *plog,
                        apr_pool_t *ptemp, server_rec *s)
{
    /*
     * Log the call and exit.
     */
    trace_add(s, NULL, NULL, "gsw_open_logs()");
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
    trace_add(s, NULL, NULL, note);
    return APR_SUCCESS;
}

/*
 * All our process initialiser does is add its trace to the log.
 */
static void gsw_child_init(apr_pool_t *p, server_rec *s)
{
    char *note;
    char *sname = s->server_hostname;

    /*
     * Set up any module cells that ought to be initialised.
     */
    setup_module_cells();
    /*
     * The arbitrary text we add to our trace entry indicates for which server
     * we're being called.
     */
    sname = (sname != NULL) ? sname : "";
    note = apr_pstrcat(p, "gsw_child_init(", sname, ")", NULL);
    trace_add(s, NULL, NULL, note);

    apr_pool_cleanup_register(p, s, gsw_child_exit, gsw_child_exit);
}

/*
 * XXX: This routine is called XXX
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, the
 * server will still call any remaining modules with an handler for this
 * phase.
 */
#if 0
static const char *gsw_http_scheme(const request_rec *r)
{
    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * Log the call and exit.
     */
    trace_add(r->server, NULL, cfg, "gsw_http_scheme()");
    return "gsw";
}

/*
 * XXX: This routine is called XXX
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, the
 * server will still call any remaining modules with an handler for this
 * phase.
 */
static apr_port_t gsw_default_port(const request_rec *r)
{
    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * Log the call and exit.
     */
    trace_add(r->server, NULL, cfg, "gsw_default_port()");
    return 80;
}
#endif /*0*/

/*
 * XXX: This routine is called XXX
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, the
 * server will still call any remaining modules with an handler for this
 * phase.
 */
static void gsw_insert_filter(request_rec *r)
{
    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * Log the call and exit.
     */
    trace_add(r->server, NULL, cfg, "gsw_insert_filter()");
}

/*
 * XXX: This routine is called XXX
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, the
 * server will still call any remaining modules with an handler for this
 * phase.
 */
static int gsw_quick_handler(request_rec *r, int lookup_uri)
{
    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * Log the call and exit.
     */
    trace_add(r->server, NULL, cfg, "gsw_quick_handler()");

    ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "gsw_quick_handler uri: %s", r->uri);

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
static int gsw_pre_connection(conn_rec *c, void *csd)
{
    gsw_cfg *cfg;

    cfg = our_cconfig(c);
#if 0
    /*
     * Log the call and exit.
     */
    trace_add(r->server, NULL, cfg, "gsw_pre_connection()");
#endif
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
static int gsw_process_connection(conn_rec *c)
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
static int gsw_post_read_request(request_rec *r)
{
    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * We don't actually *do* anything here, except note the fact that we were
     * called.
     */
    trace_add(r->server, r, cfg, "gsw_post_read_request()");
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
static int gsw_translate_handler(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * We don't actually *do* anything here, except note the fact that we were
     * called.
     */

    if (strncmp(r->uri, "/wo/",4) != 0) {
        ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "gsw_translate_handler DECLINED");
        return DECLINED;
    }

    ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "gsw_translate_handler uri: %s filename: %s hostname: %s", r->uri, r->filename,  r->hostname);

    trace_add(r->server, r, cfg, "gsw_translate_handler()");
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
static int gsw_map_to_storage_handler(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * We don't actually *do* anything here, except note the fact that we were
     * called.
     */
    trace_add(r->server, r, cfg, "gsw_map_to_storage_handler()");
    return DECLINED;
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
static int gsw_header_parser_handler(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * We don't actually *do* anything here, except note the fact that we were
     * called.
     */
    trace_add(r->server, r, cfg, "header_parser_handler()");
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
static int gsw_check_user_id(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * Don't do anything except log the call.
     */
    trace_add(r->server, r, cfg, "gsw_check_user_id()");
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
static int gsw_auth_checker(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * Log the call and return OK, or access will be denied (even though we
     * didn't actually do anything).
     */
    trace_add(r->server, r, cfg, "gsw_auth_checker()");
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
static int gsw_access_checker(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    trace_add(r->server, r, cfg, "gsw_access_checker()");
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
static int gsw_type_checker(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * Log the call, but don't do anything else - and report truthfully that
     * we didn't do anything.
     */
    trace_add(r->server, r, cfg, "gsw_type_checker()");
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
static int gsw_fixer_upper(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    /*
     * Log the call and exit.
     */
    trace_add(r->server, r, cfg, "gsw_fixer_upper()");
    return OK;
}

/*
 * This routine is called to perform any module-specific logging activities
 * over and above the normal server things.
 *
 * The return value is OK, DECLINED, or HTTP_mumble.  If we return OK, any
 * remaining modules with an handler for this phase will still be called.
 */
static int gsw_logger(request_rec *r)
{

    gsw_cfg *cfg;

    cfg = our_dconfig(r);
    trace_add(r->server, r, cfg, "gsw_logger()");
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
/* All of the routines have been declared now.  Here's the list of          */
/* directives specific to our module, and information about where they      */
/* may appear and how the command parser should pass them to us for         */
/* processing.  Note that care must be taken to ensure that there are NO    */
/* collisions of directive names between modules.                           */
/*                                                                          */
/*--------------------------------------------------------------------------*/
/*
 * List of directives specific to our module.
 */
 
/*
RSRC_CONF - httpd.conf at top level or in a VirtualHost context. 

ACCESS_CONF - httpd.conf in a Directory context.
*/


//    AP_INIT_RAW_ARGS("<GSWApplications",
//                      proxysection,
//                      (void*)1,
//                      RSRC_CONF,


static const command_rec gsw_cmds[] =
{
    AP_INIT_FLAG("ShowApps", 
                 set_ShowApps,
                 NULL,
                 RSRC_CONF,
                 "on | off if invalid requests should show available applications"),

    AP_INIT_TAKE3("App",
                      set_App,
                      NULL,
                      RSRC_CONF,
    "Container for directives affecting resources located in the proxied "
    "location, in regular expression syntax"),

    {NULL}
};
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
