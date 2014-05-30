/** GSWKeyValueConditional.m - <title>GSWeb: Class GSWKeyValueConditional</title>

   Copyright (C) 2003 Free Software Foundation, Inc.
   
   Written by:	Dave Lopper
   Date: 	Mar 2003
   
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

#include "config.h"

#include "GSWExtWOCompatibility.h"
#include "GSWKeyValueConditional.h"

//===================================================================================
@implementation GSWKeyValueConditional

//--------------------------------------------------------------------
- (BOOL) synchronizesVariablesWithBindings
{
    return NO;
}

//--------------------------------------------------------------------
- (BOOL) condition
{
  BOOL condition = NO;
  id parentValue;
  id value;

//    key = [self valueForBinding:@"key"];
//    parentValue = (key ? [[self parent] valueForKeyPath:key]:nil);
  parentValue = [self valueForBinding:@"key"];
  value = [self valueForBinding:@"value"];

  if(parentValue == nil)
    condition = (value == nil);
  else
    condition = [parentValue isEqual:value];

  return condition;
}

@end
