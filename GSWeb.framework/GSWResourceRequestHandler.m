/* GSWResourceRequestHandler.m - GSWeb: Class GSWResourceRequestHandler
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Feb 1999
   
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWResourceRequestHandler

//--------------------------------------------------------------------
-(GSWResponse*)handleRequest:(GSWRequest*)request_
{
  //OK
  // /cgi/GSWeb.exe/ObjCTest3.gswa/wr?gswdata=0
  GSWResponse* _response=nil;
  NSString* _gswdata=nil;
  NSDictionary* _elements=nil;
  LOGObjectFnStart();
  _elements=[request_ uriOrFormOrCookiesElements];
  NSDebugMLog(@"_elements=%@",_elements);
  _gswdata=[_elements objectForKey:GSWKey_Data[GSWebNamingConv]];
  NSDebugMLog(@"_gswdata=%@",_gswdata);
  if (_gswdata)
	_response=[self _responseForDataCachedWithKey:_gswdata];
  else
	{
	  ExceptionRaise0(@"GSWResourceRequestHandler",@"No data key in request");
	  LOGError0(@"");//TODO
	};
  NSDebugMLog(@"_response=%@",_response);
  [_response _finalizeInContext:nil];
  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
-(GSWResponse*)_responseForJavaClassAtPath:(NSString*)_path
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(GSWResponse*)_responseForDataAtPath:(NSString*)_path
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(GSWResponse*)_responseForDataCachedWithKey:(NSString*)_key
{
  //OK
  GSWResponse* _response=nil;
  GSWResourceManager* _resourceManager=nil;
  GSWURLValuedElementData* _data=nil;
  LOGObjectFnStart();
  NSDebugMLog(@"_key=%@",_key);
  _response=[[GSWResponse new]autorelease];
  _resourceManager=[[GSWApplication application] resourceManager];
  _data=[_resourceManager _cachedDataForKey:_key];
  NSDebugMLog(@"_data=%@",_data);
  if (_data)
	[_data appendToResponse:_response
		   inContext:nil];
  else
	{
	  LOGSeriousError(@"No data for _key %@",
					  _key);
	  //TODO
	};
  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
-(GSWResponse*)_generateResponseForData:(NSData*)_data
							  mimeType:(NSString*)_mimeType
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

