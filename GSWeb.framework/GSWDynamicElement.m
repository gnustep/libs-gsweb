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
  //OK
  if ((self=[super init]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogAssertGood(self);
  GSWLogC("Dealloc GSWDynamicElement");
  GSWLogC("Dealloc GSWDynamicElement: name");
  GSWLogC("Dealloc GSWDynamicElement Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWDynamicElement");
}

//--------------------------------------------------------------------
-(BOOL)		evaluateCondition:(id)condition
                        inContext:(GSWContext*)context
    noConditionAssociationDefault:(BOOL)noConditionAssociationDefault
               noConditionDefault:(BOOL)noConditionDefault
{
  //OK
  BOOL result=noConditionAssociationDefault;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"condition_=%@ noConditionAssociationDefault=%s noConditionDefault=%s",
               condition,(noConditionAssociationDefault ? "YES" : "NO"),
               (noConditionDefault ?  "YES" : "NO"));
  if (condition)
    {
      GSWComponent* component=GSWContext_component(context);
      id value=[condition valueInComponent:component];
      NSDebugMLLog(@"gswdync",@"_value=%@ class=%@",value,[value class]);
#ifndef NDEBUG
      if ([value respondsToSelector:@selector(unsignedCharValue)])
        {
          NSDebugMLLog(@"gswdync",@"unsignedCharValue=%d",(int)[value unsignedCharValue]);
        };
#endif
      result=boolValueWithDefaultFor(value,noConditionDefault);
    };
  NSDebugMLLog(@"gswdync",@"condition_=%@ noConditionAssociationDefault=%s noConditionDefault=%s ==> result=%s",
               condition,(noConditionAssociationDefault ? "YES" : "NO"),
               (noConditionDefault ?  "YES" : "NO"),(result ? "YES" : "NO"));
  LOGObjectFnStop();
  return result;
};

//--------------------------------------------------------------------
-(BOOL)evaluateCondition:(id)condition
               inContext:(GSWContext*)context
{
  BOOL result=NO;
  LOGObjectFnStart();
  
  result=[self 	evaluateCondition:condition
                inContext:context
                noConditionAssociationDefault:NO
                noConditionDefault:YES];
  
  LOGObjectFnStop();
  return result;
};
@end
