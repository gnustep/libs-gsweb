/* GSWPageDefElement.m - GSWeb: Class GSWPageDefElement
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>


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
  DESTROY(elementName);
//  GSWLogC("Dealloc GSWPageDefElement: className");
  DESTROY(className);
//  GSWLogC("Dealloc GSWPageDefElement: associations");
  DESTROY(associations);
  [super dealloc];
//  GSWLogC("End Dealloc GSWPageDefElement");
}

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWPageDefElement* clone = [[isa allocWithZone:zone] init];
  ASSIGNCOPY(clone->elementName,elementName);
  ASSIGNCOPY(clone->className,className);
  ASSIGNCOPY(clone->associations,associations);
  return clone;
};

//--------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*)coder_
{
  if ((self = [super init]))
	{
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&elementName];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&className];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&associations];
	};
  return self;
};

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder_
{
  [coder_ encodeObject:elementName];
  [coder_ encodeObject:className];
  [coder_ encodeObject:associations];
};


//--------------------------------------------------------------------
-(NSString*)elementName
{
  return elementName;
};

//--------------------------------------------------------------------
-(void)setElementName:(NSString*)_name
{
  ASSIGNCOPY(elementName,_name);
};

//--------------------------------------------------------------------
-(NSString*)className
{
  return className;
};

//--------------------------------------------------------------------
-(void)setClassName:(NSString*)_name
{
  ASSIGNCOPY(className,_name);
};

//--------------------------------------------------------------------
-(NSDictionary*)associations
{
  return associations;
};

//--------------------------------------------------------------------
-(void)setAssociation:(GSWAssociation*)_association
			   forKey:(NSString*)_key
{
  if (!associations)
	associations=[NSMutableDictionary new];
  [associations setObject:_association
				forKey:_key];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%@ %p elementName:[%@] className:[%@] associations:\n%@",
				   [self class],
				   (void*)self,
				   elementName,
				   className,
				   associations];
};
@end
