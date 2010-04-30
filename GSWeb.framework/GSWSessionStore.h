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
  NSRecursiveLock* _lock;
  GSWSessionTimeOutManager* _timeOutManager;
#ifndef NDEBUG
  int _lockn;
#endif
};

-(GSWSession*)removeSessionWithID:(NSString*)aSessionID;
-(GSWSession*)restoreSessionWithID:(NSString*)aSessionID
                           request:(GSWRequest*)aRequest;
-(void)saveSessionForContext:(GSWContext*)aContext;
-(GSWSession*)checkOutSessionWithID:(NSString*)aSessionID
                            request:(GSWRequest*)aRequest;
-(void)checkInSessionForContext:(GSWContext*)aContext;

-(void)_checkInSessionForContext:(GSWContext*)aContext;

-(void)unlock;
-(void)lock;

@end

//====================================================================
@interface GSWSessionStore (GSWSessionStoreCreation)
+(GSWSessionStore*)serverSessionStore;
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
