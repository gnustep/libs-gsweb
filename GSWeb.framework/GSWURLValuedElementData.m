/** GSWURLValuedElementData.m - <title>GSWeb: Class GSWURLValuedElementData</title>

   Copyright (C) 1999-2005 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$
   
   <abstract></abstract>

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

//====================================================================

static Class NSStringClass = Nil;

@implementation GSWURLValuedElementData

+ (void) initialize
{
  if (self == [GSWURLValuedElementData class])
    {
      NSStringClass = [NSString class];
    }
}


+ (NSString*) _dataURLInContext: (GSWContext*) context
                            key:(GSWAssociation*) key
                           data:(GSWAssociation*) data
                       mimeType:(GSWAssociation*) mimeType
                    inComponent:(GSWComponent*) component
{
  id                     obj = nil; 
  NSString             * str = nil;
  NSString             * keyStr = nil;
  NSString             * mimeValue = nil;
  GSWResourceManager   * resourcemanager = [GSWApp resourceManager];
  if (key != nil) {
    id keyValue = [key valueInComponent:component];
    if (keyValue != nil) {
      keyStr = [keyValue description];
    }
  }
  if (keyStr != nil) {
    obj = [resourcemanager _cachedDataForKey: keyStr];
  }
  if (obj == nil) {
    NSData * nsdataValue = [data valueInComponent:component];

    mimeValue = [mimeType valueInComponent:component];
    if (nsdataValue != nil && mimeValue != nil) {
      obj = [[GSWURLValuedElementData alloc] initWithData: nsdataValue
                                                 mimeType: mimeValue
                                                      key: keyStr];
      AUTORELEASE(obj);                                                      

      if (obj != nil) {
        [resourcemanager _cacheData:obj];
      }
    }
  }
  if (obj == nil) {
    obj = @"/ERROR/NOT_FOUND/DYNAMIC_DATA";
    return obj;
  }
  if ([obj isKindOfClass:NSStringClass]) {
    return obj;
  } else {
    str = [(GSWURLValuedElementData*) obj dataURLInContext:context];
  }
  return str;
}



// _appendDataURLAttributeToResponse 
+ (void) _appendDataURLToResponse:(GSWResponse*) response
                        inContext:(GSWContext*) context
                              key:(GSWAssociation*) key
                             data:(GSWAssociation*) data
                         mimeType:(GSWAssociation*) mimeType
                 urlAttributeName:(NSString *) urlAttribute    // @"src"
                      inComponent:(GSWComponent*) component
{
  NSString * dataURL = [self _dataURLInContext: context
                                           key: key
                                          data: data 
                                      mimeType: mimeType
                                   inComponent: component];


  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, urlAttribute, dataURL, NO);    
}

// checkme if 0 is the right value in GSW for unused applicationNumber

// dataURL
- (NSString*) dataURLInContext:(GSWContext *) context
{
  int                    appNr = 0;
  NSString             * appNrStr = nil;
  GSWDynamicURLString  * url = nil;    
  GSWDynamicURLString  * url2 = nil;    
  NSMutableString      * myStr = [NSMutableString stringWithCapacity:80];
  
  [myStr appendString: GSWKey_Data[GSWebNamingConv]];       //wodata
  [myStr appendString:@"="];
  [myStr appendString:[[self key] encodeURL]];

  appNr = [[context request] applicationNumber];
  if (appNr > 0) {
    url = [context _url];
    appNrStr = [url applicationNumber];
    // with our current URLString it is a bit waste of time but that is how others to it.
    [url setApplicationNumber: GSWIntToNSString(appNr)];
  }

  url2 = [context urlWithRequestHandlerKey:[GSWApp resourceRequestHandlerKey]
                                      path: nil
                               queryString: myStr];
              
  if (appNr > 0) {
    [url setApplicationNumber:appNrStr];
  }
  return url2;
}


-(id)initWithData:(NSData*)data
         mimeType:(NSString*)type
              key:(NSString*)key
{
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      ASSIGN(_data,data);
      NSDebugMLog(@"data=%@",_data);
      ASSIGN(_mimeType,type);
      NSDebugMLog(@"mimeType=%@",_mimeType);
      NSDebugMLog(@"key=%@",key);
      if (key)
        {
          ASSIGN(_key,key);
        }
      else
        {
          _temporaryKey=YES;
          ASSIGN(_key,
		 [NSString stringUniqueIdWithLength:sizeof(NSTimeInterval)]);
        };
      NSDebugMLog(@"key=%@",_key);
    };
  LOGObjectFnStop();
  return self;
};


//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_data);
  DESTROY(_mimeType);
  DESTROY(_key);
  [super dealloc];
};

//--------------------------------------------------------------------
-(void)appendDataURLToResponse:(GSWResponse*)aResponse
                     inContext:(GSWContext*)aContext
{
  NSString* queryString=nil;
  GSWDynamicURLString* url=nil;
  LOGObjectFnStart();
  queryString=[NSString stringWithFormat:@"%@=%@",GSWKey_Data[GSWebNamingConv],[self key]];
  NSDebugMLog(@"queryString=%@",queryString);
  url=[aContext urlWithRequestHandlerKey:GSWResourceRequestHandlerKey[GSWebNamingConv]
               path:nil
               queryString:queryString];
  NSDebugMLog(@"url=%@",url);
  GSWResponse_appendContentAsciiString(aResponse,(NSString*)url);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)aContext
{
  //OK
  NSData* data=_data;
  LOGObjectFnStart();
//  GSWStartElement(aContext);
//  GSWSaveAppendToResponseElementID(aContext);
  NSDebugMLog(@"data=%@",data);
  if (!data)
    {
      NSDebugMLog(@"key=%@",_key);
      data=[NSData dataWithContentsOfFile:_key];
      NSDebugMLog(@"data=%@",data);
    }
  else
    [response setContent:data];
  [response setHeader:GSWIntToNSString((int)[data length])
            forKey:@"content-length"];
  
  [response setHeader:_mimeType
            forKey:@"content-type"];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_get_class_name(self),
                   (void*)self];
};

//--------------------------------------------------------------------
-(BOOL)isTemporary
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _temporaryKey;
};

//--------------------------------------------------------------------
-(NSData*)data
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _data;
};

//--------------------------------------------------------------------
-(NSString*)type
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _mimeType;
};

//--------------------------------------------------------------------
-(NSString*)key
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _key;
};

@end
