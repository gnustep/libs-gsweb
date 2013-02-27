/** GSWResponse.m - <title>GSWeb: Class GSWResponse</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
   $Revision$
   $Date$
   $Id$

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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"
#include "NSData+Compress.h"
#include "GSWPrivate.h"
#include <GNUstepBase/NSObject+GNUstepBase.h>

//====================================================================
@implementation GSWResponse

static NSString* disabledCacheDateString=nil;
static NSArray* cacheControlHeaderValues=nil;
static NSArray* compressableContentTypesCache=nil;

static SEL appendTagAttributeValueEscapingHTMLAttributeValueSEL = NULL;

//====================================================================
/** Fill impsPtr structure with IMPs for response **/
void GetGSWResponseIMPs(GSWResponseIMPs* impsPtr,GSWResponse* aResponse)
{
  memset(impsPtr,0,sizeof(GSWResponseIMPs));

  NSCAssert(aResponse,@"No response");

  impsPtr->_appendTagAttributeValueEscapingHTMLAttributeValueIMP = 
    [aResponse methodForSelector:appendTagAttributeValueEscapingHTMLAttributeValueSEL];
};

//====================================================================
/** functions to accelerate calls of frequently used GSWResponse methods **/

//--------------------------------------------------------------------
void GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(GSWResponse* aResponse,
                                                                   NSString* aString,
                                                                   id value,
                                                                   BOOL escaping)
{
  if (aResponse)
    {
      (*(aResponse->_selfIMPs._appendTagAttributeValueEscapingHTMLAttributeValueIMP))
        (aResponse,appendTagAttributeValueEscapingHTMLAttributeValueSEL,aString,value,escaping);
    };
}

//--------------------------------------------------------------------
+(void)initialize
{
  if (self==[GSWResponse class])
    {
      // So cache date stamp will be set to earlier date
      ASSIGN(disabledCacheDateString,[[NSCalendarDate date] htmlDescription]);

      // Other cache control headers
      ASSIGN(cacheControlHeaderValues,([NSArray arrayWithObjects:@"private",
                                                @"no-cache",
                                                @"no-store",
                                                @"must-revalidate",
                                                @"max-age=0",
                                                nil]));

      appendTagAttributeValueEscapingHTMLAttributeValueSEL = @selector(_appendTagAttribute:value:escapingHTMLAttributeValue:);
      
      ASSIGN(compressableContentTypesCache, ([NSArray arrayWithObjects:@"text/html",
                                             @"text/plain",
                                             @"text/css",
                                             @"text/csv",
                                             @"text/xml",
                                             @"text/rtf",
                                             @"text/calendar",
                                             @"text/x-vcalendar",
                                             @"text/enriched",
                                             @"text/directory",
                                             @"image/svg+xml",
                                              nil]));
                                             
    };
};

+ (NSArray*) compressableContentTypes
{
  return compressableContentTypesCache;
}

+ (void) setCompressableContentTypes:(NSArray*) cTypes
{
  ASSIGN(compressableContentTypesCache,cTypes);
}

//--------------------------------------------------------------------
//	init
-(id)init 
{
  //OK
  if ((self=[super init]))
    {
      GetGSWResponseIMPs(&_selfIMPs,self);
      _canDisableClientCaching=YES;
      _status=200;
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
//  GSWLogAssertGood(self);
//  NSDebugFLog(@"dealloc Response %p",self);
//  NSDebugFLog0(@"Release Response contentFaults");
  DESTROY(_contentFaults);
//  NSDebugFLog0(@"Release Response contentData");
  DESTROY(_contentStreamFileHandle);
//  NSDebugFLog0(@"Release Response");
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWResponse* clone = (GSWResponse*)[super copyWithZone:zone];
  if (clone)
    {
      clone->_status=_status;
      ASSIGNCOPY(clone->_contentFaults,_contentFaults);
      clone->_isClientCachingDisabled=_isClientCachingDisabled;
      clone->_canDisableClientCaching=_canDisableClientCaching;
      clone->_contentFaultsHaveBeenResolved=_contentFaultsHaveBeenResolved;
    };
  return clone;
};

//--------------------------------------------------------------------
//	willSend
//NDFN
-(void)willSend
{
  NSAssert(_isFinalizeInContextHasBeenCalled,@"GSWResponse _finalizeInContext: not called");
};

//--------------------------------------------------------------------
-(void)forceFinalizeInContext
{
  _isFinalizeInContextHasBeenCalled=YES;
};

//--------------------------------------------------------------------
//	setStatus:

//sets http status
-(void)setStatus:(unsigned int)status
{
  _status=status;
};

//--------------------------------------------------------------------
//	status

-(unsigned int)status
{
  return _status;
};

//--------------------------------------------------------------------
// should be called before finalizeInContext
-(void)setCanDisableClientCaching:(BOOL)yn
{
  _canDisableClientCaching=yn;
};

//--------------------------------------------------------------------
-(void)disableClientCaching
{

  if (!_isClientCachingDisabled && _canDisableClientCaching)
    {
      [self setHeader:disabledCacheDateString 
            forKey:@"Date"];
      [self setHeader:disabledCacheDateString
            forKey:@"Expires"];
      [self setHeader:@"no-cache"
            forKey:@"Pragma"];
      
      if([[GSWApp class] _allowsCacheControlHeader])
        [self setHeaders:cacheControlHeaderValues
              forKey:@"cache-control"];
      _isClientCachingDisabled=YES;
    };

};

//--------------------------------------------------------------------
-(NSString*)description
{
  NSString* description=nil;
  description=[NSString stringWithFormat:
                          @"<%s %p - httpVersion=%@ status=%d headers=%p contentFaults=%p contentData=%p contentEncoding=%d userInfo=%p>",
                        object_getClassName(self),
                        (void*)self,
                        _httpVersion,
                        _status,
                        (void*)_headers,
                        (void*)_contentFaults,
                        (void*)_contentData,
                        (int)_contentEncoding,
                        (void*)_userInfo];
  return description;
}

// it seems that in WO, this is a class method, which makes no sense
- (void) _redirectResponse:(NSString *) location contentString:(NSString *) content
{
  GSWResponse_appendContentString(self, content);
  [self setStatus:302];
  [self setHeader:location
           forKey:@"Location"];
  [self setHeader:@"YES"
           forKey:@"x-webobjects-refusing-redirection"];
}


//--------------------------------------------------------------------
//NDFN
-(BOOL)isFinalizeInContextHasBeenCalled
{
  return _isFinalizeInContextHasBeenCalled;
};


- (BOOL)_browserSupportsCompression:(GSWRequest *)aRequest
{
  NSString	*value;
  NSRange 	 range;

  if (aRequest && ((value = [aRequest headerForKey:GSWHTTPHeader_AcceptEncoding]))) {
    range = [value rangeOfString:@"gzip" options:0];

    if (range.length) {
      return YES;
    }
  }
  return NO;
}

-(void)_finalizeContentEncodingInContext:(GSWContext*)aContext
{
#ifdef HAVE_LIBZ
  NSUInteger dataLength=0;
  
  dataLength=[self _contentLength];
  
  if (dataLength>0) {
/*
 NSString * eTagString = [NSString stringWithFormat:@"%lx", 
                             (unsigned long) [_contentData hash]];
    
    [self setHeader:eTagString
             forKey:@"ETag"];
 */
  }
  
  // Now we see if we can gzip the content
  // it does not make sense to compress data less than 150 bytes.
  if ((dataLength > 150) && ([self _browserSupportsCompression:[aContext request]])) 
  {
    NSString* contentType=[self headerForKey:@"Content-Type"];
    NSString* contentEncoding=[self headerForKey:@"Content-Encoding"];
    
    if ((contentEncoding) || (!compressableContentTypesCache)) {
      return;
    }
    
    // only compress if we know it makes sense
    if ([compressableContentTypesCache containsObject:contentType])
    {
#ifdef DEBUG
      NSDate* compressStartDate=[NSDate date];
#endif
      NSData* content=[self content];
      NSData* compressedData=[content deflate];
      if (compressedData)
      {
#ifdef DEBUG
        NSDate* compressStopDate=[NSDate date];
        NSString* sizeInfoHeader=[NSString stringWithFormat:@"deflate from %d to %d in %0.3f s",
                                  dataLength,
                                  [compressedData length],
                                  [compressStopDate timeIntervalSinceDate:compressStartDate]];
        [self setHeader:sizeInfoHeader
                 forKey:@"deflate-info"];
#endif
        [self setContent:compressedData];
        dataLength=[self _contentLength];
        [self setHeader:@"gzip"
                 forKey:@"Content-Encoding"];
      }
    }
  }
#endif // HAVE_LIBZ
}
          
//--------------------------------------------------------------------
-(void)_finalizeInContext:(GSWContext*)aContext
{
  int dataLength=0;
  NSString* dataLengthString=nil;
  NSData* content=nil;


  NSAssert(!_isFinalizeInContextHasBeenCalled,@"GSWResponse _finalizeInContext: already called");

  //TODOV: if !session in request and session created: no client cache
  if (![self _isClientCachingDisabled] && [aContext hasSession] && ![aContext _requestSessionID])
    [self disableClientCaching];

  // where does this come from?
  //[self _resolveContentFaultsInContext:aContext];

  // Finalize cookies
  [self _finalizeCookiesInContext:aContext];

  // Add load info to headers
  if (![self headersForKey:GSWHTTPHeader_LoadAverage])
    [self setHeader:GSWIntToNSString([GSWApp activeSessionsCount])
          forKey:GSWHTTPHeader_LoadAverage];

  // Add refusing new sessions info to headers
  if ([GSWApp isRefusingNewSessions]
      && ![self headersForKey:GSWHTTPHeader_RefuseSessions])
    [self setHeader:GSWIntToNSString((int)[GSWApp _refuseNewSessionsTimeInterval])
          forKey:GSWHTTPHeader_RefuseSessions];

  [self _finalizeContentEncodingInContext:aContext];

  content=[self content];
  dataLength=[self _contentLength];

  dataLengthString=GSWIntToNSString(dataLength);

  [self setHeader:dataLengthString
		forKey:GSWHTTPHeader_ContentLength];

  _isFinalizeInContextHasBeenCalled=YES;

};

//--------------------------------------------------------------------
// called _appendTagAttributeAndValue in WO 5
-(void)_appendTagAttribute:(NSString*)attributeName
                     value:(id)value
escapingHTMLAttributeValue:(BOOL)escape
{

  GSWResponse_appendContentCharacter(self,' ');
  GSWResponse_appendContentAsciiString(self,attributeName);
  GSWResponse_appendContentAsciiString(self,@"=\"");

  if (escape) {
    GSWResponse_appendContentString(self,
                                         GSWResponse_stringByEscapingHTMLAttributeValue(self,value));
  } else {
    GSWResponse_appendContentString(self,value);
  }
  
  GSWResponse_appendContentCharacter(self,'"');
  
};

-(void)_resolveContentFaultsInContext:(GSWContext*)aContext
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(void)_appendContentFault:(id)unknown
{
  [self notImplemented: _cmd];	//TODOFN
};

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

//--------------------------------------------------------------------
-(BOOL)_responseIsEqual:(GSWResponse*)aResponse
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(GSWResponse*)generateResponse
{
  return self;
};

-(void)setContentStreamFileHandle:(NSFileHandle*)fileHandle
                       bufferSize:(unsigned int)bufferSize
                           length:(unsigned long)length
{
  ASSIGN(_contentStreamFileHandle,fileHandle);
  if (bufferSize==0)
    _contentStreamBufferSize=4096;
  else
    _contentStreamBufferSize=bufferSize;
  _contentStreamBufferLength=length;
};

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
  GSWResponse* aResponse=nil;
  NSString* httpVersion=nil;
  aResponse=[GSWApp createResponseInContext:aContext];
  if (aResponse)
    {
      NSString* responseString=nil;
      if (aContext && [aContext request])
	aRequest=[aContext request];
      httpVersion=[aRequest httpVersion];
      if (httpVersion)
	[aResponse setHTTPVersion:httpVersion];
      [aResponse setHeader:@"text/html"
                forKey:@"Content-Type"];
      [aContext _setResponse:aResponse];
      responseString=[NSString stringWithFormat:@"<HTML>\n<TITLE>GNUstepWeb Error</TITLE>\n</HEAD>\n<BODY bgcolor=\"white\">\n<CENTER>\n%@\n</CENTER>\n</BODY>\n</HTML>\n",
                               GSWResponse_stringByEscapingHTMLString(aResponse,aMessage)];
      GSWResponse_appendContentString(aResponse,responseString);
      if (forceFinalize)
        [aResponse forceFinalizeInContext];
    };
  return aResponse;
};

//--------------------------------------------------------------------
//
//Refuse Response
+(GSWResponse*)generateRefusingResponseInContext:(GSWContext*)aContext
                                      forRequest:(GSWRequest*)aRequest
{
  GSWResponse* response=nil;
  NSString* httpVersion=nil;
  response=[GSWApp createResponseInContext:aContext];
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

      locationURLString = [NSString stringWithFormat:@"%@/%@.gswa",
                                    [aRequest adaptorPrefix], 
                                    [aRequest applicationName]];

      message = [NSString stringWithFormat:@"Sorry, your request could not immediately be processed. Please try this URL: <a href=\"%@\">%@</a>\nConnection closed by foreign host.", 
                          locationURLString, 
                          locationURLString];

      responseString=[NSString stringWithFormat:@"<HTML>\n<TITLE>GNUstepWeb</TITLE>\n</HEAD>\n<BODY bgcolor=\"white\">\n<CENTER>\n%@\n</CENTER>\n</BODY>\n</HTML>\n",
                               message];
      
      [response _generateRedirectResponseWithMessage:responseString
                location:locationURLString
                isDefinitive:NO];
      
      if (aContext) 
        {
          [aContext _setResponse:response];
        }
    };
  return response;
};

//--------------------------------------------------------------------
-(void)_generateRedirectResponseWithMessage:(NSString*)message
                                   location:(NSString*)location
                               isDefinitive:(BOOL)isDefinitive
{
  if (message)
    {
      GSWResponse_appendContentString(self,message);
      
      [self setHeader:GSWIntToNSString([[self content] length])
            forKey:@"content-length"];
    };
  if (isDefinitive)
    [self setStatus:301]; // redirect definitive !
  else
    [self setStatus:302]; // redirect temporary !
  [self setHeader:location
        forKey:@"Location"];
  [self setHeader:@"text/html" 
        forKey:@"Content-Type"];
  [self setHeader:@"YES"
        forKey:@"x-gsweb-refusing-redirection"];
}

//--------------------------------------------------------------------
//
//Redirect Response
+(GSWResponse*)generateRedirectResponseWithMessage:(NSString*)message
                                          location:(NSString*)location
                                      isDefinitive:(BOOL)isDefinitive
                                         inContext:(GSWContext*)aContext
                                        forRequest:(GSWRequest*)aRequest
{
  GSWResponse* response=nil;
  NSString* httpVersion=nil;
  response=[GSWApp createResponseInContext:aContext];
  if (response)
    {
      if (aContext && [aContext request]) 
        {
          aRequest=[aContext request];
        }
      httpVersion=[aRequest httpVersion];
      if (httpVersion) 
        {
          [response setHTTPVersion:httpVersion];
        }

      [response _generateRedirectResponseWithMessage:message
                location:location
                isDefinitive:isDefinitive];
      
      if (aContext)
        {
          [aContext _setResponse:response];
        }
    };
  return response;
};

//--------------------------------------------------------------------
//
//Redirect Response
+(GSWResponse*)generateRedirectResponseWithMessage:(NSString*)message
                                          location:(NSString*)location
                                      isDefinitive:(BOOL)isDefinitive
{
  GSWResponse* response=nil;
  response=[self generateRedirectResponseWithMessage:message
                 location:location
                 isDefinitive:isDefinitive
                 inContext:nil
                 forRequest:nil];
  return response;
};

//--------------------------------------------------------------------
+(GSWResponse*)generateRedirectDefaultResponseWithLocation:(NSString*)location
                                              isDefinitive:(BOOL)isDefinitive
                                                 inContext:(GSWContext*)aContext
                                                forRequest:(GSWRequest*)aRequest
{
  NSString* message=nil;
  GSWResponse* response=nil;
  message=[NSString stringWithFormat:@"This page has been moved%s to <a HREF=\"%@\">%@</a>",
                    (isDefinitive ? "" : " temporarily"),
                    location,
                    location];
  response=[self generateRedirectResponseWithMessage:message
                 location:location
                 isDefinitive:isDefinitive
                 inContext:aContext
                 forRequest:aRequest];
  return response;
};

//--------------------------------------------------------------------
+(GSWResponse*)generateRedirectDefaultResponseWithLocation:(NSString*)location
                                              isDefinitive:(BOOL)isDefinitive
{
  GSWResponse* response=nil;
  response=[self generateRedirectDefaultResponseWithLocation:location
                 isDefinitive:isDefinitive
                 inContext:nil
                 forRequest:nil];
  return response;
}

@end


