/** GSWURLValuedElementData.m - <title>GSWeb: Class GSWURLValuedElementData</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
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
@implementation GSWURLValuedElementData

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
-(void)appendDataURLToResponse:(GSWResponse*)response
                     inContext:(GSWContext*)context
{
  NSString* queryString=nil;
  GSWDynamicURLString* url=nil;
  LOGObjectFnStart();
  queryString=[NSString stringWithFormat:@"%@=%@",GSWKey_Data[GSWebNamingConv],[self key]];
  NSDebugMLog(@"queryString=%@",queryString);
  url=[context urlWithRequestHandlerKey:GSWResourceRequestHandlerKey[GSWebNamingConv]
               path:nil
               queryString:queryString];
  NSDebugMLog(@"url=%@",url);
  [response _appendContentAsciiString:(NSString*)url];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  //OK
  NSData* data=_data;
  LOGObjectFnStart();
//  GSWStartElement(context);
//  GSWSaveAppendToResponseElementID(context);
  NSDebugMLog(@"data=%@",data);
  if (!data)
    {
      NSDebugMLog(@"key=%@",_key);
      data=[NSData dataWithContentsOfFile:_key];
      NSDebugMLog(@"data=%@",data);
    }
  else
    [response setContent:data];
  [response setHeader:[NSString stringWithFormat:@"%u",[data length]]
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
