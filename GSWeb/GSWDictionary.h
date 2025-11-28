/** GSWDictionary.h
 
 Copyright (C) 2007 Free Software Foundation, Inc.
 
 Written by:    David Wetzel <dave@turbocat.de>
 Date:     20-Dec-2017
 
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
 **/

#ifndef _GSWebDICTIONARY_h__
#define _GSWebDICTIONARY_h__
@class	NSMutableDictionary;

@interface GSWDictionary : NSObject
{
  NSMutableDictionary	*_storageDict;
}

+ (instancetype)dictionary;

- (NSUInteger) count;

-(id)objectForKeys:(NSString*)keys,...;

-(id)objectForKeyArray:(NSArray *)keys;

-(void)setObject:(id)object
         forKeys:(id)keys,...;


-(void)setObject:(id)object
     forKeyArray:(NSArray *)keys;

- (void)removeObjectForKeyArray:(NSArray *)keys;

- (void)removeObjectForKeys:(NSString*)keys,...;

@end
#endif // _GSWebDICTIONARY_h__
