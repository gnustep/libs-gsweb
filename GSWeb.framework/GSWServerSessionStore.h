/** GSWServerSessionStore.h - <title>GSWeb: Class GSWServerSessionStore</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 1999
   
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

#ifndef _GSWServerSessionStore_h__
	#define _GSWServerSessionStore_h__


//====================================================================
@interface GSWServerSessionStore : GSWSessionStore
{
  NSMutableDictionary* _sessions;
  GSWSessionTimeOutManager* _timeOutManager;
};

-(id)init;
-(void)dealloc;
-(id)description;
-(void)saveSessionForContext:(GSWContext*)aContext;
-(GSWSession*)restoreSessionWithID:(NSString*)aSessionID
                           request:(GSWRequest*)aRequest;
-(GSWSession*)removeSessionWithID:(NSString*)aSessionID;

@end

//====================================================================
@interface GSWServerSessionStore (GSWServerSessionStoreInfo)
-(BOOL)containsSessionID:(NSString*)aSessionID;
-(NSArray *)allSessionIDs;
@end

#endif //_GSWServerSessionStore_h__
