/** GSWIFrame.m - <title>GSWeb: Class GSWIFrame</title>
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

#include <GSWeb/GSWeb.h>
#include "GSWIFrame.h"

//===================================================================================
@implementation GSWIFrame

-(BOOL)synchronizesVariablesWithBindings
{
  return NO;
};

-(NSString*)srcUrl
{
  NSString* src=nil;
  if ([self hasBinding:@"src"])
    src=[self valueForBinding:@"src"];
  else if ([self hasBinding:@"pageName"] || [self hasBinding:@"value"])
    src=[[self context]componentActionURL];
  return src;
};

-(GSWElement*)getFrameContent
{
  GSWElement* element=nil;
  if ([self hasBinding:@"pageName"])
    {
      NSString* pageName = [self valueForBinding:@"pageName"];
      element=[self pageWithName:pageName];
    }
  else
    element = [self valueForBinding:@"value"];        
  return element;
};

@end
