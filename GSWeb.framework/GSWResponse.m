/** GSWResponse.m - <title>GSWeb: Class GSWResponse</title>

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
      _httpVersion=@"HTTP/1.0";
      _status=200;
      _headers=[NSMutableDictionary new];
      [self _initContentData];
      _contentEncoding=NSISOLatin1StringEncoding;
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
//  GSWLogAssertGood(self);
//  NSDebugFLog(@"dealloc Response %p",self);
//  NSDebugFLog0(@"Release Response httpVersion");
  DESTROY(_httpVersion);
//  NSDebugFLog0(@"Release Response headers");
  DESTROY(_headers);
//  NSDebugFLog0(@"Release Response contentFaults");
  DESTROY(_contentFaults);
//  NSDebugFLog0(@"Release Response contentData");
  DESTROY(_contentData);
//  NSDebugFLog0(@"Release Response userInfo");
  DESTROY(_userInfo);
  //NSDebugFLog0(@"Release Response cookies");
  DESTROY(_cookies);
//  NSDebugFLog0(@"Release Response");
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWResponse* clone = [[isa allocWithZone:zone] init];
  if (clone)
    {
      ASSIGNCOPY(clone->_httpVersion,_httpVersion);
      clone->_status=_status;
      ASSIGNCOPY(clone->_headers,_headers);
      ASSIGNCOPY(clone->_contentFaults,_contentFaults);
      ASSIGNCOPY(clone->_contentData,_contentData);
      clone->_contentEncoding=_contentEncoding;
      ASSIGNCOPY(clone->_userInfo,_userInfo);
      ASSIGNCOPY(clone->_cookies,_cookies);
      clone->_isClientCachingDisabled=_isClientCachingDisabled;
      clone->_contentFaultsHaveBeenResolved=_contentFaultsHaveBeenResolved;
    };
  return clone;
};

//--------------------------------------------------------------------
//	content

-(NSData*)content
{
  //TODO exception..
  return _contentData;
};

//--------------------------------------------------------------------
//	willSend
//NDFN
-(void)willSend
{
  NSAssert(_isFinalizeInContextHasBeenCalled,@"GSWResponse _finalizeInContext: not called");
};

-(void)forceFinalizeInContext
{
  _isFinalizeInContextHasBeenCalled=YES;
};

//--------------------------------------------------------------------
//	headerForKey:

//  return:
//  	nil: if no header for key_
//	1st header: if multiple headers for key_
//	header: otherwise

-(NSString*)headerForKey:(NSString*)key
{
  id object=[_headers objectForKey:key];
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
  return [_headers allKeys];
};

//--------------------------------------------------------------------
//	headersForKey:

//return array of headers of key_
-(NSArray*)headersForKey:(NSString*)key
{
  id object=[_headers objectForKey:key];
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
  return _httpVersion;
};

//--------------------------------------------------------------------
//	setContent:

//Set content with contentData_
-(void)setContent:(NSData*)contentData
{
  if (contentData)
    {
      NSMutableData* aData=[[NSMutableData new]autorelease];
      [aData appendData:contentData];
      contentData=aData;
    };
  ASSIGN(_contentData,(NSMutableData*)contentData);
};

//--------------------------------------------------------------------
//	setHeader:forKey:

-(void)setHeader:(NSString*)header
          forKey:(NSString*)key
{
  //OK
  id object=[_headers objectForKey:key];
  if (object)
    [self setHeaders:[object arrayByAddingObject:header]
          forKey:key];
  else
    [self setHeaders:[NSArray arrayWithObject:header]
          forKey:key];
};

//--------------------------------------------------------------------
//	setHeaders:forKey:

-(void)setHeaders:(NSArray*)headers
           forKey:(NSString*)key
{
  //OK
  if (!_headers)
    _headers=[NSMutableDictionary new];
  [_headers setObject:headers
            forKey:key];
};

//--------------------------------------------------------------------
//	setHeaders:
 
-(void)setHeaders:(NSDictionary*)headerDictionary
{
  if (!_headers)
    _headers=[NSMutableDictionary new];
  
  if (headerDictionary)
    {
      NSEnumerator* keyEnum=nil;
      id	    headerName=nil;
    
      keyEnum = [headerDictionary keyEnumerator];
      while ((headerName = [keyEnum nextObject]))
        {
          [self setHeaders:[NSArray arrayWithObject:[headerDictionary objectForKey:headerName]] forKey:headerName];
 	};
    };
};
 
//--------------------------------------------------------------------
//	headers

-(NSMutableDictionary*)headers
{
  return _headers;
};

//--------------------------------------------------------------------
//	setHTTPVersion:

//sets the http version (like @"HTTP/1.0"). 
-(void)setHTTPVersion:(NSString*)version
{
  //OK
  ASSIGN(_httpVersion,version);
};

//--------------------------------------------------------------------
//	setStatus:

//sets http status
-(void)setStatus:(unsigned int)status
{
  _status=status;
};

//--------------------------------------------------------------------
//	setUserInfo:

-(void)setUserInfo:(NSDictionary*)userInfo
{
  ASSIGN(_userInfo,userInfo);
};

//--------------------------------------------------------------------
//	status

-(unsigned int)status
{
  return _status;
};

//--------------------------------------------------------------------
//	userInfo

-(NSDictionary*)userInfo 
{
  return _userInfo;
};

//--------------------------------------------------------------------
-(void)disableClientCaching
{
  //OK
  NSString* dateString=nil;
  LOGObjectFnStart();
  if (!_isClientCachingDisabled)
    {
      dateString=[[NSCalendarDate date] htmlDescription];
      NSDebugMLLog(@"low",@"dateString:%@",dateString);
      [self setHeader:dateString 
            forKey:@"date"];
      [self setHeader:dateString
            forKey:@"expires"];
      [self setHeader:@"no-cache"
            forKey:@"pragma"];
      
      [self setHeaders:[NSArray arrayWithObjects:@"private",@"no-cache",@"max-age=0",nil]
            forKey:@"cache-control"];
  
      _isClientCachingDisabled=YES;
    };
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
                        _httpVersion,
                        _status,
                        (void*)_headers,
                        (void*)_contentFaults,
                        (void*)_contentData,
                        (int)_contentEncoding,
                        (void*)_userInfo];
  LOGObjectFnStop();
  return description;
};
@end

//====================================================================
@implementation GSWResponse (GSWContentConveniences)

//--------------------------------------------------------------------
//	appendContentBytes:length:

-(void)appendContentBytes:(const void*)bytes
                   length:(unsigned)length
{
  LOGObjectFnStart();
  [_contentData appendBytes:bytes
               length:length];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendContentCharacter:

-(void)appendContentCharacter:(char)aChar
{
  LOGObjectFnStart();
  [_contentData appendBytes:&aChar
                length:1];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendContentData:

-(void)appendContentData:(NSData*)dataObject
{
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"response=%p dataObject:%@",self,dataObject);
  [_contentData appendData:dataObject];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendContentString:

-(void)appendContentString:(NSString*)aString
{
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"response=%p contentEncoding=%d",self,(int)_contentEncoding);
  if (aString)
    {
      NSData* newData=nil;
      NSString* string=nil;
      string=[NSString stringWithObject:aString];
      NSAssert(string,@"Can't get string from object");
#ifndef NDEBUG
      NSAssert3(![string isKindOfClass:[NSString class]] || [string canBeConvertedToEncoding:_contentEncoding],
                @"string %s (of class %@) can't be converted to encoding %d",
                [string lossyCString],
                [string class],
                _contentEncoding);
#endif
      newData=[string dataUsingEncoding:_contentEncoding];
      NSAssert3(newData,@"Can't create data from %@ \"%s\" using encoding %d",
               [string class],
               ([string isKindOfClass:[NSString class]] ? [string lossyCString] : @"**Not a string**"),
               (int)_contentEncoding);
      NSDebugMLLog(@"low",@"newData=%@",newData);
      [_contentData appendData:newData];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendDebugCommentContentString:

-(void)appendDebugCommentContentString:(NSString*)aString
{
#ifndef NDEBUG
  [self appendContentString:[NSString stringWithFormat:@"\n<!-- %@ -->\n",aString]];
#endif
};

//--------------------------------------------------------------------
//	contentEncoding

-(NSStringEncoding)contentEncoding 
{
  return _contentEncoding;
};

//--------------------------------------------------------------------
//	setContentEncoding:

-(void)setContentEncoding:(NSStringEncoding)encoding
{
  NSDebugMLLog(@"low",@"setContentEncoding:%d",(int)encoding);
  _contentEncoding=encoding;
};


@end

//====================================================================
@implementation GSWResponse (GSWHTMLConveniences)

//--------------------------------------------------------------------
//	appendContentHTMLAttributeValue:

-(void)appendContentHTMLAttributeValue:(NSString*)value
{
  NSString* string=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"response=%p value=%@",self,value);
  string=[NSString stringWithObject:value];
  [self appendContentString:[[self class]stringByEscapingHTMLAttributeValue:string]];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendContentHTMLString:

-(void)appendContentHTMLString:(NSString*)aString
{
  NSString* string=[NSString stringWithObject:aString];
  [self appendContentString:[[self class]stringByEscapingHTMLString:string]];
};

//--------------------------------------------------------------------
-(void)appendContentHTMLConvertString:(NSString*)aString
{
  NSString* string=[NSString stringWithObject:aString];
  [self appendContentString:[[self class]stringByConvertingToHTML:string]];
};

//--------------------------------------------------------------------
-(void)appendContentHTMLEntitiesConvertString:(NSString*)aString
{
  NSString* string=[NSString stringWithObject:aString];
  [self appendContentString:[[self class]stringByConvertingToHTMLEntities:string]];
};

//--------------------------------------------------------------------
+(NSString*)stringByEscapingHTMLString:(NSString*)aString
{
  NSString* string=[NSString stringWithObject:aString];
  return [string stringByEscapingHTMLString];
};

//--------------------------------------------------------------------
+(NSString*)stringByEscapingHTMLAttributeValue:(NSString*)aString
{
  NSString* string=[NSString stringWithObject:aString];
  return [string stringByEscapingHTMLAttributeValue];
};

//--------------------------------------------------------------------
+(NSString*)stringByConvertingToHTMLEntities:(NSString*)aString
{
  NSString* string=[NSString stringWithObject:aString];
  return [string stringByConvertingToHTMLEntities];
};

//--------------------------------------------------------------------
+(NSString*)stringByConvertingToHTML:(NSString*)aString
{
  NSString* string=[NSString stringWithObject:aString];
  return [string stringByConvertingToHTML];
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
  if (!_cookies)
    _cookies=[NSMutableArray new];
  return _cookies;
};

//--------------------------------------------------------------------
-(void)addCookie:(GSWCookie*)cookie
{
  //OK
  NSMutableArray* cookies=nil;
  LOGObjectFnStart();
  cookies=[self allocCookiesIFND];
  [cookies addObject:cookie];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)removeCookie:(GSWCookie*)cookie
{
  NSMutableArray* cookies=nil;
  LOGObjectFnStart();
  cookies=[self allocCookiesIFND];
  [cookies removeObject:cookie];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSArray*)cookies
{
  NSMutableArray* cookies=[self allocCookiesIFND];
  return cookies;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)cookiesHeadersValues
{
  NSMutableArray* strings=nil;
  NSArray* cookies=[self cookies];
  if ([cookies count]>0)
    {
      int i=0;
      int count=[cookies count];
      GSWCookie* cookie=nil;
      NSString* cookieString=nil;
      strings=[NSMutableArray array];
      for(i=0;i<count;i++)
        {
          cookie=[cookies objectAtIndex:i];
          cookieString=[cookie headerValue];
          [strings addObject:cookieString];
        };
    };
  return (strings ? [NSArray arrayWithArray:strings] : nil);
};

@end

//====================================================================
@implementation GSWResponse (GSWResponseA)

//--------------------------------------------------------------------
//NDFN
-(BOOL)isFinalizeInContextHasBeenCalled
{
  return _isFinalizeInContextHasBeenCalled;
};

//--------------------------------------------------------------------
-(void)_finalizeInContext:(GSWContext*)aContext
{
  //OK
  NSArray* setCookieHeader=nil;
  NSArray* cookies=nil;
  GSWRequest* request=nil;
  int applicationNumber=-1;
  int dataLength=0;
  NSString* dataLengthString=nil;
  LOGObjectFnStart();
  NSAssert(!_isFinalizeInContextHasBeenCalled,@"GSWResponse _finalizeInContext: already called");

#ifndef NDEBUG
  if(GSDebugSet(@"GSWDocStructure"))
    {
      NSString* docStructure=[aContext docStructure];
      if (docStructure)
        [self appendDebugCommentContentString:docStructure];
    }
#endif

  //TODOV: if !session in request and session created: no client cache
  if (![self _isClientCachingDisabled] && [aContext hasSession] && ![aContext _requestSessionID])
    [self disableClientCaching];

  [self _resolveContentFaultsInContext:aContext];
  setCookieHeader=[self headersForKey:GSWHTTPHeader_SetCookie];
  if (setCookieHeader)
    {
      ExceptionRaise(@"GSWResponse",
                     @"%@ header already exists",
                     GSWHTTPHeader_SetCookie);
    };
  cookies=[self cookies];
  if ([cookies count]>0)
    {
      id cookiesHeadersValues=[self cookiesHeadersValues];
      NSDebugMLLog(@"low",@"cookiesHeadersValues=%@",cookiesHeadersValues);
      [self setHeaders:cookiesHeadersValues
            forKey:GSWHTTPHeader_SetCookie];
    };
  request=[aContext request];
  applicationNumber=[request applicationNumber];
  NSDebugMLLog(@"low",@"applicationNumber=%d",applicationNumber);
  //TODO
  /*  if (_applicationNumber>=0)
      {
	  LOGError(); //TODO
          }; */
  dataLength=[_contentData length];
  dataLengthString=[NSString stringWithFormat:@"%d",
                             dataLength];
  [self setHeader:dataLengthString
		forKey:GSWHTTPHeader_ContentLength];
  NSDebugMLLog(@"low",@"headers:%@",_headers);
  _isFinalizeInContextHasBeenCalled=YES;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_initContentData
{
  //OK
  DESTROY(_contentData);
  _contentData=[NSMutableData new];
};

//--------------------------------------------------------------------
-(void)_appendContentAsciiString:(NSString*)aString
{
  NSData* newData=nil;
  NSString* string=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"aString:%@",aString);
  string=[NSString stringWithObject:aString];
  NSDebugMLLog(@"low",@"_string:%@",string);
  newData=[string dataUsingEncoding:_contentEncoding];
  [_contentData appendData:newData];
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWResponse (GSWResponseB)
-(void)_resolveContentFaultsInContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_appendContentFault:(id)unknown
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWResponse (GSWResponseC)

//--------------------------------------------------------------------
-(BOOL)_isClientCachingDisabled
{
  return _isClientCachingDisabled;
};

//--------------------------------------------------------------------
-(unsigned int)_contentDataLength
{
  return [_contentData length];
};

@end

//====================================================================
@implementation GSWResponse (GSWResponseD)

//--------------------------------------------------------------------
-(BOOL)_responseIsEqual:(GSWResponse*)aResponse
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
  //LOGObjectFnNotImplemented();	//TODOFN
  //return nil;
  return self;
};

@end

//====================================================================
@implementation GSWResponse (GSWResponseDefaultEncoding)

//--------------------------------------------------------------------
+(void)setDefaultEncoding:(NSStringEncoding)encoding
{
  globalDefaultEncoding=encoding;
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

+(GSWResponse*)responseWithMessage:(NSString*)aMessage
			 inContext:(GSWContext*)aContext
			forRequest:(GSWRequest*)aRequest
{
  return [self responseWithMessage:aMessage
               inContext:aContext
               forRequest:aRequest
               forceFinalize:NO];
};

+(GSWResponse*)responseWithMessage:(NSString*)aMessage
			 inContext:(GSWContext*)aContext
			forRequest:(GSWRequest*)aRequest
                     forceFinalize:(BOOL)forceFinalize
{
  GSWResponse* response=nil;
  NSString* httpVersion=nil;
  LOGClassFnStart();
  response=[[self new]autorelease];
  if (response)
    {
      NSString* responseString=nil;
      if (aContext && [aContext request])
	aRequest=[aContext request];
      httpVersion=[aRequest httpVersion];
      if (httpVersion)
	[response setHTTPVersion:httpVersion];
      [response setHeader:@"text/html"
                forKey:@"content-type"];
      [aContext _setResponse:response];
      responseString=[NSString stringWithFormat:@"<HTML>\n<TITLE>GNUstepWeb Error</TITLE>\n</HEAD>\n<BODY bgcolor=\"white\">\n<CENTER>\n%@\n</CENTER>\n</BODY>\n</HTML>\n",
                               [[response class]stringByEscapingHTMLString:aMessage]];
      [response appendContentString:responseString];
      if (forceFinalize)
        [response forceFinalizeInContext];
    };
  LOGClassFnStop();
  return response;
};

@end

//====================================================================
@implementation GSWResponse (GSWResponseRefused)

//--------------------------------------------------------------------
//
//Refuse Response
+(GSWResponse*)generateRefusingResponseInContext:(GSWContext*)aContext
                                      forRequest:(GSWRequest*)aRequest
{
  GSWResponse* response=nil;
  NSString* httpVersion=nil;
  LOGClassFnStart();
  response=[[self new]autorelease];
  if (response)
    {
      NSString* responseString=nil;
      NSString* locationURLString=nil;
      NSString* message=nil;

      if (aContext && [aContext request]) 
        {
          aRequest=[aContext request];
        }
      httpVersion=[aRequest httpVersion];
      if (httpVersion) 
        {
          [response setHTTPVersion:httpVersion];
        }

      [response setStatus:302];
      locationURLString = [NSString stringWithFormat:@"%@/%@.gswa",
                                    [aRequest adaptorPrefix], 
                                    [aRequest applicationName]];
      if (locationURLString) 
          [response setHeader:locationURLString 
                    forKey:@"location"];

      [response setHeader:@"text/html" 
                forKey:@"content-type"];
      [response setHeader:@"YES"
                forKey:@"x-gsweb-refusing-redirection"];
      
      if (aContext) 
        {
          [aContext _setResponse:response];
        }

      message = [NSString stringWithFormat:@"Sorry, your request could not immediately be processed. Please try this URL: <a href=\"%@\">%@</a>\nConnection closed by foreign host.", 
                          locationURLString, 
                          locationURLString];

      responseString=[NSString stringWithFormat:@"<HTML>\n<TITLE>GNUstepWeb</TITLE>\n</HEAD>\n<BODY bgcolor=\"white\">\n<CENTER>\n%@\n</CENTER>\n</BODY>\n</HTML>\n",
                               message];
      //[[response class]stringByEscapingHTMLString:message]];
      [response appendContentString:responseString];
      
      [response setHeader:[NSString stringWithFormat:@"%d",[[response content] length]] 
                forKey:@"content-length"];      
    };
  LOGClassFnStop();
  return response;
};

@end

