/* GSWExceptionPage.m - GSWeb: Class GSWExceptionPage
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
#include "GSWExceptionPage.h"

//===================================================================================
@implementation GSWExceptionPage

-(void)dealloc
{
  GSWLogC("Dealloc GSWExceptionPage\n");  
  DESTROY(exception);
  GSWLogC("Dealloc GSWExceptionPage reasons\n");  
  DESTROY(reasons);
  GSWLogC("Dealloc GSWExceptionPage super\n");  
  [super dealloc];
  GSWLogC("Dealloc GSWExceptionPage end\n");  
};

-(void)awake
{
  [super awake];
};

-(void)sleep
{
  [super sleep];
};

-(NSArray*)getReasons
{
  if (!reasons)
	{
	  ASSIGN(reasons,[[exception reason] componentsSeparatedByString:@"\n"]);
	};
  return reasons;
};

-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  [super appendToResponse:response_
			  inContext:context_];
  [response_ disableClientCaching];
};

-(void)setException:(NSException*)exception_
{
  ASSIGN(exception,exception_);
};

-(id)getTmpUserInfoValue
{
  //If array, print it nicely
  if ([tmpUserInfoValue  isKindOfClass:[NSArray class]])
      return [tmpUserInfoValue componentsJoinedByString:@"\n"];
  else
    return tmpUserInfoValue;
}
@end
