/** GSWRequest.m - <title>GSWeb: Class GSWRequest</title>

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

#include "GSWeb.h"
#include <GNUstepBase/GSMime.h>
#include "GSWInputStreamData.h"
#include "GSWPrivate.h"

//====================================================================
@implementation GSWValueQualityHeaderPart

/** Returns an array of values ordered by quality descending **/
+(NSArray*)valuesFromHeaderString:(NSString*)string
{
  NSArray* values=nil;
  NSArray* valuesAndQualities=nil;
  int count=0;

  valuesAndQualities=[string componentsSeparatedByString:@","];
  count=[valuesAndQualities count];
  if (count>0)
    {
      int i=0;
      NSMutableArray* qvs=[NSMutableArray array];
      for(i=0;i<count;i++)
        {
          NSString* string=[valuesAndQualities objectAtIndex:i];
          GSWValueQualityHeaderPart* qv=[GSWValueQualityHeaderPart 
                                           valueQualityHeaderPartWithString:string];
          if ([[qv value]length]>0)
              [qvs addObject:qv];
        };
      count=[qvs count];
      if (count>0)
        {
          unsigned int i;
          //Sor oon quality desc
          [qvs sortUsingSelector:@selector(compareOnQualityDesc:)];

          //Remove Duplicates
          for(i=0;i<count;i++)
            {
              int j=0;
              GSWValueQualityHeaderPart* qv=[qvs objectAtIndex:i];
              NSString* value=[qv value];
              for(j=i+1;j<count;j++)
                {
                  GSWValueQualityHeaderPart* qv2=[qvs objectAtIndex:j];
                  NSString* value2=[qv2 value];
                  if ([value2 isEqual:value])
                    {
                      [qvs removeObjectAtIndex:j];
                      count--;
                    };
                };
            };
          //Finally keep only values
          values=[qvs valueForKey:@"value"];
        };
    };

  return values;
};

+(GSWValueQualityHeaderPart*)valueQualityHeaderPartWithString:(NSString*)string
{
  return [[[self alloc]initWithString:string]autorelease];
};

+(GSWValueQualityHeaderPart*)valueQualityHeaderPartWithValue:(NSString*)value
                                               qualityString:(NSString*)qualityString
{
  return [[[self alloc]initWithValue:value
                       qualityString:qualityString]autorelease];
};

-(id)initWithString:(NSString*)string
{
  NSString* value=nil;
  NSString* qualityString=nil;
  NSRange qualitySeparatorRange;
  string=[string stringByTrimmingSpaces];
  qualitySeparatorRange=[string rangeOfString:@";q="];
  if (qualitySeparatorRange.length>0)
    {
      if (qualitySeparatorRange.location==0)
        {
          LOGError(@"value/quality string: '%@'",string);
        }
      else
        {
          value=[string substringToIndex:qualitySeparatorRange.location];
          if (qualitySeparatorRange.location
              +qualitySeparatorRange.length<[string length])
            qualityString=[string substringFromIndex:qualitySeparatorRange.location
                                  +qualitySeparatorRange.length];          
        };
    }
  else
    value=string;
  return [self initWithValue:value
               qualityString:qualityString];
};

-(id)initWithValue:(NSString*)value
     qualityString:(NSString*)qualityString
{
  if ((self=[self init]))
    {
      ASSIGN(_value,value);
      qualityString=[qualityString stringByTrimmingSpaces];
      if ([qualityString length]>0)
        _quality=[qualityString floatValue];
      else
        _quality=1;
    };
  return self;
};

-(void)dealloc
{
  DESTROY(_value);
  [super dealloc];
};

-(NSString*)description
{
  return [NSString stringWithFormat: @"<%s %p : %@: %.1f>",
		   object_get_class_name(self),
		   (void*)self,
		   _value,
                   _quality];
}
-(NSString*)value
{
  return _value;
};

-(float)quality
{
  return _quality;
};

-(int)compareOnQualityDesc:(GSWValueQualityHeaderPart*)qv
{
  float quality=[self quality];
  float qvQuality=[qv quality];
  if (quality>qvQuality)
    return NSOrderedAscending;
  else if (quality<qvQuality)
    return NSOrderedDescending;
  else
    return NSOrderedSame;  
}

@end

@interface GSWRequest (Internal)

-(NSDictionary*)_uriElements;

@end

@implementation GSWRequest

//--------------------------------------------------------------------
//	initWithMethod:uri:httpVersion:headers:content:userInfo:

// may raise exception
-(id)initWithMethod:(NSString*)aMethod
                uri:(NSString*)anURL
        httpVersion:(NSString*)aVersion
            headers:(NSDictionary*)headers
            content:(NSData*)content
           userInfo:(NSDictionary*)userInfo
{
  if ((self=[super init])) {
    NSString* adaptorVersion = nil;

    if ((!aMethod) || ([aMethod length]==0)) {
      ExceptionRaise(@"GSWRequest",@"Empty/Null method during initialization");
    }

    if (([aMethod isEqualToString:@"GET"] == NO) && ([aMethod isEqualToString:@"POST"] == NO) &&
        ([aMethod isEqualToString:@"HEAD"] == NO)) {

        ExceptionRaise(@"GSWRequest", @"Method '%@' is not supported. To support '%@', you will have to implement a subclass of GSWRequest, and force GSWeb to instantiate it.", aMethod, aMethod);
    }

    if ((! anURL) /*|| ([anURL length]==0)*/) {
      ExceptionRaise(@"GSWRequest",@"Empty/Null uri during initialization");
    }
    if ((! aVersion) || ([aVersion length]==0)) {
      ExceptionRaise(@"GSWRequest",@"Empty/Null http version during initialization");
    }

    ASSIGNCOPY(_method,aMethod);
    [self setHTTPVersion:aVersion];
    [self setHeaders:headers];
    
    _defaultFormValueEncoding=[[self class] defaultEncoding];      
    _applicationNumber=-9999;
    adaptorVersion=[self headerForKey:GSWHTTPHeader_AdaptorVersion[GSWebNamingConv]];
    if (!adaptorVersion) {
      adaptorVersion=[self headerForKey:GSWHTTPHeader_AdaptorVersion[GSWebNamingConvInversed]];
    }
    [self _setIsUsingWebServer:(adaptorVersion!=nil)];

    _uri = [[GSWDynamicURLString alloc] initWithString:anURL];
    [_uri checkURL];
    
    if (!content)
    content = [NSData data];
    [self setContent:content];
    
    [self setUserInfo:userInfo];
  }
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_method);
  DESTROY(_uri);
  DESTROY(_formValues);
  DESTROY(_uriElements);
  DESTROY(_cookie);
  DESTROY(_applicationURLPrefix);
  DESTROY(_requestHandlerPathArray);
  DESTROY(_browserLanguages);
  DESTROY(_browserAcceptedEncodings);

  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWRequest* clone = (GSWRequest*)[super copyWithZone:zone];
  if (clone)
    {
      ASSIGNCOPY(clone->_method,_method);
      ASSIGNCOPY(clone->_uri,_uri);
      clone->_defaultFormValueEncoding=_defaultFormValueEncoding;
      clone->_formValueEncoding=_formValueEncoding;
      ASSIGNCOPY(clone->_formValues,_formValues);
      ASSIGNCOPY(clone->_uriElements,_uriElements);
      ASSIGNCOPY(clone->_cookie,_cookie);
      ASSIGNCOPY(clone->_applicationURLPrefix,_applicationURLPrefix);
      ASSIGNCOPY(clone->_requestHandlerPathArray,_requestHandlerPathArray);
      ASSIGNCOPY(clone->_browserLanguages,_browserLanguages);
      ASSIGNCOPY(clone->_browserAcceptedEncodings,_browserAcceptedEncodings);
      clone->_requestType=_requestType;
      clone->_isUsingWebServer=_isUsingWebServer;
      clone->_formValueEncodingDetectionEnabled=_formValueEncodingDetectionEnabled;
      clone->_applicationNumber=_applicationNumber;
    };
  return clone;
};

//--------------------------------------------------------------------
-(GSWContext*)_context
{
  return _context;
}

//--------------------------------------------------------------------
-(void)_setContext:(GSWContext*)context
{
  _context = context;//Don't retain because request is retained by context
}

//--------------------------------------------------------------------
//	method
// GET or PUT

-(NSString*)method 
{
  return _method;
};

//--------------------------------------------------------------------
//	uri
-(NSString*)uri 
{
  return (NSString*)_uri;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlProtocol
{
  NSString* urlProtocol=[_uri urlProtocol];
  if (!urlProtocol)
    {
      urlProtocol=[self headerForKey:GSWHTTPHeader_RequestScheme[GSWebNamingConv]];
      if (!urlProtocol)
        {
          urlProtocol=[self headerForKey:GSWHTTPHeader_RequestScheme[GSWebNamingConvInversed]];
          if (!urlProtocol)      
            urlProtocol=GSWProtocol_HTTP;
        };
    };
  return urlProtocol;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)_remoteAddress
{
  NSString* remoteAddress=nil;

  remoteAddress = [self headerForKey:GSWHTTPHeader_RemoteAddress[GSWebNamingConv]];
  if (!remoteAddress)
    {
      remoteAddress = [self headerForKey:GSWHTTPHeader_RemoteAddress[GSWebNamingConvInversed]];
      if (!remoteAddress)
        remoteAddress = [self headerForKey:@"remote_addr"];
    };
  return remoteAddress;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)remoteAddress
{
  return [self _remoteAddress];
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)_remoteHost
{
  NSString* remoteHost=nil;

  remoteHost = [self headerForKey:GSWHTTPHeader_RemoteHost[GSWebNamingConv]];
  if (!remoteHost)
    {
      remoteHost = [self headerForKey:GSWHTTPHeader_RemoteHost[GSWebNamingConvInversed]];
      if (!remoteHost)
        remoteHost = [self headerForKey:@"remote_host"];
    };
  return remoteHost;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)remoteHost
{
  return [self _remoteHost];
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)_serverName
{
  NSString* serverName=nil;
  if ([self _isUsingWebServer])
    {
      serverName=[self headerForKey:GSWHTTPHeader_ServerName[GSWebNamingConv]];
      if (!serverName)
        {
          serverName=[self headerForKey:GSWHTTPHeader_ServerName[GSWebNamingConvInversed]];
          if (!serverName)
            {
              serverName=[self headerForKey:@"server_name"];
              if (!serverName)
                {
                  serverName=[self headerForKey:@"host"];
                  if (!serverName)
                    ExceptionRaise(@"GSWRequest",@"No server name");
                };
            };
        };
    }
  else
    {
      serverName = [GSWApplication host];
    }
  return serverName;
}

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlHost
{
  NSString* urlHost=[_uri urlHost];
  if (!urlHost)
    {
      urlHost=[self headerForKey:GSWHTTPHeader_ServerName[GSWebNamingConv]];
      if (!urlHost)
        urlHost=[self headerForKey:GSWHTTPHeader_ServerName[GSWebNamingConvInversed]];
    };
  return urlHost;
};

//--------------------------------------------------------------------
-(NSString*)_serverPort
{
  NSString* serverPort=nil;
  if ([self _isUsingWebServer])
    {
      serverPort = [self headerForKey:GSWHTTPHeader_ServerPort[GSWebNamingConv]];
      if (!serverPort)
        serverPort=[self headerForKey:GSWHTTPHeader_ServerPort[GSWebNamingConvInversed]];
    } 
  else
    {
      NSArray* adaptors = [[GSWApplication application]adaptors];
      if ([adaptors count]>0)
        serverPort = GSWIntToNSString([(GSWAdaptor*)[adaptors objectAtIndex:0] port]);
    }
  return serverPort;
}

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlPortString
{
  NSString* urlPortString=[_uri urlPortString];
  if (!urlPortString)
    {
      urlPortString=[self headerForKey:GSWHTTPHeader_ServerPort[GSWebNamingConv]];
      if (!urlPortString)
        urlPortString=[self headerForKey:GSWHTTPHeader_ServerPort[GSWebNamingConvInversed]];
    };
  return urlPortString;
};

//--------------------------------------------------------------------
//NDFN
-(int)urlPort
{
  int port=[_uri urlPort];
  if (!port)
    {
      port=[[self headerForKey:GSWHTTPHeader_ServerPort[GSWebNamingConv]]intValue];
      if (!port)
        port=[[self headerForKey:GSWHTTPHeader_ServerPort[GSWebNamingConvInversed]]intValue];
    };
  return port;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlProtocolHostPort
{
  return [_uri urlProtocolHostPort];
};

//--------------------------------------------------------------------
//NDFN
-(BOOL)isSecure
{
  return ([[self urlProtocol] caseInsensitiveCompare:GSWProtocol_HTTPS]==NSOrderedSame);
};

//--------------------------------------------------------------------
-(NSString*)userAgent
{
  NSString* userAgent=nil;

  userAgent=[self headerForKey:GSWHTTPHeader_UserAgent];

  return userAgent;
};

//--------------------------------------------------------------------
-(NSString*)referer
{
  NSString* referer=nil;

  referer=[self headerForKey:GSWHTTPHeader_Referer];

  return referer;
};

//--------------------------------------------------------------------
-(NSArray*)browserLanguages
{
  //OK

  if (!_browserLanguages)
    {
      NSMutableArray* browserLanguages=nil;
      NSString* header=[self headerForKey:GSWHTTPHeader_AcceptLanguage];

      if (header)
        {
          NSArray* languages=[GSWValueQualityHeaderPart valuesFromHeaderString:header];
          if (!languages)
            {
              LOGError0(@"No languages");
            };
          browserLanguages=(NSMutableArray*)[GSWResourceManager GSLanguagesFromISOLanguages:languages];
          if (browserLanguages)
            {
              //Remove Duplicates
              int i=0;
              int browserLanguagesCount=0;

              browserLanguages=[browserLanguages mutableCopy];
              browserLanguagesCount=[browserLanguages count];

              for(i=0;i<browserLanguagesCount;i++)
                {
                  int j=0;
                  NSString* language=[browserLanguages objectAtIndex:i];
                  for(j=browserLanguagesCount-1;j>i;j--)
                    {
                      NSString* language2=[browserLanguages objectAtIndex:j];
                      if ([language2 isEqual:language])
                        {
                          [browserLanguages removeObjectAtIndex:j];
                          browserLanguagesCount--;
                        };
                    };
                };
            };
        }
      else
        {
          LOGError0(@"No languages header");
        };
      
      if (!browserLanguages)
        {
          LOGError0(@"No known languages");
          browserLanguages=(NSMutableArray*)[NSArray array];
        };
      ASSIGN(_browserLanguages,browserLanguages);
    };

  return _browserLanguages;
};

//--------------------------------------------------------------------
-(NSArray*)browserAcceptedEncodings
{
  //OK

  if (!_browserAcceptedEncodings)
    {
      NSString* header=[self headerForKey:GSWHTTPHeader_AcceptEncoding];

      if (header)
        {
          NSArray* values=[GSWValueQualityHeaderPart valuesFromHeaderString:header];
          if (!values)
            values=[NSArray array];
          ASSIGN(_browserAcceptedEncodings,values);
        };
    };

  return _browserAcceptedEncodings;
};

//--------------------------------------------------------------------
-(NSArray*)requestHandlerPathArray
{
  if (!_requestHandlerPathArray)
    {
      NSString* urlRequestHandlerPath=[_uri urlRequestHandlerPath];
      ASSIGN(_requestHandlerPathArray,
             [urlRequestHandlerPath componentsSeparatedByString:@"/"]);
    };
  return _requestHandlerPathArray;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - method=%@, uri=%@, httpVersion=%@, headers=%@, content=%@, userInfo=%@, defaultFormValueEncoding=%u, formValueEncoding=%u, formValues=%@, uriElements=%@, cookie=%@, applicationURLPrefix=%@, requestHandlerPathArray=%@, browserLanguages=%@, requestType=%d, isUsingWebServer=%s, formValueEncodingDetectionEnabled=%s, applicationNumber=%d",
                   object_get_class_name(self),
                   (void*)self,
                   _method,
                   _uri,
                   _httpVersion,
                   _headers,
                   _contentData,
                   _userInfo,
                   _defaultFormValueEncoding,
                   _formValueEncoding,
                   _formValues,
                   _uriElements,
                   _cookie,
                   _applicationURLPrefix,
                   _requestHandlerPathArray,
                   _browserLanguages,
                   _requestType,
                   _isUsingWebServer ? "YES" : "NO",
                   _formValueEncodingDetectionEnabled ? "YES" : "NO",
                   _applicationNumber];
};

//--------------------------------------------------------------------
//	setDefaultFormValueEncoding:
-(void)setDefaultFormValueEncoding:(NSStringEncoding)encoding
{
  _defaultFormValueEncoding=encoding;
};

//--------------------------------------------------------------------
//	defaultFormValueEncoding
-(NSStringEncoding)defaultFormValueEncoding 
{
  return _defaultFormValueEncoding;
};

//--------------------------------------------------------------------
//	setFormValueEncodingDetectionEnabled:
-(void)setFormValueEncodingDetectionEnabled:(BOOL)flag
{
  _formValueEncodingDetectionEnabled=flag;
};

//--------------------------------------------------------------------
//	isFormValueEncodingDetectionEnabled
-(BOOL)isFormValueEncodingDetectionEnabled 
{
  return _formValueEncodingDetectionEnabled;
};

//--------------------------------------------------------------------
//	formValueEncoding

-(NSStringEncoding)formValueEncoding 
{
  return _formValueEncoding?_formValueEncoding:_defaultFormValueEncoding;
};

//--------------------------------------------------------------------
//	formValueKeys

-(NSArray*)formValueKeys
{
  NSDictionary* formValues=nil;
  NSArray* formValueKeys=nil;

  NS_DURING
    {
      formValues=[self _formValues];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"GSWRequest formValueKeys");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    };
  NS_ENDHANDLER;
  formValueKeys=[formValues allKeys];

  return formValueKeys;
};

//--------------------------------------------------------------------
//	formValuesForKey:

-(NSArray*)formValuesForKey:(NSString*)key
{
  NSArray* formValuesForKey=nil;
  NSDictionary* formValues=nil;

  NS_DURING
    {
      formValues=[self _formValues];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"GSWRequest formValuesForKey");
      [localException raise];
    };
  NS_ENDHANDLER;
  formValuesForKey=[formValues objectForKey:key];

  return formValuesForKey;
};

//--------------------------------------------------------------------
//	formValueForKey:
// return id because GSWFileUpload
-(id)formValueForKey:(NSString*)key
{
  id formValue=nil;
  NSArray* formValuesForKey=nil;

  formValuesForKey=[self formValuesForKey:key];
  NSAssert3(!formValuesForKey || [formValuesForKey isKindOfClass:[NSArray class]],@"formValues:%@ ForKey:%@ is not a NSArray it's a %@",
            formValuesForKey,
            key,
            [formValuesForKey class]);
  if (formValuesForKey && [formValuesForKey count]>0)
    formValue=[formValuesForKey objectAtIndex:0];

  return formValue;
};

//--------------------------------------------------------------------
-(NSString*)stringFormValueForKey:(NSString*)key
{
  id value=nil;

  value=[self formValueForKey:key];
  if (value && ![value isKindOfClass:[NSString class]])
    value=[value description];

  return value;
}

//--------------------------------------------------------------------
-(NSNumber*)numberFormValueForKey:(NSString*)key
                    withFormatter:(NSNumberFormatter*)formatter
{
  NSNumber* value=nil;
  NSString* stringValue=nil;

  stringValue=[self stringFormValueForKey:key];
  if (stringValue && formatter)
    {
      NSString* errorDscr=nil;
      if (![formatter getObjectValue:&value
                      forString:stringValue
                      errorDescription:&errorDscr])
        {
          NSLog(@"Error: %@",errorDscr);
        };
    };

  return value;
}

//--------------------------------------------------------------------
-(NSCalendarDate*)dateFormValueForKey:(NSString*)key
                        withFormatter:(NSDateFormatter*)formatter
{
  NSCalendarDate* value=nil;
  NSString* stringValue=nil;

  stringValue= [self stringFormValueForKey:key];
  if (stringValue && formatter)
    {
      NSString* errorDscr=nil;
      if (![formatter getObjectValue:&value
                      forString:stringValue
                      errorDescription:&errorDscr])
        {
          NSLog(@"Error: %@",errorDscr);
        };
    };

  return value;
}

//--------------------------------------------------------------------
//	formValues
-(NSDictionary*)formValues
{
  NSDictionary* formValues=nil;

  NS_DURING
    {
      formValues=[self _formValues];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"GSWRequest formValues");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    };
  NS_ENDHANDLER;

  return formValues;
};

-(void)appendFormValue:(id)value
                forKey:(NSString*)key
{

  if (value)
    {
      NSMutableDictionary* formValues=nil;
      NSMutableArray* keyValues=nil;
      formValues=(NSMutableDictionary*)[self _formValues];
      if (formValues)
        {
          if (![formValues isKindOfClass:[NSMutableDictionary class]])
            {
              formValues=[[formValues mutableCopy] autorelease];
              ASSIGN(_formValues,formValues);
            };
        }
      else
        {
          formValues=(NSMutableDictionary*)[NSMutableDictionary dictionary];
          ASSIGN(_formValues,formValues);
        };
      keyValues=[formValues objectForKey:key];
      if (keyValues)
        {
          if (![keyValues isKindOfClass:[NSMutableArray class]])
            {
              keyValues=[[formValues mutableCopy] autorelease];
              [formValues setObject:keyValues
                          forKey:key];
            };
        }
      else
        {
          keyValues=(NSMutableArray*)[NSMutableArray array];
          [formValues setObject:keyValues
                      forKey:key];
        };
      [keyValues addObject:value];
    };

};

-(void)appendFormValues:(NSArray*)values
                 forKey:(NSString*)key
{
  if (values)
    {
      NSMutableDictionary* formValues=nil;
      NSMutableArray* keyValues=nil;
      formValues=(NSMutableDictionary*)[self _formValues];
      if (formValues)
        {
          if (![formValues isKindOfClass:[NSMutableDictionary class]])
            {
              formValues=[[formValues mutableCopy] autorelease];
              ASSIGN(_formValues,formValues);
            };
        }
      else
        {
          formValues=(NSMutableDictionary*)[NSMutableDictionary dictionary];
          ASSIGN(_formValues,formValues);
        };
      keyValues=[formValues objectForKey:key];
      if (keyValues)
        {
          if (![keyValues isKindOfClass:[NSMutableArray class]])
            {
              keyValues=[[formValues mutableCopy] autorelease];
              [formValues setObject:keyValues
                          forKey:key];
            };
        }
      else
        {
          keyValues=(NSMutableArray*)[NSMutableArray array];
          [formValues setObject:keyValues
                      forKey:key];
        };
      [keyValues addObjectsFromArray:values];
    };
};

//--------------------------------------------------------------------
//	uriValueKeys

-(NSArray*)uriElementKeys
{
  NSDictionary* uriElements=nil;
  NSArray* uriElementKeys=nil;

  NS_DURING
    {
      uriElements=[self _uriElements];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"GSWRequest uriElementKeys");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    };
  NS_ENDHANDLER;
  uriElementKeys=[uriElements allKeys];

  return uriElementKeys;
};

//--------------------------------------------------------------------
//	uriElementForKey:
-(NSString*)uriElementForKey:(NSString*)key
{
  NSString* uriElement=nil;
  NSDictionary* uriElements=nil;

  NS_DURING
    {
      uriElements=[self _uriElements];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"GSWRequest uriElementForKey:");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    };
  NS_ENDHANDLER;
  uriElement=[uriElements objectForKey:key];

  return uriElement;
};

//--------------------------------------------------------------------
//	uriElements
-(NSDictionary*)uriElements
{
  NSDictionary* uriElements=nil;

  NS_DURING
    {
      uriElements=[self _uriElements];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"GSWRequest uriElements");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    };
  NS_ENDHANDLER;

  return uriElements;
};

//--------------------------------------------------------------------
//	isFromClientComponent

-(BOOL)isFromClientComponent 
{
  //OK
  NSString* remoteInvocationPost=nil;
  BOOL isFromClientComponent=NO;

  remoteInvocationPost=[self formValueForKey:GSWFormValue_RemoteInvocationPost[GSWebNamingConv]];
  isFromClientComponent=(remoteInvocationPost!=nil);

  return isFromClientComponent;
};


//--------------------------------------------------------------------
-(void)setCookieFromHeaders
{
  NSDictionary* cookie=nil;
  NSString* cookieHeader=nil;

  cookieHeader=[self headerForKey:GSWHTTPHeader_Cookie];
  if (cookieHeader)
    {
      NSDictionary* cookieStrings=[cookieHeader dictionaryWithSep1:@"; "
                                                withSep2:@"="
                                                withOptionUnescape:NO];
      if (cookieStrings)
        {
          NSMutableDictionary* cookieTmp=[NSMutableDictionary dictionary];
          NSEnumerator* enumerator = [cookieStrings keyEnumerator];
          id key;
          id value;
          NSArray* newValue;
          id prevValue;

          while ((key = [enumerator nextObject]))
            {
              value=[cookieStrings objectForKey:key];
              if (value)
                {
                  id cookieValue=nil;
                  int index=0;
                  int valueCount=[value count];
                  for(index=0;index<valueCount;index++)
                    {
                      cookieValue=[value objectAtIndex:index];
                      if (cookieValue)
                        {
                          newValue=nil;
                          cookieValue=[GSWCookie cookieWithName:key
                                                 value:cookieValue];
                          prevValue=[cookie objectForKey:key];
                          if (prevValue)
                            newValue=[prevValue arrayByAddingObject:cookieValue];
                          else
                            newValue=[NSArray arrayWithObject:cookieValue];
                          [cookieTmp setObject:newValue
                                     forKey:key];
                        };
                    };
                };
            };		  
          cookie=[NSDictionary dictionaryWithDictionary:cookieTmp];
        };
    };
  ASSIGN(_cookie,cookie);

};

//--------------------------------------------------------------------
//	cookieValuesForKey:
-(NSArray*)cookieValuesForKey:(NSString*)key
{
  NSArray* cookieValuesForKey=nil;
  NSDictionary* cookieValues=nil;

  cookieValues=[self cookieValues];
  cookieValuesForKey=[cookieValues objectForKey:key];

  return cookieValuesForKey;
};

//--------------------------------------------------------------------
//	cookieValueForKey:
-(NSString*)cookieValueForKey:(NSString*)key
{
  NSArray* values=nil;
  NSString* cookieValueForKey=nil;

  values=[self cookieValuesForKey:key];
  if ([values count]>0)
    cookieValueForKey=[values objectAtIndex:0];

  return cookieValueForKey;
};

//--------------------------------------------------------------------
//	cookieValues
-(NSDictionary*)cookieValues
{
  NSDictionary* cookieValues=nil;

  cookieValues=[self _initCookieDictionary];

  return cookieValues;
};

//--------------------------------------------------------------------
// Dictionary of ccokie name / cookie value
-(NSDictionary*)_initCookieDictionary
{
  if (!_cookie)
    {
      NSString* cookieDescription=[self _cookieDescription];
      NSArray* cookiesArray=[cookieDescription componentsSeparatedByString:@"; "];
      NSMutableDictionary* cookies=[NSMutableDictionary dictionary];
      NSString* cookieString=nil;
      NSArray* cookie=nil;
      NSString* cookieName=nil;
      NSString* cookieValue=nil;
      NSArray* cookieArrayValue=nil;
      NSArray* cookiePrevValue=nil;
      int i=0;
      int cookiesArrayCount=[cookiesArray count];

      for(i=0;i<cookiesArrayCount;i++)
        {
          int cookieCount=0;
          cookieString=[cookiesArray objectAtIndex:i];
          cookie=[cookieString componentsSeparatedByString:@"="];

          cookieCount=[cookie count];
          if (cookieCount>0)
            {
              cookieName=[cookie objectAtIndex:0];
              if (cookieCount>1)
                cookieValue=[cookie objectAtIndex:1];
              else
                cookieValue=[NSString string];
              cookiePrevValue=[cookies objectForKey:cookieName];
              if (cookiePrevValue)
                cookieArrayValue=[cookiePrevValue arrayByAddingObject:cookieValue];
              else
                cookieArrayValue=[NSArray arrayWithObject:cookieValue];
              [cookies setObject:cookieArrayValue
                       forKey:cookieName];
            };		 
        };
      ASSIGN(_cookie,[NSDictionary dictionaryWithDictionary:cookies]);
    };
  return _cookie;
};

//--------------------------------------------------------------------
-(NSDictionary*)_cookieDictionary
{
  return [self _initCookieDictionary];
};

//--------------------------------------------------------------------
-(NSString*)_cookieDescription
{
  //OK
  NSString* cookieHeader=nil;

  cookieHeader=[self headerForKey:GSWHTTPHeader_Cookie];
  if (!cookieHeader)
    cookieHeader=[self headerForKey:GSWHTTPHeader_CookieStupidIIS];// God damn it

  return cookieHeader;
};

-(NSArray*)cookies
{
  // build super->cookies
  if (!_cookies)
    {
      NSDictionary* cookies = nil;
      NSEnumerator* keysEnum = nil;
      NSString* key = nil;
      [self _initCookies]; // super cookies init
      cookies=[self cookieValues];
      keysEnum=[cookies keyEnumerator];
      key=nil;
      while((key=[keysEnum nextObject]))
        {
          NSString* value=[cookies objectForKey:key];
          [_cookies addObject:[GSWCookie cookieWithName:key
                                         value:value]];
        }
    };
  return _cookies;
};


//--------------------------------------------------------------------
-(NSString*)sessionIDFromValuesOrCookie
{
  return [self sessionIDFromValuesOrCookieByLookingForCookieFirst:[[self class]_lookForIDsInCookiesFirst]];
};

//--------------------------------------------------------------------
-(NSString*)sessionIDFromValuesOrCookieByLookingForCookieFirst:(BOOL)lookCookieFirst
{
  NSString* sessionID=nil;

  sessionID=[self uriOrFormOrCookiesElementForKey:GSWKey_SessionID[GSWebNamingConv]
                  byLookingForCookieFirst:lookCookieFirst];
  if (!sessionID)
    {
      sessionID=[self uriOrFormOrCookiesElementForKey:GSWKey_SessionID[GSWebNamingConvInversed]
                      byLookingForCookieFirst:lookCookieFirst];
    };

  return sessionID;
};

//--------------------------------------------------------------------
//	sessionID
// nil if first request of session

-(NSString*)sessionID 
{
  return [self sessionIDFromValuesOrCookie];
};

//--------------------------------------------------------------------
-(NSString*)requestHandlerPath
{
  return [_uri urlRequestHandlerPath];
};

//--------------------------------------------------------------------
//	adaptorPrefix

-(NSString*)adaptorPrefix
{
  return [_uri urlPrefix];
};


//--------------------------------------------------------------------
//	applicationName

-(NSString*)applicationName
{
  return [_uri urlApplicationName];
};

//--------------------------------------------------------------------
//	applicationNumber
// nil if request can be handled by any instance

-(int)applicationNumber
{
  //OK
  if (_applicationNumber==-9999)
    {
      NSDictionary* uriElements=[self uriOrFormOrCookiesElements];
      NSString* applicationNumber=[uriElements objectForKey:GSWKey_InstanceID[GSWebNamingConv]];
      if (!applicationNumber)
        applicationNumber=[uriElements objectForKey:GSWKey_InstanceID[GSWebNamingConvInversed]];
      _applicationNumber=[applicationNumber intValue];
    };
  return _applicationNumber;

};


- (void) _setApplicationNumber:(int) newValue force:(BOOL) yn
{
  if (yn || (_applicationNumber==-9999))
  {
    _applicationNumber = newValue;
  }
}


//--------------------------------------------------------------------
-(NSString*)requestHandlerKey
{
  NSString* requestHandlerKey=[_uri urlRequestHandlerKey];
  return requestHandlerKey;
};


//--------------------------------------------------------------------
-(NSDictionary*)_extractValuesFromFormData:(NSData*)aFormData
                              withEncoding:(NSStringEncoding)encoding
{
  NSArray* allKeys=nil;
  NSDictionary* tmpFormData=nil;
  NSString* formString=nil;
  int allKeysCount=0;


// CHECKME: we should use ACSII encoding here? dave@turbocat.de
// according to the the standard http://www.w3.org/International/O-URL-code.html,
// URIs are encoded in NSASCIIStringEncoding with escape sequences cooresponding
// to the hexadecimal value of the UTF-8 encoding.  Therefore the encoding should
// only be relevant for -dictionaryQueryString and not for formString.
// Yet it seems that browsers do not use UTF-8 consistently but the encoding 
// specified by the response.

  formString=[[[NSString alloc]initWithData:aFormData
                               encoding:encoding] autorelease];

  tmpFormData=[formString dictionaryQueryStringWithEncoding: encoding];

  allKeys=[tmpFormData allKeys];

  allKeysCount=[allKeys count];

  
  if (allKeysCount>0)
    {
      int i=0;
      NSString* key=nil;
      BOOL ismapCoordsFound=NO;
      NSArray* value=nil;
      for(i=0;i<allKeysCount && !ismapCoordsFound;i++)
        {
          key=[allKeys objectAtIndex:i];
          value=[tmpFormData objectForKey:key];
          if ([value count]==1
              &&[[value objectAtIndex:0]length]==0
              &&[key ismapCoordx:NULL
                     y:NULL])
            {
              NSMutableDictionary* tmpFormDataMutable=[[tmpFormData mutableCopy]autorelease];
              ismapCoordsFound=YES;
              [tmpFormDataMutable setObject:[NSArray arrayWithObject:key]
                                  forKey:GSWKey_IsmapCoords[GSWebNamingConv]];
              [tmpFormDataMutable removeObjectForKey:key];
              tmpFormData=[NSDictionary dictionaryWithDictionary:tmpFormDataMutable];
            };
        };
    };

  return tmpFormData;
};

//--------------------------------------------------------------------
-(NSStringEncoding)_formValueEncodingFromFormData:(NSData*)aFormData
{
  return [self formValueEncoding]; //TODO
};

//--------------------------------------------------------------------
-(NSData*)_formData
{
  //OK
  NSData* data=nil;

  if ([_method isEqualToString:GSWHTTPHeader_MethodGet])
    {
      NSString* urlQueryString=[self _urlQueryString];

      data=[urlQueryString dataUsingEncoding: [self formValueEncoding]];//??
    }
  else if ([_method isEqualToString:GSWHTTPHeader_MethodPost])
    {
      data=_contentData;
    };

  return data;
};

//--------------------------------------------------------------------
-(NSString*)_contentType
{
  //OK
  NSString* contentType=nil;
  NSRange range;

  contentType=[self headerForKey:GSWHTTPHeader_ContentType];

  //We can get something like 
  // multipart/form-data; boundary=---------------------------1810101926251
  // In this case, return only multipart/form-data
  if (contentType) 
    {
      range=[contentType rangeOfString:@";"];
      if (range.length>0)
        {
          contentType=[contentType substringToIndex:range.location];
        };
    };
  return contentType;
};

//--------------------------------------------------------------------
-(NSString*)_urlQueryString
{
  //OK
  NSString* urlQueryString=nil;

  urlQueryString=[_uri urlQueryString];

  return urlQueryString;
};

//--------------------------------------------------------------------
// FIXME:check if that is needed for 4.5 compat
-(BOOL)_isUsingWebServer
{
  return _isUsingWebServer;
}

// this is legal at least in some versions of WO. -- dw
-(BOOL)isUsingWebServer
{
  return _isUsingWebServer;
}

-(void)_setIsUsingWebServer:(BOOL)flag
{
  _isUsingWebServer=flag;
}

-(void)setIsUsingWebServer:(BOOL)flag
{
  _isUsingWebServer=flag;
}

//--------------------------------------------------------------------
-(BOOL)_isSessionIDInRequest
{
  id ID=nil;
  NSDictionary* uriElements=[self uriElements];
  ID=[uriElements objectForKey:GSWKey_SessionID[GSWebNamingConv]];
  if (!ID)
    ID=[uriElements objectForKey:GSWKey_SessionID[GSWebNamingConvInversed]];
  return (ID!=nil);
};

//--------------------------------------------------------------------
-(BOOL)_isSessionIDInCookies
{
  id ID=nil;
  ID=[self cookieValueForKey:GSWKey_SessionID[GSWebNamingConv]];
  if (!ID)
    ID=[self cookieValueForKey:GSWKey_SessionID[GSWebNamingConvInversed]];
  return (ID!=nil);
};

//--------------------------------------------------------------------
-(BOOL)_isSessionIDInFormValues
{
  id ID=nil;
  ID=[self formValueForKey:GSWKey_SessionID[GSWebNamingConv]];
  if (!ID)
    ID=[self formValueForKey:GSWKey_SessionID[GSWebNamingConvInversed]];
  return (ID!=nil);
};

//--------------------------------------------------------------------
-(id)_completeURLWithRequestHandlerKey:(NSString*)key
                                  path:(NSString*)path
                           queryString:(NSString*)queryString
                              isSecure:(BOOL)isSecure
                                  port:(int)port
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
/** urlPrefix will prefix url (before the /GSWeb) **/
-(GSWDynamicURLString*)_urlWithURLPrefix:(NSString*)urlPrefix
                       requestHandlerKey:(NSString*)key
                                    path:(NSString*)path
                             queryString:(NSString*)queryString
{
  GSWDynamicURLString* url=nil;

  url=[self _applicationURLPrefix];

  if (urlPrefix)
    [url setURLPrefix:[urlPrefix stringByAppendingString:[url urlPrefix]]];

  [url setURLRequestHandlerKey:key];
  [url setURLRequestHandlerPath:path];
  [url setURLQueryString:queryString];

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)_urlWithRequestHandlerKey:(NSString*)key
                                            path:(NSString*)path
                                     queryString:(NSString*)queryString
{
  GSWDynamicURLString* url=nil;

  url=[self _urlWithURLPrefix:nil
            requestHandlerKey:key
            path:path
            queryString:queryString];

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)_applicationURLPrefix
{
  GSWDynamicURLString* applicationURLPrefix=[[_uri copy] autorelease];
  [applicationURLPrefix setURLRequestHandlerKey:nil];
  [applicationURLPrefix setURLRequestHandlerPath:nil];
  [applicationURLPrefix setURLQueryString:nil];
  return applicationURLPrefix;
};

//--------------------------------------------------------------------
-(NSDictionary*)_formValues
{
  //OK
  if (!_formValues || !_finishedParsingMultipartFormData)
    {
      NSString* contentType=[self _contentType];

      if (!contentType || [contentType isEqualToString:GSWHTTPHeader_FormURLEncoded])
        {
          [self _getFormValuesFromURLEncoding];
        }
      else if ([contentType isEqualToString:GSWHTTPHeader_MultipartFormData])
        {
          [self _getFormValuesFromMultipartFormData];
        }
      else
        {
          //NSDebugMLLog(@"requests",@"contentType=%@",contentType);
        };
      _finishedParsingMultipartFormData=YES;
    };

  return _formValues;
};

//--------------------------------------------------------------------
-(void)_getFormValuesFromURLEncoding
{
  NSData* formData=nil;

  formData=[self _formData];

  if (formData)
    {
      NSStringEncoding formValueEncoding=[self _formValueEncodingFromFormData:formData];
      NSDictionary* formValues=nil;

      formValues=[self _extractValuesFromFormData:formData
                       withEncoding:formValueEncoding];
      ASSIGN(_formValues,formValues);
    };
};

//--------------------------------------------------------------------
+(BOOL)_lookForIDsInCookiesFirst
{
  return NO;
}

//--------------------------------------------------------------------
-(BOOL)_hasFormValues
{
  NSDictionary* formValues=[self _formValues];
  return [formValues count]>0;
};

//--------------------------------------------------------------------

-(void)_getFormValuesFromMultipartFormData
{
  NSMutableDictionary* formValues=nil;
  GSMimeParser* parser=nil;
  id key=nil;
  NSData* headersData=nil;
  NSMutableString* headersString=[NSMutableString string];
  NSDictionary* headers=nil;
  NSEnumerator* enumerator=nil;
  IMP headersString_appendStringIMP=NULL;
  NSStringEncoding e;

  formValues=(NSMutableDictionary*)[NSMutableDictionary dictionary];

  // Append Each Header
  headers=[self headers];
  enumerator=[headers keyEnumerator];
  while((key=[enumerator nextObject]))
    {
      NSArray* value=[headers objectForKey:key];
      int i=0;
      int count=[value count];
      for(i=0;i<count;i++)
        {
          // append "key: value\n" to headersString
          GSWeb_appendStringWithImpPtr(headersString,
                                       &headersString_appendStringIMP,
                                       key);
          GSWeb_appendStringWithImpPtr(headersString,
                                       &headersString_appendStringIMP,
                                       @": ");
          GSWeb_appendStringWithImpPtr(headersString,
                                       &headersString_appendStringIMP,
                                       [value objectAtIndex:i]);
          GSWeb_appendStringWithImpPtr(headersString,
                                       &headersString_appendStringIMP,
                                       @"\n");
        };
    };

  // Append \n to specify headers end.
  GSWeb_appendStringWithImpPtr(headersString,
                               &headersString_appendStringIMP,
                               @"\n");

  // headersData=[headersString dataUsingEncoding:[self formValueEncoding]];
  // NSASCIIStringEncoding should be ok dave@turbocat.de
  headersData=[headersString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

  parser=[GSMimeParser mimeParser];
  [parser parse:headersData];
  [parser expectNoHeaders];

  e = [self formValueEncoding];
  switch (e)
    {
      case NSISOLatin1StringEncoding:
	[parser setDefaultCharset: @"iso-8859-1"];
	break;
      case NSUTF8StringEncoding:
	[parser setDefaultCharset: @"utf-8"];
	break;
      default:
	[parser setDefaultCharset: 
	   [GSObjCClass([parser mimeDocument]) charsetFromEncoding: e]];
	break;
    }

  if ([parser parse:_contentData])
    [parser parse:nil];
  if ([parser isComplete] == NO)
    {
          //TODO
    }
  else
    {      
      GSMimeDocument* document = [parser mimeDocument];
      NSArray* content=nil;
      NSString* contentSubtype=nil;

      content=[document content];
      contentSubtype=[document contentSubtype];

      if ([contentSubtype isEqual:@"form-data"])
        {
          if (![content isKindOfClass:[NSArray class]])
            {
              //TODO
            }
          else
            {
              int i=0;
              int count=[content count];
              for(i=0;i<count;i++)
                {
                  GSMimeDocument* aDoc=[content objectAtIndex:i];
                  GSMimeHeader* contentDispositionHeader=nil;
                  NSString* contentDispositionValue=nil;
                  NSDictionary* contentDispositionParams=nil;
                  id aDocContent=nil;
                  NSAssert2([aDoc isKindOfClass:[GSMimeDocument class]],
                            @"Document is not a GSMimeDocument but a %@:\n%@",
                            [aDoc class],aDoc);
                  aDocContent=[aDoc content];
                  contentDispositionHeader=[aDoc headerNamed:@"content-disposition"];
                  contentDispositionValue=[contentDispositionHeader value];
                  contentDispositionParams=[contentDispositionHeader parameters];
                  if ([contentDispositionValue isEqual:@"form-data"])
                    {
                      NSString* formDataName=[contentDispositionParams objectForKey:@"name"];
                      if (!formDataName)
                        {
                          ExceptionRaise(@"GSWRequest",
                                         @"GSWRequest: No name \n%@\n",
                                         aDoc);
                        }
                      else
                        {
                          NSString* paramName=nil;
                          NSEnumerator* paramNamesEnumerator=[contentDispositionParams keyEnumerator];
                          while((paramName=[paramNamesEnumerator nextObject]))
                            {
                              if (![paramName isEqualToString:@"name"])
                                {
                                  NSArray* previous=nil;
                                  NSString* paramFormValueName=nil;
                                  id paramValue=nil;

                                  paramValue=[contentDispositionParams objectForKey:paramName];
                                  paramFormValueName=[NSString stringWithFormat:@"%@.%@",formDataName,paramName];
                                  previous=[formValues objectForKey:paramFormValueName];

                                  if (previous)
                                    [formValues setObject:[previous arrayByAddingObject:paramValue]
                                                forKey:paramFormValueName];                                  
                                  else
                                    [formValues setObject:[NSArray arrayWithObject:paramValue]
                                                forKey:paramFormValueName];
                                };
                            };
                          if (aDocContent)
                            {
                              NSArray* previous=[formValues objectForKey:formDataName];
                              if (previous)
                                [formValues setObject:[previous arrayByAddingObject:aDocContent]
                                            forKey:formDataName];                                  
                              else
                                [formValues setObject:[NSArray arrayWithObject:aDocContent]
                                            forKey:formDataName];
                            };
                        };
                    };
                };
            };
        };
    };
  ASSIGN(_formValues,formValues);
};

//--------------------------------------------------------------------
-(NSArray*)_decodeMultipartBody:(NSData*)aBody
                       boundary:(NSString*)aBoundary
{
  NSData* dataBoundary=nil;
  NSString* boundaryString=nil;
  NSArray* parts=nil;
  int i=0;
  NSData* tmpData=nil;
  int partsCount=0;

  boundaryString=[NSString stringWithFormat:@"--%@\r\n",aBoundary];//Add "--" and "\r\n"
  dataBoundary=[boundaryString dataUsingEncoding:[self formValueEncoding]];//TODO
  parts=[aBody componentsSeparatedByData:dataBoundary];

  partsCount=[parts count];

  for(i=0;i<partsCount;i++)
    {
      tmpData=[parts objectAtIndex:i];
      if ([tmpData length]<400)
        {
          NSString* _dataString=nil;
          _dataString=[[[NSString alloc]initWithData:tmpData
                                        encoding:[self formValueEncoding]]autorelease];
        }
      else
        {
          //NSDebugMLLog(@"requests",@"tmpData=%@",tmpData);
      };
    };

  // The 1st part should be empty (or it's only a warning message...)
  if (partsCount>0)
    {
      parts=[parts subarrayWithRange:NSMakeRange(1,partsCount-1)];
      partsCount=[parts count];
    };

  // Now deleting last \r\n of each object
  parts=[parts mutableCopy];
  for(i=0;i<partsCount;i++)
    {
      tmpData=[parts objectAtIndex:i];
      if (i==partsCount-1)
        {
          //Delete the last \r\nseparator--\r\n
          boundaryString=[NSString stringWithFormat:@"\r\n%@--\r\n",aBoundary];
          dataBoundary=[boundaryString dataUsingEncoding:[self formValueEncoding]];//TODO
          tmpData=[tmpData dataByDeletingLastBytesCount:[dataBoundary length]];
        }
      else
        {
          tmpData=[tmpData dataByDeletingLastBytesCount:2];
        };
      [(NSMutableArray*)parts replaceObjectAtIndex:i
                        withObject:tmpData];
    };
  
  for(i=0;i<partsCount;i++)
    {
      tmpData=[parts objectAtIndex:i];
      if ([tmpData length]<400)
        {
          NSString* dataString=nil;
          dataString=[[[NSString alloc]initWithData:tmpData
                                       encoding:[self formValueEncoding]]autorelease];
          
        }
      else
        {
        };
    };

  return parts;
};

//--------------------------------------------------------------------
// Convert:
// <436f6e74 656e742d 44697370 6f736974 696f6e3a 20666f72 6d2d6461 74613b20 6e616d65 3d22392e 31223b20 66696c65 6e616d65 3d22433a 5c54454d 505c7a61 686e2e74 7874220d 0a436f6e 74656e74 2d547970 653a2074 6578742f 706c6169 6e0d0a0d 0a415145 41414151 774d4441 79666f30 546c4e2b 58586843 5769314b 50516351 59735736 77426d33 6f526172 47365846 334c7a64 55563766 4e39654b 6b764b4a 43717150 59674172 50593748 63783979 4436506b 66774a75 50465a41 412f3034 63446c50 72485256 70537a41 35676647 38623645 72443141 58372b70 67734c50 75304b4d 770d0a0d 0a>
// Into:
//	(
//		{
//			"content-disposition" = "form-data; name=\"9.1\"; filename=\"C:\\TEMP\\zahn.txt\"";
//			"content-type" = text/plain;
//		},
//		<41514541 41415177 4d444179 666f3054 6c4e2b58 58684357 69314b50 51635159 73573677 426d336f 52617247 36584633 4c7a6455 5637664e 39654b6b 764b4a43 71715059 67417250 59374863 78397944 36506b66 774a7550 465a4141 2f303463 446c5072 48525670 537a4135 67664738 62364572 44314158 372b7067 734c5075 304b4d77 0d0a0d0a >
//	)

// convert:
// <436f6e74 656e742d 44697370 6f736974 696f6e3a 20666f72 6d2d6461 74613b20 6e616d65 3d22392e 33220d0a 0d0a7375 626d6974 >
// Into:
//	(
//		{
//			"content-disposition" = "form-data; name=\"9.3\"";
//		},
//		<7375626d 6974>
//	)
-(NSArray*)_parseData:(NSData*)aData
{
  NSArray* parsedData=nil;
  NSMutableDictionary* tmpHeaders=[NSMutableDictionary dictionary];
  NSData* tmpData=nil;
  if (aData)
    {
      unsigned int tmpDataLength=[aData length];
      const unsigned char* bytes=(unsigned char*)[aData bytes];
      BOOL tmpHeadersEnd=NO;
      int start=0;
      int i=0;
      for(i=0;i<tmpDataLength-1 && !tmpHeadersEnd;i++) // -1 for \n
        {
          //Parse Headers
          if (bytes[i]=='\r' && bytes[i+1]=='\n')
            {
              if (i-start==0)//Empty Line: End Of Headers
                tmpHeadersEnd=YES;
              else
                {
                  NSRange range;
                  NSString* key=@"";
                  NSString* value=@"";
                  NSData* headerData=[aData subdataWithRange:NSMakeRange(start,i-start)];
                  NSString* tmpHeaderString=[[[NSString alloc]initWithData:headerData
                                                              encoding:[self formValueEncoding]]autorelease];
                  range=[tmpHeaderString rangeOfString:@": "];
                  if (range.length>0)
                    {
                      key=[tmpHeaderString  substringToIndex:range.location];
                      key=[key lowercaseString];
                      if (range.location+1<[tmpHeaderString length])
                        {
                          value=[tmpHeaderString substringFromIndex:range.location+1];
                          value=[value stringByTrimmingSpaces];
                        };
                    };
                  [tmpHeaders setObject:value
                              forKey:key];
                };
              i++; //Pass the '\n'
              start=i+1;
            };
        };
      if (!tmpHeadersEnd)
        {
          //TODO error
          NSLog(@"Error in %s line %d",__PRETTY_FUNCTION__, __LINE__);
        }
      else
        {
          tmpData=[aData subdataWithRange:NSMakeRange(i,tmpDataLength-i)];
          //I'm not sure this is good but it avoid 2 bytes datas on an empty input type=file located t the end of the request)
          //It may be better to deal with this few lines up, around (tmpHeadersEnd=YES;)
          
          if ([tmpData length]==2)
            {
              const unsigned char* bytes=(unsigned char*)[tmpData bytes];
              if (bytes[0]=='\r' && bytes[1]=='\n')
                tmpData=[NSData data];
            };
        };
      tmpHeaders=[NSDictionary dictionaryWithDictionary:tmpHeaders];
      parsedData=[NSArray arrayWithObjects:tmpHeaders,tmpData,nil];
    };
  return parsedData;
};

//--------------------------------------------------------------------
/*
- convert "multipart/form-data; boundary=---------------------------1810101926251"
into
  {
    boundary = "---------------------------1810101926251";
    "multipart/form-data" = "multipart/form-data"; 
  }

- convert form-data; name="9.1"; filename="C:\TEMP\zahn.txt"
into
{filename = "C:\\TEMP\\zahn.txt"; "form-data" = "form-data"; name = 9.1; }

- convert form-data; name="9.3"
into
{"form-data" = "form-data"; name = 9.3; }
*/

-(NSDictionary*)_parseOneHeader:(NSString*)aHeader
{
  //TODO Process quoted string !
  NSMutableDictionary* parsedParts=nil;
  NSArray* headerParts=nil;
  int partIndex=0;
  int partCount=0;
  NSString* part=nil;

  parsedParts=(NSMutableDictionary*)[NSMutableDictionary dictionary];
  headerParts=[aHeader componentsSeparatedByString:@";"];
  partCount=[headerParts count];
  for(partIndex=0;partIndex<partCount;partIndex++)
    {
      NSArray* parsedPart=nil;
      int parsedPartCount=0;
      NSString* key=nil;
      NSString* value=nil;
      part=[headerParts objectAtIndex:partIndex];
      part=[part stringByTrimmingSpaces];
      parsedPart=[part componentsSeparatedByString:@"="];
      parsedPartCount=[parsedPart count];
      switch(parsedPartCount)
        {
        case 1:
          key=[parsedPart objectAtIndex:0];
          value=key;
          break;
        case 2:
          key=[parsedPart objectAtIndex:0];
          value=[parsedPart objectAtIndex:1];
          break;
        default:
          NSAssert1(NO,@"objects number != 1 or 2 in %@",parsedPart);
          //TODO Error
          break;
        };
      if (key && value)
        {
          if ([value isQuotedWith:@"\""])
            value=[value stringWithoutQuote:@"\""];
          [parsedParts setObject:value
                       forKey:key];
        };
    };
  parsedParts=[NSDictionary dictionaryWithDictionary:parsedParts];

  return parsedParts;
};



//--------------------------------------------------------------------
-(id)nonNilFormValueForKey:(NSString*)key
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};



//--------------------------------------------------------------------
-(id)dictionaryWithKeys:(id)unknown
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)selectedButtonName
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)valueFromImageMapNamed:(NSString*)aName
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)valueFromImageMapNamed:(NSString*)aName
                inFramework:(NSString*)aFramework
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)valueFromImageMap:(id)unknown
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)yCoord
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)xCoord
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)formKeyWithSuffix:(NSString*)suffix
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};


//--------------------------------------------------------------------
//	applicationHost
// nil if request can be handled by any instance

-(NSString*)applicationHost 
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
//	pageName
-(NSString*)pageName 
{
  NSString* pageName=nil;
  NSDictionary* uriElements=[self uriOrFormOrCookiesElements];
  pageName=[uriElements objectForKey:GSWKey_PageName[GSWebNamingConv]];
  if (!pageName)
    pageName=[uriElements objectForKey:GSWKey_PageName[GSWebNamingConvInversed]];

  return pageName;
};

//--------------------------------------------------------------------
//	senderID
-(NSString*)senderID 
{
  NSString* senderID=nil;
  NSDictionary* uriElements=[self uriOrFormOrCookiesElements];
  senderID=[uriElements objectForKey:GSWKey_ElementID[GSWebNamingConv]];
  if (!senderID)
    senderID=[uriElements objectForKey:GSWKey_ElementID[GSWebNamingConvInversed]];
  return senderID;
};

//--------------------------------------------------------------------
//	contextID

-(NSString*)contextID 
{
  NSString* contextID=nil;
  NSDictionary* uriElements=nil;

  uriElements=[self uriOrFormOrCookiesElements];
  contextID=[uriElements objectForKey:GSWKey_ContextID[GSWebNamingConv]];
  if (!contextID)
    contextID=[uriElements objectForKey:GSWKey_ContextID[GSWebNamingConvInversed]];

  return contextID;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)uriOrFormOrCookiesElements
{
  return [self uriOrFormOrCookiesElementsByLookingForCookieFirst:[[self class]_lookForIDsInCookiesFirst]];
};

//--------------------------------------------------------------------
//NDFN
-(id)uriOrFormOrCookiesElementForKey:(NSString*)key
             byLookingForCookieFirst:(BOOL)lookCookieFirst
{
  id element=nil;

  if (lookCookieFirst)
    element=[self cookieValueForKey:key];

  if (!element)
    {
      element=[self uriElementForKey:key];
      if (!element)
        {
          element=[self formValueForKey:key];
          if (!element && !lookCookieFirst)
            element=[self cookieValueForKey:key];
        };
    };

  return element;
}
//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)uriOrFormOrCookiesElementsByLookingForCookieFirst:(BOOL)lookCookieFirst
{
  NSMutableDictionary* elements=nil;
  NSString* tmpString=nil;

  elements=(NSMutableDictionary*)[NSMutableDictionary dictionary];

  //SessionID
  tmpString=[self sessionIDFromValuesOrCookieByLookingForCookieFirst:lookCookieFirst];
  if (tmpString)
    [elements setObject:tmpString
              forKey:GSWKey_SessionID[GSWebNamingConv]];

  //PageName
  tmpString=[self uriOrFormOrCookiesElementForKey:GSWKey_PageName[GSWebNamingConv]
                  byLookingForCookieFirst:lookCookieFirst];
  if (!tmpString)
    {
      tmpString=[self uriOrFormOrCookiesElementForKey:GSWKey_PageName[GSWebNamingConvInversed]
                      byLookingForCookieFirst:lookCookieFirst];
    };
  if (tmpString)
    [elements setObject:tmpString
              forKey:GSWKey_PageName[GSWebNamingConv]];

  //ContextID
  tmpString=[self uriOrFormOrCookiesElementForKey:GSWKey_ContextID[GSWebNamingConv]
                  byLookingForCookieFirst:lookCookieFirst];
  if (!tmpString)
    {
      tmpString=[self uriOrFormOrCookiesElementForKey:GSWKey_ContextID[GSWebNamingConvInversed]
                      byLookingForCookieFirst:lookCookieFirst];
    };
  if (tmpString)
    [elements setObject:tmpString
              forKey:GSWKey_ContextID[GSWebNamingConv]];

  //ElementID
  tmpString=[self uriOrFormOrCookiesElementForKey:GSWKey_ElementID[GSWebNamingConv]
                  byLookingForCookieFirst:lookCookieFirst];
  if (!tmpString)
    {
      tmpString=[self uriOrFormOrCookiesElementForKey:GSWKey_ElementID[GSWebNamingConvInversed]
                      byLookingForCookieFirst:lookCookieFirst];
    };
  if (tmpString)
    [elements setObject:tmpString
              forKey:GSWKey_ElementID[GSWebNamingConv]];

  //InstanceID
  tmpString=[self uriOrFormOrCookiesElementForKey:GSWKey_InstanceID[GSWebNamingConv]
                  byLookingForCookieFirst:lookCookieFirst];
  if (!tmpString)
    {
      tmpString=[self uriOrFormOrCookiesElementForKey:GSWKey_InstanceID[GSWebNamingConvInversed]
                      byLookingForCookieFirst:lookCookieFirst];
    };
  if (tmpString)
    [elements setObject:tmpString
              forKey:GSWKey_InstanceID[GSWebNamingConv]];

  //DataID
  tmpString=[self uriOrFormOrCookiesElementForKey:GSWKey_Data[GSWebNamingConv]
                  byLookingForCookieFirst:lookCookieFirst];
  if (!tmpString)
    {
      tmpString=[self uriOrFormOrCookiesElementForKey:GSWKey_Data[GSWebNamingConvInversed]
                      byLookingForCookieFirst:lookCookieFirst];
    };
  if (tmpString)
    [elements setObject:tmpString
              forKey:GSWKey_Data[GSWebNamingConv]];

  return elements;
};

//--------------------------------------------------------------------
-(NSDictionary*)_uriElements
{
  //OK

  if (!_uriElements)
    {
      NSMutableDictionary* dict=nil;
      NSArray* requestHandlerPathArray=nil;
      int index=0;
      NSString* tmpString=nil;
      NSString* gswpage=nil;
      NSString* gswsid=nil;
      NSString* gswcid=nil;
      NSString* gsweid=nil;
      NSString* gswinst=nil;
      NSString* requestHandlerKey=nil;
      int applicationNumber;
      dict=[[NSMutableDictionary new] autorelease];

      requestHandlerKey=[((GSWDynamicURLString*)[self uri]) urlRequestHandlerKey];

      if (!requestHandlerKey
          || (![requestHandlerKey isEqualToString:GSWDirectActionRequestHandlerKey[GSWebNamingConv]]
              &&![requestHandlerKey isEqualToString:GSWDirectActionRequestHandlerKey[GSWebNamingConvInversed]]))
        {
          int requestHandlerPathArrayCount=0;
          requestHandlerPathArray=[self requestHandlerPathArray];

          requestHandlerPathArrayCount=[requestHandlerPathArray count];
          if (requestHandlerPathArrayCount>index)
            {
              tmpString=[requestHandlerPathArray objectAtIndex:index];

              if ([tmpString hasSuffix:GSWPagePSuffix[GSWebNamingConv]])
                {
                  gswpage=[tmpString stringByDeletingSuffix:GSWPagePSuffix[GSWebNamingConv]];
                  index++;
                }
              else if ([tmpString hasSuffix:GSWPagePSuffix[GSWebNamingConvInversed]])
                {
                  gswpage=[tmpString stringByDeletingSuffix:GSWPagePSuffix[GSWebNamingConvInversed]];
                  index++;
                };

              if (requestHandlerPathArrayCount>index)
                {
                  gswsid=[requestHandlerPathArray objectAtIndex:index];
                  index++;

                  if (requestHandlerPathArrayCount>index)
                    {
                      NSString* senderID=[requestHandlerPathArray objectAtIndex:index];
                      index++;

                      if (senderID && [senderID length]>0)
                        {
                          NSArray* senderIDParts=[senderID componentsSeparatedByString:@"."];

                          if ([senderIDParts count]>0)
                            {
                              tmpString=[senderIDParts objectAtIndex:0];

                              if (tmpString && [tmpString length]>0)
                                gswcid=tmpString;
                          
                              if ([senderIDParts count]>1)
                                {
                                  tmpString=[[senderIDParts subarrayWithRange:
                                                              NSMakeRange(1,[senderIDParts count]-1)]
                                              componentsJoinedByString:@"."];

                                  if (tmpString && [tmpString length]>0)
                                    {
                                      gsweid=tmpString;
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };
  
      if (gswpage)
        [dict setObject:gswpage
              forKey:GSWKey_PageName[GSWebNamingConv]];
  
      if (gswsid)
        [dict setObject:gswsid
              forKey:GSWKey_SessionID[GSWebNamingConv]];

      if (gswcid)
        [dict setObject:gswcid
              forKey:GSWKey_ContextID[GSWebNamingConv]];
  
      if (gsweid)
        [dict setObject:gsweid
              forKey:GSWKey_ElementID[GSWebNamingConv]];
  
      applicationNumber=[_uri urlApplicationNumber];
      if (applicationNumber<0)
        {
          NSString* tmpString2=[self cookieValueForKey:GSWKey_InstanceID[GSWebNamingConv]];
          if (!tmpString2)
            tmpString2=[self cookieValueForKey:GSWKey_InstanceID[GSWebNamingConvInversed]];
          if (tmpString2)
            applicationNumber=[gswinst intValue];
        };
      if (applicationNumber>=0)
        [dict setObject:GSWIntToNSString(applicationNumber)
              forKey:GSWKey_InstanceID[GSWebNamingConv]];
  
      ASSIGN(_uriElements,[NSDictionary dictionaryWithDictionary:dict]);
    };
  return _uriElements;
};

//--------------------------------------------------------------------
-(void)_validateAPI
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end
