/** GSWMultiKeyDictionary.m - <title>GSWeb: Class GSWMultiKeyDictionary</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 1999
   
   $Revision$
   $Date$

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

#define DEFAULT_DICTIONARY_CAPACITY 32

//==============================================================================
@implementation GSWMultiKeyDictionary : NSObject

//------------------------------------------------------------------------------
+(id)dictionary
{
  return [[self alloc]init];
};

//------------------------------------------------------------------------------
-(id)init
{
  LOGObjectFnStart();
  self=[self initWithCapacity:DEFAULT_DICTIONARY_CAPACITY];
  LOGObjectFnStop();
  return self;
};

//------------------------------------------------------------------------------
-(id)initWithCapacity:(unsigned int)capacity
{
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      _dict=[[NSMutableDictionary dictionaryWithCapacity:capacity] retain];
    };
  LOGObjectFnStop();
  return self;
};

//------------------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_dict);
  [super dealloc];
};

//------------------------------------------------------------------------------
-(NSString*)description
{
  NSString* descr=nil;
//  GSWLogC("GSWMultiKeyDictionary description A");
  descr=[NSString stringWithFormat:@"<%s %p - ",
				  object_get_class_name(self),
				  (void*)self];
//  GSWLogC("GSWMultiKeyDictionary description B");
  descr=[descr stringByAppendingFormat:@"dict=%@>",
               _dict];
//  GSWLogC("GSWMultiKeyDictionary description C");
  return descr;
};

//------------------------------------------------------------------------------
-(NSEnumerator*)objectEnumerator
{
  return [_dict objectEnumerator];
};

//------------------------------------------------------------------------------
-(void)removeAllObjects
{
  [_dict removeAllObjects];
};

//------------------------------------------------------------------------------
-(void)setObject:(id)object
         forKeys:(id)keys,...
{
  NSMutableArray* array=nil;
  va_list ap;
  id tmpId;

  array = [NSMutableArray array];

  va_start(ap, keys);

  tmpId = keys;
  do 
    {
      [array addObject:tmpId];
      tmpId = va_arg(ap,id);
    }
  while(tmpId);

  va_end(ap);

  [self setObject:object
	forKeysArray:array];
};

//------------------------------------------------------------------------------
-(id)objectForKeys:(id)keys,...
{
  NSMutableArray* array=nil;
  va_list ap;
  id tmpId;

  array = [NSMutableArray array];
  va_start(ap, keys);

  tmpId = keys;
  do 
    {
      [array addObject:tmpId];
      tmpId = va_arg(ap,id);
    }
  while(tmpId);

  va_end(ap);

  return [self objectForKeysArray:array];
};

//------------------------------------------------------------------------------
-(void)setObject:(id)object
    forKeysArray:(NSArray*)keys
{
  [_dict setObject:object
        forKey:keys];
};

//------------------------------------------------------------------------------
-(id)objectForKeysArray:(NSArray*)keys
{
  return [_dict objectForKey:keys];
};

//------------------------------------------------------------------------------
-(NSArray*)objectsForKeysArrays:(NSArray*)keys
                 notFoundMarker:(id)notFoundMarker
{
  return [_dict objectsForKeys:keys
                notFoundMarker:notFoundMarker];
};

//------------------------------------------------------------------------------
-(NSArray*)allValues
{
  return [_dict allValues];
};

//------------------------------------------------------------------------------
-(NSArray*)allKeys
{
  return [_dict allKeys];
};

//------------------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector
{
  [_dict makeObjectsPerformSelector:selector];
};

//------------------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector
                       withObject:(id)object
{
  [_dict makeObjectsPerformSelector:selector
         withObject:object];
};

//------------------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector
                       withObject:(id)object1
                       withObject:(id)object2
{
  [_dict makeObjectsPerformSelector:selector
		withObject:object1
		withObject:object2];
};

@end

