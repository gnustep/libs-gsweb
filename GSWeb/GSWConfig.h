/** GSWConfig.h - config
   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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
**/

// $Id$

#ifndef _GSWebConfig_h__
#define _GSWebConfig_h__

#ifdef  GSWEB_WONAMES
#include "GSWWOCompatibility.h"
#endif

#define GSLOCK_DELAY_S	360

#define GSWEB_STRICT	0

#define GSWOPTVALUE_ApplicationBaseURL_WO			@"/WebObjects"
#define GSWOPTVALUE_ApplicationBaseURL_GSWEB			@"/GSWeb"
#define GSWOPTVALUE_AutoOpenInBrowser				@"NO"
#define GSWOPTVALUE_CGIAdaptorURL_WO				@"/cgi/WebObjects"
#define GSWOPTVALUE_CGIAdaptorURL_GSWEB				@"/cgi/GSWeb"
//or					@"http://host.com/cgi/GSWeb"
#define GSWOPTVALUE_CachingEnabled				@"YES"
#define GSWOPTVALUE_DebuggingEnabled				@"YES"
#define GSWOPTVALUE_StatusDebuggingEnabled			@"YES"
#define GSWOPTVALUE_StatusLoggingEnabled			@"YES"
#define GSWOPTVALUE_DirectConnectEnabled			@"YES"
#define GSWOPTVALUE_FrameworksBaseURL				@"/GSW/Frameworks"
#define GSWOPTVALUE_IncludeCommentsInResponse			@"YES"
#define GSWOPTVALUE_ListenQueueSize				@"16"
#define GSWOPTVALUE_MonitorEnabled				@"NO"
#define GSWOPTVALUE_MonitorHost					@"localhost"
#define GSWOPTVALUE_Port					@"9001"
#define GSWOPTVALUE_SMTPHost					@"smtp"
#define GSWOPTVALUE_SessionTimeOut		 		@"3600"
#define GSWOPTVALUE_WorkerThreadCount		 	   	@"8"
#define GSWOPTVALUE_MultiThreadEnabled				@"YES"
#define GSWOPTVALUE_AdaptorHost					@""
#define GSWOPTVALUE_DefaultTemplateParser      			@"RawHTML"
#define GSWOPTVALUE_LifebeatEnabled				@"NO"
#define GSWOPTVALUE_LifebeatDestinationHost			@"localhost"
#define GSWOPTVALUE_LifebeatDestinationPort			@"1085"
#define GSWOPTVALUE_LifebeatInterval				@"30"
#define GSWOPTVALUE_DefaultUndoStackLimit			@"10"
#define GSWOPTVALUE_LockDefaultEditingContext			@"NO"
#define GSWOPTVALUE_WorkerThreadCountMin			@"16"
#define GSWOPTVALUE_WorkerThreadCountMax			@"256"
#define GSWOPTVALUE_DisplayExceptionPages			@"YES"
#define GSWOPTVALUE_AllowsCacheControlHeader			@"NO"
#endif // _GSWebConfig_h__
