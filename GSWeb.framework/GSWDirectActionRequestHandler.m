/** GSWDirectActionRequestHandler.m - <title>GSWeb: Class GSWDirectActionRequestHandler</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 1999
   
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

//====================================================================
@implementation GSWDirectActionRequestHandler

//--------------------------------------------------------------------
-(GSWResponse*)handleRequest:(GSWRequest*)aRequest
{
  //OK
  GSWResponse* response=nil;
  GSWStatisticsStore* statisticsStore=nil;
  GSWApplication* application=nil;
  LOGObjectFnStart();
  application=[GSWApplication application];
  if (0/*[application isRefusingNewSessions]*/)
    {
      //TODO
    }
  else
    {
      id submitButtonsActionPathFromRequest=nil;
      NSArray* requestHandlerPathArray=nil;
      NSString* actionName=nil;
      NSString* className=nil;
      GSWContext* context=nil;
      [application lockRequestHandling];
      NS_DURING
        {
          NS_DURING
            {
              statisticsStore=[[GSWApplication application]statisticsStore];
              [statisticsStore _applicationWillHandleDirectActionRequest];
              submitButtonsActionPathFromRequest=[self submitButtonsActionPathFromRequest:aRequest]; //So what ?
              NSDebugMLLog(@"requests",@"submitButtonsActionPathFromRequest=%@",
                           submitButtonsActionPathFromRequest);
              requestHandlerPathArray=[aRequest requestHandlerPathArray];
              NSDebugMLLog(@"requests",@"requestHandlerPathArray=%@",
                           requestHandlerPathArray);
              switch([requestHandlerPathArray count])
                {
                case 0:
                  actionName=@"default";
                  className=@"DirectAction";
                  break;
                case 1:
                  {
                    NSString* tmpActionName=[NSString stringWithFormat:@"%@Action",
                                                       [requestHandlerPathArray objectAtIndex:0]];
                    SEL tmpActionSel=NSSelectorFromString(tmpActionName);
                    Class aClass = NSClassFromString(@"DirectAction");
                    NSDebugMLLog(@"requests",@"tmpActionName=%@",
                                 tmpActionName);
                    if (tmpActionSel && aClass)
                      {
                        if ([aClass instancesRespondToSelector:tmpActionSel])
                          {
                            actionName=[requestHandlerPathArray objectAtIndex:0];
                            className=@"DirectAction";
                          };
                      };
                    if (!actionName)
                      {
                        className=[requestHandlerPathArray objectAtIndex:0];
                        actionName=@"default";
                      };
                  };
                  break;
                case 2:
                default:
                  className=[requestHandlerPathArray objectAtIndex:0];
                  actionName=[NSString stringWithFormat:@"%@",
                                       [requestHandlerPathArray objectAtIndex:1]];
                  break;
                };
              NSDebugMLLog(@"requests",@"className=%@",className);
              NSDebugMLLog(@"requests",@"actionName=%@",actionName);
              if ([application isCachingEnabled])
                {
                  //TODO
                };
              {
                GSWResourceManager* resourceManager=nil;
                GSWDeployedBundle* appBundle=nil;
                GSWDirectAction* directAction=nil;
                id<GSWActionResults> actionResult=nil;
                Class aClass=nil;
                resourceManager=[application resourceManager];
                appBundle=[resourceManager _appProjectBundle];
                [resourceManager _allFrameworkProjectBundles];//So what ?
                [application awake];
                aClass=NSClassFromString(className);
                NSAssert1(aClass,@"No direct action class named %@",
                          className);
                directAction=[[aClass alloc]initWithRequest:aRequest];
                NSAssert1(directAction,@"Direct action of class named %@ can't be created",
                          className);
                context=[directAction _context];
                actionResult=[directAction performActionNamed:actionName];
                response=[actionResult generateResponse];
                
                //Finir ?
              };
            }
	  NS_HANDLER
            {
              LOGException(@"%@ (%@)",localException,[localException reason]);
              if (!context)
                context=[GSWApp _context];
              response=[application handleException:localException
                                    inContext:context];
              //TODO
            };
	  NS_ENDHANDLER;
	  NSDebugMLLog(@"requests",@"response=%@",response);
	  RETAIN(response);
	  if (!context)
            context=[GSWApp _context];
	  [context _putAwakeComponentsToSleep];
	  [application saveSessionForContext:context];
	  NSDebugMLLog(@"requests",@"response=%@",response);
	  AUTORELEASE(response);
	  
	  //Here ???
	  [application sleep];
	  //TODO do not fnalize if already done (in handleException for exemple)
	  [response _finalizeInContext:context];
	  [application _setContext:nil];
	  statisticsStore=[[GSWApplication application] statisticsStore];
	  [statisticsStore _applicationDidHandleDirectActionRequestWithActionNamed:actionName];
        }
      NS_HANDLER
        {
          LOGException(@"%@ (%@)",localException,[localException reason]);
          [application unlockRequestHandling];
          [localException raise];//TODO
        };
      NS_ENDHANDLER;
      [application unlockRequestHandling];
    };
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return response;
};

//--------------------------------------------------------------------
-(GSWResponse*)_nilResponse
{
  //OK
  GSWResponse* response=nil;
  LOGObjectFnStart();
  response=[GSWApp createResponseInContext:nil];
  [response appendContentString:@"<HTML><HEAD><TITLE>DirectAction Error</TITLE></HEAD><BODY>The result of a direct action returned nothing.</BODY></HTML>"];
  LOGObjectFnStop();
  return response;
};

//--------------------------------------------------------------------
-(void)_initializeRequestSessionIDInContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(id)submitButtonsActionPathFromRequest:(GSWRequest*)aRequest
{
  //OK
  NSArray* submitActions=nil;
  LOGObjectFnStart();
  submitActions=[aRequest formValuesForKey:GSWKey_SubmitAction[GSWebNamingConv]];
  if (submitActions)
    {
      //TODO
    };
  
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;
};

//NDFN: return additional path elements
+(NSArray*)additionalRequestPathArrayFromRequest:(GSWRequest*)aRequest
{
  NSArray* requestHandlerPathArray=nil;
  NSArray* additionalRequestPathArray=nil;
  LOGObjectFnStart();
  requestHandlerPathArray=[aRequest requestHandlerPathArray];
  if ([requestHandlerPathArray count]>2)
    additionalRequestPathArray=[requestHandlerPathArray subarrayWithRange:NSMakeRange(2,[requestHandlerPathArray count]-2)];
  LOGObjectFnStart();
  return additionalRequestPathArray;
};
@end

//====================================================================
@implementation GSWDirectActionRequestHandler (GSWRequestHandlerClassA)

//--------------------------------------------------------------------
+(id)handler
{
  return [[GSWDirectActionRequestHandler new] autorelease];
};
@end

