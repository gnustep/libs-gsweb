/** GSWApplication.m - <title>GSWeb: Class GSWApplication</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:  Manuel Guesdon <mguesdon@orange-concept.com>
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

#include "config.h"

#include "GSWeb.h"
#include "GSWPrivate.h"
#include "GSWLifebeatThread.h"
#include "GSWRecording.h"
#include "GSWApplication+Defaults.h"

#include "stacktrace.h"
#include "attach.h"

#include <GNUstepBase/NSThread+GNUstepBase.h>
#include <GNUstepBase/NSString+GNUstepBase.h>
#include <GNUstepBase/NSObject+GNUstepBase.h>
#include <GNUstepBase/GSObjCRuntime.h>

/*
Monitor Refresh (or View Details):
application lock
GSWStatisticsStore statistics
application unlock


*/

/* 
   The following class does not exist.  The declaration is merely used
   to aid the compiler to find the correct signatures for messages
   sent to the class and to avoid polluting the compiler output with
   superfluous warnings.
*/
@interface GSWAppClassDummy : NSObject
- (NSString *)adaptor;
- (NSString *)host;
- (NSNumber *)port;
+ (id)defaultGroup;
@end

#ifdef GNUSTEP
@interface NSDistantObject (GNUstepPrivate)
+ (void) setDebug: (int)val;
@end
#endif

@interface GSWApplication (GSWApplicationPrivate)
- (void)_setPool:(NSAutoreleasePool *)pool;
@end

#define GSWFPutSL(string, file) \
  do { NSData* cString=[string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]; NSUInteger length=[cString length]; fwrite([cString bytes],1,length,file); fputs("\n",file); fflush(file); } \
  while (0)

/* GSWApplication+Defaults.m */
/* These functions should actually be static inline to limit thier scope
   but that would mean that they have to be part of this transalation unit.  */
void GSWeb_ApplicationDebugSetChange(void);
void GSWeb_AdjustVolatileNSArgumentDomain(void);
void GSWeb_InitializeGlobalAppDefaultOptions(void);
void GSWeb_InitializeDebugOptions(void);
void GSWeb_DestroyGlobalAppDefaultOptions(void);

//====================================================================
GSWApplication* GSWApp=nil;
NSString* globalApplicationClassName=nil;
NSMutableDictionary* localDynCreateClassNames=nil;
int GSWebNamingConv=GSWNAMES_INDEX;
NSString* GSWPageNotFoundException=@"GSWPageNotFoundException";

// Main function
int GSWApplicationMainReal(NSString* applicationClassName,
                           int argc,
                           const char *argv[])
{
  Class applicationClass=Nil;
  int result=0;
  //call NSBundle Start:_usesFastJavaBundleSetup
  //call :NSBundle Start:_setUsesFastJavaBundleSetup:YES
  //call NSBundle mainBundle
  NSAutoreleasePool *appAutoreleasePool=nil;
  
  appAutoreleasePool = [NSAutoreleasePool new];
  
  GSWeb_AdjustVolatileNSArgumentDomain();
  
  if (!localDynCreateClassNames)
    localDynCreateClassNames=[NSMutableDictionary new];
  
  GSWeb_InitializeGlobalAppDefaultOptions();
  GSWeb_InitializeDebugOptions();
  //TODO
  if (applicationClassName && [applicationClassName length]>0)
    ASSIGNCOPY(globalApplicationClassName,applicationClassName);
  GSWeb_ApplicationDebugSetChange();
  applicationClass=[GSWApplication _applicationClass];
  
  if (!applicationClass) {
    NSCAssert(NO,@"!applicationClass");
    //TODO error
    result=-1;
  }
  
  if (result>=0) {
    NSArray* frameworks=[applicationClass loadFrameworks];
    
    if (frameworks) {
      NSBundle* bundle=nil;
      unsigned i=0,j=0;
      BOOL loadResult=NO;
      NSFileManager *fm = [NSFileManager defaultManager];
      NSArray *searchDomains = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                                   NSAllDomainsMask,
                                                                   NO);
      unsigned frameworksCount = [frameworks count];
      unsigned searchDomainCount = [searchDomains count];
      
      for (i=0; i<frameworksCount; i++) {
        NSString* bundlePath=[frameworks objectAtIndex:i];
	      NSString* searchPath=nil;
        
	      for (j=0; j<searchDomainCount; j++) {
          searchPath = [searchDomains objectAtIndex:j];
          searchPath = [searchPath stringByAppendingPathComponent:@"Frameworks"];
          searchPath = [searchPath stringByAppendingPathComponent: bundlePath];
          /* FIXME: This should be using stringByAppendingPathExtension:
           but GSFrameworkPSuffix already has the '.'.*/
          searchPath = [searchPath stringByAppendingString: GSFrameworkPSuffix];
          
          if ([fm fileExistsAtPath: searchPath]) {
            bundle=[NSBundle bundleWithPath:searchPath];
            loadResult=[bundle load];
            
            if (!loadResult) {
              ExceptionRaise(@"GSWApplication",@"Can't load framework %@",
                             searchPath);
            }
            /* Break out of the inner for loop.  */
            j = searchDomainCount;
          } else {
            bundle = nil;
          }
        }
	      if (!bundle) {
          ExceptionRaise(@"GSWApplication",@"Can't load framework %@",
                         bundlePath);
        }
      }
    }	  
  }
  
  if (result>=0) {
    NS_DURING
    {
      id app=[applicationClass new];
      if (app)
        result=1;
      else
        result=-1;
    }	  
    // Make sure we pass all exceptions back to the requestor.
    NS_HANDLER
    {
      NSLog(@"Can't create Application (Class:%@)- "
            @"%@ %@ Name:%@ Reason:%@",
            applicationClass,
            localException,
            [localException description],
            [localException name],
            [localException reason]);
      result=-1;
    }
    NS_ENDHANDLER;
  }
  if (result>=0 && GSWApp) {
    [GSWApp _setPool:[NSAutoreleasePool new]];
    
    [GSWApp run];
    
    DESTROY(GSWApp);
  }
  
  DESTROY(appAutoreleasePool);
  return result;
}

//====================================================================
// Main function (for WO compatibility)
int WOApplicationMain(NSString* applicationClassName,
                      int argc,
                      const char *argv[])
{
  GSWebNamingConv=WONAMES_INDEX;
  return GSWApplicationMainReal(applicationClassName,argc,argv);
};

//====================================================================
// Main function (GSWeb)
int GSWApplicationMain(NSString* applicationClassName,
                      int argc,
                      const char *argv[])
{
  GSWebNamingConv=GSWNAMES_INDEX;
  return GSWApplicationMainReal(applicationClassName,argc,argv);
};

//====================================================================
@implementation GSWApplication

//--------------------------------------------------------------------
+(void)initialize
{
  BOOL initialized=NO;
  if (!initialized)
    {
      initialized=YES;
      GSWInitializeAllMisc();
    };
};

//--------------------------------------------------------------------
- (void)_setPool:(NSAutoreleasePool *)pool
{
  _globalAutoreleasePool = pool;
}

//--------------------------------------------------------------------
+(id)init
{
  id ret=[[self superclass]init];
  [GSWAssociation addLogHandlerClasse:[self class]];
  return ret;
};

//--------------------------------------------------------------------
// FIXME: do we need to dealloc a CLASS??? looks strange to me -- dw
//+(void)dealloc
//{
//  // FIXME: do we need to dealloc a CLASS??? looks strange to me -- dw
//  [GSWAssociation removeLogHandlerClasse:[self class]];
//  DESTROY(localDynCreateClassNames);
//  GSWeb_DestroyGlobalAppDefaultOptions();
//  [[self superclass]dealloc];
//};

//-----------------------------------------------------------------------------------
//init

-(id)init 
{
  NSUserDefaults* standardUserDefaults=nil;
  
  if ((self=[super init]))
    {
      _selfLock=[NSRecursiveLock new];
      _globalLock=[NSRecursiveLock new];
      
      ASSIGN(_startDate,[NSDate date]);
      ASSIGN(_lastAccessDate,[NSDate date]);
      [self setTimeOut:0];//No time out

      //Do it before run so application can addTimer,... in -run
      ASSIGN(_currentRunLoop,[NSRunLoop currentRunLoop]); 

      _pageCacheSize=30;
      _permanentPageCacheSize=30;
      _pageRecreationEnabled=YES;
      _pageRefreshOnBacktrackEnabled=YES;
      _refusingNewSessions = NO;
      _minimumActiveSessionsCount = 0;	// 0 is default
      _dynamicLoadingEnabled=YES;
      _printsHTMLParserDiagnostics=YES;
      _allowsConcurrentRequestHandling = NO;

      [[self class] _setApplication:self];
      [self _touchPrincipalClasses];

      standardUserDefaults=[NSUserDefaults standardUserDefaults];

      [self _initAdaptorsWithUserDefaults:standardUserDefaults];

      [self setSessionStore:[self createSessionStore]];
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
      _activeSessionsCountLock=[NSLock new];

      _componentDefinitionCache=[GSWMultiKeyDictionary new];

      [self setResourceManager:[self createResourceManager]];
      [self setStatisticsStore:[self createStatisticsStore]];

      if ([[self class]isMonitorEnabled])
	{
	  [self _setupForMonitoring];
	};
      // ?? 
      //      [[GSWResourceManager _applicationGSWBundle] initializeObject:self
      //                                                  fromArchiveNamed:@"Application"];
      [self setPrintsHTMLParserDiagnostics:NO];

      if ([[self class] recordingPath])
        {
          Class recordingClass=[[self class]recordingClass];
          _recorder=[recordingClass new];
        };

      //call recordingPath
      [self registerRequestHandlers];
      
      [[NSNotificationCenter defaultCenter]addObserver:self
                                           selector:@selector(_sessionDidTimeOutNotification:)
                                           name:GSWNotification__SessionDidTimeOutNotification[GSWebNamingConv]
                                           object:nil];
      
      // Create lifebeat thread only if we're not the observer :-)

      if (![self isTaskDaemon] && [[self class] isLifebeatEnabled])
        {
          NSTimeInterval lifebeatInterval=[[self class]lifebeatInterval];
          if (lifebeatInterval<1)
            lifebeatInterval=30; //30s

          ASSIGN(_lifebeatThread,
		 [GSWLifebeatThread lifebeatThreadWithApplication:self
				    name:[self name]
				    host:[(GSWAppClassDummy*)[self class] host]
				    port:[[self class] intPort]
				    lifebeatHost:[[self class] lifebeatDestinationHost]
				    lifebeatPort:[[self class] lifebeatDestinationPort]
				    interval:lifebeatInterval]);
//#warning go only multi-thread if we want this!

          [NSThread detachNewThreadSelector:@selector(run:)
                    toTarget:_lifebeatThread
                    withObject:nil];

        };
    };
  
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_adaptors);
  DESTROY(_sessionStore);
  DESTROY(_componentDefinitionCache);
  DESTROY(_lastAccessDate);
  DESTROY(_timer);
//  DESTROY(_context);//deprecated
  DESTROY(_statisticsStore);
  DESTROY(_resourceManager);
  DESTROY(_remoteMonitor);
  DESTROY(_remoteMonitorConnection);
  DESTROY(_instanceNumber);
  DESTROY(_requestHandlers);
  DESTROY(_defaultRequestHandler);
  DESTROY(_selfLock);
  DESTROY(_globalLock);
  DESTROY(_globalAutoreleasePool);
  DESTROY(_currentRunLoop);
  DESTROY(_runLoopDate);
  DESTROY(_initialTimer);
  DESTROY(_activeSessionsCountLock);
  DESTROY(_lifebeatThread);
  
  if (GSWApp == self)
  {
    GSWApp = nil;
  }

  [super dealloc];
};


-(void) _setHostAddress:(NSString *) hostAdr
{
  [_hostAddress release];
  _hostAddress = [hostAdr retain];
}

- (NSString*) hostAddress
{
  if(_hostAddress == nil)
  {
    _hostAddress = [[[NSHost currentHost] address] retain];
  }
  return _hostAddress;
}


//--------------------------------------------------------------------
-(NSString*)description
{
  //OK
  NSString* dscr=nil;
  [self lock];
  dscr=[NSString stringWithFormat:
                   @"<%s %p - name=%@ adaptors=%@ sessionStore=%@ pageCacheSize=%d permanentPageCacheSize=%d pageRecreationEnabled=%s pageRefreshOnBacktrackEnabled=%s componentDefinitionCache=%@ caching=%s terminating=%s timeOut=%f dynamicLoadingEnabled=%s>",
                 object_getClassName(self),
                 (void*)self,
                 [self name],
                 [[self adaptors] description],
                 [[self sessionStore] description],
                 [self pageCacheSize],
                 [self permanentPageCacheSize],
                 [self _isPageRecreationEnabled] ? "YES" : "NO",
                 [self isPageRefreshOnBacktrackEnabled] ? "YES" : "NO",
                 [_componentDefinitionCache description],
                 [self isCachingEnabled] ? "YES" : "NO",
                 [self isTerminating] ? "YES" : "NO",
                 [self timeOut],
                 [self _isDynamicLoadingEnabled] ? "YES" : "NO"];
  [self unlock];
  return dscr;
};

-(BOOL) shouldRestoreSessionOnCleanEntry:(GSWRequest*) aRequest
{
  return NO;
}


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
  return _isMultiThreaded;
}

//--------------------------------------------------------------------
//	isConcurrentRequestHandlingEnabled
-(BOOL)isConcurrentRequestHandlingEnabled
{
  return (_isMultiThreaded && _allowsConcurrentRequestHandling);
}

//--------------------------------------------------------------------
- (NSRecursiveLock *) requestHandlingLock
{
  if (_isMultiThreaded && !_allowsConcurrentRequestHandling)
    return _globalLock;
  else
    return nil;
}

//--------------------------------------------------------------------
// calls the class because on MacOSX KVC does not support "application.class.isDebuggingEnabled"
- (BOOL)isDebuggingEnabled
{
  return [[self class] isDebuggingEnabled];
};

//--------------------------------------------------------------------
//	lockRequestHandling
-(BOOL)isRequestHandlingLocked
{
  BOOL lockable = LoggedTryLock(_globalLock);

  if (lockable == YES)
    {
      LoggedUnlock(_globalLock);
    }

  return (lockable ? NO : YES);
};

-(void) lock
{
  [_globalLock lock];
}

-(void) unlock
{
  [_globalLock unlock];
}

//--------------------------------------------------------------------
-(BOOL)isTaskDaemon
{
  return [[self name]isEqual:@"gswtaskd"];
};

//--------------------------------------------------------------------
//name

-(NSString*)name 
{
  NSString* name=nil;
  NSProcessInfo* processInfo=nil;
  NSString* processName=nil;
  
  //TODO
/*  if (applicationName)
	return applicationName;
  else
	{*/
  processInfo=[NSProcessInfo processInfo];
  processName=[processInfo processName];

  processName=[processName lastPathComponent];
  if ([processName hasSuffix:GSWApplicationPSuffix[GSWebNamingConv]])
    name=[processName stringByDeletingSuffix:GSWApplicationPSuffix[GSWebNamingConv]];
  else
    name=processName;
  //	};
  return name;
  
};

//--------------------------------------------------------------------
//number
-(NSString*)number 
{
  return @"-1";
};

//--------------------------------------------------------------------
//path
-(NSString*)path 
{
  NSString* path=nil;
  
  path=[[_resourceManager _appProjectBundle] bundlePath];
  
  return path;
};

//--------------------------------------------------------------------
//baseURL
-(NSString*)baseURL 
{
  return [[self class]applicationBaseURL];
};

//--------------------------------------------------------------------
-(void)registerRequestHandlers
{
    //OK
    NSString* componentRequestHandlerKey=nil;
    NSString* resourceRequestHandlerKey=nil;
    NSString* directActionRequestHandlerKey=nil;
    NSString* pingDirectActionRequestHandlerKey=nil;
    NSString* streamDirectActionRequestHandlerKey=nil;
    NSString* ajaxRequestHandlerKey=nil;

    GSWRequestHandler* componentRequestHandler=nil;
    GSWResourceRequestHandler* resourceRequestHandler=nil;
    GSWDirectActionRequestHandler* directActionRequestHandler=nil;
    GSWDirectActionRequestHandler* pingDirectActionRequestHandler=nil;
    GSWDirectActionRequestHandler* streamDirectActionRequestHandler=nil;
    GSWAjaxRequestHandler*         ajaxRequestHander=nil;
    GSWRequestHandler*             defaultRequestHandler=nil;
    
    Class defaultRequestHandlerClass=nil;
    
    
    
    // Component Handler
    componentRequestHandler=[[self class] _componentRequestHandler];
    componentRequestHandlerKey=[[self class] componentRequestHandlerKey];
    
    
    // Resource Handler
    resourceRequestHandler=(GSWResourceRequestHandler*)
    [GSWResourceRequestHandler handler];
    
    resourceRequestHandlerKey=[[self class] resourceRequestHandlerKey];
    
    
    // DirectAction Handler
    directActionRequestHandler=(GSWDirectActionRequestHandler*)
    [GSWDirectActionRequestHandler handler];
    
    directActionRequestHandlerKey=[[self class] directActionRequestHandlerKey];
    
    
    // "Ping" Handler
    pingDirectActionRequestHandler=(GSWDirectActionRequestHandler*)
    [GSWDirectActionRequestHandler handlerWithDefaultActionClassName:@"GSWAdminAction"
                                                   defaultActionName:@"ping"
                                               shouldAddToStatistics:NO];
    pingDirectActionRequestHandlerKey=[[self class] pingActionRequestHandlerKey];
    
    
    // Stream Handler
    streamDirectActionRequestHandler=(GSWDirectActionRequestHandler*)
    [GSWDirectActionRequestHandler handler];
    
    streamDirectActionRequestHandlerKey=[[self class] streamActionRequestHandlerKey];
    [streamDirectActionRequestHandler setAllowsContentInputStream:YES];
    
    // Ajax
    
    ajaxRequestHandlerKey = [[self class] ajaxRequestHandlerKey];
    ajaxRequestHander = [GSWAjaxRequestHandler handler];
        
    [self registerRequestHandler:componentRequestHandler
                          forKey:componentRequestHandlerKey];
    [self registerRequestHandler:resourceRequestHandler
                          forKey:resourceRequestHandlerKey];
    [self registerRequestHandler:directActionRequestHandler
                          forKey:directActionRequestHandlerKey];
    [self registerRequestHandler:directActionRequestHandler
                          forKey:GSWDirectActionRequestHandlerKey[GSWebNamingConvInversed]];
    [self registerRequestHandler:pingDirectActionRequestHandler
                          forKey:pingDirectActionRequestHandlerKey];
    [self registerRequestHandler:streamDirectActionRequestHandler
                          forKey:streamDirectActionRequestHandlerKey];
    
    [self registerRequestHandler:ajaxRequestHander
                          forKey:ajaxRequestHandlerKey];

    // Default Request Handler
    defaultRequestHandlerClass=[self defaultRequestHandlerClass];
    if (defaultRequestHandlerClass)
    defaultRequestHandler=(GSWRequestHandler*)[defaultRequestHandlerClass handler];
    else
    defaultRequestHandler=componentRequestHandler;
    [self setDefaultRequestHandler:defaultRequestHandler];
    
    
    // If direct connect enabled, add static resources handler
    if ([[self class] isDirectConnectEnabled])
    {
        GSWStaticResourceRequestHandler* staticResourceRequestHandler = (GSWStaticResourceRequestHandler*)
        [GSWStaticResourceRequestHandler handler];
        NSString* staticResourceRequestHandlerKey=[[self class] staticResourceRequestHandlerKey];
        [self registerRequestHandler:staticResourceRequestHandler
                              forKey:staticResourceRequestHandlerKey];
    };
    
};


//--------------------------------------------------------------------
-(NSString*)defaultRequestHandlerClassName
{
  return @"GSWComponentRequestHandle";
};

//--------------------------------------------------------------------
-(Class)defaultRequestHandlerClass
{
  Class defaultRequestHandlerClass=Nil;
  NSString* className=[self defaultRequestHandlerClassName];
  if ([className length]>0)
    {
      defaultRequestHandlerClass=NSClassFromString(className);
    };
  return defaultRequestHandlerClass;
};

-(void)becomesMultiThreaded
{
  [self notImplemented: _cmd];	//TODOFN
}

-(NSString*)_webserverConnectURL
{
  NSString* webserverConnectURL=nil;
  NSString* cgiAdaptorURL=[[self class]cgiAdaptorURL]; //return http://www.example.com/cgi-bin/GSWeb.exe
  if (!cgiAdaptorURL)
    {
      //NSDebugMLog(@"No CGI adaptor");
    }
  else
    {
      int port=1;
      NSArray* adaptors=[self adaptors];
      if ([adaptors count]>0)
        {
          GSWAdaptor* firstAdaptor=[adaptors objectAtIndex:0];
          port=[firstAdaptor port];
        };
      webserverConnectURL=[NSString stringWithFormat:@"%@/%@.%@/-%d",
                                    cgiAdaptorURL,
                                    [self name],
                                    [self _applicationExtension],
                                    port];
    } 
  return webserverConnectURL; //return http://www.example.com:1436/cgi-bin/GSWeb.exe/ObjCTest3.gswa/-2
};

//--------------------------------------------------------------------
-(NSString*)_directConnectURL
{
  Class GSWAppClass = [self class];
  NSString* directConnectURL=nil;
  
  directConnectURL = [NSString stringWithFormat:@"http://%@:%@%@/%@.%@/0/", [GSWAppClass host],
                                                                  [GSWAppClass port],
                                                                  [GSWAppClass applicationBaseURL],
                                                                  [self name],
                                                                  [self _applicationExtension]];
                                                                  

  return directConnectURL; //return http://www.example.com:1436/cgi-bin/GSWeb.exe/ObjCTest3
};

//--------------------------------------------------------------------
-(NSString*)_applicationExtension
{
  return GSWApplicationSuffix[GSWebNamingConv];
};

//--------------------------------------------------------------------
-(void)_resetCacheForGeneration
{
};

//--------------------------------------------------------------------
-(void)_resetCache
{
  //OK
//  NSEnumerator           * anEnum     = nil;
//  GSWComponentDefinition * definition = nil;

  [self lock];
  NS_DURING
    {
      // we should probably clear the _componentDefinitionCache? -- dw
      
//      anEnum=[_componentDefinitionCache objectEnumerator];
//      while ((definition = [anEnum nextObject]))
//        {
//          if (((NSString*)definition != GSNotFoundMarker) && (![definition isCachingEnabled]))
//            [definition _clearCache];
//        }
      if (![self isCachingEnabled])
        {
          [_resourceManager flushDataCache];
        }
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In Application _resetCache");
      [self unlock];
      [localException raise];
      //TODO
    };
  NS_ENDHANDLER;
  [self unlock];

}

-(GSWComponentDefinition*) _componentDefinitionWithName:(NSString*)aName
                                              languages:(NSArray*)languages
{
  //OK
  GSWComponentDefinition* componentDefinition=nil;
  
  [self lock];
  NS_DURING
    {
      componentDefinition=[self lockedComponentDefinitionWithName:aName
                                 languages:languages];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In lockedComponentDefinitionWithName");
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  
  return componentDefinition;
};

-(GSWComponentDefinition*)lockedComponentDefinitionWithName:(NSString*)aName
                                                  languages:(NSArray*)languages
{
  //OK
  BOOL isCachedComponent=NO;
  GSWComponentDefinition* componentDefinition=nil;
  NSString* language=nil;
  int iLanguage=0;
  int languagesCount=0;

  languagesCount=[languages count];

  for(iLanguage=0;iLanguage<languagesCount && !componentDefinition;iLanguage++)
  {
    language=[languages objectAtIndex:iLanguage];
    if (language)
    {
      if ([self isCachingEnabled])
      {
        componentDefinition=[_componentDefinitionCache objectForKeys:aName,language,nil];
        if (componentDefinition==(GSWComponentDefinition*)GSNotFoundMarker)
          componentDefinition=nil;
        else if (componentDefinition)
          isCachedComponent=YES;
      }
      if (!componentDefinition)
      {
        componentDefinition=[self lockedLoadComponentDefinitionWithName:aName
                                  language:language];
        if ([self isCachingEnabled])
        {
          if (componentDefinition)
            [_componentDefinitionCache setObject:componentDefinition
                                        forKeys:aName,language,nil];
          else
            [_componentDefinitionCache setObject:GSNotFoundMarker
                                        forKeys:aName,language,nil];
        };
      };
    };
  };
  if (!componentDefinition)
    {
      language=nil;

      if ([self isCachingEnabled])
        {
          componentDefinition=[_componentDefinitionCache objectForKeys:aName,nil];
          if (componentDefinition==(GSWComponentDefinition*)GSNotFoundMarker)
            componentDefinition=nil;
          else if (componentDefinition)
            isCachedComponent=YES;
        };
      if (!componentDefinition)
        {
          componentDefinition=[self lockedLoadComponentDefinitionWithName:aName
                                    language:language];
          if ([self isCachingEnabled])
            {
              if (componentDefinition)
                [_componentDefinitionCache setObject:componentDefinition
                                           forKeys:aName,nil];
              else
                [_componentDefinitionCache setObject:GSNotFoundMarker
                                           forKeys:aName,nil];
            };
        };
    };

  if (!componentDefinition)
    {
      static Class gswCClass = nil;
      Class cClass = NSClassFromString([aName lastPathComponent]);
      
    if (gswCClass == nil)
  	{
  	  gswCClass = [GSWComponent class];
  	}

    if (cClass != 0 && [cClass isSubclassOfClass: gswCClass])
  	{
  	  NSString *baseURL
  	    = @"/ERROR/RelativeUrlsNotSupportedWhenCompenentHasNoWrapper";
  	  NSString *bundlePath
  	    = [[NSBundle bundleForClass: cClass] bundlePath];
  	  NSString *frameworkName
  	    = [[bundlePath lastPathComponent] stringByDeletingPathExtension];
  // xxxx

      NS_DURING
      {
        componentDefinition = [GSWComponentDefinition alloc];

        [componentDefinition initWithName:aName
                                     path:bundlePath
                                  baseURL: baseURL
                            frameworkName:frameworkName];
        [componentDefinition autorelease];
      }
      NS_HANDLER
      {
        [componentDefinition release];
        componentDefinition = nil;
        [localException raise];
      }
      NS_ENDHANDLER

      if ([self isCachingEnabled] && (componentDefinition))
  	  {
  	    [_componentDefinitionCache setObject: componentDefinition
  				                        	 forKeys: aName, nil];
  	  }
  	}
  }

  if (!componentDefinition)
  {
    NSLog(@"EXCEPTION: allFrameworks pathes=%@",[[NSBundle allFrameworks] valueForKey:@"resourcePath"]);
    ExceptionRaise(GSWPageNotFoundException,
                    @"Unable to create component definition for %@ for languages: %@ (no componentDefinition).",
                    aName,
                    languages);
  }

  return componentDefinition;
};

//--------------------------------------------------------------------
-(GSWComponentDefinition*)lockedLoadComponentDefinitionWithName:(NSString*)aName
                                                       language:(NSString*)language
{
  GSWComponentDefinition* componentDefinition=nil;
  GSWResourceManager* resourceManager=nil;
  NSString* frameworkName=nil;
  NSString* resourceName=nil;
  NSString* htmlResourceName=nil;
  NSString* path=nil;
  NSString* url=nil;
  int iName=0;

  for(iName=0;!path && iName<2;iName++)
  {
    resourceName=[aName stringByAppendingString:GSWPagePSuffix[GSWebNamingConvForRound(iName)]];
    htmlResourceName=[aName stringByAppendingString:GSWComponentTemplatePSuffix];
    
    resourceManager=[self resourceManager];
    path=[resourceManager pathForResourceNamed:resourceName
                        inFramework:nil
                        language:language];
    
    if (!path)
    {
      NSArray* frameworks = [self lockedComponentBearingFrameworks];
      NSBundle* framework = nil;
      int frameworkN      = 0;
      int frameworksCount = [frameworks count];

      for(frameworkN=0;frameworkN<frameworksCount && !path;frameworkN++)
      {
        framework = [frameworks objectAtIndex:frameworkN];
        path = [resourceManager pathForResourceNamed:resourceName
                                         inFramework:[framework bundleName]
                                            language:language];
        if (!path)
        {
          path=[resourceManager pathForResourceNamed:htmlResourceName
                                         inFramework:[framework bundleName]
                                            language:language];
        }
        if (path)
        {
          frameworkName=[framework bundlePath];
          frameworkName=[frameworkName lastPathComponent];
          frameworkName=[frameworkName stringByDeletingPathExtension];
        }
      }
    }
  }
  if (path)
  {
    url=[resourceManager urlForResourceNamed:resourceName
                          inFramework:frameworkName
                          languages:(language ? [NSArray arrayWithObject:language] : nil)
                          request:nil];

    NS_DURING
    {
      componentDefinition = [GSWComponentDefinition alloc];

      [componentDefinition initWithName:aName
                                    path:path
                                baseURL:url
                          frameworkName:frameworkName];
      [componentDefinition autorelease];
    }
    NS_HANDLER
    {
      [componentDefinition release];
      componentDefinition = nil;
      [localException raise];
    }
    NS_ENDHANDLER
  }
  
  return componentDefinition;
}

//--------------------------------------------------------------------
-(NSArray*)lockedComponentBearingFrameworks
{
  //OK
  NSArray* array=nil;
  NSMutableArray* allFrameworks=nil;
  
  allFrameworks=[[NSBundle allFrameworks] mutableCopy];
  [allFrameworks addObjectsFromArray:[NSBundle allBundles]];
  //NSDebugMLLog(@"gswcomponents",@"allFrameworks=%@",allFrameworks);
  //NSDebugFLLog(@"gswcomponents",@"allFrameworks pathes=%@",[allFrameworks valueForKey:@"resourcePath"]);
  array=[self lockedInitComponentBearingFrameworksFromBundleArray:allFrameworks];

  [allFrameworks release];

  
  return array;
};

//--------------------------------------------------------------------
-(NSArray*)lockedInitComponentBearingFrameworksFromBundleArray:(NSArray*)bundles
{
  NSMutableArray* array=nil;
  int i=0;
  int bundlesCount=0;
  NSBundle* bundle=nil;
  // NSDictionary* bundleInfo=nil;
  // This makes only trouble and saves not so much time dave@turbocat.de
  // id hasGSWComponents=nil;

  

  array=[NSMutableArray array];
  bundlesCount=[bundles count];

  for(i=0;i<bundlesCount;i++)
    {
      bundle=[bundles objectAtIndex:i];
      //NSDebugMLLog(@"gswcomponents",@"bundle=%@",bundle);
      //NSDebugMLLog(@"gswcomponents",@"bundle resourcePath=%@",[bundle resourcePath]);
      ///bundleInfo=[bundle infoDictionary];
      //NSDebugMLLog(@"gswcomponents",@"bundleInfo=%@",bundleInfo);
      ///hasGSWComponents=[bundleInfo objectForKey:@"HasGSWComponents"];
      //NSDebugMLLog(@"gswcomponents",@"hasGSWComponents=%@",hasGSWComponents);
      //NSDebugMLLog(@"gswcomponents",@"hasGSWComponents class=%@",[hasGSWComponents class]);
      //if (boolValueFor(hasGSWComponents))
      //  {
          [array addObject:bundle];
      //  };
    };
  //  NSDebugMLLog(@"gswcomponents",@"_array=%@",_array);
  
  return array;
}


//--------------------------------------------------------------------
-(Class)contextClass
{
  NSString* contextClassName=[self contextClassName];
  Class contextClass=NSClassFromString(contextClassName);
  NSAssert1(contextClass,@"No contextClass named '%@'",contextClassName);
  return contextClass;
};

//--------------------------------------------------------------------
-(GSWContext*)createContextForRequest:(GSWRequest*)aRequest
{
  GSWContext* context=nil;
  Class contextClass=[self contextClass];
  NSAssert(contextClass,@"No contextClass");
  if (contextClass)
    {
      context=[contextClass contextWithRequest:aRequest];
    }
  if (!context)
    {
      //TODO: throw cleaner exception
      NSAssert(NO,@"Can't create context");
    };
  return context;
}

//--------------------------------------------------------------------
-(Class)responseClass
{
  NSString* responseClassName=[self responseClassName];
  Class responseClass=NSClassFromString(responseClassName);
  NSAssert1(responseClass,@"No responseClass named '%@'",responseClassName);
  return responseClass;
};

//--------------------------------------------------------------------
-(GSWResponse*)createResponseInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  Class responseClass=[self responseClass];
  NSAssert(responseClass,@"No responseClass named");
  if (responseClass)
    {
      response=[[responseClass new]autorelease];
    }
  if (!response)
    {
      //TODO: throw cleaner exception
      NSAssert(NO,@"Can't create response");
    };
  return response;
};

//--------------------------------------------------------------------
// It's not exist in WO but enable to have custom request class
//   like we can customer context and session classes
-(Class)requestClass
{
  NSString* requestClassName=[self requestClassName];
  Class requestClass=NSClassFromString(requestClassName);
  NSAssert1(requestClass,@"No requestClass named '%@'",requestClassName);
  return requestClass;
};

//--------------------------------------------------------------------
-(GSWResourceManager*)createResourceManager
{
  NSString* resourceManagerClassName=[[self class] resourceManagerClassName];
  Class resourceManagerClass=Nil;
  if (!resourceManagerClassName) {
    resourceManagerClassName=GSWClassName_ResourceManager[GSWebNamingConv];
  }
  resourceManagerClass=NSClassFromString(resourceManagerClassName);
  NSAssert1(resourceManagerClass,@"No resourceManagerClass named %@",
            resourceManagerClassName);
  return [[resourceManagerClass new]autorelease];
};

//--------------------------------------------------------------------
-(GSWStatisticsStore*)createStatisticsStore
{
  NSString* statisticsStoreClassName=[[self class] statisticsStoreClassName];
  Class statisticsStoreClass=Nil;
  if (!statisticsStoreClassName) {
    statisticsStoreClassName=GSWClassName_StatisticsStore[GSWebNamingConv];
  }
  statisticsStoreClass=NSClassFromString(statisticsStoreClassName);
  NSAssert1(statisticsStoreClass,@"No statisticsStoreClass named %@",
            statisticsStoreClassName);
  return [[statisticsStoreClass new]autorelease];
};

//--------------------------------------------------------------------
-(GSWSessionStore*)createSessionStore
{
  NSString* sessionStoreClassName=[[self class] sessionStoreClassName];
  Class sessionStoreClass=Nil;
  if (!sessionStoreClassName) {
    sessionStoreClassName=GSWClassName_ServerSessionStore[GSWebNamingConv];
  }
  sessionStoreClass=NSClassFromString(sessionStoreClassName);
  NSAssert1(sessionStoreClass,@"No sessionStoreClass named %@",
            sessionStoreClassName);
  return [[sessionStoreClass new]autorelease];
};

//--------------------------------------------------------------------
-(void)_discountTerminatedSession
{
  int activeSessionsCount=0;
  
  [self lock];
  activeSessionsCount=--_activeSessionsCount;
  [self unlock];
  if ([self isRefusingNewSessions] && activeSessionsCount<=_minimumActiveSessionsCount)
    {
      NSLog(@"Application is refusing new session and active sessions count <= minimum session count. Will terminate");
      [self terminate];
    };
};

//--------------------------------------------------------------------
-(void)_finishInitializingSession:(GSWSession*)aSession
{  
  //Does nothing on WO 5 
}

//--------------------------------------------------------------------
-(GSWSession*)_initializeSessionInContext:(GSWContext*)aContext
{
  GSWSession* session = nil;
  
  if ([self isRefusingNewSessions])
  {
    [aContext _setIsRefusingThisRequest:YES];
  }
  
  // SYNCHRONIZED makes no sense here, we are just changing a number -- dw
  [self lock];
  _activeSessionsCount++;
  [self unlock];
  
  session = [self createSessionForRequest:[aContext request]];
  
  if (session == nil)
    {
      [self lock];
      _activeSessionsCount--;
      [self unlock];
    
      return nil;
    }
  
  [aContext _setSession:session];
  [session awakeInContext:aContext];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SessionDidCreateNotification"
					object:session];
  
  return session;
}

//--------------------------------------------------------------------
-(int)_activeSessionsCount
{
  return _activeSessionsCount;
}

//--------------------------------------------------------------------
-(void)_setContext:(GSWContext*)aContext
{
  NSMutableDictionary * thDict = [[NSThread currentThread] threadDictionary];
  
  if (aContext) {
    [thDict setObject:aContext
               forKey:GSWThreadKey_Context];
  } else {
    [thDict removeObjectForKey:GSWThreadKey_Context];  
  }
  
}

//--------------------------------------------------------------------
// Internal Use only
-(GSWContext*)_context
{
  GSWContext* context=nil;
  
  NSMutableDictionary * thDict = [[NSThread currentThread] threadDictionary];
  
  context = [thDict objectForKey:GSWThreadKey_Context];
  
  return context;
}


//--------------------------------------------------------------------
-(BOOL)_isDynamicLoadingEnabled
{
  return _dynamicLoadingEnabled;
};

//--------------------------------------------------------------------
-(void)_disableDynamicLoading
{
  _dynamicLoadingEnabled=NO;
};


//--------------------------------------------------------------------
-(BOOL)_isPageRecreationEnabled
{
  return _pageRecreationEnabled;
};

//--------------------------------------------------------------------
-(void)_touchPrincipalClasses
{
  NSArray* allFrameworks=nil;
  
  [self lock];
  NS_DURING
    {
      int frameworkN=0;
      int allFrameworksCount=0;
      //????
      allFrameworks=[NSBundle allFrameworks];
      allFrameworksCount=[allFrameworks count];

      for(frameworkN=0;frameworkN<allFrameworksCount;frameworkN++)
        {
          //Not used yet NSDictionary* infoDictionary=[[allFrameworks objectAtIndex:frameworkN] infoDictionary];
          //TODO what ???
        };
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"");
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  
};

//--------------------------------------------------------------------
/** Returns base application URL so visitor will be relocated 
to another instance **/
-(NSString*)_newLocationForRequest:(GSWRequest*)aRequest
{
  NSString* location=nil;
  if (aRequest)
    {
      location=[NSString stringWithFormat:@"%@/%@",
                         [aRequest adaptorPrefix],
                         [aRequest applicationName]];
    };
  return location;
};

//--------------------------------------------------------------------
//called when deamon is shutdown
-(void)_connectionDidDie:(id)unknown
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(BOOL)_shouldKill
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
//TODO return  (Vv9@0:4c8)
-(void)_setShouldKill:(BOOL)flag
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(void)_synchronizeInstanceSettingsWithMonitor:(id)_monitor
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(BOOL)_setupForMonitoring
{
  //OK
  id remoteMonitor=nil;
  NSString* monitorApplicationName=nil;
  int port=0;
  
  monitorApplicationName=[self _monitorApplicationName];
  port=[[self class]intPort];
  remoteMonitor=[self _remoteMonitor];
  
  return (remoteMonitor!=nil);
};

//--------------------------------------------------------------------
-(id)_remoteMonitor
{
  
  if (!_remoteMonitor)
    {
      NSString* monitorHost=[self _monitorHost];
//      NSNumber* workerThreadCount=[[self class]workerThreadCount];
      id proxy=nil;
//      if ([[NSDistantObject class] respondsToSelector:@selector(setDebug:)])
//	{
//	  [NSDistantObject setDebug:YES];
//	}
      _remoteMonitorConnection = [NSConnection connectionWithRegisteredName:GSWMonitorServiceName
                                               host:monitorHost];
      proxy=[_remoteMonitorConnection rootProxy];
      _remoteMonitor=[proxy performSelector:@selector(targetForProxy)];
      [self _synchronizeInstanceSettingsWithMonitor:_remoteMonitor];
    };
  
  return _remoteMonitor;
};

//--------------------------------------------------------------------
-(NSString*)_monitorHost
{
  return [[self class]monitorHost];
};

//--------------------------------------------------------------------
-(NSString*)_monitorApplicationName
{
  NSString* name=[self name];
  NSNumber* port=[(GSWAppClassDummy*)[self class] port];
  NSString* monitorApplicationName=[NSString stringWithFormat:@"%@-%@",
                                             name,
                                             port];
  return monitorApplicationName;
};

//--------------------------------------------------------------------
-(void)_terminateFromMonitor
{
  [self terminate];
};

//--------------------------------------------------------------------
//adaptors

-(NSArray*)adaptors 
{
  return _adaptors;
};

//--------------------------------------------------------------------
//adaptorWithName:arguments:

-(GSWAdaptor*)adaptorWithName:(NSString*)name
                    arguments:(NSDictionary*)arguments
{
/*
  //call _isDynamicLoadingEnabled
  // call isTerminating
  //call isCachingEnabled
  //call isPageRefreshOnBacktrackEnabled
*/
  GSWAdaptor* adaptor=nil;
  Class adaptorClass=NSClassFromString(name);

  NSAssert([name length]>0,@"No adaptor name");
  NSAssert1(adaptorClass,@"No adaptor named '%@'",name);

  if (adaptorClass)
    {
      Class gswadaptorClass=[GSWAdaptor class];
      if (GSObjCIsKindOf(adaptorClass,gswadaptorClass))
        {
          adaptor=[[[adaptorClass alloc] initWithName:name
                                         arguments:arguments] autorelease];
        }
      else
        {
          NSAssert1(NO,@"adaptor of class %@ is not a GSWAdaptor",name);
        };
    };
  
  if([adaptor dispatchesRequestsConcurrently])
    _isMultiThreaded = YES;

  return adaptor;
};


//--------------------------------------------------------------------
//setCachingEnabled:
-(void)setCachingEnabled:(BOOL)flag
{
  [[self class]setCachingEnabled:flag];
};

//--------------------------------------------------------------------
//isCachingEnabled
-(BOOL)isCachingEnabled 
{
  //OK
  return [[self class]isCachingEnabled];
};


//--------------------------------------------------------------------
//sessionStore
-(GSWSessionStore*)sessionStore 
{
  return _sessionStore;
};

//--------------------------------------------------------------------
//setSessionStore:
-(void)setSessionStore:(GSWSessionStore*)sessionStore
{
  if (_sessionStore)
    {
      // We can't set the editing context if one has already been created
      [NSException raise:NSInvalidArgumentException 
                   format:@"%s Can't set a sessionStore when one already exists",
                   object_getClassName(self)];
    }
  else
    {
      ASSIGN(_sessionStore,sessionStore);
    };
};

//--------------------------------------------------------------------
-(void)saveSessionForContext:(GSWContext*)aContext
{
  GSWSession* session=nil;
  session = [aContext _session];                            // NOT existingSession!
  if (session != nil) {
	  [session sleepInContext:aContext];
	  [_sessionStore checkInSessionForContext:aContext];
	  [aContext _setSession:nil];
  }
}

//--------------------------------------------------------------------
-(GSWSession*)restoreSessionWithID:(NSString*)sessionID
                         inContext:(GSWContext*)aContext
{
  GSWSession* session=nil;
  
  session = [_sessionStore checkOutSessionWithID:sessionID
                                         request:[aContext request]];
  
  if (session != nil)
  {
    [aContext _setSession:session];
    [session awakeInContext:aContext];
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SessionDidRestoreNotification"
                                                      object:session];
  
  return session;
}

//--------------------------------------------------------------------
-(Class)_sessionClass
{
  Class sessionClass=nil;
  
//  sessionClass=[[_resourceManager _appProjectBundle] scriptedClassWithName:GSWClassName_Session
//                                                            superclassName:GSWClassName_Session];
  
  if (!sessionClass)
    sessionClass=NSClassFromString(GSWClassName_Session);
  
  return sessionClass;
}

//--------------------------------------------------------------------
//NDFN
-(Class)sessionClass
{
  return [self _sessionClass];
};

//--------------------------------------------------------------------
-(GSWSession*)createSessionForRequest:(GSWRequest*)aRequest
{
  //OK
  GSWSession* session=nil;
  
  session=[self _createSessionForRequest:aRequest];

  // is this done in 4.5? -- dw
  [_statisticsStore _applicationCreatedSession:session];
    
  return session;
}

//--------------------------------------------------------------------
-(GSWSession*)_createSessionForRequest:(GSWRequest*)aRequest
{
  //OK
  Class sessionClass=Nil;
  GSWSession* session=nil;
  
  sessionClass=[self _sessionClass];
  
  if (!sessionClass)
  {
    NSAssert(NO,@"Can't find session class");
  }
  else
  {
    session=[[sessionClass new]autorelease];
  }
  
  return session;
}


//--------------------------------------------------------------------
//setPageCacheSize:

-(void)setPageCacheSize:(unsigned int)size
{
  _pageCacheSize = size;
};

//--------------------------------------------------------------------
//pageCacheSize

-(unsigned int)pageCacheSize 
{
  return _pageCacheSize;
};

//--------------------------------------------------------------------
-(unsigned)permanentPageCacheSize;
{
  return _permanentPageCacheSize;
};

//--------------------------------------------------------------------
-(void)setPermanentPageCacheSize:(unsigned)size
{
  _permanentPageCacheSize=size;
};

//--------------------------------------------------------------------
//isPageRefreshOnBacktrackEnabled

-(BOOL)isPageRefreshOnBacktrackEnabled 
{
  return _pageRefreshOnBacktrackEnabled;
};

//--------------------------------------------------------------------
-(void)setPageRefreshOnBacktrackEnabled:(BOOL)flag
{
  [self lock];
  _pageRefreshOnBacktrackEnabled=flag;
  [self unlock];
};

//--------------------------------------------------------------------
-(GSWComponent*)pageWithName:(NSString*)aName
                  forRequest:(GSWRequest*)aRequest
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
// raises an exception if the page cannot be created
// this behaviour is documeted on Apple's WO 4.5 Doc pages.
// if you want to create your own pages not based on .wo wrappers, you should 
// override this without calling super.

-(GSWComponent*)pageWithName:(NSString*)aName
                   inContext:(GSWContext*)aContext
{
  //OK
  GSWComponent* component=nil;
  GSWComponentDefinition* componentDefinition=nil;
  NSArray* languages=nil;

  if (!aContext) {
    [NSException raise:NSInvalidArgumentException 
                 format:@"%s: No context!",
                 __PRETTY_FUNCTION__];
  }
  [self lock];
  NS_DURING
    {
      // If the pageName is empty, try to get one from -defaultPageName
      if ((!aName) || ([aName length]<1)) {
        aName=[self defaultPageName];
      }
      // If the pageName is still empty, use a default one ("Main")
      if ((!aName) || ([aName length]<1)) {
        aName=GSWMainPageName;
      }

      languages=[aContext languages];

      // Find component definition for pageName and languages
      componentDefinition=[self lockedComponentDefinitionWithName:aName
                                languages:languages];

      if (!componentDefinition) {
        [NSException raise:NSInvalidArgumentException 
                    format:@"%s: unable to create page '%@'.",
                            __PRETTY_FUNCTION__, aName];
      }
      // As we've found a component defintion, we create an instance (an object of class GSWComponent)
      component=[componentDefinition componentInstanceInContext:aContext];
      [component _awakeInContext:aContext];

      // And flag it as a page.
      [component _setIsPage:YES];
    }
  NS_HANDLER
    {
      localException=[localException exceptionByAddingUserInfoFrameInfoFormat:@"In %s",
                                                                               __PRETTY_FUNCTION__];
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  return component;
}

//--------------------------------------------------------------------
//NDFN
-(NSString*)defaultPageName
{
  return GSWMainPageName;
};


//--------------------------------------------------------------------
-(GSWElement*)dynamicElementWithName:(NSString*)aName
                        associations:(NSDictionary*)someAssociations
                            template:(GSWElement*)templateElement
                           languages:(NSArray*)languages
{
  GSWElement* element=nil;
  [self lock];
  NS_DURING
    {
      element=[self lockedDynamicElementWithName:aName
                    associations:someAssociations
                    template:templateElement
                    languages:languages];
    }
  NS_HANDLER
    {
      [self unlock];
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In lockedDynamicElementWithName:associations:template:languages:");
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  return element;
};

//--------------------------------------------------------------------
-(GSWElement*)lockedDynamicElementWithName:(NSString*)aName
                              associations:(NSDictionary*)someAssociations
                                  template:(GSWElement*)templateElement
                                 languages:(NSArray*)languages
{
  GSWElement* element=nil;
  Class elementClass=nil;
  //lock bundle
  //unlock bundle
  if ([someAssociations isAssociationDebugEnabledInComponent:nil])
    [someAssociations associationsSetDebugEnabled];
  elementClass=NSClassFromString(aName);

  if (elementClass && !ClassIsKindOfClass(elementClass,[GSWComponent class]))
    {
      element=[[(GSWDynamicElement*)[elementClass alloc] initWithName:aName
                                                         associations:someAssociations
                                                             template:templateElement]
                autorelease];
    }
  else
    {
      GSWComponentDefinition* componentDefinition=nil;
      componentDefinition=[self lockedComponentDefinitionWithName:aName
                                 languages:languages];
      if (componentDefinition)
        {
          element=[componentDefinition componentReferenceWithAssociations:someAssociations
                                         template:templateElement];
        }
      else
        {
          ExceptionRaise(@"GSWApplication",
                         @"GSWApplication: Component Definition named '%@' not found or can't be created",
                         aName);
        };
    };
  return element;
};


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
  SEL registerForEventsSEL=NULL;
  SEL unregisterForEventsSEL=NULL;
  
  registerForEventsSEL=@selector(registerForEvents);
  unregisterForEventsSEL=@selector(unregisterForEvents);
  [_adaptors makeObjectsPerformSelector:registerForEventsSEL];
  //call adaptor run
  //call self _openInitialURL

  NSAssert(_currentRunLoop,@"No runLoop");
  
  NS_DURING {    
    NSLog(@"Application running. To use direct connect enter\n%@\nin your web Browser.\nPlease make sure that this port is only reachable in a trusted network.",
          [self _directConnectURL]);
    
    while ((_terminating == NO) && [_currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
      // run loop
    }
  } NS_HANDLER {
    NSLog(@"%@",localException);
    [localException raise];
  } NS_ENDHANDLER;
  
  [_adaptors makeObjectsPerformSelector:unregisterForEventsSEL];
  
}

//--------------------------------------------------------------------
//runLoop

-(NSRunLoop*)runLoop 
{
  return _currentRunLoop;
};

//--------------------------------------------------------------------
// threadWillExit
//NDFN
-(void)threadWillExit
{
//printf("GC** GarbageCollector collectGarbages START\n");
//TODO-NOW  [GarbageCollector collectGarbages];//LAST //CLEAN
//GSWLogC("GC** GarbageCollector collectGarbages STOP");
//printf("GC** GarbageCollector collectGarbages STOP\n");
};

//--------------------------------------------------------------------
//setTimeOut:

-(void)setTimeOut:(NSTimeInterval)aTimeInterval
{
  if (aTimeInterval==0)
    _timeOut=[[NSDate distantFuture]timeIntervalSinceDate:_lastAccessDate];
  else
    _timeOut=aTimeInterval;  
  [self _scheduleApplicationTimerForTimeInterval:_timeOut];
};

//--------------------------------------------------------------------
//timeOut

-(NSTimeInterval)timeOut 
{
  return _timeOut;
};

//--------------------------------------------------------------------
//isTerminating

-(BOOL)isTerminating 
{
  return _terminating;
}

//--------------------------------------------------------------------
//terminate
-(void)terminate 
{
//  NSTimer* timer=nil;
  _terminating = YES;
  /*
  timer=[NSTimer timerWithTimeInterval:0
                 target:self
                 selector:@selector(_handleQuitTimer:)
                 userInfo:nil
                 repeats:NO];
  [GSWApp addTimer:timer];
   */
}

//--------------------------------------------------------------------
-(void)_scheduleApplicationTimerForTimeInterval:(NSTimeInterval)aTimeInterval
{
  
  [self lock];
  NS_DURING
    {
      [_timer invalidate];
      ASSIGN(_timer,[NSTimer timerWithTimeInterval:aTimeInterval
                             target:self
                             selector:@selector(_terminateOrResetTimer:)
                             userInfo:nil
                             repeats:NO]);
      [self lockedAddTimer:_timer];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In addTimer:");
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  
};

//--------------------------------------------------------------------
// lastAccessDate

-(NSDate*)lastAccessDate
{
  return _lastAccessDate;
};

//--------------------------------------------------------------------
// startDate

-(NSDate*)startDate
{
  return _startDate;
};

//--------------------------------------------------------------------
//NDFN
-(void)lockedAddTimer:(NSTimer*)aTimer
{
  [[self runLoop]addTimer:aTimer
                 forMode:NSDefaultRunLoopMode];  
};

//--------------------------------------------------------------------
//NDFN
-(void)addTimer:(NSTimer*)aTimer
{ 
  [self lock];
  NS_DURING
    {
      [self lockedAddTimer:aTimer];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In addTimer:");
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];  
};

//--------------------------------------------------------------------
-(void)_terminateOrResetTimer:(NSTimer*)aTimer
{
  NSTimeInterval timIntervalSinceLastAccessDate=[[NSDate date]timeIntervalSinceDate:_lastAccessDate];
  if (timIntervalSinceLastAccessDate >= _timeOut) // Time out ?
    [self terminate];
  else // reschedule
    [self _scheduleApplicationTimerForTimeInterval:_timeOut-timIntervalSinceLastAccessDate];
};

//--------------------------------------------------------------------
-(void)_setNextCollectionCount:(int)_count
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(void)_sessionDidTimeOutNotification:(NSNotification*)notification
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
      NSString* directConnectURL=[self _directConnectURL];
      if ([[self class]autoOpenInBrowser])
        {
          [self _openURL:directConnectURL];
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
-(void)_openURL:(NSString*)url
{
//  [NSBundle bundleForClass:XX];
  //TODO finish
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(BOOL)runOnce
{
  BOOL ret=NO;
  if (![self isTerminating])
    {
      [_currentRunLoop runMode:[_currentRunLoop currentMode]
                       beforeDate:_runLoopDate];
      ret=YES;
    }
  return ret;
};


-(GSWResponse*)dispatchRequest:(GSWRequest*)aRequest
{
  GSWResponse           * response=nil;
  GSWRequestHandler     * requestHandler=nil;
  
  NS_DURING
    {
      NSNotificationCenter  * noteCenter = [NSNotificationCenter defaultCenter];
      ASSIGN(_lastAccessDate,[NSDate date]);
      
      [noteCenter postNotificationName:@"ApplicationWillDispatchRequestNotification"
		  object:aRequest];
      
      requestHandler = [self handlerForRequest:aRequest];
    
      if (!requestHandler)
	requestHandler = [self defaultRequestHandler];
        
      response = [requestHandler handleRequest:aRequest];
      if (!response)
	response = [self createResponseInContext:nil];
    
      [self _resetCache];
      
      [noteCenter postNotificationName:@"ApplicationDidDispatchRequestNotification"
		  object:response];
      [aRequest _setContext:nil];
    }
  NS_HANDLER
    {
      NSLog(@"EXCEPTION: %@",localException);
    }
  NS_ENDHANDLER;
  
  return response;
}

//--------------------------------------------------------------------
//awake

-(void)awake
{
  //Does Nothing
};

//--------------------------------------------------------------------
//takeValuesFromRequest:inContext:

-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext 
{
  GSWSession* session=[aContext existingSession];
  [session takeValuesFromRequest:aRequest
           inContext:aContext];
};


//--------------------------------------------------------------------
//invokeActionForRequest:inContext:

-(id <GSWActionResults>)invokeActionForRequest:(GSWRequest*)aRequest
                                     inContext:(GSWContext*)aContext
{
  id <GSWActionResults> results = nil;
  
  NS_DURING
    {
      GSWSession* session = [aContext existingSession];
      results = [session invokeActionForRequest:aRequest
			 inContext:aContext];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
							      @"In GSWApplication invokeActionForRequest:inContext");
      [localException raise];
    }
  NS_ENDHANDLER;
  
  return results;
}

//--------------------------------------------------------------------
//appendToResponse:inContext:

-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext 
{
  GSWRequest* request=[aContext request];
  GSWSession* session=[aContext existingSession];

  if ([aContext _isRefusingThisRequest])
    {
      [aResponse _generateRedirectResponseWithMessage:nil
                 location:[self _newLocationForRequest:request]
                 isDefinitive:YES];//301
      [session terminate];
    }
  else
    {
      NS_DURING
        {
          [session appendToResponse:aResponse
                   inContext:aContext];
        }
      NS_HANDLER
        {
          localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                                  @"In %@ appendToResponse:inContext",
                                                                  [self class]);
          [localException raise];
        }
      NS_ENDHANDLER;

      NS_DURING
        {
          [self _setRecordingHeadersToResponse:aResponse
                forRequest:request
                inContext:aContext];
        }
      NS_HANDLER
        {
          localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                                  @"In %@ _setRecordingHeadersToResponse...",
                                                                  [self class]);
          [localException raise];
        }
      NS_ENDHANDLER;
    };
  
};

-(void)_setRecordingHeadersToResponse:(GSWResponse*)aResponse
                           forRequest:(GSWRequest*)aRequest
                            inContext:(GSWContext*)aContext
{  
  if (_recorder
      && ([aRequest headerForKey:GSWHTTPHeader_Recording[GSWebNamingConv]]
          || [[self class] recordingPath]))
    {
      NSString* sessionID = nil;
      GSWSession* session = nil;
      NSString* header=nil;
      
      header=GSWIntToNSString([aRequest applicationNumber]);

      [aResponse setHeader:header
                 forKey:GSWHTTPHeader_RecordingApplicationNumber[GSWebNamingConv]];
      
      if ([aContext hasSession])
        {
          session = [aContext session];
          sessionID = [session sessionID];
        }
      else
        sessionID = [aRequest sessionID];

      if (sessionID)
        {
          [aResponse setHeader:sessionID
                     forKey:GSWHTTPHeader_RecordingSessionID[GSWebNamingConv]];
          
          if ([session storesIDsInCookies])
            [aResponse setHeader:@"yes"
                       forKey:GSWHTTPHeader_RecordingIDsCookie[GSWebNamingConv]];
          
          if ([session storesIDsInURLs])
            [aResponse setHeader:@"yes"
                       forKey:GSWHTTPHeader_RecordingIDsURL[GSWebNamingConv]];
        };
    };

  
};

//--------------------------------------------------------------------
//sleep

-(void)sleep 
{
  //Does Nothing
};


//Not used now. For future exception handling rewrite
-(GSWResponse*)_invokeDefaultException:(NSException*)exception
                                 named:(NSString*)name
                             inContext:(GSWContext*)aContext
{
  //TODO
  GSWResponse* response=nil;
  
  response=[GSWResponse responseWithMessage:@"Exception Handling failed"
                        inContext:aContext
                        forRequest:nil];
  
  return response;
};

//--------------------------------------------------------------------
-(GSWResponse*)_handleErrorWithPageNamed:(NSString*)pageName
                               exception:(NSException*)anException
                               inContext:(GSWContext*)aContext
{
  GSWContext* context=aContext;
  GSWResponse* response=nil;
  GSWComponent* errorPage=nil;
  
  if (context)
    [context _putAwakeComponentsToSleep];
  else
    {
      context=[GSWContext contextWithRequest:nil];	  
    };
  //TODO Hack: verify that there is an application context otherswise, it failed in component Creation
  if (![self _context])
      [self _setContext:context];

  NS_DURING
    {
      errorPage=[self pageWithName:pageName
                         inContext:context];
      
      if (anException)
        [errorPage setValue:anException
                     forKey:@"exception"]; 
    }
  NS_HANDLER
    {
      // My God ! Exception on exception !      
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In _handleException:inContext:");
      NSLog(@"exception=%@",localException);                                                         
      if ([[localException name]isEqualToString:GSWPageNotFoundException])
        response=[self _invokeDefaultException:localException
                       named:pageName
                       inContext:aContext];
      else
        {
          //TODO: better exception text...
          NSException* exception=[NSException exceptionWithName:@"Exception"
                                              reason:[NSString stringWithFormat:@"Cant handle exception %@",localException]
                                              userInfo:nil];
          response=[self _invokeDefaultException:exception
                         named:pageName
                         inContext:aContext];
        };
    }
  NS_ENDHANDLER;
  if (!response)
    {
      if (errorPage)
        {
//          id monitor=nil;
          response=[errorPage generateResponse];          
          //here ?
//          monitor=[self _remoteMonitor];
//          if (monitor)
//            {
//              //Not used yet NSString* monitorApplicationName=[self _monitorApplicationName];
//              //TODO
//            };
        }
      else
        {
          NSString* message=[NSString stringWithFormat:@"Exception Handling failed. Can't find Error Page named '%@'",
                                      pageName];
          NSLog(@"%@", message);
                                      
          response=[GSWResponse responseWithMessage:message
                                inContext:context
                                forRequest:nil];
        };
    };
  NSAssert(![response isFinalizeInContextHasBeenCalled],
           @"GSWApplication _handlePageRestorationErrorInContext: _finalizeInContext called for GSWResponse");
  
  return response;
};

//--------------------------------------------------------------------
-(GSWResponse*)handleException:(NSException*)anException 
                     inContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  
  NSLog(@"EXCEPTION=%@",anException);
  NS_DURING
    {
      response = 
	[self _handleErrorWithPageNamed: GSWExceptionPageName[GSWebNamingConv]
	      exception: anException
	      inContext: aContext];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In _handleException:inContext:");
      response=[GSWResponse responseWithMessage:@"Exception Handling failed"
                            inContext:aContext
                            forRequest:nil];
    }
  NS_ENDHANDLER;
  NSAssert(![response isFinalizeInContextHasBeenCalled],
           @"GSWApplication handleException: _finalizeInContext called for GSWResponse");
  
  return response;
};

//--------------------------------------------------------------------
//handlePageRestorationError
-(GSWResponse*)handlePageRestorationErrorInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  
  NS_DURING
    {
      response=[self _handlePageRestorationErrorInContext:aContext];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In _handlePageRestorationErrorInContext:");
      response=[GSWResponse responseWithMessage:@"Exception Handling failed. Can't find Page Restoration Error Page"
                            inContext:aContext
                            forRequest:nil];
    }
  NS_ENDHANDLER;
  NSAssert(![response isFinalizeInContextHasBeenCalled],
           @"GSWApplication handlePageRestorationErrorInContext: _finalizeInContext called for GSWResponse");
  
  return response;
};


//--------------------------------------------------------------------
//handlePageRestorationError
-(GSWResponse*)_handlePageRestorationErrorInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  
  response=[self _handleErrorWithPageNamed:GSWPageRestorationErrorPageName[GSWebNamingConv]
                 exception:nil
                 inContext:aContext];
  
  return response;
};

//--------------------------------------------------------------------
//handleSessionCreationError
-(GSWResponse*)handleSessionCreationErrorInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  
  NS_DURING
    {
      response=[self _handleSessionCreationErrorInContext:aContext];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In _handleSessionCreationErrorInContext:");
      response=[GSWResponse responseWithMessage:@"Session Creation Error Handling failed."
                            inContext:aContext
                            forRequest:nil];
    }
  NS_ENDHANDLER;
  NSAssert(![response isFinalizeInContextHasBeenCalled],
           @"GSWApplication handleSessionCreationErrorInContext: _finalizeInContext called for GSWResponse");
  
  return response;
};

//--------------------------------------------------------------------
//handleSessionCreationError
-(GSWResponse*)_handleSessionCreationErrorInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  
  response=[self _handleErrorWithPageNamed:GSWSessionCreationErrorPageName[GSWebNamingConv]
                 exception:nil
                 inContext:aContext];
  
  return response;
};

//--------------------------------------------------------------------
//handleSessionRestorationError

-(GSWResponse*)handleSessionRestorationErrorInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  
  NS_DURING
    {
      response=[self _handleSessionRestorationErrorInContext:aContext];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In _handleSessionRestorationErrorInContext:");
      response=[GSWResponse responseWithMessage:@"Session Restoration Error Handling failed."
                            inContext:aContext
                            forRequest:nil];
    }
  NS_ENDHANDLER;
  NSAssert(![response isFinalizeInContextHasBeenCalled],
           @"GSWApplication handleSessionRestorationErrorInContext: _finalizeInContext called for GSWResponse");
  
  return response;
};

//--------------------------------------------------------------------
//handleSessionRestorationError

-(GSWResponse*)_handleSessionRestorationErrorInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  
  response=[self _handleErrorWithPageNamed:GSWSessionRestorationErrorPageName[GSWebNamingConv]
                 exception:nil
                 inContext:aContext];
  
  return response;
};

//--------------------------------------------------------------------
-(GSWResponse*)handleActionRequestErrorWithRequest:(GSWRequest*)aRequest
                                         exception:(NSException*)exception
                                            reason:(NSString*)reason
                                    requestHanlder:(GSWActionRequestHandler*)requestHandler
                                   actionClassName:(NSString*)actionClassName
                                        actionName:(NSString*)actionName
                                       actionClass:(Class)actionClass
                                      actionObject:(GSWAction*)actionObject
{
    
  //do nothing
  
  return nil;
}

+(GSWApplication*)application
{
  return GSWApp;
};

+(void)_setApplication:(GSWApplication*)application
{
  //OK
  //Call self _isDynamicLoadingEnabled
  //call self isTerminating
  //call self isCachingEnabled
  //call self isPageRefreshOnBacktrackEnabled
  GSWApp=application;
}

-(void)setPrintsHTMLParserDiagnostics:(BOOL)flag
{
  [self lock];
  NS_DURING
    {
      _printsHTMLParserDiagnostics=flag;
    }
  NS_HANDLER
    {
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
  //FIXME
//  return [GSWHTMLParser printsDiagnostics];
  return NO;
};

//--------------------------------------------------------------------
//scriptedClassWithPath:

-(Class)scriptedClassWithPath:(NSString*)path
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
//scriptedClassWithPath:encoding:

-(Class)scriptedClassWithPath:(NSString*)path
                     encoding:(NSStringEncoding)encoding
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(Class)_classWithScriptedClassName:(NSString*)aName
                          languages:(NSArray*)languages
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)_setClassFromNameResolutionEnabled:(BOOL)flag
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
//NDFN
-(Class)libraryClassWithPath:(NSString*)path
{
  Class aClass=nil;
  NSBundle* bundle=[NSBundle bundleWithPath:path];
  if (bundle)
    {
      [bundle load];
      aClass=[bundle principalClass];
    };
  return aClass;
};

//--------------------------------------------------------------------
-(void)debugWithString:(NSString*)aString
{
  if ([[self class]isDebuggingEnabled])
    {
      GSWFPutSL(aString,stderr);
    };
};

//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)aFormat
             arguments:(va_list)arguments
{
  NSString* string=[NSString stringWithFormat:aFormat
                              arguments:arguments];
  [self debugWithString:string];
};

//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [self debugWithFormat:aFormat
        arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)debugWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [GSWApp debugWithFormat:aFormat
          arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------

-(void)_setTracingAspect:(id)unknwon
                 enabled:(BOOL)enabled
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [self logWithFormat:aFormat
        arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)logWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [GSWApp logWithFormat:aFormat
          arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(void)logString:(NSString*)aString
{
  GSWFPutSL(aString,stderr);
};

//--------------------------------------------------------------------
+(void)logString:(NSString*)aString
{
  [GSWApp logString:aString];
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)aFormat
           arguments:(va_list)arguments
{
  NSString* string=[NSString stringWithFormat:aFormat
                             arguments:arguments];
  [self logString:string];
};

//--------------------------------------------------------------------
-(void)logErrorWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [self logErrorWithFormat:aFormat
        arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)logErrorWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [GSWApp logErrorWithFormat:aFormat
          arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(void)logErrorString:(NSString*)aString
{
  GSWFPutSL(aString,stderr);
  GSWFPutSL(aString,stdout);
};

//--------------------------------------------------------------------
+(void)logErrorString:(NSString*)aString
{
  [GSWApp logErrorString:aString];
};

//--------------------------------------------------------------------
-(void)logErrorWithFormat:(NSString*)aFormat
                arguments:(va_list)arguments
{
  NSString* string=[NSString stringWithFormat:aFormat
                             arguments:arguments];
  [self logErrorString:string];
};

//--------------------------------------------------------------------
//trace:
-(void)trace:(BOOL)flag
{
  if (flag!=_isTracingEnabled)
    {
      [self lock];
      _isTracingEnabled=flag;
      [self unlock];
    };
};

//--------------------------------------------------------------------
//traceAssignments:
-(void)traceAssignments:(BOOL)flag
{
  if (flag!=_isTracingAssignmentsEnabled)
    {
      [self lock];
      _isTracingAssignmentsEnabled=flag;
      [self unlock];
    };
};

//--------------------------------------------------------------------
//traceObjectiveCMessages:
-(void)traceObjectiveCMessages:(BOOL)flag
{
  if (flag!=_isTracingObjectiveCMessagesEnabled)
    {
      [self lock];
      _isTracingObjectiveCMessagesEnabled=flag;
      [self unlock];
    };
};

//--------------------------------------------------------------------
//traceScriptedMessages:
-(void)traceScriptedMessages:(BOOL)flag
{
  if (flag!=_isTracingScriptedMessagesEnabled)
    {
      [self lock];
      _isTracingScriptedMessagesEnabled=flag;
      [self unlock];
    };
};

//--------------------------------------------------------------------
//traceStatements:
-(void)traceStatements:(BOOL)flag
{
  if (flag!=_isTracingStatementsEnabled)
    {
      [self lock];
      _isTracingStatementsEnabled=flag;
      [self unlock];
    };
};

//--------------------------------------------------------------------
+(void)logSynchronizeComponentToParentForValue:(id)aValue
                                   association:(GSWAssociation*)anAssociation
                                   inComponent:(NSObject*)aComponent
{
  //TODO
  [self logWithFormat:@"ComponentToParent [%@:%@] %@ ==> %@",
		@"",
		[aComponent description],
		aValue,
		[anAssociation bindingName]];
};

//--------------------------------------------------------------------
+(void)logSynchronizeParentToComponentForValue:(id)aValue
                                   association:(GSWAssociation*)anAssociation
                                   inComponent:(NSObject*)aComponent
{
  //TODO
  [self logWithFormat:@"ParentToComponent [%@:%@] %@ ==> %@",
        @"",
        [aComponent description],
        aValue,
        [anAssociation bindingName]];
};

//--------------------------------------------------------------------
+(void)logTakeValueForDeclarationNamed:(NSString*)aDeclarationName
                                  type:(NSString*)aDeclarationType
                          bindingNamed:(NSString*)aBindingName
                associationDescription:(NSString*)associationDescription
                                 value:(id)aValue
{
  [GSWApp logTakeValueForDeclarationNamed:aDeclarationName
          type:aDeclarationType
          bindingNamed:aBindingName
          associationDescription:associationDescription
          value:aValue];
};

//--------------------------------------------------------------------
+(void)logSetValueForDeclarationNamed:(NSString*)aDeclarationName
                                 type:(NSString*)aDeclarationType
                         bindingNamed:(NSString*)aBindingName
               associationDescription:(NSString*)associationDescription
                                value:(id)aValue
{
  [GSWApp logSetValueForDeclarationNamed:aDeclarationName
          type:aDeclarationType
          bindingNamed:aBindingName
          associationDescription:associationDescription
          value:aValue];
};

//--------------------------------------------------------------------
-(void)logTakeValueForDeclarationNamed:(NSString*)aDeclarationName
                                  type:(NSString*)aDeclarationType
                          bindingNamed:(NSString*)aBindingName
                associationDescription:(NSString*)associationDescription
                                 value:(id)aValue
{
  //TODO
  [self logWithFormat:@"TakeValue DeclarationNamed:%@ type:%@ bindingNamed:%@ associationDescription:%@ value:%@",
		aDeclarationName,
		aDeclarationType,
		aBindingName,
		associationDescription,
		aValue];
};

//--------------------------------------------------------------------
-(void)logSetValueForDeclarationNamed:(NSString*)aDeclarationName
                                 type:(NSString*)aDeclarationType
                         bindingNamed:(NSString*)aBindingName
               associationDescription:(NSString*)associationDescription
                                value:(id)aValue
{
  //TODO
  [self logWithFormat:@"SetValue DeclarationNamed:%@ type:%@ bindingNamed:%@ associationDescription:%@ value:%@",
		aDeclarationName,
		aDeclarationType,
		aBindingName,
		associationDescription,
		aValue];
};

/**
 * This method is called when a request loop has finished.  You can override
 * this method to inspect your process (e.g. for memory leaks).  You should
 * create an NSAutoreleasePool at the beginning of your method and release
 * it at the end if you plan to use the implementation long running production
 * envirnment analysis.  This method is a GSWeb extension.  The default
 * implementation does nothing.
 */
-(void)debugAdaptorThreadExited
{
}


//--------------------------------------------------------------------
-(void)statusDebugWithString:(NSString*)aString
{
  if ([[self class]isStatusDebuggingEnabled])
    {
      GSWFPutSL(aString,stdout);
      [self debugWithString:aString];
    };
};

//--------------------------------------------------------------------
-(void)statusDebugWithFormat:(NSString*)aFormat
                   arguments:(va_list)arguments
{
  if ([[self class]isStatusDebuggingEnabled])
    {
      NSString* string=[NSString stringWithFormat:aFormat
				 arguments:arguments];
      [self statusDebugWithString:string];
    }
};

//--------------------------------------------------------------------
-(void)statusDebugWithFormat:(NSString*)aFormat,...
{
  if ([[self class]isStatusDebuggingEnabled])
    {
      va_list ap;
      va_start(ap,aFormat);
      [self statusDebugWithFormat:aFormat
	    arguments:ap];
      va_end(ap);
    }
};

//--------------------------------------------------------------------
+(void)statusDebugWithFormat:(NSString*)aFormat,...
{
  if ([[self class]isStatusDebuggingEnabled])
    {
      va_list ap;
      va_start(ap,aFormat);
      [GSWApp statusDebugWithFormat:aFormat
	      arguments:ap];
      va_end(ap);
    }
};

//--------------------------------------------------------------------
-(void)statusLogString:(NSString*)aString
{
  if ([[self class]isStatusDebuggingEnabled])
    {
      GSWFPutSL(aString,stdout);
      [self logString:aString];
    }
};

//--------------------------------------------------------------------
+(void)statusLogString:(NSString*)aString
{
  if ([[self class]isStatusLoggingEnabled])
    {
      [GSWApp statusLogString:aString];
    }
};

//--------------------------------------------------------------------
-(void)statusLogWithFormat:(NSString*)aFormat,...
{
  if ([[self class]isStatusLoggingEnabled])
    {
      va_list ap;
      va_start(ap,aFormat);
      [self statusLogWithFormat:aFormat
	    arguments:ap];
      va_end(ap);
    }
};

//--------------------------------------------------------------------
+(void)statusLogWithFormat:(NSString*)aFormat,...
{
  if ([[self class]isStatusLoggingEnabled])
    {
      va_list ap;
      va_start(ap,aFormat);
      [GSWApp statusLogWithFormat:aFormat
	      arguments:ap];
      va_end(ap);
    }
};

//--------------------------------------------------------------------
-(void)statusLogWithFormat:(NSString*)aFormat
                 arguments:(va_list)arguments
{
  if ([[self class]isStatusLoggingEnabled])
    {
      NSString* string=[NSString stringWithFormat:aFormat
				 arguments:arguments];
      [self statusLogString:string];
    }
};

//--------------------------------------------------------------------
-(void)statusLogErrorWithFormat:(NSString*)aFormat,...
{
  if ([[self class]isStatusLoggingEnabled])
    {
      va_list ap;
      va_start(ap,aFormat);
      [self statusLogErrorWithFormat:aFormat
	    arguments:ap];
      va_end(ap);
    }
};

//--------------------------------------------------------------------
+(void)statusLogErrorWithFormat:(NSString*)aFormat,...
{
  if ([[self class]isStatusLoggingEnabled])
    {
      va_list ap;
      va_start(ap,aFormat);
      [GSWApp statusLogErrorWithFormat:aFormat
	      arguments:ap];
      va_end(ap);
    }
};

//--------------------------------------------------------------------
-(void)statusLogErrorWithFormat:(NSString*)aFormat
                      arguments:(va_list)arguments
{
  if ([[self class]isStatusLoggingEnabled])
    {
      NSString* string=[NSString stringWithFormat:aFormat
				 arguments:arguments];
      GSWFPutSL(string,stdout);
      [self logErrorWithFormat:@"%@",string];
    }
};

//--------------------------------------------------------------------
-(void)statusLogErrorString:(NSString*)aString
{
  if ([[self class]isStatusLoggingEnabled])
    {
      GSWFPutSL(aString,stdout);
      [self logErrorString:aString];
    }
};

//--------------------------------------------------------------------
+(void)statusLogErrorString:(NSString*)aString
{
  if ([[self class]isStatusLoggingEnabled])
    {
      [GSWApp statusLogErrorString:aString];
    }
};

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
  return _statisticsStore;
};

//--------------------------------------------------------------------
//setStatisticsStore:
-(void)setStatisticsStore:(GSWStatisticsStore*)statisticsStore
{
  ASSIGN(_statisticsStore,statisticsStore);
};


//--------------------------------------------------------------------
//monitoringEnabled [deprecated]
-(BOOL)monitoringEnabled 
{
  return [[self class] isMonitorEnabled];
};

//--------------------------------------------------------------------
//activeSessionsCount
-(int)activeSessionsCount 
{
  return _activeSessionsCount;
};

//--------------------------------------------------------------------
//setMinimumActiveSessionsCount:
-(void)setMinimumActiveSessionsCount:(int)count
{
  _minimumActiveSessionsCount = count;
};

//--------------------------------------------------------------------
//minimumActiveSessionsCountCount
-(int)minimumActiveSessionsCount
{
  return _minimumActiveSessionsCount;
};

//--------------------------------------------------------------------
//isRefusingNewSessions
-(BOOL)isRefusingNewSessions 
{
  return _refusingNewSessions;
};

//--------------------------------------------------------------------
//refuseNewSessions:
-(void)refuseNewSessions:(BOOL)flag 
{
  if (flag && [[self class] isDirectConnectEnabled])
    {
      [NSException raise:NSInvalidArgumentException 
                   format:@"We can't refuse newSessions if direct connect enabled"];      
    }
  else
    {
      _refusingNewSessions = flag;
      if (_refusingNewSessions && _activeSessionsCount<=_minimumActiveSessionsCount)
        {
          NSLog(@"Application is refusing new session and active sessions count <= minimum session count. Will terminate");
          [self terminate];
        };
    };
};

//--------------------------------------------------------------------
-(NSTimeInterval)_refuseNewSessionsTimeInterval
{
  NSTimeInterval ti=0;
  NSTimeInterval sessionTimeOut=0;
  int activeSessionsCount=0;

  

  sessionTimeOut=[[self class]sessionTimeOutValue];
  activeSessionsCount=[self activeSessionsCount];
  
  if (activeSessionsCount>0) // Is there active sessions ?
    {
      // Wait for 1/4 of session time out
      ti = sessionTimeOut / 4;
    };
  if (ti<15)
    ti = 15;

  

  return ti;
}

//--------------------------------------------------------------------
//logToMonitorWithFormat:
-(void)logToMonitorWithFormat:(NSString*)aFormat 
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
//terminateAfterTimeInterval: [deprecated]
-(void)terminateAfterTimeInterval:(NSTimeInterval)aTimeInterval
{
  [self setTimeOut:aTimeInterval];
};

//--------------------------------------------------------------------
//setResourceManager:
-(void)setResourceManager:(GSWResourceManager*)resourceManager
{
  //OK
  [self lock];
  NS_DURING
    {
      ASSIGN(_resourceManager,resourceManager);
    }
  NS_HANDLER
    {
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
  return _resourceManager;
};

//--------------------------------------------------------------------
-(GSWRequestHandler*)defaultRequestHandler
{
  return _defaultRequestHandler;
};

//--------------------------------------------------------------------
-(void)setDefaultRequestHandler:(GSWRequestHandler*)handler
{
  
  [self lock];
  NS_DURING
    {
      ASSIGN(_defaultRequestHandler,handler);
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"application",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  
};

//--------------------------------------------------------------------
-(void)registerRequestHandler:(GSWRequestHandler*)handler
                       forKey:(NSString*)aKey
{
  [self lock];
  NS_DURING
    {
      if (!_requestHandlers)
        _requestHandlers=[NSMutableDictionary new];
      [_requestHandlers setObject:handler
                       forKey:aKey];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"application",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
};

//--------------------------------------------------------------------
-(void)removeRequestHandlerForKey:(NSString*)requestHandlerKey
{
  [self lock];
  NS_DURING
    {
      [_requestHandlers removeObjectForKey:requestHandlerKey];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"application",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
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
  return [_requestHandlers allKeys];
};

//--------------------------------------------------------------------
-(GSWRequestHandler*)requestHandlerForKey:(NSString*)aKey
{
  GSWRequestHandler* handler=nil;
  
  handler=[_requestHandlers objectForKey:aKey];
  
  return handler;
};

//--------------------------------------------------------------------
-(GSWRequestHandler*)handlerForRequest:(GSWRequest*)aRequest
{
  GSWRequestHandler* handler=nil;
  NSString* requestHandlerKey=nil;
  
  requestHandlerKey=[aRequest requestHandlerKey];
  NSDebugMLLog(@"application",@"requestHandlerKey=%@",requestHandlerKey);
  handler=[self requestHandlerForKey:requestHandlerKey];
  NSDebugMLLog(@"application",@"handler=%@",handler);
  
  return handler;
};

//--------------------------------------------------------------------
+(NSDictionary*)_webServerConfigDictionary
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(Class)_applicationClass
{
  NSBundle * mainBundle = [NSBundle mainBundle];
  NSString * className  = [[mainBundle infoDictionary] objectForKey:@"NSPrincipalClass"];
  Class      potentialAppClass = NULL;
  
  if (className) {
    potentialAppClass = NSClassFromString(className);
    
    if ((potentialAppClass) && GSObjCIsKindOf(potentialAppClass,[GSWApplication class])) 
    {
      return potentialAppClass;
    }
  } 
  
  potentialAppClass = NSClassFromString(@"Application");
  
  if ((potentialAppClass) && GSObjCIsKindOf(potentialAppClass,[GSWApplication class])) 
  {
    return potentialAppClass;
  }
  
  
  NSLog(@"You should consider creating your own WOApplication subclass.");
  return NSClassFromString(@"WOApplication");
}

//--------------------------------------------------------------------
+(Class)_compiledApplicationClass
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(GSWRequestHandler*)_componentRequestHandler
{
  return (GSWRequestHandler*)[GSWComponentRequestHandler handler];
};


//--------------------------------------------------------------------
+(id)defaultModelGroup
{
#ifdef TCSDB
  return (id) [NSClassFromString(@"DBModelGroup") defaultGroup];
#else
  return (id) [NSClassFromString(@"EOModelGroup") defaultGroup];
#endif
}

//--------------------------------------------------------------------
+(id)_modelGroupFromBundles:(id)bundles
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};


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
  NSBundle* mainBundle=nil;
//  [self notImplemented: _cmd];	//TODOFN
  mainBundle=[NSBundle mainBundle];
  NSDebugMLog(@"[mainBundle  bundlePath]:%@",[mainBundle  bundlePath]);
  return mainBundle;

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


//--------------------------------------------------------------------
+(int)_garbageCollectionRepeatCount
{
  [self notImplemented: _cmd];	//TODOFN
  return 1;
};

//--------------------------------------------------------------------
+(id)_allowsConcurrentRequestHandling
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(void)_setAllowsConcurrentRequestHandling:(id)unknown
{
  [self notImplemented: _cmd];	//TODOFN
};


//--------------------------------------------------------------------
+(int)_requestLimit
{
  [self notImplemented: _cmd];	//TODOFN
  return 1;
};

//--------------------------------------------------------------------
+(int)_requestWindow
{
  [self notImplemented: _cmd];	//TODOFN
  return 1;
};

//--------------------------------------------------------------------
+(BOOL)_multipleThreads
{
  [self notImplemented: _cmd];	//TODOFN
  return YES;
};

//--------------------------------------------------------------------
+(BOOL)_multipleInstances
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
+(void)_readLicenseParameters
{
  NSLog(@"LGPL'ed software don't have license parameters. To find License Parameters, please try proprietary softwares");
};


//--------------------------------------------------------------------
//NDFN
-(id)propListWithResourceNamed:(NSString*)aName
                        ofType:(NSString*)type
                   inFramework:(NSString*)aFrameworkName
                     languages:(NSArray*)languages
{
    id propList=nil;
    GSWResourceManager* resourceManager=nil;
    NSString* pathName=nil;
    
    resourceManager=[self resourceManager];
    pathName=[resourceManager pathForResourceNamed:[NSString stringWithFormat:@"%@.%@",aName,type]
                                       inFramework:aFrameworkName
                                         languages:languages];
    if (pathName)
    {
        NSStringEncoding  encoding;
        NSError          *error = nil;
        
        NSString* propListString=[NSString stringWithContentsOfFile:pathName
                                                       usedEncoding:&encoding
                                                              error:&error];
        propList = [propListString propertyList];
        if (!propList)
        {
            //          LOGSeriousError(@"Bad propertyList \n%@\n from file %@",
            //                          propListString,
            //                          pathName);
        };
    };
    
    return propList;
}

//--------------------------------------------------------------------
+(BOOL)createUnknownComponentClasses:(NSArray*)classes
                      superClassName:(NSString*)aSuperClassName
{
#ifdef NOEXTENSIONS
  ExceptionRaise(@"GSWApplication",
                 @"GSWApplication: createUnknownComponentClasses: %@ superClassName: %@\n works only when you do not define NOEXTENSIONS while compiling GSWeb",
                 classes, aSuperClassName);

  return NO;

#else
  BOOL ok=YES;
  int classesCount=0;


  classesCount=[classes count];

  if (classesCount>0)
    {
      int i=0;
      NSString* aClassName=nil;
      NSMutableArray* newClasses=nil;
      for(i=0;i<classesCount;i++)
        {
          aClassName=[classes objectAtIndex:i];
          NSDebugMLLog(@"application",@"aClassName:%@",aClassName);
          if (!NSClassFromString(aClassName))
            {
              NSString* superClassName=nil;
              superClassName=[localDynCreateClassNames objectForKey:aClassName];
              NSDebugMLLog(@"application",@"superClassName=%p",(void*)superClassName);
              if (!superClassName)
                {
                  superClassName=aSuperClassName;
                  if (!superClassName)
                    {
                      ExceptionRaise(@"GSWApplication",
                                     @"GSWApplication: no superclass for class named: %@",
                                     aClassName);
                    };
                };
              NSDebugMLLog(@"application",@"Create Unknown Class: %@ (superclass: %@)",
                           aClassName,
                           superClassName);
              if (superClassName)
                {
                  NSValue* aClassPtr=GSObjCMakeClass(aClassName,superClassName,nil);
                  if (aClassPtr)
                    {
                      if (!newClasses)
                        newClasses=[NSMutableArray array];
                      [newClasses addObject:aClassPtr];
                    }
                  else
                    {    
                      NSLog(@"Can't create one of these classes %@ (super class: %@)",
                               aClassName,superClassName);
                    };
                };
            };
        };
      if ([newClasses count]>0)
        {
          GSObjCAddClasses(newClasses);
        };
    };
  return ok;
#endif
};

//--------------------------------------------------------------------
+(void)addDynCreateClassName:(NSString*)className
              superClassName:(NSString*)superClassName
{
  NSDebugMLLog(@"gswdync",@"ClassName:%@ superClassName:%@",
	       className, superClassName);
  [localDynCreateClassNames setObject:superClassName
                            forKey:className];
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)pathForResourceNamed:(NSString*)name
                     inFramework:(NSString*)aFrameworkName
                       languages:(NSArray*)languages
{
  return [[self resourceManager]pathForResourceNamed:name
                                inFramework:aFrameworkName
                                languages:languages];
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)type
                     inFramework:(NSString*)aFrameworkName
                       languages:(NSArray*)languages
{
  
  NSString * name;
  
  if (type) {
    name = [NSString stringWithFormat:@"%@.%@",aName,type];
  } else {
    name = aName;
  }
  
  return [[self resourceManager]pathForResourceNamed:name
                                inFramework:aFrameworkName
                                languages:languages];
}

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlForResourceNamed:(NSString*)aName
                    inFramework:(NSString*)aFrameworkName
                      languages:(NSArray*)languages
                        request:(GSWRequest*)aRequest
{
  return [[self resourceManager]urlForResourceNamed:aName
                                inFramework:aFrameworkName
                                languages:languages
                                request:aRequest];
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)stringForKey:(NSString*)aKey
            inTableNamed:(NSString*)aTableName
        withDefaultValue:(NSString*)defaultValue
             inFramework:(NSString*)aFrameworkName
               languages:(NSArray*)languages
{
  return [[self resourceManager]stringForKey:aKey
                                inTableNamed:aTableName
                                withDefaultValue:defaultValue
                                inFramework:aFrameworkName
                                languages:languages];
};


////--------------------------------------------------------------------
////NDFN
//-(NSDictionary*)stringsTableNamed:(NSString*)aTableName
//                      inFramework:(NSString*)aFrameworkName
//                        languages:(NSArray*)languages
//{
//  NSDictionary* st=nil;
//  
//  st=[[self resourceManager]stringsTableNamed:aTableName
//                            inFramework:aFrameworkName
//                            languages:languages];
//  
//  return st;
//};

//--------------------------------------------------------------------
//NDFN
//-(NSArray*)stringsTableArrayNamed:(NSString*)aTableName
//                      inFramework:(NSString*)aFrameworkName
//                        languages:(NSArray*)languages
//{
//  return [[self resourceManager]stringsTableArrayNamed:aTableName
//                                inFramework:aFrameworkName
//                                languages:languages];
//};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)filterLanguages:(NSArray*)languages
{
  return languages;
};

- (NSString*) sessionIdKey
{
  return GSWKey_SessionID[GSWebNamingConv];
}

- (NSString*) instanceIdKey
{
  return GSWKey_InstanceID[GSWebNamingConv];
}


// Hackers note: we will not implement WO 5's newDynamicURL. Use 
// [GSWDynamicURLString string];
// or [GSWDynamicURLString stringWithString:url]
// instead.

// we need BOTH of those frameworkNameXX methods otherwise either GSWNames or WONames will fail -- dwetzel

// Returns GSWExtensions or WOExtensions
- (NSString*)frameworkNameGSWExtensions
{
  return GSWFramework_extensions[GSWebNamingConv];
}

- (NSString*)frameworkNameWOExtensions
{
    return GSWFramework_extensions[GSWebNamingConv];
}

@end

