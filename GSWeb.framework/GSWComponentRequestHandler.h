/* GSWComponentRequestHandler.h - GSWeb: Class GSWComponentRequestHandler
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Feb 1999
   
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

#ifndef _GSWComponentRequestHandler_h__
	#define _GSWComponentRequestHandler_h__


@interface GSWComponentRequestHandler: GSWRequestHandler
{
}

-(GSWResponse*)handleRequest:(GSWRequest*)request_;
-(GSWResponse*)lockedHandleRequest:(GSWRequest*)request_;
-(GSWResponse*)lockedDispatchWithPreparedApplication:(GSWApplication*)_application
									 inContext:(GSWContext*)context_
									  elements:(NSDictionary*)_elements;
-(GSWResponse*)lockedDispatchWithPreparedSession:(GSWSession*)_session
								 inContext:(GSWContext*)context_
								  elements:(NSDictionary*)_elements;
-(GSWResponse*)lockedDispatchWithPreparedPage:(GSWComponent*)_component
							  inSession:(GSWSession*)_session
							  inContext:(GSWContext*)context_
							   elements:(NSDictionary*)_elements;
-(GSWComponent*)lockedRestorePageForContextID:(NSString*)context_ID
							  inSession:(GSWSession*)_session;

@end

//====================================================================
@interface GSWComponentRequestHandler (GSWRequestHandlerClassA)
+(id)handler;
+(NSDictionary*)_requestHandlerValuesForRequest:(GSWRequest*)request_;
@end

#endif //_GSWComponentRequestHandler_h__
