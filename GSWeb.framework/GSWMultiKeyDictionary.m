/* GSWMultiKeyDictionary.m - GSWeb: Class GSWMultiKeyDictionary
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Mar 1999
   
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

static char rcsId[] = "$Id$";

#include <gsweb/GSWeb.framework/GSWeb.h>

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
-(id)initWithCapacity:(unsigned int)capacity_
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  dict=[[NSMutableDictionary dictionaryWithCapacity:capacity_] retain];
	};
  LOGObjectFnStop();
  return self;
};

//------------------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(dict);
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
			   dict];
//  GSWLogC("GSWMultiKeyDictionary description C");
  return descr;
};

//------------------------------------------------------------------------------
-(NSEnumerator*)objectEnumerator
{
  return [dict objectEnumerator];
};

//------------------------------------------------------------------------------
-(void)removeAllObjects
{
  [dict removeAllObjects];
};

//------------------------------------------------------------------------------
-(void)setObject:(id)object_
		 forKeys:(id)keys_,...
{
  NSMutableArray* array=nil;
  va_list ap;
  va_start(ap, keys_);
  array=[[[NSMutableArray alloc]initWithObjects:keys_
							   rest:ap]
		  autorelease];
  va_end(ap);
  [self setObject:object_
		forKeysArray:array];
};

//------------------------------------------------------------------------------
-(id)objectForKeys:(id)keys_,...
{
  NSMutableArray* array=nil;
  va_list ap;
  va_start(ap, keys_);
  array=[[[NSMutableArray alloc]initWithObjects:keys_
							   rest:ap]
		  autorelease];
  va_end(ap);
  return [self objectForKeysArray:array];
};

//------------------------------------------------------------------------------
-(void)setObject:(id)object_
	forKeysArray:(NSArray*)keys_
{
  [dict setObject:object_
		forKey:keys_];
};

//------------------------------------------------------------------------------
-(id)objectForKeysArray:(NSArray*)keys_
{
  return [dict objectForKey:keys_];
};

//------------------------------------------------------------------------------
-(NSArray*)objectsForKeysArrays:(NSArray*)keys_
				 notFoundMarker:(id)notFoundMarker_
{
  return [dict objectsForKeys:keys_
			   notFoundMarker:notFoundMarker_];  
};

//------------------------------------------------------------------------------
-(NSArray*)allValues
{
  return [dict allValues];
};

//------------------------------------------------------------------------------
-(NSArray*)allKeys
{
  return [dict allKeys];
};

//------------------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector_
{
  [dict makeObjectsPerformSelector:selector_];
};

//------------------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector_
					   withObject:(id)object_
{
  [dict makeObjectsPerformSelector:selector_
		withObject:object_];
};

//------------------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector_
					   withObject:(id)object1_
					   withObject:(id)object2_
{
  [dict makeObjectsPerformSelector:selector_
		withObject:object1_
		withObject:object2_];
};

@end

