/* GSCache.m - Class GSCache
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
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

#ifndef _GSCache_h__
	#define _GSCache_h__

@interface GSCacheEntry : NSObject
{
  NSDate*			firstAccess;
  NSDate*			lastAccess;
  NSTimeInterval	duration;
  id				obj;
}

+(GSCacheEntry*)newEntryWithObject:(id)_obj
					  withDuration:(NSTimeInterval)_duration;

-(id)init;
-(id)	initWithObject:(id)_obj
		  withDuration:(NSTimeInterval)_duration;
-(void)dealloc;
-(NSString*)description;
-(BOOL) isExpired;
-(void) setObj:(id)_obj;
-(void) setDuration:(NSTimeInterval)_duration;
-(void) setFirstAccess:(NSDate*)_date;
-(void) setLastAccess:(NSDate*)_date;
-(id) getObj;

@end

@interface GSCache : NSObject
{
  NSMutableDictionary*		entries;
}
+(id)cache;
+(GSCache*)newWithObject:(id)_obj
				  forKey:(id)_key
			withDuration:(NSTimeInterval)_duration;


-(id)init;
-(id)	initWithObject:(id)_obj
				forKey:(id)_key
		  withDuration:(NSTimeInterval)_duration;
-(void)dealloc;
-(NSString*)description;
-(BOOL) isExpired;
-(void)deleteExpiredEntries;

-(void)setObject:(id)_obj
		  forKey:(id)_key
	withDuration:(NSTimeInterval)_duration;
-(id)objectForKey:(id)_key;

@end

#endif // _GSCache_h__

