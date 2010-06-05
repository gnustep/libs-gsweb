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
    };
};

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
  DESTROY(_acceptedEncodings);
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
      ASSIGNCOPY(clone->_acceptedEncodings,_acceptedEncodings);
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
-(NSArray*)acceptedEncodings
{
  return _acceptedEncodings;
};

//--------------------------------------------------------------------
-(void)setAcceptedEncodings:(NSArray*)acceptedEncodings
{
  ASSIGN(_acceptedEncodings,acceptedEncodings);
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
            forKey:@"date"];
      [self setHeader:disabledCacheDateString
            forKey:@"expires"];
      [self setHeader:@"no-cache"
            forKey:@"pragma"];
      
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
-(void)_finalizeContentEncodingInContext:(GSWContext*)aContext
{
#ifdef HAVE_LIBZ
  int dataLength=0;

  dataLength=[self _contentLength];
  NSDebugMLog(@"dataLength=%d",dataLength);
  // Now we see if we can gzip the content
  if (dataLength>1024) // min length: 1024
    {
      // we could do better by having parameters for types
      NSArray* appAcceptedContentEncodingArray=[GSWApplication acceptedContentEncodingArray];
      NSDebugMLog(@"appAcceptedContentEncodingArray=%@",appAcceptedContentEncodingArray);
      if ([appAcceptedContentEncodingArray count]>0)
        {
          NSString* contentType=[self headerForKey:@"content-type"];
          NSString* gzHeader=[self headerForKey:@"gzip"];

          if ([contentType isEqual:@"text/html"])
            {
              NSString* contentEncoding=[self headerForKey:@"content-encoding"];
              // we could do better by handling compress,...
              if (([contentEncoding length]==0 // Not already encoded
                  && [_acceptedEncodings containsObject:@"gzip"]
                  && [appAcceptedContentEncodingArray containsObject:@"gzip"]) 
                  && ((gzHeader == nil) || ([gzHeader isEqual:@"0"])))

                {
                  NSDate* compressStartDate=[NSDate date];
                  NSData* content=[self content];
                  NSData* compressedData=[content deflate];
                  NSDebugMLog(@"compressedData=%@",compressedData);
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
                            forKey:@"content-encoding"];
                    };
                };
            };
        };
    };
#endif
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

@end

//====================================================================
@implementation GSWResponse (GSWResponseB)
-(void)_resolveContentFaultsInContext:(GSWContext*)aContext
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(void)_appendContentFault:(id)unknown
{
  [self notImplemented: _cmd];	//TODOFN
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
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

@end
//====================================================================
@implementation GSWResponse (GSWActionResults)

//--------------------------------------------------------------------
-(GSWResponse*)generateResponse
{
  return self;
};

@end

//====================================================================
@implementation GSWResponse (Stream)
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
                forKey:@"content-type"];
      [aContext _setResponse:aResponse];
      responseString=[NSString stringWithFormat:@"<HTML>\n<TITLE>GNUstepWeb Error</TITLE>\n</HEAD>\n<BODY bgcolor=\"white\">\n<CENTER>\n%@\n</CENTER>\n</BODY>\n</HTML>\n",
                               GSWResponse_stringByEscapingHTMLString(aResponse,aMessage)];
      GSWResponse_appendContentString(aResponse,responseString);
      if (forceFinalize)
        [aResponse forceFinalizeInContext];
    };
  return aResponse;
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

@end

//====================================================================
@implementation GSWResponse (GSWResponseRedirected)

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
        forKey:@"content-type"];
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


