/* GSWAppRequest.c - GSWeb: Adaptors: App Request
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
#include <stdlib.h>
#include <sys/param.h>

#include "config.h"
#include "GSWUtil.h"
#include "GSWDict.h"
#include "GSWConfig.h"
#include "GSWURLUtil.h"
#include "GSWAppRequestStruct.h"
#include "GSWAppConnect.h"
#include "GSWHTTPRequest.h"
#include "GSWHTTPResponse.h"
#include "GSWAppRequest.h"
#include "GSWHTTPHeaders.h"
#include "GSWLoadBalancing.h"

unsigned long glbRequestsNb = 0;
unsigned long glbResponsesNb = 0;


GSWHTTPResponse* GSWAppRequest_SendAppRequestToApp(GSWHTTPRequest** p_ppHTTPRequest,
												   GSWURLComponents* p_pURLComponents,
												   GSWAppRequest* p_pAppRequest,
												   CONST char* p_pszHTTPVersion,
												   void* p_pLogServerData);

GSWHTTPResponse* GSWAppRequest_HandleRequest(GSWHTTPRequest** p_ppHTTPRequest,
											 GSWURLComponents* p_pURLComponents,
											 CONST char* p_pszHTTPVersion,
											 CONST char* p_pszDocRoot,
											 CONST char* p_pszTestAppName,
											 void* p_pLogServerData)
{
  GSWHTTPResponse* pHTTPResponse=NULL;
  glbRequestsNb++;

  if (p_pURLComponents->stAppName.iLength<=0
	  || !p_pURLComponents->stAppName.pszStart)
	{
	  pHTTPResponse=GSWHTTPResponse_BuildErrorResponse("No Application Name");
	}
  else
	{
	  char szAppName[MAXPATHLEN+1]="";
	  char szHost[MAXHOSTNAMELEN+1]="";
	  GSWAppRequest stAppRequest;
	  memset(&stAppRequest,0,sizeof(stAppRequest));

	  // Get App Name
	  strncpy(szAppName,
			  p_pURLComponents->stAppName.pszStart,
			  p_pURLComponents->stAppName.iLength);
	  szAppName[p_pURLComponents->stAppName.iLength]=0;

	  DeleteTrailingSlash(szAppName);
	  if (strcmp(szAppName,p_pszTestAppName) == 0)
		pHTTPResponse=GSWHTTPResponse_BuildTestResponse(p_pLogServerData,*p_ppHTTPRequest);
	  else
		{
		  // Get Host Name
		  if (p_pURLComponents->stAppHost.iLength>0 && p_pURLComponents->stAppHost.pszStart)
			{
			  strncpy(szHost,
					  p_pURLComponents->stAppHost.pszStart,
					  p_pURLComponents->stAppHost.iLength);
			  szHost[p_pURLComponents->stAppHost.iLength] = '\0';
			};
		  
		  // Get Request Instance Number
		  
		  // in URL  ?
		  if (p_pURLComponents->stAppNumber.iLength>0 && p_pURLComponents->stAppNumber.pszStart)
			stAppRequest.iInstance = atoi(p_pURLComponents->stAppNumber.pszStart);
		  
		  // In Cookie ?
		  else
			{
			  CONST char* pszCookie=GSWHTTPRequest_HeaderForKey(*p_ppHTTPRequest,g_szHeader_Cookie);
			  if (pszCookie)
				{
				  CONST char* pszInstanceCookie=strstr(pszCookie, g_szGSWeb_InstanceCookie);
				  if (pszInstanceCookie)
					{
					  stAppRequest.iInstance = atoi(pszInstanceCookie + strlen(g_szGSWeb_InstanceCookie));
					  GSWLog(GSW_INFO,p_pLogServerData,"Cookie instance %d from %s",
							 stAppRequest.iInstance,
							 pszCookie);
					};
				};
			};
			  
		  stAppRequest.pszName = szAppName;
		  stAppRequest.pszHost = szHost;
		  stAppRequest.pszDocRoot = p_pszDocRoot;
		  stAppRequest.pRequest = *p_ppHTTPRequest;
		  stAppRequest.uURLVersion = (p_pURLComponents->stVersion.pszStart) ? 
			atoi(p_pURLComponents->stVersion.pszStart) : GSWEB_VERSION_MAJOR;
		  
		  GSWHTTPRequest_AddHeader(*p_ppHTTPRequest,
								   g_szHeader_GSWeb_ServerAdaptor,
								   g_szGSWeb_ServerAndAdaptorVersion);
		  pHTTPResponse=GSWAppRequest_SendAppRequestToApp(p_ppHTTPRequest,
														  p_pURLComponents,
														  &stAppRequest,
														  p_pszHTTPVersion,
														  p_pLogServerData);
		};
	};
  return pHTTPResponse;
}

GSWHTTPResponse* GSWAppRequest_SendAppRequestToApp(GSWHTTPRequest** p_ppHTTPRequest,
												   GSWURLComponents* p_pURLComponents,
												   GSWAppRequest* p_pAppRequest,
												   CONST char* p_pszHTTPVersion,
												   void* p_pLogServerData)
{
  GSWHTTPResponse* pHTTPResponse=NULL;
  BOOL fAppFound=FALSE;
  int iAttemptsRemaining=APP_CONNECT_RETRIES_NB;
  AppConnectHandle hConnect=NULL;

  if (p_pAppRequest->iInstance)
	fAppFound = GSWLoadBalancing_FindInstance(p_pLogServerData,p_pAppRequest);
  else
	fAppFound = GSWLoadBalancing_FindApp(p_pLogServerData,p_pAppRequest);

  if (!fAppFound)
	{
	  //TODO
	  // Call AppStart daemon
	};

  while (!pHTTPResponse && fAppFound && iAttemptsRemaining-->0)
	{
	  GSWLog(GSW_INFO,p_pLogServerData,"Trying to contact %s:%d on %s(%d)",
			 p_pAppRequest->pszName,
			 p_pAppRequest->iInstance,
			 p_pAppRequest->pszHost,
			 p_pAppRequest->iPort);
	  
	  hConnect = GSWApp_Open(p_pLogServerData,p_pAppRequest);
	  if (hConnect)
		{
		  if (p_pAppRequest->eType==EAppType_LoadBalanced)
			GSWLoadBalancing_StartAppRequest(p_pLogServerData,p_pAppRequest);
		  
		  GSWLog(GSW_INFO,p_pLogServerData,"%s:%d on %s(%d) connected",
				 p_pAppRequest->pszName,
				 p_pAppRequest->iInstance,
				 p_pAppRequest->pszHost,
				 p_pAppRequest->iPort);
		  
		  GSWHTTPRequest_HTTPToAppRequest(*p_ppHTTPRequest,
										  p_pAppRequest,
										  p_pURLComponents,
										  p_pszHTTPVersion);
		  if (GSWHTTPRequest_SendRequest(p_pLogServerData,*p_ppHTTPRequest, hConnect) != 0)
			{
			  GSWLog(GSW_ERROR,p_pLogServerData,"Failed to send request");
			  GSWApp_Close(p_pLogServerData,hConnect);
			  hConnect=NULL;
			  pHTTPResponse=GSWHTTPResponse_BuildErrorResponse("No Response");
			}
		  else
			{
			  GSWLog(GSW_INFO,p_pLogServerData,
					 "Request %s sent, awaiting response",
					 (*p_ppHTTPRequest)->pszRequest);
			
			  p_pAppRequest->pRequest = NULL;
			  pHTTPResponse = GSWHTTPResponse_GetResponse(p_pLogServerData,hConnect);
//			  GSWLog(GSW_INFO,p_pLogServerData,"GetResponse End pHTTPResponse=%p",pHTTPResponse);
			  p_pAppRequest->pResponse = pHTTPResponse;
			  
			  if (p_pAppRequest->eType == EAppType_LoadBalanced)
				GSWLoadBalancing_StopAppRequest(p_pLogServerData,p_pAppRequest);
				  
			  GSWApp_Close(p_pLogServerData,hConnect);
			  hConnect=NULL;
					  
			  glbResponsesNb++;
			  if (pHTTPResponse)
				{
				  GSWLog(GSW_INFO,p_pLogServerData,
						 "received: %d %s",
						 pHTTPResponse->uStatus,
						 pHTTPResponse->pszStatusMessage);
				};
			};
		}
	  else
		{
		  GSWLog(GSW_INFO,p_pLogServerData,"%s:%d NOT LISTENING on %s(%d)",
				p_pAppRequest->pszName,
				p_pAppRequest->iInstance,
				p_pAppRequest->pszHost,
				p_pAppRequest->iPort);
		  //TODO
		  /*
		  if (p_pAppRequest->eType == EAppType_Auto)
		  GSWLoadBalancing_MarkNotRespondingApp(p_pLogServerData,p_pAppRequest);

		  else*/ if (p_pAppRequest->eType == EAppType_LoadBalanced)
			{
			  GSWLoadBalancing_MarkNotRespondingApp(p_pLogServerData,p_pAppRequest);
			  if (iAttemptsRemaining-- > 0)
				  fAppFound = GSWLoadBalancing_FindApp(p_pLogServerData,p_pAppRequest);
			};
		  pHTTPResponse = GSWHTTPResponse_BuildErrorResponse("No Response");
		};
	};
  if (!pHTTPResponse)
	{
	  GSWLog(GSW_INFO,p_pLogServerData,
			 "Application %s not found or not responding",
			 p_pAppRequest->pszName);
	  pHTTPResponse = GSWDumpConfigFile(p_pLogServerData,p_pURLComponents);
	  if (!pHTTPResponse)
		{
		  pHTTPResponse = GSWHTTPResponse_BuildErrorResponse("No App Found");		
		  pHTTPResponse->uStatus = 404;
		  if (pHTTPResponse->pszStatusMessage)
			{
			  free(pHTTPResponse->pszStatusMessage);
			  pHTTPResponse->pszStatusMessage=NULL;
			};
		  pHTTPResponse->pszStatusMessage = strdup("File Not found");
		}
	};
  GSWHTTPRequest_Free(*p_ppHTTPRequest);
  *p_ppHTTPRequest=NULL;
  return pHTTPResponse;
};
