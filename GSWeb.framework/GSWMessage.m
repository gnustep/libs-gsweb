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

static SEL appendDataSel = NULL;

static SEL contentEncodingSEL = NULL;
static SEL contentSEL = NULL;
static SEL contentStringSEL = NULL;

static SEL appendContentAsciiStringSEL = NULL;
static SEL appendContentCharacterSEL = NULL;

static SEL appendContentStringSEL = NULL;
static SEL appendContentDataSEL = NULL;

static SEL appendContentBytesSEL = NULL;
static SEL appendDebugCommentContentStringSEL = NULL;
static SEL replaceContentDataByDataSEL = NULL;

static SEL appendContentHTMLStringSEL = NULL;
static SEL appendContentHTMLAttributeValueSEL = NULL;
static SEL appendContentHTMLConvertStringSEL = NULL;
static SEL appendContentHTMLEntitiesConvertStringSEL = NULL;

static SEL stringByEscapingHTMLStringSEL = NULL;
static SEL stringByEscapingHTMLAttributeValueSEL = NULL;
static SEL stringByConvertingToHTMLEntitiesSEL = NULL;
static SEL stringByConvertingToHTMLSEL = NULL;


//====================================================================
/** functions to accelerate calls of frequently used GSWMessage methods **/

//--------------------------------------------------------------------
NSStringEncoding GSWMessage_contentEncoding(GSWMessage* aMessage)
{
  if (aMessage)
    {
      return (*(aMessage->_selfMsgIMPs._contentEncodingIMP))
        (aMessage,contentEncodingSEL);
    }
  else
    return (NSStringEncoding)0;
}

//--------------------------------------------------------------------
NSData* GSWMessage_content(GSWMessage* aMessage)
{
  if (aMessage)
    {
      return (*(aMessage->_selfMsgIMPs._contentIMP))
        (aMessage,contentSEL);
    }
  else
    return nil;
}

//--------------------------------------------------------------------
NSString* GSWMessage_contentString(GSWMessage* aMessage)
{
  if (aMessage)
    {
      return (*(aMessage->_selfMsgIMPs._contentStringIMP))
        (aMessage,contentStringSEL);
    }
  else
    return nil;
}

//--------------------------------------------------------------------
void GSWMessage_appendContentAsciiString(GSWMessage* aMessage,NSString* aString)
{
  if (aMessage)
    {
      (*(aMessage->_selfMsgIMPs._appendContentAsciiStringIMP))
        (aMessage,appendContentAsciiStringSEL,aString);
    };
}

//--------------------------------------------------------------------
void GSWMessage_appendContentCharacter(GSWMessage* aMessage,char aChar)
{
  if (aMessage)
    {
      (*(aMessage->_selfMsgIMPs._appendContentCharacterIMP))
        (aMessage,appendContentCharacterSEL,aChar);
    };
}

//--------------------------------------------------------------------
void GSWMessage_appendContentString(GSWMessage* aMessage,NSString* aString)
{
  if (aMessage)
    {
      (*(aMessage->_selfMsgIMPs._appendContentStringIMP))
        (aMessage,appendContentStringSEL,aString);
    };
}

//--------------------------------------------------------------------
void GSWMessage_appendContentData(GSWMessage* aMessage,NSData* contentData)
{
  if (aMessage)
    {
      (*(aMessage->_selfMsgIMPs._appendContentDataIMP))
        (aMessage,appendContentDataSEL,contentData);
    };
}

//--------------------------------------------------------------------
void GSWMessage_appendContentBytes(GSWMessage* aMessage,const void* contentsBytes,unsigned length)
{
  if (aMessage)
    {
      (*(aMessage->_selfMsgIMPs._appendContentBytesIMP))
        (aMessage,appendContentBytesSEL,contentsBytes,length);
    };
}

//--------------------------------------------------------------------
void GSWMessage_appendDebugCommentContentString(GSWMessage* aMessage,NSString* aString)
{
  if (aMessage)
    {
      (*(aMessage->_selfMsgIMPs._appendDebugCommentContentStringIMP))
        (aMessage,appendDebugCommentContentStringSEL,aString);
    };
}

//--------------------------------------------------------------------
void GSWMessage_replaceContentDataByData(GSWMessage* aMessage,NSData* replaceData,NSData* byData)
{
  if (aMessage)
    {
      (*(aMessage->_selfMsgIMPs._replaceContentDataByDataIMP))
        (aMessage,replaceContentDataByDataSEL,replaceData,byData);
    };
}

//--------------------------------------------------------------------
void GSWMessage_appendContentHTMLString(GSWMessage* aMessage,NSString* aString)
{
  if (aMessage)
    {
      (*(aMessage->_selfMsgIMPs._appendContentHTMLStringIMP))
        (aMessage,appendContentHTMLStringSEL,aString);
    };
}

//--------------------------------------------------------------------
void GSWMessage_appendContentHTMLAttributeValue(GSWMessage* aMessage,NSString* aString)
{
  if (aMessage)
    {
      (*(aMessage->_selfMsgIMPs._appendContentHTMLAttributeValueIMP))
        (aMessage,appendContentHTMLAttributeValueSEL,aString);
    };
}

//--------------------------------------------------------------------
void GSWMessage_appendContentHTMLConvertString(GSWMessage* aMessage,NSString* aString)
{
  if (aMessage)
    {
      (*(aMessage->_selfMsgIMPs._appendContentHTMLConvertStringIMP))
        (aMessage,appendContentHTMLConvertStringSEL,aString);
    };
}

//--------------------------------------------------------------------
void GSWMessage_appendContentHTMLEntitiesConvertString(GSWMessage* aMessage,NSString* aString)
{
  if (aMessage)
    {
      (*(aMessage->_selfMsgIMPs._appendContentHTMLEntitiesConvertStringIMP))
        (aMessage,appendContentHTMLEntitiesConvertStringSEL,aString);
    };
}

//--------------------------------------------------------------------
NSString* GSWMessage_stringByEscapingHTMLString(GSWMessage* aMessage,NSString* aString)
{
  if (aMessage)
    {
      return (*(aMessage->_selfMsgIMPs._stringByEscapingHTMLStringIMP))
        (object_get_class(aMessage),stringByEscapingHTMLStringSEL,aString);
    }
  else 
    return nil;
};

//--------------------------------------------------------------------
NSString* GSWMessage_stringByEscapingHTMLAttributeValue(GSWMessage* aMessage,NSString* aString)
{
  if (aMessage)
    {
      return (*(aMessage->_selfMsgIMPs._stringByEscapingHTMLAttributeValueIMP))
        (object_get_class(aMessage),stringByEscapingHTMLAttributeValueSEL,aString);
    }
  else 
    return nil;
};

//--------------------------------------------------------------------
NSString* GSWMessage_stringByConvertingToHTMLEntities(GSWMessage* aMessage,NSString* aString)
{
  if (aMessage)
    {
      return (*(aMessage->_selfMsgIMPs._stringByConvertingToHTMLEntitiesIMP))
        (object_get_class(aMessage),stringByConvertingToHTMLEntitiesSEL,aString);
    }
  else 
    return nil;
};

//--------------------------------------------------------------------
NSString* GSWMessage_stringByConvertingToHTML(GSWMessage* aMessage,NSString* aString)
{
  if (aMessage)
    {
      return (*(aMessage->_selfMsgIMPs._stringByConvertingToHTMLIMP))
        (object_get_class(aMessage),stringByConvertingToHTMLSEL,aString);
    }
  else 
    return nil;
};


// Site size of Ascii characters to data cache
#define GSWMESSGAEDATACHESIZE 128
static id GSWMessageDataCache[GSWMESSGAEDATACHESIZE];

// Default data content size
#define DEF_CONTENT_SIZE 81920

//====================================================================
#ifndef NO_GNUSTEP

@interface GSWMessage (GSWMessageCachePrivate)
-(void)_cacheAppendData:(NSData*)data;
-(void)_cacheAppendBytes:(const void*)aBuffer
                  length:(unsigned int)bufferSize;
@end

#endif

//====================================================================
#define assertContentDataADImp();		\
	{ if (!_contentDataADImp) { 		\
		_contentDataADImp=[_contentData \
			methodForSelector:appendDataSel]; }; };

#define assertCurrentCacheDataADImp();		\
	{ if (!_currentCacheDataADImp) { 		\
		_currentCacheDataADImp=[_currentCacheData \
			methodForSelector:appendDataSel]; }; };

//====================================================================

// Initialize Ascii string to data cache
void initGSWMessageDataCache(void)
{
  int i=0;
  char cstring[2];
  NSString *myNSString;
  NSData   *myData;
  
  cstring[1] = 0;
  
  for (i=0;i<GSWMESSGAEDATACHESIZE;i++)
    {
      cstring[0] = (char)i;
      myNSString = [NSString stringWithCString:cstring
                             length:1];
      myData = [myNSString dataUsingEncoding:NSASCIIStringEncoding
                           allowLossyConversion:YES];
      [myData retain];
      GSWMessageDataCache[i] = myData;
    };
}


//====================================================================
/** Fill impsPtr structure with IMPs for message **/
void GetGSWMessageIMPs(GSWMessageIMPs* impsPtr,GSWMessage* message)
{
  memset(impsPtr,0,sizeof(GSWMessageIMPs));

  NSCAssert(message,@"No message");

  Class messageClass=object_get_class(message);

  NSCAssert(contentEncodingSEL,@"No contentEncodingSEL on GetGSWMessageIMPs");

  impsPtr->_contentEncodingIMP = 
    (GSWIMP_STRING_ENCODING)[message methodForSelector:contentEncodingSEL];
  
  impsPtr->_contentIMP = 
    [message methodForSelector:contentSEL];
  
  impsPtr->_contentStringIMP = 
    [message methodForSelector:contentStringSEL];
  
  impsPtr->_appendContentAsciiStringIMP = 
    [message methodForSelector:appendContentAsciiStringSEL];
  
  impsPtr->_appendContentCharacterIMP = 
    [message methodForSelector:appendContentCharacterSEL];
  
  impsPtr->_appendContentDataIMP = 
    [message methodForSelector:appendContentDataSEL];
  
  impsPtr->_appendContentStringIMP = 
    [message methodForSelector:appendContentStringSEL];
  
  impsPtr->_appendContentBytesIMP = 
    [message methodForSelector:appendContentBytesSEL];
  
  impsPtr->_appendDebugCommentContentStringIMP = 
    [message methodForSelector:appendDebugCommentContentStringSEL];
  
  impsPtr->_replaceContentDataByDataIMP = 
    [message methodForSelector:replaceContentDataByDataSEL];
  
  impsPtr->_appendContentHTMLStringIMP = 
    [message methodForSelector:appendContentHTMLStringSEL];
  
  impsPtr->_appendContentHTMLAttributeValueIMP = 
    [message methodForSelector:appendContentHTMLAttributeValueSEL];
  
  impsPtr->_appendContentHTMLConvertStringIMP = 
    [message methodForSelector:appendContentHTMLConvertStringSEL];
  
  impsPtr->_appendContentHTMLEntitiesConvertStringIMP = 
    [message methodForSelector:appendContentHTMLEntitiesConvertStringSEL];
  
  impsPtr->_stringByEscapingHTMLStringIMP = 
    [messageClass methodForSelector:stringByEscapingHTMLStringSEL];
  NSCAssert(impsPtr->_stringByEscapingHTMLStringIMP,@"No stringByEscapingHTMLStringIMP");
  
  impsPtr->_stringByEscapingHTMLAttributeValueIMP = 
    [messageClass methodForSelector:stringByEscapingHTMLAttributeValueSEL];
  NSCAssert(impsPtr->_stringByEscapingHTMLAttributeValueIMP,@"No stringByEscapingHTMLAttributeValueIMP");
  
  impsPtr->_stringByConvertingToHTMLEntitiesIMP = 
    [messageClass methodForSelector:stringByConvertingToHTMLEntitiesSEL];
  NSCAssert(impsPtr->_stringByConvertingToHTMLEntitiesIMP,@"No stringByConvertingToHTMLEntitiesIMP");
  
  impsPtr->_stringByConvertingToHTMLIMP = 
    [messageClass methodForSelector:stringByConvertingToHTMLSEL];
  NSCAssert(impsPtr->_stringByConvertingToHTMLIMP,@"No stringByConvertingToHTMLIMP");
};


//====================================================================
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

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWMessage class])
    {
      appendDataSel = @selector(appendData:);
      NSAssert(appendDataSel,@"No appendDataSel");

      contentEncodingSEL = @selector(contentEncoding);
      NSAssert(contentEncodingSEL,@"No contentEncodingSEL");

      contentSEL = @selector(content);
      NSAssert(contentSEL,@"No contentSEL");

      contentStringSEL = @selector(contentString);
      NSAssert(contentStringSEL,@"No contentStringSEL");
      
      appendContentAsciiStringSEL = @selector(_appendContentAsciiString:);
      NSAssert(appendContentAsciiStringSEL,@"No appendContentAsciiStringSEL");

      appendContentCharacterSEL = @selector(appendContentCharacter:);
      NSAssert(appendContentCharacterSEL,@"No appendContentCharacterSEL");
      
      appendContentDataSEL = @selector(appendContentData:);
      NSAssert(appendContentDataSEL,@"No appendContentDataSEL");

      appendContentStringSEL = @selector(appendContentString:);
      NSAssert(appendContentStringSEL,@"No appendContentStringSEL");
      
      appendContentBytesSEL = @selector(appendContentBytes:length:);
      NSAssert(appendContentBytesSEL,@"No appendContentBytesSEL");

      appendDebugCommentContentStringSEL = @selector(appendDebugCommentContentString:);
      NSAssert(appendDebugCommentContentStringSEL,@"No appendDebugCommentContentStringSEL");

      replaceContentDataByDataSEL = @selector(replaceContentData:byData:);
      NSAssert(replaceContentDataByDataSEL,@"No replaceContentDataByDataSEL");
      
      appendContentHTMLStringSEL = @selector(appendContentHTMLString:);
      NSAssert(appendContentHTMLStringSEL,@"No appendContentHTMLStringSEL");

      appendContentHTMLAttributeValueSEL = @selector(appendContentHTMLAttributeValue:);
      NSAssert(appendContentHTMLAttributeValueSEL,@"No appendContentHTMLAttributeValueSEL");

      appendContentHTMLConvertStringSEL = @selector(appendContentHTMLConvertString:);
      NSAssert(appendContentHTMLConvertStringSEL,@"No appendContentHTMLConvertStringSEL");

      appendContentHTMLEntitiesConvertStringSEL = @selector(appendContentHTMLEntitiesConvertString:);
      NSAssert(appendContentHTMLEntitiesConvertStringSEL,@"No appendContentHTMLEntitiesConvertStringSEL");

      stringByEscapingHTMLStringSEL = @selector(stringByEscapingHTMLString:);
      NSAssert(stringByEscapingHTMLStringSEL,@"No stringByEscapingHTMLStringSEL");

      stringByEscapingHTMLAttributeValueSEL = @selector(stringByEscapingHTMLAttributeValue:);
      NSAssert(stringByEscapingHTMLAttributeValueSEL,@"No stringByEscapingHTMLAttributeValueSEL");

      stringByConvertingToHTMLEntitiesSEL = @selector(stringByConvertingToHTMLEntities:);
      NSAssert(stringByConvertingToHTMLEntitiesSEL,@"No stringByConvertingToHTMLEntitiesSEL");

      stringByConvertingToHTMLSEL = @selector(stringByConvertingToHTML:);
      NSAssert(stringByConvertingToHTMLSEL,@"No stringByConvertingToHTMLSEL");
           
      globalDefaultEncoding = WOStrictFlag ? NSISOLatin1StringEncoding : [NSString defaultCStringEncoding];
      initGSWMessageDataCache();
    }
}

//--------------------------------------------------------------------
//	init

-(id)init 
{
  if ((self=[super init]))
    {
      GetGSWMessageIMPs(&_selfMsgIMPs,self);
      ASSIGN(_httpVersion,@"HTTP/1.0");
      _headers=[NSMutableDictionary new];
      _contentEncoding=[[self class] defaultEncoding];
      _checkBody(self);
    };
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
      if ([clone->_cachesStack count]>0)
        {
          clone->_currentCacheData=[clone->_cachesStack lastObject];
          clone->_currentCacheDataADImp=NULL;
        };
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

  if (!_headers)
    _headers=[NSMutableDictionary new];

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
-(void)removeHeader:(NSString*)header
             forKey:(NSString*)key
{
  id object=[_headers objectForKey:key];

  if (object)
    {
      if ([object isKindOfClass:[NSArray class]])
        {
          int index=[object indexOfObject:header];
          if (index!=NSNotFound)
            {
              if ([object count]==1)
                [_headers removeObjectForKey:key];
              else
                {                  
                  object=[[object mutableCopy]autorelease];
                  [object removeObjectAtIndex:index];
                  [self setHeaders:object
                        forKey:key];
                };
            }
        }
      else if ([object isEqual:header])
        {
          [_headers removeObjectForKey:key];
        };
    };
};

//--------------------------------------------------------------------
-(void)removeHeaderForKey:(NSString*)key
{
  [self removeHeadersForKey:key];
}

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
  DESTROY(_contentData);
  GSWMessage_appendContentData(self,contentData);
};

//--------------------------------------------------------------------
//	content
-(NSData*)content
{
  return _contentData;
};

//--------------------------------------------------------------------
-(NSString*)contentString
{
  NSString* contentString=nil;

  NS_DURING
    {
      contentString=AUTORELEASE([[NSString alloc] initWithData:_contentData
                                                  encoding:[self contentEncoding]]);
    }
  NS_HANDLER
    {
      NSWarnLog(@"Can't convert contentData to String: %@",localException);
    }
  NS_ENDHANDLER;

  return contentString;
};

//--------------------------------------------------------------------
-(void)appendContentData:(NSData*)contentData
{
  if (contentData)
    {
      _checkBody(self);
      (*_contentDataADImp)(_contentData,appendDataSel,contentData);

#ifndef NO_GNUSTEP
      // Caching management
      if (_currentCacheData)
        {
          assertCurrentCacheDataADImp();
          (*_currentCacheDataADImp)(_currentCacheData,appendDataSel,contentData);
        };
#endif
    };
}

//--------------------------------------------------------------------
- (void)appendContentString:(NSString *)aValue 
{

  // checking [aValue length] takes too long!  
  if (aValue)
    {
      NSData *myData = [aValue dataUsingEncoding:_contentEncoding
                               allowLossyConversion:NO];

      if (!myData)
        {
          NSLog(aValue);
          [NSException raise:NSInvalidArgumentException 
                       format:@"%s: could not convert '%s' non-lossy to encoding %i",
                       __PRETTY_FUNCTION__, [aValue lossyCString],_contentEncoding];  
        }

      _checkBody(self);
      (*_contentDataADImp)(_contentData,appendDataSel,myData);

#ifndef NO_GNUSTEP
      // Caching management
      if (_currentCacheData)
        {
          assertCurrentCacheDataADImp();
          (*_currentCacheDataADImp)(_currentCacheData,appendDataSel,myData);
        };
#endif
    };
}

//--------------------------------------------------------------------
-(void)_appendContentAsciiString:(NSString*) aValue
{
  // checking [aValue length] takes too long!  
  if (aValue)
    {
      NSData* ad=[aValue dataUsingEncoding:NSASCIIStringEncoding
                         allowLossyConversion:YES];
      
      (*_contentDataADImp)(_contentData,appendDataSel,ad);

#ifndef NO_GNUSTEP
          // Caching management
          if (_currentCacheData)
            {
              assertCurrentCacheDataADImp();
              (*_currentCacheDataADImp)(_currentCacheData,appendDataSel,ad);
            };
#endif
    };

}

//--------------------------------------------------------------------
//	appendContentCharacter:
// append one ASCII char
-(void)appendContentCharacter:(char)aChar
{
  NSData *myData = nil;
  int i = aChar;

  myData=GSWMessageDataCache[i];
  
  if (!myData)
    {
      NSString* string=[NSString stringWithCString:&aChar
                                 length:1];
      if (string)
        {
          GSWMessage_appendContentString(self,string);
        }
    }
  else
    {
      _checkBody(self);
      (*_contentDataADImp)(_contentData,appendDataSel,myData);

#ifndef NO_GNUSTEP
      // Caching management
      if (_currentCacheData)
        {
          assertCurrentCacheDataADImp();
          (*_currentCacheDataADImp)(_currentCacheData,appendDataSel,myData);
        };
#endif
    }
};

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
  if ((length>0) && (bytes != NULL))
    {
      [_contentData appendBytes:bytes
                    length:length];

#ifndef NO_GNUSTEP
      // Caching management
      if (_currentCacheData)
        {
          [_currentCacheData appendBytes:bytes
                             length:length];
        };
#endif
    };
};

//--------------------------------------------------------------------
//	appendDebugCommentContentString:

-(void)appendDebugCommentContentString:(NSString*)aString
{
#ifndef NDEBUG
  if (GSDebugSet(@"debugComments") == YES)
    {
      GSWMessage_appendContentAsciiString(self,@"\n<!-- ");
      GSWMessage_appendContentString(self,aString);
      GSWMessage_appendContentAsciiString(self,@" -->\n");      
    };
#endif
};

//--------------------------------------------------------------------
-(void)replaceContentData:(NSData*)replaceData
                   byData:(NSData*)byData
{
  if ([replaceData length]>0) // is there something to replace ?
    {
      NSDebugMLog(@"[_contentData length]=%d",[_contentData length]);
      if ([_contentData length]>0)
        {
          [_contentData replaceOccurrencesOfData:replaceData
                        withData:byData
                        range:NSMakeRange(0,[_contentData length])];
        };
    };
};

@end


//====================================================================
@implementation GSWMessage (GSWHTMLConveniences)

//--------------------------------------------------------------------
//	appendContentHTMLAttributeValue:

-(void)appendContentHTMLAttributeValue:(NSString*)value
{

  GSWMessage_appendContentString(self,
                                 GSWMessage_stringByEscapingHTMLAttributeValue(self,value));
};

//--------------------------------------------------------------------
//	appendContentHTMLString:

-(void)appendContentHTMLString:(NSString*)aString
{

  GSWMessage_appendContentString(self,
                                 GSWMessage_stringByEscapingHTMLString(self,aString));
};

//--------------------------------------------------------------------
-(void)appendContentHTMLConvertString:(NSString*)aString
{

  GSWMessage_appendContentString(self,
                                 GSWMessage_stringByConvertingToHTML(self,aString));
};

//--------------------------------------------------------------------
-(void)appendContentHTMLEntitiesConvertString:(NSString*)aString
{

  GSWMessage_appendContentString(self,
                                 GSWMessage_stringByConvertingToHTMLEntities(self,aString));
};

//--------------------------------------------------------------------
+(NSString*)stringByEscapingHTMLString:(NSString*)aString
{
  return [NSStringWithObject(aString) stringByEscapingHTMLString];
};

//--------------------------------------------------------------------
+(NSString*)stringByEscapingHTMLAttributeValue:(NSString*)aString
{
  return [NSStringWithObject(aString) stringByEscapingHTMLAttributeValue];
};

//--------------------------------------------------------------------
+(NSString*)stringByConvertingToHTMLEntities:(NSString*)aString
{
  return stringByConvertingToHTMLEntities(NSStringWithObject(aString));
};

//--------------------------------------------------------------------
+(NSString*)stringByConvertingToHTML:(NSString*)aString
{
  return stringByConvertingToHTML(NSStringWithObject(aString));
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

  cookies=[self _initCookies];

  if (cookie)
    [cookies addObject:cookie];
};

//--------------------------------------------------------------------
-(void)removeCookie:(GSWCookie*)cookie
{
  NSMutableArray* cookies=nil;

  cookies=[self _initCookies];
  if (cookie)
    [cookies removeObject:cookie];
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

  if (!_cachesStack)
    {
      _cachesStack=[NSMutableArray new];
    };

  _currentCacheData=(NSMutableData*)[NSMutableData data];
  _currentCacheDataADImp=NULL;

  [_cachesStack addObject:_currentCacheData];

  index=[_cachesStack count]-1;

  return index;
};

//--------------------------------------------------------------------
-(id)stopCacheOfIndex:(int)cacheIndex
{
  NSMutableData* cachedData=nil;
  int cacheStackCount=0;

  cacheStackCount=[_cachesStack count];

  if (cacheIndex<cacheStackCount)
    {
      cachedData=[_cachesStack objectAtIndex:cacheIndex];
      AUTORELEASE(RETAIN(cachedData));

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
              NSData* tmp=[_cachesStack objectAtIndex:cacheIndex];

              [cachedData appendData:tmp];
              [_cachesStack removeObjectAtIndex:cacheIndex];
            };
        };
      cacheStackCount=[_cachesStack count];

      //Add cachedData to previous cache item data
      if (cacheStackCount>0)
        {
          _currentCacheData=[_cachesStack objectAtIndex:cacheStackCount-1];
          _currentCacheDataADImp=NULL;
          if ([cachedData length]>0)
            {
              assertCurrentCacheDataADImp();
              (*_currentCacheDataADImp)(_currentCacheData,appendDataSel,cachedData);
            };
        }
      else
        {
          _currentCacheData=nil;
          _currentCacheDataADImp=NULL;
        };
    };
  
  return cachedData;
}

@end

#endif
