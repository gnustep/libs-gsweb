/* GSWCollapsibleComponentContent.m - GSWeb: Class GSWCollapsibleComponentContent
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
#include "GSWCollapsibleComponentContent.h"

//===================================================================================
@implementation GSWCollapsibleComponentContent

-(void)awake
{
  [super awake];
};

-(void)sleep
{
  [super sleep];
};

-(void)dealloc
{
  GSWLogC("Dealloc GSWCollopsibleComponent");
  GSWLogC("Dealloc GSWCollopsibleComponent Super");
  DESTROY(openedImageFileName);
  DESTROY(closedImageFileName);
  DESTROY(openedHelpString);
  DESTROY(closedHelpString);
  [super dealloc];
  GSWLogC("End Dealloc GSWCollopsibleComponent");
};

-(BOOL)synchronizesVariablesWithBindings
{
    return NO;
};

-(BOOL)isVisible
{
  LOGObjectFnStart();
  NSDebugMLog(@"isVisibleConditionPassed=%s",(isVisibleConditionPassed ? "YES" : "NO"));
  if (!isVisibleConditionPassed)
	{
	  isVisible=boolValueFor([self valueForBinding:@"condition"]);
	  isVisibleConditionPassed=YES;
	};
  NSDebugMLog(@"isVisible=%s",(isVisible ? "YES" : "NO"));
  LOGObjectFnStop();
  return isVisible;
};

-(GSWComponent*)toggleVisibilityAction
{
  LOGObjectFnStart();
  NSDebugMLog(@"isVisible=%s",(isVisible ? "YES" : "NO"));
  isVisible = ![self isVisible];
  NSDebugMLog(@"isVisible=%s",(isVisible ? "YES" : "NO"));
  if ([self hasBinding:@"visibility"])
	{
	  [self setValue:[NSNumber numberWithBool:isVisible]
							   forBinding:@"visibility"];
	};
  LOGObjectFnStop();
  return nil;
};

-(NSString*)imageFileName
{
  NSString* _image=nil;
  LOGObjectFnStart();
  if ([self isVisible])
	{
	  if (!openedImageFileName) 
		{
		  if ([self hasBinding:@"openedImageFileName"])
			ASSIGN(openedImageFileName,[self valueForBinding:@"openedImageFileName"]);
		  else if ([self hasBinding:@"helpString"])
			ASSIGN(openedImageFileName,[self valueForBinding:@"helpString"]);
		  else
			ASSIGN(openedImageFileName,@"DownTriangle.png");
		};
	  _image=openedImageFileName;
	}
  else
	{
	  NSDebugMLog(@"closedImageFileName=%@",closedImageFileName);
	  if (!closedImageFileName) 
		{
		  if ([self hasBinding:@"closedImageFileName"])
			ASSIGN(closedImageFileName,[self valueForBinding:@"closedImageFileName"]);
		  else if ([self hasBinding:@"helpString"])
			ASSIGN(closedImageFileName,[self valueForBinding:@"helpString"]);
		  else
			ASSIGN(closedImageFileName,@"RightTriangle.png");
		};
	  _image=closedImageFileName;
	};
  NSDebugMLog(@"_image=%@",_image);
  LOGObjectFnStop();
  return _image;
};

-(NSString*)label
{
  NSString* _label=nil;
  LOGObjectFnStart();
  if ([self isVisible])
	{
	  if ([self hasBinding:@"openedLabel"])
		_label=[self valueForBinding:@"openedLabel"];
	  else if ([self hasBinding:@"label"])
		_label=[self valueForBinding:@"label"];
	}
  else
	{
	  if ([self hasBinding:@"closedLabel"])
		_label=[self valueForBinding:@"closedLabel"];
	  else if ([self hasBinding:@"label"])
		_label=[self valueForBinding:@"label"];
	};
  NSDebugMLog(@"_label=%@",_label);
  LOGObjectFnStop();
  return _label;
};

-(NSString*)helpString
{
  NSString* _helpString=nil;
  LOGObjectFnStart();
  if ([self isVisible])
	{
	  if (!openedHelpString)
		{
		  if ([self hasBinding:@"openedHelpString"])
			ASSIGN(openedHelpString,[self valueForBinding:@"openedHelpString"]);
		  else if ([self hasBinding:@"helpString"])
			ASSIGN(openedHelpString,[self valueForBinding:@"helpString"]);
		  else
			ASSIGN(openedHelpString,@"Click to collapse");
		};
	  _helpString=openedHelpString;
	}
  else
	{
	  if (!closedHelpString) 
		{
		  if ([self hasBinding:@"closedHelpString"])
			ASSIGN(closedHelpString,[self valueForBinding:@"closedHelpString"]);
		  else if ([self hasBinding:@"helpString"])
			ASSIGN(closedHelpString,[self valueForBinding:@"helpString"]);
		  else
			ASSIGN(closedHelpString,@"Click to expand");
		};
	  _helpString=closedHelpString;
	};
  NSDebugMLog(@"_helpString=%@",_helpString);
  LOGObjectFnStop();
  return _helpString;
};


@end
