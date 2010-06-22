/** GSWActionRequestHandler.m - <title>GSWeb: Class GSWActionRequestHandler</title>

   Copyright (C) 1999-2006 Free Software Foundation, Inc.
   
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
#include <GNUstepBase/GSObjCRuntime.h>
#include <GNUstepBase/NSObject+GNUstepBase.h>

//====================================================================
@implementation GSWActionRequestHandler

//--------------------------------------------------------------------
-(NSString*)defaultActionClassName
{
  [self subclassResponsibility: _cmd];
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)defaultDefaultActionName
{
  return @"default";
};

//--------------------------------------------------------------------
-(BOOL)defaultShouldAddToStatistics
{
  return YES;
};

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
    {
      ASSIGN(_actionClassName,[self defaultActionClassName]);
      if (_actionClassName)
        ASSIGN(_actionClassClass,[[self class] _actionClassForName:_actionClassName]);
      ASSIGN(_defaultActionName,[self defaultDefaultActionName]);
      _shouldAddToStatistics=[self defaultShouldAddToStatistics];
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithDefaultActionClassName:(NSString*)defaultActionClassName
                  defaultActionName:(NSString*)defaultActionName
              shouldAddToStatistics:(BOOL)shouldAddToStatistics
{
  if ((self=[self init]))
    {
      ASSIGN(_actionClassName,defaultActionClassName);
      if (_actionClassName)
        ASSIGN(_actionClassClass,[[self class]_actionClassForName:_actionClassName]);
      ASSIGN(_defaultActionName,defaultActionName);
      _shouldAddToStatistics=shouldAddToStatistics;
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_actionClassName);
  DESTROY(_actionClassClass);
  DESTROY(_defaultActionName);
  [super dealloc];
};

//--------------------------------------------------------------------
-(BOOL)isSessionIDInRequest:(GSWRequest*)aRequest
{
  return [aRequest _isSessionIDInRequest];
}

//--------------------------------------------------------------------
-(void)registerWillHandleActionRequest
{
  [self subclassResponsibility: _cmd];
};

//--------------------------------------------------------------------
-(void)registerDidHandleActionRequestWithActionNamed:(NSString*)actionName
{
  [self subclassResponsibility: _cmd];
};

//--------------------------------------------------------------------
-(GSWResponse*)handleRequest:(GSWRequest*)aRequest
{
  GSWResponse* response=nil;
  GSWApplication* application=nil;

  application=[GSWApplication application];

  // Test if we should accept request
  if ([application isRefusingNewSessions]
      && ![self isSessionIDInRequest:aRequest]
      && [aRequest _isUsingWebServer])
    {
      // Reject it
      response=[self generateRequestRefusalResponseForRequest:aRequest];
    }
  else
    {
      // Accept it 
      [application lockRequestHandling];
      NS_DURING
        {
          response=[self _handleRequest:aRequest];
        }
      NS_HANDLER
        {
          [application unlockRequestHandling];
          [localException raise];//TODO
        };
      NS_ENDHANDLER;
      [application unlockRequestHandling];
    };
  if (!response)
    {
      response=[self generateNullResponse];
      [response _finalizeInContext:nil];
    };

  return response;
};

//--------------------------------------------------------------------
-(void)_setRecordingHeadersToResponse:(GSWResponse*)aResponse
                           forRequest:(GSWRequest*)request
                            inContext:(GSWContext*)context
{
  [[GSWApplication application] _setRecordingHeadersToResponse:aResponse
                                forRequest:request
                                inContext:context];
};

//--------------------------------------------------------------------
-(NSArray*)getRequestHandlerPathForRequest:(GSWRequest*)aRequest
{
  return [self subclassResponsibility: _cmd];
};

//--------------------------------------------------------------------
+(Class)_actionClassForName:(NSString*)name
{
  Class class=Nil;

  class=NSClassFromString(name);

  if (class)
    {
      [class description];//TODO: does this to force class init. Check this later
      if (!GSObjCIsKindOf(class,[GSWAction class]))
        class=Nil;
    };

  return class;
}

//--------------------------------------------------------------------
-(void)getRequestActionClassNameInto:(NSString**)actionClassNamePtr
                           classInto:(Class*)actionClassPtr
                            nameInto:(NSString**)actionNamePtr
                            forPath:(NSArray*)path
{
  int pathCount=0;
  int i=0;

  pathCount=[path count];

  // remove empty last parts
  for(i=pathCount-1;i>=0 && [[path objectAtIndex:i]length]==0;i--)
    pathCount--;
  if (pathCount<[path count])
    {
      path=[path subarrayWithRange:NSMakeRange(0,pathCount)];
    };

  switch(pathCount)
    {
    case 0:
      *actionClassNamePtr = _actionClassName;
      *actionClassPtr = _actionClassClass;
      *actionNamePtr = _defaultActionName;
      break;
    case 1:
      {
        NSString* testActionName=[path objectAtIndex:0];

        if ([GSWAction _isActionNamed:testActionName
                       actionOfClass:*actionClassPtr])
          {
            if(!_actionClassClass)
              _actionClassClass = [[self class]_actionClassForName:_actionClassName];           
            *actionClassNamePtr = _actionClassName;
            *actionClassPtr = _actionClassClass;
            *actionNamePtr = testActionName;
          } 
        else
          {
            *actionClassPtr = [[self class]_actionClassForName:testActionName]; // is it a class ?
            if (*actionClassPtr)
              {
                *actionClassNamePtr = NSStringFromClass(*actionClassPtr);
                *actionNamePtr = _defaultActionName;
              } 
            else
              {
                *actionClassNamePtr = _actionClassName;
                *actionClassPtr = _actionClassClass;
                *actionNamePtr = testActionName;
              }
          };
      };
      break;
    case 2:
    default:
      {
        *actionClassNamePtr=[path objectAtIndex:0];
        *actionNamePtr=NSStringWithObject([path objectAtIndex:1]);
        if ([*actionNamePtr isEqual:*actionClassNamePtr])
          {
            *actionClassNamePtr = _actionClassName;
            *actionClassPtr = _actionClassClass;
          }
        else
          {
            *actionClassPtr = [[self class]_actionClassForName:*actionClassNamePtr];
          };
        };
      break;
    };
};

//--------------------------------------------------------------------
-(GSWAction*)getActionInstanceOfClass:(Class)actionClass
                          withRequest:(GSWRequest*)aRequest
{
  GSWAction* action=nil;

  action = AUTORELEASE([[actionClass alloc] initWithRequest:aRequest]);

  return action;
}


//--------------------------------------------------------------------
// Application lockRequestHandling is set
-(GSWResponse*)_handleRequest:(GSWRequest*)aRequest
{
  GSWResponse* response=nil;
  GSWStatisticsStore* statisticsStore=nil;
  GSWApplication* application=nil;
  NSArray* requestHandlerPathArray=nil;
  Class actionClass=Nil;
  NSString* actionName=nil;
  NSString* actionClassName=nil;
  GSWContext* context=nil;
  GSWAction* action=nil;
  NSException* exception=nil;
  BOOL hasSession=NO;

  application = GSWApp;

  NS_DURING
    {
      NS_DURING
        {
          statisticsStore=[application statisticsStore];
          if (_shouldAddToStatistics)
            [self registerWillHandleActionRequest];
          
          [application awake];
          
          requestHandlerPathArray=[self getRequestHandlerPathForRequest:aRequest];
          
          // Parse path into actionClassName,actionClass and actionName

          // Be carefull: there's no context created for the moment
          NS_DURING
            {          
              [self getRequestActionClassNameInto:&actionClassName
                    classInto:&actionClass
                    nameInto:&actionName
                    forPath:requestHandlerPathArray];
            }
          NS_HANDLER
            {
              // Be carefull: there's no context created for the moment
              response=[application  handleActionRequestErrorWithRequest:aRequest
                                     exception:localException
                                     reason:@"InvalidPathError"
                                     requestHanlder:self
                                     actionClassName:actionClassName
                                     actionName:actionName
                                     actionClass:actionClass
                                     actionObject:action];
              [localException raise]; // Will be caught be up level Exception
            };
          NS_ENDHANDLER;

          if (actionClass)
            {
              id<GSWActionResults> actionResult=nil;
          
              NS_DURING
                {
                  // Will also create context
                  action=[self getActionInstanceOfClass:actionClass
                               withRequest:aRequest];
                }
              NS_HANDLER
                {
                  response=[application  handleActionRequestErrorWithRequest:aRequest
                                         exception:localException
                                         reason:@"InstantiationError"
                                         requestHanlder:self
                                         actionClassName:actionClassName
                                         actionName:actionName
                                         actionClass:actionClass
                                         actionObject:action];
                  [localException raise];// Will be caught be up level Exception
                };
              NS_ENDHANDLER;

              NSAssert1(action,@"Direct action of class named %@ can't be created",
                        actionClassName);
          
              NS_DURING
                {
                  actionResult=[action performActionNamed:actionName];
                }
              NS_HANDLER
                {
                  response=[application  handleActionRequestErrorWithRequest:aRequest
                                         exception:localException
                                         reason:@"InvocationError"
                                         requestHanlder:self
                                         actionClassName:actionClassName
                                         actionName:actionName
                                         actionClass:actionClass
                                         actionObject:action];
                  [localException raise]; // Will be caught be up level Exception
                };
              NS_ENDHANDLER;
 
              response=[actionResult generateResponse];
          
              context=[action _context];
          
              [[NSNotificationCenter defaultCenter]postNotificationName:@"DidHandleRequestNotification"
                                                   object:context];
              [self _setRecordingHeadersToResponse:response
                    forRequest:aRequest
                    inContext:context];
            }
          else
            {
              NSException* exception=nil;

              if ([actionClassName length]>0)
                {
                  exception=[NSException exceptionWithName:NSInvalidArgumentException//TODO better name (IllegalStateException)
                                         reason:[NSString stringWithFormat:@"Can't find action class named '%@'",actionClassName]
                                         userInfo:nil];
                  response=[application  handleActionRequestErrorWithRequest:aRequest
                                         exception:exception
                                         reason:@"InvocationError"
                                         requestHanlder:self
                                         actionClassName:actionClassName
                                         actionName:actionName
                                         actionClass:actionClass
                                         actionObject:action];
                }
              else 
                {
                  exception=[NSException exceptionWithName:NSInvalidArgumentException//TODO better name (IllegalStateException)
                                         reason:[NSString stringWithFormat:@"Can't execute action with path: '%@'",
                                                          requestHandlerPathArray]
                                         userInfo:nil];
                  response=[application  handleActionRequestErrorWithRequest:aRequest
                                         exception:exception
                                         reason:@"InvocationError"
                                         requestHanlder:self
                                         actionClassName:actionClassName
                                         actionName:actionName
                                         actionClass:actionClass
                                         actionObject:action];
                };
              [exception raise]; // Will be caught be up level Exception
            };
          if ([application isCachingEnabled])
            {
              //TODO
            };
        }
      NS_HANDLER
        {
          if (!response)
            {
              if (!context)
                {
                  context=[action _context];
                  if (!context)
                    {
                      context=[GSWApp _context];
                      if (!context)
                        {
                          context = [application createContextForRequest:aRequest];
                        };
                    };
                };
               
              NS_DURING
                {
                  response = [self generateErrorResponseWithException:localException
                                   inContext:context];
                }
              NS_HANDLER
                {
                  [NSException raise:@"Exception"
                               format:@"Exception wduring error reponse generation in %@: %@",
                               [self className],localException];
                };
              NS_ENDHANDLER;
            };
        };
      NS_ENDHANDLER;
    }
  NS_HANDLER
    {
      ASSIGN(exception,localException); // re-raise later
    };
  NS_ENDHANDLER;
  
  RETAIN(response);
  if (!context)
    context=[GSWApp _context];
  if (context)
    {
      [context _putAwakeComponentsToSleep];
      hasSession=[context hasSession];
      [application saveSessionForContext:context];
    };

  AUTORELEASE(response);
  AUTORELEASE(exception);
	  
  [application sleep];

  if (exception)
    [exception raise];
  else
    {
      if (statisticsStore && _shouldAddToStatistics)
        [self registerDidHandleActionRequestWithActionNamed:actionName];
      
      //TODO do not finalize if already done (in handleException for exemple)
      if (response)
        {
          [response _finalizeInContext:context];
          if(hasSession && [application isPageRefreshOnBacktrackEnabled])
            [response disableClientCaching];
        };
      [application _setContext:nil];
    };

  return response;
};

//--------------------------------------------------------------------
-(GSWResponse*)generateNullResponse
{
  return [self subclassResponsibility: _cmd];
};

//--------------------------------------------------------------------
-(GSWResponse*)generateRequestRefusalResponseForRequest:(GSWRequest*)aRequest
{
  return [self subclassResponsibility: _cmd];
};

//--------------------------------------------------------------------
-(GSWResponse*)generateErrorResponseWithException:(NSException*)error
                                        inContext:(GSWContext*)aContext
{
  return [self subclassResponsibility: _cmd];
};

//--------------------------------------------------------------------
+(id)handler
{
  return [[GSWActionRequestHandler new] autorelease];
};

//--------------------------------------------------------------------
+(GSWActionRequestHandler*)handlerWithDefaultActionClassName:(NSString*)defaultActionClassName
                                           defaultActionName:(NSString*)defaultActionName
                                       shouldAddToStatistics:(BOOL)shouldAddToStatistics
{
  return [[[self alloc]initWithDefaultActionClassName:defaultActionClassName
                       defaultActionName:defaultActionName
                       shouldAddToStatistics:shouldAddToStatistics]autorelease];
};
@end

