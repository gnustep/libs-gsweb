/** GSWLogin.m - <title>GSWeb: Class GSWLogin</title>

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

#include "GSWExtGSWWOCompatibility.h"
#include "GSWLogin.h"
//====================================================================
@implementation GSWLogin

//--------------------------------------------------------------------
-(id)init
{
  LOGObjectFnStart();
  if ((self=[super init]))
    {
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)awake
{
  LOGObjectFnStart();
  [super awake];
  message=nil;
  user=nil;
  password=nil;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)sleep
{
  LOGObjectFnStart();
  message=nil;
  user=nil;
  password=nil;
  [super sleep];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)dealloc
{
  [super dealloc];
};

//--------------------------------------------------------------------
-(BOOL)synchronizesVariablesWithBindings
{
  return NO;
};

//--------------------------------------------------------------------
-(GSWComponent*)login
{
  GSWComponent* _nextPage=nil;
  BOOL _bindingOk=NO;
  LOGObjectFnStart();
  NSDebugMLog(@"user=%@ password=%@",user,password);
  NS_DURING
    {
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
      _tryCount++;
    }
  NS_HANDLER
    {
      LOGException0(@"exception in GSWLogin login action");
      LOGException(@"exception=%@",localException);
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"In GSWLogin login action");
      LOGException(@"exception=%@",localException);
      [localException raise];
    }
  NS_ENDHANDLER;
  LOGObjectFnStop();
  return _nextPage;
};

//--------------------------------------------------------------------
-(NSNumber*)computeIsTryCountGreaterThanForKey:(NSString*)count
{
  NSDebugMLog(@"_tryCount=%d",_tryCount);
  NSDebugMLog(@"count=%@ countIntValue=%d",count,[count intValue]);
  return [NSNumber numberWithBool:(_tryCount>[count intValue] ? YES : NO)];
};
@end

