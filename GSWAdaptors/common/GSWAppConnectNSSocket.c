/* GSWAppConnectNSSocket.c - GSWeb: Adaptors: App Connection by Netscape Sockets
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
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>
#include <sys/socket.h>
#include <errno.h>

#include "config.h"
#include "GSWUtil.h"
#include "GSWDict.h"
#include "GSWURLUtil.h"
//#include "GSWAppRequest.h"
#include "GSWAppRequestStruct.h"
#include "GSWAppConnect.h"

typedef SYS_NETFD AppConnectNSSocketHandle;

AppConnectHandle
GSWApp_Open(GSWAppRequest *p_pAppRequest,
	    void          *p_pLogServerData)
{
  AppConnectHandle handle=NULL;
  if (!p_pAppRequest)
    {
    }
  else
    {
      struct hostent *pHost=hl_find(p_pAppRequest->pszHost);
      if (!pHost)
	{
	  GSWLog(GSW_ERROR, p_pLogServerData,
		 "gethostbyname(%s) returns no host",
		 p_pAppRequest->pszHost);
	}
      else if (pHost->h_addrtype!=AF_INET)
	{
	  GSWLog(GSW_ERROR, p_pLogServerData, "Host %s has bad address type",
		 p_pAppRequest->pszHost);
	}
      else
	{
	  AppConnectNSSocketHandle nshandle=NULL;
	  struct sockaddr_in sin;
	  memset(&sin,0,sizeof(sin));
	  sin.sin_family = pHost->h_addrtype;
	  sin.sin_port = htons(p_pAppRequest->iPort);
	  memcpy(&sin.sin_addr, pHost->h_addr_list[0] , pHost->h_length);

	  GSWLog(GSW_INFO, p_pLogServerData, "Try contacting %s on port %d...",
		 p_pAppRequest->pszHost,
		 p_pAppRequest->iPort);
	  nshandle = net_socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);	
	  if (nshandle<0)
	    {
	      GSWLog(GSW_ERROR, p_pLogServerData,
		     "Can't Create socket to %s:%d. Error=%d (%s)",
		     p_pAppRequest->pszHost,
		     p_pAppRequest->iPort,
		     errno,
		     strerror(errno));
	    }
	  else
	    {
	      if (net_connect(nshandle,(struct sockaddr *)&sin,sizeof(sin))<0)
		{
		  GSWLog(GSW_ERROR, p_pLogServerData,
			 "Can't connect to %s:%d. Error=%d (%s)",
			 p_pAppRequest->pszHost,
			 p_pAppRequest->iPort,
			 errno,
			 strerror(errno));
		  net_close(nshandle);
		};
	    };
	  handle=(AppConnectHandle)nshandle;
	};
    };
  return handle;
};

void
GSWApp_Close(AppConnectHandle p_handle,
	     void            *p_pLogServerData)
{
  if (p_handle)
    {
      AppConnectNSSocketHandle handle=(AppConnectNSSocketHandle)p_handle;
      if (handle && handle>(AppConnectNSSocketHandle)1)
	net_close(handle);
    };
};

int
GSWApp_SendLine(AppConnectHandle p_handle,
		CONST char      *p_pszBuffer,
		void            *p_pLogServerData)
{
  int iRetValue=-1;
  if (p_handle)
    iRetValue=sendbytes(p_handle,p_pszBuffer,strlen(p_pszBuffer));
  return iRetValue;
}

int
GSWApp_SendBlock(AppConnectHandle p_handle,
		 CONST char      *p_pszBuffer,
		 int              p_iSize,
		 void            *p_pLogServerData)
{
  int iRetValue=-1;
  if (p_handle)
    {
      AppConnectNSSocketHandle handle=(AppConnectNSSocketHandle)p_handle;
      int iSent=0;
      int iRemainingSize = p_iSize;	
      while (iRemainingSize>0 && iSent>=0)
	{
	  iSent=net_write(handle,(char *)p_pszBuffer,iRemainingSize);
	  if (iSent<0)
	    GSWLog(GSW_ERROR, p_pLogServerData, 
		   "send failed. Error=%d (%s)",
		   errno,
		   strerror(errno));
	  else
	    {
	      p_pszBuffer+=iSent;
	      iRemainingSize-=iSent;
	    };
	};
      iRetValue=(iRemainingSize>0) ? -1 : 0;
    };
  return iRetValue;
}

int
GSWApp_ReceiveLine(AppConnectHandle p_handle,
		   char            *p_pszBuffer,
		   int              p_iBufferSize,
		   void            *p_pLogServerData)
{
  int iRetValue=-1;
  if (p_handle)
    {
      AppConnectNSSocketHandle handle=(AppConnectNSSocketHandle)p_handle;
      char c=0;
      int iReaden=0;
      int i = 0;
      BOOL fOk=TRUE;
      while (c!='\n' && i<p_iBufferSize-1 && fOk)
	{
	  iReaden=net_read(handle,&c,1,APP_CONNECT_TIMEOUT);
	  if (iReaden<1)
	    {
	      GSWLog(GSW_ERROR, p_pLogServerData,
		     "GSWApp_ReceiveLine. Error=%d (%s)",
		     errno,
		     strerror(errno));
	      iRetValue=0; //??
	      fOk=FALSE;
	    }
	  else
	    p_pszBuffer[i++] = c;
	};
      if (i>0)
	{
	  p_pszBuffer[i] = '\0';
	  iRetValue=DeleteTrailingCRNL(p_pszBuffer);
	}
      else
	iRetValue=0; //??
    };
  return iRetValue;
};

int
GSWApp_ReceiveBlock(AppConnectHandle p_handle,
		    char            *p_pszBuffer,
		    int              p_iBufferSize,
		    void            *p_pLogServerData) 
{
  int iRetValue=-1;
  if (p_handle)
    {
      AppConnectNSSocketHandle handle=(AppConnectNSSocketHandle)p_handle;
      int iReceived=0;
      int iRemainingSize=p_iBufferSize;
      BOOL fOk=TRUE;
      while (iRemainingSize>0 && fOk)
	{
	  iReceived=net_read(handle,p_pszBuffer,
			     iRemainingSize,APP_CONNECT_TIMEOUT);
	  if (iReceived<0)
	    {
	      GSWLog(GSW_ERROR, p_pLogServerData,
		     "GSWApp_ReceiveBlock failed. Error=%d %s",
		     errno,
		     strerror(errno));
	      fOk=FALSE;
	    }
	  else
	    {
	      p_pszBuffer+=iReceived;
	      iRemainingSize-=iReceived;
	    };
	};
      iRetValue=p_iBufferSize-iRemainingSize;
    };
  return iRetValue;
};
