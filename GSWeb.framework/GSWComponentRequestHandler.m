/** GSWComponentRequestHandler.m - <title>GSWeb: Class GSWComponentRequestHandler</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
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
  LOGObjectFnStart();
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
  NSDebugMLLog(@"requests",@"response=%@",response);
  LOGObjectFnStop();
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
  LOGObjectFnStart();
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

      NSDebugMLLog(@"requests",@"requestHandlerValues=%@",requestHandlerValues);
      //statisticsStore=[[GSWApplication application]statisticsStore];
//      NSDebugMLLog(@"requests",@"statisticsStore=%@",statisticsStore);
      //[statisticsStore applicationWillHandleComponentActionRequest];

      aContext=[[GSWApplication application]createContextForRequest:aRequest];
      NSDebugMLLog(@"requests",@"aContext=%@",aContext);

      senderID=[requestHandlerValues objectForKey:GSWKey_ElementID[GSWebNamingConv]];
      NSDebugMLLog(@"requests",@"AA senderID=%@",senderID);
      [aContext _setSenderID:senderID];

      requestContextID=[requestHandlerValues objectForKey:GSWKey_ContextID[GSWebNamingConv]];
      NSDebugMLLog(@"requests",@"AA requestContextID=%@",requestContextID);
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
  //statisticsStore=[[GSWApplication application] statisticsStore];
  //[statisticsStore applicationDidHandleComponentActionRequest];
  NSDebugMLLog(@"requests",@"response=%@",response);
  LOGObjectFnStop();
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
  LOGObjectFnStart();
  NS_DURING
    {
      sessionID=[elements objectForKey:GSWKey_SessionID[GSWebNamingConv]];
      NSDebugMLLog(@"requests",@"sessionID=%@",sessionID);
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
          NSDebugMLLog(@"requests",@"session=%@",session);
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
          NSDebugMLLog(@"requests",@"session=%@",session);
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
      NSDebugMLLog(@"requests",@"response=%@",response);
      NSDebugMLLog(@"requests",@"errorResponse=%@",errorResponse);
      RETAIN(response);
      [aContext _putAwakeComponentsToSleep];
      [application saveSessionForContext:aContext];
      NSDebugMLLog(@"requests",@"session=%@",session);
      NSDebugMLLog(@"requests",@"sessionCount=%u",[session retainCount]);
      NSDebugMLLog(@"requests",@"response=%@",response);
      AUTORELEASE(response);
    };
  LOGObjectFnStop();
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
  LOGObjectFnStart();

  NSDebugMLLog(@"requests",@"aSession=%@",aSession);
  NSDebugMLLog(@"requests",@"aContext=%@",aContext);

  storesIDsInCookies=[aSession storesIDsInCookies]; //For What ?
  NSDebugMLLog(@"requests",@"storesIDsInCookies=%s",(storesIDsInCookies ? "YES" : "NO"));

  contextID=[elements objectForKey:GSWKey_ContextID[GSWebNamingConv]];//use aContext requestContextID instead ?
  NSDebugMLLog(@"requests",@"contextID=%@",contextID);

  if (contextID) // ??
    {
      NSAssert([contextID length]>0,@"contextID empty");
      page=[self lockedRestorePageForContextID:contextID
                 inSession:aSession];
      //??
      NSDebugMLLog(@"requests",@"contextID=%@",contextID);
      NSDebugMLLog(@"requests",@"aSession=%@",aSession);
      NSDebugMLLog(@"requests",@"page=%@",page);
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
      NSDebugMLLog(@"requests",@"pageName=%@",pageName);
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
      //TODO method adds a header to the HTTP response. This header sets the expiration date for an HTML page to the date and time of the creation of the page. Later, when the browser checks its cache for this page, it finds that the page is no longer valid and so refetches it by resubmitting the request URL to the WebObjects application.

      [aSession _saveCurrentPage];
#if 0
      if (!contextID) // ??
        {
          if (![aSession storesIDsInCookies])//??
            [aSession clearCookieFromResponse:response];
        };
#endif
    };
  NSDebugMLLog(@"requests",@"response=%@",response);
  LOGObjectFnStop();
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

  LOGObjectFnStart();
  NSDebugMLLog(@"requests",@"aComponent=%@",aComponent);

  request=[aContext request];
  contextID=[elements objectForKey:GSWKey_ContextID[GSWebNamingConv]];
  NSDebugMLLog(@"requests",@"contextID=%@",contextID);

  response=[GSWApp createResponseInContext:aContext];
  NSDebugMLLog(@"requests",@"response=%@",response);
  NSDebugMLLog(@"requests",@"aSession=%@",aSession);
  NSDebugMLLog(@"requests",@"aContext=%@",aContext);

  senderID=[aContext senderID];
  NSDebugMLLog(@"requests",@"AA senderID=%@",senderID);
  NSDebugMLLog(@"requests",@"AA request=%@",request);

  matchingContextID=[aSession _contextIDMatchingIDsInContext:aContext];
  NSDebugMLLog(@"requests",@"matchingContextID=%@",matchingContextID);

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
      [[GSWApplication application] appendToResponse:response
                                    inContext:aContext];
      NSDebugMLLog(@"requests",@"After appendToResponse [aContext elementID]=%@",
                   [aContext elementID]);
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
          NSDebugMLLog(@"requests",@"Before takeValues [aContext elementID]=%@",
                       [aContext elementID]);
          NSAssert([[aContext elementID] length]==0,
                   @"1 lockedDispatchWithPreparedPage elementID length>0");
          [[GSWApplication application] takeValuesFromRequest:request
                                        inContext:aContext];
          NSDebugMLLog(@"requests",@"After takeValues[aContext elementID]=%@",
                       [aContext elementID]);
          if (![[aContext elementID] length]==0)
            {
              LOGSeriousError0(@"2 lockedDispatchWithPreparedPage elementID length>0");
              [aContext deleteAllElementIDComponents];//NDFN
            };
          [aContext _setPageChanged:NO];//???
          isFromClientComponent=[request isFromClientComponent];
          [aContext _setPageReplaced:NO];
        };
      if (senderID) //??
        {
          BOOL pageChanged=NO;
          NSException* exception=nil;
          NSDebugMLLog(@"requests",@"Before invokeAction [aContext elementID]=%@",
                       [aContext elementID]);
          NSAssert([[aContext elementID] length]==0,
                   @"3 lockedDispatchWithPreparedPage elementID length>0");
          // Exception catching here ?
          NS_DURING
            {
              responsePage=(GSWComponent*)[[GSWApplication application] invokeActionForRequest:request
                                                                        inContext:aContext];
              NSDebugMLLog(@"requests",@"After invokeAction [aContext elementID]=%@",[aContext elementID]);
              NSAssert([[aContext elementID] length]==0,@"4 lockedDispatchWithPreparedPage elementID length>0");
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
          //	  [aContext deleteAllElementIDComponents];//NDFN
          NSDebugMLLog(@"requests",@"responsePage=%@",responsePage);
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
              NSDebugMLLog(@"requests",@"responseContext=%@",responseContext);
              [responseContext _setPageReplaced:NO];
              responsePageElement=(GSWComponent*)[responseContext _pageElement];
              NSDebugMLLog(@"requests",@"responsePageElement=%@",responsePageElement);
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
              NSDebugMLLog(@"requests",@"response before appendToResponse=%@",response);
              NSDebugMLLog(@"requests",@"responseContext=%@",responseContext);
              NSAssert([[aContext elementID] length]==0,
                       @"5 lockedDispatchWithPreparedPage elementID length>0");
              NSDebugMLLog(@"requests",@"Before appendToResponse [aContext elementID]=%@",
                       [aContext elementID]);
              [[GSWApplication application] appendToResponse:response
                                            inContext:responseContext];
              NSDebugMLLog(@"requests",@"After appendToResponse [aContext elementID]=%@",
                           [aContext elementID]);
              NSAssert([[aContext elementID] length]==0,
                       @"6 lockedDispatchWithPreparedPage elementID length>0");
              responseRequest=[responseContext request];//SoWhat ?
              //Not used [responseRequest isFromClientComponent];//SoWhat
            }
          NS_HANDLER
            {
              localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                                      @"In appendToResponse page=%@ of Class %@",
                                                                      [page name],
                                                                      [page class]);
              LOGException(@"exception=%@",localException);
              NSDebugMLLog(@"requests",@"context=%@",aContext);
              errorResponse=[[GSWApplication application] handleException:localException
                                                          inContext:aContext];
            }
          NS_ENDHANDLER;
        };
    };
  NSDebugMLLog(@"requests",@"response=%@",response);
  LOGObjectFnStop();
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
  LOGClassFnStart();
  NS_DURING
    {
      values=[aRequest uriOrFormOrCookiesElements];
      NSDebugMLLog(@"requests",@"values=%@",values);
    }
  NS_HANDLER
    {
      LOGException(@"%@ (%@)",
		   localException,
		   [localException reason]);
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In +_requestHandlerValuesForRequest:");
      LOGException(@"exception=%@",localException);
      [localException raise];
    };
  NS_ENDHANDLER;
  LOGClassFnStop();
  return values;
};


@end

