/** GSWSession.h - <title>GSWeb: Class GSWSession</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
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

// $Id$

#ifndef _GSWSession_h__
	#define _GSWSession_h__

@interface GSWSession : NSObject <NSCoding,NSCopying>
{
@private
  NSString* _sessionID;
  NSAutoreleasePool* _autoreleasePool;
  NSTimeInterval _timeOut;
  NSMutableArray* _contextArrayStack;
  NSMutableDictionary* _contextRecords;
  EOEditingContext* _editingContext;
  NSArray* _languages;
  NSMutableDictionary* _componentState;
  NSDate* _birthDate;
  BOOL _wasTimedOut;
  NSMutableArray* _statistics;
  NSMutableString* _formattedStatistics;
  GSWContext* _currentContext;
  NSMutableDictionary* _permanentPageCache;
  NSMutableArray* _permanentContextIDArray;
  int _contextCounter;
  int _requestCounter;
  BOOL _isAllowedToViewStatistics;
  BOOL _isAllowedToViewEvents;
  BOOL _isTerminating;
  BOOL _isDistributionEnabled;
  BOOL _storesIDsInCookies;
  BOOL _storesIDsInURLs;
  BOOL _hasSessionLockedEditingContext;
};


+(NSString*)createSessionID;

-(NSString*)domainForIDCookies;
-(BOOL)storesIDsInURLs;
-(void)setStoresIDsInURLs:(BOOL)flag;
-(NSDate*)expirationDateForIDCookies;
-(BOOL)storesIDsInCookies;
-(void)setStoresIDsInCookies:(BOOL)flag;

/** Returns NO if URLs contains application number so requests are 
	directed to the specific application instance.
    Resturns YES if  URLs doesn't contain application number so requests 
    	can be directed to any instance (load balancing)
    Default value is NO
**/
-(BOOL)isDistributionEnabled;

/** Enables or disables application instance number in URLs.
    If flag is NO, URLs contains application number so requests are directed 
	to the specific application instance.
    If flag is YES, URLs doesn't contain application number so requests can 
	be directed to any instance (load balancing)
**/
-(void)setDistributionEnabled:(BOOL)flag;


-(NSString*)sessionID;
-(void)setSessionID:(NSString*)sessionID;
-(NSString*)description;


@end

//====================================================================
@interface GSWSession (GSWSessionA)
-(id)_initWithSessionID:(NSString*)aSessionID;

@end

//====================================================================
@interface GSWSession (GSWTermination)

-(void)terminate;
-(void)_terminateByTimeout;
-(BOOL)isTerminating;
-(void)setTimeOut:(NSTimeInterval)timeInterval;
-(NSTimeInterval)timeOut;

@end

//====================================================================
@interface GSWSession (GSWSessionDebugging)

-(void)debugWithFormat:(NSString*)format,...;

@end

//====================================================================
@interface GSWSession (GSWSessionD)

-(void)_debugWithString:(NSString*)string;

@end

//====================================================================
@interface GSWSession (GSWPageManagement)

-(void)savePage:(GSWComponent*)page;
-(GSWComponent*)restorePageForContextID:(NSString*)aContextID;
-(uint)permanentPageCacheSize;
-(void)savePageInPermanentCache:(GSWComponent*)page;

@end

//====================================================================
@interface GSWSession (GSWSessionF)

-(void)clearCookieFromResponse:(GSWResponse*)aResponse;
-(void)appendCookieToResponse:(GSWResponse*)aResponse;

@end

//====================================================================
@interface GSWSession (GSWSessionG)

-(void)_releaseAutoreleasePool;
-(void)_createAutoreleasePool;
-(GSWComponent*)_permanentPageWithContextID:(NSString*)aContextID;
-(NSMutableDictionary*)_permanentPageCache;
-(NSString*)_contextIDMatchingIDsInContext:(GSWContext*)aContext;
-(void)_rearrangeContextArrayStackForContextID:(NSString*)contextID;
-(NSMutableArray*)_contextArrayForContextID:(NSString*)aContextID
                                 stackIndex:(unsigned int*)pStackIndex
                          contextArrayIndex:(unsigned int*)pContextArrayIndex;
-(void)_replacePage:(GSWComponent*)page;
-(void)_savePage:(GSWComponent*)page
       forChange:(BOOL)forChange;
-(uint)pageCacheSize;
-(void)_saveCurrentPage;
-(int)_requestCounter;
-(void)_contextDidIncrementContextID;
-(int)_contextCounter;
-(void)_setContext:(GSWContext*)aContext;
-(void)sleepInContext:(GSWContext*)aContext;
-(void)awakeInContext:(GSWContext*)aContext; 

@end

//====================================================================
@interface GSWSession (GSWLocalization)

-(void)setLanguages:(NSArray*)languages;

/** GSWeb specific
Insert language language at the begining of session languages array 
**/
-(void)insertLanguage:(NSString*)language;

/** GSWeb specific
Add language language at the end of session languages array if language 
is not present
**/
-(void)addLanguage:(NSString*)language;

-(NSArray*)languages;
-(NSArray*)_languages;

/** GSWeb specific
Returns first element of languages or nil if languages is empty
**/
-(NSString*)firstLanguage;

@end

//====================================================================
@interface GSWSession (GSWComponentStateManagement)

-(void)setObject:(id)object
          forKey:(NSString*)key;

-(id)objectForKey:(NSString*)key;
-(void)removeObjectForKey:(NSString*)key;
-(NSMutableDictionary*)componentState;//NDFN
@end

//====================================================================
@interface GSWSession (GSWEnterpriseObjects)

-(EOEditingContext*)defaultEditingContext;
-(void)setDefaultEditingContext:(EOEditingContext*)editingContext;

@end

//====================================================================
@interface GSWSession (GSWRequestHandling)

-(GSWContext*)context;
-(void)awake;
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext;

-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext;

-(void)sleep;

@end

//====================================================================
@interface GSWSession (GSWStatistics)

-(NSArray*)statistics;
-(BOOL)_allowedToViewStatistics;
-(void)_allowToViewStatistics;
-(void)_setAllowedToViewStatistics:(BOOL)flag;
-(BOOL)validateStatisticsLogin:(NSString*)login
                  withPassword:(NSString*)password;
-(NSString*)_formattedStatistics;
-(NSDate*)_birthDate;
-(void)_setBirthDate:(NSDate*)birthDate;
@end

//====================================================================
@interface GSWSession (GSWEvents)

-(BOOL)_allowedToViewEvents;
-(void)_allowToViewEvents;
-(void)_setAllowedToViewEvents:(BOOL)flag;
-(BOOL)validateEventsLogin:(NSString*)login
              withPassword:(NSString*)password;
@end

//====================================================================
@interface GSWSession (GSWSessionN)

-(GSWApplication*)application;

@end

//====================================================================
@interface GSWSession (GSWSessionO)

-(void)_validateAPI;

@end

//====================================================================
@interface GSWSession (GSWSessionClassA)
+(void)__setContextCounterIncrementingEnabled:(BOOL)flag;
+(int)__counterIncrementingEnabledFlag;

@end
#endif
