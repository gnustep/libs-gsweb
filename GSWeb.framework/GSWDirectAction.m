/* GSWDirectAction.m - GSWeb: Class GSWDirectAction
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Feb 1999
   
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

#include <gsweb/GSWeb.framework/GSWeb.h>

//====================================================================
@implementation GSWDirectAction

//--------------------------------------------------------------------
-(id)initWithRequest:(GSWRequest*)request_
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  context=[GSWContext contextWithRequest:request_];
	  [GSWApp _setContext:context]; //NDFN
	  [self _initializeRequestSessionIDInContext:context];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(context);
  [super dealloc];
};

//--------------------------------------------------------------------
-(GSWRequest*)request
{
  return [context request];
};

//--------------------------------------------------------------------
-(GSWSession*)existingSession
{
  //OK
  GSWSession* _session=nil;
  BOOL _hasSession=NO;
  LOGObjectFnStart();
  _hasSession=[context hasSession];
  if (_hasSession)
	_session=[context existingSession];
  if (!_session)
	{
	  NSString* _sessionID=nil;
	  _sessionID=[[self request] sessionID];
	  if (_sessionID)
		{
		  NS_DURING
			{
			  NSDebugMLLog(@"requests",@"_sessionID=%@",_sessionID);
			  _session=[GSWApp restoreSessionWithID:_sessionID
							   inContext:context];
			  //No Exception if session can't be restored !
			}
		  NS_HANDLER
			{
			  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"in session create/restore");
			  LOGException(@"exception=%@",localException);
			  //No Exception if session can't be restored !
			  _session=nil;
			}
		  NS_ENDHANDLER;
		};
	};
  LOGObjectFnStop();
  return _session;
};

//--------------------------------------------------------------------
-(GSWSession*)session
{
  BOOL _hasSession=NO;
  GSWSession* _session=nil;
  LOGObjectFnStart();
  _hasSession=[context hasSession];
  if (_hasSession)
	_session=[context existingSession];
  if (!_session)
	{
	  NSString* _sessionID=nil;
	  _sessionID=[[self request] sessionID];
	  if (_sessionID)
		{
		  NS_DURING
			{
			  _session=[GSWApp restoreSessionWithID:_sessionID
							   inContext:context];
			}
		  NS_HANDLER
			{
			  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"in session create/restore");
			  LOGException(@"exception=%@",localException);
			  [localException raise];
			};
		  NS_ENDHANDLER;
		  if (!_session)
			{
			  ExceptionRaise(@"GSWDirectAction",
							 @"Unable to restore sessionID %@.",
							 _sessionID);
			};
		}
	  else
		{
		  // No Session ID: Create a new Session
		  _session=[context session];
		};
	};
  LOGObjectFnStop();
  return _session;
};

//--------------------------------------------------------------------
//	application

-(GSWApplication*)application 
{
  return [GSWApplication application];
};

//--------------------------------------------------------------------
-(GSWComponent*)pageWithName:(NSString*)pageName_
{
  //OK
  GSWComponent* _component=nil;
  LOGObjectFnStart();
  NS_DURING
	{
	  _component=[[GSWApplication application]pageWithName:pageName_
											  inContext:context];
	}
  NS_HANDLER
	{
	  LOGException(@"%@ (%@)",
				   localException,
				   [localException reason]);
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In pageWithName:inContext:");
	  [localException raise];
	};
  NS_ENDHANDLER;
  LOGObjectFnStop();
  return _component;
};

//--------------------------------------------------------------------
-(id <GSWActionResults>)performActionNamed:(NSString*)actionName_
{
  //OK
  id<GSWActionResults> _actionResult=nil;
  NSString* _actionSelName=nil;
  SEL _actionSel=NULL;
  LOGObjectFnStart();
  _actionSelName=[NSString stringWithFormat:@"%@Action",actionName_];
  NSDebugMLLog(@"requests",@"_actionSelName=%@",_actionSelName);
  _actionSel=NSSelectorFromString(_actionSelName);
  NSDebugMLLog(@"requests",@"_actionSel=%p",(void*)_actionSel);
  if (_actionSel)
	{
	  NS_DURING
		{
		  _actionResult=[self performSelector:_actionSel];
		  NSDebugMLLog(@"requests",
					   @"_actionResult=%@ class=%@",
					   _actionResult,
					   [_actionResult class]);
		}
	  NS_HANDLER
		{
		  LOGException(@"%@ (%@)",
					   localException,
					   [localException reason]);
		  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In performSelector:");
		  [localException raise];
		};
	  NS_ENDHANDLER;
	}
  else
	{
	  LOGError(@"No selector for: %@",_actionSelName);//TODO
	  _actionResult=[self defaultAction];//No ??
	};
  LOGObjectFnStop();
  return _actionResult;
};

//--------------------------------------------------------------------
-(id)defaultAction
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return nil;//??
};

//--------------------------------------------------------------------
-(void)_initializeRequestSessionIDInContext:(GSWContext*)_context
{
  //OK
  GSWRequest* _request=nil;
  NSString* _gswsid=nil;
  LOGObjectFnStart();
  _request=[_context request];
  _gswsid=[_request formValueForKey:GSWKey_SessionID];
  if (!_gswsid)
	{
	   _gswsid=[_request cookieValueForKey:GSWKey_SessionID];
	};
  if (_gswsid)
	{
	  //TODO
	};
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWDirectAction (GSWDirectActionA)
-(GSWContext*)_context
{
  //OK
  return context;
};

//--------------------------------------------------------------------
-(GSWSession*)_session
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

@end
//====================================================================
@implementation GSWDirectAction (GSWTakeValuesConvenience)

//--------------------------------------------------------------------
-(void)takeFormValueArraysForKeyArray:(NSArray*)keyArray_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)takeFormValuesForKeyArray:(NSArray*)keyArray_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)takeFormValueArraysForKeys:(NSString*)firstKey_, ...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)takeFormValuesForKeys:(NSString*)firstKey_, ...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWDirectAction (GSWDebugging)

//--------------------------------------------------------------------
-(void)logWithString:(NSString*)_string
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)format_,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(void)logWithFormat:(NSString*)format_,...
{
  LOGClassFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_debugWithString:(NSString*)_string
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)format_,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end


