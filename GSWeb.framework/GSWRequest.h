/* GSWRequest.h - GSWeb: Class GSWRequest
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

#ifndef _GSWRequest_h__
	#define _GSWRequest_h__


//====================================================================
@interface GSWRequest : NSObject <NSCopying>
{
@private
  NSString* method;
  GSWDynamicURLString* uri;
  NSString* httpVersion;
  NSDictionary* headers;
  NSData* content;
  NSDictionary* userInfo;
  NSStringEncoding defaultFormValueEncoding;
  NSStringEncoding formValueEncoding;
  NSDictionary* formValues;
  NSDictionary* cookie;
  NSString* applicationURLPrefix;
  NSArray* requestHandlerPathArray;
  NSArray* browserLanguages;
  int requestType;
  BOOL isUsingWebServer;
  BOOL formValueEncodingDetectionEnabled;
  int applicationNumber;
};

-(id)initWithMethod:(NSString*)method_
				uri:(NSString*)url_
		httpVersion:(NSString*)httpVersion_
			headers:(NSDictionary*)headers_
			content:(NSData*)content_
		   userInfo:(NSDictionary*)userInfo_;

-(void)dealloc;
-(id)copyWithZone:(NSZone*)zone_;

-(NSData*)content;
-(NSString*)headerForKey:(NSString*)key_;
-(NSArray*)headerKeys;
-(NSArray*)headersForKey:(NSString*)key_;
-(NSString*)httpVersion;
-(NSString*)method;
-(NSArray*)browserLanguages;
-(NSArray*)requestHandlerPathArray;
-(NSString*)uri;
-(NSString*)urlProtocol;//NDFN
-(NSString*)urlHost;//NDFN
-(NSString*)urlPortString;//NDFN
-(int)urlPort;//NDFN
-(NSString*)urlProtocolHostPort;//NDFN
-(BOOL)isSecure;//NDFN
-(NSDictionary*)userInfo;
-(NSString*)description;

@end

//====================================================================
@interface GSWRequest (GSWFormValueReporting)

-(void)setDefaultFormValueEncoding:(NSStringEncoding)encoding_;
-(NSStringEncoding)defaultFormValueEncoding;

-(void)setFormValueEncodingDetectionEnabled:(BOOL)flag_;
-(BOOL)isFormValueEncodingDetectionEnabled;

-(NSStringEncoding)formValueEncoding;
-(NSArray*)formValueKeys;
-(NSArray*)formValuesForKey:(NSString*)key_;
-(id)formValueForKey:(NSString*)key_; // return id because GSWFileUpload

-(NSDictionary*)formValues;
@end
//====================================================================
@interface GSWRequest (GSWRequestTypeReporting)
-(BOOL)isFromClientComponent;
@end

//====================================================================
@interface GSWRequest (Cookies)

//NDFN
-(void)setCookieFromHeaders;

-(NSArray*)cookieValuesForKey:(NSString*)key_;
-(NSString*)cookieValueForKey:(NSString*)key_;
-(NSDictionary*)cookieValues;

-(NSDictionary*)_initCookieDictionary;
-(NSString*)_cookieDescription;

@end
//====================================================================
@interface GSWRequest (GSWRequestA)

-(NSString*)sessionID;
-(NSString*)requestHandlerPath;
-(NSString*)adaptorPrefix;
-(NSString*)applicationName;
-(int)applicationNumber;
-(NSString*)requestHandlerKey;

@end
//====================================================================
@interface GSWRequest (GSWRequestB)
-(NSDictionary*)_extractValuesFromFormData:(NSData*)_formData
							  withEncoding:(NSStringEncoding)_encoding;
-(NSStringEncoding)_formValueEncodingFromFormData:(NSData*)_formData;
-(NSData*)_formData;
-(NSString*)_contentType;
-(NSString*)_urlQueryString;
@end

//====================================================================
@interface GSWRequest (GSWRequestF)
-(BOOL)_isUsingWebServer;
-(void)_setIsUsingWebServer:(BOOL)_flag;
@end
//====================================================================
@interface GSWRequest (GSWRequestG)
-(BOOL)_isSessionIDinRequest;
-(BOOL)_isSessionIDinCookies;
-(BOOL)_isSessionIDinFormValues;
-(id)_completeURLWithRequestHandlerKey:(NSString*)_key
								  path:(NSString*)_path
						   queryString:(NSString*)_queryString
							  isSecure:(BOOL)_isSecure
								  port:(int)_port;
-(GSWDynamicURLString*)_urlWithRequestHandlerKey:(NSString*)_key
										   path:(NSString*)_path
									queryString:(NSString*)_queryString;
-(GSWDynamicURLString*)_applicationURLPrefix;
-(NSDictionary*)_formValues;
-(void)_getFormValuesFromURLEncoding;
-(BOOL)_hasFormValues; 

@end
//====================================================================
@interface GSWRequest (GSWRequestH)
-(void)_getFormValuesFromMultipartFormData;
-(NSArray*)_decodeMultipartBody:(NSData*)_body
					   boundary:(NSString*)_boundary;
-(NSArray*)_parseData:(NSData*)_data;
-(NSDictionary*)_parseOneHeader:(NSString*)_header;
@end
//====================================================================
@interface GSWRequest (GSWRequestI)
-(id)nonNilFormValueForKey:(NSString*)_key;
@end
//====================================================================
@interface GSWRequest (GSWRequestJ)
-(id)dictionaryWithKeys:(id)_unknown;
-(NSString*)selectedButtonName;
-(id)valueFromImageMapNamed:(NSString*)_name;
-(id)valueFromImageMapNamed:(NSString*)_name
				inFramework:(NSString*)_framework;
-(id)valueFromImageMap:(id)_unknown;
-(id)yCoord;
-(id)xCoord;
-(id)formKeyWithSuffix:(NSString*)_suffix;
@end
//====================================================================
@interface GSWRequest (GSWRequestK)
-(NSString*)applicationHost;
-(NSString*)pageName;
-(NSString*)contextID;
-(NSString*)senderID;
//NDFN
-(NSMutableDictionary*)uriOrFormOrCookiesElements;
-(NSMutableDictionary*)uriElements;
@end
//====================================================================
@interface GSWRequest (GSWRequestL)
-(void)_validateAPI;
@end

#endif //_GSWRequest_h__


