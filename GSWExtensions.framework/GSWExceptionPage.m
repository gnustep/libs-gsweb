/** GSWExceptionPage.m - <title>GSWeb: Class GSWExceptionPage</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
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
#include "GSWExceptionPage.h"

//===================================================================================
@implementation GSWExceptionPage

-(void)dealloc
{
  GSWLogC("Dealloc GSWExceptionPage\n");  
  DESTROY(_exception);
  GSWLogC("Dealloc GSWExceptionPage reasons\n");  
  DESTROY(_reasons);
  GSWLogC("Dealloc GSWExceptionPage reference\n");  
  DESTROY(_reference);
  GSWLogC("Dealloc GSWExceptionPage super\n");  
  [super dealloc];
  GSWLogC("Dealloc GSWExceptionPage end\n");  
};

-(void)awake
{
  if (!_reference)
    {
      ASSIGN(_reference,[NSCalendarDate calendarDate]);
    }
  [super awake];
};

-(void)sleep
{
  [super sleep];
};

-(NSArray*)getReasons
{
  if (!_reasons)
    {
      ASSIGN(_reasons,[[_exception reason] componentsSeparatedByString:@"\n"]);
      NSDebugMLog(@"_reasons=%@",_reasons);
    };
  return _reasons;
};

-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)aContext
{
  [super appendToResponse:response
         inContext:aContext];
  [response disableClientCaching];
};

-(void)setException:(NSException*)exception
{
  ASSIGN(_exception,exception);
  NSDebugMLog(@"_exception=%@",_exception);
};

-(id)getTmpUserInfoValue
{
  //If array, print it nicely
  if ([_tmpUserInfoValue  isKindOfClass:[NSArray class]])
    return [(NSArray*)_tmpUserInfoValue componentsJoinedByString:@"\n"];
  else
    return _tmpUserInfoValue;
}

-(NSString*)referenceString
{
  return _reference;
}
@end
