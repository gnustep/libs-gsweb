/* GSWApplication.h - GSWeb: Class GSWApplication
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

#ifndef _GSWApplication_h__
	#define _GSWApplication_h__

extern void GSWApplicationSetDebugSetOption(NSString* opt_);
extern int WOApplicationMain(NSString* applicationClassName,
                             int argc,
                             const char *argv[]);
extern int GSWApplicationMain(NSString* applicationClassName,
							  int argc,
							  const char *argv[]);
extern NSString* globalApplicationClassName;
extern int GSWebNamingConv;//GSWNAMES_INDEX or WONAMES_INDEX
#define GSWebNamingConvInversed		(GSWebNamingConv==GSWNAMES_INDEX ? WONAMES_INDEX : GSWNAMES_INDEX)
#define GSWebNamingConvForRound(r)	((r)==0 ? GSWebNamingConv : (GSWebNamingConv==GSWNAMES_INDEX ? WONAMES_INDEX : GSWNAMES_INDEX))

extern BOOL WOStrictFlag;
//====================================================================
@interface GSWApplication : NSObject <NSLocking>
{
  NSArray* adaptors;
  GSWSessionStore* sessionStore;
  GSWMultiKeyDictionary* componentDefinitionCache;
  NSTimeInterval timeOut;
  NSTimer* timer;
//  GSWContext* context;        // being deprecated
  GSWStatisticsStore* statisticsStore;
  GSWResourceManager* resourceManager;
  NSDistantObject* remoteMonitor;
  NSConnection* remoteMonitorConnection;
  NSString* instanceNumber;
  NSMutableDictionary* requestHandlers;
  GSWRequestHandler* defaultRequestHandler;
@public //TODO-NOW REMOVE
  NSRecursiveLock* selfLock;
#ifndef NDEBUG
  int selfLockn;
  objc_thread_t selfLock_thread_id;
#endif
  NSLock* globalLock;
#ifndef NDEBUG
  int globalLockn;
  objc_thread_t globalLock_thread_id;
#endif
  NSAutoreleasePool* globalAutoreleasePool;
  unsigned pageCacheSize;
  unsigned permanentPageCacheSize;
  int activeSessionsCount;
  int minimumActiveSessionsCount;
  BOOL pageRecreationEnabled;
  BOOL pageRefreshOnBacktrackEnabled;
  BOOL terminating;
  BOOL dynamicLoadingEnabled;
  BOOL printsHTMLParserDiagnostics;
  BOOL refusingNewSessions;
  BOOL shouldDieWhenRefusing;
  BOOL refusingNewClients;
  BOOL refuseThisRequest;
  BOOL isMultiThreaded;
  BOOL isMTProtected;
  BOOL timedRunLoop;
  BOOL isTracingEnabled;
  BOOL isTracingAssignmentsEnabled;
  BOOL isTracingObjectiveCMessagesEnabled;
  BOOL isTracingScriptedMessagesEnabled;
  BOOL isTracingStatementsEnabled;
  NSRunLoop* currentRunLoop;
  NSDate* runLoopDate;
  NSTimer* initialTimer;
  NSLock* activeSessionsCountLock;
}

-(void)dealloc;
-(id)init;


-(BOOL)allowsConcurrentRequestHandling;
-(BOOL)adaptorsDispatchRequestsConcurrently;
-(BOOL)isConcurrentRequestHandlingEnabled;
-(BOOL)isRequestHandlingLocked;
-(void)lockRequestHandling;
-(void)unlockRequestHandling;
-(void)lock;
-(void)unlock;


-(NSString*)baseURL;

-(NSString*)number;
-(NSString*)path;
-(NSString*)name;
-(NSString*)description;
-(void)setPageRefreshOnBacktrackEnabled:(BOOL)flag;

-(void)registerRequestHandlers;
-(void)_initAdaptorsWithUserDefaults:(NSUserDefaults*)_userDefault;
-(NSDictionary*)_argsDictionaryWithUserDefaults:(NSUserDefaults*)_userDefault;
-(void)unlock;
-(void)lock;
-(void)unlockRequestHandling;
-(void)lockRequestHandling;

+(void)_initRegistrationDomainDefaults;
+(void)_initUserDefaultsKeys;
@end

//====================================================================
@interface GSWApplication (GSWApplicationA)
-(void)becomesMultiThreaded;
@end

//====================================================================
@interface GSWApplication (GSWApplicationB)
-(id)_webserverConnectURL;
-(NSString*)_directConnectURL;
-(id)_applicationExtension;
@end

//====================================================================
@interface GSWApplication (GSWApplicationC)
-(void)_resetCacheForGeneration;
-(void)_resetCache;
@end

//====================================================================
@interface GSWApplication (GSWApplicationD)

-(GSWComponentDefinition*)componentDefinitionWithName:(NSString*)_name
											languages:(NSArray*)_languages;
-(GSWComponentDefinition*)lockedComponentDefinitionWithName:(NSString*)_name
												  languages:(NSArray*)_languages;
-(GSWComponentDefinition*)lockedLoadComponentDefinitionWithName:(NSString*)_name
													   language:(NSString*)_language;
-(NSArray*)lockedComponentBearingFrameworks;
-(NSArray*)lockedInitComponentBearingFrameworksFromBundleArray:(NSArray*)_bundles;

@end

//====================================================================
@interface GSWApplication (GSWApplicationE)
-(void)_discountTerminatedSession;
-(void)_finishInitializingSession:(GSWSession*)_session;
-(GSWSession*)_initializeSessionInContext:(GSWContext*)context_;
-(int)lockedDecrementActiveSessionCount;
-(int)lockedIncrementActiveSessionCount;
-(int)_activeSessionsCount;

@end

//====================================================================
@interface GSWApplication (GSWApplicationF)
-(void)_setContext:(GSWContext*)context_;
// Internal Use only
-(GSWContext*)_context;
@end

//====================================================================
@interface GSWApplication (GSWApplicationG)

-(BOOL)_isDynamicLoadingEnabled;
-(void)_disableDynamicLoading;


@end

//====================================================================
@interface GSWApplication (GSWApplicationI)

-(BOOL)_isPageRecreationEnabled;
-(void)_touchPrincipalClasses;

@end

//====================================================================
@interface GSWApplication (GSWApplicationJ)

-(id)_newLocationForRequest:(GSWRequest*)_request;
-(void)_connectionDidDie:(id)_unknown;
-(BOOL)_shouldKill;
-(void)_setShouldKill:(BOOL)_flag;
-(void)_synchronizeInstanceSettingsWithMonitor:(id)_monitor;
-(BOOL)_setupForMonitoring;
-(id)_remoteMonitor;
-(NSString*)_monitorHost;
-(NSString*)_monitorApplicationName;
-(void)_terminateFromMonitor;
@end

//====================================================================
@interface GSWApplication (GSWApplicationK)
-(void)_validateAPI;
@end

//====================================================================
@interface GSWApplication (GSWAdaptorManagement)

-(NSArray*)adaptors;
-(GSWAdaptor*)adaptorWithName:(NSString*)name_
				   arguments:(NSDictionary*)someArguments;

@end

//====================================================================
@interface GSWApplication (GSWCacheManagement)

-(BOOL)isCachingEnabled;
-(void)setCachingEnabled:(BOOL)flag_;
@end

//====================================================================
@interface GSWApplication (GSWSessionManagement)

-(GSWSessionStore*)sessionStore;
-(void)setSessionStore:(GSWSessionStore*)sessionStore_;

-(GSWSession*)createSessionForRequest:(GSWRequest*)_request;
-(GSWSession*)_createSessionForRequest:(GSWRequest*)_request;
-(Class)_sessionClass;
-(GSWSession*)restoreSessionWithID:(NSString*)_sessionID
						inContext:(GSWContext*)context_;
-(GSWSession*)_restoreSessionWithID:(NSString*)_sessionID
						inContext:(GSWContext*)context_;
-(void)saveSessionForContext:(GSWContext*)context_;
-(void)_saveSessionForContext:(GSWContext*)context_;
@end

//====================================================================
@interface GSWApplication (GSWPageManagement)

-(unsigned int)pageCacheSize;
-(void)setPageCacheSize:(unsigned int)size_;
-(unsigned)permanentPageCacheSize;
-(void)setPermanentPageCacheSize:(unsigned)size_;
-(BOOL)isPageRefreshOnBacktrackEnabled;
-(void)setPageRefreshOnBacktrackEnabled:(BOOL)_flag;
-(GSWComponent*)pageWithName:(NSString*)name_
				 forRequest:(GSWRequest*)request_;
-(GSWComponent*)pageWithName:(NSString*)name_
				  inContext:(GSWContext*)context_;
-(NSString*)defaultPageName;//NDFN
-(GSWComponent*)_pageWithName:(NSString*)name_
				  inContext:(GSWContext*)context_;
@end

//====================================================================
@interface GSWApplication (GSWElementCreation)

-(GSWElement*)dynamicElementWithName:(NSString *)name_
						associations:(NSDictionary*)associations_
							template:(GSWElement*)templateElement_
						   languages:(NSArray*)languages_;
-(GSWElement*)lockedDynamicElementWithName:(NSString *)name_
							  associations:(NSDictionary*)associations_
								  template:(GSWElement*)templateElement_
								 languages:(NSArray*)languages_;
@end

//====================================================================
@interface GSWApplication (GSWRunning)
-(NSRunLoop*)runLoop;
-(void)threadWillExit;//NDFN
-(void)run;
-(BOOL)runOnce;
-(void)setTimeOut:(NSTimeInterval)timeInterval_;
-(NSTimeInterval)timeOut;
-(void)terminate;
-(BOOL)isTerminating;

-(void)_scheduleApplicationTimerForTimeInterval:(NSTimeInterval)timeInterval_;
-(void)addTimer:(NSTimer*)timer_;//NDFN
-(void)cancelInitialTimer;
-(void)handleInitialTimer;
-(void)_setNextCollectionCount:(int)_count;
-(void)_sessionDidTimeOutNotification:(NSNotification*)notification_;
-(void)_openInitialURL;
-(void)_openURL:(NSString*)_url;
@end

//====================================================================
@interface GSWApplication (GSWRequestHandling)
-(GSWResponse*)dispatchRequest:(GSWRequest*)request_;
-(void)awake;
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						   inContext:(GSWContext*)context_;
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_;

-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;
-(void)sleep;
@end

//====================================================================
@interface GSWApplication (GSWErrorHandling)
-(GSWResponse*)handleException:(NSException*)exception_
					 inContext:(GSWContext*)context_;
-(GSWResponse*)_handleException:(NSException*)exception_
					  inContext:(GSWContext*)context_;
-(GSWResponse*)handlePageRestorationErrorInContext:(GSWContext*)context_;
-(GSWResponse*)_handlePageRestorationErrorInContext:(GSWContext*)context_;
-(GSWResponse*)handleSessionCreationErrorInContext:(GSWContext*)context_;
-(GSWResponse*)_handleSessionCreationErrorInContext:(GSWContext*)context_;
-(GSWResponse*)handleSessionRestorationErrorInContext:(GSWContext*)context_;
-(GSWResponse*)_handleSessionRestorationErrorInContext:(GSWContext*)context_;

@end

//====================================================================
@interface GSWApplication (GSWConveniences)
+(void)_setApplication:(GSWApplication*)_application;
+(GSWApplication*)application;
@end

//====================================================================
@interface GSWApplication (GSWHTMLTemplateParsingDebugging)
-(BOOL)printsHTMLParserDiagnostics;
-(void)setPrintsHTMLParserDiagnostics:(BOOL)flag_;
@end

//====================================================================
@interface GSWApplication (GSWScriptedObjectSupport)
-(Class)scriptedClassWithPath:(NSString*)path_;
-(Class)scriptedClassWithPath:(NSString*)path_
					 encoding:(NSStringEncoding)encoding_;
-(Class)_classWithScriptedClassName:(NSString*)_name
						  languages:(NSArray*)_languages;
-(void)_setClassFromNameResolutionEnabled:(BOOL)_flag;
@end

//====================================================================
@interface GSWApplication (GSWLibrarySupport)
-(Class)libraryClassWithPath:(NSString*)path_;//NDFN
@end

//====================================================================
@interface GSWApplication (GSWDebugging)
-(void)debugWithString:(NSString*)_string;
-(void)debugWithFormat:(NSString*)_format
			 arguments:(va_list)someArgumentsu;
-(void)debugWithFormat:(NSString*)formatString_,...;
+(void)debugWithFormat:(NSString*)formatString_,...;
-(void)logWithFormat:(NSString*)format_,...;
+(void)logWithFormat:(NSString*)format_,...;
-(void)logWithFormat:(NSString*)formatString_
		   arguments:(va_list)arguments_;
-(void)logErrorWithFormat:(NSString*)format_,...;
+(void)logErrorWithFormat:(NSString*)format_,...;
-(void)logErrorWithFormat:(NSString*)formatString_
				arguments:(va_list)arguments_;
-(void)trace:(BOOL)flag_;
-(void)traceAssignments:(BOOL)flag_;
-(void)traceObjectiveCMessages:(BOOL)flag_;
-(void)traceScriptedMessages:(BOOL)flag_;
-(void)traceStatements:(BOOL)flag_;
+(void)logTakeValueForDeclarationNamed:(NSString*)declarationName_
								  type:(NSString*)declarationType_
						  bindingNamed:(NSString*)bindingName_
				associationDescription:(NSString*)associationDescription_
								 value:(id)value_;
+(void)logSetValueForDeclarationNamed:(NSString*)declarationName_
								 type:(NSString*)declarationType_
						 bindingNamed:(NSString*)bindingName_
			   associationDescription:(NSString*)associationDescription_
								value:(id)value_;

-(void)logTakeValueForDeclarationNamed:(NSString*)declarationName_
								  type:(NSString*)declarationType_
						  bindingNamed:(NSString*)bindingName_
				associationDescription:(NSString*)associationDescription_
								 value:(id)value_;

-(void)logSetValueForDeclarationNamed:(NSString*)declarationName_
								 type:(NSString*)declarationType_
						 bindingNamed:(NSString*)bindingName_
			   associationDescription:(NSString*)associationDescription_
								value:(id)value_;
+(void)logSynchronizeComponentToParentForValue:(id)value_
								   association:(GSWAssociation*)association_
								   inComponent:(NSObject*)component_;
+(void)logSynchronizeParentToComponentForValue:(id)value_
								   association:(GSWAssociation*)association_
								   inComponent:(NSObject*)component_;

-(void)_setTracingAspect:(id)_unknwon
				 enabled:(BOOL)_enabled;
@end

//====================================================================
//NDFN
//Same as GSWDebugging but it print messages on stdout AND call GSWDebugging methods
@interface GSWApplication (GSWDebuggingStatus)

-(void)statusDebugWithString:(NSString*)string_;
-(void)statusDebugWithFormat:(NSString*)format_
				   arguments:(va_list)arguments_;
-(void)statusDebugWithFormat:(NSString*)format_,...;
+(void)statusDebugWithFormat:(NSString*)format_,...;
-(void)statusLogWithFormat:(NSString*)format_,...;
+(void)statusLogWithFormat:(NSString*)format_,...;
-(void)statusLogWithFormat:(NSString*)format_
				 arguments:(va_list)arguments_;
-(void)statusLogErrorWithFormat:(NSString*)format_,...;
+(void)statusLogErrorWithFormat:(NSString*)format_,...;
-(void)statusLogErrorWithFormat:(NSString*)format_
					  arguments:(va_list)arguments_;
@end

//====================================================================
@interface GSWApplication (GSWStatisticsSupport)
-(void)setStatisticsStore:(GSWStatisticsStore*)statisticsStore_;
-(NSDictionary*)statistics;//bycopy
-(GSWStatisticsStore*)statisticsStore;
@end

//====================================================================
@interface GSWApplication (MonitorableApplication)
-(BOOL)monitoringEnabled;
-(int)activeSessionsCount;
-(int)minimumActiveSessionsCount;
-(void)setMinimumActiveSessionsCount:(int)count_;
-(BOOL)isRefusingNewSessions;
-(void)refuseNewSessions:(BOOL)flag;
-(void)logToMonitorWithFormat:(NSString*)format_;
-(void)terminateAfterTimeInterval:(NSTimeInterval)timeInterval_;
@end

//====================================================================
@interface GSWApplication (GSWResourceManagerSupport)
-(void)setResourceManager:(GSWResourceManager*)resourceManager_;
-(GSWResourceManager*)resourceManager;
@end

//====================================================================
@interface GSWApplication (RequestDispatching)
-(GSWRequestHandler*)defaultRequestHandler;

-(void)setDefaultRequestHandler:(GSWRequestHandler*)handler_;

-(void)registerRequestHandler:(GSWRequestHandler*)handler_
					   forKey:(NSString*)key_;

-(void)removeRequestHandlerForKey:(NSString*)requestHandlerKey_;

-(NSArray*)registeredRequestHandlerKeys;

-(GSWRequestHandler*)requestHandlerForKey:(NSString*)key_;

-(GSWRequestHandler*)handlerForRequest:(GSWRequest*)request_;
@end

//====================================================================
@interface GSWApplication (UserDefaults)
+(NSArray*)loadFrameworks;
+(void)setLoadFrameworks:(NSArray*)frameworks_;
+(BOOL)isDebuggingEnabled;
+(void)setDebuggingEnabled:(BOOL)flag_;
+(BOOL)isStatusDebuggingEnabled;//NDFN
+(void)setStatusDebuggingEnabled:(BOOL)flag_;//NDFN
+(BOOL)autoOpenInBrowser;
+(void)setAutoOpenInBrowser:(BOOL)flag_;
+(BOOL)isDirectConnectEnabled;
+(void)setDirectConnectEnabled:(BOOL)flag_;
+(NSString*)cgiAdaptorURL;
+(void)setCGIAdaptorURL:(NSString*)url_;
+(BOOL)isCachingEnabled;
+(void)setCachingEnabled:(BOOL)flag_;
+(NSString*)applicationBaseURL;
+(void)setApplicationBaseURL:(NSString*)baseURL_;
+(NSString*)frameworksBaseURL;
+(void)setFrameworksBaseURL:(NSString*)baseURL_;
+(NSString*)recordingPath;
+(void)setRecordingPath:(NSString*)path_;
+(NSArray*)projectSearchPath;
+(void)setProjectSearchPath:(NSArray*)pathArray_;
+(BOOL)isMonitorEnabled;
+(void)setMonitorEnabled:(BOOL)flag_;
+(NSString*)monitorHost;
+(void)setMonitorHost:(NSString*)hostName_;
+(NSString*)SMTPHost;
+(void)setSMTPHost:(NSString*)hostName_;
+(NSString*)adaptor;
+(void)setAdaptor:(NSString*)adaptorName_;
+(id)port;
+(void)setPort:(id)port_;
+(id)host;
+(void)setHost:(id)host_;
+(id)listenQueueSize;
+(void)setListenQueueSize:(id)listenQueueSize_;
+(id)workerThreadCount;
+(void)setWorkerThreadCount:(id)workerThreadCount_;
+(NSArray*)additionalAdaptors;
+(void)setAdditionalAdaptors:(NSArray*)adaptorList;
+(BOOL)includeCommentsInResponses;
+(void)setIncludeCommentsInResponses:(BOOL)flag_;
+(NSString*)componentRequestHandlerKey;
+(void)setComponentRequestHandlerKey:(NSString*)key_;
+(NSString*)directActionRequestHandlerKey;
+(void)setDirectActionRequestHandlerKey:(NSString*)key_;
+(NSString*)resourceRequestHandlerKey;
+(void)setResourceRequestHandlerKey:(NSString*)key_;
+(void)setSessionTimeOut:(id)timeOut_;
+(id)sessionTimeOut;
+(NSTimeInterval)sessionTimeOutValue;
+(NSString*)debugSetConfigFilePath;//NDFN
+(void)setDebugSetConfigFilePath:(NSString*)debugSetConfigFilePath_;//NDFN
+(NSString*)saveResponsesPath;//NDFN
+(void)setSaveResponsesPath:(NSString*)saveResponsesPath;//NDFN
@end

//====================================================================
@interface GSWApplication (GSWApplicationInternals)
+(NSDictionary*)_webServerConfigDictionary;
+(Class)_applicationClass;
+(Class)_compiledApplicationClass;
+(GSWRequestHandler*)_componentRequestHandler;
@end

//====================================================================
@interface GSWApplication (GSWApplicationClassB)
+(id)defaultModelGroup;
+(id)_modelGroupFromBundles:(id)_bundles;
@end

//====================================================================
@interface GSWApplication (GSWApplicationClassC)
-(NSDictionary*)mainBundleInfoDictionary;
+(NSDictionary*)mainBundleInfoDictionary;
-(NSDictionary*)bundleInfo;
+(NSDictionary*)bundleInfo;
-(NSBundle*)mainBundle;
+(NSBundle*)mainBundle;
@end

//====================================================================
@interface GSWApplication (GSWApplicationClassD)
+(int)_garbageCollectionRepeatCount;
+(BOOL)_lockDefaultEditingContext;
+(void)_setLockDefaultEditingContext:(BOOL)_flag;
+(id)_allowsConcurrentRequestHandling;
+(void)_setAllowsConcurrentRequestHandling:(id)_unknown;

@end

//====================================================================
@interface GSWApplication (GSWApplicationClassE)
+(int)_requestLimit;
+(int)_requestWindow;
+(BOOL)_multipleThreads;
+(BOOL)_multipleInstances;
+(void)_readLicenseParameters;
@end

//====================================================================
@interface GSWApplication (NDFN)
//NDFN
-(id)propListWithResourceNamed:(NSString*)name_
						ofType:(NSString*)type_
				   inFramework:(NSString*)frameworkName_
					 languages:(NSArray*)languages_;
+(BOOL)createUnknownComponentClasses:(NSArray*)classes_
					  superClassName:(NSString*)superClassName_;
+(void)addDynCreateClassName:(NSString*)className_
			  superClassName:(NSString*)superClassName_;
//NDFN
-(NSString*)pathForResourceNamed:(NSString*)name_
					 inFramework:(NSString*)frameworkName_
					   languages:(NSArray*)languages_;
//NDFN
-(NSString*)pathForResourceNamed:(NSString*)name_
						  ofType:(NSString*)type_ 
					 inFramework:(NSString*)frameworkName_
					   languages:(NSArray*)languages_;

//NDFN
-(NSString*)urlForResourceNamed:(NSString*)name_
					inFramework:(NSString*)frameworkName_
					  languages:(NSArray*)languages_
						request:(GSWRequest*)request_;
//NDFN
-(NSString*)stringForKey:(NSString*)key_
			inTableNamed:(NSString*)tableName_
		withDefaultValue:(NSString*)defaultValue_
			 inFramework:(NSString*)frameworkName_
			   languages:(NSArray*)languages_;
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)tableName_
					  inFramework:(NSString*)frameworkName_
						languages:(NSArray*)languages_;
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)tableName_
					  inFramework:(NSString*)frameworkName_
						languages:(NSArray*)languages_;
//NDFN
-(NSArray*)filterLanguages:(NSArray*)languages;
@end
//====================================================================
/*
@interface GSWApplication (GSWDeprecatedAPI)
-(GSWComponent*)pageWithName:(NSString*)name_; //OldFN
-(void)savePage:(GSWComponent*)page_;
-(GSWSession*)session;
-(GSWContext*)context;
-(GSWSession*)createSession;
-(GSWSession*)restoreSession;
-(void)saveSession:(GSWSession*)session_;

-(GSWResponse*)handleSessionCreationError;
-(GSWResponse*)handleSessionRestorationError;
-(GSWResponse*)handlePageRestorationError;
-(GSWResponse*)handleException:(NSException*)exception_;

-(GSWComponent*)restorePageForContextID:(NSString*)contextID_;
-(NSString*)pathForResourceNamed:(NSString*)name_
						   ofType:(NSString*)type_;
-(NSString*)urlForResourceNamed:(NSString*)name_
						  ofType:(NSString*)type_;
-(NSString*)stringForKey:(NSString*)key_
			inTableNamed:(NSString*)table_
		withDefaultValue:(NSString*)defaultValue_;
-(GSWResponse*)handleRequest:(GSWRequest*)request_;
-(GSWDynamicElement*)dynamicElementWithName:(NSString*)name_
							  associations:(NSDictionary*)associations_
								  template:(GSWElement*)templateElement_; //OldFN
@end
*/
extern GSWApplication* GSWApp;
#endif //_GSWApplication_h__
