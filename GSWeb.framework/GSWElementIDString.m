/* GSWElementIDString.m - GSWeb: Class GSWElementIDString
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
@implementation GSWElementIDString
@end

//====================================================================
@implementation GSWElementIDString  (GSWElementIDStringGSW)

//--------------------------------------------------------------------
-(void)deleteAllElementIDComponents
{
  [self setString:nil];
};

//--------------------------------------------------------------------
-(void)deleteLastElementIDComponent
{
  NSArray* ids=nil;
  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"self:%@",self);  
  if ([self length]>0)
	{
	  ids=[self componentsSeparatedByString:@"."];
	  NSAssert([ids count]>0,@"PROBLEM");
	  if ([ids count]==1)
		[self setString:@""];
	  else
		{
		  [self setString:[[ids subarrayWithRange:NSMakeRange(0,[ids count]-1)]
							componentsJoinedByString:@"."]];
		};
	}
  else
	{
	  ExceptionRaise0(@"GSWElementIDString",@"Can't deleteLastElementIDComponent of an empty ElementID String");
	};
  NSDebugMLLog(@"low",@"self:%@",self);  
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)incrementLastElementIDComponent
{
  NSArray* ids=nil;
  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"self:%@",self);  
  ids=[self componentsSeparatedByString:@"."];
  if (ids && [ids count]>0)
	{
	  NSString* _last=[ids lastObject];
	  NSString* _new=nil;
	  NSDebugMLLog(@"low",@"_last:%@",_last);  
	  _last=[NSString  stringWithFormat:@"%d",([_last intValue]+1)];	  
	  NSDebugMLLog(@"low",@"_last:%@",_last);  
	  NSDebugMLLog(@"low",@"ids count:%d",[ids count]);  
	  if ([ids count]>1)
		_new=[[[ids subarrayWithRange:NSMakeRange(0,[ids count]-1)]
				componentsJoinedByString:@"."]
			   stringByAppendingFormat:@".%@",_last];
	  else
		_new=_last;
	  [self setString:_new];
	};
  NSDebugMLLog(@"low",@"self:%@",self);  
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendZeroElementIDComponent
{
  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"self:%@",self);  
  if ([self length]>0)
	  [self appendString:@".0"];
  else
	  [self setString:@"0"];
  NSDebugMLLog(@"low",@"self:%@",self);  
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendElementIDComponent:(id)_element
{
  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"self:%@",self);  
//  NSDebugMLLog(@"low",@"_element:%@",_element);  
  if (self && [self length]>0)
	  [self appendFormat:@".%@",_element];
  else
	  [self setString:_element];
  NSDebugMLLog(@"low",@"self:%@",self);  
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
#ifndef NDEBBUG
-(int)elementsNb
{
	if ([self length]==0)
	  return 0;
	else
	  return [[self componentsSeparatedByString:@"."] count];
};
#endif

@end
