/** GSWToggle.m - <title>GSWeb: Class GSWToggle</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
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

static char rcsId[] = "$Id$";

#include "GSWeb.h"

//====================================================================
@implementation GSWToggle

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
                   object_get_class_name(self),
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
  GSWComponent* component=[aContext component];
  BOOL disabled=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"elementID=%@",[aContext elementID]);
  if (_disabled)
    disabled=[self evaluateCondition:_disabled
                   inContext:aContext];
  if (!disabled)
    {
      NSString* url=nil;
      [aResponse _appendContentAsciiString:@"<A "];
      [aResponse _appendContentAsciiString:@"href"];
      [aResponse appendContentCharacter:'='];
      [aResponse appendContentCharacter:'"'];
      url=(NSString*)[aContext componentActionURL];
      NSDebugMLLog(@"gswdync",@"url=%@",url);
      [aResponse appendContentString:url];
      [aResponse appendContentCharacter:'"'];
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
              [aResponse appendContentCharacter:' '];
              [aResponse _appendContentAsciiString:key];
              [aResponse appendContentCharacter:'='];
              [aResponse appendContentCharacter:'"'];
              [aResponse appendContentHTMLString:oaValue];
              [aResponse appendContentCharacter:'"'];
            };
        };
      [aResponse appendContentCharacter:'>'];
    };
  [_children appendToResponse:aResponse
            inContext:aContext];
  if (!disabled)//??
    {
      [aResponse _appendContentAsciiString:@"</a>"];
    };
  NSDebugMLLog(@"gswdync",@"senderID=%@",[aContext senderID]);
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
  senderID=[aContext senderID];
  NSDebugMLLog(@"gswdync",@"senderID=%@",senderID);
  elementID=[aContext elementID];
  NSDebugMLLog(@"gswdync",@"elementID=%@",elementID);
  if ([elementID isEqualToString:senderID])
    {
      GSWComponent* component=[aContext component];
      BOOL conditionValue=[self evaluateCondition:_condition
                                inContext:aContext];
      conditionValue=!conditionValue;
      if (_action)
        [_action setValue:[NSNumber numberWithBool:conditionValue]
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
  NSDebugMLLog(@"gswdync",@"senderID=%@",[aContext senderID]);
  NSDebugMLLog(@"gswdync",@"elementID=%@",[aContext elementID]);
  LOGObjectFnStop();
  return element;
};


@end
