/* GSWUtil.h - GSWeb: Adaptors: Util
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

#ifndef _GSWUtil_h__
#define _GSWUtil_h__

#ifndef BOOL
  typedef int BOOL;
#endif

#ifndef FALSE
#define FALSE 0
#define TRUE (!FALSE)
#endif

#ifdef __cplusplus
extern "C" {
#endif

#if	defined(Apache)
#include "httpd.h"
#include "http_log.h"
//#define APLOG_EMERG     LOG_EMERG     /* system is unusable */
//#define APLOG_ALERT     LOG_ALERT     /* action must be taken immediately */
#define GSW_CRITICAL 	APLOG_CRIT      /* critical conditions */
#define GSW_ERROR		APLOG_ERR		/* error conditions */
#define GSW_WARNING		APLOG_WARNING	/* warning conditions */
//#define APLOG_NOTICE    LOG_NOTICE    /* normal but significant condition */
#define	GSW_INFO	  	APLOG_INFO		/* informational */
#define	GSW_DEBUG		APLOG_DEBUG     /* debug-level messages */
#else
#define	GSW_DEBUG	0
#define	GSW_INFO    1
#define	GSW_WARNING 2
#define	GSW_ERROR  3
#define GSW_CRITICAL 4
#endif


#define max(x, y)               ((x) > (y) ? (x) : (y))
#define min(x, y)               ((x) < (y) ? (x) : (y))
  
void GSWLog(int p_iLevel,
#if	defined(Apache)
			server_rec* p_pLogServerData,
#else
			void* p_pLogServerData,
#endif
			CONST char *p_pszFormat, ...);

  void GSWLogSized(int p_iLevel,
#if	defined(Apache)
				   server_rec* p_pLogServerData,
#else
				   void* p_pLogServerData,
#endif
				   int p_iBufferSize,
				   CONST char *p_pszFormat, ...);

void GSWLogIntern(char* file,
			int line,
			char* fn,
			int p_iLevel,
#if	defined(Apache)
			server_rec* p_pLogServerData,
#else
			void* p_pLogServerData,
#endif
			CONST char *p_pszFormat, ...);
  

void GSWLogSizedIntern(char* file,
				 int line,
				 char* fn,
				 int p_iLevel,
#if	defined(Apache)
				 server_rec* p_pLogServerData,
#else
				 void* p_pLogServerData,
#endif
				 int p_iBufferSize,
				 CONST char *p_pszFormat, ...);

// return new len
int DeleteTrailingCRNL(char* p_pszString);
int DeleteTrailingSlash(char* p_pszString);
int DeleteTrailingSpaces(char* p_pszString);

int SafeStrlen(CONST char* p_pszString);
char* SafeStrdup(CONST char* p_pszString);
CONST char* strcasestr(CONST char* p_pszString,CONST char* p_pszSearchedString);


//#include <netdb.h>
typedef	struct hostent* PSTHostent;

PSTHostent GSWUtil_HostLookup(CONST char* p_pszHost,void* p_pLogServerData);
void GSWUtil_ClearHostCache();
PSTHostent GSWUtil_FindHost(CONST char* p_pszHost,void* p_pLogServerData);

#include "GSWDict.h"

void GSWLog_Init(GSWDict* p_pDict,int p_iLevel);


#ifdef __cplusplus
}
#endif // __cplusplus

#endif // _GSWUtil_h__
