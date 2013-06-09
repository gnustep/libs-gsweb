/* mod_gsweb.c - GSWeb: Apache Module
   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	July 1999
   
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

#define moduleRevision "$Revision$"

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <sys/param.h>

#include "../common/config.h"


#include "GSWUtil.h"
#include "GSWStats.h"
#include "GSWDict.h"
#include "GSWString.h"
#include "GSWConfig.h"
#include "GSWURLUtil.h"
#include "GSWHTTPHeaders.h"

#include "GSWAppRequestStruct.h"
#include "GSWAppConnect.h"
#include "GSWHTTPRequest.h"
#include "GSWHTTPResponse.h"
#include "GSWAppRequest.h"

#include "httpd.h"
#include <http_config.h>
#include <http_request.h>
#include <http_core.h>

#include <http_protocol.h>

// Module Definition:

// Declare the module
module gsweb_module;


typedef struct _GSWeb_Config
{
  const char *pszGSWeb;      // default = GSWeb
  const char *pszConfigPath; // path to GSWeb.conf
//  const char *pszRoot;       // normally htdocs/GSWeb
} GSWeb_Config;


//TODO: remove ??
struct table
{
  /* This has to be first to promote backwards compatibility with
   * older modules which cast a table * to an array_header *...
   * they should use the table_elts() function for most of the
   * cases they do this for.
   */
    array_header a;
#ifdef MAKE_TABLE_PROFILE
    void *creator;
#endif
};  

/*
static CONST char *GSWeb_SetDocRoot(cmd_parms *p_pCmdParams,
				    void      *p_pUnused,
				    char      *p_pszArg);
*/
static CONST char *GSWeb_SetScriptAlias(cmd_parms *p_pCmdParams,
					void      *p_pUnused,
					char      *p_pszArg);
static CONST char *GSWeb_SetConfig(cmd_parms *p_pCmdParams,
				   void      *p_pUnused,
				   char      *p_pszArg);
static int GSWeb_Handler(request_rec *p_pRequestRec);

/*
 * Locate our server configuration record for the current request.
 */
static GSWeb_Config *
GSWeb_GetServerConfig(server_rec *p_pServerRec)
{
  return (GSWeb_Config *)ap_get_module_config(p_pServerRec->module_config,
					      &gsweb_module);
}


//--------------------------------------------------------------------
// Init
static void
GSWeb_Init(server_rec *p_pServerRec,
	   pool       *p) 
{
  GSWDict      *pDict=GSWDict_New(0);
  GSWeb_Config *pConfig=NULL;

  pConfig=GSWeb_GetServerConfig(p_pServerRec);
  GSWLog_Init(NULL,GSW_INFO);
  GSWLog(__FILE__, __LINE__,GSW_INFO,p_pServerRec,
	 "GSWeb Init Start Config. Handler: " GSWEB_HANDLER);
  GSWDebugLog(p_pServerRec,
	 "GSWeb_Init: pConfig->pszGSWeb=%s",
	 pConfig->pszGSWeb);
	
  if (pConfig && pConfig->pszConfigPath)
    GSWDict_AddStringDup(pDict,
			 g_szGSWeb_Conf_ConfigFilePath,
			 pConfig->pszConfigPath);
/*
  if (pConfig && pConfig->pszRoot)
    GSWDict_AddStringDup(pDict,
			 g_szGSWeb_Conf_DocRoot,
			 pConfig->pszRoot);
*/
  GSWLog(__FILE__, __LINE__,GSW_INFO,p_pServerRec,
	 "GSWeb Init LB Init. Handler: " GSWEB_HANDLER);
  GSWConfig_Init(pDict,p_pServerRec);
	
  GSWLog(__FILE__, __LINE__,GSW_INFO,p_pServerRec,
	 "GSWeb Init. Handler: " GSWEB_HANDLER);
  GSWDict_Free(pDict);
};

//--------------------------------------------------------------------
// Create Config
static void *
GSWeb_CreateServerConfig(pool       *p_pPool,
			 server_rec *p_pServerRec)
{
  GSWeb_Config *pConfig = (GSWeb_Config *)ap_palloc(p_pPool,
						    sizeof(GSWeb_Config));

  pConfig->pszGSWeb = g_szGSWeb_Prefix;
  GSWDebugLog(p_pServerRec,
	 "GSWeb_CreateServerConfig: pConfig->pszGSWeb=%s",
         pConfig->pszGSWeb);
  pConfig->pszConfigPath = NULL;
//  pConfig->pszRoot = NULL;
  return pConfig;
};
/*
//--------------------------------------------------------------------
// Set Param: DocRoot
static CONST char *
GSWeb_SetDocRoot(cmd_parms *p_pCmdParams,
		 void      *p_pUnused,
		 char      *p_pszArg)
{
  server_rec   *pServerRec = p_pCmdParams->server;
  GSWeb_Config *pConfig = NULL;

  GSWDebugLog(pServerRec,"Start GSWeb_SetDocRoot");
  pConfig=(GSWeb_Config *)ap_get_module_config(pServerRec->module_config,
					       &gsweb_module);
  pConfig->pszRoot = p_pszArg;
  GSWDebugLog(pServerRec,"Start GSWeb_SetDocRoot");
  return NULL;
};
*/
//--------------------------------------------------------------------
// Set Param: ScriptAlias
static CONST char *
GSWeb_SetScriptAlias(cmd_parms *p_pCmdParams,
		     void      *p_pUnused,
		     char      *p_pszArg)
{
  server_rec   *pServerRec = p_pCmdParams->server;
  GSWeb_Config *pConfig = NULL;
  GSWDebugLog(pServerRec,"Start GSWeb_SetScriptAlias");
  pConfig=GSWeb_GetServerConfig(pServerRec);
  pConfig->pszGSWeb = p_pszArg;
  GSWDebugLog(pServerRec,"Stop GSWeb_SetScriptAlias");
  return NULL;
};

//--------------------------------------------------------------------
// Set Param: ConfigFile
static CONST char *
GSWeb_SetConfig(cmd_parms *p_pCmdParams,
		void      *p_pUnused,
		char      *p_pszArg)
{
  server_rec   *pServerRec = p_pCmdParams->server;
  GSWeb_Config *pConfig = NULL;

  GSWDebugLog(pServerRec,"Start GSWeb_SetConfig");
  pConfig=GSWeb_GetServerConfig(pServerRec);
  GSWDebugLog(pServerRec,"pConfig=%p",pConfig);
  GSWDebugLog(pServerRec,"p_pszArg=%s",p_pszArg);
  pConfig->pszConfigPath = p_pszArg;
  GSWDebugLog(pServerRec,"Stop GSWeb_SetConfig");
  return NULL;
};


//--------------------------------------------------------------------
// Translate
int
GSWeb_Translation(request_rec *p_pRequestRec)
{
  int               iRetValue=OK;
  GSWeb_Config     *pConfig=NULL;
  GSWURLComponents  stURL;

  memset(&stURL,0,sizeof(stURL));
  GSWDebugLog(p_pRequestRec->server,"Start GSWeb_Translation");
  pConfig=GSWeb_GetServerConfig(p_pRequestRec->server);

  // Is this for us ?
  if (strncmp(pConfig->pszGSWeb,
	      p_pRequestRec->uri,
	      strlen(pConfig->pszGSWeb))==0) 
    {
      GSWURLError eError=GSWParseURL(&stURL,p_pRequestRec->uri,
				     p_pRequestRec->server);
      if (eError!=GSWURLError_OK)
	{
	  GSWLog(__FILE__, __LINE__,GSW_ERROR,p_pRequestRec->server,
		 "GSWeb_Translation Declined (Error %d)",(int)eError);
	  iRetValue=DECLINED;
	}
      else
	{
	  GSWDebugLog(
		 p_pRequestRec->server,
		 "GSWeb_Translation Handler p_pRequestRec->handler=%s pool=%p handler=%s pConfig->pszGSWeb=%s",
		 p_pRequestRec->handler,
		 p_pRequestRec->pool,
		 g_szGSWeb_Handler,
		 pConfig->pszGSWeb);
	  p_pRequestRec->handler=(char *)ap_pstrdup(p_pRequestRec->pool,
						    g_szGSWeb_Handler);
	  iRetValue=OK;
	};
    }
  else
    {
      GSWDebugLog(p_pRequestRec->server,"GSWeb_Translation Declined");
      iRetValue=DECLINED;
    };
  GSWDebugLog(p_pRequestRec->server,
	 "Stop GSWeb_Translation return %d",
	 iRetValue);
  return iRetValue;
};

//--------------------------------------------------------------------
// Copy p_pRequestRec in headers into p_pGSWHTTPRequest
// Also add some environment variable headers
static void
copyHeaders(request_rec    *p_pRequestRec,
	    GSWHTTPRequest *p_pGSWHTTPRequest)
{
  server_rec         *pServerRec = p_pRequestRec->server;
  conn_rec           *pConnection = p_pRequestRec->connection;
  const array_header *headers_arr=ap_table_elts(p_pRequestRec->headers_in);
  table_entry        *headers=NULL;
  int i=0;
  char		     *pszPort=NULL;
  CONST char         *pszRemoteLogName=NULL;
  GSWDebugLog(pServerRec,"Start copyHeaders");

  // copy p_pRequestRec headers
  headers =  (table_entry *) headers_arr->elts;
  for (i=0;i<headers_arr->nelts;i++)
    {
      if (headers[i].key)
        {
          GSWDebugLog(pServerRec,"key=%s value=%s",
                      headers[i].key,headers[i].val);
          GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
                                   headers[i].key,headers[i].val);
        };
    };

  // Add server headers
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			   g_szServerInfo_ServerSoftware,
			   SERVER_VERSION
                           );
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			   g_szServerInfo_RequestScheme,
			   ap_http_method(p_pRequestRec));

  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			   g_szServerInfo_Protocol,
			   p_pRequestRec->protocol);

  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			   g_szServerInfo_ProtocolNum,
			   ap_psprintf(p_pRequestRec->pool,
                                        "%u",
                                        p_pRequestRec->proto_num));

  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			   g_szServerInfo_ServerName,
			   pServerRec->server_hostname);

  {
    unsigned int serverPort=(unsigned)ap_get_server_port(p_pRequestRec);
    if (serverPort==0)
      {
        if (p_pRequestRec->parsed_uri.port_str && p_pRequestRec->parsed_uri.port!=0)
          serverPort=(unsigned)p_pRequestRec->parsed_uri.port;
        else
          serverPort=(unsigned)pServerRec->port;
      };
    pszPort = ap_psprintf(p_pRequestRec->pool,
                           "%u",
                           (unsigned int)serverPort);
  };

  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			   g_szServerInfo_ServerPort,
			   pszPort);
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			   g_szServerInfo_RemoteHost,
			   (CONST char *)ap_get_remote_host(pConnection,
						p_pRequestRec->per_dir_config,
						REMOTE_NAME));
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			   g_szServerInfo_RemoteAddress,
			   pConnection->remote_ip);
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			   g_szServerInfo_DocumentRoot,
			   (char *)ap_document_root(p_pRequestRec));
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			   g_szServerInfo_ServerAdmin,
			   pServerRec->server_admin);
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			   g_szServerInfo_ScriptFileName,
			   p_pRequestRec->filename);
#if 0
  pszPort = ap_psprintf(p_pRequestRec->pool,
                         "%u",
                         ntohs(pConnection->remote_addr.sin_port)
                         );
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			   g_szServerInfo_RemotePort,
			   pszPort);
#endif
  
  if (pConnection->user)
    GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			     g_szServerInfo_RemoteUser,
			     pConnection->user);
  if (pConnection->ap_auth_type)
    GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			     g_szServerInfo_AuthType,//"auth_type",
			     pConnection->ap_auth_type);
  pszRemoteLogName = (char *)ap_get_remote_logname(p_pRequestRec);
  if (pszRemoteLogName)
    GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
			     g_szServerInfo_RemoteIdent,
			     pszRemoteLogName);
  GSWDebugLog(pServerRec,"Stop copyHeaders");
};

//--------------------------------------------------------------------
// callback fonction to copy an header into p_pRequest
static void
getHeader(GSWDictElem *p_pElem,
	  void        *p_pRequestRec)
{
  request_rec *pRequestRec = (request_rec *)p_pRequestRec;
  server_rec *pServerRec = pRequestRec->server;

  GSWDebugLog(pServerRec,"Start getHeader key=%s value=%s headers_out=%p",
              p_pElem->pszKey,(char *)p_pElem->pValue,pRequestRec->headers_out);

  if (!pRequestRec->content_type &&
      strcasecmp(p_pElem->pszKey,g_szHeader_ContentType)==0)
    {
      pRequestRec->content_type = (char *)ap_pstrdup(pRequestRec->pool,
                                                     (char *)p_pElem->pValue);//TODOVERIFY: strdup or not ?
    }
  else
    ap_table_add(pRequestRec->headers_out,p_pElem->pszKey,
		 (char *)p_pElem->pValue);

  GSWDebugLog(pServerRec,"Stop getHeader");
};

//--------------------------------------------------------------------
// send response

static void
sendResponse(request_rec     *p_pRequestRec,
	     GSWHTTPResponse *p_pHTTPResponse)
{
  server_rec *pServerRec = p_pRequestRec->server;

  GSWDebugLog(pServerRec,"Start sendResponse");

  p_pHTTPResponse->pStats->_responseLength=p_pHTTPResponse->uContentLength;
  p_pHTTPResponse->pStats->_responseStatus=p_pHTTPResponse->uStatus;
  
  p_pHTTPResponse->pStats->_prepareSendResponseTS=GSWTime_now();
	
  // Process Headers
  GSWDict_PerformForAllElem(p_pHTTPResponse->pHeaders,getHeader,p_pRequestRec);
	
  GSWDebugLog(pServerRec,"status message=[%s]",p_pHTTPResponse->pszStatusMessage);
  p_pRequestRec->status_line = ap_psprintf(p_pRequestRec->pool,"%u %s",
                                            p_pHTTPResponse->uStatus,
                                            p_pHTTPResponse->pszStatusMessage);

  p_pRequestRec->status = p_pHTTPResponse->uStatus;
  GSWDebugLog(pServerRec,"p_pRequestRec->status_line=[%s]",p_pRequestRec->status_line);

  // Set content type if none
  if (!p_pRequestRec->content_type)
    {
      p_pRequestRec->content_type = g_szContentType_TextHtml;
    };
  GSWDebugLog(pServerRec,"p_pRequestRec->content_type=%s",p_pRequestRec->content_type);
	
  // Set content length
  ap_set_content_length(p_pRequestRec, p_pHTTPResponse->uContentLength);

  // Now Send response...

  p_pHTTPResponse->pStats->_beginSendResponseTS=GSWTime_now();

  // send Headers
  ap_send_http_header(p_pRequestRec);	

  // If not headers only
  if (!p_pRequestRec->header_only)
    {
      ap_soft_timeout("Send GSWeb response",p_pRequestRec);
      ap_rwrite(p_pHTTPResponse->pContent,p_pHTTPResponse->uContentLength,
		p_pRequestRec);
      ap_kill_timeout(p_pRequestRec);
    };

  p_pHTTPResponse->pStats->_endSendResponseTS=GSWTime_now();

  GSWDebugLog(pServerRec,"Stop sendResponse");
};

//--------------------------------------------------------------------
// die/send response
static int
dieSendResponse(request_rec       *p_pRequestRec,
                GSWTimeStats      *p_pStats,
		GSWHTTPResponse  **p_ppHTTPResponse,
		BOOL               p_fDecline)
{
  server_rec *pServerRec = p_pRequestRec->server;
  void       *pLogServerData=pServerRec;

  GSWDebugLog(pLogServerData,"Start dieSendResponse");
  sendResponse(p_pRequestRec,*p_ppHTTPResponse);
  GSWHTTPResponse_Free(*p_ppHTTPResponse,pLogServerData);
  *p_ppHTTPResponse=NULL;
  GSWDebugLog(pLogServerData,"Start dieSendResponse");
  return p_fDecline ? DECLINED : OK;
};

//--------------------------------------------------------------------
// die with a message
static int
dieWithMessage(request_rec *p_pRequestRec,
               GSWTimeStats *p_pStats,
	       CONST char  *p_pszMessage,
	       BOOL         p_fDecline)
{
  int iReturn=0;
  GSWHTTPResponse *pResponse=NULL;	
  server_rec      *pServerRec = p_pRequestRec->server;

  GSWDebugLog(pServerRec,"Start dieWithMessage");
  GSWLog(__FILE__, __LINE__,GSW_ERROR,pServerRec,"Send Error Response: %s",p_pszMessage);

  pResponse = GSWHTTPResponse_BuildErrorResponse(NULL,
                                                 p_pStats,
                                                 200,	// Status
                                                 NULL,	// Headers
                                                 &GSWTemplate_ErrorResponse,	// Template
                                                 p_pszMessage, // Message
						 p_pRequestRec->server);

  iReturn=dieSendResponse(p_pRequestRec,p_pStats,
                          &pResponse,p_fDecline);

  GSWDebugLog(pServerRec,"Stop dieWithMessage");
  return iReturn;
};

//--------------------------------------------------------------------
//	GSWeb Request Handler
static int
GSWeb_Handler(request_rec *p_pRequestRec)
{
  int               iRetVal=OK;
  GSWURLComponents  stURLComponents;
  GSWHTTPResponse  *pResponse = NULL;
  GSWURLError       eError=GSWURLError_OK;
  CONST char       *pszURLError=NULL;
  server_rec       *pServerRec = p_pRequestRec->server;
  void             *pLogServerData=pServerRec;
  GSWeb_Config     *pConfig=NULL;
  GSWTimeStats	   stStats;

  memset(&stStats,0,sizeof(stStats));

  // The request time stamp
  stStats._requestTS=(GSWTime)(p_pRequestRec->request_time);

  // Handling start time stamp
  stStats._beginHandleRequestTS=GSWTime_now();
 
  memset(&stURLComponents,0,sizeof(stURLComponents));

  // We'll load config soon to set debug flag
  if (!GSWConfig_IsReaden())
    GSWConfig_LoadConfiguration(pLogServerData);

  GSWDebugLog(pLogServerData,"Start GSWeb_Handler");

  pConfig=GSWeb_GetServerConfig(p_pRequestRec->server);

  // Log the request
  GSWLog(__FILE__, __LINE__,GSW_INFO,
	 pLogServerData,
	 "GNUstepWeb New request: %s",
	 p_pRequestRec->uri);

  // Is this for us ?
  if (strncmp(pConfig->pszGSWeb,
	      p_pRequestRec->uri,
	      strlen(pConfig->pszGSWeb))==0) 
    {
      // Parse the uri
      eError=GSWParseURL(&stURLComponents,
                         p_pRequestRec->uri,
			 pLogServerData);
      if (eError!=GSWURLError_OK)
	{
	  pszURLError=GSWURLErrorMessage(eError,
					 pLogServerData);
	  GSWLog(__FILE__, __LINE__,GSW_INFO,pLogServerData,"URL Parsing Error: %s", pszURLError);
	  if (eError==GSWURLError_InvalidAppName)
	    {
	      pResponse = GSWDumpConfigFile(&stStats,
                                            &stURLComponents,
					    p_pRequestRec->server);
	      iRetVal=dieSendResponse(p_pRequestRec,&stStats,
                                      &pResponse,NO);
	    }
	  else
	    iRetVal=dieWithMessage(p_pRequestRec,
                                   &stStats,
                                   pszURLError,NO);
	}
      else
	{
	  iRetVal = ap_setup_client_block(p_pRequestRec,REQUEST_CHUNKED_ERROR);
	  if (iRetVal==0) // OK Continue
	    {
	      // Build the GSWHTTPRequest with the method
	      GSWHTTPRequest *pRequest=NULL;
	      CONST char     *pszRequestError=NULL;
	      
	      pRequest=GSWHTTPRequest_New(p_pRequestRec->method,
                                          NULL,
                                          &stStats,
					  pLogServerData);
	      
	      // validate the method
	      pszRequestError=GSWHTTPRequest_ValidateMethod(pRequest,
							    pLogServerData);
	      if (pszRequestError)
		{
		  iRetVal=dieWithMessage(p_pRequestRec,&stStats,
                                         pszRequestError,NO);
		}
	      else
		{
		  CONST char *pszDocRoot=NULL;	
		  char* applicationName=NULL;
                  if (stURLComponents.stAppName.pszStart)
                    applicationName=gsw_strndup(stURLComponents.stAppName.pszStart,
                                                stURLComponents.stAppName.iLength);//We'll need to release it

		  // copy headers
		  copyHeaders(p_pRequestRec,pRequest);

                  if (applicationName)
                    GSWHTTPRequest_AddHeader(pRequest,
                                             g_szHeader_GSWeb_ApplicationName,
                                             applicationName);
		  // Get Form data if any
		  // POST Method
		  if (pRequest->eMethod==ERequestMethod_Post
		      && pRequest->uContentLength>0
		      && ap_should_client_block(p_pRequestRec))
		    {
		      long iReadLength=0;

		      size_t iRemainingLength = pRequest->uContentLength;
		      char *pszBuffer = malloc(pRequest->uContentLength);
		      char *pszData = pszBuffer;
		      
		      while (iRemainingLength>0)
			{
			  ap_soft_timeout("reading GSWeb request",
					  p_pRequestRec);
			  iReadLength=ap_get_client_block(p_pRequestRec,
							  pszData,
							  iRemainingLength);
			  ap_kill_timeout(p_pRequestRec);
			  if (iReadLength>0)
			    {
			      pszData += iReadLength;
			      iRemainingLength-=iReadLength;
			    }
			  else
			    {
			      /* FIXME: I think we should do some better
				 error handling but we need this so that
				 we don't endup backtracking the entire
				 content upon error which will make the
				 server look like it's in an endless loop.
				 I'm not sure whether ap_get_client_block
				 can ever legally return 0 eventhough
				 iRemainingLength was larger that 0, but
				 in such a case this will also get us out
			         of a potential endless loop.  */
			      memset(pszData,0,iRemainingLength);
			      iRemainingLength=0;
			    }
			};
		      GSWLog(__FILE__, __LINE__,GSW_INFO,pLogServerData,"pszBuffer(%p)=%.*s",
			     (void *)pszBuffer,
			     (int)pRequest->uContentLength,
			     pszBuffer);
		      pRequest->pContent = pszBuffer;
		    }
		  else if (pRequest->eMethod==ERequestMethod_Get)
		    {
		      // Get the QueryString
		      stURLComponents.stQueryString.pszStart =
			p_pRequestRec->args;
		      stURLComponents.stQueryString.iLength =
			p_pRequestRec->args ? strlen(p_pRequestRec->args) : 0;
		    };
		  
		  // get the document root
		  /*  if (pConfig && pConfig->pszRoot)
		      pszDocRoot = pConfig->pszRoot;
		      else*/
		  pszDocRoot=(char *)ap_document_root(p_pRequestRec);
		  
		  // Build the response 
		  // (Beware: tr_handleRequest free pRequest)
		  ap_soft_timeout("Call GSWeb Application",p_pRequestRec);
		  pRequest->pServerHandle = p_pRequestRec;
		  pResponse=GSWAppRequest_HandleRequest(&pRequest,
                                                        &stURLComponents,
                                                        p_pRequestRec->protocol,
                                                        pszDocRoot,
                                                        g_szGSWeb_StatusResponseAppName, //AppTest name
                                                        pLogServerData);
		  ap_kill_timeout(p_pRequestRec);
		  
		  // Send the response (if any)
		  if (pResponse)
		    {
		      sendResponse(p_pRequestRec,pResponse);
		      GSWHTTPResponse_Free(pResponse,pLogServerData);
		      iRetVal = OK;
		    }
		  else 
		    iRetVal = DECLINED;
                  if (applicationName)
                    free(applicationName);
		};
	    };
	};
      stStats._endHandleRequestTS=GSWTime_now();
      GSWStats_logStats(&stStats,pLogServerData);
      GSWStats_freeVars(&stStats);
    }
  else
    iRetVal = DECLINED;


  GSWDebugLog(pLogServerData,"Stop GSWeb_Handler");

  return iRetVal;
};

//--------------------------------------------------------------------
// Module definitions


static command_rec GSWeb_Commands[] =
{
  {
    GSWEB_CONF__ALIAS,    // Command keyword
    GSWeb_SetScriptAlias, // Function
    NULL,                 // Fixed Arg
    RSRC_CONF,            // Type
    TAKE1,                // Args Descr
    "ScriptAlias for GSWeb"
  },
  {
    GSWEB_CONF__CONFIG_FILE_PATH, // Command keyword
    GSWeb_SetConfig,              // Function
    NULL,                         // Fixed Arg
    RSRC_CONF,                    // Type
    TAKE1,                        // Args Descr
    "Configuration File Path for GSWeb"
  },
  {
    NULL
  }
};


handler_rec GSWeb_Handlers[] =
{
  { GSWEB__MIME_TYPE, GSWeb_Handler },
  { GSWEB_HANDLER, GSWeb_Handler },
  { NULL }
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
module gsweb_module =
{
  STANDARD_MODULE_STUFF,
  GSWeb_Init,               // Init
  NULL,                     // Create DirectoryConfig
  NULL,                     // Merge DirectoryConfig
  GSWeb_CreateServerConfig, // Create ServerConfig
  NULL,                     // Merge ServerConfig
  GSWeb_Commands,           // Commands List
  GSWeb_Handlers,           // Handlers List
  GSWeb_Translation,        // Fn to Translatie Filename/URI
  NULL,					
  NULL,					
  NULL,					
  NULL,					
  NULL,					
  NULL,					
  NULL					
};

