/* GSWHTMLStaticGroup.m - GSWeb: Class GSWHTMLStaticGroup
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

#include <gsweb/GSWeb.framework/GSWeb.h>

//====================================================================
@implementation GSWHTMLStaticGroup
-(id)initWithContentElements:(NSArray*)elements_
{
  //OK
  LOGObjectFnStart();  
  NSDebugMLLog(@"gswdync",@"elements_:%@",elements_);
  if ([elements_ count]==1 && [[elements_ objectAtIndex:0] class]==[GSWHTMLStaticGroup class])
	  self=[super initWithName:nil
				  attributeDictionary:nil
				  contentElements:[[elements_ objectAtIndex:0]dynamicChildren]];
  else
	  self=[super initWithName:nil
				  attributeDictionary:nil
				  contentElements:elements_];
  LOGObjectFnStop();
  return self;
};

@end
