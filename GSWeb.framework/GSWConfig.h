/* config.h - config
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
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
*/

// $Id$

#ifndef _GSWebConfig_h__
#define _GSWebConfig_h__

#define GSLOCK_DELAY_S	360

#define GSWEB_STRICT	0
#define GSWEB_WONAMES	0

#define GSWEB_DEFAULT_HTML_PARSER_CLASS_NAME				@"GSWTemplateParserXMLHTML"
#define GSWOPTVALUE_ApplicationBaseURL					@"/GSWeb"
#define GSWOPTVALUE_AutoOpenInBrowser					@"YES"
#define GSWOPTVALUE_CGIAdaptorURL						@"/cgi/GSWeb"
//or					@"http://host.com/cgi/GSWeb"
#define GSWOPTVALUE_CachingEnabled						@"YES"
#define GSWOPTVALUE_DebuggingEnabled					@"YES"
#define GSWOPTVALUE_StatusDebuggingEnabled				@"YES"
#define GSWOPTVALUE_DirectConnectEnabled				@"YES"
#define GSWOPTVALUE_FrameworksBaseURL				    @"/GSW/Frameworks"
#define GSWOPTVALUE_IncludeCommentsInResponse			@"YES"
#define GSWOPTVALUE_ListenQueueSize						@"16"
#define GSWOPTVALUE_MonitorEnabled				   		@"NO"
#define GSWOPTVALUE_MonitorHost							@"Undefined"
#define GSWOPTVALUE_Port								@"9001"
#define GSWOPTVALUE_SMTPHost						  	@"smtp"
#define GSWOPTVALUE_SessionTimeOut		 				@"3600"
#define GSWOPTVALUE_WorkerThreadCount		 	   		@"8"
#define GSWOPTVALUE_MultiThreadEnabled					@"YES"

#endif // _GSWebConfig_h__
