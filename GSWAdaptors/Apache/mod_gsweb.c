/* mod_gsweb.c - GSWeb: Apache Module
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jully 1999
   
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

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <sys/param.h>

#include "config.h"


#include "GSWUtil.h"
#include "GSWDict.h"
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


// Module Definition:

// Declare the module
module GSWeb_Module;


typedef struct _GSWeb_Config
{
  const char* pszGSWeb;				// default = GSWeb
  const char* pszConfigPath;			// path to GSWeb.conf
  const char* pszRoot;				// normally htdocs/GSWeb
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

static CONST char* GSWeb_SetDocRoot(cmd_parms* p_pCmdParams,void* p_pUnused,char *p_pszArg);
static CONST char* GSWeb_SetScriptAlias(cmd_parms *p_pCmdParams, void *p_pUnused, char *p_pszArg);
static CONST char *GSWeb_SetConfig(cmd_parms *p_pCmdParams, void *p_pUnused, char *p_pszArg);
static int GSWeb_Handler(request_rec* p_pRequestRec);

//--------------------------------------------------------------------
// Init
static void GSWeb_Init(server_rec* p_pServerRec, pool *p) 
{
  GSWDict* pDict=GSWDict_New(0);
  GSWeb_Config* pConfig=NULL;
  GSWConfig_Init();
  pConfig=(GSWeb_Config*)ap_get_module_config(p_pServerRec->module_config,
											  &GSWeb_Module);
  GSWLog_Init(NULL,GSW_INFO);
	
  if (pConfig && pConfig->pszConfigPath)
	GSWDict_AddStringDup(pDict,
						 g_szGSWeb_Conf_ConfigFilePath,
						 pConfig->pszConfigPath);
  if (pConfig && pConfig->pszRoot)
	GSWDict_AddStringDup(pDict,
						 g_szGSWeb_Conf_DocRoot,
						 pConfig->pszRoot);
  GSWLoadBalancing_Init(pDict);
	
  GSWLog(GSW_INFO,p_pServerRec,"GSWeb Init" GSWEB_HANDLER);
  GSWDict_Free(pDict);
};

//--------------------------------------------------------------------
// Create Config
static void *GSWeb_CreateConfig(pool* p_pPool,
								server_rec* p_pServerRec)
{
  GSWeb_Config *pConfig = (GSWeb_Config*)ap_palloc(p_pPool,sizeof(GSWeb_Config));
  pConfig->pszGSWeb = g_szGSWeb_Prefix;
  pConfig->pszConfigPath = NULL;
  pConfig->pszRoot = NULL;
  return pConfig;
};

//--------------------------------------------------------------------
// Set Param: DocRoot
static CONST char* GSWeb_SetDocRoot(cmd_parms* p_pCmdParams,void* p_pUnused,char *p_pszArg)
{
  server_rec* pServerRec = p_pCmdParams->server;
  GSWeb_Config* pConfig = (GSWeb_Config *)ap_get_module_config(pServerRec->module_config,
															   &GSWeb_Module);
  pConfig->pszRoot = p_pszArg;
  return NULL;
};

//--------------------------------------------------------------------
// Set Param: ScriptAlias
static CONST char* GSWeb_SetScriptAlias(cmd_parms *p_pCmdParams, void *p_pUnused, char *p_pszArg)
{
  server_rec* pServerRec = p_pCmdParams->server;
  GSWeb_Config* pConfig = (GSWeb_Config *)ap_get_module_config(pServerRec->module_config,
															   &GSWeb_Module);
  pConfig->pszGSWeb = p_pszArg;
  return NULL;
};

//--------------------------------------------------------------------
// Set Param: ConfigFile
static CONST char *GSWeb_SetConfig(cmd_parms *p_pCmdParams, void *p_pUnused, char *p_pszArg)
{
  server_rec* pServerRec = p_pCmdParams->server;
  GSWeb_Config* pConfig = (GSWeb_Config *)ap_get_module_config(pServerRec->module_config,
															   &GSWeb_Module);
  pConfig->pszConfigPath = p_pszArg;
  return NULL;
};


//--------------------------------------------------------------------
// Translate
int GSWeb_Translation(request_rec* p_pRequestRec)
{
  int iRetValue=OK;
  GSWeb_Config *pConfig= (GSWeb_Config *)ap_get_module_config(p_pRequestRec->server->module_config,
															  &GSWeb_Module);
  GSWURLComponents stURL;
  // Is this for us ?
  if (strncmp(pConfig->pszGSWeb,
			  p_pRequestRec->uri,
			  strlen(pConfig->pszGSWeb))==0) 
	{
	  GSWURLError eError=GSWParseURL(&stURL,p_pRequestRec->uri);
	  GSWLog(GSW_ERROR,p_pRequestRec->server,"==>GSWeb_Translation Error=%d",eError);
/*	  if (eError!=GSWURLError_OK)
		{
		  GSWLog(GSW_ERROR,p_pRequestRec->server,"==>GSWeb_Translation Decliend");
		  iRetValue=DECLINED;
		}
	  else
		{*/
	  GSWLog(GSW_INFO,
			 p_pRequestRec->server,
			 "GSWeb_Translation Handler p_pRequestRec->handler=%s pool=%p handler=%s pConfig->pszGSWeb=%s",
			 p_pRequestRec->handler,
			 p_pRequestRec->pool,
			 g_szGSWeb_Handler,
			 pConfig->pszGSWeb);
	  p_pRequestRec->handler=(char*)ap_pstrdup(p_pRequestRec->pool,g_szGSWeb_Handler);
	  iRetValue=OK;
/*		};*/
	}
  else
	{
	  GSWLog(GSW_INFO,p_pRequestRec->server,"GSWeb_Translation Decliend");
	  iRetValue=DECLINED;
	};
  return iRetValue;
};

//--------------------------------------------------------------------
static void copyHeaders(request_rec* p_pRequestRec,GSWHTTPRequest* p_pGSWHTTPRequest)
{
  server_rec* pServerRec = p_pRequestRec->server;
  conn_rec* pConnection = p_pRequestRec->connection;
  table* pHeadersIn = p_pRequestRec->headers_in;
  table_entry* pHeader=NULL;
  int i;
  char szPort[40]="";
  CONST char* pszRemoteLogName=NULL;
	
  // copy p_pRequestRec headers
  pHeader =  (table_entry*)(&pHeadersIn->a)->elts;
  for (i=0;i<(&pHeadersIn->a)->nelts;i++)
	{
	  if (pHeader->key)
		  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,pHeader->key,pHeader->val);
	  pHeader++;
	};

  // Add server headers
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
						   g_szServerInfo_ServerSoftware,
						   SERVER_VERSION);
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
						   g_szServerInfo_ServerName,
						   pServerRec->server_hostname);
  ap_snprintf(szPort,
			  sizeof(szPort),
			  "%u",
			  pServerRec->port);

  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
							 g_szServerInfo_ServerPort,
							 szPort);
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
						   g_szServerInfo_RemoteHost,
						   (CONST char*)ap_get_remote_host(pConnection,p_pRequestRec->per_dir_config,REMOTE_NAME));
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
						   g_szServerInfo_RemoteAddress,
						   pConnection->remote_ip);
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
						   g_szServerInfo_DocumentRoot,
						   (char*)ap_document_root(p_pRequestRec));
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
						   g_szServerInfo_ServerAdmin,
						   pServerRec->server_admin);
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
						   g_szServerInfo_ScriptFileName,
						   p_pRequestRec->filename);
  ap_snprintf(szPort,
			  sizeof(szPort),
			  "%d",
			  ntohs(pConnection->remote_addr.sin_port));
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
						   g_szServerInfo_RemotePort,
						   szPort);
	
  if (pConnection->user)
	GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
							 g_szServerInfo_RemoteUser,
							 pConnection->user);
  if (pConnection->ap_auth_type)
	GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
							 g_szServerInfo_AuthType,//"auth_type",
							 pConnection->ap_auth_type);
  pszRemoteLogName = (char*)ap_get_remote_logname(p_pRequestRec);
  if (pszRemoteLogName)
	GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
							 g_szServerInfo_RemoteIdent,
							 pszRemoteLogName);
};

//--------------------------------------------------------------------
// callback finction to copy an header into p_pRequest
static void getHeader(GSWDictElem* p_pElem,void* p_pRequestRec)
{
  request_rec* pRequestRec = (request_rec*)p_pRequestRec;
	
  if (!pRequestRec->content_type && strcasecmp(p_pElem->pszKey,g_szHeader_ContentType)==0)
	pRequestRec->content_type = (char*)ap_pstrdup(pRequestRec->pool,(char*)p_pElem->pValue);
  else
	ap_table_add(pRequestRec->headers_out,p_pElem->pszKey,(char*)p_pElem->pValue);
};

//--------------------------------------------------------------------
// send response

static void sendResponse(request_rec* p_pRequestRec,GSWHTTPResponse* p_pHTTPResponse)
{
  char szStatusBuffer[512]="";
	
  // Process Headers
  GSWDict_PerformForAllElem(p_pHTTPResponse->pHeaders,getHeader,p_pRequestRec);
	
  ap_snprintf(szStatusBuffer,sizeof(szStatusBuffer),"%u %s",
			  p_pHTTPResponse->uStatus,
			  p_pHTTPResponse->pszStatusMessage);
  p_pRequestRec->status_line = szStatusBuffer;
  p_pRequestRec->status = p_pHTTPResponse->uStatus;

  // Set content type if none
  if (!p_pRequestRec->content_type)
	p_pRequestRec->content_type = g_szContentType_TextHtml;
	
  // Set content length
  ap_set_content_length(p_pRequestRec, p_pHTTPResponse->uContentLength);

  // Now Send response...

  // send Headers
  ap_send_http_header(p_pRequestRec);	

  // If not headers only
  if (!p_pRequestRec->header_only)
	{
	  ap_soft_timeout("Send GSWeb response",p_pRequestRec);
	  ap_rwrite(p_pHTTPResponse->pContent,p_pHTTPResponse->uContentLength,p_pRequestRec);
	  ap_kill_timeout(p_pRequestRec);
	};
};

//--------------------------------------------------------------------
// die/send response
static int dieSendResponse(request_rec* p_pRequestRec,GSWHTTPResponse** p_ppHTTPResponse,BOOL p_fDecline)
{
  sendResponse(p_pRequestRec,*p_ppHTTPResponse);
  GSWHTTPResponse_Free(*p_ppHTTPResponse);
  *p_ppHTTPResponse=NULL;
  return p_fDecline ? DECLINED : OK;
};

//--------------------------------------------------------------------
// die with a message
static int dieWithMessage(request_rec* p_pRequestRec,CONST char* p_pszMessage,BOOL p_fDecline)
{
	GSWHTTPResponse* pResponse=NULL;	
	server_rec* pServerRec = p_pRequestRec->server;
	GSWLog(GSW_ERROR,pServerRec,"Send Error Response: %s",p_pszMessage);
	pResponse = GSWHTTPResponse_BuildErrorResponse(p_pszMessage);
	return dieSendResponse(p_pRequestRec,&pResponse,p_fDecline);
};

//--------------------------------------------------------------------
//	GSWeb Request Handler
static int GSWeb_Handler(request_rec* p_pRequestRec)
{
  int iRetVal=OK;
  GSWURLComponents stURLComponents;
  GSWHTTPResponse* pResponse = NULL;
  GSWURLError eError=GSWURLError_OK;
  CONST char* pszURLError=NULL;
  server_rec* pServerRec = p_pRequestRec->server;
  memset(&stURLComponents,0,sizeof(stURLComponents));

  // Log the request
  GSWLog(GSW_INFO,
		 pServerRec,
		 "GNUstepWeb New request: %s",
		 p_pRequestRec->uri);

  // Parse the uri
  eError=GSWParseURL(&stURLComponents,p_pRequestRec->uri);
  if (eError!=GSWURLError_OK)
	{
	  pszURLError=GSWURLErrorMessage(eError);
	  GSWLog(GSW_INFO,pServerRec,"URL Parsing Error: %s", pszURLError);
	  if (eError==GSWURLError_InvalidAppName && GSWDumpConfigFile_CanDump())
		{
		  pResponse = GSWDumpConfigFile(p_pRequestRec->server,&stURLComponents);
		  iRetVal=dieSendResponse(p_pRequestRec,&pResponse,NO);
		}
	  else
		iRetVal=dieWithMessage(p_pRequestRec,pszURLError,NO);
	}
  else
	{
	  iRetVal = ap_setup_client_block(p_pRequestRec,REQUEST_CHUNKED_ERROR);
	  if (iRetVal==0) // OK Continue
		{
		  // Build the GSWHTTPRequest with the method
		  GSWHTTPRequest* pRequest=GSWHTTPRequest_New(p_pRequestRec->method,NULL);
	
		  // validate the method
		  CONST char* pszRequestError=GSWHTTPRequest_ValidateMethod(pRequest);
		  if (pszRequestError)
			{
			  iRetVal=dieWithMessage(p_pRequestRec,pszRequestError,NO);
			}
		  else
			{
			  GSWeb_Config* pConfig = NULL;
			  CONST char* pszDocRoot=NULL;	

			  // copy headers
			  copyHeaders(p_pRequestRec,pRequest);
	
			  // Get Form data if any
			  // POST Method
			  if (pRequest->eMethod==ERequestMethod_Post
				  && pRequest->uContentLength>0
				  && ap_should_client_block(p_pRequestRec))
				{
				  int iReadLength=0;
				  int iRemainingLength = pRequest->uContentLength;
				  char* pszBuffer = malloc(pRequest->uContentLength);
				  char* pszData = pszBuffer;
		
				  while (iRemainingLength>0)
					{
					  ap_soft_timeout("reading GSWeb request",p_pRequestRec);
					  iReadLength=ap_get_client_block(p_pRequestRec,pszData,iRemainingLength);
					  ap_kill_timeout(p_pRequestRec);
					  pszData += iReadLength;
					  iRemainingLength-=iReadLength;
					};
				  GSWLog(GSW_INFO,pServerRec,"pszBuffer(%p)=%.*s",
						 (void*)pszBuffer,
						 (int)pRequest->uContentLength,
						 pszBuffer);
				  pRequest->pContent = pszBuffer;
				}
			  else if (pRequest->eMethod==ERequestMethod_Get)
				{
				  // Get the QueryString
				  stURLComponents.stQueryString.pszStart = p_pRequestRec->args;
				  stURLComponents.stQueryString.iLength = p_pRequestRec->args ? strlen(p_pRequestRec->args) : 0;
				};

			  // get the document root
			  pConfig=(GSWeb_Config*)ap_get_module_config(p_pRequestRec->per_dir_config,&GSWeb_Module);
			  if (pConfig && pConfig->pszRoot)
				pszDocRoot = pConfig->pszRoot;
			  else
				pszDocRoot=(char*)ap_document_root(p_pRequestRec);
	
			  // Build the response (Beware: tr_handleRequest free pRequest)
			  ap_soft_timeout("Call GSWeb Application",p_pRequestRec);
			  pRequest->pServerHandle = p_pRequestRec;
			  pResponse=GSWAppRequest_HandleRequest(&pRequest,
													&stURLComponents,
													p_pRequestRec->protocol,
													pszDocRoot,
													"SB", //TODO AppTest name
													(void*)p_pRequestRec->server);
			  ap_kill_timeout(p_pRequestRec);
	
			  // Send the response (if any)
			  if (pResponse)
				{
				  sendResponse(p_pRequestRec,pResponse);
				  GSWHTTPResponse_Free(pResponse);
				  iRetVal = OK;
				}
			  else 
				iRetVal = DECLINED;
			};
		};
	};
  return iRetVal;
}


//--------------------------------------------------------------------
// Module definitions


static command_rec GSWeb_Commands[20] =
{
  {
	GSWEB_CONF__DOC_ROOT,			// Command keyword
	GSWeb_SetDocRoot,				// Function
	NULL,							// Fixed Arg
	RSRC_CONF,						// Type
	TAKE1,							// Args Descr
	"RootDirectory for GSWeb"
  },
  {
	GSWEB_CONF__ALIAS,		   	// Command keyword
	GSWeb_SetScriptAlias,			// Function
	NULL,							// Fixed Arg
	RSRC_CONF,						// Type
	TAKE1,							// Args Descr
	"ScriptAlias for GSWeb"
  },
  {
	GSWEB_CONF__CONFIG_FILE_PATH, 	// Command keyword
	GSWeb_SetConfig,				// Function
	NULL,							// Fixed Arg
	RSRC_CONF,						// Type
	TAKE1,							// Args Descr
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

module GSWeb_Module =
{
  STANDARD_MODULE_STUFF,
  GSWeb_Init,			// Init
  NULL,					// Create DirectoryConfig
  NULL,					// Merge DirectoryConfig
  GSWeb_CreateConfig,	// Create ServerConfig
  NULL,					// Merge ServerConfig
  GSWeb_Commands,		// Commands List
  GSWeb_Handlers,		// Handlers List
  GSWeb_Translation,	// Fn to Translatie Filename/URI
  NULL,					
  NULL,					
  NULL,					
  NULL,					
  NULL,					
  NULL,					
  NULL					
};
