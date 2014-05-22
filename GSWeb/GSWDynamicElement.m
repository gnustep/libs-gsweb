/** GSWDynamicElement.m - <title>GSWeb: Class GSWDynamicElement</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

SEL evaluateConditionInContextSEL = NULL;

//====================================================================
@implementation GSWDynamicElement

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWDynamicElement class])
    {
      evaluateConditionInContextSEL=@selector(evaluateCondition:inContext:);
    };
};

//--------------------------------------------------------------------
//	initWithName:associations:template:

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  if ((self=[super init]))
    {  
    }  
  return self;
}

//--------------------------------------------------------------------
-(BOOL)		evaluateCondition:(id)condition
                        inContext:(GSWContext*)context
    noConditionAssociationDefault:(BOOL)noConditionAssociationDefault
               noConditionDefault:(BOOL)noConditionDefault
{
  //OK
  BOOL result=noConditionAssociationDefault;

  if (condition)
    {
      GSWComponent* component=GSWContext_component(context);
      id value=[condition valueInComponent:component];
      result=boolValueWithDefaultFor(value,noConditionDefault);
    };

  return result;
};

//--------------------------------------------------------------------
-(BOOL)evaluateCondition:(id)condition
               inContext:(GSWContext*)context
{
  BOOL result=NO;

  result=[self 	evaluateCondition:condition
                inContext:context
                noConditionAssociationDefault:NO
                noConditionDefault:YES];
  
  return result;
};
@end
