/* GSWTabComponent.m - GSWeb: Class GSWTabComponent
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Apr 1999
   
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
#include <GSWeb/GSWeb.h>
#include "GSWTabComponent.h"
//====================================================================
@implementation GSWTabComponent

-(id)init
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	};
  LOGObjectFnStop();
  return self;
};

-(void)awake
{
  LOGObjectFnStart();
  [super awake];
  LOGObjectFnStop();
};

-(void)sleep
{
  LOGObjectFnStart();
  [super sleep];
  LOGObjectFnStop();
};

-(void)dealloc
{
  [super dealloc];
};

-(BOOL)synchronizesVariablesWithBindings
{
  return NO;
};

-(NSString*)tabLeftBorderImage
{
  NSString* _image=nil;
  BOOL _isSelected=NO;
  LOGObjectFnStart();
  _isSelected=boolValueFor([self valueForBinding:@"isCurrentTabSelected"]);
  if (_isSelected)
	{
	  if ([self hasBinding:@"tabLeftBorderSelectedImage"])
		_image=[self valueForBinding:@"tabLeftBorderSelectedImage"];
	  else if ([self hasBinding:@"tabLeftBorderImage"])
		_image=[self valueForBinding:@"tabLeftBorderImage"];
	  else
		_image = @"tabLeftBorderSelected.gif";
	}
  else
	{
	  if ([self hasBinding:@"tabLeftBorderNotSelectedImage"])
		_image=[self valueForBinding:@"tabLeftBorderNotSelectedImage"];
	  else if ([self hasBinding:@"tabLeftBorderImage"])
		_image=[self valueForBinding:@"tabLeftBorderImage"];
	  else
		_image = @"tabLeftBorderNotSelected.gif";
	};
  NSDebugMLog(@"_image=%@",_image);
  return _image;
};

-(NSString*)tabRightBorderImage
{
  NSString* _image=nil;
  BOOL _isSelected=NO;
  LOGObjectFnStart();
  _isSelected=boolValueFor([self valueForBinding:@"isCurrentTabSelected"]);
  if (_isSelected)
	{
	  if ([self hasBinding:@"tabRightBorderSelectedImage"])
		_image=[self valueForBinding:@"tabRightBorderSelectedImage"];
	  else if ([self hasBinding:@"tabRightBorderImage"])
		_image=[self valueForBinding:@"tabRightBorderImage"];
	  else
		_image = @"tabRightBorderSelected.gif";
	}
  else
	{
	  if ([self hasBinding:@"tabRightBorderNotSelectedImage"])
		_image=[self valueForBinding:@"tabRightBorderNotSelectedImage"];
	  else if ([self hasBinding:@"tabRightBorderImage"])
		_image=[self valueForBinding:@"tabRightBorderImage"];
	  else
		_image = @"tabRightBorderNotSelected.gif";
	};
  NSDebugMLog(@"_image=%@",_image);
  return _image;
};
-(NSString*)tabImage
{
  NSString* _image=nil;
  BOOL _isSelected=NO;
  LOGObjectFnStart();
  _isSelected=boolValueFor([self valueForBinding:@"isCurrentTabSelected"]);
  if (_isSelected)
	{
	  if ([self hasBinding:@"tabSelectedImage"])
		_image=[self valueForBinding:@"tabSelectedImage"];
	  else if ([self hasBinding:@"tabImage"])
		_image=[self valueForBinding:@"tabImage"];
	}
  else
	{
	  if ([self hasBinding:@"tabNotSelectedImage"])
		_image=[self valueForBinding:@"tabNotSelectedImage"];
	  else if ([self hasBinding:@"tabImage"])
		_image=[self valueForBinding:@"tabImage"];
	};
  NSDebugMLog(@"_image=%@",_image);
  return _image;
};

-(NSString*)tabText
{
  NSString* _text=nil;
  BOOL _isSelected=NO;
  LOGObjectFnStart();
  _isSelected=boolValueFor([self valueForBinding:@"isCurrentTabSelected"]);
  if (_isSelected)
	{
	  if ([self hasBinding:@"tabSelectedText"])
		_text=[self valueForBinding:@"tabSelectedText"];
	  else if ([self hasBinding:@"tabText"])
		_text=[self valueForBinding:@"tabText"];
	}
  else
	{
	  if ([self hasBinding:@"tabNotSelectedText"])
		_text=[self valueForBinding:@"tabNotSelectedText"];
	  else if ([self hasBinding:@"tabText"])
		_text=[self valueForBinding:@"tabText"];
	};
  NSDebugMLog(@"_text=%@",_text);
  LOGObjectFnStop();
  return _text;
};

-(GSWComponent*)selectCurrentTab
{
  GSWComponent* _page=nil;
  LOGObjectFnStart();
  _page=[self valueForBinding:@"selectCurrentTab"];
  LOGObjectFnStop();
  return _page;
};
@end


