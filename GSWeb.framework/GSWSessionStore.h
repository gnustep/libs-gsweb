/* GSWSessionStore.h - GSWeb: Class GSWSessionStore
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
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

#ifndef _GSWSessionStore_h__
	#define _GSWSessionStore_h__


@interface GSWSessionStore : NSObject <NSLocking>
{
  NSMutableSet* usedIDs;
  NSRecursiveLock* lock;
#ifndef NDEBUG
  int lockn;
#endif
//TODO  void* sessionCheckedInCondition;
};

-(void)dealloc;
-(id)init;

-(GSWSession*)restoreSessionWithID:(NSString*)sessionID_
						  request:(GSWRequest*)request_;
-(void)saveSessionForContext:(GSWContext*)context_;
-(GSWSession*)checkOutSessionWithID:(NSString*)sessionID_
						   request:(GSWRequest*)request_;
-(void)checkInSessionForContext:(GSWContext*)context_;

-(void)_checkInSessionForContext:(GSWContext*)context_;
-(GSWSession*)_checkOutSessionWithID:(NSString*)sessionID_
							request:(GSWRequest*)request_;
-(void)_checkinSessionID:(NSString*)sessionID_;
-(void)_checkoutSessionID:(NSString*)sessionID_;
-(void)unlock;
-(BOOL)tryLock;
-(void)lock;

@end
/*
//====================================================================
@interface GSWSessionStore (GSWSessionStoreCreation)
+(GSWSessionStore*)serverSessionStore;
@end

//====================================================================
@interface GSWSessionStore (GSWSessionStoreOldFn)
+(GSWSessionStore*)cookieSessionStoreWithDistributionDomain:(NSString*)domain_
													secure:(BOOL)flag_;
+(GSWSessionStore*)pageSessionStore;
+(GSWSessionStore*)serverSessionStore;

-(GSWSession*)restoreSession;
-(void)saveSession:(GSWSession*)session_;
@end
*/

//====================================================================
@interface GSWSessionStore (GSWSessionStoreA)
-(BOOL)_isSessionIDCheckedOut:(NSString*)sessionID_;

@end

//====================================================================
@interface GSWSessionStore (GSWSessionStoreB)
-(void)_validateAPI;
@end


#endif //_GSWSessionStore_h__
