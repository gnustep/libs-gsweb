/* GSWHTTPRequest.h - GSWeb: GSWeb Request
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

#ifndef _GSWHTTPRequest_h__
#define _GSWHTTPRequest_h__


#ifdef __cplusplus
extern "C" {
#endif // __cplusplus



typedef	enum
{
  ERequestMethod_None = -2,
  ERequestMethod_Unknown,
  ERequestMethod_Get,
  ERequestMethod_Post,
  ERequestMethod_Head,
  ERequestMethod_Put
} ERequestMethod;

typedef struct _GSWHTTPRequest
{
  ERequestMethod  eMethod;		// Method
  char           *pszRequest;		// Request String
  GSWDict        *pHeaders;		// Headers
  void           *pServerHandle;	// Server Handle
  unsigned        uContentLength;	// Content Length
  void           *pContent;		// Content
} GSWHTTPRequest;


GSWHTTPRequest *GSWHTTPRequest_New(CONST char *pszMethod,
				   char       *p_pszURI,
				   void       *p_pLogServerData);
void GSWHTTPRequest_Free(GSWHTTPRequest *p_pHTTPRequest,
			 void           *p_pLogServerData);

// Return error message (NULL if ok)
CONST char *GSWHTTPRequest_ValidateMethod(GSWHTTPRequest *p_pHTTPRequest,
					  void           *p_pLogServerData);

// HTTP Request -> GSWeb App Request
void GSWHTTPRequest_HTTPToAppRequest(GSWHTTPRequest   *p_pHTTPRequest,
				     GSWAppRequest    *p_pAppRequest,
				     GSWURLComponents *p_pURLComponents,
				     CONST char       *p_pszHTTPVersion,
				     void             *p_pLogServerData);

// Add Header
void GSWHTTPRequest_AddHeader(GSWHTTPRequest *p_pHTTPRequest,
			      CONST char     *p_pszKey,
			      CONST char     *p_pszValue);

// Get Header (case insensitive)
CONST char *GSWHTTPRequest_HeaderForKey(GSWHTTPRequest *p_pHTTPRequest,
					CONST char     *p_pszKey);

// Handle Request (send it to Application)
BOOL GSWHTTPRequest_SendRequest(GSWHTTPRequest   *p_pHTTPRequest,
				AppConnectHandle  p_socket,
				void             *p_pLogServerData);

#ifdef __cplusplus
}
#endif // __cplusplus


#endif // _GSWHTTPRequest_h__
