/* GSWStats.c - GSWeb: Util
   Copyright (C) 2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Dec 2004
   
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
#include <stdarg.h>
#include <netdb.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "config.h"
#include "GSWLock.h"

#if defined(Netscape)
#include <frame/log.h>
#elif defined(Apache)
#include <httpd.h>
#include <http_log.h>
#endif

#include "config.h"
#include "GSWUtil.h"
#include "GSWStats.h"
#include "GSWDict.h"
#include "GSWString.h"
#include "GSWConfig.h"


//--------------------------------------------------------------------
// caller should free the returned string
char* GSWStats_formatStats(GSWTimeStats *p_pStats,
                           const char*  p_pszPrefix,
                           void         *p_pLogServerData)
{
  char buffer0[25]="";
  char* formattedString=NULL;
  GSWTime baseTS=0;
  GSWTime responseTransfert=0;

  GSWDebugLog(p_pLogServerData,"Start GSWStats_formatStats");

  baseTS=p_pStats->_requestTS;
  formattedString=malloc(2048+(p_pszPrefix ? strlen(p_pszPrefix) : 0));

  if (p_pStats->_pszApplicationStats && !p_pStats->_pszRecalculedApplicationStats)
    {
      int applicatonStatsLen=strlen(p_pStats->_pszApplicationStats);
      if (applicatonStatsLen>0)
        {
          char floatBuffer[20];
          double baseFloatSec=GSWTime_floatSec(p_pStats->_beginSendRequestTS-baseTS);
          char* p=p_pStats->_pszApplicationStats;
          char* resultStats=NULL;
          int i=0;
          p_pStats->_pszRecalculedApplicationStats=malloc(applicatonStatsLen+100);
          resultStats=p_pStats->_pszRecalculedApplicationStats;
          while(*p)
            {
              *resultStats++=*p;
              if (*p=='+')
                {
                  int aLen=0;
                  char* endPtr=NULL;
                  double val=strtof(++p,&endPtr);
                  val=baseFloatSec+val;
                  p=endPtr+1;
                  sprintf(floatBuffer,"%0.3f",val);
                  aLen=strlen(floatBuffer);
                  memcpy(resultStats,floatBuffer,aLen);
                  resultStats+=aLen;
                }
              else
                p++;
            };
          *resultStats++=' ';
          *resultStats++='\0';
        };
    };
  responseTransfert=(p_pStats->_endSendResponseTS ? 
                     (p_pStats->_endSendResponseTS-p_pStats->_beginSendResponseTS) : 0);

  sprintf(formattedString,
         "%srequestedApplication=%s requestedInstance=%d finalApplication=%s finalInstance=%d host=%s port=%d responseStatus=%u responseLength=%u requestDate=%s "
         "beginHandleRequest=+%0.3fs beginHandleAppRequest=+%0.3fs "
         "beginSearchAppInstance=+%0.3fs endSearchAppInstance=+%0.3fs searchAppInstance=%0.3fs "
         "tryContactingAppInstance=+%0.3fs tryContactingAppInstanceCount=%d tryContactingAppInstance=%0.3fs "
         "prepareToSendRequest=+%0.3fs beginSendRequest=+%0.3fs endSendRequest=+%0.3fs sendRequest=%0.3fs "
         "%s"
         "beginGetResponse=+%0.3fs endGetResponseReceiveFirstLine=+%0.3fs endGetResponseReceiveLines=+%0.3fs endGetResponse=+%0.3fs waitResponseFirstLine=%0.3fs getResponse=%0.3fs "
         "endAppRequest=+%0.3fs appRequest=%0.3fs "
         "endHandleAppRequest=+%0.3fs handleAppRequest=%0.3fs "
         "prepareSendResponse=+%0.3fs beginSendResponse=+%0.3fs endSendResponse=+%0.3fs sendResponse=%0.3fs responseTransfert=%0.3fs "
         "endHandleRequest=+%0.3fs handleRequest=%0.3fs "
         "totalTimeSpent=%0.3fs totalTimeSpentExceptResponseTransfert=%0.3fs",
         //Line 1
          (p_pszPrefix ? p_pszPrefix : ""),
          p_pStats->_pszRequestedAppName,
          p_pStats->_iRequestedAppInstance,	// App Instance
          p_pStats->_pszFinalAppName,	// App Name relative to Prefix
          p_pStats->_iFinalAppInstance,	// App Instance
          p_pStats->_pszHost,
          p_pStats->_iPort,
          p_pStats->_responseStatus,
          p_pStats->_responseLength,
          GSWTime_format(buffer0,p_pStats->_requestTS),
          //Line 2
          GSWTime_floatSec(p_pStats->_beginHandleRequestTS-baseTS),
          GSWTime_floatSec(p_pStats->_beginHandleAppRequestTS-baseTS),
          //Line 3
          GSWTime_floatSec(p_pStats->_beginSearchAppInstanceTS-baseTS),
          GSWTime_floatSec(p_pStats->_endSearchAppInstanceTS-baseTS),
          GSWTime_floatSec(p_pStats->_endSearchAppInstanceTS-p_pStats->_beginSearchAppInstanceTS),
          //Line 4
          GSWTime_floatSec(p_pStats->_tryContactingAppInstanceTS-baseTS),
          p_pStats->_tryContactingAppInstanceCount,
          GSWTime_floatSec(p_pStats->_prepareToSendRequestTS>0 ? (p_pStats->_prepareToSendRequestTS-p_pStats->_tryContactingAppInstanceTS) : 0),
          //Line 5
          GSWTime_floatSec(p_pStats->_prepareToSendRequestTS ? (p_pStats->_prepareToSendRequestTS-baseTS) : 0),
          GSWTime_floatSec(p_pStats->_beginSendRequestTS ? (p_pStats->_beginSendRequestTS-baseTS) : 0),
          GSWTime_floatSec(p_pStats->_endSendRequestTS ? (p_pStats->_endSendRequestTS-baseTS) : 0),
          GSWTime_floatSec(p_pStats->_endSendRequestTS ? (p_pStats->_endSendRequestTS-p_pStats->_beginSendRequestTS) : 0),
          //Line 6
          (p_pStats->_pszRecalculedApplicationStats ? p_pStats->_pszRecalculedApplicationStats : ""),
          //Line 7
          GSWTime_floatSec(p_pStats->_beginGetResponseTS ? (p_pStats->_beginGetResponseTS-baseTS) : 0),
          GSWTime_floatSec(p_pStats->_endGetResponseReceiveFirstLineTS ? (p_pStats->_endGetResponseReceiveFirstLineTS-baseTS) : 0),
          GSWTime_floatSec(p_pStats->_endGetResponseReceiveLinesTS ? (p_pStats->_endGetResponseReceiveLinesTS-baseTS) : 0),
          GSWTime_floatSec(p_pStats->_endGetResponseTS ? (p_pStats->_endGetResponseTS-baseTS) : 0),
          GSWTime_floatSec(p_pStats->_endGetResponseReceiveFirstLineTS ? (p_pStats->_endGetResponseReceiveFirstLineTS-p_pStats->_beginGetResponseTS) : 0),
          GSWTime_floatSec(p_pStats->_endGetResponseTS ? (p_pStats->_endGetResponseTS-p_pStats->_beginGetResponseTS) : 0),
          //Line 8
          GSWTime_floatSec(p_pStats->_endAppRequestTS ? (p_pStats->_endAppRequestTS-baseTS) : 0),
          GSWTime_floatSec(p_pStats->_endAppRequestTS ? (p_pStats->_endAppRequestTS-p_pStats->_beginAppRequestTS) : 0),
          //Line 9
          GSWTime_floatSec(p_pStats->_endHandleAppRequestTS-baseTS),
          GSWTime_floatSec(p_pStats->_endHandleAppRequestTS-p_pStats->_beginHandleAppRequestTS),
          //Line 10
          GSWTime_floatSec(p_pStats->_prepareSendResponseTS ? (p_pStats->_prepareSendResponseTS-baseTS) : 0),
          GSWTime_floatSec(p_pStats->_beginSendResponseTS ? (p_pStats->_beginSendResponseTS-baseTS) : 0),
          GSWTime_floatSec(p_pStats->_endSendResponseTS ? (p_pStats->_endSendResponseTS-baseTS) : 0),
          GSWTime_floatSec(p_pStats->_endSendResponseTS ? (p_pStats->_endSendResponseTS-p_pStats->_prepareSendResponseTS) : 0),
          GSWTime_floatSec(responseTransfert),
          //Line 11
          GSWTime_floatSec(p_pStats->_endHandleRequestTS ? (p_pStats->_endHandleRequestTS-baseTS) : 0),
          GSWTime_floatSec(p_pStats->_endHandleRequestTS ? (p_pStats->_endHandleRequestTS-p_pStats->_beginHandleRequestTS) : 0),
          //Line 12
          GSWTime_floatSec(p_pStats->_endHandleRequestTS ? (p_pStats->_endHandleRequestTS-baseTS) : 0),
          GSWTime_floatSec(p_pStats->_endHandleRequestTS ? (p_pStats->_endHandleRequestTS-baseTS-responseTransfert) : 0));
  
  GSWDebugLog(p_pLogServerData,"Stop GSWStats_formatStats");
  
  return formattedString;
};

//--------------------------------------------------------------------
void GSWStats_logStats(GSWTimeStats *p_pStats,
                       void         *p_pLogServerData)
{
  char* formattedStats=GSWStats_formatStats(p_pStats,NULL,p_pLogServerData);
  GSWLog(GSW_INFO,p_pLogServerData,"%s",formattedStats);
  if (formattedStats)
    free(formattedStats);
};

//--------------------------------------------------------------------
void GSWStats_freeVars(GSWTimeStats* p_pStats)
{
  if (p_pStats)
    {
      if (p_pStats->_pszRequestedAppName)
        {
          free(p_pStats->_pszRequestedAppName);
          p_pStats->_pszRequestedAppName=NULL;
        };
      if (p_pStats->_pszFinalAppName)
        {
          free(p_pStats->_pszFinalAppName);
          p_pStats->_pszFinalAppName=NULL;
        };
      if (p_pStats->_pszHost)
        {
          free(p_pStats->_pszHost);
          p_pStats->_pszHost=NULL;
        };
      if (p_pStats->_pszApplicationStats)
        {
          free(p_pStats->_pszApplicationStats);
          p_pStats->_pszApplicationStats=NULL;
        };
      if (p_pStats->_pszRecalculedApplicationStats)
        {
          free(p_pStats->_pszRecalculedApplicationStats);
          p_pStats->_pszRecalculedApplicationStats=NULL;
        };

    };
};

//--------------------------------------------------------------------
void GSWStats_setApplicationStats(GSWTimeStats* p_pStats,
                                  const char* applicationStats,
                                  void         *p_pLogServerData)
{
  GSWDebugLog(p_pLogServerData,"GSWStats_setApplicationStats: applicationStats=%s",applicationStats);

  if (p_pStats->_pszApplicationStats)
    {
      free(p_pStats->_pszApplicationStats);
    };
  p_pStats->_pszApplicationStats=strdup(applicationStats);
};
