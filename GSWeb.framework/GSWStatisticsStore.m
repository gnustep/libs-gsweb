/** GSWStatisticsStore.m - <title>GSWeb: Class GSWStatisticsStore</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

#include <sys/resource.h>
#include <unistd.h>

//====================================================================
@implementation GSWStatisticsStore

//--------------------------------------------------------------------
-(id)init
{
  //OK
  if ((self=[super init]))
    {
      _transactionMovingAverageSampleCount = 100;
      _sessionMovingAverageSampleCount = 10;
      ASSIGN(_startDate, [NSDate date]);
      ASSIGN(_initializationMemory, [self _memoryUsage]);
      _selfLock = [NSRecursiveLock new];
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWStatisticsStore");
  GSWLogC("Dealloc GSWStatisticsStore: selfLock");
  DESTROY(_selfLock);
  GSWLogC("Dealloc GSWStatisticsStore: maxActiveSessionsDate");
  DESTROY(_maxActiveSessionsDate);
  DESTROY(_lastSessionStatistics);
  DESTROY(_startDate);
  DESTROY(_lastStatsDate);
  DESTROY(_initializationMemory);
  DESTROY(_pagesStatistics);
  DESTROY(_currentPage);
  DESTROY(_pathsStatistics);
  DESTROY(_logPath);
  DESTROY(_logCreationDate);
  DESTROY(_password);
  DESTROY(_directActionStatistics);
  GSWLogC("Dealloc GSWStatisticsStore Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWStatisticsStore");
};

//--------------------------------------------------------------------
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLog(@"selfLockn=%d",_selfLockn);
  LoggedUnlock(_selfLock);
#ifndef NDEBUG
  _selfLockn--;
#endif
  NSDebugMLog(@"selfLockn=%d",_selfLockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)lock
{
  LOGObjectFnStart();
  NSDebugMLog(@"selfLockn=%d",_selfLockn);
  LoggedLockBeforeDate(_selfLock, GSW_LOCK_LIMIT);
#ifndef NDEBUG
  _selfLockn++;
#endif
  NSDebugMLog(@"selfLockn=%d",_selfLockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/*
 should return this:

 2002-10-26 13:50:19.825 foobarWO[3207] stats=<CFDictionary 0xf6fa0 [0x8016024c]>{count = 5, capacity = 6, pairs = (
     0 : Pages = <CFDictionary 0xf98f0 [0x8016024c]>{count = 1, capacity = 3, pairs = (
     1 : Main = <CFDictionary 0xfb040 [0x8016024c]>{count = 4, capacity = 6, pairs = (
     1 : Min Resp. Time = 0.06496943533420562432
     2 : Max Resp. Time = 0.4728142097592352768
     3 : Avg Resp. Time = 0.2195588141679763968
     7 : Served = 5
 )}
 )}
     3 : StartedAt = 2002-10-26 13:49:05 +0200
     5 : Transactions = <CFDictionary 0xf82a0 [0x8016024c]>{count = 11, capacity = 11, pairs = (
     0 : Component Action Transactions = 6
     2 : Transaction Rate = 0
     4 : Direct Action Avg. Transaction Time = 0
     5 : Transactions = 6
     7 : Avg. Idle Time = 12.154283278932174848
     9 : Moving Avg. Idle Time = 12.154283278932174848
     10 : Direct Action Transactions = 0
     11 : Component Action  Avg. Transaction Time = 0.2195588141679763456
     12 : Moving Avg. Transaction Time = 0.2195588141679763456
     13 : Avg. Transaction Time = 0.2195588141679763456
     15 : Sample Size For Moving Avg. = 100
 )}
     6 : Sessions = <CFDictionary 0xfd290 [0x8016024c]>{count = 11, capacity = 11, pairs = (
     0 : Peak Active Sessions Date = 2002-10-26 13:50:17 +0200
     1 : Current Active Sessions = 2
     4 : Peak Active Sessions = 2
     6 : Avg. Memory Per Session = <CFDictionary 0xf8b00 [0x8016024c]>{count = 2, capacity = 3, pairs = (
     2 : Virtual = 1388544
     3 : Resident Set Size = 264192
 )}
     9 : Moving Avg. Transactions Per Session = 0
     10 : Sample Size For Moving Avg. = 10
     11 : Moving Avg. Session Life = 0
     12 : Session Rate = 0
     13 : Avg. Transactions Per Session = 0
     14 : Avg. Session Life = 0
     15 : Total Sessions Created = 2
 )}
     7 : Memory = <CFDictionary 0xfafe0 [0x8016024c]>{count = 2, capacity = 3, pairs = (
     2 : Virtual = 541458432
     3 : Resident Set Size = 1622016
 )}
 )}
 */

-(id)statistics
{
  NSMutableDictionary	*statDict = [NSMutableDictionary dictionary];
  NSMutableDictionary	*sessionsDict = [NSMutableDictionary dictionary];

  [statDict setObject:_startDate
               forKey:@"StartedAt"];

 // Sessions

  [sessionsDict setObject:GSWIntToNSString(_sessionsCount)
                   forKey:@"Current Active Sessions"];


  [statDict setObject:sessionsDict
               forKey:@"Sessions"];

  // Pages
  if (_pagesStatistics) {
  [statDict setObject:_pagesStatistics
               forKey:@"Pages"];
  }
  
  
//  LOGObjectFnNotImplemented();	//TODOFN
  return statDict;
};

//--------------------------------------------------------------------
-(int)sessionMovingAverageSampleSize
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _sessionMovingAverageSampleCount;
};

//--------------------------------------------------------------------
-(void)setSessionMovingAverageSampleSize:(int)aSize
{
  LOGObjectFnStart();
  _sessionMovingAverageSampleCount=aSize;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(int)transactionMovingAverageSampleSize
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _transactionMovingAverageSampleCount;
};

//--------------------------------------------------------------------
-(void)setTransactionMovingAverageSampleSize:(int)aSize
{
  LOGObjectFnStart();
  _transactionMovingAverageSampleCount=aSize;
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
-(void)_updatePathsStatisticsWithPaths:(id)paths
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
-(void)_sessionTerminating:(GSWSession*)aSession
{
  int activeSessionsCount = 0;
  NSArray* statistics = nil;
  NSDate* sessionBirthDate = nil;
  NSTimeInterval sessionTimeOut = 0;
  int sessionRequestCounter = 0;
  //OK
  LOGObjectFnStart();
  activeSessionsCount=[GSWApp _activeSessionsCount];
  statistics=[aSession statistics];
  sessionBirthDate=nil;
  sessionTimeOut=0;
  sessionRequestCounter=0;
  [self _updatePathsStatisticsWithPaths:statistics];
  sessionBirthDate=[aSession _birthDate];
  sessionTimeOut=[aSession timeOut];
  sessionRequestCounter=[aSession _requestCounter];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)sessionTerminating:(GSWSession*)aSession
{
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      [self _sessionTerminating:aSession];
    }
  NS_HANDLER
    {
      NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",
                  localException,[localException reason],
                  __FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];  
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_applicationCreatedSession:(GSWSession*)aSession
{
  //OK
  int activeSessionsCount=0;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      activeSessionsCount=[[GSWApplication application] _activeSessionsCount];
      ASSIGN(_maxActiveSessionsDate,[NSDate date]);
      _maxActiveSessionsCount=max(activeSessionsCount,_maxActiveSessionsCount);
      _sessionsCount++; //ou activeSessionsCount
    }
  NS_HANDLER
    {
      NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",
                  localException,[localException reason],
                  __FILE__,__LINE__);
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
  NSTimeInterval idleTimeInterval = 0;
  NSDate* currentDate=nil;
  
  currentDate=[NSDate date];

  _transactionsCount++;

  _lastWillHandleRequestTimeInterval = [currentDate timeIntervalSinceDate:_startDate];

  idleTimeInterval = _lastWillHandleRequestTimeInterval - _lastDidHandleRequestTimeInterval;
  _totalIdleTimeInterval += idleTimeInterval;
  if (_transactionMovingAverageSampleCount>0)
    {
      _movingAverageTransactionsCount++;
      _movingIdleTimeInterval += idleTimeInterval;
      if(_movingAverageTransactionsCount > _transactionMovingAverageSampleCount)
        {
          _movingIdleTimeInterval -= 
            _movingIdleTimeInterval / (double)_transactionMovingAverageSampleCount;
        };
    };
};

//--------------------------------------------------------------------
-(void)applicationWillHandleDirectActionRequest
{
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      _directActionTransactionsCount++;
      [self _applicationWillHandleRequest];
    }
  NS_HANDLER
    {
      NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",
                  localException,[localException reason],
                  __FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)applicationWillHandleWebServiceRequest
{
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      _webServiceTransactionsCount++;
      [self _applicationWillHandleRequest];
    }
  NS_HANDLER
    {
      NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",
                  localException,[localException reason],
                  __FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)applicationWillHandleComponentActionRequest
{
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      _componentActionTransactionsCount++;
      [self _applicationWillHandleRequest];
    }
  NS_HANDLER
    {
      NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",
                  localException,[localException reason],
                  __FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

-(void)_updateHandlerStatistics:(NSMutableDictionary*)statistics
                        withKey:(NSString*)aKey
           handlingTimeInterval:(NSTimeInterval)handlingTimeInterval
{
  LOGObjectFnStart();
  if (aKey)
    {
      NSNumber* AvgRespTime=nil;
      NSNumber* MinRespTime=nil;
      NSNumber* MaxRespTime=nil;
      NSNumber* Served=nil;
      double AvgRespTimeValue=0;
      double MinRespTimeValue=0;
      double MaxRespTimeValue=0;
      int ServedValue=0;
      NSMutableDictionary* statsForKey=[statistics objectForKey:aKey];

      NSDebugMLog(@"statsForKey=%@",statsForKey);
      if (statsForKey)
        {
          AvgRespTime=[statsForKey objectForKey:@"Avg Resp. Time"];
          MinRespTime=[statsForKey objectForKey:@"Min Resp. Time"];
          MaxRespTime=[statsForKey objectForKey:@"Max Resp. Time"];
          Served=[statsForKey objectForKey:@"Served"];
          
          ServedValue=[Served intValue];
          if (MinRespTime)
            {
              MinRespTimeValue=[MinRespTime doubleValue];
              MinRespTimeValue=min(MinRespTimeValue,handlingTimeInterval);
            }
          else
            MinRespTimeValue=handlingTimeInterval;
          if (MaxRespTime)
            {
              MaxRespTimeValue=[MaxRespTime doubleValue];
                  MaxRespTimeValue=max(MaxRespTimeValue,handlingTimeInterval);
            }
          else
            MaxRespTimeValue=handlingTimeInterval;
          if (AvgRespTime)
            {
              AvgRespTimeValue=[AvgRespTime doubleValue];
              AvgRespTimeValue=((AvgRespTimeValue*ServedValue)+handlingTimeInterval)/(ServedValue+1);
            }
          else
            AvgRespTimeValue=handlingTimeInterval;
          ServedValue++;
        }
      else
        {
          statsForKey=(NSMutableDictionary*)[NSMutableDictionary dictionary];
          [statistics setObject:statsForKey
                      forKey:aKey];
          AvgRespTimeValue=handlingTimeInterval;
          MinRespTimeValue=handlingTimeInterval;
          MaxRespTimeValue=handlingTimeInterval;
          ServedValue=1;
        };
      AvgRespTime=[NSNumber numberWithDouble:AvgRespTimeValue];
      MinRespTime=[NSNumber numberWithDouble:MinRespTimeValue];
      MaxRespTime=[NSNumber numberWithDouble:MaxRespTimeValue];
      Served=GSWIntNumber(ServedValue);
      NSDebugMLog(@"AvgRespTime=%@",AvgRespTime);
      NSDebugMLog(@"MinRespTime=%@",MinRespTime);
      NSDebugMLog(@"MaxRespTime=%@",MaxRespTime);
      NSDebugMLog(@"Served=%@",Served);
      [statsForKey setObject:AvgRespTime
                   forKey:@"Avg Resp. Time"];
      [statsForKey setObject:MinRespTime
                   forKey:@"Min Resp. Time"];
      [statsForKey setObject:MaxRespTime
                   forKey:@"Max Resp. Time"];
      [statsForKey setObject:Served
                       forKey:@"Served"];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSTimeInterval)_applicationDidHandleRequest
{
  NSTimeInterval handlingTimeInterval=0;
  NSDate* currentDate=nil;

  currentDate=[NSDate date];

  _lastDidHandleRequestTimeInterval = [currentDate timeIntervalSinceDate:_startDate];
  handlingTimeInterval = _lastDidHandleRequestTimeInterval - _lastWillHandleRequestTimeInterval;

  _totalTransactionTimeInterval += handlingTimeInterval;
  if (_transactionMovingAverageSampleCount>0)
    {
      _movingTransactionTimeInterval += handlingTimeInterval;
      if (_movingAverageTransactionsCount>_transactionMovingAverageSampleCount)
        {
          _movingTransactionTimeInterval -= 
            _movingTransactionTimeInterval / (NSTimeInterval)_transactionMovingAverageSampleCount;
        };
    }
  return handlingTimeInterval;
};

//--------------------------------------------------------------------
-(void)_applicationDidHandleComponentActionRequest
{
  NSTimeInterval handlingTimeInterval=[self _applicationDidHandleRequest];
  _totalCATransactionTimeInterval += handlingTimeInterval;
  [self _updateHandlerStatistics:_pagesStatistics
        withKey:_currentPage
        handlingTimeInterval:handlingTimeInterval];
};

//--------------------------------------------------------------------
-(void)_applicationDidHandleDirectActionRequestWithActionNamed:(NSString*)actionName
{
  NSTimeInterval handlingTimeInterval=[self _applicationDidHandleRequest];
  _totalDATransactionTimeInterval += handlingTimeInterval;
  [self _updateHandlerStatistics:_directActionStatistics
        withKey:actionName
        handlingTimeInterval:handlingTimeInterval];
};

//--------------------------------------------------------------------
-(void)_applicationDidHandleWebServiceRequestWithActionNamed:(NSString*)actionName
{
  NSTimeInterval handlingTimeInterval=[self _applicationDidHandleRequest];
  _totalWSTransactionTimeInterval += handlingTimeInterval;
  [self _updateHandlerStatistics:_webServiceStatistics
        withKey:actionName
        handlingTimeInterval:handlingTimeInterval];
};

//--------------------------------------------------------------------
-(void)applicationDidHandleComponentActionRequestWithPageNamed:(NSString*)pageName
{
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      [self _applicationDidHandleComponentActionRequest];
    }
  NS_HANDLER
    {
      NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",
                  localException,[localException reason],
                  __FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)applicationDidHandleDirectActionRequestWithActionNamed:(NSString*)actionName
{
  //OK
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      [self _applicationDidHandleDirectActionRequestWithActionNamed:actionName];
    }
  NS_HANDLER
    {
      NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",
                  localException,[localException reason],
                  __FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)applicationDidHandleWebServiceRequestWithActionNamed:(NSString*)actionName
{
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      [self _applicationDidHandleWebServiceRequestWithActionNamed:actionName];
    }
  NS_HANDLER
    {
      NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",
                  localException,[localException reason],
                  __FILE__,__LINE__);
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
@implementation GSWStatisticsStore (GSWStatisticsStoreB)

//--------------------------------------------------------------------
-(NSString*)descriptionForResponse:(GSWResponse*)aResponse
                         inContext:(GSWContext*)aContext
{
  //OK
  GSWComponent* page=nil;
  NSString* description=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      page=[aContext page];
      description=[page descriptionForResponse:aResponse
                        inContext:aContext];
    }
  NS_HANDLER
    {
      NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",
                  localException,[localException reason],
                  __FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return description;
};

//--------------------------------------------------------------------
-(void)recordStatisticsForResponse:(GSWResponse*)aResponse
                         inContext:(GSWContext*)aContext
{
  //OK
  GSWComponent* page=nil;
  NSString* pageName=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      page=[aContext page];
      NSDebugMLog(@"page=%@",page);
      pageName=[page name];
      NSDebugMLog(@"pageName=%@",pageName);
      ASSIGN(_currentPage,pageName);
      NSDebugMLog(@"_currentPage=%@",_currentPage);
      [self _memoryUsage];//TODO Delete because it's Just for Test !
    }
  NS_HANDLER
    {
      NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",
                  localException,[localException reason],
                  __FILE__,__LINE__);
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
-(void)logString:(id)aString
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(double)logFileRotationFrequencyInDays
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _logRotation;
};

//--------------------------------------------------------------------
-(NSString*)logFile
{
  //OK
  NSString* logFile=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      logFile=_logPath;
    }
  NS_HANDLER
    {
      NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d]",
                  localException,[localException reason],
                  __FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return logFile;
};

//--------------------------------------------------------------------
-(void)	       setLogFile:(id)logFile
  rotationFrequencyInDays:(double)rotationFrequency
{
  LOGObjectFnStart();
  ASSIGN(_logPath,logFile);
  _logRotation=rotationFrequency;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
+(NSString*)formatDescription:(NSString*)description
                  forResponse:(GSWResponse*)aResponse
                    inContext:(GSWContext*)aContext
{
  NSString* formattedDescr=nil;
//  public String formatDescription(String s, WOResponse woresponse, WOContext wocontext)
  if (description)
    {
      GSWRequest* request = [aContext request];
      NSString* remoteHost=nil;
      NSString* remoteUser=nil;
      NSString* requestMethod=nil;
      NSString* httpVersion=nil;
      if (request)
        {
          remoteHost=[request headerForKey:GSWHTTPHeader_RemoteHost[GSWebNamingConv]];
          if ([remoteHost length]==0)
            {
              remoteHost=[request headerForKey:GSWHTTPHeader_RemoteAddress[GSWebNamingConv]];
              if ([remoteHost length]==0)
                remoteHost=@"-";
            };
          remoteUser=[request headerForKey:GSWHTTPHeader_RemoteUser[GSWebNamingConv]];
          if ([remoteHost length]==0)
            {
              remoteUser=@"-";
            };
          requestMethod=[request method];
          httpVersion=[request httpVersion];
        }
      else
        {
          remoteHost=@"?";
          remoteUser=@"?";
          requestMethod=@"?";
          httpVersion=@"?";
        };
      description = [description stringByReplacingString:@" "
                                 withString:@"_"];
      formattedDescr=[NSString stringWithFormat:@"%@ - %@ [%@] \"%@ %@/%@ %@\" %u %u\n",
                               remoteHost,
                               remoteUser,
                               [NSDate date],
                               requestMethod,
                               [[GSWApplication application]name],
                               description,
                               httpVersion,
                               (unsigned int)[aResponse status],
                               (unsigned int)[aResponse _contentDataLength]];
    };
  return formattedDescr;
};

@end

//====================================================================
@implementation GSWStatisticsStore (GSWStatisticsStoreD)

//--------------------------------------------------------------------
-(NSString*)_password
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _password;
};

//--------------------------------------------------------------------
-(NSDictionary*)_pathsStatistics
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _pathsStatistics;
};

//--------------------------------------------------------------------
-(NSDictionary*)_pagesStatistics
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _pagesStatistics;
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
  struct rusage rusageStruct;
  int i=0;
  LOGObjectFnStart();
//Use NSRealMemoryAvailable ??
  for(i=0;i<2;i++)
    {
      memset(&rusageStruct,0,sizeof(rusageStruct));
      if (getrusage(i>0 ? RUSAGE_CHILDREN : RUSAGE_SELF,&rusageStruct)!=0)
        {
          LOGError(@"getrusage faled %d",errno);
        }
      else
        {
          NSTimeInterval userTime=NSTimeIntervalFromTimeVal(&rusageStruct.ru_utime);
          NSTimeInterval systemTime=NSTimeIntervalFromTimeVal(&rusageStruct.ru_stime);
          NSDebugMLog(@"userTime=%ld",(long)userTime);
          NSDebugMLog(@"systemTime=%ld",(long)systemTime);
          NSDebugMLog(@"ru_maxrss=%ld",rusageStruct.ru_maxrss);          /* maximum resident set size */
          NSDebugMLog(@"ru_ixrss=%ld",rusageStruct.ru_ixrss);      /* integral shared memory size */
          NSDebugMLog(@"ru_idrss=%ld",rusageStruct.ru_idrss);      /* integral unshared data size */
          NSDebugMLog(@"ru_isrss=%ld",rusageStruct.ru_isrss);      /* integral unshared stack size */
          NSDebugMLog(@"ru_minflt=%ld",rusageStruct.ru_minflt);          /* page reclaims */
          NSDebugMLog(@"ru_minflt bytes=%ld",rusageStruct.ru_minflt*getpagesize());          /* page reclaims */
          NSDebugMLog(@"ru_majflt=%ld",rusageStruct.ru_majflt);          /* page faults */
          NSDebugMLog(@"ru_majflt bytes=%ld",rusageStruct.ru_majflt*getpagesize());          /* page faults */
          NSDebugMLog(@"ru_nswap=%ld",rusageStruct.ru_nswap);      /* swaps */
          NSDebugMLog(@"ru_inblock=%ld",rusageStruct.ru_inblock);         /* block input operations */
          NSDebugMLog(@"ru_oublock=%ld",rusageStruct.ru_oublock);         /* block output operations */
          NSDebugMLog(@"ru_msgsnd=%ld",rusageStruct.ru_msgsnd);          /* messages sent */
          NSDebugMLog(@"ru_msgrcv=%ld",rusageStruct.ru_msgrcv);          /* messages received */
          NSDebugMLog(@"ru_nsignals=%ld",rusageStruct.ru_nsignals);        /* signals received */
          NSDebugMLog(@"ru_nvcsw=%ld",rusageStruct.ru_nvcsw);      /* voluntary context switches */
          NSDebugMLog(@"ru_nivcsw=%ld",rusageStruct.ru_nivcsw);          /* involuntary context switches */	  
        };
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
  return _movingAverageSessionLife;
};

//--------------------------------------------------------------------
-(double)_averageSessionLife
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _averageSessionLife;
};

//--------------------------------------------------------------------
-(float)_movingAverageRequestsPerSession
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _movingAverageRequestsPerSession;
};

//--------------------------------------------------------------------
-(float)_averageRequestsPerSession
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _averageRequestsPerSession;
};

//--------------------------------------------------------------------
-(NSDate*)_maxActiveSessionsDate
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _maxActiveSessionsDate;
};

//--------------------------------------------------------------------
-(int)_maxActiveSessionsCount
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _maxActiveSessionsCount;
};

//--------------------------------------------------------------------
-(int)_sessionsCount
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _sessionsCount;
};

//--------------------------------------------------------------------
-(double)_movingAverageTransactionTime
{
  LOGObjectFnStart();
  NSAssert(_movingAverageTransactionsCount!=0,@"movingAverageTransactionsCount==0");
  LOGObjectFnStop();
  return _movingTransactionTimeInterval/_movingAverageTransactionsCount; //?
};

//--------------------------------------------------------------------
-(double)_movingAverageIdleTime
{
  LOGObjectFnStart();
  NSAssert(_movingAverageTransactionsCount!=0,@"movingAverageTransactionsCount==0");
  LOGObjectFnStop();
  return _movingIdleTimeInterval/_movingAverageTransactionsCount;//??
};

//--------------------------------------------------------------------
-(double)_averageCATransactionTime
{
  LOGObjectFnStart();
  NSAssert(_movingAverageTransactionsCount!=0,@"movingAverageTransactionsCount==0");
  LOGObjectFnStop();
  return _totalCATransactionTimeInterval/_movingAverageTransactionsCount; //??
};

//--------------------------------------------------------------------
-(double)_averageDATransactionTime
{
  LOGObjectFnStart();
  NSAssert(_movingAverageTransactionsCount!=0,@"movingAverageTransactionsCount==0");
  LOGObjectFnStop();
  return _totalDATransactionTimeInterval/_movingAverageTransactionsCount; //??
};

//--------------------------------------------------------------------
-(double)_averageTransactionTime
{
  LOGObjectFnStart();
  NSAssert(_movingAverageTransactionsCount!=0,@"movingAverageTransactionsCount==0");
  LOGObjectFnStop();
  return _totalTransactionTimeInterval/_movingAverageTransactionsCount; //?
};

//--------------------------------------------------------------------
-(double)_averageIdleTime
{
  LOGObjectFnStart();
  NSAssert(_movingAverageTransactionsCount!=0,@"movingAverageTransactionsCount==0");
  LOGObjectFnStop();
  return _totalIdleTimeInterval/_movingAverageTransactionsCount;//??
};

//--------------------------------------------------------------------
-(int)_directActionTransactionsCount
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _directActionTransactionsCount;
};

//--------------------------------------------------------------------
-(int)_componentActionTransactionsCount
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _componentActionTransactionsCount;
};

//--------------------------------------------------------------------
-(int)_transactionsCount
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _transactionsCount;
};

@end

//====================================================================
@implementation GSWStatisticsStore (GSWStatisticsStoreE)

//--------------------------------------------------------------------
-(BOOL)validateLogin:(id)aLogin
          forSession:(id)aSession
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(void)setPassword:(NSString*)aPassword
{
  LOGObjectFnStart();
  ASSIGN(_password,aPassword);
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWStatisticsStore (GSWStatisticsStoreF)
//--------------------------------------------------------------------
-(BOOL)validateLogin:(id)aLogin
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
+(id)timeIntervalDescription:(double)aTimeInterval
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

@end


