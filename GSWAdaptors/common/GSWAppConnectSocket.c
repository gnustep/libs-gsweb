/* GSWAppConnectSocket.c - GSWeb: Adaptors: App Connection by Socket
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
#include "GSWAppRequestStruct.h"
#include "GSWAppConnect.h"

//--------------------------------------------------------------------
typedef	struct _STAppConnectSocket
{
  int	iSocketDescr;
  FILE* pFileRead;
  FILE* pFileWrite;
} STAppConnectSocket;
typedef STAppConnectSocket* AppConnectSocketHandle;

//--------------------------------------------------------------------
AppConnectHandle GSWApp_Open(GSWAppRequest* p_pAppRequest,void* p_pLogServerData)
{
  AppConnectHandle handle=NULL;
  if (!p_pAppRequest)
	{
	  GSWLog(GSW_CRITICAL,p_pLogServerData,
				 "No AppRequest !");
	  //TODO
	}
  else
	{
	  PSTHostent pHost = GSWUtil_FindHost(p_pAppRequest->pszHost,p_pLogServerData);
	  if (!pHost)
		{
		  GSWLog(GSW_ERROR,p_pLogServerData,
				 "gethostbyname(%s) returns no host",
				 p_pAppRequest->pszHost);
		}
	  else
		{
		  int iSocketDescr = 0;
		  struct sockaddr_in sin;
		  memset(&sin,0,sizeof(sin));
		  sin.sin_family = pHost->h_addrtype;
		  sin.sin_port = htons(p_pAppRequest->iPort);
		  memcpy(&sin.sin_addr,pHost->h_addr_list[0],pHost->h_length);
		  GSWLog(GSW_INFO,
				 p_pLogServerData,
				 "Try contacting %s on port %d...",
				 p_pAppRequest->pszHost,
				 p_pAppRequest->iPort);
		  iSocketDescr=socket(pHost->h_addrtype,SOCK_STREAM, 0);
		  if (iSocketDescr<0)
			{
			  GSWLog(GSW_ERROR,
					 p_pLogServerData,
					 "Can't Create socket to %s:%d. Error=%d (%s)",
					 p_pAppRequest->pszHost,
					 p_pAppRequest->iPort,
					 errno,
					 strerror(errno));
			}
		  else
			{
			  if (connect(iSocketDescr,(struct sockaddr*)&sin,sizeof(sin))<0)
				{
				  GSWLog(GSW_ERROR,
						 p_pLogServerData,
						 "Can't connect to %s:%d. Error=%d (%s)",
						 p_pAppRequest->pszHost,
						 p_pAppRequest->iPort,
						 errno,
						 strerror(errno));
				  close(iSocketDescr);
				  iSocketDescr=0;
				}
			  else
				{
				  FILE* pFileRead=fdopen(iSocketDescr,"r");
				  if (!pFileRead)
					{
					  GSWLog(GSW_ERROR,
							 p_pLogServerData,
							 "Can't open for reading. Error=%d (%s)",
							 errno,
							 strerror(errno));
					  close(iSocketDescr);
					  iSocketDescr=0;
					}
				  else
					{
					  FILE* pFileWrite=fdopen(iSocketDescr,"w");
					  if (!pFileWrite)
						{
						  GSWLog(GSW_ERROR,
								 p_pLogServerData,
								 "Can't open for writing. Error=%d (%s)",
								 errno,
								 strerror(errno));
						  fclose(pFileRead);
						  pFileRead=NULL;
						  close(iSocketDescr);
						  iSocketDescr=0;
						}
					  else
						{
						  handle = calloc(1, sizeof(STAppConnectSocket));
						  ((AppConnectSocketHandle)handle)->iSocketDescr = iSocketDescr;
						  ((AppConnectSocketHandle)handle)->pFileRead = pFileRead;
						  ((AppConnectSocketHandle)handle)->pFileWrite = pFileWrite;
						};
					};
				};
			};
		};
	};
  return handle;
};

//--------------------------------------------------------------------
void GSWApp_Close(AppConnectHandle p_handle,void* p_pLogServerData)
{
/*
#ifdef	DEBUG
  GSWLog(GSW_ERROR,p_pLogServerData,"GSWApp_Close Start");
#endif
*/
  if (p_handle)
	{
	  AppConnectSocketHandle handle=(AppConnectSocketHandle)p_handle;
	  if (handle->iSocketDescr)
		{
		  close(handle->iSocketDescr);
		  fclose(handle->pFileRead);
		  fclose(handle->pFileWrite);
		};
	  free(handle);
	};
/*
#ifdef	DEBUG
  GSWLog(GSW_ERROR,p_pLogServerData,"GSWApp_Close Stop");
#endif
*/
};

//--------------------------------------------------------------------
int GSWApp_SendLine(AppConnectHandle p_handle, CONST char* p_pszBuffer,void* p_pLogServerData)
{
  int iRetValue=-1;
  if (p_handle)
	{
	  AppConnectSocketHandle handle=(AppConnectSocketHandle)p_handle;
	  if (fputs(p_pszBuffer,handle->pFileWrite)!=EOF)
		{
		  fflush(handle->pFileWrite);
		  iRetValue=0;
		}
	  else
		{
		  GSWLog(GSW_ERROR,
				 p_pLogServerData,
				 "GSWApp_SendLine failed. Error=%d (%s)",
				 errno,
				 strerror(errno));
		  iRetValue=-1;
		};
	};
  return iRetValue;
};


//--------------------------------------------------------------------
int GSWApp_SendBlock(AppConnectHandle p_handle,
					 CONST char* p_pszBuffer,
					 int p_iSize,
					 void* p_pLogServerData)
{
  int iRetValue=-1;
  int iBytesSent=0;
  if (p_handle)
	{
	  AppConnectSocketHandle handle=(AppConnectSocketHandle)p_handle;
	  iBytesSent = fwrite(p_pszBuffer,sizeof(char),p_iSize,handle->pFileWrite);
	  fflush(handle->pFileWrite);

	  if (iBytesSent<0)
		{
		  GSWLog(GSW_ERROR,
				 p_pLogServerData,
				 "send failed. Error=%d (%s)",
				 errno,
				 strerror(errno));
		  iRetValue=-1;
		}
	  else
		iRetValue=0;
	};
  return iRetValue;
};

//--------------------------------------------------------------------
int GSWApp_ReceiveLine(AppConnectHandle p_handle,
					   char* p_pszBuffer,
					   int p_iBufferSize,
					   void* p_pLogServerData)
{
  int iRetValue=-1;
  if (p_handle)
	{
	  AppConnectSocketHandle handle=(AppConnectSocketHandle)p_handle;
	  char* pszLine=fgets(p_pszBuffer,p_iBufferSize,handle->pFileRead);
	  if (pszLine)
		{
		  iRetValue=DeleteTrailingCRNL(p_pszBuffer);
		}
	  else
		{
		  *p_pszBuffer=0;
		  iRetValue=-1; //??
		};
	};
  return iRetValue;
};

//--------------------------------------------------------------------
int GSWApp_ReceiveBlock(AppConnectHandle p_handle,
						char* p_pszBuffer,
						int p_iBufferSize,
						void* p_pLogServerData) 
{
  int iRetValue=-1;
  if (p_handle)
	{
	  AppConnectSocketHandle handle=(AppConnectSocketHandle)p_handle;
	  iRetValue=fread(p_pszBuffer,sizeof(char),p_iBufferSize,handle->pFileRead); 
	};
  return iRetValue;
};

