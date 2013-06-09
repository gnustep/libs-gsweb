/* GSWUtil.c - GSWeb: Util
   Copyright (C) 1999, 2000, 2001, 2002, 2003 Free Software Foundation, Inc.
   
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

#include <httpd.h>
#include <http_log.h>

#include "config.h"
#include "GSWUtil.h"
#include "GSWDict.h"
#include "GSWString.h"
#include "GSWConfig.h"


// Hosts Cache
static GSWDict *g_pHostCache = NULL;


GSWTime GSWTime_now()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return GSWTime_makeTimeFromSecAndUSec(tv.tv_sec,tv.tv_usec);
}

time_t GSWTime_secPart(GSWTime t)
{
  return (time_t)(t/USEC_PER_SEC);
};

long GSWTime_usecPart(GSWTime t)
{
  return (time_t)(t%USEC_PER_SEC);
};

long GSWTime_msecPart(GSWTime t)
{
  return ((time_t)(t%USEC_PER_SEC))/1000;
};

// 2003/12/24 22:12:25.123
// date_str should be at least 24 characters (including \0)
char* GSWTime_format(char *date_str,GSWTime t)
{
  struct tm stTM;
  time_t timeSecPart=GSWTime_secPart(t);
  long timeMSecPart=GSWTime_msecPart(t);
  int real_year;

  localtime_r(&timeSecPart,&stTM);
  real_year = 1900 + stTM.tm_year;
  
  date_str[0] = real_year / 1000 + '0';
  date_str[1] = (real_year % 1000) / 100 + '0';
  date_str[2] = (real_year % 100) / 10 + '0';
  date_str[3] = real_year % 10 + '0';

  date_str[4] = '/';

  date_str[5] = (stTM.tm_mon+1) / 10 + '0';
  date_str[6] = (stTM.tm_mon+1) % 10 + '0';

  date_str[7] = '/';

  date_str[8] = stTM.tm_mday / 10 + '0';
  date_str[9] = stTM.tm_mday % 10 + '0';
  
  date_str[10] = ' ';
  date_str[11] = stTM.tm_hour / 10 + '0';
  date_str[12] = stTM.tm_hour % 10 + '0';
  date_str[13] = ':';
  date_str[14] = stTM.tm_min / 10 + '0';
  date_str[15] = stTM.tm_min % 10 + '0';
  date_str[16] = ':';
  date_str[17] = stTM.tm_sec / 10 + '0';
  date_str[18] = stTM.tm_sec % 10 + '0';
  date_str[19] = '.';
  date_str[20] = timeMSecPart / 100 + '0';
  date_str[21] = (timeMSecPart % 100) / 10 + '0';
  date_str[22] = timeMSecPart % 10 + '0';

  date_str[23] = 0;
  return date_str;
}

//--------------------------------------------------------------------
void
GSWLog_Init(GSWDict *p_pDict,
	    int      p_iLevel)
{
};

//--------------------------------------------------------------------
void
VGSWLogSizedIntern(char       *file,
		   int         line,
		   char       *fn,
		   int         p_iLevel,
		   server_rec *p_pLogServerData,
		   int         p_iBufferSize,
		   CONST char *p_pszFormat,
		   va_list     ap)
{
  if (p_iLevel!=GSW_DEBUG
      || GSWConfig_IsDebug())
    {
      FILE *pLog = NULL;
      char szBuffer[p_iBufferSize+512];
      
      szBuffer[0] = 0;
      errno = 0;//Because Apache use it in ap_log_error to display the message.
      vsnprintf(szBuffer, p_iBufferSize+511, p_pszFormat, ap);
      szBuffer[p_iBufferSize+511] = 0;
      
      ap_log_error(file,line,p_iLevel,
                   (server_rec *)p_pLogServerData,
                   "GSWeb[%lu]: %s",(unsigned long)getpid(),szBuffer);
    };
}

//--------------------------------------------------------------------
void
GSWLog(
       char       *file,
		   int         line,
		   int         p_iLevel,
       server_rec *p_pLogServerData,
       CONST char *p_pszFormat, ...)
{
  va_list ap;
  va_start(ap,p_pszFormat);
  VGSWLogSizedIntern(
		     file,
		     line,
		     NULL,
		     p_iLevel,
		     p_pLogServerData,
		     4096,
		     p_pszFormat,
		     ap);
  va_end(ap);
};

//--------------------------------------------------------------------
void
GSWLogSized(int p_iLevel,
	    server_rec *p_pLogServerData,
	    int p_iBufferSize,
	    CONST char *p_pszFormat, ...)
{
  va_list ap;
  va_start(ap,p_pszFormat);
  VGSWLogSizedIntern(NULL,
		     0,
		     NULL,
		     p_iLevel,
		     p_pLogServerData,
		     p_iBufferSize,
		     p_pszFormat,
		     ap);
  va_end(ap);
};

//--------------------------------------------------------------------
void
GSWLogIntern(char *file,
	     int   line,
	     char *fn,
	     int   p_iLevel,
	     server_rec *p_pLogServerData,
	     CONST char *p_pszFormat,...)
{
  va_list ap;
  va_start(ap,p_pszFormat);
  VGSWLogSizedIntern(file,
		     line,
		     fn,
		     p_iLevel,
		     p_pLogServerData,
		     4096,
		     p_pszFormat,
		     ap);
  va_end(ap);
};

//--------------------------------------------------------------------
void
GSWLogSizedIntern(char *file,
		  int   line,
		  char *fn,
		  int   p_iLevel,
		  server_rec *p_pLogServerData,
		  int p_iBufferSize,
		  CONST char *p_pszFormat,...)
{
  va_list ap;
  va_start(ap,p_pszFormat);
  VGSWLogSizedIntern(file,
		     line,
		     fn,
		     p_iLevel,
		     p_pLogServerData,
		     p_iBufferSize,
		     p_pszFormat,
		     ap);
  va_end(ap);
};


//--------------------------------------------------------------------
// return new len
int
DeleteTrailingCRNL(char *p_pszString) 
{
  int i=0;
  if (p_pszString)
    {
      i=strlen(p_pszString)-1;
      while (i>=0 && p_pszString[i] && 
	     (p_pszString[i]=='\r' || p_pszString[i]=='\n'))
	p_pszString[i--]=0;
      i++;
    };
  return i;
}

//--------------------------------------------------------------------
int
DeleteTrailingSlash(char *p_pszString)
{
  int i=0;
  if (p_pszString)
    {
      i=strlen(p_pszString)-1;
      while (i>=0 && p_pszString[i] && p_pszString[i]=='/')
	p_pszString[i--]=0;
      i++;
    };
  return i;
}

//--------------------------------------------------------------------
int
DeleteTrailingSpaces(char *p_pszString)
{
  int i=0;
  if (p_pszString)
    {
      i=strlen(p_pszString)-1;
      while (i>=0 && p_pszString[i] && p_pszString[i]==' ')
	p_pszString[i--]=0;
      i++;
    };
  return i;
}

//--------------------------------------------------------------------
int
SafeStrlen(CONST char *p_pszString)
{
  return (p_pszString ? strlen(p_pszString) : 0);
};

//--------------------------------------------------------------------
char *
SafeStrdup(CONST char *p_pszString)
{
  return (p_pszString ? strdup(p_pszString) : NULL);
};

char *
strcasestr(CONST char *p_pszString,CONST char *p_pszSearchedString)
{
  if (p_pszString && p_pszSearchedString)
    {
      int i=0;
      int iStringLen=strlen(p_pszString);
      int iSearchedStringLen=strlen(p_pszSearchedString);
      if (iStringLen>0 && iSearchedStringLen>0)
	{
	  char ch1stUpper=toupper(p_pszSearchedString[0]);
	  for(i=0;i<iStringLen-iSearchedStringLen+1;i++)
	    {
	      if (toupper(p_pszString[i])==ch1stUpper)
		{
		  BOOL fSame=TRUE;
		  int j=0;
		  for(j=1;j<iSearchedStringLen && fSame;j++)
		    fSame=toupper(p_pszString[i+j]) ==
		      toupper(p_pszSearchedString[j]);
		  if (fSame)
		    return p_pszString+i;
		};
	    };
	};
    };
  return NULL;
};

//--------------------------------------------------------------------
void
GSWUtil_ClearHostCache()
{
  if (g_pHostCache)
    {
      GSWDict_Free(g_pHostCache);
      g_pHostCache=NULL;
    };
};

//--------------------------------------------------------------------
PSTHostent
GSWUtil_FindHost(CONST char *p_pszHost,
		 void       *p_pLogServerData)
{
  PSTHostent pHost=NULL;
  if (!p_pszHost) 
    p_pszHost="localhost";

  pHost = (g_pHostCache) ?
    (PSTHostent)GSWDict_ValueForKey(g_pHostCache,p_pszHost) : NULL;
  if (!pHost)
    {
      pHost = GSWUtil_HostLookup(p_pszHost,p_pLogServerData);
      if (pHost)
	{
	  if (!g_pHostCache)
	    g_pHostCache = GSWDict_New(32);
	  GSWDict_Add(g_pHostCache,p_pszHost,pHost,TRUE);
	  GSWDebugLog(p_pLogServerData,"Caching hostent for %s",p_pszHost);
	};
    };
  return pHost;
};


#define ROUND_UP(n, m)  (((unsigned)(n)+(m)-1)&~((m)-1))
#define	BUFLEN			4096


//--------------------------------------------------------------------
CONST char *
hstrerror(int herr)
{
  if (herr == -1)				// see errno 
    return strerror(errno);
  else if (herr == HOST_NOT_FOUND)
    return "Host not found";
  else if (herr == TRY_AGAIN)
    return "Try again";				// ? 
  else if (herr == NO_RECOVERY)
    return "Non recoverable error";
  else if (herr == NO_DATA)
    return "No data";
  else if (herr == NO_ADDRESS)
    return "No address";			// same as no data
  else if (herr == NETDB_SUCCESS)		
    return "No error";				// Gag !
  else
    return "unknown error";
}

//--------------------------------------------------------------------
static PSTHostent
GSWUtil_CopyHostent(PSTHostent p_pHost)
{
  int i = 0, alias_index = 0;

  while (p_pHost->h_aliases[alias_index] != NULL)
    {
      ++alias_index;
    }
  struct hostent *pNewHost = (struct hostent*) malloc (sizeof(struct hostent));
  bzero(pNewHost, sizeof(struct hostent));
  pNewHost->h_name = (char *) strdup(p_pHost->h_name);
  pNewHost->h_aliases = (char **) malloc ((alias_index + 1) * sizeof(char *));
  if (alias_index)
    {
      for (i=0; i<alias_index; i++) 
        {
          pNewHost->h_aliases[i] = (char *) strdup(p_pHost->h_aliases[i]);
        }
    }
  else
    {
      pNewHost->h_aliases[0] = NULL;
    }
  pNewHost->h_aliases[alias_index] = 0;
  pNewHost->h_addrtype = AF_INET;
  pNewHost->h_length = sizeof(struct in_addr);
  pNewHost->h_addr_list = (char **) malloc (2 * sizeof(char *));
  pNewHost->h_addr_list[0] = (char *) malloc(sizeof(struct in_addr));
  memset(pNewHost->h_addr_list[0], 0, sizeof(struct in_addr));
  memcpy(pNewHost->h_addr_list[0], p_pHost->h_addr_list[0], sizeof(struct in_addr));
  pNewHost->h_addr_list[1] = 0;
  return pNewHost;
};

//--------------------------------------------------------------------
PSTHostent
GSWUtil_HostLookup(CONST char *p_pszHost,
		   void       *p_pLogServerData)
{
  PSTHostent pHost=NULL;
  struct in_addr hostaddr;
  struct hostent stTmpHost;
  int error=0;

  if (!p_pszHost) 
    p_pszHost="localhost";

  if (isdigit(*p_pszHost)) 
    hostaddr.s_addr=inet_addr(p_pszHost);
	
  pHost = &stTmpHost;
  if (isdigit(*p_pszHost))
    {
      in_addr_t address = inet_addr(p_pszHost);
      pHost = gethostbyaddr(&address, sizeof(in_addr_t),
			    AF_INET);
      error = (pHost) ? 0 : h_errno;
    }
  else
    {
      pHost = gethostbyname(p_pszHost);
      error = (pHost) ? 0 : h_errno;
    }

  if (!pHost)
    {
      GSWLog(__FILE__, __LINE__,GSW_ERROR,p_pLogServerData,
	     "gethostbyname(%s) returns no host: %s",
	     p_pszHost,
	     hstrerror(error));
    }
  else if (pHost->h_addrtype != AF_INET)
    {
      GSWLog(__FILE__, __LINE__,GSW_ERROR,p_pLogServerData,"Wrong address type in hostptr for host %s",p_pszHost);
    };
  if (pHost)
    pHost=GSWUtil_CopyHostent(pHost);
  return pHost;
};

// buffer should be at leat 20 characters
// [dollar]Revision: 1.12 [dollar] ==> 1.12
char* RevisionStringToRevisionValue(char* buffer,const char* revisionString)
{
  char* dstBuffer=buffer;
  while(*revisionString && *revisionString!=':')
    revisionString++;
  if (*revisionString==':')
    {
      while(*revisionString && !isdigit(*revisionString))
        revisionString++;
      if (isdigit(*revisionString))
        {
          while(*revisionString && (isdigit(*revisionString) || *revisionString=='.') && (dstBuffer-buffer)<20)
            {
              *dstBuffer=*revisionString;
              revisionString++;
              dstBuffer++;
            };
        };
    };
  *dstBuffer=0;
  return buffer;
};


#ifndef __USE_GNU
char* gsw_strndup(const char *s, size_t len)
{
  char *dups=NULL;

  // search end of string
  const char *end = memchr(s, '\0', len);
  
  if (end)
     len=end-s;
  
  dups = malloc(len+1); // +1 for \0

  if (len>0)
        memcpy(dups,s,len);

  dups[len]='\0';
  return dups;
}
#endif

