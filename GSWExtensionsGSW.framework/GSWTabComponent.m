/** GSWTabComponent.m - <title>GSWeb: Class GSWTabComponent</title>
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Apr 1999
   
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

static char rcsId[] = "$Id$";

#include "GSWExtGSWWOCompatibility.h"
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
  NSString* image=nil;
  BOOL isSelected=NO;
  LOGObjectFnStart();
  isSelected=boolValueFor([self valueForBinding:@"isCurrentTabSelected"]);
  if (isSelected)
    {
      if ([self hasBinding:@"tabLeftBorderSelectedImage"])
        image=[self valueForBinding:@"tabLeftBorderSelectedImage"];
      else if ([self hasBinding:@"tabLeftBorderImage"])
        image=[self valueForBinding:@"tabLeftBorderImage"];
      else
        image = @"tabLeftBorderSelected.gif";
    }
  else
    {
      if ([self hasBinding:@"tabLeftBorderNotSelectedImage"])
        image=[self valueForBinding:@"tabLeftBorderNotSelectedImage"];
      else if ([self hasBinding:@"tabLeftBorderImage"])
        image=[self valueForBinding:@"tabLeftBorderImage"];
      else
        image = @"tabLeftBorderNotSelected.gif";
    };
  NSDebugMLog(@"image=%@",image);
  return image;
};

-(NSString*)tabRightBorderImage
{
  NSString* image=nil;
  BOOL isSelected=NO;
  LOGObjectFnStart();
  isSelected=boolValueFor([self valueForBinding:@"isCurrentTabSelected"]);
  if (isSelected)
    {
      if ([self hasBinding:@"tabRightBorderSelectedImage"])
        image=[self valueForBinding:@"tabRightBorderSelectedImage"];
      else if ([self hasBinding:@"tabRightBorderImage"])
        image=[self valueForBinding:@"tabRightBorderImage"];
      else
        image = @"tabRightBorderSelected.gif";
    }
  else
    {
      if ([self hasBinding:@"tabRightBorderNotSelectedImage"])
        image=[self valueForBinding:@"tabRightBorderNotSelectedImage"];
      else if ([self hasBinding:@"tabRightBorderImage"])
        image=[self valueForBinding:@"tabRightBorderImage"];
      else
        image = @"tabRightBorderNotSelected.gif";
    };
  NSDebugMLog(@"image=%@",image);
  return image;
};
-(NSString*)tabImage
{
  NSString* image=nil;
  BOOL isSelected=NO;
  LOGObjectFnStart();
  isSelected=boolValueFor([self valueForBinding:@"isCurrentTabSelected"]);
  if (isSelected)
    {
      if ([self hasBinding:@"tabSelectedImage"])
        image=[self valueForBinding:@"tabSelectedImage"];
      else if ([self hasBinding:@"tabImage"])
        image=[self valueForBinding:@"tabImage"];
    }
  else
    {
      if ([self hasBinding:@"tabNotSelectedImage"])
        image=[self valueForBinding:@"tabNotSelectedImage"];
      else if ([self hasBinding:@"tabImage"])
        image=[self valueForBinding:@"tabImage"];
    };
  NSDebugMLog(@"image=%@",image);
  return image;
};

-(NSString*)tabText
{
  NSString* text=nil;
  BOOL isSelected=NO;
  LOGObjectFnStart();
  isSelected=boolValueFor([self valueForBinding:@"isCurrentTabSelected"]);
  if (isSelected)
    {
      if ([self hasBinding:@"tabSelectedText"])
        text=[self valueForBinding:@"tabSelectedText"];
      else if ([self hasBinding:@"tabText"])
        text=[self valueForBinding:@"tabText"];
    }
  else
    {
      if ([self hasBinding:@"tabNotSelectedText"])
        text=[self valueForBinding:@"tabNotSelectedText"];
      else if ([self hasBinding:@"tabText"])
        text=[self valueForBinding:@"tabText"];
    };
  NSDebugMLog(@"text=%@",text);
  LOGObjectFnStop();
  return text;
};

-(GSWComponent*)selectCurrentTab
{
  GSWComponent* page=nil;
  LOGObjectFnStart();
  page=[self valueForBinding:@"selectCurrentTab"];
  LOGObjectFnStop();
  return page;
};
@end


