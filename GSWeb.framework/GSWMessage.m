/** GSWMessage.m - <title>GSWeb: Class GSWMessage</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

#include <GNUstepBase/Unicode.h>
#include "GSWeb.h"
#include "NSData+Compress.h"


static NSStringEncoding globalDefaultEncoding=GSUndefinedEncoding;
static NSString* globalDefaultURLEncoding=nil;

static SEL appendStringSel = NULL;
static SEL appendDataSel = NULL;

//====================================================================
#ifndef NO_GNUSTEP

@interface GSWMessage (GSWMessageCachePrivate)
-(void)_cacheAppendString:(NSString*)string;
-(void)_cacheAppendData:(NSData*)data;
-(void)_cacheAppendBytes:(const void*)aBuffer
                  length:(unsigned int)bufferSize;
@end

#endif

#define assertContentStringASImp();		\
	{ if (!_contentStringASImp) { 		\
		_contentStringASImp=[_contentString \
			methodForSelector:appendStringSel]; }; };

#define assertContentDataADImp();		\
	{ if (!_contentDataADImp) { 		\
		_contentDataADImp=[_contentData \
			methodForSelector:appendDataSel]; }; };

//====================================================================
@implementation GSWMessage

+ (void) initialize
{
  if (self == [GSWMessage class])
    {
      appendStringSel = @selector(appendString:);
      appendDataSel = @selector(appendData:);
      globalDefaultEncoding = WOStrictFlag 
	? NSISOLatin1StringEncoding : GetDefEncoding() ;
    };
};

//--------------------------------------------------------------------
//	init

-(id)init 
{
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      ASSIGN(_httpVersion,@"HTTP/1.0");
      _headers=[NSMutableDictionary new];
      _contentEncoding=[[self class] defaultEncoding];
      [self _initContentData];
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
//  GSWLogAssertGood(self);
//  NSDebugFLog(@"dealloc Message %p",self);
//  NSDebugFLog0(@"Release Message httpVersion");
  DESTROY(_httpVersion);
//  NSDebugFLog0(@"Release Message headers");
  DESTROY(_headers);
//  NSDebugFLog0(@"Release Message contentString");
  DESTROY(_contentString);
//  NSDebugFLog0(@"Release Message contentData");
  DESTROY(_contentData);
//  NSDebugFLog0(@"Release Message userInfo");
  DESTROY(_userInfo);
  //NSDebugFLog0(@"Release Message cookies");
  DESTROY(_cookies);
//  NSDebugFLog0(@"Release Message");
#ifndef NO_GNUSTEP
  DESTROY(_cachesStack);
#endif
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWMessage* clone = [[isa allocWithZone:zone] init];
  if (clone)
    {
      ASSIGNCOPY(clone->_httpVersion,_httpVersion);

      DESTROY(clone->_headers);
      clone->_headers=[_headers mutableCopyWithZone:zone];

      clone->_contentEncoding=_contentEncoding;
      ASSIGNCOPY(clone->_userInfo,_userInfo);
      ASSIGNCOPY(clone->_cookies,_cookies);

      DESTROY(clone->_contentString);
      clone->_contentString=[_contentString mutableCopyWithZone:zone];
      clone->_contentStringASImp=NULL;

      DESTROY(clone->_contentData);
      clone->_contentData=[_contentData mutableCopyWithZone:zone];
      clone->_contentDataADImp=NULL;

#ifndef NO_GNUSTEP
      DESTROY(clone->_cachesStack);
      clone->_cachesStack=[_cachesStack mutableCopyWithZone:zone];
#endif
    };
  return clone;
};

//--------------------------------------------------------------------
// Used in transactions
-(BOOL)isEqual:(id)anObject
{
  BOOL isEqual=NO;

  if (anObject==self)
    isEqual=YES;
  else if ([anObject isKindOfClass:[GSWMessage class]])
    {
      GSWMessage* aMessage=(GSWMessage*)anObject;
      if ((_headers == aMessage->_headers
           || [_headers isEqual:aMessage->_headers])
          && [_contentData isEqual:aMessage->_contentData]
          && [_contentString isEqual:aMessage->_contentString])
        isEqual=YES;
    };
          
  return isEqual;
}

//--------------------------------------------------------------------
//	setHTTPVersion:

//sets the http version (like @"HTTP/1.0"). 
-(void)setHTTPVersion:(NSString*)version
{
  ASSIGN(_httpVersion,version);
};

//--------------------------------------------------------------------
//	httpVersion

//return http version like @"HTTP/1.0"

-(NSString*)httpVersion
{
  return _httpVersion;
};

//--------------------------------------------------------------------
//	setUserInfo:

-(void)setUserInfo:(NSDictionary*)userInfo
{
  ASSIGN(_userInfo,userInfo);
};

//--------------------------------------------------------------------
//	userInfo

-(NSDictionary*)userInfo 
{
  return _userInfo;
};


//--------------------------------------------------------------------
//	setHeader:forKey:

// Should replace, not append. FIXME later
-(void)setHeader:(NSString*)header
          forKey:(NSString*)key
{
  //OK
  id object=nil;
  NSAssert(header,@"No header");
  NSAssert(key,@"No header key");
  object=[_headers objectForKey:key];
  if (object)
    [self setHeaders:[object arrayByAddingObject:header]
          forKey:key];
  else
    [self setHeaders:[NSArray arrayWithObject:header]
          forKey:key];
};

//--------------------------------------------------------------------
-(void)appendHeader:(NSString*)header
             forKey:(NSString*)key
{
  [self appendHeaders:[NSArray arrayWithObject:header]
        forKey:key];
}


//--------------------------------------------------------------------
//	setHeaders:forKey:

-(void)setHeaders:(NSArray*)headers
           forKey:(NSString*)key
{
  NSAssert(headers,@"No headers");
  NSAssert(key,@"No header key");

  NSDebugMLLog(@"GSWMessage",@"_headers=%@",_headers);

  if (!_headers)
    _headers=[NSMutableDictionary new];

  NSDebugMLLog(@"GSWMessage",@"key=%@ headers=%@",key,headers);

  [_headers setObject:headers
            forKey:key];
};


//--------------------------------------------------------------------
-(void)appendHeaders:(NSArray*)headers
              forKey:(NSString*)key
{
  id object=nil;
  NSAssert(headers,@"No headers");
  NSAssert(key,@"No header key");

  object=[_headers objectForKey:key];
  if (object)
    [self setHeaders:[object arrayByAddingObjectsFromArray:headers]
          forKey:key];
  else
    [self setHeaders:headers
          forKey:key];
};

//--------------------------------------------------------------------
//	setHeaders:
 
-(void)setHeaders:(NSDictionary*)headerDictionary
{
  NSDebugMLLog(@"GSWMessage",@"headerDictionary=%@",headerDictionary);

  NSDebugMLLog(@"GSWMessage",@"_headers=%@",_headers);

  if (!_headers && [headerDictionary count]>0)
    _headers=[NSMutableDictionary new];
  
  if (headerDictionary)
    {
      NSEnumerator* keyEnum=nil;
      id	    headerName=nil;
    
      keyEnum = [headerDictionary keyEnumerator];
      while ((headerName = [keyEnum nextObject]))
        {
          id value=[headerDictionary objectForKey:headerName];
          if (![value isKindOfClass:[NSArray class]])
            value=[NSArray arrayWithObject:value];
          [self setHeaders:value
                forKey:headerName];
 	};
    };

  NSDebugMLLog(@"GSWMessage",@"_headers=%@",_headers);
};
 
//--------------------------------------------------------------------
//	headers

-(NSMutableDictionary*)headers
{
  return _headers;
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
-(void)removeHeadersForKey:(NSString*)key
{
  [_headers removeObjectForKey:key];
}

//--------------------------------------------------------------------
-(void)_initContentData
{
  LOGObjectFnStart();

  DESTROY(_contentString);
  DESTROY(_contentData);

  _contentString=[NSMutableString new];
  _contentStringASImp=NULL;

  _contentData=[NSMutableData new];
  _contentDataADImp=NULL;

  LOGObjectFnStop();
};


//--------------------------------------------------------------------
/** Set content with contentData
**/
-(void)setContent:(NSData*)contentData
{
  LOGObjectFnStart();
  [self _initContentData];
  [self appendContentData:contentData];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** Set content with contentString
**/
-(void)setContentString:(NSString*)contentString
{
  LOGObjectFnStart();
  [self _initContentData];
  [self appendContentString:contentString];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	content

-(NSData*)content
{
  NSData* content=nil;
  LOGObjectFnStart();
  if ([_contentString length]>0)
    {
      NS_DURING
        {
          content=[_contentString dataUsingEncoding:[self contentEncoding]];
        }
      NS_HANDLER
        {
          //TODO
          [localException raise];
        }
      NS_ENDHANDLER;
    }
  else
    content=_contentData;
  LOGObjectFnStop();
  return content;
};

//--------------------------------------------------------------------
//	contentString

-(NSString*)contentString
{
  NSString* contentString=nil;
  LOGObjectFnStart();
  if ([_contentString length]>0)
    contentString=[NSString stringWithString:_contentString];
  else
    contentString=[[[NSString alloc]initWithData:_contentData
                                    encoding:[self contentEncoding]]
                    autorelease];
  LOGObjectFnStop();
  return contentString;
}

//--------------------------------------------------------------------
-(void)appendContentData:(NSData*)contentData
{
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"contentData:%@",contentData);
  if ([contentData length]>0) // is there something to append ?
    {
      if ([_contentString length]>0) // is actual content is string ?
        {
          // Convert contentData to append into string and append it to _contentString
          NSString* tmpString=nil;
          NSDebugMLog(@"Converting appending Data To String");
          tmpString=[[[NSString alloc]initWithData:contentData
                                      encoding:[self contentEncoding]]
                      autorelease];
          assertContentStringASImp();
          (*_contentStringASImp)(_contentString,appendStringSel,tmpString);

#ifndef NO_GNUSTEP
          if (_cachesStack)
            [self _cacheAppendString:tmpString];
#endif
        }
      else // No actual content or data one
        {
          if ([_contentData length]>0)
            {
              assertContentDataADImp();
              (*_contentDataADImp)(_contentData,appendDataSel,contentData);
            }
          else
            {
              _contentData = (NSMutableData*)[contentData mutableCopy];
              _contentDataADImp = NULL;
            };

#ifndef NO_GNUSTEP
          if (_cachesStack)
            [self _cacheAppendData:contentData];
#endif
        };
    };
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
-(void)_appendContentAsciiString:(NSString*)aString
{
  NSString* string=nil;

  LOGObjectFnStart();

  NSAssert2([_contentData length]==0,
            @"Try to append string but content is data. \nString: '%@'\nData: '%@'",
            string,
            [[[NSString alloc]initWithData:_contentData
                              encoding:[self contentEncoding]]
              autorelease]);

  NSDebugMLLog(@"low",@"aString:%@",aString);
  string=[NSString stringWithObject:aString];

  NSDebugMLLog(@"low",@"string:%@",string);
  assertContentStringASImp();
  (*_contentStringASImp)(_contentString,appendStringSel,string);

#ifndef NO_GNUSTEP
  if (_cachesStack)
    [self _cacheAppendString:string];
#endif

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	_appendContentCharacter:

-(void)_appendContentCharacter:(char)aChar
{
  NSString* string=nil;

  LOGObjectFnStart();

  NSDebugMLLog(@"low",@"aChar:%c",aChar);
  NSAssert2([_contentData length]==0,
            @"Try to append string but content is data. \naChar: '%c'\nData: '%@'",
            aChar,
            [[[NSString alloc]initWithData:_contentData
                              encoding:[self contentEncoding]]
              autorelease]);  

  string=[NSString stringWithCString:&aChar
                   length:1];

  assertContentStringASImp();
  (*_contentStringASImp)(_contentString,appendStringSel,string);

#ifndef NO_GNUSTEP
  if (_cachesStack)
    [self _cacheAppendString:string];
#endif

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendContentString:(NSString*)string
{
  LOGObjectFnStart();

  NSDebugMLLog(@"low",@"string:%@",string);
  NSAssert2([_contentData length]==0,
            @"Try to append string but content is data. \n"
	    @"String: '%@'\nData: '%@'",
            string,
            [[[NSString alloc]initWithData:_contentData
                              encoding:[self contentEncoding]]
              autorelease]);

  if (string)
    {
      assertContentStringASImp();
      (*_contentStringASImp)(_contentString,appendStringSel,string);

#ifndef NO_GNUSTEP
      if (_cachesStack)
        [self _cacheAppendString:string];
#endif
    };

  LOGObjectFnStop();
}

//--------------------------------------------------------------------
-(int)_contentLength
{
  int contentLength=[_contentString length];
  if (contentLength==0)
    contentLength=[_contentData length];
  return contentLength;
}

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
@implementation GSWMessage (GSWContentConveniences)

//--------------------------------------------------------------------
//	appendContentBytes:length:

-(void)appendContentBytes:(const void*)bytes
                   length:(unsigned)length
{
  LOGObjectFnStart();
  if (length>0)
    {
      [_contentData appendBytes:bytes
                    length:length];

#ifndef NO_GNUSTEP
      if (_cachesStack)
        [self _cacheAppendBytes:bytes
              length:length];
#endif
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendContentCharacter:

-(void)appendContentCharacter:(char)aChar
{
  LOGObjectFnStart();
/*  [self appendContentBytes:&aChar
        length:1];
*/
  [self _appendContentCharacter:aChar];
  LOGObjectFnStop();
};
/*
//--------------------------------------------------------------------
//	appendContentData:

-(void)appendContentData:(NSData*)dataObject
{
  const void* bytes=NULL;
  unsigned int length=0;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"response=%p dataObject:%@",self,dataObject);
  bytes=[dataObject bytes];
  length=[dataObject length];
  [self appendContentBytes:bytes
        length:length];
  LOGObjectFnStop();
};
*/
//--------------------------------------------------------------------
//	appendContentString:
/*
-(void)appendContentString:(NSString*)aString
{
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"response=%p contentEncoding=%d",self,(int)_contentEncoding);
  [self _appendContentString:aString];

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
               ([string isKindOfClass:[NSString class]] ? [string lossyCString] : "**Not a string**"),
               (int)_contentEncoding);
      NSDebugMLLog(@"low",@"newData=%@",newData);
      [_contentData appendData:newData];
    };

  LOGObjectFnStop();
};
*/

//--------------------------------------------------------------------
//	appendDebugCommentContentString:

-(void)appendDebugCommentContentString:(NSString*)aString
{
#ifndef NDEBUG
  if (GSDebugSet(@"debugComments") == YES)
    {
      [self appendContentString:@"\n<!-- "];
      [self appendContentString:aString];
      [self appendContentString:@" -->\n"];
    };
#endif
};

//--------------------------------------------------------------------
-(void)replaceContentString:(NSString*)replaceString
                   byString:(NSString*)byString
{
  LOGObjectFnStart();
  NSDebugMLog(@"replaceString=%@",replaceString);
  NSDebugMLog(@"byString=%@",byString);
  if ([replaceString length]>0) // is there something to replace ?
    {
      NSDebugMLog(@"[_contentString length]=%d",[_contentString length]);
      NSDebugMLog(@"[_contentData length]=%d",[_contentData length]);
      if ([_contentString length]>0) // is actual content is string ?
        {
          [_contentString replaceOccurrencesOfString:replaceString
                          withString:byString
                          options:0
                          range:NSMakeRange(0,[_contentString length])];
        }
      else // No actual content or data one
        {
          if ([_contentData length]>0)
            {
              // Convert to data
              NSData* tmpReplaceData=nil;
              NSData* tmpByData=nil;
              NSDebugMLog(@"Converting String To Data");
              tmpReplaceData=[replaceString dataUsingEncoding:[self contentEncoding]];
              tmpByData=[byString dataUsingEncoding:[self contentEncoding]];
              
              [_contentData replaceOccurrencesOfData:tmpReplaceData
                            withData:tmpByData
                            range:NSMakeRange(0,[_contentData length])];
            };
        };
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)replaceContentData:(NSData*)replaceData
                   byData:(NSData*)byData
{
  LOGObjectFnStart();
  if ([replaceData length]>0) // is there something to replace ?
    {
      NSDebugMLog(@"[_contentString length]=%d",[_contentString length]);
      NSDebugMLog(@"[_contentData length]=%d",[_contentData length]);
      if ([_contentString length]>0) // is actual content is string ?
        {
          // Convert to string
          NSString* tmpReplaceString=nil;
          NSString* tmpByString=nil;
          NSDebugMLog(@"Converting Data To String");
          tmpReplaceString=[[[NSString alloc]initWithData:replaceData
                                             encoding:[self contentEncoding]]
                             autorelease];
          tmpByString=[[[NSString alloc]initWithData:byData
                                        encoding:[self contentEncoding]]
                        autorelease];
          [_contentString replaceOccurrencesOfString:tmpReplaceString
                          withString:tmpByString
                          options:0
                          range:NSMakeRange(0,[_contentString length])];
        }
      else // No actual content or data one
        {
          if ([_contentData length]>0)
            {
              [_contentData replaceOccurrencesOfData:replaceData
                            withData:byData
                            range:NSMakeRange(0,[_contentData length])];
            };
        };
    };
  LOGObjectFnStop();
};

@end


//====================================================================
@implementation GSWMessage (GSWHTMLConveniences)

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
  NSString* string=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"aString=%@",aString);
  string=[NSString stringWithObject:aString];
  NSDebugMLLog(@"low",@"string=%@",string);
  [self appendContentString:[[self class]stringByEscapingHTMLString:string]];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendContentHTMLConvertString:(NSString*)aString
{
  NSString* string=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"aString=%@",aString);
  string=[NSString stringWithObject:aString];
  NSDebugMLLog(@"low",@"string=%@",string);
  [self appendContentString:[[self class]stringByConvertingToHTML:string]];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendContentHTMLEntitiesConvertString:(NSString*)aString
{
  NSString* string=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"aString=%@",aString);
  string=[NSString stringWithObject:aString];
  NSDebugMLLog(@"low",@"string=%@",string);
  [self appendContentString:[[self class]stringByConvertingToHTMLEntities:string]];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
+(NSString*)stringByEscapingHTMLString:(NSString*)aString
{
  NSString* string=[NSString stringWithObject:aString];
  NSDebugMLLog(@"low",@"aString=%@",aString);
  NSDebugMLLog(@"low",@"string=%@",string);
  return [string stringByEscapingHTMLString];
};

//--------------------------------------------------------------------
+(NSString*)stringByEscapingHTMLAttributeValue:(NSString*)aString
{
  NSString* string=[NSString stringWithObject:aString];
  NSDebugMLLog(@"low",@"aString=%@",aString);
  NSDebugMLLog(@"low",@"string=%@",string);
  return [string stringByEscapingHTMLAttributeValue];
};

//--------------------------------------------------------------------
+(NSString*)stringByConvertingToHTMLEntities:(NSString*)aString
{
  NSString* string=[NSString stringWithObject:aString];
  NSDebugMLLog(@"low",@"aString=%@",aString);
  NSDebugMLLog(@"low",@"string=%@",string);
  return [string stringByConvertingToHTMLEntities];
};

//--------------------------------------------------------------------
+(NSString*)stringByConvertingToHTML:(NSString*)aString
{
  NSString* string=[NSString stringWithObject:aString];
  NSDebugMLLog(@"low",@"aString=%@",aString);
  NSDebugMLLog(@"low",@"string=%@",string);
  return [string stringByConvertingToHTML];
};

@end

//====================================================================
@implementation GSWMessage (Cookies)

//--------------------------------------------------------------------
-(NSString*)_formattedCookiesString
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSMutableArray*)_initCookies
{
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
  cookies=[self _initCookies];
  if (cookie)
    [cookies addObject:cookie];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)removeCookie:(GSWCookie*)cookie
{
  NSMutableArray* cookies=nil;
  LOGObjectFnStart();
  cookies=[self _initCookies];
  if (cookie)
    [cookies removeObject:cookie];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSArray*)cookies
{
  NSMutableArray* cookies=[self _initCookies];
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
          NSAssert(cookieString,@"No cookie HeaderValue");
          [strings addObject:cookieString];
        };
    };
  return (strings ? [NSArray arrayWithArray:strings] : nil);
};

//--------------------------------------------------------------------
-(void)_finalizeCookiesInContext:(GSWContext*)aContext
{
  NSArray* cookieHeader=nil;
  NSArray* cookies=nil;
  NSString* cookiesKey=nil;
  BOOL isRequest=NO;
  
  isRequest=[self isKindOfClass:[GSWRequest class]];

  if (isRequest)
    cookiesKey=GSWHTTPHeader_Cookie;
  else
    cookiesKey=GSWHTTPHeader_SetCookie;

  cookieHeader=[self headersForKey:cookiesKey];
  if (cookieHeader)
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
            forKey:cookiesKey];
    };
};

@end



//====================================================================
@implementation GSWMessage (KeyValueCoding)

+(BOOL)canAccessFieldsDirectly
{
  return YES;
}

@end

//====================================================================
@implementation GSWMessage (GSWMessageDefaultEncoding)

//--------------------------------------------------------------------
+(void)setDefaultEncoding:(NSStringEncoding)encoding
{
  globalDefaultEncoding=encoding;
};

//--------------------------------------------------------------------
+(NSStringEncoding)defaultEncoding
{
  return globalDefaultEncoding;
};

//--------------------------------------------------------------------
-(void)setDefaultURLEncoding:(NSString*)enc
{
  ASSIGN(globalDefaultURLEncoding,enc);
}

//--------------------------------------------------------------------
-(NSString*)defaultURLEncoding
{
  return globalDefaultURLEncoding;
}


@end


//====================================================================
#ifndef NO_GNUSTEP

@implementation GSWMessage (GSWMessageCache)

//--------------------------------------------------------------------
-(int)startCache
{
  int index=0;
  LOGObjectFnStart();

  if (!_cachesStack)
    {
      _cachesStack=[NSMutableArray new];
    };
  if (_contentData)
    [_cachesStack addObject:[NSMutableData data]];
  else
    [_cachesStack addObject:[NSMutableString string]];

  index=[_cachesStack count]-1;

  LOGObjectFnStop();
  return index;
};

-(id)appendCacheData:(id)fromCacheData
         toCacheData:(id)toCacheData
{
  LOGObjectFnStart();
  if ([fromCacheData length]>0)
    {
      if ([fromCacheData isKindOfClass:[NSString class]])
        {
          if ([toCacheData isKindOfClass:[NSString class]]) // String+String
            {
              [toCacheData appendString:(NSString*)fromCacheData];
            }
          else if ([toCacheData length]==0)
            { // Empty Data+String
              toCacheData=[NSMutableString stringWithString:fromCacheData];
            }
          else                           
            {
              // Empty String
              NSAssert(NO,
                       @"Try to append cache string to cache");
            };
        }
      else // ??+Data
        {
          if ([toCacheData isKindOfClass:[NSData class]]) // Data+Data
            {
              [toCacheData appendData:fromCacheData];
            }
          else // String+Data
            {
              // Convert fromCacheData data to append into toCacheData string
              NSString* fromCacheDataString=nil;
              NSDebugMLog(@"Converting appending Data To String");
              fromCacheDataString=[[[NSString alloc]initWithData:(NSData*)fromCacheData
                                          encoding:[self contentEncoding]]
                          autorelease];
              [toCacheData appendString:fromCacheDataString];
            };
        };
    };
  LOGObjectFnStop();
  return toCacheData;
}
//--------------------------------------------------------------------
-(id)stopCacheOfIndex:(int)cacheIndex
{
  id cachedData=nil;
  int cacheStackCount=0;

  LOGObjectFnStart();

  NSDebugMLLog(@"GSWCacheElement",@"cacheIndex=%d",cacheIndex);

  cacheStackCount=[_cachesStack count];

  NSDebugMLLog(@"GSWCacheElement",@"cacheStackCount=%d",cacheStackCount);

  if (cacheIndex<cacheStackCount)
    {
      cachedData=[_cachesStack objectAtIndex:cacheIndex];
      AUTORELEASE(RETAIN(cachedData));

      NSDebugMLLog(@"GSWCacheElement",@"cachedData=%@",cachedData);

      // Last one ? (normal case)
      if (cacheIndex==(cacheStackCount-1))
        {
          [_cachesStack removeObjectAtIndex:cacheIndex];          
        }
      else
        {
          // Strange case: may be an exception which avoided component to retrieve their cache ?
          cacheIndex++;
          while(cacheIndex<cacheStackCount)
            {
              id tmp=[_cachesStack objectAtIndex:cacheIndex];
              NSDebugMLLog(@"GSWCacheElement",@"tmp=%@",tmp);
              cachedData=[self appendCacheData:tmp
                               toCacheData:cachedData];
              [_cachesStack removeObjectAtIndex:cacheIndex];
            };
        };
      cacheStackCount=[_cachesStack count];

      //Add cachedData to previous cache item data
      if (cacheStackCount>0 && [cachedData length]>0)
        {
          id previous=[_cachesStack objectAtIndex:cacheStackCount-1];
          id newPrevious=[self appendCacheData:cachedData
                               toCacheData:previous];
          if (newPrevious!=previous)
            [_cachesStack replaceObjectAtIndex:cacheStackCount-1
                          withObject:newPrevious];
        };
    };

  NSDebugMLLog(@"GSWCacheElement",@"cachedData=%@",cachedData);

  LOGObjectFnStop();
  
  return cachedData;
}

@end

@implementation GSWMessage (GSWMessageCachePrivate)

//--------------------------------------------------------------------
-(void)_cacheAppendString:(NSString*)string
{
  LOGObjectFnStart();

  if ([string length]>0)
    {
      int index=0;
      index=[_cachesStack count]-1;
      if (index>=0)
        {
          id cachedData=[_cachesStack  objectAtIndex:index];
          if ([cachedData isKindOfClass:[NSData class]])
            {
              if ([cachedData length]>0)
                {
                  NSAssert2(NO,
                            @"Try to append string to cache but content is data. \nString: '%@'\nData: '%@'",
                            string,
                            [[[NSString alloc]initWithData:_contentData
                                              encoding:[self contentEncoding]]
                              autorelease]);
                }
              else
                [_cachesStack replaceObjectAtIndex:index
                              withObject:[NSMutableString stringWithString:string]];
            }
          else
            [cachedData appendString:string];
        };
    };
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
-(void)_cacheAppendData:(NSData*)data
{
  LOGObjectFnStart();

  if ([data length]>0)
    {
      int index=0;
      index=[_cachesStack count]-1;
      if (index>=0)
        {
          id cachedData=[_cachesStack  objectAtIndex:index];
          if ([cachedData isKindOfClass:[NSString class]])
            {
              if ([cachedData length]>0)
                {
                  // Convert contentData to append into string and append it to _contentString
                  NSString* tmpString=nil;
                  NSDebugMLog(@"Converting appending Data To String");
                  tmpString=[[[NSString alloc]initWithData:data
                                              encoding:[self contentEncoding]]
                              autorelease];
                  [cachedData appendString:tmpString];
                }
              else
                [_cachesStack  replaceObjectAtIndex:index
                               withObject:[NSMutableData dataWithData:data]];
            }
          else
            [cachedData appendData:data];
        };
    };
  
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
-(void)_cacheAppendBytes:(const void*)aBuffer
              length: (unsigned int)bufferSize
{
  LOGObjectFnStart();
  if (bufferSize>0)
    {
      int index=0;
      index=[_cachesStack count]-1;
      if (index>=0)
        {
          id cachedData=[_cachesStack  objectAtIndex:index];
          if ([cachedData isKindOfClass:[NSString class]])
            {
              if ([cachedData length]>0)
                {
                  // Convert contentData to append into string and append it to _contentString
                  NSString* tmpString=nil;
                  NSData* tmpData=nil;
                  NSDebugMLog(@"Converting appending Data To String");
                  tmpData=[NSData dataWithBytes:aBuffer
                                  length:bufferSize];
                  tmpString=[[[NSString alloc]initWithData:tmpData
                                              encoding:[self contentEncoding]]
                              autorelease];
                  [cachedData appendString:tmpString];
                }
              else
                [_cachesStack  replaceObjectAtIndex:index
                               withObject:[NSMutableData dataWithBytes:aBuffer
                                                         length:bufferSize]];
            }
          else
            [cachedData appendBytes:aBuffer
                        length:bufferSize];
        };
    };
  LOGObjectFnStop();
};
@end

#endif
