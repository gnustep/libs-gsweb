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

#if defined(Netscape)
#include <frame/log.h>
#elif defined(Apache)
#include <httpd.h>
#include <http_log.h>
#endif

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
#if	defined(Apache)
		   server_rec *p_pLogServerData,
#else
		   void       *p_pLogServerData,
#endif
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
      
#if	defined(Netscape)
      log_error(0,"GSWeb: ",NULL,NULL,szBuffer);
#endif
      
#if defined(Apache)
#if defined(Apache2)
      ap_log_error(APLOG_MARK,p_iLevel,0,
                   (server_rec *)p_pLogServerData,
                   "GSWeb[%lu]: %s",(unsigned long)getpid(),szBuffer);
#else
      ap_log_error(APLOG_MARK,p_iLevel,
                   (server_rec *)p_pLogServerData,
                   "GSWeb[%lu]: %s",(unsigned long)getpid(),szBuffer);
#endif
#endif 
    };
}

//--------------------------------------------------------------------
void
GSWLog(int         p_iLevel,
#if	defined(Apache)
       server_rec *p_pLogServerData,
#else
       void       *p_pLogServerData,
#endif
       CONST char *p_pszFormat, ...)
{
  va_list ap;
  va_start(ap,p_pszFormat);
  VGSWLogSizedIntern(NULL,
		     0,
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
#if	defined(Apache)
	    server_rec *p_pLogServerData,
#else
	    void       *p_pLogServerData,
#endif
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
#if	defined(Apache)
	     server_rec *p_pLogServerData,
#else
	     void       *p_pLogServerData,
#endif
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
#if	defined(Apache)
		  server_rec *p_pLogServerData,
#else
		  void *p_pLogServerData,
#endif
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

#if defined(HAS_REENTRANT_GETHOSTENT) && !defined(_REENTRANT)
#define _REENTRANT     /* needs to be defined so proper structs get included */
#endif

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


#if	defined(NEEDS_HSTRERR)
#ifndef	NETDB_SUCCESS
#define	NETDB_SUCCESS 0
#endif

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
#endif

//--------------------------------------------------------------------
static PSTHostent
GSWUtil_CopyHostent(PSTHostent p_pHost)
{
  PSTHostent pNewHost=NULL;
  int    iSize=(ROUND_UP(sizeof(struct hostent),
			 sizeof(void *)))+strlen(p_pHost->h_name)+1;
  int    iAliasNb=0;
  int    iAddressesNb = 0;
  char **ppszAliasOrAddress=NULL;
  char **ppszNewHostAliasOrAddress=NULL;
  void  *pTmp=NULL;
  
  // Aliases
  for (ppszAliasOrAddress=p_pHost->h_aliases;
       ppszAliasOrAddress && *ppszAliasOrAddress;
       ppszAliasOrAddress++)
    {
      iSize+=strlen(*ppszAliasOrAddress)+1;
      iAliasNb++;
    };

  // Aliases Pointers Null Terminated List
  iSize=ROUND_UP(iSize,sizeof(char *));
  iSize+=(iAliasNb+1)*sizeof(char *);
	
  for (ppszAliasOrAddress=p_pHost->h_addr_list;
       ppszAliasOrAddress && *ppszAliasOrAddress;
       ppszAliasOrAddress++)
    iAddressesNb++;
  
  iSize+=iAddressesNb*(sizeof(char *)+p_pHost->h_length+1);
  
  pNewHost=malloc(ROUND_UP(iSize,sizeof(char *)));
  pTmp=pNewHost;
  pNewHost->h_addrtype = p_pHost->h_addrtype;
  pNewHost->h_length = p_pHost->h_length;
		
  pTmp+=ROUND_UP(sizeof(struct hostent),sizeof(void *));
  pNewHost->h_aliases = (char **)pTmp;
  pTmp+=(iAliasNb+1)*sizeof(char *);
  pNewHost->h_addr_list = (char **)pTmp;
  pTmp+=(iAddressesNb+1)*sizeof(char *);
	
  pNewHost->h_name = pTmp;
  strcpy(pNewHost->h_name,p_pHost->h_name);
  pTmp+=strlen(pNewHost->h_name)+1;

  // Copy Aliases
  for (ppszAliasOrAddress=p_pHost->h_aliases,
	 ppszNewHostAliasOrAddress=pNewHost->h_aliases;
       ppszAliasOrAddress && *ppszAliasOrAddress;
       ppszAliasOrAddress++,ppszNewHostAliasOrAddress++)
    {
      *ppszNewHostAliasOrAddress = (char *)pTmp;
      strcpy((char *)pTmp,*ppszAliasOrAddress);
      pTmp+=strlen(*ppszAliasOrAddress) + 1;
    };
  *ppszNewHostAliasOrAddress=NULL;
  
  pTmp=(void *)ROUND_UP(pTmp,pNewHost->h_length);
  for (ppszAliasOrAddress=p_pHost->h_addr_list,
	 ppszNewHostAliasOrAddress=pNewHost->h_addr_list;
       ppszAliasOrAddress && *ppszAliasOrAddress;
       ppszAliasOrAddress++,ppszNewHostAliasOrAddress++)
    {
      *ppszNewHostAliasOrAddress=(char *)pTmp;
      memcpy(*ppszNewHostAliasOrAddress,*ppszAliasOrAddress,
	     pNewHost->h_length);
      pTmp+=pNewHost->h_length;
    };
  *ppszNewHostAliasOrAddress=NULL;
  return pNewHost;
};

//--------------------------------------------------------------------
PSTHostent
GSWUtil_HostLookup(CONST char *p_pszHost,
		   void       *p_pLogServerData)
{
  PSTHostent pHost=NULL;
  struct in_addr hostaddr;
  int error=0;

#if	defined(HAS_REENTRANT_GETHOSTENT)
  struct hostent stTmpHost;
  char szBuffer[BUFLEN];
  
  pHost = &stTmpHost;		/* point to struct on the stack */
  memset(pHost,0,sizeof(struct hostent));
  memset(szBuffer,0,sizeof(szBuffer));
#endif	
  
  if (!p_pszHost) 
    p_pszHost="localhost";

  if (isdigit(*p_pszHost)) 
    hostaddr.s_addr=inet_addr(p_pszHost);
	
#if	defined(HAS_REENTRANT_GETHOSTENT)
  if (isdigit(*p_pszHost))
    {
#if	defined(SOLARIS)
      pHost = gethostbyaddr_r((char *)&hostaddr.s_addr,
			      sizeof(hostaddr.s_addr),
			      AF_INET,
			      pHost,
			      szBuffer,
			      BUFLEN, &error);
#else	// !SOLARIS
      if (gethostbyaddr_r((char *)&hostaddr.s_addr, 
			  sizeof(hostaddr.s_addr),
			  AF_INET,
			  &stTmpHost,
			  szBuffer) == 0)
	{
	  pHost = &stTmpHost;
	  error = 0;
	}
      else
	{
	  pHost=NULL;
	  error = h_errno;
	};
#endif  // SOLARIS
    }
  else
    {
#if	defined(SOLARIS)
      pHost = gethostbyname_r(p_pszHost,
			      &stTmpHost,
			      szBuffer,
			      BUFLEN,
			      &error);
#else	// !SOLARIS
      pHost = (gethostbyname_r(p_pszHost,&stTmpHost,szBuffer)==0) ? 
	&stTmpHost : NULL;
      error = (pHost) ? 0 : h_errno;
#endif  // SOLARIS
    };
#else   // !HAS_REENTRANT_GETHOSTENT
  if (isdigit(*p_pszHost))
    {
      pHost = gethostbyaddr((char *)&hostaddr.s_addr, sizeof(hostaddr.s_addr),
			    AF_INET);
      error = (pHost) ? 0 : h_errno;
    }
  else
    {
      pHost = gethostbyname(p_pszHost);
      error = (pHost) ? 0 : h_errno;
    }
#endif  // HAS_REENTRANT_GETHOSTENT

  if (!pHost)
    {
      GSWLog(GSW_ERROR,p_pLogServerData,
	     "gethostbyname(%s) returns no host: %s",
	     p_pszHost,
	     hstrerror(error));
    }
  else if (pHost->h_addrtype != AF_INET)
    {
      GSWLog(GSW_ERROR,p_pLogServerData,"Wrong address type in hostptr for host %s",p_pszHost);
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

