/* GSWHTTPResponse.h - GSWeb: GSWeb Request
   Copyright (C) 1999, 2000, 2003-2004 Free Software Foundation, Inc.
   
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

#ifndef _GSWHTTPResponse_h__
#define _GSWHTTPResponse_h__

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

#include "GSWTemplates.h"

typedef struct _GSWHTTPResponse
{
  unsigned int uStatus;
  char        *pszStatusMessage;
  GSWDict     *pHeaders;
  unsigned int uContentLength;
  void        *pContent;
} GSWHTTPResponse;

GSWHTTPResponse *GSWHTTPResponse_New(CONST char *p_pszStatus,
				     void       *p_pLogServerData);
void GSWHTTPResponse_Free(GSWHTTPResponse *p_pHTTPResponse,
			  void            *p_pLogServerData);

// Get The response from Application
GSWHTTPResponse *GSWHTTPResponse_GetResponse(AppConnectHandle p_socket,
					     void           *p_pLogServerData);

// Build an error response
GSWHTTPResponse *GSWHTTPResponse_BuildErrorResponse(GSWAppRequest *p_pAppRequest,
                                                    unsigned int  p_uStatus,
                                                    GSWDict	 *p_pHeaders,
                                                    GSWTemplate_FN pTemplateFN,
						    CONST char *p_pszMessage,
						    void *p_pLogServerData);

// Redirect Response
GSWHTTPResponse *GSWHTTPResponse_BuildRedirectedResponse(CONST char *p_pszRedirectPath,
						       void *p_pLogServerData);

// Service Unavailabel Response
GSWHTTPResponse *GSWHTTPResponse_BuildServiceUnavailableResponse(GSWAppRequest *p_pAppRequest,
                                                                 time_t     unavailableUntil,
                                                                 void       *p_pLogServerData);

// Add Header
void GSWHTTPResponse_AddHeader(GSWHTTPResponse *p_pHTTPResponse,
			       char            *p_pszHeader);

char *p_pszGSWHTTPResponse_PackageHeaders(GSWHTTPResponse *p_pHTTPResponse,
					  char            *p_pszBuffer,
					  int              iBufferSize);

GSWHTTPResponse *GSWHTTPResponse_BuildStatusResponse(GSWHTTPRequest *p_pHTTPRequest,
						     void *p_pLogServerData);
GSWHTTPResponse* GSWDumpConfigFile(GSWURLComponents *p_pURLComponents,
				   void             *p_pLogServerData);

#ifdef __cplusplus
}
#endif // __cplusplus


#endif // _GSWHTTPResponse_h__
