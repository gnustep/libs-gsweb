/* GSWContext.m - GSWeb: Class GSWContext
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

static int dontTraceComponentActionURL=0;
//====================================================================
@implementation GSWContext

//--------------------------------------------------------------------
//	init

-(id)init 
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  [self _initWithContextID:(unsigned int)-1];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogAssertGood(self);
  NSDebugFLog(@"Dealloc GSWContext %p",(void*)self);
  NSDebugFLog0(@"Release GSWContext senderID");
  DESTROY(senderID);
  NSDebugFLog0(@"Release GSWContext requestSessionID");
  DESTROY(requestSessionID);
  NSDebugFLog0(@"Release GSWContext elementID");
  DESTROY(elementID);
  if (session)
	{
	  NSDebugFLog(@"sessionCount=%u",[session retainCount]);
	};
  NSDebugFLog0(@"Release GSWContext session");
  DESTROY(session);
  NSDebugFLog0(@"Release GSWContext request");
  DESTROY(request);
  NSDebugFLog0(@"Release GSWContext Response");
  DESTROY(response);
  NSDebugFLog0(@"Release GSWContext pageElement");
  DESTROY(pageElement);
  NSDebugFLog0(@"Release GSWContext pageComponent");
  DESTROY(pageComponent);
  NSDebugFLog0(@"Release GSWContext currentComponent");
  DESTROY(currentComponent);
  NSDebugFLog0(@"Release GSWContext url");
  DESTROY(url);
  NSDebugFLog0(@"Release GSWContext awakePageComponents");
  DESTROY(awakePageComponents);
  NSDebugFLog0(@"Dealloc GSWContext super");
  [super dealloc];
  NSDebugFLog0(@"end Dealloc GSWContext");
}

//--------------------------------------------------------------------
-(id)initWithRequest:(GSWRequest*)_request;
{
  //OK
  LOGObjectFnStart();
  if ((self=[self init]))
	{
	  [self _setRequest:_request];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
+(GSWContext*)contextWithRequest:(GSWRequest*)request_
{
  //OK
  GSWContext* _context=nil;
  LOGObjectFnStart();
  _context=[[[GSWContext alloc]
			  initWithRequest:request_]
			 autorelease];
  LOGObjectFnStop();
  return _context;
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone_
{
  GSWContext* clone = [[isa allocWithZone:zone_] init];
  if (clone)
	{
	  clone->contextID=contextID;
	  ASSIGNCOPY(clone->senderID,senderID);
	  ASSIGNCOPY(clone->requestSessionID,requestSessionID);
	  ASSIGNCOPY(clone->elementID,elementID);
	  ASSIGN(clone->session,session); //TODOV
	  ASSIGN(clone->request,request); //TODOV
	  ASSIGN(clone->response,response); //TODOV
	  ASSIGN(clone->pageElement,pageElement);
	  ASSIGN(clone->pageComponent,pageComponent);
	  ASSIGN(clone->currentComponent,currentComponent);
	  ASSIGNCOPY(clone->url,url);
	  ASSIGNCOPY(clone->awakePageComponents,awakePageComponents);
	  clone->urlApplicationNumber=urlApplicationNumber;
	  clone->isClientComponentRequest=isClientComponentRequest;
	  clone->distributionEnabled=distributionEnabled;
	  clone->pageChanged=pageChanged;
	  clone->pageReplaced=pageReplaced;
	  clone->generateCompleteURLs=generateCompleteURLs;
	  clone->isInForm=isInForm;
	  clone->actionInvoked=actionInvoked;
	  clone->formSubmitted=formSubmitted;
	  clone->isMultipleSubmitForm=isMultipleSubmitForm;
	};
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  //OK
  NSString* _desc=nil;
  dontTraceComponentActionURL++;
 _desc= [NSString stringWithFormat:
					@"%s: %p contextID=%@ senderID=%@ elementID=%@ session=%p request=%p response=%p pageElement=%p pageComponent=%p currentComponent=%p url=%@ urlApplicationNumber=%d isClientComponentRequest=%s distributionEnabled=%s pageChanged=%s pageReplaced=%s",
				   object_get_class_name(self),
				   (void*)self,
				   [self contextID],
				   [self senderID],
				   [self elementID],
				   (void*)[self existingSession],
				   (void*)[self request],
				   (void*)[self response],
				   (void*)pageElement,
				   (void*)pageComponent,
				   (void*)currentComponent,
				   url,
				   urlApplicationNumber,
				   isClientComponentRequest ? "YES" : "NO",
				   distributionEnabled ? "YES" : "NO",
				   pageChanged ? "YES" : "NO",
				   pageReplaced ? "YES" : "NO"];
  dontTraceComponentActionURL--;
  return _desc;
};

//--------------------------------------------------------------------
-(void)setInForm:(BOOL)_flag
{
  isInForm=_flag;
};

//--------------------------------------------------------------------
-(BOOL)isInForm
{
  return isInForm;
};

//--------------------------------------------------------------------
//	elementID
-(NSString*)elementID 
{
  return elementID;
};

//--------------------------------------------------------------------
-(GSWComponent*)component
{
  GSWComponent* _component=nil;
//  LOGObjectFnStart();
  _component=currentComponent;
//  LOGObjectFnStop();
  return _component;
};

//--------------------------------------------------------------------
-(NSString*)contextID
{
  //OK
  if (contextID==(unsigned int)-1)
	return nil;
  else
	return [NSString stringWithFormat:@"%u",contextID];
};

//--------------------------------------------------------------------
-(GSWComponent*)page
{
  if ([pageComponent _isPage]) //TODOV
	return pageComponent;
  else
	return nil;//TODOV
};

//--------------------------------------------------------------------
-(GSWRequest*)request
{
  return request;
};

//--------------------------------------------------------------------
-(GSWResponse*)response
{ 
  return response;
};

//--------------------------------------------------------------------
-(BOOL)hasSession
{
  return (session!=nil);
};

//--------------------------------------------------------------------
-(GSWSession*)session
{
  GSWSession* _session=nil;
  LOGObjectFnStart();
  if (session)
	_session=session;
  else
	{
	  _session=[GSWApp _initializeSessionInContext:self];
	};
  LOGObjectFnStop();
  return _session;
};

//--------------------------------------------------------------------
-(NSString*)senderID
{
  return senderID;
};

@end

//====================================================================
@implementation GSWContext (GSWURLGeneration)

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName_
									 queryDictionary:(NSDictionary*)queryDictionary_
{
  //OK
  GSWSession* _session=nil;
  GSWDynamicURLString* _url=nil;
  LOGObjectFnStart();
  _session=[self existingSession];
  NSDebugMLog(@"url=%@",url);
  _url=[self _directActionURLForActionNamed:actionName_
			 queryDictionary:queryDictionary_
			 url:url];
  LOGObjectFnStop();
  return _url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)componentActionURL
{
  //OK
  BOOL _storesIDsInURLs=NO;
  GSWDynamicURLString* _url=nil;
  GSWSession* _session=nil;
  NSString* _elementID=nil;
  NSString* _componentRequestHandlerKey=nil;
  NSString* _requestHandlerKey=nil;
  NSString* _requestHandlerPath=nil;
  LOGObjectFnStartCond(dontTraceComponentActionURL==0);
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"contextID=%u",contextID);
/*
  _url=[[url copy] autorelease];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_url=%@",_url);
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"urlApplicationNumber=%d",urlApplicationNumber);
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"[_url urlApplicationNumber]=%d",[_url urlApplicationNumber]);
  _session=[self session]; //OK
  NSDebugMLLogCond(dontTraceComponentActionURL==0,@"sessions",@"_session=%@",_session);
  NSDebugMLLogCond(dontTraceComponentActionURL==0,@"sessions",@"_sessionID=%@",[_session sessionID]);
  _elementID=[self elementID];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_elementID=%@",_elementID);
  _componentRequestHandlerKey=[GSWApplication componentRequestHandlerKey];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_componentRequestHandlerKey=%@",_componentRequestHandlerKey);
  [_url setURLRequestHandlerKey:_componentRequestHandlerKey];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_url=%@",_url);
  //call application pageCacheSize
  _storesIDsInURLs=[_session storesIDsInURLs];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_storesIDsInURLs=%s",(_storesIDsInURLs ? "YES" : "NO"));
  if (_storesIDsInURLs)
	{
	  NSString* _sessionID=[_session sessionID];
	  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_sessionID=%@",_sessionID);
	  [_url setURLRequestHandlerPath:[NSString stringWithFormat:@"%@/%u.%@",
											  _sessionID,
											  contextID,
											  _elementID]];
	  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_url=%@",_url);
	}
  else
	{
	  [_url setURLRequestHandlerPath:[NSString stringWithFormat:@"/%u.%@", //??
											   contextID,
											   _elementID]];
	  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_url=%@",_url);
	};
  [_url setURLQueryString:nil]; //???
*/
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"urlApplicationNumber=%d",urlApplicationNumber);
  _session=[self session]; //OK
  NSDebugMLLogCond(dontTraceComponentActionURL==0,@"sessions",@"_session=%@",_session);
  NSDebugMLLogCond(dontTraceComponentActionURL==0,@"sessions",@"_sessionID=%@",[_session sessionID]);
  _elementID=[self elementID];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_elementID=%@",_elementID);
  _componentRequestHandlerKey=[GSWApplication componentRequestHandlerKey];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_componentRequestHandlerKey=%@",_componentRequestHandlerKey);
  
  _requestHandlerKey=_componentRequestHandlerKey;
  _storesIDsInURLs=[_session storesIDsInURLs];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_storesIDsInURLs=%s",(_storesIDsInURLs ? "YES" : "NO"));
  if (_storesIDsInURLs)
	{
	  NSString* _sessionID=[_session sessionID];
	  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_sessionID=%@",_sessionID);
	  _requestHandlerPath=[NSString stringWithFormat:@"%@/%u.%@",
									_sessionID,
									contextID,
									_elementID];
	}
  else
	_requestHandlerPath=[NSString stringWithFormat:@"/%u.%@", //??
								  contextID,
								  _elementID];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_requestHandlerPath=%@",_requestHandlerPath);
  _url=[self urlWithRequestHandlerKey:_requestHandlerKey
			 path:_requestHandlerPath
			 queryString:nil];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"_url=%@",_url);
  LOGObjectFnStopCond(dontTraceComponentActionURL==0);
  return _url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)urlWithRequestHandlerKey:(NSString*)requestHandlerKey_
										  path:(NSString*)requestHandlerPath_
								   queryString:(NSString*)queryString_
{
  //OK
  GSWDynamicURLString* _url=nil;
  GSWRequest* _request=[self request];
  if (generateCompleteURLs)
	_url=[self completeURLWithRequestHandlerKey:requestHandlerKey_
			   path:requestHandlerPath_
			   queryString:queryString_];
  else
	_url=[_request _urlWithRequestHandlerKey:requestHandlerKey_
				   path:requestHandlerPath_
				   queryString:queryString_];
  return _url;
};

//--------------------------------------------------------------------
//NDFN
-(GSWDynamicURLString*)completeURLWithRequestHandlerKey:(NSString*)requestHandlerKey_
												   path:(NSString*)requestHandlerPath_
											queryString:(NSString*)queryString_
{
  GSWRequest* _request=nil;
  _request=[self request];
  return [self completeURLWithRequestHandlerKey:requestHandlerKey_
			   path:requestHandlerPath_
			   queryString:queryString_
			   isSecure:[_request isSecure]
			   port:[_request urlPort]];
};


//--------------------------------------------------------------------
-(GSWDynamicURLString*)completeURLWithRequestHandlerKey:(NSString*)requestHandlerKey_
												   path:(NSString*)requestHandlerPath_
											queryString:(NSString*)queryString_
											   isSecure:(BOOL)isSecure_
												   port:(int)port_
{
  GSWDynamicURLString* _url=nil;
  GSWRequest* _request=nil;
  LOGObjectFnStart();
  _request=[self request];
  _url=[_request _urlWithRequestHandlerKey:requestHandlerKey_
				 path:requestHandlerPath_
				 queryString:queryString_];
  NSDebugMLLog(@"low",@"_url=%@",_url);
  if (isSecure_)
	[_url setURLProtocol:GSWProtocol_HTTPS];
  else
	[_url setURLProtocol:GSWProtocol_HTTP];
  
  if (port_)
	[_url setURLPort:port_];

  [_url setURLHost:[_request urlHost]];
  NSDebugMLLog(@"low",@"_url=%@",_url);
  LOGObjectFnStop();
  return _url;
};

@end

//====================================================================
@implementation GSWContext (GSWContextA)

//--------------------------------------------------------------------
-(id)_initWithContextID:(unsigned int)_contextID
{
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"_contextID=%u",_contextID);
  contextID=_contextID;
  DESTROY(url);
  url=[GSWDynamicURLString new];
  DESTROY(awakePageComponents);
  awakePageComponents=[NSMutableArray new];
  urlApplicationNumber=-1;
  LOGObjectFnStop();
  return self;
};

@end

//====================================================================
@implementation GSWContext (GSWContextB)

//--------------------------------------------------------------------
-(BOOL)_isMultipleSubmitForm
{
  return isMultipleSubmitForm;
};

//--------------------------------------------------------------------
-(void)_setIsMultipleSubmitForm:(BOOL)_flag
{
  isMultipleSubmitForm=_flag;
};

//--------------------------------------------------------------------
-(BOOL)_wasActionInvoked
{
  return actionInvoked;
};

//--------------------------------------------------------------------
-(void)_setActionInvoked:(BOOL)_flag
{
  actionInvoked=_flag;
};

//--------------------------------------------------------------------
-(BOOL)_wasFormSubmitted
{
  return formSubmitted;
};

//--------------------------------------------------------------------
-(void)_setFormSubmitted:(BOOL)_flag
{
  formSubmitted=_flag;
};

//--------------------------------------------------------------------
-(void)_putAwakeComponentsToSleep
{
  //OK TODOV
  int i=0;
  GSWComponent* _component=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"awakePageComponents=%@",awakePageComponents);
  for(i=0;i<[awakePageComponents count];i++)
	{
	  _component=[awakePageComponents objectAtIndex:i];
	  [_component sleepInContext:self];
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_generateCompleteURLs
{
  generateCompleteURLs=YES;
};

//--------------------------------------------------------------------
-(id)_directActionURLForActionNamed:(NSString*)_actionName
					queryDictionary:(NSDictionary*)_dict
								url:(id)_url
{
  //OK
  NSString* _queryString=nil;
  NSEnumerator* _enumerator =nil;
  id _key=nil;
  LOGObjectFnStart();
//  _url=[[_url copy] autorelease];
  //TODOV
  _enumerator = [_dict keyEnumerator];
  while ((_key = [_enumerator nextObject]))
	{
	  if (!_queryString)
		_queryString=[[NSString new] autorelease];
	  else
		_queryString=[_queryString stringByAppendingString:@"&"];
	  _queryString=[_queryString stringByAppendingFormat:@"%@=%@",
								 _key,
								 [_dict objectForKey:_key]];
	};
  /*
  [_url setURLRequestHandlerKey:GSWDirectActionRequestHandlerKey];
  [_url setURLRequestHandlerPath:_actionName];
  [_url setURLQueryString:_queryString];
*/
  _url=[self completeURLWithRequestHandlerKey:GSWDirectActionRequestHandlerKey
			 path:_actionName
			 queryString:_queryString];
  LOGObjectFnStop();
  return _url;
};

//--------------------------------------------------------------------
-(NSArray*)languages
{
  NSArray* _languages=nil;
  if (request)
	{
	  _languages=[request browserLanguages];
	  if (!_languages)
		{
		  LOGError0(@"No languages in request");
		};
	};
  if (!_languages && session)
	{
	  _languages=[session languages];
	  if (!_languages)
		{
		  LOGError0(@"No languages in session");
		};
	};
  return _languages;
};

//--------------------------------------------------------------------
-(GSWComponent*)_pageComponent
{
  return pageComponent;
};

//--------------------------------------------------------------------
-(GSWElement*)_pageElement
{
  return pageElement;
};

//--------------------------------------------------------------------
-(void)_setPageElement:(GSWElement*)_element
{
  LOGObjectFnStart();
  ASSIGN(pageElement,_element);
  //TODOV
  [self _setPageComponent:(GSWComponent*)_element];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setPageComponent:(GSWComponent*)_component
{
  LOGObjectFnStart();
  ASSIGN(pageComponent,_component);
  if (_component)
	[self _takeAwakeComponent:_component];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setResponse:(GSWResponse*)_response;
{
  //OK
  LOGObjectFnStart();
  ASSIGN(response,_response);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setRequest:(GSWRequest*)_request;
{
  //OK
  NSString* _adaptorPrefix=nil;
  NSString* _applicationName=nil;
  LOGObjectFnStart();
  _adaptorPrefix=[_request adaptorPrefix];
  NSDebugMLLog(@"low",@"url=%@",url);
  [url setURLPrefix:_adaptorPrefix];
  NSDebugMLLog(@"low",@"url=%@",url);
  _applicationName=[_request applicationName];
  [url setURLApplicationName:_applicationName];
  NSDebugMLLog(@"low",@"url=%@",url);
  ASSIGN(request,_request);
  [self _synchronizeForDistribution];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setSession:(GSWSession*)_session
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"_session ID:%@",[_session sessionID]);
  ASSIGN(session,_session);
  [self _synchronizeForDistribution];
  NSDebugMLLog(@"low",@"contextID=%u",contextID);
  contextID=[session _contextCounter];
  NSDebugMLLog(@"low",@"contextID=%u",contextID);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setSenderID:(NSString*)_senderID
{
  LOGObjectFnStart();
  ASSIGNCOPY(senderID,_senderID);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_synchronizeForDistribution
{
  //OK
  LOGObjectFnStart();
  if (session)
	{
	  //call  session storesIDsInURLs [ret 1]
	  //call session isDistributionEnabled [ret 0]
	  [url setURLApplicationNumber:[request applicationNumber]];//OK
	}
  else
	[url setURLApplicationNumber:-1];//OK
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_incrementContextID
{
  [session _contextDidIncrementContextID];
};

//--------------------------------------------------------------------
//oldname= _session
-(GSWSession*)existingSession
{
  return session;
};

//--------------------------------------------------------------------
-(void)_setCurrentComponent:(GSWComponent*)_component
{
  //OK
  LOGObjectFnStart();
  ASSIGN(currentComponent,_component);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setPageReplaced:(BOOL)_flag
{
  pageReplaced=_flag;
};
  
//--------------------------------------------------------------------
-(BOOL)_pageReplaced
{
  return pageReplaced;
};

//--------------------------------------------------------------------
-(void)_setPageChanged:(BOOL)_flag
{
  pageChanged=_flag;
};

//--------------------------------------------------------------------
-(BOOL)_pageChanged
{
  return pageChanged;
};

//--------------------------------------------------------------------
-(void)_setRequestSessionID:(NSString*)_sessionID
{
  LOGObjectFnStart();
  ASSIGNCOPY(requestSessionID,_sessionID);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSString*)_requestSessionID
{
  return requestSessionID;
};

//--------------------------------------------------------------------
-(void)_takeAwakeComponentsFromArray:(id)_unknwon
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_takeAwakeComponent:(GSWComponent*)_component
{
  //OK
  LOGObjectFnStart();
  if (!awakePageComponents)
	awakePageComponents=[NSMutableArray new];
  [awakePageComponents addObject:_component];
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWContext (GSWContextC)

//--------------------------------------------------------------------
//	incrementLastElementIDComponent
-(void)incrementLastElementIDComponent 
{
//  LOGObjectFnStart();
  if (!elementID)
	elementID=[GSWElementIDString new];
  [elementID incrementLastElementIDComponent];
//  LOGObjectFnStop();
};



//--------------------------------------------------------------------
//	appendElementIDComponent:
-(void)appendElementIDComponent:(NSString*)string_ 
{
//  LOGObjectFnStart();
  if (!elementID)
	elementID=[GSWElementIDString new];
  [elementID appendElementIDComponent:string_];
//  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendZeroElementIDComponent
-(void)appendZeroElementIDComponent 
{
//  LOGObjectFnStart();
  if (!elementID)
	elementID=[GSWElementIDString new];
  [elementID appendZeroElementIDComponent];
//  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	deleteAllElementIDComponents
-(void)deleteAllElementIDComponents 
{
//  LOGObjectFnStart();
  [elementID deleteAllElementIDComponents];
//  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	deleteLastElementIDComponent
-(void)deleteLastElementIDComponent 
{
//  LOGObjectFnStart();
  if (!elementID)
	elementID=[GSWElementIDString new];
  [elementID deleteLastElementIDComponent];
//  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWContext (GSWContextD)
//--------------------------------------------------------------------
-(NSString*)url
{
  //OK
  GSWDynamicURLString* _componentActionURL=nil;
  LOGObjectFnStart();
  _componentActionURL=[self componentActionURL];
  LOGObjectFnStop();
  return (NSString*)_componentActionURL;
};

//--------------------------------------------------------------------
//	urlSessionPrefix

// return http://my.host.org/cgi-bin/GSWeb/MyApp.ApplicationSuffix/123456789012334567890123456789
-(NSString*)urlSessionPrefix 
{
  LOGObjectFnNotImplemented();	//TODOFN
  NSDebugMLLog(@"low",@"[request urlProtocolHorstPort]=%@",[request urlProtocolHostPort]);
  NSDebugMLLog(@"low",@"[request adaptorPrefix]=%@",[request adaptorPrefix]);
  NSDebugMLLog(@"low",@"[request applicationName]=%@",[request applicationName]);
  NSDebugMLLog(@"low",@"[session sessionID]=%@",[session sessionID]);
  return [NSString stringWithFormat:@"%@%@/%@.%@/%@",
				   [request urlProtocolHostPort],
				   [request adaptorPrefix],
				   [request applicationName],
				   GSWApplicationSuffix,
				   [session sessionID]];
};

//--------------------------------------------------------------------
-(GSWApplication*)application
{
  return [GSWApplication application];
};

//--------------------------------------------------------------------
//	isDistributionEnabled

-(BOOL)isDistributionEnabled 
{
  return distributionEnabled;
};

//--------------------------------------------------------------------
//	setDistributionEnabled:

-(void)setDistributionEnabled:(BOOL)isDistributionEnabled_
{
  distributionEnabled=isDistributionEnabled_;
};
@end

//====================================================================
@implementation GSWContext (GSWContextGSWeb)
-(BOOL)isValidate
{
  return isValidate;
};

//--------------------------------------------------------------------
-(void)setValidate:(BOOL)isValidate_
{
  isValidate = isValidate_;
  NSDebugMLLog(@"low",@"isValidate_=%d\n",(int)isValidate_);
};
@end
