/** GSWPageDefElement.h - <title>GSWeb: Class GSWPageDefElement</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Mar 1999
   
   $Revision$
   $Date$

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

#ifndef _GSWPageDefElement_h__
	#define _GSWPageDefElement_h__

//====================================================================
@interface GSWPageDefElement: NSObject <NSCopying>
{
  NSString* _elementName;
  NSString* _className;
  NSMutableDictionary* _associations;
};

-(NSString*)description;
-(id)init;
-(void)dealloc;
-(id)copyWithZone:(NSZone *)zone;
-(id)initWithCoder:(NSCoder*)code;
-(void)encodeWithCoder:(NSCoder*)code;
-(NSString*)elementName;
-(void)setElementName:(NSString*)aNname;
-(NSString*)className;
-(void)setClassName:(NSString*)aNname;
-(NSDictionary*)associations;
-(void)setAssociation:(GSWAssociation*)association
               forKey:(NSString*)key;
@end

#endif //_GSWPageDefElement_h__
