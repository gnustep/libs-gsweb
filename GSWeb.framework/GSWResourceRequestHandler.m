/** GSWResourceRequestHandler.m - <title>GSWeb: Class GSWResourceRequestHandler</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 1999
   
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

//====================================================================
@implementation GSWResourceRequestHandler

//--------------------------------------------------------------------
-(GSWResponse*)handleRequest:(GSWRequest*)aRequest
{
  //OK
  // /GSWeb/ObjCTest3.gswa/wr?gswdata=0
  GSWResponse* response=nil;
  NSString* gswdata=nil;
  NSDictionary* elements=nil;
  LOGObjectFnStart();
  elements=[aRequest uriOrFormOrCookiesElements];
  NSDebugMLog(@"elements=%@",elements);
  gswdata=[elements objectForKey:GSWKey_Data[GSWebNamingConv]];
  NSDebugMLog(@"gswdata=%@",gswdata);
  if (gswdata)
    response=[self _responseForDataCachedWithKey:gswdata];
  else
    {
      ExceptionRaise0(@"GSWResourceRequestHandler",@"No data key in request");
      LOGError0(@"");//TODO
    };
  NSDebugMLog(@"response=%@",response);
  [response _finalizeInContext:nil];
  LOGObjectFnStop();
  return response;
};

//--------------------------------------------------------------------
-(GSWResponse*)_responseForJavaClassAtPath:(NSString*)aPath
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(GSWResponse*)_responseForDataAtPath:(NSString*)aPath
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(GSWResponse*)_responseForDataCachedWithKey:(NSString*)aKey
{
  //OK
  GSWResponse* response=nil;
  GSWResourceManager* resourceManager=nil;
  GSWURLValuedElementData* data=nil;
  LOGObjectFnStart();
  NSDebugMLog(@"aKey=%@",aKey);
  response=[GSWApp createResponseInContext:nil];
  resourceManager=[[GSWApplication application] resourceManager];
  data=[resourceManager _cachedDataForKey:aKey];
  NSDebugMLog(@"data=%@",data);
  if (data)
    [data appendToResponse:response
          inContext:nil];
  else
    {
      LOGSeriousError(@"No data for key '%@'",
                      aKey);
      //TODO
    };
  LOGObjectFnStop();
  return response;
};

//--------------------------------------------------------------------
-(GSWResponse*)_generateResponseForData:(NSData*)aData
                               mimeType:(NSString*)mimeType
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWResourceRequestHandler (GSWRequestHandlerClassA)

//--------------------------------------------------------------------
+(id)handler
{
  return [[GSWResourceRequestHandler new] autorelease];
};

@end

