/* GSWURLValuedElementData.h - GSWeb: Class GSWURLValuedElementData
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Apr 1999
   
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

#ifndef _GSWURLValuedElementData_h__
	#define _GSWURLValuedElementData_h__


@interface GSWURLValuedElementData: NSObject
{
  NSString* key;
  NSString* mimeType;
  NSData * data;
  BOOL temporaryKey;
};

-(id)initWithData:(NSData*)data_
		 mimeType:(NSString*)type_
			  key:(NSString*)key_;
-(void)dealloc;

-(void)appendDataURLToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;
-(NSString*)description;
-(BOOL)isTemporary;
-(NSData*)data;
-(NSString*)type;
-(NSString*)key;

@end

#endif //_GSWURLValuedElementData_h__
