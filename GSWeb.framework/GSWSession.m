/** GSWSession.m - <title>GSWeb: Class GSWSession</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
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
#include <gnustep/base/GSCategories.h>

#include <time.h>
#if __linux__
#include <linux/kernel.h>
#include <linux/sys.h>
#include <sys/sysinfo.h>
#endif

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
  LOGObjectFnNotImplemented();	//TODOFN
  /*
  [clone setSessionID:sessionID];
  [clone setLanguages:languages];
  [clone setTimeOut:timeOut];
  [clone setVariables:[[variables copy]autorelease]];
  [clone setPageCache:[[pageCache copy]autorelease]];
*/
  return clone;
};

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
  [super encodeWithCoder:coder];
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
  self = [super initWithCoder: coder];
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
  NSDebugFLog(@"Dealloc GSWSession %p. ThreadID=%p",(void*)self,(void*)objc_thread_id());
  NSDebugFLog0(@"Dealloc GSWSession: sessionID");
  DESTROY(_sessionID);
  NSDebugFLog0(@"Dealloc GSWSession:autoreleasePool ");
  GSWLogMemCF("Destroy NSAutoreleasePool: %p. ThreadID=%p",_autoreleasePool,(void*)objc_thread_id());
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
  //OK
  return _storesIDsInURLs;
};

//--------------------------------------------------------------------
-(void)setStoresIDsInURLs:(BOOL)flag
{
  //OK
  _storesIDsInURLs=flag;
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
  //OK
  return _storesIDsInCookies;
};

//--------------------------------------------------------------------
-(void)setStoresIDsInCookies:(BOOL)flag
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"newflag=%d",(int)flag);
  _storesIDsInCookies=flag;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(BOOL)isDistributionEnabled
{
  return _isDistributionEnabled;
};

//--------------------------------------------------------------------
-(void)setDistributionEnabled:(BOOL)flag
{
  LOGObjectFnStart();
  _isDistributionEnabled=flag;
  LOGObjectFnStop();
};

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
  ASSIGN(_birthDate,[NSDate date]);
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
  //OK
  NSString* sessionID=nil;
  LOGObjectFnStart();

  _isTerminating=YES;
  sessionID=[self sessionID];
  [self setTimeOut:(NSTimeInterval) 1];	// forces to call removeSessionWithID in GSWServerSessionStore to dealloc it
  [[NSNotificationCenter defaultCenter] postNotificationName:GSWNotification__SessionDidTimeOutNotification[GSWebNamingConv]
                                        object:sessionID];
  //TODO: VERIFY
  [self setTimeOut:(NSTimeInterval) 1];	// forces to call removeSessionWithID in GSWServerSessionStore to dealloc it
  //goto => GSWApp _sessionDidTimeOutNotification:
  //call GSWApp _discountTerminatedSession
  //call GSWApp statisticsStore
  //call statstore _sessionTerminating:self
  [[GSWApp statisticsStore] _sessionTerminating:self];
  LOGObjectFnStop();
};
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
  _timeOut=timeOut;
};

@end

//====================================================================
@implementation GSWSession (GSWSessionDebugging)

//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)format,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWSession (GSWSessionD)

//--------------------------------------------------------------------
-(void)_debugWithString:(NSString*)string
{
  LOGObjectFnNotImplemented();	//TODOFN
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
    [context _pageChanged];
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
  unsigned int stackIndex=0;
  unsigned int contextArrayIndex=0;
  LOGObjectFnStart();
  GSWLogAssertGood(self);
  NSAssert(aContextID,@"No contextID");
  NSAssert([aContextID length]>0,@"contextID empty");
  NSDebugMLLog(@"sessions",@"aContextID=%@",aContextID);

  if ([_permanentPageCache objectForKey:aContextID])
    {
      page=[self _permanentPageWithContextID:aContextID];
    }
  else
    {
      transactionRecord=[_contextRecords objectForKey:aContextID];
      NSDebugMLLog(@"sessions",@"transactionRecord=%@",transactionRecord);
      if (transactionRecord)
        {
          NSDebugMLLog(@"sessions",@"transactionRecord2=%@",transactionRecord);
          page=[transactionRecord responsePage];
          GSWLogAssertGood(page);
        };
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
              [_contextArrayStack addObject:contextArray];
              NSDebugMLLog(@"sessions",@"SESSION REMOVE: %p",[_contextArrayStack objectAtIndex:stackIndex]);
              [_contextArrayStack removeObjectAtIndex:stackIndex];
              //TODO faire pareil avec _contextArray ?
            };
        };
    };
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
-(uint)permanentPageCacheSize
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
  while([_permanentContextIDArray count]>0 && [_permanentContextIDArray count]>=permanentPageCacheSize)
    {
      id deletePage=nil;
      NSString* deleteContextID=nil;
      [GSWApplication statusLogWithFormat:@"Deleting permanent cached Page"];
      deleteContextID=[_permanentContextIDArray objectAtIndex:0];
      GSWLogAssertGood(deleteContextID);
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
  //TODO
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
  LOGObjectFnStart();
  domainForIDCookies=[self domainForIDCookies];
  sessionID=[self sessionID];
  [aResponse addCookie:[GSWCookie cookieWithName:GSWKey_SessionID[GSWebNamingConv]
                                  value:sessionID
                                  path:domainForIDCookies
                                  domain:nil
                                  expires:[self expirationDateForIDCookies]
                                  isSecure:NO]];
  [aResponse addCookie:[GSWCookie cookieWithName:GSWKey_InstanceID[GSWebNamingConv]
                                  value:@"-1" //TODO
                                  path:domainForIDCookies
                                  domain:nil
                                  expires:[self expirationDateForIDCookies]
                                  isSecure:NO]];

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendCookieToResponse:(GSWResponse*)aResponse
{
  //OK
  LOGObjectFnStart();
  if ([self storesIDsInCookies])
    {
      //TODO VERIFY
      NSString* domainForIDCookies=nil;
      NSString* sessionID=nil;
      domainForIDCookies=[self domainForIDCookies];
      sessionID=[self sessionID];
      [aResponse addCookie:[GSWCookie cookieWithName:GSWKey_SessionID[GSWebNamingConv]
                                      value:sessionID
                                      path:domainForIDCookies
                                      domain:nil
                                      expires:[self expirationDateForIDCookies]
                                      isSecure:NO]];
      
      [aResponse addCookie:[GSWCookie cookieWithName:GSWKey_InstanceID[GSWebNamingConv]
                                      value:@"1" //TODO
                                      path:domainForIDCookies
                                      domain:nil
                                      expires:[self expirationDateForIDCookies]
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
  printf("session %p _releaseAutoreleasePool START\n",self);
  fprintf(stderr,"session %p _releaseAutoreleasePool START\n",self);
//TODO-NOW remettre  [GarbageCollector collectGarbages];
  printf("session %p _releaseAutoreleasePool after garbage",self);
fprintf(stderr,"session %p _releaseAutoreleasePool after garbage\n",self);
  DESTROY(_autoreleasePool);
  printf("session %p _releaseAutoreleasePool STOP\n",self);
fprintf(stderr,"session %p _releaseAutoreleasePool STOP\n",self);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_createAutoreleasePool
{
  //OK
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
  //OK
  GSWComponent* page=nil;
  LOGObjectFnStart();
  page=[_permanentPageCache objectForKey:aContextID];
  LOGObjectFnStop();
  return page;
};

//--------------------------------------------------------------------
-(NSMutableDictionary*)_permanentPageCache
{
  //OK
  LOGObjectFnStart();
  if (!_permanentPageCache)
    _permanentPageCache=[NSMutableDictionary new];
  if (!_permanentContextIDArray)
    _permanentContextIDArray=[NSMutableArray new];
  LOGObjectFnStop();
  return _permanentPageCache;
};

//--------------------------------------------------------------------
-(GSWContext*)_contextIDMatchingContextID:(NSString*)aContextID
                          requestSenderID:(NSString*)aSenderID
{
  //avec (0) contextID=0 senderID=1.3 ==> return index=(0) stackIndex=0 contextArrayIndex=0 ==> return nil
  //avec (0,1) contextID=1 senderID=3 ==> return index=(1) stackIndex=1 contextArrayIndex=0 ==> return nil
  //avec (0,1,2) contextID=2 senderID=1.3 ==> return index=(2) stackIndex=2 contextArrayIndex=0 ==> return nil
  //avec (0,2,3,1) contextID=1 senderID=3 ==> return index=(1) stackIndex=3 contextArrayIndex=0 ==> return nil
  //avec (0,2,3,1,4) contextID=4 senderID=1.1 ==> return index=(4) stackIndex=4 contextArrayIndex=0 ==> return nil
  //avec (0,2,3,1,4,5) contextID=5 senderID=3 ==> return index=(5) stackIndex=5 contextArrayIndex=0 ==> return nil
  //avec (0,2,3,1,4,5,6) contextID=6 senderID=1.3 ==> return index=(6) stackIndex=6 contextArrayIndex=0 ==> return nil
  //avec (0,2,3,1,5,6,7,4) contextID=4 senderID=1.1 ==> return index=(4) stackIndex=7 contextArrayIndex=0 ==> return ni
  //avec (0,2,3,1,5,6,7,8,4) contextID=4 senderID=1.1 ==> return index=(4) stackIndex=8 contextArrayIndex=0 ==> return nil


  //OK
  GSWContext* context=nil;
  if (_contextArrayStack)
    {
      unsigned int stackIndex=0;
      unsigned int contextArrayIndex=0;
      NSArray* contextArray=[self _contextArrayForContextID:aContextID
                                  stackIndex:&stackIndex
                                  contextArrayIndex:&contextArrayIndex];
    };
  //TODO!!
  return context;
};

//--------------------------------------------------------------------
-(void)_rearrangeContextArrayStack
{
  LOGObjectFnStart();
  //avec (0) contextID=1 ==> return index=nil stackIndex=0 contextArrayIndex=0 ==> nothing
  //avec (0,1) contextID=2 ==> return index=nil stackIndex=0 contextArrayIndex=0 ==> nothing
  //avec (0,1,2) contextID=3 ==> return index=nil stackIndex=0 contextArrayIndex=0 ==> nothing
  //avec (0,2,3,1) contextID=4 ==> return index=nil stackIndex=0 contextArrayIndex=0 ==> nothing
  //avec (0,2,3,1,4) contextID=5 ==> return index=nil stackIndex=0 contextArrayIndex=0 ==> nothing
  //avec (0,2,3,1,4,5) contextID=6 ==> return index=nil stackIndex=0 contextArrayIndex=0 ==> nothing
  //avec (0,2,3,1,4,5,6) contextID=7 ==> return index=nil stackIndex=0 contextArrayIndex=0 ==> nothing
  //avec (0,2,3,1,5,6,7,4) contextID=8 ==> return index=nil stackIndex=0 contextArrayIndex=0 ==> nothing
  //avec (0,2,3,1,5,6,7,8,4) contextID=9 ==> return index=nil stackIndex=0 contextArrayIndex=0 ==> nothing
  
  /*
  NSArray* _contextArray=[self _contextArrayForContextID:contextID
							   stackIndex:XX
							   contextArrayIndex:XX];
  */
  LOGObjectFnNotImplemented();  //TODOFN
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSArray*)_contextArrayForContextID:(NSString*)aContextID
                          stackIndex:(unsigned int*)pStackIndex
                   contextArrayIndex:(unsigned int*)pContextArrayIndex
{

  //OK
  NSArray* contextArray=nil;
  unsigned int index=[_contextArrayStack indexOfObject:aContextID];
  LOGObjectFnNotImplemented();	//TODOFN
  if (index==NSNotFound)
    {
      if (pStackIndex)
        *pStackIndex=0;
      if (pContextArrayIndex)
        *pContextArrayIndex=0;
    }
  else
    {
      if (pStackIndex)
        *pStackIndex=index;
/*	  if (pContextArrayIndex)
		*pContextArrayIndex=XX;*/
      contextArray=[_contextArrayStack objectAtIndex:index];
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
-(uint)pageCacheSize
{
  return [GSWApp pageCacheSize];
};

//--------------------------------------------------------------------
-(void)_savePage:(GSWComponent*)page
	   forChange:(BOOL)forChange
{
  //OK
  GSWResponse* response=nil;
  BOOL isClientCachingDisabled=NO;
  GSWTransactionRecord* transactionRecord=nil;
  unsigned int pageCacheSize=0;
  NSString* contextID=nil;
  LOGObjectFnStart();
  NSAssert(page,@"No Page");
  if ([_contextArrayStack count]>0) // && _forChange!=NO ??
    [self _rearrangeContextArrayStack];

  // Get the response
  response=[_currentContext response];//currentContext??
  NSDebugMLLog(@"sessions",@"response=%@",response);
  isClientCachingDisabled=[response _isClientCachingDisabled]; //So what
  NSDebugMLLog(@"sessions",@"currentContext=%@",_currentContext);

  // Create a new transaction record
  transactionRecord=[[[GSWTransactionRecord alloc] 
                       initWithResponsePage:page
                       context:_currentContext]//currentContext??
                                              autorelease];
  NSDebugMLLog(@"sessions",@"transactionRecord=%@",transactionRecord);

  // Retrieve the pageCacheSize
  pageCacheSize=[self pageCacheSize];
  NSDebugMLLog(@"sessions",@"pageCacheSize=%d",pageCacheSize);

  // Create contextArrayStack and contextRecords if not already created
  if (!_contextArrayStack)
    _contextArrayStack=[NSMutableArray new];
  if (!_contextRecords)
    _contextRecords=[NSMutableDictionary new];
  NSDebugMLLog(@"sessions",@"contextArrayStack=%@",_contextArrayStack);
  NSDebugMLLog(@"sessions",@"contextRecords=%@",_contextRecords);

  // Remove some pages if page number greater than page cache size
  while([_contextArrayStack count]>0 && [_contextArrayStack count]>=pageCacheSize)
    {
      id deleteRecord=nil;
      NSString* deleteContextID=nil;
      [GSWApplication statusLogWithFormat:@"Deleting cached Page"];
      deleteContextID=[_contextArrayStack objectAtIndex:0];
      GSWLogAssertGood(deleteContextID);
      [GSWApplication statusLogWithFormat:@"contextArrayStack=%@",_contextArrayStack];
      [GSWApplication statusLogWithFormat:@"contextID=%@",deleteContextID];
      NSDebugMLLog(@"sessions",@"_deleteContextID=%@",deleteContextID);
      NSDebugMLLog(@"sessions",@"[contextArrayStack objectAtIndex:0]=%@",
                   [_contextArrayStack objectAtIndex:0]);
      NSDebugMLLog(@"sessions",@"[contextArrayStack objectAtIndex:0] retainCount=%d",
                   (int)[[_contextArrayStack objectAtIndex:0] retainCount]);
      NSDebugMLLog(@"sessions",@"SESSION REMOVE: %p",[_contextArrayStack objectAtIndex:0]);
      [_contextArrayStack removeObjectAtIndex:0];
      deleteRecord=[_contextRecords objectForKey:deleteContextID];
      GSWLogAssertGood(deleteRecord);
      GSWLogAssertGood([deleteRecord responsePage]);
      [GSWApplication statusLogWithFormat:@"delete page of class=%@",
                      [[deleteRecord responsePage] class]];
      NSDebugMLLog(@"sessions",@"SESSION REMOVE: %p",[_contextRecords objectForKey:deleteContextID]);
      [_contextRecords removeObjectForKey:deleteContextID];
    };

  GSWLogC("display page");
  NSDebugMLLog(@"sessions",@"page=%@",page);
  NSDebugMLLog(@"sessions",@"page context=%@",[page context]);

  // Retrieve Page contextID
  contextID=[[page context]contextID];
  NSDebugMLLog(@"sessions",@"_contextID=%@",contextID);
  NSAssert(contextID,@"No contextID");

  if ([_contextArrayStack containsObject:contextID])
    {
      LOGSeriousError(@"page of class %@ contextID %@ already in cache stack",
                      [page class],
                      contextID);
      NSDebugMLLog(@"sessions",@"SESSION REMOVE: %p",contextID);
      [_contextArrayStack removeObject:contextID];
      if (![_contextRecords objectForKey:contextID])
        {
          LOGSeriousError0(@"but not present in cache");
        };
    }
  else if ([_contextRecords objectForKey:contextID])
    {
      LOGSeriousError(@"page of class %@ contextID %@ in cache but not in stack",
                      [page class],
                      contextID);
    };
  // Add the page contextID in contextArrayStack
  [_contextArrayStack addObject:contextID];

  // Add the record for this contextID in contextRecords
  NSDebugMLLog(@"sessions",@"SESSION REPLACE: %p",[_contextRecords objectForKey:contextID]);
  [_contextRecords setObject:transactionRecord
                   forKey:contextID];
  NSDebugMLLog(@"sessions",@"contextArrayStack=%@",_contextArrayStack);
  //TODO
  {
    int i=0;
    GSWTransactionRecord* aTransRecord=nil;
    id anotherContextID=nil;
    for(i=0;i<[_contextArrayStack count];i++)
      {
        anotherContextID=[_contextArrayStack objectAtIndex:i];
        aTransRecord=[_contextRecords objectForKey:anotherContextID];
        [GSWApplication statusLogWithFormat:@"%d contextID=%@ page class=%@",
                        i,anotherContextID,[[aTransRecord responsePage] class]];
      };
  };
  if ([_contextArrayStack count]!=[_contextRecords count])
    {
      LOGSeriousError(@"[contextArrayStack count] %d != [contextRecords count] %d",
                      (int)[_contextArrayStack count],
                      (int)[_contextRecords count]);
    };
  NSDebugMLLog(@"sessions",@"contextRecords=%@",_contextRecords);
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
  _currentContext=aContext;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)sleepInContext:(GSWContext*)aContext
{
  //OK
  LOGObjectFnStart();
  [self sleep];
  [self _setContext:nil];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)awakeInContext:(GSWContext*)aContext
{
  //OK
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
  [self awake];
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWSession (GSWLocalization)

//--------------------------------------------------------------------
-(void)setLanguages:(NSArray*)someLanguages
{
  //OK
  if (!someLanguages)
    {
      LOGError0(@"No languages");
    };
  ASSIGN(_languages,someLanguages);
};

//--------------------------------------------------------------------
-(NSArray*)languages
{
  //OK
  if (!_languages)
    {
      GSWContext* aContext=[self context];
      GSWRequest* request=[aContext request];
      NSArray* languages=[request browserLanguages];
      [self setLanguages:languages];
    };
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
#if GDL2
  if(!_editingContext)
    {
      ASSIGN(_editingContext,[[[EOEditingContext alloc] init] autorelease]);
    }
#endif

  return _editingContext;
};

//--------------------------------------------------------------------
-(void)setDefaultEditingContext:(EOEditingContext*)editingContext
{
  ASSIGN(_editingContext,editingContext);
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
  //OK
  GSWElement* pageElement=nil;
  GSWComponent* pageComponent=nil;
  LOGObjectFnStart();
  pageElement=[aContext _pageElement];
  pageComponent=[aContext _pageComponent];
#ifndef NDEBUG
  [aContext addDocStructureStep:@"Take Values From Request"];
#endif
  [aContext _setCurrentComponent:pageComponent]; //_pageElement ??
  [pageComponent takeValuesFromRequest:aRequest
                 inContext:aContext]; //_pageComponent ??
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
      [aContext _setCurrentComponent:pageComponent]; //_pageElement ??
      element=[pageComponent invokeActionForRequest:aRequest
                             inContext:aContext]; //_pageComponent
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
  //OK
  GSWStatisticsStore* statisticsStore=nil;
  NSString* logFile=nil;
  GSWSession* session=nil;
  GSWElement* pageElement=nil;
  GSWComponent* pageComponent=nil;
  LOGObjectFnStart();
  statisticsStore=[[GSWApplication application] statisticsStore];
  pageElement=[aContext _pageElement];
  pageComponent=[aContext _pageComponent];
#ifndef NDEBUG
  [aContext addDocStructureStep:@"Append To Response"];
#endif
  [aContext _setCurrentComponent:pageComponent]; //_pageElement ??
  NS_DURING
    {
      [pageComponent appendToResponse:aResponse
                     inContext:aContext]; //_pageComponent??
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
  session=[aContext existingSession];
  [session appendCookieToResponse:aResponse];
  [statisticsStore recordStatisticsForResponse:aResponse
                   inContext:aContext];
  [statisticsStore descriptionForResponse:aResponse
                    inContext:aContext];
  logFile=[statisticsStore logFile];
  if (logFile)
    {
      //TODO
    };
  LOGObjectFnStop();
};


@end

//====================================================================
@implementation GSWSession (GSWStatistics)

//--------------------------------------------------------------------
-(NSArray*)statistics
{
  //return (Main, DisksList, DisksList, DisksList) (page dans l'ordre des context)
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWSession (GSWSessionM)

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
-(id)_formattedStatistics
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSDate*)_birthDate
{
  return _birthDate;
};

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
