/** GSWServerSessionStore.m - <title>GSWeb: Class GSWServerSessionStore</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

//====================================================================
@implementation GSWServerSessionStore
-(id)init
{
  //OK
  if ((self=[super init]))
    {
      _sessions=[NSMutableDictionary new];
    };

  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_sessions);
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)description
{
  return [NSString stringWithFormat:@"<%s: %p sessions=%@ manager=%@>",
                   object_getClassName(self),
                   (void*)self,
                   _sessions,
                   _timeOutManager];
};

//--------------------------------------------------------------------
/** Should be Locked **/
-(void)saveSessionForContext:(GSWContext*)aContext
{
  //OK
  GSWSession* session=nil;
  NSString* sessionID=nil;
  session=[aContext existingSession];

  if (!session)
    {
      [NSException raise:@"IllegalStateException"
                   format:@"Current context has no existing session. Can't save session"];
    };

  sessionID=[session sessionID];
  NSAssert(sessionID,@"No _sessionID!");

  [_sessions setObject:session
             forKey:sessionID];

}

//--------------------------------------------------------------------
/** Should be Locked **/
-(GSWSession*)restoreSessionWithID:(NSString*)aSessionID
                  request:(GSWRequest*)aRequest
{
  GSWSession* session=nil;

  session = [_sessions objectForKey:aSessionID];
  return session;
}

//--------------------------------------------------------------------
/** Should be Locked **/
-(GSWSession*)removeSessionWithID:(NSString*)aSessionID
{
  GSWSession* session=nil;
  session=[_sessions objectForKey:aSessionID];
  RETAIN(session); //to avoid discarding it now
  [_sessions removeObjectForKey:aSessionID];
  AUTORELEASE(session); //discard it 'later'

  return session;
}

@end

//====================================================================
@implementation GSWServerSessionStore (GSWServerSessionStoreInfo)
-(BOOL)containsSessionID:(NSString*)aSessionID
{
  BOOL contain = NO;
  //OK
  if([_sessions objectForKey:aSessionID]) 
    contain = YES;
  return contain;
};

-(NSArray *)allSessionIDs
{
  return [_sessions allKeys];
}

@end

