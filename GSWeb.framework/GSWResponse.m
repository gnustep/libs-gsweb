/* GSWResponse.m - GSWeb: Class GSWResponse
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
@implementation GSWResponse

NSStringEncoding globalDefaultEncoding=NSISOLatin1StringEncoding;

//--------------------------------------------------------------------
//	init
-(id)init 
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  httpVersion=@"HTTP/1.0";
	  status=200;
	  headers=[NSMutableDictionary new];
	  [self _initContentData];
	  contentEncoding=NSISOLatin1StringEncoding;
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogAssertGood(self);
  NSDebugFLog(@"dealloc Response %p",self);
  NSDebugFLog0(@"Release Response httpVersion");
  DESTROY(httpVersion);
  NSDebugFLog0(@"Release Response headers");
  DESTROY(headers);
  NSDebugFLog0(@"Release Response contentFaults");
  DESTROY(contentFaults);
  NSDebugFLog0(@"Release Response contentData");
  DESTROY(contentData);
  NSDebugFLog0(@"Release Response userInfo");
  DESTROY(userInfo);
  NSDebugFLog0(@"Release Response cookies");
  DESTROY(cookies);
  NSDebugFLog0(@"Release Response");
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone_
{
  GSWResponse* clone = [[isa allocWithZone:zone_] init];
  if (clone)
	{
	  ASSIGNCOPY(clone->httpVersion,httpVersion);
	  clone->status=status;
	  ASSIGNCOPY(clone->headers,headers);
	  ASSIGNCOPY(clone->contentFaults,contentFaults);
	  ASSIGNCOPY(clone->contentData,contentData);
	  clone->contentEncoding=contentEncoding;
	  ASSIGNCOPY(clone->userInfo,userInfo);
	  ASSIGNCOPY(clone->cookies,cookies);
	  clone->isClientCachingDisabled=isClientCachingDisabled;
	  clone->contentFaultsHaveBeenResolved=contentFaultsHaveBeenResolved;
	};
  return clone;
};

//--------------------------------------------------------------------
//	content

-(NSData*)content
{
  //TODO exception..
  return contentData;
};

//--------------------------------------------------------------------
//	willSend
//NDFN
-(void)willSend
{
  NSAssert(isFinalizeInContextHasBeenCalled,@"GSWResponse _finalizeInContext: not called");
};


//--------------------------------------------------------------------
//	headerForKey:

//  return:
//  	nil: if no header for key_
//	1st header: if multiple headers for key_
//	header: otherwise

-(NSString*)headerForKey:(NSString*)key_ 
{
  id object=[headers objectForKey:key_];
  if (object && [object isKindOfClass:[NSArray class]])
	return [object objectAtIndex:0];
  else
	return (NSString*)object;
};

//--------------------------------------------------------------------
//	headerKeys

// return array of header keys or nil if no header
-(NSArray*)headerKeys 
{
  return [headers allKeys];
};

//--------------------------------------------------------------------
//	headersForKey:

//return array of headers of key_
-(NSArray*)headersForKey:(NSString*)key_ 
{
  id object=[headers objectForKey:key_];
  if (!object || [object isKindOfClass:[NSArray class]])
	return (NSArray*)object;
  else
	return [NSArray arrayWithObject:object];
};

//--------------------------------------------------------------------
//	httpVersion

//return http version like @"HTTP/1.0"

-(NSString*)httpVersion
{
  return httpVersion;
};

//--------------------------------------------------------------------
//	setContent:

//Set content with contentData_
-(void)setContent:(NSData*)contentData_ 
{
  if (contentData_)
	{
	  NSMutableData* _void=[[NSMutableData new]autorelease];
	  [_void appendData:contentData_];
	  contentData_=_void;
	};
  ASSIGN(contentData,(NSMutableData*)contentData_);
};

//--------------------------------------------------------------------
//	setHeader:forKey:

-(void)setHeader:(NSString*)header_
		  forKey:(NSString*)key_ 
{
  //OK
  id object=[headers objectForKey:key_];
  if (object)
	[self setHeaders:[object arrayByAddingObject:header_]
		  forKey:key_];
  else
	[self setHeaders:[NSArray arrayWithObject:header_]
		  forKey:key_];
};

//--------------------------------------------------------------------
//	setHeaders:forKey:

-(void)setHeaders:(NSArray*)headers_
		   forKey:(NSString*)key_ 
{
  //OK
  if (!headers)
	headers=[NSMutableDictionary new];
  [headers setObject:headers_
		   forKey:key_];
};

//--------------------------------------------------------------------
//	setHTTPVersion:

//sets the http version (like @"HTTP/1.0"). 
-(void)setHTTPVersion:(NSString*)version_
{
  //OK
  ASSIGN(httpVersion,version_);
};

//--------------------------------------------------------------------
//	setStatus:

//sets http status
-(void)setStatus:(unsigned int)status_
{
  status=status_;
};

//--------------------------------------------------------------------
//	setUserInfo:

-(void)setUserInfo:(NSDictionary*)userInfo_
{
  ASSIGN(userInfo,userInfo_);
};

//--------------------------------------------------------------------
//	status

-(unsigned int)status
{
  return status;
};

//--------------------------------------------------------------------
//	userInfo

-(NSDictionary*)userInfo 
{
  return userInfo;
};

//--------------------------------------------------------------------
-(void)disableClientCaching
{
  //OK
  NSString* _dateString=nil;
  LOGObjectFnStart();
  _dateString=[[NSCalendarDate date] htmlDescription];
  NSDebugMLLog(@"low",@"_dateString:%@",_dateString);
  [self setHeader:_dateString 
		forKey:@"date"];
  [self setHeader:_dateString
		forKey:@"expires"];
  [self setHeader:@"no-cache"
		forKey:@"pragma"];
  [self setHeaders:[NSArray arrayWithObjects:@"private",@"no-cache",@"max-age=0",nil]
		forKey:@"cache-control"];		
  isClientCachingDisabled=YES;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSString*)description
{
  NSString* description=nil;
  LOGObjectFnStart();
  description=[NSString stringWithFormat:
						  @"<%s %p - httpVersion=%@ status=%d headers=%p contentFaults=%p contentData=%p contentEncoding=%d userInfo=%p>",
				   object_get_class_name(self),
				   (void*)self,
				   httpVersion,
				   status,
				   (void*)headers,
				   (void*)contentFaults,
				   (void*)contentData,
				   (int)contentEncoding,
				   (void*)userInfo];
  LOGObjectFnStop();
  return description;
};
@end

//====================================================================
@implementation GSWResponse (GSWContentConveniences)

//--------------------------------------------------------------------
//	appendContentBytes:length:

-(void)appendContentBytes:(const void*)bytes_
				   length:(unsigned)length_
{
  LOGObjectFnStart();
  [contentData appendBytes:bytes_
		   length:length_];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendContentCharacter:

-(void)appendContentCharacter:(char)char_
{
  LOGObjectFnStart();
  [contentData appendBytes:&char_
		   length:1];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendContentData:

-(void)appendContentData:(NSData*)dataObject_
{
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"response=%p dataObject_:%@",self,dataObject_);
  [contentData appendData:dataObject_];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendContentString:

-(void)appendContentString:(NSString*)string_
{
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"response=%p contentEncoding=%d",self,(int)contentEncoding);
  if (string_)
    {
      NSData* newData=nil;
      NSString* _string=nil;
      _string=[NSString stringWithObject:string_];
      NSAssert(_string,@"Can't get string from object");
#ifndef NDEBUG
      NSAssert3(![_string isKindOfClass:[NSString class]] || [_string canBeConvertedToEncoding:contentEncoding],
                @"string %s (of class %@) can't be converted to encoding %d",
                [_string lossyCString],
                [_string class],
                contentEncoding);
#endif
      newData=[_string dataUsingEncoding:contentEncoding];
      NSAssert3(newData,@"Can't create data from %@ \"%s\" using encoding %d",
               [_string class],
               ([_string isKindOfClass:[NSString class]] ? [_string lossyCString] : @"**Not a string**"),
               (int)contentEncoding);
      NSDebugMLLog(@"low",@"newData=%@",newData);
      [contentData appendData:newData];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	contentEncoding

-(NSStringEncoding)contentEncoding 
{
  return contentEncoding;
};

//--------------------------------------------------------------------
//	setContentEncoding:

-(void)setContentEncoding:(NSStringEncoding)encoding_
{
  NSDebugMLLog(@"low",@"setContentEncoding:%d",(int)encoding_);
  contentEncoding=encoding_;
};


@end

//====================================================================
@implementation GSWResponse (GSWHTMLConveniences)

//--------------------------------------------------------------------
//	appendContentHTMLAttributeValue:

-(void)appendContentHTMLAttributeValue:(NSString*)value_
{
  NSString* _string=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"response=%p value_=%@",self,value_);
  _string=[NSString stringWithObject:value_];
  [self appendContentString:[[self class]stringByEscapingHTMLAttributeValue:_string]];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendContentHTMLString:

-(void)appendContentHTMLString:(NSString*)string_
{
  NSString* _string=[NSString stringWithObject:string_];
  [self appendContentString:[[self class]stringByEscapingHTMLString:_string]];
};

//--------------------------------------------------------------------
-(void)appendContentHTMLConvertString:(NSString*)string_
{
  NSString* _string=[NSString stringWithObject:string_];
  [self appendContentString:[[self class]stringByConvertingToHTML:_string]];
};

//--------------------------------------------------------------------
-(void)appendContentHTMLEntitiesConvertString:(NSString*)string_
{
  NSString* _string=[NSString stringWithObject:string_];
  [self appendContentString:[[self class]stringByConvertingToHTMLEntities:_string]];
};

//--------------------------------------------------------------------
+(NSString*)stringByEscapingHTMLString:(NSString*)string_
{
  return [string_ stringByEscapingHTMLString];
};

//--------------------------------------------------------------------
+(NSString*)stringByEscapingHTMLAttributeValue:(NSString*)string_
{
  return [string_ stringByEscapingHTMLAttributeValue];
};

//--------------------------------------------------------------------
+(NSString*)stringByConvertingToHTMLEntities:(NSString*)string_
{
  return [string_ stringByConvertingToHTMLEntities];
};

//--------------------------------------------------------------------
+(NSString*)stringByConvertingToHTML:(NSString*)string_
{
  return [string_ stringByConvertingToHTML];
};

@end

//====================================================================
@implementation GSWResponse (Cookies)

//--------------------------------------------------------------------
-(NSString*)_formattedCookiesString
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSArray*)allocCookiesIFND
{
  //OK
  if (!cookies)
	cookies=[NSMutableArray new];
  return cookies;
};

//--------------------------------------------------------------------
-(void)addCookie:(GSWCookie*)cookie_
{
  //OK
  NSMutableArray* _cookies=nil;
  LOGObjectFnStart();
  _cookies=[self allocCookiesIFND];
  [_cookies addObject:cookie_];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)removeCookie:(GSWCookie*)cookie_
{
  NSMutableArray* _cookies=nil;
  LOGObjectFnStart();
  _cookies=[self allocCookiesIFND];
  [_cookies removeObject:cookie_];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSArray*)cookies
{
  NSMutableArray* _cookies=[self allocCookiesIFND];
  return _cookies;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)cookiesHeadersValues
{
  NSMutableArray* _strings=nil;
  NSArray* _cookies=[self cookies];
  if ([_cookies count]>0)
	{
	  int i=0;
	  int _count=[_cookies count];
	  GSWCookie* _cookie=nil;
	  NSString* _cookieString=nil;
	  _strings=[NSMutableArray array];
	  for(i=0;i<_count;i++)
		{
		  _cookie=[_cookies objectAtIndex:i];
		  _cookieString=[_cookie headerValue];
		  [_strings addObject:_cookieString];
		};
	};
  return (_strings ? [NSArray arrayWithArray:_strings] : nil);
};

@end

//====================================================================
@implementation GSWResponse (GSWResponseA)

//--------------------------------------------------------------------
//NDFN
-(BOOL)isFinalizeInContextHasBeenCalled
{
  return isFinalizeInContextHasBeenCalled;
};

//--------------------------------------------------------------------
-(void)_finalizeInContext:(GSWContext*)_context
{
  //OK
  NSArray* _setCookieHeader=nil;
  NSArray* _cookies=nil;
  GSWRequest* _request=nil;
  int _applicationNumber=-1;
  int _dataLength=0;
  NSString* _dataLengthString=nil;
  LOGObjectFnStart();
  NSAssert(!isFinalizeInContextHasBeenCalled,@"GSWResponse _finalizeInContext: already called");
  //TODOV: if !session in request and session created: no client cache
  if (![self _isClientCachingDisabled] && [_context hasSession] && ![_context _requestSessionID])
	[self disableClientCaching];

  [self _resolveContentFaultsInContext:_context];
  _setCookieHeader=[self headersForKey:GSWHTTPHeader_SetCookie];
  if (_setCookieHeader)
	{
	  ExceptionRaise(@"GSWResponse",
					 @"%@ header already exists",
					 GSWHTTPHeader_SetCookie);
	};
  _cookies=[self cookies];
  if ([_cookies count]>0)
	{
	  id _cookiesHeadersValues=[self cookiesHeadersValues];
	  NSDebugMLLog(@"low",@"_cookiesHeadersValues=%@",_cookiesHeadersValues);
	  [self setHeaders:_cookiesHeadersValues
			forKey:GSWHTTPHeader_SetCookie];
	};
  _request=[_context request];
  _applicationNumber=[_request applicationNumber];
  NSDebugMLLog(@"low",@"_applicationNumber=%d",_applicationNumber);
  //TODO
/*  if (_applicationNumber>=0)
	{
	  LOGError(); //TODO
	}; */
  _dataLength=[contentData length];
  _dataLengthString=[NSString stringWithFormat:@"%d",
							  _dataLength];
  [self setHeader:_dataLengthString
		forKey:GSWHTTPHeader_ContentLength];
  NSDebugMLLog(@"low",@"headers:%@",headers);
  isFinalizeInContextHasBeenCalled=YES;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_initContentData
{
  //OK
  DESTROY(contentData);
  contentData=[NSMutableData new];
};

//--------------------------------------------------------------------
-(void)_appendContentAsciiString:(NSString*)string_
{
  NSData* newData=nil;
  NSString* _string=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"string_:%@",string_);
  _string=[NSString stringWithObject:string_];
  NSDebugMLLog(@"low",@"_string:%@",_string);
  newData=[_string dataUsingEncoding:contentEncoding];
  [contentData appendData:newData];
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWResponse (GSWResponseB)
-(void)_resolveContentFaultsInContext:(GSWContext*)_context
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_appendContentFault:(id)_unknown
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWResponse (GSWResponseC)

//--------------------------------------------------------------------
-(BOOL)_isClientCachingDisabled
{
  return isClientCachingDisabled;
};

//--------------------------------------------------------------------
-(unsigned int)_contentDataLength
{
  return [contentData length];
};

@end

//====================================================================
@implementation GSWResponse (GSWResponseD)

//--------------------------------------------------------------------
-(BOOL)_responseIsEqual:(GSWResponse*)_response
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

@end
//====================================================================
@implementation GSWResponse (GSWActionResults)

//--------------------------------------------------------------------
-(GSWResponse*)generateResponse
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWResponse (GSWResponseDefaultEncoding)

//--------------------------------------------------------------------
+(void)setDefaultEncoding:(NSStringEncoding)encoding_
{
  globalDefaultEncoding=encoding_;
};

//--------------------------------------------------------------------
+(NSStringEncoding)defaultEncoding;
{
  return globalDefaultEncoding;
};

@end

//====================================================================
@implementation GSWResponse (GSWResponseError)

//--------------------------------------------------------------------
//NDFN
//Last cHance Response
+(GSWResponse*)responseWithMessage:(NSString*)message_
			 inContext:(GSWContext*)context_
			forRequest:(GSWRequest*)request_
{
  GSWResponse* _response=nil;
  NSString* _httpVersion=nil;
  LOGClassFnStart();
  _response=[[self new]autorelease];
  if (_response)
    {
      NSString* _responseString=nil;
      if (context_ && [context_ request])
	request_=[context_ request];
      _httpVersion=[request_ httpVersion];
      if (_httpVersion)
	[_response setHTTPVersion:_httpVersion];
      [_response setHeader:@"text/html"
		 forKey:@"content-type"];
      [context_ _setResponse:_response];
      _responseString=[NSString stringWithFormat:@"<HTML>\n<TITLE>GNUstepWeb Error</TITLE>\n</HEAD>\n<BODY bgcolor=\"white\">\n<CENTER>\n%@\n</CENTER>\n</BODY>\n</HTML>\n",
				[[_response class]stringByEscapingHTMLString:message_]];
      [_response appendContentString:_responseString];
    };
  LOGClassFnStop();
  return _response;
};

@end

