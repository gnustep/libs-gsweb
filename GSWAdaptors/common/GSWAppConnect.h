/* GSWAppConnect.h - GSWeb: GSWeb App Connect
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

#ifndef _GSWAppConnect_h__
#define _GSWAppConnect_h__

typedef struct _STAppConnectHandle
{
  void* foo;
} STAppConnectHandle;

typedef STAppConnectHandle* AppConnectHandle;


AppConnectHandle GSWApp_Open(GSWAppRequest* p_pAppRequest,
							 void* p_pLogServerData);
void GSWApp_Close(AppConnectHandle p_handle,
				  void* p_pLogServerData);

int GSWApp_SendBlock(AppConnectHandle p_handle,
					 CONST char* p_pszBuffer,
					 int p_iSize,
					 void* p_pLogServerData);
int GSWApp_ReceiveBlock(AppConnectHandle p_handle,
						char* p_pszBuffer,
						int p_iBufferSize,
						void* p_pLogServerData);

int GSWApp_SendLine(AppConnectHandle p_handle,
					CONST char* p_pszBuffer,
					void* p_pLogServerData);
int GSWApp_ReceiveLine(AppConnectHandle p_handle,
					   char* p_pszBuffer,
					   int p_iBufferSize,
					   void* p_pLogServerData);


#endif // _GSWAppConnect_h__


