/* GSWSessionTimeOutManager.m - GSWeb: Class GSWSessionTimeOutManager
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Mar 1999
   
   This file is part of the GNUstep Web Library.
   
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
*/

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
	  //sessionOrderedTimeOuts=[[NSMutableOrderedArray alloc]initWithCompareSelector:@selector(compareTimeOutDate:)];
	  sessionOrderedTimeOuts=[NSMutableArray new];
	  sessionTimeOuts=[NSMutableDictionary new];
//	  selfLock=[NSRecursiveLock new];
	  selfLock=[NSLock new];
	};
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(sessionOrderedTimeOuts);
  DESTROY(sessionTimeOuts);
  //Do Not Retain ! DESTROY(target);
  DESTROY(timer);
  DESTROY(selfLock);
  [super dealloc];
};

//--------------------------------------------------------------------
-(void)updateTimeOutForSessionWithID:(NSString*)sessionID_
							 timeOut:(NSTimeInterval)timeOut_
{
  //OK
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  NSTimer* _timer=nil;
	  GSWSessionTimeOut* _sessionTimeOut=nil;
	  NSDebugMLLog(@"sessions",@"timeOut_=%ld",(long)timeOut_);
	  _sessionTimeOut=[sessionTimeOuts objectForKey:sessionID_];
	  NSDebugMLLog(@"sessions",@"_sessionTimeOut=%@",_sessionTimeOut);
	  NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",sessionOrderedTimeOuts);
	  if (_sessionTimeOut)
		{
		  [_sessionTimeOut retain];
		  [sessionOrderedTimeOuts removeObject:_sessionTimeOut];
		  [_sessionTimeOut setLastAccessTime:[NSDate timeIntervalSinceReferenceDate]];
		  if (timeOut_!=[_sessionTimeOut sessionTimeOut])
			[_sessionTimeOut setSessionTimeOut:timeOut_];
		  [sessionOrderedTimeOuts addObject:_sessionTimeOut];
		  [_sessionTimeOut release];
		}
	  else
		{
		  _sessionTimeOut=[GSWSessionTimeOut timeOutWithSessionID:sessionID_
											 lastAccessTime:[NSDate timeIntervalSinceReferenceDate]
											 sessionTimeOut:timeOut_];
		  [sessionTimeOuts setObject:_sessionTimeOut
						   forKey:sessionID_];
		  [sessionOrderedTimeOuts addObject:_sessionTimeOut];
		};
	  NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",sessionOrderedTimeOuts);
	  NSDebugMLLog(@"sessions",@"_sessionTimeOut=%@",_sessionTimeOut);
	  _timer=[self resetTimer];
	  NSDebugMLLog(@"sessions",@"_timer=%@",_timer);
	  if (_timer)
		{
		  [GSWApplication logWithFormat:@"lock Target..."];
		  [target lock];
		  NS_DURING
			{
			  [self addTimer:_timer];
			}
		  NS_HANDLER
			{
			NSLog(@"### exception from ... addTimer... %@", [localException reason]);
			  LOGException(@"%@ (%@)",localException,[localException reason]);
			  //TODO
			  [target unlock];
			  [self unlock];
			  [localException raise];
			}
		  NS_ENDHANDLER;

		  [GSWApplication logWithFormat:@"unlock Target..."];
		  [target unlock];
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
-(void)handleTimer:(id)timer_
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
		  NSEnumerator	*_sessionTimeOutEnum = nil;
		  GSWSessionTimeOut* _sessionTimeOut=nil;
		  NSTimeInterval _now=[NSDate timeIntervalSinceReferenceDate];
		  NSTimer* _timer=nil;
		  int _removedNb=0;

/*
		  if ([sessionOrderedTimeOuts count]>0)
			_sessionTimeOut=[sessionOrderedTimeOuts objectAtIndex:0];
*/
		
		  _sessionTimeOutEnum = [sessionOrderedTimeOuts objectEnumerator];

		  while (/*_removedNb<20 && *//*_sessionTimeOut && [_sessionTimeOut timeOutTime]<_now*/
			_sessionTimeOut = [_sessionTimeOutEnum nextObject])
			{
			 if ([_sessionTimeOut timeOutTime]<_now) 
			  {
			  id _session=nil;
			  [target lock];
			  NS_DURING
				{
				  _session=[target performSelector:callback
								   withObject:[_sessionTimeOut sessionID]];
				  NSDebugMLLog(@"sessions",@"_session=%@",_session);
				}
			  NS_HANDLER
				{
				  LOGException(@"%@ (%@)",localException,[localException reason]);
				  //TODO
				  [target unlock];

				  _timer=[self resetTimer];
				  if (_timer)
					[self addTimer:_timer];

				  [self unlock];
				  [GSWApp unlockRequestHandling];
				  [localException raise];
				}
			  NS_ENDHANDLER;
			  [target unlock];

			  if (_session)
				{
				  NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",sessionOrderedTimeOuts);
				  [_session terminate];
				  NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",sessionOrderedTimeOuts);

				  NSLog(@"GSWSessionTimeOutMananger : removeObject = %@", _sessionTimeOut);

				/*  [sessionOrderedTimeOuts removeObjectAtIndex:0]; */
				  [sessionOrderedTimeOuts removeObject:_sessionTimeOut];
		  		  [sessionTimeOuts removeObjectForKey:[_session sessionID]];

				  NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",sessionOrderedTimeOuts);
				  _removedNb++;
				/*
				  if ([sessionOrderedTimeOuts count]>0)
					_sessionTimeOut=[sessionOrderedTimeOuts objectAtIndex:0];
				  else
					_sessionTimeOut=nil;
				*/
				}
			  else
				_sessionTimeOut=nil;
			 };
			};
		  
		  _timer=[self resetTimer];
		  if (_timer)
			[self addTimer:_timer];
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
	  NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",sessionOrderedTimeOuts);
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
  NSTimer* _newTimer=nil;
  GSWSessionTimeOut* _sessionTimeOut=nil;
  LOGObjectFnStart();
//  [self lock];
  NS_DURING
	{
	  NSTimeInterval _now=[NSDate timeIntervalSinceReferenceDate];
	  NSTimeInterval _timerFireTimeInterval=[[timer fireDate]timeIntervalSinceReferenceDate];

	  NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",sessionOrderedTimeOuts);
	  if ([sessionOrderedTimeOuts count]>0)
		{
		  NSEnumerator	* sessionOrderedTimeOutsEnum = [sessionOrderedTimeOuts objectEnumerator];
		  GSWSessionTimeOut* sessionTimeOutObject=nil;
		  NSTimeInterval _minTimeOut;

		  _sessionTimeOut = [sessionOrderedTimeOuts objectAtIndex:0];
		  _minTimeOut = [_sessionTimeOut timeOutTime];
		  while (sessionTimeOutObject = [sessionOrderedTimeOutsEnum nextObject]) {
			if ([sessionTimeOutObject timeOutTime] < _minTimeOut) {
			    _sessionTimeOut = sessionTimeOutObject;
		  	    _minTimeOut = [_sessionTimeOut timeOutTime];
			}
		  }

		  //_sessionTimeOut=[sessionOrderedTimeOuts objectAtIndex:0];

		  // search for minimum timeouts

		  NSDebugMLLog(@"sessions",@"_sessionTimeOut=%@",_sessionTimeOut);
		  NSDebugMLLog(@"sessions",@"[timer fireDate]=%@",[timer fireDate]);
		  NSDebugMLLog(@"sessions",@"[old timer isValide]=%s",
					   [timer isValid] ? "YES" : "NO");
/*
		NSLog(@"_sessionTimeOut=%@",_sessionTimeOut);
		NSLog(@"[old timer isValide]=%s", [timer isValid] ? "YES" : "NO");
		NSLog(@"[_sessionTimeOut timeOutTime] = %ld",(long)[_sessionTimeOut timeOutTime]);
		NSLog(@"_timerFireTimeInterval = %ld",(long) _timerFireTimeInterval);
		NSLog(@"_now = %ld",(long) _now);
*/
		  if (_sessionTimeOut
			  && (![timer isValid]
				  || [_sessionTimeOut timeOutTime]<_timerFireTimeInterval
				  || _timerFireTimeInterval<_now))
		  {
			NSTimeInterval _timerTimeInterval=[_sessionTimeOut timeOutTime]-_now;

	NSDebugMLLog(@"sessions",@"_timerTimeInterval=%ld",(long)_timerTimeInterval);
			_timerTimeInterval=max(_timerTimeInterval,1);//20s minimum
			NSDebugMLLog(@"sessions",@"_timerTimeInterval=%ld",(long)_timerTimeInterval);
			NSLog(@"new _timerTimeInterval=%ld",(long)_timerTimeInterval);

			_newTimer=[NSTimer timerWithTimeInterval:_timerTimeInterval
							   target:self
							   selector:@selector(handleTimer:)
							   userInfo:nil
							   repeats:NO];
			NSDebugMLLog(@"sessions",@"old timer=%@",timer);
			NSDebugMLLog(@"sessions",@"new timer=%@",_newTimer);
			//If timer is a repeat one (anormal) or will be fired in the future
			NSDebugMLLog(@"sessions",@"[old timer fireDate]=%@",
						 [timer fireDate]);
			NSDebugMLLog(@"sessions",@"[old timer isValide]=%s",
						 [timer isValid] ? "YES" : "NO");
/*
			if (timer && [[timer fireDate]compare:[NSDate date]]==NSOrderedDescending)
			  [timer invalidate];
*/
			ASSIGN(timer,_newTimer);
		  };
		}
	  else
		ASSIGN(timer,_newTimer);
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
  return _newTimer;
};

//--------------------------------------------------------------------
-(void)addTimer:(NSTimer*)timer_
{
  //OK
  LOGObjectFnStart();
  [GSWApp addTimer:timer];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)removeCallBack
{
  target=nil;
  callback=NULL;
};

//--------------------------------------------------------------------
-(void)setCallBack:(SEL)callback_
			target:(id)target_
{
  //OK
  target=target_; //Do not retain !
  callback=callback_;
};

//--------------------------------------------------------------------
-(void)lock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"selfLockn=%d",selfLockn);
  TmpLockBeforeDate(selfLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
  selfLockn++;
#endif
  NSDebugMLLog(@"sessions",@"selfLockn=%d",selfLockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"selfLockn=%d",selfLockn);
  TmpUnlock(selfLock);
#ifndef NDEBUG
	selfLockn--;
#endif
  NSDebugMLLog(@"sessions",@"selfLockn=%d",selfLockn);
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWSessionTimeOutManager (GSWSessionRefused)

//--------------------------------------------------------------------
-(void)startHandleTimerRefusingSessions
{
	NSTimer* _newTimer = nil;

NSLog(@"---Start startHandleTimerRefusingSessions");
    //[GSWApplication statusLogWithFormat:@"Start startHandleTimerRefusingSessions"];
	//LOGObjectFnStart();
	[self lock];
/*
  	_newTimer=[NSTimer timerWithTimeInterval:5	// first time after 5 seconds
							   target:self
							   selector:@selector(handleTimerRefusingSessions:)
							   userInfo:nil
							   repeats:NO];

	if (_newTimer) {
		[GSWApp addTimer:_newTimer];
	}
*/

        _newTimer = [NSTimer scheduledTimerWithTimeInterval:5 
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
-(void)handleTimerKillingApplication:(id)timer_
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
-(void)handleTimerRefusingSessions:(id)timer_
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
		  GSWApplication	*ourApp = [GSWApplication application];
		  NSTimer				*_timer=nil;

		  if (ourApp && [ourApp isRefusingNewSessions] && ([sessionOrderedTimeOuts count] <= [ourApp minimumActiveSessionsCount])) {

		  // okay , soft-shutdown for all avtive sessions

		  GSWSessionTimeOut 	*_sessionTimeOut=nil;

	      while ([sessionOrderedTimeOuts count] > 0) { 

			_sessionTimeOut = [sessionOrderedTimeOuts lastObject];
			if (_sessionTimeOut) {

			  id _session=nil;
			  [target lock];
			  NS_DURING
				{
				  _session=[target performSelector:callback
								   withObject:[_sessionTimeOut sessionID]];
				  NSDebugMLLog(@"sessions",@"_session=%@",_session);
				}
			  NS_HANDLER
				{
				  LOGException(@"%@ (%@)",localException,[localException reason]);
				  //TODO
				  [target unlock];
        		  _timer = [NSTimer scheduledTimerWithTimeInterval:5 
                                                           target:self
                                                         selector:@selector(handleTimerRefusingSessions:)
                                                         userInfo:nil
                                                          repeats:NO];

				  [self unlock];
				  //[GSWApp unlockRequestHandling];
				  [localException raise];
				}
			  NS_ENDHANDLER;
			  [target unlock];

			  if (_session)
				{
				  NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",sessionOrderedTimeOuts);
				  [_session terminate];	// ???
				  NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",sessionOrderedTimeOuts);

				  NSLog(@"GSWSessionTimeOutMananger : removeObject = %@", _sessionTimeOut);

				  [sessionOrderedTimeOuts removeObject:_sessionTimeOut];
		  		  [sessionTimeOuts removeObjectForKey:[_session sessionID]];

				  NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",sessionOrderedTimeOuts);
				}

			}
		   }
		   // app terminate
			NSLog(@"application is preparing to shut down in 10 sec...");

        	_timer = [NSTimer scheduledTimerWithTimeInterval:10 
                                                           target:self
                                                         selector:@selector(handleTimerKillingApplication:)
                                                         userInfo:nil
                                                          repeats:NO];

		  }	else  
			{
		  	// new timer, app does not terminate
        	_timer = [NSTimer scheduledTimerWithTimeInterval:5 
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
	  NSDebugMLLog(@"sessions",@"sessionOrderedTimeOuts=%@",sessionOrderedTimeOuts);
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
