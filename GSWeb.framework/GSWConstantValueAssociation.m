/* GSWConstantValueAssociation.m - GSWeb: Class GSWConstantValueAssociation
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

static char rcsId[] = "$Id$";

#include <gsweb/GSWeb.framework/GSWeb.h>

//====================================================================
@implementation GSWConstantValueAssociation

//--------------------------------------------------------------------
-(id)initWithValue:(id)value_
{
  //OK
  if ((self=[super init]))
	{
	  ASSIGNCOPY(value,value_);
	};
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(value);
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone;
{
  GSWConstantValueAssociation* clone = [super copyWithZone:zone];
  ASSIGN(clone->value,value);
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)debugDescription
{
  NSString* _dscr=[NSString stringWithFormat:@"<%s %p - value=%@",
							object_get_class_name(self),
							(void*)self,
							value];
  return _dscr;
};

//--------------------------------------------------------------------
-(BOOL)isValueConstant
{
  return YES;
};

//--------------------------------------------------------------------
-(BOOL)isValueSettable
{
  return NO;
};

//--------------------------------------------------------------------
-(id)valueInObject:(id)object_
{
  [self logTakeValue:value];
  return value;
};

//--------------------------------------------------------------------
-(void)setValue:(id)value_
	   inObject:(id)object_
{
  ExceptionRaise0(@"GSWConstantValueAssociation",@"Can't set value for a constant value association");
};

//--------------------------------------------------------------------
-(NSString*)description
{
  NSString* _dscr=nil;
  LOGAssertGood(self);
  if (value)
	{
	  LOGAssertGood(value);
	};
  _dscr=[NSString stringWithFormat:@"<%s %p - value=%@",
				  object_get_class_name(self),
				  (void*)self,
				  value];
  return _dscr;
};

@end

