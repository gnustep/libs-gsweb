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
  if ((self=[super init]))
    {
      _context=[GSWContext contextWithRequest:aRequest];
      [GSWApp _setContext:_context]; //NDFN
      [self _initializeRequestSessionIDInContext:_context];
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_context);
  [super dealloc];
};

//--------------------------------------------------------------------
-(GSWRequest*)request
{
  return [_context request];
};

//--------------------------------------------------------------------
-(GSWSession*)existingSession
{
  //OK
  GSWSession* session=nil;
  BOOL hasSession=NO;
  LOGObjectFnStart();
  hasSession=[_context hasSession];
  if (hasSession)
    session=[_context existingSession];
  if (!session)
    {
      NSString* sessionID=nil;
      sessionID=[[self request] sessionID];
      if (sessionID)
        {
          NS_DURING
            {
              NSDebugMLLog(@"requests",@"sessionID=%@",sessionID);
              session=[GSWApp restoreSessionWithID:sessionID
                              inContext:_context];
              //No Exception if session can't be restored !
            }
          NS_HANDLER
            {
              localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"in session create/restore");
              LOGException(@"exception=%@",localException);
              //No Exception if session can't be restored !
              session=nil;
            }
          NS_ENDHANDLER;
        };
    };
  LOGObjectFnStop();
  return session;
};

//--------------------------------------------------------------------
-(GSWSession*)existingSessionWithSessionID:(NSString*)aSessionID
{
  //OK
  GSWSession* session=nil;
  BOOL hasSession=NO;
  LOGObjectFnStart();
  hasSession=[_context hasSession];
  if (hasSession)
    session=[_context existingSession];
  if (!session)
    {
      if (aSessionID)
        {
          NS_DURING
            {
              NSDebugMLLog(@"requests",@"aSessionID=%@",aSessionID);
              session=[GSWApp restoreSessionWithID:aSessionID
                              inContext:_context];
              //No Exception if session can't be restored !
            }
          NS_HANDLER
            {
              localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"in session create/restore");
              LOGException(@"exception=%@",localException);
              //No Exception if session can't be restored !
              session=nil;
            }
          NS_ENDHANDLER;
        };
    };
  LOGObjectFnStop();
  return session;
};

//--------------------------------------------------------------------
-(GSWSession*)session
{
  BOOL hasSession=NO;
  GSWSession* session=nil;
  LOGObjectFnStart();
  hasSession=[_context hasSession];
  if (hasSession)
    session=[_context existingSession];
  if (!session)
    {
      NSString* sessionID=nil;
      sessionID=[[self request] sessionID];
      if (sessionID)
        {
          NS_DURING
            {
              session=[GSWApp restoreSessionWithID:sessionID
                              inContext:_context];
            }
          NS_HANDLER
            {
              localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"in session create/restore");
              LOGException(@"exception=%@",localException);
              [localException raise];
            };
          NS_ENDHANDLER;
          if (!session)
            {
              ExceptionRaise(@"GSWDirectAction",
                             @"Unable to restore sessionID %@.",
                             sessionID);
            };
        }
      else
        {
          // No Session ID: Create a new Session
          session=[_context session];
        };
    };
  LOGObjectFnStop();
  return session;
};

//--------------------------------------------------------------------
//	application

-(GSWApplication*)application 
{
  return [GSWApplication application];
};

//--------------------------------------------------------------------
-(GSWComponent*)pageWithName:(NSString*)pageName
{
  //OK
  GSWComponent* component=nil;
  LOGObjectFnStart();
  NS_DURING
    {
      component=[[GSWApplication application]pageWithName:pageName
                                             inContext:_context];
    }
  NS_HANDLER
    {
      LOGException(@"%@ (%@)",
                   localException,
                   [localException reason]);
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In pageWithName:inContext:");
      [localException raise];
    };
  NS_ENDHANDLER;
  LOGObjectFnStop();
  return component;
};

//--------------------------------------------------------------------
-(id <GSWActionResults>)performActionNamed:(NSString*)actionName
{
  //OK
  id<GSWActionResults> actionResult=nil;
  NSString* actionSelName=nil;
  SEL actionSel=NULL;
  LOGObjectFnStart();
  actionSelName=[NSString stringWithFormat:@"%@Action",actionName];
  NSDebugMLLog(@"requests",@"actionSelName=%@",actionSelName);
  actionSel=NSSelectorFromString(actionSelName);
  NSDebugMLLog(@"requests",@"actionSel=%p",(void*)actionSel);
  if (actionSel)
    {
      NS_DURING
        {
          actionResult=[self performSelector:actionSel];
          NSDebugMLLog(@"requests",
                       @"_actionResult=%@ class=%@",
                       actionResult,
                       [(id)actionResult class]);
        }
      NS_HANDLER
        {
          LOGException(@"%@ (%@)",
                       localException,
                       [localException reason]);
          localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In performSelector:");
          [localException raise];
        };
      NS_ENDHANDLER;
    }
  else
    {
      LOGError(@"No selector for: %@",actionSelName);//TODO
      actionResult=[self defaultAction];//No ??
    };
  LOGObjectFnStop();
  return actionResult;
};

//--------------------------------------------------------------------
-(id)defaultAction
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return nil;//??
};

//--------------------------------------------------------------------
-(NSString*)sessionIDForRequest:(GSWRequest*)aRequest
{
  NSString* sessionID = nil;
  NSDebugMLog(@"aRequest=%@",aRequest);
  if(aRequest)
    sessionID = [aRequest sessionIDFromValuesOrCookieByLookingForCookieFirst:NO];
  NSDebugMLog(@"sessionID=%@",sessionID);
  return sessionID;
}

//--------------------------------------------------------------------
-(void)_initializeRequestSessionIDInContext:(GSWContext*)aContext
{
  GSWRequest* request=nil;
  NSString* sessionID=nil;
  LOGObjectFnStart();
  request=[aContext request];
  NSDebugMLog(@"request=%@",request);
  sessionID=[request formValueForKey:GSWKey_SessionID[GSWebNamingConv]];
  NSDebugMLog(@"sessionID=%@",sessionID);
  if (!sessionID)
    {
      sessionID=[request cookieValueForKey:GSWKey_SessionID[GSWebNamingConv]];
      NSDebugMLog(@"sessionID=%@",sessionID);
    };
  if (sessionID)
    {
      [aContext _setRequestSessionID:sessionID];
    };
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWDirectAction (GSWDirectActionA)
-(GSWContext*)_context
{
  //OK
  return _context;
};

//--------------------------------------------------------------------
-(GSWSession*)_session
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
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
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)takeFormValuesForKeyArray:(NSArray*)keyArray
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)takeFormValueArraysForKeys:(NSString*)firstKey,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)takeFormValuesForKeys:(NSString*)firstKey,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWDirectAction (GSWDebugging)

//--------------------------------------------------------------------
-(void)logWithString:(NSString*)string
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)format,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(void)logWithFormat:(NSString*)format,...
{
  LOGClassFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_debugWithString:(NSString*)string
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)format,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end


