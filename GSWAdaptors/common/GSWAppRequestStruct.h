/* GSWAppRequestStruct.h - GSWeb: GSWeb App Request Struct
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

#ifndef _GSWAppRequestStruct_h__
#define _GSWAppRequestStruct_h__

#include "GSWApp.h"

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

// Application Type
typedef	enum {
  EAppType_Unknown,
  EAppType_Auto,		// autolaunched/co-hosted
  EAppType_LoadBalanced
} EAppType;
	

// AppRequest
typedef struct _GSWAppRequest
{
  char           *pszName;	// App Name relative to Prefix
  char           *pszHost;	// App Host
  void           *pHostent;	// App Host hostent
  int             iPort;	// AppPort
  int             iInstance;	// App Instance
  EAppType        eType;	// AppType
  unsigned char	  uURLVersion;	// URL Version
  CONST char     *pszDocRoot; 	// Doc Root
  void           *pRequest;	// HTTPRequest
  void           *pResponse;	// HTTPResponse
  GSWAppInstance *pAppInstance;
} GSWAppRequest;


#endif //_GSWAppRequestStruct_h__

