/* GSWHTTPResponse.h - GSWeb: GSWeb Request
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

#ifndef _GSWHTTPResponse_h__
#define _GSWHTTPResponse_h__

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

typedef struct _GSWHTTPResponse
{
  unsigned int uStatus;
  char* pszStatusMessage;
  GSWDict* pHeaders;
  unsigned int uContentLength;
  void* pContent;
} GSWHTTPResponse;

GSWHTTPResponse* GSWHTTPResponse_New(void* p_pLogServerData,CONST char* p_pszStatus);
void GSWHTTPResponse_Free(GSWHTTPResponse* p_pHTTPResponse);

// Get The response from Application
GSWHTTPResponse* GSWHTTPResponse_GetResponse(void* p_pLogServerData,AppConnectHandle p_socket);

// Build an error response
GSWHTTPResponse *GSWHTTPResponse_BuildErrorResponse(CONST char* p_pszMessage);

// Redirect Response
GSWHTTPResponse* GSWHTTPResponse_BuildRedirectedResponse(CONST char* p_pszRedirectPath);

// Add Header
void GSWHTTPResponse_AddHeader(GSWHTTPResponse* p_pHTTPResponse,
							   char* p_pszHeader);

char* p_pszGSWHTTPResponse_PackageHeaders(GSWHTTPResponse* p_pHTTPResponse,
										  char* p_pszBuffer,
										  int iBufferSize);

GSWHTTPResponse* GSWHTTPResponse_BuildTestResponse(void* p_pLogServerData,GSWHTTPRequest* p_pHTTPRequest);

BOOL GSWDumpConfigFile_CanDump();
GSWHTTPResponse* GSWDumpConfigFile(void* p_pLogServerData,GSWURLComponents* p_pURLComponents);

#ifdef __cplusplus
}
#endif // __cplusplus


#endif // _GSWHTTPResponse_h__
