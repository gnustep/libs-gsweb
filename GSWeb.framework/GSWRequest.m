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

//====================================================================
@implementation GSWValueQualityHeaderPart

/** Returns an array of values ordered by quality descending **/
+(NSArray*)valuesFromHeaderString:(NSString*)string
{
  NSArray* values=nil;
  NSArray* valuesAndQualities=nil;
  int count=0;
  LOGObjectFnStart();
  valuesAndQualities=[string componentsSeparatedByString:@","];
  count=[valuesAndQualities count];
  NSDebugMLog(@"string=%@",string);
  if (count>0)
    {
      int i=0;
      NSMutableArray* qvs=[NSMutableArray array];
      for(i=0;i<count;i++)
        {
          NSString* string=[valuesAndQualities objectAtIndex:i];
          GSWValueQualityHeaderPart* qv=[GSWValueQualityHeaderPart 
                                           valueQualityHeaderPartWithString:string];
          NSDebugMLog(@"string=%@",string);
          NSDebugMLog(@"qv=%@",qv);
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
              NSString* value=[[qvs objectAtIndex:i] value];
              for(j=i+1;j<count;j++)
                {
                  NSString* value2=[[qvs objectAtIndex:j] value];
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
  NSDebugMLog(@"values=%@",values);
  LOGObjectFnStop();
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
};
@end

//====================================================================
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
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      NSDebugMLLog(@"requests",@"aMethod=%@",aMethod);
      if ([aMethod length]==0)
        {
          ExceptionRaise(@"GSRequest",@"Empty/Null method during initialization");
        }
      else
        {
          NSDebugMLLog(@"requests",@"anURL=%@",anURL);
          if ([anURL length]==0)
            {
              ExceptionRaise(@"GSRequest",@"Empty/Null uri during initialization");
            }
          else
            {              
              NSDebugMLLog(@"requests",@"aVersion=%@",aVersion);
              if ([aVersion length]==0)
                {
                  ExceptionRaise(@"GSRequest",@"Empty/Null http version during initialization");
                }
              else
                {              
                  ASSIGNCOPY(_method,aMethod);
                  
                  [self setHTTPVersion:aVersion];

                  NSDebugMLLog(@"requests",@"headers=%@",headers);
                  [self setHeaders:headers];
                  
                  _defaultFormValueEncoding=[[self class]defaultEncoding];
                  _formValueEncoding=[[self class]defaultEncoding];
                  
                  _applicationNumber=-9999;
                  {
                    NSString* adaptorVersion=[self headerForKey:GSWHTTPHeader_AdaptorVersion[GSWebNamingConv]];
                    if (!adaptorVersion)
                      adaptorVersion=[self headerForKey:GSWHTTPHeader_AdaptorVersion[GSWebNamingConvInversed]];
                    NSDebugMLLog(@"requests",@"adaptorVersion=%@",adaptorVersion);
                    [self _setIsUsingWebServer:(adaptorVersion!=nil)];
                  };
                  
                  _uri=[[GSWDynamicURLString alloc]initWithCString:[anURL cString]
                                               length:[anURL length]];
                  NSDebugMLLog(@"requests",@"uri=%@",_uri);
                  [_uri checkURL];

                  if (!content)
                    content = [NSData data];
                  if ([content isKindOfClass:[GSWInputStreamData class]])
                    [self setContent:content];
                  else
                    [self appendContentData:content];

                  [self setUserInfo:userInfo];
                };
            };
        };
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogAssertGood(self);
  NSDebugFLog0(@"dealloc GSWRequest");
  NSDebugFLog0(@"Release GSWRequest method");
  DESTROY(_method);
  NSDebugFLog0(@"Release GSWRequest uri");
  DESTROY(_uri);
  NSDebugFLog0(@"Release GSWRequest formValues");
  DESTROY(_formValues);
  NSDebugFLog0(@"Release GSWRequest uriElements");
  DESTROY(_uriElements);
  NSDebugFLog0(@"Release GSWRequest cookie");
  DESTROY(_cookie);
  NSDebugFLog0(@"Release GSWRequest applicationURLPrefix");
  DESTROY(_applicationURLPrefix);
  NSDebugFLog0(@"Release GSWRequest requestHandlerPathArray");
  DESTROY(_requestHandlerPathArray);
  NSDebugFLog0(@"Release GSWRequest browserLanguages");
  DESTROY(_browserLanguages);
  NSDebugFLog0(@"Release GSWRequest browserAcceptedEncodings");
  DESTROY(_browserAcceptedEncodings);
  NSDebugFLog0(@"Release GSWRequest super");
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

  LOGObjectFnStart();

  userAgent=[self headerForKey:GSWHTTPHeader_UserAgent];

  LOGObjectFnStop();

  return userAgent;
};

//--------------------------------------------------------------------
-(NSString*)referer
{
  NSString* referer=nil;

  LOGObjectFnStart();

  referer=[self headerForKey:GSWHTTPHeader_Referer];

  LOGObjectFnStop();

  return referer;
};

//--------------------------------------------------------------------
-(NSArray*)browserLanguages
{
  //OK
  LOGObjectFnStart();
  if (!_browserLanguages)
    {
      NSMutableArray* browserLanguages=nil;
      NSString* header=[self headerForKey:GSWHTTPHeader_AcceptLanguage];
      NSDebugMLLog(@"requests",@"lang header:%@",header);
      if (header)
        {
          NSArray* languages=[GSWValueQualityHeaderPart valuesFromHeaderString:header];
          if (!languages)
            {
              LOGError0(@"No languages");
            };
          browserLanguages=(NSMutableArray*)[GSWResourceManager GSLanguagesFromISOLanguages:languages];
          NSDebugMLLog(@"requests",@"browserLanguages:%@",browserLanguages);
          if (browserLanguages)
            {
              //Remove Duplicates
              int i=0;
              browserLanguages=[browserLanguages mutableCopy];
              for(i=0;i<[browserLanguages count];i++)
                {
                  int j=0;
                  NSString* language=[browserLanguages objectAtIndex:i];
                  for(j=[browserLanguages count]-1;j>i;j--)
                    {
                      NSString* language2=[browserLanguages objectAtIndex:j];
                      if ([language2 isEqual:language])
                        [browserLanguages removeObjectAtIndex:j];
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
      NSDebugMLLog(@"requests",@"browserLanguages:%@",_browserLanguages);
    };
  LOGObjectFnStop();
  return _browserLanguages;
};

//--------------------------------------------------------------------
-(NSArray*)browserAcceptedEncodings
{
  //OK
  LOGObjectFnStart();
  if (!_browserAcceptedEncodings)
    {
      NSString* header=[self headerForKey:GSWHTTPHeader_AcceptEncoding];
      NSDebugMLLog(@"requests",@"accept encoding header:%@",header);
      if (header)
        {
          NSArray* values=[GSWValueQualityHeaderPart valuesFromHeaderString:header];
          if (!values)
            values=[NSArray array];
          ASSIGN(_browserAcceptedEncodings,values);
        };
      NSDebugMLLog(@"requests",@"browserAcceptedEncodings:%@",_browserAcceptedEncodings);
    };
  LOGObjectFnStop();
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

@end

//====================================================================
@implementation GSWRequest (GSWFormValueReporting)

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
  return _formValueEncoding;
};

//--------------------------------------------------------------------
//	formValueKeys

-(NSArray*)formValueKeys
{
  NSDictionary* formValues=nil;
  NSArray* formValueKeys=nil;
  LOGObjectFnStart();
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
  LOGObjectFnStop();
  return formValueKeys;
};

//--------------------------------------------------------------------
//	formValuesForKey:

-(NSArray*)formValuesForKey:(NSString*)key
{
  NSArray* formValuesForKey=nil;
  NSDictionary* formValues=nil;
  LOGObjectFnStart();
  NS_DURING
    {
      formValues=[self _formValues];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"GSWRequest formValuesForKey");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    };
  NS_ENDHANDLER;
  formValuesForKey=[formValues objectForKey:key];
  LOGObjectFnStop();
  return formValuesForKey;
};

//--------------------------------------------------------------------
//	formValueForKey:
// return id because GSWFileUpload
-(id)formValueForKey:(NSString*)key
{
  id formValue=nil;
  NSArray* formValuesForKey=nil;
  LOGObjectFnStart();
  formValuesForKey=[self formValuesForKey:key];
  NSAssert3(!formValuesForKey || [formValuesForKey isKindOfClass:[NSArray class]],@"formValues:%@ ForKey:%@ is not a NSArray it's a %@",
            formValuesForKey,
            key,
            [formValuesForKey class]);
  if (formValuesForKey && [formValuesForKey count]>0)
    formValue=[formValuesForKey objectAtIndex:0];
  LOGObjectFnStop();
  return formValue;
};

//--------------------------------------------------------------------
-(NSString*)stringFormValueForKey:(NSString*)key
{
  id value=nil;
  LOGObjectFnStart();
  value=[self formValueForKey:key];
  if (value && ![value isKindOfClass:[NSString class]])
    value=[value description];
  LOGObjectFnStop();
  return value;
}

//--------------------------------------------------------------------
-(NSNumber*)numberFormValueForKey:(NSString*)key
                    withFormatter:(NSNumberFormatter*)formatter
{
  NSNumber* value=nil;
  NSString* stringValue=nil;
  LOGObjectFnStart();
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
  LOGObjectFnStop();
  return value;
}

//--------------------------------------------------------------------
-(NSCalendarDate*)dateFormValueForKey:(NSString*)key
                        withFormatter:(NSDateFormatter*)formatter
{
  NSCalendarDate* value=nil;
  NSString* stringValue=nil;
  LOGObjectFnStart();
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
  LOGObjectFnStop();
  return value;
}

//--------------------------------------------------------------------
//	formValues
-(NSDictionary*)formValues
{
  NSDictionary* formValues=nil;
  LOGObjectFnStart();
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
  LOGObjectFnStop();
  return formValues;
};

-(void)appendFormValue:(id)value
                forKey:(NSString*)key
{
  LOGObjectFnStart();
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
  LOGObjectFnStop();
};

-(void)appendFormValues:(NSArray*)values
                 forKey:(NSString*)key
{
  LOGObjectFnStart();
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
  LOGObjectFnStop();
};
@end

//====================================================================
@implementation GSWRequest (GSWURIElementReporting)

//--------------------------------------------------------------------
//	uriValueKeys

-(NSArray*)uriElementKeys
{
  NSDictionary* uriElements=nil;
  NSArray* uriElementKeys=nil;
  LOGObjectFnStart();
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
  LOGObjectFnStop();
  return uriElementKeys;
};

//--------------------------------------------------------------------
//	uriElementForKey:
-(NSString*)uriElementForKey:(NSString*)key
{
  NSString* uriElement=nil;
  NSDictionary* uriElements=nil;
  LOGObjectFnStart();
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
  LOGObjectFnStop();
  return uriElement;
};

//--------------------------------------------------------------------
//	uriElements
-(NSDictionary*)uriElements
{
  NSDictionary* uriElements=nil;
  LOGObjectFnStart();
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
  LOGObjectFnStop();
  return uriElements;
};

@end

//====================================================================
@implementation GSWRequest (GSWRequestTypeReporting)

//--------------------------------------------------------------------
//	isFromClientComponent

-(BOOL)isFromClientComponent 
{
  //OK
  NSString* remoteInvocationPost=nil;
  BOOL isFromClientComponent=NO;
  LOGObjectFnStart();
  remoteInvocationPost=[self formValueForKey:GSWFormValue_RemoteInvocationPost[GSWebNamingConv]];
  isFromClientComponent=(remoteInvocationPost!=nil);
  LOGObjectFnStop();
  return isFromClientComponent;
};

@end

//====================================================================
@implementation GSWRequest (Cookies)

//--------------------------------------------------------------------
-(void)setCookieFromHeaders
{
  NSDictionary* cookie=nil;
  NSString* cookieHeader=nil;
  LOGObjectFnStart();
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
          NSDebugMLLog(@"requests",@"enumerator=%@ cookieTmp=%@",enumerator,cookieTmp);
          while ((key = [enumerator nextObject]))
            {
              value=[cookieStrings objectForKey:key];
              if (value)
                {
                  id cookieValue=nil;
                  int index=0;
                  for(index=0;index<[value count];index++)
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
  NSDebugMLLog(@"requests",@"Cookies: %@",_cookies);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	cookieValuesForKey:
-(NSArray*)cookieValuesForKey:(NSString*)key
{
  NSArray* cookieValuesForKey=nil;
  NSDictionary* cookieValues=nil;
  LOGObjectFnStart();
  cookieValues=[self cookieValues];
  cookieValuesForKey=[cookieValues objectForKey:key];
  LOGObjectFnStop();
  return cookieValuesForKey;
};

//--------------------------------------------------------------------
//	cookieValueForKey:
-(NSString*)cookieValueForKey:(NSString*)key
{
  NSArray* values=nil;
  NSString* cookieValueForKey=nil;
  LOGObjectFnStart();
  values=[self cookieValuesForKey:key];
  if ([values count]>0)
    cookieValueForKey=[values objectAtIndex:0];
  NSDebugMLLog(@"requests",@"cookieValueForKey:%@=%@",key,cookieValueForKey);
  LOGObjectFnStop();
  return cookieValueForKey;
};

//--------------------------------------------------------------------
//	cookieValues
-(NSDictionary*)cookieValues
{
  NSDictionary* cookieValues=nil;
  LOGObjectFnStart();
  cookieValues=[self _initCookieDictionary];
  LOGObjectFnStop();
  return cookieValues;
};

//--------------------------------------------------------------------
// Dictionary of ccokie name / cookie value
-(NSDictionary*)_initCookieDictionary
{
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"cookies=%@",_cookie);
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
      NSDebugMLLog(@"low",@"cookieDescription=%@",cookieDescription);
      NSDebugMLLog(@"low",@"cookiesArray=%@",cookiesArray);
      for(i=0;i<[cookiesArray count];i++)
        {
          cookieString=[cookiesArray objectAtIndex:i];
          NSDebugMLLog(@"low",@"cookieString=%@",cookieString);
          cookie=[cookieString componentsSeparatedByString:@"="];
          NSDebugMLLog(@"low",@"cookie=%@",cookie);
          if ([cookie count]>0)
            {
              cookieName=[cookie objectAtIndex:0];
              if ([cookie count]>1)
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
  LOGObjectFnStop();
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
  LOGObjectFnStart();
  cookieHeader=[self headerForKey:GSWHTTPHeader_Cookie];
  if (!cookieHeader)
    cookieHeader=[self headerForKey:GSWHTTPHeader_CookieStupidIIS];// God damn it
  LOGObjectFnStop();
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

@end


//====================================================================
@implementation GSWRequest (GSWRequestA)

//--------------------------------------------------------------------
-(NSString*)sessionIDFromValuesOrCookie
{
  return [self sessionIDFromValuesOrCookieByLookingForCookieFirst:[[self class]_lookForIDsInCookiesFirst]];
};

//--------------------------------------------------------------------
-(NSString*)sessionIDFromValuesOrCookieByLookingForCookieFirst:(BOOL)lookCookieFirst
{
  NSString* sessionID=nil;
  LOGObjectFnStart();
  sessionID=[self uriOrFormOrCookiesElementForKey:GSWKey_SessionID[GSWebNamingConv]
                  byLookingForCookieFirst:lookCookieFirst];
  if (!sessionID)
    {
      sessionID=[self uriOrFormOrCookiesElementForKey:GSWKey_SessionID[GSWebNamingConvInversed]
                      byLookingForCookieFirst:lookCookieFirst];
    };
  LOGObjectFnStop();
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

//--------------------------------------------------------------------
-(NSString*)requestHandlerKey
{
  NSString* requestHandlerKey=[_uri urlRequestHandlerKey];
  return requestHandlerKey;
};

@end

//====================================================================
@implementation GSWRequest (GSWRequestB)

//--------------------------------------------------------------------
-(NSDictionary*)_extractValuesFromFormData:(NSData*)aFormData
                              withEncoding:(NSStringEncoding)encoding
{
  NSArray* allKeys=nil;
  NSDictionary* tmpFormData=nil;
  NSString* formString=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"aFormData=%@",aFormData);
  NSDebugMLLog(@"requests",@"encoding=%ld",(long)encoding);
  formString=[[[NSString alloc]initWithData:aFormData
                               encoding:encoding] autorelease];
  NSDebugMLLog(@"requests",@"formString=%@",formString);
  tmpFormData=[formString dictionaryQueryString];
  NSDebugMLLog(@"requests",@"tmpFormData=%@",tmpFormData);
  allKeys=[tmpFormData allKeys];
  NSDebugMLLog(@"requests",@"allKeys=%@",allKeys);
  NSDebugMLLog(@"requests",@"allKeys count=%d",[allKeys count]);
  if ([allKeys count]>0)
    {
      int i=0;
      int count=[allKeys count];
      NSString* key=nil;
      BOOL ismapCoordsFound=NO;
      NSArray* value=nil;
      for(i=0;i<count && !ismapCoordsFound;i++)
        {
          key=[allKeys objectAtIndex:i];
          NSDebugMLLog(@"requests",@"key=%@",key);
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
  NSDebugMLLog(@"requests",@"tmpFormData=%@",tmpFormData);
  LOGObjectFnStop();
  return tmpFormData;
};

//--------------------------------------------------------------------
-(NSStringEncoding)_formValueEncodingFromFormData:(NSData*)aFormData
{
  return [[self class] defaultEncoding]; //TODO
};

//--------------------------------------------------------------------
-(NSData*)_formData
{
  //OK
  NSData* data=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"method=%@",_method);
  NSDebugMLLog(@"requests",@"contentData=%@",_contentData);
  if ([_method isEqualToString:GSWHTTPHeader_MethodGet])
    {
      NSString* urlQueryString=[self _urlQueryString];
      data=[urlQueryString dataUsingEncoding: [self formValueEncoding]];//??
      NSDebugMLLog(@"requests",@"data=%@",data);
    }
  else if ([_method isEqualToString:GSWHTTPHeader_MethodPost])
    {
      data=_contentData;
      NSDebugMLLog(@"requests",@"data=%@",data);
    };
  LOGObjectFnStop();
  return data;
};

//--------------------------------------------------------------------
-(NSString*)_contentType
{
  //OK
  NSString* contentType=nil;
  NSRange range;
  LOGObjectFnStart();
  contentType=[self headerForKey:GSWHTTPHeader_ContentType];
  NSDebugMLLog(@"requests",@"contentType=%@",contentType);
  //We can get something like 
  // multipart/form-data; boundary=---------------------------1810101926251
  // In this case, return only multipart/form-data
  if (contentType) 
    {
      range=[contentType rangeOfString:@";"];
      if (range.length>0)
        {
          contentType=[contentType substringToIndex:range.location];
          NSDebugMLLog(@"requests",@"contentType=%@",contentType);
        };
    };
  LOGObjectFnStop();
  return contentType;
};

//--------------------------------------------------------------------
-(NSString*)_urlQueryString
{
  //OK
  NSString* urlQueryString=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"uri=%@",_uri);
  NSDebugMLLog(@"requests",@"uri class=%@",[_uri class]);
  urlQueryString=[_uri urlQueryString];
  LOGObjectFnStop();
  return urlQueryString;
};


@end


//====================================================================
@implementation GSWRequest (GSWRequestF)

//--------------------------------------------------------------------
-(BOOL)_isUsingWebServer
{
  return _isUsingWebServer;
};

//--------------------------------------------------------------------
-(void)_setIsUsingWebServer:(BOOL)flag
{
  _isUsingWebServer=flag;
};

@end

//====================================================================
@implementation GSWRequest (GSWRequestG)

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

  LOGObjectFnStart();

  url=[self _applicationURLPrefix];

  if (urlPrefix)
    [url setURLPrefix:[NSString stringWithFormat:@"%@%@",
                                urlPrefix,[url urlPrefix]]];

  [url setURLRequestHandlerKey:key];
  [url setURLRequestHandlerPath:path];
  [url setURLQueryString:queryString];

  LOGObjectFnStop();

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)_urlWithRequestHandlerKey:(NSString*)key
                                            path:(NSString*)path
                                     queryString:(NSString*)queryString
{
  GSWDynamicURLString* url=nil;

  LOGObjectFnStart();

  url=[self _urlWithURLPrefix:nil
            requestHandlerKey:key
            path:path
            queryString:queryString];

  LOGObjectFnStop();

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
  LOGObjectFnStart();
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
          NSDebugMLLog(@"requests",@"contentType=%@",contentType);
        };
      NSDebugMLLog(@"requests",@"formValues=%@",_formValues);
      _finishedParsingMultipartFormData=YES;
    };
  LOGObjectFnStop();
  return _formValues;
};

//--------------------------------------------------------------------
-(void)_getFormValuesFromURLEncoding
{
  NSData* formData=nil;
  LOGObjectFnStart();
  formData=[self _formData];
  NSDebugMLLog(@"requests",@"formData=%@",formData);
  if (formData)
    {
      NSStringEncoding formValueEncoding=[self _formValueEncodingFromFormData:formData];
      NSDictionary* formValues=nil;
      NSDebugMLLog(@"requests",@"formValueEncoding=%d",(int)formValueEncoding);
      formValues=[self _extractValuesFromFormData:formData
                       withEncoding:formValueEncoding];
      ASSIGN(_formValues,formValues);
      NSDebugMLLog(@"requests",@"formValues=%@",_formValues);
    };
  LOGObjectFnStop();
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

@end

//====================================================================
@implementation GSWRequest (GSWRequestH)

//--------------------------------------------------------------------
-(void)_getFormValuesFromMultipartFormDataOld
{
  NSMutableDictionary* formValues=nil;
  NSArray* contentTypes=nil;
  int contentTypeIndex=0;
  int contentTypeCount=0;
  NSString* contentType=nil;
  NSData* tmpContentData=nil;
  LOGObjectFnStart();
  formValues=(NSMutableDictionary*)[NSMutableDictionary dictionary];
  contentTypes=[self headersForKey:GSWHTTPHeader_ContentType];
  contentTypeIndex=0;
  contentTypeCount=[contentTypes count];
  NSDebugMLLog(@"requests",@"contentTypes=%@",contentTypes);
  tmpContentData=[self content];
  NS_DURING
    {
      for(contentTypeIndex=0;contentTypeIndex<contentTypeCount;contentTypeIndex++)
        {
          NSDictionary* parsedContentType=nil;
          NSString* boundaryString=nil;
          NSArray* decodedParts=nil;
          int decodedPartIndex=0;
          int decodedPartCount=0;
          
          // get "multipart/form-data; boundary=---------------------------1810101926251"
          contentType=[contentTypes objectAtIndex:contentTypeIndex];
          NSDebugMLLog(@"requests",@"contentType=%@",contentType);
          // convert it into
          //	{
          //		boundary = "---------------------------1810101926251";
          //		"multipart/form-data" = "multipart/form-data"; 
          //	}
          parsedContentType=[self _parseOneHeader:contentType];
          NSDebugMLLog(@"requests",@"parsedContentType=%@",parsedContentType);
          boundaryString=[parsedContentType objectForKey:@"boundary"];
          NSDebugMLLog(@"requests",@"boundaryString=%@",boundaryString);
          NSAssert1(boundaryString,@"No boundary in %@",parsedContentType);
          NSDebugMLLog(@"requests",@"tmpContentData=%@",tmpContentData);
          decodedParts=[self _decodeMultipartBody:tmpContentData
                             boundary:boundaryString];
          NSDebugMLLog(@"requests",@"decodedParts=%@",decodedParts);
          decodedPartIndex=0;
          decodedPartCount=[decodedParts count];
          for(decodedPartIndex=0;decodedPartIndex<decodedPartCount;decodedPartIndex++)
            {
              NSData* decodedPart=nil;
              NSArray* parsedParts=nil;
              int parsedPartsCount=0;

              decodedPart=[decodedParts objectAtIndex:decodedPartIndex];
              NSDebugMLLog(@"requests",@"decodedPart=%@",decodedPart);
              parsedParts=[self _parseData:decodedPart];
              NSDebugMLLog(@"requests",@"parsedParts=%@",parsedParts);
              //return :
              //	(
              //		{
              //			"content-disposition" = "form-data; name=\"9.1\"; filename=\"C:\\TEMP\\zahn.txt\""; 
              //			"content-type" = text/plain; 
              //	    },
              //		<41514541 41415177 4d444179 666f3054 6c4e2b58 58684357 69314b50 51635159 73573677 426d336f 52617247 36584633 4c7a6455 5637664e 39654b6b 764b4a43 71715059 67417250 59374863 78397944 36506b66 774a7550 465a4141 2f303463 446c5072 48525670 537a4135 67664738 62364572 44314158 372b7067 734c5075 304b4d77 0d0a0d0a >
              //	)
              parsedPartsCount=[parsedParts count];
              if (parsedPartsCount==0)
                {
                  LOGError(@"parsedPartsCount==0 decodedPart=%@",decodedPart);
                  //TODO error
                }
              else
                {
                  NSDictionary* partInfo=nil;
                  NSString* parsedPartsContentType=nil;
                  NSString* parsedPartsContentDisposition=nil;
                  NSDictionary* parsedContentDispositionOfParsedPart=nil;
                  NSEnumerator* anEnumerator=nil;
                  NSString* aName=nil;
                  NSString* dscrKey=nil;
                  id descrValue=nil;

                  partInfo=[parsedParts objectAtIndex:0];

                  NSDebugMLLog(@"requests",@"partInfo=%@",
                               partInfo);
                  NSAssert1([partInfo isKindOfClass:[NSDictionary class]],
                            @"partInfo %@ is not a dictionary",partInfo);

                  parsedPartsContentType=[[partInfo objectForKey:GSWHTTPHeader_ContentType] lowercaseString];
                  NSDebugMLLog(@"requests",@"parsedPartsContentType=%@",
                               parsedPartsContentType);
                  parsedPartsContentDisposition=[partInfo objectForKey:@"content-disposition"];
                  NSDebugMLLog(@"requests",@"parsedPartsContentDisposition=%@",
                               parsedPartsContentDisposition);
                  //Convert: "form-data; name=\"9.1\"; filename=\"C:\\TEMP\\zahn.txt\"";
                  // into: {filename = "C:\\TEMP\\zahn.txt"; "form-data" = "form-data"; name = 9.1; }
                  parsedContentDispositionOfParsedPart=[self _parseOneHeader:parsedPartsContentDisposition];
                  NSDebugMLLog(@"requests",@"parsedContentDispositionOfParsedPart=%@",
                               parsedContentDispositionOfParsedPart);
                  anEnumerator=[parsedContentDispositionOfParsedPart keyEnumerator];
                  aName=[parsedContentDispositionOfParsedPart objectForKey:@"name"];
                  NSDebugMLLog(@"requests",@"aName=%@",
                               aName);
                  if (!aName)
                    {
                      ExceptionRaise(@"GSWRequest",
                                     @"GSWRequest: No name \n%@\n",
                                     parsedContentDispositionOfParsedPart);
                    };
                  while((dscrKey=[anEnumerator nextObject]))
                    {
                      NSDebugMLLog(@"requests",@"dscrKey=%@",dscrKey);
                      if (![dscrKey isEqualToString:@"name"] 
                          && ![dscrKey isEqualToString:@"form-data"])
                        {
                          NSString* _key=nil;
                          descrValue=[parsedContentDispositionOfParsedPart objectForKey:dscrKey];
                          NSDebugMLLog(@"requests",@"descrValue=%@",descrValue);
                          _key=[NSString stringWithFormat:@"%@.%@",aName,dscrKey];
                          NSDebugMLLog(@"requests",@"_key=%@",_key);
                          //NSLog(@"getFormValues... _key=%@ descrValue=%@",_key,descrValue);
                          [formValues setObject:[NSArray arrayWithObject:descrValue]
                                      forKey:_key];
                        };
                    };
                  if (parsedPartsCount>1)
                    {
                      NSArray* values=[parsedParts subarrayWithRange:NSMakeRange(1,[parsedParts count]-1)];
                      NSMutableArray* valuesNew=[NSMutableArray array];
                      NSMutableArray* addedValues = nil;
                      NSDebugMLLog(@"requests",@"values=%@",
                                   values);
                      NSDebugMLLog(@"requests",@"parsedPartsContentType=%@",
                                   parsedPartsContentType);
                      if (!parsedPartsContentType
                          || [parsedPartsContentType isEqualToString:GSWHTTPHeader_MimeType_TextPlain])
                        {
                          int valueIndex=0;
                          int valuesCount=[values count];
                          id value=nil;
                          for(valueIndex=0;valueIndex<valuesCount;valueIndex++)
                            {
                              value=[values objectAtIndex:valueIndex];
                              NSDebugMLLog(@"requests",@"value=%@",value);
                              value=[[[NSString alloc]initWithData:value
                                                      encoding:[self formValueEncoding]]autorelease];
                              [valuesNew addObject:value];
                            };
                          values=[NSArray arrayWithArray:valuesNew];
                        };
                      //NSLog(@"getFormValues 2... values=%@ key=%@",values,aName);
                      if ((addedValues = [formValues objectForKey:aName])) {
                        addedValues = [NSMutableArray arrayWithArray:addedValues];
                        [addedValues addObjectsFromArray:values];
                        [formValues setObject:addedValues
                                    forKey:aName];

                      } else {
                      
                      [formValues setObject:values
                                  forKey:aName];
                      }
                    };
                };
            };
        };
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"GSWRequest in _getFormValuesFromMultipartFormData");
      LOGException(@"%@ (%@) \ncontentTypes=%@\ntmpContentData=%@",
                   localException,
                   [localException reason],
                   contentTypes,
                   tmpContentData);
      [localException raise];
    };
  NS_ENDHANDLER;
  NSDebugMLLog(@"requests",@"formValues=%@",formValues);
  ASSIGN(_formValues,formValues);
  //
  //	{
  //    	9.1 = 	(
  //					<41514541 41415177 4d444179 666f3054 6c4e2b58 58684357 69314b50 51635159 73573677 426d336f 52617247 36584633 4c7a6455 5637664e 39654b6b 764b4a43 71715059 67417250 59374863 78397944 36506b66 774a7550 465a4141 2f303463 446c5072 48525670 537a4135 67664738 62364572 44314158 372b7067 734c5075 304b4d77 0d0a0d0a >
  //				);
  //		9.1.filename = ("C:\\TEMP\\zahn.txt"); 
  //		9.3 = (submit);
  //	}
  LOGObjectFnStop();
};

-(void)_getFormValuesFromMultipartFormData
{
  NSMutableDictionary* formValues=nil;
  GSMimeParser* parser=nil;
  id key=nil;
  NSData* headersData=nil;
  NSMutableString* headersString=[NSMutableString string];
  NSDictionary* headers=nil;
  NSEnumerator* enumerator=nil;
  LOGObjectFnStart();

  formValues=(NSMutableDictionary*)[NSMutableDictionary dictionary];

  headers=[self headers];
  enumerator=[headers keyEnumerator];
  while((key=[enumerator nextObject]))
    {
      NSArray* value=[headers objectForKey:key];
      int i=0;
      int count=[value count];
      for(i=0;i<count;i++)
        [headersString appendFormat:@"%@: %@\n",
                       key,[value objectAtIndex:i]];
    };
  [headersString appendString:@"\n"];
  NSDebugMLLog(@"requests",@"headersString=[\n%@\n]",headersString);

  headersData=[headersString dataUsingEncoding:[self formValueEncoding]];
  parser=[GSMimeParser mimeParser];
  [parser parse:headersData];
  [parser expectNoHeaders];
  if ([parser parse:_contentData])
    [parser parse:nil];
  NSDebugMLLog(@"requests",@"[parser isComplete]=%d",[parser isComplete]);
  if ([parser isComplete] == NO)
    {
          //TODO
    }
  else
    {      
      GSMimeDocument* document = [parser mimeDocument];
      NSArray* content=nil;
      NSString* contentSubtype=nil;
      NSDebugMLLog(@"requests",@"document=%@",document);
      content=[document content];
      NSDebugMLLog(@"requests",@"contentType=%@",[document contentType]);
      contentSubtype=[document contentSubtype];
      NSDebugMLLog(@"requests",@"contentSubtype=%@",contentSubtype);

      if ([contentSubtype isEqual:@"form-data"])
        {
          NSDebugMLLog(@"requests",@"contentID=%@",[document contentID]);
          NSDebugMLLog(@"requests",@"[document allHeaders]=%@",[document allHeaders]);
          NSDebugMLLog(@"requests",@"[document content]=%@",content);
          NSDebugMLLog(@"requests",@"[document content] class=%@",[content class]);

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
                  NSDebugMLLog(@"requests",@"aDoc=%@",aDoc);
                  aDocContent=[aDoc content];
                  NSDebugMLLog(@"requests",@"aDocContent=%@",aDocContent);
                  NSDebugMLLog(@"requests",@"contentType=%@",[aDoc contentType]);
                  NSDebugMLLog(@"requests",@"contentSubtype=%@",[aDoc contentSubtype]);
                  NSDebugMLLog(@"requests",@"contentID=%@",[aDoc contentID]);
                  contentDispositionHeader=[aDoc headerNamed:@"content-disposition"];
                  NSDebugMLLog(@"requests",@"contentDispositionHeader=%@",contentDispositionHeader);
                  contentDispositionValue=[contentDispositionHeader value];
                  contentDispositionParams=[contentDispositionHeader parameters];
                  NSDebugMLLog(@"requests",@"contentDispositionValue=%@",contentDispositionValue);
                  NSDebugMLLog(@"requests",@"contentDispositionParams=%@",contentDispositionParams);
                  NSDebugMLLog(@"requests",@"aDoc allHeaders=%@",[aDoc allHeaders]);
                  NSDebugMLLog(@"requests",@"aDocContent class=%@",[aDocContent class]);
                  if ([contentDispositionValue isEqual:@"form-data"])
                    {
                      NSString* formDataName=[contentDispositionParams objectForKey:@"name"];
                      NSDebugMLLog(@"requests",@"formDataName=%@",
                                   formDataName);
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
                              NSDebugMLLog(@"requests",@"paramName=%@",paramName);
                              if (![paramName isEqualToString:@"name"])
                                {
                                  NSArray* previous=nil;
                                  NSString* paramFormValueName=nil;
                                  id paramValue=nil;
                                  paramValue=[contentDispositionParams objectForKey:paramName];
                                  NSDebugMLLog(@"requests",@"paramValue=%@",paramValue);
                                  paramFormValueName=[NSString stringWithFormat:@"%@.%@",formDataName,paramName];
                                  NSDebugMLLog(@"requests",@"paramFormValueName=%@",paramFormValueName);
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
  NSDebugMLLog(@"requests",@"_formValues=%@",_formValues);
  LOGObjectFnStop();
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
/*  _CRLFSeparator=NO;
  unsigned char* _CRLF[2]={ 0x0d, 0x0a };
  unsigned char* _LF[2]={ 0x0a };
  NSData* _CRLFData=[NSData dataWithBytes:_CRLF
							length:2];
  NSData* _LFData=[NSData dataWithBytes:_LF
						  length:1];
*/
  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"aBody=%@",aBody);
  NSDebugMLLog(@"requests",@"aBoundary=%@",aBoundary);
  boundaryString=[NSString stringWithFormat:@"--%@\r\n",aBoundary];//Add "--" and "\r\n"
  NSDebugMLLog(@"requests",@"aBoundary=%@",aBoundary);
  dataBoundary=[boundaryString dataUsingEncoding:[self formValueEncoding]];//TODO
  NSDebugMLLog(@"requests",@"dataBoundary=%@",dataBoundary);
/*  {
	NSString* _dataString=nil;
	_dataString=[[[NSString alloc]initWithData:_body
					  encoding:[self formValueEncoding]]autorelease];
	NSDebugMLLog(@"requests",@"_bodyString=%@",_dataString);
  }
*/
  NSDebugMLLog0(@"requests",@"componentsSeparatedByData");
  parts=[aBody componentsSeparatedByData:dataBoundary];
  NSDebugMLLog(@"requests",@"parts=%@",parts);
  {
    for(i=0;i<[parts count];i++)
      {
        tmpData=[parts objectAtIndex:i];
        if ([tmpData length]<400)
          {
            NSString* _dataString=nil;
            _dataString=[[[NSString alloc]initWithData:tmpData
                                          encoding:[self formValueEncoding]]autorelease];
            NSDebugMLLog(@"requests",@"_tmpDataString=[\n%@\n]",_dataString);
          }
        else
          {
            NSDebugMLLog(@"requests",@"tmpData=%@",tmpData);
          };
      };
  };
  // The 1st part should be empty (or it's only a warning message...)
  if ([parts count]>0)
    {
      parts=[parts subarrayWithRange:NSMakeRange(1,[parts count]-1)];
    };
  // Now deleting last \r\n of each object
  parts=[parts mutableCopy];
  for(i=0;i<[parts count];i++)
    {
      tmpData=[parts objectAtIndex:i];
      if (i==[parts count]-1)
        {
          //Delete the last \r\nseparator--\r\n
          boundaryString=[NSString stringWithFormat:@"\r\n%@--\r\n",aBoundary];
          NSDebugMLLog(@"requests",@"aBoundary=%@",aBoundary);
          dataBoundary=[boundaryString dataUsingEncoding:[self formValueEncoding]];//TODO
          NSDebugMLLog(@"requests",@"tmpData_=%@",tmpData);
          tmpData=[tmpData dataByDeletingLastBytesCount:[dataBoundary length]];
          NSDebugMLLog(@"requests",@"tmpData=%@",tmpData);
        }
      else
        {
          tmpData=[tmpData dataByDeletingLastBytesCount:2];
        };
      [(NSMutableArray*)parts replaceObjectAtIndex:i
                        withObject:tmpData];
    };
  {
    for(i=0;i<[parts count];i++)
      {
        tmpData=[parts objectAtIndex:i];
        if ([tmpData length]<400)
          {
            NSString* dataString=nil;
            dataString=[[[NSString alloc]initWithData:tmpData
                                         encoding:[self formValueEncoding]]autorelease];
            NSDebugMLLog(@"requests",@"tmpDataString=[\n%@\n]",dataString);
			
          }
        else
          {
            NSDebugMLLog(@"requests",@"tmpData=%@",tmpData);
          };
      };
  };
  LOGObjectFnStop();
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
  LOGObjectFnStart();
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
                  NSDebugMLLog(@"requests",@"i=%d",i);
                  NSDebugMLLog(@"requests",@"start=%d",start);
                  NSDebugMLLog(@"requests",@"headerData=%@",headerData);
                  NSDebugMLLog(@"requests",@"tmpHeaderString=%@",tmpHeaderString);
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
          NSDebugMLog(@"Error");
        }
      else
        {
          NSDebugMLLog(@"requests",@"i=%d tmpDataLength=%d tmpDataLength-i=%d",
                       i,tmpDataLength,(tmpDataLength-i));
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
      NSDebugMLLog(@"requests",@"tmpHeaders=%@",tmpHeaders);
      NSDebugMLLog(@"requests",@"tmpData %p (length=%d)=%@",
                   tmpData,[tmpData length],tmpData);
      NSDebugMLLog(@"requests",@"parsedData %p =%@",
                   parsedData,parsedData);
    };
  LOGObjectFnStop();
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
  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"aHeader=%@",aHeader);
  parsedParts=(NSMutableDictionary*)[NSMutableDictionary dictionary];
  NSDebugMLLog(@"requests",@"parsedParts=%@",parsedParts);
  headerParts=[aHeader componentsSeparatedByString:@";"];
  NSDebugMLLog(@"requests",@"headerParts=%@",headerParts);
  partCount=[headerParts count];
  for(partIndex=0;partIndex<partCount;partIndex++)
    {
      NSArray* parsedPart=nil;
      int parsedPartCount=0;
      NSString* key=nil;
      NSString* value=nil;
      part=[headerParts objectAtIndex:partIndex];
      NSDebugMLLog(@"requests",@"part=%@",part);
      part=[part stringByTrimmingSpaces];
      NSDebugMLLog(@"requests",@"part=%@",part);
      parsedPart=[part componentsSeparatedByString:@"="];
      NSDebugMLLog(@"requests",@"parsedPart=%@",parsedPart);
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
      NSDebugMLLog(@"requests",@"key=%@",key);
      NSDebugMLLog(@"requests",@"value=%@",value);
      if (key && value)
        {
          if ([value isQuotedWith:@"\""])
            value=[value stringWithoutQuote:@"\""];
          [parsedParts setObject:value
                       forKey:key];
        };
    };
  NSDebugMLLog(@"requests",@"parsedParts=%@",parsedParts);
  parsedParts=[NSDictionary dictionaryWithDictionary:parsedParts];
  LOGObjectFnStop();
  return parsedParts;
};


@end

//====================================================================
@implementation GSWRequest (GSWRequestI)

//--------------------------------------------------------------------
-(id)nonNilFormValueForKey:(NSString*)key
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};


@end

//====================================================================
@implementation GSWRequest (GSWRequestJ)

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

@end

//====================================================================
@implementation GSWRequest (GSWRequestK)

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
  NSDebugMLLog(@"requests",@"request %p: pageName=%@",
               self,pageName);
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
  LOGObjectFnStart();
  uriElements=[self uriOrFormOrCookiesElements];
  contextID=[uriElements objectForKey:GSWKey_ContextID[GSWebNamingConv]];
  if (!contextID)
    contextID=[uriElements objectForKey:GSWKey_ContextID[GSWebNamingConvInversed]];
  LOGObjectFnStop();
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
  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"request %p: key=%@",
               self,key);
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
  NSDebugMLLog(@"requests",@"request %p: key=%@ element=%@",
               self,key,element);
  LOGObjectFnStop();
  return element;
}
//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)uriOrFormOrCookiesElementsByLookingForCookieFirst:(BOOL)lookCookieFirst
{
  NSMutableDictionary* elements=nil;
  NSString* tmpString=nil;
  LOGObjectFnStart();
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

  NSDebugMLLog(@"requests",@"elements=%@",elements);
  LOGObjectFnStop();
  return elements;
};

//--------------------------------------------------------------------
-(NSDictionary*)_uriElements
{
  //OK
  LOGObjectFnStart();
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

      NSDebugMLLog(@"requests",@"request %@",self);

      requestHandlerKey=[((GSWDynamicURLString*)[self uri]) urlRequestHandlerKey];
      NSDebugMLLog(@"requests",@"request %p: requestHandlerKey=%@",
                   self,requestHandlerKey);

      if (!requestHandlerKey
          || (![requestHandlerKey isEqualToString:GSWDirectActionRequestHandlerKey[GSWebNamingConv]]
              &&![requestHandlerKey isEqualToString:GSWDirectActionRequestHandlerKey[GSWebNamingConvInversed]]))
        {
          requestHandlerPathArray=[self requestHandlerPathArray];
          NSDebugMLLog(@"requests",@"request %p: requestHandlerPathArray=%@",
                       self,requestHandlerPathArray);

          if ([requestHandlerPathArray count]>index)
            {
              tmpString=[requestHandlerPathArray objectAtIndex:index];
              NSDebugMLLog(@"requests",@"rquest %p: tmpString=%@",
                           self,tmpString);

              if ([tmpString hasSuffix:GSWPagePSuffix[GSWebNamingConv]])
                {
                  gswpage=[tmpString stringByDeletingSuffix:GSWPagePSuffix[GSWebNamingConv]];
                  NSDebugMLLog(@"requests",@"request %p: gswpage=%@",
                               self,gswpage);
                  index++;
                }
              else if ([tmpString hasSuffix:GSWPagePSuffix[GSWebNamingConvInversed]])
                {
                  gswpage=[tmpString stringByDeletingSuffix:GSWPagePSuffix[GSWebNamingConvInversed]];
                  NSDebugMLLog(@"requests",@"request %p: gswpage=%@",
                               self,gswpage);
                  index++;
                };

              if ([requestHandlerPathArray count]>index)
                {
                  gswsid=[requestHandlerPathArray objectAtIndex:index];
                  NSDebugMLLog(@"requests",@"request %p: gswsid=%@",
                               self,gswsid);
                  index++;

                  if ([requestHandlerPathArray count]>index)
                    {
                      NSString* senderID=[requestHandlerPathArray objectAtIndex:index];
                      NSDebugMLLog(@"requests",@"senderID=%@",senderID);
                      index++;

                      if (senderID && [senderID length]>0)
                        {
                          NSArray* senderIDParts=[senderID componentsSeparatedByString:@"."];
                          NSDebugMLLog(@"requests",@"request %p: senderIDParts=%@",
                                       self,senderIDParts);

                          if ([senderIDParts count]>0)
                            {
                              tmpString=[senderIDParts objectAtIndex:0];
                              NSDebugMLLog(@"requests",@"request %p: tmpString=%@",
                                           self,tmpString);

                              if (tmpString && [tmpString length]>0)
                                gswcid=tmpString;
                          
                              if ([senderIDParts count]>1)
                                {
                                  tmpString=[[senderIDParts subarrayWithRange:
                                                              NSMakeRange(1,[senderIDParts count]-1)]
                                              componentsJoinedByString:@"."];
                                  NSDebugMLLog(@"requests",@"request %p: tmpString=%@",
                                               self,tmpString);

                                  if (tmpString && [tmpString length]>0)
                                    {
                                      gsweid=tmpString;
                                      NSDebugMLLog(@"requests",@"request %p: gsweid=%@",
                                                   self,gsweid);
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
      NSDebugMLLog(@"requests",@"request %@: _uriElements=%@",
                   self,_uriElements);
    };
  LOGObjectFnStop();
  return _uriElements;
};
@end

//====================================================================
@implementation GSWRequest (GSWRequestL)
//--------------------------------------------------------------------
-(void)_validateAPI
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end
