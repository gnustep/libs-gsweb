/* GSWAppRequest.c - GSWeb: Adaptors: App Request
   Copyright (C) 1999, 2000, 2001, 2003-2005 Free Software Foundation, Inc.
   
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

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <sys/param.h>

#include "config.h"
#include "GSWUtil.h"
#include "GSWStats.h"
#include "GSWDict.h"
#include "GSWString.h"
#include "GSWConfig.h"
#include "GSWURLUtil.h"
#include "GSWAppRequestStruct.h"
#include "GSWAppConnect.h"
#include "GSWHTTPRequest.h"
#include "GSWHTTPResponse.h"
#include "GSWAppRequest.h"
#include "GSWHTTPHeaders.h"
#include "GSWLoadBalancing.h"
#include "GSWTemplates.h"
#include "GSWStats.h"

unsigned long glbRequestsNb = 0;
unsigned long glbResponsesNb = 0;

/*

HTTP/1.0 302 Apple WebObjects
x-webobjects-refusenewsessions: 900
Location: /cgi-bin/WebObjects/cancer.woa
x-webobjects-refusing-redirection: YES
x-webobjects-loadaverage: 1
Content-Length: 152

Sorry, your request could not immediately be processed. Please try this URL: <a href="/cgi-bin/WebObjects/cancer.woa">/cgi-bin/WebObjects/cancer.woa</a>
Connection closed by foreign host.

*/

//--------------------------------------------------------------------
GSWHTTPResponse *
GSWAppRequest_SendAppRequestToApp(GSWHTTPRequest  **p_ppHTTPRequest,
				  GSWURLComponents *p_pURLComponents,
				  GSWAppRequest    *p_pAppRequest,
				  CONST char       *p_pszHTTPVersion,
				  void             *p_pLogServerData)
{
  GSWHTTPResponse *pHTTPResponse=NULL;
  BOOL             fAppFound=FALSE;
  BOOL             fAppNotResponding=FALSE;
  int              iAttemptsRemaining=APP_CONNECT_RETRIES_NB;
  AppConnectHandle hConnect=NULL;
  char            *appName = NULL;
  int              appInstance = 0;

  GSWDebugLog(p_pLogServerData,"Start GSWAppRequest_SendAppRequestToApp");

  (*p_ppHTTPRequest)->pStats->_beginSearchAppInstanceTS=GSWTime_now();

  if (p_pAppRequest->iInstance>0) //-1 or 0 mean any instance
    fAppFound = GSWLoadBalancing_FindInstance(p_pAppRequest,
					      p_pLogServerData,
					      p_pURLComponents);
  else
    fAppFound = GSWLoadBalancing_FindApp(p_pAppRequest,
					 p_pLogServerData, 
					 p_pURLComponents);

  if (!fAppFound)
    {
      GSWLog(GSW_WARNING,p_pLogServerData,
             "App '%s' not found",
             p_pAppRequest->pszName);
      //TODO
      // Call AppStart daemon
    };

  (*p_ppHTTPRequest)->pStats->_endSearchAppInstanceTS=GSWTime_now();

  // Check if application is unavailable
  if (fAppFound
      && p_pAppRequest->pAppInstance
      && p_pAppRequest->pAppInstance->pApp
      && p_pAppRequest->pAppInstance->pApp->unavailableUntil>0
      && p_pAppRequest->pAppInstance->pApp->unavailableUntil>time(NULL))
    {
      pHTTPResponse=GSWHTTPResponse_BuildServiceUnavailableResponse(p_pAppRequest,
                                                                    p_pAppRequest->pStats,
                                                                    p_pAppRequest->pAppInstance->pApp->unavailableUntil,
                                                                    p_pLogServerData);
    }
  else
    {
      while (!pHTTPResponse && fAppFound && iAttemptsRemaining-->0)
        {
          fAppNotResponding=FALSE;
          GSWLog(GSW_INFO,p_pLogServerData,"Attempt# %d: Trying to contact %s:%d on %s:%d",
                 (int)(APP_CONNECT_RETRIES_NB-iAttemptsRemaining),
                 p_pAppRequest->pszName,
                 p_pAppRequest->iInstance,
                 p_pAppRequest->pszHost,
                 p_pAppRequest->iPort);
      
          if (p_pAppRequest->pStats->_pszRequestedAppName)
            free(p_pAppRequest->pStats->_pszRequestedAppName);
          p_pAppRequest->pStats->_pszRequestedAppName=strdup(p_pAppRequest->pszName);
          p_pAppRequest->pStats->_iRequestedAppInstance=p_pAppRequest->iInstance;

          hConnect = GSWApp_Open(p_pAppRequest,p_pLogServerData);
          if (hConnect)
            {
              GSWAssert(p_pAppRequest->pStats,p_pLogServerData,"No p_pAppRequest->pStats");
              p_pAppRequest->pStats->_beginAppRequestTS=GSWTime_now();
              if (p_pAppRequest->eType==EAppType_LoadBalanced)
                GSWLoadBalancing_StartAppRequest(p_pAppRequest,
                                                 p_pLogServerData);
          
              GSWDebugLog(p_pLogServerData,"%s:%d on %s:%d connected",
                          p_pAppRequest->pszName,
                          p_pAppRequest->iInstance,
                          p_pAppRequest->pszHost,
                          p_pAppRequest->iPort);

              if (p_pAppRequest->pStats->_pszHost)
                free(p_pAppRequest->pStats->_pszHost);
              p_pAppRequest->pStats->_pszHost=strdup(p_pAppRequest->pszHost);
              p_pAppRequest->pStats->_iPort=p_pAppRequest->iPort;
          
              GSWHTTPRequest_HTTPToAppRequest(*p_ppHTTPRequest,
                                              p_pAppRequest,
					      p_pURLComponents,
                                              p_pszHTTPVersion,
                                              p_pLogServerData);
              if (GSWHTTPRequest_SendRequest(*p_ppHTTPRequest,
                                             hConnect,
                                             p_pLogServerData) != 0)
                {
                  GSWLog(GSW_ERROR,p_pLogServerData,"Failed to send request to application %s:%d on %s:%d",
                         p_pAppRequest->pszName,
                         p_pAppRequest->iInstance,
                         p_pAppRequest->pszHost,
                         p_pAppRequest->iPort);
              
                  GSWApp_Close(hConnect,p_pLogServerData);
                  hConnect=NULL;
                  fAppNotResponding=TRUE;
                }
              else
                {
                  GSWDebugLog(p_pLogServerData,
                              "Request %s sent, awaiting response",
                              (*p_ppHTTPRequest)->pszRequest);
              
                  appName = strdup(p_pAppRequest->pszName);
                  appInstance = p_pAppRequest->iInstance;

                  if (p_pAppRequest->pStats->_pszFinalAppName)
                    free(p_pAppRequest->pStats->_pszFinalAppName);
                  p_pAppRequest->pStats->_pszFinalAppName=strdup(p_pAppRequest->pszName);
                  p_pAppRequest->pStats->_iFinalAppInstance=appInstance;
              
                  p_pAppRequest->pRequest = NULL;
                  pHTTPResponse = GSWHTTPResponse_GetResponse(p_pAppRequest->pStats,
                                                              hConnect,
                                                              p_pLogServerData);
                  p_pAppRequest->pResponse = pHTTPResponse;
              
                  if (p_pAppRequest->eType == EAppType_LoadBalanced)
                    GSWLoadBalancing_StopAppRequest(p_pAppRequest,
                                                    p_pLogServerData);
              
                  GSWApp_Close(hConnect,p_pLogServerData);
                  hConnect=NULL;
              
                  glbResponsesNb++;
                  if (pHTTPResponse)
                    {
                      char *value =
                        GSWDict_ValueForKey(pHTTPResponse->pHeaders,
                                            "x-gsweb-refusing-redirection");
                      if (value && (strncmp(value,"YES",3)==0))
			{
			  // refuseNewSessions == YES in app
			  GSWLog(GSW_INFO,p_pLogServerData,
                                 "### This app (%s / %d) is refusing all new sessions ###",
				 appName, appInstance);
			  GSWAppInfo_Set(appName, appInstance, TRUE);
			}
                  
                      GSWDebugLog(p_pLogServerData,"received: %d %s",
                                  pHTTPResponse->uStatus,
                                  pHTTPResponse->pszStatusMessage);
                    };
                  if (appName)
                    {
                      free(appName);
                      appName = NULL;
                    }
                };
              p_pAppRequest->pStats->_endAppRequestTS=GSWTime_now();
            }
          else
            {
              fAppNotResponding=TRUE;
              GSWLog(GSW_WARNING,p_pLogServerData,
                     "%s:%d NOT LISTENING on %s:%d",
                     p_pAppRequest->pszName,
                     p_pAppRequest->iInstance,
                     p_pAppRequest->pszHost,
                     p_pAppRequest->iPort);
              //TODO
              /*
                if (p_pAppRequest->eType == EAppType_Auto)
                GSWLoadBalancing_MarkNotRespondingApp(p_pAppRequest,
                p_pLogServerData);

                else*/ if (p_pAppRequest->eType==EAppType_LoadBalanced)
                  {
                    GSWLoadBalancing_MarkNotRespondingApp(p_pAppRequest,
                                                          p_pLogServerData);
                    if (iAttemptsRemaining-->0)
                      fAppFound=GSWLoadBalancing_FindApp(p_pAppRequest,
                                                         p_pLogServerData,
                                                         p_pURLComponents);
                  };
            };
        };
      if (fAppNotResponding)
        {
          GSWApp *pApp=(p_pAppRequest ?
                        (p_pAppRequest->pAppInstance ?
                         p_pAppRequest->pAppInstance->pApp : NULL) : NULL);
          char *pszString=GSWTemplate_ErrorNoResponseIncludedMessage(TRUE,pApp);
          pHTTPResponse = GSWHTTPResponse_BuildErrorResponse(p_pAppRequest,
                                                             p_pAppRequest->pStats,
                                                             200,	// Status
                                                             NULL,	// Headers
                                                             &GSWTemplate_ErrorNoResponse,	// Template
                                                             pszString,	// Message
                                                             p_pLogServerData);
          free(pszString);
        };

      if (!pHTTPResponse)
        {
          GSWLog(GSW_WARNING,p_pLogServerData,
                 "Application %s not found or not responding",
                 p_pAppRequest->pszName);
          pHTTPResponse = GSWDumpConfigFile(p_pAppRequest->pStats,
                                            p_pURLComponents,
                                            p_pLogServerData);
          if (!pHTTPResponse)
            {
              pHTTPResponse = GSWHTTPResponse_BuildErrorResponse(p_pAppRequest,
                                                                 p_pAppRequest->pStats,
                                                                 200,	// Status
                                                                 NULL,	// Headers
                                                                 &GSWTemplate_ErrorResponse,	// Template
                                                                 "No App Found",	// Message
                                                                 p_pLogServerData);
              pHTTPResponse->uStatus = 404;
              if (pHTTPResponse->pszStatusMessage)
                {
                  free(pHTTPResponse->pszStatusMessage);
                  pHTTPResponse->pszStatusMessage=NULL;
                };
              pHTTPResponse->pszStatusMessage = strdup("File Not found");
            }
        };
    };
  GSWHTTPRequest_Free(*p_ppHTTPRequest,p_pLogServerData);
  *p_ppHTTPRequest=NULL;

  GSWDebugLog(p_pLogServerData,"Stop GSWAppRequest_SendAppRequestToApp");
  return pHTTPResponse;
};

//--------------------------------------------------------------------
GSWHTTPResponse *
GSWAppRequest_HandleRequest(GSWHTTPRequest  **p_ppHTTPRequest,
			    GSWURLComponents *p_pURLComponents,
			    CONST char       *p_pszHTTPVersion,
			    CONST char       *p_pszDocRoot,
			    CONST char       *p_pszTestAppName,
			    void             *p_pLogServerData)
{
  GSWHTTPResponse *pHTTPResponse=NULL;

  GSWDebugLog(p_pLogServerData,"Start GSWAppRequest_HandleRequest");

  (*p_ppHTTPRequest)->pStats->_beginHandleAppRequestTS=GSWTime_now();

  glbRequestsNb++;

  if (!p_pURLComponents)
    {
      GSWLog(GSW_CRITICAL,p_pLogServerData,
	     "p_pURLComponents is NULL in GSWAppRequest_HandleRequest");
    }
  else
    {
      if (p_pURLComponents->stAppName.iLength<=0
	  || !p_pURLComponents->stAppName.pszStart)
	{
	  pHTTPResponse=GSWHTTPResponse_BuildErrorResponse(NULL,
                                                           (*p_ppHTTPRequest)->pStats,
                                                           200,		// Status
                                                           NULL,	// Headers
                                                           &GSWTemplate_ErrorResponse,	// Template
                                                           "No Application Name",	// Message
                                                           p_pLogServerData);
	}
      else
	{
	  char szAppName[MAXPATHLEN+1]="";
	  char szHost[MAXHOSTNAMELEN+1]="";
	  GSWAppRequest stAppRequest;
	  memset(&stAppRequest,0,sizeof(stAppRequest));
          stAppRequest.pStats=(*p_ppHTTPRequest)->pStats;

	  GSWDebugLog(p_pLogServerData,"Copy AppName");
	  // Get App Name
	  strncpy(szAppName,
		  p_pURLComponents->stAppName.pszStart,
		  p_pURLComponents->stAppName.iLength);
	  szAppName[p_pURLComponents->stAppName.iLength]=0;

	  DeleteTrailingSlash(szAppName);
	  if (strcmp(szAppName,p_pszTestAppName)==0)
	    pHTTPResponse=GSWHTTPResponse_BuildStatusResponse(*p_ppHTTPRequest,
							     p_pLogServerData);
	  else
	    {
	      GSWDebugLog(p_pLogServerData,"Get HostByName");
	      // Get Host Name
	      if (p_pURLComponents->stAppHost.iLength>0 &&
		  p_pURLComponents->stAppHost.pszStart)
		{
		  strncpy(szHost,
			  p_pURLComponents->stAppHost.pszStart,
			  p_pURLComponents->stAppHost.iLength);
		  szHost[p_pURLComponents->stAppHost.iLength] = '\0';
		};
		  
	      // Get Request Instance Number
	      GSWDebugLog(p_pLogServerData,"Get Request Instance Number");
	      
	      // in URL  ?
              GSWDebugLog(p_pLogServerData,
                     "Cookie %s",
                     p_pURLComponents->stAppNumber);
	      if (p_pURLComponents->stAppNumber.iLength>0 &&
		  p_pURLComponents->stAppNumber.pszStart)
                {
                  stAppRequest.iInstance =
                    atoi(p_pURLComponents->stAppNumber.pszStart);
                };

              // Any instance or not yet found instance ?
              // Search in cookie
              if (stAppRequest.iInstance<=0) 
		{
		  CONST char *pszCookie=
		    GSWHTTPRequest_HeaderForKey(*p_ppHTTPRequest,
						g_szHeader_Cookie);
                  GSWDebugLog(p_pLogServerData,
                         "Cookie Instance %s: %s",
                         g_szHeader_Cookie,
                         pszCookie);
		  if (pszCookie)
		    {
		      CONST char *pszInstanceCookie =
			strstr(pszCookie,
			       g_szGSWeb_InstanceCookie[GSWNAMES_INDEX]);
		      if (pszInstanceCookie)
			{
			  stAppRequest.iInstance = atoi(pszInstanceCookie +
			    strlen(g_szGSWeb_InstanceCookie[GSWNAMES_INDEX]));
			  GSWLog(GSW_INFO,p_pLogServerData,
				 "Cookie instance %d from %s",
				 stAppRequest.iInstance,
				 pszCookie);
			}
		      else
			{
			  pszInstanceCookie=strstr(pszCookie,
				      g_szGSWeb_InstanceCookie[WONAMES_INDEX]);
			  if (pszInstanceCookie)
			    {
			      stAppRequest.iInstance = atoi(pszInstanceCookie +
			      strlen(g_szGSWeb_InstanceCookie[WONAMES_INDEX]));
			      GSWLog(GSW_INFO,p_pLogServerData,
				     "Cookie instance %d from %s",
				     stAppRequest.iInstance,
				     pszCookie);
			    };
			};
		    };
		};
	      
	      stAppRequest.pszName = szAppName;
	      stAppRequest.pszHost = szHost;
	      stAppRequest.pszDocRoot = p_pszDocRoot;
	      stAppRequest.pRequest = *p_ppHTTPRequest;
	      stAppRequest.uURLVersion =
		(p_pURLComponents->stVersion.pszStart) ? 
		atoi(p_pURLComponents->stVersion.pszStart) :
		GSWEB_VERSION_MAJOR;
		  
	      GSWDebugLog(p_pLogServerData,"Add Header");
	      GSWHTTPRequest_AddHeader(*p_ppHTTPRequest,
				       g_szHeader_GSWeb_ServerAdaptor,
				       g_szGSWeb_ServerAndAdaptorVersion);
	      GSWDebugLog(p_pLogServerData,"SendAppRequestToApp");
	      pHTTPResponse =
		GSWAppRequest_SendAppRequestToApp(p_ppHTTPRequest,
						  p_pURLComponents,
						  &stAppRequest,
						  p_pszHTTPVersion,
						  p_pLogServerData);
	    };
	};
    };
  if (pHTTPResponse)
    pHTTPResponse->pStats->_endHandleAppRequestTS=GSWTime_now();

  GSWDebugLog(p_pLogServerData,"Stop GSWAppRequest_HandleRequest");

  return pHTTPResponse;
};

