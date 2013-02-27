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
#include <GNUstepBase/NSObject+GNUstepBase.h>
#include <GNUstepBase/NSString+GNUstepBase.h>

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
      //ASSIGN(_initializationMemory, [self _memoryUsage]);
      _selfLock = [NSRecursiveLock new];
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_selfLock);
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
  [super dealloc];
};

//--------------------------------------------------------------------
-(void)unlock
{
  LoggedUnlock(_selfLock);
#ifndef NDEBUG
  _selfLockn--;
#endif
};

//--------------------------------------------------------------------
-(void)lock
{
  LoggedLockBeforeDate(_selfLock, GSW_LOCK_LIMIT);
#ifndef NDEBUG
  _selfLockn++;
#endif
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
  
  
//  [self notImplemented: _cmd];	//TODOFN
  return statDict;
};

//--------------------------------------------------------------------
-(int)sessionMovingAverageSampleSize
{
  return _sessionMovingAverageSampleCount;
};

//--------------------------------------------------------------------
-(void)setSessionMovingAverageSampleSize:(int)aSize
{
  _sessionMovingAverageSampleCount=aSize;
};

//--------------------------------------------------------------------
-(int)transactionMovingAverageSampleSize
{
  return _transactionMovingAverageSampleCount;
};

//--------------------------------------------------------------------
-(void)setTransactionMovingAverageSampleSize:(int)aSize
{
  _transactionMovingAverageSampleCount=aSize;
};


//--------------------------------------------------------------------
-(void)_purgePathsStatistics
{
  SYNCHRONIZED(self) {
    NSUInteger n = 2;
    
    for(; [_pathsStatistics count] > 100; n++)
    {
      NSEnumerator   * pathsEnum = [_pathsStatistics keyEnumerator];
      NSEnumerator   * pathsToRemoveEnum = nil;
      NSMutableArray * pathsToRemove = [NSMutableArray array];
      NSString       * path = nil;
      
      while ((path = [pathsEnum nextObject])) 
      {
        // we have to store NSNumbers
        if ([[_pathsStatistics objectForKey:path] integerValue] < n) {          
          [pathsToRemove addObject:path];
        }
      }
      pathsToRemoveEnum = [pathsToRemove objectEnumerator];
      
      while ((path = [pathsToRemoveEnum nextObject])) {
        [_pathsStatistics removeObjectForKey:path];
      }
      
    }
  } END_SYNCHRONIZED;
}

//--------------------------------------------------------------------
-(void)_updatePathsStatisticsWithPaths:(id)paths
{
  NSEnumerator   * pathsEnum;
  NSString       * path = nil;
  
  [self _purgePathsStatistics];
  
  pathsEnum = [paths objectEnumerator];
  
  while ((path = [pathsEnum nextObject]))
  {
    NSNumber * count = [_pathsStatistics objectForKey:path];
    
    if (count) {
      NSInteger integerValue = [count integerValue] + 1;
      [_pathsStatistics setObject:[NSNumber numberWithInteger:integerValue]
                           forKey:path];
    } else {
      [_pathsStatistics setObject:[NSNumber numberWithInteger:1]
                           forKey:path];
    }
  }
  
}

//--------------------------------------------------------------------
-(void)_sessionTerminating:(GSWSession*)aSession
{
  int activeSessionsCount = 0;
  NSArray* statistics = nil;
  NSDate* sessionBirthDate = nil;
  NSTimeInterval sessionTimeOut = 0;
  int sessionRequestCounter = 0;
  //OK
  activeSessionsCount=[GSWApp _activeSessionsCount];
  statistics=[aSession statistics];
  sessionBirthDate=nil;
  sessionTimeOut=0;
  sessionRequestCounter=0;
  [self _updatePathsStatisticsWithPaths:statistics];
  sessionBirthDate=[aSession _birthDate];
  sessionTimeOut=[aSession timeOut];
  sessionRequestCounter=[aSession _requestCounter];
};

//--------------------------------------------------------------------
-(void)sessionTerminating:(GSWSession*)aSession
{
  [self lock];
  NS_DURING
    {
      [self _sessionTerminating:aSession];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];  
};

//--------------------------------------------------------------------
-(void)_applicationCreatedSession:(GSWSession*)aSession
{
  //OK
  int activeSessionsCount=0;
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
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
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
  [self lock];
  NS_DURING
    {
      _directActionTransactionsCount++;
      [self _applicationWillHandleRequest];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
};

//--------------------------------------------------------------------
-(void)applicationWillHandleWebServiceRequest
{
  [self lock];
  NS_DURING
    {
      _webServiceTransactionsCount++;
      [self _applicationWillHandleRequest];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
};

//--------------------------------------------------------------------
-(void)applicationWillHandleComponentActionRequest
{
  [self lock];
  NS_DURING
    {
      _componentActionTransactionsCount++;
      [self _applicationWillHandleRequest];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
};

-(void)_updateHandlerStatistics:(NSMutableDictionary*)statistics
                        withKey:(NSString*)aKey
           handlingTimeInterval:(NSTimeInterval)handlingTimeInterval
{
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

      [statsForKey setObject:AvgRespTime
                   forKey:@"Avg Resp. Time"];
      [statsForKey setObject:MinRespTime
                   forKey:@"Min Resp. Time"];
      [statsForKey setObject:MaxRespTime
                   forKey:@"Max Resp. Time"];
      [statsForKey setObject:Served
                       forKey:@"Served"];
    };
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
  [self lock];
  NS_DURING
    {
      [self _applicationDidHandleComponentActionRequest];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
};

//--------------------------------------------------------------------
-(void)applicationDidHandleDirectActionRequestWithActionNamed:(NSString*)actionName
{
  //OK
  [self lock];
  NS_DURING
    {
      [self _applicationDidHandleDirectActionRequestWithActionNamed:actionName];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
};

//--------------------------------------------------------------------
-(void)applicationDidHandleWebServiceRequestWithActionNamed:(NSString*)actionName
{
  [self lock];
  NS_DURING
    {
      [self _applicationDidHandleWebServiceRequestWithActionNamed:actionName];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
};



//--------------------------------------------------------------------
-(NSString*)descriptionForResponse:(GSWResponse*)aResponse
                         inContext:(GSWContext*)aContext
{
  //OK
  GSWComponent* page=nil;
  NSString* description=nil;
  [self lock];
  NS_DURING
    {
      page=[aContext page];
      description=[page descriptionForResponse:aResponse
                        inContext:aContext];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  return description;
};

//--------------------------------------------------------------------
-(void)recordStatisticsForResponse:(GSWResponse*)aResponse
                         inContext:(GSWContext*)aContext
{
  //OK
  GSWComponent* page=nil;
  NSString* pageName=nil;
  [self lock];
  NS_DURING
    {
      page=[aContext page];
      pageName=[page name];
      ASSIGN(_currentPage,pageName);
      //[self _memoryUsage];//TODO Delete because it's Just for Test !
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
};


//--------------------------------------------------------------------
-(void)logString:(id)aString
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(double)logFileRotationFrequencyInDays
{
  return _logRotation;
};

//--------------------------------------------------------------------
-(NSString*)logFile
{
  //OK
  NSString* logFile=nil;
  [self lock];
  NS_DURING
    {
      logFile=_logPath;
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  return logFile;
};

//--------------------------------------------------------------------
-(void) setLogFile:(NSString *)logFile rotationFrequencyInDays:(NSTimeInterval)rotationFrequency
{
  ASSIGN(_logPath,logFile);
  _logRotation=rotationFrequency;
}

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


//--------------------------------------------------------------------
-(NSString*)_password
{
  return _password;
};

//--------------------------------------------------------------------
-(NSDictionary*)_pathsStatistics
{
  return _pathsStatistics;
};

//--------------------------------------------------------------------
-(NSDictionary*)_pagesStatistics
{
  return _pagesStatistics;
};

//--------------------------------------------------------------------
-(id)_lastSessionStatistics
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSDictionary*)_memoryUsage
{
  struct rusage rusageStruct;
  int i=0;
//Use NSRealMemoryAvailable ??
  for(i=0;i<2;i++)
    {
      memset(&rusageStruct,0,sizeof(rusageStruct));
      if (getrusage(i>0 ? RUSAGE_CHILDREN : RUSAGE_SELF,&rusageStruct)!=0)
        {
//          LOGError(@"getrusage faled %d",errno);
        }
      else
        {
//          NSTimeInterval userTime=NSTimeIntervalFromTimeVal(&rusageStruct.ru_utime);
//          NSTimeInterval systemTime=NSTimeIntervalFromTimeVal(&rusageStruct.ru_stime);
        };
    };
  
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


  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)_averageSessionMemory
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(double)_movingAverageSessionLife
{
  return _movingAverageSessionLife;
};

//--------------------------------------------------------------------
-(double)_averageSessionLife
{
  return _averageSessionLife;
};

//--------------------------------------------------------------------
-(float)_movingAverageRequestsPerSession
{
  return _movingAverageRequestsPerSession;
};

//--------------------------------------------------------------------
-(float)_averageRequestsPerSession
{
  return _averageRequestsPerSession;
};

//--------------------------------------------------------------------
-(NSDate*)_maxActiveSessionsDate
{
  return _maxActiveSessionsDate;
};

//--------------------------------------------------------------------
-(int)_maxActiveSessionsCount
{
  return _maxActiveSessionsCount;
};

//--------------------------------------------------------------------
-(int)_sessionsCount
{
  return _sessionsCount;
};

//--------------------------------------------------------------------
-(double)_movingAverageTransactionTime
{
  NSAssert(_movingAverageTransactionsCount!=0,@"movingAverageTransactionsCount==0");
  return _movingTransactionTimeInterval/_movingAverageTransactionsCount; //?
};

//--------------------------------------------------------------------
-(double)_movingAverageIdleTime
{
  NSAssert(_movingAverageTransactionsCount!=0,@"movingAverageTransactionsCount==0");
  return _movingIdleTimeInterval/_movingAverageTransactionsCount;//??
};

//--------------------------------------------------------------------
-(double)_averageCATransactionTime
{
  NSAssert(_movingAverageTransactionsCount!=0,@"movingAverageTransactionsCount==0");
  return _totalCATransactionTimeInterval/_movingAverageTransactionsCount; //??
};

//--------------------------------------------------------------------
-(double)_averageDATransactionTime
{
  NSAssert(_movingAverageTransactionsCount!=0,@"movingAverageTransactionsCount==0");
  return _totalDATransactionTimeInterval/_movingAverageTransactionsCount; //??
};

//--------------------------------------------------------------------
-(double)_averageTransactionTime
{
  NSAssert(_movingAverageTransactionsCount!=0,@"movingAverageTransactionsCount==0");
  return _totalTransactionTimeInterval/_movingAverageTransactionsCount; //?
};

//--------------------------------------------------------------------
-(double)_averageIdleTime
{
  NSAssert(_movingAverageTransactionsCount!=0,@"movingAverageTransactionsCount==0");
  return _totalIdleTimeInterval/_movingAverageTransactionsCount;//??
};

//--------------------------------------------------------------------
-(int)_directActionTransactionsCount
{
  return _directActionTransactionsCount;
};

//--------------------------------------------------------------------
-(int)_componentActionTransactionsCount
{
  return _componentActionTransactionsCount;
};

//--------------------------------------------------------------------
-(int)_transactionsCount
{
  return _transactionsCount;
};


//--------------------------------------------------------------------
-(BOOL)validateLogin:(id)aLogin
          forSession:(id)aSession
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(void)setPassword:(NSString*)aPassword
{
  ASSIGN(_password,aPassword);
};

//--------------------------------------------------------------------
-(BOOL)validateLogin:(id)aLogin
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
+(id)timeIntervalDescription:(double)aTimeInterval
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

@end


