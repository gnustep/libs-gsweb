/** GSWValidationFailureComponent.m - <title>GSWeb: Class GSWValidationFailureComponent</title>
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Sept 1999
   
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

//--------------------------------------------------------------------
-(void)awake
{
  LOGObjectFnStart();
  [super awake];
  _tmpValidationFailureMessage=nil;
  _tmpAllValidationFailureMessagesArray=nil;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)sleep
{
  LOGObjectFnStart();
  _tmpValidationFailureMessage=nil;
  _tmpAllValidationFailureMessagesArray=nil;
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
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)aContext
{
  LOGObjectFnStart();
  _tmpValidationFailureMessage=nil;
  _tmpAllValidationFailureMessagesArray=nil;  
  [super appendToResponse:response
         inContext:aContext];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(BOOL)isValidationFailure
{
  return [[self allValidationFailureMessagesArray] count]>0;
};

//--------------------------------------------------------------------
-(NSArray*)allValidationFailureMessagesArray
{
  LOGObjectFnStart();
  if (!_tmpAllValidationFailureMessagesArray)
    {
      NSArray* allValidationFailureMessagesArray=[[self parent]allValidationFailureMessages];
      NSDebugMLog(@"allValidationFailureMessagesArray=%@",allValidationFailureMessagesArray);
      _tmpAllValidationFailureMessagesArray=allValidationFailureMessagesArray;
      NSDebugMLog(@"_tmpAllValidationFailureMessagesArray=%@",_tmpAllValidationFailureMessagesArray);
    };
  NSDebugMLog(@"_tmpAllValidationFailureMessagesArray=%@",_tmpAllValidationFailureMessagesArray);
  LOGObjectFnStop();
  return _tmpAllValidationFailureMessagesArray;
};

@end

