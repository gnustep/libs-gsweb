/** GSWToggle.m - <title>GSWeb: Class GSWToggle</title>

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

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWToggle

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWToggle class])
    {
      standardClass=[GSWToggle class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)someAssociations
         template:(GSWElement*)templateElement
{
  //OK
  NSMutableDictionary* otherAssociations=nil;
  LOGObjectFnStart();
  ASSIGN(_children,templateElement);
  _action = [[someAssociations objectForKey:action__Key
                               withDefaultObject:[_action autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"_action=%@",_action);

  _actionYes = [[someAssociations objectForKey:actionYes__Key
                                  withDefaultObject:[_actionYes autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"_actionYes=%@",_actionYes);

  _actionNo = [[someAssociations objectForKey:actionNo__Key
                                 withDefaultObject:[_actionNo autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"_actionNo=%@",_actionNo);

  _condition = [[someAssociations objectForKey:condition__Key
                                  withDefaultObject:[_condition autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"_condition=%@",_condition);

  _disabled = [[someAssociations objectForKey:disabled__Key
                                 withDefaultObject:[_disabled autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"_disabled=%@",_disabled);

  otherAssociations=[NSMutableDictionary dictionaryWithDictionary:someAssociations];
  [otherAssociations removeObjectForKey:action__Key];
  [otherAssociations removeObjectForKey:actionYes__Key];
  [otherAssociations removeObjectForKey:actionNo__Key];
  [otherAssociations removeObjectForKey:condition__Key];
  [otherAssociations removeObjectForKey:disabled__Key];
  if ([otherAssociations count]>0)
    _otherAssociations=[[NSDictionary dictionaryWithDictionary:otherAssociations] retain];

  if ((self=[super initWithName:aName
                   associations:nil
                   template:nil]))
    {
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_action);
  DESTROY(_actionYes);
  DESTROY(_actionNo);
  DESTROY(_condition);
  DESTROY(_disabled);
  DESTROY(_otherAssociations);
  DESTROY(_children);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_getClassName(self),
                   (void*)self];
};

@end

//====================================================================
@implementation GSWToggle (GSWToggleA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  //OK (condition/action/directActionName)
  GSWComponent* component=GSWContext_component(aContext);
  BOOL disabled=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"elementID=%@",GSWContext_elementID(aContext));
  if (_disabled)
    {
      disabled=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                        standardEvaluateConditionInContextIMP,
                                                        _disabled,aContext);
    };

  if (!disabled)
    {
      NSString* url=nil;
      GSWResponse_appendContentAsciiString(aResponse,@"<A ");
      GSWResponse_appendContentAsciiString(aResponse,@"href");
      GSWResponse_appendContentCharacter(aResponse,'=');
      GSWResponse_appendContentCharacter(aResponse,'"');
      url=(NSString*)[aContext componentActionURL];
      NSDebugMLLog(@"gswdync",@"url=%@",url);
      GSWResponse_appendContentString(aResponse,url);
      GSWResponse_appendContentCharacter(aResponse,'"');
      NSDebugMLLog(@"gswdync",@"_otherAssociations=%@",_otherAssociations);
      if (_otherAssociations)
        {
          NSEnumerator *enumerator = [_otherAssociations keyEnumerator];
          id key=nil;
          id oaValue=nil;
          while ((key = [enumerator nextObject]))
            {
              NSDebugMLLog(@"gswdync",@"key=%@",key);
              oaValue=[[_otherAssociations objectForKey:key] 
                        valueInComponent:component];
              NSDebugMLLog(@"gswdync",@"oaValue=%@",oaValue);
              GSWResponse_appendContentCharacter(aResponse,' ');
              GSWResponse_appendContentAsciiString(aResponse,key);
              GSWResponse_appendContentCharacter(aResponse,'=');
              GSWResponse_appendContentCharacter(aResponse,'"');
              GSWResponse_appendContentHTMLString(aResponse,oaValue);
              GSWResponse_appendContentCharacter(aResponse,'"');
            };
        };
      GSWResponse_appendContentCharacter(aResponse,'>');
    };
  [_children appendToResponse:aResponse
            inContext:aContext];
  if (!disabled)//??
    {
      GSWResponse_appendContentAsciiString(aResponse,@"</a>");
    };
  NSDebugMLLog(@"gswdync",@"senderID=%@",GSWContext_senderID(aContext));
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext
{
  //OK
  GSWElement* element=nil;
  NSString* senderID=nil;
  NSString* elementID=nil;

  LOGObjectFnStart();

  senderID=GSWContext_senderID(aContext);
  NSDebugMLLog(@"gswdync",@"senderID=%@",senderID);

  elementID=GSWContext_elementID(aContext);
  NSDebugMLLog(@"gswdync",@"elementID=%@",elementID);

  if ([elementID isEqualToString:senderID])
    {
      GSWComponent* component=GSWContext_component(aContext);
      BOOL conditionValue=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                                   standardEvaluateConditionInContextIMP,
                                                                   _condition,aContext);
      conditionValue=!conditionValue;
      if (_action)
        [_action setValue:(conditionValue ? GSWNumberYes : GSWNumberNo)
                 inComponent:component];
      else
        {
          if (_actionYes && conditionValue)
            [_actionYes valueInComponent:component];
          else if (_actionNo && !conditionValue)
            [_actionNo valueInComponent:component];
          else
            {
              //TODO ERROR
            };
        };
      //TODOV
      if (!element)
        element=[aContext page];
    }
  else
    {
      element=[_children invokeActionForRequest:aRequest
                        inContext:aContext];
      NSDebugMLLog(@"gswdync",@"element=%@",element);
    };

  NSDebugMLLog(@"gswdync",@"senderID=%@",GSWContext_senderID(aContext));
  NSDebugMLLog(@"gswdync",@"elementID=%@",GSWContext_elementID(aContext));

  LOGObjectFnStop();

  return element;
};


@end
