/* GSWURLValuedElementData.m - GSWeb: Class GSWURLValuedElementData
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

static char rcsId[] = "$Id$";

#include <gsweb/GSWeb.framework/GSWeb.h>

//====================================================================
@implementation GSWURLValuedElementData

-(id)initWithData:(NSData*)data_
		 mimeType:(NSString*)type_
			  key:(NSString*)key_
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  ASSIGN(data,data_);
	  NSDebugMLog(@"data=%@",data);
	  ASSIGN(mimeType,type_);
	  NSDebugMLog(@"mimeType=%@",mimeType);
	  NSDebugMLog(@"key_=%@",key_);
	  if (key_)
		{
		  ASSIGN(key,key_);
		}
	  else
		{
		  temporaryKey=YES;
		  ASSIGN(key,[NSString stringUniqueIdWithLength:4]);
		};
	  NSDebugMLog(@"key=%@",key);
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(data);
  DESTROY(mimeType);
  DESTROY(key);
  [super dealloc];
};

//--------------------------------------------------------------------
-(void)appendDataURLToResponse:(GSWResponse*)response_
					 inContext:(GSWContext*)context_
{
  NSString* _queryString=nil;
  GSWDynamicURLString* _url=nil;
  LOGObjectFnStart();
  _queryString=[NSString stringWithFormat:@"%@=%@",GSWKey_Data,[self key]];
  NSDebugMLog(@"_queryString=%@",_queryString);
  _url=[context_ urlWithRequestHandlerKey:GSWResourceRequestHandlerKey
				 path:nil
				 queryString:_queryString];
  NSDebugMLog(@"_url=%@",_url);
  [response_ _appendContentAsciiString:(NSString*)_url];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
  NSData* _data=data;
  LOGObjectFnStart();
  NSDebugMLog(@"_data=%@",_data);
  [response_ setHeader:[NSString stringWithFormat:@"%u",[data length]]
			 forKey:@"content-length"];
  if (!_data)
	{
	  NSDebugMLog(@"key=%@",key);
	  _data=[NSData dataWithContentsOfFile:key];
	  NSDebugMLog(@"_data=%@",_data);
	}
  else
	[response_ setContent:_data];
  
  [response_ setHeader:mimeType
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
  return temporaryKey;
};

//--------------------------------------------------------------------
-(NSData*)data
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return data;
};

//--------------------------------------------------------------------
-(NSString*)type
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return mimeType;
};

//--------------------------------------------------------------------
-(NSString*)key
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return key;
};

@end
