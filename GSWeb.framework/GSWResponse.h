/* GSWResponse.h - GSWeb: Class GSWResponse
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

// $Id$

#ifndef _GSWResponse_h__
	#define _GSWResponse_h__

//====================================================================
@protocol GSWActionResults
-(GSWResponse*)generateResponse;
@end

//====================================================================
@interface GSWResponse : NSObject <NSCopying>
{
@private
    NSString* httpVersion;
    unsigned int status;
    NSMutableDictionary* headers;
    NSMutableArray* contentFaults;
    NSMutableData* contentData;
    NSStringEncoding contentEncoding;
    NSDictionary* userInfo;
    NSMutableArray* cookies;
    BOOL isClientCachingDisabled;
    BOOL contentFaultsHaveBeenResolved;
    BOOL isFinalizeInContextHasBeenCalled;
};

-(id)init;
-(void)dealloc;
-(id)copyWithZone:(NSZone*)zone_;
-(NSData*)content;
-(void)willSend;//NDFN
-(NSString*)headerForKey:(NSString*)key_;
-(NSArray*)headerKeys;
-(NSArray*)headersForKey:(NSString*)key_;
-(NSString*)httpVersion;
-(void)setContent:(NSData*)someData;
-(void)setHeader:(NSString*)header_
		  forKey:(NSString*)key_;
-(void)setHeaders:(NSArray*)headerList_
		   forKey:(NSString*)key_;
-(void)setHTTPVersion:(NSString*)version_;
-(void)setStatus:(unsigned int)status_;
-(void)setUserInfo:(NSDictionary*)userInfo_;
-(unsigned int)status;
-(NSDictionary*)userInfo;
-(NSString*)description;

-(void)disableClientCaching;

@end

//====================================================================
@interface GSWResponse (GSWContentConveniences)
-(void)appendContentBytes:(const void*)contentsBytes_
				   length:(unsigned)length_;
-(void)appendContentCharacter:(char)char_;
-(void)appendContentString:(NSString*)string_;
-(void)appendContentData:(NSData*)contentData_;
-(void)setContentEncoding:(NSStringEncoding)encoding_;
-(NSStringEncoding)contentEncoding;


@end

//====================================================================
@interface GSWResponse (GSWHTMLConveniences)

-(void)appendContentHTMLString:(NSString*)string_;
-(void)appendContentHTMLAttributeValue:(NSString*)string_;
-(void)appendContentHTMLConvertString:(NSString*)string_;
-(void)appendContentHTMLEntitiesConvertString:(NSString*)string_;
+(NSString*)stringByEscapingHTMLString:(NSString*)string_;
+(NSString*)stringByEscapingHTMLAttributeValue:(NSString*)string_;
+(NSString*)stringByConvertingToHTMLEntities:(NSString*)string_;
+(NSString*)stringByConvertingToHTML:(NSString*)string_;
@end

//====================================================================
@interface GSWResponse (Cookies)
-(NSString*)_formattedCookiesString;
-(NSMutableArray*)allocCookiesIFND;
-(void)addCookie:(GSWCookie*)cookie_;
-(void)removeCookie:(GSWCookie*)cookie_;
-(NSArray*)cookies;
-(NSArray*)cookiesHeadersValues;//NDFN

@end

//====================================================================
@interface GSWResponse (GSWResponseA)
-(BOOL)isFinalizeInContextHasBeenCalled;//NDFN
-(void)_finalizeInContext:(GSWContext*)context_;
-(void)_initContentData;
-(void)_appendContentAsciiString:(NSString*)_string;

@end

//====================================================================
@interface GSWResponse (GSWResponseB)
-(void)_resolveContentFaultsInContext:(GSWContext*)context_;
-(void)_appendContentFault:(id)_unknown;

@end

//====================================================================
@interface GSWResponse (GSWResponseC)
-(BOOL)_isClientCachingDisabled;
-(unsigned int)_contentDataLength;
@end

//====================================================================
@interface GSWResponse (GSWResponseD)
-(BOOL)_responseIsEqual:(GSWResponse*)response_;
@end

//====================================================================
@interface GSWResponse (GSWActionResults) <GSWActionResults>

-(GSWResponse*)generateResponse;

@end

//====================================================================
@interface GSWResponse (GSWResponseDefaultEncoding)
+(void)setDefaultEncoding:(NSStringEncoding)_encoding;
+(NSStringEncoding)defaultEncoding;
@end

#endif //_GSWResponse_h__
