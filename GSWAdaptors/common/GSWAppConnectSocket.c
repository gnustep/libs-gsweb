/* GSWAppConnectSocket.c - GSWeb: Adaptors: App Connection by Socket
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
#ifdef	DEBUG
  GSWLog(GSW_DEBUG,p_pLogServerData,"Start GSWApp_Open");
#endif
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
#ifdef	DEBUG
  GSWLog(GSW_DEBUG,p_pLogServerData,"Stop GSWApp_Open");
#endif
  return handle;
};

//--------------------------------------------------------------------
void GSWApp_Close(AppConnectHandle p_handle,void* p_pLogServerData)
{
#ifdef	DEBUG
  GSWLog(GSW_DEBUG,p_pLogServerData,"Start GSWApp_Close ");
#endif
  if (!p_handle)
	{
	  GSWLog(GSW_CRITICAL,p_pLogServerData,"GSWApp_Close: no Handle !");
	}
  else
	{
	  AppConnectSocketHandle handle=(AppConnectSocketHandle)p_handle;
	  if (!handle->iSocketDescr)
		{
		  GSWLog(GSW_CRITICAL,p_pLogServerData,"GSWApp_Close: no socket desc !");
		}
	  else
		{
		  close(handle->iSocketDescr);
		  fclose(handle->pFileRead);
		  fclose(handle->pFileWrite);
		};
	  free(handle);
	};
#ifdef	DEBUG
  GSWLog(GSW_ERROR,p_pLogServerData,"Stop GSWApp_Close");
#endif
};

//--------------------------------------------------------------------
int GSWApp_SendLine(AppConnectHandle p_handle, CONST char* p_pszBuffer,void* p_pLogServerData)
{
  int iRetValue=-1;
#ifdef	DEBUG
  GSWLog(GSW_DEBUG,p_pLogServerData,"Start GSWApp_SendLine");
#endif
  if (!p_handle)
	{
	  GSWLog(GSW_CRITICAL,p_pLogServerData,"GSWApp_SendLine: no Handle !");
	}
  else
	{
	  AppConnectSocketHandle handle=(AppConnectSocketHandle)p_handle;
	  if (!handle->pFileWrite)
		{
		  GSWLog(GSW_CRITICAL,p_pLogServerData,"GSWApp_SendLine: no write file handle !");
		}
	  else
		{
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
			};
		};
	};
#ifdef	DEBUG
  GSWLog(GSW_DEBUG,p_pLogServerData,"Stop GSWApp_SendLine");
#endif
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
#ifdef	DEBUG
  GSWLog(GSW_DEBUG,p_pLogServerData,"Start GSWApp_SendBlock");
#endif
  if (!p_handle)
	{
	  GSWLog(GSW_CRITICAL,p_pLogServerData,"GSWApp_SendBlock: no Handle !");
	}
  else
	{
	  AppConnectSocketHandle handle=(AppConnectSocketHandle)p_handle;
	  if (!handle->pFileWrite)
		{
		  GSWLog(GSW_CRITICAL,p_pLogServerData,"GSWApp_SendBlock: no write file handle !");
		}
	  else
		{
		  iBytesSent = fwrite(p_pszBuffer,sizeof(char),p_iSize,handle->pFileWrite);
		  fflush(handle->pFileWrite);		  
		  if (iBytesSent<0)
			{
			  GSWLog(GSW_ERROR,
					 p_pLogServerData,
					 "send failed. Error=%d (%s)",
					 errno,
					 strerror(errno));
			}
		  else
			iRetValue=0;
		};
	};
#ifdef	DEBUG
  GSWLog(GSW_DEBUG,p_pLogServerData,"Stop GSWApp_SendBlock");
#endif
  return iRetValue;
};

//--------------------------------------------------------------------
int GSWApp_ReceiveLine(AppConnectHandle p_handle,
					   char* p_pszBuffer,
					   int p_iBufferSize,
					   void* p_pLogServerData)
{
  int iRetValue=-1;
#ifdef	DEBUG
  GSWLog(GSW_DEBUG,p_pLogServerData,"Start GSWApp_ReceiveLine p_iBufferSize=%d",p_iBufferSize);
#endif
  *p_pszBuffer=0;
  if (!p_handle)
	{
	  GSWLog(GSW_CRITICAL,p_pLogServerData,"GSWApp_ReceiveLine: no Handle !");
	}
  else
	{
	  AppConnectSocketHandle handle=(AppConnectSocketHandle)p_handle;
	  if (!handle->pFileRead)
		{
		  GSWLog(GSW_CRITICAL,p_pLogServerData,"GSWApp_ReceiveLine: no read file handle !");
		}
	  else
		{
		  char* pszLine=fgets(p_pszBuffer,p_iBufferSize,handle->pFileRead);
		  if (pszLine)
			{
			  iRetValue=DeleteTrailingCRNL(p_pszBuffer);
			}
		  else
			*p_pszBuffer=0;
		};
	};
#ifdef	DEBUG
  GSWLog(GSW_DEBUG,p_pLogServerData,"GSWApp_ReceiveLine line=[%s]",p_pszBuffer);
  GSWLog(GSW_DEBUG,p_pLogServerData,"Stop GSWApp_ReceiveLine");
#endif
  return iRetValue;
};

//--------------------------------------------------------------------
int GSWApp_ReceiveBlock(AppConnectHandle p_handle,
						char* p_pszBuffer,
						int p_iBufferSize,
						void* p_pLogServerData) 
{
  int iRetValue=-1;
#ifdef	DEBUG
  GSWLog(GSW_DEBUG,p_pLogServerData,"Start GSWApp_ReceiveBlock");
#endif
  if (!p_handle)
	{
	  GSWLog(GSW_CRITICAL,p_pLogServerData,"GSWApp_ReceiveBlock: no Handle !");
	}
  else
	{
	  AppConnectSocketHandle handle=(AppConnectSocketHandle)p_handle;
	  if (!handle->pFileRead)
		{
		  GSWLog(GSW_CRITICAL,p_pLogServerData,"GSWApp_ReceiveBlock: no read file handle !");
		}
	  else
		{
		  iRetValue=fread(p_pszBuffer,sizeof(char),p_iBufferSize,handle->pFileRead); 
		};
	};
#ifdef	DEBUG
  GSWLog(GSW_DEBUG,p_pLogServerData,"Stop GSWApp_ReceiveBlock");
#endif
  return iRetValue;
};

