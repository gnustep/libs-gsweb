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

NSDictionary* globalAppDefaultOptions = nil;
BOOL WOStrictFlag=NO;

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

#ifndef NDEBUG
void GSWeb_ApplicationDebugSetChange()
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
#endif
void GSWApplicationSetDebugSetOption(NSString* opt)
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
      NSDebugFLLog(@"options",
		   @"globalAppDefaultOptions=%@", globalAppDefaultOptions);

      NSDebugFLLog(@"options",@"GSWebNamingConv=%d",GSWebNamingConv);
      NSCAssert1((GSWebNamingConv==WONAMES_INDEX 
		  || GSWebNamingConv==GSWNAMES_INDEX),
		 @"GSWebNamingConv=%d",GSWebNamingConv);
          
      NSDebugFLLog(@"options", @"GSWClassName_DefaultAdaptor -> %@",
		   GSWClassName_DefaultAdaptor[GSWebNamingConv]);
      NSDebugFLLog(@"options", @"GSWOPT_Adaptor -> %@",
		   GSWOPT_Adaptor[GSWebNamingConv]);
      NSDebugFLLog(@"options", @"GSWOPT_AdditionalAdaptors -> %@",
		   GSWOPT_AdditionalAdaptors[GSWebNamingConv]);
      NSDebugFLLog(@"options", @"GSWClassName_DefaultContext -> %@",
		   GSWClassName_DefaultContext[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPT_Context -> %@",
		   GSWOPT_Context[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPT_Response -> %@",
		   GSWOPT_Response[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPT_Request -> %@",
		   GSWOPT_Request[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTVALUE_ApplicationBaseURL_WO -> %@",
		   GSWOPTVALUE_ApplicationBaseURL_WO);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_ApplicationBaseURL_GSWEB -> %@",
		   GSWOPTVALUE_ApplicationBaseURL_GSWEB);
      NSDebugFLLog(@"options",@"GSWOPT_ApplicationBaseURL -> %@",
		   GSWOPT_ApplicationBaseURL[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_AutoOpenInBrowser -> %@",
		   GSWOPTVALUE_AutoOpenInBrowser);
      NSDebugFLLog(@"options",@"GSWOPT_AutoOpenInBrowser -> %@",
		   GSWOPT_AutoOpenInBrowser[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_CGIAdaptorURL_WO -> %@",
		   GSWOPTVALUE_CGIAdaptorURL_WO);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_CGIAdaptorURL_GSWEB -> %@",
		   GSWOPTVALUE_CGIAdaptorURL_GSWEB);
      NSDebugFLLog(@"options",@"GSWOPT_CGIAdaptorURL -> %@",
		   GSWOPT_CGIAdaptorURL[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_CachingEnabled -> %@",
		   GSWOPTVALUE_CachingEnabled);
      NSDebugFLLog(@"options",@"GSWOPT_CachingEnabled -> %@",
		   GSWOPT_CachingEnabled[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWComponentRequestHandlerKey -> %@",
		   GSWComponentRequestHandlerKey[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPT_ComponentRequestHandlerKey -> %@",
		   GSWOPT_ComponentRequestHandlerKey[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_DebuggingEnabled -> %@",
		   GSWOPTVALUE_DebuggingEnabled);
      NSDebugFLLog(@"options",@"GSWOPT_DebuggingEnabled -> %@",
		   GSWOPT_DebuggingEnabled[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_StatusDebuggingEnabled -> %@",
		   GSWOPTVALUE_StatusDebuggingEnabled);
      NSDebugFLLog(@"options",@"GSWOPT_StatusDebuggingEnabled -> %@",
		   GSWOPT_StatusDebuggingEnabled[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTValue_DirectActionRequestHandlerKey -> %@",
		   GSWOPTValue_DirectActionRequestHandlerKey[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPT_DirectActionRequestHandlerKey -> %@",
		   GSWOPT_DirectActionRequestHandlerKey[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTValue_PingActionRequestHandlerKey -> %@",
		   GSWOPTValue_PingActionRequestHandlerKey[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPT_PingActionRequestHandlerKey -> %@",
		   GSWOPT_PingActionRequestHandlerKey[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPT_StreamActionRequestHandlerKey -> %@",
		   GSWOPT_StreamActionRequestHandlerKey[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPT_StreamActionRequestHandlerKey -> %@",
		   GSWOPT_StreamActionRequestHandlerKey[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTValue_StaticResourceRequestHandlerKey -> %@",
		   GSWOPTValue_StaticResourceRequestHandlerKey[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPT_StaticResourceRequestHandlerKey -> %@",
		   GSWOPT_StaticResourceRequestHandlerKey[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTValue_SessionStoreClassName -> %@",
		   GSWOPTValue_SessionStoreClassName[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPT_SessionStoreClassName -> %@",
		   GSWOPT_SessionStoreClassName[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_DirectConnectEnabled -> %@",
		   GSWOPTVALUE_DirectConnectEnabled);
      NSDebugFLLog(@"options",@"GSWOPT_DirectConnectEnabled -> %@",
		   GSWOPT_DirectConnectEnabled[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_FrameworksBaseURL -> %@",
		   GSWOPTVALUE_FrameworksBaseURL);
      NSDebugFLLog(@"options",@"GSWOPT_FrameworksBaseURL -> %@",
		   GSWOPT_FrameworksBaseURL[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_IncludeCommentsInResponse -> %@",
		   GSWOPTVALUE_IncludeCommentsInResponse);
      NSDebugFLLog(@"options",@"GSWOPT_IncludeCommentsInResponse -> %@",
		   GSWOPT_IncludeCommentsInResponse[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_ListenQueueSize -> %@",
		   GSWOPTVALUE_ListenQueueSize);
      NSDebugFLLog(@"options",@"GSWOPT_ListenQueueSize -> %@",
		   GSWOPT_ListenQueueSize[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPT_LoadFrameworks -> %@",
		   GSWOPT_LoadFrameworks[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_LifebeatEnabled -> %@",
		   GSWOPTVALUE_LifebeatEnabled);
      NSDebugFLLog(@"options",@"GSWOPT_LifebeatEnabled -> %@",
		   GSWOPT_LifebeatEnabled[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTVALUE_LifebeatDestinationHost -> %@",
		   GSWOPTVALUE_LifebeatDestinationHost);
      NSDebugFLLog(@"options",@"GSWOPT_LifebeatDestinationHost -> %@",
		   GSWOPT_LifebeatDestinationHost[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTVALUE_LifebeatDestinationPort -> %@",
		   GSWOPTVALUE_LifebeatDestinationPort);
      NSDebugFLLog(@"options",@"GSWOPT_LifebeatDestinationPort -> %@",
		   GSWOPT_LifebeatDestinationPort[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTVALUE_LifebeatInterval -> %@",
		   GSWOPTVALUE_LifebeatInterval);
      NSDebugFLLog(@"options",@"GSWOPT_LifebeatInterval -> %@",
		   GSWOPT_LifebeatInterval[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_MonitorEnabled -> %@",
		   GSWOPTVALUE_MonitorEnabled);
      NSDebugFLLog(@"options",@"GSWOPT_MonitorEnabled -> %@",
		   GSWOPT_MonitorEnabled[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_MonitorHost -> %@",
		   GSWOPTVALUE_MonitorHost);
      NSDebugFLLog(@"options",@"GSWOPT_MonitorHost -> %@",
		   GSWOPT_MonitorHost[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_Port -> %@",
		   GSWOPTVALUE_Port);
      NSDebugFLLog(@"options",@"GSWOPT_Port -> %@",
		   GSWOPT_Port[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWResourceRequestHandlerKey -> %@",
		   GSWResourceRequestHandlerKey[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPT_ResourceRequestHandlerKey -> %@",
		   GSWOPT_ResourceRequestHandlerKey[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_SMTPHost -> %@",
		   GSWOPTVALUE_SMTPHost);
      NSDebugFLLog(@"options",@"GSWOPT_SMTPHost -> %@",
		   GSWOPT_SMTPHost[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_SessionTimeOut -> %@",
		   GSWOPTVALUE_SessionTimeOut);
      NSDebugFLLog(@"options",@"GSWOPT_SessionTimeOut -> %@",
		   GSWOPT_SessionTimeOut[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTVALUE_DefaultUndoStackLimit -> %@",
		   GSWOPTVALUE_DefaultUndoStackLimit);
      NSDebugFLLog(@"options",@"GSWOPT_DefaultUndoStackLimit -> %@",
		   GSWOPT_DefaultUndoStackLimit[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTVALUE_LockDefaultEditingContext -> %@",
		   GSWOPTVALUE_LockDefaultEditingContext);
      NSDebugFLLog(@"options",@"GSWOPT_LockDefaultEditingContext -> %@",
		   GSWOPT_LockDefaultEditingContext[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTVALUE_WorkerThreadCount -> %@",
		   GSWOPTVALUE_WorkerThreadCount);
      NSDebugFLLog(@"options",@"GSWOPT_WorkerThreadCount -> %@",
		   GSWOPT_WorkerThreadCount[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTVALUE_WorkerThreadCountMin -> %@",
		   GSWOPTVALUE_WorkerThreadCountMin);
      NSDebugFLLog(@"options",@"GSWOPT_WorkerThreadCountMin -> %@",
		   GSWOPT_WorkerThreadCountMin[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTVALUE_WorkerThreadCountMax -> %@",
		   GSWOPTVALUE_WorkerThreadCountMax);
      NSDebugFLLog(@"options",@"GSWOPT_WorkerThreadCountMax -> %@",
		   GSWOPT_WorkerThreadCountMax[GSWebNamingConv]);

      NSDebugFLLog(@"options",@"GSWOPTVALUE_MultiThreadEnabled -> %@",
		   GSWOPTVALUE_MultiThreadEnabled);
      NSDebugFLLog(@"options",@"GSWOPT_MultiThreadEnabled -> %@",
		   GSWOPT_MultiThreadEnabled);

      NSDebugFLLog(@"options",@"GSWOPT_AdaptorHost -> %@",
		   GSWOPT_AdaptorHost[GSWebNamingConv]);
      NSDebugFLLog(@"options",@"GSWOPTVALUE_AdaptorHost -> %@",
		   GSWOPTVALUE_AdaptorHost);
      NSDebugFLLog(@"options",@"DefaultTemplateParser -> %@",
		   GSWOPTVALUE_DefaultTemplateParser);
      NSDebugFLLog(@"options",@"AcceptedContentEncoding -> %@",
		   GSWOPTVALUE_AcceptedContentEncoding);
      NSDebugFLLog(@"options",@"DisplayExceptionPages -> %@",
		   GSWOPTVALUE_DisplayExceptionPages);
      NSDebugFLLog(@"options",@"DisplayExceptionPages -> %@",
		   GSWOPTVALUE_AllowsCacheControlHeader);

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

  [defaults registerDefaults:globalAppDefaultOptions];
      
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
-(void)setContextClassName:(NSString*)className
{
  NSAssert(NO,@"TODO");
}

//--------------------------------------------------------------------
-(NSString*)contextClassName
{
  NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
  NSString* contextClassName
    = [userDefaults objectForKey:GSWOPT_Context[GSWebNamingConv]];
  NSAssert([contextClassName length]>0,@"No contextClassName");
  return contextClassName;
}

//--------------------------------------------------------------------
-(void)setResponseClassName:(NSString*)className
{
  NSAssert(NO,@"TODO");
}

//--------------------------------------------------------------------
-(NSString*)responseClassName
{
  NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
  NSString* responseClassName=[userDefaults objectForKey:GSWOPT_Response[GSWebNamingConv]];
  NSAssert([responseClassName length]>0,@"No responseClassName");
  return responseClassName;
}

 //--------------------------------------------------------------------
-(void)setRequestClassName:(NSString*)className
{
  NSAssert(NO,@"TODO");
}

//--------------------------------------------------------------------
-(NSString*)requestClassName
{
  NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
  NSString* requestClassName=[userDefaults objectForKey:GSWOPT_Request[GSWebNamingConv]];
  NSAssert([requestClassName length]>0,@"No requestClassName");
  return requestClassName;
}

@end


//====================================================================
@implementation GSWApplication (UserDefaults)

//--------------------------------------------------------------------
//TODO: take values from application ?
+(NSArray*)loadFrameworks
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_LoadFrameworks[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setLoadFrameworks:(NSArray*)frameworks
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:frameworks
    forKey:GSWOPT_LoadFrameworks[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(BOOL)isDebuggingEnabled
{
  return [[[NSUserDefaults standardUserDefaults] 
            objectForKey:GSWOPT_DebuggingEnabled[GSWebNamingConv]] boolValue];
};

//--------------------------------------------------------------------
+(void)setDebuggingEnabled:(BOOL)flag
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:[NSNumber numberWithBool:flag]
    forKey:GSWOPT_DebuggingEnabled[GSWebNamingConv]];
};

//--------------------------------------------------------------------
//NDFN
+(BOOL)isStatusDebuggingEnabled
{
  return [[[NSUserDefaults standardUserDefaults] 
            objectForKey:GSWOPT_StatusDebuggingEnabled[GSWebNamingConv]] boolValue];
};

//--------------------------------------------------------------------
//NDFN
+(void)setStatusDebuggingEnabled:(BOOL)flag
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:[NSNumber numberWithBool:flag]
    forKey:GSWOPT_StatusDebuggingEnabled[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(BOOL)autoOpenInBrowser
{
  return [[[NSUserDefaults standardUserDefaults] 
            objectForKey:GSWOPT_AutoOpenInBrowser[GSWebNamingConv]] boolValue];
};

//--------------------------------------------------------------------
+(void)setAutoOpenInBrowser:(BOOL)flag
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:[NSNumber numberWithBool:flag]
    forKey:GSWOPT_AutoOpenInBrowser[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(BOOL)isDirectConnectEnabled
{
  return [[[NSUserDefaults standardUserDefaults] 
            objectForKey:GSWOPT_DirectConnectEnabled[GSWebNamingConv]] boolValue];
};

//--------------------------------------------------------------------
+(void)setDirectConnectEnabled:(BOOL)flag
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:[NSNumber numberWithBool:flag]
    forKey:GSWOPT_DirectConnectEnabled[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)cgiAdaptorURL
{
  NSString* cgiAdaptorURL=[[NSUserDefaults standardUserDefaults] 
                            objectForKey:GSWOPT_CGIAdaptorURL[GSWebNamingConv]];
  if (!cgiAdaptorURL)
    cgiAdaptorURL=@"http://localhost/cgi-bin/GSWeb";
  return cgiAdaptorURL;
};

//--------------------------------------------------------------------
+(void)setCGIAdaptorURL:(NSString*)url
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:url
    forKey:GSWOPT_CGIAdaptorURL[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(BOOL)isCachingEnabled
{
  return [[[NSUserDefaults standardUserDefaults] 
            objectForKey:GSWOPT_CachingEnabled[GSWebNamingConv]] boolValue];
};

//--------------------------------------------------------------------
+(void)setCachingEnabled:(BOOL)flag
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:[NSNumber numberWithBool:flag]
    forKey:GSWOPT_CachingEnabled[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)applicationBaseURL
{
  NSString* url=nil;
  LOGClassFnStart();
  url=[[NSUserDefaults standardUserDefaults] 
        objectForKey:GSWOPT_ApplicationBaseURL[GSWebNamingConv]];
  NSDebugMLLog(@"application",@"url=%@",url);
  LOGClassFnStop();
  return url;
};

//--------------------------------------------------------------------
+(void)setApplicationBaseURL:(NSString*)baseURL
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:baseURL
    forKey:GSWOPT_ApplicationBaseURL[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)frameworksBaseURL
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_FrameworksBaseURL[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setFrameworksBaseURL:(NSString*)aString
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:aString
    forKey:GSWOPT_FrameworksBaseURL[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)outputPath
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_OutputPath[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setOutputPath:(NSString*)aString
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:aString
    forKey:GSWOPT_OutputPath[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)recordingPath
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_RecordingPath[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setRecordingPath:(NSString*)aPath
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:aPath
    forKey:GSWOPT_RecordingPath[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSArray*)projectSearchPath
{
  //OK //TODO
  NSArray* projectSearchPath=nil;
  NSBundle* mainBundle=nil;
  LOGClassFnStart();

  mainBundle=[NSBundle mainBundle];
  NSDebugMLLog(@"options",
               @"[[NSUserDefaults  standardUserDefaults] dictionaryRepresentation]=%@",
               [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
  projectSearchPath=[[NSUserDefaults standardUserDefaults] 
                       objectForKey:GSWOPT_ProjectSearchPath]; //return H:\\Wotests
  NSDebugMLLog(@"application",@"projectSearchPath:%@",projectSearchPath);
  if (!projectSearchPath)
    {
	  //TODO dirty hack here !
      NSBundle* mainBundle=[self mainBundle];
      NSString* bundlePath=[mainBundle bundlePath];
      NSString* path=[bundlePath stringGoodPath];
      NSAssert(mainBundle,@"No mainBundle");
      NSAssert(bundlePath,@"No bundlePath");
      NSAssert(path,@"No path");
      NSDebugMLLog(@"application",@"bundlePath:%@",bundlePath);
      NSDebugMLLog(@"application",@"path:%@",path);
      NSDebugMLLog(@"application",@"mainBundle:%@",mainBundle);
      path=[path stringByDeletingLastPathComponent];
      NSDebugMLLog(@"application",@"path:%@",path);
      projectSearchPath=[NSArray arrayWithObject:path];
    };
  NSDebugMLLog(@"application",@"projectSearchPath:%@",projectSearchPath);
  LOGClassFnStop();
  return projectSearchPath;
};

//--------------------------------------------------------------------
+(void)setProjectSearchPath:(NSArray*)paths
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:paths
    forKey:GSWOPT_ProjectSearchPath];
};

//--------------------------------------------------------------------
+(BOOL)isLifebeatEnabled
{
  return [[[NSUserDefaults standardUserDefaults] 
            objectForKey:GSWOPT_LifebeatEnabled[GSWebNamingConv]] boolValue];
};

//--------------------------------------------------------------------
+(void)setLifebeatEnabled:(BOOL)flag
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:[NSNumber numberWithBool:flag]
    forKey:GSWOPT_LifebeatEnabled[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)lifebeatDestinationHost
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_LifebeatDestinationHost[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setLifebeatDestinationHost:(NSString*)host
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:host
    forKey:GSWOPT_LifebeatDestinationHost[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(int)lifebeatDestinationPort
{
  return [[[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_LifebeatDestinationPort[GSWebNamingConv]] intValue];
};

//--------------------------------------------------------------------
+(void)setLifebeatDestinationPort:(int)port
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:[NSNumber numberWithInt:port]
    forKey:GSWOPT_LifebeatDestinationPort[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSTimeInterval)lifebeatInterval
{
  id interval=nil;
  LOGClassFnStart();
  interval=[[NSUserDefaults standardUserDefaults] 
             objectForKey:GSWOPT_LifebeatInterval[GSWebNamingConv]];
  LOGClassFnStop();
  return (NSTimeInterval)[interval intValue];
};

//--------------------------------------------------------------------
+(void)setLifebeatInterval:(NSTimeInterval)interval
{
  LOGClassFnStart();
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:interval]
                                         forKey:GSWOPT_LifebeatInterval[GSWebNamingConv]];
  LOGClassFnStop();
};

//--------------------------------------------------------------------
+(BOOL)isMonitorEnabled
{
  return [[[NSUserDefaults standardUserDefaults] 
            objectForKey:GSWOPT_MonitorEnabled[GSWebNamingConv]] boolValue];
};

//--------------------------------------------------------------------
+(void)setMonitorEnabled:(BOOL)flag
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:[NSNumber numberWithBool:flag]
    forKey:GSWOPT_MonitorEnabled[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)monitorHost
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_MonitorHost[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setMonitorHost:(NSString*)hostName
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:hostName
    forKey:GSWOPT_MonitorHost[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)SMTPHost
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_SMTPHost[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setSMTPHost:(NSString*)hostName
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:hostName
    forKey:GSWOPT_SMTPHost[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)adaptor
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_Adaptor[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setAdaptor:(NSString*)adaptorName
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:adaptorName
    forKey:GSWOPT_Adaptor[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSNumber*)port
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_Port[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setPort:(NSNumber*)port
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:port
    forKey:GSWOPT_Port[GSWebNamingConv]];
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
+(NSString*)host
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_Host[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setHost:(NSString*)host
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:host
    forKey:GSWOPT_Host[GSWebNamingConv]];
  //TODO
  /*
    [[GSWApp adaptors] makeObjectsPerformSelector:@selector(setHost:)
	withObject:host_];
  */
};

//--------------------------------------------------------------------
+(id)listenQueueSize
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_ListenQueueSize[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setListenQueueSize:(id)listenQueueSize
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:listenQueueSize
    forKey:GSWOPT_ListenQueueSize[GSWebNamingConv]];
  [[GSWApp adaptors] makeObjectsPerformSelector:@selector(setListenQueueSize:)
                     withObject:listenQueueSize];
};

//--------------------------------------------------------------------
// [deprecated]
+(id)workerThreadCount
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_WorkerThreadCount[GSWebNamingConv]];
};

//--------------------------------------------------------------------
// [deprecated]
+(void)setWorkerThreadCount:(id)workerThreadCount
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:workerThreadCount
    forKey:GSWOPT_WorkerThreadCount[GSWebNamingConv]];
  [[GSWApp adaptors] makeObjectsPerformSelector:@selector(setWorkerThreadCount:)
                     withObject:workerThreadCount];
};

//--------------------------------------------------------------------
+(id)workerThreadCountMin
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_WorkerThreadCountMin[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setWorkerThreadCountMin:(id)workerThreadCount
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:workerThreadCount
    forKey:GSWOPT_WorkerThreadCountMin[GSWebNamingConv]];
  [[GSWApp adaptors] makeObjectsPerformSelector:@selector(setWorkerThreadCountMin:)
                     withObject:workerThreadCount];
};

//--------------------------------------------------------------------
+(id)workerThreadCountMax
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_WorkerThreadCountMax[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setWorkerThreadCountMax:(id)workerThreadCount
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:workerThreadCount
    forKey:GSWOPT_WorkerThreadCountMax[GSWebNamingConv]];
  [[GSWApp adaptors] makeObjectsPerformSelector:@selector(setWorkerThreadCountMax:)
                     withObject:workerThreadCount];
};

//--------------------------------------------------------------------
+(NSArray*)additionalAdaptors
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_AdditionalAdaptors[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setAdditionalAdaptors:(NSArray*)adaptorsArray
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:adaptorsArray
    forKey:GSWOPT_AdditionalAdaptors[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(BOOL)includeCommentsInResponses
{
  return [[[NSUserDefaults standardUserDefaults] 
            objectForKey:GSWOPT_IncludeCommentsInResponse[GSWebNamingConv]] boolValue];
};

//--------------------------------------------------------------------
+(void)setIncludeCommentsInResponses:(BOOL)flag
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:[NSNumber numberWithBool:flag]
    forKey:GSWOPT_IncludeCommentsInResponse[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)componentRequestHandlerKey
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_ComponentRequestHandlerKey[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setComponentRequestHandlerKey:(NSString*)aKey
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:aKey
    forKey:GSWOPT_ComponentRequestHandlerKey[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)directActionRequestHandlerKey
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_DirectActionRequestHandlerKey[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setDirectActionRequestHandlerKey:(NSString*)aKey
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:aKey
    forKey:GSWOPT_DirectActionRequestHandlerKey[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)resourceRequestHandlerKey
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_ResourceRequestHandlerKey[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setResourceRequestHandlerKey:(NSString*)aKey
{
  [[NSUserDefaults standardUserDefaults] setObject:aKey
                                         forKey:GSWOPT_ResourceRequestHandlerKey[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)streamActionRequestHandlerKey
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_StreamActionRequestHandlerKey[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setStreamActionRequestHandlerKey:(NSString*)aKey
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:aKey
    forKey:GSWOPT_StreamActionRequestHandlerKey[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)pingActionRequestHandlerKey
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_PingActionRequestHandlerKey[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setPingActionRequestHandlerKey:(NSString*)aKey
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:aKey
    forKey:GSWOPT_PingActionRequestHandlerKey[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)staticResourceRequestHandlerKey
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_StaticResourceRequestHandlerKey[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setStaticResourceRequestHandlerKey:(NSString*)aKey
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:aKey
    forKey:GSWOPT_StaticResourceRequestHandlerKey[GSWebNamingConv]];
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
+(NSString*)resourceManagerClassName
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_ResourceManagerClassName[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setResourceManagerClassName:(NSString*)name
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:name
    forKey:GSWOPT_ResourceManagerClassName[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)statisticsStoreClassName
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_StatisticsStoreClassName[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setStatisticsStoreClassName:(NSString*)name
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:name
    forKey:GSWOPT_StatisticsStoreClassName[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)sessionStoreClassName
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_SessionStoreClassName[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setSessionStoreClassName:(NSString*)name
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:name
    forKey:GSWOPT_SessionStoreClassName[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(NSString*)recordingClassName
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_RecordingClassName[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setRecordingClassName:(NSString*)name
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:name
    forKey:GSWOPT_RecordingClassName[GSWebNamingConv]];
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
+(void)setSessionTimeOut:(NSNumber*)aTimeOut
{
  LOGClassFnStart();
  NSDebugMLLog(@"sessions",@"aTimeOut=%@",aTimeOut);
  [[NSUserDefaults standardUserDefaults] 
    setObject:aTimeOut
    forKey:GSWOPT_SessionTimeOut[GSWebNamingConv]];
  LOGClassFnStop();
};

//--------------------------------------------------------------------
+(NSNumber*)sessionTimeOut
{
  id sessionTimeOut=nil;
  LOGClassFnStart();
  sessionTimeOut=[[NSUserDefaults standardUserDefaults] 
                   objectForKey:GSWOPT_SessionTimeOut[GSWebNamingConv]];
  NSDebugMLLog(@"sessions",@"sessionTimeOut=%@",sessionTimeOut);
  LOGClassFnStop();
  return sessionTimeOut;
};

//--------------------------------------------------------------------
+(void)setSessionTimeOutValue:(NSTimeInterval)aTimeOutValue
{
  LOGClassFnStart();
  NSDebugMLLog(@"sessions",@"aTimeOutValue=%f",aTimeOutValue);
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:aTimeOutValue]
                                         forKey:GSWOPT_SessionTimeOut[GSWebNamingConv]];
  LOGClassFnStop();
};

//--------------------------------------------------------------------
+(NSTimeInterval)sessionTimeOutValue
{
  id sessionTimeOut=nil;
  LOGClassFnStart();
  sessionTimeOut=[[NSUserDefaults standardUserDefaults] 
                   objectForKey:GSWOPT_SessionTimeOut[GSWebNamingConv]];
  NSDebugMLLog(@"sessions",@"sessionTimeOut=%@",sessionTimeOut);
  LOGClassFnStop();
  return (NSTimeInterval)[sessionTimeOut intValue];
};

//--------------------------------------------------------------------
+(void)setDefaultUndoStackLimit:(int)limit
{
  LOGClassFnStart();
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:limit]
                                         forKey:GSWOPT_DefaultUndoStackLimit[GSWebNamingConv]];
  LOGClassFnStop();
};

+(int)defaultUndoStackLimit
{
  id limit=nil;
  LOGClassFnStart();
  limit=[[NSUserDefaults standardUserDefaults] 
                   objectForKey:GSWOPT_DefaultUndoStackLimit[GSWebNamingConv]];
  LOGClassFnStop();
  return [limit intValue];
};

//--------------------------------------------------------------------
+(BOOL)_lockDefaultEditingContext
{
  return [[[NSUserDefaults standardUserDefaults] 
            objectForKey:GSWOPT_LockDefaultEditingContext[GSWebNamingConv]] boolValue];
};

//--------------------------------------------------------------------
+(void)_setLockDefaultEditingContext:(BOOL)flag
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:[NSNumber numberWithBool:flag]
    forKey:GSWOPT_LockDefaultEditingContext[GSWebNamingConv]];
};

//--------------------------------------------------------------------
//NDFN
+(NSString*)debugSetConfigFilePath
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_DebugSetConfigFilePath];
};

//--------------------------------------------------------------------
+(void)setDebugSetConfigFilePath:(NSString*)debugSetConfigFilePath
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:debugSetConfigFilePath
    forKey:GSWOPT_DebugSetConfigFilePath];
};

/** Returns the path where to store responses or nil if responses are not saved **/
+(NSString*)saveResponsesPath
{
  NSAssert(NO,@"+saveResponsesPath is now obsolete. Use +recordingPath");
  return nil;
};

//--------------------------------------------------------------------
+(void)setSaveResponsesPath:(NSString*)saveResponsesPath
{
  NSAssert(NO,@"+setSaveResponsesPath: is now obsolete. Use +setRecordingPath:");
};

//--------------------------------------------------------------------
+(NSString*)acceptedContentEncoding
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_AcceptedContentEncoding[GSWebNamingConv]];
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
  [[NSUserDefaults standardUserDefaults] 
    setObject:acceptedContentEncoding
    forKey:GSWOPT_AcceptedContentEncoding[GSWebNamingConv]];
};


//--------------------------------------------------------------------
/** Returns the default template parser option **/
+(NSString*)defaultTemplateParser
{
  return [[NSUserDefaults standardUserDefaults] 
           objectForKey:GSWOPT_DefaultTemplateParser[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(void)setDefaultTemplateParser:(NSString*)defaultTemplateParser
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:defaultTemplateParser
    forKey:GSWOPT_DefaultTemplateParser[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(BOOL)defaultDisplayExceptionPages
{
  return [[[NSUserDefaults standardUserDefaults] 
            objectForKey:GSWOPT_DisplayExceptionPages[GSWebNamingConv]] boolValue];
};

//--------------------------------------------------------------------
+(void)setDefaultDisplayExceptionPages:(BOOL)flag
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:[NSNumber numberWithBool:flag]
    forKey:GSWOPT_DisplayExceptionPages[GSWebNamingConv]];
};

//--------------------------------------------------------------------
+(BOOL)_allowsCacheControlHeader
{
  return [[[NSUserDefaults standardUserDefaults] 
            objectForKey:GSWOPT_AllowsCacheControlHeader[GSWebNamingConv]] boolValue];
};

//--------------------------------------------------------------------
+(void)_setAllowsCacheControlHeader:(BOOL)flag
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:[NSNumber numberWithBool:flag]
    forKey:GSWOPT_AllowsCacheControlHeader[GSWebNamingConv]];
};

@end
