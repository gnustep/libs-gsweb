/* GSWStatisticsStore.m - GSWeb: Class GSWStatisticsStore
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

#include <gsweb/GSWeb.framework/GSWeb.h>
#include <sys/resource.h>


//====================================================================
@implementation GSWStatisticsStore

//--------------------------------------------------------------------
-(id)init
{
  //OK
  if ((self=[super init]))
	{
	  transactionMovingAverageSampleCount=100;
	  sessionMovingAverageSampleCount=10;
	  startDate=[NSDate date];
	  ASSIGN(initializationMemory,[self _memoryUsage]);
	  selfLock=[NSRecursiveLock new];
	};
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWStatisticsStore");
  GSWLogC("Dealloc GSWStatisticsStore: selfLock");
  DESTROY(selfLock);
  GSWLogC("Dealloc GSWStatisticsStore: maxActiveSessionsDate");
  DESTROY(maxActiveSessionsDate);
  DESTROY(lastSessionStatistics);
  DESTROY(startDate);
  DESTROY(lastStatsDate);
  DESTROY(initializationMemory);
  DESTROY(pagesStatistics);
  DESTROY(currentPage);
  DESTROY(pathsStatistics);
  DESTROY(logPath);
  DESTROY(logCreationDate);
  DESTROY(password);
  DESTROY(directActionStatistics);
  GSWLogC("Dealloc GSWStatisticsStore Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWStatisticsStore");
};

//--------------------------------------------------------------------
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLog(@"selfLockn=%d",selfLockn);
  TmpUnlock(selfLock);
#ifndef NDEBUG
	selfLockn--;
#endif
  NSDebugMLog(@"selfLockn=%d",selfLockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)lock
{
  LOGObjectFnStart();
  NSDebugMLog(@"selfLockn=%d",selfLockn);
  TmpLockBeforeDate(selfLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
  selfLockn++;
#endif
  NSDebugMLog(@"selfLockn=%d",selfLockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(id)statistics
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(int)sessionMovingAverageSampleSize
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return sessionMovingAverageSampleCount;
};

//--------------------------------------------------------------------
-(void)setSessionMovingAverageSampleSize:(int)size_
{
  LOGObjectFnStart();
  sessionMovingAverageSampleCount=size_;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(int)transactionMovingAverageSampleSize
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return transactionMovingAverageSampleCount;
};

//--------------------------------------------------------------------
-(void)setTransactionMovingAverageSampleSize:(int)size_
{
  LOGObjectFnStart();
  transactionMovingAverageSampleCount=size_;
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWStatisticsStore (GSWStatisticsStoreA)

//--------------------------------------------------------------------
-(void)_purgePathsStatistics
{
  //OK
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  LOGObjectFnNotImplemented();	//TODOFN
	}
  NS_HANDLER
	{
	  NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	}
  NS_ENDHANDLER;
  [self unlock];  
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_updatePathsStatisticsWithPaths:(id)paths_
{
  //OK
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  [self _purgePathsStatistics];
	  LOGObjectFnNotImplemented();	//TODOFN
	}
  NS_HANDLER
	{
	  NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	}
  NS_ENDHANDLER;
  [self unlock];  
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_updatePagesStatisticsForPage:(id)page_
						timeInterval:(NSTimeInterval)timeInterval_
{
  //OK
  NSMutableDictionary* _pageStats=nil;
  NSNumber* _AvgRespTime=nil;
  NSNumber* _MinRespTime=nil;
  NSNumber* _MaxRespTime=nil;
  NSNumber* _Served=nil;
  double _AvgRespTimeValue=0;
  double _MinRespTimeValue=0;
  double _MaxRespTimeValue=0;
  int _ServedValue=0;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  NSDebugMLog(@"page_=%@",page_);
	  if (!pagesStatistics)
		pagesStatistics=[NSMutableDictionary new];
	  else
		_pageStats=[pagesStatistics objectForKey:page_];
	  NSDebugMLog(@"pagesStatistics=%@",pagesStatistics);
	  NSDebugMLog(@"_pageStats=%@",_pageStats);
	  if (_pageStats)
		{
		  _AvgRespTime=[_pageStats objectForKey:@"Avg Resp. Time"];
		  _MinRespTime=[_pageStats objectForKey:@"Min Resp. Time"];
		  _MaxRespTime=[_pageStats objectForKey:@"Max Resp. Time"];
		  _Served=[_pageStats objectForKey:@"Served"];
		  
		  _ServedValue=[_Served intValue];
		  if (_MinRespTime)
			{
			  _MinRespTimeValue=[_MinRespTime doubleValue];
			  _MinRespTimeValue=min(_MinRespTimeValue,timeInterval_);
			}
		  else
			_MinRespTimeValue=timeInterval_;
		  if (_MaxRespTime)
			{
			  _MaxRespTimeValue=[_MaxRespTime doubleValue];
			  _MaxRespTimeValue=max(_MaxRespTimeValue,timeInterval_);
			}
		  else
			_MaxRespTimeValue=timeInterval_;
		  if (_AvgRespTime)
			{
			  _AvgRespTimeValue=[_AvgRespTime doubleValue];
			  _AvgRespTimeValue=((_AvgRespTimeValue*_ServedValue)+timeInterval_)/(_ServedValue+1);
			}
		  else
			_AvgRespTimeValue=timeInterval_;
		  _Served++;
		}
	  else
		{
		  _pageStats=[NSMutableDictionary dictionary];
		  [pagesStatistics setObject:_pageStats
						   forKey:page_];
		  _AvgRespTimeValue=timeInterval_;
		  _MinRespTimeValue=timeInterval_;
		  _MaxRespTimeValue=timeInterval_;
		  _ServedValue=1;
		};
	  _AvgRespTime=[NSNumber numberWithDouble:_AvgRespTimeValue];
	  _MinRespTime=[NSNumber numberWithDouble:_MinRespTimeValue];
	  _MaxRespTime=[NSNumber numberWithDouble:_MaxRespTimeValue];
	  _Served=[NSNumber numberWithInt:_ServedValue];
	  NSDebugMLog(@"_AvgRespTime=%@",_AvgRespTime);
	  NSDebugMLog(@"_MinRespTime=%@",_MinRespTime);
	  NSDebugMLog(@"_MaxRespTime=%@",_MaxRespTime);
	  NSDebugMLog(@"_Served=%@",_Served);
	  [_pageStats setObject:_AvgRespTime
				  forKey:@"Avg Resp. Time"];
	  [_pageStats setObject:_MinRespTime
				  forKey:@"Min Resp. Time"];
	  [_pageStats setObject:_MaxRespTime
				  forKey:@"Max Resp. Time"];
	  [_pageStats setObject:_Served
				  forKey:@"Served"];
	}
  NS_HANDLER
	{
	  NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	}
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_updateDAStatisticsForActionNamed:(id)name_
							timeInterval:(NSTimeInterval)timeInterval_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_sessionTerminating:(id)session_
{
  //OK
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  int _activeSessionsCount=[GSWApp _activeSessionsCount];
	  NSArray* _statistics=[session_ statistics];
	  NSDate* _sessionBirthDate=nil;
	  NSTimeInterval _sessionTimeOut=0;
	  int _sessionRequestCounter=0;
	  [self _updatePathsStatisticsWithPaths:_statistics];
	  _sessionBirthDate=[session_ _birthDate];
	  _sessionTimeOut=[session_ timeOut];
	  _sessionRequestCounter=[session_ _requestCounter];
	  //TODOFN
	}
  NS_HANDLER
	{
	  NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	}
  NS_ENDHANDLER;
  [self unlock];  
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_applicationCreatedSession:(GSWSession*)session_
{
  //OK
  int _activeSessionsCount=0;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  _activeSessionsCount=[[GSWApplication application] _activeSessionsCount];
	  ASSIGN(maxActiveSessionsDate,[NSDate date]);
	  maxActiveSessionsCount=max(_activeSessionsCount,maxActiveSessionsCount);
	  sessionsCount++; //ou _activeSessionsCount
	}
  NS_HANDLER
	{
	  NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	}
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_applicationDidHandleComponentActionRequest
{
  //OK
  double _timeInterval=0;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  _timeInterval=[self _applicationDidHandleRequest];
	  NSDebugMLog(@"currentPage=%@",currentPage);
	  if (currentPage)//TODO no current page if no session (error page,...)
		[self _updatePagesStatisticsForPage:currentPage
			  timeInterval:_timeInterval];
	}
  NS_HANDLER
	{
	  NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	}
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_applicationDidHandleDirectActionRequestWithActionNamed:(id)name_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(double)_applicationDidHandleRequest
{
  //OK
  LOGObjectFnNotImplemented();	//TODOFN
  //lastDidHandleRequestTimeInterval=115.005370  (ancien=53.516954)
  //totalTransactionTimeInterval=double DOUBLE:61.488416 (ancien=0)
  //movingTransactionTimeInterval=double DOUBLE:61.488416 (ancien=0)

  return movingTransactionTimeInterval; //??? 61.488416: ou _totalTransactionTimeInterval - precedent
};

//--------------------------------------------------------------------
-(void)_applicationWillHandleDirectActionRequest
{
  //OK
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  directActionTransactionsCount++;
	  [self _applicationWillHandleRequest];
	}
  NS_HANDLER
	{
	  NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	}
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_applicationWillHandleComponentActionRequest
{
  //OK
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  componentActionTransactionsCount++;
	  [self _applicationWillHandleRequest];
	}
  NS_HANDLER
	{
	  NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	}
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_applicationWillHandleRequest
{
  //OK
  LOGObjectFnNotImplemented();	//TODOFN
  transactionsCount++;
  /*
	lastWillHandleRequestTimeInterval=double DOUBLE:53.516954 [RC=4294967295]
	totalIdleTimeInterval=double DOUBLE:53.516954 [RC=4294967295]
	movingIdleTimeInterval=double DOUBLE:53.516954 [RC=4294967295]
  */
  movingAverageTransactionsCount++;
};

@end

//====================================================================
@implementation GSWStatisticsStore (GSWStatisticsStoreB)

//--------------------------------------------------------------------
-(NSString*)descriptionForResponse:(GSWResponse*)response_
						 inContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _page=nil;
  NSString* _description=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  _page=[context_ page];
	  _description=[_page descriptionForResponse:response_
						  inContext:context_];
	}
  NS_HANDLER
	{
	  NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	}
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return _description;
};

//--------------------------------------------------------------------
-(void)recordStatisticsForResponse:(GSWResponse*)response_
						 inContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _page=nil;
  NSString* _pageName=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  _page=[context_ page];
	  NSDebugMLog(@"_page=%@",_page);
	  _pageName=[_page name];
	  NSDebugMLog(@"_pageName=%@",_pageName);
	  ASSIGN(currentPage,_pageName);
	  NSDebugMLog(@"currentPage=%@",currentPage);
 [self _memoryUsage];//TODO Delete because it's Just for Test !
	}
  NS_HANDLER
	{
	  NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	}
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWStatisticsStore (GSWStatisticsStoreC)

//--------------------------------------------------------------------
-(void)logString:(id)string_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(double)logFileRotationFrequencyInDays
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return logRotation;
};

//--------------------------------------------------------------------
-(NSString*)logFile
{
  //OK
  NSString* _logFile=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  _logFile=logPath;
	}
  NS_HANDLER
	{
	  NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	}
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return _logFile;
};

//--------------------------------------------------------------------
-(void)			setLogFile:(id)logFile_
   rotationFrequencyInDays:(double)rotationFrequency
{
  LOGObjectFnStart();
  ASSIGN(logPath,logFile_);
  logRotation=rotationFrequency;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(id)formatDescription:(id)description_
		   forResponse:(GSWResponse*)response_
			 inContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWStatisticsStore (GSWStatisticsStoreD)

//--------------------------------------------------------------------
-(NSString*)_password
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return password;
};

//--------------------------------------------------------------------
-(NSDictionary*)_pathsStatistics
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return pathsStatistics;
};

//--------------------------------------------------------------------
-(NSDictionary*)_pagesStatistics
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return pagesStatistics;
};

//--------------------------------------------------------------------
-(id)_lastSessionStatistics
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSDictionary*)_memoryUsage
{
  struct rusage _rusage;
  int i=0;
  LOGObjectFnStart();
//Use NSRealMemoryAvailable ??
  for(i=0;i<2;i++)
	{
	  memset(&_rusage,0,sizeof(_rusage));
	  if (getrusage(i>0 ? RUSAGE_CHILDREN : RUSAGE_SELF,&_rusage)!=0)
		{
		  LOGError(@"getrusage faled %d",errno);
		}
	  else
		{
		  NSTimeInterval _userTime=NSTimeIntervalFromTimeVal(&_rusage.ru_utime);
		  NSTimeInterval _systemTime=NSTimeIntervalFromTimeVal(&_rusage.ru_stime);
		  NSDebugMLog(@"_userTime=%ld",(long)_userTime);
		  NSDebugMLog(@"_systemTime=%ld",(long)_systemTime);
		  NSDebugMLog(@"ru_maxrss=%ld",_rusage.ru_maxrss);          /* maximum resident set size */
		  NSDebugMLog(@"ru_ixrss=%ld",_rusage.ru_ixrss);      /* integral shared memory size */
		  NSDebugMLog(@"ru_idrss=%ld",_rusage.ru_idrss);      /* integral unshared data size */
		  NSDebugMLog(@"ru_isrss=%ld",_rusage.ru_isrss);      /* integral unshared stack size */
		  NSDebugMLog(@"ru_minflt=%ld",_rusage.ru_minflt);          /* page reclaims */
		  NSDebugMLog(@"ru_minflt bytes=%ld",_rusage.ru_minflt*getpagesize());          /* page reclaims */
		  NSDebugMLog(@"ru_majflt=%ld",_rusage.ru_majflt);          /* page faults */
		  NSDebugMLog(@"ru_majflt bytes=%ld",_rusage.ru_majflt*getpagesize());          /* page faults */
		  NSDebugMLog(@"ru_nswap=%ld",_rusage.ru_nswap);      /* swaps */
		  NSDebugMLog(@"ru_inblock=%ld",_rusage.ru_inblock);         /* block input operations */
		  NSDebugMLog(@"ru_oublock=%ld",_rusage.ru_oublock);         /* block output operations */
		  NSDebugMLog(@"ru_msgsnd=%ld",_rusage.ru_msgsnd);          /* messages sent */
		  NSDebugMLog(@"ru_msgrcv=%ld",_rusage.ru_msgrcv);          /* messages received */
		  NSDebugMLog(@"ru_nsignals=%ld",_rusage.ru_nsignals);        /* signals received */
		  NSDebugMLog(@"ru_nvcsw=%ld",_rusage.ru_nvcsw);      /* voluntary context switches */
		  NSDebugMLog(@"ru_nivcsw=%ld",_rusage.ru_nivcsw);          /* involuntary context switches */	  
		};
	};
  {
	proc_t P;
	memset(&P,0,sizeof(proc_t));
	pidstat(getpid(),&P);
	pidstatm(getpid(),&P);
  };
  NSDebugMLog(@"ProcInfo:%@",[GSWProcFSProcInfo filledProcInfo]);

  //{Committed = 14184448; Reserved = 19025920; }
/*
 sysinfo(struct sysinfo *info);
CONFORMING TO
       This function is Linux-specific, and should not be used in
       programs intended to be portable.

DESCRIPTION
       sysinfo returns information in the following structure:

              struct sysinfo {
                   long uptime;              // Seconds since boot 
                   unsigned long loads[3];   // 1, 5, and 15 minute load average
s 
                   unsigned long totalram;   // Total usable main memory size 
                   unsigned long freeram;    // Available memory size 
                   unsigned long sharedram;  // Amount of shared memory 
                   unsigned long bufferram;  // Memory used by buffers 
                   unsigned long totalswap;  // Total swap space size 
                   unsigned long freeswap;   // swap space still available 
                   unsigned short procs;     // Number of current processes 
                   char _f[22];              // Pads structure to 64 bytes 
              };
*/


  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;
};

//--------------------------------------------------------------------
-(id)_averageSessionMemory
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(double)_movingAverageSessionLife
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return movingAverageSessionLife;
};

//--------------------------------------------------------------------
-(double)_averageSessionLife
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return averageSessionLife;
};

//--------------------------------------------------------------------
-(float)_movingAverageRequestsPerSession
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return movingAverageRequestsPerSession;
};

//--------------------------------------------------------------------
-(float)_averageRequestsPerSession
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return averageRequestsPerSession;
};

//--------------------------------------------------------------------
-(NSDate*)_maxActiveSessionsDate
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return maxActiveSessionsDate;
};

//--------------------------------------------------------------------
-(int)_maxActiveSessionsCount
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return maxActiveSessionsCount;
};

//--------------------------------------------------------------------
-(int)_sessionsCount
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return sessionsCount;
};

//--------------------------------------------------------------------
-(double)_movingAverageTransactionTime
{
  LOGObjectFnStart();
  NSAssert(movingAverageTransactionsCount,@"movingAverageTransactionsCount==0");
  LOGObjectFnStop();
  return movingTransactionTimeInterval/movingAverageTransactionsCount; //?
};

//--------------------------------------------------------------------
-(double)_movingAverageIdleTime
{
  LOGObjectFnStart();
  NSAssert(movingAverageTransactionsCount,@"movingAverageTransactionsCount==0");
  LOGObjectFnStop();
  return movingIdleTimeInterval/movingAverageTransactionsCount;//??
};

//--------------------------------------------------------------------
-(double)_averageCATransactionTime
{
  LOGObjectFnStart();
  NSAssert(movingAverageTransactionsCount,@"movingAverageTransactionsCount==0");
  LOGObjectFnStop();
  return totalCATransactionTimeInterval/movingAverageTransactionsCount; //??
};

//--------------------------------------------------------------------
-(double)_averageDATransactionTime
{
  LOGObjectFnStart();
  NSAssert(movingAverageTransactionsCount,@"movingAverageTransactionsCount==0");
  LOGObjectFnStop();
  return totalDATransactionTimeInterval/movingAverageTransactionsCount; //??
};

//--------------------------------------------------------------------
-(double)_averageTransactionTime
{
  LOGObjectFnStart();
  NSAssert(movingAverageTransactionsCount,@"movingAverageTransactionsCount==0");
  LOGObjectFnStop();
  return totalTransactionTimeInterval/movingAverageTransactionsCount; //?
};

//--------------------------------------------------------------------
-(double)_averageIdleTime
{
  LOGObjectFnStart();
  NSAssert(movingAverageTransactionsCount,@"movingAverageTransactionsCount==0");
  LOGObjectFnStop();
  return totalIdleTimeInterval/movingAverageTransactionsCount;//??
};

//--------------------------------------------------------------------
-(int)_directActionTransactionsCount
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return directActionTransactionsCount;
};

//--------------------------------------------------------------------
-(int)_componentActionTransactionsCount
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return componentActionTransactionsCount;
};

//--------------------------------------------------------------------
-(int)_transactionsCount
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return transactionsCount;
};

@end

//====================================================================
@implementation GSWStatisticsStore (GSWStatisticsStoreE)

//--------------------------------------------------------------------
-(BOOL)validateLogin:(id)login_
		  forSession:(id)session_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(void)setPassword:(NSString*)password_
{
  LOGObjectFnStart();
  ASSIGN(password,password_);
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWStatisticsStore (GSWStatisticsStoreF)
//--------------------------------------------------------------------
-(BOOL)validateLogin:(id)login_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

@end

//====================================================================
@implementation GSWStatisticsStore (GSWStatisticsStoreG)
//--------------------------------------------------------------------
-(void)_validateAPI
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWStatisticsStore (GSWStatisticsStoreH)

//--------------------------------------------------------------------
+(id)timeIntervalDescription:(double)timeInterval_
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

@end


