/* GSWUtil.h - GSWeb: Adaptors: Util
   Copyright (C) 1999, 2000, 2003 Free Software Foundation, Inc.
   
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

//====================================================================
// Time Functions

typedef long long GSWTime; // usec since Epoch

#define USEC_PER_SEC	((GSWTime)1000000)
#define GSWTime_makeTimeFromSecAndUSec(sec,usec)	((GSWTime)(sec)*USEC_PER_SEC+(GSWTime)(usec))

GSWTime GSWTime_now();
char* GSWTime_format(char *date_str,GSWTime t); // yyyy/mm/dd hh:mm:ss.msec
time_t GSWTime_secPart(GSWTime t);
long GSWTime_usecPart(GSWTime t);
long GSWTime_msecPart(GSWTime t);

#define GSWTime_floatSec(t) ((double)(((double)GSWTime_secPart(t))+((double)GSWTime_usecPart(t))/USEC_PER_SEC))

#ifdef Apache
#define GSWTime_makeFromAPRTime(aprtime) ((GSWTime)(aprtime))
#endif
  
//====================================================================
// Asserts
#define GSWAssert(condition,p_pLogServerData,p_pszFormat, args...); \
	{ if (!(condition)) \
		{ \
                  GSWLog(GSW_CRITICAL,p_pLogServerData,"ARGHH"); \
                  char* format=malloc(strlen(p_pszFormat)+strlen(__FILE__)+101); \
  		  sprintf(format,"In %s (%d): %s",__FILE__,__LINE__,p_pszFormat); \
                  GSWLog(GSW_CRITICAL,p_pLogServerData,format,  ## args); \
		  free(format); \
                 }} while (0);

//====================================================================
// Log Functions
void GSWLog(int p_iLevel,
#if	defined(Apache)
	    server_rec *p_pLogServerData,
#else
	    void *p_pLogServerData,
#endif
	    CONST char *p_pszFormat, ...);

#define GSWDebugLog(p_pLogServerData,p_pszFormat, args...); \
			GSWLog(GSW_DEBUG,p_pLogServerData,p_pszFormat,  ## args);
#define GSWDebugLogCond(condition,p_pLogServerData,p_pszFormat, args...); \
			{ if ((condition)) GSWLog(GSW_DEBUG,p_pLogServerData,p_pszFormat,  ## args);};

void GSWLogSized(int p_iLevel,
#if	defined(Apache)
		   server_rec *p_pLogServerData,
#else
                   void *p_pLogServerData,
#endif
                   int p_iBufferSize,
                   CONST char *p_pszFormat, ...);

void GSWLogIntern(char       *file,
		  int         line,
		  char       *fn,
		  int         p_iLevel,
#if	defined(Apache)
		  server_rec *p_pLogServerData,
#else
		  void       *p_pLogServerData,
#endif
		  CONST char *p_pszFormat, ...);
  

void GSWLogSizedIntern(char       *file,
		       int         line,
		       char       *fn,
		       int         p_iLevel,
#if	defined(Apache)
		       server_rec *p_pLogServerData,
#else
		       void       *p_pLogServerData,
#endif
		       int         p_iBufferSize,
		       CONST char *p_pszFormat, ...);

//====================================================================
// Misc String Functions

// return new len
int DeleteTrailingCRNL(char *p_pszString);
int DeleteTrailingSlash(char *p_pszString);
int DeleteTrailingSpaces(char *p_pszString);

int SafeStrlen(CONST char *p_pszString);
char *SafeStrdup(CONST char *p_pszString);
char *strcasestr(CONST char *p_pszString, CONST char *p_pszSearchedString);

#ifdef __USE_GNU
#define gsw_strndup(a,b) strndup((a),(b))
#else
  extern char* gsw_strndup(const char *s, size_t len);
#endif

//====================================================================
// Host lookup Functions
//#include <netdb.h>
typedef	struct hostent *PSTHostent;

PSTHostent GSWUtil_HostLookup(CONST char *p_pszHost, void *p_pLogServerData);
void GSWUtil_ClearHostCache();
PSTHostent GSWUtil_FindHost(CONST char *p_pszHost, void *p_pLogServerData);

//====================================================================
#include "GSWDict.h"

void GSWLog_Init(GSWDict *p_pDict, int p_iLevel);

char* RevisionStringToRevisionValue(char* buffer,const char* revisionString);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // _GSWUtil_h__
