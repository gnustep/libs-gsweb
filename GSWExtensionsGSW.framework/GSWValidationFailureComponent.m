/* GSWValidationFailureComponent.m - GSWeb: Class GSWValidationFailureComponent
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Sept 1999
   
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
#include "GSWValidationFailureComponent.h"
//====================================================================
@implementation GSWValidationFailureComponent

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
  tmpValidationFailureMessage=nil;
  tmpAllValidationFailureMessagesArray=nil;
  LOGObjectFnStop();
};

-(void)sleep
{
  LOGObjectFnStart();
  tmpValidationFailureMessage=nil;
  tmpAllValidationFailureMessagesArray=nil;
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

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  LOGObjectFnStart();
  tmpValidationFailureMessage=nil;
  tmpAllValidationFailureMessagesArray=nil;  
  [super appendToResponse:response_
                          inContext:context_];
  LOGObjectFnStop();
};

-(BOOL)isValidationFailure
{
  return [[self allValidationFailureMessagesArray] count]>0;
};

-(NSArray*)allValidationFailureMessagesArray
{
  LOGObjectFnStart();
  if (!tmpAllValidationFailureMessagesArray)
	{
	  NSArray* _allValidationFailureMessagesArray=[[self parent]allValidationFailureMessages];
	  NSDebugMLog(@"_allValidationFailureMessagesArray=%@",_allValidationFailureMessagesArray);
	  tmpAllValidationFailureMessagesArray=_allValidationFailureMessagesArray;
	  NSDebugMLog(@"tmpAllValidationFailureMessagesArray=%@",tmpAllValidationFailureMessagesArray);
	};
  NSDebugMLog(@"tmpAllValidationFailureMessagesArray=%@",tmpAllValidationFailureMessagesArray);
  LOGObjectFnStop();
  return tmpAllValidationFailureMessagesArray;
};

@end

