/** GSWAction.m - <title>GSWeb: Class GSWAction</title>

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
@implementation GSWAction

//--------------------------------------------------------------------
-(id)initWithRequest:(GSWRequest*)aRequest
{
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      _context=[[GSWApplication application]createContextForRequest:aRequest];
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
              ExceptionRaise(@"GSWAction",
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
+(BOOL)_isActionNamed:(NSString*)actionName
        actionOfClass:(Class)actionClass
{
  return ([self _selectorForActionNamed:actionName
                inClass:actionClass]!=NULL);
};

//--------------------------------------------------------------------
+(SEL)_selectorForActionNamed:(NSString*)actionName
                      inClass:(Class)class
{
  NSString* actionSelName=nil;
  SEL actionSel=NULL;
  actionSelName=[NSString stringWithFormat:@"%@Action",actionName];
  NSDebugMLLog(@"requests",@"actionSelName=%@",actionSelName);
  actionSel=NSSelectorFromString(actionSelName);
  return actionSel;
}

//--------------------------------------------------------------------
-(SEL)_selectorForActionNamed:(NSString*)actionName
{
  return [[self class]_selectorForActionNamed:actionName
                      inClass:[self class]];
}

//--------------------------------------------------------------------
-(id <GSWActionResults>)performActionNamed:(NSString*)actionName
{
  return [self subclassResponsibility: _cmd];
};

//--------------------------------------------------------------------
/** Returns YES if self reponds to actionName **/
-(BOOL)isActionNamed:(NSString*)actionName
{
  SEL actionSel=[self _selectorForActionNamed:actionName];
  if (actionSel)
    return [self respondsToSelector:actionSel];
  else
    return NO;
}

//--------------------------------------------------------------------
-(NSString*)sessionIDForRequest:(GSWRequest*)aRequest
{
  return [self subclassResponsibility: _cmd];
}

//--------------------------------------------------------------------
-(void)_initializeRequestSessionIDInContext:(GSWContext*)aContext
{
  GSWRequest* request=nil;
  NSString* sessionID=nil;

  LOGObjectFnStart();

  request=[aContext request];
  NSDebugMLog(@"request=%@",request);

  sessionID=[self sessionIDForRequest:request];
  if (sessionID)
    {
      [aContext _setRequestSessionID:sessionID];
    };

  LOGObjectFnStop();
};


-(void)setLanguages:(NSArray*)languages
{
  [_context _setLanguages:languages];
}

-(NSArray*)languages
{
  return [_context languages];
}

@end

//====================================================================
@implementation GSWAction (GSWActionA)
-(GSWContext*)_context
{
  //OK
  return _context;
};

//--------------------------------------------------------------------
-(GSWSession*)_session
{
  return nil;//TODO?
};

@end

//====================================================================
@implementation GSWAction (GSWDebugging)

//--------------------------------------------------------------------
-(void)logWithString:(NSString*)string
{
  [GSWApplication logWithFormat:@"%@",string];
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)aFormat,...
{
  va_list ap=NULL;
  va_start(ap,aFormat);
  [GSWApplication logWithFormat:aFormat
                  arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)logWithFormat:(NSString*)aFormat,...
{
  va_list ap=NULL;
  va_start(ap,aFormat);
  [GSWApplication logWithFormat:aFormat
                  arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(void)_debugWithString:(NSString*)string
{
  [[GSWApplication application]debugWithString:string];
};

//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)aFormat,...
{
  va_list ap=NULL;
  va_start(ap,aFormat);
  [[GSWApplication application]debugWithFormat:aFormat
                               arguments:ap];
  va_end(ap);
};

@end


