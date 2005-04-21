/** GSWSessionTimeOutManager.m - <title>GSWeb: Class GSWSessionTimeOutManager</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 1999
   
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
#include "GSWSessionTimeOut.h"

#define SESSION_TIMEOUT_TIMER_INTERVAL_MIN	15	// 15s minimum
#define REFUSING_NEW_SESSION_TIMER_INTERVAL	5	// 5s minimum
#define REFUSING_NEW_SESSION_APPLICATION_END	10	// 10s

//====================================================================
@implementation GSWSessionTimeOutManager
-(id)init
{
  //OK
  if ((self=[super init]))
    {
      _sessionOrderedTimeOuts=[NSMutableArray new];
      NSDebugMLLog(@"sessions",@"INIT self=%p",self);
      NSDebugMLLog(@"sessions",@"self=%p _sessionOrderedTimeOuts %p=%@",
                   self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);
      _sessionTimeOuts=[NSMutableDictionary new];
      //	  selfLock=[NSRecursiveLock new];
      _selfLock=[NSLock new];
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_sessionOrderedTimeOuts);
  DESTROY(_sessionTimeOuts);
  //Do Not Retain ! DESTROY(target);
  DESTROY(_timer);
  DESTROY(_selfLock);
  [super dealloc];
};

// Must be locked
-(GSWSessionTimeOut*)_sessionTimeOutForSessionID:(NSString*)sessionID
{
  GSWSessionTimeOut* sessionTimeOut=nil;
  LOGObjectFnStart();
  sessionTimeOut=[_sessionTimeOuts objectForKey:sessionID];
  if (sessionTimeOut)
    {
      // Retain/autorelease it so it won't be destroyed too soon
      RETAIN(sessionTimeOut);
      AUTORELEASE(sessionTimeOut);
    }
  else
    {
      sessionTimeOut=[GSWSessionTimeOut timeOutWithSessionID:sessionID
                                        lastAccessTime:[NSDate timeIntervalSinceReferenceDate]
                                        sessionTimeOut:[GSWApplication sessionTimeOutValue]];
      [_sessionTimeOuts setObject:sessionTimeOut
                        forKey:sessionID];
      [_sessionOrderedTimeOuts addObject:sessionTimeOut];
    };
  LOGObjectFnStop();
  return sessionTimeOut;
};

// Must not be locked
-(GSWSessionTimeOut*)sessionTimeOutForSessionID:(NSString*)sessionID
{
  GSWSessionTimeOut* sessionTimeOut=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      sessionTimeOut=[self _sessionTimeOutForSessionID:sessionID];
    }
  NS_HANDLER
    {
      NSLog(@"### exception ... %@", [localException reason]);
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return sessionTimeOut;
};

//--------------------------------------------------------------------
-(void)updateTimeOutForSessionWithID:(NSString*)sessionID
                             timeOut:(NSTimeInterval)timeOut
{
  //OK
  BOOL selfLocked=NO;
  BOOL targetLocked=NO;
  LOGObjectFnStart();
  [self lock];
  selfLocked=YES;  
  NS_DURING
    {
      NSTimer* timer=nil;
      GSWSessionTimeOut* sessionTimeOut=nil;
      NSDebugMLLog(@"sessions",@"timeOut=%ld",(long)timeOut);
      sessionTimeOut=[self _sessionTimeOutForSessionID:sessionID];
      NSDebugMLLog(@"sessions",@"sessionTimeOut=%@",sessionTimeOut);
      NSDebugMLLog(@"sessions",@"self=%p _sessionOrderedTimeOuts %p=%@",
                   self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);
      NSAssert(sessionTimeOut,@"No sessionTimeOut");

      [_sessionOrderedTimeOuts removeObject:sessionTimeOut];
      [sessionTimeOut setLastAccessTime:[NSDate timeIntervalSinceReferenceDate]];
      if (timeOut!=[sessionTimeOut sessionTimeOut])
        [sessionTimeOut setSessionTimeOut:timeOut];
      [_sessionOrderedTimeOuts addObject:sessionTimeOut];

      NSDebugMLLog(@"sessions",@"self=%p sessionOrderedTimeOuts %p=%@",
                   self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);
      NSDebugMLLog(@"sessions",@"sessionTimeOut=%@",sessionTimeOut);
      timer=[self resetTimer];
      NSDebugMLLog(@"sessions",@"timer=%@",timer);
      NSDebugMLLog(@"sessions",@"timer fireDate=%@",[timer fireDate]);
      if (timer)
        {
          [_target lock];
          targetLocked=YES;
          NS_DURING
            {
              [self addTimer:timer];
            }
          NS_HANDLER
            {
              NSLog(@"### exception from ... addTimer... %@", [localException reason]);
              LOGException(@"%@ (%@)",localException,[localException reason]);
              NSLog(@"### exception ... %@", [localException reason]);
              //TODO
              if (targetLocked)
                {
                  [_target unlock];
                  targetLocked=NO;
                };
              if (selfLocked)
                {
                  NSDebugMLLog(@"sessions",@"Unlock self");
                  [self unlock];
                  selfLocked=NO;
                };
              [localException raise];
            }
          NS_ENDHANDLER;
          
          if (targetLocked)
            {
              [_target unlock];
              targetLocked=NO;
            };
        };
    }
  NS_HANDLER
    {
      NSLog(@"### exception ... %@", [localException reason]);
      LOGException(@"%@ (%@)",localException,[localException reason]);
      //TODO
      if (selfLocked)
        {
          NSDebugMLLog(@"sessions",@"Unlock self");
          [self unlock];
          selfLocked=NO;
        };
      [localException raise];
    }
  NS_ENDHANDLER;
  if (selfLocked)
    {
      NSDebugMLLog(@"sessions",@"Unlock self");
      [self unlock];
      selfLocked=NO;
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)handleTimer:(id)aTimer
{
  //OK
  BOOL requestHandlingLocked=NO;
  BOOL selfLocked=NO;
  BOOL targetLocked=NO;
  [GSWApplication statusLogWithFormat:@"Start HandleTimer"];
//  NSDebugMLog(@"Start HandleTimer");
  NSDebugMLLog(@"sessions",@"timer=%@",aTimer);
  NSDebugMLLog(@"sessions",@"timer fireDate=%@",[aTimer fireDate]);
  NSDebugMLLog(@"sessions",@"timer tisn=%f",[[aTimer fireDate]timeIntervalSinceNow]);
//  LOGObjectFnStart();
  [GSWApp lockRequestHandling];
  requestHandlingLocked=YES;
  NS_DURING
    {
      [self lock];
      selfLocked=YES;
      NS_DURING
        {
          NSEnumerator *sessionTimeOutEnum = nil;
          GSWSessionTimeOut* sessionTimeOut=nil;
          NSTimeInterval now=[NSDate timeIntervalSinceReferenceDate];
          NSTimer* timer=nil;
          int removedNb=0;

/*
  if ([sessionOrderedTimeOuts count]>0)
  _sessionTimeOut=[sessionOrderedTimeOuts objectAtIndex:0];
*/
          NSDebugMLLog(@"sessions",@"self=%p aTimer=%p",self,aTimer);
          NSDebugMLLog(@"sessions",@"self=%p sessionOrderedTimeOuts %p=%@",
                       self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);
          NSDebugMLLog(@"sessions",@"now=%f",now);
		
          sessionTimeOutEnum = [_sessionOrderedTimeOuts objectEnumerator];

          while (/*_removedNb<20 && *//*sessionTimeOut && [sessionTimeOut timeOutTime]<_now*/
                 (sessionTimeOut = [sessionTimeOutEnum nextObject]))
            {
              if ([sessionTimeOut timeOutTime]<now) 
                {
                  id session=nil;
                  [_target lock];
                  targetLocked=YES;
                  NS_DURING
                    {
                      NSDebugMLLog(@"sessions",@"[sessionTimeOut sessionID]=%@",[sessionTimeOut sessionID]);
                      NSDebugMLLog(@"sessions",@"target [%@]=%@",[_target class],_target);
                      NSDebugMLLog(@"sessions",@"_callback=%@",NSStringFromSelector(_callback));
                      session=[_target performSelector:_callback
                                       withObject:[sessionTimeOut sessionID]];
                      NSDebugMLLog(@"sessions",@"session=%@",session);
                    }
                  NS_HANDLER
                    {
                      NSLog(@"### exception ... %@", [localException reason]);
                      LOGException(@"%@ (%@)",localException,[localException reason]);
                      //TODO                      
                      [_target unlock];
                      targetLocked=NO;
                      
                      timer=[self resetTimer];
                      NSDebugMLLog(@"sessions",@"timer=%@",timer);
                      NSDebugMLLog(@"sessions",@"timer fireDate=%@",[timer fireDate]);
                      if (timer)
                        [self addTimer:timer];
                      
                      [self unlock];
                      selfLocked=NO;
                      [GSWApp unlockRequestHandling];
                      requestHandlingLocked=NO;
                      [localException raise];
                    }
                  NS_ENDHANDLER;
                  [_target unlock];
                  targetLocked=NO;

                  NSDebugMLLog(@"sessions",@"session=%p",session);
                  NSLog(@"%s %d GSWSessionTimeOutMananger : before removeObject sessionID=%@ session = %p",
                        __FILE__,__LINE__,[sessionTimeOut sessionID],session);

                  if (sessionTimeOut)
                    {
                      // Remove sessionTimeOut anyway
                      [_sessionTimeOuts removeObjectForKey:[sessionTimeOut sessionID]];
                      //NSLog(@"%d %d removed from _sessionTimeOuts",__FILE__,__LINE__);
                      [_sessionOrderedTimeOuts removeObject:sessionTimeOut];
                      //NSLog(@"%s %d removed from _sessionOrderedTimeOuts",__FILE__,__LINE__);
                    };
                  
                  NSDebugMLLog(@"sessions",@"self=%p sessionOrderedTimeOuts %p=%@",
                               self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);
                  removedNb++;
                  
                  if (session)
                    {
                      //NSLog(@"%s %d will terminate session",__FILE__,__LINE__);
                      NSDebugMLLog(@"sessions",@"self=%p sessionOrderedTimeOuts %p=%@",
                                   self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);
                      [session _terminateByTimeout];
                      NSDebugMLLog(@"sessions",@"self=%p sessionOrderedTimeOuts %p=%@",
                                   self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);

                      //NSLog(@"%s %d session terminated",__FILE__,__LINE__);

                      /*
                        if ([sessionOrderedTimeOuts count]>0)
                        _sessionTimeOut=[sessionOrderedTimeOuts objectAtIndex:0];
                        else
                        _sessionTimeOut=nil;
                      */
                    }
                  else
                    sessionTimeOut=nil;
                };
            };
          
          timer=[self resetTimer];
          NSDebugMLLog(@"sessions",@"timer=%@",timer);
          NSDebugMLLog(@"sessions",@"timer fireDate=%@",[timer fireDate]);
          if (timer)
            [self addTimer:timer];
        }
      NS_HANDLER
        {
          LOGException(@"%@ (%@)",localException,[localException reason]);
          //TODO
          if (selfLocked)
            {
              [self unlock];
              selfLocked=NO;
            };
          if (requestHandlingLocked)
            {
              [GSWApp unlockRequestHandling];
              requestHandlingLocked=NO;
            };
          [localException raise];
        };
      NS_ENDHANDLER;
      NSDebugMLLog(@"sessions",@"self=%p sessionOrderedTimeOuts %p=%@",
                   self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);
      if (selfLocked)
        {
          [self unlock];
          selfLocked=NO;
        };
    }
  NS_HANDLER
    {
      LOGException(@"%@ (%@)",localException,[localException reason]);
      //TODO
      if (requestHandlingLocked)
        {
          [GSWApp unlockRequestHandling];
          requestHandlingLocked=NO;
        };
      [localException raise];
    };
  NS_ENDHANDLER;
  if (requestHandlingLocked)
    {
      [GSWApp unlockRequestHandling];
      requestHandlingLocked=NO;
    };
  //  LOGObjectFnStop();
  [GSWApplication statusLogWithFormat:@"Stop HandleTimer"];
//  NSDebugMLog(@"Stop HandleTimer");
};

//--------------------------------------------------------------------
-(NSTimer*)resetTimer
{
  NSTimer* newTimer=nil;
  GSWSessionTimeOut* sessionTimeOut=nil;
  LOGObjectFnStart();
//  [self lock];
  NS_DURING
    {
      NSTimeInterval now=[NSDate timeIntervalSinceReferenceDate];
      NSTimeInterval timerFireTimeInterval=[[_timer fireDate]timeIntervalSinceReferenceDate];

      NSDebugMLLog(@"sessions",@"self=%p sessionOrderedTimeOuts %p=%@",
                   self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);
      //NSLog(@"%s %d [_sessionOrderedTimeOuts count]=%d",__FILE__,__LINE__,[_sessionOrderedTimeOuts count]);
      if ([_sessionOrderedTimeOuts count]>0)
        {
          NSEnumerator* sessionOrderedTimeOutsEnum = [_sessionOrderedTimeOuts objectEnumerator];
          GSWSessionTimeOut* sessionTimeOutObject=nil;
          NSTimeInterval minTimeOut;

          sessionTimeOut = [_sessionOrderedTimeOuts objectAtIndex:0];
          minTimeOut = [sessionTimeOut timeOutTime];
          while ((sessionTimeOutObject = [sessionOrderedTimeOutsEnum nextObject])) 
            {
              if ([sessionTimeOutObject timeOutTime]<minTimeOut) 
                {
                  sessionTimeOut = sessionTimeOutObject;
                  minTimeOut = [sessionTimeOut timeOutTime];
                }
            }
          
          //sessionTimeOut=[_sessionOrderedTimeOuts objectAtIndex:0];
          
          // search for minimum timeouts

          NSDebugMLLog(@"sessions",@"sessionTimeOut=%@",sessionTimeOut);
          NSDebugMLLog(@"sessions",@"[_timer fireDate]=%@",[_timer fireDate]);
          NSDebugMLLog(@"sessions",@"[old timer isValide]=%s",
                       [_timer isValid] ? "YES" : "NO");
          /*
          NSLog(@"%s %d sessionTimeOut=%@ [_timer fireDate]=%@ [old timer isValid]=%s timerFireTimeInterval=%d now=%d",
                __FILE__,__LINE__,
                sessionTimeOut,[_timer fireDate],
                ([_timer isValid] ? "YES" : "NO"),
                (int)timerFireTimeInterval,
                (int)now);
          */
          if (sessionTimeOut
              && (![_timer isValid]
                  || [sessionTimeOut timeOutTime]<timerFireTimeInterval
                  || timerFireTimeInterval<now))
            {
              NSTimeInterval timerTimeInterval=[sessionTimeOut timeOutTime]-now;

              NSDebugMLLog(@"sessions",@"timerTimeInterval=%ld",(long)timerTimeInterval);
              timerTimeInterval=max(timerTimeInterval,SESSION_TIMEOUT_TIMER_INTERVAL_MIN);// TIMER_INTERVAL_MIN seconds minimum
              NSDebugMLLog(@"sessions",@"timerTimeInterval=%ld",(long)timerTimeInterval);
              /*
              NSLog(@"%s %d new timerTimeInterval=%ld for sessionTimeOut: %@",
                    __FILE__,__LINE__,
                    (long)timerTimeInterval,sessionTimeOut);
              */
              newTimer=[NSTimer timerWithTimeInterval:timerTimeInterval
                                target:self
                                selector:@selector(handleTimer:)
                                userInfo:nil
                                repeats:NO];
              NSDebugMLLog(@"sessions",@"old timer=%@",_timer);
              NSDebugMLLog(@"sessions",@"new timer=%@",newTimer);
              //If timer is a repeat one (anormal) or will be fired in the future
              NSDebugMLLog(@"sessions",@"[old timer fireDate]=%@",
                           [_timer fireDate]);
              NSDebugMLLog(@"sessions",@"[old timer isValide]=%s",
                           [_timer isValid] ? "YES" : "NO");
/*
  if (timer && [[timer fireDate]compare:[NSDate date]]==NSOrderedDescending)
  [timer invalidate];
*/
              ASSIGN(_timer,newTimer);
              NSDebugMLLog(@"sessions",@"old timer=%@",_timer);
              NSDebugMLLog(@"sessions",@"new timer=%@",newTimer);
            };
        }
      else
        ASSIGN(_timer,newTimer);
    }
  NS_HANDLER
    {
      NSLog(@"%@ (%@)",localException,[localException reason]);
      LOGException(@"%@ (%@)",localException,[localException reason]);
      //TODO
      //	  [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  //  [self unlock];
  NSDebugMLLog(@"sessions",@"newTimer=%@",newTimer);
  NSDebugMLLog(@"sessions",@"newTimer fireDate=%@",[newTimer fireDate]);
  LOGObjectFnStop();
  return newTimer;
};

//--------------------------------------------------------------------
-(void)addTimer:(NSTimer*)timer
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"timer=%@",timer);
  NSDebugMLLog(@"sessions",@"timer fireDate=%@",[timer fireDate]);
  NSDebugMLLog(@"sessions",@"timer tisn=%f",[[timer fireDate]timeIntervalSinceNow]);
  [GSWApp addTimer:timer];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)removeCallBack
{
  _target=nil;
  _callback=NULL;
};

//--------------------------------------------------------------------
-(void)setCallBack:(SEL)callback
            target:(id)target
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"target [%@]=%@",[target class],target);
  NSDebugMLLog(@"sessions",@"callback=%@",NSStringFromSelector(callback));
  _target=target; //Do not retain !
  _callback=callback;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(BOOL)tryLockBeforeTimeIntervalSinceNow:(NSTimeInterval)ti
{
  BOOL locked=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"selfLockn=%d lock before %f s (%@)",
               _selfLockn,ti,[NSDate dateWithTimeIntervalSinceNow:ti]);
  locked=LoggedTryLockBeforeDate(_selfLock,
				 [NSDate dateWithTimeIntervalSinceNow:ti]);
#ifndef NDEBUG
  if (locked)
    _selfLockn++;
#endif
  NSDebugMLLog(@"sessions",@"selfLockn=%d",_selfLockn);
  LOGObjectFnStop();
  return locked;
};

//--------------------------------------------------------------------
-(void)lockBeforeTimeIntervalSinceNow:(NSTimeInterval)ti
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"selfLockn=%d lock before %f s (%@)",
               _selfLockn,ti,[NSDate dateWithTimeIntervalSinceNow:ti]);
  LoggedLockBeforeDate(_selfLock,[NSDate dateWithTimeIntervalSinceNow:ti]);
#ifndef NDEBUG
  _selfLockn++;
#endif
  NSDebugMLLog(@"sessions",@"selfLockn=%d",_selfLockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)lock
{
  LOGObjectFnStart();
  [self lockBeforeTimeIntervalSinceNow:GSLOCK_DELAY_S];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"selfLockn=%d",_selfLockn);
  LoggedUnlock(_selfLock);
#ifndef NDEBUG
	_selfLockn--;
#endif
  NSDebugMLLog(@"sessions",@"selfLockn=%d",_selfLockn);
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWSessionTimeOutManager (GSWSessionRefused)

//--------------------------------------------------------------------
-(void)startHandleTimerRefusingSessions
{
  NSTimer* newTimer = nil;
  NSDebugMLLog(@"sessions",@"Start startHandleTimerRefusingSessions");

  //NSLog(@"---Start startHandleTimerRefusingSessions");
  //[GSWApplication statusLogWithFormat:@"Start startHandleTimerRefusingSessions"];
  //LOGObjectFnStart();
  [self lock];
  /*
    newTimer=[NSTimer timerWithTimeInterval:REFUSING_NEW_SESSION_TIMER_INTERVAL	// first time after 5 seconds
    target:self*****
    selector:@selector(handleTimerRefusingSessions:)
    userInfo:nil
    repeats:NO];
    
    if (newTimer) 
    [GSWApp addTimer:newTimer];
	
*/
  newTimer = [NSTimer scheduledTimerWithTimeInterval:REFUSING_NEW_SESSION_TIMER_INTERVAL
                      target:self
                      selector:@selector(handleTimerRefusingSessions:)
                      userInfo:nil
                      repeats:NO];

  NSDebugMLLog(@"sessions",@"newTimer=%@",newTimer);
  NSDebugMLLog(@"sessions",@"newTimer fireDate=%@",[newTimer fireDate]);
  NSDebugMLLog(@"sessions",@"newTimer tisn=%f",[[newTimer fireDate]timeIntervalSinceNow]);
  
  [self unlock];
  //LOGObjectFnStop();
  //[GSWApplication statusLogWithFormat:@"Stop startHandleTimerRefusingSessions"];
  //NSLog(@"---Stop startHandleTimerRefusingSessions");
}

//--------------------------------------------------------------------
-(void)handleTimerKillingApplication:(id)timer
{
  NSLog(@"application is shutting down...");
  [GSWApp lock];
  [GSWApp lockRequestHandling];
  [self lock];
  [GSWApp dealloc];
  [GSWApplication dealloc];	// call class method , not instance method
  exit(0);
}

//--------------------------------------------------------------------
-(void)handleTimerRefusingSessions:(id)aTimer
{
  NSDebugMLLog(@"sessions",@"timer=%@",aTimer);
  NSDebugMLLog(@"sessions",@"timer fireDate=%@",[aTimer fireDate]);
  NSDebugMLLog(@"sessions",@"timer tisn=%f",[[aTimer fireDate]timeIntervalSinceNow]);
  //OK
  //NSLog(@"-Start HandleTimerRefusingSessions");
  //[GSWApplication statusLogWithFormat:@"-Start HandleTimerRefusingSessions"];
  //[GSWApp lockRequestHandling];
  if ([self tryLockBeforeTimeIntervalSinceNow:1])//Try locking before 1s
    {
      NSDebugMLLog(@"sessions",@"locked");
      NS_DURING
        {
          GSWApplication* ourApp = [GSWApplication application];
          NSTimer *timer=nil;

          NSDebugMLLog(@"sessions",@"aTimer=%p",aTimer);
          NSDebugMLLog(@"sessions",@"self=%p sessionOrderedTimeOuts %p=%@",
                       self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);
          if (ourApp && [ourApp isRefusingNewSessions] && ([_sessionOrderedTimeOuts count] <= [ourApp minimumActiveSessionsCount])) 
            {              
              // okay , soft-shutdown for all avtive sessions
              
              GSWSessionTimeOut* sessionTimeOut=nil;

	      while ([_sessionOrderedTimeOuts count] > 0) 
                { 
                  sessionTimeOut = [_sessionOrderedTimeOuts lastObject];
                  if (sessionTimeOut) 
                    {
                      id session=nil;
                      [_target lock];
                      NS_DURING
                        {
                          NSDebugMLLog(@"sessions",@"[sessionTimeOut sessionID]=%@",[sessionTimeOut sessionID]);
                          session=[_target performSelector:_callback
                                           withObject:[sessionTimeOut sessionID]];
                          NSDebugMLLog(@"sessions",@"session=%@",session);
                        }
                      NS_HANDLER
                        {
                          NSLog(@"### exception ... %@", [localException reason]);
                          LOGException(@"%@ (%@)",localException,[localException reason]);
                          //TODO
                          [_target unlock];
        		  timer = [NSTimer scheduledTimerWithTimeInterval:REFUSING_NEW_SESSION_TIMER_INTERVAL
                                           target:self
                                           selector:@selector(handleTimerRefusingSessions:)
                                           userInfo:nil
                                           repeats:NO];

                          [self unlock];
                          //[GSWApp unlockRequestHandling];
                          [localException raise];
                        }
                      NS_ENDHANDLER;
                      [_target unlock];

                      if (session)
                        {
                          NSDebugMLLog(@"sessions",@"self=%p sessionOrderedTimeOuts %p=%@",
                                       self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);
                          [session terminate];	// ???
                          NSDebugMLLog(@"sessions",@"self=%p sessionOrderedTimeOuts %p=%@",
                                       self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);

                          //NSLog(@"GSWSessionTimeOutMananger : removeObject = %@", sessionTimeOut);

                          [_sessionOrderedTimeOuts removeObject:sessionTimeOut];
                          [_sessionTimeOuts removeObjectForKey:[session sessionID]];

                          NSDebugMLLog(@"sessions",@"self=%p sessionOrderedTimeOuts %p=%@",
                                       self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);
                        }
                    }
                }
              // app terminate
              NSLog(@"application is preparing to shut down in %d sec...",
                    (int)REFUSING_NEW_SESSION_APPLICATION_END);
              
              timer = [NSTimer scheduledTimerWithTimeInterval:REFUSING_NEW_SESSION_APPLICATION_END
                               target:self
                               selector:@selector(handleTimerKillingApplication:)
                               userInfo:nil
                               repeats:NO];
              
            }	
          else  
            {
              // new timer, app does not terminate
              timer = [NSTimer scheduledTimerWithTimeInterval:REFUSING_NEW_SESSION_TIMER_INTERVAL
                               target:self
                               selector:@selector(handleTimerRefusingSessions:)
                               userInfo:nil
                               repeats:NO];
              
            }
        }
      NS_HANDLER
        {
          NSDebugMLLog(@"sessions",@"EXCEPTION");
          LOGException(@"%@ (%@)",localException,[localException reason]);
          //TODO
          [self unlock];
          //[GSWApp unlockRequestHandling];
          [localException raise];
        };
      NS_ENDHANDLER;
      NSDebugMLLog(@"sessions",@"self=%p sessionOrderedTimeOuts %p=%@",
                   self,_sessionOrderedTimeOuts,_sessionOrderedTimeOuts);
      [self unlock];
      NSDebugMLLog(@"sessions",@"unlocked");
    }
  else
    {
      NSTimer* newTimer = nil;
      //TODO
      //[GSWApp unlockRequestHandling];
      //[localException raise];
      // Can't lock, reschedule
      NSLog(@"Can't lock, reschedule....");
      NSDebugMLLog(@"sessions",@"selfLockn=%d",_selfLockn);
      newTimer = [NSTimer scheduledTimerWithTimeInterval:REFUSING_NEW_SESSION_TIMER_INTERVAL
                          target:self
                          selector:@selector(handleTimerRefusingSessions:)
                          userInfo:nil
                          repeats:NO];
      NSDebugMLLog(@"sessions",@"newTimer=%@",newTimer);
      NSDebugMLLog(@"sessions",@"newTimer fireDate=%@",[newTimer fireDate]);
      NSDebugMLLog(@"sessions",@"newTimer tisn=%f",[[newTimer fireDate]timeIntervalSinceNow]);
      NSDebugMLLog(@"sessions",@"selfLockn=%d",_selfLockn);
    };

  //[GSWApp unlockRequestHandling];
  //[GSWApplication statusLogWithFormat:@"-Stop HandleTimerRefusingSessions"];
  //NSLog(@"-Stop HandleTimerRefusingSessions");
};


@end
