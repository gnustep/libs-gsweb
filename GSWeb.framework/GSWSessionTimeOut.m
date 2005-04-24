/** GSWSessionTimeOut.m - <title>GSWeb: Class GSWSessionTimeOut</title>

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

//====================================================================
@implementation GSWSessionTimeOut

//--------------------------------------------------------------------
-(id)initWithSessionID:(NSString*)aSessionID
        lastAccessTime:(NSTimeInterval)aTime
        sessionTimeOut:(NSTimeInterval)aTimeOutInterval
{
  if ((self=[super init]))
    {
      ASSIGN(_sessionID,aSessionID);
      _lastAccessTime=aTime;
      _timeOut=aTimeOutInterval;
      NSDebugMLLog(@"sessions",@"_lastAccessTime=%f (%@)",
                   _lastAccessTime,
                   [NSDate dateWithTimeIntervalSinceReferenceDate:_lastAccessTime]);
      NSDebugMLLog(@"sessions",@"_timeOut=%f s",
                   _timeOut);
    };
  return self;
};

//--------------------------------------------------------------------
+(id)timeOutWithSessionID:(NSString*)aSessionID
           lastAccessTime:(NSTimeInterval)aTime
           sessionTimeOut:(NSTimeInterval)aTimeOutInterval
{
  return [[[self alloc]initWithSessionID:aSessionID
                       lastAccessTime:aTime
                       sessionTimeOut:aTimeOutInterval]autorelease];
};

//--------------------------------------------------------------------
-(void)dealloc
{
  NSDebugFLog0(@"Dealloc GSWSessionTimeOut");
  if (_sessionID)
    {
      NSDebugFLog(@"sessionIDCount=%u",[_sessionID retainCount]);
    };
  DESTROY(_sessionID);
  [super dealloc];
};


//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - sessionID=%@ timeOutTime=%@ lastAccessTime=%@ timeOut=%ld isCheckedOut=%s",
                   object_get_class_name(self),
                   (void*)self,
                   _sessionID,
                   [self timeOutTimeDate],
                   [self lastAccessTimeDate],
                   (long)_timeOut,
                   (_isCheckedOut ? "YES" : "NO")];
};

//--------------------------------------------------------------------
-(NSComparisonResult)compareTimeOutDate:(GSWSessionTimeOut*)timeOutObject
{
  if (timeOutObject)
    {
      if ([self timeOutTime]<[timeOutObject timeOutTime])
        return NSOrderedAscending;
      else if ([self timeOutTime]==[timeOutObject timeOutTime])
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
  return _timeOut;
};

//--------------------------------------------------------------------
-(void)setSessionTimeOut:(NSTimeInterval)aTimeOutInterval
{
  _timeOut=aTimeOutInterval;
  NSDebugMLLog(@"sessions",@"_timeOut=%f s",
               _timeOut);
};

//--------------------------------------------------------------------
-(NSString*)sessionID
{
  return _sessionID;
};

//--------------------------------------------------------------------
-(void)setLastAccessTime:(NSTimeInterval)aTime
{
  _lastAccessTime=aTime;
  NSDebugMLLog(@"sessions",@"_lastAccessTime=%f (%@)",
               _lastAccessTime,
               [NSDate dateWithTimeIntervalSinceReferenceDate:_lastAccessTime]);
};

//--------------------------------------------------------------------
-(NSTimeInterval)lastAccessTime
{
  return _lastAccessTime;
};

//--------------------------------------------------------------------
-(NSDate*)lastAccessTimeDate
{
  return [NSDate dateWithTimeIntervalSinceReferenceDate:_lastAccessTime];
};

//--------------------------------------------------------------------
-(NSTimeInterval)timeOutTime
{
  return _lastAccessTime+_timeOut;
};

//--------------------------------------------------------------------
-(NSDate*)timeOutTimeDate
{
  return [NSDate dateWithTimeIntervalSinceReferenceDate:_lastAccessTime+_timeOut];
};

//--------------------------------------------------------------------
-(BOOL)isCheckedOut
{
  return _isCheckedOut;
};

//--------------------------------------------------------------------
-(void)setIsCheckedOut:(BOOL)isCheckOut
{
  _isCheckedOut=isCheckOut;
};

@end

