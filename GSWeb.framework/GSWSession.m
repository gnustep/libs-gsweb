/** GSWSession.m - <title>GSWeb: Class GSWSession</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$
   $Id$

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
#include <GNUstepBase/GSCategories.h>

#include <time.h>
#if __linux__
#include <linux/kernel.h>
#include <linux/sys.h>
#include <sys/sysinfo.h>
#endif

//====================================================================
@interface GSWSession (Private)
-(void)_setContextArrayStack:(NSArray*)contextArrayStack;
-(void)_setContextRecords:(NSDictionary*)contextRecords;
-(void)_setComponentState:(NSDictionary*)componentState;
-(void)_setStatistics:(NSArray*)statistics;
-(void)_setFormattedStatistics:(NSString*)formattedStatistics;
-(void)_setContextCounter:(int)contextCounter;
-(void)_setRequestCounter:(int)requestCounter;
@end

//====================================================================
@implementation GSWSession

//--------------------------------------------------------------------
//	init
-(id)init
{
  LOGObjectFnStart();
  if ((self = [super init]))
    {
      NSTimeInterval sessionTimeOut=[GSWApplication sessionTimeOutValue];
      NSDebugMLLog(@"sessions",@"sessionTimeOut=%ld",(long)sessionTimeOut);
      [self setTimeOut:sessionTimeOut];
      [self _initWithSessionID:[[self class]createSessionID]];
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)copyWithZone: (NSZone*)zone
{
  GSWSession* clone = [[isa allocWithZone: zone] init];
  [clone setSessionID:_sessionID];
  [clone setTimeOut:_timeOut];
  [clone _setContextArrayStack:_contextArrayStack];
  [clone _setContextRecords:_contextRecords];
  //_editingContext: no
  [clone setLanguages:_languages];
  [clone _setComponentState:_componentState];
  [clone _setBirthDate:_birthDate];
    //_wasTimedOut: no
  [clone _setStatistics:_statistics];
  [clone _setFormattedStatistics:_formattedStatistics];
  [clone _setContext:_currentContext];
  //_permanentPageCache:
  //_permanentContextIDArray: no
  [clone _setContextCounter:_contextCounter];
  [clone _setRequestCounter:_requestCounter];  
  [clone _setAllowedToViewStatistics:_isAllowedToViewStatistics];
  [clone _setAllowedToViewEvents:_isAllowedToViewEvents];
  //_isTerminating: no
  [clone setDistributionEnabled:_isDistributionEnabled];
  [clone setStoresIDsInURLs:_storesIDsInURLs];
  [clone setStoresIDsInCookies:_storesIDsInCookies];  
  //_hasSessionLockedEditingContext: no
  return clone;
};

//--------------------------------------------------------------------
+(NSString*)createSessionID
{
  // The idea is to have uniq sessionID generated.
  // Parts are:
  // o a modified TimeStamp (modified because we don't want to give 
  //  information on server exact time which can be always a security 
  // problem), so we can remember this sessionID for long time without conflict
  // o a md5 sum of various elements

  // The generated session ID is a sizeof(time_t)+16 bytes string
  
  NSString* sessionID=nil;
  NSMutableData* data=nil;
  NSMutableData* md5Data=nil;
  NSData* md5Sum=nil;
  void* pMd5Data=NULL;
  time_t ts=time(NULL);
  int sizeToFill=64;

  md5Data=[NSMutableData dataWithLength:64];
  pMd5Data=[md5Data mutableBytes];

  // initialize random generator 
  // We xor time stamp with a pointer so 2 sessions created at the same 
  // time won't have the same random generator initializer
  srand(((unsigned long int)ts) ^ ((unsigned long int)md5Data)); 
  
  // We randomize on 60s
  ts=ts+(int)(60*rand()/(RAND_MAX+1.0));
  
  data=[NSMutableData dataWithBytes:&ts
                      length:sizeof(ts)];

  // Now, use some system related chnaging info (
#if __linux__
  {
    struct sysinfo info;
    if ((sysinfo(&info)) == 0)
      {
        unsigned int rnd;

        // >0 test is to ignore not changing elements

        if (sizeToFill>=sizeof(unsigned int) && info.uptime>0)
          {
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            NSDebugMLog(@"UPTIME %ld",(long)info.uptime);
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.uptime)) ^ rnd);
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);
          };

        if (sizeToFill>=sizeof(unsigned int) && info.loads[0]>0)
          {
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            NSDebugMLog(@"loads[0] %ld",(long)info.loads[0]);
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.loads[0] >> 4)) ^ rnd);
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);
          };

        if (sizeToFill>=sizeof(unsigned int) && info.loads[1]>0)
          {
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            NSDebugMLog(@"loads[1] %ld",(long)info.loads[1]);
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.loads[1] >> 4)) ^ rnd);
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);
          };

        if (sizeToFill>=sizeof(unsigned int) && info.loads[2]>0)
          {
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            NSDebugMLog(@"loads[2] %ld",(long)info.loads[2]);
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.loads[2] >> 4)) ^ rnd);
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);
          };

        if (sizeToFill>=sizeof(unsigned int) && info.freeram>0)
          {
            NSDebugMLog(@"freeram %ld",(unsigned long)info.freeram);
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.freeram >> 4)) ^ rnd); // Drop 4 minor bits
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);
          };
        
        if (sizeToFill>=sizeof(unsigned int) && info.sharedram>0)
          {
            NSDebugMLog(@"sharedram %ld",(unsigned long)info.sharedram);
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.sharedram >> 4)) ^ rnd); // Drop 4 minor bits
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);
          };
        
        if (sizeToFill>=sizeof(unsigned int) && info.freeswap>0)
          {
            NSDebugMLog(@"freeswap %ld",(unsigned long)info.freeswap);
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.freeswap >> 4)) ^ rnd); // Drop 4 minor bits
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);
          };
        
        if (sizeToFill>=sizeof(unsigned int) && info.bufferram>0)
          {
            NSDebugMLog(@"bufferram %ld",(unsigned long)info.bufferram);
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.bufferram >> 4)) ^ rnd); // Drop 4 minor bits
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);                            
          };
      };
  };
#endif
  NSDebugMLog(@"sizeToFill %d",sizeToFill);
  while(sizeToFill>0)
    {
      *((unsigned char*)pMd5Data)=(unsigned char)(256.0*rand()/(RAND_MAX+1.0));
      sizeToFill--;
      pMd5Data++;
    };
  //Now do md5 on bytes after sizeof(ts)
  md5Sum=[md5Data md5Digest];
  [data appendData:md5Sum];
  sessionID=[data hexadecimalRepresentation];
  return sessionID;
};
//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder
{
  LOGObjectFnNotImplemented();	//TODOFN
  /*
  [coder_ encodeObject:sessionID];
  [coder_ encodeObject:languages];
  [coder_ encodeValueOfObjCType: @encode(NSTimeInterval) at: &timeOut];
  [coder_ encodeObject:variables];
  [coder_ encodeObject:pageCache];
*/
}

//--------------------------------------------------------------------
-(id)initWithCoder: (NSCoder*)coder
{
  LOGObjectFnNotImplemented();	//TODOFN
  /*
  [coder_ decodeValueOfObjCType: @encode(id) at:&sessionID];
  [coder_ decodeValueOfObjCType: @encode(id) at:&languages];
  [coder_ decodeValueOfObjCType: @encode(NSTimeInterval) at: &timeOut];
  [coder_ decodeValueOfObjCType: @encode(id) at:&variables];
  [coder_ decodeValueOfObjCType: @encode(id) at:&pageCache];
*/
  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogAssertGood(self);
  NSDebugFLog(@"Dealloc GSWSession %p. %@",
	      (void*)self, GSCurrentThread());
  NSDebugFLog0(@"Dealloc GSWSession: sessionID");
  DESTROY(_sessionID);
  NSDebugFLog0(@"Dealloc GSWSession:autoreleasePool ");
  GSWLogMemCF("Destroy NSAutoreleasePool: %p. %@",
	      _autoreleasePool, GSCurrentThread());
  DESTROY(_autoreleasePool);
  NSDebugFLog0(@"Dealloc GSWSession: contextArrayStack");
  DESTROY(_contextArrayStack);
  NSDebugFLog0(@"Dealloc GSWSession: contextRecords");
  DESTROY(_contextRecords);
  NSDebugFLog0(@"Dealloc GSWSession: editingContext");
  DESTROY(_editingContext);
  NSDebugFLog0(@"Dealloc GSWSession: languages");
  DESTROY(_languages);
  NSDebugFLog0(@"Dealloc GSWSession: componentState");
  DESTROY(_componentState);
  NSDebugFLog0(@"Dealloc GSWSession: birthDate");
  DESTROY(_birthDate);
  NSDebugFLog0(@"Dealloc GSWSession: statistics");
  DESTROY(_statistics);
  NSDebugFLog0(@"Dealloc GSWSession: formattedStatistics");
  DESTROY(_formattedStatistics);
  NSDebugFLog0(@"Dealloc GSWSession: currentContext (set to nil)");
  _currentContext=nil;
  NSDebugFLog0(@"Dealloc GSWSession: permanentPageCache");
  DESTROY(_permanentPageCache);
  NSDebugFLog0(@"Dealloc GSWSession: permanentContextIDArray");
  DESTROY(_permanentContextIDArray);
  NSDebugFLog0(@"Dealloc GSWSession Super");
  [super dealloc];
  NSDebugFLog0(@"End Dealloc GSWSession");
}

//--------------------------------------------------------------------
-(NSString*)description
{
  NSString* dscr=nil;
  GSWLogAssertGood(self);
  /*
  NSDebugMLLog(@"sessions",@"selfCount=%u",(unsigned int)[self retainCount]);
  NSDebugMLLog(@"sessions",@"sessionIDCount=%u",(unsigned int)[sessionID retainCount]);
  */
  dscr=[NSString stringWithFormat:@"<%s %p>",
				 object_get_class_name(self),
				 (void*)self];
  /*
  dscr=[NSString stringWithFormat:@"<%s %p - sessionID=%@ autoreleasePool=%p timeOut=%f contextArrayStack=%@",
				 object_get_class_name(self),
				 (void*)self,
				 sessionID,
				 (void*)autoreleasePool,
				 timeOut,
				 contextArrayStack];
  dscr=[dscr stringByAppendingFormat:@" contextRecords=%@ editingContext=%p languages=%@ componentState=%@ birthDate=%@",
			 contextRecords,
			 (void*)editingContext,
			 languages,
			 componentState,
			 birthDate];
  dscr=[dscr stringByAppendingFormat:@" statistics=%@ formattedStatistics=%@ currentContext=%p permanentPageCache=%@",
				   statistics,
				   formattedStatistics,
				   (void*)currentContext,
				   permanentPageCache];
  dscr=[dscr stringByAppendingFormat:@" permanentContextIDArray=%@ contextCounter=%d requestCounter=%d isAllowedToViewStatistics=%s", 
			 permanentContextIDArray,
			 contextCounter,
			 requestCounter,
			 isAllowedToViewStatistics ? "YES" : "NO"];

  dscr=[dscr stringByAppendingFormat:@" isTerminating=%s isDistributionEnabled=%s storesIDsInCookies=%s storesIDsInURLs=%s hasSessionLockedEditingContext=%s>",
				   isTerminating ? "YES" : "NO",
				   isDistributionEnabled ? "YES" : "NO",
				   storesIDsInCookies ? "YES" : "NO",
				   storesIDsInURLs ? "YES" : "NO",
				   hasSessionLockedEditingContext ? "YES" : "NO"];
  */
  return dscr;
};

//--------------------------------------------------------------------
//	sessionID

-(NSString*)sessionID
{
  return _sessionID;
};

//--------------------------------------------------------------------
//	sessionID

-(void)setSessionID:(NSString*)sessionID
{
  ASSIGN(_sessionID,sessionID);
};

//--------------------------------------------------------------------
-(NSString*)domainForIDCookies
{
  //OK
  NSString* domain=nil;
  GSWContext* context=nil;
  GSWRequest* request=nil;
  NSString* applicationName=nil;
  NSString* adaptorPrefix=nil;
  LOGObjectFnStart();
  [[GSWApplication application]lock];
  context=[self context];
  request=[context request];
  applicationName=[request applicationName];
  NSDebugMLLog(@"sessions",@"applicationName=%@",applicationName);
  adaptorPrefix=[request adaptorPrefix];
  NSDebugMLLog(@"sessions",@"adaptorPrefix=%@",adaptorPrefix);
  [[GSWApplication application]unlock];
  domain=[NSString stringWithFormat:@"%@/%@.%@",
                   adaptorPrefix,
                   applicationName,
                   GSWApplicationSuffix[GSWebNamingConv]];
  NSDebugMLLog(@"sessions",@"domain=%@",domain);
  LOGObjectFnStop();
  return domain;
};

//--------------------------------------------------------------------
-(BOOL)storesIDsInURLs
{
  return _storesIDsInURLs;
};

//--------------------------------------------------------------------
-(void)setStoresIDsInURLs:(BOOL)flag
{
  LOGObjectFnStart();

  if (flag!=_storesIDsInURLs)
    _storesIDsInURLs=flag;

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSDate*)expirationDateForIDCookies
{
  NSDate* expirationDateForIDCookies=nil;
  NSDebugMLLog(@"sessions",@"timeOut=%f",(double)_timeOut);
  expirationDateForIDCookies=[NSDate dateWithTimeIntervalSinceNow:_timeOut];
  NSDebugMLLog(@"sessions",@"expirationDateForIDCookies=%@ (HTML: %@)",
               expirationDateForIDCookies,
               [expirationDateForIDCookies htmlDescription]);
  return expirationDateForIDCookies;
};

//--------------------------------------------------------------------
-(BOOL)storesIDsInCookies
{
  return _storesIDsInCookies;
};

//--------------------------------------------------------------------
-(void)setStoresIDsInCookies:(BOOL)flag
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"newflag=%d",(int)flag);
  if (flag!=_storesIDsInCookies)
    {
      _storesIDsInCookies=flag;
      [_currentContext _synchronizeForDistribution];
    };      
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** Returns NO if URLs contains application number so requests are 
	directed to the specific application instance.
    Resturns YES if  URLs doesn't contain application number so requests 
    	can be directed to any instance (load balancing)
    Default value is NO
**/
-(BOOL)isDistributionEnabled
{
  return _isDistributionEnabled;
};

//--------------------------------------------------------------------
/** Enables or disables application instance number in URLs.
    If flag is NO, URLs contains application number so requests are directed 
	to the specific application instance.
    If flag is YES, URLs doesn't contain application number so requests can 
	be directed to any instance (load balancing)
**/
-(void)setDistributionEnabled:(BOOL)flag
{
  LOGObjectFnStart();
  if (flag!=_isDistributionEnabled)
    {
      _isDistributionEnabled=flag;
      [_currentContext _synchronizeForDistribution];
    };
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWSession (Private)

//--------------------------------------------------------------------
-(void)_setContextArrayStack:(NSArray*)contextArrayStack
{
  DESTROY(_contextArrayStack);
  _contextArrayStack=[contextArrayStack mutableCopy];
}

//--------------------------------------------------------------------
-(void)_setContextRecords:(NSDictionary*)contextRecords
{
  DESTROY(_contextRecords);
  _contextRecords=[contextRecords mutableCopy];
}

//--------------------------------------------------------------------
-(void)_setComponentState:(NSDictionary*)componentState
{
  DESTROY(_componentState);
  _componentState=[componentState mutableCopy];
}

//--------------------------------------------------------------------
-(void)_setStatistics:(NSArray*)statistics
{
  DESTROY(_statistics);
  _statistics=[statistics mutableCopy];
}

//--------------------------------------------------------------------
-(void)_setFormattedStatistics:(NSString*)formattedStatistics
{
  DESTROY(_formattedStatistics);
  _formattedStatistics=[formattedStatistics mutableCopy];
}

//--------------------------------------------------------------------
-(void)_setContextCounter:(int)contextCounter
{
  _contextCounter = contextCounter;
}

//--------------------------------------------------------------------
-(void)_setRequestCounter:(int)requestCounter
{
  _requestCounter = requestCounter;
}

@end

//====================================================================
@implementation GSWSession (GSWSessionA)

//--------------------------------------------------------------------
-(id)_initWithSessionID:(NSString*)aSessionID
{
  //OK
  GSWApplication* application=nil;
  GSWStatisticsStore* statisticsStore=nil;
  LOGObjectFnStart();
  statisticsStore=[GSWApp statisticsStore];
  [statisticsStore _applicationCreatedSession:self];

  ASSIGNCOPY(_sessionID,aSessionID);
  NSDebugMLLog(@"sessions",@"sessionID=%u",aSessionID);
  NSDebugMLLog(@"sessions",@"_sessionID=%u",_sessionID);
  if (_sessionID)
    {
      NSDebugMLLog(@"sessions",@"sessionIDCount=%u",[_sessionID retainCount]);
    };
  application=[GSWApplication application];
  //applic statisticsStore
  //applic _activeSessionsCount
  [self _setBirthDate:[NSDate date]];
  ASSIGN(_statistics,[NSMutableArray array]);
  _storesIDsInURLs=YES;
  [application _finishInitializingSession:self];
  LOGObjectFnStop();
  return self;
};

@end

//====================================================================

@implementation GSWSession (GSWTermination)

//--------------------------------------------------------------------
//	isTerminating

//--------------------------------------------------------------------
-(BOOL)isTerminating 
{
  return _isTerminating;
};

//--------------------------------------------------------------------
//	terminate
-(void)terminate 
{
  LOGObjectFnStart();

  if (!_isTerminating) // don't do it multiple times !
    {
      GSWApplication* application=[GSWApplication application];
      NSString* sessionID=[self sessionID];

      _isTerminating=YES;

      [[NSNotificationCenter defaultCenter] 
        postNotificationName:GSWNotification__SessionDidTimeOutNotification[GSWebNamingConv]
        object:sessionID];

      [application _discountTerminatedSession];
      [[application statisticsStore] _sessionTerminating:self];

      if (_editingContext)
        {
          if (_hasSessionLockedEditingContext)
            {
              [_editingContext unlock];
              _hasSessionLockedEditingContext = NO;
            };
          DESTROY(_editingContext);
        };
      /*
        [self setTimeOut:(NSTimeInterval) 1];	// forces to call removeSessionWithID in GSWServerSessionStore to dealloc it
        //TODO: VERIFY
        [self setTimeOut:(NSTimeInterval) 1];	// forces to call removeSessionWithID in GSWServerSessionStore to dealloc it
      */
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_terminateByTimeout
{
  _wasTimedOut = YES;
  [self terminate];
}

// componentDefinition _notifyObserversForDyingComponent:Main component
//....

//--------------------------------------------------------------------
//	timeOut

-(NSTimeInterval)timeOut
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"timeOut=%ld",(long)_timeOut);
  LOGObjectFnStop();
  return _timeOut;
};

//--------------------------------------------------------------------
//	setTimeOut:

-(void)setTimeOut:(NSTimeInterval)timeOut
{
  NSDebugMLLog(@"sessions",@"timeOut=%ld",(long)timeOut);
  if (timeOut==0)
    _timeOut=[[NSDate distantFuture]timeIntervalSinceDate:_birthDate];
  else
    _timeOut=timeOut;  
};

@end

//====================================================================
@implementation GSWSession (GSWSessionDebugging)

//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [GSWApp debugWithFormat:aFormat
          arguments:ap];
  va_end(ap);
};

@end

//====================================================================
@implementation GSWSession (GSWSessionD)

//--------------------------------------------------------------------
-(void)_debugWithString:(NSString*)string
{
  [GSWApp debugWithString:string];
};

@end

//====================================================================

@implementation GSWSession (GSWPageManagement)

//--------------------------------------------------------------------
-(void)savePage:(GSWComponent*)page
{
  //OK
  GSWContext* context=nil;
  BOOL pageReplaced=NO;
  BOOL pageChanged=NO;
  LOGObjectFnStart();

  NSAssert(page,@"No Page");

  context=[self context];
  pageReplaced=[context _pageReplaced];

  if (!pageReplaced)
    pageChanged=[context _pageChanged];

  [self _savePage:page
        forChange:pageChanged || pageReplaced]; //??

/*
  NSData* data=[NSArchiver archivedDataWithRootObject:page];
  NSDebugMLLog(@"sessions",@"savePage data=%@",data);
  [pageCache setObject:data
  forKey:[[self context] contextID]//TODO
			 withDuration:60*60];//TODO
*/
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWComponent*)restorePageForContextID:(NSString*)aContextID
{
  //OK
  GSWComponent* page=nil;
  NSArray* contextArray=nil;
  GSWTransactionRecord* transactionRecord=nil;
  LOGObjectFnStart();
  GSWLogAssertGood(self);
  NSAssert(aContextID,@"No contextID");
  NSAssert([aContextID length]>0,@"contextID empty");
  NSDebugMLLog(@"sessions",@"aContextID=%@",aContextID);

  transactionRecord=[_contextRecords objectForKey:aContextID];
  NSDebugMLLog(@"sessions",@"transactionRecord=%@",transactionRecord);

  if (transactionRecord)
    {
      NSDebugMLLog(@"sessions",@"transactionRecord2=%@",transactionRecord);
      page=[transactionRecord responsePage];
      GSWLogAssertGood(page);
    };
  
  if (page) // will put it at the end of the stack
    {
      unsigned int stackIndex=0;
      unsigned int contextArrayIndex=0;

      NSDebugMLLog(@"sessions",@"transactionRecord3=%@",transactionRecord);
      NSDebugMLLog(@"sessions",@"page 1=%@",page);

      contextArray=[self _contextArrayForContextID:aContextID
                         stackIndex:&stackIndex
                         contextArrayIndex:&contextArrayIndex];

      NSDebugMLLog(@"sessions",@"page 2=%@",page);
      if (contextArray)
        {
          if (stackIndex!=([_contextArrayStack count]-1))
            {
              //NSLog(@"AA stackIndex=%d",stackIndex);
              //NSLog(@"AA _contextArrayStack class=%@",[_contextArrayStack class]);
              //NSLog(@"AA [_contextArrayStack count]=%d",[_contextArrayStack count]);
              [_contextArrayStack addObject:contextArray]; //add before removing to avoid release
              [_contextArrayStack removeObjectAtIndex:stackIndex];
            };
        };
    };

  if ([_permanentPageCache objectForKey:aContextID])
      page=[self _permanentPageWithContextID:aContextID];

  NSAssert(self,@"self");
  NSDebugMLLog(@"sessions",@"_currentContext=%@",_currentContext);
  NSDebugMLLog(@"sessions",@"page 3=%@",page);
  [page awakeInContext:_currentContext];
  NSDebugMLLog(@"sessions",@"page 4=%@",page);
  LOGObjectFnStop();
  return page;
};

//--------------------------------------------------------------------
//NDFN
-(unsigned int)permanentPageCacheSize
{
  return [GSWApp permanentPageCacheSize];
};

//--------------------------------------------------------------------
-(void)savePageInPermanentCache:(GSWComponent*)page
{
  GSWContext* context=nil;
  NSMutableDictionary* permanentPageCache=nil;
  unsigned int permanentPageCacheSize=0;
  NSString* contextID=nil;
  LOGObjectFnStart();
  context=[self context];
  permanentPageCache=[self _permanentPageCache];
  permanentPageCacheSize=[self permanentPageCacheSize];

  // first we'll remove excessive cached pages.
  while([_permanentContextIDArray count]>0 && [_permanentContextIDArray count]>=permanentPageCacheSize)
    {
      id deletePage=nil;
      NSString* deleteContextID=nil;
      [GSWApplication statusLogWithFormat:@"Deleting permanent cached Page"];
      deleteContextID=[_permanentContextIDArray objectAtIndex:0];
      GSWLogAssertGood(deleteContextID);
      RETAIN(deleteContextID); // We'll remove it from array
      [GSWApplication statusLogWithFormat:@"permanentContextIDArray=%@",
                      _permanentContextIDArray];
      [GSWApplication statusLogWithFormat:@"contextID=%@",deleteContextID];
      NSDebugMLLog(@"sessions",@"deleteContextID=%@",deleteContextID);
      NSDebugMLLog(@"sessions",@"[permanentContextIDArray objectAtIndex:0]=%@",
                   [_permanentContextIDArray objectAtIndex:0]);
      NSDebugMLLog(@"sessions",@"[permanentContextIDArray objectAtIndex:0] retainCount=%d",
                   (int)[[_permanentContextIDArray objectAtIndex:0] retainCount]);
      NSDebugMLLog(@"sessions",@"SESSION REMOVE: %p",[_permanentContextIDArray objectAtIndex:0]);
      [_permanentContextIDArray removeObjectAtIndex:0];
      deletePage=[_contextRecords objectForKey:deleteContextID];
      GSWLogAssertGood(deletePage);
      [GSWApplication statusLogWithFormat:@"delete page of class=%@",
                      [deletePage class]];
      NSDebugMLLog(@"sessions",@"SESSION REMOVE: %p",[permanentPageCache objectForKey:deleteContextID]);
      [permanentPageCache removeObjectForKey:deleteContextID];
      RELEASE(deleteContextID);
    };
  contextID=[context contextID];
  NSAssert(contextID,@"No contextID");

  if ([_permanentContextIDArray containsObject:contextID])
    {
      LOGSeriousError(@"page of class %@ contextID %@ already in permanent cache stack",
                      [page class],
                      contextID);
      NSDebugMLLog(@"sessions",@"SESSION REMOVE: %p",contextID);
      [_permanentContextIDArray removeObject:contextID];
      if (![permanentPageCache objectForKey:contextID])
        {
          LOGSeriousError0(@"but not present in cache");
        };
    }
  else if ([permanentPageCache objectForKey:contextID])
    {
      LOGSeriousError(@"page of class %@ contextID %@ in permanent cache but not in stack",
                      [page class],
                      contextID);
    };

  NSDebugMLLog(@"sessions",@"SESSION REPLACE: %p",[permanentPageCache objectForKey:contextID]);
  [permanentPageCache setObject:page
                      forKey:contextID];
  [_permanentContextIDArray addObject:contextID];
  /*
  {
    int i=0;
    id anObject=nil;
    id anotherContextID=nil;
    for(i=0;i<[_permanentContextIDArray count];i++)
      {
        anotherContextID=[_permanentContextIDArray objectAtIndex:i];
        anObject=[permanentPageCache objectForKey:anotherContextID];
        [GSWApplication statusLogWithFormat:@"%d contextID=%@ page class=%@",i,anotherContextID,[anObject class]];
      };
  };
  */
  if ([_permanentContextIDArray count]!=[permanentPageCache count])
    {
      LOGSeriousError(@"[permanentContextIDArray count] %d != [permanentPageCache count] %d",
                      (int)[_permanentContextIDArray count],
                      (int)[permanentPageCache count]);
    };
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWSession (GSWSessionF)

//--------------------------------------------------------------------
-(void)clearCookieFromResponse:(GSWResponse*)aResponse
{
  NSString* domainForIDCookies=nil;
  NSString* sessionID=nil;
  NSDate* anExpireDate=nil;
  LOGObjectFnStart();
  domainForIDCookies=[self domainForIDCookies];
  sessionID=[self sessionID];
  anExpireDate=[NSDate date]; // Expire now
  [aResponse addCookie:[GSWCookie cookieWithName:GSWKey_SessionID[GSWebNamingConv]
                                  value:sessionID
                                  path:domainForIDCookies
                                  domain:nil
                                  expires:anExpireDate
                                  isSecure:NO]];
  [aResponse addCookie:[GSWCookie cookieWithName:GSWKey_InstanceID[GSWebNamingConv]
                                  value:@"-1"
                                  path:domainForIDCookies
                                  domain:nil
                                  expires:anExpireDate
                                  isSecure:NO]];

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendCookieToResponse:(GSWResponse*)aResponse
{
  LOGObjectFnStart();
  if ([self storesIDsInCookies])
    {
      NSString* domainForIDCookies=[self domainForIDCookies];
      NSString* sessionID=nil;
      int instance=-1;
      NSDate* anExpireDate=nil;
      if ([self isTerminating])
        {
          sessionID=@"";
          anExpireDate=[NSDate date]; //expire now !
        }
      else
        {
          sessionID=[self sessionID];
          anExpireDate=[self expirationDateForIDCookies];
        };

      // SessionID cookie
      [aResponse addCookie:[GSWCookie cookieWithName:GSWKey_SessionID[GSWebNamingConv]
                                      value:sessionID
                                      path:domainForIDCookies
                                      domain:nil
                                      expires:anExpireDate
                                      isSecure:NO]];

      // Instance Cookie
      // No Instance if distribution enabled or this session is terminating
      if ([self isDistributionEnabled] || [self isTerminating])
        {
          instance=-1;
          anExpireDate=[NSDate date]; //expire now !
        }
      else
        {
          GSWRequest* request = [_currentContext request];
          if (request)
            instance=[request applicationNumber]; // use the request instance number
          else
          instance=-1;
        };
      [aResponse addCookie:[GSWCookie cookieWithName:GSWKey_InstanceID[GSWebNamingConv]
                                      value:GSWIntToNSString(instance)
                                      path:domainForIDCookies
                                      domain:nil
                                      expires:anExpireDate
                                      isSecure:NO]];

    };
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWSession (GSWSessionG)
extern id gcObjectsToBeVisited;
//--------------------------------------------------------------------
-(void)_releaseAutoreleasePool
{
  //OK
  LOGObjectFnStart();
//  printf("session %p _releaseAutoreleasePool START\n",self);
//  fprintf(stderr,"session %p _releaseAutoreleasePool START\n",self);
//TODO-NOW remettre  [GarbageCollector collectGarbages];
//  printf("session %p _releaseAutoreleasePool after garbage",self);
//  fprintf(stderr,"session %p _releaseAutoreleasePool after garbage\n",self);
  DESTROY(_autoreleasePool);
//  printf("session %p _releaseAutoreleasePool STOP\n",self);
//  fprintf(stderr,"session %p _releaseAutoreleasePool STOP\n",self);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_createAutoreleasePool
{
  LOGObjectFnStart();
  if (!_autoreleasePool)
    {
      _autoreleasePool=[NSAutoreleasePool new];
      GSWLogMemCF("New NSAutoreleasePool: %p",_autoreleasePool);
    }
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWComponent*)_permanentPageWithContextID:(NSString*)aContextID
{
  GSWComponent* page=nil;
  LOGObjectFnStart();
  page=[_permanentPageCache objectForKey:aContextID];
  LOGObjectFnStop();
  return page;
};

//--------------------------------------------------------------------
-(NSMutableDictionary*)_permanentPageCache
{
  LOGObjectFnStart();
  if (!_permanentPageCache)
    _permanentPageCache=[NSMutableDictionary new];
  if (!_permanentContextIDArray)
    _permanentContextIDArray=[NSMutableArray new];
  LOGObjectFnStop();
  return _permanentPageCache;
};

//--------------------------------------------------------------------
-(NSString*)_contextIDMatchingContextID:(NSString*)aContextID
                        requestSenderID:(NSString*)aSenderID
{
  NSAssert(NO,@"Deprecated. use _contextIDMatchingIDsInContext:");
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)_contextIDMatchingIDsInContext:(GSWContext*)aContext
{
  NSString* contextID=nil;
  NSString* requestContextID=nil;

  LOGObjectFnStart();
  NSDebugMLog(@"aContext=%@",aContext);
  requestContextID=[aContext _requestContextID];
  NSDebugMLog(@"requestContextID=%@",requestContextID);
  if (_contextRecords &&  requestContextID)
    {
      NSArray* contextIDs = [_contextRecords allKeys];
      int count = [contextIDs count];
      int i=0;
      for(i=0;!contextID && i<count;i++)
        {
          NSString* aContextID=[contextIDs objectAtIndex:i];
          GSWTransactionRecord* aTransactionRecord=[_contextRecords objectForKey:aContextID];
          if ([aTransactionRecord isMatchingIDsInContext:aContext])
            contextID=aContextID;
        };      
    }

  LOGObjectFnStop();

  return contextID;
}

//--------------------------------------------------------------------
-(void)_rearrangeContextArrayStackForContextID:(NSString*)contextID
{
  LOGObjectFnStart();

  if (_contextRecords)
    {
      unsigned int stackIndex=0;
      unsigned int contextArrayIndex=0;
      NSMutableArray* contextArray = [self _contextArrayForContextID:contextID
                                           stackIndex:&stackIndex
                                           contextArrayIndex:&contextArrayIndex];
      int stackCount=[_contextArrayStack count];
      if (contextArray  // Found
          && (stackIndex!=stackCount-1 // not already the last one
              || contextArrayIndex!=[contextArray count]-1)
          )
        {
          // Put it at the stack end
          [_contextArrayStack addObject:contextArray]; //add before removing to avoid release
          //NSLog(@"AA _contextArrayStack class=%@",[_contextArrayStack class]);
          //NSLog(@"BB stackIndex=%d",stackIndex);
          //NSLog(@"BB [_contextArrayStack count]=%d",[_contextArrayStack count]);
          [_contextArrayStack removeObjectAtIndex:stackIndex];              
        };
    }
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSMutableArray*)_contextArrayForContextID:(NSString*)aContextID
                                 stackIndex:(unsigned int*)pStackIndex
                          contextArrayIndex:(unsigned int*)pContextArrayIndex
{
  NSMutableArray* contextArray=nil;
  int stackCount=[_contextArrayStack count];
  unsigned int i=0;
  for(i=0;!contextArray && i<stackCount;i++)
    {
      NSMutableArray* aContextArray=[_contextArrayStack objectAtIndex:i];
      unsigned int contextArrayIndex=[aContextArray indexOfObject:aContextID];
      if (contextArrayIndex!=NSNotFound)
        {
          contextArray=aContextArray;
          if (pStackIndex)
            *pStackIndex=i;
          if (pContextArrayIndex)
            *pContextArrayIndex=contextArrayIndex;
        };
    };
  if (!contextArray)
    {
      if (pStackIndex)
        *pStackIndex=NSNotFound;
      if (pContextArrayIndex)
        *pContextArrayIndex=NSNotFound;
    };
  return contextArray;
};

//--------------------------------------------------------------------
-(void)_replacePage:(GSWComponent*)page
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//NDFN
-(unsigned int)pageCacheSize
{
  return [GSWApp pageCacheSize];
};

//--------------------------------------------------------------------
-(void)_savePage:(GSWComponent*)page
       forChange:(BOOL)forChange
{
  //OK
  GSWResponse* response=nil;
  GSWTransactionRecord* transactionRecord=nil;
  int pageCacheSize=0;
  NSString* contextID=nil;
  int pagesCount=0;
  int contextsCount=0;
  NSMutableArray* contextArray=nil;
  BOOL createNewContextArrayFlag=NO;
  LOGObjectFnStart();

  NSAssert(page,@"No Page");

  // Retrieve Page contextID
  contextID=[[page context]contextID];
  NSDebugMLLog(@"sessions",@"_contextID=%@",contextID);
  NSAssert(contextID,@"No contextID");

  if ([_contextArrayStack count]>0) // && _forChange!=NO ??
    {
      [self _rearrangeContextArrayStackForContextID:contextID];
      contextArray=[_contextArrayStack lastObject]; //??
    };

  if(forChange || !contextArray)
    createNewContextArrayFlag=YES;
  else if ([contextArray count]>0)
    {
      NSString* lastContextID=[contextArray lastObject];
      GSWTransactionRecord* transRecord = (GSWTransactionRecord*)[_contextRecords objectForKey:lastContextID];
      GSWComponent* transRecordResponsePage = [transRecord responsePage];
      createNewContextArrayFlag = (page!=transRecordResponsePage);
    }
  
  if (createNewContextArrayFlag)
    {
      contextArray = [NSMutableArray array];
      [_contextArrayStack addObject:contextArray];
    }

  // Create contextArrayStack and contextRecords if not already created
  if (!_contextArrayStack)
    _contextArrayStack=[NSMutableArray new];

  if (!_contextRecords)
    _contextRecords=[NSMutableDictionary new];

  NSDebugMLLog(@"sessions",@"contextArrayStack=%@",_contextArrayStack);
  NSDebugMLLog(@"sessions",@"contextRecords=%@",_contextRecords);

  // Get the response
  response=[_currentContext response];
  NSDebugMLLog(@"sessions",@"response=%@",response);

  // Create a new transaction record
  if (response && [response _isClientCachingDisabled])
    transactionRecord = [GSWTransactionRecord transactionRecordWithResponsePage:page
                                              context:_currentContext];
  else
    transactionRecord = [GSWTransactionRecord transactionRecordWithResponsePage:page
                                              context:NULL];

  NSDebugMLLog(@"sessions",@"transactionRecord=%@",transactionRecord);

  // Add it to contextRecords...
  [_contextRecords setObject:transactionRecord
                   forKey:contextID];
  [contextArray addObject:contextID];

  // Retrieve the pageCacheSize
  pageCacheSize=[self pageCacheSize];
  NSDebugMLLog(@"sessions",@"pageCacheSize=%d",pageCacheSize);
  NSAssert1(pageCacheSize>=0,@"bad pageCacheSize %d",pageCacheSize);

  // Remove contextArray pages if page number greater than page cache size
  pagesCount=[contextArray count];
  while(pagesCount>=pageCacheSize)
    {
      NSString* deleteContextID=[contextArray objectAtIndex:0];

      RETAIN(deleteContextID);
      GSWLogAssertGood(deleteContextID);

      [GSWApplication statusLogWithFormat:@"Deleting cached Page"];

      //NSLog(@"DD contextArray class=%@",[contextArray class]);
      //NSLog(@"CC contextArray count=%d",[contextArray count]);
      [contextArray removeObjectAtIndex:0];
      [_contextRecords removeObjectForKey:deleteContextID];
      RELEASE(deleteContextID);
      pagesCount--;
    };

  // If empty, remove it
  //NSLog(@"DD _contextArrayStack class=%@",[_contextArrayStack class]);
  //NSLog(@"DD _contextArrayStack count=%d",[_contextArrayStack count]);
  if(pagesCount==0)
    [_contextArrayStack removeLastObject];

  contextsCount=[_contextArrayStack count];
  //NSLog(@"zz1 contextsCount=%d",contextsCount);
  //NSLog(@"zz1 pageCacheSize=%d",pageCacheSize);
  while(contextsCount>=pageCacheSize)
    {
      NSMutableArray* aContextArray=[_contextArrayStack objectAtIndex:0];
      //NSLog(@"zz2 contextsCount=%d",contextsCount);
      pagesCount=[aContextArray count];
      while(pagesCount)
        {
          NSString* deleteContextID=[aContextArray objectAtIndex:0];
          RETAIN(deleteContextID);
          GSWLogAssertGood(deleteContextID);

          [GSWApplication statusLogWithFormat:@"Deleting cached Page"];

          //NSLog(@"EE aContextArray class=%@",[aContextArray class]);
          //NSLog(@"EE aContextArray count=%d",[aContextArray count]);
          [aContextArray removeObjectAtIndex:0];
          [_contextRecords removeObjectForKey:deleteContextID];
          RELEASE(deleteContextID);
          pagesCount--;
        };
      contextsCount--;
    };
  //NSLog(@"FF _contextArrayStack class=%@",[_contextArrayStack class]);
  //NSLog(@"FF _contextArrayStack count=%d",[_contextArrayStack count]);

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_saveCurrentPage
{
  //OK
  LOGObjectFnStart();
  if (_currentContext)
    {
      GSWComponent* component=[_currentContext _pageComponent];
      if ([component _isPage])
        {
          GSWComponent* testComponent=[self _permanentPageWithContextID:[_currentContext contextID]];
          if (testComponent!=component)
            {
              testComponent=[self _permanentPageWithContextID:[_currentContext _requestContextID]];
              if (testComponent && [self permanentPageCacheSize]>0)
                {
                  [self savePageInPermanentCache:component];
                }
              else
                {
                  if ([self pageCacheSize]>0)
                    [self savePage:component];
                };
            };
        };
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(int)_requestCounter
{
  //OK
  return _requestCounter;
};

//--------------------------------------------------------------------
-(void)_contextDidIncrementContextID
{
  _contextCounter++;
};

//--------------------------------------------------------------------
-(int)_contextCounter
{
  //OK
  return _contextCounter;
};

//--------------------------------------------------------------------
-(void)_setContext:(GSWContext*)aContext
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"aContext=%p",(void*)aContext);
  if (aContext!=_currentContext)
    _currentContext=aContext;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)sleepInContext:(GSWContext*)aContext
{
  //OK
  LOGObjectFnStart();
  [self sleep];
  if (_hasSessionLockedEditingContext)
    {
      [_editingContext unlock];
      _hasSessionLockedEditingContext = NO;
    }
  [self _setContext:nil];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)awakeInContext:(GSWContext*)aContext
{
  LOGObjectFnStart();
  [self _setContext:aContext];
  NSDebugMLLog(@"sessions",@"contextCounter=%i",_contextCounter);
  if (aContext)
    {
      if ([[self class] __counterIncrementingEnabledFlag]) //??
        {
          _contextCounter++;
          _requestCounter++;
        };
    };
  NSDebugMLLog(@"sessions",@"contextCounter=%i",_contextCounter);
  if (_editingContext 
      && !_hasSessionLockedEditingContext
      && [GSWApplication _lockDefaultEditingContext])
    {
      [_editingContext lock];
      _hasSessionLockedEditingContext=YES;
    };
  [self awake];
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWSession (GSWLocalization)

//--------------------------------------------------------------------
-(void)setLanguages:(NSArray*)someLanguages
{
  LOGObjectFnStart();

  NSDebugMLLog(@"sessions",@"someLanguages=%@",someLanguages);

  if (!someLanguages)
    {
      LOGError0(@"No languages");
    };
  ASSIGN(_languages,someLanguages);

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** GSWeb specific
Insert language language at the begining of session languages array 
**/
-(void)insertLanguage:(NSString*)language
{
  NSArray* languages=nil;
  LOGObjectFnStart();
  if ([language length]>0)
    {
      languages=[self languages];
      if ([languages count]>0)
        {
          if (![language isEqualToString:[languages objectAtIndex:0]])
            {
              NSMutableArray* mutableLanguages=[[languages mutableCopy]autorelease];
              [mutableLanguages removeObject:language];//Remove language if it exists in languages
              [mutableLanguages insertObject:language
                                atIndex:0];
              [self setLanguages:mutableLanguages];
            };
        }
      else
        [self setLanguages:[NSArray arrayWithObject:language]];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** GSWeb specific
Add language language at the end of session languages array if language 
is not present
**/
-(void)addLanguage:(NSString*)language
{
  NSArray* languages=nil;
  LOGObjectFnStart();
  if ([language length]>0)
    {
      languages=[self languages];
      if ([languages count]>0)
        {
          if (![languages containsObject:language])
            [self setLanguages:[languages arrayByAddingObject:language]];
        }
      else
        [self setLanguages:[NSArray arrayWithObject:language]];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** GSWeb specific
Returns first element of languages or nil if languages is empty
**/
-(NSString*)firstLanguage
{
  NSArray* languages=nil;
  NSString* firstLanguage=nil;
  LOGObjectFnStart();

  languages=[self languages];
  if ([languages count]>0)
    firstLanguage=[languages objectAtIndex:0];

  LOGObjectFnStop();

  return firstLanguage;
};

//--------------------------------------------------------------------
-(NSArray*)languages
{
  LOGObjectFnStart();

  NSDebugMLLog(@"sessions",@"_languages=%@",_languages);

  if (!_languages)
    {
      GSWContext* aContext=[self context];
      GSWRequest* request=[aContext request];
      NSArray* languages=[request browserLanguages];
      [self setLanguages:languages];
      NSDebugMLLog(@"sessions",@"_languages=%@",_languages);
    };

  LOGObjectFnStop();

  return _languages;
};

//--------------------------------------------------------------------
-(NSArray*)_languages
{
  LOGObjectFnStart();
  LOGObjectFnStop();

  return _languages;
};

@end

//====================================================================
@implementation GSWSession (GSWComponentStateManagement)

//--------------------------------------------------------------------
//	objectForKey:
-(id)objectForKey:(NSString*)key
{
  id object=nil;
  LOGObjectFnStart();
  object=[_componentState objectForKey:key];
  NSDebugMLLog(@"sessions",@"key=%@ object=%@",key,object);
  LOGObjectFnStop();
  return object;
};

//--------------------------------------------------------------------
//	setObject:forKey:
-(void)setObject:(id)object
          forKey:(NSString*)key
{
  LOGObjectFnStart();
  if (!_componentState)
    _componentState=[NSMutableDictionary new];
  NSDebugMLLog(@"sessions",@"key=%@ object=%@",key,object);
  [_componentState setObject:object
                   forKey:key];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)removeObjectForKey:(NSString*)key
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"key=%@",key);
  [_componentState removeObjectForKey:key];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(NSMutableDictionary*)componentState
{
  return _componentState;
};

@end

//====================================================================
@implementation GSWSession (GSWEnterpriseObjects)

//--------------------------------------------------------------------
-(EOEditingContext*)defaultEditingContext
{
#if HAVE_GDL2
  if(!_editingContext)
    {
      ASSIGN(_editingContext,[[[EOEditingContext alloc] init] autorelease]);
      [_editingContext setLevelsOfUndo:[GSWApplication defaultUndoStackLimit]];
      if ([GSWApplication _lockDefaultEditingContext])
        {
          [_editingContext lock];
          _hasSessionLockedEditingContext=YES;
        };
    }
#endif

  return _editingContext;
};

//--------------------------------------------------------------------
-(void)setDefaultEditingContext:(EOEditingContext*)editingContext
{
  if (_editingContext)
    {
      // We can't set the editing context if one has already been created
      [NSException raise:NSInvalidArgumentException 
                   format:@"%s Can't set a defautEditingContext when one already exists",
                   object_get_class_name(self)];
    }
  else
    {
      ASSIGN(_editingContext,editingContext);
      if ([GSWApplication _lockDefaultEditingContext])
        {
          [_editingContext lock];
          _hasSessionLockedEditingContext=YES;
        };
    };
};

@end

//====================================================================
@implementation GSWSession (GSWRequestHandling)

//--------------------------------------------------------------------
-(GSWContext*)context
{
  return _currentContext;
};

//--------------------------------------------------------------------
//	awake
-(void)awake 
{
  //ok
  //Does Nothing
};

//--------------------------------------------------------------------
//	sleep

-(void)sleep 
{
  //Does Nothing
};

//--------------------------------------------------------------------
//	takeValuesFromRequest:inContext:
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext 
{
  GSWElement* pageElement=nil;
  GSWComponent* pageComponent=nil;
  LOGObjectFnStart();
  pageElement=[aContext _pageElement];
  pageComponent=[aContext _pageComponent];
#ifndef NDEBUG
  [aContext addDocStructureStep:@"Take Values From Request"];
#endif
  [aContext _setCurrentComponent:pageComponent];
  [pageElement takeValuesFromRequest:aRequest
               inContext:aContext];
  [aContext _setCurrentComponent:nil];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	invokeActionForRequest:inContext:
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext 
{
  GSWElement* element=nil;
  GSWElement* pageElement=nil;
  GSWComponent* pageComponent=nil;
  LOGObjectFnStart();
  NS_DURING
    {
      pageElement=[aContext _pageElement];
      pageComponent=[aContext _pageComponent];
#ifndef NDEBUG
      [aContext addDocStructureStep:@"Invoke Action For Request"];
#endif
      [aContext _setCurrentComponent:pageComponent];
      element=[pageElement invokeActionForRequest:aRequest
                           inContext:aContext];
      [aContext _setCurrentComponent:nil];
      if (!element)
        element=[aContext page]; //??
    }
  NS_HANDLER
    {
      LOGException0(@"exception in GSWSession invokeActionForRequest:inContext");
      LOGException(@"exception=%@",localException);
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"In GSWSession invokeActionForRequest:inContext");
      LOGException(@"exception=%@",localException);
      [localException raise];
    }
  NS_ENDHANDLER;
  LOGObjectFnStop();
  return element;
};

//--------------------------------------------------------------------
//	appendToResponse:inContext:
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  GSWStatisticsStore* statisticsStore=nil;
  NSString* logFile=nil;
  GSWElement* pageElement=nil;
  GSWComponent* pageComponent=nil;

  LOGObjectFnStart();

  statisticsStore=[[GSWApplication application] statisticsStore];

  pageElement=[aContext _pageElement];
  pageComponent=[aContext _pageComponent];

#ifndef NDEBUG
  [aContext addDocStructureStep:@"Append To Response"];
#endif

  [aContext _setCurrentComponent:pageComponent];
  NS_DURING
    {
      [pageElement appendToResponse:aResponse
                   inContext:aContext];
    }
  NS_HANDLER
    {
      LOGException(@"exception in %@ appendToResponse:inContext",
                   [self class]);
      LOGException(@"exception=%@",localException);
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"In %@ appendToResponse:inContext",
                                                              [self class]);
      LOGException(@"exception=%@",localException);
      [localException raise];
    }
  NS_ENDHANDLER;

  [aContext _setCurrentComponent:nil];

  [self appendCookieToResponse:aResponse];

  {
    NSString* descr=nil;
    [statisticsStore recordStatisticsForResponse:aResponse
                     inContext:aContext];
    descr=[statisticsStore descriptionForResponse:aResponse
                           inContext:aContext];
    if (descr)
      {
        [_statistics addObject:descr];
        logFile=[statisticsStore logFile];
        if (logFile)
          {
            NSString* formattedDescr=[GSWStatisticsStore formatDescription:descr
                                                         forResponse:aResponse
                                                         inContext:aContext];
            if (formattedDescr)
              {
                if (!_formattedStatistics)
                  _formattedStatistics = [NSMutableString new];
                [_formattedStatistics appendString:formattedDescr];
              }
          };
      };
  };
  LOGObjectFnStop();
};


@end

//====================================================================
@implementation GSWSession (GSWStatistics)

//--------------------------------------------------------------------
-(NSArray*)statistics
{
  return _statistics;
};

//--------------------------------------------------------------------
-(BOOL)_allowedToViewStatistics
{
  return _isAllowedToViewStatistics;
};

//--------------------------------------------------------------------
-(void)_allowToViewStatistics
{
  _isAllowedToViewStatistics=YES;
};

//--------------------------------------------------------------------
-(void)_setAllowedToViewStatistics:(BOOL)flag
{
  _isAllowedToViewStatistics=flag;
};

//--------------------------------------------------------------------
-(BOOL)validateStatisticsLogin:(NSString*)login
                  withPassword:(NSString*)password
{
  GSWStatisticsStore* statsStore = [[GSWApplication application]statisticsStore];
  if (statsStore)
    {
      NSString* statsStorePassword=[statsStore _password];
      if ([statsStorePassword isEqual:password])
        [self _allowToViewStatistics];
    }
  return [self _allowedToViewStatistics];
}

//--------------------------------------------------------------------
-(NSString*)_formattedStatistics
{
  return [NSString stringWithString:_formattedStatistics];
};

//--------------------------------------------------------------------
-(NSDate*)_birthDate
{
  return _birthDate;
};

//--------------------------------------------------------------------
-(void)_setBirthDate:(NSDate*)birthDate
{
  ASSIGN(_birthDate,birthDate);
};
@end

//====================================================================
@implementation GSWSession (GSWEvents)

//--------------------------------------------------------------------
-(BOOL)_allowedToViewEvents
{
  return _isAllowedToViewEvents;
};

//--------------------------------------------------------------------
-(void)_allowToViewEvents
{
  _isAllowedToViewEvents=YES;
};

//--------------------------------------------------------------------
-(void)_setAllowedToViewEvents:(BOOL)flag
{
  _isAllowedToViewEvents=flag;
};

//--------------------------------------------------------------------
-(BOOL)validateEventsLogin:(NSString*)login
              withPassword:(NSString*)password
{
//TODO wait for gdl2 implementation
/*
  NSString* eventCenterPassword=[EOEventCenter password];
  if ([eventCenterPassword isEqual:password])
    [self _allowToViewEvents];
*/
  return [self _allowedToViewEvents];
}

@end

//====================================================================
@implementation GSWSession (GSWSessionN)

//--------------------------------------------------------------------
-(GSWApplication*)application
{
  return [GSWApplication application];
};

@end

//====================================================================
@implementation GSWSession (GSWSessionO)

//--------------------------------------------------------------------
-(void)_validateAPI
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWSession (GSWSessionClassA)

//--------------------------------------------------------------------
+(void)__setContextCounterIncrementingEnabled:(BOOL)flag
{
  LOGClassFnNotImplemented();  //TODOFN
};

//--------------------------------------------------------------------
+(int)__counterIncrementingEnabledFlag
{
  LOGClassFnNotImplemented();  //TODOFN
  return 1;
};

@end
