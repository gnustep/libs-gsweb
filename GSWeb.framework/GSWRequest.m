/* GSWRequest.m - GSWeb: Class GSWRequest
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
@implementation GSWRequest

//--------------------------------------------------------------------
//	initWithMethod:uri:httpVersion:headers:content:userInfo:

// may raise exception
-(id)initWithMethod:(NSString*)method_
				uri:(NSString*)url_
		httpVersion:(NSString*)httpVersion_
			headers:(NSDictionary*)headers_
			content:(NSData*)content_
		   userInfo:(NSDictionary*)userInfo_
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  ASSIGNCOPY(method,method_);
	  NSDebugMLLog(@"requests",@"method=%@",method);
	  ASSIGNCOPY(httpVersion,httpVersion_);
	  ASSIGNCOPY(headers,headers_);
	  defaultFormValueEncoding=NSISOLatin1StringEncoding;
	  formValueEncoding=NSISOLatin1StringEncoding;
	  [self _initCookieDictionary];//NDFN
	  applicationNumber=-9999;
	  {
		NSString* _adaptorVersion=[self headerForKey:GSWHTTPHeader_AdaptorVersion];
		NSDebugMLLog(@"requests",@"_adaptorVersion=%@",_adaptorVersion);
		[self _setIsUsingWebServer:(_adaptorVersion!=nil)];//??
	  };
	  NSDebugMLLog(@"requests",@"url_=%@",url_);
	  uri=[[GSWDynamicURLString alloc]initWithCString:[url_ cString]
									 length:[url_ length]];
	  NSDebugMLLog(@"requests",@"uri=%@",uri);
	  [uri checkURL];
	  ASSIGNCOPY(content,content_);
	  ASSIGNCOPY(userInfo,userInfo_);
	  
	  if (!method_ || !url_)
		{
		  LOGException0(@"NSGenericException GSWRequest: no method and no url");
		  [NSException raise:NSGenericException
					   format:@"GSWRequest: no method and no url"];
		};
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogAssertGood(self);
  NSDebugFLog0(@"dealloc GSWRequest");
  NSDebugFLog0(@"Release GSWRequest method");
  DESTROY(method);
  NSDebugFLog0(@"Release GSWRequest uri");
  DESTROY(uri);
  NSDebugFLog0(@"Release GSWRequest httpVersion");
  DESTROY(httpVersion);
  NSDebugFLog0(@"Release GSWRequest headers");
  DESTROY(headers);
  NSDebugFLog0(@"Release GSWRequest content");
  DESTROY(content);
  NSDebugFLog0(@"Release GSWRequest userInfo");
  DESTROY(userInfo);
  NSDebugFLog0(@"Release GSWRequest formValues");
  DESTROY(formValues);
  NSDebugFLog0(@"Release GSWRequest cookie");
  DESTROY(cookie);
  NSDebugFLog0(@"Release GSWRequest applicationURLPrefix");
  DESTROY(applicationURLPrefix);
  NSDebugFLog0(@"Release GSWRequest requestHandlerPathArray");
  DESTROY(requestHandlerPathArray);
  NSDebugFLog0(@"Release GSWRequest browserLanguages");
  DESTROY(browserLanguages);
  NSDebugFLog0(@"Release GSWRequest super");
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone_
{
  GSWRequest* clone = [[isa allocWithZone:zone_] init];
  if (clone)
	{
	  ASSIGNCOPY(clone->method,method);
	  ASSIGNCOPY(clone->uri,uri);
	  ASSIGNCOPY(clone->httpVersion,httpVersion);
	  ASSIGNCOPY(clone->headers,headers);
	  ASSIGNCOPY(clone->content,content);
	  ASSIGNCOPY(clone->userInfo,userInfo);
	  clone->defaultFormValueEncoding=defaultFormValueEncoding;
	  clone->formValueEncoding=formValueEncoding;
	  ASSIGNCOPY(clone->formValues,formValues);
	  ASSIGNCOPY(clone->cookie,cookie);
	  ASSIGNCOPY(clone->applicationURLPrefix,applicationURLPrefix);
	  ASSIGNCOPY(clone->requestHandlerPathArray,requestHandlerPathArray);
	  ASSIGNCOPY(clone->browserLanguages,browserLanguages);
	  clone->requestType=requestType;
	  clone->isUsingWebServer=isUsingWebServer;
	  clone->formValueEncodingDetectionEnabled=formValueEncodingDetectionEnabled;
	  clone->applicationNumber=applicationNumber;
	};
  return clone;
};

//--------------------------------------------------------------------
//	content

-(NSData*)content 
{
  return content;
};

//--------------------------------------------------------------------
//	headerForKey:

-(NSString*)headerForKey:(NSString*)key_ 
{
  id value=[self headersForKey:key_];
  if (value && [value count]>0)
	return [value objectAtIndex:0];
  else
	return nil;
};

//--------------------------------------------------------------------
//	headerKeys

-(NSArray*)headerKeys 
{
  return [headers allKeys];
};

//--------------------------------------------------------------------
//	headersForKey:

-(NSArray*)headersForKey:(NSString*)key_ 
{
  return [headers objectForKey:key_];
};

//--------------------------------------------------------------------
//	httpVersion

-(NSString*)httpVersion 
{
  return httpVersion;
};

//--------------------------------------------------------------------
//	method
// GET or PUT

-(NSString*)method 
{
  return method;
};

//--------------------------------------------------------------------
//	uri
-(NSString*)uri 
{
  return (NSString*)uri;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlProtocol
{
  //TODO
  NSString* _urlProtocol=[uri urlProtocol];
  if (!_urlProtocol)
	_urlProtocol=GSWProtocol_HTTP;
  return _urlProtocol;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlHost
{
  NSString* _urlHost=[uri urlHost];
  if (!_urlHost)
	_urlHost=[self headerForKey:GSWHTTPHeader_ServerName];
  return _urlHost;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlPortString
{
  NSString* _urlPortString=[uri urlPortString];
  if (!_urlPortString)
	{
	  _urlPortString=[self headerForKey:GSWHTTPHeader_ServerPort];
	};
  return _urlPortString;
};

//--------------------------------------------------------------------
//NDFN
-(int)urlPort
{
  int _port=[uri urlPort];
  if (!_port)
	_port=[[self headerForKey:GSWHTTPHeader_ServerPort]intValue];
  return _port;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlProtocolHostPort
{
  return [uri urlProtocolHostPort];
};

//--------------------------------------------------------------------
//NDFN
-(BOOL)isSecure
{
  return [[self urlProtocol] isEqualToString:GSWProtocol_HTTPS];
};

//--------------------------------------------------------------------
-(NSArray*)browserLanguages
{
  //OK
  LOGObjectFnStart();
  if (!browserLanguages)
	{
	  NSMutableArray* _browserLanguages=nil;
	  NSString* header=[self headerForKey:GSWHTTPHeader_AcceptLanguage];
	  NSDebugMLLog(@"requests",@"lang header:%@",header);
	  if (header)
		{
		  NSArray* _languages=[header componentsSeparatedByString:@","];
		  if (!_languages)
			{
			  LOGError0(@"No languages");
			};
/*
//		  NSDebugMLLog(@"requests",@"_languages:%@",_languages);
		  if ([_languages count]>0)
			{
			  int i=0;
			  NSString* _fromLanguage=nil;
			  NSString* _toLanguage=nil;
			  _browserLanguages=[NSMutableArray array];
			  for(i=0;i<[_languages count];i++)
				{
				  _fromLanguage=[[_languages objectAtIndex:i] lowercaseString];
//				  NSDebugMLLog(@"requests",@"_fromLanguage:%@",_fromLanguage);
				  _toLanguage=[globalLanguages objectForKey:_fromLanguage];
//				  NSDebugMLLog(@"requests",@"_toLanguage:%@",_toLanguage);
				  [_browserLanguages addObject:_toLanguage];
				};
			};
		};
	  if (_browserLanguages)
		_browserLanguages=[NSArray arrayWithArray:_browserLanguages];
	  else
		_browserLanguages=[[NSArray new]autorelease];
*/
		  _browserLanguages=(NSMutableArray*)[GSWResourceManager GSLanguagesFromISOLanguages:_languages];
		  NSDebugMLLog(@"requests",@"browserLanguages:%@",browserLanguages);
		  if (_browserLanguages)
			{
			  //Remove Duplicates
			  int i=0;
			  _browserLanguages=[_browserLanguages mutableCopy];
			  for(i=0;i<[_browserLanguages count];i++)
				{
				  int j=0;
				  NSString* language=[_browserLanguages objectAtIndex:i];
				  for(j=[_browserLanguages count]-1;j>i;j--)
					{
					  NSString* language2=[_browserLanguages objectAtIndex:j];
					  if ([language2 isEqual:language])
						[_browserLanguages removeObjectAtIndex:j];
					};
				};
			};
		}
	  else
		{
		  LOGError0(@"No languages header");
		};

	  if (!_browserLanguages)
		{
		  LOGError0(@"No known languages");
		  _browserLanguages=(NSMutableArray*)[NSArray array];
		};
	  ASSIGN(browserLanguages,_browserLanguages);
	  NSDebugMLLog(@"requests",@"browserLanguages:%@",browserLanguages);
	};
  LOGObjectFnStop();
  return browserLanguages;
};

//--------------------------------------------------------------------
-(NSArray*)requestHandlerPathArray
{
  if (!requestHandlerPathArray)
	{
	  NSString* _urlRequestHandlerPath=[uri urlRequestHandlerPath];
	  ASSIGN(requestHandlerPathArray,
			 [_urlRequestHandlerPath componentsSeparatedByString:@"/"]);
	};
  return requestHandlerPathArray;
};

//--------------------------------------------------------------------
//	userInfo
-(NSDictionary*)userInfo 
{
  return userInfo;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - 
method=%@, uri=%@, httpVersion=%@, headers=%@, content=%@, userInfo=%@, defaultFormValueEncoding=%u, formValueEncoding=%u, formValues=%@, cookie=%@, applicationURLPrefix=%@, requestHandlerPathArray=%@, browserLanguages=%@, requestType=%d, isUsingWebServer=%s, formValueEncodingDetectionEnabled=%s, applicationNumber=%d",
				   object_get_class_name(self),
				   (void*)self,
				   method,
				   uri,
				   httpVersion,
				   headers,
				   content,
				   userInfo,
				   defaultFormValueEncoding,
				   formValueEncoding,
				   formValues,
				   cookie,
				   applicationURLPrefix,
				   requestHandlerPathArray,
				   browserLanguages,
				   requestType,
				   isUsingWebServer ? "YES" : "NO",
				   formValueEncodingDetectionEnabled ? "YES" : "NO",
				   applicationNumber];
};

@end

//====================================================================
@implementation GSWRequest (GSWFormValueReporting)

//--------------------------------------------------------------------
//	setDefaultFormValueEncoding:
-(void)setDefaultFormValueEncoding:(NSStringEncoding)encoding_ 
{
  defaultFormValueEncoding=encoding_;
};

//--------------------------------------------------------------------
//	defaultFormValueEncoding
-(NSStringEncoding)defaultFormValueEncoding 
{
  return defaultFormValueEncoding;
};

//--------------------------------------------------------------------
//	setFormValueEncodingDetectionEnabled:
-(void)setFormValueEncodingDetectionEnabled:(BOOL)flag_ 
{
  formValueEncodingDetectionEnabled=flag_;
};

//--------------------------------------------------------------------
//	isFormValueEncodingDetectionEnabled
-(BOOL)isFormValueEncodingDetectionEnabled 
{
  return formValueEncodingDetectionEnabled;
};

//--------------------------------------------------------------------
//	formValueEncoding

-(NSStringEncoding)formValueEncoding 
{
  return formValueEncoding;
};

//--------------------------------------------------------------------
//	formValueKeys

-(NSArray*)formValueKeys
{
  NSDictionary* _formValues=nil;
  NSArray* _formValueKeys=nil;
  LOGObjectFnStart();
  NS_DURING
    {
	  _formValues=[self _formValues];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"GSWRequest _formValues");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    };
  NS_ENDHANDLER;
  _formValueKeys=[_formValues allKeys];
  LOGObjectFnStop();
  return _formValueKeys;
};

//--------------------------------------------------------------------
//	formValuesForKey:

-(NSArray*)formValuesForKey:(NSString*)key_ 
{
  NSArray* _formValuesForKey=nil;
  NSDictionary* _formValues=nil;
  LOGObjectFnStart();
  NS_DURING
    {
      _formValues=[self _formValues];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"GSWRequest _formValues");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    };
  NS_ENDHANDLER;
  _formValuesForKey=[_formValues objectForKey:key_];
  LOGObjectFnStop();
  return _formValuesForKey;
};

//--------------------------------------------------------------------
//	formValueForKey:
// return id because GSWFileUpload
-(id)formValueForKey:(NSString*)key_ 
{
  //OK
  id _formValue=nil;
  NSArray* _formValuesForKey=nil;
  LOGObjectFnStart();
  _formValuesForKey=[self formValuesForKey:key_];
  NSAssert3(!_formValuesForKey || [_formValuesForKey isKindOfClass:[NSArray class]],@"formValues:%@ ForKey:%@ is not a NSArray it's a %@",
			_formValuesForKey,
			key_,
			[_formValuesForKey class]);
  if (_formValuesForKey && [_formValuesForKey count]>0)
	_formValue=[_formValuesForKey objectAtIndex:0];
  LOGObjectFnStop();
  return _formValue;
};

//--------------------------------------------------------------------
//	formValues
-(NSDictionary*)formValues
{
  NSDictionary* _formValues=nil;
  LOGObjectFnStart();
  NS_DURING
    {
      _formValues=[self _formValues];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"GSWRequest _formValues");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    };
  NS_ENDHANDLER;
  LOGObjectFnStop();
  return _formValues;
};

@end

//====================================================================
@implementation GSWRequest (GSWRequestTypeReporting)

//--------------------------------------------------------------------
//	isFromClientComponent

-(BOOL)isFromClientComponent 
{
  //OK
  NSString* _remoteInvocationPost=nil;
  BOOL _isFromClientComponent=NO;
  LOGObjectFnStart();
  _remoteInvocationPost=[self formValueForKey:GSWFormValue_RemoteInvocationPost];
  _isFromClientComponent=(_remoteInvocationPost!=nil);
  LOGObjectFnStop();
  return _isFromClientComponent;
};

@end

//====================================================================
@implementation GSWRequest (Cookies)

//--------------------------------------------------------------------
-(void)setCookieFromHeaders
{
  NSDictionary* _cookie=nil;
  NSString* cookieHeader=nil;
  LOGObjectFnStart();
  cookieHeader=[self headerForKey:GSWHTTPHeader_Cookie];
  if (cookieHeader)
	{
	  NSDictionary* _cookieStrings=[cookieHeader dictionaryWithSep1:@"; "
												   withSep2:@"="
												   withOptionUnescape:NO];
	  if (_cookieStrings)
		{
		  NSMutableDictionary* _cookieTmp=[NSMutableDictionary dictionary];
		  NSEnumerator* enumerator = [_cookieStrings keyEnumerator];
		  id key;
		  id value;
		  NSArray* newValue;
		  id prevValue;
		  NSDebugMLLog(@"requests",@"enumerator=%@ _cookieTmp=%@",enumerator,_cookieTmp);
		  while ((key = [enumerator nextObject]))
			{
			  value=[_cookieStrings objectForKey:key];
			  if (value)
				{
				  id cookieValue=nil;
				  int index=0;
				  for(index=0;index<[value count];index++)
					{
					  cookieValue=[value objectAtIndex:index];
					  if (cookieValue)
						{
						  newValue=nil;
						  cookieValue=[GSWCookie cookieWithName:key
												value:cookieValue];
						  prevValue=[_cookieTmp objectForKey:key];
						  if (prevValue)
							newValue=[prevValue arrayByAddingObject:cookieValue];
						  else
							newValue=[NSArray arrayWithObject:cookieValue];
						  [_cookieTmp setObject:newValue
									   forKey:key];
						};
					};
				};
			};		  
		  _cookie=[NSDictionary dictionaryWithDictionary:_cookieTmp];
		};
	};
  ASSIGN(cookie,_cookie);
  NSDebugMLLog(@"requests",@"Cookie: %@",cookie);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	cookieValuesForKey:
-(NSArray*)cookieValuesForKey:(NSString*)key_
{
  NSArray* _cookieValuesForKey=nil;
  LOGObjectFnStart();
  [self _initCookieDictionary];
  _cookieValuesForKey=[cookie objectForKey:key_];
  LOGObjectFnStop();
  return _cookieValuesForKey;
};

//--------------------------------------------------------------------
//	cookieValueForKey:
-(NSString*)cookieValueForKey:(NSString*)key_
{
  id object=nil;
  NSString* _cookieValueForKey=nil;
  //OK
  LOGObjectFnStart();
  [self _initCookieDictionary];
  object=[cookie objectForKey:key_];
  if (object && [object count]>0)
	_cookieValueForKey=[object objectAtIndex:0];
  LOGObjectFnStop();
  return _cookieValueForKey;
};

//--------------------------------------------------------------------
//	cookieValues
-(NSDictionary*)cookieValues
{
  //OK
  LOGObjectFnStart();
  [self _initCookieDictionary];
  LOGObjectFnStop();
  return cookie;
};

//--------------------------------------------------------------------
-(NSDictionary*)_initCookieDictionary
{
  //ok
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"cookie=%@",cookie);
  if (!cookie)
	{
	  NSString* _cookieDescription=[self _cookieDescription];
	  NSArray* _cookiesArray=[_cookieDescription componentsSeparatedByString:@"; "];
	  NSMutableDictionary* _cookies=[NSMutableDictionary dictionary];
	  NSString* _cookieString=nil;
	  NSArray* _cookie=nil;
	  NSString* _cookieName=nil;
	  NSString* _cookieValue=nil;
	  NSArray* _cookieArrayValue=nil;
	  NSArray* _cookiePrevValue=nil;
	  int i=0;
	  NSDebugMLLog(@"low",@"_cookieDescription=%@",_cookieDescription);
	  NSDebugMLLog(@"low",@"_cookiesArray=%@",_cookiesArray);
	  for(i=0;i<[_cookiesArray count];i++)
		{
		  _cookieString=[_cookiesArray objectAtIndex:i];
		  NSDebugMLLog(@"low",@"_cookieString=%@",_cookieString);
		  _cookie=[_cookieString componentsSeparatedByString:@"="];
		  NSDebugMLLog(@"low",@"_cookie=%@",_cookie);
		  if ([_cookie count]>0)
			{
			  _cookieName=[_cookie objectAtIndex:0];
			  if ([_cookie count]>1)
				_cookieValue=[_cookie objectAtIndex:1];
			  else
				_cookieValue=[NSString string];
			  _cookiePrevValue=[_cookies objectForKey:_cookieName];
			  if (_cookiePrevValue)
				_cookieArrayValue=[_cookiePrevValue arrayByAddingObject:_cookieValue];
			  else
				_cookieArrayValue=[NSArray arrayWithObject:_cookieValue];
			  [_cookies setObject:_cookieArrayValue
						forKey:_cookieName];
			};		 
		};
	  ASSIGN(cookie,[NSDictionary dictionaryWithDictionary:_cookies]);
	};
  LOGObjectFnStop();
  return cookie;
};

//--------------------------------------------------------------------
-(NSString*)_cookieDescription
{
  //OK
  NSString* _cookieHeader=nil;
  LOGObjectFnStart();
  _cookieHeader=[self headerForKey:GSWHTTPHeader_Cookie];
  LOGObjectFnStop();
  return _cookieHeader;
};

@end


//====================================================================
@implementation GSWRequest (GSWRequestA)

//--------------------------------------------------------------------
//	sessionID
// nil if first request of session

-(NSString*)sessionID 
{
  NSString* _sessionID=nil;
  NSDictionary* _uriElements=nil;
  LOGObjectFnStart();
  _uriElements=[self uriOrFormOrCookiesElements];
  _sessionID=[_uriElements objectForKey:GSWKey_SessionID];
  LOGObjectFnStop();
  return _sessionID;
};

//--------------------------------------------------------------------
-(NSString*)requestHandlerPath
{
  return [uri urlRequestHandlerPath];
};

//--------------------------------------------------------------------
//	adaptorPrefix

-(NSString*)adaptorPrefix
{
  return [uri urlPrefix];
};


//--------------------------------------------------------------------
//	applicationName

-(NSString*)applicationName
{
  return [uri urlApplicationName];
};

//--------------------------------------------------------------------
//	applicationNumber
// nil if request can be handled by any instance

-(int)applicationNumber
{
  //OK
  if (applicationNumber==-9999)
	{
	  NSDictionary* _uriElements=[self uriOrFormOrCookiesElements];
	  NSString* _applicationNumber=[_uriElements objectForKey:GSWKey_InstanceID];
	  applicationNumber=[_applicationNumber intValue];
	};
  return applicationNumber;

};

//--------------------------------------------------------------------
-(NSString*)requestHandlerKey
{
  NSString* _requestHandlerKey=[uri urlRequestHandlerKey];
  return _requestHandlerKey;
};

@end

//====================================================================
@implementation GSWRequest (GSWRequestB)

//--------------------------------------------------------------------
-(NSDictionary*)_extractValuesFromFormData:(NSData*)formData_
							  withEncoding:(NSStringEncoding)encoding_
{
  NSArray* _allKeys=nil;
  NSDictionary* _formData=nil;
  NSString* _formString=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"formData_=%@",formData_);
  NSDebugMLLog(@"requests",@"encoding_=%ld",(long)encoding_);
  _formString=[[[NSString alloc]initWithData:formData_
								encoding:encoding_] autorelease];
  NSDebugMLLog(@"requests",@"_formString=%@",_formString);
  _formData=[_formString dictionaryQueryString];
  NSDebugMLLog(@"requests",@"_formData=%@",_formData);
  _allKeys=[_formData allKeys];
  NSDebugMLLog(@"requests",@"_allKeys=%@",_allKeys);
  NSDebugMLLog(@"requests",@"_allKeys count=%d",[_allKeys count]);
  if ([_allKeys count]>0)
	{
	  int i=0;
	  int _count=[_allKeys count];
	  NSString* _key=nil;
	  BOOL ismapCoordsFound=NO;
	  NSArray* _value=nil;
	  for(i=0;i<_count && !ismapCoordsFound;i++)
		{
		  _key=[_allKeys objectAtIndex:i];
		  NSDebugMLLog(@"requests",@"_key=%@",_key);
		  _value=[_formData objectForKey:_key];
		  if ([_value count]==1
			  &&[[_value objectAtIndex:0]length]==0
			  &&[_key ismapCoordx:NULL
					  y:NULL])
			{
			  NSMutableDictionary* _formDataMutable=[[_formData mutableCopy]autorelease];
			  ismapCoordsFound=YES;
			  [_formDataMutable setObject:[NSArray arrayWithObject:_key]
								forKey:GSWKey_IsmapCoords];
			  [_formDataMutable removeObjectForKey:_key];
			  _formData=[NSDictionary dictionaryWithDictionary:_formDataMutable];
			};
		};
	};
  NSDebugMLLog(@"requests",@"_formData=%@",_formData);
  LOGObjectFnStop();
  return _formData;
};

//--------------------------------------------------------------------
-(NSStringEncoding)_formValueEncodingFromFormData:(NSData*)_formData
{
  return NSISOLatin1StringEncoding; //TODO
};

//--------------------------------------------------------------------
-(NSData*)_formData
{
  //OK
  NSData* _data=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"method=%@",method);
  NSDebugMLLog(@"requests",@"content=%@",content);
  if ([method isEqualToString:GSWHTTPHeader_MethodGet])
	{
	  NSString* _urlQueryString=[self _urlQueryString];
	  _data=[_urlQueryString dataUsingEncoding:NSISOLatin1StringEncoding];//??
	  NSDebugMLLog(@"requests",@"_data=%@",_data);
	}
  else if ([method isEqualToString:GSWHTTPHeader_MethodPost])
	{
	  _data=content;
	  NSDebugMLLog(@"requests",@"_data=%@",_data);
	};
  LOGObjectFnStop();
  return _data;
};

//--------------------------------------------------------------------
-(NSString*)_contentType
{
  //OK
  NSString* _contentType=nil;
  NSRange _range;
  LOGObjectFnStart();
  _contentType=[self headerForKey:GSWHTTPHeader_ContentType];
  NSDebugMLLog(@"requests",@"_contentType=%@",_contentType);
  //We can get something like 
  // multipart/form-data; boundary=---------------------------1810101926251
  // In this case, return only multipart/form-data
  _range=[_contentType rangeOfString:@";"];
  if (_range.length>0)
	{
	  _contentType=[_contentType substringToIndex:_range.location];
	  NSDebugMLLog(@"requests",@"_contentType=%@",_contentType);
	};
  LOGObjectFnStop();
  return _contentType;
};

//--------------------------------------------------------------------
-(NSString*)_urlQueryString
{
  //OK
  NSString* _urlQueryString=nil;
//  NSArray* _url=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"uri=%@",uri);
  NSDebugMLLog(@"requests",@"uri class=%@",[uri class]);
  _urlQueryString=[uri urlQueryString];
/*
  _url=[uri componentsSeparatedByString:@"?"];
  NSDebugMLLog(@"requests",@"_url=%@",_url);
  if ([_url count]>1)
	_urlQueryString=[[_url subarrayWithRange:NSMakeRange(1,[_url count])]
					  componentsJoinedByString:@"?"];
  else
	_urlQueryString=[NSString string];
*/
  LOGObjectFnStop();
  return _urlQueryString;
};


@end


//====================================================================
@implementation GSWRequest (GSWRequestF)

//--------------------------------------------------------------------
-(BOOL)_isUsingWebServer
{
  return isUsingWebServer;
};

//--------------------------------------------------------------------
-(void)_setIsUsingWebServer:(BOOL)_flag
{
  isUsingWebServer=_flag;
};

@end

//====================================================================
@implementation GSWRequest (GSWRequestG)

//--------------------------------------------------------------------
-(BOOL)_isSessionIDinRequest
{
  NSDictionary* _uriElements=[self uriElements];
  return ([_uriElements objectForKey:GSWKey_SessionID]!=nil);
};

//--------------------------------------------------------------------
-(BOOL)_isSessionIDinCookies
{
  return ([self cookieValueForKey:GSWKey_SessionID]!=nil);
};

//--------------------------------------------------------------------
-(BOOL)_isSessionIDinFormValues
{
  return ([self formValueForKey:GSWKey_SessionID]!=nil);
};

//--------------------------------------------------------------------
-(id)_completeURLWithRequestHandlerKey:(NSString*)_key
								  path:(NSString*)_path
						   queryString:(NSString*)_queryString
							  isSecure:(BOOL)_isSecure
								  port:(int)_port
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)_urlWithRequestHandlerKey:(NSString*)_key
										   path:(NSString*)_path
									queryString:(NSString*)_queryString
{
  //OK
  GSWDynamicURLString* _url=[self _applicationURLPrefix];
  [_url setURLRequestHandlerKey:_key];
  [_url setURLRequestHandlerPath:_path];
  [_url setURLQueryString:_queryString];
  return _url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)_applicationURLPrefix
{
  //OK
  GSWDynamicURLString* _applicationURLPrefix=[[uri copy] autorelease];
  [_applicationURLPrefix setURLRequestHandlerKey:nil];
  [_applicationURLPrefix setURLRequestHandlerPath:nil];
  [_applicationURLPrefix setURLQueryString:nil];
  return _applicationURLPrefix;
};

//--------------------------------------------------------------------
-(NSDictionary*)_formValues
{
  //OK
  LOGObjectFnStart();
  if(!formValues)
	{
	  NSString* _contentType=[self _contentType];
	  if (!_contentType || [_contentType isEqualToString:GSWHTTPHeader_FormURLEncoded])
		{
		  [self _getFormValuesFromURLEncoding];
		}
	  else if ([_contentType isEqualToString:GSWHTTPHeader_MultipartFormData])
		{
		  [self _getFormValuesFromMultipartFormData];
		}
	  else
		{
		  NSDebugMLLog(@"requests",@"_contentType=%@",_contentType);
		  LOGObjectFnNotImplemented(); //TODO
		};
	  NSDebugMLLog(@"requests",@"formValues=%@",formValues);
	};
  LOGObjectFnStop();
  return formValues;
};

//--------------------------------------------------------------------
-(void)_getFormValuesFromURLEncoding
{
  //OK
  NSData* _formData=nil;
  LOGObjectFnStart();
  _formData=[self _formData];
  NSDebugMLLog(@"requests",@"_formData=%@",_formData);
  if (_formData)
	{
	  NSStringEncoding _formValueEncoding=[self _formValueEncodingFromFormData:_formData];
	  NSDictionary* _formValues=nil;
	  NSDebugMLLog(@"requests",@"_formValueEncoding=%d",(int)_formValueEncoding);
	  _formValues=[self _extractValuesFromFormData:_formData
						withEncoding:_formValueEncoding];
	  ASSIGN(formValues,_formValues);
	  NSDebugMLLog(@"requests",@"formValues=%@",formValues);
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(BOOL)_hasFormValues
{
  //OK
  NSDictionary* _formValues=[self _formValues];
  return [_formValues count]>0;
};


@end

//====================================================================
@implementation GSWRequest (GSWRequestH)

//--------------------------------------------------------------------
-(void)_getFormValuesFromMultipartFormData
{
  NSMutableDictionary* _formValues=nil;
  NSArray* _contentTypes=nil;
  int _contentTypeIndex=0;
  int _contentTypeCount=0;
  NSString* _contentType=nil;
  NSData* _content=nil;
  LOGObjectFnStart();
  _formValues=[NSMutableDictionary dictionary];
  _contentTypes=[self headersForKey:GSWHTTPHeader_ContentType];
  _contentTypeIndex=0;
  _contentTypeCount=[_contentTypes count];
  NSDebugMLLog(@"requests",@"_contentTypes=%@",_contentTypes);
  _content=[self content];
  NS_DURING
    {
	  for(_contentTypeIndex=0;_contentTypeIndex<_contentTypeCount;_contentTypeIndex++)
		{
		  NSDictionary* _parsedContentType=nil;
		  NSString* _boundary=nil;
		  NSArray* _decodedParts=nil;
		  int _decodedPartIndex=0;
		  int _decodedPartCount=0;
		  
		  // get "multipart/form-data; boundary=---------------------------1810101926251"
		  _contentType=[_contentTypes objectAtIndex:_contentTypeIndex];
		  NSDebugMLLog(@"requests",@"_contentType=%@",_contentType);
		  // convert it into
		  //	{
		  //		boundary = "---------------------------1810101926251";
		  //		"multipart/form-data" = "multipart/form-data"; 
		  //	}
		  _parsedContentType=[self _parseOneHeader:_contentType];
		  NSDebugMLLog(@"requests",@"_parsedContentType=%@",_parsedContentType);
		  _boundary=[_parsedContentType objectForKey:@"boundary"];
		  NSDebugMLLog(@"requests",@"_boundary=%@",_boundary);
		  NSAssert1(_boundary,@"No boundary in %@",_parsedContentType);
		  NSDebugMLLog(@"requests",@"_content=%@",_content);
		  _decodedParts=[self _decodeMultipartBody:_content
							  boundary:_boundary];
		  NSDebugMLLog(@"requests",@"_decodedParts=%@",_decodedParts);
		  _decodedPartIndex=0;
		  _decodedPartCount=[_decodedParts count];
		  for(_decodedPartIndex=0;_decodedPartIndex<_decodedPartCount;_decodedPartIndex++)
			{
			  NSData* _decodedPart=nil;
			  NSArray* _parsedParts=nil;
			  int _parsedPartsCount=0;

			  _decodedPart=[_decodedParts objectAtIndex:_decodedPartIndex];
			  NSDebugMLLog(@"requests",@"_decodedPart=%@",_decodedPart);
			  _parsedParts=[self _parseData:_decodedPart];
			  NSDebugMLLog(@"requests",@"_parsedParts=%@",_parsedParts);
			  //return :
			  //	(
			  //		{
			  //			"content-disposition" = "form-data; name=\"9.1\"; filename=\"C:\\TEMP\\zahn.txt\""; 
			  //			"content-type" = text/plain; 
			  //	    },
			  //		<41514541 41415177 4d444179 666f3054 6c4e2b58 58684357 69314b50 51635159 73573677 426d336f 52617247 36584633 4c7a6455 5637664e 39654b6b 764b4a43 71715059 67417250 59374863 78397944 36506b66 774a7550 465a4141 2f303463 446c5072 48525670 537a4135 67664738 62364572 44314158 372b7067 734c5075 304b4d77 0d0a0d0a >
			  //	)
			  _parsedPartsCount=[_parsedParts count];
			  if (_parsedPartsCount==0)
				{
				  LOGError(@"_parsedPartsCount==0 _decodedPart=%@",_decodedPart);
				  //TODO error
				}
			  else
				{
				  NSDictionary* _partInfo=nil;
				  NSString* _parsedPartsContentType=nil;
				  NSString* _parsedPartsContentDisposition=nil;
				  NSDictionary* _parsedContentDispositionOfParsedPart=nil;
				  NSEnumerator* _enum=nil;
				  NSString* _name=nil;
				  NSString* _dscrKey=nil;
				  id _descrValue=nil;

				  _partInfo=[_parsedParts objectAtIndex:0];
				  NSDebugMLLog(@"requests",@"_partInfo=%@",_partInfo);
				  NSAssert1([_partInfo isKindOfClass:[NSDictionary class]],@"partInfo %@ is not a dictionary",_partInfo);
				  _parsedPartsContentType=[[_partInfo objectForKey:GSWHTTPHeader_ContentType] lowercaseString];
				  NSDebugMLLog(@"requests",@"_parsedPartsContentType=%@",_parsedPartsContentType);
				  _parsedPartsContentDisposition=[_partInfo objectForKey:@"content-disposition"];
				  NSDebugMLLog(@"requests",@"_parsedPartsContentDisposition=%@",_parsedPartsContentDisposition);
				  //Convert: "form-data; name=\"9.1\"; filename=\"C:\\TEMP\\zahn.txt\"";
				  // into: {filename = "C:\\TEMP\\zahn.txt"; "form-data" = "form-data"; name = 9.1; }
				  _parsedContentDispositionOfParsedPart=[self _parseOneHeader:_parsedPartsContentDisposition];
				  NSDebugMLLog(@"requests",@"_parsedContentDispositionOfParsedPart=%@",_parsedContentDispositionOfParsedPart);
				  _enum=[_parsedContentDispositionOfParsedPart keyEnumerator];
				  _name=[_parsedContentDispositionOfParsedPart objectForKey:@"name"];
				  NSDebugMLLog(@"requests",@"_name=%@",_name);
				  if (!_name)
					{
					  ExceptionRaise(@"GSWRequest",
									 @"GSWRequest: No name \n%@\n",
									 _parsedContentDispositionOfParsedPart);
					};
				  while((_dscrKey=[_enum nextObject]))
					{
					  NSDebugMLLog(@"requests",@"_dscrKey=%@",_dscrKey);
					  if (![_dscrKey isEqualToString:@"name"] && ![_dscrKey isEqualToString:@"form-data"])
						{
						  NSString* _key=nil;
						  _descrValue=[_parsedContentDispositionOfParsedPart objectForKey:_dscrKey];
						  NSDebugMLLog(@"requests",@"_descrValue=%@",_descrValue);
						  _key=[NSString stringWithFormat:@"%@.%@",_name,_dscrKey];
						  NSDebugMLLog(@"requests",@"_key=%@",_key);
						  [_formValues setObject:[NSArray arrayWithObject:_descrValue]
									   forKey:_key];
						};
					};
				  if (_parsedPartsCount>1)
					{
					  NSArray* _values=[_parsedParts subarrayWithRange:NSMakeRange(1,[_parsedParts count]-1)];
					  NSMutableArray* _valuesNew=[NSMutableArray array];
					  NSDebugMLLog(@"requests",@"_values=%@",_values);
					  NSDebugMLLog(@"requests",@"_parsedPartsContentType=%@",_parsedPartsContentType);
					  if (!_parsedPartsContentType || [_parsedPartsContentType isEqualToString:GSWHTTPHeader_MimeType_TextPlain])
						{
						  int _valueIndex=0;
						  int _valuesCount=[_values count];
						  id _value=nil;
						  for(_valueIndex=0;_valueIndex<_valuesCount;_valueIndex++)
							{
							  _value=[_values objectAtIndex:_valueIndex];
							  NSDebugMLLog(@"requests",@"_value=%@",_value);
							  _value=[[[NSString alloc]initWithData:_value
													   encoding:NSISOLatin1StringEncoding]autorelease];
							  [_valuesNew addObject:_value];
							};
						  _values=[NSArray arrayWithArray:_valuesNew];
						};
					  [_formValues setObject:_values
								   forKey:_name];
					};
				};
			};
		};
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"GSWRequest in _getFormValuesFromMultipartFormData");
      LOGException(@"%@ (%@) \n_contentTypes=%@\n_content=%@",
				   localException,
				   [localException reason],
				   _contentTypes,
				   _content);
      [localException raise];
    };
  NS_ENDHANDLER;
  NSDebugMLLog(@"requests",@"_formValues=%@",_formValues);
  ASSIGN(formValues,_formValues);
  //
  //	{
  //    	9.1 = 	(
  //					<41514541 41415177 4d444179 666f3054 6c4e2b58 58684357 69314b50 51635159 73573677 426d336f 52617247 36584633 4c7a6455 5637664e 39654b6b 764b4a43 71715059 67417250 59374863 78397944 36506b66 774a7550 465a4141 2f303463 446c5072 48525670 537a4135 67664738 62364572 44314158 372b7067 734c5075 304b4d77 0d0a0d0a >
  //				);
  //		9.1.filename = ("C:\\TEMP\\zahn.txt"); 
  //		9.3 = (submit);
  //	}
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSArray*)_decodeMultipartBody:(NSData*)body_
					   boundary:(NSString*)boundary_
{
  NSData* _dataBoundary=nil;
  NSString* _boundary=nil;
  NSArray* _parts=nil;
  int i=0;
  NSData* tmpData=nil;
/*  _CRLFSeparator=NO;
  unsigned char* _CRLF[2]={ 0x0d, 0x0a };
  unsigned char* _LF[2]={ 0x0a };
  NSData* _CRLFData=[NSData dataWithBytes:_CRLF
							length:2];
  NSData* _LFData=[NSData dataWithBytes:_LF
						  length:1];
*/
  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"body_=%@",body_);
  NSDebugMLLog(@"requests",@"boundary_=%@",boundary_);
  _boundary=[NSString stringWithFormat:@"--%@\r\n",boundary_];//Add "--" and "\r\n"
  NSDebugMLLog(@"requests",@"boundary_=%@",boundary_);
  _dataBoundary=[_boundary dataUsingEncoding:NSISOLatin1StringEncoding];//TODO
  NSDebugMLLog(@"requests",@"_dataBoundary=%@",_dataBoundary);
/*  {
	NSString* _dataString=nil;
	_dataString=[[[NSString alloc]initWithData:_body
								  encoding:NSISOLatin1StringEncoding]autorelease];
	NSDebugMLLog(@"requests",@"_bodyString=%@",_dataString);
  }
*/
  NSDebugMLLog0(@"requests",@"componentsSeparatedByData");
  _parts=[body_ componentsSeparatedByData:_dataBoundary];
  NSDebugMLLog(@"requests",@"_parts=%@",_parts);
  {
	for(i=0;i<[_parts count];i++)
	  {
		tmpData=[_parts objectAtIndex:i];
		if ([tmpData length]<400)
		  {
			NSString* _dataString=nil;
			_dataString=[[[NSString alloc]initWithData:tmpData
										  encoding:NSISOLatin1StringEncoding]autorelease];
			NSDebugMLLog(@"requests",@"_tmpDataString=%@",_dataString);
		  }
		else
		  {
			NSDebugMLLog(@"requests",@"tmpData=%@",tmpData);
		  };
	  };
  };
  // The 1st part should be empty (or it's only a warning message...)
  if ([_parts count]>0)
	{
	  _parts=[_parts subarrayWithRange:NSMakeRange(1,[_parts count]-1)];
	};
  // Now deleting last \r\n of each object
  _parts=[_parts mutableCopy];
  for(i=0;i<[_parts count];i++)
	{
	  tmpData=[_parts objectAtIndex:i];
	  if (i==[_parts count]-1)
		{
		  //Delete the last \r\nseparator--\r\n
		  _boundary=[NSString stringWithFormat:@"\r\n%@--\r\n",boundary_];
		  NSDebugMLLog(@"requests",@"boundary_=%@",boundary_);
		  _dataBoundary=[_boundary dataUsingEncoding:NSISOLatin1StringEncoding];//TODO
		  NSDebugMLLog(@"requests",@"tmpData_=%@",tmpData);
		  tmpData=[tmpData dataByDeletingLastBytesCount:[_dataBoundary length]];
		  NSDebugMLLog(@"requests",@"tmpData=%@",tmpData);
		}
	  else
		{
		  tmpData=[tmpData dataByDeletingLastBytesCount:2];
		};
	  [(NSMutableArray*)_parts replaceObjectAtIndex:i
						withObject:tmpData];
	};
  {
	for(i=0;i<[_parts count];i++)
	  {
		tmpData=[_parts objectAtIndex:i];
		if ([tmpData length]<400)
		  {
			NSString* _dataString=nil;
			_dataString=[[[NSString alloc]initWithData:tmpData
										  encoding:NSISOLatin1StringEncoding]autorelease];
			NSDebugMLLog(@"requests",@"_tmpDataString=%@",_dataString);
			
		  }
		else
		  {
			NSDebugMLLog(@"requests",@"tmpData=%@",tmpData);
		  };
	  };
  };
  LOGObjectFnStop();
  return _parts;
};

//--------------------------------------------------------------------
// Convert:
// <436f6e74 656e742d 44697370 6f736974 696f6e3a 20666f72 6d2d6461 74613b20 6e616d65 3d22392e 31223b20 66696c65 6e616d65 3d22433a 5c54454d 505c7a61 686e2e74 7874220d 0a436f6e 74656e74 2d547970 653a2074 6578742f 706c6169 6e0d0a0d 0a415145 41414151 774d4441 79666f30 546c4e2b 58586843 5769314b 50516351 59735736 77426d33 6f526172 47365846 334c7a64 55563766 4e39654b 6b764b4a 43717150 59674172 50593748 63783979 4436506b 66774a75 50465a41 412f3034 63446c50 72485256 70537a41 35676647 38623645 72443141 58372b70 67734c50 75304b4d 770d0a0d 0a>
// Into:
//	(
//		{
//			"content-disposition" = "form-data; name=\"9.1\"; filename=\"C:\\TEMP\\zahn.txt\"";
//			"content-type" = text/plain;
//		},
//		<41514541 41415177 4d444179 666f3054 6c4e2b58 58684357 69314b50 51635159 73573677 426d336f 52617247 36584633 4c7a6455 5637664e 39654b6b 764b4a43 71715059 67417250 59374863 78397944 36506b66 774a7550 465a4141 2f303463 446c5072 48525670 537a4135 67664738 62364572 44314158 372b7067 734c5075 304b4d77 0d0a0d0a >
//	)

// convert:
// <436f6e74 656e742d 44697370 6f736974 696f6e3a 20666f72 6d2d6461 74613b20 6e616d65 3d22392e 33220d0a 0d0a7375 626d6974 >
// Into:
//	(
//		{
//			"content-disposition" = "form-data; name=\"9.3\"";
//		},
//		<7375626d 6974>
//	)
-(NSArray*)_parseData:(NSData*)data_
{
  NSArray* _parsedData=nil;
  NSMutableDictionary* _headers=[NSMutableDictionary dictionary];
  NSData* _data=nil;
  LOGObjectFnStart();
  if (data_)
	{
	  unsigned int _dataLength=[data_ length];
	  const unsigned char* _bytes=(unsigned char*)[data_ bytes];
	  BOOL _headersEnd=NO;
	  int _start=0;
	  int i=0;
	  for(i=0;i<_dataLength-1 && !_headersEnd;i++) // -1 for \n
		{
		  //Parse Headers
		  if (_bytes[i]=='\r' && _bytes[i+1]=='\n')
			{
			  if (i-_start==0)//Empty Line: End Of Headers
				_headersEnd=YES;
			  else
				{
				  NSRange _range;
				  NSString* _key=@"";
				  NSString* _value=@"";
				  NSData* _headerData=[data_ subdataWithRange:NSMakeRange(_start,i-_start)];
				  NSString* _headerString=[[[NSString alloc]initWithData:_headerData
															encoding:NSISOLatin1StringEncoding]autorelease];
				  NSDebugMLLog(@"requests",@"i=%d",i);
				  NSDebugMLLog(@"requests",@"_start=%d",_start);
				  NSDebugMLLog(@"requests",@"_headerData=%@",_headerData);
				  NSDebugMLLog(@"requests",@"_headerString=%@",_headerString);
				  _range=[_headerString rangeOfString:@": "];
				  if (_range.length>0)
					{
					  _key=[_headerString  substringToIndex:_range.location];
					  _key=[_key lowercaseString];
					  if (_range.location+1<[_headerString length])
						{
						  _value=[_headerString substringFromIndex:_range.location+1];
						  _value=[_value stringByTrimmingSpaces];
						};
					};
				  [_headers setObject:_value
							forKey:_key];
				};
			  i++; //Pass the '\n'
			  _start=i+1;
			};
		};
	  if (!_headersEnd)
		{
		  //TODO error
		}
	  else
		{
		  NSDebugMLLog(@"requests",@"i=%d",i);
		  _data=[data_ subdataWithRange:NSMakeRange(i,_dataLength-i)];
		};
	  _headers=[NSDictionary dictionaryWithDictionary:_headers];
	  _parsedData=[NSArray arrayWithObjects:_headers,_data,nil];
	  NSDebugMLLog(@"requests",@"_headers=%@",_headers);
	  NSDebugMLLog(@"requests",@"_data=%@",_data);
	  NSDebugMLLog(@"requests",@"_parsedData=%@",_parsedData);
	};
  LOGObjectFnStop();
  return _parsedData;
};

//--------------------------------------------------------------------
/*
- convert "multipart/form-data; boundary=---------------------------1810101926251"
into
  {
    boundary = "---------------------------1810101926251";
    "multipart/form-data" = "multipart/form-data"; 
  }

- convert form-data; name="9.1"; filename="C:\TEMP\zahn.txt"
into
{filename = "C:\\TEMP\\zahn.txt"; "form-data" = "form-data"; name = 9.1; }

- convert form-data; name="9.3"
into
{"form-data" = "form-data"; name = 9.3; }
*/

-(NSDictionary*)_parseOneHeader:(NSString*)_header
{
  //TODO Process quoted string !
  NSMutableDictionary* _parsedParts=nil;
  NSArray* _headerParts=nil;
  int _partIndex=0;
  int _partCount=0;
  NSString* _part=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"_header=%@",_header);
  _parsedParts=[NSMutableDictionary dictionary];
  NSDebugMLLog(@"requests",@"_parsedParts=%@",_parsedParts);
  _headerParts=[_header componentsSeparatedByString:@";"];
  NSDebugMLLog(@"requests",@"_headerParts=%@",_headerParts);
  _partCount=[_headerParts count];
  for(_partIndex=0;_partIndex<_partCount;_partIndex++)
	{
	  NSArray* _parsedPart=nil;
	  int _parsedPartCount=0;
	  NSString* _key=nil;
	  NSString* _value=nil;
	  _part=[_headerParts objectAtIndex:_partIndex];
	  NSDebugMLLog(@"requests",@"_part=%@",_part);
	  _part=[_part stringByTrimmingSpaces];
	  NSDebugMLLog(@"requests",@"_part=%@",_part);
	  _parsedPart=[_part componentsSeparatedByString:@"="];
	  NSDebugMLLog(@"requests",@"_parsedPart=%@",_parsedPart);
	  _parsedPartCount=[_parsedPart count];
	  switch(_parsedPartCount)
		{
		case 1:
		  _key=[_parsedPart objectAtIndex:0];
		  _value=_key;
		  break;
		case 2:
		  _key=[_parsedPart objectAtIndex:0];
		  _value=[_parsedPart objectAtIndex:1];
		  break;
		default:
		  NSAssert1(NO,@"objects number != 1 or 2 in %@",_parsedPart);
		  //TODO Error
		  break;
		};
	  NSDebugMLLog(@"requests",@"_key=%@",_key);
	  NSDebugMLLog(@"requests",@"_value=%@",_value);
	  if (_key && _value)
		{
		  if ([_value isQuotedWith:@"\""])
			_value=[_value stringWithoutQuote:@"\""];
		  [_parsedParts setObject:_value
						forKey:_key];
		};
	};
  NSDebugMLLog(@"requests",@"_parsedParts=%@",_parsedParts);
  _parsedParts=[NSDictionary dictionaryWithDictionary:_parsedParts];
  LOGObjectFnStop();
  return _parsedParts;
};


@end

//====================================================================
@implementation GSWRequest (GSWRequestI)

//--------------------------------------------------------------------
-(id)nonNilFormValueForKey:(NSString*)_key
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};


@end

//====================================================================
@implementation GSWRequest (GSWRequestJ)

//--------------------------------------------------------------------
-(id)dictionaryWithKeys:(id)_unknown
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)selectedButtonName
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)valueFromImageMapNamed:(NSString*)_name
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)valueFromImageMapNamed:(NSString*)_name
				inFramework:(NSString*)_framework
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)valueFromImageMap:(id)_unknown
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)yCoord
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)xCoord
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)formKeyWithSuffix:(NSString*)_suffix
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWRequest (GSWRequestK)

//--------------------------------------------------------------------
//	applicationHost
// nil if request can be handled by any instance

-(NSString*)applicationHost 
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
//	pageName
-(NSString*)pageName 
{
  NSDictionary* _uriElements=[self uriOrFormOrCookiesElements];
  return [_uriElements objectForKey:GSWKey_PageName];
};

//--------------------------------------------------------------------
//	senderID
-(NSString*)senderID 
{
  NSDictionary* _uriElements=[self uriOrFormOrCookiesElements];
  return [_uriElements objectForKey:GSWKey_ElementID];
};

//--------------------------------------------------------------------
//	contextID

-(NSString*)contextID 
{
  NSString* _contextID=nil;
  NSDictionary* _uriElements=nil;
  LOGObjectFnStart();
  _uriElements=[self uriOrFormOrCookiesElements];
  _contextID=[_uriElements objectForKey:GSWKey_ContextID];
  LOGObjectFnStop();
  return _contextID;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)uriOrFormOrCookiesElements
{
  NSString* _tmp=nil;
  NSMutableDictionary* _uriElements=nil;
  LOGObjectFnStart();
  _uriElements=[self uriElements];
  if (![_uriElements objectForKey:GSWKey_SessionID])
	{
	  _tmp=[self formValueForKey:GSWKey_SessionID];
	  if (!_tmp)
		_tmp=[self cookieValueForKey:GSWKey_SessionID];
	  if (_tmp)
		[_uriElements setObject:_tmp
					  forKey:GSWKey_SessionID];
	};
  if (![_uriElements objectForKey:GSWKey_ContextID])
	{
	  _tmp=[self formValueForKey:GSWKey_ContextID];
	  if (!_tmp)
		_tmp=[self cookieValueForKey:GSWKey_ContextID];
	  if (_tmp)
		[_uriElements setObject:_tmp
					  forKey:GSWKey_ContextID];
	};
  if (![_uriElements objectForKey:GSWKey_ElementID])
	{
	  _tmp=[self formValueForKey:GSWKey_ElementID];
	  if (!_tmp)
		_tmp=[self cookieValueForKey:GSWKey_ElementID];
	  if (_tmp)
		[_uriElements setObject:_tmp
					  forKey:GSWKey_ContextID];
	};

  if (![_uriElements objectForKey:GSWKey_ElementID])
	{
	  _tmp=[self formValueForKey:GSWKey_ElementID];
	  if (!_tmp)
		_tmp=[self cookieValueForKey:GSWKey_ElementID];
	  if (_tmp)
		[_uriElements setObject:_tmp
					  forKey:GSWKey_ContextID];
	};
  if (![_uriElements objectForKey:GSWKey_InstanceID])
	{
	  _tmp=[self formValueForKey:GSWKey_InstanceID];
	  if (!_tmp)
		_tmp=[self cookieValueForKey:GSWKey_InstanceID];
	  if (_tmp)
		[_uriElements setObject:_tmp
					  forKey:GSWKey_InstanceID];
	};
  if (![_uriElements objectForKey:GSWKey_Data])
	{
	  _tmp=[self formValueForKey:GSWKey_Data];
	  if (_tmp)
		[_uriElements setObject:_tmp
					  forKey:GSWKey_Data];
	};
  LOGObjectFnStop();
  return _uriElements;
};
//--------------------------------------------------------------------
//NDFN
-(NSMutableDictionary*)uriElements
{
  //OK
  NSMutableDictionary* _dict=nil;
  NSArray* _requestHandlerPathArray=nil;
  int _index=0;
  NSString* tmp=nil;
  NSString* _gswpage=nil;
  NSString* _gswsid=nil;
  NSString* _gswcid=nil;
  NSString* _gsweid=nil;
  NSString* _gswinst=nil;
  NSString* _requestHandlerKey=nil;
  int _applicationNumber;
  LOGObjectFnStart();
  _dict=[NSMutableDictionary new];
  //NEW//TODO
  _requestHandlerKey=[((GSWDynamicURLString*)[self uri]) urlRequestHandlerKey];
  if (!_requestHandlerKey || ![_requestHandlerKey isEqualToString:GSWDirectActionRequestHandlerKey])
	{
	  _requestHandlerPathArray=[self requestHandlerPathArray];
	  NSDebugMLLog(@"requests",@"_requestHandlerPathArray=%@",_requestHandlerPathArray);
	  if ([_requestHandlerPathArray count]>_index)
		{
		  tmp=[_requestHandlerPathArray objectAtIndex:_index];
		  NSDebugMLLog(@"requests",@"tmp=%@",tmp);
		  if ([tmp hasSuffix:GSWPagePSuffix])
			{
			  _gswpage=[tmp stringWithoutSuffix:GSWPagePSuffix];
			  NSDebugMLLog(@"requests",@"_gswpage=%@",_gswpage);
			  _index++;
			};
		  if ([_requestHandlerPathArray count]>_index)
			{
			  _gswsid=[_requestHandlerPathArray objectAtIndex:_index];
			  NSDebugMLLog(@"requests",@"_gswsid=%@",_gswsid);
			  _index++;
			  if ([_requestHandlerPathArray count]>_index)
				{
				  NSString* _senderID=[_requestHandlerPathArray objectAtIndex:_index];
				  NSDebugMLLog(@"requests",@"_senderID=%@",_senderID);
				  _index++;
				  if (_senderID && [_senderID length]>0)
					{
					  NSArray* _senderIDParts=[_senderID componentsSeparatedByString:@"."];
					  NSDebugMLLog(@"requests",@"_senderIDParts=%@",_senderIDParts);
					  if ([_senderIDParts count]>0)
						{
						  tmp=[_senderIDParts objectAtIndex:0];
						  NSDebugMLLog(@"requests",@"tmp=%@",tmp);
						  if (tmp && [tmp length]>0)
							_gswcid=tmp;
					  
						  if ([_senderIDParts count]>1)
							{
							  tmp=[[_senderIDParts subarrayWithRange:
													 NSMakeRange(1,[_senderIDParts count]-1)]
									componentsJoinedByString:@"."];
							  NSDebugMLLog(@"requests",@"tmp=%@",tmp);
							  if (tmp && [tmp length]>0)
								{
								  _gsweid=tmp;
								  NSDebugMLLog(@"requests",@"_gsweid=%@",_gsweid);
								};
							};
						};
					};
				};
			};
		};
	};
  
  if (_gswpage)
	[_dict setObject:_gswpage
		   forKey:GSWKey_PageName];
  
  if (_gswsid)
	[_dict setObject:_gswsid
		   forKey:GSWKey_SessionID];

  if (_gswcid)
	[_dict setObject:_gswcid
		   forKey:GSWKey_ContextID];

  if (_gsweid)
	[_dict setObject:_gsweid
		   forKey:GSWKey_ElementID];

  _applicationNumber=[uri urlApplicationNumber];
  if (_applicationNumber<0)
	{
	  NSString* _tmp=[self cookieValueForKey:GSWKey_InstanceID];
	  if (_tmp)
		_applicationNumber=[_gswinst intValue];
	};
  if (_applicationNumber>=0)
	[_dict setObject:[NSString stringWithFormat:@"%d",_applicationNumber]
		   forKey:GSWKey_InstanceID];
	
  NSDebugMLLog(@"requests",@"AA _dict=%@",_dict);
  LOGObjectFnStop();
  return _dict;
};
@end

//====================================================================
@implementation GSWRequest (GSWRequestL)
//--------------------------------------------------------------------
-(void)_validateAPI
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end
