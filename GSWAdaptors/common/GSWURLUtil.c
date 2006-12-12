/* GSWURLUtil.c - GSWeb: Adaptors: URL Utils
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

//<PREFIX>/<APPLICATION-NAME>[ApplicationSuffix[/<APPLICATION-NUMBER>][/<REQUEST-HANDLER-KEY>[/<REQUEST-HANDLER-PATH>]]][?<QUERY-STRING>]

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#include "config.h"
#include "GSWUtil.h"
#include "GSWDict.h"
#include "GSWString.h"
#include "GSWConfig.h"
#include "GSWURLUtil.h"

//--------------------------------------------------------------------
GSWURLError
GSWParseURL(GSWURLComponents *p_pURLComponents,
	    CONST char       *p_pszURL,
	    void             *p_pLogServerData)
{
  GSWURLError eError=GSWURLError_OK;
  GSWURLComponent *pURLCPrefix=&p_pURLComponents->stPrefix;
  GSWURLComponent *pURLCVersion=&p_pURLComponents->stVersion;
  GSWURLComponent *pURLCAppName=&p_pURLComponents->stAppName;
  GSWURLComponent *pURLCAppNum=&p_pURLComponents->stAppNumber;
  GSWURLComponent *pURLCReqHandlerKey=&p_pURLComponents->stRequestHandlerKey;
  GSWURLComponent *pURLCReqHandlerPath=&p_pURLComponents->stRequestHandlerPath;
  GSWURLComponent *pURLCQueryString=&p_pURLComponents->stQueryString;
  int iURLLen=p_pszURL ? strlen(p_pszURL) : 0;
  CONST char *pszStart=pszStart = (p_pszURL ? p_pszURL : "");
  CONST char *pszStop=NULL;
  CONST char *pszNext=NULL;
  CONST char *pszPrefix=NULL;
  CONST char *pszS=NULL;
  CONST char *pszURLEnd=p_pszURL+iURLLen;
  CONST char *pszQueryStringMark=strchr(pszStart,'?');
  CONST char *pszTmpStop=(pszQueryStringMark && pszQueryStringMark<pszURLEnd) ?
    pszQueryStringMark : pszURLEnd;
  memset(p_pURLComponents,0,sizeof(GSWURLComponents));

  // First, get URL prefix
  pszPrefix=strcasestr(pszStart,g_szGSWeb_Prefix);
  if (pszPrefix && pszQueryStringMark && pszQueryStringMark<=pszPrefix)
    pszPrefix=NULL;

  if (pszPrefix)
    {
      CONST char *pszAppExtension=NULL;
      CONST char *pszfoundExtension=NULL;
      pszStop=pszPrefix+strlen(g_szGSWeb_Prefix);
      pszNext=*pszStop ? pszStop+1 : pszStop; // Drop the trailing /
      pURLCPrefix->pszStart = pszPrefix;
      pURLCPrefix->iLength = pszStop-pszStart;
      pURLCPrefix->iLength = max(pURLCPrefix->iLength,0);
      pURLCVersion->pszStart = g_szGSWeb_AdaptorVersion;
      pURLCVersion->iLength = strlen(g_szGSWeb_AdaptorVersion);
      
      // Get Application Name
      pszStart=pszNext;
      pszAppExtension=strcasestr(pszStart,
				 g_szGSWeb_AppExtention[GSWNAMES_INDEX]);
      if (pszAppExtension)
	pszfoundExtension=g_szGSWeb_AppExtention[GSWNAMES_INDEX];
      else
	{
	  pszAppExtension=strcasestr(pszStart,
				     g_szGSWeb_AppExtention[WONAMES_INDEX]);
	  if (pszAppExtension)
	    pszfoundExtension=g_szGSWeb_AppExtention[WONAMES_INDEX];
	};
      if (pszAppExtension)
	{
	  if (pszQueryStringMark && pszQueryStringMark<=pszAppExtension)
	    {
	      pszAppExtension=NULL;
	      pszStop=pszURLEnd;
	      pszNext=pszStop;
	    }
	  else
	    {
	      pszStop=pszAppExtension;
	      pszNext=pszStop+strlen(pszfoundExtension);
	    };
	}
      else
	{
	  pszStop=strchr(pszStart,'/');
	  if (pszStop && pszQueryStringMark && pszQueryStringMark<=pszStop)
	    pszStop=pszQueryStringMark-1;
	  if (pszStop)
	    pszNext=pszStop+1;
	  else
	    {
	      pszStop=pszTmpStop;
	      pszNext=NULL;
	    };
	};
      pURLCAppName->pszStart = pszStart;
      pURLCAppName->iLength = pszStop-pszStart;
      pURLCAppName->iLength = max(pURLCAppName->iLength,0);
      // Drop trailing slashes
      while(pURLCAppName->iLength && 
	    pURLCAppName->pszStart[pURLCAppName->iLength-1]== '/')
	pURLCAppName->iLength--;
      pURLCAppName->iLength = max(pURLCAppName->iLength,0);
      
      // Get Instance Number
      pszStart = pszNext;
      if (!pszStart)
	{
	  pURLCAppNum->pszStart="";
	  pURLCAppNum->iLength=0;
	}
      else
	{
	  // Skip slashes
	  while(*pszStart=='/')
	    pszStart++;

	  // Find 
	  for (pszS=pszStart;pszS<pszTmpStop && *pszS!='/';pszS++);
	  pszStop= pszS;
	  pszNext=(pszStop<pszTmpStop) ? pszStop+1 : pszStop;
	  pURLCAppNum->pszStart = pszStart;
	  pURLCAppNum->iLength = pszStop-pszStart;
	  pURLCAppNum->iLength = max(pURLCAppNum->iLength,0);
	  
	  // -1 case ?
	  if (!(pURLCAppNum->iLength==2
		&& pURLCAppNum->pszStart[0]=='-'
		&& pURLCAppNum->pszStart[1]=='1'))
	    {
	      // Test if alldigits
	      for (pszS=pszStart;pszS<pszStop && isdigit(*pszS);pszS++);
	      
	      if (pszS!=pszStop)
		{
		  // not all digits, so it's the request handler key !
		  pURLCReqHandlerKey->pszStart = pURLCAppNum->pszStart;
		  pURLCReqHandlerKey->iLength = pURLCAppNum->iLength;
		  pURLCReqHandlerKey->iLength =
		    max(pURLCReqHandlerKey->iLength,0);
		  pURLCAppNum->pszStart="";
		  pURLCAppNum->iLength=0;
		}
	      else
		{
		  pszStart=pszNext;
		  // Skip slashes
		  while(*pszStart=='/')
		    pszStart++;
		  
		  for (pszS=pszStart;pszS<pszTmpStop && *pszS!='/';pszS++);
		  pszStop = pszS;
		  pURLCReqHandlerKey->pszStart = pszStart;
		  pURLCReqHandlerKey->iLength = pszStop-pszStart;
		  pURLCReqHandlerKey->iLength =
		    max(pURLCReqHandlerKey->iLength,0);
		  pszNext=(pszStop<pszTmpStop) ? pszStop+1 : pszStop;
		};
	    };
	  // Get Request Handler Path
	  pszStart = pszNext;
	  for (pszS=pszStart;pszS<pszTmpStop;pszS++);
	  pszStop = pszS;
	  pURLCReqHandlerPath->pszStart = pszStart;
	  pURLCReqHandlerPath->iLength = pszStop-pszStart;
	  pURLCReqHandlerPath->iLength = max(pURLCReqHandlerPath->iLength,0);
	  pszNext=(pszStop<pszTmpStop) ? pszStop+1 : pszStop;
	  pszStart=pszNext;
	};
      // Query String
      if (!pszStart)
	pszStart=pszTmpStop;
      pURLCQueryString->pszStart = pszStart;
      pURLCQueryString->iLength = pszURLEnd - pszStart;
      pURLCQueryString->iLength = max(pURLCQueryString->iLength,0);
    };
  if (!pURLCPrefix->pszStart || pURLCPrefix->iLength<=0)
    {
      eError=GSWURLError_InvalidPrefix;
      GSWLog(GSW_ERROR,p_pLogServerData,"ParseURL GSWURLError_InvalidPrefix");
    }
  else
    {
      GSWDebugLog(p_pLogServerData,
                  "pURLCPrefix=%.*s",
                  pURLCPrefix->iLength,pURLCPrefix->pszStart);
      if (!pURLCAppName->pszStart || pURLCAppName->iLength<=0)
	{
	  eError=GSWURLError_InvalidAppName;
	  GSWLog(GSW_ERROR,p_pLogServerData,
		 "ParseURL GSWURLError_InvalidAppName");
	}
      else
	{
	  GSWDebugLog(p_pLogServerData,
		 "pURLCAppName=%.*s",
		 pURLCAppName->iLength,pURLCAppName->pszStart);
	  if (!pURLCAppNum->pszStart)
	    {
	      eError=GSWURLError_InvalidAppNumber;
	      GSWLog(GSW_ERROR,p_pLogServerData,
		     "ParseURL GSWURLError_InvalidAppNumber");
	    }
	  else
	    {
	      GSWDebugLog(p_pLogServerData,
		     "pURLCAppNum=%.*s",
		     pURLCAppNum->iLength,pURLCAppNum->pszStart);
	      if ((!pURLCReqHandlerKey->pszStart ||
		   pURLCReqHandlerKey->iLength<=0)
		  && pURLCReqHandlerPath->iLength>0)
		{
		  eError=GSWURLError_InvalidRequestHandlerKey;
		  GSWLog(GSW_ERROR,p_pLogServerData,
			 "ParseURL GSWURLError_InvalidRequestHandlerKey");
		}
	      else
		{
		  GSWDebugLog(p_pLogServerData,
			 "pURLCReqHandlerPath=%.*s",
			 pURLCReqHandlerPath->iLength,
			 pURLCReqHandlerPath->pszStart);
		  /*
		    if (!pURLCReqHandlerPath->pszStart ||
			pURLCReqHandlerPath->iLength<=0)
		      eError=GSWURLError_InvalidRequestHandlerPath;
		    else if (!pURLCQueryString->pszStart ||
			     pURLCQueryString->iLength<=0)
		      eError=GSWURLError_InvalidQueryString;
		    */
		};
	    };
	};
    };
  GSWDebugLog(p_pLogServerData,"End ParseURL eError=%d",eError);
  return eError;
};

//--------------------------------------------------------------------
void
GSWComposeURL(char             *p_pszURL,
	      GSWURLComponents *p_pURLComponents,
	      void             *p_pLogServerData)
{
  GSWURLComponent *pURLCPrefix=&p_pURLComponents->stPrefix;
  GSWURLComponent *pURLCAppName=&p_pURLComponents->stAppName;
  GSWURLComponent *pURLCAppNum=&p_pURLComponents->stAppNumber;
  GSWURLComponent *pURLCReqHandlerKey=&p_pURLComponents->stRequestHandlerKey;
  GSWURLComponent *pURLCReqHandlerPath=&p_pURLComponents->stRequestHandlerPath;
  GSWURLComponent *pURLCQueryString=&p_pURLComponents->stQueryString;
  
  strncpy(p_pszURL,pURLCPrefix->pszStart, pURLCPrefix->iLength);
  p_pszURL+=pURLCPrefix->iLength;

  *p_pszURL++='/';
  strncpy(p_pszURL, pURLCAppName->pszStart, pURLCAppName->iLength);
  p_pszURL+= pURLCAppName->iLength;
  strcpy(p_pszURL,g_szGSWeb_AppExtention[GSWNAMES_INDEX]);
  p_pszURL+=strlen(g_szGSWeb_AppExtention[GSWNAMES_INDEX]);

  if (pURLCAppNum->iLength>0)
    {
      *p_pszURL++='/';
      strncpy(p_pszURL,pURLCAppNum->pszStart,pURLCAppNum->iLength);
      p_pszURL+= pURLCAppNum->iLength;
    };

  if (pURLCReqHandlerKey->iLength>0)
    {
      *p_pszURL++='/';
      strncpy(p_pszURL, pURLCReqHandlerKey->pszStart,
	      pURLCReqHandlerKey->iLength);
      p_pszURL+= pURLCReqHandlerKey->iLength;
    };

    if (pURLCReqHandlerPath->iLength>0)
      {
        *p_pszURL++='/';
        strncpy(p_pszURL, pURLCReqHandlerPath->pszStart,
		pURLCReqHandlerPath->iLength);
        p_pszURL+= pURLCReqHandlerPath->iLength;
      };

    if (pURLCQueryString->iLength>0)
      {
        *p_pszURL++='?';
        strncpy(p_pszURL,pURLCQueryString->pszStart,
		pURLCQueryString->iLength);
        p_pszURL+= pURLCQueryString->iLength;
      };
    *p_pszURL=0;
};

//--------------------------------------------------------------------
int
GSWComposeURLLen(GSWURLComponents *p_pURLComponents,
		 void             *p_pLogServerData)
{
  int iLength=0;
  GSWURLComponent *pURLCPrefix=&p_pURLComponents->stPrefix;
  GSWURLComponent *pURLCAppName=&p_pURLComponents->stAppName;
  GSWURLComponent *pURLCAppNum=&p_pURLComponents->stAppNumber;
  GSWURLComponent *pURLCReqHandlerKey=&p_pURLComponents->stRequestHandlerKey;
  GSWURLComponent *pURLCReqHandlerPath=&p_pURLComponents->stRequestHandlerPath;
  GSWURLComponent *pURLCQueryString=&p_pURLComponents->stQueryString;
  
  iLength+=pURLCPrefix->iLength;
  iLength+=1+pURLCAppName->iLength;
  iLength+=strlen(g_szGSWeb_AppExtention[GSWNAMES_INDEX]);
  if (pURLCAppNum->iLength>0)
    iLength+= 1+pURLCAppNum->iLength;
  if (pURLCReqHandlerKey->iLength>0)
    iLength+=1+pURLCReqHandlerKey->iLength;
  if (pURLCReqHandlerPath->iLength>0)
    iLength+= 1+pURLCReqHandlerPath->iLength;
  if (pURLCQueryString->iLength>0)
    iLength+=1+pURLCQueryString->iLength;
  return iLength;
};

//--------------------------------------------------------------------
CONST char *szGSWURLErrorMessage[]=
{
  "",					//GSWURLError_OK
  "Invalid prefix in URL",		//GSWURLError_InvalidPrefix
  "Invalid version in URL",		//GSWURLError_InvalidVersion
  "Invalid application name",		//GSWURLError_InvalidAppName
  "Invalid application number in URL",	//GSWURLError_InvalidAppNumber,
  "Invalid request handler key in URL",	//GSWURLError_InvalidRequestHandlerKey,
  "Invalid request handler path in URL",//GSWURLError_InvalidRequestHandlerPath,
  "Invalid application host name in URL",//GSWURLError_InvalidAppHost,
  "Invalid page name in URL",		//GSWURLError_InvalidPageName,
  "Invalid session ID in URL",		//GSWURLError_InvalidSessionID,
  "Invalid context ID in URL",		//GSWURLError_InvalidContextID,
  "Invalid sender ID in URL",		//GSWURLError_InvalidSenderID,
  "Invalid query string in URL",	//GSWURLError_InvalidQueryString,
  "Invalid suffix in URL"		//GSWURLError_InvalidSuffix
};

CONST char *
GSWURLErrorMessage(GSWURLError p_eError,
		   void       *p_pLogServerData)
{
  if (p_eError>=0 &&
      p_eError<sizeof(szGSWURLErrorMessage)/sizeof(szGSWURLErrorMessage[0]))
    return szGSWURLErrorMessage[p_eError];
  else
    return "";
};
