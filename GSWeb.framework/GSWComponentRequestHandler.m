/** GSWComponentRequestHandler.m - <title>GSWeb: Class GSWComponentRequestHandler</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de>
   Date: 	Mar 2008
   
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
#include "GSWPrivate.h"

//====================================================================
@implementation GSWComponentRequestHandler


// note: we are NOT looking at [WORequest _lookForIDsInCookiesFirst] since it is always NO -- dw

- (NSDictionary*) requestHandlerValuesForRequest:(GSWRequest *) aRequest
{
  NSMutableDictionary  * aDictionary = [NSMutableDictionary dictionary];
  NSArray              * pathArray = [aRequest requestHandlerPathArray];
  NSString             * lastObject = nil;
  NSString             * penultElement = nil;
  NSString             * aSessionID = nil;
  NSString             * aContextID = nil;
  NSString             * aSenderID = nil;
  NSMutableString      * pageName = nil;
  NSString             * sessionIdKey = [GSWApp sessionIdKey];
  int p = 0;
  int count = 0;
  int length = 0;
  int pageNameLocation = 0;
  int pageNameLength = 0;
  
  if ((pathArray))
  {
    count = [pathArray count];
  }
  
  if (count != 0)
  {
    lastObject = [pathArray lastObject];
    if(count > 1)
    {
      penultElement = [pathArray objectAtIndex:count - 2];
    }
    
    for (length = [lastObject length]; ((p < length) && (isdigit([lastObject characterAtIndex:p]) != 0)); p++) { }
    
    if ((p < length) && ([lastObject characterAtIndex:p] == '.')) {
      aContextID = [lastObject substringToIndex:p];
      p++;
      aSenderID = [lastObject substringFromIndex:p];
      
      if ((penultElement != nil) && ([penultElement hasSuffix:GSWPagePSuffix[GSWebNamingConv]])) {
        if (GSWebNamingConv == 1) {
          pageNameLength = count - 2; // .wo
        } else {
          pageNameLength = count - 4; // .gswc
        }
      } else {
        if (penultElement != nil) {
          aSessionID = penultElement;
          pageNameLength = count - 2;   // TODO:check if that works with GSWNAMES.
        } else {
          pageNameLength = 0;
        }
      }
      if (aContextID != nil)
      {
        [aDictionary setObject:aContextID forKey:GSWKey_ContextID[GSWebNamingConv]]; // wocid
        [aDictionary setObject:aSenderID forKey:GSWKey_ElementID[GSWebNamingConv]]; // woeid
      }
    } else {
      if ([lastObject hasSuffix:GSWPagePSuffix[GSWebNamingConv]]) {
        pageNameLength = count;
      } else {
        aSessionID = lastObject;
        pageNameLength = count - 1;
      }
    }
    
    if (pageNameLength != 0) {
      if (pageNameLength == 1) {
        pageName = [pathArray objectAtIndex:0];
      } else {
        int i;
        pageName = [(NSMutableString*) [NSMutableString alloc] initWithCapacity:256];
        [pageName autorelease];
        
        for (i = pageNameLocation; i < pageNameLength - pageNameLocation; i++) {
          [pageName appendString:[pathArray objectAtIndex:i]];
          [pageName appendString:@"/"];
        }
        [pageName appendString:[pathArray objectAtIndex:i]];
      }
      if ([pageName hasSuffix:GSWPagePSuffix[GSWebNamingConv]]) {
        if (GSWebNamingConv == 1) {
          pageName = (NSMutableString*) [pageName substringToIndex:[pageName length] - 3]; // .wo
        } else {
          pageName = (NSMutableString*) [pageName substringToIndex:[pageName length] - 5]; // .gswc
        }
      }
      [aDictionary setObject:pageName 
                      forKey:GSWKey_PageName[GSWebNamingConv]];
    }
    
    if (aSessionID == nil) {
      aSessionID = [aRequest stringFormValueForKey:sessionIdKey];
      
      if(aSessionID == nil) {
        aSessionID = [aRequest cookieValueForKey:sessionIdKey];
      }
    }
  } else {
    if ([GSWApp shouldRestoreSessionOnCleanEntry:aRequest]) {
      aSessionID = [aRequest cookieValueForKey:sessionIdKey];
    }
  }
  
  if ((aSessionID != nil) && ([aSessionID length] > 0)) {
    [aDictionary setObject:aSessionID forKey:sessionIdKey];
  }
  return aDictionary;
}

GSWResponse * _dispatchWithPreparedPage(GSWComponent * aPage, GSWSession * aSession, GSWContext * aContext, NSDictionary * someElements)
{
  GSWRequest      * aRequest = [aContext request];
  GSWApplication  * anApplication = GSWApp;
  GSWResponse     * aResponse = [anApplication createResponseInContext:aContext];
  NSString        * aSenderID = [aContext senderID];
  NSString        * oldContextID = [aSession _contextIDMatchingIDsInContext:aContext];
  BOOL              didPageChange = NO;

  [aResponse setHTTPVersion:[aRequest httpVersion]];
  [aResponse setHeader:@"text/html"
                forKey:@"content-type"];
  [aContext _setResponse:aResponse];
  
  if (oldContextID == nil) {
    if ((aSenderID != nil) && ([aRequest _hasFormValues])) {
      [anApplication takeValuesFromRequest:aRequest inContext:aContext];
    }
    [aContext _setPageChanged:NO];
    
    if (aSenderID != nil) {
      GSWElement * anActionResults = [anApplication invokeActionForRequest:aRequest inContext:aContext];

      if ((anActionResults == nil) || ([anActionResults isKindOfClass: [GSWComponent class]])) {
        GSWComponent  * aResultComponent = (GSWComponent*) anActionResults;

        if ((aResultComponent != nil) && ([aResultComponent context] != aContext)) {
          [aResultComponent _awakeInContext:aContext];
        }        
        
        if ((aResultComponent != nil) && (aResultComponent != [aContext _pageElement])) {
          didPageChange = YES;
        }
        
        [aContext _setPageChanged:didPageChange];

        if (didPageChange) {
          [aContext _setPageElement:aResultComponent];
        }
      } else {
        // CHECKME: extend the GSWElement protocol? -- dw
        GSWResponse * theResponse = [(GSWComponent*)anActionResults generateResponse];
        return theResponse;
      }
    }
  } else {
    GSWComponent * responsePage = [aSession restorePageForContextID:oldContextID];
    [aContext _setPageElement:responsePage];
  }
  
  [anApplication appendToResponse:aResponse inContext: aContext];
  
  return aResponse;
}

GSWResponse * _dispatchWithPreparedSession(GSWSession * aSession, GSWContext * aContext, NSDictionary * someElements)
{
  GSWComponent    * aPage = nil;
  GSWResponse     * aResponse = nil;
  NSString        * aPageName = [someElements objectForKey:GSWKey_PageName[GSWebNamingConv]]; // "wopage"
  NSString        * oldContextID = [aContext _requestContextID];
  GSWApplication  * anApplication = GSWApp;
  NSString        * sessionIdKey = [anApplication sessionIdKey];
  NSString        * oldSessionID = [someElements objectForKey:sessionIdKey];
  BOOL              clearIDsInCookies = NO;
  BOOL              storesIDsInCookies = [aSession storesIDsInCookies];
  
  if ((oldSessionID == nil) || (oldContextID == nil)) {
    if ((aPageName == nil) && (!storesIDsInCookies))
    {
      GSWRequest * request = [aContext request];
      NSString   * cookieHeader = [request headerForKey:GSWHTTPHeader_Cookie]; //"cookie"
      if ((cookieHeader != nil) && ([cookieHeader length] > 0)) {
        NSDictionary * cookieDict = [request cookieValues];

        if (([cookieDict objectForKey:sessionIdKey] != nil) || 
            ([cookieDict objectForKey:[anApplication instanceIdKey]] != nil)) {
          clearIDsInCookies = YES;
        }
      }
    }
    aPage = [anApplication pageWithName:aPageName inContext:aContext];
  } else {
    aPage = [aSession restorePageForContextID:oldContextID];

    if (aPage == nil) {
      if ([anApplication _isPageRecreationEnabled]) {
        aPage = [anApplication pageWithName:aPageName inContext: aContext];
      } else {
        return [anApplication handlePageRestorationErrorInContext:aContext];
      }
    }
  }
  
  [aContext _setPageElement:aPage];
  aResponse = _dispatchWithPreparedPage(aPage, aSession, aContext, someElements);

  if ([anApplication isPageRefreshOnBacktrackEnabled]) {
    [aResponse disableClientCaching];
  }
  
  [aSession _saveCurrentPage];
  
  if ((clearIDsInCookies) && (!storesIDsInCookies)) {
    [aSession _clearCookieFromResponse:aResponse];
  }
  
  return aResponse;
}


GSWResponse * _dispatchWithPreparedApplication(GSWApplication *app, GSWContext * aContext, NSDictionary * requestHandlerDict)
{
  GSWSession  * session = nil;
  GSWResponse * response = nil;
  NSString    * sessionID;

  sessionID = [requestHandlerDict objectForKey:GSWKey_SessionID[GSWebNamingConv]]; //@"wosid"
  if ((!sessionID)) {
    session = [app _initializeSessionInContext:aContext];
    if (session == nil) {
      response = [app handleSessionCreationErrorInContext:aContext];
    }
  } else {
    session = [app restoreSessionWithID:sessionID inContext:aContext];
    if (session == nil) {
      response = [app handleSessionRestorationErrorInContext:aContext];
    }
  }

  if (response == nil) {
      response = _dispatchWithPreparedSession(session, aContext, requestHandlerDict);
  }

  [aContext _putAwakeComponentsToSleep];
  [app saveSessionForContext:aContext];
  
  return response;
}

- (GSWResponse*) _handleRequest:(GSWRequest*) aRequest
{
  GSWContext          * aContext = nil;
  NSDictionary        * requestHandlerValues;
  NSString            * aSessionID;
  NSString            * aSenderID;
  NSString            * oldContextID;
  GSWStatisticsStore  * aStatisticsStore;
  GSWResponse         * aResponse;
  GSWApplication      * app = GSWApp;   // is there any reason not to use the global var? -- dw
  
  requestHandlerValues = [self requestHandlerValuesForRequest:aRequest];
  aSessionID = [requestHandlerValues objectForKey:[app sessionIdKey]];
  
  if ((aSessionID == nil) && [app isRefusingNewSessions]) 
  {
    NSString * newLocationURL = [app _newLocationForRequest:aRequest];
    NSString * msgString = [NSString stringWithFormat:@"Sorry, your request could not immediately be processed. Please try this URL: <a href=\"%@\">%@</a>",
                            newLocationURL, newLocationURL];
    
    aResponse = [app createResponseInContext:nil];
    [aResponse _redirectResponse:newLocationURL contentString:msgString];
    [aResponse _finalizeInContext:nil];
    
    return aResponse;
  }
  
  aSenderID = [requestHandlerValues objectForKey:GSWKey_ElementID[GSWebNamingConv]];
  oldContextID = [requestHandlerValues objectForKey:GSWKey_ContextID[GSWebNamingConv]];
  
  if ((aStatisticsStore = [app statisticsStore]))
  {
    [aStatisticsStore applicationWillHandleComponentActionRequest];
  }
  
  NS_DURING {
    aContext = [app createContextForRequest:aRequest];
    [aContext _setRequestContextID:oldContextID];
    [aContext _setSenderID:aSenderID];
    
    [app awake];
    aResponse = _dispatchWithPreparedApplication(app, aContext, requestHandlerValues);
    [[NSNotificationCenter defaultCenter] postNotificationName:DidHandleRequestNotification
                                                        object:aContext];
    
    [app sleep];
  } NS_HANDLER {
    GSWSession * aSession = nil;
    
    NSLog(@"%s: Exception occurred while handling request:%@", __PRETTY_FUNCTION__, [localException reason]);
    
    if(aContext == nil)
    {
      aContext = [app createContextForRequest:aRequest];
    } else {
      [aContext _putAwakeComponentsToSleep];
    }
    
    aSession = [aContext _session];
    aResponse = [app handleException:localException 
                           inContext:aContext];
    
    if (aSession) {
      NS_DURING {
        [app saveSessionForContext:aContext];
        [app sleep];
      } NS_HANDLER {
        NSLog(@"WOApplication '%@': Another Exception occurred while trying to clean the application :%@", [app name], [localException reason]);
      } NS_ENDHANDLER;
    }
    
  } NS_ENDHANDLER;
  
  if ((aContext) && ([aContext _session]))
  {
    [app saveSessionForContext:aContext];
  }
  
  if ((aResponse))
  {
    [aResponse _finalizeInContext:aContext];
  }
  
  if ((aStatisticsStore))
  {
    GSWComponent * aPage = [aContext page];
    NSString     * pageName = nil;
    
    if ((aPage))
    {
      pageName = [aPage name];
    }
    [aStatisticsStore applicationDidHandleComponentActionRequestWithPageNamed:pageName];
  }
  return aResponse;
}



/** Handle request aRequest and return the response 
    This may lock the application
**/

-(GSWResponse*)handleRequest:(GSWRequest*)aRequest
{
  //OK
  GSWResponse* response=nil;
  NSLock        * lock;

  lock = [GSWApp requestHandlingLock];
  
  if (lock) {
    SYNCHRONIZED(lock) {
      response = [self _handleRequest:aRequest];
    }
    END_SYNCHRONIZED;
    
  } else {
    // no locking
    response = [self _handleRequest:aRequest];
  }
  
  return response;
}

// do we need this? -- dw
// used in GSWApplication _componentRequestHandler
+(id)handler
{
  return [[GSWComponentRequestHandler new] autorelease];
}


@end

