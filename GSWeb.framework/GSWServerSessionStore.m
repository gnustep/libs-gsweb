/* GSWServerSessionStore.m - GSWeb: Class GSWServerSessionStore
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

//====================================================================
@implementation GSWServerSessionStore
-(id)init
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  timeOut_manager=[GSWSessionTimeOutManager new];
	  sessions=[NSMutableDictionary new];
	  [timeOut_manager setCallBack:@selector(removeSessionWithID:)
					   target:self];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(sessions);
  DESTROY(timeOut_manager);
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)description
{
  return [NSString stringWithFormat:@"<%s: %p sessions=%@ manager=%@>",
				   object_get_class_name(self),
				   (void*)self,
				   sessions,
				   timeOut_manager];
};

//--------------------------------------------------------------------
-(void)saveSessionForContext:(GSWContext*)context_
{
  //OK
  GSWSession* _session=nil;
  NSString* _sessionID=nil;
  NSTimeInterval _sessionTimeOut=0;
  BOOL _sessionIsTerminating=NO;
  LOGObjectFnStart();
  _session=[context_ existingSession];
  NSAssert(_session,@"No session!");
  NSDebugMLLog(@"sessions",@"_session=%@",_session);
  _sessionIsTerminating=[_session isTerminating]; //TODO
  [_session setDistributionEnabled:NO];
  _sessionID=[_session sessionID];
  NSAssert(_sessionID,@"No _sessionID!");
  NSDebugMLLog(@"sessions",@"_sessionID=%@",_sessionID);
  _sessionTimeOut=[_session timeOut];
  [sessions setObject:_session
			forKey:_sessionID];
  NSDebugMLLog(@"sessions",@"_session=%@",_session);
  NSDebugMLLog(@"sessions",@"_sessionTimeOut=%ld",(long)_sessionTimeOut);
  [timeOut_manager updateTimeOutForSessionWithID:_sessionID
				   timeOut:_sessionTimeOut];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(id)restoreSessionWithID:(NSString*)_sessionID
				  request:(GSWRequest*)request_
{
  GSWSession* _session=nil;
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"_sessionID=%@",_sessionID);
  NSDebugMLLog(@"sessions",@"sessions=%@",sessions);
  _session=[sessions objectForKey:_sessionID];
  NSDebugMLLog(@"sessions",@"_session=%@",_session);
  LOGObjectFnStop();
  return _session;
};

//--------------------------------------------------------------------
-(GSWSession*)removeSessionWithID:(NSString*)_sessionID
{
  //OK
  GSWSession* _session=nil;
  BOOL _isSessionIDCheckedOut=NO;
  LOGObjectFnStart();
  _isSessionIDCheckedOut=[self _isSessionIDCheckedOut:_sessionID];
  if (_isSessionIDCheckedOut)
	{
	  return nil;//Used Session
	}
  else
	{
	  _session=[sessions objectForKey:_sessionID];
	  NSDebugMLLog(@"sessions",@"_session=%@",_session);
	  [_session retain]; //to avoid discarding it now
	  [_session autorelease]; //discard it 'later'
	  [sessions removeObjectForKey:_sessionID];
	};
  LOGObjectFnStop();
  return _session;
};

@end

