/** GSWMessage.h - <title>GSWeb: Class GSWMessage</title>

   Copyright (C) 2003-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Aug 2003
   
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

// $Id$

#ifndef _GSWMessage_h__
	#define _GSWMessage_h__

typedef struct _GSWMessageIMPs
{
  // Instance IMPs
  GSWIMP_STRING_ENCODING _contentEncodingIMP;
  IMP _contentIMP;
  IMP _contentStringIMP;
  IMP _appendContentAsciiStringIMP;
  IMP _appendContentCharacterIMP;
  IMP _appendContentStringIMP;
  IMP _appendContentDataIMP;
  IMP _appendContentBytesIMP;
  IMP _appendDebugCommentContentStringIMP;
  IMP _replaceContentDataByDataIMP;
  IMP _appendContentHTMLStringIMP;
  IMP _appendContentHTMLAttributeValueIMP;
  IMP _appendContentHTMLConvertStringIMP;
  IMP _appendContentHTMLEntitiesConvertStringIMP;

  // Class IMPs
  IMP _stringByEscapingHTMLStringIMP;
  IMP _stringByEscapingHTMLAttributeValueIMP;
  IMP _stringByConvertingToHTMLEntitiesIMP;
  IMP _stringByConvertingToHTMLIMP;
} GSWMessageIMPs;

/** Fill impsPtr structure with IMPs for message **/
GSWEB_EXPORT void GetGSWMessageIMPs(GSWMessageIMPs* impsPtr,GSWMessage* message);

/** functions to accelerate calls of frequently used GSWMessage methods **/
GSWEB_EXPORT NSStringEncoding GSWMessage_contentEncoding(GSWMessage* aMessage);
GSWEB_EXPORT NSData* GSWMessage_content(GSWMessage* aMessage);
GSWEB_EXPORT NSString* GSWMessage_contentString(GSWMessage* aMessage);
GSWEB_EXPORT void GSWMessage_appendContentAsciiString(GSWMessage* aMessage,NSString* aString);
GSWEB_EXPORT void GSWMessage_appendContentCharacter(GSWMessage* aMessage,char aChar);
GSWEB_EXPORT void GSWMessage_appendContentString(GSWMessage* aMessage,NSString* string);
GSWEB_EXPORT void GSWMessage_appendContentData(GSWMessage* aMessage,NSData* contentData);
GSWEB_EXPORT void GSWMessage_appendContentBytes(GSWMessage* aMessage,const void* contentsBytes,unsigned length);
GSWEB_EXPORT void GSWMessage_appendDebugCommentContentString(GSWMessage* aMessage,NSString* string);
GSWEB_EXPORT void GSWMessage_replaceContentData(GSWMessage* aMessage,NSData* replaceData,NSData* byData);
GSWEB_EXPORT void GSWMessage_appendContentHTMLString(GSWMessage* aMessage,NSString* string);
GSWEB_EXPORT void GSWMessage_appendContentHTMLAttributeValue(GSWMessage* aMessage,NSString* string);
GSWEB_EXPORT void GSWMessage_appendContentHTMLConvertString(GSWMessage* aMessage,NSString* string);
GSWEB_EXPORT void GSWMessage_appendContentHTMLEntitiesConvertString(GSWMessage* aMessage,NSString* string);
GSWEB_EXPORT NSString* GSWMessage_stringByEscapingHTMLString(GSWMessage* aMessage,NSString* aString);
GSWEB_EXPORT NSString* GSWMessage_stringByEscapingHTMLAttributeValue(GSWMessage* aMessage,NSString* aString);
GSWEB_EXPORT NSString* GSWMessage_stringByConvertingToHTMLEntities(GSWMessage* aMessage,NSString* aString);
GSWEB_EXPORT NSString* GSWMessage_stringByConvertingToHTML(GSWMessage* aMessage,NSString* aString);

//====================================================================
@interface GSWMessage : NSObject <NSCopying>
{
  NSString* _httpVersion;
  NSMutableDictionary* _headers;
  NSMutableArray* _cookies;
  NSStringEncoding _contentEncoding;
  NSDictionary* _userInfo;
  NSMutableData* _contentData;
  IMP _contentDataADImp;

#ifndef NO_GNUSTEP
  NSMutableArray* _cachesStack; // Cache Stacks
  NSMutableData* _currentCacheData; // Current Cache Data (last object of _cachesStack). Do not retain/release
  IMP _currentCacheDataADImp;
#endif

@public // For functions
  GSWMessageIMPs _selfMsgIMPs;
};

-(void)setHTTPVersion:(NSString*)version;
-(NSString*)httpVersion;

-(void)setUserInfo:(NSDictionary*)userInfo;
-(NSDictionary*)userInfo;

-(void)setHeader:(NSString*)header
          forKey:(NSString*)key;
-(void)setHeaders:(NSArray*)headerList
           forKey:(NSString*)key;
-(void)setHeaders:(NSDictionary*)headerList;

-(void)removeHeader:(NSString*)header
             forKey:(NSString*)key;

-(void)removeHeaderForKey:(NSString*)key;
-(void)removeHeadersForKey:(NSString*)key;

-(void)appendHeader:(NSString*)header
             forKey:(NSString*)key;
-(void)appendHeaders:(NSArray*)headers
              forKey:(NSString*)key;

-(NSMutableDictionary*)headers;

-(NSString*)headerForKey:(NSString*)key;
-(NSArray*)headerKeys;
-(NSArray*)headersForKey:(NSString*)key;

-(int)_contentLength;

-(void)setContentEncoding:(NSStringEncoding)encoding;
-(NSStringEncoding)contentEncoding;

-(NSData*)content;
-(NSString*)contentString;
-(void)setContent:(NSData*)contentData;

-(void)_appendContentAsciiString:(NSString*)aString;
-(void)appendContentCharacter:(char)aChar;

-(void)appendContentString:(NSString*)string;
-(void)appendContentData:(NSData*)contentData;

@end

//====================================================================
@interface GSWMessage (GSWContentConveniences)
-(void)appendContentBytes:(const void*)contentsBytes
                   length:(unsigned)length;
-(void)appendDebugCommentContentString:(NSString*)string;
-(void)replaceContentData:(NSData*)replaceData
                   byData:(NSData*)byData;

@end
//====================================================================
@interface GSWMessage (GSWHTMLConveniences)

-(void)appendContentHTMLString:(NSString*)string;
-(void)appendContentHTMLAttributeValue:(NSString*)string;
-(void)appendContentHTMLConvertString:(NSString*)string;
-(void)appendContentHTMLEntitiesConvertString:(NSString*)string;
+(NSString*)stringByEscapingHTMLString:(NSString*)string;
+(NSString*)stringByEscapingHTMLAttributeValue:(NSString*)string;
+(NSString*)stringByConvertingToHTMLEntities:(NSString*)string;
+(NSString*)stringByConvertingToHTML:(NSString*)string;
@end

//====================================================================
@interface GSWMessage (Cookies)
-(void)_finalizeCookiesInContext:(GSWContext*)aContext;
-(NSMutableArray*)_initCookies;
-(NSString*)_formattedCookiesString;
-(void)addCookie:(GSWCookie*)cookie;
-(void)removeCookie:(GSWCookie*)cookie;
-(NSArray*)cookies;
-(NSArray*)cookiesHeadersValues;//NDFN

@end

//====================================================================
@interface GSWMessage (GSWMessageDefaultEncoding)
+(void)setDefaultEncoding:(NSStringEncoding)encoding;
+(NSStringEncoding)defaultEncoding;
@end

//====================================================================
#ifndef NO_GNUSTEP

@interface GSWMessage (GSWMessageCache)
-(int)startCache;
-(id)stopCacheOfIndex:(int)cacheIndex;
@end

#endif


#endif //_GSWMessage_h__
