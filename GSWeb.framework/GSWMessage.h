/** GSWMessage.h - <title>GSWeb: Class GSWMessage</title>

   Copyright (C) 2003 Free Software Foundation, Inc.
   
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

//====================================================================
@interface GSWMessage : NSObject <NSCopying>
{
  NSString* _httpVersion;
  NSMutableDictionary* _headers;
  NSMutableArray* _cookies;
  NSStringEncoding _contentEncoding;
  NSDictionary* _userInfo;
  NSMutableString* _contentString;
  NSMutableData* _contentData;
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

-(void)_initContentData;

-(NSData*)content;
-(NSString*)contentString;
-(void)setContent:(NSData*)contentData;
-(void)setContentString:(NSString*)contentString;

-(void)_appendContentAsciiString:(NSString*)aString;
-(void)_appendContentCharacter:(char)aChar;

-(void)appendContentString:(NSString*)string;
-(void)appendContentData:(NSData*)contentData;

@end

//====================================================================
@interface GSWMessage (GSWContentConveniences)
-(void)appendContentBytes:(const void*)contentsBytes
                   length:(unsigned)length;
-(void)appendContentCharacter:(char)aChar;
-(void)appendDebugCommentContentString:(NSString*)string;
-(void)replaceContentString:(NSString*)replaceString
                   byString:(NSString*)byString;
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



#endif //_GSWMessage_h__
