/** GSWStatsPage.m - <title>GSWeb: Class GSWStatsPage</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Apr 1999
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWExtWOCompatibility.h"
#include "GSWStatsPage.h"

//===================================================================================
@implementation GSWStatsPage
-(id)submit
{
  GSWStatisticsStore* statisticsStore = [[self application] statisticsStore];
  if (statisticsStore)
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
/*
 NSLog(@"detailsDict");
NSLog([_detailsDict description]);
NSLog(@"pagesDict");
NSLog([_pagesDict description]);
NSLog(@"directActionsDict");
NSLog([_directActionsDict description]);
NSLog(@"sessionMemoryDict");
NSLog([_sessionMemoryDict description]);

NSLog(@"transactions");
NSLog(_transactions);
NSLog(@"statsDict");
NSLog(_statsDict);
NSLog(@"memoryDict");
NSLog(_memoryDict);
NSLog(@"sessionStats");
NSLog(_sessionStats);
NSLog(@"sessionsDict");
NSLog(_sessionsDict);
*/
}

-(id)instance
{
  id instance=nil;
  NSArray* commandLineArguments = [[NSProcessInfo processInfo] arguments];
  NSUInteger i=0;
  i = [commandLineArguments indexOfObject:@"-n"];
  if (i!=NSNotFound && ([commandLineArguments count] > i + 1))
	instance=[commandLineArguments objectAtIndex:i+1];
  return instance;
};

-(NSNumber*)_maxServedForDictionary:(NSDictionary*)aDictionary
{
  int maxServedCount = 0;
  int tmpCount=0;
  NSDictionary* page = nil;
  NSEnumerator* anEnum = [aDictionary objectEnumerator];
  while ((page = [anEnum nextObject]))
    {
      tmpCount = [[page objectForKey:@"Served"] intValue];
      maxServedCount = max(maxServedCount,tmpCount);
    };
  return [NSNumber numberWithInt:maxServedCount];
};

-(id)_initIvars
{
  _statsDict = [[self application] statistics];
  _pagesDict = [_statsDict objectForKey:@"Pages"];
  _directActionsDict = [_statsDict objectForKey:@"DirectActions"];
  _detailsDict = [_statsDict objectForKey:@"Details"];
  _transactions = [_statsDict objectForKey:@"Transactions"];
  _memoryDict = [_statsDict objectForKey:@"Memory"];
  _sessionsDict = [[[NSMutableDictionary alloc] initWithDictionary:
                                                  [_statsDict objectForKey:@"Sessions"]]
				   autorelease];
  _sessionMemoryDict = [_sessionsDict objectForKey:@"Avg. Memory Per Session"];
  [_sessionsDict removeObjectForKey:@"Avg. Memory Per Session"];
  
  _sessionStats = [_sessionsDict objectForKey:@"Last Session's Statistics"];
  [_sessionsDict removeObjectForKey:@"Last Session's Statistics"];
  
  _maxSessionsDate = [_sessionsDict objectForKey:@"Peak Active Sessions Date"];
  [_sessionsDict removeObjectForKey:@"Peak Active Sessions Date"];
  
  _maxPageCount = 0;
  _maxActionCount = 0;
  
  _maxPageCount = [self _maxServedForDictionary:_pagesDict];
  _maxActionCount = [self _maxServedForDictionary:_directActionsDict];
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
  int detailPercent=0;
  id aTransactionsCount = [_transactions objectForKey:@"Transactions"];
  int aDetailCount = [[self detailCount] intValue];
  if (aTransactionsCount > 0)
	  detailPercent=(aDetailCount / [aTransactionsCount intValue]) * 100;
  return [NSNumber numberWithInt:detailPercent];
};

-(id)runningTime
{
  NSTimeInterval aRunningTime = (-1.0 * [[_statsDict objectForKey:@"StartedAt"] timeIntervalSinceNow]);
  NSString* aRunningTimeString = [GSWStatisticsStore timeIntervalDescription:aRunningTime];
  return aRunningTimeString;
}

-(id)detailCount
{
  return [_detailsDict objectForKey:_tmpKey];
}


@end
