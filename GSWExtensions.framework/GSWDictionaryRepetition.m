/** GSWDictionaryRepetition.m - <title>GSWeb: Class GSWDictionaryRepetition</title>
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Apr 1999
   
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

#include "GSWExtWOCompatibility.h"
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
  DESTROY(_keyList);
  DESTROY(_dictionary);
  [super dealloc];
};

-(BOOL)synchronizesVariablesWithBindings
{
  return NO;
};

-(NSDictionary*)dictionary
{
  if (!_dictionary)
	{
	  ASSIGN(_dictionary,[self valueForBinding:@"dictionary"]);
	};
  return _dictionary;
};

-(NSArray*)keyList
{
  if (!_keyList)
	{
	  ASSIGN(_keyList,[[self dictionary] allKeys]);
	};
  return _keyList;
};

-(id)currentKey
{
  return nil;
};

-(void)setCurrentKey:(id)key
{
  id value = nil;
  NSDebugMLLog(@"gswdync",@"key=%@",key);
  value=[[self dictionary] objectForKey:key];
  NSDebugMLLog(@"gswdync",@"value=%@",value);
  [self setValue:key
		forBinding:@"key"];
  [self setValue:value
		forBinding:@"item"];
};

@end

