/** GSWURLValuedElementData.h - <title>GSWeb: Class GSWURLValuedElementData</title>
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Apr 1999
   
   $Revision$
   $Date$
   
   <abstract></abstract>

   This file is part of the GNUstep Web Library.
   
   <license>
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
   </license>
**/

// $Id$

#ifndef _GSWURLValuedElementData_h__
	#define _GSWURLValuedElementData_h__


@interface GSWURLValuedElementData: NSObject
{
  NSString* _key;
  NSString* _mimeType;
  NSData * _data;
  BOOL _temporaryKey;
};

+ (void) _appendDataURLAttributeToResponse:(GSWResponse*) response
				 inContext:(GSWContext*) context
				       key:(GSWAssociation*) key
				      data:(GSWAssociation*) data
				  mimeType:(GSWAssociation*) mimeType
			  urlAttributeName:(NSString *) urlAttribute    // @"src"
			       inComponent:(GSWComponent*) component;

-(id)initWithData:(NSData*)data
         mimeType:(NSString*)type
              key:(NSString*)key;
-(void)dealloc;

-(void)appendDataURLToResponse:(GSWResponse*)response
                     inContext:(GSWContext*)context;
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context;
-(NSString*)description;
-(BOOL)isTemporary;
-(NSData*)data;
-(NSString*)type;
-(NSString*)key;

@end

#endif //_GSWURLValuedElementData_h__
