/** GSWApplication+Defautls.m

   Copyright (C) 2004 Free Software Foundation, Inc.
   
   Written by:  David Ayers  <d.ayers@inode.at>
   Date: 	Aug 2004
   Based on:	GSWApplication.m

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


/* globals used by GSWeb: */
BOOL WOStrictFlag=NO;

/* static locals: */
static NSDictionary *globalAppDefaultOptions = nil;
static NSUserDefaults *_userDefaults = nil;

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
@end

void
GSWeb_ApplicationDebugSetChange()
{
  static NSString* prevStateString=nil;
  NSProcessInfo* processInfo=[NSProcessInfo processInfo];
  NSMutableSet* debugSet=[processInfo debugSet];
  NSString* debugSetConfigFilePath=nil;
  NSString* newStateString=nil;
  BOOL change=NO;

  debugSetConfigFilePath = [GSWApplication debugSetConfigFilePath];
  NSDebugFLog(@"debugSetConfigFilePath=%@", debugSetConfigFilePath);

  if (debugSetConfigFilePath)
    newStateString = [NSString stringWithContentsOfFile:
				 [GSWApplication debugSetConfigFilePath]];

  NSDebugFLog(@"debugSet=%@", debugSet);
  NSDebugFLog(@"newStateString=%@", newStateString);
  NSDebugFLog(@"prevStateString=%@", prevStateString);

  if (newStateString)
    change =! [newStateString isEqualToString: prevStateString];
  else if (prevStateString)
    change =! [prevStateString isEqualToString: newStateString];

  NSDebugFLog(@"change=%d",change);
  
  if (change)
    {		
      NSArray* pList=[newStateString propertyList];
      [debugSet removeAllObjects];
      if (pList && [pList isKindOfClass:[NSArray class]])
        {
          int count=[pList count];
          int i=0;
          for(i=0;i<count;i++)
            {
              [debugSet addObject:[pList objectAtIndex:i]];
            };
        };
      ASSIGN(prevStateString,newStateString);
    };
};

void
GSWApplicationSetDebugSetOption(NSString* opt)
{
  NSProcessInfo* processInfo=nil;
  processInfo=[NSProcessInfo processInfo];
  if ([opt isEqualToString:@"all"])
    {
      NSDebugFLog(@"Adding All DebugOptions");
      [[processInfo debugSet] addObject:@"dflt"];
      [[processInfo debugSet] addObject:@"GSWebFn"];
      [[processInfo debugSet] addObject:@"seriousError"];
      [[processInfo debugSet] addObject:@"exception"];
      [[processInfo debugSet] addObject:@"error"];
      [[processInfo debugSet] addObject:@"gswdync"];
      [[processInfo debugSet] addObject:@"low"];
      [[processInfo debugSet] addObject:@"gswcomponents"];
      [[processInfo debugSet] addObject:@"associations"];
      [[processInfo debugSet] addObject:@"sessions"];
      [[processInfo debugSet] addObject:@"bundles"];
      [[processInfo debugSet] addObject:@"requests"];
      [[processInfo debugSet] addObject:@"resmanager"];
      [[processInfo debugSet] addObject:@"options"];
      [[processInfo debugSet] addObject:@"info"];
      [[processInfo debugSet] addObject:@"trace"];
      /*
      //[NSObject enableDoubleReleaseCheck:YES];
      [NSPort setDebug:255];
      behavior_set_debug(1);
      */
    }
  else if ([opt isEqualToString:@"most"])
    {
      NSDebugFLog(@"Adding Most DebugOptions");
      [[processInfo debugSet] addObject:@"dflt"];
      //	  [[processInfo debugSet] addObject:@"GSWebFn"];
      [[processInfo debugSet] addObject:@"seriousError"];
      [[processInfo debugSet] addObject:@"exception"];
      [[processInfo debugSet] addObject:@"error"];
      [[processInfo debugSet] addObject:@"gswdync"];
      //	  [[processInfo debugSet] addObject:@"low"];
      [[processInfo debugSet] addObject:@"gswcomponents"];
      
      [[processInfo debugSet] addObject:@"associations"];
      //	  [[processInfo debugSet] addObject:@"sessions"];
      //	  [[processInfo debugSet] addObject:@"bundles"];
      [[processInfo debugSet] addObject:@"requests"];
      //	  [[processInfo debugSet] addObject:@"resmanager"];
      //	  [[processInfo debugSet] addObject:@"options"];
      [[processInfo debugSet] addObject:@"info"];
    }
  else
    {
      [[processInfo debugSet] addObject:opt];
    };
};

void
GSWeb_AdjustVolatileNSArgumentDomain(void)
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

  if (defaults)
    {
      NSDictionary* args = [defaults volatileDomainForName: NSArgumentDomain];
      if (args && [args count]>0)
	{
	  NSMutableDictionary* newArgs = [NSMutableDictionary dictionary];
	  NSEnumerator* argEnum = nil;
	  NSString* argKey = nil;
	  id argValue = nil;

	  argEnum=[args keyEnumerator];
	  while ((argKey = [argEnum nextObject]))
	    {
	      argValue=[args objectForKey:argKey];
	      if ([argKey hasPrefix:@"-GSW"])
		argKey = [argKey substringFromIndex:1];
	      [newArgs setObject: argValue
		       forKey: argKey];
	    }

	  NSDebugFLog(@"NSArgumentDomain: %@ Args: %@",
		      NSArgumentDomain, newArgs);

	  [defaults removeVolatileDomainForName: NSArgumentDomain];
	  [defaults setVolatileDomain: newArgs
		    forName: NSArgumentDomain];
	}
    }
}

void
GSWeb_InitializeGlobalAppDefaultOptions(void)
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

  if (!globalAppDefaultOptions)
    {
      NSDictionary* defaultsOptions = nil;
      globalAppDefaultOptions
	= [[GSWApplication bundleInfo] objectForKey:@"defaults"];

#define LOGOPT_NC(optname) \
      NSDebugFLLog(@"options", @"%s -> %@", \
		   #optname, optname[GSWebNamingConv])

#define LOGOPT(optname) \
      NSDebugFLLog(@"options", @"%s -> %@", \
		   #optname, optname)

      LOGOPT(globalAppDefaultOptions);

      NSDebugFLLog(@"options",@"GSWebNamingConv=%d",GSWebNamingConv);
      NSCAssert1((GSWebNamingConv==WONAMES_INDEX 
		  || GSWebNamingConv==GSWNAMES_INDEX),
		 @"GSWebNamingConv=%d",GSWebNamingConv);
          
      LOGOPT_NC(GSWClassName_DefaultAdaptor);
      LOGOPT_NC(GSWOPT_Adaptor);
      LOGOPT_NC(GSWOPT_AdditionalAdaptors);

      LOGOPT_NC(GSWClassName_DefaultContext);

      LOGOPT_NC(GSWOPT_Context);
      LOGOPT_NC(GSWOPT_Response);
      LOGOPT_NC(GSWOPT_Request);

      LOGOPT   (GSWOPTVALUE_ApplicationBaseURL_WO);
      LOGOPT   (GSWOPTVALUE_ApplicationBaseURL_GSWEB);
      LOGOPT_NC(GSWOPT_ApplicationBaseURL);

      LOGOPT   (GSWOPTVALUE_AutoOpenInBrowser);
      LOGOPT_NC(GSWOPT_AutoOpenInBrowser);

      LOGOPT   (GSWOPTVALUE_CGIAdaptorURL_WO);
      LOGOPT   (GSWOPTVALUE_CGIAdaptorURL_GSWEB);
      LOGOPT_NC(GSWOPT_CGIAdaptorURL);

      LOGOPT   (GSWOPTVALUE_CachingEnabled);
      LOGOPT_NC(GSWOPT_CachingEnabled);

      LOGOPT_NC(GSWComponentRequestHandlerKey);
      LOGOPT_NC(GSWOPT_ComponentRequestHandlerKey);

      LOGOPT   (GSWOPTVALUE_DebuggingEnabled);
      LOGOPT_NC(GSWOPT_DebuggingEnabled);
      LOGOPT   (GSWOPTVALUE_StatusDebuggingEnabled);
      LOGOPT_NC(GSWOPT_StatusDebuggingEnabled);

      LOGOPT_NC(GSWOPTValue_DirectActionRequestHandlerKey);
      LOGOPT_NC(GSWOPT_DirectActionRequestHandlerKey);

      LOGOPT_NC(GSWOPTValue_PingActionRequestHandlerKey);
      LOGOPT_NC(GSWOPT_PingActionRequestHandlerKey);

      LOGOPT_NC(GSWOPTValue_StreamActionRequestHandlerKey);
      LOGOPT_NC(GSWOPT_StreamActionRequestHandlerKey);

      LOGOPT_NC(GSWOPTValue_StaticResourceRequestHandlerKey);
      LOGOPT_NC(GSWOPT_StaticResourceRequestHandlerKey);

      LOGOPT_NC(GSWOPTValue_SessionStoreClassName);
      LOGOPT_NC(GSWOPT_SessionStoreClassName);

      LOGOPT_NC(GSWOPTVALUE_DirectConnectEnabled);
      LOGOPT_NC(GSWOPT_DirectConnectEnabled);

      LOGOPT   (GSWOPTVALUE_FrameworksBaseURL);
      LOGOPT_NC(GSWOPT_FrameworksBaseURL);

      LOGOPT   (GSWOPTVALUE_IncludeCommentsInResponse);
      LOGOPT_NC(GSWOPT_IncludeCommentsInResponse);

      LOGOPT   (GSWOPTVALUE_ListenQueueSize);
      LOGOPT_NC(GSWOPT_ListenQueueSize);

      LOGOPT_NC(GSWOPT_LoadFrameworks);

      LOGOPT   (GSWOPTVALUE_LifebeatEnabled);
      LOGOPT_NC(GSWOPT_LifebeatEnabled);
      LOGOPT   (GSWOPTVALUE_LifebeatDestinationHost);
      LOGOPT_NC(GSWOPT_LifebeatDestinationHost);
      LOGOPT   (GSWOPTVALUE_LifebeatDestinationPort);
      LOGOPT_NC(GSWOPT_LifebeatDestinationPort);
      LOGOPT   (GSWOPTVALUE_LifebeatInterval);
      LOGOPT_NC(GSWOPT_LifebeatInterval);

      LOGOPT   (GSWOPTVALUE_MonitorEnabled);
      LOGOPT_NC(GSWOPT_MonitorEnabled);
      LOGOPT   (GSWOPTVALUE_MonitorHost);
      LOGOPT_NC(GSWOPT_MonitorHost);

      LOGOPT   (GSWOPTVALUE_Port);
      LOGOPT_NC(GSWOPT_Port);

      LOGOPT_NC(GSWResourceRequestHandlerKey);
      LOGOPT_NC(GSWOPT_ResourceRequestHandlerKey);

      LOGOPT   (GSWOPTVALUE_SMTPHost);
      LOGOPT_NC(GSWOPT_SMTPHost);

      LOGOPT   (GSWOPTVALUE_SessionTimeOut);
      LOGOPT_NC(GSWOPT_SessionTimeOut);

      LOGOPT   (GSWOPTVALUE_DefaultUndoStackLimit);
      LOGOPT_NC(GSWOPT_DefaultUndoStackLimit);

      LOGOPT   (GSWOPTVALUE_LockDefaultEditingContext);
      LOGOPT_NC(GSWOPT_LockDefaultEditingContext);

      LOGOPT   (GSWOPTVALUE_WorkerThreadCount);
      LOGOPT_NC(GSWOPT_WorkerThreadCount);
      LOGOPT   (GSWOPTVALUE_WorkerThreadCountMin);
      LOGOPT_NC(GSWOPT_WorkerThreadCountMin);
      LOGOPT   (GSWOPTVALUE_WorkerThreadCountMax);
      LOGOPT_NC(GSWOPT_WorkerThreadCountMax);

      LOGOPT   (GSWOPTVALUE_MultiThreadEnabled);
      LOGOPT   (GSWOPT_MultiThreadEnabled);

      LOGOPT   (GSWOPTVALUE_AdaptorHost);
      LOGOPT_NC(GSWOPT_AdaptorHost);

      LOGOPT   (GSWOPTVALUE_DefaultTemplateParser);
      LOGOPT   (GSWOPTVALUE_AcceptedContentEncoding);
      LOGOPT   (GSWOPTVALUE_DisplayExceptionPages);
      LOGOPT   (GSWOPTVALUE_AllowsCacheControlHeader);

#undef LOGOPT
#undef LOGOPT_NC

      defaultsOptions = 
	[NSDictionary dictionaryWithObjectsAndKeys:
			GSWClassName_DefaultAdaptor[GSWebNamingConv],   
		      GSWOPT_Adaptor[GSWebNamingConv],
		      
		      [NSArray array],					
		      GSWOPT_AdditionalAdaptors[GSWebNamingConv],
		      
		      (GSWebNamingConv==WONAMES_INDEX 
		       ? GSWOPTVALUE_ApplicationBaseURL_WO 
		       : GSWOPTVALUE_ApplicationBaseURL_GSWEB), 
		      GSWOPT_ApplicationBaseURL[GSWebNamingConv],
		      
		      GSWClassName_DefaultContext[GSWebNamingConv],   
		      GSWOPT_Context[GSWebNamingConv],
		      
		      GSWClassName_DefaultResponse[GSWebNamingConv],   
		      GSWOPT_Response[GSWebNamingConv],
		      
		      GSWClassName_DefaultRequest[GSWebNamingConv],   
		      GSWOPT_Request[GSWebNamingConv],
		      
		      GSWOPTVALUE_AutoOpenInBrowser,			
		      GSWOPT_AutoOpenInBrowser[GSWebNamingConv],
		      
		      (GSWebNamingConv==WONAMES_INDEX 
		       ? GSWOPTVALUE_CGIAdaptorURL_WO 
		       : GSWOPTVALUE_CGIAdaptorURL_GSWEB),
		      GSWOPT_CGIAdaptorURL[GSWebNamingConv],
		      
		      GSWOPTVALUE_CachingEnabled,
		      GSWOPT_CachingEnabled[GSWebNamingConv],
		      
		      GSWOPTValue_ComponentRequestHandlerKey[GSWebNamingConv],
		      GSWOPT_ComponentRequestHandlerKey[GSWebNamingConv],
		      
		      GSWOPTVALUE_DebuggingEnabled,
		      GSWOPT_DebuggingEnabled[GSWebNamingConv],
		      
		      GSWOPTVALUE_StatusDebuggingEnabled,
		      GSWOPT_StatusDebuggingEnabled[GSWebNamingConv],
		      
		      GSWOPTValue_DirectActionRequestHandlerKey[GSWebNamingConv],
		      GSWOPT_DirectActionRequestHandlerKey[GSWebNamingConv],
		      
		      GSWOPTValue_StreamActionRequestHandlerKey[GSWebNamingConv],
		      GSWOPT_StreamActionRequestHandlerKey[GSWebNamingConv],
		      
		      GSWOPTValue_PingActionRequestHandlerKey[GSWebNamingConv],
		      GSWOPT_PingActionRequestHandlerKey[GSWebNamingConv],
		      
		      GSWOPTValue_StaticResourceRequestHandlerKey[GSWebNamingConv],
		      GSWOPT_StaticResourceRequestHandlerKey[GSWebNamingConv],
		      
		      GSWOPTValue_SessionStoreClassName[GSWebNamingConv],
		      GSWOPT_SessionStoreClassName[GSWebNamingConv],
		      
		      GSWOPTVALUE_DirectConnectEnabled,
		      GSWOPT_DirectConnectEnabled[GSWebNamingConv],
		      
		      GSWOPTVALUE_FrameworksBaseURL,
		      GSWOPT_FrameworksBaseURL[GSWebNamingConv],
		      
		      GSWOPTVALUE_IncludeCommentsInResponse,
		      GSWOPT_IncludeCommentsInResponse[GSWebNamingConv],
		      
		      GSWOPTVALUE_ListenQueueSize,
		      GSWOPT_ListenQueueSize[GSWebNamingConv],
		      
		      [NSArray array],
		      GSWOPT_LoadFrameworks[GSWebNamingConv],
		      
		      GSWOPTVALUE_LifebeatEnabled,
		      GSWOPT_LifebeatEnabled[GSWebNamingConv],
		      
		      GSWOPTVALUE_LifebeatDestinationHost,
		      GSWOPT_LifebeatDestinationHost[GSWebNamingConv],
		      
		      GSWOPTVALUE_LifebeatDestinationPort,
		      GSWOPT_LifebeatDestinationPort[GSWebNamingConv],
		      
		      GSWOPTVALUE_LifebeatInterval,
		      GSWOPT_LifebeatInterval[GSWebNamingConv],
		      
		      GSWOPTVALUE_MonitorEnabled,
		      GSWOPT_MonitorEnabled[GSWebNamingConv],
		      
		      GSWOPTVALUE_MonitorHost,
		      GSWOPT_MonitorHost[GSWebNamingConv],
		      
		      GSWOPTVALUE_Port,
		      GSWOPT_Port[GSWebNamingConv],
		      
		      GSWOPTValue_ResourceRequestHandlerKey[GSWebNamingConv],
		      GSWOPT_ResourceRequestHandlerKey[GSWebNamingConv],
		      
		      GSWOPTVALUE_SMTPHost,
		      GSWOPT_SMTPHost[GSWebNamingConv],
		      
		      GSWOPTVALUE_SessionTimeOut,
		      GSWOPT_SessionTimeOut[GSWebNamingConv],
		      
		      GSWOPTVALUE_DefaultUndoStackLimit,
		      GSWOPT_DefaultUndoStackLimit[GSWebNamingConv],
		      
		      GSWOPTVALUE_LockDefaultEditingContext,
		      GSWOPT_LockDefaultEditingContext[GSWebNamingConv],
		      
		      GSWOPTVALUE_WorkerThreadCount,
		      GSWOPT_WorkerThreadCount[GSWebNamingConv],
		      
		      GSWOPTVALUE_WorkerThreadCountMin,
		      GSWOPT_WorkerThreadCountMin[GSWebNamingConv],
		      
		      GSWOPTVALUE_WorkerThreadCountMax,
		      GSWOPT_WorkerThreadCountMax[GSWebNamingConv],
		      
		      GSWOPTVALUE_MultiThreadEnabled,
		      GSWOPT_MultiThreadEnabled,
		      
		      GSWOPTVALUE_AdaptorHost,
		      GSWOPT_AdaptorHost[GSWebNamingConv],
		      
		      GSWOPTVALUE_DefaultTemplateParser,
		      GSWOPT_DefaultTemplateParser[GSWebNamingConv],

		      GSWOPTVALUE_AcceptedContentEncoding,
		      GSWOPT_AcceptedContentEncoding[GSWebNamingConv],
		      
		      GSWOPTVALUE_DisplayExceptionPages,
		      GSWOPT_DisplayExceptionPages[GSWebNamingConv],
		      
		      GSWOPTVALUE_AllowsCacheControlHeader,
		      GSWOPT_AllowsCacheControlHeader[GSWebNamingConv],
		      
		      nil];

      NSDebugFLLog(@"options",@"_globalAppDefaultOptions=%@",
		   globalAppDefaultOptions);
      globalAppDefaultOptions
	= [NSDictionary dictionaryWithDictionary: globalAppDefaultOptions
			andDefaultEntriesFromDictionary: defaultsOptions];
      NSDebugFLLog(@"options",@"_globalAppDefaultOptions=%@",
		   globalAppDefaultOptions);
    }

  [defaults registerDefaults: globalAppDefaultOptions];
      
}

void
GSWeb_InitializeDebugOptions(void)
{
  NSArray *args = [[NSProcessInfo processInfo] arguments];
  int i=0;
  int count=[args count];
  NSString* opt=nil;
  NSString* debugOpt=nil;
  for(i=0;i<count;i++)
    {
      debugOpt=nil;
      opt=[args objectAtIndex:i];
      if ([opt hasPrefix:@"--GSWebDebug="])
	debugOpt=[opt stringByDeletingPrefix:@"--GSWebDebug="];
      else if  ([opt hasPrefix:@"-GSWebDebug="])
	debugOpt=[opt stringByDeletingPrefix:@"-GSWebDebug="];
      else if  ([opt hasPrefix:@"GSWebDebug="])
	debugOpt=[opt stringByDeletingPrefix:@"GSWebDebug="];
      if (debugOpt)
	GSWApplicationSetDebugSetOption(debugOpt);
    }
}
	      
void
GSWeb_DestroyGlobalAppDefaultOptions(void)
{
  DESTROY(globalAppDefaultOptions);
}

#define NSUSERDEFAULTS \
     (_userDefaults ? _userDefaults \
      : (_userDefaults = [NSUserDefaults standardUserDefaults]))

/* FIXME: Once setValue:forKey: is implemented in -base we should use
   use it unconditionally.  */
#ifdef GNUSTEP
#define TAKEVALUEFORKEY [self takeValue: val forKey: key]
#else
#define TAKEVALUEFORKEY [self setValue: val forKey: key]
#endif

/* These two macros are seperate for experimental reasons.  
   They may be merged later.  */
#define INIT_DFLT_OBJ(name,opt) \
     if (_dflt_init_##name == NO) { \
       id key = [NSString stringWithCString: #name]; \
       id val = [NSUSERDEFAULTS objectForKey: opt]; \
       TAKEVALUEFORKEY; }

#define INIT_DFLT_BOOL(name, opt) \
     if (_dflt_init_##name == NO) { \
       id key = [NSString stringWithCString: #name]; \
       BOOL v = [NSUSERDEFAULTS boolForKey: opt]; \
       id val = [NSNumber numberWithBool: v]; \
       TAKEVALUEFORKEY; }

#define INIT_DFLT_INT(name, opt) \
     if (_dflt_init_##name == NO) { \
       id key = [NSString stringWithCString: #name]; \
       int  v = [NSUSERDEFAULTS integerForKey: opt]; \
       id val = [NSNumber numberWithInt: v]; \
       TAKEVALUEFORKEY; }

#define INIT_DFLT_FLT(name, opt) \
     if (_dflt_init_##name == NO) { \
       id key  = [NSString stringWithCString: #name]; \
       float v = [NSUSERDEFAULTS floatForKey: opt]; \
       id val  = [NSNumber numberWithFloat: v]; \
       TAKEVALUEFORKEY; }

@implementation GSWApplication (GSWApplicationDefaults)
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
-(void)_initAdaptorsWithUserDefaults:(NSUserDefaults*)userDefaults
{
  GSWAdaptor* adaptor=nil;
  NSDictionary* args=nil;
  NSString* adaptorName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"options",@"userDefault=%@",userDefaults);
  args=[self _argsDictionaryWithUserDefaults:userDefaults];
  NSDebugMLLog(@"options",@"args=%@",args);
  adaptorName=[userDefaults objectForKey:GSWOPT_Adaptor[GSWebNamingConv]];
  NSAssert([adaptorName length]>0,@"No adaptor name");
  adaptor=[self adaptorWithName:adaptorName
                arguments:args];
  if (_adaptors)
    ASSIGN(_adaptors,[_adaptors arrayByAddingObject:adaptor]);
  else
    ASSIGN(_adaptors,[NSArray arrayWithObject:adaptor]);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSDictionary*)_argsDictionaryWithUserDefaults:(NSUserDefaults*)userDefault
{
  //VERIFY
  //OK
  NSNumber* port=nil;
  NSString* host=nil;
  NSString* adaptor=nil;
  NSNumber* workerThreadCount=nil;
  NSNumber* listenQueueSize=nil;
  NSMutableDictionary* argsDict=nil;
  LOGObjectFnStart();
  port=[(GSWAppClassDummy*)[self class] port];
  host=[(GSWAppClassDummy*)[self class] host];
  adaptor=[(GSWAppClassDummy*)[self class] adaptor];
  workerThreadCount=[[self class] workerThreadCount];
  listenQueueSize=[[self class] listenQueueSize];
  argsDict=(NSMutableDictionary*)[NSMutableDictionary dictionary];
  [argsDict addEntriesFromDictionary:[userDefault dictionaryRepresentation]];
  if (port)
    [argsDict setObject:port
              forKey:GSWOPT_Port[GSWebNamingConv]];
  if (host)
    [argsDict setObject:host
              forKey:GSWOPT_Host[GSWebNamingConv]];
  if (adaptor)
    [argsDict setObject:adaptor
              forKey:GSWOPT_Adaptor[GSWebNamingConv]];
  if (workerThreadCount)
    [argsDict setObject:workerThreadCount
              forKey:GSWOPT_WorkerThreadCount[GSWebNamingConv]];
  if (listenQueueSize)
    [argsDict setObject:listenQueueSize
              forKey:GSWOPT_ListenQueueSize[GSWebNamingConv]];
  LOGObjectFnStop();
  return argsDict;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_contextClassName = NO;
static NSString *_dflt_contextClassName = nil;
-(void)setContextClassName:(NSString*)className
{
  ASSIGNCOPY(_dflt_contextClassName, className);
  _dflt_init_contextClassName = YES;
}

//--------------------------------------------------------------------
-(NSString*)contextClassName
{
  INIT_DFLT_OBJ(contextClassName,
		GSWOPT_Context[GSWebNamingConv]);
  NSAssert([_dflt_contextClassName length],
	   @"No contextClassName");
  return _dflt_contextClassName;
}

//--------------------------------------------------------------------
static BOOL      _dflt_init_responseClassName = NO;
static NSString *_dflt_responseClassName = nil;
-(void)setResponseClassName:(NSString*)className
{
  ASSIGNCOPY(_dflt_responseClassName, className);
  _dflt_init_responseClassName = YES;
}

//--------------------------------------------------------------------
-(NSString*)responseClassName
{
  INIT_DFLT_OBJ(responseClassName,
		GSWOPT_Response[GSWebNamingConv]);
  NSAssert([_dflt_responseClassName length],
	   @"No responseClassName");
  return _dflt_responseClassName;
}

//--------------------------------------------------------------------
static BOOL      _dflt_init_requestClassName = NO;
static NSString *_dflt_requestClassName = nil;
-(void)setRequestClassName:(NSString*)className
{
  ASSIGNCOPY(_dflt_requestClassName, className);
  _dflt_init_requestClassName = YES;
}

//--------------------------------------------------------------------
-(NSString*)requestClassName
{
  INIT_DFLT_OBJ(requestClassName,
		GSWOPT_Request[GSWebNamingConv]);
  NSAssert([_dflt_requestClassName length],
	   @"No requestClassName");
  return _dflt_requestClassName;
}

@end


//====================================================================
@implementation GSWApplication (UserDefaults)

//--------------------------------------------------------------------
//TODO: take values from application ?
static BOOL     _dflt_init_loadFrameworks = NO;
static NSArray *_dflt_loadFrameworks = nil;
+(NSArray*)loadFrameworks
{
  INIT_DFLT_OBJ(loadFrameworks,
		GSWOPT_LoadFrameworks[GSWebNamingConv]);
  return _dflt_loadFrameworks;
};

//--------------------------------------------------------------------
+(void)setLoadFrameworks:(NSArray*)frameworks
{
  ASSIGNCOPY(_dflt_loadFrameworks, frameworks);
  _dflt_init_loadFrameworks = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_debuggingEnabled = NO;
static BOOL _dflt_debuggingEnabled = NO;
+(BOOL)isDebuggingEnabled
{
  INIT_DFLT_BOOL(debuggingEnabled,
		 GSWOPT_DebuggingEnabled[GSWebNamingConv]);
  return _dflt_debuggingEnabled;
};

//--------------------------------------------------------------------
+(void)setDebuggingEnabled:(BOOL)flag
{
  _dflt_debuggingEnabled = flag;
  _dflt_init_debuggingEnabled = YES;
};

//--------------------------------------------------------------------
//NDFN
static BOOL _dflt_init_statusDebuggingEnabled = NO;
static BOOL _dflt_statusDebuggingEnabled = NO;
+(BOOL)isStatusDebuggingEnabled
{
  INIT_DFLT_BOOL(statusDebuggingEnabled,
		 GSWOPT_StatusDebuggingEnabled[GSWebNamingConv]);
  return _dflt_statusDebuggingEnabled;
};

//--------------------------------------------------------------------
//NDFN
+(void)setStatusDebuggingEnabled:(BOOL)flag
{
  _dflt_statusDebuggingEnabled = flag;
  _dflt_init_statusDebuggingEnabled = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_autoOpenInBrowser = NO;
static BOOL _dflt_autoOpenInBrowser = NO;
+(BOOL)autoOpenInBrowser
{
  INIT_DFLT_BOOL(autoOpenInBrowser,
		 GSWOPT_AutoOpenInBrowser[GSWebNamingConv]);
  return _dflt_autoOpenInBrowser;
};

//--------------------------------------------------------------------
+(void)setAutoOpenInBrowser:(BOOL)flag
{
  _dflt_autoOpenInBrowser = flag;
  _dflt_init_autoOpenInBrowser = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_directConnectEnabled = NO;
static BOOL _dflt_directConnectEnabled = NO;
+(BOOL)isDirectConnectEnabled
{
  INIT_DFLT_BOOL(directConnectEnabled,
		 GSWOPT_DirectConnectEnabled[GSWebNamingConv]);
  return _dflt_directConnectEnabled;
};

//--------------------------------------------------------------------
+(void)setDirectConnectEnabled:(BOOL)flag
{
  _dflt_directConnectEnabled = flag;
  _dflt_init_directConnectEnabled = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_CGIAdaptorURL = NO;
static NSString *_dflt_CGIAdaptorURL = nil;
+(NSString*)cgiAdaptorURL
{
  INIT_DFLT_OBJ(CGIAdaptorURL,
		GSWOPT_CGIAdaptorURL[GSWebNamingConv]);
  if ([_dflt_CGIAdaptorURL length] == 0)
    {
      [self setCGIAdaptorURL: @"http://localhost/cgi-bin/GSWeb"];
    }
  return _dflt_CGIAdaptorURL;
};

//--------------------------------------------------------------------
+(void)setCGIAdaptorURL:(NSString*)url
{
  ASSIGNCOPY(_dflt_CGIAdaptorURL, url);
  _dflt_init_CGIAdaptorURL = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_cachingEnabled = NO;
static BOOL _dflt_cachingEnabled = NO;
+(BOOL)isCachingEnabled
{
  INIT_DFLT_BOOL(cachingEnabled,
		 GSWOPT_CachingEnabled[GSWebNamingConv]);
  return _dflt_cachingEnabled;
};

//--------------------------------------------------------------------
+(void)setCachingEnabled:(BOOL)flag
{
  _dflt_cachingEnabled = flag;
  _dflt_init_cachingEnabled = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_applicationBaseURL = NO;
static NSString *_dflt_applicationBaseURL = nil;
+(NSString*)applicationBaseURL
{
  LOGClassFnStart();
  INIT_DFLT_OBJ(applicationBaseURL,
		GSWOPT_ApplicationBaseURL[GSWebNamingConv]);
  NSDebugMLLog(@"application",@"url=%@", _dflt_applicationBaseURL);
  LOGClassFnStop();
  return _dflt_applicationBaseURL;
};

//--------------------------------------------------------------------
+(void)setApplicationBaseURL:(NSString*)baseURL
{
  ASSIGNCOPY(_dflt_applicationBaseURL, baseURL);
  _dflt_init_applicationBaseURL = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_frameworksBaseURL = NO;
static NSString *_dflt_frameworksBaseURL = nil;
+(NSString*)frameworksBaseURL
{
  INIT_DFLT_OBJ(frameworksBaseURL,
		GSWOPT_FrameworksBaseURL[GSWebNamingConv]);
  return _dflt_frameworksBaseURL;
};

//--------------------------------------------------------------------
+(void)setFrameworksBaseURL:(NSString*)aString
{
  ASSIGNCOPY(_dflt_frameworksBaseURL, aString);
  _dflt_init_frameworksBaseURL = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_outputPath = NO;
static NSString *_dflt_outputPath = nil;
+(NSString*)outputPath
{
  INIT_DFLT_OBJ(outputPath,
		GSWOPT_OutputPath[GSWebNamingConv]);
  return _dflt_outputPath;
};

//--------------------------------------------------------------------
+(void)setOutputPath:(NSString*)aString
{
  ASSIGNCOPY(_dflt_outputPath, aString);
  _dflt_init_outputPath = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_recordingPath = NO;
static NSString *_dflt_recordingPath = nil;
+(NSString*)recordingPath
{
  INIT_DFLT_OBJ(recordingPath,
		GSWOPT_RecordingPath[GSWebNamingConv]);
  return _dflt_recordingPath;
};

//--------------------------------------------------------------------
+(void)setRecordingPath:(NSString*)aPath
{
  ASSIGNCOPY(_dflt_recordingPath, aPath);
  _dflt_init_recordingPath = YES;
};

//--------------------------------------------------------------------
static BOOL     _dflt_init_projectSearchPath = NO;
static NSArray *_dflt_projectSearchPath = nil;
+(NSArray*)projectSearchPath
{
  LOGClassFnStart();

  INIT_DFLT_OBJ(projectSearchPath,
		GSWOPT_ProjectSearchPath);

  NSDebugMLLog(@"application",@"projectSearchPath:%@",
	       _dflt_projectSearchPath);

  if (!_dflt_projectSearchPath)
    {
      //TODO dirty hack here !
      NSBundle* mainBundle=[self mainBundle];
      NSString* bundlePath=[mainBundle bundlePath];
      NSString* path=[bundlePath stringGoodPath];
      NSArray* projectSearchPath=nil;

      NSAssert(mainBundle,@"No mainBundle");
      NSAssert(bundlePath,@"No bundlePath");
      NSAssert(path,@"No path");
      NSDebugMLLog(@"application",@"bundlePath:%@",bundlePath);
      NSDebugMLLog(@"application",@"path:%@",path);
      NSDebugMLLog(@"application",@"mainBundle:%@",mainBundle);
      path=[path stringByDeletingLastPathComponent];
      NSDebugMLLog(@"application",@"path:%@",path);
      projectSearchPath=[NSArray arrayWithObject:path];
      [self setProjectSearchPath: projectSearchPath];
    };

  NSDebugMLLog(@"application",@"projectSearchPath:%@",
	       _dflt_projectSearchPath);
  LOGClassFnStop();
  return _dflt_projectSearchPath;
};

//--------------------------------------------------------------------
+(void)setProjectSearchPath:(NSArray*)paths
{
  ASSIGNCOPY(_dflt_projectSearchPath, paths);
  _dflt_init_projectSearchPath = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_lifebeatEnabled = NO;
static BOOL _dflt_lifebeatEnabled = NO;
+(BOOL)isLifebeatEnabled
{
  INIT_DFLT_BOOL(lifebeatEnabled,
		 GSWOPT_LifebeatEnabled[GSWebNamingConv]);
  return _dflt_lifebeatEnabled;
};

//--------------------------------------------------------------------
+(void)setLifebeatEnabled:(BOOL)flag
{
  _dflt_lifebeatEnabled = flag;
  _dflt_init_lifebeatEnabled = YES;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_lifebeatDestinationHost = NO;
static NSString *_dflt_lifebeatDestinationHost = nil;
+(NSString*)lifebeatDestinationHost
{
  INIT_DFLT_OBJ(lifebeatDestinationHost,
		GSWOPT_LifebeatDestinationHost[GSWebNamingConv]);
  return _dflt_lifebeatDestinationHost;
};

//--------------------------------------------------------------------
+(void)setLifebeatDestinationHost:(NSString*)host
{
  ASSIGNCOPY(_dflt_lifebeatDestinationHost, host);
  _dflt_init_lifebeatDestinationHost = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_lifebeatDestinationPort = NO;
static int  _dflt_lifebeatDestinationPort = 0;
+(int)lifebeatDestinationPort
{
  INIT_DFLT_INT(lifebeatDestinationPort,
		GSWOPT_LifebeatDestinationPort[GSWebNamingConv]);
  return _dflt_lifebeatDestinationPort;
};

//--------------------------------------------------------------------
+(void)setLifebeatDestinationPort:(int)port
{
  _dflt_lifebeatDestinationPort = port;
  _dflt_init_lifebeatDestinationPort = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_lifebeatInterval = NO;
static NSTimeInterval _dflt_lifebeatInterval = 0.0;
+(NSTimeInterval)lifebeatInterval
{
  LOGClassFnStart();
  INIT_DFLT_FLT(lifebeatInterval,
		GSWOPT_LifebeatInterval[GSWebNamingConv]);
  LOGClassFnStop();
  return _dflt_lifebeatInterval;
};

//--------------------------------------------------------------------
+(void)setLifebeatInterval:(NSTimeInterval)interval
{
  LOGClassFnStart();
  _dflt_lifebeatInterval = interval;
  _dflt_init_lifebeatInterval = YES;
  LOGClassFnStop();
};

//--------------------------------------------------------------------
static BOOL _dflt_init_monitorEnabled = NO;
static BOOL _dflt_monitorEnabled = NO;
+(BOOL)isMonitorEnabled
{
  INIT_DFLT_BOOL(monitorEnabled,
		 GSWOPT_MonitorEnabled[GSWebNamingConv]);
  return _dflt_monitorEnabled;
};

//--------------------------------------------------------------------
+(void)setMonitorEnabled:(BOOL)flag
{
  _dflt_monitorEnabled = flag;
  _dflt_init_monitorEnabled = YES;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_monitorHost = NO;
static NSString *_dflt_monitorHost = nil;
+(NSString*)monitorHost
{
  INIT_DFLT_OBJ(monitorHost,
		GSWOPT_MonitorHost[GSWebNamingConv]);
  return _dflt_monitorHost;
};

//--------------------------------------------------------------------
+(void)setMonitorHost:(NSString*)hostName
{
  ASSIGNCOPY(_dflt_monitorHost, hostName);
  _dflt_init_monitorHost = YES;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_SMTPHost = NO;
static NSString *_dflt_SMTPHost = nil;
+(NSString*)SMTPHost
{
  INIT_DFLT_OBJ(SMTPHost,
		GSWOPT_SMTPHost[GSWebNamingConv]);
  return _dflt_SMTPHost;
};

//--------------------------------------------------------------------
+(void)setSMTPHost:(NSString*)hostName
{
  ASSIGNCOPY(_dflt_SMTPHost, hostName);
  _dflt_init_SMTPHost = YES;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_adaptor = NO;
static NSString *_dflt_adaptor = nil;
+(NSString*)adaptor
{
  INIT_DFLT_OBJ(adaptor,
		GSWOPT_Adaptor[GSWebNamingConv]);
  return _dflt_adaptor;
};

//--------------------------------------------------------------------
+(void)setAdaptor:(NSString*)adaptorName
{
  ASSIGNCOPY(_dflt_adaptor, adaptorName);
  _dflt_init_adaptor = YES;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_port = NO;
static NSNumber *_dflt_port = nil;
+(NSNumber*)port
{
  INIT_DFLT_OBJ(port,
		GSWOPT_Port[GSWebNamingConv]);
  return _dflt_port;
};

//--------------------------------------------------------------------
+(void)setPort:(NSNumber*)port
{
  ASSIGNCOPY(_dflt_port, port);
  _dflt_init_port = YES;
  //TODO
  /*
	[[GSWApp adaptors] makeObjectsPerformSelector:@selector(setPort:)
	withObject:port_];
   */
};

//--------------------------------------------------------------------
+(int)intPort
{
  return [[self port]intValue];
};

//--------------------------------------------------------------------
+(void)setIntPort:(int)port
{
  [self setPort:[NSNumber numberWithInt:port]];
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_host= NO;
static NSString *_dflt_host = nil;
+(NSString*)host
{
  INIT_DFLT_OBJ(host,
		GSWOPT_Host[GSWebNamingConv]);
  return _dflt_host;
};

//--------------------------------------------------------------------
+(void)setHost:(NSString*)host
{
  ASSIGNCOPY(_dflt_host, host);
  _dflt_init_host = YES;
  //TODO
  /*
    [[GSWApp adaptors] makeObjectsPerformSelector:@selector(setHost:)
	withObject:host_];
  */
};

//--------------------------------------------------------------------
static BOOL _dflt_init_listenQueueSize  = NO;
static id   _dflt_listenQueueSize = nil;
+(id)listenQueueSize
{
  INIT_DFLT_OBJ(listenQueueSize,
		GSWOPT_ListenQueueSize[GSWebNamingConv]);
  return _dflt_listenQueueSize;
};

//--------------------------------------------------------------------
+(void)setListenQueueSize:(id)listenQueueSize
{
  ASSIGN(_dflt_listenQueueSize, listenQueueSize);
  _dflt_init_listenQueueSize = YES;
  [[GSWApp adaptors] makeObjectsPerformSelector:@selector(setListenQueueSize:)
                     withObject:listenQueueSize];
};

//--------------------------------------------------------------------
// [deprecated]
static BOOL _dflt_init_workerThreadCount  = NO;
static id   _dflt_workerThreadCount = nil;
+(id)workerThreadCount
{
  INIT_DFLT_OBJ(workerThreadCount,
		GSWOPT_WorkerThreadCount[GSWebNamingConv]);
  return _dflt_workerThreadCount;
};

//--------------------------------------------------------------------
// [deprecated]
+(void)setWorkerThreadCount:(id)workerThreadCount
{
  ASSIGN(_dflt_workerThreadCount, workerThreadCount);
  _dflt_init_workerThreadCount = YES;
  [[GSWApp adaptors] makeObjectsPerformSelector:@selector(setWorkerThreadCount:)
                     withObject:workerThreadCount];
};

//--------------------------------------------------------------------
static BOOL _dflt_init_workerThreadCountMin = NO;
static id   _dflt_workerThreadCountMin = nil;
+(id)workerThreadCountMin
{
  INIT_DFLT_OBJ(workerThreadCountMin,
		GSWOPT_WorkerThreadCountMin[GSWebNamingConv]);
  return _dflt_workerThreadCountMin;
};

//--------------------------------------------------------------------
+(void)setWorkerThreadCountMin:(id)workerThreadCount
{
  ASSIGN(_dflt_workerThreadCountMin, workerThreadCount);
  _dflt_init_workerThreadCountMin = YES;
  [[GSWApp adaptors] makeObjectsPerformSelector:@selector(setWorkerThreadCountMin:)
                     withObject:workerThreadCount];
};

//--------------------------------------------------------------------
static BOOL _dflt_init_workerThreadCountMax = NO;
static id   _dflt_workerThreadCountMax = nil;
+(id)workerThreadCountMax
{
  INIT_DFLT_OBJ(workerThreadCountMax,
		GSWOPT_WorkerThreadCountMax[GSWebNamingConv]);
  return _dflt_workerThreadCountMax;
};

//--------------------------------------------------------------------
+(void)setWorkerThreadCountMax:(id)workerThreadCount
{
  ASSIGN(_dflt_workerThreadCountMax, workerThreadCount);
  _dflt_init_workerThreadCountMax = YES;
  [[GSWApp adaptors] makeObjectsPerformSelector:@selector(setWorkerThreadCountMax:)
                     withObject:workerThreadCount];
};

//--------------------------------------------------------------------
static BOOL     _dflt_init_additionalAdaptors = NO;
static NSArray *_dflt_additionalAdaptors = nil;
+(NSArray*)additionalAdaptors
{
  INIT_DFLT_OBJ(additionalAdaptors,
		GSWOPT_AdditionalAdaptors[GSWebNamingConv]);
  return _dflt_additionalAdaptors;
};

//--------------------------------------------------------------------
+(void)setAdditionalAdaptors:(NSArray*)adaptorsArray
{
  ASSIGNCOPY(_dflt_additionalAdaptors, adaptorsArray);
  _dflt_init_additionalAdaptors = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_includeCommentsInResponses = NO;
static BOOL _dflt_includeCommentsInResponses = NO;
+(BOOL)includeCommentsInResponses
{
  INIT_DFLT_BOOL(includeCommentsInResponses,
		 GSWOPT_IncludeCommentsInResponse[GSWebNamingConv]);
  return _dflt_includeCommentsInResponses;
};

//--------------------------------------------------------------------
+(void)setIncludeCommentsInResponses:(BOOL)flag
{
  _dflt_includeCommentsInResponses = flag;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_componentRequestHandlerKey = NO;
static NSString *_dflt_componentRequestHandlerKey = nil;
+(NSString*)componentRequestHandlerKey
{
  INIT_DFLT_OBJ(componentRequestHandlerKey,
		GSWOPT_ComponentRequestHandlerKey[GSWebNamingConv]);
  return _dflt_componentRequestHandlerKey;
};

//--------------------------------------------------------------------
+(void)setComponentRequestHandlerKey:(NSString*)aKey
{
  ASSIGNCOPY(_dflt_componentRequestHandlerKey, aKey);
  _dflt_init_componentRequestHandlerKey = YES;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_directActionRequestHandlerKey = NO;
static NSString *_dflt_directActionRequestHandlerKey;
+(NSString*)directActionRequestHandlerKey
{
  INIT_DFLT_OBJ(directActionRequestHandlerKey,
		GSWOPT_DirectActionRequestHandlerKey[GSWebNamingConv]);
  return _dflt_directActionRequestHandlerKey;
};

//--------------------------------------------------------------------
+(void)setDirectActionRequestHandlerKey:(NSString*)aKey
{
  ASSIGNCOPY(_dflt_directActionRequestHandlerKey, aKey);
  _dflt_init_directActionRequestHandlerKey = YES;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_resourceRequestHandlerKey = NO;
static NSString *_dflt_resourceRequestHandlerKey = nil;
+(NSString*)resourceRequestHandlerKey
{
  INIT_DFLT_OBJ(resourceRequestHandlerKey,
		GSWOPT_ResourceRequestHandlerKey[GSWebNamingConv]);
  return _dflt_resourceRequestHandlerKey;
};

//--------------------------------------------------------------------
+(void)setResourceRequestHandlerKey:(NSString*)aKey
{
  ASSIGNCOPY(_dflt_resourceRequestHandlerKey, aKey);
  _dflt_init_resourceRequestHandlerKey = YES;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_streamActionRequestHandlerKey = NO;
static NSString *_dflt_streamActionRequestHandlerKey = nil;
+(NSString*)streamActionRequestHandlerKey
{
  INIT_DFLT_OBJ(streamActionRequestHandlerKey,
		GSWOPT_StreamActionRequestHandlerKey[GSWebNamingConv]);
  return _dflt_streamActionRequestHandlerKey;
};

//--------------------------------------------------------------------
+(void)setStreamActionRequestHandlerKey:(NSString*)aKey
{
  ASSIGNCOPY(_dflt_streamActionRequestHandlerKey, aKey);
  _dflt_init_streamActionRequestHandlerKey = YES;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_pingActionRequestHandlerKey = NO;
static NSString *_dflt_pingActionRequestHandlerKey = nil;
+(NSString*)pingActionRequestHandlerKey
{
  INIT_DFLT_OBJ(pingActionRequestHandlerKey,
		GSWOPT_PingActionRequestHandlerKey[GSWebNamingConv]);
  return _dflt_pingActionRequestHandlerKey;
};

//--------------------------------------------------------------------
+(void)setPingActionRequestHandlerKey:(NSString*)aKey
{
  ASSIGNCOPY(_dflt_pingActionRequestHandlerKey, aKey);
  _dflt_init_pingActionRequestHandlerKey = YES;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_staticResourceRequestHandlerKey = NO;
static NSString *_dflt_staticResourceRequestHandlerKey = nil;
+(NSString*)staticResourceRequestHandlerKey
{
  INIT_DFLT_OBJ(staticResourceRequestHandlerKey,
		GSWOPT_StaticResourceRequestHandlerKey[GSWebNamingConv]);
  return _dflt_staticResourceRequestHandlerKey;
};

//--------------------------------------------------------------------
+(void)setStaticResourceRequestHandlerKey:(NSString*)aKey
{
  ASSIGNCOPY(_dflt_staticResourceRequestHandlerKey, aKey);
  _dflt_init_staticResourceRequestHandlerKey = YES;
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

//--------------------------------------------------------------------
static BOOL      _dflt_init_resourceManagerClassName = NO;
static NSString *_dflt_resourceManagerClassName = nil;
+(NSString*)resourceManagerClassName
{
  INIT_DFLT_OBJ(resourceManagerClassName,
		GSWOPT_ResourceManagerClassName[GSWebNamingConv]);
  return _dflt_resourceManagerClassName;
};

//--------------------------------------------------------------------
+(void)setResourceManagerClassName:(NSString*)name
{
  ASSIGNCOPY(_dflt_resourceManagerClassName, name);
  _dflt_init_resourceManagerClassName = YES;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_statisticsStoreClassName = NO;
static NSString *_dflt_statisticsStoreClassName = nil;
+(NSString*)statisticsStoreClassName
{
  INIT_DFLT_OBJ(statisticsStoreClassName,
		GSWOPT_StatisticsStoreClassName[GSWebNamingConv]);
  return _dflt_statisticsStoreClassName;
};

//--------------------------------------------------------------------
+(void)setStatisticsStoreClassName:(NSString*)name
{
  ASSIGNCOPY(_dflt_statisticsStoreClassName, name);
  _dflt_init_statisticsStoreClassName = YES;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_sessionStoreClassName = NO;
static NSString *_dflt_sessionStoreClassName = nil;
+(NSString*)sessionStoreClassName
{
  INIT_DFLT_OBJ(sessionStoreClassName,
		GSWOPT_SessionStoreClassName[GSWebNamingConv]);
  return _dflt_sessionStoreClassName;
};

//--------------------------------------------------------------------
+(void)setSessionStoreClassName:(NSString*)name
{
  ASSIGNCOPY(_dflt_sessionStoreClassName, name);
  _dflt_init_sessionStoreClassName = YES;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_recordingClassName = NO;
static NSString *_dflt_recordingClassName = nil;
+(NSString*)recordingClassName
{
  INIT_DFLT_OBJ(recordingClassName,
		GSWOPT_RecordingClassName[GSWebNamingConv]);
  return _dflt_recordingClassName;
};

//--------------------------------------------------------------------
+(void)setRecordingClassName:(NSString*)name
{
  ASSIGNCOPY(_dflt_recordingClassName, name);
  _dflt_init_recordingClassName = YES;
};

//--------------------------------------------------------------------
+(Class)recordingClass
{
  Class recordingClass = Nil;
  NSString* recordingClassName = nil;

  LOGClassFnStart();

  recordingClassName = [self recordingClassName];
  if (!recordingClassName)
    recordingClassName=GSWClassName_DefaultRecording[GSWebNamingConv];
  recordingClass=NSClassFromString(recordingClassName);

  NSAssert1(recordingClass,@"No recording class named '%@'",
            recordingClassName);

  LOGClassFnStop();

  return recordingClass;
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_sessionTimeOut = NO;
static NSNumber *_dflt_sessionTimeOut = nil;
+(void)setSessionTimeOut:(NSNumber*)aTimeOut
{
  LOGClassFnStart();
  NSDebugMLLog(@"sessions",@"aTimeOut=%@",aTimeOut);
  ASSIGNCOPY(_dflt_sessionTimeOut, aTimeOut);
  _dflt_init_sessionTimeOut = YES;
  LOGClassFnStop();
};

//--------------------------------------------------------------------
+(NSNumber*)sessionTimeOut
{
  LOGClassFnStart();
  INIT_DFLT_OBJ(sessionTimeOut,
		GSWOPT_SessionTimeOut[GSWebNamingConv]);
  NSDebugMLLog(@"sessions",@"sessionTimeOut=%@",
	       _dflt_sessionTimeOut);
  LOGClassFnStop();
  return _dflt_sessionTimeOut;
};

//--------------------------------------------------------------------
+(void)setSessionTimeOutValue:(NSTimeInterval)aTimeOutValue
{
  LOGClassFnStart();
  NSDebugMLLog(@"sessions",@"aTimeOutValue=%f",aTimeOutValue);
  [self setSessionTimeOut: [NSNumber numberWithDouble: aTimeOutValue]];
  LOGClassFnStop();
};

//--------------------------------------------------------------------
+(NSTimeInterval)sessionTimeOutValue
{
  id sessionTimeOut=nil;
  LOGClassFnStart();
  sessionTimeOut=[self sessionTimeOut];
  NSDebugMLLog(@"sessions",@"sessionTimeOut=%@",sessionTimeOut);
  LOGClassFnStop();
  return (NSTimeInterval)[sessionTimeOut doubleValue];
};

//--------------------------------------------------------------------
static BOOL _dflt_init_defaultUndoStackLimit = NO;
static int _dflt_defaultUndoStackLimit = 0;
+(void)setDefaultUndoStackLimit:(int)limit
{
  LOGClassFnStart();
  _dflt_defaultUndoStackLimit = limit;
  _dflt_init_defaultUndoStackLimit = YES;
  LOGClassFnStop();
};

+(int)defaultUndoStackLimit
{
  LOGClassFnStart();
  INIT_DFLT_INT(defaultUndoStackLimit,
		GSWOPT_DefaultUndoStackLimit[GSWebNamingConv]);
  LOGClassFnStop();
  return _dflt_defaultUndoStackLimit;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_lockDefaultEditingContext = NO;
static BOOL _dflt_lockDefaultEditingContext = NO;
+(BOOL)_lockDefaultEditingContext
{
  INIT_DFLT_BOOL(lockDefaultEditingContext,
		 GSWOPT_LockDefaultEditingContext[GSWebNamingConv]);
  return _dflt_lockDefaultEditingContext;
};

//--------------------------------------------------------------------
+(void)_setLockDefaultEditingContext:(BOOL)flag
{
  _dflt_lockDefaultEditingContext = flag;
  _dflt_init_lockDefaultEditingContext = YES;
};

//--------------------------------------------------------------------
//NDFN
static BOOL      _dflt_init_debugSetConfigFilePath = NO;
static NSString *_dflt_debugSetConfigFilePath = nil;
+(NSString*)debugSetConfigFilePath
{
  INIT_DFLT_OBJ(debugSetConfigFilePath,
		GSWOPT_DebugSetConfigFilePath);
  return _dflt_debugSetConfigFilePath;
};

//--------------------------------------------------------------------
+(void)setDebugSetConfigFilePath:(NSString*)debugSetConfigFilePath
{
  ASSIGNCOPY(_dflt_debugSetConfigFilePath, debugSetConfigFilePath);
  _dflt_init_debugSetConfigFilePath = YES;
};

+(NSString*)saveResponsesPath
{
  NSAssert(NO,@"+saveResponsesPath is now obsolete. Use +recordingPath");
  return nil;
};

//--------------------------------------------------------------------
+(void)setSaveResponsesPath:(NSString*)saveResponsesPath
{
  NSAssert(NO,
	   @"+setSaveResponsesPath: is now obsolete. Use +setRecordingPath:");
};

//--------------------------------------------------------------------
static BOOL      _dflt_init_acceptedContentEncoding = NO;
static NSString *_dflt_acceptedContentEncoding = nil;
+(NSString*)acceptedContentEncoding
{
  INIT_DFLT_OBJ(acceptedContentEncoding,
		GSWOPT_AcceptedContentEncoding[GSWebNamingConv]);
  return _dflt_acceptedContentEncoding;
};

//--------------------------------------------------------------------
+(NSArray*)acceptedContentEncodingArray
{
  NSArray* acceptedContentEncodingArray=nil;
  NSString* acceptedContentEncoding=[self acceptedContentEncoding];
  acceptedContentEncodingArray=[acceptedContentEncoding componentsSeparatedByString:@";"];
  return acceptedContentEncodingArray;
};

//--------------------------------------------------------------------
+(void)setAcceptedContentEncoding:(NSString*)acceptedContentEncoding
{
  ASSIGNCOPY(_dflt_acceptedContentEncoding, acceptedContentEncoding);
  _dflt_init_acceptedContentEncoding = YES;
};


//--------------------------------------------------------------------
static BOOL      _dflt_init_defaultTemplateParser = NO;
static NSString *_dflt_defaultTemplateParser = nil;
/** Returns the default template parser option **/
+(NSString*)defaultTemplateParser
{
  INIT_DFLT_OBJ(defaultTemplateParser,
		GSWOPT_DefaultTemplateParser[GSWebNamingConv]);
  return _dflt_defaultTemplateParser;
};

//--------------------------------------------------------------------
+(void)setDefaultTemplateParser:(NSString*)defaultTemplateParser
{
  ASSIGNCOPY(_dflt_defaultTemplateParser, defaultTemplateParser);
  _dflt_init_defaultTemplateParser = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_defaultDisplayExceptionPages = NO;
static BOOL _dflt_defaultDisplayExceptionPages = NO;
+(BOOL)defaultDisplayExceptionPages
{
  INIT_DFLT_BOOL(defaultDisplayExceptionPages,
		 GSWOPT_DisplayExceptionPages[GSWebNamingConv]);
  return _dflt_defaultDisplayExceptionPages;
};

//--------------------------------------------------------------------
+(void)setDefaultDisplayExceptionPages:(BOOL)flag
{
  _dflt_defaultDisplayExceptionPages = flag;
  _dflt_init_defaultDisplayExceptionPages = YES;
};

//--------------------------------------------------------------------
static BOOL _dflt_init_allowsCacheControlHeader = NO;
static BOOL _dflt_allowsCacheControlHeader = NO;
+(BOOL)_allowsCacheControlHeader
{
  INIT_DFLT_BOOL(allowsCacheControlHeader,
		 GSWOPT_AllowsCacheControlHeader[GSWebNamingConv]);
  return _dflt_allowsCacheControlHeader;
};

//--------------------------------------------------------------------
+(void)_setAllowsCacheControlHeader:(BOOL)flag
{
  _dflt_allowsCacheControlHeader = flag;
  _dflt_init_allowsCacheControlHeader = YES;
};

@end
