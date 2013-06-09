/* GSWTemplates.h - GSWeb: GSWTemplates
   Copyright (C) 2000, 2001, 2003-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	March 2000
   
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

#ifndef _GSWTemplates_h__
#define _GSWTemplates_h__

#include "GSWApp.h"
#include "GSWString.h"

typedef char* (*GSWTemplate_FN)(BOOL p_fHTML, GSWApp *pApp);

//You need to free returned char
char *GSWTemplate_ErrorResponse(BOOL p_fHTML, GSWApp *pApp);
char *GSWTemplate_ErrorNoResponse(BOOL p_fHTML, GSWApp *pApp);
char *GSWTemplate_ErrorNoResponseIncludedMessage(BOOL p_fHTML, GSWApp *pApp);
char *GSWTemplate_StatusAllowedResponse(BOOL p_fHTML, GSWApp *pApp);
char *GSWTemplate_StatusDeniedResponse(BOOL p_fHTML, GSWApp *pApp);
char *GSWTemplate_ServiceUnavailableResponse(BOOL p_fHTML,GSWApp *pApp);
char *GSWTemplate_GetDumpHead(BOOL p_fHTML);
char *GSWTemplate_GetDumpFoot(BOOL p_fHTML);
char *GSWTemplate_GetDumpApp(BOOL p_fHTML);
char *GSWTemplate_GetDumpAppInstance(BOOL p_fHTML);
void GSWTemplate_ReplaceStd(GSWString *p_pString, GSWApp *p_pApp,void *p_pLogServerData);

#endif //_GSWTemplates_h__
