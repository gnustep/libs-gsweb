/** GSWRequest.h - <title>GSWeb: Class GSWRequest</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

#ifndef _GSWRequest_h__
	#define _GSWRequest_h__

@class GSWDynamicURLString;
@class GSWContext;

#include "GSWMessage.h"

//====================================================================
/** A class to handle value and quality like for Accept-Language or 
Accept-Encoding 
Cf RFC 2616 (http://www.rfc-editor.org/rfc/rfc2616.txt)
**/
@interface GSWValueQualityHeaderPart : NSObject
{
  NSString* _value;
  float _quality;
}
+(NSArray*)valuesFromHeaderString:(NSString*)string;
+(GSWValueQualityHeaderPart*)valueQualityHeaderPartWithString:(NSString*)string;
+(GSWValueQualityHeaderPart*)valueQualityHeaderPartWithValue:(NSString*)value
                                               qualityString:(NSString*)qualityString;
-(id)initWithString:(NSString*)string;
-(id)initWithValue:(NSString*)value
     qualityString:(NSString*)qualityString;
-(NSString*)value;
-(float)quality;
-(int)compareOnQualityDesc:(GSWValueQualityHeaderPart*)qv;
@end

//====================================================================
/** HTTP request class **/
@interface GSWRequest : GSWMessage
{
@private
  NSString* _method;
  GSWDynamicURLString* _uri;
  NSStringEncoding _defaultFormValueEncoding;
  NSStringEncoding _formValueEncoding;
  NSDictionary* _formValues;
  NSDictionary* _uriElements;
  NSDictionary* _cookie;
  BOOL _finishedParsingMultipartFormData;
  NSString* _applicationURLPrefix;
  NSArray* _requestHandlerPathArray;
  NSArray* _browserLanguages;
  NSArray* _browserAcceptedEncodings;
  int _requestType;
  BOOL _isUsingWebServer;
  BOOL _formValueEncodingDetectionEnabled;
  int _applicationNumber;
  GSWContext* _context;//Don't retain/release because request is retained by context
};

-(id)initWithMethod:(NSString*)aMethod
                uri:(NSString*)anURL
        httpVersion:(NSString*)aVersion
            headers:(NSDictionary*)headers
            content:(NSData*)content
           userInfo:(NSDictionary*)userInfo;

-(GSWContext*)_context;
-(void)_setContext:(GSWContext*)context;
-(NSString*)method;
-(NSArray*)browserLanguages;
-(NSArray*)browserAcceptedEncodings;
-(NSArray*)requestHandlerPathArray;
-(NSString*)uri;
-(NSString*)urlProtocol;//NDFN
-(NSString*)urlHost;//NDFN
-(NSString*)urlPortString;//NDFN
-(int)urlPort;//NDFN
-(NSString*)urlProtocolHostPort;//NDFN
-(BOOL)isSecure;//NDFN
-(NSString*)remoteAddress;
-(NSString*)remoteHost;
-(NSString*)userAgent;//NDFN
-(NSString*)referer;//NDFN
-(NSString*)description;


-(void)setDefaultFormValueEncoding:(NSStringEncoding)encoding;
-(NSStringEncoding)defaultFormValueEncoding;

-(void)setFormValueEncodingDetectionEnabled:(BOOL)flag;
-(BOOL)isFormValueEncodingDetectionEnabled;

-(NSStringEncoding)formValueEncoding;
-(NSArray*)formValueKeys;
-(NSArray*)formValuesForKey:(NSString*)key;
-(id)formValueForKey:(NSString*)key; // return id because GSWFileUpload
-(NSString*)stringFormValueForKey:(NSString*)key;
-(NSNumber*)numberFormValueForKey:(NSString*)key
                    withFormatter:(NSNumberFormatter*)formatter;
-(NSCalendarDate*)dateFormValueForKey:(NSString*)key
                        withFormatter:(NSDateFormatter*)formatter;

-(NSDictionary*)formValues;
-(void)appendFormValue:(id)value
                forKey:(NSString*)key;
-(void)appendFormValues:(NSArray*)values
                 forKey:(NSString*)key;

-(NSArray*)uriElementKeys;
-(NSString*)uriElementForKey:(NSString*)key;
-(NSDictionary*)uriElements;

-(BOOL)isFromClientComponent;


//NDFN
-(void)setCookieFromHeaders;

-(NSArray*)cookieValuesForKey:(NSString*)key;
-(NSString*)cookieValueForKey:(NSString*)key;
-(NSDictionary*)cookieValues;

-(NSDictionary*)_initCookieDictionary;
-(NSString*)_cookieDescription;

-(NSString*)sessionIDFromValuesOrCookieByLookingForCookieFirst:(BOOL)lookCookieFirst;
-(NSString*)sessionID;
-(NSString*)requestHandlerPath;
-(NSString*)adaptorPrefix;
-(NSString*)applicationName;
-(int)applicationNumber;
-(NSString*)requestHandlerKey;

-(NSDictionary*)_extractValuesFromFormData:(NSData*)formData
                              withEncoding:(NSStringEncoding)encoding;
-(NSStringEncoding)_formValueEncodingFromFormData:(NSData*)formData;
-(NSData*)_formData;
-(NSString*)_contentType;
-(NSString*)_urlQueryString;

-(BOOL)_isUsingWebServer;
-(BOOL)isUsingWebServer;

-(void)_setIsUsingWebServer:(BOOL)_flag;

-(BOOL)_isSessionIDInRequest;
-(BOOL)_isSessionIDInCookies;
-(BOOL)_isSessionIDInFormValues;
-(id)_completeURLWithRequestHandlerKey:(NSString*)key
                                  path:(NSString*)path
                           queryString:(NSString*)queryString
                              isSecure:(BOOL)isSecure
                                  port:(int)port;

/** urlPrefix will prefix url (before the /GSWeb) **/
-(GSWDynamicURLString*)_urlWithURLPrefix:(NSString*)urlPrefix
                       requestHandlerKey:(NSString*)key
                                    path:(NSString*)path
                             queryString:(NSString*)queryString;

-(GSWDynamicURLString*)_urlWithRequestHandlerKey:(NSString*)key
                                            path:(NSString*)path
                                     queryString:(NSString*)queryString;
-(GSWDynamicURLString*)_applicationURLPrefix;
-(NSDictionary*)_formValues;
-(void)_getFormValuesFromURLEncoding;
+(BOOL)_lookForIDsInCookiesFirst;
-(BOOL)_hasFormValues; 

-(void)_getFormValuesFromMultipartFormData;
-(NSArray*)_decodeMultipartBody:(NSData*)body
                       boundary:(NSString*)boundary;
-(NSArray*)_parseData:(NSData*)data;
-(NSDictionary*)_parseOneHeader:(NSString*)header;

-(id)nonNilFormValueForKey:(NSString*)key;

-(id)dictionaryWithKeys:(id)unknown;
-(NSString*)selectedButtonName;
-(id)valueFromImageMapNamed:(NSString*)aName;
-(id)valueFromImageMapNamed:(NSString*)aName
                inFramework:(NSString*)aFramework;
-(id)valueFromImageMap:(id)unknown;
-(id)yCoord;
-(id)xCoord;
-(id)formKeyWithSuffix:(NSString*)suffix;

-(NSString*)applicationHost;
-(NSString*)pageName;
-(NSString*)contextID;
-(NSString*)senderID;
//NDFN
-(NSDictionary*)uriOrFormOrCookiesElementsByLookingForCookieFirst:(BOOL)lookCookieFirst;
-(id)uriOrFormOrCookiesElementForKey:(NSString*)key
             byLookingForCookieFirst:(BOOL)lookCookieFirst;
-(NSDictionary*)uriOrFormOrCookiesElements;

-(void)_validateAPI;
@end

#endif //_GSWRequest_h__


