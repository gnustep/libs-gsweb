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
#include "gsw_compat.h"   /* apr_parse_int64 fallback, used by set_*_timeout */

/*--------------------------------------------------------------------------*/
/*                                                                          */
/* Directive handlers for the six gsw directives, the command table the     */
/* module struct points at, and the two cells used while reading the        */
/* configuration (instance_count, last_app_index).                          */
/*                                                                          */
/* This file *defines* instance_count and last_app_index; they are reached  */
/* from other files through the extern declarations in gsw_private.h.       */
/*                                                                          */
/*--------------------------------------------------------------------------*/

// used to read configs
int instance_count;
int last_app_index;


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
    return NULL;
}


static const char * set_ShowApps(cmd_parms *cmd, void *mconfig, int mybool)
{
    gsw_cfg *cfg = (gsw_cfg *) mconfig;
    
    cfg->showApps = mybool;
    
    return NULL;
}

static const char *set_inst_count(cmd_parms *cmd, void *key, const char *value)
{
  gsw_cfg *cfg = ap_get_module_config(cmd->server->module_config, &gsw_module);
  
  if (instance_count != DEFAULT_APP_COUNT) {
    return "InstanceCount is only allowed once.";
  }

  instance_count = atoi((char *)value);

  // success
  return NULL;
}

static const char *set_connect_timeout(cmd_parms *cmd, void *mconfig, const char *value)
{
  gsw_cfg *cfg = (gsw_cfg *) mconfig;
  apr_int64_t  v;
  char        * end;

  if (apr_parse_int64(&v, (char *)value, 10, &end) != APR_SUCCESS) {
    return apr_psprintf(cmd->pool, "WOConnectTimeout: invalid value '%s'", value);
  }
  if (*end != '\0') {
    return apr_psprintf(cmd->pool, "WOConnectTimeout: invalid value '%s'", value);
  }
  if (v < 0) {
    return "WOConnectTimeout must not be negative";
  }

  cfg->connect_timeout = apr_time_from_sec(v);

  return NULL;
}

static const char *set_wait_timeout(cmd_parms *cmd, void *mconfig, const char *value)
{
  gsw_cfg *cfg = (gsw_cfg *) mconfig;
  apr_int64_t  v;
  char        * end;

  if (apr_parse_int64(&v, (char *)value, 10, &end) != APR_SUCCESS) {
    return apr_psprintf(cmd->pool, "WOWaitTimeout: invalid value '%s'", value);
  }
  if (*end != '\0') {
    return apr_psprintf(cmd->pool, "WOWaitTimeout: invalid value '%s'", value);
  }
  if (v < 0) {
    return "WOWaitTimeout must not be negative";
  }

  cfg->wait_timeout = apr_time_from_sec(v);

  return NULL;
}

static const char *set_max_body_size(cmd_parms *cmd, void *mconfig, const char *value)
{
  gsw_cfg *cfg = (gsw_cfg *) mconfig;
  apr_int64_t  v;
  char        * end;

  if (apr_parse_int64(&v, (char *)value, 10, &end) != APR_SUCCESS) {
    return apr_psprintf(cmd->pool, "WOMaxBodySize: invalid value '%s'", value);
  }
  if (*end != '\0') {
    return apr_psprintf(cmd->pool, "WOMaxBodySize: invalid value '%s'", value);
  }
  if (v < 0) {
    return "WOMaxBodySize must not be negative";
  }

  cfg->max_body_size = (apr_off_t) v;

  return NULL;
}

//
//const char*(* cmd_func::take3)
//                           (cmd_parms *parms, void *mconfig, const char *w, const char *w2, const char *w3)

static const char * set_App(cmd_parms *cmd, void *mconfig,
                                 const char *word1, const char *word2, const char *word3)
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
  gsw_cfg *modulecfg = ap_get_module_config(cmd->server->module_config, &gsw_module);
  const apr_array_header_t *tarr = apr_table_elts(cfg->app_table);

//App Name=TCWebMail Instance=1 Host=10.1.0.1:9901
//App Name=PBX Instance=1 Host=10.1.0.1:9001

  appName = strrchr(word1, '=');
  instanceStr = strrchr(word2, '=');
  hostName = strrchr(word3, '=');
  
  if ((!appName) || (!instanceStr) || (!hostName)) {
    return apr_psprintf(cmd->temp_pool, "App '%s' '%s' '%s' is invalid.", word1, word2, word3);
  }
  
  appConf = apr_pcalloc(cmd->pool, sizeof(gsw_app_conf));

  appName++;
  hostName++;
  instanceStr++;

  // The names are stored in fixed MAX_NAME_LENGTH buffers; the old code
  // silently truncated anything longer, and the table key (built from the
  // *untruncated* name) no longer matched the stored app_name, so the
  // instance lookup for such an app failed at request time.  Reject the
  // directive instead.
  if (strlen(appName) >= sizeof(appConf->app_name)) {
    return apr_psprintf(cmd->temp_pool, "App name '%s' is too long (max %d characters).",
                        appName, (int) (sizeof(appConf->app_name) - 1));
  }

  portStr = strrchr(hostName, ':');
  if (portStr == NULL) {
    return apr_psprintf(cmd->temp_pool, "App host '%s' is missing a port.", hostName);
  }

  // remove port from string
  *portStr = '\0';
  portStr++;

  if (strlen(hostName) >= sizeof(appConf->host_name)) {
    return apr_psprintf(cmd->temp_pool, "App host '%s' is too long (max %d characters).",
                        hostName, (int) (sizeof(appConf->host_name) - 1));
  }

  strncpy(appConf->app_name, appName, sizeof(appConf->app_name));
  appConf->app_name[sizeof(appConf->app_name) - 1] = '\0';

  appConf->port = atoi(portStr);

  strncpy(appConf->host_name, hostName, sizeof(appConf->host_name));
  appConf->host_name[sizeof(appConf->host_name) - 1] = '\0';

  appConf->instance_number = atoi(instanceStr);
  appConf->total_index = last_app_index;

  if (instance_count < appConf->total_index) {
    return apr_psprintf(cmd->temp_pool, "InstanceCount is '%d', but you added '%d' applications. Increase InstanceCount.",
                        instance_count, appConf->total_index);
  }

  snprintf(tmpStr, sizeof(tmpStr), "%s:%d", appName, appConf->instance_number);

  len = strlen(tmpStr)+1;
  keyStr = apr_pcalloc(cmd->pool,len);
  strncpy(keyStr, tmpStr, len);

  apr_table_addn((apr_table_t*) tarr, (const char *) keyStr, (const char *) appConf);
  last_app_index++;

  return NULL;
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


const command_rec gsw_cmds[] =
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

  AP_INIT_TAKE1("InstanceCount",
                set_inst_count,
                NULL,
                RSRC_CONF,
                "InstanceCount <number> -- the number of instances to tell the module how much shared memory is needed"
                ),

  AP_INIT_TAKE1("WOConnectTimeout",
                set_connect_timeout,
                NULL,
                RSRC_CONF,
                "WOConnectTimeout <seconds> -- timeout for connecting to the backend application (default 5)"),

  AP_INIT_TAKE1("WOWaitTimeout",
                set_wait_timeout,
                NULL,
                RSRC_CONF,
                "WOWaitTimeout <seconds> -- timeout for reading a response from the backend application (default 60)"),

  AP_INIT_TAKE1("WOMaxBodySize",
                set_max_body_size,
                NULL,
                RSRC_CONF,
                "WOMaxBodySize <bytes> -- maximum POST body size to buffer; larger requests get a 413 (default 8388608)"),

    {NULL}
};

