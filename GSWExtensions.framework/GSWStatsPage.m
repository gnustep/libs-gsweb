/* GSWStatsPage.m - GSWeb: Class GSWStatsPage
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
#include "GSWStatsPage.h"

//===================================================================================
@implementation GSWStatsPage
-(id)submit
{
  GSWStatisticsStore* _statisticsStore = [[self application] statisticsStore];
  if (_statisticsStore)
	{
        //[_statisticsStore validateLogin:password];
		[[self session] _allowToViewStatistics];
    };
  return self;
};

-(id)host
{
  return [[NSHost currentHost] name];
}

- (void) awake
{
/*
  NSString* tmpKey;
  NSString* tmpItem;

  NSDictionary* detailsDict;
  NSDictionary* pagesDict;
  NSDictionary* directActionsDict;
  NSDictionary* sessionMemoryDict;
  NSDictionary* transactions;
  NSDictionary* statsDict;
  NSDictionary* memoryDict;
  NSArray* sessionStats;
  NSMutableDictionary* sessionsDict;
  NSNumber* maxPageCount;
  NSNumber* maxActionCount;
  NSDate* maxSessionsDate;
  NSString* userName;
  NSString* password;

*/
NSLog(@"detailsDict");
NSLog([detailsDict description]);
NSLog(@"pagesDict");
NSLog([pagesDict description]);
NSLog(@"directActionsDict");
NSLog([directActionsDict description]);
NSLog(@"sessionMemoryDict");
NSLog([sessionMemoryDict description]);

NSLog(@"transactions");
/*NSLog(transactions);
NSLog(@"statsDict");
NSLog(statsDict);
NSLog(@"memoryDict");
NSLog(memoryDict);
NSLog(@"sessionStats");
NSLog(sessionStats);
NSLog(@"sessionsDict");
NSLog(sessionsDict);
*/
}

-(id)instance
{
  id _instance=nil;
  NSArray* _commandLineArguments = [[NSProcessInfo processInfo] arguments];
  unsigned int i=0;
  i = [_commandLineArguments indexOfObject:@"-n"];
  if (i!=NSNotFound && ([_commandLineArguments count] > i + 1))
	_instance=[_commandLineArguments objectAtIndex:i+1];
  return _instance;
};

-(NSNumber*)_maxServedForDictionary:(NSDictionary*)aDictionary
{
  int _maxServedCount = 0;
  int _tmpCount=0;
  NSDictionary* _page = nil;
  NSEnumerator* _enum = [aDictionary objectEnumerator];
  while ((_page = [_enum nextObject]))
	{
	  _tmpCount = [[_page objectForKey:@"Served"] intValue];
	  _maxServedCount = max(_maxServedCount,_tmpCount);
    };
  return [NSNumber numberWithInt:_maxServedCount];
};

-(id)_initIvars
{
  id currentCount=nil;
  statsDict = [[self application] statistics];
  pagesDict = [statsDict objectForKey:@"Pages"];
  directActionsDict = [statsDict objectForKey:@"DirectActions"];
  detailsDict = [statsDict objectForKey:@"Details"];
  transactions = [statsDict objectForKey:@"Transactions"];
  memoryDict = [statsDict objectForKey:@"Memory"];
  sessionsDict = [[[NSMutableDictionary alloc] initWithDictionary:
												 [statsDict objectForKey:@"Sessions"]]
				   autorelease];
  sessionMemoryDict = [sessionsDict objectForKey:@"Avg. Memory Per Session"];
  [sessionsDict removeObjectForKey:@"Avg. Memory Per Session"];
  
  sessionStats = [sessionsDict objectForKey:@"Last Session's Statistics"];
  [sessionsDict removeObjectForKey:@"Last Session's Statistics"];
  
  maxSessionsDate = [sessionsDict objectForKey:@"Peak Active Sessions Date"];
  [sessionsDict removeObjectForKey:@"Peak Active Sessions Date"];
  
  maxPageCount = 0;
  maxActionCount = 0;
  
  maxPageCount = [self _maxServedForDictionary:pagesDict];
  maxActionCount = [self _maxServedForDictionary:directActionsDict];
  return nil; //??? //TODO
};

-(void)appendToResponse:(GSWResponse*)aResponse
			  inContext:(GSWContext*)aContext
{
  // ** This should probably be somewhere else.
  [self _initIvars];
  [super appendToResponse:aResponse
		 inContext:aContext];
};


-(void)setDetailPercent:(NSNumber*)aValue
{
}

-(NSNumber*)detailPercent
{
  int _detailPercent=0;
  id aTransactionsCount = [transactions objectForKey:@"Transactions"];
  int aDetailCount = [[self detailCount] intValue];
  if (aTransactionsCount > 0)
	  _detailPercent=(aDetailCount / [aTransactionsCount intValue]) * 100;
  return [NSNumber numberWithInt:_detailPercent];
};

-(id)runningTime
{
  NSTimeInterval aRunningTime = (-1.0 * [[statsDict objectForKey:@"StartedAt"] timeIntervalSinceNow]);
  NSString* aRunningTimeString = [GSWStatisticsStore timeIntervalDescription:aRunningTime];
  return aRunningTimeString;
}

-(id)detailCount
{
  return [detailsDict objectForKey:tmpKey];
}


@end
