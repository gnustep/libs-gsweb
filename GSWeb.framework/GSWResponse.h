/** GSWResponse.h - GSWeb: Class GSWResponse
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
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
**/

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
-(id)copyWithZone:(NSZone*)zone;
-(NSData*)content;
-(void)willSend;//NDFN
-(NSString*)headerForKey:(NSString*)key;
-(NSArray*)headerKeys;
-(NSArray*)headersForKey:(NSString*)key;
-(NSString*)httpVersion;
-(void)setContent:(NSData*)someData;
-(void)setHeader:(NSString*)header
		  forKey:(NSString*)key;
-(void)setHeaders:(NSArray*)headerList
		   forKey:(NSString*)key;
-(void)setHeaders:(NSDictionary*)headerList;
-(NSMutableDictionary*)headers;
-(void)setHTTPVersion:(NSString*)version;
-(void)setStatus:(unsigned int)status;
-(void)setUserInfo:(NSDictionary*)userInfo;
-(unsigned int)status;
-(NSDictionary*)userInfo;
-(NSString*)description;

-(void)disableClientCaching;

@end

//====================================================================
@interface GSWResponse (GSWContentConveniences)
-(void)appendContentBytes:(const void*)contentsBytes
                   length:(unsigned)length;
-(void)appendContentCharacter:(char)aChar;
-(void)appendContentString:(NSString*)string;
-(void)appendDebugCommentContentString:(NSString*)string;
-(void)appendContentData:(NSData*)contentData;
-(void)setContentEncoding:(NSStringEncoding)encoding;
-(NSStringEncoding)contentEncoding;


@end

//====================================================================
@interface GSWResponse (GSWHTMLConveniences)

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
@interface GSWResponse (Cookies)
-(NSString*)_formattedCookiesString;
-(NSMutableArray*)allocCookiesIFND;
-(void)addCookie:(GSWCookie*)cookie;
-(void)removeCookie:(GSWCookie*)cookie;
-(NSArray*)cookies;
-(NSArray*)cookiesHeadersValues;//NDFN

@end

//====================================================================
@interface GSWResponse (GSWResponseA)
-(BOOL)isFinalizeInContextHasBeenCalled;//NDFN
-(void)_finalizeInContext:(GSWContext*)context;
-(void)_initContentData;
-(void)_appendContentAsciiString:(NSString*)string;

@end

//====================================================================
@interface GSWResponse (GSWResponseB)
-(void)_resolveContentFaultsInContext:(GSWContext*)context;
-(void)_appendContentFault:(id)unknown;

@end

//====================================================================
@interface GSWResponse (GSWResponseC)
-(BOOL)_isClientCachingDisabled;
-(unsigned int)_contentDataLength;
@end

//====================================================================
@interface GSWResponse (GSWResponseD)
-(BOOL)_responseIsEqual:(GSWResponse*)response;
@end

//====================================================================
@interface GSWResponse (GSWActionResults) <GSWActionResults>

-(GSWResponse*)generateResponse;

@end

//====================================================================
@interface GSWResponse (GSWResponseDefaultEncoding)
+(void)setDefaultEncoding:(NSStringEncoding)encoding;
+(NSStringEncoding)defaultEncoding;
@end

//====================================================================
@interface GSWResponse (GSWResponseError)

//NDFN
//Last cHance Response
+(GSWResponse*)responseWithMessage:(NSString*)message
			 inContext:(GSWContext*)context
			forRequest:(GSWRequest*)request;

+(GSWResponse*)responseWithMessage:(NSString*)message
			 inContext:(GSWContext*)context
			forRequest:(GSWRequest*)request
                     forceFinalize:(BOOL)forceFinalize;
@end

//====================================================================
@interface GSWResponse (GSWResponseRefused)

//--------------------------------------------------------------------
//
//Refuse Response
+(GSWResponse*)generateRefusingResponseInContext:(GSWContext*)context
                                      forRequest:(GSWRequest*)request;
@end


#endif //_GSWResponse_h__
