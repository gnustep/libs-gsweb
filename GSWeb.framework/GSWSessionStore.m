/* GSWSessionStore.m - GSWeb: Class GSWSessionStore
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>


//====================================================================
@implementation GSWSessionStore

//--------------------------------------------------------------------
-(id)init
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  usedIDs=[NSMutableSet new];
	  lock=[NSRecursiveLock new];
	  [self _validateAPI];
	};
  LOGObjectFnStop();
  return self;   
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWSessionStore");
  GSWLogC("Dealloc GSWSessionStore: usedIDs");
  DESTROY(usedIDs);
  GSWLogC("Dealloc GSWSessionStore: lock");
  DESTROY(lock);
  GSWLogC("Dealloc GSWSessionStore Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWSessionStore");
};

//--------------------------------------------------------------------
-(GSWSession*)restoreSessionWithID:(NSString*)sessionID_
						  request:(GSWRequest*)request_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)saveSessionForContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(GSWSession*)checkOutSessionWithID:(NSString*)sessionID_
						   request:(GSWRequest*)request_
{
  GSWSession* _session=nil;
  BOOL _sessionUsed=YES;
  NSDate* limit=[NSDate dateWithTimeIntervalSinceNow:60];
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"sessionID_=%@",sessionID_);
  NSDebugMLLog(@"sessions",@"usedIDs=%@",usedIDs);
  NSDebugMLLog(@"sessions",@"self=%@",self);
  NSDebugMLLog(@"sessions",@"[NSDate date]=%@",[NSDate date]);
  NSDebugMLLog(@"sessions",@"limit=%@",limit);
  NSDebugMLLog(@"sessions",@"[[NSDate date]compare:limit]==NSOrderedAscending=%d",(int)([[NSDate date]compare:limit]==NSOrderedAscending));
  

  while(!_session && _sessionUsed && [[NSDate date]compare:limit]==NSOrderedAscending)
	{
	  BOOL _tmpUsed=NO;
	  if ([self tryLock])
		{
		  _tmpUsed=[usedIDs containsObject:sessionID_];
		  if (_tmpUsed)
			[self unlock];
		  else
			{
			  NS_DURING
				{
				  _session=[self _checkOutSessionWithID:sessionID_
								 request:request_];
				}
			  NS_HANDLER
				{
				  NSDebugMLLog(@"sessions",@"Can't checkOutSessionID=%@",sessionID_);
				  if ([[localException name]isEqualToString:@"GSWSessionStoreException"])
					_sessionUsed=YES;
				}
			  NS_ENDHANDLER;
			  [self unlock];
			  _sessionUsed=NO;
			  NSDebugMLLog(@"sessions",@"_session=%@",_session);
			};
		};
	};
  NSDebugMLLog(@"sessions",@"_session=%@",_session);
  LOGObjectFnStop();
  return _session;
};

//--------------------------------------------------------------------
-(void)checkInSessionForContext:(GSWContext*)context_
{
  //OK
  LOGObjectFnStart();
  if ([self tryLock])
	{
	  NS_DURING
		{
		  [self _checkInSessionForContext:context_];
		}
	  NS_HANDLER
		{
		  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In _checkInSessionForContext:");
		  LOGException(@"%@ (%@)",localException,[localException reason]);
		  //TODO
		  [self unlock];
		  [localException raise];
		}
	  NS_ENDHANDLER;
	  [self unlock];
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_checkInSessionForContext:(GSWContext*)context_
{
  //OK
  NSString* _sessionID=nil;
  GSWSession* _session=nil;
  LOGObjectFnStart();
  _session=[context_ existingSession];
  GSWLogAssertGood(_session);
  NSDebugMLLog(@"sessions",@"_session=%@",_session);
  NS_DURING
	{
	  [self saveSessionForContext:context_];
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In saveSessionForContext:");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  [localException raise];
	}
  NS_ENDHANDLER;
  GSWLogAssertGood(_session);
  NSDebugMLLog(@"sessions",@"_session=%@",_session);
  NS_DURING
	{
	  [_session _releaseAutoreleasePool];
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In [_session _releaseAutoreleasePool]");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  [localException raise];
	}
  NS_ENDHANDLER;
  GSWLogAssertGood(_session);
  NSDebugMLLog(@"sessions",@"_session=%@",_session);
  _sessionID=[_session sessionID];
  GSWLogAssertGood(_session);
  NSDebugMLLog(@"sessions",@"_sessionID=%@",_sessionID);
  NS_DURING
	{
	  [self _checkinSessionID:_sessionID];
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In _checkinSessionID");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  [localException raise];
	}
  NS_ENDHANDLER;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWSession*)_checkOutSessionWithID:(NSString*)sessionID_
							request:(GSWRequest*)request_
{
  GSWSession* _session=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"sessionID_=%@",sessionID_);
  NSDebugMLLog(@"sessions",@"self=%@",self);
  //OK
  NSDebugMLog0(@"starting:_checkoutSessionID");
  [self _checkoutSessionID:sessionID_];
  NSDebugMLog0(@"end of:_checkoutSessionID");
  NSDebugMLog0(@"starting:restoreSessionWithID");
  _session=[self restoreSessionWithID:sessionID_
				 request:request_];
  NSDebugMLog0(@"end of:restoreSessionWithID");
  if (_session)
	[_session _createAutoreleasePool];
  else
	[self _checkinSessionID:sessionID_];
  NSDebugMLLog(@"sessions",@"_session=%@",_session);
  LOGObjectFnStop();
  return _session;
};

//--------------------------------------------------------------------
-(void)_checkinSessionID:(NSString*)sessionID_
{
  LOGObjectFnStart();
  //OK
/*  if (![usedIDs containsObject:sessionID_])
	{
	  NSDebugMLLog(@"sessions",@"SessionID=%@ not is use",sessionID_);
	}
  else
	{*/
	  [usedIDs removeObject:sessionID_];
//	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_checkoutSessionID:(NSString*)sessionID_
{
  //OK
  LOGObjectFnStart();
  if ([usedIDs containsObject:sessionID_])
	{
	  NSDebugMLLog(@"sessions",@"SessionID=%@ already in use",sessionID_);
	  LOGException0(@"NSGenericException session used");
	  [NSException raise:@"GSWSessionStoreException"
				   format:@"Session %@ used",
				   sessionID_];
	}
  else
	{
	  [usedIDs addObject:sessionID_];
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"lockn=%d",lockn);
  TmpUnlock(lock);
#ifndef NDEBUG
	lockn--;
#endif
  NSDebugMLLog(@"sessions",@"lockn=%d",lockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(BOOL)tryLock
{
  BOOL locked=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"lockn=%d",lockn);
  locked=TmpTryLockBeforeDate(lock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
  if (locked)
	lockn++;
#endif
  NSDebugMLLog(@"sessions",@"lockn=%d",lockn);
  LOGObjectFnStop();
  return locked;
};

//--------------------------------------------------------------------
-(void)lock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"lockn=%d",lockn);
  TmpLockBeforeDate(lock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
  lockn++;
#endif
  NSDebugMLLog(@"sessions",@"lockn=%d",lockn);
  LOGObjectFnStop();
};

@end
//*
//====================================================================
@implementation GSWSessionStore (GSWSessionStoreCreation)

//--------------------------------------------------------------------
+(GSWSessionStore*)serverSessionStore
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWSessionStore (GSWSessionStoreOldFn)
/*
//--------------------------------------------------------------------
//	cookieSessionStoreWithDistributionDomain:secure:

+(GSWSessionStore*)cookieSessionStoreWithDistributionDomain:(NSString*)domain_
													secure:(BOOL)flag_
{
  return [[[GSWSessionStoreCookie alloc] initWithDistributionDomain:domain_
									   secure:flag_] autorelease];
};

//--------------------------------------------------------------------
//	pageSessionStore

+(GSWSessionStore*)pageSessionStore 
{
  return [[GSWSessionStorePage new] autorelease];
};

//--------------------------------------------------------------------
//	serverSessionStore

+(GSWSessionStore*)serverSessionStore 
{
  return [[GSWSessionStoreServer new] autorelease];
};
*/
//--------------------------------------------------------------------
//	restoreSession

-(GSWSession*)restoreSession
{
  //Does Nothing
  return nil;
};

//--------------------------------------------------------------------
//	saveSession:

-(void)saveSession:(GSWSession*)session_ 
{
  //Does Nothing
};

@end

//====================================================================
@implementation GSWSessionStore (GSWSessionStoreA)
-(BOOL)_isSessionIDCheckedOut:(NSString*)sessionID_
{
  //OK
  BOOL _checkedOut=NO;
  LOGObjectFnStart();
  _checkedOut=[usedIDs containsObject:sessionID_];
  LOGObjectFnStop();
  return _checkedOut;
};

@end

//====================================================================
@implementation GSWSessionStore (GSWSessionStoreB)
-(void)_validateAPI
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end









