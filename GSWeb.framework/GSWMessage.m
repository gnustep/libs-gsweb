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

#define GSWMESSGAEDATACHESIZE 128
static id GSWMessageDataCache[GSWMESSGAEDATACHESIZE];


#define DEF_CONTENT_SIZE 81920

//====================================================================

#define assertContentDataADImp();		\
	{ if (!_contentDataADImp) { 		\
		_contentDataADImp=[_contentData \
			methodForSelector:appendDataSel]; }; };

//====================================================================

void initGSWMessageDataCache(void)
{
  int i=0;
  char cstring[2];
  NSString *myNSString;
  NSData   *myData;
  
  cstring[1] = 0;
  
  for (i=0;i<GSWMESSGAEDATACHESIZE;i++) {   
    cstring[0] = i;
    myNSString = [NSString stringWithCString:&cstring
                                      length:1];
      myData = [myNSString dataUsingEncoding:NSASCIIStringEncoding
                        allowLossyConversion:YES];
      [myData retain];
    GSWMessageDataCache[i] = myData;
  }
}

@implementation GSWMessage

static __inline__ NSMutableData *_checkBody(GSWMessage *self) {
  if (self->_contentData == nil) {
    self->_contentData = [[NSMutableData alloc] initWithCapacity:DEF_CONTENT_SIZE];
  }
  if (!self->_contentDataADImp) { 		
		self->_contentDataADImp=[self->_contentData methodForSelector:appendDataSel]; 
		}
  return self->_contentData;
}

+ (void) initialize
{
  if (self == [GSWMessage class])
    {
      appendStringSel = @selector(appendString:);
      appendDataSel = @selector(appendData:);
      globalDefaultEncoding = WOStrictFlag ? NSISOLatin1StringEncoding : GetDefEncoding() ;
    	initGSWMessageDataCache();
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
      _checkBody(self);
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
//  DESTROY(_contentString);
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

//      DESTROY(clone->_contentString);
//      clone->_contentString=[_contentString mutableCopyWithZone:zone];
//      clone->_contentStringASImp=NULL;

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
          && [_contentData isEqual:aMessage->_contentData])
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
/** Set content with contentData
**/
-(void)setContent:(NSData*)contentData
{
  LOGObjectFnStart();
  [_contentData release];
  _contentData = nil;
  [self appendContentData:contentData];
  LOGObjectFnStop();
};
//--------------------------------------------------------------------
//	content
// DW
-(NSData*)content
{
  return _contentData;
};

//--------------------------------------------------------------------
// DW
-(void)appendContentData:(NSData*)contentData
{
  if (contentData == nil) {
    return;
  }
  
  _checkBody(self);
  (*_contentDataADImp)(_contentData,appendDataSel,contentData);
}

//--------------------------------------------------------------------
// DW
- (void)appendContentString:(NSString *)aValue 
{
  NSData *myData = nil;
  
  // checking [aValue length] takes too long!  
  if (!aValue) {
    return;
  }
  
  myData = [aValue dataUsingEncoding:_contentEncoding
                allowLossyConversion:NO];
                
  if (!myData) {
    NSLog(aValue);
    [NSException raise:NSInvalidArgumentException 
    format:@"%s: could not convert '%s' non-lossy to encoding %i",
    __PRETTY_FUNCTION__, [aValue lossyCString],_contentEncoding];  
  }

  _checkBody(self);
  (*_contentDataADImp)(_contentData,appendDataSel,myData);

}

-(void)_appendContentAsciiString:(NSString*) aValue
{
  NSData *myData = nil;
  char   *lossyCString = NULL;
  int    length = 0;
  int    i,ch;
  
  // checking [aValue length] takes too long!  
  if (!aValue) {
    return;
  }
  
  lossyCString = [aValue lossyCString];
  length = strlen(lossyCString);

  _checkBody(self);
  
  for (i=0; i<length;i++) {
    ch = lossyCString[i];
    myData=GSWMessageDataCache[ch];
    (*_contentDataADImp)(_contentData,appendDataSel,myData);
  }
}
//--------------------------------------------------------------------
-(int)_contentLength
{
  return [_contentData length];
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
  if ((length>0) && (bytes != NULL))
    {
      [_contentData appendBytes:bytes
                    length:length];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendContentCharacter:
// append one ASCII char
-(void)appendContentCharacter:(char)aChar
{
  NSString * string = nil;
  NSData *myData = nil;
  int i = aChar;

  LOGObjectFnStart();
  
  myData=GSWMessageDataCache[i];
  
  if (!myData) {
    string=[NSString stringWithCString:&aChar
                                length:1];
    if (string) {
      [self appendContentString:string];
    }
  } else {
     _checkBody(self);
     (*_contentDataADImp)(_contentData,appendDataSel,myData);
  }

  LOGObjectFnStop();
};

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
