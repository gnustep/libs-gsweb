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

static char rcsId[] = "$Id$";

#include "GSWeb.h"
#include "GSCache.h"

//========================================================================================
@implementation GSCacheEntry

//----------------------------------------------------------------------------------------
-(id)init
{
  self = [super init];
  firstAccess=	nil;
  lastAccess=	nil;
  duration	=	86400;//1 Jour
  obj		=	nil;
  return self;
};

//----------------------------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(firstAccess);
  DESTROY(lastAccess);
  DESTROY(obj);
};

//----------------------------------------------------------------------------------------
+(GSCacheEntry*)newEntryWithObject:(id)_obj
					  withDuration:(NSTimeInterval)_duration
{
  return [[[GSCacheEntry alloc] initWithObject:_obj
								withDuration:_duration] autorelease];
};

//----------------------------------------------------------------------------------------
-(id)	initWithObject:(id)_obj
	   withDuration:(NSTimeInterval)_duration
{
  self = [self init];
  [self setObj:_obj];
  [self setDuration:_duration];
  [self setFirstAccess:[NSDate date]];
  [self setLastAccess:[NSDate date]];
  return self;
};

//----------------------------------------------------------------------------------------
-(NSString*)description
{
  return @"";
};

//----------------------------------------------------------------------------------------
-(BOOL) isExpired
{
  return ([[NSDate date] timeIntervalSinceDate:lastAccess]>duration);
};

-(void) setObj:(id)_obj { ASSIGN(obj,_obj); };
-(void) setDuration:(NSTimeInterval)_duration { duration=_duration; };
-(void) setFirstAccess:(NSDate*)_date { ASSIGN(firstAccess,_date); };
-(void) setLastAccess:(NSDate*)_date { ASSIGN(lastAccess,_date); };

-(id) getObj { return obj; };

@end
//========================================================================================

@implementation GSCache

//----------------------------------------------------------------------------------------
- (id) init
{
  self = [super init];
  entries		=	nil;
  return self;
}

//----------------------------------------------------------------------------------------
- (void) dealloc
{
  DESTROY(entries);
  [super dealloc];
}

//----------------------------------------------------------------------------------------
-(NSString*)description
{
  return @"";
};

//----------------------------------------------------------------------------------------
+(id)cache
{
  return [[[GSCache alloc] init] autorelease];
};

//----------------------------------------------------------------------------------------
+(GSCache*)newWithObject:(id)_obj
			   forKey:(id)_key
		 withDuration:(NSTimeInterval)_duration
{
  return [[[GSCache alloc] initWithObject:_obj
						   forKey:_key
						   withDuration:_duration] autorelease];
};

//----------------------------------------------------------------------------------------
-(id)	initWithObject:(id)_obj
				forKey:(id)_key
		  withDuration:(NSTimeInterval)_duration

{
  self = [self init];
  if (!entries)
	entries=[NSMutableDictionary new];
  [entries setObject:[GSCacheEntry newEntryWithObject:_obj
								   withDuration:_duration]
		   forKey:_key];
  return self;
};

//----------------------------------------------------------------------------------------
-(BOOL) isExpired
{
  if (entries)
	{
	  NSEnumerator* enumerator=[entries keyEnumerator];
	  id key;
	  while ((key = [enumerator nextObject]))
		  if (![[entries objectForKey:key] isExpired])
			return NO;
	};
	return YES;
};

//----------------------------------------------------------------------------------------
-(void)deleteExpiredEntries
{
  if (entries)
	{
	  id entry=nil;
	  NSEnumerator* enumerator=[entries keyEnumerator];
	  id key;
	  while ((key = [enumerator nextObject]))
		{
		  entry=[entries objectForKey:key];
		  if (entry && [entry isKindOfClass:[GSCache class]])
			[entry deleteExpiredEntries];
		  else if ([entry isExpired])
			[entries removeObjectForKey:key];
		};
	};
};

//----------------------------------------------------------------------------------------
-(void)setObject:(id)_obj
		  forKey:(id)_key
	withDuration:(NSTimeInterval)_duration
{
  BOOL localEntry=YES;
  if (!entries)
	entries=[NSMutableDictionary new];
  if ([_key isKindOfClass:[NSString class]])
	{
	  NSArray* components=[_key componentsSeparatedByString:@"/"];
	  if ([components count]>1)
		{
		  id sub=nil;
		  NSRange range;
		  range.location = 1;
		  range.length = [components count];
		  localEntry=NO;
		  sub=[entries objectForKey:[components objectAtIndex:0]];
		  if (!sub)
			{
			  sub=[[GSCache new] autorelease];
			  [entries setObject:sub forKey:[components objectAtIndex:0]];
			};
		  [sub setObject:_obj
			   forKey:[[components subarrayWithRange:range]
						componentsJoinedByString:@"/"]
			   withDuration:_duration];
		};
	};
  if (localEntry)
	{
	  [entries setObject:[GSCacheEntry newEntryWithObject:_obj
									   withDuration:_duration]
			   forKey:_key];
	};
};

//----------------------------------------------------------------------------------------
-(id)objectForKey:(id)_key
{
  id obj=nil;
  if (entries)
	{	
	  BOOL localEntry=YES;
	  if ([_key isKindOfClass:[NSString class]])
		{
		  NSArray* components=[_key componentsSeparatedByString:@"/"];
		  if ([components count]>1)
			{
			  id sub=nil;
			  NSRange range;
			  range.location = 1;
			  range.length = [components count];
			  localEntry=NO;
			  sub=[entries objectForKey:[components objectAtIndex:0]];
			  if (sub)
				{
				  NSAssert([sub isKindOfClass:[GSCache class]],@"Sub Cache is an Entry !");
				  if ([sub isKindOfClass:[GSCache class]])
					  obj=[sub objectForKey:[[components subarrayWithRange:range]
											  componentsJoinedByString:@"/"]];
				};
			};
		};
	  if (localEntry)
		{
		  obj=[entries objectForKey:_key];
		  if (obj)
			{
			  if ([obj isKindOfClass:[GSCacheEntry class]])
				{
				  [obj setLastAccess:[NSDate date]];
				  obj=[obj getObj];
				}
			  else
				{
				  NSAssert1([obj isKindOfClass:[GSCache class]],@"Not a Cache or Entry ! it's a %@",[obj class]);
				};
			};
		};
	};
  return obj;
};

@end
