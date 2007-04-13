/** GSWSessionTimeOutManager.h - <title>GSWeb: Class GSWSessionTimeOutManager</title>

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

// $Id$

#ifndef _GSWSessionTimeOutManager_h__
	#define _GSWSessionTimeOutManager_h__


//====================================================================
@interface GSWSessionTimeOutManager : NSObject
{
  NSMutableArray* _sessionOrderedTimeOuts;
  NSMutableDictionary* _sessionTimeOuts;
  id _target;
  SEL _callback;
  NSTimer* _timer;
//  NSRecursiveLock* _selfLock;
  NSLock* _selfLock;
#ifndef NDEBUG
  int _selfLockn;
#endif
};

-(void)updateTimeOutForSessionWithID:(NSString*)sessionID
                             timeOut:(NSTimeInterval)timeOut;
-(void)handleTimer:(NSTimer*)timer;
-(NSTimer*)resetTimer;
-(void)addTimer:(id)timer;
-(void)removeCallBack;
-(void)setCallBack:(SEL)callback
            target:(id)target;
-(BOOL)tryLockBeforeTimeIntervalSinceNow:(NSTimeInterval)ti;
-(void)lockBeforeTimeIntervalSinceNow:(NSTimeInterval)ti;
-(void)lock;
-(void)unlock;
// Must not be locked
-(GSWSessionTimeOut*)sessionTimeOutForSessionID:(NSString*)sessionID;


-(void)startHandleTimerRefusingSessions;
-(void)handleTimerKillingApplication:(id)timer;
-(void)handleTimerRefusingSessions:(id)timer;

@end
#endif //_GSWSessionTimeOutManager_h__
