/** GSWDirectAction.m - <title>GSWeb: Class GSWDirectAction</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
   
   $Revision$
   $Date$
   $Id$

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
@implementation GSWDirectAction

//--------------------------------------------------------------------
-(id)initWithRequest:(GSWRequest*)aRequest
{
  LOGObjectFnStart();
  if ((self=[super initWithRequest:aRequest]))
    {
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  [super dealloc];
};

//--------------------------------------------------------------------
-(id <GSWActionResults>)performActionNamed:(NSString*)actionName
{
  //OK
  id<GSWActionResults> actionResult=nil;
  SEL actionSel=NULL;
  LOGObjectFnStart();
  actionSel=[self _selectorForActionNamed:actionName];
  NSDebugMLLog(@"requests",@"actionSel=%p",(void*)actionSel);
  if (!actionSel)
    {
      //TODO exception
      LOGError(@"No selector for action: %@ (%@Action)",actionName,actionName);//TODO
      actionResult=[self defaultAction];//No ??
    }
  else
    {
      NS_DURING
        {
          actionResult=[self performSelector:actionSel];
          NSDebugMLLog(@"requests",
                       @"_actionResult=%@ class=%@",
                       actionResult,
                       [(NSObject*)actionResult class]);
        }
      NS_HANDLER
        {
          LOGException(@"%@ (%@)",
                       localException,
                       [localException reason]);
          localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                                  @"In performSelector: class: %@ actionName: %@",
                                                                  [self class],actionName);
          [localException raise];
        };
      NS_ENDHANDLER;
    };
  LOGObjectFnStop();
  return actionResult;
};

//--------------------------------------------------------------------
-(NSString*)sessionIDForRequest:(GSWRequest*)aRequest
{
  NSString* sessionID = nil;
  NSDebugMLog(@"aRequest=%@",aRequest);
  sessionID = [aRequest sessionIDFromValuesOrCookieByLookingForCookieFirst:NO];
  NSDebugMLog(@"sessionID=%@",sessionID);
  return sessionID;
}

//--------------------------------------------------------------------
-(id<GSWActionResults>)defaultAction
{
  GSWComponent* component=[self pageWithName:nil];
  GSWResponse* response=[component generateResponse];
  [response disableClientCaching];
  return response;
};

@end

//====================================================================
@implementation GSWDirectAction (GSWTakeValuesConvenience)

//NDFN: return additional path elements
-(NSArray*)additionalRequestPathArray
{
  return [GSWDirectActionRequestHandler 
           additionalRequestPathArrayFromRequest:[self request]];
};

//--------------------------------------------------------------------
-(void)takeFormValueArraysForKeyArray:(NSArray*)keyArray
{
  GSWRequest* request=[self request];
  if (request)
    {
      int count=[keyArray count];
      int i=0;
      for(i=0;i<count;i++)
        {
          NSString* key=[keyArray objectAtIndex:i];
          NSArray* v=[request formValuesForKey:key];
          [self takeValue:v
                forKey:key];
        };      
    }
};

//--------------------------------------------------------------------
-(void)takeFormValuesForKeyArray:(NSArray*)keyArray
{
  GSWRequest* request=[self request];
  if (request)
    {
      int count=[keyArray count];
      int i=0;
      for(i=0;i<count;i++)
        {
          NSString* key=[keyArray objectAtIndex:i];
          id v=[request formValueForKey:key];
          [self takeValue:v
                forKey:key];
        }
    };
};

//--------------------------------------------------------------------
-(void)takeFormValueArraysForKeys:(NSString*)firstKey,...
{
  GSWRequest* request=[self request];
  if (request)
    {
      va_list ap=NULL;
      id key=nil;
      va_start(ap, firstKey);
      key = firstKey;
      while(key)
        {
          NSArray* v=[request formValuesForKey:key];
          [self takeValue:v
                forKey:key];
          key = va_arg(ap,id);
        };
      va_end(ap);
    }
};

//--------------------------------------------------------------------
-(void)takeFormValuesForKeys:(NSString*)firstKey,...
{
  GSWRequest* request=[self request];
  if (request)
    {
      va_list ap=NULL;
      id key=nil;
      va_start(ap, firstKey);
      key = firstKey;
      while(key)
        {
          id v=[request formValueForKey:key];
          [self takeValue:v
                forKey:key];
          key = va_arg(ap,id);
        };
      va_end(ap);
    }
};

@end

