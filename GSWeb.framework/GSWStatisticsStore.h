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
  int _componentActionTransactionsCount;
  int _sessionsCount;
  int _lastStatsSessionsCount;
  int _maxActiveSessionsCount;
  NSDate* _maxActiveSessionsDate;
  float _averageRequestsPerSession;
  double _averageSessionLife;
  NSArray* _lastSessionStatistics;
  double _movingAverageSessionLife;
  float _movingAverageRequestsPerSession;
  int _movingAverageSessionsCount;
  NSDate* _startDate;
  NSDate* _lastStatsDate;
  double _lastWillHandleRequestTimeInterval;
  double _lastDidHandleRequestTimeInterval;
  double _totalIdleTimeInterval;
  double _totalTransactionTimeInterval;
  double _totalDATransactionTimeInterval;
  double _totalCATransactionTimeInterval;
  double _movingIdleTimeInterval;
  double _movingTransactionTimeInterval;
  int _movingAverageTransactionsCount;
  NSDictionary* _initializationMemory;
  NSMutableDictionary* _pagesStatistics;
  NSString* _currentPage;
  NSMutableDictionary* _pathsStatistics;
  NSString* _logPath;
  double _logRotation;
  NSDate* _logCreationDate;
  NSString* _password;
  NSMutableDictionary* _directActionStatistics;
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
@end

@interface GSWStatisticsStore (GSWStatisticsStoreA)
-(void)_purgePathsStatistics;
-(void)_updatePathsStatisticsWithPaths:(id)paths;
-(void)_updatePagesStatisticsForPage:(id)page
                        timeInterval:(NSTimeInterval)timeInterval;
-(void)_updateDAStatisticsForActionNamed:(id)name
                            timeInterval:(NSTimeInterval)timeInterval;
-(void)_sessionTerminating:(id)session;
-(void)_applicationCreatedSession:(GSWSession*)session;
-(void)_applicationDidHandleComponentActionRequest;
-(void)_applicationDidHandleDirectActionRequestWithActionNamed:(id)name;
-(double)_applicationDidHandleRequest;
-(void)_applicationWillHandleDirectActionRequest;
-(void)_applicationWillHandleComponentActionRequest;
-(void)_applicationWillHandleRequest;
@end

@interface GSWStatisticsStore (GSWStatisticsStoreB)
-(NSString*)descriptionForResponse:(GSWResponse*)aResponse
                         inContext:(GSWContext*)aContext;
-(void)recordStatisticsForResponse:(GSWResponse*)aResponse
                         inContext:(GSWContext*)aContext;

@end

@interface GSWStatisticsStore (GSWStatisticsStoreC)
-(void)logString:(id)string;
-(double)logFileRotationFrequencyInDays;
-(NSString*)logFile;
-(void)			setLogFile:(NSString*)logFile
   rotationFrequencyInDays:(double)rotationFrequency;
-(id)formatDescription:(id)description
           forResponse:(GSWResponse*)aResponse
             inContext:(GSWContext*)aContext;
@end

@interface GSWStatisticsStore (GSWStatisticsStoreD)
-(NSString*)_password;
-(NSDictionary*)_pathsStatistics;
-(NSDictionary*)_pagesStatistics;
-(id)_lastSessionStatistics;
-(NSDictionary*)_memoryUsage;
-(id)_averageSessionMemory;
-(double)_movingAverageSessionLife;
-(double)_averageSessionLife;
-(float)_movingAverageRequestsPerSession;
-(float)_averageRequestsPerSession;
-(NSDate*)_maxActiveSessionsDate;
-(int)_maxActiveSessionsCount;
-(int)_sessionsCount;
-(double)_movingAverageTransactionTime;
-(double)_movingAverageIdleTime;
-(double)_averageCATransactionTime;
-(double)_averageDATransactionTime;
-(double)_averageTransactionTime;
-(double)_averageIdleTime;
-(int)_directActionTransactionsCount;
-(int)_componentActionTransactionsCount;
-(int)_transactionsCount;
 
@end

@interface GSWStatisticsStore (GSWStatisticsStoreE)
-(BOOL)validateLogin:(id)login
          forSession:(id)session;
-(void)setPassword:(NSString*)password;

@end

@interface GSWStatisticsStore (GSWStatisticsStoreF)
-(BOOL)validateLogin:(id)login;
@end

@interface GSWStatisticsStore (GSWStatisticsStoreG)
-(void)_validateAPI;

@end

@interface GSWStatisticsStore (GSWStatisticsStoreH)
+(id)timeIntervalDescription:(double)timeInterval;
@end
#endif //_GSWStatisticsStore_h__
