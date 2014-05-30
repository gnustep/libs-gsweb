/** GSWValidationFailureComponent.m - <title>GSWeb: Class GSWValidationFailureComponent</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Sept 1999
   
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

#include "GSWExtGSWWOCompatibility.h"
#include "GSWValidationFailureComponent.h"
//====================================================================
@implementation GSWValidationFailureComponent

-(id)init
{
  if ((self=[super init]))
	{
	};
  return self;
};

//--------------------------------------------------------------------
-(void)awake
{
  [super awake];
  _tmpValidationFailureMessage=nil;
  _tmpAllValidationFailureMessagesArray=nil;
};

//--------------------------------------------------------------------
-(void)sleep
{
  _tmpValidationFailureMessage=nil;
  _tmpAllValidationFailureMessagesArray=nil;
  [super sleep];
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
  _tmpValidationFailureMessage=nil;
  _tmpAllValidationFailureMessagesArray=nil;  
  [super appendToResponse:response
         inContext:aContext];
};

//--------------------------------------------------------------------
-(BOOL)isValidationFailure
{
  return [[self allValidationFailureMessagesArray] count]>0;
};

//--------------------------------------------------------------------
-(NSArray*)allValidationFailureMessagesArray
{
  if (!_tmpAllValidationFailureMessagesArray)
    {
      NSArray* allValidationFailureMessagesArray=[[self parent]allValidationFailureMessages];
      _tmpAllValidationFailureMessagesArray=allValidationFailureMessagesArray;
    };

  return _tmpAllValidationFailureMessagesArray;
};

@end

