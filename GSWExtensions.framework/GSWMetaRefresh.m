/** GSWMetaRefresh.m - <title>GSWeb: Class GSWMetaRefresh</title>
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

#include "GSWExtWOCompatibility.h"
#include "GSWMetaRefresh.h"

//===================================================================================
@implementation GSWMetaRefresh
-(BOOL)synchronizesVariablesWithBindings
{
  return NO;
};

-(NSString*)contentString
{
  NSNumber* seconds = [self valueForBinding:@"seconds"];
  NSString* contentString = [NSString stringWithFormat:@"%@;url=%@",
                                      [seconds description],
                                      [[self context]componentActionURL]];
  return contentString;
};

-(GSWComponent*)invokeAction
{
  GSWComponent* component = nil;
  if ([self hasBinding:@"pageName"])
    {
      NSString* pageName = [self valueForBinding:@"pageName"];
      component = [self pageWithName:pageName];
    }
  else
    component = [self valueForBinding:@"action"];
  return component;
};


@end
