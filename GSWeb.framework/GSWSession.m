/* GSWSession.m - GSWeb: Class GSWSession
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

#include <GSWeb/GSWeb.h>
#include <extensions/GarbageCollector.h>

//====================================================================

@implementation GSWSession

//--------------------------------------------------------------------
//	init
-(id)init
{
  LOGObjectFnStart();
  if ((self = [super init]))
	{
	  NSTimeInterval _sessionTimeOut=[GSWApplication sessionTimeOutValue];
	  NSDebugMLLog(@"sessions",@"_sessionTimeOut=%ld",(long)_sessionTimeOut);
	  [self setTimeOut:_sessionTimeOut];
	  [self _initWithSessionID:[NSString stringUniqueIdWithLength:8]]; //TODO
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

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder_
{
  [super encodeWithCoder: coder_];
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
-(id)initWithCoder: (NSCoder*)coder_
{
  self = [super initWithCoder: coder_];
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
  NSDebugFLog0(@"Dealloc GSWSession");
  NSDebugFLog0(@"Dealloc GSWSession: sessionID");
  DESTROY(sessionID);
  NSDebugFLog0(@"Dealloc GSWSession:autoreleasePool ");
  DESTROY(autoreleasePool);
  NSDebugFLog0(@"Dealloc GSWSession: contextArrayStack");
  DESTROY(contextArrayStack);
  NSDebugFLog0(@"Dealloc GSWSession: contextRecords");
  DESTROY(contextRecords);
  NSDebugFLog0(@"Dealloc GSWSession: editingContext");
  DESTROY(editingContext);
  NSDebugFLog0(@"Dealloc GSWSession: languages");
  DESTROY(languages);
  NSDebugFLog0(@"Dealloc GSWSession: componentState");
  DESTROY(componentState);
  NSDebugFLog0(@"Dealloc GSWSession: birthDate");
  DESTROY(birthDate);
  NSDebugFLog0(@"Dealloc GSWSession: statistics");
  DESTROY(statistics);
  NSDebugFLog0(@"Dealloc GSWSession: formattedStatistics");
  DESTROY(formattedStatistics);
  NSDebugFLog0(@"Dealloc GSWSession: currentContext (set to nil)");
  currentContext=nil;
  NSDebugFLog0(@"Dealloc GSWSession: permanentPageCache");
  DESTROY(permanentPageCache);
  NSDebugFLog0(@"Dealloc GSWSession: permanentContextIDArray");
  DESTROY(permanentContextIDArray);
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
  return sessionID;
};

//--------------------------------------------------------------------
-(NSString*)domainForIDCookies
{
  //OK
  NSString* _domain=nil;
  GSWContext* _context=nil;
  GSWRequest* _request=nil;
  NSString* _applicationName=nil;
  NSString* _adaptorPrefix=nil;
  LOGObjectFnStart();
  [[GSWApplication application]lock];
  _context=[self context];
  _request=[_context request];
  _applicationName=[_request applicationName];
  _adaptorPrefix=[_request adaptorPrefix];
  [[GSWApplication application]unlock];
  _domain=[NSString stringWithFormat:@"%@/%@.%@",
					_adaptorPrefix,
					_applicationName,
					GSWApplicationSuffix[GSWebNamingConv]];
  LOGObjectFnStop();
  return _domain;
};

//--------------------------------------------------------------------
-(BOOL)storesIDsInURLs
{
  //OK
  return storesIDsInURLs;
};

//--------------------------------------------------------------------
-(void)setStoresIDsInURLs:(BOOL)_flag
{
  //OK
  storesIDsInURLs=_flag;
};

//--------------------------------------------------------------------
-(NSDate*)expirationDateForIDCookies
{
  return [NSDate dateWithTimeIntervalSinceNow:timeOut];
};

//--------------------------------------------------------------------
-(BOOL)storesIDsInCookies
{
  //OK
  return storesIDsInCookies;
};

//--------------------------------------------------------------------
-(void)setStoresIDsInCookies:(BOOL)_flag
{
  //OK
  LOGObjectFnStart();
  storesIDsInCookies=_flag;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(BOOL)isDistributionEnabled
{
  return isDistributionEnabled;
};

//--------------------------------------------------------------------
-(void)setDistributionEnabled:(BOOL)_flag
{
  LOGObjectFnStart();
  isDistributionEnabled=_flag;
  LOGObjectFnStop();
};

@end

//====================================================================

@implementation GSWSession (GSWSessionA)

//--------------------------------------------------------------------
-(id)_initWithSessionID:(NSString*)_sessionID
{
  //OK
  GSWApplication* _application=nil;
  GSWStatisticsStore* _statisticsStore=nil;
  LOGObjectFnStart();
  _statisticsStore=[[GSWApplication application]statisticsStore];
  [_statisticsStore _applicationCreatedSession:self];

  ASSIGNCOPY(sessionID,_sessionID);
  NSDebugMLLog(@"sessions",@"_sessionID=%u",_sessionID);
  NSDebugMLLog(@"sessions",@"sessionID=%u",sessionID);
  if (sessionID)
	{
	  NSDebugMLLog(@"sessions",@"sessionIDCount=%u",[sessionID retainCount]);
	};
  _application=[GSWApplication application];
  //applic statisticsStore
  //applic _activeSessionsCount
  ASSIGN(birthDate,[NSDate date]);
  ASSIGN(statistics,[NSMutableArray array]);
  storesIDsInURLs=YES;
  [_application _finishInitializingSession:self];
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
  return isTerminating;
};

//--------------------------------------------------------------------
//	terminate
-(void)terminate 
{
  //OK
  NSString* _sessionID=nil;
  NSNotification* _notification=nil;
  LOGObjectFnStart();

  isTerminating=YES;
  _sessionID=[self sessionID];
  [[NSNotificationCenter defaultCenter] postNotificationName:GSWNotification__SessionDidTimeOutNotification[GSWebNamingConv]
                                        object:_sessionID];
  //goto => GSWApp _sessionDidTimeOutNotification:
  //call GSWApp _discountTerminatedSession
  //call GSWApp statisticsStore
  //call statstore _sessionTerminating:self
  LOGObjectFnStop();
};
// componentDefinition _notifyObserversForDyingComponent:Main component
//....

//--------------------------------------------------------------------
//	timeOut

-(NSTimeInterval)timeOut
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"timeOut=%ld",(long)timeOut);
  LOGObjectFnStop();
  return timeOut;
};

//--------------------------------------------------------------------
//	setTimeOut:

-(void)setTimeOut:(NSTimeInterval)_timeOut
{
  NSDebugMLLog(@"sessions",@"_timeOut=%ld",(long)_timeOut);
  timeOut=_timeOut;
};

@end

//====================================================================
@implementation GSWSession (GSWSessionDebugging)

//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)format_,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWSession (GSWSessionD)

//--------------------------------------------------------------------
-(void)_debugWithString:(NSString*)_string
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================

@implementation GSWSession (GSWPageManagement)

//--------------------------------------------------------------------
-(void)savePage:(GSWComponent*)page_
{
  //OK
  GSWContext* _context=nil;
  BOOL _pageReplaced=NO;
  BOOL _pageChanged=NO;
  LOGObjectFnStart();
  NSAssert(page_,@"No Page");
  _context=[self context];
  _pageReplaced=[_context _pageReplaced];
  if (!_pageReplaced)
	[_context _pageChanged];
  [self _savePage:page_
		forChange:_pageChanged || _pageReplaced]; //??


/*
  NSData* data=[NSArchiver archivedDataWithRootObject:page_];
  NSDebugMLLog(@"sessions",@"savePage data=%@",data);
  [pageCache setObject:data
			 forKey:[[self context] contextID]//TODO
			 withDuration:60*60];//TODO
*/
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWComponent*)restorePageForContextID:(NSString*)contextID_
{
  //OK
  GSWComponent* _page=nil;
  NSArray* _contextArray=nil;
  GSWTransactionRecord* _transactionRecord=nil;
  unsigned int _stackIndex=0;
  unsigned int _contextArrayIndex=0;
  LOGObjectFnStart();
  GSWLogAssertGood(self);
  NSAssert(contextID_,@"No contextID");
  NSAssert([contextID_ length]>0,@"contextID empty");
  NSDebugMLLog(@"sessions",@"contextID=%@",contextID_);

  if ([permanentPageCache objectForKey:contextID_])
	{
	  _page=[self _permanentPageWithContextID:contextID_];
	}
  else
	{
	  _transactionRecord=[contextRecords objectForKey:contextID_];
	  NSDebugMLLog(@"sessions",@"_transactionRecord=%@",_transactionRecord);
	  if (_transactionRecord)
		{
		  NSDebugMLLog(@"sessions",@"_transactionRecord2=%@",_transactionRecord);
		  _page=[_transactionRecord responsePage];
		  GSWLogAssertGood(_page);
		};
	  NSDebugMLLog(@"sessions",@"_transactionRecord3=%@",_transactionRecord);
	  NSDebugMLLog(@"sessions",@"_page 1=%@",_page);
	  _contextArray=[self _contextArrayForContextID:contextID_
						  stackIndex:&_stackIndex
						  contextArrayIndex:&_contextArrayIndex];
	  NSDebugMLLog(@"sessions",@"_page 2=%@",_page);
	  if (_contextArray)
		{
		  if (_stackIndex!=([contextArrayStack count]-1))
			{
			  [contextArrayStack addObject:_contextArray];
			  [contextArrayStack removeObjectAtIndex:_stackIndex];
			  //TODO faire pareil avec _contextArray ?
			};
		};
	};
  NSAssert(self,@"self");
  NSDebugMLLog(@"sessions",@"currentContext=%@",currentContext);
  NSDebugMLLog(@"sessions",@"_page 3=%@",_page);
  [_page awakeInContext:currentContext];
  NSDebugMLLog(@"sessions",@"_page 4=%@",_page);
  LOGObjectFnStop();
  return _page;
};

//--------------------------------------------------------------------
//NDFN
-(uint)permanentPageCacheSize
{
  return [GSWApp permanentPageCacheSize];
};

//--------------------------------------------------------------------
-(void)savePageInPermanentCache:(GSWComponent*)page_
{
  GSWContext* _context=nil;
  NSMutableDictionary* _permanentPageCache=nil;
  unsigned int _permanentPageCacheSize=0;
  NSString* _contextID=nil;
  LOGObjectFnStart();
  _context=[self context];
  _permanentPageCache=[self _permanentPageCache];
  _permanentPageCacheSize=[self permanentPageCacheSize];
  while([permanentContextIDArray count]>0 && [permanentContextIDArray count]>=_permanentPageCacheSize)
	{
	  id _deletePage=nil;
	  NSString* _deleteContextID=nil;
	  [GSWApplication statusLogWithFormat:@"Deleting permanent cached Page"];
	  _deleteContextID=[permanentContextIDArray objectAtIndex:0];
	  GSWLogAssertGood(_deleteContextID);
	  [GSWApplication statusLogWithFormat:@"permanentContextIDArray=%@",permanentContextIDArray];
	  [GSWApplication statusLogWithFormat:@"contextID=%@",_deleteContextID];
	  NSDebugMLLog(@"sessions",@"_deleteContextID=%@",_deleteContextID);
	  NSDebugMLLog(@"sessions",@"[permanentContextIDArray objectAtIndex:0]=%@",[permanentContextIDArray objectAtIndex:0]);
	  NSDebugMLLog(@"sessions",@"[permanentContextIDArray objectAtIndex:0] retainCount=%d",(int)[[permanentContextIDArray objectAtIndex:0] retainCount]);
	  [permanentContextIDArray removeObjectAtIndex:0];
	  _deletePage=[contextRecords objectForKey:_deleteContextID];
	  GSWLogAssertGood(_deletePage);
	  [GSWApplication statusLogWithFormat:@"delete page of class=%@",[_deletePage class]];
	  [_permanentPageCache removeObjectForKey:_deleteContextID];
	};
  _contextID=[_context contextID];
  NSAssert(_contextID,@"No contextID");

  if ([permanentContextIDArray containsObject:_contextID])
	{
	  LOGSeriousError(@"page of class %@ contextID %@ already in permanent cache stack",
					  [page_ class],
					  _contextID);
	  [permanentContextIDArray removeObject:_contextID];
	  if (![_permanentPageCache objectForKey:_contextID])
		{
		  LOGSeriousError0(@"but not present in cache");
		};
	}
  else if ([_permanentPageCache objectForKey:_contextID])
	{
	  LOGSeriousError(@"page of class %@ contextID %@ in permanent cache but not in stack",
					  [page_ class],
					  _contextID);
	};

  [_permanentPageCache setObject:page_
					   forKey:_contextID];
  [permanentContextIDArray addObject:_contextID];
  //TODO
  {
	int i=0;
	id __object=nil;
	id __contextID=nil;
	for(i=0;i<[permanentContextIDArray count];i++)
	  {
		__contextID=[permanentContextIDArray objectAtIndex:i];
		__object=[_permanentPageCache objectForKey:__contextID];
		[GSWApplication statusLogWithFormat:@"%d contextID=%@ page class=%@",i,__contextID,[__object class]];
	  };
  };
  if ([permanentContextIDArray count]!=[_permanentPageCache count])
	{
	  LOGSeriousError(@"[permanentContextIDArray count] %d != [permanentPageCache count] %d",
					  (int)[permanentContextIDArray count],
					  (int)[_permanentPageCache count]);
	};
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWSession (GSWSessionF)

//--------------------------------------------------------------------
-(void)clearCookieFromResponse:(GSWResponse*)_response
{
  NSString* _domainForIDCookies=nil;
  NSString* _sessionID=nil;
  LOGObjectFnStart();
  _domainForIDCookies=[self domainForIDCookies];
  _sessionID=[self sessionID];
  [_response addCookie:[GSWCookie cookieWithName:GSWKey_SessionID[GSWebNamingConv]
								 value:_sessionID
								 path:_domainForIDCookies
								 domain:nil
								 expires:[self expirationDateForIDCookies]
								 isSecure:NO]];
  [_response addCookie:[GSWCookie cookieWithName:GSWKey_InstanceID[GSWebNamingConv]
								 value:@"-1" //TODO
								 path:_domainForIDCookies
								 domain:nil
								 expires:[self expirationDateForIDCookies]
								 isSecure:NO]];

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendCookieToResponse:(GSWResponse*)_response
{
  //OK
  LOGObjectFnStart();
  if ([self storesIDsInCookies])
	{
	  //TODO VERIFY
	  NSString* _domainForIDCookies=nil;
	  NSString* _sessionID=nil;
	  _domainForIDCookies=[self domainForIDCookies];
	  _sessionID=[self sessionID];
	  [_response addCookie:[GSWCookie cookieWithName:GSWKey_SessionID[GSWebNamingConv]
									  value:_sessionID
									  path:_domainForIDCookies
									  domain:nil
									  expires:[self expirationDateForIDCookies]
									  isSecure:NO]];
	  
	  [_response addCookie:[GSWCookie cookieWithName:GSWKey_InstanceID[GSWebNamingConv]
									  value:@"1" //TODO
									  path:_domainForIDCookies
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
  [GarbageCollector collectGarbages];
  DESTROY(autoreleasePool);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_createAutoreleasePool
{
  //OK
  LOGObjectFnStart();
  if (!autoreleasePool)
	autoreleasePool=[NSAutoreleasePool new];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWComponent*)_permanentPageWithContextID:(NSString*)_contextID
{
  //OK
  GSWComponent* _page=nil;
  LOGObjectFnStart();
  _page=[permanentPageCache objectForKey:_contextID];
  LOGObjectFnStop();
  return _page;
};

//--------------------------------------------------------------------
-(NSMutableDictionary*)_permanentPageCache
{
  //OK
  LOGObjectFnStart();
  if (!permanentPageCache)
	permanentPageCache=[NSMutableDictionary new];
  if (!permanentContextIDArray)
	permanentContextIDArray=[NSMutableArray new];
  LOGObjectFnStop();
  return permanentPageCache;
};

//--------------------------------------------------------------------
-(GSWContext*)_contextIDMatchingContextID:(NSString*)_contextID
						 requestSenderID:(NSString*)_senderID
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
  GSWContext* _context=nil;
  if (contextArrayStack)
	{
	  unsigned int _stackIndex=0;
	  unsigned int _contextArrayIndex=0;
	  NSArray* _contextArray=[self _contextArrayForContextID:_contextID
								   stackIndex:&_stackIndex
								   contextArrayIndex:&_contextArrayIndex];
	};
  //TODO!!
  return _context;
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
-(NSArray*)_contextArrayForContextID:(NSString*)_contextID
						  stackIndex:(unsigned int*)_pStackIndex
				   contextArrayIndex:(unsigned int*)_pContextArrayIndex
{

  //OK
  NSArray* _contextArray=nil;
  unsigned int index=[contextArrayStack indexOfObject:_contextID];
  LOGObjectFnNotImplemented();	//TODOFN
  if (index==NSNotFound)
	{
	  if (_pStackIndex)
		*_pStackIndex=0;
	  if (_pContextArrayIndex)
		*_pContextArrayIndex=0;
	}
  else
	{
	  if (_pStackIndex)
		*_pStackIndex=index;
/*	  if (_pContextArrayIndex)
		*_pContextArrayIndex=XX;*/
	  _contextArray=[contextArrayStack objectAtIndex:index];
	};
  return _contextArray;
};

//--------------------------------------------------------------------
-(void)_replacePage:(GSWComponent*)_page
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
-(void)_savePage:(GSWComponent*)_page
	   forChange:(BOOL)_forChange
{
  //OK
  GSWResponse* _response=nil;
  BOOL _isClientCachingDisabled=NO;
  GSWTransactionRecord* _transactionRecord=nil;
  unsigned int _pageCacheSize=0;
  NSString* _contextID=nil;
  LOGObjectFnStart();
  NSAssert(_page,@"No Page");
  if ([contextArrayStack count]>0) // && _forChange!=NO ??
	[self _rearrangeContextArrayStack];

  // Get the response
  _response=[currentContext response];//currentContext??
  NSDebugMLLog(@"sessions",@"_response=%@",_response);
  _isClientCachingDisabled=[_response _isClientCachingDisabled]; //So what
  NSDebugMLLog(@"sessions",@"currentContext=%@",currentContext);

  // Create a new transaction record
  _transactionRecord=[[[GSWTransactionRecord alloc] 
						initWithResponsePage:_page
						context:currentContext]//currentContext??
											   autorelease];
  NSDebugMLLog(@"sessions",@"_transactionRecord=%@",_transactionRecord);

  // Retrieve the pageCacheSize
  _pageCacheSize=[self pageCacheSize];
  NSDebugMLLog(@"sessions",@"_pageCacheSize=%d",_pageCacheSize);

  // Create contextArrayStack and contextRecords if not already created
  if (!contextArrayStack)
	contextArrayStack=[NSMutableArray new];
  if (!contextRecords)
	contextRecords=[NSMutableDictionary new];
  NSDebugMLLog(@"sessions",@"contextArrayStack=%@",contextArrayStack);
  NSDebugMLLog(@"sessions",@"contextRecords=%@",contextRecords);

  // Remove some pages if page number greater than page cache size
  while([contextArrayStack count]>0 && [contextArrayStack count]>=_pageCacheSize)
	{
	  id _deleteRecord=nil;
	  NSString* _deleteContextID=nil;
	  [GSWApplication statusLogWithFormat:@"Deleting cached Page"];
	  _deleteContextID=[contextArrayStack objectAtIndex:0];
	  GSWLogAssertGood(_deleteContextID);
	  [GSWApplication statusLogWithFormat:@"contextArrayStack=%@",contextArrayStack];
	  [GSWApplication statusLogWithFormat:@"contextID=%@",_deleteContextID];
	  NSDebugMLLog(@"sessions",@"_deleteContextID=%@",_deleteContextID);
	  NSDebugMLLog(@"sessions",@"[contextArrayStack objectAtIndex:0]=%@",[contextArrayStack objectAtIndex:0]);
	  NSDebugMLLog(@"sessions",@"[contextArrayStack objectAtIndex:0] retainCount=%d",(int)[[contextArrayStack objectAtIndex:0] retainCount]);
	  [contextArrayStack removeObjectAtIndex:0];
	  _deleteRecord=[contextRecords objectForKey:_deleteContextID];
	  GSWLogAssertGood(_deleteRecord);
	  GSWLogAssertGood([_deleteRecord responsePage]);
	  [GSWApplication statusLogWithFormat:@"delete page of class=%@",[[_deleteRecord responsePage] class]];
	  [contextRecords removeObjectForKey:_deleteContextID];
	};

  GSWLogC("display _page");
  NSDebugMLLog(@"sessions",@"_page=%@",_page);
  NSDebugMLLog(@"sessions",@"_page context=%@",[_page context]);

  // Retrieve Page contextID
  _contextID=[[_page context]contextID];
  NSDebugMLLog(@"sessions",@"_contextID=%@",_contextID);
  NSAssert(_contextID,@"No contextID");

  if ([contextArrayStack containsObject:_contextID])
	{
	  LOGSeriousError(@"page of class %@ contextID %@ already in cache stack",
					  [_page class],
					  _contextID);
	  [contextArrayStack removeObject:_contextID];
	  if (![contextRecords objectForKey:_contextID])
		{
		  LOGSeriousError0(@"but not present in cache");
		};
	}
  else if ([contextRecords objectForKey:_contextID])
	{
	  LOGSeriousError(@"page of class %@ contextID %@ in cache but not in stack",
					  [_page class],
					  _contextID);
	};
  // Add the page contextID in contextArrayStack
  [contextArrayStack addObject:_contextID];

  // Add the record for this contextID in contextRecords
  [contextRecords setObject:_transactionRecord
				  forKey:_contextID];
  NSDebugMLLog(@"sessions",@"contextArrayStack=%@",contextArrayStack);
  //TODO
  {
	int i=0;
	GSWTransactionRecord* __trecord=nil;
	id __contextID=nil;
	for(i=0;i<[contextArrayStack count];i++)
	  {
		__contextID=[contextArrayStack objectAtIndex:i];
		__trecord=[contextRecords objectForKey:__contextID];
		[GSWApplication statusLogWithFormat:@"%d contextID=%@ page class=%@",i,__contextID,[[__trecord responsePage] class]];
	  };
  };
  if ([contextArrayStack count]!=[contextRecords count])
	{
	  LOGSeriousError(@"[contextArrayStack count] %d != [contextRecords count] %d",
					  (int)[contextArrayStack count],
					  (int)[contextRecords count]);
	};
  NSDebugMLLog(@"sessions",@"contextRecords=%@",contextRecords);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_saveCurrentPage
{
  //OK
  GSWComponent* _component=nil;
  unsigned int _pageCacheSize=0;
  LOGObjectFnStart();
  LOGObjectFnStart();
  NSAssert(currentContext,@"currentContext");
  _component=[currentContext _pageComponent];
  NSAssert(_component,@"_component");
  _pageCacheSize=[self pageCacheSize];
  if (_pageCacheSize>0)
	{
	  if ([_component _isPage])
		{
		  [self savePage:_component];
		};
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(int)_requestCounter
{
  //OK
  return requestCounter;
};

//--------------------------------------------------------------------
-(void)_contextDidIncrementContextID
{
  contextCounter++;
};

//--------------------------------------------------------------------
-(int)_contextCounter
{
  //OK
  return contextCounter;
};

//--------------------------------------------------------------------
-(void)_setContext:(GSWContext*)_context
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"_context=%p",(void*)_context);
  currentContext=_context;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)sleepInContext:(GSWContext*)_context
{
  //OK
  LOGObjectFnStart();
  [self sleep];
  [self _setContext:nil];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)awakeInContext:(GSWContext*)_context
{
  //OK
  LOGObjectFnStart();
  [self _setContext:_context];
  NSDebugMLLog(@"sessions",@"contextCounter=%i",contextCounter);
  if (_context)
	{
	  if ([[self class] __counterIncrementingEnabledFlag]) //??
		{
		  contextCounter++;
		  requestCounter++;
		};
	};
  NSDebugMLLog(@"sessions",@"contextCounter=%i",contextCounter);
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
  ASSIGN(languages,someLanguages);
};

//--------------------------------------------------------------------
-(NSArray*)languages
{
  //OK
  if (!languages)
	{
	  GSWContext* _context=[self context];
	  GSWRequest* _request=[_context request];
	  NSArray* _languages=[_request browserLanguages];
	  [self setLanguages:_languages];
	};
  return languages;
};

@end

//====================================================================
@implementation GSWSession (GSWComponentStateManagement)

//--------------------------------------------------------------------
//	objectForKey:
-(id)objectForKey:(NSString*)key_ 
{
  id _object=nil;
  LOGObjectFnStart();
  _object=[componentState objectForKey:key_];
  NSDebugMLLog(@"sessions",@"key_=%@ _object=%@",key_,_object);
  LOGObjectFnStop();
  return _object;
};

//--------------------------------------------------------------------
//	setObject:forKey:
-(void)setObject:(id)object_
		  forKey:(NSString*)key_ 
{
  LOGObjectFnStart();
  if (!componentState)
	componentState=[NSMutableDictionary new];
  NSDebugMLLog(@"sessions",@"key_=%@ object_=%@",key_,object_);
  [componentState setObject:object_
				  forKey:key_];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)removeObjectForKey:(NSString*)key_
{
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"key_=%@",key_);
  [componentState removeObjectForKey:key_];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(NSMutableDictionary*)componentState
{
  return componentState;
};
@end

//====================================================================
@implementation GSWSession (GSWEnterpriseObjects)

//--------------------------------------------------------------------
-(EOEditingContext*)defaultEditingContext
{
#if GDL2
  if(editingContext == nil)
    {
      ASSIGN(editingContext, [[[EOEditingContext alloc] init] autorelease]);
    }
#endif

  return editingContext;
};

//--------------------------------------------------------------------
-(void)setDefaultEditingContext:(EOEditingContext*)_editingContext
{
  ASSIGN(editingContext,_editingContext);
};

@end

//====================================================================
@implementation GSWSession (GSWRequestHandling)

//--------------------------------------------------------------------
-(GSWContext*)context
{
  return currentContext;
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
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_ 
{
  //OK
  GSWElement* _pageElement=nil;
  GSWComponent* _pageComponent=nil;
  LOGObjectFnStart();
  _pageElement=[context_ _pageElement];
  _pageComponent=[context_ _pageComponent];
  [context_ _setCurrentComponent:_pageComponent]; //_pageElement ??
  [_pageComponent takeValuesFromRequest:request_
				  inContext:context_]; //_pageComponent ??
  [context_ _setCurrentComponent:nil];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	invokeActionForRequest:inContext:
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_ 
{
  GSWElement* _element=nil;
  GSWElement* _pageElement=nil;
  GSWComponent* _pageComponent=nil;
  LOGObjectFnStart();
  NS_DURING
	{
	  _pageElement=[context_ _pageElement];
	  _pageComponent=[context_ _pageComponent];
	  [context_ _setCurrentComponent:_pageComponent]; //_pageElement ??
	  _element=[_pageComponent invokeActionForRequest:request_
							   inContext:context_]; //_pageComponent
	  [context_ _setCurrentComponent:nil];
	  if (!_element)
		_element=[context_ page]; //??
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
  return _element;
};

//--------------------------------------------------------------------
//	appendToResponse:inContext:
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_ 
{
  //OK
  GSWStatisticsStore* _statisticsStore=nil;
  NSString* _logFile=nil;
  GSWSession* _session=nil;
  GSWComponent* _page=nil;
  NSString* _pageName=nil;
  NSString* _description=nil;
  GSWElement* _pageElement=nil;
  GSWComponent* _pageComponent=nil;
  LOGObjectFnStart();
  _statisticsStore=[[GSWApplication application] statisticsStore];
  _pageElement=[context_ _pageElement];
  _pageComponent=[context_ _pageComponent];
  [context_ _setCurrentComponent:_pageComponent]; //_pageElement ??
  [_pageComponent appendToResponse:response_
				  inContext:context_]; //_pageComponent??
  [context_ _setCurrentComponent:nil];
  _session=[context_ existingSession];
  [_session appendCookieToResponse:response_];
  [_statisticsStore recordStatisticsForResponse:response_
					inContext:context_];
  [_statisticsStore descriptionForResponse:response_
					inContext:context_];
  _logFile=[_statisticsStore logFile];
  if (_logFile)
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
  return isAllowedToViewStatistics;
};

//--------------------------------------------------------------------
-(void)_allowToViewStatistics
{
  isAllowedToViewStatistics=YES;
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
  return birthDate;
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
+(void)__setContextCounterIncrementingEnabled:(BOOL)_flag
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
