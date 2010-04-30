/** GSWSessionStore.m - <title>GSWeb: Class GSWSessionStore</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   Written by:	David Wetzel <dave@turbocat.de>
   
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
#include <time.h>
#include <unistd.h>

//====================================================================
@implementation GSWSessionStore

//--------------------------------------------------------------------
-(id)init
{
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      _lock=[NSRecursiveLock new];
      _timeOutManager=[GSWSessionTimeOutManager new];
      NSDebugMLLog(@"sessions",@"GSWSessionStore self=%p class=%@",self,[self class]);
      [_timeOutManager setCallBack:@selector(removeSessionWithID:)
                       target:self];
      [_timeOutManager startHandleTimerRefusingSessions];
      [self _validateAPI];
    };
  LOGObjectFnStop();
  return self;   
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWSessionStore");
  GSWLogC("Dealloc GSWSessionStore: lock");
  DESTROY(_lock);
  GSWLogC("Dealloc GSWSessionStore: timeOutManager");
  DESTROY(_timeOutManager);
  GSWLogC("Dealloc GSWSessionStore Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWSessionStore");
};

//--------------------------------------------------------------------
/** Abstract **/
-(GSWSession*)removeSessionWithID:(NSString*)aSessionID
{
  NSDebugMLLog(@"sessions",@"self=%p class=%@",self,[self class]);
  [self subclassResponsibility: _cmd];
  return nil;
};

//--------------------------------------------------------------------
/** Abstract **/
-(GSWSession*)restoreSessionWithID:(NSString*)aSessionID
                           request:(GSWRequest*)aRequest
{
  [self subclassResponsibility: _cmd];
  return nil;
};

//--------------------------------------------------------------------
/** Abstract **/
-(void)saveSessionForContext:(GSWContext*)aContext
{
  [self subclassResponsibility: _cmd];
};


//--------------------------------------------------------------------
-(GSWSession*)checkOutSessionWithID:(NSString*)aSessionID
                            request:(GSWRequest*)aRequest
{
  GSWSession* session=nil;
  
  session = [self restoreSessionWithID:aSessionID
                               request:aRequest];
  
  if (!session) {
    return nil;
  }
  
  SYNCHRONIZED(_lock) {
    
    BOOL isCheckedOut = YES;
    
    GSWSessionTimeOut* entry = [_timeOutManager sessionTimeOutForSessionID:aSessionID];
    //int expirationTime=(int)[entry sessionTimeOutValue];//seconds
    
    isCheckedOut=[entry isCheckedOut]; // See if session is used
    
    if (!isCheckedOut) 
    {
      session = [self restoreSessionWithID:aSessionID
                                   request:aRequest];
      if (session) {        
        // If sessionID has Changed, re-find entry
        if (![[session sessionID] isEqualToString:aSessionID])
        {
          [NSException raise:@"IllegalStateException"
                      format:@"How can a session ID change? -- dw"];
          
        }
        isCheckedOut = [entry isCheckedOut];
        
        if (!isCheckedOut) 
        {                          
          [session _createAutoreleasePool];
          [entry setIsCheckedOut:YES];
        }
      }
    }
  }
  END_SYNCHRONIZED;
  
  return session;
}

//--------------------------------------------------------------------
-(void)checkInSessionForContext:(GSWContext*)aContext
{
  SYNCHRONIZED(_lock) {
    [self _checkInSessionForContext:aContext];
  }
  END_SYNCHRONIZED;
}

//--------------------------------------------------------------------
/** Should be Locked **/
-(void)_checkInSessionForContext:(GSWContext*)aContext
{
  GSWSession* session=nil;
  
  session=[aContext existingSession];
  if (!session)
  {
    [NSException raise:@"IllegalStateException"
                format:@"Current context has no existing session. Can't save session"];
  }
  else
  {
    NS_DURING 
    {
      
      NSString* sessionID=nil;
      BOOL sessionIsTerminating=NO;
      NSTimeInterval sessionTimeOut=0;
      GSWSessionTimeOut* entry=nil;
      
      [session retain];
      
      sessionID=[session sessionID];
      
      NSAssert(sessionID,@"No _sessionID!");
      
      sessionIsTerminating=[session isTerminating];
      
      [session setDistributionEnabled:sessionIsTerminating];
      
      entry=[_timeOutManager sessionTimeOutForSessionID:sessionID];
      [entry setIsCheckedOut:NO];
      
      if (sessionIsTerminating)
      {
        [self removeSessionWithID:sessionID];
      } else {
        [self saveSessionForContext:aContext];
      }
      
      sessionTimeOut=[session timeOut];
      
      [_timeOutManager updateTimeOutForSessionWithID:sessionID
                                             timeOut:sessionTimeOut];
      
      // why do we do that?
      //[session _releaseAutoreleasePool];

      [session release];
      session = nil;
    } NS_HANDLER {
      [session release];
      session = nil;
      [localException raise];
    } NS_ENDHANDLER;
  }
}

//--------------------------------------------------------------------
-(void)unlock
{
  [_lock unlock];
}
//--------------------------------------------------------------------
-(void)lock
{
  [_lock lock];
}

@end

//====================================================================
@implementation GSWSessionStore (GSWSessionStoreCreation)

//--------------------------------------------------------------------
+(GSWSessionStore*)serverSessionStore
{
  return [[GSWServerSessionStore new] autorelease];
};

@end

//====================================================================
@implementation GSWSessionStore (GSWSessionStoreOldFn)
/*
//--------------------------------------------------------------------
//	cookieSessionStoreWithDistributionDomain:secure:

+(GSWSessionStore*)cookieSessionStoreWithDistributionDomain:(NSString*)domain_
													secure:(BOOL)flag_
{
  return [[[GSWSessionStoreCookie alloc] initWithDistributionDomain:domain_
									   secure:flag_] autorelease];
};

//--------------------------------------------------------------------
//	pageSessionStore

+(GSWSessionStore*)pageSessionStore 
{
  return [[GSWSessionStorePage new] autorelease];
};

*/
//--------------------------------------------------------------------
//	restoreSession

-(GSWSession*)restoreSession
{
  //Does Nothing
  return nil;
};

//--------------------------------------------------------------------
//	saveSession:

-(void)saveSession:(GSWSession*)session
{
  //Does Nothing
};

@end
//====================================================================
@implementation GSWSessionStore (GSWSessionStoreB)
-(void)_validateAPI
{
  LOGObjectFnStart();
  if ([self class]==[GSWSessionStore class])
    {
      [NSException raise:NSGenericException
                   format:@"Can't allocate a direct GSWSessionStore instance because some methods need to be implemented by subclasses"];
    };
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};

@end


//====================================================================
@implementation GSWSessionStore (GSWSessionStoreInfo)

-(BOOL)containsSessionID:(NSString*)aSessionID
{
  return NO;
};

-(NSArray *)allSessionIDs
{
  return nil;
}

@end


