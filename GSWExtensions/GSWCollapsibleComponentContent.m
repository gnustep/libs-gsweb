/** GSWCollapsibleComponentContent.m - <title>GSWeb: Class GSWCollapsibleComponentContent</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Apr 1999
   
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

#include "GSWExtWOCompatibility.h"
#include "GSWCollapsibleComponentContent.h"

//===================================================================================
@implementation GSWCollapsibleComponentContent

//-----------------------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_framework);
  DESTROY(_openedImageFileName);
  DESTROY(_closedImageFileName);
  DESTROY(_openedHelpString);
  DESTROY(_closedHelpString);
  [super dealloc];
};

//-----------------------------------------------------------------------------------
-(BOOL)synchronizesVariablesWithBindings
{
    return NO;
};

//-----------------------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext 
{
  _tmpAnchorName=AUTORELEASE([[aContext elementID]copy]);
  [super appendToResponse:aResponse
         inContext:aContext];
  _tmpAnchorName=nil;
};

//-----------------------------------------------------------------------------------
-(BOOL)isVisible
{

  if (!_isVisibleConditionPassed)
    {
      if ([self hasBinding:@"condition"])
        _isVisible=boolValueFor([self valueForBinding:@"condition"]);
      else if ([self hasBinding:@"visibility"])
        _isVisible=boolValueFor([self valueForBinding:@"visibility"]);
      else
        _isVisible=boolValueFor([self valueForBinding:@"condition"]);
      _isVisibleConditionPassed=YES;
    };

  return _isVisible;
};

//-----------------------------------------------------------------------------------
-(GSWComponent*)toggleVisibilityAction
{
  _isVisible = ![self isVisible];

  if ([self hasBinding:@"visibility"])
	{
	  [self setValue:(_isVisible ? GSWNumberYes : GSWNumberNo)
                forBinding:@"visibility"];
	};

  return nil;
};

//-----------------------------------------------------------------------------------
- (NSString*)framework
{
  if (!_framework)
    {
      if ([self hasBinding:@"framework"])
	ASSIGN(_framework,([self valueForBinding:@"framework"]));
      else
	ASSIGN(_framework,([GSWApp frameworkNameGSWExtensions]));
    }
  return _framework;
}

//-----------------------------------------------------------------------------------
-(NSString*)imageFileName
{
  NSString* _image=nil;

  if ([self isVisible])
	{
	  if (!_openedImageFileName) 
		{
		  if ([self hasBinding:@"openedImageFileName"])
			ASSIGN(_openedImageFileName,[self valueForBinding:@"openedImageFileName"]);
		  else if ([self hasBinding:@"helpString"])
			ASSIGN(_openedImageFileName,[self valueForBinding:@"helpString"]);
		  else
			ASSIGN(_openedImageFileName,@"DownTriangle.png");
		};
	  _image=_openedImageFileName;
	}
  else
	{
	  if (!_closedImageFileName) 
		{
		  if ([self hasBinding:@"closedImageFileName"])
			ASSIGN(_closedImageFileName,[self valueForBinding:@"closedImageFileName"]);
		  else if ([self hasBinding:@"helpString"])
			ASSIGN(_closedImageFileName,[self valueForBinding:@"helpString"]);
		  else
			ASSIGN(_closedImageFileName,@"RightTriangle.png");
		};
	  _image=_closedImageFileName;
	};

  return _image;
};

//-----------------------------------------------------------------------------------
-(NSString *)label
{
  NSString* _label=nil;

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
  
  return _label;
};

//-----------------------------------------------------------------------------------
-(NSString*)helpString
{
  NSString* _helpString=nil;

  if ([self isVisible])
	{
	  if (!_openedHelpString)
		{
		  if ([self hasBinding:@"openedHelpString"])
			ASSIGN(_openedHelpString,[self valueForBinding:@"openedHelpString"]);
		  else if ([self hasBinding:@"helpString"])
			ASSIGN(_openedHelpString,[self valueForBinding:@"helpString"]);
		  else
			ASSIGN(_openedHelpString,@"Click to collapse");
		};
	  _helpString=_openedHelpString;
	}
  else
	{
	  if (!_closedHelpString) 
		{
		  if ([self hasBinding:@"closedHelpString"])
			ASSIGN(_closedHelpString,[self valueForBinding:@"closedHelpString"]);
		  else if ([self hasBinding:@"helpString"])
			ASSIGN(_closedHelpString,[self valueForBinding:@"helpString"]);
		  else
			ASSIGN(_closedHelpString,@"Click to expand");
		};
	  _helpString=_closedHelpString;
	};

  return _helpString;
};

//-----------------------------------------------------------------------------------
-(NSString*)anchorName
{
  return _tmpAnchorName;
};

//-----------------------------------------------------------------------------------
-(BOOL)isDisabled
{
  BOOL isDisabled=NO;

  if ([self hasBinding:@"disabled"])
    isDisabled=boolValueFor([self valueForBinding:@"disabled"]);
  else if ([self hasBinding:@"enabled"])
    {
      BOOL isEnabled=boolValueFor([self valueForBinding:@"enabled"]);
      isDisabled=(isEnabled ? NO : YES);
    };
  
  return isDisabled;
};

//-----------------------------------------------------------------------------------
-(BOOL)shouldDisplay
{
  BOOL shouldDisplay=YES;

  if ([self isDisabled]
      && [self hasBinding:@"displayDisabled"]
      && !boolValueFor([self valueForBinding:@"displayDisabled"]))
    shouldDisplay=NO;
  
  return shouldDisplay;
};

@end
