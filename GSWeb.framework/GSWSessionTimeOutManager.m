/** GSWSessionTimeOutManager.m - <title>GSWeb: Class GSWSessionTimeOutManager</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Mar 1999
   
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

#include <GSWeb/GSWeb.h>
#include "GSWSessionTimeOut.h"

//====================================================================
@implementation GSWSessionTimeOutManager
-(id)init
{
  //OK
  if ((self=[super init]))
    {
      _sessionOrderedTimeOuts=[NSMutableArray new];
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

//--------------------------------------------------------------------
-(void)updateTimeOutForSessionWithID:(NSString*)sessionID
                             timeOut:(NSTimeInterval)timeOut
{
  //OK
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      NSTimer* timer=nil;
      GSWSessionTimeOut* sessionTimeOut=nil;
      NSDebugMLLog(@"sessions",@"timeOut=%ld",(long)timeOut);
      sessionTimeOut=[_sessionTimeOuts objectForKey:sessionID];
      NSDebugMLLog(@"sessions",@"sessionTimeOut=%@",sessionTimeOut);
      NSDebugMLLog(@"sessions",@"_sessionOrderedTimeOuts=%@",_sessionOrderedTimeOuts);
      if (sessionTimeOut)
        {
          [sessionTimeOut retain];
          [_sessionOrderedTimeOuts removeObject:sessionTimeOut];
          [sessionTimeOut setLastAccessTime:[NSDate timeIntervalSinceReferenceDate]];
          if (timeOut!=[sessionTimeOut sessionTimeOut])
            [sessionTimeOut setSessionTimeOut:timeOut];
          [_sessionOrderedTimeOuts addObject:sessionTimeOut];
          [sessionTimeOut release];
        }
      else
        {
          sessionTimeOut=[GSWSessionTimeOut timeOutWithSessionID:sessionID
                                            lastAccessTime:[NSDate timeIntervalSinceReferenceDate]
                                            sessionTimeOut:timeOut];
          [_sessionTimeOuts setObject:sessionTimeOut
                            forKey:sessionID];
          [_sessionOrderedTimeOuts addObject:sessionTimeOut];
        };
      NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",_sessionOrderedTimeOuts);
      NSDebugMLLog(@"sessions",@"sessionTimeOut=%@",sessionTimeOut);
      timer=[self resetTimer];
      NSDebugMLLog(@"sessions",@"timer=%@",timer);
      if (timer)
        {
          [GSWApplication logWithFormat:@"lock Target..."];
          [_target lock];
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
              [_target unlock];
              [self unlock];
              [localException raise];
            }
          NS_ENDHANDLER;
          
          [GSWApplication logWithFormat:@"unlock Target..."];
          [_target unlock];
        };
    }
  NS_HANDLER
    {
      NSLog(@"### exception ... %@", [localException reason]);
      LOGException(@"%@ (%@)",localException,[localException reason]);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)handleTimer:(id)aTimer
{
  //OK
  [GSWApplication statusLogWithFormat:@"Start HandleTimer"];
//  LOGObjectFnStart();
  [GSWApp lockRequestHandling];
  NS_DURING
    {
      [self lock];
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
		
          sessionTimeOutEnum = [_sessionOrderedTimeOuts objectEnumerator];

          while (/*_removedNb<20 && *//*sessionTimeOut && [sessionTimeOut timeOutTime]<_now*/
                 (sessionTimeOut = [sessionTimeOutEnum nextObject]))
            {
              if ([sessionTimeOut timeOutTime]<now) 
                {
                  id session=nil;
                  [_target lock];
                  NS_DURING
                    {
                      session=[_target performSelector:_callback
                                       withObject:[sessionTimeOut sessionID]];
                      NSDebugMLLog(@"sessions",@"session=%@",session);
                    }
                  NS_HANDLER
                    {
                      LOGException(@"%@ (%@)",localException,[localException reason]);
                      //TODO
                      [_target unlock];
                      
                      timer=[self resetTimer];
                      if (timer)
                        [self addTimer:timer];
                      
                      [self unlock];
                      [GSWApp unlockRequestHandling];
                      [localException raise];
                    }
                  NS_ENDHANDLER;
                  [_target unlock];

                  if (session)
                    {
                      NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",_sessionOrderedTimeOuts);
                      [session terminate];
                      NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",_sessionOrderedTimeOuts);

                      NSLog(@"GSWSessionTimeOutMananger : removeObject = %@", sessionTimeOut);

                      /*  [_sessionOrderedTimeOuts removeObjectAtIndex:0]; */
                      [_sessionOrderedTimeOuts removeObject:sessionTimeOut];
                      [_sessionTimeOuts removeObjectForKey:[session sessionID]];

                      NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",_sessionOrderedTimeOuts);
                      removedNb++;
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
          if (timer)
            [self addTimer:timer];
        }
      NS_HANDLER
        {
          LOGException(@"%@ (%@)",localException,[localException reason]);
          //TODO
          [self unlock];
          [GSWApp unlockRequestHandling];
          [localException raise];
        };
      NS_ENDHANDLER;
      NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",_sessionOrderedTimeOuts);
      [self unlock];
    }
  NS_HANDLER
    {
      LOGException(@"%@ (%@)",localException,[localException reason]);
      //TODO
      [GSWApp unlockRequestHandling];
      [localException raise];
    };
  NS_ENDHANDLER;
  [GSWApp unlockRequestHandling];
//  LOGObjectFnStop();
  [GSWApplication statusLogWithFormat:@"Stop HandleTimer"];
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

      NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",_sessionOrderedTimeOuts);
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
          if (sessionTimeOut
              && (![_timer isValid]
                  || [sessionTimeOut timeOutTime]<timerFireTimeInterval
                  || timerFireTimeInterval<now))
            {
              NSTimeInterval timerTimeInterval=[sessionTimeOut timeOutTime]-now;

              NSDebugMLLog(@"sessions",@"timerTimeInterval=%ld",(long)timerTimeInterval);
              timerTimeInterval=max(timerTimeInterval,1);//20s minimum
              NSDebugMLLog(@"sessions",@"timerTimeInterval=%ld",(long)timerTimeInterval);
              NSLog(@"new timerTimeInterval=%ld",(long)timerTimeInterval);

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
            };
        }
      else
        ASSIGN(_timer,newTimer);
    }
  NS_HANDLER
    {
      LOGException(@"%@ (%@)",localException,[localException reason]);
      //TODO
      //	  [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  //  [self unlock];
  LOGObjectFnStop();
  return newTimer;
};

//--------------------------------------------------------------------
-(void)addTimer:(NSTimer*)timer
{
  //OK
  LOGObjectFnStart();
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
  _target=target; //Do not retain !
  _callback=callback;
};

//--------------------------------------------------------------------
-(void)lock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"selfLockn=%d",_selfLockn);
  TmpLockBeforeDate(_selfLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
  _selfLockn++;
#endif
  NSDebugMLLog(@"sessions",@"selfLockn=%d",_selfLockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"selfLockn=%d",_selfLockn);
  TmpUnlock(_selfLock);
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

  NSLog(@"---Start startHandleTimerRefusingSessions");
  //[GSWApplication statusLogWithFormat:@"Start startHandleTimerRefusingSessions"];
  //LOGObjectFnStart();
  [self lock];
  /*
    newTimer=[NSTimer timerWithTimeInterval:5	// first time after 5 seconds
    target:self
    selector:@selector(handleTimerRefusingSessions:)
    userInfo:nil
    repeats:NO];
    
    if (newTimer) 
    [GSWApp addTimer:newTimer];
	
*/
  newTimer = [NSTimer scheduledTimerWithTimeInterval:5 
                      target:self
                      selector:@selector(handleTimerRefusingSessions:)
                      userInfo:nil
                      repeats:NO];
  
  [self unlock];
  //LOGObjectFnStop();
  //[GSWApplication statusLogWithFormat:@"Stop startHandleTimerRefusingSessions"];
  NSLog(@"---Stop startHandleTimerRefusingSessions");
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
  //OK
  //NSLog(@"-Start HandleTimerRefusingSessions");
  //[GSWApplication statusLogWithFormat:@"-Start HandleTimerRefusingSessions"];
  //[GSWApp lockRequestHandling];
  NS_DURING
    {
      [self lock];
      NS_DURING
        {
          GSWApplication* ourApp = [GSWApplication application];
          NSTimer *timer=nil;

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
                          session=[_target performSelector:_callback
                                           withObject:[sessionTimeOut sessionID]];
                          NSDebugMLLog(@"sessions",@"session=%@",session);
                        }
                      NS_HANDLER
                        {
                          LOGException(@"%@ (%@)",localException,[localException reason]);
                          //TODO
                          [_target unlock];
        		  timer = [NSTimer scheduledTimerWithTimeInterval:5 
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
                          NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",_sessionOrderedTimeOuts);
                          [session terminate];	// ???
                          NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",_sessionOrderedTimeOuts);

                          NSLog(@"GSWSessionTimeOutMananger : removeObject = %@", sessionTimeOut);

                          [_sessionOrderedTimeOuts removeObject:sessionTimeOut];
                          [_sessionTimeOuts removeObjectForKey:[session sessionID]];

                          NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",_sessionOrderedTimeOuts);
                        }
                    }
                }
              // app terminate
              NSLog(@"application is preparing to shut down in 10 sec...");
              
              timer = [NSTimer scheduledTimerWithTimeInterval:10 
                               target:self
                               selector:@selector(handleTimerKillingApplication:)
                               userInfo:nil
                               repeats:NO];
              
            }	
          else  
            {
              // new timer, app does not terminate
              timer = [NSTimer scheduledTimerWithTimeInterval:5 
                               target:self
                               selector:@selector(handleTimerRefusingSessions:)
                               userInfo:nil
                               repeats:NO];
              
            }
        }
      NS_HANDLER
        {
          LOGException(@"%@ (%@)",localException,[localException reason]);
          //TODO
          [self unlock];
          //[GSWApp unlockRequestHandling];
          [localException raise];
        };
      NS_ENDHANDLER;
      NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",_sessionOrderedTimeOuts);
      [self unlock];
    }
  NS_HANDLER
    {
      LOGException(@"%@ (%@)",localException,[localException reason]);
      //TODO
      //[GSWApp unlockRequestHandling];
      [localException raise];
    };
  NS_ENDHANDLER;
  //[GSWApp unlockRequestHandling];
  //[GSWApplication statusLogWithFormat:@"-Stop HandleTimerRefusingSessions"];
  //NSLog(@"-Stop HandleTimerRefusingSessions");
};


@end
