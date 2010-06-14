/** GSWAction.m - <title>GSWeb: Class GSWAction</title>

   Copyright (C) 1999-2006 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 1999
   
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
#include <GNUstepBase/NSObject+GNUstepBase.h>

//====================================================================
@implementation GSWAction

//--------------------------------------------------------------------
-(id)initWithRequest:(GSWRequest*)aRequest
{
  if ((self=[super init]))
    {
      _context = RETAIN([GSWApp createContextForRequest:aRequest]);
      [GSWApp _setContext:_context]; //NDFN
      [self _initializeRequestSessionIDInContext:_context];
    };

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

  if (![_context isSessionDisabled])   // TODO:check if wo does it like that.
    {
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
                  //No Exception if session can't be restored !
                }
              NS_HANDLER
                {
                  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"in session create/restore");
                  //No Exception if session can't be restored !
                  session=nil;
                }
              NS_ENDHANDLER;
            };
        };
    };

  return session;
};

//--------------------------------------------------------------------
-(GSWSession*)existingSessionWithSessionID:(NSString*)aSessionID
{
  //OK
  GSWSession* session=nil;
  BOOL hasSession=NO;

  if (![_context isSessionDisabled])
    {
      hasSession=[_context hasSession];
      if (hasSession)
        session=[_context existingSession];
      if (!session)
        {
          if (aSessionID)
            {
              NS_DURING
                {
                  session=[GSWApp restoreSessionWithID:aSessionID
                                  inContext:_context];
                  //No Exception if session can't be restored !
                }
              NS_HANDLER
                {
                  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"in session create/restore");
                  //No Exception if session can't be restored !
                  session=nil;
                }
              NS_ENDHANDLER;
            };
        };
    };

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

  NS_DURING
    {
      NSAssert(_context,@"No Context");
      component=[[GSWApplication application]pageWithName:pageName
                                             inContext:_context];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In pageWithName:inContext:");
      [localException raise];
    };
  NS_ENDHANDLER;

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
  actionSelName=[actionName stringByAppendingString:@"Action"];

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

  request=[aContext request];

  sessionID=[self sessionIDForRequest:request];
  if (sessionID)
    {
      [aContext _setRequestSessionID:sessionID];
    };

};

//--------------------------------------------------------------------
-(void)setLanguages:(NSArray*)languages
{
  [_context _setLanguages:languages];
}

//--------------------------------------------------------------------
-(NSArray*)languages
{
  return [_context languages];
}

//--------------------------------------------------------------------
-(GSWContext*)context
{
  return _context;
};

-(GSWContext*)_context
{
  //OK
  return _context;
};

//--------------------------------------------------------------------
-(GSWSession*)session
{
  return [self _session];
};

//--------------------------------------------------------------------
-(GSWSession*)_session
{
  return [_context session];
};

//--------------------------------------------------------------------
-(void)logWithString:(NSString*)string
{
  [GSWApp logString:string];
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [GSWApp logWithFormat:aFormat
              arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)logWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [GSWApp logWithFormat:aFormat
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
  va_list ap;
  va_start(ap,aFormat);
  [[GSWApplication application]debugWithFormat:aFormat
                               arguments:ap];
  va_end(ap);
};

@end


