/* GSWLogin.m - GSWeb: Class GSWLogin
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
#include <gsweb/GSWeb.framework/GSWeb.h>
#include "GSWLogin.h"
//====================================================================
@implementation GSWLogin

-(id)init
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  NSDebugMLog(@"associationsKeys=%@",associationsKeys);
	};
  LOGObjectFnStop();
  return self;
};

-(void)awake
{
  LOGObjectFnStart();
  [super awake];
  message=nil;
  user=nil;
  password=nil;
  currentDate=nil;
  LOGObjectFnStop();
};

-(void)sleep
{
  LOGObjectFnStart();
  message=nil;
  user=nil;
  password=nil;
  currentDate=nil;
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

-(GSWComponent*)login
{
  GSWComponent* _nextPage=nil;
  BOOL _bindingOk=NO;
  LOGObjectFnStart();
  NSDebugMLog(@"user=%@ password=%@",user,password);
  NSDebugMLog(@"associationsKeys=%@",associationsKeys);
  if ([self hasBinding:@"password"])
	{
	  if ([self hasBinding:@"user"])
		{
		  _bindingOk=YES;
		  [self setValue:user
				forBinding:@"user"];
		}
	  else if ([self hasBinding:@"login"])
		{
		  _bindingOk=YES;
		  [self setValue:user
				forBinding:@"login"];
		};
	};
  NSDebugMLog(@"_bindingOk=%s",(_bindingOk ? "YES" : "NO"));
  if (_bindingOk)
	{
	  [self setValue:password
			forBinding:@"password"];
	  _nextPage=[[self parent] validateLogin];
	}
  else
	_nextPage=[[self parent] validateLoginUser:user
							 password:password];
  if ([self hasBinding:@"message"])
	{
	  message=[self valueForBinding:@"message"];
	};
  NSDebugMLog(@"message=%@",message);
  LOGObjectFnStop();
  return _nextPage;
};

-(NSString*)currentDate
{
  return @"--";
};

-(void)setCurrentDate:(NSString*)date_
{
  NSDebugMLog(@"FDdate_=%@",date_);
};

-(NSString*)onClickString
{
  return @"d=Date(); this.form.currentDate.value=Date.UTC(d.getYear(),d.getMonth(),d.getDay(),d.getHours(),d.getMinutes(),d.getSeconds())";
};

@end

