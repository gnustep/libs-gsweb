/* GSWHTTPResponse.c - GSWeb: Adaptors: HTTP Response
   Copyright (C) 1999, 2000, 2001, 2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
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
#include "GSWDict.h"
#include "GSWString.h"
#include "GSWURLUtil.h"
#include "GSWConfig.h"
#include "GSWHTTPHeaders.h"
#include "GSWAppRequestStruct.h"
#include "GSWAppConnect.h"
#include "GSWHTTPRequest.h"
#include "GSWHTTPResponse.h"
#include "GSWAppRequest.h"
#include "GSWTemplates.h"


static char *g_pszLocalHostName = NULL;

#define	STATUS	"Status"
#define	HTTP_SLASH	"HTTP/"

//--------------------------------------------------------------------
GSWHTTPResponse *
GSWHTTPResponse_New(CONST char *p_pszStatus,
		    void       *p_pLogServerData)
{
  GSWHTTPResponse *pHTTPResponse=NULL;
  BOOL fOk=FALSE;
  // Accept "HTTP/1.0 200 OK GSWeb..." and "HTTP/1.0 200 OK GNUstep GSWeb..."
#ifdef	DEBUG
  GSWLog(GSW_INFO,p_pLogServerData,"p_pszStatus=%s",p_pszStatus);
#endif
  if (strncmp(p_pszStatus,HTTP_SLASH,strlen(HTTP_SLASH))==0)
    {
      // Status Code
      CONST char *pszSpace=strchr(p_pszStatus,' ');
      if (pszSpace)
	{
	  unsigned int uStatus=0;
	  fOk=TRUE;
	  pszSpace++;
	  uStatus=atoi(pszSpace);
#ifdef	DEBUG
	  GSWLog(GSW_INFO,p_pLogServerData,"uStatus=%u",uStatus);
#endif
	  for(;fOk && *pszSpace && !isspace(*pszSpace);pszSpace++)
	    fOk=isdigit(*pszSpace);
#ifdef	DEBUG
	  GSWLog(GSW_INFO,p_pLogServerData,"fOk=%d",(int)fOk);
#endif
	  if (fOk)
	    {
	      pHTTPResponse = calloc(1,sizeof(GSWHTTPResponse));
	      memset(pHTTPResponse,0,sizeof(GSWHTTPResponse));
	      pHTTPResponse->uStatus=uStatus;
	      pHTTPResponse->pHeaders = GSWDict_New(16);
	      if (*pszSpace)
		{
		  pszSpace=strchr(pszSpace,' ');
		  if (pszSpace)
		    pHTTPResponse->pszStatusMessage=strdup(pszSpace);
		};
	    };
	};
    };
  if (!fOk)
    GSWLog(GSW_ERROR,p_pLogServerData,"Invalid response");
  return pHTTPResponse;
};

//--------------------------------------------------------------------
GSWHTTPResponse * 
GSWHTTPResponse_BuildErrorResponse(GSWAppRequest *p_pAppRequest,
				   CONST char    *p_pszMessage,
				   void          *p_pLogServerData)
{
  char             szBuffer[128]="";
  GSWApp          *pApp=NULL;
  GSWString       *pBuffer=GSWString_New();
  GSWString       *pBufferMessage=GSWString_New();
  GSWHTTPResponse *pHTTPResponse=calloc(1,sizeof(GSWHTTPResponse));
  char            *pszString=NULL;

  GSWLog(GSW_DEBUG,p_pLogServerData,
	 "Start GSWHTTPResponse_BuildErrorResponse");
  if (p_pAppRequest && p_pAppRequest->pAppInstance)
    pApp=p_pAppRequest->pAppInstance->pApp;
#ifdef	DEBUG
  GSWLog(GSW_INFO,p_pLogServerData,
	 "Build Error Response [%s] pApp=%p",p_pszMessage,pApp);
#endif
  pHTTPResponse->uStatus = 200;
  pHTTPResponse->pszStatusMessage = strdup(g_szOKGSWeb[GSWNAMES_INDEX]);
  pHTTPResponse->pHeaders = GSWDict_New(2);
  GSWDict_Add(pHTTPResponse->pHeaders,
	      g_szHeader_ContentType,
	      g_szContentType_TextHtml,
	      FALSE);
  GSWString_Append(pBufferMessage,p_pszMessage);
  if (p_pAppRequest)
    {
      GSWString_SearchReplace(pBufferMessage,"##APP_NAME##",
			      p_pAppRequest->pszName);
      sprintf(szBuffer,"%d",p_pAppRequest->iInstance);
      GSWString_SearchReplace(pBufferMessage,"##APP_INSTANCE##",szBuffer);
      GSWString_SearchReplace(pBufferMessage,"##APP_HOST##",
			      p_pAppRequest->pszHost);
      sprintf(szBuffer,"%d",p_pAppRequest->iPort);
      GSWString_SearchReplace(pBufferMessage,"##APP_PORT##",szBuffer);
    };
  GSWTemplate_ReplaceStd(pBufferMessage,pApp);

  pszString=GSWTemplate_ErrorResponseText(TRUE,pApp);
  GSWString_Append(pBuffer,pszString);
  free(pszString);
  GSWString_SearchReplace(pBuffer,"##TEXT##",pBufferMessage->pszData);  
  GSWTemplate_ReplaceStd(pBuffer,pApp);
  
  pHTTPResponse->uContentLength = GSWString_Len(pBuffer);
  pHTTPResponse->pContent = pBuffer->pszData;
  GSWString_Detach(pBuffer);
  GSWString_Free(pBuffer);
  pBuffer=NULL;

  GSWString_Free(pBufferMessage);
  pBufferMessage=NULL;
  sprintf(szBuffer,"%d",pHTTPResponse->uContentLength);
  GSWDict_AddStringDup(pHTTPResponse->pHeaders,
		       g_szHeader_ContentLength,szBuffer);
  GSWLog(GSW_DEBUG,p_pLogServerData,"Stop GSWHTTPResponse_BuildErrorResponse");
  return pHTTPResponse;
};

//--------------------------------------------------------------------
GSWHTTPResponse *
GSWHTTPResponse_BuildRedirectedResponse(CONST char *p_pszRedirectPath,
					void       *p_pLogServerData)
{
  GSWHTTPResponse *pHTTPResponse=calloc(1,sizeof(GSWHTTPResponse));
  GSWLog(GSW_DEBUG,p_pLogServerData,
	 "Start GSWHTTPResponse_BuildRedirectedResponse");
  pHTTPResponse->uStatus = 302;
  pHTTPResponse->pszStatusMessage = strdup(g_szOKGSWeb[GSWNAMES_INDEX]);
  pHTTPResponse->pHeaders=GSWDict_New(2);
  GSWDict_Add(pHTTPResponse->pHeaders, g_szHeader_ContentType,
	      g_szContentType_TextHtml,FALSE);
  GSWDict_AddStringDup(pHTTPResponse->pHeaders,"location",p_pszRedirectPath);
  GSWLog(GSW_DEBUG,p_pLogServerData,
	 "Stop GSWHTTPResponse_BuildRedirectedResponse");
  return pHTTPResponse;
};

//--------------------------------------------------------------------
void
GSWHTTPResponse_Free(GSWHTTPResponse *p_pHTTPResponse,
		     void            *p_pLogServerData)
{
  GSWLog(GSW_DEBUG,p_pLogServerData,"Start GSWHTTPResponse_Free");
  if (p_pHTTPResponse)
    {
      if (p_pHTTPResponse->pHeaders)
	{
	  GSWDict_Free(p_pHTTPResponse->pHeaders);
	  p_pHTTPResponse->pHeaders=NULL;
	};
      if (p_pHTTPResponse->pszStatusMessage)
	{
	  free(p_pHTTPResponse->pszStatusMessage);
	  p_pHTTPResponse->pszStatusMessage=NULL;
	};
      if (p_pHTTPResponse->pContent)
	{
	  free(p_pHTTPResponse->pContent);
	  p_pHTTPResponse->pContent=NULL;
	};
      free(p_pHTTPResponse);
      p_pHTTPResponse=NULL;
    };
  GSWLog(GSW_DEBUG,p_pLogServerData,"Stop GSWHTTPResponse_Free");
};

//--------------------------------------------------------------------
void
GSWHTTPResponse_AddHeader(GSWHTTPResponse *p_pHTTPResponse,
			  char            *p_pszHeader)
{
  char *pszKey=NULL;
  char *pszValue=NULL;
	
  for (pszKey=p_pszHeader,pszValue=pszKey;*pszValue!=':';pszValue++)
    {
      if (isupper(*pszValue))
	*pszValue = tolower(*pszValue);
    };
  if (*pszValue==':')
    {
      *pszValue++='\0';
      while (*pszValue && isspace(*pszValue))
	pszValue++;
      GSWDict_AddStringDup(p_pHTTPResponse->pHeaders,pszKey,pszValue);
	
      if (p_pHTTPResponse->uContentLength==0 && 
	  strcmp(g_szHeader_ContentLength,pszKey)==0)
	p_pHTTPResponse->uContentLength = atoi(pszValue);
    }
  else
    {
      //TODO PB
    };
};

//--------------------------------------------------------------------
GSWHTTPResponse *
GSWHTTPResponse_GetResponse(AppConnectHandle p_socket,
			    void            *p_pLogServerData)
{
  GSWHTTPResponse *pHTTPResponse=NULL;
  char szResponseBuffer[RESPONSE__LINE_MAX_SIZE];
  GSWLog(GSW_DEBUG,p_pLogServerData,"Start GSWHTTPResponse_GetResponse");
	
  // Get the 1st Line
  GSWApp_ReceiveLine(p_socket,szResponseBuffer,
		     RESPONSE__LINE_MAX_SIZE,p_pLogServerData);
  pHTTPResponse = GSWHTTPResponse_New(szResponseBuffer,p_pLogServerData);
#ifdef	DEBUG
  GSWLog(GSW_INFO,p_pLogServerData,"Response receive first line:\t\t[%s]",
	 szResponseBuffer);
#endif
	
  if (!pHTTPResponse) //Error
    pHTTPResponse=GSWHTTPResponse_BuildErrorResponse(NULL,"Invalid Response",
						     p_pLogServerData);
  else
    {
      int iHeader=0;
      // Headers
      while (GSWApp_ReceiveLine(p_socket,szResponseBuffer,
				RESPONSE__LINE_MAX_SIZE,p_pLogServerData)>0
	     && szResponseBuffer[0])
	{
#ifdef	DEBUG
	  GSWLog(GSW_INFO,p_pLogServerData,"Header %d=\t\t[%s]",
		 iHeader,szResponseBuffer);
#endif
	  GSWHTTPResponse_AddHeader(pHTTPResponse,szResponseBuffer);
	};

	  // Content
      if (pHTTPResponse->uContentLength)
	{
	  char *pszBuffer= malloc(pHTTPResponse->uContentLength);
	  int iReceivedCount=GSWApp_ReceiveBlock(p_socket,pszBuffer,
						 pHTTPResponse->uContentLength,
						 p_pLogServerData);
#ifdef	DEBUG
	  GSWLog(GSW_INFO,p_pLogServerData,"iReceivedCount=%d",iReceivedCount);
#endif
	  if (iReceivedCount!= pHTTPResponse->uContentLength)
	    {
	      pHTTPResponse->pContent = pszBuffer;//TODO: Verify this (Turbocat patch)
	      
	      GSWLog(GSW_ERROR,p_pLogServerData,
		     "Content received doesn't equal to ContentLength. Too bad, same player shoot again !");

	      free(pszBuffer);
	      pszBuffer=NULL;
	      GSWHTTPResponse_Free(pHTTPResponse,p_pLogServerData);
	      pHTTPResponse=NULL;
	      pHTTPResponse = GSWHTTPResponse_BuildErrorResponse(NULL,
				  "Invalid Response",p_pLogServerData);

	    }
	  else
	    pHTTPResponse->pContent = pszBuffer;
	}
#ifdef	DEBUG
/*
      if (pHTTPResponse->pContent)
        {
	  char szTraceBuffer[pHTTPResponse->uContentLength+1];
	  GSWLog(GSW_INFO,p_pLogServerData,"\ncontent (%d Bytes)=\n",
	         pHTTPResponse->uContentLength);
	  memcpy(szTraceBuffer,pHTTPResponse->pContent,
		 pHTTPResponse->uContentLength);
	  szTraceBuffer[pHTTPResponse->uContentLength] = 0;
	  GSWLogSized(GSW_INFO,p_pLogServerData,
		      pHTTPResponse->uContentLength+1,
		      "%.*s",
		      (int)pHTTPResponse->uContentLength,
		      szTraceBuffer);
//	  GSWLog(GSW_INFO,p_pLogServerData,"\nEND\n");
	};
*/
#endif
    };
  GSWLog(GSW_DEBUG,p_pLogServerData,"Stop GSWHTTPResponse_GetResponse");
  return pHTTPResponse;
};


//--------------------------------------------------------------------
static void
GetHeaderLength(GSWDictElem *p_pElem,
		void        *p_piAddTo)
{
  int *piAddTo=(int *)p_piAddTo;
  // +2=": "
  // +1="\r"
  // +1="\n"
  (*piAddTo)+=strlen(p_pElem->pszKey)+strlen((char *)p_pElem->pValue)+2+1+2;
};

//--------------------------------------------------------------------
static void
FormatHeader(GSWDictElem *p_pElem,
	     void        *p_ppszBuffer)
{
  char **ppszBuffer=(char **)p_ppszBuffer;
  strcpy(*ppszBuffer,p_pElem->pszKey);
  strcat(*ppszBuffer, ": ");
  strcat(*ppszBuffer,(char *)p_pElem->pValue);
  (*ppszBuffer)+= strlen(*ppszBuffer);
  **ppszBuffer = '\r';
  (*ppszBuffer)++;
  **ppszBuffer = '\n';
  (*ppszBuffer)++;
};

//--------------------------------------------------------------------
char *
GSWHTTPResponse_PackageHeaders(GSWHTTPResponse *p_pHTTPResponse,
			       char            *p_pszBuffer,
			       int              p_iBufferSize)
{
  int iHeaderLength=0;
  char *pszBuffer=NULL;
  char *pszTmp=NULL;
	
  GSWDict_PerformForAllElem(p_pHTTPResponse->pHeaders,
			    GetHeaderLength,
			    (void *)&iHeaderLength);
  pszBuffer = ((p_iBufferSize > (iHeaderLength)) ?
	       p_pszBuffer : malloc(p_iBufferSize+1));
  pszTmp = pszBuffer;
	
  GSWDict_PerformForAllElem(p_pHTTPResponse->pHeaders,FormatHeader,&pszTmp);
  *pszTmp = '\0';
  if (pszTmp-pszBuffer>1)
    {
      // Remove last \r\n
      *(pszTmp-1) = 0;
      *(pszTmp-2) = 0; 
    };
  return pszBuffer;
};

//--------------------------------------------------------------------
void
GSWHTTPResponse_AddHeaderToString(GSWDictElem *p_pElem,
				  void        *p_pData)
{
  GSWString *pString=(GSWString *)p_pData;
  GSWString_Append(pString,p_pElem->pszKey);
  GSWString_Append(pString,": ");
  GSWString_Append(pString,(char *)p_pElem->pValue);
  GSWString_Append(pString,"<br>");
};

//--------------------------------------------------------------------
GSWHTTPResponse *
GSWHTTPResponse_BuildStatusResponse(GSWHTTPRequest *p_pHTTPRequest,
				    void           *p_pLogServerData)
{
  GSWHTTPResponse *pHTTPResponse=
    GSWHTTPResponse_New(g_szOKStatus[GSWNAMES_INDEX],p_pLogServerData);
  GSWDict    *pRequestHeaders=NULL;
  GSWString  *pContent=GSWString_New();
  GSWString  *pHeadersBuffer=GSWString_New();
  const char *pszRemoteAddr=NULL;
  const char *pszRemoteHost=NULL;
  char       *pszString=NULL;

  GSWLog(GSW_DEBUG,p_pLogServerData,
	 "Start GSWHTTPResponse_BuildStatusResponse");
  GSWLog(GSW_INFO,p_pLogServerData,"Build Status Page.");
  GSWConfig_LoadConfiguration(p_pLogServerData);
  GSWDict_AddString(pHTTPResponse->pHeaders,
		    g_szHeader_ContentType,
		    g_szContentType_TextHtml,
		    FALSE);
  
  pRequestHeaders = (GSWDict *)(p_pHTTPRequest->pHeaders);
  GSWDict_PerformForAllElem(pRequestHeaders,
			    GSWHTTPResponse_AddHeaderToString,pHeadersBuffer);
  if (GSWConfig_CanDumpStatus())
    pszString=GSWTemplate_StatusAllowedResponse(TRUE,NULL);
  else
    pszString=GSWTemplate_StatusDeniedResponse(TRUE,NULL);
  GSWString_Append(pContent,pszString);
  free(pszString);
  pszRemoteAddr=(const char *)GSWDict_ValueForKey(pRequestHeaders,
						  "x-gsweb-remote-addr");
  if (!pszRemoteAddr)
    pszRemoteAddr="";
  pszRemoteHost=(const char *)GSWDict_ValueForKey(pRequestHeaders,
						  "x-gsweb-remote-host");
  if (!pszRemoteHost)
    pszRemoteHost="";
  GSWString_SearchReplace(pContent,"##REMOTE_ADDR##",pszRemoteAddr);
  GSWString_SearchReplace(pContent,"##REMOTE_HOST##",pszRemoteHost);
  GSWString_SearchReplace(pContent,"##SERVER_INFO##",
			  GSWConfig_ServerStringInfo());  
  GSWString_SearchReplace(pContent,"##SERVER_URL##",GSWConfig_ServerURL());  
  GSWString_SearchReplace(pContent,"##ADAPTOR_INFO##",
			  g_szGSWeb_AdaptorStringInfo());  
  GSWString_SearchReplace(pContent,"##ADAPTOR_URL##",g_szGSWeb_AdaptorURL());  
  GSWString_SearchReplace(pContent,"##HEADERS##",pHeadersBuffer->pszData);  
  GSWTemplate_ReplaceStd(pContent,NULL);
  GSWString_Free(pHeadersBuffer);  
  pHeadersBuffer=NULL;
  
  pHTTPResponse->uContentLength = GSWString_Len(pContent);
  pHTTPResponse->pContent = pContent->pszData;
  GSWString_Detach(pContent);
  GSWString_Free(pContent);
  GSWLog(GSW_DEBUG,p_pLogServerData,
	 "Stop GSWHTTPResponse_BuildStatusResponse");
  return pHTTPResponse;
};

//--------------------------------------------------------------------
GSWHTTPResponse *
GSWDumpConfigFile(GSWURLComponents *p_pURLComponents,
		  void             *p_pLogServerData)
{
  GSWHTTPResponse *pHTTPResponse=NULL;  
  GSWString       *pContent=NULL;
  char             pszPrefix[MAXPATHLEN]="";
  char             szReqAppName[MAXPATHLEN]="Unknown";

  GSWLog(GSW_DEBUG,p_pLogServerData,"Start GSWDumpConfigFile");
  GSWLog(GSW_INFO,p_pLogServerData,"Creating Applications Page.");
  if (!g_pszLocalHostName)
    {
      char szHostName[MAXHOSTNAMELEN+1];
      gethostname(szHostName, MAXHOSTNAMELEN);
      g_pszLocalHostName= strdup(szHostName);
    };
	  
  pHTTPResponse = GSWHTTPResponse_New(g_szOKStatus[GSWNAMES_INDEX],
				      p_pLogServerData);
  GSWDict_AddString(pHTTPResponse->pHeaders,
		    g_szHeader_ContentType,
		    g_szContentType_TextHtml,
		    FALSE);
  if (p_pURLComponents->stAppName.iLength>0 &&
      p_pURLComponents->stAppName.pszStart)
    {
      strncpy(szReqAppName,p_pURLComponents->stAppName.pszStart,
	      p_pURLComponents->stAppName.iLength);
      szReqAppName[p_pURLComponents->stAppName.iLength]=0;
    };
	  
  strncpy(pszPrefix, p_pURLComponents->stPrefix.pszStart,
	  p_pURLComponents->stPrefix.iLength);
  pszPrefix[p_pURLComponents->stPrefix.iLength] = '\0';

  GSWConfig_LoadConfiguration(p_pLogServerData);
  pContent=GSWConfig_DumpGSWApps(szReqAppName,pszPrefix,FALSE,TRUE,
				 p_pLogServerData);
  GSWTemplate_ReplaceStd(pContent,NULL);
  pHTTPResponse->uContentLength = pContent->iLen;
  pHTTPResponse->pContent = pContent->pszData;
  GSWString_Detach(pContent);
  GSWString_Free(pContent);
  GSWLog(GSW_DEBUG,p_pLogServerData,"Stop GSWDumpConfigFile");
  return pHTTPResponse;	
};
