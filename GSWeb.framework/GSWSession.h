/* GSWSession.h - GSWeb: Class GSWSession
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

#ifndef _GSWSession_h__
	#define _GSWSession_h__

@interface GSWSession : NSObject <NSCoding,NSCopying>
{
@private
  NSString* sessionID;
  NSAutoreleasePool* autoreleasePool;
  NSTimeInterval timeOut;
  NSMutableArray* contextArrayStack;
  NSMutableDictionary* contextRecords;
  EOEditingContext* editingContext;
  NSArray* languages;
  NSMutableDictionary* componentState;
  NSDate* birthDate;
  NSMutableArray* statistics;
  NSMutableString* formattedStatistics;
  GSWContext* currentContext;
  NSMutableDictionary* permanentPageCache;
  NSMutableArray* permanentContextIDArray;
  int contextCounter;
  int requestCounter;
  BOOL isAllowedToViewStatistics;
  BOOL isTerminating;
  BOOL isDistributionEnabled;
  BOOL storesIDsInCookies;
  BOOL storesIDsInURLs;
  BOOL hasSessionLockedEditingContext;
};


-(id)init;
-(void)dealloc;
-(id)copyWithZone:(NSZone *)zone;

-(NSString*)domainForIDCookies;
-(BOOL)storesIDsInURLs;
-(void)setStoresIDsInURLs:(BOOL)flag_;
-(NSDate*)expirationDateForIDCookies;
-(BOOL)storesIDsInCookies;
-(void)setStoresIDsInCookies:(BOOL)flag_;
-(BOOL)isDistributionEnabled;
-(void)setDistributionEnabled:(BOOL)flag_;
-(NSString*)sessionID;
-(NSString*)description;


@end

//====================================================================
@interface GSWSession (GSWSessionA)
-(id)_initWithSessionID:(NSString*)_sessionID;

@end

//====================================================================
@interface GSWSession (GSWTermination)

-(void)terminate;
-(BOOL)isTerminating;
-(void)setTimeOut:(NSTimeInterval)timeInterval;
-(NSTimeInterval)timeOut;

@end

//====================================================================
@interface GSWSession (GSWSessionDebugging)

-(void)debugWithFormat:(NSString*)format_, ...;

@end

//====================================================================
@interface GSWSession (GSWSessionD)

-(void)_debugWithString:(NSString*)_string;

@end

//====================================================================
@interface GSWSession (GSWPageManagement)

-(void)savePage:(GSWComponent*)page_;
-(GSWComponent*)restorePageForContextID:(NSString*)contextID_;
-(uint)permanentPageCacheSize;
-(void)savePageInPermanentCache:(GSWComponent*)page_;

@end

//====================================================================
@interface GSWSession (GSWSessionF)

-(void)clearCookieFromResponse:(GSWResponse*)response_;
-(void)appendCookieToResponse:(GSWResponse*)response_;

@end

//====================================================================
@interface GSWSession (GSWSessionG)

-(void)_releaseAutoreleasePool;
-(void)_createAutoreleasePool;
-(GSWComponent*)_permanentPageWithContextID:(NSString*)contextID_;
-(NSMutableDictionary*)_permanentPageCache;
-(GSWContext*)_contextIDMatchingContextID:(NSString*)contextID_
						 requestSenderID:(NSString*)_senderID;
-(void)_rearrangeContextArrayStack;
-(NSArray*)_contextArrayForContextID:(NSString*)contextID_
						 stackIndex:(unsigned int*)pStackIndex_
				  contextArrayIndex:(unsigned int*)pContextArrayIndex_;
-(void)_replacePage:(GSWComponent*)_page;
-(void)_savePage:(GSWComponent*)_page
	   forChange:(BOOL)_forChange;
-(uint)pageCacheSize;
-(void)_saveCurrentPage;
-(int)_requestCounter;
-(void)_contextDidIncrementContextID;
-(int)_contextCounter;
-(void)_setContext:(GSWContext*)context_;
-(void)sleepInContext:(GSWContext*)context_;
-(void)awakeInContext:(GSWContext*)context_; 

@end

//====================================================================
@interface GSWSession (GSWLocalization)

-(void)setLanguages:(NSArray*)languages_;
-(NSArray*)languages;

@end

//====================================================================
@interface GSWSession (GSWComponentStateManagement)

-(void)setObject:(id)object
		  forKey:(NSString*)key_;

-(id)objectForKey:(NSString*)key_;
-(void)removeObjectForKey:(NSString*)key_;
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
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext *)context_;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_;

-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;

-(void)sleep;

@end

//====================================================================
@interface GSWSession (GSWStatistics)

-(NSArray*)statistics;

@end

//====================================================================
@interface GSWSession (GSWSessionM)

-(BOOL)_allowedToViewStatistics;
-(void)_allowToViewStatistics;
-(id)_formattedStatistics;
-(NSDate*)_birthDate;

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
+(void)__setContextCounterIncrementingEnabled:(BOOL)flag_;
+(int)__counterIncrementingEnabledFlag;

@end
#endif
