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

extern id gcObjectsToBeVisited;

//--------------------------------------------------------------------

//	init
-(id)init
{  
    if ((self = [super init]))
    {
      NSNumber       *mytimeOutNum    = [[GSWApp class] sessionTimeOut];
      NSTimeInterval mySessionTimeOut = [mytimeOutNum  doubleValue];

      [self setTimeOut:mySessionTimeOut];
      [self _initWithSessionID:[[self class] createSessionID]];
    }
  
  return self;
}

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
}

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
          }

        if (sizeToFill>=sizeof(unsigned int) && info.loads[0]>0)
          {
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            NSDebugMLog(@"loads[0] %ld",(long)info.loads[0]);
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.loads[0] >> 4)) ^ rnd);
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);
          }

        if (sizeToFill>=sizeof(unsigned int) && info.loads[1]>0)
          {
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            NSDebugMLog(@"loads[1] %ld",(long)info.loads[1]);
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.loads[1] >> 4)) ^ rnd);
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);
          }

        if (sizeToFill>=sizeof(unsigned int) && info.loads[2]>0)
          {
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            NSDebugMLog(@"loads[2] %ld",(long)info.loads[2]);
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.loads[2] >> 4)) ^ rnd);
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);
          }

        if (sizeToFill>=sizeof(unsigned int) && info.freeram>0)
          {
            NSDebugMLog(@"freeram %ld",(unsigned long)info.freeram);
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.freeram >> 4)) ^ rnd); // Drop 4 minor bits
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);
          }
        
        if (sizeToFill>=sizeof(unsigned int) && info.sharedram>0)
          {
            NSDebugMLog(@"sharedram %ld",(unsigned long)info.sharedram);
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.sharedram >> 4)) ^ rnd); // Drop 4 minor bits
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);
          }
        
        if (sizeToFill>=sizeof(unsigned int) && info.freeswap>0)
          {
            NSDebugMLog(@"freeswap %ld",(unsigned long)info.freeswap);
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.freeswap >> 4)) ^ rnd); // Drop 4 minor bits
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);
          }
        
        if (sizeToFill>=sizeof(unsigned int) && info.bufferram>0)
          {
            NSDebugMLog(@"bufferram %ld",(unsigned long)info.bufferram);
            rnd=(unsigned)(((float)UINT_MAX)*rand()/(RAND_MAX+1.0));
            *((unsigned int*)pMd5Data)=(((unsigned int)(info.bufferram >> 4)) ^ rnd); // Drop 4 minor bits
            sizeToFill-=sizeof(unsigned int);
            pMd5Data+=sizeof(unsigned int);                            
          }
      }
  }
#endif
  NSDebugMLog(@"sizeToFill %d",sizeToFill);
  while(sizeToFill>0)
    {
      *((unsigned char*)pMd5Data)=(unsigned char)(256.0*rand()/(RAND_MAX+1.0));
      sizeToFill--;
      pMd5Data++;
    }
  //Now do md5 on bytes after sizeof(ts)
  md5Sum=[md5Data md5Digest];
  [data appendData:md5Sum];
  sessionID=[data hexadecimalRepresentation];
  return sessionID;
}
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
  DESTROY(_sessionID);
  DESTROY(_autoreleasePool);
  DESTROY(_contextArrayStack);
  DESTROY(_contextRecords);
  DESTROY(_editingContext);
  DESTROY(_languages);
  DESTROY(_componentState);
  DESTROY(_birthDate);
  DESTROY(_statistics);
  DESTROY(_formattedStatistics);
  _currentContext=nil;
  DESTROY(_permanentPageCache);
  DESTROY(_permanentContextIDArray);
  DESTROY(_domainForIDCookies);
  [super dealloc];
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
//  dscr=[NSString stringWithFormat:@"<%s %p>",
//				 object_getClassName(self),
//				 (void*)self];
  
  dscr=[NSString stringWithFormat:@"<%s %p - sessionID=%@ autoreleasePool=%p timeOut=%f contextArrayStack=%@",
				 object_getClassName(self),
				 (void*)self,
				 _sessionID,
				 (void*)_autoreleasePool,
				 _timeOut,
				 _contextArrayStack];
/*
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
*/
  dscr=[dscr stringByAppendingFormat:@" isTerminating=%s isDistributionEnabled=%s storesIDsInCookies=%s storesIDsInURLs=%s hasSessionLockedEditingContext=%s>",
				   _isTerminating ? "YES" : "NO",
				   _isDistributionEnabled ? "YES" : "NO",
				   _storesIDsInCookies ? "YES" : "NO",
				   _storesIDsInURLs ? "YES" : "NO",
				   _hasSessionLockedEditingContext ? "YES" : "NO"];
  
  return dscr;
}

//--------------------------------------------------------------------
//	sessionID

-(NSString*)sessionID
{
  return _sessionID;
}

//--------------------------------------------------------------------
//	sessionID

-(void)setSessionID:(NSString*)sessionID
{
  ASSIGN(_sessionID,sessionID);
}

//--------------------------------------------------------------------
-(NSString*)domainForIDCookies
{
  //OK
  
  if (!_domainForIDCookies)
    {
      GSWContext* context=nil;
      GSWRequest* request=nil;
      NSString* applicationName=nil;
      NSString* adaptorPrefix=nil;
      [[GSWApplication application]lock];
      context=[self context];
      request=[context request];
      applicationName=[request applicationName];
      NSDebugMLLog(@"sessions",@"applicationName=%@",applicationName);
      adaptorPrefix=[request adaptorPrefix];
      NSDebugMLLog(@"sessions",@"adaptorPrefix=%@",adaptorPrefix);
      [[GSWApplication application]unlock];
      ASSIGN(_domainForIDCookies,
             ([NSString stringWithFormat:@"%@/%@.%@",
                        adaptorPrefix,
                        applicationName,
                        GSWApplicationSuffix[GSWebNamingConv]]));
    }

  NSDebugMLLog(@"sessions",@"_domainForIDCookies=%@",_domainForIDCookies);

  

  return _domainForIDCookies;
}

//--------------------------------------------------------------------
-(BOOL)storesIDsInURLs
{
  return _storesIDsInURLs;
}

//--------------------------------------------------------------------
-(void)setStoresIDsInURLs:(BOOL)flag
{
  
  if (flag!=_storesIDsInURLs)
    _storesIDsInURLs=flag;

  
}

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
}

//--------------------------------------------------------------------
-(BOOL)storesIDsInCookies
{
  return _storesIDsInCookies;
}

//--------------------------------------------------------------------
-(void)setStoresIDsInCookies:(BOOL)flag
{
    NSDebugMLLog(@"sessions",@"newflag=%d",(int)flag);
  if (flag!=_storesIDsInCookies)
    {
      _storesIDsInCookies=flag;
      [_currentContext _synchronizeForDistribution];
    }      
  
}

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
}

//--------------------------------------------------------------------
/** Enables or disables application instance number in URLs.
    If flag is NO, URLs contains application number so requests are directed 
	to the specific application instance.
    If flag is YES, URLs doesn't contain application number so requests can 
	be directed to any instance (load balancing)
**/
-(void)setDistributionEnabled:(BOOL)flag
{
    if (flag!=_isDistributionEnabled)
    {
      _isDistributionEnabled=flag;
      [_currentContext _synchronizeForDistribution];
    }
  
}


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


//--------------------------------------------------------------------
-(id)_initWithSessionID:(NSString*)aSessionID
{
  //OK
  GSWApplication* application=nil;
  GSWStatisticsStore* statisticsStore=nil;

  statisticsStore=[GSWApp statisticsStore];
  [statisticsStore _applicationCreatedSession:self];

  ASSIGNCOPY(_sessionID,aSessionID);

  if (_sessionID)
    {
      NSDebugMLLog(@"sessions",@"sessionIDCount=%u",[_sessionID retainCount]);
    }
  application=[GSWApplication application];
  //applic statisticsStore
  //applic _activeSessionsCount
  [self _setBirthDate:[NSDate date]];
  ASSIGN(_statistics,[NSMutableArray array]);
  _storesIDsInURLs=YES;
  [application _finishInitializingSession:self];

  return self;
}


//--------------------------------------------------------------------
//	isTerminating

//--------------------------------------------------------------------
-(BOOL)isTerminating 
{
  return _isTerminating;
}

//--------------------------------------------------------------------
//	terminate
-(void)terminate 
{
  
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
            }
          DESTROY(_editingContext);
        }
      /*
        [self setTimeOut:(NSTimeInterval) 1];	// forces to call removeSessionWithID in GSWServerSessionStore to dealloc it
        //TODO: VERIFY
        [self setTimeOut:(NSTimeInterval) 1];	// forces to call removeSessionWithID in GSWServerSessionStore to dealloc it
      */
    }
  
}

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
  return _timeOut;
}

//--------------------------------------------------------------------
//	setTimeOut:

-(void)setTimeOut:(NSTimeInterval)timeOut
{
  if (timeOut==0)
    _timeOut=[[NSDate distantFuture]timeIntervalSinceDate:_birthDate];
  else
    _timeOut=timeOut;  
}


//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [GSWApp debugWithFormat:aFormat
          arguments:ap];
  va_end(ap);
}


//--------------------------------------------------------------------
-(void)_debugWithString:(NSString*)string
{
  [GSWApp debugWithString:string];
}


//--------------------------------------------------------------------
-(void)savePage:(GSWComponent*)page
{
  GSWTransactionRecord * transactionrec = nil;
  BOOL pageChanged = [_currentContext _pageChanged];
  BOOL createArray = NO;
  NSString * ctxID = [_currentContext contextID];
  NSMutableArray *ctxArray = nil;
  int i=0;
  int k=0;
  NSString     * currentCtx = nil;
  
  if (_contextArrayStack == nil) {
    ASSIGN(_contextArrayStack, [NSMutableArray arrayWithCapacity:64]);
    ASSIGN(_contextRecords, [NSMutableDictionary dictionaryWithCapacity:64]);
  } else {
    ctxArray = [_contextArrayStack lastObject];
    [self _rearrangeContextArrayStackForContextID:ctxID];
  }
  if (pageChanged || (ctxArray == nil)) {
    createArray = YES;
  } else {
    if ([ctxArray count] > 0) {
      GSWTransactionRecord * transactionrecord = [_contextRecords objectForKey:[ctxArray lastObject]];
      GSWComponent * otherComponent = nil;
      if (transactionrecord != nil) {
        otherComponent = [transactionrecord responsePage];
      }
      if (otherComponent == page) {
        createArray = NO;
      } else {
        createArray = YES;
      }
    }
  }
  if (createArray) {
    ctxArray = [NSMutableArray arrayWithCapacity:64];    
    [_contextArrayStack addObject:ctxArray];
  }
  if (([_currentContext response] != nil) && ([[_currentContext response] _isClientCachingDisabled])) {
    transactionrec = [GSWTransactionRecord transactionRecordWithResponsePage:page
                                                                     context:_currentContext];
  } else {
    transactionrec = [GSWTransactionRecord transactionRecordWithResponsePage:page
                                                                     context:nil];
  }
  [_contextRecords setObject: transactionrec forKey: ctxID];
  [ctxArray addObject:ctxID];
  
  for (i = [GSWApp pageCacheSize]; ([ctxArray count] > i); [ctxArray removeObjectAtIndex:0]) {
    currentCtx = [ctxArray objectAtIndex:0];
    [_contextRecords removeObjectForKey:currentCtx];
  }

  if ([ctxArray count] == 0) {
    [_contextArrayStack removeObjectAtIndex:([_contextArrayStack count] - 1)];
  }
  for (; ([_contextArrayStack count] > i); [_contextArrayStack removeObjectAtIndex:0]) {
    NSMutableArray * stackArray = [_contextArrayStack objectAtIndex:0];
    int stackArraySize = [stackArray count];

    for (k = 0; k < stackArraySize; k++){
      [_contextRecords removeObjectForKey:[stackArray objectAtIndex:0]];
    }
  }
}

//--------------------------------------------------------------------
-(GSWComponent*)restorePageForContextID:(NSString*)aContextID
{
  //OK
  GSWComponent* page=nil;
  NSArray* contextArray=nil;
  GSWTransactionRecord* transactionRecord=nil;

  GSWLogAssertGood(self);
  NSAssert(aContextID,@"No contextID");
  NSAssert([aContextID length]>0,@"contextID empty");

  transactionRecord=[_contextRecords objectForKey:aContextID];

  if (transactionRecord)
    {
      page=[transactionRecord responsePage];
      GSWLogAssertGood(page);
    }
  
  if (page) // will put it at the end of the stack
    {
      unsigned int stackIndex=0;
      unsigned int contextArrayIndex=0;

      contextArray=[self _contextArrayForContextID:aContextID
                         stackIndex:&stackIndex
                         contextArrayIndex:&contextArrayIndex];

      if (contextArray)
        {
          if (stackIndex!=([_contextArrayStack count]-1))
            {
              [_contextArrayStack addObject:contextArray]; //add before removing to avoid release
              [_contextArrayStack removeObjectAtIndex:stackIndex];
            }
        }
    }

  if ([_permanentPageCache objectForKey:aContextID])
      page=[self _permanentPageWithContextID:aContextID];

  NSAssert(self,@"self");

  [page _awakeInContext:_currentContext];

  return page;
}

//--------------------------------------------------------------------
//NDFN
-(unsigned int)permanentPageCacheSize
{
  return [GSWApp permanentPageCacheSize];
}

//--------------------------------------------------------------------
-(void)savePageInPermanentCache:(GSWComponent*)page
{
  GSWContext* context=nil;
  NSMutableDictionary* permanentPageCache=nil;
  unsigned int permanentPageCacheSize=0;
  NSString* contextID=nil;
    context=[self context];
  permanentPageCache=[self _permanentPageCache];
  permanentPageCacheSize=[self permanentPageCacheSize];

  // first we'll remove excessive cached pages.
  while([_permanentContextIDArray count]>0 && [_permanentContextIDArray count]>=permanentPageCacheSize)
    {
      id deletePage=nil;
      NSString* deleteContextID=nil;
      [GSWApplication statusLogString:@"Deleting permanent cached Page"];
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
    }
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
        }
    }
  else if ([permanentPageCache objectForKey:contextID])
    {
      LOGSeriousError(@"page of class %@ contextID %@ in permanent cache but not in stack",
                      [page class],
                      contextID);
    }

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
      }
  }
  */
  if ([_permanentContextIDArray count]!=[permanentPageCache count])
    {
      LOGSeriousError(@"[permanentContextIDArray count] %d != [permanentPageCache count] %d",
                      (int)[_permanentContextIDArray count],
                      (int)[permanentPageCache count]);
    }
  
}


//--------------------------------------------------------------------
-(void)clearCookieFromResponse:(GSWResponse*)aResponse
{
  NSString* domainForIDCookies=nil;
  NSString* sessionID=nil;
  NSDate* anExpireDate=nil;
  GSWCookie* sessionIDCookie=nil;
  GSWCookie* instanceIDCookie=nil;  

  
  domainForIDCookies=[self domainForIDCookies];
  sessionID=[self sessionID];
  anExpireDate=[NSDate date]; // Expire now

  sessionIDCookie=[GSWCookie cookieWithName:GSWKey_SessionID[GSWebNamingConv]
                             value:sessionID
                             path:domainForIDCookies
                             domain:nil
                             expires:anExpireDate
                             isSecure:NO];
  NSDebugMLLog(@"sessions",@"sessionIDCookie=%@",sessionIDCookie);

  [aResponse addCookie:sessionIDCookie];

  instanceIDCookie=[GSWCookie cookieWithName:GSWKey_InstanceID[GSWebNamingConv]
                              value:@"-1"
                              path:domainForIDCookies
                              domain:nil
                              expires:anExpireDate
                              isSecure:NO];
  NSDebugMLLog(@"sessions",@"instanceIDCookie=%@",instanceIDCookie);

  [aResponse addCookie:instanceIDCookie];

  
}

//--------------------------------------------------------------------
-(void)appendCookieToResponse:(GSWResponse*)aResponse
{
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
        }

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
        }
      [aResponse addCookie:[GSWCookie cookieWithName:GSWKey_InstanceID[GSWebNamingConv]
                                      value:GSWIntToNSString(instance)
                                      path:domainForIDCookies
                                      domain:nil
                                      expires:anExpireDate
                                      isSecure:NO]];

    }
  
}



//--------------------------------------------------------------------
-(void)_releaseAutoreleasePool
{
  //OK
  //  printf("session %p _releaseAutoreleasePool START\n",self);
//  fprintf(stderr,"session %p _releaseAutoreleasePool START\n",self);
//TODO-NOW remettre  [GarbageCollector collectGarbages];
//  printf("session %p _releaseAutoreleasePool after garbage",self);
//  fprintf(stderr,"session %p _releaseAutoreleasePool after garbage\n",self);
  DESTROY(_autoreleasePool);
//  printf("session %p _releaseAutoreleasePool STOP\n",self);
//  fprintf(stderr,"session %p _releaseAutoreleasePool STOP\n",self);
  
}

//--------------------------------------------------------------------
-(void)_createAutoreleasePool
{
    if (!_autoreleasePool)
    {
      _autoreleasePool=[NSAutoreleasePool new];
      GSWLogMemCF("New NSAutoreleasePool: %p",_autoreleasePool);
    }
  
}

//--------------------------------------------------------------------
-(GSWComponent*)_permanentPageWithContextID:(NSString*)aContextID
{
  GSWComponent* page=nil;
    page=[_permanentPageCache objectForKey:aContextID];
  
  return page;
}

//--------------------------------------------------------------------
-(NSMutableDictionary*)_permanentPageCache
{
    if (!_permanentPageCache)
    _permanentPageCache=[NSMutableDictionary new];
  if (!_permanentContextIDArray)
    _permanentContextIDArray=[NSMutableArray new];
  
  return _permanentPageCache;
}

//--------------------------------------------------------------------
-(NSString*)_contextIDMatchingContextID:(NSString*)aContextID
                        requestSenderID:(NSString*)aSenderID
{
  NSAssert(NO,@"Deprecated. use _contextIDMatchingIDsInContext:");
  return nil;
}

//--------------------------------------------------------------------
-(NSString*)_contextIDMatchingIDsInContext:(GSWContext*)aContext
{
  NSString* contextID=nil;
  NSString* requestContextID=nil;

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
        }      
    }

  

  return contextID;
}

//--------------------------------------------------------------------
// _rearrangeContextArrayStack in wo 5
-(void)_rearrangeContextArrayStackForContextID:(NSString*)contextID
{
  
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
          [_contextArrayStack removeObjectAtIndex:stackIndex];              
        }
    }
  
}

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
        }
    }
  if (!contextArray)
    {
      if (pStackIndex)
        *pStackIndex=NSNotFound;
      if (pContextArrayIndex)
        *pContextArrayIndex=NSNotFound;
    }
  return contextArray;
}

//--------------------------------------------------------------------
-(void)_replacePage:(GSWComponent*)page
{
  LOGObjectFnNotImplemented();	//TODOFN
}

//--------------------------------------------------------------------
//NDFN
-(unsigned int)pageCacheSize
{
  return [GSWApp pageCacheSize];
}

//--------------------------------------------------------------------

//--------------------------------------------------------------------
-(void)_saveCurrentPage
{
  //OK
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
                }
            }
        }
    }
  
}

//--------------------------------------------------------------------
-(int)_requestCounter
{
  //OK
  return _requestCounter;
}

//--------------------------------------------------------------------
-(void)_contextDidIncrementContextID
{
  _contextCounter++;
}

//--------------------------------------------------------------------
-(int)_contextCounter
{
  //OK
  return _contextCounter;
}

//--------------------------------------------------------------------
-(void)_setContext:(GSWContext*)aContext
{
  //OK
    NSDebugMLLog(@"sessions",@"aContext=%p",(void*)aContext);
  if (aContext!=_currentContext)
    _currentContext=aContext;
  
}

//--------------------------------------------------------------------
-(void)sleepInContext:(GSWContext*)aContext
{
  //OK
    [self sleep];
  if (_hasSessionLockedEditingContext)
    {
      [_editingContext unlock];
      _hasSessionLockedEditingContext = NO;
    }
  [self _setContext:nil];
  
}

//--------------------------------------------------------------------
-(void)awakeInContext:(GSWContext*)aContext
{
    [self _setContext:aContext];
  NSDebugMLLog(@"sessions",@"contextCounter=%i",_contextCounter);
  if (aContext)
    {
      if ([[self class] __counterIncrementingEnabledFlag]) //??
        {
          _contextCounter++;
          _requestCounter++;
        }
    }
  NSDebugMLLog(@"sessions",@"contextCounter=%i",_contextCounter);
  if (_editingContext 
      && !_hasSessionLockedEditingContext
      && [GSWApplication _lockDefaultEditingContext])
    {
      [_editingContext lock];
      _hasSessionLockedEditingContext=YES;
    }
  [self awake];
  
}


//--------------------------------------------------------------------
-(void)setLanguages:(NSArray*)someLanguages
{
  
  NSDebugMLLog(@"sessions",@"someLanguages=%@",someLanguages);

  if (!someLanguages)
    {
      LOGError0(@"No languages");
    }
  ASSIGN(_languages,someLanguages);

  
}

//--------------------------------------------------------------------
/** GSWeb specific
Insert language language at the begining of session languages array 
**/
-(void)insertLanguage:(NSString*)language
{
  NSArray* languages=nil;
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
            }
        }
      else
        [self setLanguages:[NSArray arrayWithObject:language]];
    }
  
}

//--------------------------------------------------------------------
/** GSWeb specific
Add language language at the end of session languages array if language 
is not present
**/
-(void)addLanguage:(NSString*)language
{
  NSArray* languages=nil;
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
    }
  
}

//--------------------------------------------------------------------
/** GSWeb specific
Returns first element of languages or nil if languages is empty
**/
-(NSString*)firstLanguage
{
  NSArray* languages=nil;
  NSString* firstLanguage=nil;
  
  languages=[self languages];
  if ([languages count]>0)
    firstLanguage=[languages objectAtIndex:0];

  

  return firstLanguage;
}

//--------------------------------------------------------------------
-(NSArray*)languages
{
  
  NSDebugMLLog(@"sessions",@"_languages=%@",_languages);

  if (!_languages)
    {
      GSWContext* aContext=[self context];
      GSWRequest* request=[aContext request];
      NSArray* languages=[request browserLanguages];
      [self setLanguages:languages];
      NSDebugMLLog(@"sessions",@"_languages=%@",_languages);
    }

  

  return _languages;
}

//--------------------------------------------------------------------
-(NSArray*)_languages
{
    

  return _languages;
}


//--------------------------------------------------------------------
//	objectForKey:
-(id)objectForKey:(NSString*)key
{
  id object=nil;
    object=[_componentState objectForKey:key];
  NSDebugMLLog(@"sessions",@"key=%@ object=%@",key,object);
  
  return object;
}

//--------------------------------------------------------------------
//	setObject:forKey:
-(void)setObject:(id)object
          forKey:(NSString*)key
{
  
  NSAssert(object,@"No object");
  NSAssert(key,@"No key");

  if (!_componentState)
    _componentState=[NSMutableDictionary new];
  NSDebugMLLog(@"sessions",@"key=%@ object=%@",key,object);
  [_componentState setObject:object
                   forKey:key];
  
}

//--------------------------------------------------------------------
-(void)removeObjectForKey:(NSString*)key
{
    NSDebugMLLog(@"sessions",@"key=%@",key);
  [_componentState removeObjectForKey:key];
  
}

//--------------------------------------------------------------------
//NDFN
-(NSMutableDictionary*)componentState
{
  return _componentState;
}


//--------------------------------------------------------------------
-(EOEditingContext*)defaultEditingContext
{
  if(!_editingContext)
  {
    ASSIGN(_editingContext,[[[NSClassFromString(@"EOEditingContext") alloc] init] autorelease]);
    
    [_editingContext setLevelsOfUndo:[GSWApplication defaultUndoStackLimit]];
    if ([GSWApplication _lockDefaultEditingContext])
    {
      [_editingContext lock];
      _hasSessionLockedEditingContext=YES;
    }
  }
  
  return _editingContext;
}

//--------------------------------------------------------------------
-(void)setDefaultEditingContext:(EOEditingContext*)editingContext
{
  if (_editingContext)
    {
      // We can't set the editing context if one has already been created
      [NSException raise:NSInvalidArgumentException 
                   format:@"%s Can't set a defautEditingContext when one already exists",
                   object_getClassName(self)];
    }
  else
    {
      ASSIGN(_editingContext,editingContext);
      if ([GSWApplication _lockDefaultEditingContext])
        {
          [_editingContext lock];
          _hasSessionLockedEditingContext=YES;
        }
    }
}

//--------------------------------------------------------------------
-(GSWContext*)context
{
  return _currentContext;
}

//--------------------------------------------------------------------
//	awake
-(void)awake 
{
  DESTROY(_domainForIDCookies);
}

//--------------------------------------------------------------------
//	sleep

-(void)sleep 
{
  // We destroy domainForIDCookies because applictaion name may 
  //   change between pages
  DESTROY(_domainForIDCookies);
}

//--------------------------------------------------------------------
//	takeValuesFromRequest:inContext:
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext 
{
  GSWElement* pageElement=nil;
  GSWComponent* pageComponent=nil;
    pageElement=[aContext _pageElement];
  pageComponent=[aContext _pageComponent];
#ifndef NDEBUG
  [aContext addDocStructureStep:@"Take Values From Request"];
#endif
  [aContext _setCurrentComponent:pageComponent];
  [pageElement takeValuesFromRequest:aRequest
               inContext:aContext];
  [aContext _setCurrentComponent:nil];
  
}

//--------------------------------------------------------------------
//	invokeActionForRequest:inContext:
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext 
{
  GSWElement* element=nil;
  GSWElement* pageElement=nil;
  GSWComponent* pageComponent=nil;

  NS_DURING
    pageElement = [aContext _pageElement];
    pageComponent = [aContext _pageComponent];
    [aContext _setCurrentComponent:pageComponent];

    element=[pageElement invokeActionForRequest:aRequest
                         inContext:aContext];
    [aContext _setCurrentComponent:nil];
  NS_HANDLER
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"In %s", __PRETTY_FUNCTION__);
      [localException raise];
  NS_ENDHANDLER;

  return element;
}

//--------------------------------------------------------------------
//	appendToResponse:inContext:
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  GSWStatisticsStore* statisticsStore=nil;
  NSString* logFile=nil;
  GSWElement* pageElement=nil;
  GSWComponent* pageComponent=nil;

  
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
          }
      }
  }
  
}



//--------------------------------------------------------------------
-(NSArray*)statistics
{
  return _statistics;
}

//--------------------------------------------------------------------
-(BOOL)_allowedToViewStatistics
{
  return _isAllowedToViewStatistics;
}

//--------------------------------------------------------------------
-(void)_allowToViewStatistics
{
  _isAllowedToViewStatistics=YES;
}

//--------------------------------------------------------------------
-(void)_setAllowedToViewStatistics:(BOOL)flag
{
  _isAllowedToViewStatistics=flag;
}

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
}

//--------------------------------------------------------------------
-(NSDate*)_birthDate
{
  return _birthDate;
}

//--------------------------------------------------------------------
-(void)_setBirthDate:(NSDate*)birthDate
{
  ASSIGN(_birthDate,birthDate);
}

//--------------------------------------------------------------------
-(BOOL)_allowedToViewEvents
{
  return _isAllowedToViewEvents;
}

//--------------------------------------------------------------------
-(void)_allowToViewEvents
{
  _isAllowedToViewEvents=YES;
}

//--------------------------------------------------------------------
-(void)_setAllowedToViewEvents:(BOOL)flag
{
  _isAllowedToViewEvents=flag;
}

-(void) _clearCookieFromResponse:(GSWResponse*) aResponse
{
  NSString       *cookiePath = [self domainForIDCookies];
  NSCalendarDate *today = [NSCalendarDate date];
  GSWCookie * instanceCookie;
  GSWCookie * sessionIDCookie;
  
  NSCalendarDate *dateInThePast = [today dateByAddingYears:0 months:-1 days:0 hours:0 minutes:0 seconds:0];
  
  sessionIDCookie = [GSWCookie cookieWithName:[GSWApp sessionIdKey]
                                        value:_sessionID
                                         path:cookiePath
                                       domain:nil
                                      expires:dateInThePast
                                     isSecure:NO];
  
  [aResponse addCookie:sessionIDCookie];
  
  instanceCookie = [GSWCookie cookieWithName:[GSWApp instanceIdKey]
                                       value:@"-1"
                                        path:cookiePath
                                      domain:nil
                                     expires:dateInThePast
                                    isSecure:NO];
  
  [aResponse addCookie:instanceCookie];
}


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


//--------------------------------------------------------------------
-(GSWApplication*)application
{
  return [GSWApplication application];
}


//--------------------------------------------------------------------
-(void)_validateAPI
{
  LOGObjectFnNotImplemented();	//TODOFN
}

//--------------------------------------------------------------------
+(void)__setContextCounterIncrementingEnabled:(BOOL)flag
{
  LOGClassFnNotImplemented();  //TODOFN
}

//--------------------------------------------------------------------
+(int)__counterIncrementingEnabledFlag
{
  LOGClassFnNotImplemented();  //TODOFN
  return 1;
}

@end
