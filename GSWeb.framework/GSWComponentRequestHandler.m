/** GSWComponentRequestHandler.m - <title>GSWeb: Class GSWComponentRequestHandler</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 1999
   
   $Revision$
   $Date$

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
@implementation GSWComponentRequestHandler

//--------------------------------------------------------------------
/** Handle request aRequest and return the response 
    This lock application
**/

-(GSWResponse*)handleRequest:(GSWRequest*)aRequest
{
  //OK
  GSWResponse* response=nil;
  GSWApplication* application=[GSWApplication application];

  [application lockRequestHandling];
  response=[self lockedHandleRequest:aRequest];
  if (!response)
    {
      response=[GSWResponse responseWithMessage:@"Component Handle request failed. No Response"
                            inContext:nil
                            forRequest:aRequest];
      [response _finalizeInContext:nil]; //DO Call _finalizeInContext: !
    };
  [application unlockRequestHandling];

  return response;
};

//--------------------------------------------------------------------
/** Handle request aRequest and return the response 
    Application should be locked before this
**/

-(GSWResponse*)lockedHandleRequest:(GSWRequest*)aRequest
{
  //OK
  //GSWStatisticsStore* statisticsStore=nil;
  GSWApplication* application=[GSWApplication application];
  GSWContext* aContext=nil;
  GSWResponse* response=nil;
  NSDictionary* requestHandlerValues=nil;
  BOOL exceptionRaised=NO;

  NS_DURING
    {      
      requestHandlerValues=[GSWComponentRequestHandler _requestHandlerValuesForRequest:aRequest];
    }
  NS_HANDLER
    {
      exceptionRaised=YES;
      LOGException(@"%@ (%@)",
		   localException,
		   [localException reason]);
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In -lockedHandleRequest:");
      LOGException(@"exception=%@",localException);
      [application awake];
      response=[application handleException:localException
                            inContext:nil];
      [application sleep];
      [response _finalizeInContext:aContext];//DO Call _finalizeInContext: !
      NSAssert(!response || [response isFinalizeInContextHasBeenCalled],@"_finalizeInContext not called for GSWResponse");
    };
  NS_ENDHANDLER;
  if (!exceptionRaised)
    {
      NSString* senderID=nil;
      NSString* requestContextID=nil;

      aContext=[[GSWApplication application]createContextForRequest:aRequest];

      senderID=[requestHandlerValues objectForKey:GSWKey_ElementID[GSWebNamingConv]];
      [aContext _setSenderID:senderID];

      requestContextID=[requestHandlerValues objectForKey:GSWKey_ContextID[GSWebNamingConv]];
      [aContext _setRequestContextID:requestContextID];

      [application _setContext:aContext];
      //====>
      NS_DURING
        {
          [application awake];
          response=[self lockedDispatchWithPreparedApplication:application
                         inContext:aContext
                         elements:requestHandlerValues];
          
        }
      NS_HANDLER
        {
          exceptionRaised=YES;
          LOGException(@"%@ (%@)",
                       localException,
                       [localException reason]);
          localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                   @"In lockedDispatchWithPreparedApplication");
          LOGException(@"exception=%@",localException);
          response=[application handleException:localException
                                inContext:aContext];
          [application sleep];
          [response _finalizeInContext:aContext]; //DO Call _finalizeInContext: !
          NSAssert(!response || [response isFinalizeInContextHasBeenCalled],
                   @"_finalizeInContext not called for GSWResponse");
        };
      NS_ENDHANDLER;
      if (!exceptionRaised)
        {
          NS_DURING
            {
              [application sleep];
              [response _finalizeInContext:aContext];//LAST //CLEAN
            }
          NS_HANDLER
            {
              LOGException(@"%@ (%@)",
                           localException,
                           [localException reason]);
              localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                       @"In [application sleep] or [response _finalizeInContext:aContext]");
              LOGException(@"exception=%@",localException);
              response=[application handleException:localException
                                    inContext:nil];
              [response _finalizeInContext:aContext]; //DO Call _finalizeInContext: !
              NSAssert(!response || [response isFinalizeInContextHasBeenCalled],
                       @"_finalizeInContext not called for GSWResponse");
            };
          NS_ENDHANDLER;
        };
      //<===========
    };
  
  [application _setContext:nil];

  return response;
};

//--------------------------------------------------------------------
-(GSWResponse*)lockedDispatchWithPreparedApplication:(GSWApplication*)application
                                           inContext:(GSWContext*)aContext
                                            elements:(NSDictionary*)elements
{
  //OK
  GSWResponse* response=nil;
  GSWResponse* errorResponse=nil;
  GSWSession* session=nil;
  NSString* sessionID=nil;

  NS_DURING
    {
      sessionID=[elements objectForKey:GSWKey_SessionID[GSWebNamingConv]];

      if (sessionID)
        {
          session=[application restoreSessionWithID:sessionID
                               inContext:aContext];
          if (!session)
            {
              // check for refuseNewSessions
              errorResponse=[application handleSessionRestorationErrorInContext:aContext];
            };
        }
      else
        {
          // check for refuseNewSessions
          session=[application _initializeSessionInContext:aContext];
        }
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"in session create/restore");
      LOGException(@"exception=%@",localException);
      errorResponse=[application handleException:localException
                                 inContext:aContext];
    }
  NS_ENDHANDLER;
  if (!response && !errorResponse)
    {
      if (session)
        {
          NS_DURING
            {
              response=[self lockedDispatchWithPreparedSession:session
                             inContext:aContext
                             elements:elements];
            }
          NS_HANDLER
            {
              localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                       @"in lockedDispatchWithPreparedSession");
              LOGException(@"exception=%@",localException);
              errorResponse=[application handleException:localException
                                         inContext:aContext];
            }
          NS_ENDHANDLER;
        };
    };
  //======LAST //CLEAN
  if (response || errorResponse)
    {
      RETAIN(response);
      [aContext _putAwakeComponentsToSleep];
      [application saveSessionForContext:aContext];
      AUTORELEASE(response);
    };

  return response ? response : errorResponse;
};

//--------------------------------------------------------------------
-(GSWResponse*)lockedDispatchWithPreparedSession:(GSWSession*)aSession
                                       inContext:(GSWContext*)aContext
                                        elements:(NSDictionary*)elements
{
  //OK
  GSWResponse* errorResponse=nil;
  GSWResponse* response=nil;
  GSWComponent* page=nil;
  BOOL storesIDsInCookies=NO;
  NSString* contextID=nil;

  storesIDsInCookies=[aSession storesIDsInCookies]; //For What ?

  contextID=[elements objectForKey:GSWKey_ContextID[GSWebNamingConv]];//use aContext requestContextID instead ?

  if (contextID) // ??
    {
      NSAssert([contextID length]>0,@"contextID empty");
      page=[self lockedRestorePageForContextID:contextID
                 inSession:aSession];
      if (!page)
        {
          GSWApplication* application=[aSession application];
          errorResponse=[application handlePageRestorationErrorInContext:aContext];
        };
    }
  else
    {
      NSString* pageName=[elements objectForKey:GSWKey_PageName[GSWebNamingConv]];
      NSException* exception=nil;

      NS_DURING
        {
          page=[[GSWApplication application] pageWithName:pageName
                                             inContext:aContext];
        }
      NS_HANDLER
        {
          localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                   @"In pageWithName");
          LOGException(@"exception=%@",localException);
          ASSIGN(exception,localException);
        }
      NS_ENDHANDLER;
      if (!page)
        {
          errorResponse=[[GSWApplication application] handleException:exception
                                                      inContext:aContext];
        };
      DESTROY(exception);
    };
  if (!response && !errorResponse && page)
    {
      [aContext _setPageElement:page];
      response=[self lockedDispatchWithPreparedPage:page
                     inSession:aSession
                     inContext:aContext
                     elements:elements];
    };
  if (response)
    {
      BOOL isPageRefreshOnBacktrackEnabled=[[GSWApplication application] isPageRefreshOnBacktrackEnabled];
      if (isPageRefreshOnBacktrackEnabled)
        [response disableClientCaching];

      [aSession _saveCurrentPage];
#if 0
      if (!contextID) // ??
        {
          if (![aSession storesIDsInCookies])//??
            [aSession clearCookieFromResponse:response];
        };
#endif
    };

  return response ? response : errorResponse;
};

//--------------------------------------------------------------------
-(GSWResponse*)lockedDispatchWithPreparedPage:(GSWComponent*)aComponent
                                    inSession:(GSWSession*)aSession
                                    inContext:(GSWContext*)aContext
                                     elements:(NSDictionary*)elements
{
  //OK
  GSWRequest* request=nil;
  GSWResponse* response=nil;
  GSWResponse* errorResponse=nil;
  NSString* senderID=nil;
  NSString* contextID=nil;
  NSString* httpVersion=nil;
  GSWComponent* page=nil;
  GSWComponent* responsePage=nil;
  BOOL isFromClientComponent=NO;
  BOOL hasFormValues=NO;
  GSWContext* responseContext=nil;
  GSWComponent* responsePageElement=nil;
  GSWRequest* responseRequest=nil;
  NSString* matchingContextID=nil;

  request=[aContext request];
  contextID=[elements objectForKey:GSWKey_ContextID[GSWebNamingConv]];

  response=[GSWApp createResponseInContext:aContext];

  senderID=GSWContext_senderID(aContext);

  matchingContextID=[aSession _contextIDMatchingIDsInContext:aContext];

  httpVersion=[request httpVersion];
  [response setHTTPVersion:httpVersion];
  [response setAcceptedEncodings:[request browserAcceptedEncodings]];
  [response setHeader:@"text/html"
            forKey:@"content-type"];
  [aContext _setResponse:response];

  if (matchingContextID)
    {
      page = [self lockedRestorePageForContextID:matchingContextID
                   inSession:aSession];
      [aContext _setPageElement:page];
      [GSWApp appendToResponse:response
                     inContext:aContext];
    }
  else
    {
      page=[aContext page];
      if (contextID)//??
        {
          hasFormValues=[request _hasFormValues];
        }
      else
        {
          [aContext _setPageChanged:NO];
          isFromClientComponent=[request isFromClientComponent];
          //??
          [aContext _setPageReplaced:NO];
          isFromClientComponent=[request isFromClientComponent];
        };
      if (hasFormValues)
        {
          NSAssert([GSWContext_elementID(aContext) length]==0,
                   @"1 lockedDispatchWithPreparedPage elementID length>0");
          [GSWApp takeValuesFromRequest:request
                              inContext:aContext];
          if (![GSWContext_elementID(aContext) length]==0)
            {
              LOGSeriousError0(@"2 lockedDispatchWithPreparedPage elementID length>0");
              GSWContext_deleteAllElementIDComponents(aContext);//NDFN
            };
          [aContext _setPageChanged:NO];//???
          isFromClientComponent=[request isFromClientComponent];
          [aContext _setPageReplaced:NO];
        };
      if (senderID) //??
        {
          BOOL pageChanged=NO;
          NSException* exception=nil;

          NSAssert([GSWContext_elementID(aContext) length]==0,
                   @"3 lockedDispatchWithPreparedPage elementID length>0");
          // Exception catching here ?
          NS_DURING
            {
              responsePage=(GSWComponent*)[GSWApp invokeActionForRequest:request
                                                               inContext:aContext];

              NSAssert([GSWContext_elementID(aContext) length]==0,@"4 lockedDispatchWithPreparedPage elementID length>0");
            }
          NS_HANDLER
            {
              LOGException0(@"exception in invokeActionForRequest");
              LOGException(@"exception=%@",localException);
              localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                                      @"In invokeActionForRequest component=%@ of Class %@",
                                                                      [aComponent name],
                                                                      [aComponent class]);
              LOGException(@"exception=%@",localException);
              ASSIGN(exception,localException);
              if (!responsePage)
                {
                  errorResponse=[[GSWApplication application] handleException:exception
                                                              inContext:aContext];
                };
              DESTROY(exception);
            }
          NS_ENDHANDLER;

          if (errorResponse)
            {
              response=errorResponse;
              responseContext=aContext;
            }
          else
            {
              if (!responsePage)
                responsePage=page;
              
              responseContext=[(GSWComponent*)responsePage context];//So what ?
              [responseContext _setPageReplaced:NO];
              responsePageElement=(GSWComponent*)[responseContext _pageElement];
              pageChanged=(responsePage!=responsePageElement);
              [responseContext _setPageChanged:pageChanged];//??
              if (pageChanged)
                {
                  [responseContext _setPageElement:responsePage];
                };
              responseRequest=[responseContext request];//SoWhat ?
              [responseRequest isFromClientComponent];//SoWhat
            };
        }
      else
        {
          responseContext=aContext;
          responsePageElement=page;
          responsePage=aComponent;
          responseRequest=request;
        };
      if (!errorResponse)
        {
          NS_DURING
            {
              NSAssert([GSWContext_elementID(aContext) length]==0,
                       @"5 lockedDispatchWithPreparedPage elementID length>0");
              [GSWApp appendToResponse:response
                             inContext:responseContext];
              NSAssert([GSWContext_elementID(aContext) length]==0,
                       @"6 lockedDispatchWithPreparedPage elementID length>0");
              responseRequest=[responseContext request];//SoWhat ?
            }
          NS_HANDLER
            {
              localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                                      @"In appendToResponse page=%@ of Class %@",
                                                                      [page name],
                                                                      [page class]);
              LOGException(@"exception=%@",localException);
              errorResponse=[[GSWApplication application] handleException:localException
                                                          inContext:aContext];
            }
          NS_ENDHANDLER;
        };
    };

  return errorResponse ? errorResponse : response;
};

//--------------------------------------------------------------------
-(GSWComponent*)lockedRestorePageForContextID:(NSString*)aContextID
                                    inSession:(GSWSession*)aSession
{
  //OK
  GSWComponent* page=[aSession restorePageForContextID:aContextID];
  return page;
};

@end

//====================================================================
@implementation GSWComponentRequestHandler (GSWRequestHandlerClassA)

//--------------------------------------------------------------------
+(id)handler
{
  return [[GSWComponentRequestHandler new] autorelease];
};

//--------------------------------------------------------------------
+(NSDictionary*)_requestHandlerValuesForRequest:(GSWRequest*)aRequest
{
  //OK
  NSDictionary* values=nil;

  NS_DURING
    {
      values=[aRequest uriOrFormOrCookiesElements];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In +_requestHandlerValuesForRequest:");
      LOGException(@"exception=%@",localException);
      [localException raise];
    };
  NS_ENDHANDLER;

  return values;
};


@end

