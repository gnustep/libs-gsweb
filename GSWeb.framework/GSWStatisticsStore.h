/* GSWStatisticsStore.h - GSWeb: Class GSWStatisticsStore
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

#ifndef _GSWStatisticsStore_h__
	#define _GSWStatisticsStore_h__


@interface GSWStatisticsStore : NSObject <NSLocking>
{
  NSRecursiveLock* selfLock;
#ifndef NDEBUG
  int selfLockn;
#endif
  int transactionMovingAverageSampleCount;
  int sessionMovingAverageSampleCount;
  int transactionsCount;
  int lastStatsTransactionsCount;
  int directActionTransactionsCount;
  int componentActionTransactionsCount;
  int sessionsCount;
  int lastStatsSessionsCount;
  int maxActiveSessionsCount;
  NSDate* maxActiveSessionsDate;
  float averageRequestsPerSession;
  double averageSessionLife;
  NSArray* lastSessionStatistics;
  double movingAverageSessionLife;
  float movingAverageRequestsPerSession;
  int movingAverageSessionsCount;
  NSDate* startDate;
  NSDate* lastStatsDate;
  double lastWillHandleRequestTimeInterval;
  double lastDidHandleRequestTimeInterval;
  double totalIdleTimeInterval;
  double totalTransactionTimeInterval;
  double totalDATransactionTimeInterval;
  double totalCATransactionTimeInterval;
  double movingIdleTimeInterval;
  double movingTransactionTimeInterval;
  int movingAverageTransactionsCount;
  NSDictionary* initializationMemory;
  NSMutableDictionary* pagesStatistics;
  NSString* currentPage;
  NSMutableDictionary* pathsStatistics;
  NSString* logPath;
  double logRotation;
  NSDate* logCreationDate;
  NSString* password;
  NSMutableDictionary* directActionStatistics;
};

-(id)init;
-(void)dealloc;

-(void)unlock;
-(void)lock;
-(id)statistics;
-(int)sessionMovingAverageSampleSize;
-(void)setSessionMovingAverageSampleSize:(int)size_;
-(int)transactionMovingAverageSampleSize;
-(void)setTransactionMovingAverageSampleSize:(int)size_;
@end

@interface GSWStatisticsStore (GSWStatisticsStoreA)
-(void)_purgePathsStatistics;
-(void)_updatePathsStatisticsWithPaths:(id)paths_;
-(void)_updatePagesStatisticsForPage:(id)page_
						timeInterval:(NSTimeInterval)timeInterval_;
-(void)_updateDAStatisticsForActionNamed:(id)name_
							timeInterval:(NSTimeInterval)timeInterval_;
-(void)_sessionTerminating:(id)session_;
-(void)_applicationCreatedSession:(GSWSession*)session_;
-(void)_applicationDidHandleComponentActionRequest;
-(void)_applicationDidHandleDirectActionRequestWithActionNamed:(id)name_;
-(double)_applicationDidHandleRequest;
-(void)_applicationWillHandleDirectActionRequest;
-(void)_applicationWillHandleComponentActionRequest;
-(void)_applicationWillHandleRequest;
@end

@interface GSWStatisticsStore (GSWStatisticsStoreB)
-(NSString*)descriptionForResponse:(GSWResponse*)response_
						 inContext:(GSWContext*)context_;
-(void)recordStatisticsForResponse:(GSWResponse*)response_
				  inContext:(GSWContext*)context_;

@end

@interface GSWStatisticsStore (GSWStatisticsStoreC)
-(void)logString:(id)string_;
-(double)logFileRotationFrequencyInDays;
-(NSString*)logFile;
-(void)			setLogFile:(NSString*)logFile_
   rotationFrequencyInDays:(double)rotationFrequency;
-(id)formatDescription:(id)description_
		   forResponse:(GSWResponse*)response_
			 inContext:(GSWContext*)context_;
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
-(BOOL)validateLogin:(id)login_
		  forSession:(id)session_;
-(void)setPassword:(NSString*)password_;

@end

@interface GSWStatisticsStore (GSWStatisticsStoreF)
-(BOOL)validateLogin:(id)login_;
@end

@interface GSWStatisticsStore (GSWStatisticsStoreG)
-(void)_validateAPI;

@end

@interface GSWStatisticsStore (GSWStatisticsStoreH)
+(id)timeIntervalDescription:(double)timeInterval_;
@end
#endif //_GSWStatisticsStore_h__
