/** GSWDeclaration.h - <title>GSWeb: Class GSWDeclaration</title>

   Copyright (C) 2004 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 2004
   
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

#ifndef _GSWDeclaration_h__
	#define _GSWDeclaration_h__

//====================================================================
@interface GSWDeclaration: NSObject <NSCopying>
{
  NSString* _name;
  NSString* _type;
  NSMutableDictionary* _associations;
};
+(GSWDeclaration*)declarationWithName:(NSString*)name
                                 type:(NSString*)type
                         associations:(NSDictionary*)associations;
-(id)initWithName:(NSString*)name
             type:(NSString*)type
     associations:(NSDictionary*)associations;
-(NSString*)name;
-(void)setName:(NSString*)name;
-(NSString*)type;
-(void)setType:(NSString*)type;
-(NSDictionary*)associations;
-(void)setAssociations:(NSDictionary*)associations;

@end

#endif //_GSWDeclaration_h__
