/** GSWSubmitButton.m - <title>GSWeb: Class GSWSubmitButton</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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
@implementation GSWSubmitButton

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  NSMutableDictionary* tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ _elements=%@",
               aName,associations,elements);
  [tmpAssociations setObject:[GSWAssociation associationWithValue:@"submit"]
                   forKey:@"type"];
  [tmpAssociations removeObjectForKey:action__Key];
  [tmpAssociations removeObjectForKey:actionClass__Key];
  if (_directActionName) 
    [tmpAssociations removeObjectForKey:_directActionName];
  
  if (![tmpAssociations objectForKey:value__Key])
    [tmpAssociations setObject:[GSWAssociation associationWithValue:@"submit"]
                     forKey:value__Key];

  if ((self=[super initWithName:aName
                   associations:tmpAssociations
                   contentElements:nil]))
    {
      _action = [[associations objectForKey:action__Key
                               withDefaultObject:[_action autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWSumbitButton: action=%@",_action);
      _actionClass = [[associations objectForKey:actionClass__Key
                                    withDefaultObject:[_actionClass autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWSumbitButton: actionClass=%@",_actionClass);
      _directActionName = [[associations objectForKey:directActionName__Key
                                         withDefaultObject:[_directActionName autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWSumbitButton: directActionName=%@",_directActionName);
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_action);
  DESTROY(_actionClass);
  DESTROY(_directActionName);
  [super dealloc];
};

@end

//====================================================================
@implementation GSWSubmitButton (GSWSubmitButtonA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  //OK
  LOGObjectFnStart();
  GSWStartElement(context);
  GSWSaveAppendToResponseElementID(context);
  [super appendToResponse:response
		 inContext:context];
  GSWStopElement(context);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
{
  //OK
  GSWElement* element=nil;
  BOOL disabledValue=NO;
  LOGObjectFnStart();
  GSWStartElement(context);
  NS_DURING
    {
      GSWAssertCorrectElementID(context);
      disabledValue=[self disabledInContext:context];
      NSDebugMLLog(@"gswdync",@"disabledValue=%s",(disabledValue ? "YES" : "NO"));
      if (!disabledValue)
        {
          BOOL wasFormSubmitted=[context _wasFormSubmitted];
          NSDebugMLLog(@"gswdync",@"wasFormSubmitted=%s",(wasFormSubmitted ? "YES" : "NO"));
          if (wasFormSubmitted)
            {
              BOOL invoked=NO;
              GSWComponent* component=[context component];
              BOOL isMultipleSubmitForm=[context _isMultipleSubmitForm];
              if (isMultipleSubmitForm)
                {
                  NSString* nameInContext=[self nameInContext:context];
                  NSString* formValue=[request formValueForKey:nameInContext];
                  NSDebugMLLog(@"gswdync",@"formValue=%@",formValue);
                  if (formValue)
                    invoked=YES;
                  else
                    {
                      NSDebugMLLog(@"gswdync",@"[request formValueKeys]=%@",[request formValueKeys]);
                    };
                }
              else
                invoked=YES;
              if (invoked)
                {
                  id actionValue=nil;
                  NSDebugMLLog0(@"gswdync",@"Invoked Object Found !!");
                  [context _setActionInvoked:1];
                  NS_DURING
                    {
                      NSDebugMLLog(@"gswdync",@"Invoked Object Found: action=%@",_action);
                      actionValue=[_action valueInComponent:component];
                    }
                  NS_HANDLER
                    {
                      LOGException0(@"exception in GSWSubmitButton invokeActionForRequest:inContext action");
                      LOGException(@"exception=%@",localException);
                      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                                              @"In GSWSubmitButton invokeActionForRequest:inContext action %@",
                                                                              _action);
                      LOGException(@"exception=%@",localException);
                      [localException raise];
                    }
                  NS_ENDHANDLER;
                  if (actionValue)
                    element=actionValue;
                  if (element)
                    {
                      if (![element isKindOfClass:[GSWComponent class]]) //TODO GSWComponent or Element ?
                        {
                          ExceptionRaise0(@"GSWSubmitButton",@"Invoked element return a not GSWComponent element");
                        } 
                      else 
                        {
                          // call awakeInContext when _element is sleeping deeply
                          [(GSWComponent*)element ensureAwakeInContext:context];
                          /*
                            if (![_element context]) {
                            NSDebugMLLog(@"gswdync",@"_element sleeps, awake it = %@",_element);
                            [_element awakeInContext:context];
                            } else {
                            [_element awakeInContext:context];
                            }
                          */
                        }
                    }
                  /* ???
                     if (!_element)
                     _element=[context page];
                  */
                };
            };
        };
    }
  NS_HANDLER
    {
      LOGException0(@"exception in GSWSubmitButton invokeActionForRequest:inContext");
      LOGException(@"exception=%@",localException);
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"In GSWSubmitButton invokeActionForRequest:inContext");
      LOGException(@"exception=%@",localException);
      [localException raise];
    }
  NS_ENDHANDLER;
  //if (![context _wasActionInvoked] && [[[context elementID] parentElementIDString] compare:[context senderID]]!=NSOrderedAscending)
  if (![context _wasActionInvoked] && [(GSWElementIDString*)[[context elementID] parentElementIDString] isSearchOverForSenderID:[context senderID]])
    {
      LOGError(@"Action not invoked at the end of %@ (id=%@) senderId=%@",
               [self class],
               [context elementID],
               [context senderID]);
    };
  GSWStopElement(context);
  LOGObjectFnStop();
  return element;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //Does Nothing ?
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);
  GSWStopElement(context);
};
 
//--------------------------------------------------------------------
-(void)appendNameToResponse:(GSWResponse*)response
                  inContext:(GSWContext*)context
{
  //OK
  //Here we call parent (GSWInput) method instead of doing it by ourself (as GSW)
  [super appendNameToResponse:response
         inContext:context];
};

//--------------------------------------------------------------------
-(void)_appendActionClassAndNameToResponse:(GSWResponse*)response
                                 inContext:(GSWContext*)context
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

