/** GSWDeclaration.m - <title>GSWeb: Class GSWDeclaration</title>

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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"


//====================================================================
@implementation GSWDeclaration

//--------------------------------------------------------------------
+(GSWDeclaration*)declarationWithName:(NSString*)name
                                 type:(NSString*)type
                         associations:(NSDictionary*)associations
{
  return [[[self alloc]initWithName:name
                       type:type
                       associations:associations]autorelease];
};

//--------------------------------------------------------------------
//	init

-(id)init
{
  if ((self=[super init]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name
             type:(NSString*)type
     associations:(NSDictionary*)associations
{
  if ((self=[self init]))
    {
      [self setName:name];
      [self setType:type];
      [self setAssociations:associations];
    };
return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_name);
  DESTROY(_type);
  DESTROY(_associations);
  [super dealloc];
}

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWDeclaration* clone = [[isa allocWithZone:zone] init];
  ASSIGNCOPY(clone->_name,_name);
  ASSIGNCOPY(clone->_type,_type);
  ASSIGNCOPY(clone->_associations,_associations);
  return clone;
};

//--------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*)coder
{
  if ((self = [super init]))
    {
      [coder decodeValueOfObjCType:@encode(id)
             at:&_name];
      [coder decodeValueOfObjCType:@encode(id)
             at:&_type];
      [coder decodeValueOfObjCType:@encode(id)
             at:&_associations];
    };
  return self;
};

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder
{
  [coder encodeObject:_name];
  [coder encodeObject:_type];
  [coder encodeObject:_associations];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p name:[%@] type:[%@] associations:\n%@",
                   object_getClassName(self),
                   (void*)self,
                   _name,
                   _type,
                   _associations];
};

//--------------------------------------------------------------------
-(NSString*)name
{
  return _name;
};

//--------------------------------------------------------------------
-(void)setName:(NSString*)name
{
  ASSIGNCOPY(_name,name);
};

//--------------------------------------------------------------------
-(NSString*)type
{
  return _type;
};

//--------------------------------------------------------------------
-(void)setType:(NSString*)type
{
  ASSIGNCOPY(_type,type);
};

//--------------------------------------------------------------------
-(NSDictionary*)associations
{
  return _associations;
};

//--------------------------------------------------------------------
-(void)setAssociations:(NSDictionary*)associations
{
  ASSIGNCOPY(_associations,associations);
};

@end
