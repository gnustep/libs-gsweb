/* GSWMultiKeyDictionary.h - GSWeb: Class GSWMultiKeyDictionary
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

// $Id$

#ifndef _GSWMultiKeyDictionary_h__
	#define _GSWMultiKeyDictionary_h__


//==============================================================================
@interface GSWMultiKeyDictionary : NSObject
{
  NSMutableDictionary* dict;
};

+(id)dictionary;
-(id)init;
-(id)initWithCapacity:(unsigned int)capacity_;
-(void)dealloc;
-(NSString*)description;


-(NSEnumerator*)objectEnumerator;
-(void)removeAllObjects;
-(void)setObject:(id)object_
		 forKeys:(id)keys_,...;
-(id)objectForKeys:(id)keys_,...;

-(void)setObject:(id)object_
	forKeysArray:(NSArray*)keys_;
-(id)objectForKeysArray:(NSArray*)keys_;
-(NSArray*)allValues;
-(NSArray*)allKeys;
-(NSArray*)objectsForKeysArrays:(NSArray*)keys_
				 notFoundMarker:(id)notFoundMarker_;
-(void)makeObjectsPerformSelector:(SEL)selector_;
-(void)makeObjectsPerformSelector:(SEL)selector_
					   withObject:(id)object_;
-(void)makeObjectsPerformSelector:(SEL)selector_
					   withObject:(id)object1_
					   withObject:(id)object2_;
@end

#endif // _GSWMultiKeyDictionary_h__
