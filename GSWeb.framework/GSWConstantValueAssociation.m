/** GSWConstantValueAssociation.m - <title>GSWeb: Class GSWConstantValueAssociation</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 1999
   
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
@implementation GSWConstantValueAssociation

//--------------------------------------------------------------------
-(id)initWithValue:(id)aValue
{
  //OK
  if ((self=[super init]))
    {
      ASSIGNCOPY(_value,aValue);
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogMemC("GSWConstantValueAssociation start of dealloc");
  GSWLogAssertGood(self);
  DESTROY(_value);
  GSWLogMemC("value deallocated");
  [super dealloc];
  GSWLogMemC("GSWConstantValueAssociation end of dealloc");
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWConstantValueAssociation* clone = [super copyWithZone:zone];
  ASSIGN(clone->_value,_value);
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)debugDescription
{
  NSString* dscr=[NSString stringWithFormat:@"<%s %p - value=%@ (class: %@)>",
                           object_get_class_name(self),
                           (void*)self,
                           _value,
                           [_value class]];
  return dscr;
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
-(id)valueInComponent:(GSWComponent*)object
{
  [self logTakeValue:_value];
  return _value;
};

//--------------------------------------------------------------------
-(void)setValue:(id)aValue
       inComponent:(GSWComponent*)object
{
  ExceptionRaise0(@"GSWConstantValueAssociation",
                  @"Can't set value for a constant value association");
};

//--------------------------------------------------------------------
-(NSString*)description
{
  NSString* dscr=nil;
  GSWLogAssertGood(self);
  if (_value)
    {
      GSWLogAssertGood(_value);
    };
  dscr=[NSString stringWithFormat:@"<%s %p - value=%@ (class: %@)>",
                 object_get_class_name(self),
                 (void*)self,
                 _value,
                 [_value class]];
  return dscr;
};

@end

