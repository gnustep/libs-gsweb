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

@class GSWSessionStore;
@class GSWStatisticsStore;
@class GSWResourceManager;
@class GSWRequestHandler;
@class GSWLifebeatThread;
@class GSWSession;
@class GSWAdaptor;
@class GSWComponent;
@class GSWElement;
@class GSWResponse;
@class GSWAssociation;
@class GSWComponentDefinition;
@class GSWDictionary;
@class GSWActionRequestHandler;
@class GSWAction;

//====================================================================
/**
 * GSWApplication is the central class in GSWeb applications, serving as
 * the main application controller and coordinator. It manages the entire
 * web application lifecycle, including session management, request handling,
 * component creation, resource management, and adaptor coordination.
 * This class provides the foundational infrastructure for web applications,
 * handling multi-threading, caching, statistics collection, and debugging
 * facilities. It serves as the primary entry point for all web requests
 * and coordinates the interaction between various GSWeb components.
 */
@interface GSWApplication : NSObject <NSLocking>
{
  NSArray* _adaptors;
  GSWSessionStore* _sessionStore;
  GSWDictionary* _componentDefinitionCache;
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
  NSString*          _hostAddress;
@public //TODO-NOW REMOVE
  NSRecursiveLock* _selfLock;
#ifndef NDEBUG
  int _selfLockn;
  NSThread *_selfLock_thread_id;
#endif
  NSRecursiveLock* _globalLock;
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
  BOOL _allowsConcurrentRequestHandling;
  NSRunLoop* _currentRunLoop;
  NSDate* _runLoopDate;
  NSTimer* _initialTimer;
  NSLock* _activeSessionsCountLock;

  GSWLifebeatThread* _lifebeatThread;
  id _recorder;
}

/**
 * Returns the host address for this application instance.
 */
- (NSString*) hostAddress;

/**
 * Internal method to set the host address for this application instance.
 */
-(void) _setHostAddress:(NSString *) hostAdr;


/**
 * Determines whether the session should be restored on a clean entry
 * for the specified request.
 */
-(BOOL) shouldRestoreSessionOnCleanEntry:(GSWRequest*) aRequest;

/**
 * Returns whether the application allows concurrent request handling.
 */
-(BOOL)allowsConcurrentRequestHandling;

/**
 * Returns whether adaptors dispatch requests concurrently.
 */
-(BOOL)adaptorsDispatchRequestsConcurrently;

/**
 * Returns whether concurrent request handling is enabled.
 */
-(BOOL)isConcurrentRequestHandlingEnabled;

/**
 * Returns the recursive lock used for request handling synchronization.
 */
-(NSRecursiveLock *)requestHandlingLock;

/**
 * Returns whether request handling is currently locked.
 */
-(BOOL)isRequestHandlingLocked;

/**
 * Acquires a lock for thread-safe operations. This method provides
 * synchronization for multi-threaded request processing.
 */
-(void)lock;

/**
 * Releases the lock acquired by the lock method.
 */
-(void)unlock;


/**
 * Returns the base URL for this application, used for generating
 * absolute URLs in responses.
 */
-(NSString*)baseURL;

/**
 * Returns the application instance number as a string.
 */
-(NSString*)number;

/**
 * Returns the application path used for URL generation.
 */
-(NSString*)path;

/**
 * Returns whether this application instance is running as a task daemon.
 */
-(BOOL)isTaskDaemon;

/**
 * Returns the application name.
 */
-(NSString*)name;

/**
 * Returns a string description of the application.
 */
-(NSString*)description;

/**
 * Sets whether page refresh on backtrack is enabled for this application.
 */
-(void)setPageRefreshOnBacktrackEnabled:(BOOL)flag;

/**
 * Registers the default request handlers with the application.
 * This method sets up the standard handlers for component, direct action,
 * and resource requests.
 */
-(void)registerRequestHandlers;

/**
 * Returns the class name of the default request handler.
 */
-(NSString*)defaultRequestHandlerClassName;

/**
 * Returns the class object for the default request handler.
 */
-(Class)defaultRequestHandlerClass;

/**
 * Returns the key used for session ID in requests and URLs.
 */
- (NSString*) sessionIdKey;

/**
 * Returns the key used for instance ID in requests and URLs.
 */
- (NSString*) instanceIdKey;

/**
 * Configures the application to become multi-threaded, setting up
 * the necessary synchronization and threading infrastructure.
 */
-(void)becomesMultiThreaded;

/**
 * Internal method that returns the URL for connecting to the web server.
 */
-(NSString*)_webserverConnectURL;

/**
 * Internal method that returns the URL for direct connections to
 * the application, bypassing the web server.
 */
-(NSString*)_directConnectURL;

/**
 * Internal method that returns the file extension used for this
 * application type.
 */
-(NSString*)_applicationExtension;

/**
 * Internal method that resets the cache for the current generation.
 */
-(void)_resetCacheForGeneration;

/**
 * Internal method that completely resets all caches.
 */
-(void)_resetCache;

/**
 * Internal method that retrieves a component definition with the specified
 * name in the given languages. This method handles component lookup
 * and caching.
 */
-(GSWComponentDefinition*) _componentDefinitionWithName:(NSString*)aName
                                              languages:(NSArray*)languages;

/**
 * Retrieves a component definition with thread-safe locking for the
 * specified name and languages.
 */
-(GSWComponentDefinition*)lockedComponentDefinitionWithName:(NSString*)aName
                                                  languages:(NSArray*)languages;

/**
 * Loads a component definition with locking for the specified name
 * and language, creating it if necessary.
 */
-(GSWComponentDefinition*)lockedLoadComponentDefinitionWithName:(NSString*)aName
                                                       language:(NSString*)language;

/**
 * Returns an array of frameworks that contain components, using
 * thread-safe locking.
 */
-(NSArray*)lockedComponentBearingFrameworks;

/**
 * Initializes the list of component-bearing frameworks from the
 * provided bundle array with thread-safe locking.
 */
-(NSArray*)lockedInitComponentBearingFrameworksFromBundleArray:(NSArray*)bundles;

/**
 * Returns the class used for creating context objects.
 */
-(Class)contextClass;

/**
 * Creates a new context object for the specified request.
 */
-(GSWContext*)createContextForRequest:(GSWRequest*)aRequest;

//-(Class)responseClass;

/**
 * Creates a new response object within the specified context.
 */
-(GSWResponse*)createResponseInContext:(GSWContext*)aContext;

/**
 * Returns the class used for creating request objects.
 */
-(Class)requestClass;

/**
 * Creates a new resource manager instance for this application.
 */
-(GSWResourceManager*)createResourceManager;

/**
 * Creates a new statistics store instance for this application.
 */
-(GSWStatisticsStore*)createStatisticsStore;

/**
 * Creates a new session store instance for this application.
 */
-(GSWSessionStore*)createSessionStore;

/**
 * Internal method that decrements the count of terminated sessions.
 */
-(void)_discountTerminatedSession;

/**
 * Internal method that completes the initialization of a session
 * after it has been created.
 */
-(void)_finishInitializingSession:(GSWSession*)aSession;

/**
 * Internal method that initializes a session within the specified context.
 */
-(GSWSession*)_initializeSessionInContext:(GSWContext*)aContext;

/**
 * Internal method that returns the current count of active sessions.
 */
-(int)_activeSessionsCount;

/**
 * Internal method that sets the current context for the application.
 */
-(void)_setContext:(GSWContext*)aContext;

/**
 * Internal method that returns the current application context.
 */
-(GSWContext*)_context;

/**
 * Returns whether dynamic loading of classes and components is enabled.
 */
-(BOOL)_isDynamicLoadingEnabled;

/**
 * Disables dynamic loading of classes and components.
 */
-(void)_disableDynamicLoading;

/**
 * Returns whether page recreation is enabled for this application.
 */
-(BOOL)_isPageRecreationEnabled;

/**
 * Internal method that touches principal classes to ensure they are loaded.
 */
-(void)_touchPrincipalClasses;

/**
 * Internal method that generates a new location URL for the specified request,
 * typically used for redirects.
 */
-(NSString*)_newLocationForRequest:(GSWRequest*)aRequest;

/**
 * Internal method called when a connection dies or becomes unavailable.
 */
-(void)_connectionDidDie:(id)unknown;

/**
 * Internal method that determines whether the application should be killed.
 */
-(BOOL)_shouldKill;

/**
 * Internal method that sets whether the application should be killed.
 */
-(void)_setShouldKill:(BOOL)flag;

/**
 * Internal method that synchronizes instance settings with the monitor.
 */
-(void)_synchronizeInstanceSettingsWithMonitor:(id)aMonitor;

/**
 * Internal method that sets up monitoring capabilities for the application.
 */
-(BOOL)_setupForMonitoring;

/**
 * Internal method that returns the remote monitor object.
 */
-(id)_remoteMonitor;

/**
 * Internal method that returns the monitor host name.
 */
-(NSString*)_monitorHost;

/**
 * Internal method that returns the application name used for monitoring.
 */
-(NSString*)_monitorApplicationName;

/**
 * Internal method that terminates the application from the monitor.
 */
-(void)_terminateFromMonitor;

/**
 * Returns the array of adaptors configured for this application.
 */
-(NSArray*)adaptors;

/**
 * Creates and returns an adaptor with the specified name and arguments.
 * The arguments dictionary contains configuration parameters for the adaptor.
 */
-(GSWAdaptor*)adaptorWithName:(NSString*)aName
                    arguments:(NSDictionary*)someArguments;

/**
 * Returns whether caching is enabled for this application.
 */
-(BOOL)isCachingEnabled;

/**
 * Sets whether caching should be enabled for this application.
 */
-(void)setCachingEnabled:(BOOL)flag;

/**
 * Returns the session store used by this application for session management.
 */
-(GSWSessionStore*)sessionStore;

/**
 * Sets the session store to be used by this application.
 */
-(void)setSessionStore:(GSWSessionStore*)sessionStore;

/**
 * Creates a new session for the specified request.
 */
-(GSWSession*)createSessionForRequest:(GSWRequest*)aRequest;

/**
 * Internal method that creates a new session for the specified request.
 */
-(GSWSession*)_createSessionForRequest:(GSWRequest*)aRequest;

/**
 * Internal method that returns the class used for creating sessions.
 */
-(Class)_sessionClass;

/**
 * Returns the class used for creating sessions.
 */
-(Class)sessionClass;//NDFN

/**
 * Restores a session with the specified ID within the given context.
 */
-(GSWSession*)restoreSessionWithID:(NSString*)aSessionID
                         inContext:(GSWContext*)aContext;

//-(GSWSession*)_restoreSessionWithID:(NSString*)aSessionID
//                          inContext:(GSWContext*)aContext;

/**
 * Saves the session associated with the specified context.
 */
-(void)saveSessionForContext:(GSWContext*)aContext;

/**
 * Returns the current page cache size limit.
 */
-(unsigned int)pageCacheSize;

/**
 * Sets the page cache size limit for this application.
 */
-(void)setPageCacheSize:(unsigned int)aSize;

/**
 * Returns the permanent page cache size limit.
 */
-(unsigned)permanentPageCacheSize;

/**
 * Sets the permanent page cache size limit for this application.
 */
-(void)setPermanentPageCacheSize:(unsigned)aSize;

/**
 * Returns whether page refresh on backtrack is enabled.
 */
-(BOOL)isPageRefreshOnBacktrackEnabled;

/**
 * Sets whether page refresh on backtrack should be enabled.
 */
-(void)setPageRefreshOnBacktrackEnabled:(BOOL)flag;

/**
 * Creates and returns a page component with the specified name for the request.
 */
-(GSWComponent*)pageWithName:(NSString*)aName
                  forRequest:(GSWRequest*)aRequest;

/**
 * Creates and returns a page component with the specified name in the context.
 */
-(GSWComponent*)pageWithName:(NSString*)aName
                   inContext:(GSWContext*)aContext;

/**
 * Returns the name of the default page for this application.
 */
-(NSString*)defaultPageName;//NDFN

/**
 * Creates a dynamic element with the specified name, associations, template,
 * and languages.
 */
-(GSWElement*)dynamicElementWithName:(NSString *)aName
                        associations:(NSDictionary*)someAssociations
                            template:(GSWElement*)templateElement
                           languages:(NSArray*)languages;

/**
 * Creates a dynamic element with thread-safe locking for the specified
 * name, associations, template, and languages.
 */
-(GSWElement*)lockedDynamicElementWithName:(NSString*)aName
                              associations:(NSDictionary*)someAssociations
                                  template:(GSWElement*)templateElement
                                 languages:(NSArray*)languages;

/**
 * Returns the run loop used by this application for processing events.
 */
-(NSRunLoop*)runLoop;

/**
 * Called when a thread is about to exit, allowing for cleanup operations.
 */
-(void)threadWillExit;//NDFN

/**
 * Starts the main application run loop, processing requests indefinitely
 * until the application is terminated.
 */
-(void)run;

/**
 * Processes one iteration of the run loop, handling pending requests
 * and returning whether the application should continue running.
 */
-(BOOL)runOnce;

/**
 * Sets the timeout interval for various application operations.
 */
-(void)setTimeOut:(NSTimeInterval)aTimeInterval;

/**
 * Returns the current timeout interval for application operations.
 */
-(NSTimeInterval)timeOut;

/**
 * Initiates application termination, beginning the shutdown process.
 */
-(void)terminate;

/**
 * Returns whether the application is currently in the termination process.
 */
-(BOOL)isTerminating;

/**
 * Internal method that schedules the application timer for the specified
 * time interval.
 */
-(void)_scheduleApplicationTimerForTimeInterval:(NSTimeInterval)aTimeInterval;

/**
 * Returns the date of the last access to this application.
 */
-(NSDate*)lastAccessDate;//NDFN

/**
 * Returns the date when this application was started.
 */
-(NSDate*)startDate;//NDFN

/**
 * Adds a timer to the application with thread-safe locking.
 */
-(void)lockedAddTimer:(NSTimer*)aTimer;//NDFN

/**
 * Adds a timer to the application.
 */
-(void)addTimer:(NSTimer*)aTimer;//NDFN

/**
 * Internal method that sets the next garbage collection count.
 */
-(void)_setNextCollectionCount:(int)_count;

/**
 * Internal method called when a session timeout notification is received.
 */
-(void)_sessionDidTimeOutNotification:(NSNotification*)notification_;

/**
 * Internal method that opens the initial URL for the application.
 */
-(void)_openInitialURL;

/**
 * Internal method that opens the specified URL.
 */
-(void)_openURL:(NSString*)_url;

/**
 * Main request dispatching method that processes incoming requests
 * and returns appropriate responses.
 */
-(GSWResponse*)dispatchRequest:(GSWRequest*)aRequest;

/**
 * Called when the application awakens, typically at startup or
 * after initialization.
 */
-(void)awake;

-(id <GSWActionResults>)invokeActionForRequest:(GSWRequest*)aRequest
                                     inContext:(GSWContext*)aContext;

-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext;

-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext;

-(void)_setRecordingHeadersToResponse:(GSWResponse*)aResponse
                           forRequest:(GSWRequest*)aRequest
                            inContext:(GSWContext*)aContext;
-(void)sleep;

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

+(void)_setApplication:(GSWApplication*)application;
+(GSWApplication*)application;

-(BOOL)printsHTMLParserDiagnostics;
-(void)setPrintsHTMLParserDiagnostics:(BOOL)flag;

-(Class)scriptedClassWithPath:(NSString*)path;
-(Class)scriptedClassWithPath:(NSString*)path
                     encoding:(NSStringEncoding)encoding;
-(Class)_classWithScriptedClassName:(NSString*)aName
                          languages:(NSArray*)languages;
-(void)_setClassFromNameResolutionEnabled:(BOOL)flag;

-(Class)libraryClassWithPath:(NSString*)path;//NDFN

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

//NDFN
//Same as GSWDebugging but it print messages on stdout AND call GSWDebugging methods
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

-(void)setStatisticsStore:(GSWStatisticsStore*)statisticsStore;
-(NSDictionary*)statistics;//bycopy
-(GSWStatisticsStore*)statisticsStore;

-(BOOL)monitoringEnabled;
-(int)activeSessionsCount;
-(int)minimumActiveSessionsCount;
-(void)setMinimumActiveSessionsCount:(int)aCount;
-(BOOL)isRefusingNewSessions;
-(void)refuseNewSessions:(BOOL)flag;
-(NSTimeInterval)_refuseNewSessionsTimeInterval;
-(void)logToMonitorWithFormat:(NSString*)aFormat;
-(void)terminateAfterTimeInterval:(NSTimeInterval)aTimeInterval;

-(void)setResourceManager:(GSWResourceManager*)resourceManager;
-(GSWResourceManager*)resourceManager;

-(GSWRequestHandler*)defaultRequestHandler;

-(void)setDefaultRequestHandler:(GSWRequestHandler*)handler;

-(void)registerRequestHandler:(GSWRequestHandler*)handler
                       forKey:(NSString*)aKey;

-(void)removeRequestHandlerForKey:(NSString*)requestHandlerKey;

-(NSArray*)registeredRequestHandlerKeys;

-(GSWRequestHandler*)requestHandlerForKey:(NSString*)aKey;

-(GSWRequestHandler*)handlerForRequest:(GSWRequest*)aRequest;


//-(void)setResponseClassName:(NSString*)className;
//-(NSString*)responseClassName;
//-(void)setRequestClassName:(NSString*)className;
//-(NSString*)requestClassName;

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
//-(NSDictionary*)stringsTableNamed:(NSString*)aTableName
//                      inFramework:(NSString*)aFrameworkName
//                        languages:(NSArray*)languages;
//NDFN
//-(NSArray*)stringsTableArrayNamed:(NSString*)aTableName
//                      inFramework:(NSString*)aFrameworkName
//                        languages:(NSArray*)languages;
//NDFN
-(NSArray*)filterLanguages:(NSArray*)languages;
@end

GSWEB_EXPORT GSWApplication* GSWApp;

/* User Defaults. This is an interface in WO 4.x -- dw*/
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
+(NSString*)ajaxRequestHandlerKey;
+(void)setAjaxRequestHandlerKey:(NSString*)aKey;
+(NSString*)resourceRequestHandlerKey;
+(void)setResourceRequestHandlerKey:(NSString*)aKey;
+(NSString*)statisticsStoreClassName;
+(void)setStatisticsStoreClassName:(NSString*)name;
+(void)setSessionTimeOut:(NSNumber*)aTimeOut;
+(NSNumber*)sessionTimeOut;

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
+(void)setDefaultUndoStackLimit:(NSUInteger)limit;
+(NSUInteger)defaultUndoStackLimit;
+(BOOL)_lockDefaultEditingContext;
+(void)_setLockDefaultEditingContext:(BOOL)flag;
+(NSString*)defaultTemplateParser;//NDFN
+(void)setDefaultTemplateParser:(NSString*)defaultTemplateParser;//NDFN
+(BOOL)defaultDisplayExceptionPages;//NDFN
+(void)setDefaultDisplayExceptionPages:(BOOL)flag;//NDFN
+(void)_setAllowsCacheControlHeader:(BOOL)flag;
+(BOOL)_allowsCacheControlHeader;

+(NSDictionary*)_webServerConfigDictionary;
+(Class)_applicationClass;
+(Class)_compiledApplicationClass;
+(GSWRequestHandler*)_componentRequestHandler;

+(id)defaultModelGroup;
+(id)_modelGroupFromBundles:(id)_bundles;

-(NSDictionary*)mainBundleInfoDictionary;
+(NSDictionary*)mainBundleInfoDictionary;
-(NSDictionary*)bundleInfo;
+(NSDictionary*)bundleInfo;
-(NSBundle*)mainBundle;
+(NSBundle*)mainBundle;

+(int)_garbageCollectionRepeatCount;
+(BOOL)_lockDefaultEditingContext;
+(void)_setLockDefaultEditingContext:(BOOL)flag;
+(id)_allowsConcurrentRequestHandling;
+(void)_setAllowsConcurrentRequestHandling:(id)unknown;


+(int)_requestLimit;
+(int)_requestWindow;
+(BOOL)_multipleThreads;
+(BOOL)_multipleInstances;
+(void)_readLicenseParameters;

@end /* User defaults */

#endif //_GSWApplication_h__
