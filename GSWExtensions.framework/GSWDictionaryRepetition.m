/* GSWDictionaryRepetition.m - GSWeb: Class GSWDictionaryRepetition
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
#include "GSWDictionaryRepetition.h"

//====================================================================
@implementation GSWDictionaryRepetition

-(void)awake
{
  [super awake];
};

-(void)sleep
{
  [super sleep];
};

-(id)init
{
  return [super init];
};

-(void)dealloc
{
  DESTROY(keyList);
  DESTROY(dictionary);
  [super dealloc];
};

-(BOOL)synchronizesVariablesWithBindings
{
  return NO;
};

-(NSDictionary*)dictionary
{
  if (!dictionary)
	{
	  ASSIGN(dictionary,[self valueForBinding:@"dictionary"]);
	};
  return dictionary;
};

-(NSArray*)keyList
{
  if (!keyList)
	{
	  ASSIGN(keyList,[[self dictionary] allKeys]);
	};
  return keyList;
};

-(id)currentKey
{
  return nil;
};

-(void)setCurrentKey:(id)key_
{
  id _value = [[self dictionary] objectForKey:key_];
  [self setValue:key_
		forBinding:@"key"];
  [self setValue:_value
		forBinding:@"item"];
};

@end

