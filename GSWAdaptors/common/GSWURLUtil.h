/* GSWURLUtil.h - GSWeb: Adaptors: URL Utils
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

#ifndef _GSWURLUtil_h__
#define _GSWURLUtil_h__

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _GSWURLComponent
{
  CONST char* pszStart;
  int iLength;
} GSWURLComponent;

typedef struct _GSWURLComponents
{
  GSWURLComponent stPrefix;
  GSWURLComponent stVersion;
  GSWURLComponent stAppName;
  GSWURLComponent stAppNumber;
  GSWURLComponent stAppHost;
  GSWURLComponent stSessionID;
  GSWURLComponent stPageName;
  GSWURLComponent stContextID;
  GSWURLComponent stSenderID;
  GSWURLComponent stQueryString;
  GSWURLComponent stSuffix;
  GSWURLComponent stRequestHandlerKey;
  GSWURLComponent stRequestHandlerPath;
} GSWURLComponents;

typedef enum
{
  GSWURLError_OK = 0,
  GSWURLError_InvalidPrefix,
  GSWURLError_InvalidVersion,
  GSWURLError_InvalidAppName,
  GSWURLError_InvalidAppNumber,
  GSWURLError_InvalidRequestHandlerKey,
  GSWURLError_InvalidRequestHandlerPath,
  GSWURLError_InvalidAppHost,
  GSWURLError_InvalidPageName,
  GSWURLError_InvalidSessionID,
  GSWURLError_InvalidContextID,
  GSWURLError_InvalidSenderID,
  GSWURLError_InvalidQueryString,
  GSWURLError_InvalidSuffix
} GSWURLError;

GSWURLError GSWParseURL(GSWURLComponents* p_pURLComponents,CONST char* p_pszURL);
void GSWComposeURL(char* p_pszURL,GSWURLComponents* p_pURLComponents);
int GSWComposeURLLen(GSWURLComponents* p_pURLComponents);
CONST char* GSWURLErrorMessage(GSWURLError p_eError);
#ifdef __cplusplus
}
#endif //_cplusplus


#endif //_GSWURLUtil_h__
