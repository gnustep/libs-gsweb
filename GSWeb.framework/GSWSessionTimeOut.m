/* GSWSessionTimeOut.m - GSWeb: Class GSWSessionTimeOut
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
@implementation GSWSessionTimeOut

//--------------------------------------------------------------------
-(id)initWithSessionID:(NSString*)sessionID_
		lastAccessTime:(NSTimeInterval)lastAccessTime_
		sessionTimeOut:(NSTimeInterval)timeOut_
{
  if ((self=[super init]))
	{
	  ASSIGN(sessionID,sessionID_);
	  lastAccessTime=lastAccessTime_;
	  timeOut=timeOut_;
	};
  return self;
};

//--------------------------------------------------------------------
+(id)timeOutWithSessionID:(NSString*)sessionID_
		   lastAccessTime:(NSTimeInterval)lastAccessTime_
		   sessionTimeOut:(NSTimeInterval)timeOut_
{
  return [[[self alloc]initWithSessionID:sessionID_
					  lastAccessTime:lastAccessTime_
					  sessionTimeOut:timeOut_]autorelease];
};

//--------------------------------------------------------------------
-(void)dealloc
{
  NSDebugFLog0(@"Dealloc GSWSessionTimeOut");
  if (sessionID)
	{
	  NSDebugFLog(@"sessionIDCount=%u",[sessionID retainCount]);
	};
  DESTROY(sessionID);
  [super dealloc];
};


//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - sessionID=%@ timeOutTime=%f lastAccessTime=%f timeOut=%ld",
				  object_get_class_name(self),
				  (void*)self,
				   sessionID,
				   [self timeOutTime],
				   lastAccessTime,
				   (long)timeOut];
};

//--------------------------------------------------------------------
-(NSComparisonResult)compareTimeOutDate:(GSWSessionTimeOut*)timeOutObject_
{
  if (timeOutObject_)
	{
	  if ([self timeOutTime]<[timeOutObject_ timeOutTime])
		return NSOrderedAscending;
	  else if ([self timeOutTime]==[timeOutObject_ timeOutTime])
		return NSOrderedSame;
	  else
		return NSOrderedDescending;
	}
  else
	return NSOrderedDescending;
};

//--------------------------------------------------------------------
-(NSTimeInterval)sessionTimeOut
{
  return timeOut;
};

//--------------------------------------------------------------------
-(void)setSessionTimeOut:(NSTimeInterval)timeOut_
{
  timeOut=timeOut_;
};

//--------------------------------------------------------------------
-(NSString*)sessionID
{
  return sessionID;
};

//--------------------------------------------------------------------
-(void)setLastAccessTime:(NSTimeInterval)lastAccessTime_
{
  lastAccessTime=lastAccessTime_;
};

//--------------------------------------------------------------------
-(NSTimeInterval)lastAccessTime
{
  return lastAccessTime;
};

//--------------------------------------------------------------------
-(NSTimeInterval)timeOutTime
{
  return lastAccessTime+timeOut;
};

@end

