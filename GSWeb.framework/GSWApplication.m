/** GSWApplication.m - <title>GSWeb: Class GSWApplication</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
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

RCS_ID("$Id$")

#include "GSWeb.h"
#include "GSWLifebeatThread.h"
#include "GSWRecording.h"

#if HAVE_GDL2 // GDL2 implementation
#include <EOAccess/EOModelGroup.h>
#endif
#ifdef TCSDB
#include <TCSimpleDB/TCSimpleDB.h>
#endif
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
int GSWebNamingConv=GSWNAMES_INDEX;
BOOL WOStrictFlag=NO;
NSString* GSWPageNotFoundException=@"GSWPageNotFoundException";

#ifndef NDEBUG
void GSWApplicationDebugSetChange()
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

// Main function
int GSWApplicationMainReal(NSString* applicationClassName,
                           int argc,
                           const char *argv[])
{
  Class applicationClass=Nil;
  int result=0;
  NSArray* args=nil;
//call NSBundle Start:_usesFastJavaBundleSetup
//call :NSBundle Start:_setUsesFastJavaBundleSetup:YES
//call NSBundle mainBundle
  NSProcessInfo* processInfo=nil;
  NSString* envGNUstepStringEncoding=nil;
  NSAutoreleasePool *appAutoreleasePool=nil;

  appAutoreleasePool = [NSAutoreleasePool new];
  GSWLogMemCF("New NSAutoreleasePool: %p",appAutoreleasePool);
  /*
  //TODO
  DebugInstall("/dvlp/projects/app/Source/app.gswa/shared_debug_obj/ix86/linux-gnu/gnu-gnu-gnu-xgps/app_server");
  DebugEnableBreakpoints();
  */
  processInfo=[NSProcessInfo processInfo];
  envGNUstepStringEncoding=[[processInfo environment]
                             objectForKey:@"GNUSTEP_STRING_ENCODING"];
  NSCAssert(envGNUstepStringEncoding,
            @"GNUSTEP_STRING_ENCODING environement variable is not defined !");
  NSCAssert([NSString defaultCStringEncoding]!=NSASCIIStringEncoding,
            @"NSString defaultCStringEncoding is NSASCIIStringEncoding. Please define GNUSTEP_STRING_ENCODING environement variable to better one !");
  if (!envGNUstepStringEncoding
      || [NSString defaultCStringEncoding]==NSASCIIStringEncoding)
    {
      result=-1;
    };
  if (result>=0)
    {
      NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
      if (defaults)
        {
          NSDictionary* args=[defaults volatileDomainForName:NSArgumentDomain];
          if (args && [args count]>0)
            {
              NSMutableDictionary* newArgs=[NSMutableDictionary dictionary];
              NSEnumerator* argEnum=nil;
              NSString* argKey=nil;
              id argValue=nil;
              argEnum=[args keyEnumerator];
              while ((argKey = [argEnum nextObject]))
                {
                  argValue=[args objectForKey:argKey];
                  if ([argKey hasPrefix:@"-GSW"])
                    argKey = [argKey substringFromIndex:1];
                  [newArgs setObject:argValue
                           forKey:argKey];
                };
              NSDebugFLog(@"NSArgumentDomain: %@ Args: %@",NSArgumentDomain,newArgs);
              [defaults removeVolatileDomainForName:NSArgumentDomain];
              [defaults setVolatileDomain:newArgs
                        forName:NSArgumentDomain];
            };
        };
      if (!localDynCreateClassNames)
        localDynCreateClassNames=[NSMutableDictionary new];
      if (!globalAppDefaultOptions)
        {
          NSDictionary* defaultsOptions=nil;
          globalAppDefaultOptions=[[GSWApplication bundleInfo] objectForKey:@"defaults"];
          NSDebugFLLog(@"options",@"globalAppDefaultOptions=%@",globalAppDefaultOptions);

          NSDebugFLLog(@"options",@"GSWebNamingConv=%d",GSWebNamingConv);
          NSCAssert1((GSWebNamingConv==WONAMES_INDEX || GSWebNamingConv==GSWNAMES_INDEX),
                     @"GSWebNamingConv=%d",GSWebNamingConv);
          
          NSDebugFLLog(@"options",@"GSWClassName_DefaultAdaptor -> %@",
                       GSWClassName_DefaultAdaptor[GSWebNamingConv]);
          NSDebugFLLog(@"options",@"GSWOPT_Adaptor -> %@",
                       GSWOPT_Adaptor[GSWebNamingConv]);
          NSDebugFLLog(@"options",@"GSWOPT_AdditionalAdaptors -> %@",
                       GSWOPT_AdditionalAdaptors[GSWebNamingConv]);
          NSDebugFLLog(@"options",@"GSWClassName_DefaultContext -> %@",
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

          defaultsOptions = 
            [NSDictionary dictionaryWithObjectsAndKeys:
                            GSWClassName_DefaultAdaptor[GSWebNamingConv],   
                          GSWOPT_Adaptor[GSWebNamingConv],

                          [NSArray array],					
                          GSWOPT_AdditionalAdaptors[GSWebNamingConv],
                          
                          (GSWebNamingConv==WONAMES_INDEX ? GSWOPTVALUE_ApplicationBaseURL_WO : GSWOPTVALUE_ApplicationBaseURL_GSWEB), 
                          GSWOPT_ApplicationBaseURL[GSWebNamingConv],

                          GSWClassName_DefaultContext[GSWebNamingConv],   
                          GSWOPT_Context[GSWebNamingConv],

                          GSWClassName_DefaultResponse[GSWebNamingConv],   
                          GSWOPT_Response[GSWebNamingConv],

                          GSWClassName_DefaultRequest[GSWebNamingConv],   
                          GSWOPT_Request[GSWebNamingConv],
                          
                          GSWOPTVALUE_AutoOpenInBrowser,			
                          GSWOPT_AutoOpenInBrowser[GSWebNamingConv],
                          
                          (GSWebNamingConv==WONAMES_INDEX ? GSWOPTVALUE_CGIAdaptorURL_WO : GSWOPTVALUE_CGIAdaptorURL_GSWEB),
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
                          
                          nil];
          NSDebugFLLog(@"options",@"_globalAppDefaultOptions=%@",globalAppDefaultOptions);
          globalAppDefaultOptions=[NSDictionary dictionaryWithDictionary:globalAppDefaultOptions
                                                andDefaultEntriesFromDictionary:defaultsOptions];
          NSDebugFLLog(@"options",@"_globalAppDefaultOptions=%@",globalAppDefaultOptions);
        };
      [defaults registerDefaults:globalAppDefaultOptions];
      
      args=[processInfo arguments];
      {
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
          };
      };
      //TODO
      if (applicationClassName && [applicationClassName length]>0)
        ASSIGNCOPY(globalApplicationClassName,applicationClassName);
      GSWApplicationDebugSetChange();
      applicationClass=[GSWApplication _applicationClass];
      NSDebugFLog(@"=======");
      NSDebugFLog(@"applicationClass: %@",applicationClass);
      if (!applicationClass)
        {
          NSCAssert(NO,@"!applicationClass");
          //TODO error
          result=-1;
        };
    };
  if (result>=0)
    {
      NSArray* frameworks=[applicationClass loadFrameworks];
      NSDebugFLog(@"LOAD Frameworks frameworks=%@",frameworks);
      if (frameworks)
        {
          NSBundle* bundle=nil;
          int i=0;
          BOOL loadResult=NO;
          NSString* GNUstepRoot=[[[NSProcessInfo processInfo]environment]
                                  objectForKey:@"GNUSTEP_SYSTEM_ROOT"];
          NSDebugFLLog(@"bundles",@"GNUstepRoot=%@",GNUstepRoot);
          //		  NSDebugFLLog(@"bundles",@"[[NSProcessInfo processInfo]environment]=%@",[[NSProcessInfo processInfo]environment]);
          NSDebugFLLog(@"bundles",@"[NSProcessInfo processInfo]=%@",
                       [NSProcessInfo processInfo]);
          for(i=0;i<[frameworks count];i++)
            {
              NSString* bundlePath=[frameworks objectAtIndex:i];
              NSDebugFLLog(@"bundles",@"bundlePath=%@",bundlePath);
              //TODO
              NSDebugFLLog(@"bundles",@"GSFrameworkPSuffix=%@",GSFrameworkPSuffix);
              bundlePath=[NSString stringWithFormat:@"%@/Library/Frameworks/%@%@",GNUstepRoot,bundlePath,GSFrameworkPSuffix];
              NSDebugFLLog(@"bundles",@"bundlePath=%@",bundlePath);
              bundle=[NSBundle bundleWithPath:bundlePath];
              NSDebugFLLog(@"bundles",@"bundle=%@",bundle);
              loadResult=[bundle load];
              NSDebugFLog(@"_bundlePath %@ loadResult=%s",bundlePath,(loadResult ? "YES" : "NO"));
              if (!loadResult)
                {
                  result=-1;
                  ExceptionRaise(@"GSWApplication",@"Can't load framework %@",
                                 bundlePath);
                };
            };
        };	  
      NSDebugFLLog(@"bundles",@"[NSBundle allBundles] pathes=%@",[[NSBundle allBundles] valueForKey:@"resourcePath"]);
      NSDebugFLLog(@"bundles",@"[NSBundle allFrameworks] pathes=%@",[[NSBundle allFrameworks] valueForKey:@"resourcePath"]);
    };
  if (result>=0)
    {
      NS_DURING
        {
          id app=[applicationClass new];
          if (app)
            result=1;
          else
            result=-1;
        };	  
      // Make sure we pass all exceptions back to the requestor.
      NS_HANDLER
        {
          NSLog(@"Can't create Application (Class:%@)- %@ %@ Name:%@ Reason:%@\n",
                applicationClass,
                localException,
                [localException description],
                [localException name],
                [localException reason]);
          result=-1;
        }
      NS_ENDHANDLER;
    };
  NSDebugLog(@"result=%d",result);
  printf("result=%d\n",result);
  if (result>=0 && GSWApp)
    {
      [GSWApp _setPool:[NSAutoreleasePool new]];

      [GSWApp run];

      DESTROY(GSWApp);
    };
  GSWLogMemCF("Destroy NSAutoreleasePool: %p",appAutoreleasePool);
  DESTROY(appAutoreleasePool);
  return result;
};

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
  NSUserDefaults* standardUserDefaults=nil;
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      _selfLock=[NSRecursiveLock new];
      _globalLock=[NSLock new];
      
      ASSIGN(_startDate,[NSDate date]);
      ASSIGN(_lastAccessDate,[NSDate date]);
      [self setTimeOut:0];//No time out

      NSDebugMLLog(@"application",@"GSCurrentThreadDictionary()=%@",GSCurrentThreadDictionary());

      //Do it before run so application can addTimer,... in -run
      NSDebugMLLog(@"application",@"[NSRunLoop currentRunLoop]=%@",[NSRunLoop currentRunLoop]);
      ASSIGN(_currentRunLoop,[NSRunLoop currentRunLoop]); 

      _pageCacheSize=30;
      _permanentPageCacheSize=30;
      _pageRecreationEnabled=YES;
      _pageRefreshOnBacktrackEnabled=YES;
      _refusingNewSessions = NO;
      _minimumActiveSessionsCount = 0;	// 0 is default
      _dynamicLoadingEnabled=YES;
      _printsHTMLParserDiagnostics=YES;

      [[self class] _setApplication:self];
      [self _touchPrincipalClasses];

      standardUserDefaults=[NSUserDefaults standardUserDefaults];
      NSDebugMLLog(@"options",@"standardUserDefaults=%@",standardUserDefaults);

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
	  NSDebugMLLog0(@"application",@"init: call self _setupForMonitoring");
	  [self _setupForMonitoring];
	};
      NSDebugMLLog0(@"application",@"init: call appGSWBundle initializeObject:...");
      [[GSWResourceManager _applicationGSWBundle] initializeObject:self
                                                  fromArchiveNamed:@"Application"];
      [self setPrintsHTMLParserDiagnostics:NO];

      if ([[self class] recordingPath])
        {
          Class recordingClass=[[self class]recordingClass];
          _recorder=[recordingClass new];
        };

      //call recordingPath
      NSDebugMLLog0(@"application",@"init: call self registerRequestHandlers");
      [self registerRequestHandlers];
      [self _validateAPI];
      NSDebugMLLog0(@"application",@"init: addObserver");
      [[NSNotificationCenter defaultCenter]addObserver:self
                                           selector:@selector(_sessionDidTimeOutNotification:)
                                           name:GSWNotification__SessionDidTimeOutNotification[GSWebNamingConv]
                                           object:nil];
      NSDebugMLLog0(@"application",@"init: addObserver called");
      
      // Create lifebeat thread only if we're not the observer :-)
      NSDebugMLLog(@"application",@"[self isTaskDaemon]=%d",[self isTaskDaemon]);
      NSDebugMLLog(@"application",@"[[self class] isLifebeatEnabled]=%d",[[self class] isLifebeatEnabled]);
      if (![self isTaskDaemon] && [[self class] isLifebeatEnabled])
        {
          NSTimeInterval lifebeatInterval=[[self class]lifebeatInterval];
          if (lifebeatInterval<1)
            lifebeatInterval=30; //30s
          NSDebugMLLog(@"application",@"lifebeatInterval=%f",lifebeatInterval);
          
          ASSIGN(_lifebeatThread,[GSWLifebeatThread lifebeatThreadWithApplication:self
                                                    name:[self name]
                                                    host:[[self class] host]
                                                    port:[[self class] intPort]
                                            lifebeatHost:[[self class]lifebeatDestinationHost]
                                            lifebeatPort:[[self class]lifebeatDestinationPort]
                                            interval:lifebeatInterval]);
          NSDebugMLLog(@"application",@"_lifebeatThread=%@",_lifebeatThread);
          [NSThread detachNewThreadSelector:@selector(run:)
                    toTarget:_lifebeatThread
                    withObject:nil];
        };
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogMemC("Dealloc GSWApplication");
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
  GSWLogMemC("Dealloc GSWApplication: selfLock");
  DESTROY(_selfLock);
  GSWLogMemC("Dealloc GSWApplication: globalLock");
  DESTROY(_globalLock);
  GSWLogMemC("Dealloc GSWApplication: globalAutoreleasePool");
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

  GSWLogMemC("Dealloc GSWApplication Super");
  [super dealloc];
  GSWLogMemC("End Dealloc GSWApplication");
};

//--------------------------------------------------------------------
-(NSString*)description
{
  //OK
  NSString* dscr=nil;
  [self lock];
  dscr=[NSString stringWithFormat:
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
                 [_componentDefinitionCache description],
                 [self isCachingEnabled] ? "YES" : "NO",
                 [self isTerminating] ? "YES" : "NO",
                 [self timeOut],
                 [self _isDynamicLoadingEnabled] ? "YES" : "NO"];
  [self unlock];
  return dscr;
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
  BOOL adaptorsDispatchRequestsConcurrently=NO;
  int i=0;
  int adaptorsCount=[_adaptors count];
  for(i=0;!adaptorsDispatchRequestsConcurrently && i<adaptorsCount;i++)
    adaptorsDispatchRequestsConcurrently=[[_adaptors objectAtIndex:i]dispatchesRequestsConcurrently];
  return adaptorsDispatchRequestsConcurrently;
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
  return [_globalLock isLocked];
};

//--------------------------------------------------------------------
//	lockRequestHandling
-(void)lockRequestHandling
{
  //OK
  LOGObjectFnStart();
  if (![self isConcurrentRequestHandlingEnabled])
    {
      /*  NSDebugMLLog(@"application",@"globalLockn=%d globalLock_thread_id=%p objc_thread_id()=%p",
          globalLockn,(void*)
          globalLock_thread_id,
          (void*)objc_thread_id());
          if (globalLockn>0)
          {
          if (globalLock_thread_id!=objc_thread_id())
          {
          NSDebugMLLog(@"application",@"PROBLEM: owner!=thread id");
          };
          };
      */
      NS_DURING
        {
          NSDebugLockMLog(@"GLOBALLOCK lock ThreadID=%p\n",(void*)objc_thread_id());
          //TODO-NOW	  TmpLockBeforeDate(globalLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
          [_globalLock lock];
          NSDebugLockMLog(@"GLOBALLOCK locked ThreadID=%p\n",(void*)objc_thread_id());
#ifndef NDEBUG
          _globalLockn++;
          _globalLock_thread_id=objc_thread_id();
#endif
          /*		  NSDebugMLLog(@"application",@"globalLockn=%d globalLock_thread_id=%p objc_thread_id()=%p",
                          globalLockn,
                          (void*)globalLock_thread_id,
                          (void*)objc_thread_id());*/
        }
      NS_HANDLER
        {
          localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                   @"globalLock tmplockBeforeDate");
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
          /*  NSDebugMLLog(@"application",@"globalLockn=%d globalLock_thread_id=%p objc_thread_id()=%p",
              globalLockn,
              (void*)globalLock_thread_id,
              (void*)objc_thread_id());*/
          if (_globalLockn>0)
            {
              if (_globalLock_thread_id!=objc_thread_id())
                {
                  NSDebugMLLog0(@"application",@"PROBLEM: owner!=thread id");
                };
            };
          NSDebugLockMLog(@"GLOBALLOCK unlock ThreadID=%p\n",(void*)objc_thread_id());
          TmpUnlock(_globalLock);
          NSDebugLockMLog(@"GLOBALLOCK unlocked ThreadID=%p\n",(void*)objc_thread_id());
#ifndef NDEBUG
          _globalLockn--;
          if (_globalLockn==0)
            _globalLock_thread_id=NULL;
#endif
          /*		  NSDebugMLLog(@"application",@"globalLockn=%d globalLock_thread_id=%p objc_thread_id()=%p",
                          globalLockn,
                          (void*)globalLock_thread_id,
                          (void*)objc_thread_id());*/
        }
      NS_HANDLER
        {
          NSDebugMLog(@"globalLockn=%d globalLock_thread_id=%p objc_thread_id()=%p",
                      _globalLockn,
                      (void*)_globalLock_thread_id,
                      (void*)objc_thread_id());
          localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                   @"globalLock tmpunlock");
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
  /*  NSDebugMLLog(@"application",@"selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
      selfLockn,
      (void*)selfLock_thread_id,
      (void*)objc_thread_id());
      if (selfLockn>0)
      {
      if (selfLock_thread_id!=objc_thread_id())
      {
      NSDebugMLLog(@"application",@"PROBLEM: owner!=thread id");
      };
      };
  */
  NS_DURING
    {
      /*          printf("SELFLOCK lock ThreadID=%p\n",(void*)objc_thread_id());
                  TmpLockBeforeDate(selfLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
                  printf("SELFLOCK locked ThreadID=%p\n",(void*)objc_thread_id());
                  #ifndef NDEBUG
                  selfLockn++;
                  selfLock_thread_id=objc_thread_id();
#endif
NSDebugMLLog(@"application",@"selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
selfLockn,
(void*)selfLock_thread_id,
				   (void*)objc_thread_id());
      */
      [_selfLock lock];//NEW
#ifndef NDEBUG
      _selfLockn++;
      _selfLock_thread_id=objc_thread_id();
#endif
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"selfLock tmplockBeforeDate");
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
  /*  NSDebugMLLog(@"application",@"selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
      selfLockn,
      (void*)selfLock_thread_id,
      (void*)objc_thread_id());
      if (selfLockn>0)
      {
      if (selfLock_thread_id!=objc_thread_id())
      {
      NSDebugMLLog(@"application",@"PROBLEM: owner!=thread id");
      };
      };
  */
  NS_DURING
    {
      NSDebugLockMLog(@"SELFLOCK unlock ThreadID=%p\n",(void*)objc_thread_id());
      //	  TmpUnlock(selfLock);
      [_selfLock unlock];//NEW
      NSDebugLockMLog(@"SELFLOCK unlocked ThreadID=%p\n",(void*)objc_thread_id());
#ifndef NDEBUG
      _selfLockn--;
      if (_selfLockn==0)
        _selfLock_thread_id=NULL;
#endif
      /*	  NSDebugMLLog(@"application",@"selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
                  selfLockn,
                  (void*)selfLock_thread_id,
                  (void*)objc_thread_id());
      */
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"application",@"selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
                   _selfLockn,
                   (void*)_selfLock_thread_id,
                   (void*)objc_thread_id());
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"selfLock tmpunlock");
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
  LOGObjectFnStart();
  //TODO
/*  if (applicationName)
	return applicationName;
  else
	{*/
  processInfo=[NSProcessInfo processInfo];
  processName=[processInfo processName];
  NSDebugMLLog(@"application",@"_cmd:%p",_cmd);
  NSDebugMLLog(@"application",@"processInfo:%@",processInfo);
  NSDebugMLLog(@"application",@"processName:%@",processName);
  processName=[processName lastPathComponent];
  if ([processName hasSuffix:GSWApplicationPSuffix[GSWebNamingConv]])
    name=[processName stringByDeletingSuffix:GSWApplicationPSuffix[GSWebNamingConv]];
  else
    name=processName;
  NSDebugMLLog(@"application",@"_name:%@ %p",name,name);
  //	};
  return name;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//number
-(NSString*)number 
{
  return @"-1";
};

//--------------------------------------------------------------------
//setPageRefreshOnBacktrackEnabled:
-(void)setPageRefreshOnBacktrackEnabled:(BOOL)flag 
{
  LOGObjectFnStart();
  _pageRefreshOnBacktrackEnabled=flag;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//path
-(NSString*)path 
{
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"[GSWResourceManager _applicationGSWBundle]:%@",[GSWResourceManager _applicationGSWBundle]);
  path=[[GSWResourceManager _applicationGSWBundle] path];
  NSDebugMLLog(@"application",@"path:%@",path);
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
//baseURL
-(NSString*)baseURL 
{
  NSString* baseURL=nil;
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStart();
  baseURL=[GSWURLPrefix[GSWebNamingConv] stringByAppendingString:[self name]];
  LOGObjectFnStop();
  return baseURL;
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

  GSWRequestHandler* componentRequestHandler=nil;
  GSWResourceRequestHandler* resourceRequestHandler=nil;
  GSWDirectActionRequestHandler* directActionRequestHandler=nil;
  GSWDirectActionRequestHandler* pingDirectActionRequestHandler=nil;
  GSWDirectActionRequestHandler* streamDirectActionRequestHandler=nil;
  GSWRequestHandler* defaultRequestHandler=nil;

  Class defaultRequestHandlerClass=nil;

  LOGObjectFnStart();

  // Component Handler
  componentRequestHandler=[[self class] _componentRequestHandler];
  componentRequestHandlerKey=[[self class] componentRequestHandlerKey];

  NSDebugMLLog(@"application",@"componentRequestHandlerKey:%@",
               componentRequestHandlerKey);


  // Resource Handler
  resourceRequestHandler=(GSWResourceRequestHandler*)
    [GSWResourceRequestHandler handler];

  resourceRequestHandlerKey=[[self class] resourceRequestHandlerKey];

  NSDebugMLLog(@"application",@"resourceRequestHandlerKey:%@",
               resourceRequestHandlerKey);


  // DirectAction Handler
  directActionRequestHandler=(GSWDirectActionRequestHandler*)
    [GSWDirectActionRequestHandler handler];

  directActionRequestHandlerKey=[[self class] directActionRequestHandlerKey];

  NSDebugMLLog(@"application",@"directActionRequestHandlerKey:%@",
               directActionRequestHandlerKey);


  // "Ping" Handler
  pingDirectActionRequestHandler=(GSWDirectActionRequestHandler*)
    [GSWDirectActionRequestHandler handlerWithDefaultActionClassName:@"GSWAdminAction"
                                   defaultActionName:@"ping"
                                   shouldAddToStatistics:NO];
  pingDirectActionRequestHandlerKey=[[self class] pingActionRequestHandlerKey];

  NSDebugMLLog(@"application",@"pingDirectActionRequestHandlerKey:%@",
               pingDirectActionRequestHandlerKey);


  // Stream Handler
  streamDirectActionRequestHandler=(GSWDirectActionRequestHandler*)
    [GSWDirectActionRequestHandler handler];

  streamDirectActionRequestHandlerKey=[[self class] streamActionRequestHandlerKey];
  [streamDirectActionRequestHandler setAllowsContentInputStream:YES];

  NSDebugMLLog(@"application",@"streamDirectActionRequestHandlerKey:%@",
               streamDirectActionRequestHandlerKey);


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

  // Default Request Handler
  defaultRequestHandlerClass=[self defaultRequestHandlerClass];
  if (defaultRequestHandlerClass)
    defaultRequestHandler=(GSWRequestHandler*)[defaultRequestHandlerClass handler];
  else
    defaultRequestHandler=componentRequestHandler;
  [self setDefaultRequestHandler:defaultRequestHandler];


  // If direct connect enabled, add static resources handler
  if ([self isDirectConnectEnabled])
    {
      GSWStaticResourceRequestHandler* staticResourceRequestHandler = (GSWStaticResourceRequestHandler*)
        [GSWStaticResourceRequestHandler handler];
      NSString* staticResourceRequestHandlerKey=[[self class] staticResourceRequestHandlerKey];
      [self registerRequestHandler:staticResourceRequestHandler
            forKey:staticResourceRequestHandlerKey];
    };

  NSDebugMLLog(@"application",@"_requestHandlers:%@",_requestHandlers);
  LOGObjectFnStop();
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
  port=[[self class] port];
  host=[[self class] host];
  adaptor=(NSString*)[[self class] adaptor];
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
-(NSString*)_webserverConnectURL
{
  NSString* webserverConnectURL=nil;
  NSString* cgiAdaptorURL=[[self class]cgiAdaptorURL]; //return http://titi.toto.com/cgi-bin/GSWeb.exe
  if (!cgiAdaptorURL)
    {
      NSDebugMLog(@"No CGI adaptor");
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
      NSDebugMLog(@"webserverConnectURL=%@",webserverConnectURL);
    } 
  return webserverConnectURL; //return http://titi.toto.com:1436/cgi-bin/GSWeb.exe/ObjCTest3.gswa/-2
};

//--------------------------------------------------------------------
-(NSString*)_directConnectURL
{
  NSString* directConnectURL=nil;
  NSString* cgiAdaptorURL=[[self class]cgiAdaptorURL]; //return http://titi.toto.com/cgi-bin/GSWeb.exe
  if (!cgiAdaptorURL)
    {
      NSDebugMLog(@"No CGI adaptor");
    }
  else
    {
      NSArray* adaptors=[self adaptors];
      if ([adaptors count]>0)
        {
          GSWAdaptor* firstAdaptor=[adaptors objectAtIndex:0];
          int port=[firstAdaptor port];
          GSWDynamicURLString* anURL=[[GSWDynamicURLString alloc]initWithCString:[cgiAdaptorURL cString]
                                                        length:[cgiAdaptorURL length]];
          NSDebugMLog(@"anURL=%@",anURL);
          [anURL setURLPort:port];
          NSDebugMLog(@"anURL=%@",anURL);
          [anURL setURLApplicationName:[self name]];
          NSDebugMLog(@"anURL=%@",anURL);
          directConnectURL=[NSString stringWithString:(NSString*)anURL];
          NSDebugMLog(@"directConnectURL=%@",directConnectURL);
        };
    } 
  return directConnectURL; //return http://titi.toto.com:1436/cgi-bin/GSWeb.exe/ObjCTest3
};

//--------------------------------------------------------------------
-(NSString*)_applicationExtension
{
  LOGObjectFnNotImplemented();	//TODOFN
  return GSWApplicationSuffix[GSWebNamingConv];
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
  NSEnumerator* anEnum=nil;
  id object=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      NSDebugMLLog(@"application",@"componentDefinitionCache=%@",_componentDefinitionCache);
      anEnum=[_componentDefinitionCache objectEnumerator];
      while ((object = [anEnum nextObject]))
        {
          NSDebugMLLog(@"application",@"object=%@",object);
          if (object!=GSNotFoundMarker && ![object isCachingEnabled])
            [object _clearCache];
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

-(GSWComponentDefinition*)componentDefinitionWithName:(NSString*)aName
                                            languages:(NSArray*)languages
{
  //OK
  GSWComponentDefinition* componentDefinition=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"info",@"aName=%@",aName);
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
      LOGException(@"%@ (%@)",localException,[localException reason]);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
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
#ifdef DEBUG
  NSDate* startDate=[NSDate date];
  NSDate* stopDate=nil;
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"application",@"aName %p=%@",aName,aName);
  for(iLanguage=0;iLanguage<[languages count] && !componentDefinition;iLanguage++)
    {
      language=[languages objectAtIndex:iLanguage];
      if (language)
        {
          NSDebugMLLog(@"gswcomponents",@"trying language=%@",language);
          NSDebugMLLog(@"gswcomponents",@"[self isCachingEnabled]=%s",([self isCachingEnabled] ? "YES" : "NO"));
          if ([self isCachingEnabled])
            {
              componentDefinition=[_componentDefinitionCache objectForKeys:aName,language,nil];
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
      NSDebugMLLog0(@"application",@"trying no language");
      NSDebugMLLog(@"gswcomponents",@"[self isCachingEnabled]=%s",([self isCachingEnabled] ? "YES" : "NO"));
      if ([self isCachingEnabled])
        {
          componentDefinition=[_componentDefinitionCache objectForKeys:aName,nil];
          if (componentDefinition==(GSWComponentDefinition*)GSNotFoundMarker)
            componentDefinition=nil;
          else if (componentDefinition)
            isCachedComponent=YES;
        };
      NSDebugMLLog(@"gswcomponents",@"D componentDefinition for %@ %s cached",aName,(componentDefinition ? "" : "NOT"));
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
      NSLog(@"EXCEPTION: allFrameworks pathes=%@",[[NSBundle allFrameworks] valueForKey:@"resourcePath"]);
      ExceptionRaise(GSWPageNotFoundException,
                     @"Unable to create component definition for %@ for languages: %@ (no componentDefinition).",
                     aName,
                     languages);
    };
#ifdef DEBUG
  stopDate=[NSDate date];
#endif
  if (componentDefinition)
    {
#ifdef DEBUG
      [self statusDebugWithFormat:@"Component %@ %s language %@ (%sCached) search time: %.3f s",
            aName,
            (language ? "" : "no"),
            (language ? language : @""),
            (isCachedComponent ? "" : "Not "),
            [stopDate timeIntervalSinceDate:startDate]];
#else
      [self statusDebugWithFormat:@"Component %@ %s language %@ (%sCached)",
            aName,
            (language ? "" : "no"),
            (language ? language : @""),
            (isCachedComponent ? "" : "Not ")];
#endif
    };
#ifdef DEBUG
  NSDebugMLLog(@"application",@"%s componentDefinition (%p) for %@ class=%@ %s. search time: %.3f s",
               (componentDefinition ? "FOUND" : "NOTFOUND"),
               componentDefinition,
               aName,
               (componentDefinition ? [[componentDefinition class] description]: @""),
               (componentDefinition ? (isCachedComponent ? "(Cached)" : "(Not Cached)") : ""),
	       [stopDate timeIntervalSinceDate:startDate]);
#else
  NSDebugMLLog(@"application",@"%s componentDefinition (%p) for %@ class=%@ %s.",
               (componentDefinition ? "FOUND" : "NOTFOUND"),
               componentDefinition,
               aName,
               (componentDefinition ? [[componentDefinition class] description]: @""),
               (componentDefinition ? (isCachedComponent ? "(Cached)" : "(Not Cached)") : ""));
#endif
  LOGObjectFnStop();
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
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"aName=%@",aName);
  for(iName=0;!path && iName<2;iName++)
    {
      resourceName=[aName stringByAppendingString:GSWPagePSuffix[GSWebNamingConvForRound(iName)]];
      htmlResourceName=[aName stringByAppendingString:GSWComponentTemplatePSuffix];
      NSDebugMLLog(@"gswcomponents",@"resourceName=%@",resourceName);
      resourceManager=[self resourceManager];
      path=[resourceManager pathForResourceNamed:resourceName
                            inFramework:nil
                            language:language];
      NSDebugMLLog(@"application",@"path=%@",path);
      if (!path)
	{
	  NSArray* frameworks=[self lockedComponentBearingFrameworks];
	  NSBundle* framework=nil;
	  int frameworkN=0;
	  for(frameworkN=0;frameworkN<[frameworks count] && !path;frameworkN++)
            {
              framework=[frameworks objectAtIndex:frameworkN];
              NSDebugMLLog(@"gswcomponents",@"TRY framework=%@",framework);
              path=[resourceManager pathForResourceNamed:resourceName
                                    inFramework:[framework bundleName]
                                    language:language];
              if (!path)
                {
                  path=[resourceManager pathForResourceNamed:htmlResourceName
                                        inFramework:[framework bundleName]
                                        language:language];
                };
              if (path)
                {
                  NSDebugMLLog(@"gswcomponents",@"framework=%@ class=%@",framework,[framework class]);
                  NSDebugMLLog(@"gswcomponents",@"framework bundlePath=%@",[framework bundlePath]);
                  frameworkName=[framework bundlePath];
                  NSDebugMLLog(@"gswcomponents",@"frameworkName=%@",frameworkName);
                  frameworkName=[frameworkName lastPathComponent];
                  NSDebugMLLog(@"gswcomponents",@"frameworkName=%@",frameworkName);
                  frameworkName=[frameworkName stringByDeletingPathExtension];
                  NSDebugMLLog(@"gswcomponents",@"frameworkName=%@",frameworkName);
                };
            };
	  NSDebugMLLog(@"application",@"path=%@",path);
	};
    };
  if (path)
    {
      url=[resourceManager urlForResourceNamed:resourceName
                           inFramework:frameworkName	//NEW
                           languages:(language ? [NSArray arrayWithObject:language] : nil)
                           request:nil];
      NSDebugMLLog(@"gswcomponents",@"url=%@",url);
      NSDebugMLLog(@"gswcomponents",@"frameworkName=%@",frameworkName);
      NSDebugMLog(!@"Component %@ Found at=%@",aName,path);
      componentDefinition=[[[GSWComponentDefinition alloc] initWithName:aName
                                                           path:path
                                                           baseURL:url
                                                           frameworkName:frameworkName] autorelease];
    };
  LOGObjectFnStop();
  return componentDefinition;
};

//--------------------------------------------------------------------
-(NSArray*)lockedComponentBearingFrameworks
{
  //OK
  NSArray* array=nil;
  NSMutableArray* allFrameworks=nil;
  LOGObjectFnStart();
  allFrameworks=[[NSBundle allFrameworks] mutableCopy];
  [allFrameworks addObjectsFromArray:[NSBundle allBundles]];
  //NSDebugMLLog(@"gswcomponents",@"allFrameworks=%@",allFrameworks);
  //NSDebugFLLog(@"gswcomponents",@"allFrameworks pathes=%@",[allFrameworks valueForKey:@"resourcePath"]);
  array=[self lockedInitComponentBearingFrameworksFromBundleArray:allFrameworks];
  NSDebugMLLog(@"gswcomponents",@"array=%@",array);
  [allFrameworks release];

  LOGObjectFnStop();
  return array;
};

//--------------------------------------------------------------------
-(NSArray*)lockedInitComponentBearingFrameworksFromBundleArray:(NSArray*)bundles
{
  NSMutableArray* array=nil;
  int i=0;
  NSBundle* bundle=nil;
  NSDictionary* bundleInfo=nil;
  id hasGSWComponents=nil;
  LOGObjectFnStart();
  array=[NSMutableArray array];
  for(i=0;i<[bundles count];i++)
    {
      bundle=[bundles objectAtIndex:i];
      //NSDebugMLLog(@"gswcomponents",@"bundle=%@",bundle);
      //NSDebugMLLog(@"gswcomponents",@"bundle resourcePath=%@",[bundle resourcePath]);
      bundleInfo=[bundle infoDictionary];
      //NSDebugMLLog(@"gswcomponents",@"bundleInfo=%@",bundleInfo);
      hasGSWComponents=[bundleInfo objectForKey:@"HasGSWComponents"];
      //NSDebugMLLog(@"gswcomponents",@"hasGSWComponents=%@",hasGSWComponents);
      //NSDebugMLLog(@"gswcomponents",@"hasGSWComponents class=%@",[hasGSWComponents class]);
      if (boolValueFor(hasGSWComponents))
        {
          [array addObject:bundle];
          NSDebugMLLog(@"gswcomponents",@"Add %@",[bundle bundleName]);
        };
    };
  //  NSDebugMLLog(@"gswcomponents",@"_array=%@",_array);
  LOGObjectFnStop();
  return array;
};


@end

//====================================================================
@implementation GSWApplication (GSWApplicationE)

//--------------------------------------------------------------------
-(void)setContextClassName:(NSString*)className
{
  NSAssert(NO,@"TODO");
}

//--------------------------------------------------------------------
-(NSString*)contextClassName
{
  NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
  NSString* contextClassName=[userDefaults objectForKey:GSWOPT_Context[GSWebNamingConv]];
  NSAssert([contextClassName length]>0,@"No contextClassName");
  return contextClassName;
}

//--------------------------------------------------------------------
-(GSWContext*)createContextForRequest:(GSWRequest*)aRequest
{
  GSWContext* context=nil;
  NSString* contextClassName=[self contextClassName];
  Class contextClass=NSClassFromString(contextClassName);
  NSAssert1(contextClass,@"No contextClass named '%@'",contextClassName);
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
-(GSWResponse*)createResponseInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  NSString* responseClassName=[self responseClassName];
  Class responseClass=NSClassFromString(responseClassName);
  NSAssert1(responseClass,@"No responseClass named '%@'",responseClassName);
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

//--------------------------------------------------------------------
-(GSWRequest*)createRequestWithMethod:(NSString*)aMethod
                                  uri:(NSString*)anURL
                          httpVersion:(NSString*)aVersion
                              headers:(NSDictionary*)headers
                              content:(NSData*)content
                             userInfo:(NSDictionary*)userInfo
{
  GSWRequest* request=nil;
  NSString* requestClassName=[self requestClassName];
  Class requestClass=NSClassFromString(requestClassName);
  NSAssert1(requestClass,@"No requestClass named '%@'",requestClassName);
  if (requestClass)
    {
      request=[[[requestClass alloc]initWithMethod:aMethod
                                    uri:anURL
                                    httpVersion:aVersion
                                    headers:headers
                                    content:content
                                    userInfo:userInfo]autorelease];
    }
  if (!request)
    {
      //TODO: throw cleaner exception
      NSAssert(NO,@"Can't create request");
    };
  return request;
};

//--------------------------------------------------------------------
-(GSWResourceManager*)createResourceManager
{
  NSString* resourceManagerClassName=[[self class] resourceManagerClassName];
  Class resourceManagerClass=Nil;
  if (!resourceManagerClassName)
    resourceManagerClassName=@"GSWResourceManager";
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
  if (!statisticsStoreClassName)
    statisticsStoreClassName=@"GSWStatisticsStore";
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
  if (!sessionStoreClassName)
    sessionStoreClassName=@"GSWServerSessionStore";
  sessionStoreClass=NSClassFromString(sessionStoreClassName);
  NSAssert1(sessionStoreClass,@"No sessionStoreClass named %@",
            sessionStoreClassName);
  return [[sessionStoreClass new]autorelease];
};

//--------------------------------------------------------------------
-(void)_discountTerminatedSession
{
  int activeSessionsCount=1;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      [self lockedDecrementActiveSessionCount];
      activeSessionsCount=[self activeSessionsCount];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In lockedDecrementActiveSessionCount...");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  if ([self isRefusingNewSessions] && activeSessionsCount<=_minimumActiveSessionsCount)
    {
      NSLog(@"Application is refusing new session and active sessions count <= minimum session count. Will terminate");
      [self terminate];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_finishInitializingSession:(GSWSession*)aSession
{
  //OK
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      [[GSWResourceManager _applicationGSWBundle] initializeObject:aSession
                                                  fromArchiveNamed:@"Session"];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In initializeObject:fromArchiveNamed:");
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
-(GSWSession*)_initializeSessionInContext:(GSWContext*)aContext
{
  GSWSession* session=nil;
  LOGObjectFnStart();
  if ([self isRefusingNewSessions])
    {
      LOGError0(@"Try to initialize session with isRefusingNewSessions evaluation to YES");
      [aContext _setIsRefusingThisRequest:YES];
    };
  [self lock];
  NS_DURING
    {
      [self lockedIncrementActiveSessionCount];
      session=[self createSessionForRequest:[aContext request]];
      NSDebugMLLog(@"sessions",@"session:%@",session);
      NSDebugMLLog(@"sessions",@"session ID:%@",[session sessionID]);
      if (session)
        {
          [aContext _setSession:session];
          [session awakeInContext:aContext];
          [[NSNotificationCenter defaultCenter]postNotificationName:@"SessionDidCreateNotification"
                                               object:session];
        }
      else
        {
          NSDebugMLog(@"Unable to create session");
          [self lockedDecrementActiveSessionCount];
        };
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In _initializeSessionInContext:");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return session;
};

//--------------------------------------------------------------------
-(int)lockedDecrementActiveSessionCount
{
  LOGObjectFnStart();
  _activeSessionsCount--;
  LOGObjectFnStop();
  return _activeSessionsCount;
};

//--------------------------------------------------------------------
-(int)lockedIncrementActiveSessionCount
{
  LOGObjectFnStart();
  _activeSessionsCount++;
  LOGObjectFnStop();
  return _activeSessionsCount;
};

//--------------------------------------------------------------------
-(int)_activeSessionsCount
{
  return _activeSessionsCount;
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationF)

//--------------------------------------------------------------------
-(void)_setContext:(GSWContext*)aContext
{
  NSMutableDictionary* threadDictionary=nil;
  LOGObjectFnStart();
  threadDictionary=GSCurrentThreadDictionary();
  if (aContext)
    [threadDictionary setObject:aContext
                      forKey:GSWThreadKey_Context];
  else
    [threadDictionary removeObjectForKey:GSWThreadKey_Context];  
  //  ASSIGN(context,_context);
  NSDebugMLLog(@"application",@"context:%p",(void*)aContext);
  NSDebugMLLog(@"application",@"context retain count:%p",[aContext retainCount]);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
// Internal Use only
-(GSWContext*)_context
{
  GSWContext* context=nil;
  NSMutableDictionary* threadDictionary=nil;
  LOGObjectFnStart();
  threadDictionary=GSCurrentThreadDictionary();
  context=[threadDictionary objectForKey:GSWThreadKey_Context];
  NSDebugMLLog(@"application",@"context:%p",(void*)context);
  LOGObjectFnStop();
  return context;
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationG)

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

@end

//====================================================================
@implementation GSWApplication (GSWApplicationI)

//--------------------------------------------------------------------
-(BOOL)_isPageRecreationEnabled
{
  return _pageRecreationEnabled;
};

//--------------------------------------------------------------------
-(void)_touchPrincipalClasses
{
  NSArray* allFrameworks=nil;
  int frameworkN=0;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      //????
      allFrameworks=[NSBundle allFrameworks];
      for(frameworkN=0;frameworkN<[allFrameworks count];frameworkN++)
        {
          //Not used yet NSDictionary* infoDictionary=[[allFrameworks objectAtIndex:frameworkN] infoDictionary];
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
//appellé quand le moteur est fermé 
-(void)_connectionDidDie:(id)unknown
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
-(void)_setShouldKill:(BOOL)flag
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
  id remoteMonitor=nil;
  NSString* monitorApplicationName=nil;
  int port=0;
  LOGObjectFnStart();
  monitorApplicationName=[self _monitorApplicationName];
  port=[[self class]intPort];
  remoteMonitor=[self _remoteMonitor];
  LOGObjectFnStop();
  return (remoteMonitor!=nil);
};

//--------------------------------------------------------------------
-(id)_remoteMonitor
{
  LOGObjectFnStart();
  if (!_remoteMonitor)
    {
      NSString* monitorHost=[self _monitorHost];
      NSNumber* workerThreadCount=[[self class]workerThreadCount];
      id proxy=nil;
      NSDebugFLLog(@"monitor",@"monitorHost=%@",monitorHost);
      NSDebugFLLog(@"monitor",@"workerThreadCount=%@",workerThreadCount);
      [NSDistantObject setDebug:YES];
      _remoteMonitorConnection = [NSConnection connectionWithRegisteredName:GSWMonitorServiceName
                                               host:monitorHost];
      proxy=[_remoteMonitorConnection rootProxy];
      _remoteMonitor=[proxy targetForProxy];
      [self _synchronizeInstanceSettingsWithMonitor:_remoteMonitor];
    };
  LOGObjectFnStop();
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
  NSNumber* port=[[self class]port];
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
  Class gswadaptorClass=nil;
  Class adaptorClass=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"application",@"adaptor name:%@",name);
  gswadaptorClass=[GSWAdaptor class];
  NSAssert([name length]>0,@"No adaptor name");
  adaptorClass=NSClassFromString(name);
  NSAssert1(adaptorClass,@"No adaptor named '%@'",name);
  if (adaptorClass)
    {
      if (ClassIsKindOfClass(adaptorClass,gswadaptorClass))
        {
          adaptor=[[[adaptorClass alloc] initWithName:name
                                         arguments:arguments] autorelease];
          NSDebugMLLog(@"application",@"adaptor:%@",adaptor);
        }
      else
        {
          NSAssert1(NO,@"adaptor of class %@ is not a GSWAdaptor",name);
        };
    };
  LOGObjectFnStop();
  return adaptor;
};

@end

//====================================================================
@implementation GSWApplication (GSWCacheManagement)

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

@end

//====================================================================
@implementation GSWApplication (GSWSessionManagement)

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
                   object_get_class_name(self)];
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
  LOGObjectFnStart();
  session=[aContext existingSession];
  NSDebugMLLog(@"sessions",@"session=%@",session);
  if (session)
    {
      [self _saveSessionForContext:aContext];
      NSDebugMLLog(@"sessions",@"session=%@",session);
      NSDebugMLLog(@"sessions",@"sessionStore=%@",_sessionStore);
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_saveSessionForContext:(GSWContext*)aContext
{
  GSWSession* session=nil;
  LOGObjectFnStart();
  session=[aContext existingSession];
  NSDebugMLLog(@"sessions",@"session=%@",session);
  if (session)
    {
      NS_DURING
	{
	  [session sleepInContext:aContext];
	  NSDebugMLLog(@"sessions",@"session=%@",session);
	  [_sessionStore checkInSessionForContext:aContext];
	  NSDebugMLLog(@"sessions",@"session=%@",session);
	  [aContext _setSession:nil];
	  NSDebugMLLog(@"sessions",@"session=%@",session);
	  NSDebugMLLog(@"sessions",@"sessionStore=%@",_sessionStore);
	}
      NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                   @"In _saveSessionForContext:");
	  LOGException(@"%@ (%@)",localException,[localException reason]);
	  [localException raise];
	}
      NS_ENDHANDLER;
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWSession*)restoreSessionWithID:(NSString*)sessionID
                         inContext:(GSWContext*)aContext
{
  GSWSession* session=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"Start Restore Session. sessionID=%@",sessionID);
  [aContext _setRequestSessionID:sessionID];
  NSDebugMLLog(@"sessions",@"sessionID=%@",sessionID);
  NSDebugMLLog(@"sessions",@"_sessionStore=%@",_sessionStore);
  session=[self _restoreSessionWithID:sessionID
                inContext:aContext];
  [aContext _setRequestSessionID:nil]; //ATTN: pass nil for unkwon reason
  NSDebugMLLog(@"sessions",@"session=%@",session);
  NSDebugMLLog(@"sessions",@"Stop Restore Session. sessionID=%@",sessionID);
  LOGObjectFnStop();
  return session;
};

//--------------------------------------------------------------------
-(GSWSession*)_restoreSessionWithID:(NSString*)sessionID
                          inContext:(GSWContext*)aContext
{
  //OK
  GSWRequest* request=nil;
  GSWSession* session=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"aContext=%@",aContext);
  request=[aContext request];
  NSDebugMLLog(@"sessions",@"request=%@",request);
  NSDebugMLLog(@"sessions",@"sessionID_=%@",sessionID);
  NSDebugMLLog(@"sessions",@"sessionStore=%@",_sessionStore);
  session=[_sessionStore checkOutSessionWithID:sessionID
                         request:request];
  [aContext _setSession:session];//even if nil :-)
  [session awakeInContext:aContext];//even if nil :-)
  NSDebugMLLog(@"sessions",@"session=%@",session);
  LOGObjectFnStop();
  return session;
};

//--------------------------------------------------------------------
-(Class)_sessionClass
{
  //OK
  Class sessionClass=nil;
  LOGObjectFnStart();
  sessionClass=[[GSWResourceManager _applicationGSWBundle] scriptedClassWithName:GSWClassName_Session
                                                           superclassName:GSWClassName_Session];
  if (!sessionClass)
    sessionClass=NSClassFromString(GSWClassName_Session);

/*

  //Search Compiled Class "Session" (subclass of GSWsession)
  gswsessionClass=NSClassFromString();
  sessionClass=NSClassFromString(GSWClassName_Session);

  //If not found, search for library "Session" in application .gswa directory
  if (!_sessionClass)
	{
	  NSString* sessionPath=[self pathForResourceNamed:@"session"
								  ofType:nil];
	  Class _principalClass=[self libraryClassWithPath:sessionPath];
	  NSDebugMLLog(@"application",@"_principalClass=%@",_principalClass);
	  if (_principalClass)
		{
		  _sessionClass=NSClassFromString(GSWClassName_Session);
		  NSDebugMLLog(@"application",@"sessionClass=%@",_sessionClass);
		};
	};

  //If not found, search for scripted "Session" in application .gswa directory
  if (!sessionClass)
	{
	  //TODO
	};

  //If not found, search for scripted "Session" in a session.gsws file
  if (!sessionClass)
	{
	  //TODO
	};

  if (!sessionClass)
	{
	  sessionClass=_gswsessionClass;
	}
  else
	{
	  if (!ClassIsKindOfClass(_sessionClass,_gswsessionClass))
		{
		  //TODO exception
		  NSDebugMLLog(@"application",@"session class is not a kind of GSWSession\n");
		}
	};
  NSDebugMLLog(@"application",@"_sessionClass:%@",_sessionClass);
*/
  LOGObjectFnStop();
  return sessionClass;
};

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
  LOGObjectFnStart();
  session=[self _createSessionForRequest:aRequest];
  NSDebugMLLog(@"sessions",@"session:%@",session);
  [_statisticsStore _applicationCreatedSession:session];
  LOGObjectFnStop();
  return session;
};

//--------------------------------------------------------------------
-(GSWSession*)_createSessionForRequest:(GSWRequest*)aRequest
{
  //OK
  Class sessionClass=Nil;
  GSWSession* session=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      sessionClass=[self _sessionClass];
      NSDebugMLLog(@"sessions",@"sessionClass:%@",sessionClass);
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In _sessionClass");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  if (!sessionClass)
    {
      //TODO erreur
      NSDebugMLLog0(@"application",@"No Session Class");
      NSAssert(NO,@"Can't find session class");
    }
  else
    {
      session=[[sessionClass new]autorelease];
    };
  NSDebugMLLog(@"sessions",@"session:%@",session);
  LOGObjectFnStop();
  return session;
};

@end

//====================================================================
@implementation GSWApplication (GSWPageManagement)

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
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(GSWComponent*)pageWithName:(NSString*)aName
                   inContext:(GSWContext*)aContext
{
  GSWComponent* component=nil;
  LOGObjectFnStart();
  NSAssert(aContext,@"No Context");
  component=[self _pageWithName:aName
                  inContext:aContext];
  LOGObjectFnStop();
  return component;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)defaultPageName
{
  return GSWMainPageName;
};

//--------------------------------------------------------------------
-(GSWComponent*)_pageWithName:(NSString*)aName
                    inContext:(GSWContext*)aContext
{
  //OK
  GSWComponent* component=nil;
  GSWComponentDefinition* componentDefinition=nil;
  NSArray* languages=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"info",@"aName %p=%@",aName,aName);
  if (!aContext)
    [NSException raise:NSInvalidArgumentException 
                 format:@"%s No context when calling %@",
                 object_get_class_name(self),
                 NSStringFromSelector(_cmd)];
  [self lock];
  NS_DURING
    {
      // If the pageName is empty, try to get one from -defaultPageName
      if ([aName length]<=0)
        aName=[self defaultPageName];

      // If the pageName is still empty, use a default one ("Main")
      if ([aName length]<=0)
        aName=GSWMainPageName;

      NSDebugMLLog(@"info",@"aName=%@",aName);

      // Retrieve context languages
      languages=[aContext languages];
      NSDebugMLLog(@"info",@"languages=%@",languages);

      // Find component definition for pageName and languages
      componentDefinition=[self lockedComponentDefinitionWithName:aName
                                languages:languages];
      NSDebugMLLog(@"info",@"componentDefinition %p=%@ (%@)",
                   componentDefinition,
                   componentDefinition,
                   [componentDefinition class]);
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In lockedComponentDefinitionWithName:");
      LOGException(@"exception=%@",localException);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  NS_DURING
    {
      if (!componentDefinition)
        {
          //TODO
          NSDebugMLLog0(@"info",@"GSWApplication _pageWithName no componentDefinition");
        }
      else
        {
          // As we've found a component defintion, we create an instance (an object of class GSWComponent)
          NSAssert(aContext,@"No Context");
          component=[componentDefinition componentInstanceInContext:aContext];
          NSAssert(aContext,@"No Context");
          // Next we awake it
          [component awakeInContext:aContext];

          // And flag it as a page.
          [component _setIsPage:YES];
        };
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In componentInstanceInContext:");
      LOGException(@"exception=%@",localException);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return component;
};
@end

//====================================================================
@implementation GSWApplication (GSWElementCreation)

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
  NSDebugMLLog(@"info",@"elementClass %p:%@",elementClass,elementClass);
  NSDebugMLLog(@"info",@"elementClass superClass:%@",[elementClass superClass]);
  if (elementClass && !ClassIsKindOfClass(elementClass,[GSWComponent class]))
    {
      NSDebugMLLog(@"info",@"CREATE Element of Class %p:%@",aName,aName);
      element=[[[elementClass alloc] initWithName:aName
                                     associations:someAssociations
                                     template:templateElement]
                autorelease];
      NSDebugMLLog(@"info",@"Created Element %p: %@",element,element);
    }
  else
    {
      GSWComponentDefinition* componentDefinition=nil;
      componentDefinition=[self lockedComponentDefinitionWithName:aName
                                 languages:languages];
      if (componentDefinition)
        {
          NSDebugMLLog(@"info",@"CREATE SubComponent %p:%@",aName,aName);
          element=[componentDefinition componentReferenceWithAssociations:someAssociations
                                         template:templateElement];
          NSDebugMLLog(@"info",@"Created SubComponent %p: %@",element,element);
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
  SEL registerForEventsSEL=NULL;
  SEL unregisterForEventsSEL=NULL;
  NSDebugMLLog0(@"application",@"GSWApplication run");
  LOGObjectFnStart();
  NSDebugMLog(@"ThreadID=%p\n",(void*)objc_thread_id());
  registerForEventsSEL=@selector(registerForEvents);
  unregisterForEventsSEL=@selector(unregisterForEvents);
  NSDebugMLLog(@"application",@"adaptors=%@",_adaptors);
  [_adaptors makeObjectsPerformSelector:registerForEventsSEL];
  NSDebugMLLog0(@"application",@"NSRunLoop run");
	  //call adaptor run
	  //call self _openInitialURL
  NSDebugMLLog(@"application",@"GSCurrentThreadDictionary()=%@",GSCurrentThreadDictionary());
  NSDebugMLLog(@"application",@"[NSRunLoop currentRunLoop]=%@",[NSRunLoop currentRunLoop]);
  NSAssert(_currentRunLoop,@"No runLoop");

  NS_DURING
    {
      [_currentRunLoop run];
    }
  NS_HANDLER
    {
      NSLog(@"%@",localException);
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    }
  NS_ENDHANDLER;
  
  NSDebugMLLog0(@"application",@"NSRunLoop end run");
  [_adaptors makeObjectsPerformSelector:unregisterForEventsSEL];
  NSDebugMLLog0(@"application",@"GSWApplication end run");
  LOGObjectFnStop();
};

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
//  GSWLogC("GC** GarbageCollector collectGarbages START");
  printf("GC** GarbageCollector collectGarbages START\n");
//TODO-NOW  [GarbageCollector collectGarbages];//LAST //CLEAN
//  GSWLogC("GC** GarbageCollector collectGarbages STOP");
  printf("GC** GarbageCollector collectGarbages STOP\n");
};

//--------------------------------------------------------------------
//setTimeOut:

-(void)setTimeOut:(NSTimeInterval)aTimeInterval
{
  NSDebugMLLog(@"sessions",@"timeOut=%ld",(long)aTimeInterval);
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
};

//--------------------------------------------------------------------
//terminate
-(void)terminate 
{
  NSTimer* timer=nil;
  _terminating = YES;
  timer=[NSTimer timerWithTimeInterval:0
                 target:self
                 selector:@selector(_handleQuitTimer:)
                 userInfo:nil
                 repeats:NO];
  [GSWApp addTimer:timer];
};

//--------------------------------------------------------------------
-(void)_scheduleApplicationTimerForTimeInterval:(NSTimeInterval)aTimeInterval
{
  LOGObjectFnStart();
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
  LOGObjectFnStart();
  NSDebugMLLog(@"application",@"[self runLoop]=%p",(void*)[self runLoop]);
  NSDebugMLLog(@"application",@"currentMode=%@",[[self runLoop]currentMode]);
  NSDebugMLLog(@"application",@"NSDefaultRunLoopMode=%@",NSDefaultRunLoopMode);
  NSDebugMLLog(@"application",@"aTimer=%@",aTimer);
  NSDebugMLLog(@"application",@"aTimer fireDate=%@",[aTimer fireDate]);
  [[self runLoop]addTimer:aTimer
                 forMode:NSDefaultRunLoopMode];
  NSDebugMLLog(@"application",@"limitDateForMode=%@",[[self runLoop]limitDateForMode:NSDefaultRunLoopMode]);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)addTimer:(NSTimer*)aTimer
{
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      [self lockedAddTimer:aTimer];
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
  LOGObjectFnNotImplemented();	//TODOFN
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
  LOGObjectFnNotImplemented();	//TODOFN
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

@end

//====================================================================
@implementation GSWApplication (GSWRequestHandling)

-(GSWResponse*)checkAppIfRefused:(GSWRequest*)aRequest
{
  NSDictionary* requestHandlerValues=nil;
  GSWResponse* response=nil;
  NSString* sessionID=nil;
  BOOL refuseRequest = NO;

  LOGObjectFnStart();

  NS_DURING
    {
//      NSLog(@"Application : checkAppIfRefused");
//      NSLog(@"Application : allSessionIDs = %@", [_sessionStore allSessionIDs]);
      requestHandlerValues=[GSWComponentRequestHandler _requestHandlerValuesForRequest:aRequest];
      if (requestHandlerValues) 
        {
//          NSLog(@"Application : requestHandlerValues is set");

          sessionID=[requestHandlerValues objectForKey:GSWKey_SessionID[GSWebNamingConv]];
          if (!sessionID) 
            {
              NSLog(@"Application : sessionID is nil");

              if ([self isRefusingNewSessions])
                {
                  NSLog(@"refuseRequest !");
                  refuseRequest = YES;
                };
            } 
          else 
            {
//             NSLog(@"Application : sessionID found : %@", sessionID);
//             NSLog(@"Application : allSessionIDs = %@", [_sessionStore allSessionIDs]);
              // check for existing session ID
              if (![_sessionStore containsSessionID:sessionID]) 
                {
//                  NSLog(@"Application : sessionStore does not contain _sessionID");
                  if ([self isRefusingNewSessions])
                    refuseRequest = YES;				
                }
            }
          if (refuseRequest)
            {
              NSLog(@"Application : refuseRequest == YES ,generate Response");
              // generate response, to refuse the request
              response=[GSWResponse generateRefusingResponseInContext:nil  
                                    forRequest:aRequest];
              if (response) 
                [response _finalizeInContext:nil]; //DO Call _finalizeInContext: !			
            }
        }
    }
  NS_HANDLER
    {
    }
  NS_ENDHANDLER;
  
  LOGObjectFnStop();
  return response;
}

-(GSWResponse*)dispatchRequest:(GSWRequest*)aRequest
{
  //OK
  GSWResponse* response=nil;
  GSWRequestHandler* requestHandler=nil;
  
  LOGObjectFnStart();
#ifndef NDEBUG
  [self lock];
  GSWApplicationDebugSetChange();
  [self unlock];
#endif

  NS_DURING
    {
      ASSIGN(_lastAccessDate,[NSDate date]);
      
      [[NSNotificationCenter defaultCenter]postNotificationName:@"ApplicationWillDispatchRequestNotification"
                                           object:aRequest];
      
      response = [self checkAppIfRefused:aRequest];
      if (!response) 
        {
          NSDebugMLLog(@"requests",@"aRequest=%@",aRequest);
          
          requestHandler=[self handlerForRequest:aRequest];
          NSDebugMLLog(@"requests",@"requestHandler=%@",requestHandler);
          
          if (!requestHandler)
            requestHandler=[self defaultRequestHandler];
          
          NSDebugMLLog(@"requests",@"requestHandler=%@",requestHandler);
          
          if (!requestHandler)
            {
              NSDebugMLLog0(@"application",@"GSWApplication dispatchRequest: no request handler");
              //TODO error
            }
          else
            {
              NSDebugMLLog(@"requests",@"sessionStore=%@",_sessionStore);
              response=[requestHandler handleRequest:aRequest];
              NSDebugMLLog(@"requests",@"sessionStore=%@",_sessionStore);
              [self _resetCache];
              NSDebugMLLog(@"requests",@"sessionStore=%@",_sessionStore);
            };
          if (!response)
            {
              //TODO RESPONSE_PB
            };
          [[NSNotificationCenter defaultCenter]postNotificationName:@"ApplicationDidDispatchRequestNotification"
                                               object:response];
          [aRequest _setContext:nil];
        };
    }
  NS_HANDLER
    {
      NSLog(@"EXCEPTION: %@",localException);
    }
  NS_ENDHANDLER;
  LOGObjectFnStop();
  return response;
};

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
  //OK
  GSWSession* session=nil;
  LOGObjectFnStart();
  [aContext setValidate:YES];
  session=[aContext existingSession];
  [session takeValuesFromRequest:aRequest
           inContext:aContext];
  [aContext setValidate:NO];
  LOGObjectFnStop();
};


//--------------------------------------------------------------------
//invokeActionForRequest:inContext:

-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext 
{
  //OK
  GSWElement* element=nil;
  GSWSession* session=nil;
  LOGObjectFnStart();
  NS_DURING
    {
      session=[aContext existingSession];
      element=[session invokeActionForRequest:aRequest
                       inContext:aContext];
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

-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext 
{
  GSWRequest* request=nil;
  GSWSession* session=nil;
  LOGObjectFnStart();

  request=[aContext request];
  NSDebugMLog(@"request=%p",request);
  session=[aContext existingSession];
  NSDebugMLog(@"session=%p",session);

  if ([aContext _isRefusingThisRequest])
    {
      NSLog(@"Context refuseThisRequest. Will redirect to available instance");
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
          LOGException(@"exception in %@ appendToResponse:inContext",
                       [self class]);
          LOGException(@"exception=%@",localException);
          localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                                  @"In %@ appendToResponse:inContext",
                                                                  [self class]);
          LOGException(@"exception=%@",localException);
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
          LOGException(@"exception in %@ _setRecordingHeadersToResponse...",
                       [self class]);
          LOGException(@"exception=%@",localException);
          localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                                  @"In %@ _setRecordingHeadersToResponse...",
                                                                  [self class]);
          LOGException(@"exception=%@",localException);
          [localException raise];
        }
      NS_ENDHANDLER;
    };
  LOGObjectFnStop();
};

-(void)_setRecordingHeadersToResponse:(GSWResponse*)aResponse
                           forRequest:(GSWRequest*)aRequest
                            inContext:(GSWContext*)aContext
{
  LOGObjectFnStart();

  NSDebugMLog(@"Recording Header=%@",
              [aRequest headerForKey:GSWHTTPHeader_Recording[GSWebNamingConv]]);

  if (_recorder
      && ([aRequest headerForKey:GSWHTTPHeader_Recording[GSWebNamingConv]]
          || [[self class] recordingPath]))
    {
      NSString* sessionID = nil;
      GSWSession* session = nil;
      NSString* header=nil;
      
      header=[NSString stringWithFormat:@"%d",[aRequest applicationNumber]];
      NSDebugMLog(@"header=%@",header);

      [aResponse setHeader:header
                 forKey:GSWHTTPHeader_RecordingApplicationNumber[GSWebNamingConv]];
      
      if ([aContext hasSession])
        {
          session = [aContext session];
          sessionID = [session sessionID];
        }
      else
        sessionID = [aRequest sessionID];

      NSDebugMLog(@"sessionID=%@",sessionID);

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

//Not used now. For future exception handling rewrite
-(GSWResponse*)_invokeDefaultException:(NSException*)exception
                                 named:(NSString*)name
                             inContext:(GSWContext*)aContext
{
  //TODO
  GSWResponse* response=nil;
  LOGObjectFnStart();
  response=[GSWResponse responseWithMessage:@"Exception Handling failed"
                        inContext:aContext
                        forRequest:nil];
  LOGObjectFnStop();
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
  LOGObjectFnStart();
  if (context)
    [context _putAwakeComponentsToSleep];
  else
    {
      LOGError0(@"No context !");
      context=[GSWContext contextWithRequest:nil];	  
      LOGError0(@"Really can't get context !");
    };
  //TODO Hack: verify that there is an application context otherswise, it failed in component Creation
  if (![self _context])
      [self _setContext:context];

  NS_DURING
    {
      errorPage=[self pageWithName:pageName
                      inContext:context];
      if (anException)
        [errorPage takeValue:anException
              forKey:@"exception"]; 
    }
  NS_HANDLER
    {
      // My God ! Exception on exception !
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In _handleException:inContext:");
      LOGException(@"exception=%@",localException);
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
          id monitor=nil;
          response=[errorPage generateResponse];
          
          //here ?
          monitor=[self _remoteMonitor];
          if (monitor)
            {
              //Not used yet NSString* monitorApplicationName=[self _monitorApplicationName];
              //TODO
            };
        }
      else
        {
          NSString* message=[NSString stringWithFormat:@"Exception Handling failed. Can't find Error Page named '%@'",
                                      pageName];
          response=[GSWResponse responseWithMessage:message
                                inContext:context
                                forRequest:nil];
        };
    };
  NSAssert(![response isFinalizeInContextHasBeenCalled],
           @"GSWApplication _handlePageRestorationErrorInContext: _finalizeInContext called for GSWResponse");
  LOGObjectFnStop();
  return response;
};

//--------------------------------------------------------------------
-(GSWResponse*)handleException:(NSException*)anException 
                     inContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"application",@"context=%@",aContext);
  NSDebugMLog(@"EXCEPTION=%@",anException);
  NS_DURING
    {
      response=[self _handleErrorWithPageNamed:GSWExceptionPageName[GSWebNamingConv]
                     exception:anException
                     inContext:aContext];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In _handleExcep
tion:inContext:");
      LOGException(@"exception=%@",localException);
      response=[GSWResponse responseWithMessage:@"Exception Handling failed"
                            inContext:aContext
                            forRequest:nil];
    }
  NS_ENDHANDLER;
  NSAssert(![response isFinalizeInContextHasBeenCalled],
           @"GSWApplication handleException: _finalizeInContext called for GSWRe
sponse");
  LOGObjectFnStop();
  return response;
};

//--------------------------------------------------------------------
//handlePageRestorationError
-(GSWResponse*)handlePageRestorationErrorInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  LOGObjectFnStart();
  NS_DURING
    {
      response=[self _handlePageRestorationErrorInContext:aContext];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In _handlePageRestorationErrorInContext:");
      LOGException(@"exception=%@",localException);
      response=[GSWResponse responseWithMessage:@"Exception Handling failed. Can't find Page Restoration Error Page"
                            inContext:aContext
                            forRequest:nil];
    }
  NS_ENDHANDLER;
  NSAssert(![response isFinalizeInContextHasBeenCalled],
           @"GSWApplication handlePageRestorationErrorInContext: _finalizeInContext called for GSWResponse");
  LOGObjectFnStop();
  return response;
};


//--------------------------------------------------------------------
//handlePageRestorationError
-(GSWResponse*)_handlePageRestorationErrorInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  LOGObjectFnStart();
  response=[self _handleErrorWithPageNamed:GSWPageRestorationErrorPageName[GSWebNamingConv]
                 exception:nil
                 inContext:aContext];
  LOGObjectFnStop();
  return response;
};

//--------------------------------------------------------------------
//handleSessionCreationError
-(GSWResponse*)handleSessionCreationErrorInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  LOGObjectFnStart();
  NS_DURING
    {
      response=[self _handleSessionCreationErrorInContext:aContext];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In _handleSessionCreationErrorInContext:");
      LOGException(@"exception=%@",localException);
      response=[GSWResponse responseWithMessage:@"Session Creation Error Handling failed."
                            inContext:aContext
                            forRequest:nil];
    }
  NS_ENDHANDLER;
  NSAssert(![response isFinalizeInContextHasBeenCalled],
           @"GSWApplication handleSessionCreationErrorInContext: _finalizeInContext called for GSWResponse");
  LOGObjectFnStop();
  return response;
};

//--------------------------------------------------------------------
//handleSessionCreationError
-(GSWResponse*)_handleSessionCreationErrorInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  LOGObjectFnStart();
  response=[self _handleErrorWithPageNamed:GSWSessionCreationErrorPageName[GSWebNamingConv]
                 exception:nil
                 inContext:aContext];
  LOGObjectFnStop();
  return response;
};

//--------------------------------------------------------------------
//handleSessionRestorationError

-(GSWResponse*)handleSessionRestorationErrorInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  LOGObjectFnStart();
  NS_DURING
    {
      response=[self _handleSessionRestorationErrorInContext:aContext];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In _handleSessionRestorationErrorInContext:");
      LOGException(@"exception=%@",localException);
      response=[GSWResponse responseWithMessage:@"Session Restoration Error Handling failed."
                            inContext:aContext
                            forRequest:nil];
    }
  NS_ENDHANDLER;
  NSAssert(![response isFinalizeInContextHasBeenCalled],
           @"GSWApplication handleSessionRestorationErrorInContext: _finalizeInContext called for GSWResponse");
  LOGObjectFnStop();
  return response;
};

//--------------------------------------------------------------------
//handleSessionRestorationError

-(GSWResponse*)_handleSessionRestorationErrorInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  LOGObjectFnStart();
  response=[self _handleErrorWithPageNamed:GSWSessionRestorationErrorPageName[GSWebNamingConv]
                 exception:nil
                 inContext:aContext];
  LOGObjectFnStop();
  return response;
};
@end

//====================================================================
@implementation GSWApplication (GSWConveniences)
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
  NSDebugMLog(@"setApplication:%p (of class %@) name:%@",
              application,
              [application class],
              [application name]);
  GSWApp=application;
};

@end

//====================================================================
@implementation GSWApplication (GSWHTMLTemplateParsingDebugging)
//--------------------------------------------------------------------
//setPrintsHTMLParserDiagnostics:

-(void)setPrintsHTMLParserDiagnostics:(BOOL)flag
{
  [self lock];
  NS_DURING
    {
      _printsHTMLParserDiagnostics=flag;
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
  //FIXME
//  return [GSWHTMLParser printsDiagnostics];
  return NO;
};

@end

//====================================================================
@implementation GSWApplication (GSWScriptedObjectSupport)
//--------------------------------------------------------------------
//scriptedClassWithPath:

-(Class)scriptedClassWithPath:(NSString*)path
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
//scriptedClassWithPath:encoding:

-(Class)scriptedClassWithPath:(NSString*)path
                     encoding:(NSStringEncoding)encoding
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(Class)_classWithScriptedClassName:(NSString*)aName
                          languages:(NSArray*)languages
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)_setClassFromNameResolutionEnabled:(BOOL)flag
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWApplication (GSWLibrarySupport)
//--------------------------------------------------------------------
//NDFN
-(Class)libraryClassWithPath:(NSString*)path
{
  Class aClass=nil;
  NSBundle* bundle=[NSBundle bundleWithPath:path];
  NSDebugMLLog(@"application",@"GSWApplication libraryClassWithPath:bundle=%@",bundle);
  if (bundle)
    {
      BOOL result=[bundle load];
      NSDebugMLLog(@"application",@"GSWApplication libraryClassWithPath:bundle load result=%d",result);
      aClass=[bundle principalClass];
      NSDebugMLLog(@"application",@"GSWApplication libraryClassWithPath:bundle class=%@",aClass);
    };
  return aClass;
};

@end

@implementation GSWApplication (GSWDebugging)

//--------------------------------------------------------------------
-(void)debugWithString:(NSString*)aString
{
  if ([[self class]isDebuggingEnabled])
    {
      fputs([aString cString],stderr);
      fputs("\n",stderr);
      fflush(stderr);
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
  va_list ap=NULL;
  va_start(ap,aFormat);
  [self debugWithFormat:aFormat
        arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)debugWithFormat:(NSString*)aFormat,...
{
  va_list ap=NULL;
  va_start(ap,aFormat);
  [GSWApp debugWithFormat:aFormat
          arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------

-(void)_setTracingAspect:(id)unknwon
                 enabled:(BOOL)enabled
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)aFormat,...
{
  va_list ap=NULL;
  va_start(ap,aFormat);
  [self logWithFormat:aFormat
        arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)logWithFormat:(NSString*)aFormat,...
{
  va_list ap=NULL;
  va_start(ap,aFormat);
  [GSWApp logWithFormat:aFormat
          arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)aFormat
           arguments:(va_list)arguments
{
  NSString* string=[NSString stringWithFormat:aFormat
                             arguments:arguments];
  fputs([string cString],stderr);
  fputs("\n",stderr);
  fflush(stderr);
};

//--------------------------------------------------------------------
-(void)logErrorWithFormat:(NSString*)aFormat,...
{
  va_list ap=NULL;
  va_start(ap,aFormat);
  [self logErrorWithFormat:aFormat
        arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)logErrorWithFormat:(NSString*)aFormat,...
{
  va_list ap=NULL;
  va_start(ap,aFormat);
  [GSWApp logErrorWithFormat:aFormat
          arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(void)logErrorWithFormat:(NSString*)aFormat
                arguments:(va_list)arguments
{
  const char* cString=NULL;
  NSString* string=[NSString stringWithFormat:aFormat
                             arguments:arguments];
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

@end

//====================================================================
//Same as GSWDebugging but it print messages on stdout AND call GSWDebugging methods
@implementation GSWApplication (GSWDebuggingStatus)

//--------------------------------------------------------------------
-(void)statusDebugWithString:(NSString*)aString
{
  if ([[self class]isStatusDebuggingEnabled])
    {
      fputs([aString cString],stdout);
      fputs("\n",stdout);
      fflush(stdout);
      [self debugWithString:aString];
    };
};

//--------------------------------------------------------------------
-(void)statusDebugWithFormat:(NSString*)aFormat
                   arguments:(va_list)arguments
{
  NSString* string=[NSString stringWithFormat:aFormat
                              arguments:arguments];
  [self statusDebugWithString:string];
};

//--------------------------------------------------------------------
-(void)statusDebugWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [self statusDebugWithFormat:aFormat
        arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)statusDebugWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [GSWApp statusDebugWithFormat:aFormat
          arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(void)statusLogWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [self statusLogWithFormat:aFormat
        arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)statusLogWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [GSWApp statusLogWithFormat:aFormat
          arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(void)statusLogWithFormat:(NSString*)aFormat
                 arguments:(va_list)arguments
{
  NSString* string=[NSString stringWithFormat:aFormat
                             arguments:arguments];
  fputs([string cString],stdout);
  fputs("\n",stdout);
  fflush(stdout);
  [self logWithFormat:@"%@",string];
};

//--------------------------------------------------------------------
-(void)statusLogErrorWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [self statusLogErrorWithFormat:aFormat
        arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
+(void)statusLogErrorWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [GSWApp statusLogErrorWithFormat:aFormat
          arguments:ap];
  va_end(ap);
};

//--------------------------------------------------------------------
-(void)statusLogErrorWithFormat:(NSString*)aFormat
                      arguments:(va_list)arguments
{
  const char* cString=NULL;
  NSString* string=[NSString stringWithFormat:aFormat
                             arguments:arguments];
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
  return _statisticsStore;
};

//--------------------------------------------------------------------
//setStatisticsStore:
-(void)setStatisticsStore:(GSWStatisticsStore*)statisticsStore
{
  ASSIGN(_statisticsStore,statisticsStore);
};

@end

//====================================================================
@implementation GSWApplication (MonitorableApplication)

//--------------------------------------------------------------------
//monitoringEnabled [deprecated]
-(BOOL)monitoringEnabled 
{
  return [self isMonitorEnabled];
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
  if (flag && [self isDirectConnectEnabled])
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
//logToMonitorWithFormat:
-(void)logToMonitorWithFormat:(NSString*)aFormat 
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//terminateAfterTimeInterval: [deprecated]
-(void)terminateAfterTimeInterval:(NSTimeInterval)aTimeInterval
{
  [self setTimeOut:aTimeInterval];
};

@end

//====================================================================
@implementation GSWApplication (GSWResourceManagerSupport)
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
  return _resourceManager;
};

@end

//====================================================================
@implementation GSWApplication (RequestDispatching)

//--------------------------------------------------------------------
-(GSWRequestHandler*)defaultRequestHandler
{
  return _defaultRequestHandler;
};

//--------------------------------------------------------------------
-(void)setDefaultRequestHandler:(GSWRequestHandler*)handler
{
  LOGObjectFnStart();
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
  LOGObjectFnStop();
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
  LOGObjectFnStart();
  handler=[_requestHandlers objectForKey:aKey];
  NSDebugMLogCond(!handler,@"_requestHandlers=%@",_requestHandlers);
  LOGObjectFnStop();
  return handler;
};

//--------------------------------------------------------------------
-(GSWRequestHandler*)handlerForRequest:(GSWRequest*)aRequest
{
  GSWRequestHandler* handler=nil;
  NSString* requestHandlerKey=nil;
  LOGObjectFnStart();
  requestHandlerKey=[aRequest requestHandlerKey];
  NSDebugMLLog(@"application",@"requestHandlerKey=%@",requestHandlerKey);
  handler=[self requestHandlerForKey:requestHandlerKey];
  NSDebugMLLog(@"application",@"handler=%@",handler);
  LOGObjectFnStop();
  return handler;
};

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
-(BOOL)isDirectConnectEnabled
{
  return [[[NSUserDefaults standardUserDefaults] 
            objectForKey:GSWOPT_DirectConnectEnabled[GSWebNamingConv]] boolValue];
};

//--------------------------------------------------------------------
-(void)setDirectConnectEnabled:(BOOL)flag
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
  [[GSWResourceManager _applicationGSWBundle] 
    scriptedClassWithName:GSWClassName_Application//TODO
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
  return (GSWRequestHandler*)[GSWComponentRequestHandler handler];
};

@end

//====================================================================
@implementation GSWApplication (GSWApplicationClassB)

//--------------------------------------------------------------------
+(id)defaultModelGroup
{
#if HAVE_GDL2 // GDL2 implementation
  //OK
  return [EOModelGroup defaultGroup];
#else
#ifdef TCSDB
  return [DBModelGroup defaultGroup];
#else
  LOGClassFnNotImplemented();
  return nil;
#endif
#endif
};

//--------------------------------------------------------------------
+(id)_modelGroupFromBundles:(id)bundles
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
  NSBundle* mainBundle=nil;
//  LOGClassFnNotImplemented();	//TODOFN
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
+(void)_setLockDefaultEditingContext:(BOOL)flag
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
+(void)_setAllowsConcurrentRequestHandling:(id)unknown
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
  NSLog(@"LGPL'ed software don't have license parameters. To find License Parameters, please try proprietary softwares");
};

@end

//====================================================================
@implementation GSWApplication (NDFN)

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
  LOGObjectFnStart();
  resourceManager=[self resourceManager];
  pathName=[resourceManager pathForResourceNamed:[NSString stringWithFormat:@"%@.%@",aName,type]
                            inFramework:aFrameworkName
                            languages:languages];
  NSDebugMLLog(@"application",@"pathName:%@",pathName);
  if (pathName)
    {
      NSString* propListString=[NSString stringWithContentsOfFile:pathName];
      propList=[propListString propertyList];
      if (!propList)
        {
          LOGSeriousError(@"Bad propertyList \n%@\n from file %@",
                          propListString,
                          pathName);
        };
    };
  LOGObjectFnStop();
  return propList;
};

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
  LOGClassFnStart();
  if ([classes count]>0)
    {
      int i=0;
      NSString* aClassName=nil;
      NSMutableArray* newClasses=nil;
      for(i=0;i<[classes count];i++)
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
                      LOGError(@"Can't create one of these classes %@ (super class: %@)",
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
  LOGClassFnStop();
  return ok;
#endif
};

//--------------------------------------------------------------------
+(void)addDynCreateClassName:(NSString*)className
              superClassName:(NSString*)superClassName
{
  LOGClassFnStart();
  NSDebugMLLog(@"gswdync",@"ClassName:%@ superClassName:%@\n",className,superClassName);
  [localDynCreateClassNames setObject:superClassName
                            forKey:className];
  LOGClassFnStop();
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
  return [[self resourceManager]pathForResourceNamed:(type ? [NSString stringWithFormat:@"%@.%@",aName,type] : aName)
                                inFramework:aFrameworkName
                                languages:languages];
};

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


//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aTableName
                      inFramework:(NSString*)aFrameworkName
                        languages:(NSArray*)languages
{
  NSDictionary* st=nil;
  LOGObjectFnStart();
  st=[[self resourceManager]stringsTableNamed:aTableName
                            inFramework:aFrameworkName
                            languages:languages];
  LOGObjectFnStop();
  return st;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aTableName
                      inFramework:(NSString*)aFrameworkName
                        languages:(NSArray*)languages
{
  return [[self resourceManager]stringsTableArrayNamed:aTableName
                                inFramework:aFrameworkName
                                languages:languages];
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)filterLanguages:(NSArray*)languages
{
  return languages;
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
  Class aClass=nil;
  NSDebugMLLog(@"application",@"Page with Name:%@\n",name_);
  //No Name ==> "Main"
  if (!name_ || [name_ length]==0)
	name_=GSWMainPageName;
  NSDebugMLLog(@"gswcomponents",@"Page with Name:%@\n",name_);
  aClass=NSClassFromString(name_);
  //If not found, search for library
  if (!aClass)
	{
	  NSString* pagePath=[self pathForResourceNamed:name_
							   ofType:nil];
	  Class _principalClass=[self libraryClassWithPath:pagePath];
	  NSDebugMLLog(@"gswcomponents",@"_principalClass=%@",_principalClass);
	  if (_principalClass)
		{
		  aClass=NSClassFromString(name_);
		  NSDebugMLLog(@"gswcomponents",@"aClass=%@",aClass);
		};
	};
  if (!aClass)
	{
	  //TODO Load Scripted (PageName.gsws)
	};

  if (!aClass)
	{
	  //TODO exception
	  NSDebugMLLog0(@"application",@"No component class\n");
	}
  else
	{
	  Class GSWComponentClass=[GSWComponent class]);
	  if (!ClassIsKindOfClass(aClass,GSWComponentClass))
		{
		  NSDebugMLLog0(@"application",@"component class is not a kind of GSWComponent\n");
		  //TODO exception
		}
	  else
		{
		  //TODOV
		  NSDebugMLLog0(@"application",@"Create Componnent\n");
		  component=[[aClass new] autorelease];
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

-(NSString*)stringForKey:(NSString*)aKey
			inTableNamed:(NSString*)aTableName
		withDefaultValue:(NSString*)defaultValue
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
//handleRequest:
//Olf Fn
-(GSWResponse*)handleRequest:(GSWRequest*)aRequest 
{
  return [self dispatchRequest:aRequest];//??
};

//--------------------------------------------------------------------
//dynamicElementWithName:associations:template:
//OldFn
-(GSWDynamicElement*)dynamicElementWithName:(NSString*)name_
							  associations:(NSDictionary*)someAssociations
								  template:(GSWElement*)templateElement_
{
  GSWDynamicElement* element=nil;
  //  NSString* elementName=[_XMLElement attributeForKey:@"NAME"];
  Class aClass=NSClassFromString(name_);
  LOGObjectFnNotImplemented();	//TODOFN
  NSDebugMLLog0(@"application",@"Begin GSWApplication:dynamicElementWithName\n");
  if (!aClass)
	{
	  ExceptionRaise(@"GSWApplication",
					 @"GSWApplication: No class named '%@' for creating dynamic element",
					  name_);
	}
  else
	{
	  Class GSWElementClass=[GSWElement class];
	  if (!ClassIsKindOfClass(aClass,GSWElementClass))
		{
		  ExceptionRaise(@"GSWApplication",
						 @"GSWApplication: element '%@' is not kind of GSWElement",
						 name_);
		}
	  else
		{
		  NSDebugMLLog(@"application",@"Creating DynamicElement of Class:%@\n",aClass);
		  element=[[[aClass alloc] initWithName:name_
								  associations:someAssociations
								  template:templateElement_] autorelease];
		  NSDebugMLLog(@"application",@"Creating DynamicElement:%@\n",element);
		};
	};
  return element;
};

@end
*/

