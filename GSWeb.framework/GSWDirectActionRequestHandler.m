/** GSWDirectActionRequestHandler.m - <title>GSWeb: Class GSWDirectActionRequestHandler</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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
-(id)init
{
  if ((self=[super init]))
    {
      ASSIGN(_actionClassName,[self defaultActionClassName]);
      ASSIGN(_defaultActionName,[self defaultDefaultActionName]);
      _displayExceptionPages = [self defaultDisplayExceptionPages];
    };
  return self;
};

- (NSString*) _submitButtonsActionPathFromRequest:(GSWRequest*) request
{
  NSString * resStr = nil;
  NSArray  * formValues = nil;
  
  if (_allowsContentInputStream) {
    return nil;
  }
  formValues = [request formValuesForKey:@"WOSubmitAction"];
  if (formValues != nil) {
    int i = [formValues count];
    int j = 0;
    NSString * value = nil;

    do {
      if (j >= i) {
        break;
      }
      value = [formValues objectAtIndex:j];
      if ([request formValuesForKey:value] != nil) {
        resStr = value;
        break;
      }
      if ([request formValuesForKey:[value stringByAppendingString:@".x"]] != nil) {
        resStr = value;
        break;
      }
      j++;
    } while (YES);
  }
  return resStr;
}

//--------------------------------------------------------------------
-(BOOL)defaultDisplayExceptionPages
{
  return [GSWApplication defaultDisplayExceptionPages];
};

//--------------------------------------------------------------------
-(NSString*)defaultActionClassName
{
  return @"DirectAction";
}

//--------------------------------------------------------------------
-(void)registerWillHandleActionRequest
{
  [[[GSWApplication application]statisticsStore]
    applicationWillHandleDirectActionRequest];
}

//--------------------------------------------------------------------
-(void)registerDidHandleActionRequestWithActionNamed:(NSString*)actionName
{
  [[[GSWApplication application]statisticsStore]
    applicationDidHandleDirectActionRequestWithActionNamed:actionName];
}

//--------------------------------------------------------------------
-(NSArray*)getRequestHandlerPathForRequest:(GSWRequest*)aRequest
{
  NSArray* requestHandlerPath=nil;
  id submitButtonsActionPathFromRequest=nil;
  submitButtonsActionPathFromRequest=[self _submitButtonsActionPathFromRequest:aRequest];

  if (submitButtonsActionPathFromRequest)
    requestHandlerPath=[submitButtonsActionPathFromRequest componentsSeparatedByString:@"/"];
  else
    requestHandlerPath=[aRequest requestHandlerPathArray];
  return requestHandlerPath;
}


//--------------------------------------------------------------------
-(GSWResponse*)generateNullResponse
{
  GSWResponse* aResponse=nil;

  aResponse = [GSWApp createResponseInContext:nil];

  [aResponse setStatus:500];
  GSWResponse_appendContentString(aResponse,@"<html><head><title>Error</title></head><body>Your request produced an error.</body></html>");

  return aResponse;
}

//--------------------------------------------------------------------
-(GSWResponse*)generateRequestRefusalResponseForRequest:(GSWRequest*)aRequest
{
  GSWResponse* response=nil;
  
  response = [GSWResponse generateRefusingResponseInContext:nil
                                                 forRequest:aRequest];
  return response;
}

//--------------------------------------------------------------------
-(GSWResponse*)generateErrorResponseWithException:(NSException*)exception
                                        inContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  
  if (_displayExceptionPages)
    response = [GSWApp handleException:exception
                             inContext:aContext];
  return response;
}

//--------------------------------------------------------------------
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

//--------------------------------------------------------------------
-(void)setAllowsContentInputStream:(BOOL)yn
{
  _allowsContentInputStream = yn;
};

//--------------------------------------------------------------------
-(BOOL)allowsContentInputStream
{
  return _allowsContentInputStream;
};

//--------------------------------------------------------------------
-(void)setDisplayExceptionPages:(BOOL)yn
{
  _displayExceptionPages=yn;
};

//--------------------------------------------------------------------
-(BOOL)displayExceptionPages
{
  return _displayExceptionPages;
};

@end

//====================================================================
@implementation GSWDirectActionRequestHandler (GSWRequestHandlerClassA)

//--------------------------------------------------------------------
+(id)handler
{
  return [self handlerWithDefaultActionClassName:@"DirectAction"
               defaultActionName:@"default"
               shouldAddToStatistics:YES];
};

//--------------------------------------------------------------------
+(GSWDirectActionRequestHandler*)handlerWithDefaultActionClassName:(NSString*)defaultActionClassName
                                                 defaultActionName:(NSString*)defaultActionName
                                             displayExceptionPages:(BOOL)displayExceptionPages
{
  GSWDirectActionRequestHandler* darh=[[[self alloc]initWithDefaultActionClassName:defaultActionClassName
                                                    defaultActionName:defaultActionName
                                                    shouldAddToStatistics:YES]autorelease];  
  [darh setDisplayExceptionPages:displayExceptionPages];
  return darh;
};
@end


