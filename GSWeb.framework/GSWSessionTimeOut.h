/* GSWSessionTimeOut.h - GSWeb: Class GSWSessionTimeOut
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

// $Id$

#ifndef _GSWSessionTimeOut_h__
	#define _GSWSessionTimeOut_h__


//====================================================================
@interface GSWSessionTimeOut : NSObject
{
  NSString* sessionID;
  NSTimeInterval lastAccessTime;
  NSTimeInterval timeOut;
};

-(void)dealloc;
-(id)initWithSessionID:(NSString*)sessionID_
		lastAccessTime:(NSTimeInterval)lastAccessTime_
		sessionTimeOut:(NSTimeInterval)timeOut;
+(id)timeOutWithSessionID:(NSString*)sessionID_
		   lastAccessTime:(NSTimeInterval)lastAccessTime_
		   sessionTimeOut:(NSTimeInterval)timeOut;
-(NSString*)description;
-(NSComparisonResult)compareTimeOutDate:(GSWSessionTimeOut*)timeOutObject_;
-(NSTimeInterval)sessionTimeOut;
-(void)setSessionTimeOut:(NSTimeInterval)timeOut_;
-(NSString*)sessionID;
-(void)setLastAccessTime:(NSTimeInterval)lastAccessTime_;
-(NSTimeInterval)lastAccessTime;
-(NSTimeInterval)timeOutTime;
@end


#endif // _GSWSessionTimeOut_h__
