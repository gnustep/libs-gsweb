/** GSWStatisticsStore.h - <title>GSWeb: Class GSWStatisticsStore</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

#ifndef _GSWStatisticsStore_h__
	#define _GSWStatisticsStore_h__


@interface GSWStatisticsStore : NSObject <NSLocking>
{
  NSRecursiveLock* _selfLock;
#ifndef NDEBUG
  int _selfLockn;
#endif
  int _transactionMovingAverageSampleCount;
  int _sessionMovingAverageSampleCount;
  int _transactionsCount;
  int _lastStatsTransactionsCount;
  int _directActionTransactionsCount;
  int _webServiceTransactionsCount;
  int _componentActionTransactionsCount;
  int _sessionsCount;
  int _lastStatsSessionsCount;
  int _maxActiveSessionsCount;
  NSDate* _maxActiveSessionsDate;
  float _averageRequestsPerSession;
  NSTimeInterval _averageSessionLife;
  NSArray* _lastSessionStatistics;
  NSTimeInterval _movingAverageSessionLife;
  float _movingAverageRequestsPerSession;
  int _movingAverageSessionsCount;
  NSDate* _startDate;
  NSDate* _lastStatsDate;
  NSTimeInterval _lastWillHandleRequestTimeInterval;
  NSTimeInterval _lastDidHandleRequestTimeInterval;
  NSTimeInterval _totalIdleTimeInterval;
  NSTimeInterval _totalTransactionTimeInterval;
  NSTimeInterval _totalDATransactionTimeInterval;
  NSTimeInterval _totalWSTransactionTimeInterval;
  NSTimeInterval _totalCATransactionTimeInterval;
  NSTimeInterval _movingIdleTimeInterval;
  NSTimeInterval _movingTransactionTimeInterval;
  int _movingAverageTransactionsCount;
  NSDictionary* _initializationMemory;
  NSMutableDictionary* _pagesStatistics;
  NSString* _currentPage;
  NSMutableDictionary* _pathsStatistics;
  NSString* _logPath;
  NSTimeInterval _logRotation;
  NSDate* _logCreationDate;
  NSString* _password;
  NSMutableDictionary* _directActionStatistics;
  NSMutableDictionary* _webServiceStatistics;
};

-(id)init;
-(void)dealloc;

-(void)unlock;
-(void)lock;
-(id)statistics;
-(int)sessionMovingAverageSampleSize;
-(void)setSessionMovingAverageSampleSize:(int)aSize;
-(int)transactionMovingAverageSampleSize;
-(void)setTransactionMovingAverageSampleSize:(int)aSize;

-(void)_purgePathsStatistics;
-(void)_updatePathsStatisticsWithPaths:(id)paths;
-(void)sessionTerminating:(GSWSession*)session;
-(void)_sessionTerminating:(GSWSession*)session;
-(void)_applicationCreatedSession:(GSWSession*)session;

-(void)applicationWillHandleDirectActionRequest;
-(void)applicationWillHandleWebServiceRequest;
-(void)applicationWillHandleComponentActionRequest;

-(void)applicationDidHandleComponentActionRequestWithPageNamed:(NSString*)pageName;
-(void)applicationDidHandleDirectActionRequestWithActionNamed:(NSString*)actionName;
-(void)applicationDidHandleWebServiceRequestWithActionNamed:(NSString*)actionName;

-(NSString*)descriptionForResponse:(GSWResponse*)aResponse
                         inContext:(GSWContext*)aContext;
-(void)recordStatisticsForResponse:(GSWResponse*)aResponse
                         inContext:(GSWContext*)aContext;


-(void)logString:(id)string;
-(NSTimeInterval)logFileRotationFrequencyInDays;
-(NSString*)logFile;
-(void)			setLogFile:(NSString*)logFile
   rotationFrequencyInDays:(NSTimeInterval)rotationFrequency;
+(NSString*)formatDescription:(NSString*)description
                  forResponse:(GSWResponse*)aResponse
                    inContext:(GSWContext*)aContext;

-(NSString*)_password;
-(NSDictionary*)_pathsStatistics;
-(NSDictionary*)_pagesStatistics;
-(id)_lastSessionStatistics;
-(NSDictionary*)_memoryUsage;
-(id)_averageSessionMemory;
-(NSTimeInterval)_movingAverageSessionLife;
-(NSTimeInterval)_averageSessionLife;
-(float)_movingAverageRequestsPerSession;
-(float)_averageRequestsPerSession;
-(NSDate*)_maxActiveSessionsDate;
-(int)_maxActiveSessionsCount;
-(int)_sessionsCount;
-(NSTimeInterval)_movingAverageTransactionTime;
-(NSTimeInterval)_movingAverageIdleTime;
-(NSTimeInterval)_averageCATransactionTime;
-(NSTimeInterval)_averageDATransactionTime;
-(NSTimeInterval)_averageTransactionTime;
-(NSTimeInterval)_averageIdleTime;
-(int)_directActionTransactionsCount;
-(int)_componentActionTransactionsCount;
-(int)_transactionsCount;
 
-(BOOL)validateLogin:(id)login
          forSession:(id)session;
-(void)setPassword:(NSString*)password;

-(BOOL)validateLogin:(id)login;

+(id)timeIntervalDescription:(NSTimeInterval)timeInterval;
@end
#endif //_GSWStatisticsStore_h__
