/* GSWComponentRequestHandler.m - GSWeb: Class GSWComponentRequestHandler
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
@implementation GSWComponentRequestHandler

//--------------------------------------------------------------------
-(GSWResponse*)handleRequest:(GSWRequest*)request_
{
  //OK
  GSWResponse* _response=nil;
  GSWApplication* _application=[GSWApplication application];
  LOGObjectFnStart();
  [_application lockRequestHandling];
  _response=[self lockedHandleRequest:request_];
  [_application unlockRequestHandling];
  NSDebugMLLog(@"requests",@"_response=%@",_response);
  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
-(GSWResponse*)lockedHandleRequest:(GSWRequest*)request_
{
  //OK
  GSWStatisticsStore* _statisticsStore=nil;
  GSWApplication* _application=[GSWApplication application];
  GSWContext* _context=nil;
  GSWResponse* _response=nil;
  NSDictionary* _requestHandlerValues=nil;
  NSString* _senderID=nil;
  LOGObjectFnStart();
  _requestHandlerValues=[GSWComponentRequestHandler _requestHandlerValuesForRequest:request_];
  NSDebugMLLog(@"requests",@"_requestHandlerValues=%@",_requestHandlerValues);
  _statisticsStore=[[GSWApplication application]statisticsStore];
  NSDebugMLLog(@"requests",@"_statisticsStore=%@",_statisticsStore);
  [_statisticsStore _applicationWillHandleComponentActionRequest];
  _context=[GSWContext contextWithRequest:request_];
  _senderID=[_requestHandlerValues objectForKey:GSWKey_ElementID];
  NSDebugMLLog(@"requests",@"AA _senderID=%@",_senderID);
  [_context _setSenderID:_senderID];
  [_application _setContext:_context];
  NS_DURING
	{
	  [_application awake];
	  _response=[self lockedDispatchWithPreparedApplication:_application
					  inContext:_context
					  elements:_requestHandlerValues];
	}
  NS_HANDLER
	{
	  LOGException(@"%@ (%@)",
				   localException,
				   [localException reason]);
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In lockedDispatchWithPreparedApplication");
	  LOGException(@"exception=%@",localException);
	  _response=[_application handleException:localException
							  inContext:_context];
	  [_application sleep];
//	  [_response _finalizeInContext:_context];
	  NSAssert(!_response || [_response isFinalizeInContextHasBeenCalled],@"_finalizeInContext not called for GSWResponse");
	};
  NS_ENDHANDLER;
  NS_DURING
	{
	  [_application sleep];
	  [_response _finalizeInContext:_context];
	}
  NS_HANDLER
	{
	  LOGException(@"%@ (%@)",
				   localException,
				   [localException reason]);
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
															   @"In [application sleep] or [_response _finalizeInContext:_context]");
	  LOGException(@"exception=%@",localException);
	  _response=[_application handleException:localException
							  inContext:nil];
//	  [_response _finalizeInContext:_context];
	  NSAssert(!_response || [_response isFinalizeInContextHasBeenCalled],@"_finalizeInContext not called for GSWResponse");
	};
  NS_ENDHANDLER;
  [_application _setContext:nil];
  _statisticsStore=[[GSWApplication application] statisticsStore];
  [_statisticsStore _applicationDidHandleComponentActionRequest];

  NSDebugMLLog(@"requests",@"_response=%@",_response);
  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
-(GSWResponse*)lockedDispatchWithPreparedApplication:(GSWApplication*)_application
										   inContext:(GSWContext*)_context
											elements:(NSDictionary*)_elements
{
  //OK
  GSWResponse* _response=nil;
  GSWResponse* _errorResponse=nil;
  GSWSession* _session=nil;
  NSString* _sessionID=nil;
  LOGObjectFnStart();
  NS_DURING
	{
	  _sessionID=[_elements objectForKey:GSWKey_SessionID];
	  NSDebugMLLog(@"requests",@"_sessionID=%@",_sessionID);
	  if (_sessionID)
		{
		  _session=[_application restoreSessionWithID:_sessionID
								 inContext:_context];
		  if (!_session)
			{
			  _errorResponse=[_application handleSessionRestorationErrorInContext:_context];
			};
		}
	  else
		_session=[_application _initializeSessionInContext:_context];
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"in session create/restore");
	  LOGException(@"exception=%@",localException);
	  _errorResponse=[_application handleException:localException
								   inContext:_context];
	}
  NS_ENDHANDLER;
  if (!_response && !_errorResponse)
	{
	  if (_session)
		{
		  NSDebugMLLog(@"requests",@"_session=%@",_session);
		  NS_DURING
			{
			  _response=[self lockedDispatchWithPreparedSession:_session
							  inContext:_context
							  elements:_elements];
			}
		  NS_HANDLER
			{
			  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"in lockedDispatchWithPreparedSession");
			  LOGException(@"exception=%@",localException);
			  _errorResponse=[_application handleException:localException
										   inContext:_context];
			}
		  NS_ENDHANDLER;
		};
	};
  if (_response || _errorResponse)
	{
	  NSDebugMLLog(@"requests",@"_response=%@",_response);
	  NSDebugMLLog(@"requests",@"_errorResponse=%@",_errorResponse);
	  RETAIN(_response);
	  [_context _putAwakeComponentsToSleep];
	  [_application saveSessionForContext:_context];
	  NSDebugMLLog(@"requests",@"_session=%@",_session);
	  NSDebugMLLog(@"requests",@"_sessionCount=%u",[_session retainCount]);
	  NSDebugMLLog(@"requests",@"_response=%@",_response);
	  AUTORELEASE(_response);
	};
  LOGObjectFnStop();
  return _response ? _response : _errorResponse;
};

//--------------------------------------------------------------------
-(GSWResponse*)lockedDispatchWithPreparedSession:(GSWSession*)_session
								  inContext:(GSWContext*)_context
								   elements:(NSDictionary*)_elements
{
  //OK
  GSWResponse* _errorResponse=nil;
  GSWResponse* _response=nil;
  GSWComponent* _page=nil;
  BOOL _storesIDsInCookies=NO;
  NSString* _contextID=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"_session=%@",_session);
  NSDebugMLLog(@"requests",@"_context=%@",_context);
  _storesIDsInCookies=[_session storesIDsInCookies]; //For What ?
  _contextID=[_elements objectForKey:GSWKey_ContextID];
  if (_contextID) // ??
	{
	  NSAssert([_contextID length]>0,@"contextID empty");
	  _page=[self lockedRestorePageForContextID:_contextID
				  inSession:_session];
	  //??
	  NSDebugMLLog(@"requests",@"_contextID=%@",_contextID);
	  NSDebugMLLog(@"requests",@"_session=%@",_session);
	  NSDebugMLLog(@"requests",@"_page=%@",_page);
	  if (!_page)
		{
		  GSWApplication* _application=[_session application];
		  _errorResponse=[_application handlePageRestorationErrorInContext:_context];
		};
	}
  else
	{
	  NSString* _pageName=[_elements objectForKey:GSWKey_PageName];
	  NSException* _exception=nil;
	  NS_DURING
		{
		  _page=[[GSWApplication application] pageWithName:_pageName
											  inContext:_context];
		}
	  NS_HANDLER
		{
		  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In pageWithName");
		  LOGException(@"exception=%@",localException);
		  ASSIGN(_exception,localException);
		}
	  NS_ENDHANDLER;
	  if (!_page)
		{
		  _errorResponse=[[GSWApplication application] handleException:_exception
													   inContext:_context];
		};
	  DESTROY(_exception);
	};
  if (!_response && !_errorResponse && _page)
	{
	  [_context _setPageElement:_page];
	  _response=[self lockedDispatchWithPreparedPage:_page
					  inSession:_session
					  inContext:_context
					  elements:_elements];
	};
  if (_response)
	{
	  BOOL _isPageRefreshOnBacktrackEnabled=[[GSWApplication application] isPageRefreshOnBacktrackEnabled];
	  //TODO method adds a header to the HTTP response. This header sets the expiration date for an HTML page to the date and time of the creation of the page. Later, when the browser checks its cache for this page, it finds that the page is no longer valid and so refetches it by resubmitting the request URL to the WebObjects application.

	  [_session _saveCurrentPage];
	  if (!_contextID) // ??
		{
		  if (![_session storesIDsInCookies])//??
			[_session clearCookieFromResponse:_response];
		};
	};
  NSDebugMLLog(@"requests",@"_response=%@",_response);
  LOGObjectFnStop();
  return _response ? _response : _errorResponse;
};

//--------------------------------------------------------------------
-(GSWResponse*)lockedDispatchWithPreparedPage:(GSWComponent*)_component
									inSession:(GSWSession*)_session
									inContext:(GSWContext*)_context
									 elements:(NSDictionary*)_elements
{
  //OK
  GSWRequest* _request=nil;
  GSWResponse* _response=nil;
  GSWResponse* _errorResponse=nil;
  NSString* _senderID=nil;
  NSString* _contextID=nil;
  NSString* _httpVersion=nil;
  GSWElement* _page=nil;
  GSWElement* _responsePage=nil;
  BOOL _isFromClientComponent=NO;
  BOOL _hasFormValues=NO;
  GSWContext* _responseContext=nil;
  GSWComponent* _responsePageElement=nil;
  GSWRequest* _responseRequest=nil;

  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"_component=%@",_component);
  _request=[_context request];
  _contextID=[_elements objectForKey:GSWKey_ContextID];
  NSDebugMLLog(@"requests",@"_contextID=%@",_contextID);
  _response=[[GSWResponse new]autorelease];
  NSDebugMLLog(@"requests",@"_response=%@",_response);
  NSDebugMLLog(@"requests",@"_session=%@",_session);
  NSDebugMLLog(@"requests",@"_context=%@",_context);
  _senderID=[_context senderID];
  NSDebugMLLog(@"requests",@"AA _senderID=%@",_senderID);
  //TODO
  {
	GSWContext* _matchedContext=[_session _contextIDMatchingContextID:_contextID
										 requestSenderID:_senderID];
  }
  _httpVersion=[_request httpVersion];
  [_response setHTTPVersion:_httpVersion];
  [_response setHeader:@"text/html"
			 forKey:@"content-type"];
  [_context _setResponse:_response];
  _page=[_context page];
  if (_contextID)//??
	{
	  _hasFormValues=[_request _hasFormValues];
	}
  else
	{
	  [_context _setPageChanged:NO];
	  _isFromClientComponent=[_request isFromClientComponent];
	  //??
	  [_context _setPageReplaced:NO];
	  _isFromClientComponent=[_request isFromClientComponent];
	};
  if (_hasFormValues)
	{
	  NSDebugMLLog(@"requests",@"Before takeValues [_context elementID]=%@",[_context elementID]);
	  NSAssert([[_context elementID] length]==0,@"1 lockedDispatchWithPreparedPage elementID length>0");
	  [[GSWApplication application] takeValuesFromRequest:_request
									inContext:_context];
	  NSDebugMLLog(@"requests",@"After takeValues[_context elementID]=%@",[_context elementID]);
	  if (![[_context elementID] length]==0)
		{
		  LOGSeriousError0(@"2 lockedDispatchWithPreparedPage elementID length>0");
		  [_context deleteAllElementIDComponents];//NDFN
		};
	  [_context _setPageChanged:NO];//???
	  _isFromClientComponent=[_request isFromClientComponent];
	  [_context _setPageReplaced:NO];
	};
  if (_senderID) //??
	{
	  BOOL _pageChanged=NO;
	  NSException* _exception=nil;
	  NSDebugMLLog(@"requests",@"Before invokeAction [_context elementID]=%@",[_context elementID]);
	  NSAssert([[_context elementID] length]==0,@"3 lockedDispatchWithPreparedPage elementID length>0");
	  // Exception catching here ?
	  NS_DURING
		{
		  _responsePage=[[GSWApplication application] invokeActionForRequest:_request
													  inContext:_context];
		  NSDebugMLLog(@"requests",@"After invokeAction [_context elementID]=%@",[_context elementID]);
		  NSAssert([[_context elementID] length]==0,@"4 lockedDispatchWithPreparedPage elementID length>0");
		}
	  NS_HANDLER
		{
		  LOGException0(@"exception in invokeActionForRequest");
		  LOGException(@"exception=%@",localException);
		  localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
																  @"In invokeActionForRequest component=%@ of Class %@",
																  [_component name],
																  [_component class]);
		  ASSIGN(_exception,localException);
		  if (!_responsePage)
			{
			  _errorResponse=[[GSWApplication application] handleException:_exception
														   inContext:_context];
			};
		  DESTROY(_exception);
		}
	  NS_ENDHANDLER;
//	  [_context deleteAllElementIDComponents];//NDFN
	  NSDebugMLLog(@"requests",@"_responsePage=%@",_responsePage);
	  if (_errorResponse)
		{
		  _response=_errorResponse;
		  _responseContext=_context;
		}
	  else
		{
		  if (!_responsePage)
			_responsePage=_page;
		  
		  _responseContext=[(GSWComponent*)_responsePage context];//So what ?
		  NSDebugMLLog(@"requests",@"_responseContext=%@",_responseContext);
		  [_responseContext _setPageReplaced:NO];
		  _responsePageElement=[_responseContext _pageElement];
		  NSDebugMLLog(@"requests",@"_responsePageElement=%@",_responsePageElement);
		  _pageChanged=(_responsePage!=_responsePageElement);
		  [_responseContext _setPageChanged:_pageChanged];//??
		  if (_pageChanged)
			{
			  [_responseContext _setPageElement:_responsePage];
			};
		  _responseRequest=[_responseContext request];//SoWhat ?
		  [_responseRequest isFromClientComponent];//SoWhat
		};
	}
  else
	{
	  _responseContext=_context;
	  _responsePageElement=_page;
	  _responsePage=_component;
	  _responseRequest=_request;
	};
  if (!_errorResponse)
	{
	  NS_DURING
		{
		  NSDebugMLLog(@"requests",@"_response before appendToResponse=%@",_response);
		  NSDebugMLLog(@"requests",@"_responseContext=%@",_responseContext);
		  NSAssert([[_context elementID] length]==0,@"5 lockedDispatchWithPreparedPage elementID length>0");
		  NSDebugMLLog(@"requests",@"Before appendToResponse [_context elementID]=%@",[_context elementID]);
		  [[GSWApplication application] appendToResponse:_response
										inContext:_responseContext];
		  NSDebugMLLog(@"requests",@"After appendToResponse [_context elementID]=%@",[_context elementID]);
		  NSAssert([[_context elementID] length]==0,@"6 lockedDispatchWithPreparedPage elementID length>0");
		  _responseRequest=[_responseContext request];//SoWhat ?
		  [_responseRequest isFromClientComponent];//SoWhat
		}
	  NS_HANDLER
		{
		  localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
																  @"In appendToResponse page=%@ of Class %@",
																  [_page name],
																  [_page class]);
		  LOGException(@"exception=%@",localException);
		  NSDebugMLLog(@"requests",@"context=%@",_context);
		  _errorResponse=[[GSWApplication application] handleException:localException
													   inContext:_context];
		}
	  NS_ENDHANDLER;
	};
  NSDebugMLLog(@"requests",@"_response=%@",_response);
  LOGObjectFnStop();
  return _errorResponse ? _errorResponse : _response;
};

//--------------------------------------------------------------------
-(GSWComponent*)lockedRestorePageForContextID:(NSString*)_contextID
							  inSession:(GSWSession*)_session
{
  //OK
  GSWComponent* _page=[_session restorePageForContextID:_contextID];
  return _page;
};

@end

//====================================================================
@implementation GSWComponentRequestHandler (GSWRequestHandlerClassA)

//--------------------------------------------------------------------
+(id)handler
{
  return [[GSWComponentRequestHandler new] autorelease];
};

//--------------------------------------------------------------------
+(NSDictionary*)_requestHandlerValuesForRequest:(GSWRequest*)request_
{
  //OK
  NSDictionary* _values=nil;
  LOGClassFnStart();
  _values=[request_ uriOrFormOrCookiesElements];
  LOGClassFnStop();
  return _values;
};


@end

