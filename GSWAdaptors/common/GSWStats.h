/* GSWStats.h - GSWeb: GSWeb Statistics
   Copyright (C) 2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
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

#ifndef _GSWStats_h__
#define _GSWStats_h__


#ifdef __cplusplus
extern "C" {
#endif // __cplusplus



typedef struct _GSWTimeStats
{
  char    *_pszRequestedAppName;	// App Name relative to Prefix
  int     _iRequestedAppInstance;	// App Instance
  char    *_pszFinalAppName;	// App Name relative to Prefix
  int     _iFinalAppInstance;	// App Instance
  char    *_pszHost;
  int     _iPort;
  GSWTime _requestTS;
  GSWTime _beginHandleRequestTS;
  GSWTime _beginHandleAppRequestTS;
  GSWTime _beginSearchAppInstanceTS;
  GSWTime _endSearchAppInstanceTS;
  GSWTime _tryContactingAppInstanceTS;
  int _tryContactingAppInstanceCount;
  GSWTime _beginAppRequestTS;
  GSWTime _prepareToSendRequestTS;
  GSWTime _beginSendRequestTS;
  GSWTime _endSendRequestTS;
  char* _pszApplicationStats;
  char* _pszRecalculedApplicationStats;
  GSWTime _beginGetResponseTS;
  GSWTime _endGetResponseReceiveFirstLineTS;
  GSWTime _endGetResponseReceiveLinesTS;
  GSWTime _endGetResponseTS;
  GSWTime _endAppRequestTS;
  GSWTime _endHandleAppRequestTS;
  GSWTime _prepareSendResponseTS;
  GSWTime _beginSendResponseTS;
  GSWTime _endSendResponseTS;
  GSWTime _endHandleRequestTS;
  unsigned int _responseLength;
  unsigned int _responseStatus;
} GSWTimeStats;

// caller should free the returned string
char* GSWStats_formatStats(GSWTimeStats *p_pStats,
                           const char*  p_pszPrefix,
                           void         *p_pLogServerData);

void GSWStats_logStats(GSWTimeStats *p_pStats,
                       void         *p_pLogServerData);

void GSWStats_freeVars(GSWTimeStats* p_pStats);

void GSWStats_setApplicationStats(GSWTimeStats* p_pStats,
                                  const char* applicationStats,
                                  void         *p_pLogServerData);

#ifdef __cplusplus
}
#endif // __cplusplus


#endif // _GSWStats_h__
