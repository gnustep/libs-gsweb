/* GNUstepNetscape.c - GSWeb: Netscape NSAPI Interface
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

#include <base/systems.h>
#include <base/pblock.h>
#include <base/session.h>
#include <base/daemon.h>
#include <base/net.h>
#include <base/util.h>
#include <frame/log.h>
#include <frame/req.h>
#include <frame/http.h>
#include <frame/conf.h>
#include <netsite.h>

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

#define server_portnum  port

//TODO
//#define	DEBUG_NETSCAPE

// Keywords of obj.conf
 

// Global Doc Root
static char* glb_pDocRoot = NULL;

#ifdef	DEBUG_NETSCAPE
static void NSDebugLog(pblock* p_pBlock,
					 const char* p_pszText)
{
  int i;
  struct pb_entry* entry = NULL;
  pb_param* nv=NULL;
  for (i=0;p_pBlock && i<p_pBlock->hsize;i++)
	{
	  entry = p_pBlock->ht[i];
	  while (entry)
		{
		  nv = entry->param;
		  if (nv) 
			GSWLog(GSW_ERROR,"%s: \t%s = %s",p_pszText,nv->name,nv->value);
		  entry = entry->next;
		};
	};
};
#else
#define	NSDebugLog(Block,Text)
#endif

//--------------------------------------------------------------------
// Init 

NSAPI_PUBLIC
int GSWeb_Init(pblock* p_pBlock,
			   Session* p_pSession,
			   Request *p_pRequest)
{
  GSWDict* pDict=NULL;
  const char* pDocRoot=NULL;
  int i=0;
  GSWConfig_Init();

  pDict=GSWDict_New(16);

  // Get Config Params
  for (i=0;i<p_pBlock->hsize;i++)
	{
	  struct pb_entry* pEntry=p_pBlock->ht[i];
	  while (pEntry)
		{
		  pb_param* pParam = pEntry->param;
		  if (pParam) 
			GSWDict_AddStringDup(pDict,pParam->name,pParam->value);
		  pEntry = pEntry->next;
		};
	};
  GSWLog_Init(pDict,GSW_INFO);
  GSWLoadBalancing_Init(pDict);
  
  // Get The Document Root
  pDocRoot = GSWDict_ValueForKey(pDict,g_szGSWeb_Conf_DocRoot);
  if (pDocRoot)
	{
	  glb_pDocRoot = strdup(pDocRoot);
	  GSWLog(GSW_INFO,NULL,"RootDocument=%s",glb_pDocRoot);
	}
  else
	GSWLog(GSW_INFO,NULL,"no RootDocument");
  
  GSWDict_Free(pDict);
  GSWLog(GSW_INFO,NULL,"GNUstepWeb initialized");
  return REQ_PROCEED;
};


//--------------------------------------------------------------------
// NameTrans

NSAPI_PUBLIC
int GSWeb_NameTrans(pblock *p_pBlock, Session *sn, Request *p_pRequest)
{
  int iRetVal=REQ_PROCEED;
  GSWURLComponents stURIComponents;
  const char *pszFrom=NULL;
  const char *pszURIPath=NULL;
  const char *pszObjName=NULL;
	
  memset(&stURIComponents,0,sizeof(stURIComponents));

  pszFrom = pblock_findval(g_szGSWeb_Conf_PathTrans,p_pBlock);
  pszURIPath = pblock_findval("ppath",p_pRequest->vars);
  pszObjName = pblock_findval(g_szGSWeb_Conf_Name,p_pBlock);

  if (!pszFrom || !pszURIPath || !pszObjName)
	iRetVal=REQ_NOACTION;
  else if (strncmp(pszFrom,pszURIPath,strlen(pszFrom)) == 0)
	{
	  // Parse the URL
	  GSWURLError eError=GSWParseURL(&stURIComponents,pszURIPath);
	  if (eError!=GSWURLError_OK)
		iRetVal=REQ_NOACTION;
	  else
		{
		  const char *pszAppRoot=NULL;
		  pblock_nvinsert(g_szGSWeb_Conf_Name,(char *)pszObjName,p_pRequest->vars);		
		  pszAppRoot = pblock_findval(g_szGSWeb_Conf_AppRoot,p_pBlock);
		  if (pszAppRoot)
			pblock_nvinsert(g_szGSWeb_Conf_AppRoot,(char *)pszAppRoot,p_pRequest->vars);
		  iRetVal=REQ_PROCEED;
		};
	}
  else
	iRetVal=REQ_NOACTION;
  return iRetVal;
};

//--------------------------------------------------------------------
//	GNUstepWeb Request Handler

NSAPI_PUBLIC int GSWeb_RequestHandler(pblock* p_pBlock,
									  Session* p_pSession,
									  Request* p_pRequest)
{
  int iRetVal=REQ_PROCEED;
  GSWHTTPResponse* pResponse = NULL;
  GSWURLError eError=GSWURLError_OK;
  const char* pszURLError=NULL;
  char* pszURI=NULL;
  GSWURLComponents stURLComponents;
  memset(&stURLComponents,0,sizeof(stURLComponents));

  NSDebugLog(p_pSession->client,"Session Client");
  NSDebugLog(p_pSession->client,"Session Client");
  NSDebugLog(p_pBlock,"pBlock");
  NSDebugLog(p_pRequest->vars,"p_pRequest->vars");
  NSDebugLog(p_pRequest->reqpb,"p_pRequest->reqpb");		
  NSDebugLog(p_pRequest->headers,"p_pRequest->headers");	
  NSDebugLog(p_pRequest->srvhdrs,"p_pRequest->srvhdrs");	

  // Get the URI
  pszURI = pblock_findval("uri", p_pRequest->reqpb);

  // Log it
  GSWLog(GSW_INFO,NULL,"GNUstepWeb New Request: %s", pszURI);
	
  // Parse it
  // Parse the uri
  eError=GSWParseURL(&stURLComponents,pszURI);
  if (eError!=GSWURLError_OK)
	{
	  pszURLError=GSWURLErrorMessage(eError);
	  // Log the error
	  GSWLog(GSW_INFO,NULL,"URL Parsing Error: %s", pszURLError);
	  if (eError==GSWURLError_InvalidAppName && GSWDumpConfigFile_CanDump())
		{
		  pResponse = GSWDumpConfigFile(NULL,&stURLComponents);
		  iRetVal=dieSendResponse(p_pSession,p_pRequest,&pResponse);
		}
	  else
		iRetVal=dieWithMessage(p_pSession,p_pRequest,pszURLError);
	}
  else
	{
	  // Build the GSWHTTPRequest with the method
	  GSWHTTPRequest* pRequest= GSWHTTPRequest_New(pblock_findval("method", p_pRequest->reqpb), NULL);

	  // validate the method
	  const char* pszRequestError= GSWHTTPRequest_ValidateMethod(pRequest);
	
	  if (pszRequestError)
		{
		  GSWHTTPRequest_Free(pRequest);
		  iRetVal=dieWithMessage(p_pSession,p_pRequest,pszRequestError);
		}
	  else
		{
		  // Copy Headers
		  copyHeaders(p_pBlock, p_pSession, p_pRequest, pRequest);

		  // Get Form data

		  // POST Method
		  if ((pRequest->eMethod==ERequestMethod_Post) && (pRequest->uContentLength>0))
			{
			  char* pszBuffer = malloc(pRequest->uContentLength);
			  char* pszData = pszBuffer;
			  int c;
			  int i=0;
			  for(i=0;i<pRequest->uContentLength;i++)//TODOV
				{
				  // Get a character
				  c = netbuf_getc(p_pSession->inbuf);
				  if (c == IO_ERROR)
					{
					  log_error(0,"GNUstepWeb",
								p_pSession,
								p_pRequest,
								"Error reading form data (Post Method)");
					  free(pszBuffer);
					  pResponse = GSWHTTPResponse_BuildErrorResponse("Bad mojo"); // TODO
					};
				  // Add Data
				  *pszData++ = c;
				}
			  pRequest->pContent = pszBuffer;
			}
		  // GET Method
		  else if (pRequest->eMethod==ERequestMethod_Get)
			{
			  // Get the QueryString
			  const char* pQueryString = pblock_findval("query", p_pRequest->reqpb);
			  stURLComponents.stQueryString.pszStart = pQueryString;
			  stURLComponents.stQueryString.iLength = pQueryString ? strlen(pQueryString) : 0;
			};

	
		  // So far, so good...
		  if (!pResponse)
			{
			  // Now we call the Application !

			  // get the document root
			  const char* pszDocRoot=getDocumentRoot(p_pRequest);	
			  pRequest->pServerHandle = p_pRequest;

			  // Build the response (Beware: tr_handleRequest free pRequest)
			  pResponse=GSWAppRequest_HandleRequest(&pRequest,
													&stURLComponents,
													pblock_findval("protocol",p_pRequest->reqpb),
													pszDocRoot,
													"SB", // TODO AppTest name
													NULL);
			};
		
		  // Send the response (if any)
		  if (pResponse)
			{
			  iRetVal = sendResponse(p_pSession, p_pRequest, pResponse);
			  GSWHTTPResponse_Free(pResponse);
			}
		  else 
			// No Application Response !
			iRetVal = REQ_EXIT;		
		};
	};
  return iRetVal;
};

//--------------------------------------------------------------------
// Get the DocumentRoot

static const char *getDocumentRoot(Request* p_pRequest)
{
  const char* pszAppRoot=NULL;

  // Try to get AppRoot
  pszAppRoot = pblock_findval(g_szGSWeb_Conf_AppRoot,p_pRequest->vars);
  if (!pszAppRoot) 
	{
	  // If global AppRoot, take it !
	  if (glb_pDocRoot)
		pszAppRoot=glb_pDocRoot;
	  else
		{
		  httpd_object *dflt=NULL;
		  int iDTable=0;

		  // Get the "default" object
		  dflt = objset_findbyname("default",NULL,p_pRequest->os);
		  
		  // Find the root option
		  for (iDTable=0, pszAppRoot=NULL;dflt && iDTable<dflt->nd && !pszAppRoot;iDTable++)
			{
			  int j=0;
			  dtable dt=dflt->dt[iDTable];
			  for (j=0;j<dt.ni && !pszAppRoot;j++)
				{
				  const char* pszFN=NULL;
				  pblock* pBlock = dt.inst[j].param;
				  pszFN = pblock_findval("fn", pBlock);
				  if (strcmp(pszFN, "document-root")==0)
					pszAppRoot=pblock_findval("root",pBlock);
				};
			};
		  glb_pDocRoot = (char*)pszAppRoot;
		};
	};
  return pszAppRoot;
}

//--------------------------------------------------------------------
// Copy A Header headers into p_pGSWHTTPRequest

static void copyAHeader(const char* p_pszHeaderKey,
						pblock* p_pBlock,
						GSWHTTPRequest* p_pGSWHTTPRequest,
						const char* p_pszGSWebKey)
{
  const char* p_pszValue = pblock_findval(p_pszHeaderKey,p_pBlock);
  if (p_pszValue)
	GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
				  (p_pszGSWebKey ? p_pszGSWebKey : p_pszHeaderKey),
				  p_pszValue);
};

//--------------------------------------------------------------------
// Copy headers into p_pGSWHTTPRequest

static void copyHeaders(pblock* p_pBlock,
						Session* p_pSession,
						Request* p_pRequest,
						GSWHTTPRequest* p_pGSWHTTPRequest)
{
  int i=0;
  const char* pszHeaderValue=NULL;
  char szPort[64]="";
  request_loadheaders(p_pSession,p_pRequest);
	
  // copy p_pRequest headers
  for (i=0;i<p_pRequest->headers->hsize;i++)
	{
	  struct pb_entry *pEntry=p_pRequest->headers->ht[i];
	  while (pEntry)
		{
		  pb_param *header = pEntry->param;
		  if (header) 
			GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,header->name,header->value);
		  pEntry = pEntry->next;
		};
	};

  // Add Method
  if (p_pGSWHTTPRequest->eMethod==ERequestMethod_Post)
	GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
							 g_szServerInfo_RequestMethod,
							 g_szMethod_Post);
  else
	GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
							 g_szServerInfo_RequestMethod,
							 g_szMethod_Get);

  // Add server headers
  copyAHeader("query",
			  p_pRequest->reqpb,
			  p_pGSWHTTPRequest,
			  g_szServerInfo_QueryString);
  copyAHeader("protocol",
			  p_pRequest->reqpb,
			  p_pGSWHTTPRequest,
			  g_szServerInfo_ServerProtocol);
  copyAHeader("ip",
			  p_pSession->client,
			  p_pGSWHTTPRequest,
			  g_szServerInfo_RemoteAddress);
  copyAHeader("auth-user",
			  p_pRequest->vars,
			  p_pGSWHTTPRequest,
			  g_szServerInfo_AuthUser);
  copyAHeader("auth-type",
			  p_pRequest->vars,
			  p_pGSWHTTPRequest,
			  g_szServerInfo_AuthType);
  /*
	AUTH_TYPE                         pblock_findval("auth-type", p_pRequest->vars);
	AUTH_USER                         pblock_findval("auth-user", p_pRequest->vars);
	uContentLength                    pblock_findval("content-length", p_pRequest->srvhdrs);
	CONTENT_TYPE                      pblock_findval( content-type", p_pRequest->srvhdrs);
	GATEWAY_INTERFACE                 "CGI/1.1"
	HTTP_*                            pblock_findval( "*", p_pRequest->headers); (* is lower-case, dash replaces underscore)
	PATH_INFO                         pblock_findval("path-info", p_pRequest->vars);
	PATH_TRANSLATED                   pblock_findval( path-translated", p_pRequest->vars);
	QUERY_STRING                      pblock_findval( query", p_pRequest->reqpb); // Only for GET
	REMOTE_ADDR                       pblock_findval("ip", p_pSession->client);
	REMOTE_HOST                       session_dns(p_pSession) ? session_dns(p_pSession) : pblock_findval("ip", p_pSession->client);
	REMOTE_IDENT                      pblock_findval( "from", p_pRequest->headers);
	REMOTE_USER                       pblock_findval("auth-user", p_pRequest->vars);
	REQUEST_METHOD                    pblock_findval("method", req->reqpb);
	SCRIPT_NAME                       pblock_findval("uri", p_pRequest->reqpb);
	SERVER_NAME                       char *util_hostname();
	SERVER_PORT                       conf_getglobals()->Vport; (as a string)
	SERVER_PROTOCOL                   pblock_findval("protocol", p_pRequest->reqpb);
	SERVER_SOFTWARE                   MAGNUS_VERSION_STRING
	Netscape specific:
	CLIENT_CERT                       pblock_findval("auth-cert", p_pRequest->vars);
	HOST                              char *session_maxdns(p_pSession); (may be null)
	HTTPS                             security_active ? "ON" : "OFF";
	HTTPS_KEYSIZE                     pblock_findval("keysize", p_pSession->client);
	HTTPS_SECRETKEYSIZE               pblock_findval("secret-keysize", p_pSession->client);
	QUERY                             pblock_findval( query", p_pRequest->reqpb); // Only for GET
	SERVER_URL                        http_uri2url_dynamic("","", p_pSession, p_pRequest);
  */

  // Try to get Host
  pszHeaderValue = session_maxdns(p_pSession);
  if (!pszHeaderValue)
	pszHeaderValue = session_dns(p_pSession);
  if (pszHeaderValue)
	GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
							 g_szServerInfo_RemoteHost,
							 pszHeaderValue);

  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
						   g_szServerInfo_ServerSoftware,
						   system_version());

  util_itoa(server_portnum, szPort);
  GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
						   g_szServerInfo_ServerPort,
						   szPort);
  
  //TODO
  /*
	conf_global_vars_s* pServerConf = conf_getglobals();
   GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest, "SERVER_NAME",pServerConf->Vserver_hostname);
  */
  
  pszHeaderValue = getDocumentRoot(p_pRequest);
  if (pszHeaderValue)
	GSWHTTPRequest_AddHeader(p_pGSWHTTPRequest,
							 g_szServerInfo_DocumentRoot,
							 pszHeaderValue);	
};

//--------------------------------------------------------------------
// callback finction to copy an header into p_pRequest
static void getHeader(GSWDictElem* p_pElem,Request* p_pRequest)
{
  pblock_nvinsert(p_pElem->pszKey,
				  p_pElem->pValue,
				  ((Request*)p_pRequest)->srvhdrs);
};

//--------------------------------------------------------------------
// send response

static int sendResponse(Session* p_pSession,
						Request* p_pRequest,
						GSWHTTPResponse* p_pResponse)
{
  int iRetVal=REQ_PROCEED;
  // Process Headers
  pblock_remove(g_szHeader_ContentType,p_pRequest->srvhdrs);
  GSWDict_PerformForAllElem(p_pResponse->pHeaders,getHeader,p_pRequest);
	
  // Verify content-length
  if (!pblock_findval(g_szHeader_ContentLength,p_pRequest->srvhdrs))	// !content-length ?
	{
	  char szLen[64];
	  util_itoa(p_pResponse->uContentLength,szLen);
	  pblock_nvinsert(g_szHeader_ContentLength,szLen,p_pRequest->srvhdrs);
	};
	
  // Status
  protocol_status(p_pSession,p_pRequest,p_pResponse->uStatus,p_pResponse->pszStatusMessage);

  // HEAD request unattended
  if (protocol_start_response(p_pSession, p_pRequest) == REQ_NOACTION)
	{
	  GSWLog(GSW_ERROR,NULL,"protocol_start_response() returned REQ_NOACTION");
	  iRetVal=REQ_PROCEED;
	}
  else if (p_pResponse->uContentLength)
	{
	  // Send response
	  if (net_write(p_pSession->csd, p_pResponse->pContent, p_pResponse->uContentLength) == IO_ERROR)
		{
		  GSWLog(GSW_ERROR,NULL,"Failed to send response");
		  iRetVal=REQ_EXIT;
	  };
	};
	return iRetVal;
};

//--------------------------------------------------------------------
// die/send response
static int dieSendResponse(Session* p_pSession,
						   Request* p_pRequest,
						   GSWHTTPResponse** p_ppResponse)
{
    sendResponse(p_pSession,
				 p_pRequest,
				 *p_ppResponse);
    GSWHTTPResponse_Free(*p_ppResponse);
	*p_ppResponse=NULL;
    return REQ_PROCEED;
};

//--------------------------------------------------------------------
// die with a message
static int dieWithMessage(Session* p_pSession,
						  Request* p_pRequest,
						  const char* p_pszMessage)
{
	GSWHTTPResponse* pResponse=NULL;
	log_error(0,"GNUstepWeb",NULL,NULL,"Aborting request - %s",p_pszMessage);
	pResponse = GSWHTTPResponse_BuildErrorResponse(p_pszMessage);
	return dieSendResponse(p_pSession,
						   p_pRequest,
						   &pResponse);
};



