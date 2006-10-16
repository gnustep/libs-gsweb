/** GSWApplication.h - <title>GSWeb: Class GSWApplication</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

// $Id$

#ifndef _GSWApplication_h__
	#define _GSWApplication_h__

GSWEB_EXPORT void
GSWApplicationSetDebugSetOption(NSString* opt);

GSWEB_EXPORT int
WOApplicationMain(NSString* applicationClassName,
		  int argc, const char *argv[]);

GSWEB_EXPORT int
GSWApplicationMain(NSString* applicationClassName,
		   int argc, const char *argv[]);

GSWEB_EXPORT NSString* globalApplicationClassName;
GSWEB_EXPORT int GSWebNamingConv;//GSWNAMES_INDEX or WONAMES_INDEX

#define GSWebNamingConvInversed		\
	(GSWebNamingConv==GSWNAMES_INDEX ? WONAMES_INDEX : GSWNAMES_INDEX)

#define GSWebNamingConvForRound(r)	\
	((r)==0 ? GSWebNamingConv : 	\
	  (GSWebNamingConv==GSWNAMES_INDEX ? WONAMES_INDEX : GSWNAMES_INDEX))

GSWEB_EXPORT BOOL WOStrictFlag;
//====================================================================
@interface GSWApplication : NSObject <NSLocking>
{
  NSArray* _adaptors;
  GSWSessionStore* _sessionStore;
  GSWMultiKeyDictionary* _componentDefinitionCache;
  NSTimeInterval _timeOut;
  NSDate* _startDate;
  NSDate* _lastAccessDate;
  NSTimer* _timer;
//  GSWContext* context;        // being deprecated
  GSWStatisticsStore* _statisticsStore;
  GSWResourceManager* _resourceManager;
  NSDistantObject* _remoteMonitor;
  NSConnection* _remoteMonitorConnection;
  NSString* _instanceNumber;
  NSMutableDictionary* _requestHandlers;
  GSWRequestHandler* _defaultRequestHandler;
@public //TODO-NOW REMOVE
  NSRecursiveLock* _selfLock;
#ifndef NDEBUG
  int _selfLockn;
  NSThread *_selfLock_thread_id;
#endif
  NSLock* _globalLock;
#ifndef NDEBUG
  int _globalLockn;
  NSThread *_globalLock_thread_id;
#endif
  NSAutoreleasePool* _globalAutoreleasePool;
  unsigned _pageCacheSize;
  unsigned _permanentPageCacheSize;
  int _activeSessionsCount;
  int _minimumActiveSessionsCount;
  BOOL _pageRecreationEnabled;
  BOOL _pageRefreshOnBacktrackEnabled;
  BOOL _terminating;
  BOOL _dynamicLoadingEnabled;
  BOOL _printsHTMLParserDiagnostics;
  BOOL _refusingNewSessions;
  BOOL _shouldDieWhenRefusing;
  BOOL _refusingNewClients;
  BOOL _refuseThisRequest;
  BOOL _isMultiThreaded;
  BOOL _isMTProtected;
  BOOL _timedRunLoop;
  BOOL _isTracingEnabled;
  BOOL _isTracingAssignmentsEnabled;
  BOOL _isTracingObjectiveCMessagesEnabled;
  BOOL _isTracingScriptedMessagesEnabled;
  BOOL _isTracingStatementsEnabled;
  NSRunLoop* _currentRunLoop;
  NSDate* _runLoopDate;
  NSTimer* _initialTimer;
  NSLock* _activeSessionsCountLock;

  GSWLifebeatThread* _lifebeatThread;
  id _recorder;
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
-(BOOL)isTaskDaemon;
-(NSString*)name;
-(NSString*)description;
-(void)setPageRefreshOnBacktrackEnabled:(BOOL)flag;

-(void)registerRequestHandlers;
-(void)unlock;
-(void)lock;
-(void)unlockRequestHandling;
-(void)lockRequestHandling;

-(NSString*)defaultRequestHandlerClassName;
-(Class)defaultRequestHandlerClass;
@end

//====================================================================
@interface GSWApplication (GSWApplicationA)
-(void)becomesMultiThreaded;
@end

//====================================================================
@interface GSWApplication (GSWApplicationB)
-(NSString*)_webserverConnectURL;
-(NSString*)_directConnectURL;
-(NSString*)_applicationExtension;
@end

//====================================================================
@interface GSWApplication (GSWApplicationC)
-(void)_resetCacheForGeneration;
-(void)_resetCache;
@end

//====================================================================
@interface GSWApplication (GSWApplicationD)

-(GSWComponentDefinition*) _componentDefinitionWithName:(NSString*)aName
                                              languages:(NSArray*)languages;
-(GSWComponentDefinition*)lockedComponentDefinitionWithName:(NSString*)aName
                                                  languages:(NSArray*)languages;
-(GSWComponentDefinition*)lockedLoadComponentDefinitionWithName:(NSString*)aName
                                                       language:(NSString*)language;
-(NSArray*)lockedComponentBearingFrameworks;
-(NSArray*)lockedInitComponentBearingFrameworksFromBundleArray:(NSArray*)bundles;

@end

//====================================================================
@interface GSWApplication (GSWApplicationE)
-(Class)contextClass;
-(GSWContext*)createContextForRequest:(GSWRequest*)aRequest;

-(Class)responseClass;
-(GSWResponse*)createResponseInContext:(GSWContext*)aContext;

-(Class)requestClass;
-(GSWRequest*)createRequestWithMethod:(NSString*)aMethod
                                  uri:(NSString*)anURL
                          httpVersion:(NSString*)aVersion
                              headers:(NSDictionary*)headers
                              content:(NSData*)content
                             userInfo:(NSDictionary*)userInfo;

-(GSWResourceManager*)createResourceManager;
-(GSWStatisticsStore*)createStatisticsStore;
-(GSWSessionStore*)createSessionStore;
-(void)_discountTerminatedSession;
-(void)_finishInitializingSession:(GSWSession*)aSession;
-(GSWSession*)_initializeSessionInContext:(GSWContext*)aContext;
-(int)lockedDecrementActiveSessionCount;
-(int)lockedIncrementActiveSessionCount;
-(int)_activeSessionsCount;

@end

//====================================================================
@interface GSWApplication (GSWApplicationF)
-(void)_setContext:(GSWContext*)aContext;
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

-(NSString*)_newLocationForRequest:(GSWRequest*)aRequest;
-(void)_connectionDidDie:(id)unknown;
-(BOOL)_shouldKill;
-(void)_setShouldKill:(BOOL)flag;
-(void)_synchronizeInstanceSettingsWithMonitor:(id)aMonitor;
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
-(GSWAdaptor*)adaptorWithName:(NSString*)aName
                    arguments:(NSDictionary*)someArguments;

@end

//====================================================================
@interface GSWApplication (GSWCacheManagement)

-(BOOL)isCachingEnabled;
-(void)setCachingEnabled:(BOOL)flag;
@end

//====================================================================
@interface GSWApplication (GSWSessionManagement)

-(GSWSessionStore*)sessionStore;
-(void)setSessionStore:(GSWSessionStore*)sessionStore;

-(GSWSession*)createSessionForRequest:(GSWRequest*)aRequest;
-(GSWSession*)_createSessionForRequest:(GSWRequest*)aRequest;
-(Class)_sessionClass;
-(Class)sessionClass;//NDFN
-(GSWSession*)restoreSessionWithID:(NSString*)aSessionID
                         inContext:(GSWContext*)aContext;
-(GSWSession*)_restoreSessionWithID:(NSString*)aSessionID
                          inContext:(GSWContext*)aContext;
-(void)saveSessionForContext:(GSWContext*)aContext;
@end

//====================================================================
@interface GSWApplication (GSWPageManagement)

-(unsigned int)pageCacheSize;
-(void)setPageCacheSize:(unsigned int)aSize;
-(unsigned)permanentPageCacheSize;
-(void)setPermanentPageCacheSize:(unsigned)aSize;
-(BOOL)isPageRefreshOnBacktrackEnabled;
-(void)setPageRefreshOnBacktrackEnabled:(BOOL)flag;
-(GSWComponent*)pageWithName:(NSString*)aName
                  forRequest:(GSWRequest*)aRequest;
-(GSWComponent*)pageWithName:(NSString*)aName
                   inContext:(GSWContext*)aContext;
-(NSString*)defaultPageName;//NDFN
@end

//====================================================================
@interface GSWApplication (GSWElementCreation)

-(GSWElement*)dynamicElementWithName:(NSString *)aName
                        associations:(NSDictionary*)someAssociations
                            template:(GSWElement*)templateElement
                           languages:(NSArray*)languages;
-(GSWElement*)lockedDynamicElementWithName:(NSString*)aName
                              associations:(NSDictionary*)someAssociations
                                  template:(GSWElement*)templateElement
                                 languages:(NSArray*)languages;
@end

//====================================================================
@interface GSWApplication (GSWRunning)
-(NSRunLoop*)runLoop;
-(void)threadWillExit;//NDFN
-(void)run;
-(BOOL)runOnce;
-(void)setTimeOut:(NSTimeInterval)aTimeInterval;
-(NSTimeInterval)timeOut;
-(void)terminate;
-(BOOL)isTerminating;

-(void)_scheduleApplicationTimerForTimeInterval:(NSTimeInterval)aTimeInterval;

-(NSDate*)lastAccessDate;//NDFN
-(NSDate*)startDate;//NDFN

-(void)lockedAddTimer:(NSTimer*)aTimer;//NDFN
-(void)addTimer:(NSTimer*)aTimer;//NDFN
-(void)_setNextCollectionCount:(int)_count;
-(void)_sessionDidTimeOutNotification:(NSNotification*)notification_;
-(void)_openInitialURL;
-(void)_openURL:(NSString*)_url;
@end

//====================================================================
@interface GSWApplication (GSWRequestHandling)
-(GSWResponse*)dispatchRequest:(GSWRequest*)aRequest;
-(void)awake;
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext;
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext;

-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext;
-(void)_setRecordingHeadersToResponse:(GSWResponse*)aResponse
                           forRequest:(GSWRequest*)aRequest
                            inContext:(GSWContext*)aContext;
-(void)sleep;
@end

//====================================================================
@interface GSWApplication (GSWErrorHandling)
-(GSWResponse*)handleException:(NSException*)exception
                     inContext:(GSWContext*)aContext;
-(GSWResponse*)handlePageRestorationErrorInContext:(GSWContext*)aContext;
-(GSWResponse*)_handlePageRestorationErrorInContext:(GSWContext*)aContext;
-(GSWResponse*)handleSessionCreationErrorInContext:(GSWContext*)aContext;
-(GSWResponse*)_handleSessionCreationErrorInContext:(GSWContext*)aContext;
-(GSWResponse*)handleSessionRestorationErrorInContext:(GSWContext*)aContext;
-(GSWResponse*)_handleSessionRestorationErrorInContext:(GSWContext*)aContext;
-(GSWResponse*)handleActionRequestErrorWithRequest:(GSWRequest*)aRequest
                                         exception:(NSException*)exception
                                            reason:(NSString*)reason
                                    requestHanlder:(GSWActionRequestHandler*)requestHandler
                                   actionClassName:(NSString*)actionClassName
                                        actionName:(NSString*)actionName
                                       actionClass:(Class)actionClass
                                      actionObject:(GSWAction*)actionObject;
@end

//====================================================================
@interface GSWApplication (GSWConveniences)
+(void)_setApplication:(GSWApplication*)application;
+(GSWApplication*)application;
@end

//====================================================================
@interface GSWApplication (GSWHTMLTemplateParsingDebugging)
-(BOOL)printsHTMLParserDiagnostics;
-(void)setPrintsHTMLParserDiagnostics:(BOOL)flag;
@end

//====================================================================
@interface GSWApplication (GSWScriptedObjectSupport)
-(Class)scriptedClassWithPath:(NSString*)path;
-(Class)scriptedClassWithPath:(NSString*)path
                     encoding:(NSStringEncoding)encoding;
-(Class)_classWithScriptedClassName:(NSString*)aName
                          languages:(NSArray*)languages;
-(void)_setClassFromNameResolutionEnabled:(BOOL)flag;
@end

//====================================================================
@interface GSWApplication (GSWLibrarySupport)
-(Class)libraryClassWithPath:(NSString*)path;//NDFN
@end

//====================================================================
@interface GSWApplication (GSWDebugging)
-(void)debugWithString:(NSString*)string;
-(void)debugWithFormat:(NSString*)format
             arguments:(va_list)someArgumentsu;
-(void)debugWithFormat:(NSString*)formatString,...;
+(void)debugWithFormat:(NSString*)formatString,...;

-(void)logString:(NSString*)string;
+(void)logString:(NSString*)string;

-(void)logWithFormat:(NSString*)aFormat,...;
+(void)logWithFormat:(NSString*)aFormat,...;

-(void)logWithFormat:(NSString*)formatString
           arguments:(va_list)arguments;

-(void)logErrorString:(NSString*)string;
+(void)logErrorString:(NSString*)string;
-(void)logErrorWithFormat:(NSString*)aFormat,...;

+(void)logErrorWithFormat:(NSString*)aFormat,...;
-(void)logErrorWithFormat:(NSString*)formatString
                arguments:(va_list)arguments;

-(void)trace:(BOOL)flag;
-(void)traceAssignments:(BOOL)flag;
-(void)traceObjectiveCMessages:(BOOL)flag;
-(void)traceScriptedMessages:(BOOL)flag;
-(void)traceStatements:(BOOL)flag;
+(void)logTakeValueForDeclarationNamed:(NSString*)aDeclarationName
                                  type:(NSString*)aDeclarationType
                          bindingNamed:(NSString*)aBindingName
                associationDescription:(NSString*)anAssociationDescription
                                 value:(id)aValue;
+(void)logSetValueForDeclarationNamed:(NSString*)aDeclarationName
                                 type:(NSString*)aDeclarationType
                         bindingNamed:(NSString*)aBindingName
               associationDescription:(NSString*)anAssociationDescription
                                value:(id)aValue;

-(void)logTakeValueForDeclarationNamed:(NSString*)aDeclarationName
                                  type:(NSString*)aDeclarationType
                          bindingNamed:(NSString*)aBindingName
                associationDescription:(NSString*)anAssociationDescription
                                 value:(id)aValue;

-(void)logSetValueForDeclarationNamed:(NSString*)aDeclarationName
                                 type:(NSString*)aDeclarationType
                         bindingNamed:(NSString*)aBindingName
			   associationDescription:(NSString*)anAssociationDescription
                                value:(id)aValue;
+(void)logSynchronizeComponentToParentForValue:(id)value_
                                   association:(GSWAssociation*)anAssociation
                                   inComponent:(NSObject*)aComponent;
+(void)logSynchronizeParentToComponentForValue:(id)aValue
                                   association:(GSWAssociation*)anAssociation
                                   inComponent:(NSObject*)aComponent;

-(void)_setTracingAspect:(id)unknwon
                 enabled:(BOOL)enabled;
-(void)debugAdaptorThreadExited;
@end

//====================================================================
//NDFN
//Same as GSWDebugging but it print messages on stdout AND call GSWDebugging methods
@interface GSWApplication (GSWDebuggingStatus)

-(void)statusDebugWithString:(NSString*)aString;
-(void)statusDebugWithFormat:(NSString*)aFormat
                   arguments:(va_list)arguments;

-(void)statusDebugWithFormat:(NSString*)aFormat,...;
+(void)statusDebugWithFormat:(NSString*)aFormat,...;

-(void)statusLogString:(NSString*)string;
+(void)statusLogString:(NSString*)string;

-(void)statusLogWithFormat:(NSString*)aFormat,...;
+(void)statusLogWithFormat:(NSString*)aFormat,...;

-(void)statusLogWithFormat:(NSString*)aFormat
                 arguments:(va_list)arguments;

-(void)statusLogErrorString:(NSString*)string;
+(void)statusLogErrorString:(NSString*)string;

-(void)statusLogErrorWithFormat:(NSString*)aFormat,...;
+(void)statusLogErrorWithFormat:(NSString*)aFormat,...;

-(void)statusLogErrorWithFormat:(NSString*)aFormat
                      arguments:(va_list)arguments;
@end

//====================================================================
@interface GSWApplication (GSWStatisticsSupport)
-(void)setStatisticsStore:(GSWStatisticsStore*)statisticsStore;
-(NSDictionary*)statistics;//bycopy
-(GSWStatisticsStore*)statisticsStore;
@end

//====================================================================
@interface GSWApplication (MonitorableApplication)
-(BOOL)monitoringEnabled;
-(int)activeSessionsCount;
-(int)minimumActiveSessionsCount;
-(void)setMinimumActiveSessionsCount:(int)aCount;
-(BOOL)isRefusingNewSessions;
-(void)refuseNewSessions:(BOOL)flag;
-(NSTimeInterval)_refuseNewSessionsTimeInterval;
-(void)logToMonitorWithFormat:(NSString*)aFormat;
-(void)terminateAfterTimeInterval:(NSTimeInterval)aTimeInterval;
@end

//====================================================================
@interface GSWApplication (GSWResourceManagerSupport)
-(void)setResourceManager:(GSWResourceManager*)resourceManager;
-(GSWResourceManager*)resourceManager;
@end

//====================================================================
@interface GSWApplication (RequestDispatching)
-(GSWRequestHandler*)defaultRequestHandler;

-(void)setDefaultRequestHandler:(GSWRequestHandler*)handler;

-(void)registerRequestHandler:(GSWRequestHandler*)handler
                       forKey:(NSString*)aKey;

-(void)removeRequestHandlerForKey:(NSString*)requestHandlerKey;

-(NSArray*)registeredRequestHandlerKeys;

-(GSWRequestHandler*)requestHandlerForKey:(NSString*)aKey;

-(GSWRequestHandler*)handlerForRequest:(GSWRequest*)aRequest;
@end

//====================================================================
@interface GSWApplication (GSWApplicationDefaults)
+(void)_initRegistrationDomainDefaults;
+(void)_initUserDefaultsKeys;

-(void)_initAdaptorsWithUserDefaults:(NSUserDefaults*)userDefault;
-(NSDictionary*)_argsDictionaryWithUserDefaults:(NSUserDefaults*)userDefault;

-(void)setContextClassName:(NSString*)className;
-(NSString*)contextClassName;
-(void)setResponseClassName:(NSString*)className;
-(NSString*)responseClassName;
-(void)setRequestClassName:(NSString*)className;
-(NSString*)requestClassName;
@end

//====================================================================
@interface GSWApplication (UserDefaults)
+(NSArray*)loadFrameworks;
+(void)setLoadFrameworks:(NSArray*)frameworks;
+(BOOL)isDebuggingEnabled;
+(void)setDebuggingEnabled:(BOOL)flag;
+(BOOL)autoOpenInBrowser;
+(void)setAutoOpenInBrowser:(BOOL)flag;
+(BOOL)isDirectConnectEnabled;
+(void)setDirectConnectEnabled:(BOOL)flag;
+(NSString*)cgiAdaptorURL;
+(void)setCGIAdaptorURL:(NSString*)url;
+(BOOL)isCachingEnabled;
+(void)setCachingEnabled:(BOOL)flag;
+(NSString*)applicationBaseURL;
+(void)setApplicationBaseURL:(NSString*)baseURL;
+(NSString*)frameworksBaseURL;
+(void)setFrameworksBaseURL:(NSString*)baseURL;
+(NSString*)recordingPath;
+(void)setRecordingPath:(NSString*)path;
+(NSArray*)projectSearchPath;
+(void)setProjectSearchPath:(NSArray*)pathArray;
+(BOOL)isMonitorEnabled;
+(void)setMonitorEnabled:(BOOL)flag;
+(NSString*)monitorHost;
+(void)setMonitorHost:(NSString*)hostName;
+(NSString*)SMTPHost;
+(void)setSMTPHost:(NSString*)hostName;
+(NSString*)adaptor;
+(void)setAdaptor:(NSString*)adaptorName;
+(NSNumber*)port;
+(void)setPort:(NSNumber*)port;
+(id)listenQueueSize;
+(void)setListenQueueSize:(id)aSize;
+(id)workerThreadCount;
+(void)setWorkerThreadCount:(id)workerThreadCount;
+(NSArray*)additionalAdaptors;
+(void)setAdditionalAdaptors:(NSArray*)adaptorList;
+(BOOL)includeCommentsInResponses;
+(void)setIncludeCommentsInResponses:(BOOL)flag;
+(NSString*)componentRequestHandlerKey;
+(void)setComponentRequestHandlerKey:(NSString*)aKey;
+(NSString*)directActionRequestHandlerKey;
+(void)setDirectActionRequestHandlerKey:(NSString*)aKey;
+(NSString*)resourceRequestHandlerKey;
+(void)setResourceRequestHandlerKey:(NSString*)aKey;
+(NSString*)statisticsStoreClassName;
+(void)setStatisticsStoreClassName:(NSString*)name;
+(void)setSessionTimeOut:(NSNumber*)aTimeOut;
+(NSNumber*)sessionTimeOut;
@end

//====================================================================
@interface GSWApplication (GSWUserDefaults)
+(BOOL)isStatusDebuggingEnabled;//NDFN
+(void)setStatusDebuggingEnabled:(BOOL)flag;//NDFN
+(BOOL)isStatusLoggingEnabled;//NDFN
+(void)setStatusLoggingEnabled:(BOOL)flag;//NDFN
+(NSString*)outputPath;
+(void)setOutputPath:(NSString*)path;
+(BOOL)isLifebeatEnabled;
+(void)setLifebeatEnabled:(BOOL)flag;
+(NSString*)lifebeatDestinationHost;
+(void)setLifebeatDestinationHost:(NSString*)host;
+(int)lifebeatDestinationPort;
+(void)setLifebeatDestinationPort:(int)port;
+(NSTimeInterval)lifebeatInterval;
+(void)setLifebeatInterval:(NSTimeInterval)interval;
+(int)intPort;
+(void)setIntPort:(int)port;
+(NSString*)host;
+(void)setHost:(NSString*)host;
+(id)workerThreadCountMin;
+(void)setWorkerThreadCountMin:(id)workerThreadCount;
+(id)workerThreadCountMax;
+(void)setWorkerThreadCountMax:(id)workerThreadCount;
+(NSString*)streamActionRequestHandlerKey;
+(void)setStreamActionRequestHandlerKey:(NSString*)aKey;
+(NSString*)pingActionRequestHandlerKey;
+(void)setPingActionRequestHandlerKey:(NSString*)aKey;
+(NSString*)staticResourceRequestHandlerKey;
+(void)setStaticResourceRequestHandlerKey:(NSString*)aKey;
+(NSString*)resourceManagerClassName;
+(void)setResourceManagerClassName:(NSString*)name;
+(NSString*)sessionStoreClassName;
+(void)setSessionStoreClassName:(NSString*)name;
+(NSString*)recordingClassName;
+(void)setRecordingClassName:(NSString*)name;
+(Class)recordingClass;
+(void)setSessionTimeOutValue:(NSTimeInterval)aTimeOutValue;
+(NSTimeInterval)sessionTimeOutValue;
+(NSString*)debugSetConfigFilePath;//NDFN
+(void)setDebugSetConfigFilePath:(NSString*)debugSetConfigFilePath;//NDFN
+(void)setDefaultUndoStackLimit:(int)limit;
+(int)defaultUndoStackLimit;
+(BOOL)_lockDefaultEditingContext;
+(void)_setLockDefaultEditingContext:(BOOL)flag;
+(NSString*)acceptedContentEncoding;
+(NSArray*)acceptedContentEncodingArray;
+(void)setAcceptedContentEncoding:(NSString*)acceptedContentEncoding;
+(NSString*)defaultTemplateParser;//NDFN
+(void)setDefaultTemplateParser:(NSString*)defaultTemplateParser;//NDFN
+(BOOL)defaultDisplayExceptionPages;//NDFN
+(void)setDefaultDisplayExceptionPages:(BOOL)flag;//NDFN
+(void)_setAllowsCacheControlHeader:(BOOL)flag;
+(BOOL)_allowsCacheControlHeader;
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
+(void)_setLockDefaultEditingContext:(BOOL)flag;
+(id)_allowsConcurrentRequestHandling;
+(void)_setAllowsConcurrentRequestHandling:(id)unknown;

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
-(id)propListWithResourceNamed:(NSString*)aName
                        ofType:(NSString*)aType
                   inFramework:(NSString*)aFrameworkName
                     languages:(NSArray*)languages;
+(BOOL)createUnknownComponentClasses:(NSArray*)classes
                      superClassName:(NSString*)aSuperClassName;
+(void)addDynCreateClassName:(NSString*)aClassName
              superClassName:(NSString*)aSuperClassName;
//NDFN
-(NSString*)pathForResourceNamed:(NSString*)aName
                     inFramework:(NSString*)aFrameworkName
                       languages:(NSArray*)languages;
//NDFN
-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)aType 
                     inFramework:(NSString*)aFrameworkName
                       languages:(NSArray*)languages;

//NDFN
-(NSString*)urlForResourceNamed:(NSString*)aName
                    inFramework:(NSString*)aFrameworkName
                      languages:(NSArray*)languages
                        request:(GSWRequest*)aRequest;
//NDFN
-(NSString*)stringForKey:(NSString*)key_
            inTableNamed:(NSString*)aTableName
        withDefaultValue:(NSString*)defaultValue
             inFramework:(NSString*)aFrameworkName
               languages:(NSArray*)languages;
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aTableName
                      inFramework:(NSString*)aFrameworkName
                        languages:(NSArray*)languages;
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aTableName
                      inFramework:(NSString*)aFrameworkName
                        languages:(NSArray*)languages;
//NDFN
-(NSArray*)filterLanguages:(NSArray*)languages;
@end
//====================================================================
/*
@interface GSWApplication (GSWDeprecatedAPI)
-(GSWComponent*)pageWithName:(NSString*)aName; //OldFN
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
-(NSString*)pathForResourceNamed:(NSString*)aName
						   ofType:(NSString*)aType;
-(NSString*)urlForResourceNamed:(NSString*)aName
						  ofType:(NSString*)aType;
-(NSString*)stringForKey:(NSString*)key_
			inTableNamed:(NSString*)table_
		withDefaultValue:(NSString*)defaultValue_;
-(GSWResponse*)handleRequest:(GSWRequest*)aRequest;
-(GSWDynamicElement*)dynamicElementWithName:(NSString*)aName
							  associations:(NSDictionary*)associations_
								  template:(GSWElement*)templateElement_; //OldFN
@end
*/
GSWEB_EXPORT GSWApplication* GSWApp;
#endif //_GSWApplication_h__
