/* GSWResourceRequestHandler.h - GSWeb: Class GSWResourceRequestHandler
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

#ifndef _GSWResourceRequestHandler_h__
	#define _GSWResourceRequestHandler_h__


@interface GSWResourceRequestHandler: GSWRequestHandler
{
};

-(GSWResponse*)handleRequest:(GSWRequest*)request_;
-(GSWResponse*)_responseForJavaClassAtPath:(NSString*)_path;
-(GSWResponse*)_responseForDataAtPath:(NSString*)_path;
-(GSWResponse*)_responseForDataCachedWithKey:(NSString*)_key;
-(GSWResponse*)_generateResponseForData:(NSData*)_data
							  mimeType:(NSString*)_mimeType;

@end

//====================================================================
@interface GSWResourceRequestHandler (GSWRequestHandlerClassAA)
+(id)handler;
@end




#endif //GSWResourceRequestHandler
