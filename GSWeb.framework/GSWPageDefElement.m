/** GSWPageDefElement.m - <title>GSWeb: Class GSWPageDefElement</title>

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

static char rcsId[] = "$Id$";

#include "GSWeb.h"


//====================================================================
@implementation GSWPageDefElement

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
-(void)dealloc
{
//  NSDebugFLLog(@"low",@"Dealloc GSWPageDefElement=%p",(void*)self);
//  GSWLogC("Dealloc GSWPageDefElement: elementName");
  DESTROY(_elementName);
//  GSWLogC("Dealloc GSWPageDefElement: className");
  DESTROY(_className);
//  GSWLogC("Dealloc GSWPageDefElement: associations");
  DESTROY(_associations);
  [super dealloc];
//  GSWLogC("End Dealloc GSWPageDefElement");
}

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWPageDefElement* clone = [[isa allocWithZone:zone] init];
  ASSIGNCOPY(clone->_elementName,_elementName);
  ASSIGNCOPY(clone->_className,_className);
  ASSIGNCOPY(clone->_associations,_associations);
  return clone;
};

//--------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*)coder
{
  if ((self = [super init]))
    {
      [coder decodeValueOfObjCType:@encode(id)
             at:&_elementName];
      [coder decodeValueOfObjCType:@encode(id)
             at:&_className];
      [coder decodeValueOfObjCType:@encode(id)
             at:&_associations];
    };
  return self;
};

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder
{
  [coder encodeObject:_elementName];
  [coder encodeObject:_className];
  [coder encodeObject:_associations];
};


//--------------------------------------------------------------------
-(NSString*)elementName
{
  return _elementName;
};

//--------------------------------------------------------------------
-(void)setElementName:(NSString*)aName
{
  ASSIGNCOPY(_elementName,aName);
};

//--------------------------------------------------------------------
-(NSString*)className
{
  return _className;
};

//--------------------------------------------------------------------
-(void)setClassName:(NSString*)aName
{
  ASSIGNCOPY(_className,aName);
};

//--------------------------------------------------------------------
-(NSDictionary*)associations
{
  return _associations;
};

//--------------------------------------------------------------------
-(void)setAssociation:(GSWAssociation*)association
               forKey:(NSString*)key
{
  if (!_associations)
    _associations=[NSMutableDictionary new];
  [_associations setObject:association
                 forKey:key];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%@ %p elementName:[%@] className:[%@] associations:\n%@",
                   [self class],
                   (void*)self,
                   _elementName,
                   _className,
                   _associations];
};
@end
