/** GSWSessionStore.h - <title>GSWeb: Class GSWSessionStore</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

#ifndef _GSWSessionStore_h__
	#define _GSWSessionStore_h__


@interface GSWSessionStore : NSObject <NSLocking>
{
  NSMutableSet* _usedIDs;
  NSRecursiveLock* _lock;
  GSWSessionTimeOutManager* _timeOutManager;
#ifndef NDEBUG
  int _lockn;
#endif
//TODO  void* sessionCheckedInCondition;
};

-(void)dealloc;
-(id)init;

-(GSWSession*)removeSessionWithID:(NSString*)aSessionID;
-(GSWSession*)restoreSessionWithID:(NSString*)aSessionID
                           request:(GSWRequest*)aRequest;
-(void)saveSessionForContext:(GSWContext*)aContext;
-(GSWSession*)checkOutSessionWithID:(NSString*)aSessionID
                            request:(GSWRequest*)aRequest;
-(void)checkInSessionForContext:(GSWContext*)aContext;

-(void)_checkInSessionForContext:(GSWContext*)aContext;
-(GSWSession*)_checkOutSessionWithID:(NSString*)aSessionID
                             request:(GSWRequest*)aRequest;
-(void)_checkinSessionID:(NSString*)aSessionID;
-(void)_checkoutSessionID:(NSString*)aSessionID;
-(void)unlock;
-(BOOL)tryLock;
-(void)lock;

@end

//====================================================================
@interface GSWSessionStore (GSWSessionStoreCreation)
+(GSWSessionStore*)serverSessionStore;
@end
/*
//====================================================================
@interface GSWSessionStore (GSWSessionStoreOldFn)
+(GSWSessionStore*)cookieSessionStoreWithDistributionDomain:(NSString*)aDomain
secure:(BOOL)flag;
+(GSWSessionStore*)pageSessionStore;
+(GSWSessionStore*)serverSessionStore;

-(GSWSession*)restoreSession;
-(void)saveSession:(GSWSession*)session;
@end
*/

//====================================================================
@interface GSWSessionStore (GSWSessionStoreA)
-(BOOL)_isSessionIDCheckedOut:(NSString*)aSessionID;

@end

//====================================================================
@interface GSWSessionStore (GSWSessionStoreB)
-(void)_validateAPI;
@end

//====================================================================
@interface GSWSessionStore (GSWSessionStoreInfo)
-(BOOL)containsSessionID:(NSString*)aSessionID;
-(NSArray *)allSessionIDs;
@end


#endif //_GSWSessionStore_h__
