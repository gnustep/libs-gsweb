/* GSWFileUploadFormComponent.m - GSWeb: Class GSWFileUploadFormComponent
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Dec 1999
   
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
#include <gsweb/GSWeb.framework/GSWeb.h>
#include "GSWFileUploadFormComponent.h"
//====================================================================
@implementation GSWFileUploadFormComponent

//--------------------------------------------------------------------
-(id)init
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)awake
{
  LOGObjectFnStart();
  [super awake];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)sleep
{
  LOGObjectFnStart();
  [super sleep];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(fileInfo);
  [super dealloc];
};

//--------------------------------------------------------------------
-(BOOL)synchronizesVariablesWithBindings
{
  return NO;
};

//--------------------------------------------------------------------
-(NSMutableDictionary*)fileInfo
{
  LOGObjectFnStart();
  if (!fileInfo)
	{
	  if ([self hasBinding:@"fileInfo"])
		{
		  fileInfo=[[self valueForBinding:@"fileInfo"] mutableCopy];
		};
	};
  LOGObjectFnStop();
  return fileInfo;
};

//--------------------------------------------------------------------
-(BOOL)isViewEnabled
{
  BOOL _isViewEnabled=YES;
  if ([self hasBinding:@"isViewEnabled"])
	{
	  id _isViewEnabledObject=[self valueForBinding:@"isViewEnabled"];
	  _isViewEnabled=boolValueFor(_isViewEnabledObject);
	};
  if (_isViewEnabled)
	{
	  _isViewEnabled=([[self fileInfo]objectForKey:@"data"]!=nil);
	};
  return _isViewEnabled;
};

//--------------------------------------------------------------------
-(GSWComponent*)updateAction
{
  GSWComponent* _returnPage=nil;
  LOGObjectFnStart();
  [self setValue:fileInfo
		forBinding:@"fileInfo"];
  if ([self hasBinding:@"action"])
	{
	  _returnPage=[self valueForBinding:@"action"];
	};
  DESTROY(fileInfo);
  LOGObjectFnStop();
  return _returnPage;
};

//--------------------------------------------------------------------
-(GSWComponent*)deleteAction
{
  GSWComponent* _returnPage=nil;
  LOGObjectFnStart();
  [fileInfo removeObjectForKey:@"data"];
  [self setValue:fileInfo
		forBinding:@"fileInfo"];
  if ([self hasBinding:@"action"])
	{
	  _returnPage=[self valueForBinding:@"action"];
	};
  DESTROY(fileInfo);
  LOGObjectFnStop();
  return _returnPage;
};

@end


