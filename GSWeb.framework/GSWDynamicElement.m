/* GSWDynamicElement.m - GSWeb: Class GSWDynamicElement
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
@implementation GSWDynamicElement

//--------------------------------------------------------------------
//	initWithName:associations:template:

-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
		 template:(GSWElement*)template_
{
  //OK
  if ((self=[super init]))
	{
	};
  return self;
};


//====================================================================
@implementation GSWDynamicElement (GSWDynamicElement)

//--------------------------------------------------------------------
-(BOOL)evaluateCondition:(id)condition_
			   inContext:(GSWContext*)_context
{
  //OK
  BOOL _result=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"condition_=%@",condition_);
  if (condition_)
	{
	  GSWComponent* _component=[_context component];
	  id _value=[condition_ valueInComponent:_component];
	  NSDebugMLLog(@"gswdync",@"_value=%@ class=%@",_value,[_value class]);
#ifndef NDEBUG
	  if ([_value respondsToSelector:@selector(unsignedCharValue)])
		{
		  NSDebugMLLog(@"gswdync",@"unsignedCharValue=%d",(int)[_value unsignedCharValue]);
		};
#endif
	  _result=boolValueWithDefaultFor(_value,YES);
	};
  LOGObjectFnStop();
  return _result;
};
@end
