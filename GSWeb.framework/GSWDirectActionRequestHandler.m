/* GSWDirectActionRequestHandler.m - GSWeb: Class GSWDirectActionRequestHandler
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
@implementation GSWDirectActionRequestHandler

//--------------------------------------------------------------------
-(GSWResponse*)handleRequest:(GSWRequest*)request_
{
  //OK
  GSWResponse* _response=nil;
  GSWStatisticsStore* _statisticsStore=nil;
  GSWApplication* _application=nil;
  LOGObjectFnStart();
  _application=[GSWApplication application];
  if ([_application isRefusingNewSessions])
	{
	  //TODO
	}
  else
	{
	  id _submitButtonsActionPathFromRequest=nil;
	  NSArray* _requestHandlerPathArray=nil;
	  NSString* _actionName=nil;
	  NSString* _className=nil;
	  GSWContext* _context=nil;
	  [_application lockRequestHandling];
	  NS_DURING
		{
		  _statisticsStore=[[GSWApplication application]statisticsStore];
		  [_statisticsStore _applicationWillHandleDirectActionRequest];
		  _submitButtonsActionPathFromRequest=[self submitButtonsActionPathFromRequest:request_]; //So what ?
		  NSDebugMLLog(@"requests",@"_submitButtonsActionPathFromRequest=%@",_submitButtonsActionPathFromRequest);
		  _requestHandlerPathArray=[request_ requestHandlerPathArray];
		  NSDebugMLLog(@"requests",@"_requestHandlerPathArray=%@",_requestHandlerPathArray);
		  switch([_requestHandlerPathArray count])
			{
			case 0:
			  _actionName=@"default";
			  _className=@"GSWDirectAction";
			  break;
			case 1:
			  {
				NSString* _tmpActionName=[NSString stringWithFormat:@"%@Action",
												   [_requestHandlerPathArray objectAtIndex:0]];
				SEL _tmpActionSel=NSSelectorFromString(_tmpActionName);
				NSDebugMLLog(@"requests",@"_tmpActionName=%@",_tmpActionName);
				if (_tmpActionSel)
				  {
					if ([GSWDirectAction instancesRespondToSelector:_tmpActionSel])
					  {
						_actionName=[_requestHandlerPathArray objectAtIndex:0];
						_className=@"GSWDirectAction";
					  };
				  };
				if (!_actionName)
				  {
					_className=[_requestHandlerPathArray objectAtIndex:0];
					_actionName=@"default";
				  };
			  };
			  break;
			case 2:
			  _className=[_requestHandlerPathArray objectAtIndex:0];
			  _actionName=[NSString stringWithFormat:@"%@",
									[_requestHandlerPathArray objectAtIndex:1]];
			  break;
			default:
			  ExceptionRaise0(@"GSWDirectActionRequestHandler",@"bad parameters count");
			  break;
			};
		  NSDebugMLLog(@"requests",@"_className=%@",_className);
		  NSDebugMLLog(@"requests",@"_actionName=%@",_actionName);
		  if ([_application isCachingEnabled])
			{
			  //TODO
			};
		  {
			GSWResourceManager* _resourceManager=nil;
			GSWDeployedBundle* _appBundle=nil;
			GSWDirectAction* _directAction=nil;
			id<GSWActionResults> _actionResult=nil;
			Class _class=nil;
			_resourceManager=[_application resourceManager];
			_appBundle=[_resourceManager _appProjectBundle];
			[_resourceManager _allFrameworkProjectBundles];//So what ?
			[_application awake];
			_class=NSClassFromString(_className);
			_directAction=[[_class alloc]initWithRequest:request_];
			_context=[_directAction _context];
			_actionResult=[_directAction performActionNamed:_actionName];
			_response=[_actionResult generateResponse];

			//Finir ?
		  };
		}
	  NS_HANDLER
		{
		  LOGException(@"%@ (%@)",localException,[localException reason]);
		  if (!_context)
			_context=[GSWApp _context];
		  _response=[_application handleException:localException
								  inContext:_context];
		  //TODO
		};
	  NS_ENDHANDLER;
	  NSDebugMLLog(@"requests",@"_response=%@",_response);
	  RETAIN(_response);
	  if (!_context)
		_context=[GSWApp _context];
	  [_context _putAwakeComponentsToSleep];
	  [_application saveSessionForContext:_context];
	  NSDebugMLLog(@"requests",@"_response=%@",_response);
	  AUTORELEASE(_response);
	  
	  //Here ???
	  [_application sleep];
	  //TODO do not fnalize if already done (in handleException for exemple)
	  [_response _finalizeInContext:_context];
	  [_application _setContext:nil];
	  _statisticsStore=[[GSWApplication application] statisticsStore];
	  [_statisticsStore _applicationDidHandleDirectActionRequestWithActionNamed:_actionName];

	  [_application unlockRequestHandling];
	};
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
-(GSWResponse*)_nilResponse
{
  //OK
  GSWResponse* _response=nil;
  LOGObjectFnStart();
  _response=[[GSWResponse new]autorelease];
  [_response appendContentString:@"<HTML><HEAD><TITLE>DirectAction Error</TITLE></HEAD><BODY>The result of a direct action returned nothing.</BODY></HTML>"];
  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
-(void)_initializeRequestSessionIDInContext:(GSWContext*)_context
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(id)submitButtonsActionPathFromRequest:(GSWRequest*)_request
{
  //OK
  NSArray* _submitActions=nil;
  LOGObjectFnStart();
  _submitActions=[_request formValuesForKey:GSWKey_SubmitAction];
  if (_submitActions)
	{
	  //TODO
	};

  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;
};

@end

//====================================================================
@implementation GSWDirectActionRequestHandler (GSWRequestHandlerClassA)

//--------------------------------------------------------------------
+(id)handler
{
  return [[GSWDirectActionRequestHandler new] autorelease];
};
@end

