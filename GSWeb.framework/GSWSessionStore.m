/** GSWSessionStore.m - <title>GSWeb: Class GSWSessionStore</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

static const char rcsId[]="$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWSessionStore

//--------------------------------------------------------------------
-(id)init
{
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      _usedIDs=[NSMutableSet new];
      _lock=[NSRecursiveLock new];
      _timeOutManager=[GSWSessionTimeOutManager new];
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
  GSWLogC("Dealloc GSWSessionStore: usedIDs");
  DESTROY(_usedIDs);
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
  BOOL sessionUsed=YES;
  NSDate* limit=[NSDate dateWithTimeIntervalSinceNow:60];
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"aSessionID=%@",aSessionID);
  NSDebugMLLog(@"sessions",@"usedIDs=%@",_usedIDs);
  NSDebugMLLog(@"sessions",@"self=%@",self);
  NSDebugMLLog(@"sessions",@"[NSDate date]=%@",[NSDate date]);
  NSDebugMLLog(@"sessions",@"limit=%@",limit);
  NSDebugMLLog(@"sessions",@"[[NSDate date]compare:limit]==NSOrderedAscending=%d",
               (int)([[NSDate date]compare:limit]==NSOrderedAscending));
  
  while(!session && sessionUsed && [[NSDate date]compare:limit]==NSOrderedAscending)
    {
      BOOL tmpUsed=NO;
      if ([self tryLock])
        {
          tmpUsed=[_usedIDs containsObject:aSessionID];
          if (tmpUsed)
            [self unlock];
          else
            {
              NS_DURING
                {
                  session=[self _checkOutSessionWithID:aSessionID
                                request:aRequest];
                }
              NS_HANDLER
                {
                  NSDebugMLLog(@"sessions",@"Can't checkOutSessionID=%@",aSessionID);
                  if ([[localException name]isEqualToString:@"GSWSessionStoreException"])
                    sessionUsed=YES;
                }
              NS_ENDHANDLER;
              [self unlock];
              sessionUsed=NO;
              NSDebugMLLog(@"sessions",@"session=%@",session);
            };
        };
    };
  NSDebugMLLog(@"sessions",@"session=%@",session);
  LOGObjectFnStop();
  return session;
};

//--------------------------------------------------------------------
-(void)checkInSessionForContext:(GSWContext*)aContext
{
  //OK
  LOGObjectFnStart();
  if ([self tryLock])
    {
      NS_DURING
        {
          [self _checkInSessionForContext:aContext];
        }
      NS_HANDLER
        {
          localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                   @"In _checkInSessionForContext:");
          LOGException(@"%@ (%@)",localException,[localException reason]);
          //TODO
          [self unlock];
          [localException raise];
        }
      NS_ENDHANDLER;
      [self unlock];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** Should be Locked **/
-(void)_checkInSessionForContext:(GSWContext*)aContext
{
  GSWSession* session=nil;
  LOGObjectFnStart();
  session=[aContext existingSession];
  NSDebugMLLog(@"sessions",@"session=%@",session);
  if (!session)
    {
      [NSException raise:@"IllegalStateException"
                   format:@"Current context has no existing session. Can't save session"];
    }
  else
    {
      NSString* sessionID=nil;
      BOOL sessionIsTerminating=NO;
      NSTimeInterval sessionTimeOut=0;
          

      sessionID=[session sessionID];

      NSAssert(sessionID,@"No _sessionID!");
      NSDebugMLLog(@"sessions",@"_sessionID=%@",sessionID);

      GSWLogAssertGood(session);

      sessionIsTerminating=[session isTerminating];
      
      [session setDistributionEnabled:sessionIsTerminating];

      if (sessionIsTerminating)
        {
          NS_DURING
            {
              [self removeSessionWithID:sessionID];
            }
          NS_HANDLER
            {
              localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                       @"In removeSessionWithID:");
              LOGException(@"%@ (%@)",localException,[localException reason]);
              [localException raise];
            }
          NS_ENDHANDLER;
        }
      else
        {
          NS_DURING
            {
              [self saveSessionForContext:aContext];
            }
          NS_HANDLER
            {
              localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                       @"In saveSessionForContext:");
              LOGException(@"%@ (%@)",localException,[localException reason]);
              [localException raise];
            }
          NS_ENDHANDLER;
        };

      sessionTimeOut=[session timeOut];
      NSDebugMLLog(@"sessions",@"sessionTimeOut=%ld",(long)sessionTimeOut);

      [_timeOutManager updateTimeOutForSessionWithID:sessionID
                       timeOut:sessionTimeOut];

      GSWLogAssertGood(session);
      NSDebugMLLog(@"sessions",@"session=%@",session);
      NS_DURING
        {
          [session _releaseAutoreleasePool];
        }
      NS_HANDLER
        {
          localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                   @"In [_session _releaseAutoreleasePool]");
          LOGException(@"%@ (%@)",localException,[localException reason]);
          [localException raise];
        }
      NS_ENDHANDLER;
      GSWLogAssertGood(session);
      NSDebugMLLog(@"sessions",@"session=%@",session);
      sessionID=[session sessionID];
      GSWLogAssertGood(session);
      NSDebugMLLog(@"sessions",@"sessionID=%@",sessionID);
      NS_DURING
        {
          [self _checkinSessionID:sessionID];
        }
      NS_HANDLER
        {
          localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                   @"In _checkinSessionID");
          LOGException(@"%@ (%@)",localException,[localException reason]);
          [localException raise];
        }
      NS_ENDHANDLER;
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** Should be Locked **/
-(GSWSession*)_checkOutSessionWithID:(NSString*)aSessionID
                             request:(GSWRequest*)aRequest
{
  GSWSession* session=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"aSessionID=%@",aSessionID);
  NSDebugMLLog(@"sessions",@"self=%@",self);

  NSDebugMLog0(@"starting:_checkoutSessionID");
  [self _checkoutSessionID:aSessionID];
  NSDebugMLog0(@"end of:_checkoutSessionID");
  NSDebugMLog0(@"starting:restoreSessionWithID");
  session=[self restoreSessionWithID:aSessionID
                request:aRequest];
  NSDebugMLog0(@"end of:restoreSessionWithID");
  if (session)
    [session _createAutoreleasePool];
  else
    [self _checkinSessionID:aSessionID];

  NSDebugMLLog(@"sessions",@"session=%@",session);
  LOGObjectFnStop();
  return session;
};

//--------------------------------------------------------------------
/** Should be Locked **/
-(void)_checkinSessionID:(NSString*)aSessionID
{
  LOGObjectFnStart();
  [_usedIDs removeObject:aSessionID];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** Should be Locked **/
-(void)_checkoutSessionID:(NSString*)aSessionID
{
  //OK
  LOGObjectFnStart();
  if ([_usedIDs containsObject:aSessionID])
    {
      NSDebugMLLog(@"sessions",@"SessionID=%@ already in use",aSessionID);
      LOGException0(@"NSGenericException session used");
      [NSException raise:@"GSWSessionStoreException"
                   format:@"Session %@ used",
                   aSessionID];
    }
  else
    {
      [_usedIDs addObject:aSessionID];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"lockn=%d",_lockn);
  TmpUnlock(_lock);
#ifndef NDEBUG
  _lockn--;
#endif
  NSDebugMLLog(@"sessions",@"lockn=%d",_lockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(BOOL)tryLock
{
  BOOL locked=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"lockn=%d",_lockn);
  locked=TmpTryLockBeforeDate(_lock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
  if (locked)
    _lockn++;
#endif
  NSDebugMLLog(@"sessions",@"lockn=%d",_lockn);
  LOGObjectFnStop();
  return locked;
};

//--------------------------------------------------------------------
-(void)lock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"lockn=%d",_lockn);
  TmpLockBeforeDate(_lock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
  _lockn++;
#endif
  NSDebugMLLog(@"sessions",@"lockn=%d",_lockn);
  LOGObjectFnStop();
};

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
@implementation GSWSessionStore (GSWSessionStoreA)
-(BOOL)_isSessionIDCheckedOut:(NSString*)aSessionID
{
  //OK
  BOOL checkedOut=NO;
  LOGObjectFnStart();
  checkedOut=[_usedIDs containsObject:aSessionID];
  LOGObjectFnStop();
  return checkedOut;
};

@end

//====================================================================
@implementation GSWSessionStore (GSWSessionStoreB)
-(void)_validateAPI
{
  LOGObjectFnNotImplemented();	//TODOFN
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


