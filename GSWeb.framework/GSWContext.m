/** GSWContext.m - <title>GSWeb: Class GSWContext</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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
  DESTROY(_senderID);
  NSDebugFLog0(@"Release GSWContext requestSessionID");
  DESTROY(_requestSessionID);
  NSDebugFLog0(@"Release GSWContext elementID");
  DESTROY(_elementID);
  if (_session)
	{
	  NSDebugFLog(@"sessionCount=%u",[_session retainCount]);
	};
  NSDebugFLog0(@"Release GSWContext session");
  DESTROY(_session);
  NSDebugFLog0(@"Release GSWContext request");
  DESTROY(_request);
  NSDebugFLog0(@"Release GSWContext Response");
  DESTROY(_response);
  NSDebugFLog0(@"Release GSWContext pageElement");
  DESTROY(_pageElement);
  NSDebugFLog0(@"Release GSWContext pageComponent");
  DESTROY(_pageComponent);
  NSDebugFLog0(@"Release GSWContext currentComponent");
  DESTROY(_currentComponent);
  NSDebugFLog0(@"Release GSWContext url");
  DESTROY(_url);
  NSDebugFLog0(@"Release GSWContext awakePageComponents");
  DESTROY(_awakePageComponents);
#ifndef NDEBUG
  DESTROY(_docStructure);
  DESTROY(_docStructureElements);
#endif
  NSDebugFLog0(@"Dealloc GSWContext super");
  [super dealloc];
  NSDebugFLog0(@"end Dealloc GSWContext");
}

//--------------------------------------------------------------------
-(id)initWithRequest:(GSWRequest*)aRequest
{
  //OK
  LOGObjectFnStart();
  if ((self=[self init]))
    {
      [self _setRequest:aRequest];
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
+(GSWContext*)contextWithRequest:(GSWRequest*)aRequest
{
  //OK
  GSWContext* context=nil;
  LOGObjectFnStart();
  context=[[[GSWContext alloc]
             initWithRequest:aRequest]
            autorelease];
  LOGObjectFnStop();
  return context;
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWContext* clone = [[isa allocWithZone:zone] init];
  if (clone)
    {
      clone->_contextID=_contextID;
      ASSIGNCOPY(clone->_senderID,_senderID);
      ASSIGNCOPY(clone->_requestSessionID,_requestSessionID);
      ASSIGNCOPY(clone->_elementID,_elementID);
      ASSIGN(clone->_session,_session); //TODOV
      ASSIGN(clone->_request,_request); //TODOV
      ASSIGN(clone->_response,_response); //TODOV
      ASSIGN(clone->_pageElement,_pageElement);
      ASSIGN(clone->_pageComponent,_pageComponent);
      ASSIGN(clone->_currentComponent,_currentComponent);
      ASSIGNCOPY(clone->_url,_url);
      ASSIGNCOPY(clone->_awakePageComponents,_awakePageComponents);
      clone->_urlApplicationNumber=_urlApplicationNumber;
      clone->_isClientComponentRequest=_isClientComponentRequest;
      clone->_distributionEnabled=_distributionEnabled;
      clone->_pageChanged=_pageChanged;
      clone->_pageReplaced=_pageReplaced;
      clone->_generateCompleteURLs=_generateCompleteURLs;
      clone->_isInForm=_isInForm;
      clone->_actionInvoked=_actionInvoked;
      clone->_formSubmitted=_formSubmitted;
      clone->_isMultipleSubmitForm=_isMultipleSubmitForm;
    };
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  //OK
  NSString* desc=nil;
  dontTraceComponentActionURL++;
  desc= [NSString stringWithFormat:
                    @"%s: %p contextID=%@ senderID=%@ elementID=%@ session=%p request=%p response=%p pageElement=%p pageComponent=%p currentComponent=%p url=%@ urlApplicationNumber=%d isClientComponentRequest=%s distributionEnabled=%s pageChanged=%s pageReplaced=%s",
                  object_get_class_name(self),
                  (void*)self,
                  [self contextID],
                  [self senderID],
                  [self elementID],
                  (void*)[self existingSession],
                  (void*)[self request],
                  (void*)[self response],
                  (void*)_pageElement,
                  (void*)_pageComponent,
                  (void*)_currentComponent,
                  _url,
                  _urlApplicationNumber,
                  _isClientComponentRequest ? "YES" : "NO",
                  _distributionEnabled ? "YES" : "NO",
                  _pageChanged ? "YES" : "NO",
                  _pageReplaced ? "YES" : "NO"];
  dontTraceComponentActionURL--;
  return desc;
};

//--------------------------------------------------------------------
-(void)setInForm:(BOOL)flag
{
  _isInForm=flag;
};

//--------------------------------------------------------------------
-(BOOL)isInForm
{
  return _isInForm;
};

//--------------------------------------------------------------------
//	elementID
-(GSWElementIDString*)elementID 
{
  return _elementID;
};

//--------------------------------------------------------------------
-(GSWComponent*)component
{
  GSWComponent* component=nil;
//  LOGObjectFnStart();
  component=_currentComponent;
//  LOGObjectFnStop();
  return component;
};

//--------------------------------------------------------------------
-(NSString*)contextID
{
  //OK
  if (_contextID==(unsigned int)-1)
    return nil;
  else
    return [NSString stringWithFormat:@"%u",_contextID];
};

//--------------------------------------------------------------------
-(GSWComponent*)page
{
  if ([_pageComponent _isPage]) //TODOV
    return _pageComponent;
  else
    return nil;//TODOV
};

//--------------------------------------------------------------------
-(GSWRequest*)request
{
  return _request;
};

//--------------------------------------------------------------------
-(GSWResponse*)response
{ 
  return _response;
};

//--------------------------------------------------------------------
-(BOOL)hasSession
{
  return (_session!=nil);
};

//--------------------------------------------------------------------
-(GSWSession*)session
{
  GSWSession* session=nil;
  LOGObjectFnStart();
  if (_session)
    session=_session;
  else
    {
      session=[GSWApp _initializeSessionInContext:self];
    };
  LOGObjectFnStop();
  return session;
};

//--------------------------------------------------------------------
-(NSString*)senderID
{
  return _senderID;
};

#ifndef NDEBUG
-(void)incrementLoopLevel //ForDebugging purpose: each repetition increment and next decrement it
{
  _loopLevel++;
};
-(void)decrementLoopLevel
{
  _loopLevel--;
};

-(BOOL)isInLoop
{
  return _loopLevel>0;
};

-(void)addToDocStructureElement:(id)element
{
  if(GSDebugSet(@"GSWDocStructure"))
    {
      NSString* string=nil;
      int elementIDNb=[[self elementID] elementsNb];
      NSMutableData* data=[NSMutableData dataWithCapacity:elementIDNb+1];
      char* ptab=(char*)[data bytes];
      if (!_docStructure)
        _docStructure=[NSMutableString new];
      if (!_docStructureElements)
        _docStructureElements=[NSMutableSet new];
      memset(ptab,'\t',elementIDNb);
      ptab[elementIDNb]='\0';
      string=[NSString stringWithFormat:@"%s %@ Element %p Class %@ defName=%@\n",
                       ptab,
                       [self elementID],
                       element,
                       [element class],
                       [element definitionName]];
      if (![_docStructureElements containsObject:string])
        {
          [_docStructure appendString:string];
          [_docStructureElements addObject:string];
        };
    };
}

-(void)addDocStructureStep:(NSString*)stepLabel
{
  if(GSDebugSet(@"GSWDocStructure"))
    {
      if (!_docStructure)
        _docStructure=[NSMutableString new];
      [_docStructureElements removeAllObjects];
      [_docStructure appendFormat:@"===== %@ =====\n",stepLabel];
    };
}

-(NSString*)docStructure
{
  if(GSDebugSet(@"GSWDocStructure"))
    return _docStructure;
  else
    return nil;
}
#endif

@end

//====================================================================
@implementation GSWContext (GSWURLGeneration)

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary
{
  //OK
  GSWSession* session=nil;
  GSWDynamicURLString* url=nil;
  LOGObjectFnStart();
  session=[self existingSession];
  NSDebugMLog(@"url=%@",url);
  url=[self _directActionURLForActionNamed:actionName
            queryDictionary:queryDictionary
            url:url];
  LOGObjectFnStop();
  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)componentActionURL
{
  //OK
  BOOL storesIDsInURLs=NO;
  GSWDynamicURLString* url=nil;
  GSWSession* session=nil;
  NSString* elementID=nil;
  NSString* componentRequestHandlerKey=nil;
  NSString* requestHandlerKey=nil;
  NSString* requestHandlerPath=nil;
  LOGObjectFnStartCond(dontTraceComponentActionURL==0);
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"contextID=%u",_contextID);
/*
  url=[[url copy] autorelease];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"url=%@",url);
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"urlApplicationNumber=%d",_urlApplicationNumber);
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"[url urlApplicationNumber]=%d",[url urlApplicationNumber]);
  session=[self session]; //OK
  NSDebugMLLogCond(dontTraceComponentActionURL==0,@"sessions",@"session=%@",session);
  NSDebugMLLogCond(dontTraceComponentActionURL==0,@"sessions",@"sessionID=%@",[session sessionID]);
  elementID=[self elementID];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"elementID=%@",elementID);
  componentRequestHandlerKey=[GSWApplication componentRequestHandlerKey];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"componentRequestHandlerKey=%@",componentRequestHandlerKey);
  [url setURLRequestHandlerKey:componentRequestHandlerKey];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"url=%@",url);
  //call application pageCacheSize
  storesIDsInURLs=[session storesIDsInURLs];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"storesIDsInURLs=%s",(storesIDsInURLs ? "YES" : "NO"));
  if (storesIDsInURLs)
	{
	  NSString* sessionID=[session sessionID];
	  NSDebugMLogCond(dontTraceComponentActionURL==0,@"sessionID=%@",sessionID);
	  [url setURLRequestHandlerPath:[NSString stringWithFormat:@"%@/%u.%@",
          sessionID,
          contextID,
          elementID]];
	  NSDebugMLogCond(dontTraceComponentActionURL==0,@"url=%@",url);
	}
  else
	{
	  [url setURLRequestHandlerPath:[NSString stringWithFormat:@"/%u.%@", //??
											   _contextID,
											   elementID]];
	  NSDebugMLogCond(dontTraceComponentActionURL==0,@"url=%@",url);
	};
  [url setURLQueryString:nil]; //???
*/
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"urlApplicationNumber=%d",_urlApplicationNumber);
  session=[self session]; //OK
  NSDebugMLLogCond(dontTraceComponentActionURL==0,@"sessions",@"session=%@",session);
  NSDebugMLLogCond(dontTraceComponentActionURL==0,@"sessions",@"sessionID=%@",[session sessionID]);
  elementID=[self elementID];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"elementID=%@",elementID);
  componentRequestHandlerKey=[GSWApplication componentRequestHandlerKey];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"componentRequestHandlerKey=%@",componentRequestHandlerKey);
  
  requestHandlerKey=componentRequestHandlerKey;
  storesIDsInURLs=[session storesIDsInURLs];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"storesIDsInURLs=%s",(storesIDsInURLs ? "YES" : "NO"));
  if (storesIDsInURLs)
    {
      NSString* sessionID=[_session sessionID];
      NSDebugMLogCond(dontTraceComponentActionURL==0,@"sessionID=%@",sessionID);
      requestHandlerPath=[NSString stringWithFormat:@"%@/%u.%@",
                                   sessionID,
                                   _contextID,
                                   elementID];
    }
  else
    requestHandlerPath=[NSString stringWithFormat:@"/%u.%@", //??
                                 _contextID,
                                 elementID];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"requestHandlerPath=%@",requestHandlerPath);
  url=[self urlWithRequestHandlerKey:requestHandlerKey
            path:requestHandlerPath
            queryString:nil];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"url=%@",url);
  LOGObjectFnStopCond(dontTraceComponentActionURL==0);
  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)urlWithRequestHandlerKey:(NSString*)requestHandlerKey
                                           path:(NSString*)requestHandlerPath
                                    queryString:(NSString*)queryString
{
  //OK
  GSWDynamicURLString* url=nil;
  GSWRequest* request=[self request];
  LOGObjectFnStartCond(dontTraceComponentActionURL==0);
  NSDebugMLogCond(dontTraceComponentActionURL==0,
                  @"generateCompleteURLs=%s",
                  (_generateCompleteURLs ? "YES" : "NO"));
  if (_generateCompleteURLs)
    url=[self completeURLWithRequestHandlerKey:requestHandlerKey
              path:requestHandlerPath
              queryString:queryString];
  else
    url=[request _urlWithRequestHandlerKey:requestHandlerKey
                 path:requestHandlerPath
                 queryString:queryString];
  NSDebugMLogCond(dontTraceComponentActionURL==0,
                  @"url=%@",url);
  LOGObjectFnStopCond(dontTraceComponentActionURL==0);
  return url;
};

//--------------------------------------------------------------------
//NDFN
-(GSWDynamicURLString*)completeURLWithRequestHandlerKey:(NSString*)requestHandlerKey
                                                   path:(NSString*)requestHandlerPath
                                            queryString:(NSString*)queryString
{
  GSWRequest* request=nil;
  request=[self request];
  return [self completeURLWithRequestHandlerKey:requestHandlerKey
               path:requestHandlerPath
               queryString:queryString
               isSecure:[request isSecure]
               port:[request urlPort]];
};


//--------------------------------------------------------------------
-(GSWDynamicURLString*)completeURLWithRequestHandlerKey:(NSString*)requestHandlerKey
                                                   path:(NSString*)requestHandlerPath
                                            queryString:(NSString*)queryString
                                               isSecure:(BOOL)isSecure
                                                   port:(int)port
{
  NSString* host=nil;
  GSWDynamicURLString* url=nil;
  GSWRequest* request=nil;
  LOGObjectFnStart();
  request=[self request];
  url=[_request _urlWithRequestHandlerKey:requestHandlerKey
                path:requestHandlerPath
                queryString:queryString];
  NSDebugMLLog(@"low",@"url=%@",url);
  if (isSecure)
    [url setURLProtocol:GSWProtocol_HTTPS];
  else
    [url setURLProtocol:GSWProtocol_HTTP];
  
  if (port)
    [url setURLPort:port];
  NSDebugMLLog(@"low",@"url=%@",url);
  host=[request urlHost];
  NSAssert(host,@"No host !");
  NSDebugMLLog(@"low",@"host=%@",host);
  [url setURLHost:host];
  NSDebugMLLog(@"low",@"url=%@",url);
  LOGObjectFnStop();
  return url;
};

@end

//====================================================================
@implementation GSWContext (GSWContextA)

//--------------------------------------------------------------------
-(id)_initWithContextID:(unsigned int)contextID
{
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"contextID=%u",contextID);
  _contextID=contextID;
  DESTROY(_url);
  _url=[GSWDynamicURLString new];
  DESTROY(_awakePageComponents);
  _awakePageComponents=[NSMutableArray new];
  _urlApplicationNumber=-1;
  LOGObjectFnStop();
  return self;
};

@end

//====================================================================
@implementation GSWContext (GSWContextB)

//--------------------------------------------------------------------
-(BOOL)_isMultipleSubmitForm
{
  return _isMultipleSubmitForm;
};

//--------------------------------------------------------------------
-(void)_setIsMultipleSubmitForm:(BOOL)flag
{
  _isMultipleSubmitForm=flag;
};

//--------------------------------------------------------------------
-(BOOL)_wasActionInvoked
{
  return _actionInvoked;
};

//--------------------------------------------------------------------
-(void)_setActionInvoked:(BOOL)flag
{
  _actionInvoked=flag;
};

//--------------------------------------------------------------------
-(BOOL)_wasFormSubmitted
{
  return _formSubmitted;
};

//--------------------------------------------------------------------
-(void)_setFormSubmitted:(BOOL)flag
{
  _formSubmitted=flag;
};

//--------------------------------------------------------------------
-(void)_putAwakeComponentsToSleep
{
  //OK TODOV
  int i=0;
  GSWComponent* component=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"awakePageComponents=%@",_awakePageComponents);
  for(i=0;i<[_awakePageComponents count];i++)
    {
      component=[_awakePageComponents objectAtIndex:i];
      [component sleepInContext:self];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_generateCompleteURLs
{
  _generateCompleteURLs=YES;
};

//--------------------------------------------------------------------
//_url is a semi complete one: line /cgi/WebObjects.exe/ObjCTest3.woa
-(id)_directActionURLForActionNamed:(NSString*)actionName
                    queryDictionary:(NSDictionary*)dict
                                url:(id)anURL
{
  //OK
  NSString* queryString=nil;
  NSEnumerator* enumerator =nil;
  id key=nil;
  LOGObjectFnStart();
  NSDebugMLogCond(dontTraceComponentActionURL==0,
                  @"anURL=%@",anURL);
//  _url=[[_url copy] autorelease];
  //TODOV
  enumerator = [dict keyEnumerator];
  while ((key = [enumerator nextObject]))
    {
      if (!queryString)
        queryString=[[NSString new] autorelease];
      else
        queryString=[queryString stringByAppendingString:@"&"];
      queryString=[queryString stringByAppendingFormat:@"%@=%@",
                               key,
                               [dict objectForKey:key]];
    };
  /*
    [anURL setURLRequestHandlerKey:GSWDirectActionRequestHandlerKey[GSWebNamingConv]];
  [anURL setURLRequestHandlerPath:actionName];
  [anURL setURLQueryString:queryString];
*/
  anURL=[self completeURLWithRequestHandlerKey:GSWDirectActionRequestHandlerKey[GSWebNamingConv]
			 path:actionName
              queryString:queryString];
  NSDebugMLogCond(dontTraceComponentActionURL==0,
                  @"url=%@",anURL);
  LOGObjectFnStop();
  return anURL;
};

//--------------------------------------------------------------------
-(NSArray*)languages
{
  NSArray* languages=nil;
  if (_request)
    {
      languages=[_request browserLanguages];
      if (!languages)
        {
          LOGError0(@"No languages in request");
        };
    };
  if (!languages && _session)
    {
      languages=[_session languages];
      if (!languages)
        {
          LOGError0(@"No languages in session");
        };
    };
  //Not WO: It enable application languages filtering
  languages=[GSWApp filterLanguages:languages];
  return languages;
};

//--------------------------------------------------------------------
-(GSWComponent*)_pageComponent
{
  return _pageComponent;
};

//--------------------------------------------------------------------
-(GSWElement*)_pageElement
{
  return _pageElement;
};

//--------------------------------------------------------------------
-(void)_setPageElement:(GSWElement*)element
{
  LOGObjectFnStart();
  ASSIGN(_pageElement,element);
  //TODOV
  [self _setPageComponent:(GSWComponent*)element];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setPageComponent:(GSWComponent*)component
{
  LOGObjectFnStart();
  ASSIGN(_pageComponent,component);
  if (component)
    [self _takeAwakeComponent:component];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setResponse:(GSWResponse*)aResponse
{
  //OK
  LOGObjectFnStart();
  ASSIGN(_response,aResponse);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setRequest:(GSWRequest*)aRequest
{
  //OK
  NSString* adaptorPrefix=nil;
  NSString* applicationName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"aRequest=%@",aRequest);
  NSDebugMLLog(@"low",@"url=%@",_url);
  adaptorPrefix=[aRequest adaptorPrefix];
  NSDebugMLLog(@"low",@"adaptorPrefix=%@",adaptorPrefix);
  [_url setURLPrefix:adaptorPrefix];
  NSDebugMLLog(@"low",@"url=%@",_url);
  applicationName=[aRequest applicationName];
  NSDebugMLLog(@"low",@"applicationName=%@",applicationName);
  [_url setURLApplicationName:applicationName];
  NSDebugMLLog(@"low",@"url=%@",_url);
  ASSIGN(_request,aRequest);
  [self _synchronizeForDistribution];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setSession:(GSWSession*)aSession
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"aSession ID:%@",[aSession sessionID]);
  ASSIGN(_session,aSession);
  [self _synchronizeForDistribution];
  NSDebugMLLog(@"low",@"contextID=%u",_contextID);
  _contextID=[_session _contextCounter];
  NSDebugMLLog(@"low",@"contextID=%u",_contextID);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setSenderID:(NSString*)aSenderID
{
  LOGObjectFnStart();
  ASSIGNCOPY(_senderID,aSenderID);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_synchronizeForDistribution
{
  //OK
  LOGObjectFnStart();
  if (_session)
    {
      //call  session storesIDsInURLs [ret 1]
      //call session isDistributionEnabled [ret 0]
      [_url setURLApplicationNumber:[_request applicationNumber]];//OK
    }
  else
    [_url setURLApplicationNumber:-1];//OK
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_incrementContextID
{
  [_session _contextDidIncrementContextID];
};

//--------------------------------------------------------------------
//oldname= _session
-(GSWSession*)existingSession
{
  return _session;
};

//--------------------------------------------------------------------
-(void)_setCurrentComponent:(GSWComponent*)component
{
  //OK
  LOGObjectFnStart();
  ASSIGN(_currentComponent,component);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setPageReplaced:(BOOL)flag
{
  _pageReplaced=flag;
};
  
//--------------------------------------------------------------------
-(BOOL)_pageReplaced
{
  return _pageReplaced;
};

//--------------------------------------------------------------------
-(void)_setPageChanged:(BOOL)flag
{
  _pageChanged=flag;
};

//--------------------------------------------------------------------
-(BOOL)_pageChanged
{
  return _pageChanged;
};

//--------------------------------------------------------------------
-(void)_setRequestSessionID:(NSString*)aSessionID
{
  LOGObjectFnStart();
  ASSIGNCOPY(_requestSessionID,aSessionID);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSString*)_requestSessionID
{
  return _requestSessionID;
};

//--------------------------------------------------------------------
-(void)_takeAwakeComponentsFromArray:(id)unknwon
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_takeAwakeComponent:(GSWComponent*)component
{
  //OK
  LOGObjectFnStart();
  if (!_awakePageComponents)
    _awakePageComponents=[NSMutableArray new];
  [_awakePageComponents addObject:component];
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
  if (!_elementID)
    _elementID=[GSWElementIDString new];
  [_elementID incrementLastElementIDComponent];
//  LOGObjectFnStop();
};



//--------------------------------------------------------------------
//	appendElementIDComponent:
-(void)appendElementIDComponent:(NSString*)string
{
//  LOGObjectFnStart();
  if (!_elementID)
    _elementID=[GSWElementIDString new];
  [_elementID appendElementIDComponent:string];
//  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendZeroElementIDComponent
-(void)appendZeroElementIDComponent 
{
//  LOGObjectFnStart();
  if (!_elementID)
    _elementID=[GSWElementIDString new];
  [_elementID appendZeroElementIDComponent];
//  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	deleteAllElementIDComponents
-(void)deleteAllElementIDComponents 
{
//  LOGObjectFnStart();
  [_elementID deleteAllElementIDComponents];
//  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	deleteLastElementIDComponent
-(void)deleteLastElementIDComponent 
{
//  LOGObjectFnStart();
  if (!_elementID)
    _elementID=[GSWElementIDString new];
  [_elementID deleteLastElementIDComponent];
//  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWContext (GSWContextD)
//--------------------------------------------------------------------
-(NSString*)url
{
  //OK
  GSWDynamicURLString* componentActionURL=nil;
  LOGObjectFnStart();
  componentActionURL=[self componentActionURL];
  LOGObjectFnStop();
  return (NSString*)componentActionURL;
};

//--------------------------------------------------------------------
//	urlSessionPrefix

// return http://my.host.org/cgi-bin/GSWeb/MyApp.ApplicationSuffix/123456789012334567890123456789
-(NSString*)urlSessionPrefix 
{
  LOGObjectFnNotImplemented();	//TODOFN
  NSDebugMLLog(@"low",@"[request urlProtocolHorstPort]=%@",[_request urlProtocolHostPort]);
  NSDebugMLLog(@"low",@"[request adaptorPrefix]=%@",[_request adaptorPrefix]);
  NSDebugMLLog(@"low",@"[request applicationName]=%@",[_request applicationName]);
  NSDebugMLLog(@"low",@"[session sessionID]=%@",[_session sessionID]);
  return [NSString stringWithFormat:@"%@%@/%@.%@/%@",
				   [_request urlProtocolHostPort],
				   [_request adaptorPrefix],
				   [_request applicationName],
				   GSWApplicationSuffix[GSWebNamingConv],
				   [_session sessionID]];
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
  return _distributionEnabled;
};

//--------------------------------------------------------------------
//	setDistributionEnabled:

-(void)setDistributionEnabled:(BOOL)isDistributionEnabled
{
  _distributionEnabled=isDistributionEnabled;
};
@end

//====================================================================
@implementation GSWContext (GSWContextGSWeb)
-(BOOL)isValidate
{
  return _isValidate;
};

//--------------------------------------------------------------------
-(void)setValidate:(BOOL)isValidate
{
  _isValidate = isValidate;
  NSDebugMLLog(@"low",@"isValidate=%d\n",(int)isValidate);
};
@end
