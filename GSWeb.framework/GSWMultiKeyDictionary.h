/** GSWMultiKeyDictionary.h - <title>GSWeb: Class GSWMultiKeyDictionary</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
  
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

// $Id$

#ifndef _GSWMultiKeyDictionary_h__
	#define _GSWMultiKeyDictionary_h__


//==============================================================================
@interface GSWMultiKeyDictionary : NSObject
{
  void* _mapBase;
};

+(id)dictionary;
-(id)initWithCapacity:(unsigned int)capacity;

-(void)removeAllObjects;
-(void)setObject:(id)object
         forKeys:(id)keys,...;
-(id)objectForKeys:(id)keys,...;
-(void)removeObjectForKeys:(id)keys,...;

-(void)setObject:(id)object
          forKey:(id)key
         andKeys:(va_list)nextKeys;
-(id)objectForKey:(id)key
          andKeys:(va_list)nextKeys;
-(void)removeObjectForKey:(id)key
                  andKeys:(va_list)nextKeys;

-(void)setObject:(id)object
    forKeysArray:(NSArray*)keys;
-(id)objectForKeysArray:(NSArray*)keys;
-(void)removeObjectForKeysArray:(NSArray*)keys;

-(void)makeObjectsPerformSelector:(SEL)selector;
-(void)makeObjectsPerformSelector:(SEL)selector
                       withObject:(id)object;
-(void)makeObjectsPerformSelector:(SEL)selector
                       withObject:(id)object1
                       withObject:(id)object2;
-(NSEnumerator*)objectEnumerator;
-(NSArray*)allValues;
@end

#endif // _GSWMultiKeyDictionary_h__
