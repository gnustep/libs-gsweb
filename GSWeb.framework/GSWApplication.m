/* GSWApplication.m - GSWeb: Class GSWApplication
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

#include <gsweb/GSWeb.framework/GSWeb.h>
#include <extensions/NGReflection.h>
#include <extensions/GarbageCollector.h>
#include "stacktrace.h"
#include "attach.h"

/*
Monitor Refresh (or View Details):
application lock
GSWStatisticsStore statistics
application unlock


*/

@interface GSWApplication (GSWApplicationPrivate)
- (void)_setPool:(NSAutoreleasePool *)pool;
@end

//====================================================================
GSWApplication* GSWApp=nil;
NSDictionary* globalAppDefaultOptions = nil;
NSString* globalApplicationClassName=nil;
NSMutableDictionary* localDynCreateClassNames=nil;

#ifndef NDEBUG
void GSWApplicationDebugSetChange()
{
  static NSString* _prevStateString=nil;
  NSProcessInfo* _processInfo=[NSProcessInfo processInfo];
  NSMutableSet* _debugSet=[_processInfo debugSet];
  NSString* _debugSetConfigFilePath=nil;
  NSString* _newStateString=nil;
  BOOL _change=NO;
  _debugSetConfigFilePath=[GSWApplication debugSetConfigFilePath];
  NSLog(@"_debugSetConfigFilePath=%@",_debugSetConfigFilePath);
  _newStateString=[NSString stringWithContentsOfFile:[GSWApplication debugSetConfigFilePath]];
  NSLog(@"_debugSet=%@",_debugSet);
  NSDebugFLog(@"_debugSet=%@",_debugSet);
  NSLog(@"_newStateString=%@",_newStateString);
  NSDebugFLog(@"_newStateString=%@",_newStateString);
  if (_newStateString)
	_change=![_newStateString isEqualToString:_prevStateString];
  else if (_prevStateString)
	_change=![_prevStateString isEqualToString:_newStateString];

  if (_change)
	{		
	  NSArray* _pList=[_newStateString propertyList];
	  [_debugSet removeAllObjects];
	  if (_pList && [_pList isKindOfClass:[NSArray class]])
		{
		  int _count=[_pList count];
		  int i=0;
		  for(i=0;i<_count;i++)
			{
			  [_debugSet addObject:[_pList objectAtIndex:i]];
			};
		  NSLog(@"_debugSet=%@",_debugSet);
		};
	  ASSIGN(_prevStateString,_newStateString);
	};
};
#endif
void GSWApplicationSetDebugSetOption(NSString* opt_)
{
  NSProcessInfo* _processInfo=nil;
  _processInfo=[NSProcessInfo processInfo];
  if ([opt_ isEqualToString:@"all"])
	{
	  [[_processInfo debugSet] addObject:@"dflt"];
	  [[_processInfo debugSet] addObject:@"GSWebFn"];
	  [[_processInfo debugSet] addObject:@"seriousError"];
	  [[_processInfo debugSet] addObject:@"exception"];
	  [[_processInfo debugSet] addObject:@"exception"];
	  [[_processInfo debugSet] addObject:@"error"];
	  [[_processInfo debugSet] addObject:@"gswdync"];
	  [[_processInfo debugSet] addObject:@"low"];
	  [[_processInfo debugSet] addObject:@"gswcomponents"];
	  [[_processInfo debugSet] addObject:@"associations"];
	  [[_processInfo debugSet] addObject:@"sessions"];
	  [[_processInfo debugSet] addObject:@"bundles"];
	  [[_processInfo debugSet] addObject:@"requests"];
	  [[_processInfo debugSet] addObject:@"resmanager"];
	  [[_processInfo debugSet] addObject:@"options"];
	  [[_processInfo debugSet] addObject:@"info"];
/*
  //[NSObject enableDoubleReleaseCheck:YES];
  [NSPort setDebug:255];
  behavior_set_debug(1);
*/
	}
  else if ([opt_ isEqualToString:@"most"])
	{
	  [[_processInfo debugSet] addObject:@"dflt"];
//	  [[_processInfo debugSet] addObject:@"GSWebFn"];
	  [[_processInfo debugSet] addObject:@"seriousError"];
	  [[_processInfo debugSet] addObject:@"exception"];
	  [[_processInfo debugSet] addObject:@"exception"];
	  [[_processInfo debugSet] addObject:@"error"];
	  [[_processInfo debugSet] addObject:@"gswdync"];
//	  [[_processInfo debugSet] addObject:@"low"];
	  [[_processInfo debugSet] addObject:@"gswcomponents"];

	  [[_processInfo debugSet] addObject:@"associations"];
//	  [[_processInfo debugSet] addObject:@"sessions"];
//	  [[_processInfo debugSet] addObject:@"bundles"];
	  [[_processInfo debugSet] addObject:@"requests"];
//	  [[_processInfo debugSet] addObject:@"resmanager"];
//	  [[_processInfo debugSet] addObject:@"options"];
	  [[_processInfo debugSet] addObject:@"info"];
	}
  else
	{
	  [[_processInfo debugSet] addObject:opt_];
	};
};

//====================================================================
int GSWApplicationMain(NSString* _applicationClassName,
					  int argc,
					  const char *argv[])
{
  Class applicationClass=Nil;
  int result=0;
  NSArray* _args=nil;
//call NSBundle Start:_usesFastJavaBundleSetup
//call :NSBundle Start:_setUsesFastJavaBundleSetup:YES
//call NSBundle mainBundle
  NSProcessInfo* _processInfo=nil;
  NSString* envGNUstepStringEncoding=nil;
  NSAutoreleasePool *appAutoreleasePool;

  appAutoreleasePool = [NSAutoreleasePool new];
  /*
  //TODO
  DebugInstall("/dvlp/projects/app/Source/app.gswa/shared_debug_obj/ix86/linux-gnu/gnu-gnu-gnu-xgps/app_server");
  DebugEnableBreakpoints();
  */
  _processInfo=[NSProcessInfo processInfo];
  envGNUstepStringEncoding=[[_processInfo environment]objectForKey:@"GNUSTEP_STRING_ENCODING"];
  NSCAssert(envGNUstepStringEncoding,@"GNUSTEP_STRING_ENCODING environement variable is not defined !");
  NSCAssert([NSString defaultCStringEncoding]!=NSASCIIStringEncoding,@"NSString defaultCStringEncoding is NSASCIIStringEncoding. Please define GNUSTEP_STRING_ENCODING environement variable to better one !");
  if (!envGNUstepStringEncoding || [NSString defaultCStringEncoding]==NSASCIIStringEncoding)
	{
	  result=-1;
	};
  if (result>=0)
	{
	  _args=[_processInfo arguments];
	  {
		int i=0;
		int _count=[_args count];
		NSString* _opt=nil;
		NSString* _debugOpt=nil;
		for(i=0;i<_count;i++)
		  {
			_debugOpt=nil;
			_opt=[_args objectAtIndex:i];
			if ([_opt hasPrefix:@"--GSWebDebug="])
			  _debugOpt=[_opt stringWithoutPrefix:@"--GSWebDebug="];
			else if  ([_opt hasPrefix:@"-GSWebDebug="])
			  _debugOpt=[_opt stringWithoutPrefix:@"-GSWebDebug="];
			else if  ([_opt hasPrefix:@"GSWebDebug="])
			  _debugOpt=[_opt stringWithoutPrefix:@"GSWebDebug="];
			if (_debugOpt)
			  GSWApplicationSetDebugSetOption(_debugOpt);
		  };
	  };
	  //TODO
	  if (_applicationClassName && [_applicationClassName length]>0)
		ASSIGNCOPY(globalApplicationClassName,_applicationClassName);
	  GSWApplicationDebugSetChange();
	  applicationClass=[GSWApplication _applicationClass];
	  if (!applicationClass)
		{
		  NSCAssert(NO,@"!applicationClass");
		  //TODO error
		  result=-1;
		};
	};
  if (result>=0)
	{
	  NSArray* _frameworks=[applicationClass loadFrameworks];
	  NSDebugFLog(@"LOAD Frameworks _frameworks=%@",_frameworks);
	  if (_frameworks)
		{
		  NSBundle* _bundle=nil;
		  int i=0;
		  BOOL _loadResult=NO;
		  NSString* GNUstepRoot=[[[NSProcessInfo processInfo]environment]objectForKey:@"GNUSTEP_SYSTEM_ROOT"];
		  NSDebugFLLog(@"bundles",@"GNUstepRoot=%@",GNUstepRoot);
//		  NSDebugFLLog(@"bundles",@"[[NSProcessInfo processInfo]environment]=%@",[[NSProcessInfo processInfo]environment]);
		  NSDebugFLLog(@"bundles",@"[NSProcessInfo processInfo]=%@",[NSProcessInfo processInfo]);
		  for(i=0;i<[_frameworks count];i++)
			{
			  NSString* _bundlePath=[_frameworks objectAtIndex:i];
			  NSDebugFLLog(@"bundles",@"_bundlePath=%@",_bundlePath);
			  //TODO
			  NSDebugFLLog(@"bundles",@"GSFrameworkPSuffix=%@",GSFrameworkPSuffix);
			  _bundlePath=[NSString stringWithFormat:@"%@/Libraries/%@%@",GNUstepRoot,_bundlePath,GSFrameworkPSuffix];
			  NSDebugFLLog(@"bundles",@"_bundlePath=%@",_bundlePath);
			  _bundle=[NSBundle bundleWithPath:_bundlePath];
			  NSDebugFLLog(@"bundles",@"_bundle=%@",_bundle);
			  _loadResult=[_bundle load];
			  NSDebugFLog(@"_bundlePath %@ _loadResult=%s",_bundlePath,(_loadResult ? "YES" : "NO"));
			  if (!_loadResult)
				{
				  result=-1;
				  ExceptionRaise(@"GSWApplication",@"Can't load framework %@",
								 _bundlePath);
				};
			};
		};	  
	  NSDebugFLLog(@"bundles",@"[NSBundle allBundles]=%@",[NSBundle allBundles]);
	  NSDebugFLLog(@"bundles",@"[NSBundle allFrameworks]=%@",[NSBundle allFrameworks]);
	};
  if (result>=0)
	{
	  NS_DURING
		{
		  id _app=[applicationClass new];
		  if (_app)
			result=1;
		  else
			result=-1;
		};	  
	  // Make sure we pass all exceptions back to the requestor.
	  NS_HANDLER
		{
		  NSDebugFLog(@"Can't create Application (Class:%@)- %@ %@ Name:%@ Reason:%@\n",
				applicationClass,
				localException,
				[localException description],
				[localException name],
				[localException reason]);
		  result=-1;
		}
	  NS_ENDHANDLER;
	};
  if (result>=0 && GSWApp)
	{
	  [GSWApp _setPool:[NSAutoreleasePool new]];
	  [GSWApp run];
	  DESTROY(GSWApp);
	};
  DESTROY(appAutoreleasePool);
  return result;
};

//====================================================================
@implementation GSWApplication

//--------------------------------------------------------------------
+(void)initialize
{
  if (self==[GSWApplication class])
	{
	  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	  if (defaults)
		{
		  NSDictionary* _args=[defaults volatileDomainForName:NSArgumentDomain];
		  if (_args && [_args count]>0)
			{
			  NSMutableDictionary* _newArgs=[NSMutableDictionary dictionary];
			  NSEnumerator* _enum=nil;
			  NSString* _key=nil;
			  id _value=nil;
			  _enum=[_args keyEnumerator];
			  while ((_key = [_enum nextObject]))
				{
				  _value=[_args objectForKey:_key];
				  if ([_key hasPrefix:@"-GSW"])
					_key = [_key substringFromIndex:1];
				  [_newArgs setObject:_value
							forKey:_key];
				};
			  [defaults setVolatileDomain:_newArgs
						forName:NSArgumentDomain];
			};
		};
	  if (!localDynCreateClassNames)
		localDynCreateClassNames=[NSMutableDictionary new];
	  if (!globalAppDefaultOptions)
		{
		  NSDictionary* _defaultsOptions=nil;
		  globalAppDefaultOptions=[[self bundleInfo] objectForKey:@"defaults"];
		  NSDebugFLog(@"globalAppDefaultOptions=%@",globalAppDefaultOptions);
		  NSDebugFLog(@"_globalAppDefaultOptions=%@",globalAppDefaultOptions);
		  _defaultsOptions = 
			[NSDictionary dictionaryWithObjectsAndKeys:
							GSWClassName_DefaultAdaptor,   			GSWOPT_Adaptor,
						  [NSArray array],							GSWOPT_AdditionalAdaptors,
						  GSWOPTVALUE_ApplicationBaseURL,			GSWOPT_ApplicationBaseURL,
						  GSWOPTVALUE_AutoOpenInBrowser,			GSWOPT_AutoOpenInBrowser,
						  GSWOPTVALUE_CGIAdaptorURL,				GSWOPT_CGIAdaptorURL,
						  GSWOPTVALUE_CachingEnabled,	    		GSWOPT_CachingEnabled,
						  GSWComponentRequestHandlerKey,			GSWOPT_ComponentRequestHandlerKey,
						  GSWOPTVALUE_DebuggingEnabled,				GSWOPT_DebuggingEnabled,
						  GSWOPTVALUE_StatusDebuggingEnabled,		GSWOPT_StatusDebuggingEnabled,
						  GSWDirectActionRequestHandlerKey, 		GSWOPT_DirectActionRequestHandlerKey,
						  GSWOPTVALUE_DirectConnectEnabled,	   		GSWOPT_DirectConnectEnabled,
						  GSWOPTVALUE_FrameworksBaseURL,			GSWOPT_FrameworksBaseURL,
						  GSWOPTVALUE_IncludeCommentsInResponse,	GSWOPT_IncludeCommentsInResponse,
						  GSWOPTVALUE_ListenQueueSize,				GSWOPT_ListenQueueSize,
						  [NSArray array],							GSWOPT_LoadFrameworks,
						  GSWOPTVALUE_MonitorEnabled,				GSWOPT_MonitorEnabled,
						  GSWOPTVALUE_MonitorHost,					GSWOPT_MonitorHost,
						  GSWOPTVALUE_Port,							GSWOPT_Port,
						  GSWResourceRequestHandlerKey,	  			GSWOPT_ResourceRequestHandlerKey,
						  GSWOPTVALUE_SMTPHost,						GSWOPT_SMTPHost,
						  GSWOPTVALUE_SessionTimeOut,				GSWOPT_SessionTimeOut,
						  GSWOPTVALUE_WorkerThreadCount,			GSWOPT_WorkerThreadCount,
						  GSWOPTVALUE_MultiThreadEnabled,			GSWOPT_MultiThreadEnabled,
						  nil,										nil];
		  NSDebugFLog(@"_globalAppDefaultOptions=%@",globalAppDefaultOptions);
		  globalAppDefaultOptions=[NSDictionary dictionaryWithDictionary:globalAppDefaultOptions
												andDefaultEntriesFromDictionary:_defaultsOptions];
		  NSDebugFLog(@"_globalAppDefaultOptions=%@",globalAppDefaultOptions);
		};
	  [defaults registerDefaults:globalAppDefaultOptions];
	};
};

//--------------------------------------------------------------------
- (void)_setPool:(NSAutoreleasePool *)pool
{
	globalAutoreleasePool = pool;
}

//--------------------------------------------------------------------
+(id)init
{
  id ret=[[self superclass]init];
  [GSWAssociation addLogHandlerClasse:[self class]];
  return ret;
};

//--------------------------------------------------------------------
+(void)dealloc
{
  [GSWAssociation removeLogHandlerClasse:[self class]];
  DESTROY(localDynCreateClassNames);
  DESTROY(globalAppDefaultOptions);
  [[self superclass]dealloc];
};

//-----------------------------------------------------------------------------------
//init

-(id)init 
{
  NSUserDefaults* _standardUserDefaults=nil;
  LOGObjectFnStart();
  self=[super init];
  timeOut=2*60*60;
//  context=nil;//deprecated
  selfLock=[NSRecursiveLock new];
  globalLock=[NSLock new];
  pageCacheSize=30;
  permanentPageCacheSize=30;
  pageRecreationEnabled=YES;
  pageRefreshOnBacktrackEnabled=YES;
  dynamicLoadingEnabled=YES;
  printsHTMLParserDiagnostics=YES;
  [[self class] _setApplication:self];
  [self _touchPrincipalClasses];
  _standardUserDefaults=[NSUserDefaults standardUserDefaults];
  NSDebugMLLog(@"options",@"_standardUserDefaults=%@",_standardUserDefaults);
  [self _initAdaptorsWithUserDefaults:_standardUserDefaults]; //TODOV
  sessionStore=[GSWServerSessionStore new];
  //call isMonitorEnabled

/*????
  NSBundle* _mainBundle=[NSBundle mainBundle];
  NSArray* _allFrameworks=[_mainBundle allFrameworks];
  int _frameworkN=0;
  for(_frameworkN=0;_frameworkN<[_allFrameworks count];_frameworkN++)
	{
	  NSString* _bundlePath=[[_allFrameworks objectAtIndex:_frameworkN] bundlePath];
	  //TODO what ???
	};
*/
  //call adaptorsDispatchRequestsConcurrently
  activeSessionsCountLock=[NSLock new];
  componentDefinitionCache=[GSWMultiKeyDictionary new];
  [self setResourceManager:[[GSWResourceManager new]autorelease]];
  [self setStatisticsStore:[[GSWStatisticsStore new]autorelease]];
  if ([[self class]isMonitorEnabled])
	{
	  NSDebugMLLog0(@"low",@"init: call self _setupForMonitoring");
	  [self _setupForMonitoring];
	};
  NSDebugMLLog0(@"low",@"init: call appGSWBundle initializeObject:...");
  [[GSWResourceManager _applicationGSWBundle] initializeObject:self
			   fromArchiveNamed:@"Application"];
  [self setPrintsHTMLParserDiagnostics:NO];
  //call recordingPath
  NSDebugMLLog0(@"low",@"init: call self registerRequestHandlers");
  [self registerRequestHandlers];
  [self _validateAPI];
  [[NSNotificationCenter defaultCenter]addObserver:self
									   selector:@selector(_sessionDidTimeOutNotification:)
									   name:GSWNotification__SessionDidTimeOutNotification
									   object:nil];
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWApplication");
  DESTROY(adaptors);
  DESTROY(sessionStore);
  DESTROY(componentDefinitionCache);
  DESTROY(timer);
//  DESTROY(context);//deprecated
  DESTROY(statisticsStore);
  DESTROY(resourceManager);
  DESTROY(remoteMonitor);
  DESTROY(remoteMonitorConnection);
  DESTROY(instanceNumber);
  DESTROY(requestHandlers);
  DESTROY(defaultRequestHandler);
  GSWLogC("Dealloc GSWApplication: selfLock");
  DESTROY(selfLock);
  GSWLogC("Dealloc GSWApplication: globalLock");
  DESTROY(globalLock);
  GSWLogC("Dealloc GSWApplication: globalAutoreleasePool");
  DESTROY(globalAutoreleasePool);
  DESTROY(currentRunLoop);
  DESTROY(runLoopDate);
  DESTROY(initialTimer);
  DESTROY(activeSessionsCountLock);
  GSWLogC("Dealloc GSWApplication Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWApplication");
};

//--------------------------------------------------------------------
-(NSString*)description
{
  //OK
  NSString* _dscr=nil;
  [self lock];
  _dscr=[NSString stringWithFormat:
					@"<%s %p - name=%@ adaptors=%@ sessionStore=%@ pageCacheSize=%d permanentPageCacheSize=%d pageRecreationEnabled=%s pageRefreshOnBacktrackEnabled=%s componentDefinitionCache=%@ caching=%s terminating=%s timeOut=%f dynamicLoadingEnabled=%s>",
				  object_get_class_name(self),
				  (void*)self,
				  [self name],
				  [[self adaptors] description],
				  [[self sessionStore] description],
				  [self pageCacheSize],
				  [self permanentPageCacheSize],
				  [self _isPageRecreationEnabled] ? "YES" : "NO",
				  [self isPageRefreshOnBacktrackEnabled] ? "YES" : "NO",
				  [componentDefinitionCache description],
				  [self isCachingEnabled] ? "YES" : "NO",
				  [self isTerminating] ? "YES" : "NO",
				  [self timeOut],
				  [self _isDynamicLoadingEnabled] ? "YES" : "NO"];
  [self unlock];
  return _dscr;
};

//--------------------------------------------------------------------
//	allowsConcurrentRequestHandling
-(BOOL)allowsConcurrentRequestHandling
{
  return YES;
};

//--------------------------------------------------------------------
//	adaptorsDispatchRequestsConcurrently
-(BOOL)adaptorsDispatchRequestsConcurrently
{
  //TODO: use isMultiThreaded ?
  BOOL _adaptorsDispatchRequestsConcurrently=NO;
  int i=0;
  int _adaptorsCount=[adaptors count];
  for(i=0;!_adaptorsDispatchRequestsConcurrently && i<_adaptorsCount;i++)
	  _adaptorsDispatchRequestsConcurrently=[[adaptors objectAtIndex:i]dispatchesRequestsConcurrently];
  return _adaptorsDispatchRequestsConcurrently;
};

//--------------------------------------------------------------------
//	isConcurrentRequestHandlingEnabled
-(BOOL)isConcurrentRequestHandlingEnabled
{
  return [self allowsConcurrentRequestHandling];
};

//--------------------------------------------------------------------
//	lockRequestHandling
-(BOOL)isRequestHandlingLocked
{
  return [globalLock isLocked];
};

//--------------------------------------------------------------------
//	lockRequestHandling
-(void)lockRequestHandling
{
  //OK
  LOGObjectFnStart();
  if (![self isConcurrentRequestHandlingEnabled])
	{
	  /*  NSDebugMLLog(@"low",@"globalLockn=%d globalLock_thread_id=%p objc_thread_id()=%p",
		  globalLockn,(void*)
		  globalLock_thread_id,
		  (void*)objc_thread_id());
		  if (globalLockn>0)
		  {
		  if (globalLock_thread_id!=objc_thread_id())
		  {
		  NSDebugMLLog(@"low",@"PROBLEM: owner!=thread id");
		  };
		  };
	  */
	  NS_DURING
		{
		  TmpLockBeforeDate(globalLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
		  globalLockn++;
		  globalLock_thread_id=objc_thread_id();
#endif
		  NSDebugMLLog(@"low",@"globalLockn=%d globalLock_thread_id=%p objc_thread_id()=%p",
					   globalLockn,
					   (void*)globalLock_thread_id,
					   (void*)objc_thread_id());
		}
	  NS_HANDLER
		{
		  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"globalLock tmplockBeforeDate");
		  LOGException(@"%@ (%@)",localException,[localException reason]);
		  [localException raise];
		};
	  NS_ENDHANDLER;
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	unlockRequestHandling
-(void)unlockRequestHandling
{
  //OK
  LOGObjectFnStart();
  if (![self isConcurrentRequestHandlingEnabled])
	{
	  NS_DURING
		{
		  /*  NSDebugMLLog(@"low",@"globalLockn=%d globalLock_thread_id=%p objc_thread_id()=%p",
			  globalLockn,
			  (void*)globalLock_thread_id,
			  (void*)objc_thread_id());*/
		  if (globalLockn>0)
			{
			  if (globalLock_thread_id!=objc_thread_id())
				{
				  NSDebugMLLog0(@"low",@"PROBLEM: owner!=thread id");
				};
			};
		  TmpUnlock(globalLock);
#ifndef NDEBUG
		  globalLockn--;
		  if (globalLockn==0)
			globalLock_thread_id=NULL;
#endif
		  NSDebugMLLog(@"low",@"globalLockn=%d globalLock_thread_id=%p objc_thread_id()=%p",
					   globalLockn,
					   (void*)globalLock_thread_id,
					   (void*)objc_thread_id());
		}
	  NS_HANDLER
		{
		  NSDebugMLLog(@"low",@"globalLockn=%d globalLock_thread_id=%p objc_thread_id()=%p",
					   globalLockn,
					   (void*)globalLock_thread_id,
					   (void*)objc_thread_id());
		  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"globalLock tmpunlock");
		  LOGException(@"%@ (%@)",localException,[localException reason]);
		  [localException raise];
		};
	  NS_ENDHANDLER;
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	lock
-(void)lock
{
  //call adaptorsDispatchRequestsConcurrently
  //OK
  LOGObjectFnStart();
/*  NSDebugMLLog(@"low",@"selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
	selfLockn,
	(void*)selfLock_thread_id,
	(void*)objc_thread_id());
  if (selfLockn>0)
	{
	  if (selfLock_thread_id!=objc_thread_id())
		{
		  NSDebugMLLog(@"low",@"PROBLEM: owner!=thread id");
		};
	};
*/
  NS_DURING
	{
	  TmpLockBeforeDate(selfLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
	  selfLockn++;
	  selfLock_thread_id=objc_thread_id();
#endif
	  NSDebugMLLog(@"low",@"selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
				   selfLockn,
				   (void*)selfLock_thread_id,
				   (void*)objc_thread_id());
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"selfLock tmplockBeforeDate");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  [localException raise];
	};
  NS_ENDHANDLER;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	unlock
-(void)unlock
{
  //call adaptorsDispatchRequestsConcurrently
  //OK
  LOGObjectFnStart();
/*  NSDebugMLLog(@"low",@"selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
	selfLockn,
	(void*)selfLock_thread_id,
	(void*)objc_thread_id());
  if (selfLockn>0)
	{
	  if (selfLock_thread_id!=objc_thread_id())
		{
		  NSDebugMLLog(@"low",@"PROBLEM: owner!=thread id");
		};
	};
*/
  NS_DURING
	{
	  TmpUnlock(selfLock);
#ifndef NDEBUG
	  selfLockn--;
	  if (selfLockn==0)
		selfLock_thread_id=NULL;
#endif
	  NSDebugMLLog(@"low",@"selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
				   selfLockn,
				   (void*)selfLock_thread_id,
				   (void*)objc_thread_id());
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"low",@"selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
				   selfLockn,
				   (void*)selfLock_thread_id,
				   (void*)objc_thread_id());
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"selfLock tmpunlock");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  [localException raise];
	};
  NS_ENDHANDLER;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
+(void)_initRegistrationDomainDefaults
{
  LOGClassFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(void)_initUserDefaultsKeys
{
  LOGClassFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//name

-(NSString*)name 
{
  NSString* _name=nil;
  NSProcessInfo* _processInfo=nil;
  NSString* _processName=nil;
  LOGObjectFnStart();
  //TODO
/*  if (applicationName)
	return applicationName;
  else
	{*/
	  _processInfo=[NSProcessInfo processInfo];
	  _processName=[_processInfo processName];
	  NSDebugMLLog(@"low",@"_processInfo:%@",_processInfo);
	  NSDebugMLLog(@"low",@"_processName:%@",_processName);
	  _processName=[_processName lastPathComponent];
	  if ([_processName hasSuffix:GSWApplicationPSuffix])
		_name=[_processName stringWithoutSuffix:GSWApplicationPSuffix];
	  else
		_name=_processName;
	  NSDebugMLLog(@"low",@"_name:%@",_name);
//	};
	  return _name;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//number
-(NSString*)number 
{
  LOGObjectFnNotImplemented();	//TODOFN
  return @"0";
};

//--------------------------------------------------------------------
//setPageRefreshOnBacktrackEnabled:
-(void)setPageRefreshOnBacktrackEnabled:(BOOL)flag 
{
  LOGObjectFnStart();
  pageRefreshOnBacktrackEnabled=flag;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//path
-(NSString*)path 
{
  //OK
  NSString* _path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"[GSWResourceManager _applicationGSWBundle]:%@",[GSWResourceManager _applicationGSWBundle]);
  GSWLogDumpObject([GSWResourceManager _applicationGSWBundle],2);
  _path=[[GSWResourceManager _applicationGSWBundle] path]; //return :  H:\Wotests\ObjCTest3
  NSDebugMLLog(@"low",@"_path:%@",_path);
  LOGObjectFnStop();
  return _path;
};

//--------------------------------------------------------------------
//baseURL
-(NSString*)baseURL 
{
  NSString* _baseURL=nil;
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStart();
  _baseURL=[GSWURLPrefix stringByAppendingString:[self name]];
  LOGObjectFnStop();
  return _baseURL;
};

//--------------------------------------------------------------------
-(void)registerRequestHandlers
{
  //OK
  NSString* _componentRequestHandlerKey=nil;
  NSString* _resourceRequestHandlerKey=nil;
  NSString* _directActionRequestHandlerKey=nil;
  GSWRequestHandler* _componentRequestHandler=nil;
  GSWResourceRequestHandler* _resourceRequestHandler=nil;
  GSWDirectActionRequestHandler* _directActionRequestHandler=nil;
  LOGObjectFnStart();
  _componentRequestHandler=[[self class] _componentRequestHandler];
  _componentRequestHandlerKey=[[self class] componentRequestHandlerKey];
  NSDebugMLLog(@"low",@"_componentRequestHandlerKey:%@",_componentRequestHandlerKey);

  _resourceRequestHandler=[GSWResourceRequestHandler handler];
  _resourceRequestHandlerKey=[[self class] resourceRequestHandlerKey];
  NSDebugMLLog(@"low",@"_resourceRequestHandlerKey:%@",_resourceRequestHandlerKey);

  _directActionRequestHandler=[GSWDirectActionRequestHandler handler];
  _directActionRequestHandlerKey=[[self class] directActionRequestHandlerKey];
  NSDebugMLLog(@"low",@"_directActionRequestHandlerKey:%@",_directActionRequestHandlerKey);

  [self registerRequestHandler:_componentRequestHandler
		forKey:_componentRequestHandlerKey];
  [self registerRequestHandler:_resourceRequestHandler
		forKey:_resourceRequestHandlerKey];
  [self registerRequestHandler:_directActionRequestHandler
		forKey:_directActionRequestHandlerKey];
  NSDebugMLLog(@"low",@"requestHandlers:%@",requestHandlers);
  [self setDefaultRequestHandler:_componentRequestHandler];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_initAdaptorsWithUserDefaults:(NSUserDefaults*)_userDefaults
{
  GSWAdaptor* _adaptor=nil;
  NSDictionary* _args=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"options",@"_userDefault=%@",_userDefaults);
  _args=[self _argsDictionaryWithUserDefaults:_userDefaults];
  _adaptor=[self adaptorWithName:[_userDefaults objectForKey:GSWOPT_Adaptor]
				 arguments:_args];
  if (adaptors)
	ASSIGN(adaptors,[adaptors arrayByAddingObject:_adaptor]);
  else
	ASSIGN(adaptors,[NSArray arrayWithObject:_adaptor]);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSDictionary*)_argsDictionaryWithUserDefaults:(NSUserDefaults*)_userDefault
{
  //VERIFY
  //OK
  NSNumber* _port=nil;
  NSString* _host=nil;
  NSString* _adaptor=nil;
  NSNumber* _workerThreadCount=nil;
  NSNumber* _listenQueueSize=nil;
  NSMutableDictionary* _argsDict=nil;
  LOGObjectFnStart();
  _port=[[self class] port];
  _host=[[self class] host];
  _adaptor=[[self class] adaptor];
  _workerThreadCount=[[self class] workerThreadCount];
  _listenQueueSize=[[self class] listenQueueSize];
  _argsDict=[NSMutableDictionary dictionary];
  [_argsDict addEntriesFromDictionary:[_userDefault dictionaryRepresentation]];
  if (_port)
	[_argsDict setObject:_port
			   forKey:GSWOPT_Port];
  if (_host)
	[_argsDict setObject:_host
			   forKey:GSWOPT_Host];
  if (_adaptor)
	[_argsDict setObject:_adaptor
			   forKey:GSWOPT_Adaptor];
  if (_workerThreadCount)
	[_argsDict setObject:_workerThreadCount
			   forKey:GSWOPT_WorkerThreadCount];
  if (_listenQueueSize)
	[_argsDict setObject:_listenQueueSize
			   forKey:GSWOPT_ListenQueueSize];
  LOGObjectFnStop();
  return _argsDict;
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationA)
-(void)becomesMultiThreaded
{
  LOGObjectFnNotImplemented();	//TODOFN
};
@end

//====================================================================
@implementation GSWApplication (GSWApplicationB)
-(id)_webserverConnectURL
{
  LOGObjectFnNotImplemented();	//TODOFN
  return @"";
};

//--------------------------------------------------------------------
-(NSString*)_directConnectURL
{
  NSString* _directConnectURL=nil;
  NSString* _cgiAdaptorURL=[[self class]cgiAdaptorURL]; //return http://brahma.sbuilders.com/cgi/GSWeb.exe
  NSArray* _adaptor=[self adaptors];
  //(call name)
  LOGObjectFnNotImplemented();	//TODOFN
  return _directConnectURL; //return http://brahma.sbuilders.com:1436/cgi/GSWeb.exe/ObjCTest3
};

//--------------------------------------------------------------------
-(id)_applicationExtension
{
  LOGObjectFnNotImplemented();	//TODOFN
  return GSWApplicationSuffix;
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationC)

//--------------------------------------------------------------------
-(void)_resetCacheForGeneration
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_resetCache
{
  //OK
  NSEnumerator* _enum=nil;
  id _object=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  NSDebugMLLog(@"low",@"componentDefinitionCache=%@",componentDefinitionCache);
	  _enum=[componentDefinitionCache objectEnumerator];
	  while ((_object = [_enum nextObject]))
		{
		  NSDebugMLLog(@"low",@"_object=%@",_object);
		  if (_object!=GSNotFoundMarker && ![_object isCachingEnabled])
			{
			  [_object _clearCache];
			};
		};
	  if (![self isCachingEnabled])
		{
		  [[GSWResourceManager _applicationGSWBundle] clearCache];
		};
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In clearCache");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  [self unlock];
	  [localException raise];
	  //TODO
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationD)

-(GSWComponentDefinition*)componentDefinitionWithName:(NSString*)name_
											languages:(NSArray*)languages_
{
  //OK
  GSWComponentDefinition* _componentDefinition=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"info",@"name_=%@",name_);
  [self lock];
  NS_DURING
	{
	  _componentDefinition=[self lockedComponentDefinitionWithName:name_
								 languages:languages_];
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In lockedComponentDefinitionWithName");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return _componentDefinition;
};

-(GSWComponentDefinition*)lockedComponentDefinitionWithName:(NSString*)_name
												  languages:(NSArray*)_languages
{
  //OK
  BOOL isCachedComponent=NO;
  GSWComponentDefinition* _componentDefinition=nil;
  NSString* _language=nil;
  int iLanguage=0;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"_Name=%@",_name);
  for(iLanguage=0;iLanguage<[_languages count] && !_componentDefinition;iLanguage++)
	{
	  _language=[_languages objectAtIndex:iLanguage];
	  if (_language)
		{
		  NSDebugMLLog(@"gswcomponents",@"trying _language=%@",_language);
		  NSDebugMLLog(@"gswcomponents",@"[self isCachingEnabled]=%s",([self isCachingEnabled] ? "YES" : "NO"));
		  if ([self isCachingEnabled])
			{
			  _componentDefinition=[componentDefinitionCache objectForKeys:_name,_language,nil];
			  if (_componentDefinition==(GSWComponentDefinition*)GSNotFoundMarker)
				_componentDefinition=nil;
			  else if (_componentDefinition)
				isCachedComponent=YES;
			};
		  if (!_componentDefinition)
			{
			  _componentDefinition=[self lockedLoadComponentDefinitionWithName:_name
										 language:_language];
			  if ([self isCachingEnabled])
				{
				  if (_componentDefinition)
					[componentDefinitionCache setObject:_componentDefinition
											  forKeys:_name,_language,nil];
				  else
					[componentDefinitionCache setObject:GSNotFoundMarker
											  forKeys:_name,_language,nil];
				};
			};
		};
	};
  if (!_componentDefinition)
	{
	  _language=nil;
	  NSDebugMLLog0(@"low",@"trying no language");
	  NSDebugMLLog(@"gswcomponents",@"[self isCachingEnabled]=%s",([self isCachingEnabled] ? "YES" : "NO"));
	  if ([self isCachingEnabled])
		{
		  _componentDefinition=[componentDefinitionCache objectForKeys:_name,nil];
		  if (_componentDefinition==(GSWComponentDefinition*)GSNotFoundMarker)
			_componentDefinition=nil;
		  else if (_componentDefinition)
			isCachedComponent=YES;
		};
	  NSDebugMLLog(@"gswcomponents",@"D componentDefinition for %@ %s cached",_name,(_componentDefinition ? "" : "NOT"));
	  if (!_componentDefinition)
		{
		  _componentDefinition=[self lockedLoadComponentDefinitionWithName:_name
									 language:_language];
		  if ([self isCachingEnabled])
			{
			  if (_componentDefinition)
				[componentDefinitionCache setObject:_componentDefinition
										  forKeys:_name,nil];
			  else
				[componentDefinitionCache setObject:GSNotFoundMarker
										  forKeys:_name,nil];
			};
		};
	};
  if (!_componentDefinition)
	{
	  ExceptionRaise(@"GSWApplication",
					 @"Unable to create component definition for %@ for languages: %@ (no componentDefinition).",
					 _name,
					 _languages);
	};
  if (_componentDefinition)
	{
	  [self statusDebugWithFormat:@"Component %@ %s language %@ (%sCached)",
			_name,
			(_language ? "" : "no"),
			(_language ? _language : @""),
			(isCachedComponent ? "" : "Not ")];
	};
  NSDebugMLLog(@"low",@"%s componentDefinition for %@ class=%@ %s",
			   (_componentDefinition ? "FOUND" : "NOTFOUND"),
			   _name,
			   (_componentDefinition ? [[_componentDefinition class] description]: @""),
			   (_componentDefinition ? (isCachedComponent ? "(Cached)" : "(Not Cached)") : ""));
  LOGObjectFnStop();
  return _componentDefinition;
};

//--------------------------------------------------------------------
-(GSWComponentDefinition*)lockedLoadComponentDefinitionWithName:(NSString*)_name
													   language:(NSString*)_language
{
  GSWComponentDefinition* _componentDefinition=nil;
  GSWResourceManager* _resourceManager=nil;
  NSString* _frameworkName=nil;
  NSString* _resourceName=nil;
  NSString* _htmlResourceName=nil;
  NSString* _path=nil;
  NSString* _url=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"_Name=%@",_name);
  _resourceName=[_name stringByAppendingString:GSWPagePSuffix];
  _htmlResourceName=[_name stringByAppendingString:GSWComponentTemplatePSuffix];
  NSDebugMLLog(@"gswcomponents",@"_resourceName=%@",_resourceName);
  _resourceManager=[self resourceManager];
  _path=[_resourceManager pathForResourceNamed:_resourceName
						  inFramework:nil
						  language:_language];
  NSDebugMLLog(@"low",@"_path=%@",_path);
  if (!_path)
	{
	  NSArray* _frameworks=[self lockedComponentBearingFrameworks];
	  NSBundle* _framework=nil;
	  int _frameworkN=0;
	  for(_frameworkN=0;_frameworkN<[_frameworks count] && !_path;_frameworkN++)
		{
		  _framework=[_frameworks objectAtIndex:_frameworkN];
		  NSDebugMLLog(@"gswcomponents",@"TRY _framework=%@",_framework);
		  _path=[_resourceManager pathForResourceNamed:_resourceName
								  inFramework:[_framework bundleName]
								  language:_language];
		  if (!_path)
			{
			  _path=[_resourceManager pathForResourceNamed:_htmlResourceName
									  inFramework:[_framework bundleName]
									  language:_language];
			};
		  if (_path)
			{
			  NSDebugMLLog(@"gswcomponents",@"framework=%@ class=%@",_framework,[_framework class]);
			  NSDebugMLLog(@"gswcomponents",@"framework bundlePath=%@",[_framework bundlePath]);
			  _frameworkName=[_framework bundlePath];
			  NSDebugMLLog(@"gswcomponents",@"_frameworkName=%@",_frameworkName);
			  _frameworkName=[_frameworkName lastPathComponent];
			  NSDebugMLLog(@"gswcomponents",@"_frameworkName=%@",_frameworkName);
			  _frameworkName=[_frameworkName stringByDeletingPathExtension];
			  NSDebugMLLog(@"gswcomponents",@"_frameworkName=%@",_frameworkName);
			};
		};
	  NSDebugMLLog(@"low",@"_path=%@",_path);
	};
  if (_path)
	{
	  _url=[_resourceManager urlForResourceNamed:_resourceName
							 inFramework:_frameworkName	//NEW
							 languages:(_language ? [NSArray arrayWithObject:_language] : nil)
							 request:nil];
	  NSDebugMLLog(@"gswcomponents",@"_url=%@",_url);
	  NSDebugMLLog(@"gswcomponents",@"_frameworkName=%@",_frameworkName);
	  NSDebugMLog(!@"Component %@ Found at=%@",_name,_path);
	  _componentDefinition=[[[GSWComponentDefinition alloc] initWithName:_name
															path:_path
															baseURL:_url
															frameworkName:_frameworkName] autorelease];
	};
  LOGObjectFnStop();
  return _componentDefinition;
};

//--------------------------------------------------------------------
-(NSArray*)lockedComponentBearingFrameworks
{
  //OK
  NSArray* _array=nil;
  NSArray* _allFrameworks=nil;
  LOGObjectFnStart();
  _allFrameworks=[NSBundle allFrameworks];
//  NSDebugMLLog(@"gswcomponents",@"_allFrameworks=%@",_allFrameworks);
  _array=[self lockedInitComponentBearingFrameworksFromBundleArray:_allFrameworks];
  NSDebugMLLog(@"gswcomponents",@"_array=%@",_array);
  LOGObjectFnStop();
  return _array;
};

//--------------------------------------------------------------------
-(NSArray*)lockedInitComponentBearingFrameworksFromBundleArray:(NSArray*)_bundles
{
  NSMutableArray* _array=nil;
  int i=0;
  NSBundle* _bundle=nil;
  NSDictionary* _bundleInfo=nil;
  id _hasGSWComponents=nil;
  LOGObjectFnStart();
  _array=[NSMutableArray array];
  for(i=0;i<[_bundles count];i++)
	{
	  _bundle=[_bundles objectAtIndex:i];
//	  NSDebugMLLog(@"gswcomponents",@"_bundle=%@",_bundle);
	  _bundleInfo=[_bundle infoDictionary];
//	  NSDebugMLLog(@"gswcomponents",@"_bundleInfo=%@",_bundleInfo);
	  _hasGSWComponents=[_bundleInfo objectForKey:@"HasGSWComponents"];
//	  NSDebugMLLog(@"gswcomponents",@"_hasGSWComponents=%@",_hasGSWComponents);
//	  NSDebugMLLog(@"gswcomponents",@"_hasGSWComponents class=%@",[_hasGSWComponents class]);
	  if (boolValueFor(_hasGSWComponents))
		{
		  [_array addObject:_bundle];
		  NSDebugMLLog(@"gswcomponents",@"Add %@",[_bundle bundleName]);
		};
	};
//  NSDebugMLLog(@"gswcomponents",@"_array=%@",_array);
  LOGObjectFnStop();
  return _array;
};


@end

//====================================================================
@implementation GSWApplication (GSWApplicationE)

//--------------------------------------------------------------------
-(void)_discountTerminatedSession
{
  //OK
  LOGObjectFnStart();
  [self lock]; //TODO mettre le lock ailleur
  NS_DURING
	{
	  [self lockedDecrementActiveSessionCount];
	  if ([self isRefusingNewSessions])
		{
		  //TODO
		};
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In lockedDecrementActiveSessionCount...");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_finishInitializingSession:(GSWSession*)_session
{
  //OK
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  [[GSWResourceManager _applicationGSWBundle] initializeObject:_session
												  fromArchiveNamed:@"Session"];
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In initializeObject:fromArchiveNamed:");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWSession*)_initializeSessionInContext:(GSWContext*)context_
{
  //OK
  GSWSession* _session=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  if ([self isRefusingNewSessions])
		{
		  //TODO erreur ?
		  NSDebugMLLog0(@"low",@"isRefusingNewSessions!");
		}
	  else
		{
		  [self lockedIncrementActiveSessionCount];
		  _session=[self createSessionForRequest:[context_ request]];
		  NSDebugMLLog(@"sessions",@"_session:%@",_session);
		  NSDebugMLLog(@"sessions",@"_session ID:%@",[_session sessionID]);
		  [context_ _setSession:_session];
		  [_session awakeInContext:context_];
		};
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In lockedIncrementActiveSessionCount...");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return _session;
};

//--------------------------------------------------------------------
-(int)lockedDecrementActiveSessionCount
{
  LOGObjectFnStart();
  activeSessionsCount--;
  LOGObjectFnStop();
  return activeSessionsCount;
};

//--------------------------------------------------------------------
-(int)lockedIncrementActiveSessionCount
{
  LOGObjectFnStart();
  activeSessionsCount++;
  LOGObjectFnStop();
  return activeSessionsCount;
};

//--------------------------------------------------------------------
-(int)_activeSessionsCount
{
  return activeSessionsCount;
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationF)

//--------------------------------------------------------------------
-(void)_setContext:(GSWContext*)context_
{
  NSMutableDictionary* _threadDictionary=nil;
  LOGObjectFnStart();
  _threadDictionary=GSCurrentThreadDictionary();
  if (context_)
	[_threadDictionary setObject:context_
					   forKey:GSWThreadKey_Context];
  else
	[_threadDictionary removeObjectForKey:GSWThreadKey_Context];  
  //  ASSIGN(context,_context);
  NSDebugMLLog(@"low",@"context:%p",(void*)context_);
  NSDebugMLLog(@"low",@"context retain count:%p",[context_ retainCount]);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
// Internal Use only
-(GSWContext*)_context
{
  GSWContext* _context=nil;
  NSMutableDictionary* _threadDictionary=nil;
  LOGObjectFnStart();
  _threadDictionary=GSCurrentThreadDictionary();
  _context=[_threadDictionary objectForKey:GSWThreadKey_Context];
  NSDebugMLLog(@"low",@"context:%p",(void*)_context);
  LOGObjectFnStop();
  return _context;
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationG)

//--------------------------------------------------------------------
-(BOOL)_isDynamicLoadingEnabled
{
  return dynamicLoadingEnabled;
};

//--------------------------------------------------------------------
-(void)_disableDynamicLoading
{
  dynamicLoadingEnabled=NO;
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationI)

//--------------------------------------------------------------------
-(BOOL)_isPageRecreationEnabled
{
  return pageRecreationEnabled;
};

//--------------------------------------------------------------------
-(void)_touchPrincipalClasses
{
  NSArray* _allFrameworks=nil;
  int _frameworkN=0;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  //????
	  _allFrameworks=[NSBundle allFrameworks];
	  for(_frameworkN=0;_frameworkN<[_allFrameworks count];_frameworkN++)
		{
		  NSDictionary* _infoDictionary=[[_allFrameworks objectAtIndex:_frameworkN] infoDictionary];
		  //TODO what ???
		};
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationJ)

//--------------------------------------------------------------------
-(id)_newLocationForRequest:(GSWRequest*)_request
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
//appellé quand le moteur est fermé 
-(void)_connectionDidDie:(id)_unknown
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(BOOL)_shouldKill
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
//TODO return  (Vv9@0:4c8)
-(void)_setShouldKill:(BOOL)_flag
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_synchronizeInstanceSettingsWithMonitor:(id)_monitor
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(BOOL)_setupForMonitoring
{
  //OK
  id _remoteMonitor=nil;
  NSString* _monitorApplicationName=nil;
  NSNumber* _port=nil;
  LOGObjectFnStart();
  _monitorApplicationName=[self _monitorApplicationName];
  _port=[[self class]port];
  _remoteMonitor=[self _remoteMonitor];
  LOGObjectFnStop();
  return (_remoteMonitor!=nil);
};

//--------------------------------------------------------------------
-(id)_remoteMonitor
{
  LOGObjectFnStart();
  if (!remoteMonitor)
	{
	  NSString* _monitorHost=[self _monitorHost];
	  NSNumber* _workerThreadCount=[[self class]workerThreadCount];
	  id _proxy=nil;
	  [NSDistantObject setDebug:YES];
	  remoteMonitorConnection = [NSConnection connectionWithRegisteredName:GSWMonitorServiceName
											  host:_monitorHost];
	  _proxy=[remoteMonitorConnection rootProxy];
	  remoteMonitor=[_proxy targetForProxy];
	  [self _synchronizeInstanceSettingsWithMonitor:remoteMonitor];
	};
  LOGObjectFnStop();
  return remoteMonitor;
};

//--------------------------------------------------------------------
-(NSString*)_monitorHost
{
  return [[self class]monitorHost];
};

//--------------------------------------------------------------------
-(NSString*)_monitorApplicationName
{
  NSString* _name=[self name];
  NSNumber* _port=[[self class]port];
  NSString* _monitorApplicationName=[NSString stringWithFormat:@"%@-%@",
											  _name,
											  _port];
  return _monitorApplicationName;
};

//--------------------------------------------------------------------
//TODO return value is Vv8@0:4 and not void !
-(void)_terminateFromMonitor
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationK)

//--------------------------------------------------------------------
-(void)_validateAPI
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWApplication (GSWAdaptorManagement)

//--------------------------------------------------------------------
//adaptors

-(NSArray*)adaptors 
{
  return adaptors;
};

//--------------------------------------------------------------------
//adaptorWithName:arguments:

-(GSWAdaptor*)adaptorWithName:(NSString*)name_
				   arguments:(NSDictionary*)arguments_ 
{
/*
  //call _isDynamicLoadingEnabled
  // call isTerminating
  //call isCachingEnabled
  //call isPageRefreshOnBacktrackEnabled
*/
  GSWAdaptor* adaptor=nil;
  Class gswadaptorClass=nil;
  Class adaptorClass=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"adaptor name:%@",name_);
  gswadaptorClass=[GSWAdaptor class];
  adaptorClass=NSClassFromString(name_);
  if (adaptorClass)
	{
	  if (ClassIsKindOfClass(adaptorClass,gswadaptorClass))
		{
		  adaptor=[[[adaptorClass alloc] initWithName:name_
										 arguments:arguments_] autorelease];
		};
	};
  NSDebugMLLog(@"low",@"adaptor:%@",adaptor);
  LOGObjectFnStop();
  return adaptor;
};

@end

//====================================================================
@implementation GSWApplication (GSWCacheManagement)

//--------------------------------------------------------------------
//setCachingEnabled:
-(void)setCachingEnabled:(BOOL)flag_ 
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//isCachingEnabled
-(BOOL)isCachingEnabled 
{
  //OK
  return [[self class]isCachingEnabled];
};

@end

//====================================================================
@implementation GSWApplication (GSWSessionManagement)

//--------------------------------------------------------------------
//sessionStore
-(GSWSessionStore*)sessionStore 
{
  return sessionStore;
};

//--------------------------------------------------------------------
//setSessionStore:
-(void)setSessionStore:(GSWSessionStore*)sessionStore_
{
  ASSIGN(sessionStore,sessionStore_);
};

//--------------------------------------------------------------------
-(void)saveSessionForContext:(GSWContext*)context_
{
  GSWSession* _session=nil;
  LOGObjectFnStart();
  _session=[context_ existingSession];
  NSDebugMLLog(@"sessions",@"_session=%@",_session);
  if (_session)
	{
	  [self _saveSessionForContext:context_];
	  NSDebugMLLog(@"sessions",@"_session=%@",_session);
	  NSDebugMLLog(@"sessions",@"sessionStore=%@",sessionStore);
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_saveSessionForContext:(GSWContext*)context_
{
  //OK
  GSWSession* _session=nil;
  LOGObjectFnStart();
  _session=[context_ existingSession];
  NSDebugMLLog(@"sessions",@"_session=%@",_session);
  if (_session)
	{
	  [_session sleepInContext:context_];
	  NSDebugMLLog(@"sessions",@"_session=%@",_session);
	  [sessionStore checkInSessionForContext:context_];
	  NSDebugMLLog(@"sessions",@"_session=%@",_session);
	  [context_ _setSession:nil];
	  NSDebugMLLog(@"sessions",@"_session=%@",_session);
	  NSDebugMLLog(@"sessions",@"sessionStore=%@",sessionStore);
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWSession*)restoreSessionWithID:(NSString*)sessionID_
						 inContext:(GSWContext*)context_
{
  GSWSession* _session=nil;
  //OK
  LOGObjectFnStart();
  [context_ _setRequestSessionID:sessionID_];
  NSDebugMLLog(@"sessions",@"sessionID_=%@",sessionID_);
  NSDebugMLLog(@"sessions",@"sessionStore=%@",sessionStore);
  _session=[self _restoreSessionWithID:sessionID_
				 inContext:context_];
  [context_ _setRequestSessionID:nil]; //ATTN: pass nil for unkwon reason
  NSDebugMLLog(@"sessions",@"_session=%@",_session);
  LOGObjectFnStop();
  return _session;
};

//--------------------------------------------------------------------
-(GSWSession*)_restoreSessionWithID:(NSString*)sessionID_
						 inContext:(GSWContext*)context_
{
  //OK
  GSWRequest* _request=nil;
  GSWSession* _session=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"context_=%@",context_);
  _request=[context_ request];
  NSDebugMLLog(@"sessions",@"_request=%@",_request);
  NSDebugMLLog(@"sessions",@"sessionID_=%@",sessionID_);
  NSDebugMLLog(@"sessions",@"sessionStore=%@",sessionStore);
  _session=[sessionStore checkOutSessionWithID:sessionID_
						 request:_request];
  [context_ _setSession:_session];//even if nil :-)
  [_session awakeInContext:context_];//even if nil :-)
  NSDebugMLLog(@"sessions",@"_session=%@",_session);
  LOGObjectFnStop();
  return _session;
};

//--------------------------------------------------------------------
-(Class)_sessionClass
{
  //OK
  Class _sessionClass=nil;
  LOGObjectFnStart();
/*  [[GSWResourceManager _applicationGSWBundle] lock];
  [[GSWResourceManager _applicationGSWBundle] unlock];
*/
  _sessionClass=[[GSWResourceManager _applicationGSWBundle] scriptedClassWithName:GSWClassName_Session
														  superclassName:GSWClassName_Session];
  if (!_sessionClass)
	_sessionClass=NSClassFromString(GSWClassName_Session);

/*

  //Search Compiled Class "Session" (subclass of GSWsession)
  _gswsessionClass=NSClassFromString();
  _sessionClass=NSClassFromString(GSWClassName_Session);

  //If not found, search for library "Session" in application .gswa directory
  if (!_sessionClass)
	{
	  NSString* sessionPath=[self pathForResourceNamed:@"session"
								  ofType:nil];
	  Class _principalClass=[self libraryClassWithPath:sessionPath];
	  NSDebugMLLog(@"low",@"_principalClass=%@",_principalClass);
	  if (_principalClass)
		{
		  _sessionClass=NSClassFromString(GSWClassName_Session);
		  NSDebugMLLog(@"low",@"sessionClass=%@",_sessionClass);
		};
	};

  //If not found, search for scripted "Session" in application .gswa directory
  if (!_sessionClass)
	{
	  //TODO
	};

  //If not found, search for scripted "Session" in a session.gsws file
  if (!_sessionClass)
	{
	  //TODO
	};

  if (!_sessionClass)
	{
	  _sessionClass=_gswsessionClass;
	}
  else
	{
	  if (!ClassIsKindOfClass(_sessionClass,_gswsessionClass))
		{
		  //TODO exception
		  NSDebugMLLog(@"low",@"session class is not a kind of GSWSession\n");
		}
	};
  NSDebugMLLog(@"low",@"_sessionClass:%@",_sessionClass);
*/
  LOGObjectFnStop();
  return _sessionClass;
};

//--------------------------------------------------------------------
-(GSWSession*)createSessionForRequest:(GSWRequest*)request_
{
  //OK
  GSWSession* _session=nil;
  LOGObjectFnStart();
  _session=[self _createSessionForRequest:request_];
  NSDebugMLLog(@"sessions",@"_session:%@",_session);
  LOGObjectFnStop();
  return _session;
};

//--------------------------------------------------------------------
-(GSWSession*)_createSessionForRequest:(GSWRequest*)request_
{
  //OK
  Class _sessionClass=Nil;
  GSWSession* _session=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  _sessionClass=[self _sessionClass];
	  NSDebugMLLog(@"sessions",@"_sessionClass:%@",_sessionClass);
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In _sessionClass");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  if (!_sessionClass)
	{
	  //TODO erreur
	  NSDebugMLLog0(@"low",@"No Session Class");
	}
  else
	{
	  _session=[[_sessionClass new]autorelease];
	};
  NSDebugMLLog(@"sessions",@"_session:%@",_session);
  LOGObjectFnStop();
  return _session;
};

@end

//====================================================================
@implementation GSWApplication (GSWPageManagement)

//--------------------------------------------------------------------
//setPageCacheSize:

-(void)setPageCacheSize:(unsigned int)size_
{
  pageCacheSize = size_;
};

//--------------------------------------------------------------------
//pageCacheSize

-(unsigned int)pageCacheSize 
{
  return pageCacheSize;
};

//--------------------------------------------------------------------
-(unsigned)permanentPageCacheSize;
{
  return permanentPageCacheSize;
};

//--------------------------------------------------------------------
-(void)setPermanentPageCacheSize:(unsigned)size_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//isPageRefreshOnBacktrackEnabled

-(BOOL)isPageRefreshOnBacktrackEnabled 
{
  return pageRefreshOnBacktrackEnabled;
};

//--------------------------------------------------------------------
-(void)setPageRefreshOnBacktrackEnabled:(BOOL)_flag
{
  [self lock];
  pageRefreshOnBacktrackEnabled=_flag;
  [self unlock];
};

//--------------------------------------------------------------------
-(GSWComponent*)pageWithName:(NSString*)name_
				 forRequest:(GSWRequest*)request_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(GSWComponent*)pageWithName:(NSString*)name_
				  inContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _component=nil;
  LOGObjectFnStart();
  NSAssert(context_,@"No Context");
  _component=[self _pageWithName:name_
				   inContext:context_];
  LOGObjectFnStop();
  return _component;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)defaultPageName
{
  return GSWMainPageName;
};

//--------------------------------------------------------------------
-(GSWComponent*)_pageWithName:(NSString*)name_
					inContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _component=nil;
  GSWComponentDefinition* _componentDefinition=nil;
  NSArray* _languages=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"info",@"name_=%@",name_);
  NSAssert(context_,@"No Context");
  [self lock];
  NS_DURING
	{
	  if ([name_ length]<=0)
		name_=[self defaultPageName];//NDFN
	  if ([name_ length]<=0)
		name_=GSWMainPageName;
	  _languages=[context_ languages];
	  _componentDefinition=[self lockedComponentDefinitionWithName:name_
								 languages:_languages];
	  NSDebugMLLog(@"low",@"_componentDefinition=%@ (%@)",_componentDefinition,[_componentDefinition class]);
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In lockedComponentDefinitionWithName:");
	  LOGException(@"exception=%@",localException);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  NS_DURING
	{
	  if (!_componentDefinition)
		{
		  //TODO
		  NSDebugMLLog0(@"low",@"GSWApplication _pageWithName no _componentDefinition");
		}
	  else
		{
		  NSAssert(context_,@"No Context");
		  _component=[_componentDefinition componentInstanceInContext:context_];
		  NSAssert(context_,@"No Context");
		  [_component awakeInContext:context_];
		  [_component _setIsPage:YES];
		};
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In componentInstanceInContext:");
	  LOGException(@"exception=%@",localException);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return _component;
};
@end

//====================================================================
@implementation GSWApplication (GSWElementCreation)

//--------------------------------------------------------------------
-(GSWElement*)dynamicElementWithName:(NSString*)name_
						associations:(NSDictionary*)associations_
							template:(GSWElement*)templateElement_
						   languages:(NSArray*)languages_
{
  GSWElement* _element=nil;
  [self lock];
  NS_DURING
	{
	  _element=[self lockedDynamicElementWithName:name_
					 associations:associations_
					 template:templateElement_
					 languages:languages_];
	}
  NS_HANDLER
	{
	  [self unlock];
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In lockedDynamicElementWithName:associations:template:languages:");
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  return _element;
};

//--------------------------------------------------------------------
-(GSWElement*)lockedDynamicElementWithName:(NSString*)name_
							  associations:(NSDictionary*)associations_
								  template:(GSWElement*)templateElement_
								 languages:(NSArray*)languages_
{
  GSWElement* _element=nil;
  Class _elementClass=nil;
  //lock bundle
  //unlock bundle
  if ([associations_ isAssociationDebugEnabledInComponent:nil])
	[associations_ associationsSetDebugEnabled];
  _elementClass=NSClassFromString(name_);
  NSDebugMLLog(@"low",@"_elementClass:%@",_elementClass);
  NSDebugMLLog(@"low",@"_elementClass superClass:%@",[_elementClass superClass]);
  if (_elementClass && !ClassIsKindOfClass(_elementClass,NSClassFromString(@"GSWComponent")))
	{
	  NSDebugMLLog(@"low",@"CREATE Element of Class:%@",name_);
	  _element=[[[_elementClass alloc] initWithName:name_
									   associations:associations_
									   template:templateElement_]
				 autorelease];
	  NSDebugMLLog(@"low",@"Created Element: %@",_element);
	}
  else
	{
	  GSWComponentDefinition* _componentDefinition=nil;
	  _componentDefinition=[self lockedComponentDefinitionWithName:name_
								 languages:languages_];
	  if (_componentDefinition)
		{
		  NSDebugMLLog(@"low",@"CREATE SubComponent:%@",name_);
		  _element=[_componentDefinition componentReferenceWithAssociations:associations_
										 template:templateElement_];
		  NSDebugMLLog(@"low",@"Created SubComponent: %@",_element);
		}
	  else
		{
		  ExceptionRaise(@"GSWApplication",
						 @"GSWApplication: Component Definition named '%@' not found or can't be created",
						 name_);
		};
	};
  return _element;
};


@end

//====================================================================
@implementation GSWApplication (GSWRunning)
//--------------------------------------------------------------------
//run

-(void)run 
{
  //call allowsConcurrentRequestHandling
  //call [[self class]_multipleThreads];
  //call [self name];
  //call [[self class]_requestWindow];
  //call [[self class]_requestLimit];
  //call [self becomesMultiThreaded];
  //call [[self class]_requestWindow];
  //call [[self class]_requestLimit];
  //call [self resourceManager];
  SEL registerForEventsSEL=@selector(registerForEvents);
  SEL unregisterForEventsSEL=@selector(unregisterForEvents);
  NSDebugMLLog0(@"low",@"GSWApplication run");
  LOGObjectFnStart();
  [adaptors makeObjectsPerformSelector:registerForEventsSEL];
  NSDebugMLLog0(@"low",@"NSRunLoop run");
	  //call adaptor run
	  //call self _openInitialURL
  NSDebugMLLog(@"low",@"GSCurrentThreadDictionary()=%@",GSCurrentThreadDictionary());
  NSDebugMLLog(@"low",@"[NSRunLoop currentRunLoop]=%@",[NSRunLoop currentRunLoop]);
  ASSIGN(currentRunLoop,[NSRunLoop currentRunLoop]);
  NSDebugMLLog(@"low",@"GSCurrentThreadDictionary()=%@",GSCurrentThreadDictionary());
  [NSRunLoop run];
  
  NSDebugMLLog0(@"low",@"NSRunLoop end run");
  [adaptors makeObjectsPerformSelector:unregisterForEventsSEL];
  NSDebugMLLog0(@"low",@"GSWApplication end run");
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//runLoop

-(NSRunLoop*)runLoop 
{
  return currentRunLoop;//[NSRunLoop currentRunLoop];
};

//--------------------------------------------------------------------
// threadWillExit
//NDFN
-(void)threadWillExit
{
  GSWLogC("GC** GarbageCollector collectGarbages START");
  [GarbageCollector collectGarbages];
  GSWLogC("GC** GarbageCollector collectGarbages STOP");
};

//--------------------------------------------------------------------
//setTimeOut:

-(void)setTimeOut:(NSTimeInterval)timeInterval_ 
{
  timeOut=timeInterval_;
};

//--------------------------------------------------------------------
//timeOut

-(NSTimeInterval)timeOut 
{
  return timeOut;
};

//--------------------------------------------------------------------
//isTerminating

-(BOOL)isTerminating 
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
//terminate
//TODO return (Vv8@0:4)
-(void)terminate 
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_scheduleApplicationTimerForTimeInterval:(NSTimeInterval)timeInterval_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//NDFN
-(void)addTimer:(NSTimer*)timer_
{
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  NSDebugMLLog(@"low",@"[self runLoop]=%p",(void*)[self runLoop]);
	  NSDebugMLLog(@"low",@"currentMode=%@",[[self runLoop]currentMode]);
	  NSDebugMLLog(@"low",@"NSDefaultRunLoopMode=%@",NSDefaultRunLoopMode);
	  [[self runLoop]addTimer:timer_
					 forMode:NSDefaultRunLoopMode];
	  NSDebugMLLog(@"low",@"limitDateForMode=%@",[[self runLoop]limitDateForMode:NSDefaultRunLoopMode]);
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In addTimer:");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)cancelInitialTimer
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)handleInitialTimer
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_setNextCollectionCount:(int)_count
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_sessionDidTimeOutNotification:(NSNotification*)notification_
{
  //OK
  // does nothing ?
};

//--------------------------------------------------------------------
-(void)_openInitialURL
{
  //call resourceMLanager ?
  if ([[self class]isDirectConnectEnabled])
	{
	  NSString* _directConnectURL=[self _directConnectURL];
	  if ([[self class]autoOpenInBrowser])
		{
		  [self _openURL:_directConnectURL];
		  if ([[self class]isDebuggingEnabled])
			{
			  //TODO
			};
		};
	}
  else
	{
	  //TODO
	};
};

//--------------------------------------------------------------------
-(void)_openURL:(NSString*)_url
{
//  [NSBundle bundleForClass:XX];
  //TODO finish
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(BOOL)runOnce
{
  LOGObjectFnNotImplemented();	//TODOFN
  return YES;
};

@end

//====================================================================
@implementation GSWApplication (GSWRequestHandling)
-(GSWResponse*)dispatchRequest:(GSWRequest*)request_
{
  //OK
  GSWResponse* _response=nil;
  GSWRequestHandler* _requestHandler=nil;
  LOGObjectFnStart();
#ifndef NDEBUG
  [self lock];
  GSWApplicationDebugSetChange();
  [self unlock];
#endif
  NSDebugMLLog(@"requests",@"request_=%@",request_);
  _requestHandler=[self handlerForRequest:request_];
  NSDebugMLLog(@"requests",@"_requestHandler=%@",_requestHandler);
  if (!_requestHandler)
	_requestHandler=[self defaultRequestHandler];
  NSDebugMLLog(@"requests",@"_requestHandler=%@",_requestHandler);
  if (!_requestHandler)
	{
	  NSDebugMLLog0(@"low",@"GSWApplication dispatchRequest: no request handler");
	  //TODO error
	}
  else
	{
	  NSDebugMLLog(@"requests",@"sessionStore=%@",sessionStore);
	  _response=[_requestHandler handleRequest:request_];
	  NSDebugMLLog(@"requests",@"sessionStore=%@",sessionStore);
	  [self _resetCache];
	  NSDebugMLLog(@"requests",@"sessionStore=%@",sessionStore);
	};
  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
//awake

-(void)awake
{
  //Does Nothing
};

//--------------------------------------------------------------------
//takeValuesFromRequest:inContext:

-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_ 
{
  //OK
  GSWSession* _session=nil;
  LOGObjectFnStart();
  [context_ setValidate:YES];
  _session=[context_ existingSession];
  [_session takeValuesFromRequest:request_
			inContext:context_];
  [context_ setValidate:NO];
  LOGObjectFnStop();
};


//--------------------------------------------------------------------
//invokeActionForRequest:inContext:

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_ 
{
  //OK
  GSWElement* element=nil;
  GSWSession* _session=nil;
  LOGObjectFnStart();
  NS_DURING
	{
	  _session=[context_ existingSession];
	  element=[_session invokeActionForRequest:request_
						inContext:context_];
	}
  NS_HANDLER
	{
	  LOGException0(@"exception in GSWApplication invokeActionForRequest:inContext");
	  LOGException(@"exception=%@",localException);
	  localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
															  @"In GSWApplication invokeActionForRequest:inContext");
	  LOGException(@"exception=%@",localException);
	  [localException raise];
	}
  NS_ENDHANDLER;
  LOGObjectFnStop();
  return element;
};

//--------------------------------------------------------------------
//appendToResponse:inContext:

-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_ 
{
  //OK
  GSWRequest* _request=nil;
  GSWSession* _session=nil;
  LOGObjectFnStart();
  _request=[context_ request];
  _session=[context_ existingSession];
  [_session appendToResponse:response_
			inContext:context_];
  //call request headerForKey:@"x-gsweb-recording"
  //call applic recordingPath
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//sleep

-(void)sleep 
{
  //Does Nothing
};

@end

//====================================================================
@implementation GSWApplication (GSWErrorHandling)

//--------------------------------------------------------------------
-(GSWResponse*)handleException:(NSException*)exception_ 
					  inContext:(GSWContext*)context_
{
  GSWResponse* _response=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"context=%@",context_);
  NS_DURING
	{
	  _response=[self _handleException:exception_ 
					  inContext:context_];
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In _handleException:inContext:");
	  LOGException(@"exception=%@",localException);
	  //TODO
	  //Generate simple response !
	}
  NS_ENDHANDLER;

  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
-(GSWResponse*)_handleException:(NSException*)exception_ 
					  inContext:(GSWContext*)context_
{
  GSWContext* _context=context_;
  GSWResponse* _response=nil;
  GSWResourceManager* _resourceManager=nil;
  NSString* _exceptionPage=[NSString stringWithFormat:@"%@%@",
									 GSWExceptionPageName,
									 GSWPagePSuffix];
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"context=%@",_context);
  if (_context)
	[_context _putAwakeComponentsToSleep];
  else
	{
	  LOGError0(@"No context !");
	  _context=[GSWContext contextWithRequest:nil];	  
	};
  _resourceManager=[self resourceManager];
  if ([_resourceManager pathForResourceNamed:_exceptionPage
						inFramework:GSWFramework_extensions
						languages:nil])
	{
	  GSWComponent* _page=nil;
	  NS_DURING
		{
		  _page=[self pageWithName:GSWExceptionPageName
					  inContext:_context];
		  [_page setIVarNamed:@"exception"
				 withValue:exception_]; 
		}
	  NS_HANDLER
		{
		  LOGError0(@"exception in pageWithName while loading GSWExceptionPage !");
		  //TODO
		}
	  NS_ENDHANDLER;
	  if (_page)
		{
		  id _monitor=nil;
		  _response=[_page generateResponse];
		  _monitor=[self _remoteMonitor];
		  if (_monitor)
			{
			  NSString* _monitorApplicationName=[self _monitorApplicationName];
			  //TODO
			};
		};
	}
  else
	{
	  //TODO can't find exception page !
	};
  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
//handlePageRestorationError
-(GSWResponse*)handlePageRestorationErrorInContext:(GSWContext*)context_
{
  GSWResponse* _response=nil;
  LOGObjectFnStart();
  NS_DURING
	{
	  _response=[self _handlePageRestorationErrorInContext:context_];
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In _handlePageRestorationErrorInContext:");
	  LOGException(@"exception=%@",localException);
	  //TODO
	  //Generate simple response !
	}
  NS_ENDHANDLER;
  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
//handlePageRestorationError
-(GSWResponse*)_handlePageRestorationErrorInContext:(GSWContext*)context_
{
  GSWContext* _context=context_;
  GSWResponse* _response=nil;
  GSWComponent* _errorPage=nil;
  GSWResourceManager* _resourceManager=nil;
  NSString* _restorationErrorPage=[NSString stringWithFormat:@"%@%@",
											GSWPageRestorationErrorPageName,
											GSWPagePSuffix];
  LOGObjectFnStart();
  if (_context)
	[_context _putAwakeComponentsToSleep];
  else
	{
	  LOGError0(@"No context !");
	  _context=[GSWContext contextWithRequest:nil];	  
	};
  _resourceManager=[self resourceManager];
  NSDebugMLLog0(@"low",@"GSWComponentRequestHandler _dispatchWithPreparedSession no page");
  if ([_resourceManager pathForResourceNamed:_restorationErrorPage
						inFramework:GSWFramework_extensions
						languages:nil])
	{
	  NS_DURING
		{
		  _errorPage=[self pageWithName:GSWPageRestorationErrorPageName
						   inContext:_context];
		}
	  NS_HANDLER
		{
		  LOGError0(@" exception in pageWithName while loading GSWPageRestorationErrorPage !");
		  //TODO
		}
	  NS_ENDHANDLER;
	}
  else
	{
	  LOGError0(@"");//TODO
	};
  if (_errorPage)
	_response=[_errorPage generateResponse];
  else
	{
	  //TODO
	};
  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
//handleSessionCreationError
-(GSWResponse*)handleSessionCreationErrorInContext:(GSWContext*)context_
{
  GSWResponse* _response=nil;
  LOGObjectFnStart();
  NS_DURING
	{
	  _response=[self _handleSessionCreationErrorInContext:context_];
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In _handleSessionCreationErrorInContext:");
	  LOGException(@"exception=%@",localException);
	  //TODO
	  //Generate simple response !
	}
  NS_ENDHANDLER;
  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
//handleSessionCreationError
-(GSWResponse*)_handleSessionCreationErrorInContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
//handleSessionRestorationError

-(GSWResponse*)handleSessionRestorationErrorInContext:(GSWContext*)context_
{
  GSWResponse* _response=nil;
  LOGObjectFnStart();
  NS_DURING
	{
	  _response=[self _handleSessionRestorationErrorInContext:context_];
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In _handleSessionRestorationErrorInContext:");
	  LOGException(@"exception=%@",localException);
	  //TODO
	  //Generate simple response !
	}
  NS_ENDHANDLER;
  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
//handleSessionRestorationError

-(GSWResponse*)_handleSessionRestorationErrorInContext:(GSWContext*)context_
{
  GSWContext* _context=context_;
  GSWResponse* _response=nil;
  GSWComponent* _errorPage=nil;
  GSWResourceManager* _resourceManager=nil;
  NSString* _sessionRestorationErrorPage=[NSString stringWithFormat:@"%@%@",
												   GSWSessionRestorationErrorPageName,
												   GSWPagePSuffix];
  LOGObjectFnStart();
  if (_context)
	[_context _putAwakeComponentsToSleep];
  else
	{
	  LOGError0(@"No context !");
	  _context=[GSWContext contextWithRequest:nil];	  
	};
  _resourceManager=[self resourceManager];
  if ([_resourceManager pathForResourceNamed:_sessionRestorationErrorPage
						inFramework:GSWFramework_extensions
						languages:nil])
	{
	  NS_DURING
		{
		  _errorPage=[self pageWithName:GSWSessionRestorationErrorPageName
						   inContext:_context];
		}
	  NS_HANDLER
		{
		  LOGError0(@"Exception in pageWIthName while loading GSWSessionRestorationErrorPage !");
		  //TODO
		}
	  NS_ENDHANDLER;
	}
  else
	{
	  LOGError0(@"");//TODO
	};
  if (_errorPage)
	_response=[_errorPage generateResponse];
  else
	{
	  //TODO
	};
  LOGObjectFnStart();
  return _response;
};
@end

//====================================================================
@implementation GSWApplication (GSWConveniences)
+(GSWApplication*)application
{
  return GSWApp;
};

+(void)_setApplication:(GSWApplication*)_application
{
  //OK
  //Call self _isDynamicLoadingEnabled
  //call self isTerminating
  //call self isCachingEnabled
  //call self isPageRefreshOnBacktrackEnabled
  GSWApp=_application;
};

@end

//====================================================================
@implementation GSWApplication (GSWHTMLTemplateParsingDebugging)
//--------------------------------------------------------------------
//setPrintsHTMLParserDiagnostics:

-(void)setPrintsHTMLParserDiagnostics:(BOOL)flag_ 
{
  [self lock];
  NS_DURING
	{
	  printsHTMLParserDiagnostics=flag_;
	}
  NS_HANDLER
	{
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
};

//--------------------------------------------------------------------
//printsHTMLParserDiagnostics

-(BOOL)printsHTMLParserDiagnostics 
{
  return [GSWHTMLParser printsDiagnostics];
};

@end

//====================================================================
@implementation GSWApplication (GSWScriptedObjectSupport)
//--------------------------------------------------------------------
//scriptedClassWithPath:

-(Class)scriptedClassWithPath:(NSString*)path_ 
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
//scriptedClassWithPath:encoding:

-(Class)scriptedClassWithPath:(NSString*)path_
					 encoding:(NSStringEncoding)encoding_ 
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(Class)_classWithScriptedClassName:(NSString*)_name
						  languages:(NSArray*)_languages
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)_setClassFromNameResolutionEnabled:(BOOL)_flag
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWApplication (GSWLibrarySupport)
//--------------------------------------------------------------------
//NDFN
-(Class)libraryClassWithPath:(NSString*)path_
{
  Class _class=nil;
  NSBundle* bundle=[NSBundle bundleWithPath:path_];
  NSDebugMLLog(@"low",@"GSWApplication libraryClassWithPath:bundle=%@",bundle);
  if (bundle)
	{
	  BOOL result=[bundle load];
	  NSDebugMLLog(@"low",@"GSWApplication libraryClassWithPath:bundle load result=%d",result);
	  _class=[bundle principalClass];
	  NSDebugMLLog(@"low",@"GSWApplication libraryClassWithPath:bundle _class=%@",_class);
	};
  return _class;
};

@end

@implementation GSWApplication (GSWDebugging)

//--------------------------------------------------------------------
-(void)debugWithString:(NSString*)string_
{
  if ([[self class]isDebuggingEnabled])
	{
	  fputs([string_ cString],stderr);
	  fputs("\n",stderr);
	  fflush(stderr);
	};
};

//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)format_
			  arguments:(va_list)arguments_
{
  NSString* _string=[NSString stringWithFormat:format_
							  arguments:arguments_];
  [self debugWithString:_string];
};

//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)format_,...
{
  va_list ap=NULL;
  va_start(ap,format_);
  [self debugWithFormat:format_
		  arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)debugWithFormat:(NSString*)format_,...
{
  va_list ap=NULL;
  va_start(ap,format_);
  [GSWApp debugWithFormat:format_
		  arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------

-(void)_setTracingAspect:(id)_unknwon
				 enabled:(BOOL)_enabled
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)format_,...
{
  va_list ap=NULL;
  va_start(ap,format_);
  [self logWithFormat:format_
		arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)logWithFormat:(NSString*)format_,...
{
  va_list ap=NULL;
  va_start(ap,format_);
  [GSWApp logWithFormat:format_
		  arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)format_
		   arguments:(va_list)arguments_
{
  NSString* string=[NSString stringWithFormat:format_
							 arguments:arguments_];
  fputs([string cString],stderr);
  fputs("\n",stderr);
  fflush(stderr);
};

//--------------------------------------------------------------------
-(void)logErrorWithFormat:(NSString*)format_,...
{
  va_list ap=NULL;
  va_start(ap,format_);
  [self logErrorWithFormat:format_
		arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)logErrorWithFormat:(NSString*)format_,...
{
  va_list ap=NULL;
  va_start(ap,format_);
  [GSWApp logErrorWithFormat:format_
		  arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(void)logErrorWithFormat:(NSString*)format_
		   arguments:(va_list)arguments_
{
  const char* cString=NULL;
  NSString* string=[NSString stringWithFormat:format_
							 arguments:arguments_];
  cString=[string cString];
  fputs(cString,stderr);
  fputs("\n",stderr);
  fflush(stderr);
#ifndef NDEBUG
  fputs(cString,stdout);
  fputs("\n",stdout);
  fflush(stdout);
#endif
};

//--------------------------------------------------------------------
//trace:
-(void)trace:(BOOL)flag_ 
{
  if (flag_!=isTracingEnabled)
	{
	  [self lock];
	  isTracingEnabled=flag_;
	  [self unlock];
	};
};

//--------------------------------------------------------------------
//traceAssignments:
-(void)traceAssignments:(BOOL)flag_ 
{
  if (flag_!=isTracingAssignmentsEnabled)
	{
	  [self lock];
	  isTracingAssignmentsEnabled=flag_;
	  [self unlock];
	};
};

//--------------------------------------------------------------------
//traceObjectiveCMessages:
-(void)traceObjectiveCMessages:(BOOL)flag_ 
{
  if (flag_!=isTracingObjectiveCMessagesEnabled)
	{
	  [self lock];
	  isTracingObjectiveCMessagesEnabled=flag_;
	  [self unlock];
	};
};

//--------------------------------------------------------------------
//traceScriptedMessages:
-(void)traceScriptedMessages:(BOOL)flag_ 
{
  if (flag_!=isTracingScriptedMessagesEnabled)
	{
	  [self lock];
	  isTracingScriptedMessagesEnabled=flag_;
	  [self unlock];
	};
};

//--------------------------------------------------------------------
//traceStatements:
-(void)traceStatements:(BOOL)flag_ 
{
  if (flag_!=isTracingStatementsEnabled)
	{
	  [self lock];
	  isTracingStatementsEnabled=flag_;
	  [self unlock];
	};
};

//--------------------------------------------------------------------
+(void)logSynchronizeComponentToParentForValue:(id)value_
								   association:(GSWAssociation*)association_
								   inComponent:(NSObject*)component_
{
  //TODO
  [self logWithFormat:@"ComponentToParent [%@:%@] %@ ==> %@",
		@"",
		[component_ description],
		value_,
		[association_ bindingName]];
};

//--------------------------------------------------------------------
+(void)logSynchronizeParentToComponentForValue:(id)value_
								   association:(GSWAssociation*)association_
								   inComponent:(NSObject*)component_
{
  //TODO
  [self logWithFormat:@"ParentToComponent [%@:%@] %@ ==> %@",
		@"",
		[component_ description],
		value_,
		[association_ bindingName]];
};

//--------------------------------------------------------------------
+(void)logTakeValueForDeclarationNamed:(NSString*)declarationName_
								  type:(NSString*)declarationType_
						  bindingNamed:(NSString*)bindingName_
				associationDescription:(NSString*)associationDescription_
								 value:(id)value_
{
  [GSWApp logTakeValueForDeclarationNamed:declarationName_
		  type:declarationType_
		  bindingNamed:bindingName_
		  associationDescription:associationDescription_
		  value:value_];
};

//--------------------------------------------------------------------
+(void)logSetValueForDeclarationNamed:(NSString*)declarationName_
								 type:(NSString*)declarationType_
						 bindingNamed:(NSString*)bindingName_
			   associationDescription:(NSString*)associationDescription_
								value:(id)value_
{
  [GSWApp logSetValueForDeclarationNamed:declarationName_
		  type:declarationType_
		  bindingNamed:bindingName_
		  associationDescription:associationDescription_
		  value:value_];
};

//--------------------------------------------------------------------
-(void)logTakeValueForDeclarationNamed:(NSString*)declarationName_
								  type:(NSString*)declarationType_
						  bindingNamed:(NSString*)bindingName_
				associationDescription:(NSString*)associationDescription_
								 value:(id)value_
{
  //TODO
  [self logWithFormat:@"TakeValue DeclarationNamed:%@ type:%@ bindingNamed:%@ associationDescription:%@ value:%@",
		declarationName_,
		declarationType_,
		bindingName_,
		associationDescription_,
		value_];
};

//--------------------------------------------------------------------
-(void)logSetValueForDeclarationNamed:(NSString*)declarationName_
								 type:(NSString*)declarationType_
						 bindingNamed:(NSString*)bindingName_
			   associationDescription:(NSString*)associationDescription_
								value:(id)value_
{
  //TODO
  [self logWithFormat:@"SetValue DeclarationNamed:%@ type:%@ bindingNamed:%@ associationDescription:%@ value:%@",
		declarationName_,
		declarationType_,
		bindingName_,
		associationDescription_,
		value_];
};

@end

//====================================================================
//Same as GSWDebugging but it print messages on stdout AND call GSWDebugging methods
@implementation GSWApplication (GSWDebuggingStatus)

//--------------------------------------------------------------------
-(void)statusDebugWithString:(NSString*)string_
{
  if ([[self class]isStatusDebuggingEnabled])
	{
	  fputs([string_ cString],stdout);
	  fputs("\n",stdout);
	  fflush(stdout);
	  [self debugWithString:string_];
	};
};

//--------------------------------------------------------------------
-(void)statusDebugWithFormat:(NSString*)format_
				   arguments:(va_list)arguments_
{
  NSString* _string=[NSString stringWithFormat:format_
							  arguments:arguments_];
  [self statusDebugWithString:_string];
};

//--------------------------------------------------------------------
-(void)statusDebugWithFormat:(NSString*)format_,...
{
  va_list ap=NULL;
  va_start(ap,format_);
  [self statusDebugWithFormat:format_
		arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)statusDebugWithFormat:(NSString*)format_,...
{
  va_list ap=NULL;
  va_start(ap,format_);
  [GSWApp statusDebugWithFormat:format_
		  arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(void)statusLogWithFormat:(NSString*)format_,...
{
  va_list ap=NULL;
  va_start(ap,format_);
  [self statusLogWithFormat:format_
		arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)statusLogWithFormat:(NSString*)format_,...
{
  va_list ap=NULL;
  va_start(ap,format_);
  [GSWApp statusLogWithFormat:format_
		  arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(void)statusLogWithFormat:(NSString*)format_
				 arguments:(va_list)arguments_
{
  NSString* string=[NSString stringWithFormat:format_
							 arguments:arguments_];
  fputs([string cString],stdout);
  fputs("\n",stdout);
  fflush(stdout);
  [self logWithFormat:@"%@",string];
};

//--------------------------------------------------------------------
-(void)statusLogErrorWithFormat:(NSString*)format_,...
{
  va_list ap=NULL;
  va_start(ap,format_);
  [self statusLogErrorWithFormat:format_
		arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)statusLogErrorWithFormat:(NSString*)format_,...
{
  va_list ap=NULL;
  va_start(ap,format_);
  [GSWApp statusLogErrorWithFormat:format_
		  arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(void)statusLogErrorWithFormat:(NSString*)format_
					  arguments:(va_list)arguments_
{
  const char* cString=NULL;
  NSString* string=[NSString stringWithFormat:format_
							 arguments:arguments_];
  cString=[string cString];
  fputs(cString,stdout);
  fputs("\n",stdout);
  fflush(stdout);
  [self logErrorWithFormat:@"%@",string];
};

@end

//====================================================================
@implementation GSWApplication (GSWStatisticsSupport)
//--------------------------------------------------------------------
//statistics
-(bycopy NSDictionary*)statistics 
{
  return [[[[self statisticsStore] statistics] copy]autorelease];
};

//--------------------------------------------------------------------
//statisticsStore
-(GSWStatisticsStore*)statisticsStore 
{
  return statisticsStore;
};

//--------------------------------------------------------------------
//setStatisticsStore:
-(void)setStatisticsStore:(GSWStatisticsStore*)statisticsStore_
{
  ASSIGN(statisticsStore,statisticsStore_);
};

@end

//====================================================================
@implementation GSWApplication (MonitorableApplication)
//--------------------------------------------------------------------
//monitoringEnabled
-(BOOL)monitoringEnabled 
{
  //return monitoringEnabled;
  LOGObjectFnNotImplemented();	//TODOFN
  return YES;
};

//--------------------------------------------------------------------
//activeSessionsCount
-(int)activeSessionsCount 
{
  return activeSessionsCount;
};

//--------------------------------------------------------------------
//setMinimumActiveSessionsCount:
//TODO return (Vv12@0:4i8)
-(void)setMinimumActiveSessionsCount:(int)count_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//minimumActiveSessionsCountCount
-(int)minimumActiveSessionsCount
{
  return minimumActiveSessionsCount;
};

//--------------------------------------------------------------------
//isRefusingNewSessions
-(BOOL)isRefusingNewSessions 
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
//refuseNewSessions:
//TODO return: (Vv9@0:4c8)
-(void)refuseNewSessions:(BOOL)flag 
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//logToMonitorWithFormat:
-(void)logToMonitorWithFormat:(NSString*)format_ 
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//terminateAfterTimeInterval:
//TODO return (Vv16@0:4d8)
-(void)terminateAfterTimeInterval:(NSTimeInterval)timeInterval_ 
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWApplication (GSWResourceManagerSupport)
//--------------------------------------------------------------------
//setResourceManager:
-(void)setResourceManager:(GSWResourceManager*)resourceManager_ 
{
  //OK
  [self lock];
  NS_DURING
	{
	  ASSIGN(resourceManager,resourceManager_);
	}
  NS_HANDLER
	{
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
};

//--------------------------------------------------------------------
//resourceManager
-(GSWResourceManager*)resourceManager
{
  return resourceManager;
};

@end

//====================================================================
@implementation GSWApplication (RequestDispatching)

//--------------------------------------------------------------------
-(GSWRequestHandler*)defaultRequestHandler
{
  //OK
  return defaultRequestHandler;
};

//--------------------------------------------------------------------
-(void)setDefaultRequestHandler:(GSWRequestHandler*)handler_
{
  //OK
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  ASSIGN(defaultRequestHandler,handler_);
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"low",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)registerRequestHandler:(GSWRequestHandler*)handler_
					   forKey:(NSString*)key_
{
  //OK
  [self lock];
  NS_DURING
	{
	  if (!requestHandlers)
		requestHandlers=[NSMutableDictionary new];
	  [requestHandlers setObject:handler_
					   forKey:key_];
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"low",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
};

//--------------------------------------------------------------------
-(void)removeRequestHandlerForKey:(NSString*)requestHandlerKey_
{
  //OK
  [self lock];
  NS_DURING
	{
	  [requestHandlers removeObjectForKey:requestHandlerKey_];
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"low",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
};

//--------------------------------------------------------------------
-(NSArray*)registeredRequestHandlerKeys
{
  //OK
  return [requestHandlers allKeys];
};

//--------------------------------------------------------------------
-(GSWRequestHandler*)requestHandlerForKey:(NSString*)key_
{
  //OK
  GSWRequestHandler* _handler=nil;
  LOGObjectFnStart();
  _handler=[requestHandlers objectForKey:key_];
  NSDebugMLogCond(!_handler,@"requestHandlers=%@",requestHandlers);
  LOGObjectFnStop();
  return _handler;
};

//--------------------------------------------------------------------
-(GSWRequestHandler*)handlerForRequest:(GSWRequest*)request_
{
  //OK
  GSWRequestHandler* _handler=nil;
  NSString* _requestHandlerKey=nil;
  LOGObjectFnStart();
  _requestHandlerKey=[request_ requestHandlerKey];
  NSDebugMLLog(@"low",@"_requestHandlerKey=%@",_requestHandlerKey);
  _handler=[self requestHandlerForKey:_requestHandlerKey];
  LOGObjectFnStop();
  return _handler;
};

@end

//====================================================================
@implementation GSWApplication (UserDefaults)

//--------------------------------------------------------------------
//TODO: take values from application ?
+(NSArray*)loadFrameworks
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_LoadFrameworks];
};

//--------------------------------------------------------------------
+(void)setLoadFrameworks:(NSArray*)frameworks_
{
  [[NSUserDefaults standardUserDefaults] setObject:frameworks_
										 forKey:GSWOPT_LoadFrameworks];
};

//--------------------------------------------------------------------
+(BOOL)isDebuggingEnabled
{
  return [[[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_DebuggingEnabled] boolValue];
};

//--------------------------------------------------------------------
+(void)setDebuggingEnabled:(BOOL)flag_
{
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:flag_]
										 forKey:GSWOPT_DebuggingEnabled];
};

//--------------------------------------------------------------------
//NDFN
+(BOOL)isStatusDebuggingEnabled
{
  return [[[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_StatusDebuggingEnabled] boolValue];
};

//--------------------------------------------------------------------
//NDFN
+(void)setStatusDebuggingEnabled:(BOOL)flag_
{
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:flag_]
										 forKey:GSWOPT_StatusDebuggingEnabled];
};

//--------------------------------------------------------------------
+(BOOL)autoOpenInBrowser
{
  return [[[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_AutoOpenInBrowser] boolValue];
};

//--------------------------------------------------------------------
+(void)setAutoOpenInBrowser:(BOOL)flag_
{
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:flag_]
										 forKey:GSWOPT_AutoOpenInBrowser];
};

//--------------------------------------------------------------------
+(BOOL)isDirectConnectEnabled
{
  return [[[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_DirectConnectEnabled] boolValue];
};

//--------------------------------------------------------------------
+(void)setDirectConnectEnabled:(BOOL)flag_
{
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:flag_]
										 forKey:GSWOPT_DirectConnectEnabled];
};

//--------------------------------------------------------------------
+(NSString*)cgiAdaptorURL
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_CGIAdaptorURL];
};

//--------------------------------------------------------------------
+(void)setCGIAdaptorURL:(NSString*)url_
{
  [[NSUserDefaults standardUserDefaults] setObject:url_
										 forKey:GSWOPT_CGIAdaptorURL];
};

//--------------------------------------------------------------------
+(BOOL)isCachingEnabled
{
  return [[[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_CachingEnabled] boolValue];
};

//--------------------------------------------------------------------
+(void)setCachingEnabled:(BOOL)flag_
{
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:flag_]
										 forKey:GSWOPT_CachingEnabled];
};

//--------------------------------------------------------------------
+(NSString*)applicationBaseURL
{
  NSString* _url=nil;
  LOGClassFnStart();
  _url=[[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_ApplicationBaseURL];
  NSDebugMLLog(@"low",@"_url=%@",_url);
  LOGClassFnStop();
  return _url;
};

//--------------------------------------------------------------------
+(void)setApplicationBaseURL:(NSString*)baseURL_
{
  [[NSUserDefaults standardUserDefaults] setObject:baseURL_
										 forKey:GSWOPT_ApplicationBaseURL];
};

//--------------------------------------------------------------------
+(NSString*)frameworksBaseURL
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_FrameworksBaseURL];
};

//--------------------------------------------------------------------
+(void)setFrameworksBaseURL:(NSString*)string_
{
  [[NSUserDefaults standardUserDefaults] setObject:string_
										 forKey:GSWOPT_FrameworksBaseURL];
};

//--------------------------------------------------------------------
+(NSString*)recordingPath
{
  //return [[NSUserDefaults standardUserDefaults] objectForKey:@""];
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(void)setRecordingPath:(NSString*)path_
{
  // [[NSUserDefaults standardUserDefaults] setObject:path_
  //  forKey:@""];
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(NSArray*)projectSearchPath
{
  //OK //TODO
  NSArray* _projectSearchPath=nil;
  NSBundle* _mainBundle=nil;
  LOGClassFnStart();

  _mainBundle=[NSBundle mainBundle];
  NSDebugMLLog(@"options",@"[[NSUserDefaults  standardUserDefaults] dictionaryRepresentation]=%@",[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
  _projectSearchPath=[[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_ProjectSearchPath]; //return H:\\Wotests
  NSDebugMLLog(@"low",@"_projectSearchPath:%@",_projectSearchPath);
  if (!_projectSearchPath)
	{
	  //TODO dirty hack here !
	  NSBundle* _mainBundle=[self mainBundle];
	  NSString* _bundlePath=[_mainBundle bundlePath];
	  NSString* _path_=[_bundlePath stringGoodPath];
	  NSDebugMLLog(@"low",@"_bundlePath:%@",_bundlePath);
	  NSDebugMLLog(@"low",@"_path_:%@",_path_);
	  NSDebugMLLog(@"low",@"_mainBundle:%@",_mainBundle);
	  _path_=[_path_ stringByDeletingLastPathComponent];
	  NSDebugMLLog(@"low",@"_path_:%@",_path_);
	  _projectSearchPath=[NSArray arrayWithObject:_path_];
	};
  NSDebugMLLog(@"low",@"_projectSearchPath:%@",_projectSearchPath);
  LOGClassFnStop();
  return _projectSearchPath;
};

//--------------------------------------------------------------------
+(void)setProjectSearchPath:(NSArray*)paths_
{
  [[NSUserDefaults standardUserDefaults] setObject:paths_
										 forKey:GSWOPT_ProjectSearchPath];
};

//--------------------------------------------------------------------
+(BOOL)isMonitorEnabled
{
  return [[[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_MonitorEnabled] boolValue];
};

//--------------------------------------------------------------------
+(void)setMonitorEnabled:(BOOL)flag_
{
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:flag_]
										 forKey:GSWOPT_MonitorEnabled];
};

//--------------------------------------------------------------------
+(NSString*)monitorHost
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_MonitorHost];
};

//--------------------------------------------------------------------
+(void)setMonitorHost:(NSString*)hostName_
{
  [[NSUserDefaults standardUserDefaults] setObject:hostName_
										 forKey:GSWOPT_MonitorHost];
};

//--------------------------------------------------------------------
+(NSString*)SMTPHost
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_SMTPHost];
};

//--------------------------------------------------------------------
+(void)setSMTPHost:(NSString*)hostName_
{
  [[NSUserDefaults standardUserDefaults] setObject:hostName_
										 forKey:GSWOPT_SMTPHost];
};

//--------------------------------------------------------------------
+(NSString*)adaptor
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_Adaptor];
};

//--------------------------------------------------------------------
+(void)setAdaptor:(NSString*)adaptorName_
{
  [[NSUserDefaults standardUserDefaults] setObject:adaptorName_
										 forKey:GSWOPT_Adaptor];
};

//--------------------------------------------------------------------
+(id)port
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_Port];
};

//--------------------------------------------------------------------
+(void)setPort:(id)port_
{
  [[NSUserDefaults standardUserDefaults] setObject:port_
										 forKey:GSWOPT_Port];
  //TODO
  /*
	[[GSWApp adaptors] makeObjectsPerformSelector:@selector(setPort:)
	withObject:port_];
   */
};

//--------------------------------------------------------------------
+(id)host
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_Host];
};

//--------------------------------------------------------------------
+(void)setHost:(id)host_
{
  [[NSUserDefaults standardUserDefaults] setObject:host_
										 forKey:GSWOPT_Host];
  //TODO
  /*
	[[GSWApp adaptors] makeObjectsPerformSelector:@selector(setHost:)
	withObject:host_];
   */
};

//--------------------------------------------------------------------
+(id)listenQueueSize
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_ListenQueueSize];
};

//--------------------------------------------------------------------
+(void)setListenQueueSize:(id)listenQueueSize_
{
  [[NSUserDefaults standardUserDefaults] setObject:listenQueueSize_
										 forKey:GSWOPT_ListenQueueSize];
  [[GSWApp adaptors] makeObjectsPerformSelector:@selector(setListenQueueSize:)
					 withObject:listenQueueSize_];
};

//--------------------------------------------------------------------
+(id)workerThreadCount
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_WorkerThreadCount];
};

//--------------------------------------------------------------------
+(void)setWorkerThreadCount:(id)workerThreadCount_
{
  [[NSUserDefaults standardUserDefaults] setObject:workerThreadCount_
										 forKey:GSWOPT_WorkerThreadCount];
  [[GSWApp adaptors] makeObjectsPerformSelector:@selector(setWorkerThreadCount:)
					 withObject:workerThreadCount_];
};

//--------------------------------------------------------------------
+(NSArray*)additionalAdaptors
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_AdditionalAdaptors];
};

//--------------------------------------------------------------------
+(void)setAdditionalAdaptors:(NSArray*)adaptorsArray_
{
  [[NSUserDefaults standardUserDefaults] setObject:adaptorsArray_
										 forKey:GSWOPT_AdditionalAdaptors];
};

//--------------------------------------------------------------------
+(BOOL)includeCommentsInResponses
{
  return [[[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_IncludeCommentsInResponse] boolValue];
};

//--------------------------------------------------------------------
+(void)setIncludeCommentsInResponses:(BOOL)flag_
{
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:flag_]
										 forKey:GSWOPT_IncludeCommentsInResponse];
};

//--------------------------------------------------------------------
+(NSString*)componentRequestHandlerKey
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_ComponentRequestHandlerKey];
};

//--------------------------------------------------------------------
+(void)setComponentRequestHandlerKey:(NSString*)key_
{
  [[NSUserDefaults standardUserDefaults] setObject:key_
										 forKey:GSWOPT_ComponentRequestHandlerKey];
};

//--------------------------------------------------------------------
+(NSString*)directActionRequestHandlerKey
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_DirectActionRequestHandlerKey];
};

//--------------------------------------------------------------------
+(void)setDirectActionRequestHandlerKey:(NSString*)key_
{
  [[NSUserDefaults standardUserDefaults] setObject:key_
										 forKey:GSWOPT_DirectActionRequestHandlerKey];
};

//--------------------------------------------------------------------
+(NSString*)resourceRequestHandlerKey
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_ResourceRequestHandlerKey];
};

//--------------------------------------------------------------------
+(void)setResourceRequestHandlerKey:(NSString*)key_
{
  [[NSUserDefaults standardUserDefaults] setObject:key_
										 forKey:GSWOPT_ResourceRequestHandlerKey];
};

//--------------------------------------------------------------------
+(void)setSessionTimeOut:(id)timeOut_
{
  LOGClassFnStart();
  NSDebugMLLog(@"sessions",@"_sessionTimeOut=%@",timeOut_);
  [[NSUserDefaults standardUserDefaults] setObject:timeOut_
										 forKey:GSWOPT_SessionTimeOut];
  LOGClassFnStop();
};

//--------------------------------------------------------------------
+(id)sessionTimeOut
{
  id _sessionTimeOut=nil;
  LOGClassFnStart();
  _sessionTimeOut=[[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_SessionTimeOut];
  NSDebugMLLog(@"sessions",@"_sessionTimeOut=%@",_sessionTimeOut);
  LOGClassFnStop();
  return _sessionTimeOut;
};

//--------------------------------------------------------------------
//NDFN
+(NSString*)debugSetConfigFilePath
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:GSWOPT_DebugSetConfigFilePath];
};

//--------------------------------------------------------------------
+(void)setDebugSetConfigFilePath:(NSString*)debugSetConfigFilePath_
{
  [[NSUserDefaults standardUserDefaults] setObject:debugSetConfigFilePath_
										 forKey:GSWOPT_DebugSetConfigFilePath];
};

@end


//====================================================================
@implementation GSWApplication (GSWApplicationInternals)

//--------------------------------------------------------------------
+(NSDictionary*)_webServerConfigDictionary
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(Class)_applicationClass
{
  LOGObjectFnStart();
  [[GSWResourceManager _applicationGSWBundle] scriptedClassWithName:GSWClassName_Application//TODO
											  superclassName:GSWClassName_Application]; //retirune nil //TODO
  LOGObjectFnStop();
  return NSClassFromString(globalApplicationClassName);
};

//--------------------------------------------------------------------
+(Class)_compiledApplicationClass
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(GSWRequestHandler*)_componentRequestHandler
{
  return [GSWComponentRequestHandler handler];
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationClassB)

//--------------------------------------------------------------------
+(id)defaultModelGroup
{
  //OK
  GSWResourceManager* _resourceManager=[[GSWApplication application] resourceManager];
  GSWDeployedBundle* _appProjectBundle=[_resourceManager _appProjectBundle];
  NSArray* _allFrameworkProjectBundles=[_resourceManager _allFrameworkProjectBundles];
  //return <EOModelGroup
  return nil;
};

//--------------------------------------------------------------------
+(id)_modelGroupFromBundles:(id)_bundles
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationClassC)

//--------------------------------------------------------------------
-(NSDictionary*)mainBundleInfoDictionary
{
  return [[self class] mainBundleInfoDictionary];
};

//--------------------------------------------------------------------
+(NSDictionary*)mainBundleInfoDictionary
{
  return [[self mainBundle]infoDictionary];
};

//--------------------------------------------------------------------
-(NSDictionary*)bundleInfo
{
  return [[self class] bundleInfo];
};

//--------------------------------------------------------------------
+(NSDictionary*)bundleInfo
{
  return [[self mainBundle]infoDictionary];
};

//--------------------------------------------------------------------
-(NSBundle*)mainBundle
{
  return [[self class] mainBundle];
};
//--------------------------------------------------------------------
+(NSBundle*)mainBundle
{
  LOGClassFnNotImplemented();	//TODOFN
  return [NSBundle mainBundle];
/*
			_flags=unsigned int UINT:104005633
				_infoDictionary=id object:11365312 Description:{
    NSBundleExecutablePath = "H:\\Wotests\\ObjCTest3\\ObjCTest3.gswa\\ObjCTest3.exe"; 
    NSBundleInitialPath = "H:\\Wotests\\ObjCTest3\\ObjCTest3.gswa"; 
    NSBundleLanguagesList = (); 
    NSBundleResolvedPath = "H:\\Wotests\\ObjCTest3\\ObjCTest3.gswa"; 
    NSBundleResourcePath = "H:\\Wotests\\ObjCTest3\\ObjCTest3.gswa\\Resources"; 
    NSExecutable = ObjCTest3; 
    NSJavaRootClient = WebServerResources/Java; 
    NSJavaUserPath = (); 
}
				_reserved5=void * PTR
				_principalClass=Class Class:*nil*
				_tmp1=void * PTR
				_tmp2=void * PTR
				_reserved1=void * PTR
				_reserved0=void * PTR
*/
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationClassD)

//--------------------------------------------------------------------
+(int)_garbageCollectionRepeatCount
{
  LOGClassFnNotImplemented();	//TODOFN
  return 1;
};

//--------------------------------------------------------------------
+(BOOL)_lockDefaultEditingContext
{
  LOGClassFnNotImplemented();	//TODOFN
  return YES;
};

//--------------------------------------------------------------------
+(void)_setLockDefaultEditingContext:(BOOL)_flag
{
  LOGClassFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(id)_allowsConcurrentRequestHandling
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(void)_setAllowsConcurrentRequestHandling:(id)_unknown
{
  LOGClassFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationClassE)

//--------------------------------------------------------------------
+(int)_requestLimit
{
  LOGClassFnNotImplemented();	//TODOFN
  return 1;
};

//--------------------------------------------------------------------
+(int)_requestWindow
{
  LOGClassFnNotImplemented();	//TODOFN
  return 1;
};

//--------------------------------------------------------------------
+(BOOL)_multipleThreads
{
  LOGClassFnNotImplemented();	//TODOFN
  return YES;
};

//--------------------------------------------------------------------
+(BOOL)_multipleInstances
{
  LOGClassFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
+(void)_readLicenseParameters
{
  LOGClassFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWApplication (NDFN)

//--------------------------------------------------------------------
//NDFN
-(id)propListWithResourceNamed:(NSString*)name_
						ofType:(NSString*)type_
				   inFramework:(NSString*)frameworkName_
					 languages:(NSArray*)languages_
{
  id _propList=nil;
  GSWResourceManager* _resourceManager=nil;
  NSString* _pathName=nil;
  LOGObjectFnStart();
  _resourceManager=[self resourceManager];
  _pathName=[_resourceManager pathForResourceNamed:[NSString stringWithFormat:@"%@.%@",name_,type_]
							  inFramework:frameworkName_
							  languages:languages_];
  NSDebugMLLog(@"low",@"_pathName:%@",_pathName);
  if (_pathName)
	{
	  NSString* _propListString=[NSString stringWithContentsOfFile:_pathName];
	  _propList=[_propListString propertyList];
	  if (!_propList)
		{
		  LOGSeriousError(@"Bad propertyList \n%@\n from file %@",
						  _propListString,
						  _pathName);
		};
	};
  LOGObjectFnStop();
  return _propList;
};

//--------------------------------------------------------------------
+(BOOL)createUnknownComponentClasses:(NSArray*)classes_
					  superClassName:(NSString*)superClassName_
{
  BOOL _ok=YES;
  LOGClassFnStart();
  if ([classes_ count]>0)
	{
	  int i=0;
	  NSString* _className=nil;
	  Class _class=nil;
	  int _newClassIndex=0;
	  Class* _newClasses=(Class*)objc_malloc(sizeof(Class)*([classes_ count]+1));
	  memset(_newClasses,0,sizeof(Class)*([classes_ count]+1));
	  for(i=0;i<[classes_ count];i++)
		{
		  _className=[classes_ objectAtIndex:i];
		  NSDebugMLLog(@"low",@"_className:%@",_className);
		  _class=NSClassFromString(_className);
		  NSDebugMLLog(@"low",@"_class:%@",_class);
		  if (!_class)
			{
			  NSString* _superClassName=nil;
			  _superClassName=[localDynCreateClassNames objectForKey:_className];
			  NSDebugMLLog(@"low",@"_superClassName=%p",(void*)_superClassName);
			  if (!_superClassName)
				{
				  _superClassName=superClassName_;
				  if (!_superClassName)
					{
					  ExceptionRaise(@"GSWApplication",
									 @"GSWApplication: no superclass for class named: %@",
									 _className);
					};
				};
			  NSDebugMLLog(@"low",@"Create Unknown Class: %@ (superclass: %@)",
						  _className,
						  superClassName_);
			  if (_superClassName)
				{
				  _class=[NGObjCClass createClassWithName:_className
									  superClassName:_superClassName
									  iVars:nil];
				  NSDebugMLLog(@"low",@"_class:%p",_class);
				  if (_class)
					{
					  _newClasses[_newClassIndex]=_class;
					  _newClassIndex++;
					};
				};
			};
		};
	  if (_newClassIndex>0)
		{
		  NSString* _moduleName=[NSString stringUniqueIdWithLength:4];//TODO
		  NGObjCModule* module=[NGObjCModule moduleWithName:_moduleName];
		  _ok=[module executeWithClassArray:_newClasses];
		  NSDebugMLLog(@"low",@"_ok:%d",(int)_ok);
		  if (!_ok)
			{
			  //TODO
			  LOGError(@"Can't create one of these classes %@",classes_);
			}
		  else
			{
/*			  infoClassNewClass=[NGObjCClass infoForClass:aNewClass];
			  [infoClassNewClass addMethods:[infoClass methods]];
			  [infoClassNewClass addClassMethods:[infoClass classMethods]];
*/
			};
		};
	  objc_free(_newClasses);
	};
  LOGClassFnStop();
  return _ok;
};

//--------------------------------------------------------------------
+(void)addDynCreateClassName:(NSString*)className_
			  superClassName:(NSString*)superClassName_
{
  LOGClassFnStart();
  NSDebugMLLog(@"gswdync",@"ClassName:%@ superClassName:%@\n",className_,superClassName_);
  [localDynCreateClassNames setObject:superClassName_
							forKey:className_];
  LOGClassFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)pathForResourceNamed:(NSString*)name_
					 inFramework:(NSString*)frameworkName_
					   languages:(NSArray*)languages_
{
  return [[self resourceManager]pathForResourceNamed:name_
								inFramework:frameworkName_
								languages:languages_];
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)pathForResourceNamed:(NSString*)name_
						  ofType:(NSString*)type_ 
					 inFramework:(NSString*)frameworkName_
					   languages:(NSArray*)languages_
{
  return [[self resourceManager]pathForResourceNamed:(type_ ? [NSString stringWithFormat:@"%@.%@",name_,type_] : name_)
								inFramework:frameworkName_
								languages:languages_];
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlForResourceNamed:(NSString*)name_
					inFramework:(NSString*)frameworkName_
					  languages:(NSArray*)languages_
						request:(GSWRequest*)request_
{
  return [[self resourceManager]urlForResourceNamed:name_
								inFramework:frameworkName_
								languages:languages_
								request:request_];
};


//--------------------------------------------------------------------
//NDFN
-(NSString*)stringForKey:(NSString*)key_
			inTableNamed:(NSString*)tableName_
		withDefaultValue:(NSString*)defaultValue_
			 inFramework:(NSString*)frameworkName_
			   languages:(NSArray*)languages_
{
  return [[self resourceManager]stringForKey:key_
								inTableNamed:tableName_
								withDefaultValue:defaultValue_
								inFramework:frameworkName_
								languages:languages_];
};


//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)tableName_
					  inFramework:(NSString*)frameworkName_
						languages:(NSArray*)languages_
{
  return [[self resourceManager]stringsTableNamed:tableName_
								inFramework:frameworkName_
								languages:languages_];
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)tableName_
					  inFramework:(NSString*)frameworkName_
						languages:(NSArray*)languages_
{
  return [[self resourceManager]stringsTableArrayNamed:tableName_
								inFramework:frameworkName_
								languages:languages_];
};

@end
/*
//====================================================================
@implementation GSWApplication (GSWDeprecatedAPI)

//--------------------------------------------------------------------
//pageWithName:
//OldFn
-(GSWComponent*)pageWithName:(NSString*)name_
{
  GSWComponent* component=nil;
  Class _class=nil;
  NSDebugMLLog(@"low",@"Page with Name:%@\n",name_);
  //No Name ==> "Main"
  if (!name_ || [name_ length]==0)
	name_=GSWMainPageName;
  NSDebugMLLog(@"gswcomponents",@"Page with Name:%@\n",name_);
  _class=NSClassFromString(name_);
  //If not found, search for library
  if (!_class)
	{
	  NSString* pagePath=[self pathForResourceNamed:name_
							   ofType:nil];
	  Class _principalClass=[self libraryClassWithPath:pagePath];
	  NSDebugMLLog(@"gswcomponents",@"_principalClass=%@",_principalClass);
	  if (_principalClass)
		{
		  _class=NSClassFromString(name_);
		  NSDebugMLLog(@"gswcomponents",@"_class=%@",_class);
		};
	};
  if (!_class)
	{
	  //TODO Load Scripted (PageName.gsws)
	};

  if (!_class)
	{
	  //TODO exception
	  NSDebugMLLog0(@"low",@"No component class\n");
	}
  else
	{
	  Class GSWComponentClass=NSClassFromString(@"GSWComponent");
	  if (!ClassIsKindOfClass(_class,GSWComponentClass))
		{
		  NSDebugMLLog0(@"low",@"component class is not a kind of GSWComponent\n");
		  //TODO exception
		}
	  else
		{
		  //TODOV
		  NSDebugMLLog0(@"low",@"Create Componnent\n");
		  component=[[_class new] autorelease];
		  if (!component)
			{
			  //TODO exception
			};
		};
	};

  return component;
};

//--------------------------------------------------------------------
//restorePageForContextID:
-(GSWComponent*)restorePageForContextID:(NSString*)contextID
{
  return [[self session] restorePageForContextID:contextID];
};

//--------------------------------------------------------------------
//savePage:
-(void)savePage:(GSWComponent*)page_
{
  [[self session] savePage:page_];
};

//--------------------------------------------------------------------
//session
-(GSWSession*)session 
{
  return [[self context] session];
};

//--------------------------------------------------------------------
//context
//Remove !!
-(GSWContext*)context 
{
  GSWContext* _context=nil;
  NSMutableDictionary* _threadDictionary=nil;
  LOGObjectFnStart();
  _threadDictionary=GSCurrentThreadDictionary();
  _context=[_threadDictionary objectForKey:GSWThreadKey_Context];
  LOGObjectFnStop();
  return _context;
};

//--------------------------------------------------------------------
//restoreSession
-(GSWSession*)restoreSession
{
  NSAssert(sessionStore,@"No SessionStore Object");
  return [self restoreSessionWithID:[[self session]sessionID]
				inContext:[self context]];
};

//--------------------------------------------------------------------
//saveSession:
-(void)saveSession:(GSWSession*)session_ 
{
  NSAssert(sessionStore,@"No SessionStore Object");
  [self saveSessionForContext:[self context]];
};

//--------------------------------------------------------------------
//createSession
-(GSWSession*)createSession 
{
  LOGObjectFnNotImplemented();	//TODOFN 3.5
  return nil;
};

//--------------------------------------------------------------------
//urlForResourceNamed:ofType:
-(NSString*)urlForResourceNamed:(NSString*)name_
						 ofType:(NSString*)type_ 
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
//pathForResourceNamed:ofType:

-(NSString*)pathForResourceNamed:(NSString*)name_
						  ofType:(NSString*)type_ 
{
  //TODOV
  NSBundle* bundle=[NSBundle mainBundle];
  NSString* path=[bundle pathForResource:name_
						 ofType:type_];
  return path;
};

//--------------------------------------------------------------------
//stringForKey:inTableNamed:withDefaultValue:

-(NSString*)stringForKey:(NSString*)key_
			inTableNamed:(NSString*)tableName_
		withDefaultValue:(NSString*)defaultValue_ 
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
//handleRequest:
//Olf Fn
-(GSWResponse*)handleRequest:(GSWRequest*)request_ 
{
  return [self dispatchRequest:request_];//??
};

//--------------------------------------------------------------------
//dynamicElementWithName:associations:template:
//OldFn
-(GSWDynamicElement*)dynamicElementWithName:(NSString*)name_
							  associations:(NSDictionary*)associations_
								  template:(GSWElement*)templateElement_
{
  GSWDynamicElement* element=nil;
  //  NSString* elementName=[_XMLElement attributeForKey:@"NAME"];
  Class _class=NSClassFromString(name_);
  LOGObjectFnNotImplemented();	//TODOFN
  NSDebugMLLog0(@"low",@"Begin GSWApplication:dynamicElementWithName\n");
  if (!_class)
	{
	  ExceptionRaise(@"GSWApplication",
					 @"GSWApplication: No class named '%@' for creating dynamic element",
					  name_);
	}
  else
	{
	  Class GSWElementClass=NSClassFromString(@"GSWElement");
	  if (!ClassIsKindOfClass(_class,GSWElementClass))
		{
		  ExceptionRaise(@"GSWApplication",
						 @"GSWApplication: element '%@' is not kind of GSWElement",
						 name_);
		}
	  else
		{
		  NSDebugMLLog(@"low",@"Creating DynamicElement of Class:%@\n",_class);
		  element=[[[_class alloc] initWithName:name_
								  associations:associations_
								  template:templateElement_] autorelease];
		  NSDebugMLLog(@"low",@"Creating DynamicElement:%@\n",element);
		};
	};
  return element;
};

@end
*/
