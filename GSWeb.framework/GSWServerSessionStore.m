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
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      _sessions=[NSMutableDictionary new];
    };
  LOGObjectFnStop();
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
                   object_get_class_name(self),
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
  LOGObjectFnStart();
  session=[aContext existingSession];
  NSDebugMLLog(@"sessions",@"session=%@",session);
  if (!session)
    {
      [NSException raise:@"IllegalStateException"
                   format:@"Current context has no existing session. Can't save session"];
    };

  sessionID=[session sessionID];
  NSAssert(sessionID,@"No _sessionID!");
  NSDebugMLLog(@"sessions",@"_sessionID=%@",sessionID);

  [_sessions setObject:session
             forKey:sessionID];

  NSDebugMLLog(@"sessions",@"session=%@",session);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** Should be Locked **/
-(id)restoreSessionWithID:(NSString*)aSessionID
                  request:(GSWRequest*)aRequest
{
  GSWSession* session=nil;
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"aSessionID=%@",aSessionID);
  NSDebugMLLog(@"sessions",@"sessions=%@",_sessions);
  session=[_sessions objectForKey:aSessionID];
  NSDebugMLLog(@"sessions",@"session=%@",session);
  LOGObjectFnStop();
  return session;
};

//--------------------------------------------------------------------
/** Should be Locked **/
-(GSWSession*)removeSessionWithID:(NSString*)aSessionID
{
  //OK
  GSWSession* session=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"aSessionID=%@",aSessionID);

  NSDebugMLLog(@"sessions",@"_sessions=%@",_sessions);
  session=[_sessions objectForKey:aSessionID];
  NSDebugMLLog(@"sessions",@"session=%@",session);
  RETAIN(session); //to avoid discarding it now
  [_sessions removeObjectForKey:aSessionID];
  NSDebugMLLog(@"sessions",@"_sessions=%@",_sessions);
  AUTORELEASE(session); //discard it 'later'

  LOGObjectFnStop();
  return session;
};

@end

//====================================================================
@implementation GSWServerSessionStore (GSWServerSessionStoreInfo)
-(BOOL)containsSessionID:(NSString*)aSessionID
{
  BOOL contain = NO;
  //OK
  LOGObjectFnStart();
  if([_sessions objectForKey:aSessionID]) 
    contain = YES;
  LOGObjectFnStop();
  return contain;
};

-(NSArray *)allSessionIDs
{
  return [_sessions allKeys];
}

@end

