/* GSWAppRequest.h - GSWeb: GSWeb App Request
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

#ifndef _GSWAppRequest_h__
#define _GSWAppRequest_h__

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

#define	GSWAppRequest_INITIALIZER	{NULL,NULL,NULL,0,0,AT_NONE,3,NULL,NULL,NULL,NULL}

GSWHTTPResponse* GSWAppRequest_HandleRequest(GSWHTTPRequest** p_ppHTTPRequest,
											 GSWURLComponents* p_pURLComponents,
											 CONST char* p_pszHTTPVersion,
											 CONST char* p_pszDocRoot,
											 CONST char* p_pszTestAppName,
											 void* p_pLogServerData);

#endif //_GSWAppRequest_h__

