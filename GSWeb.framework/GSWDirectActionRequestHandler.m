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
  submitButtonsActionPathFromRequest=[self submitButtonsActionPathFromRequest:aRequest];
  NSDebugMLLog(@"requests",@"submitButtonsActionPathFromRequest=%@",
               submitButtonsActionPathFromRequest);
  if (submitButtonsActionPathFromRequest)
    requestHandlerPath=[submitButtonsActionPathFromRequest componentsSeparatedByString:@"/"];
  else
    requestHandlerPath=[aRequest requestHandlerPathArray];
  return requestHandlerPath;
}

//--------------------------------------------------------------------
-(NSString*)submitButtonsActionPathFromRequest:(GSWRequest*)aRequest
{
  NSString* path=nil;
  LOGObjectFnStart();
  
  if (!_allowsContentInputStream)
    {
      NSArray* submitActions=[aRequest formValuesForKey:GSWKey_SubmitAction[GSWebNamingConv]];
      if (submitActions)
        {
          int count=[submitActions count];
          int i=0;
          for(i=0;!path && i<count;i++)
            {
              NSString* submitAction=[submitActions objectAtIndex:i];
              if ([aRequest formValuesForKey:submitAction])
                path = submitAction;
              else
                {
                  // Try image buttons
                  NSString* imageButtonFormValueName=[submitAction stringByAppendingString:@".x"];
                  if ([aRequest formValuesForKey:imageButtonFormValueName])
                    path = submitAction;
                };
            }
        };
    };
  
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
-(GSWResponse*)generateNullResponse
{
  GSWResponse* response=nil;
  LOGObjectFnStart();
  response=[GSWApp createResponseInContext:nil];
  [response appendContentString:@"<HTML><HEAD><TITLE>DirectAction Error</TITLE></HEAD><BODY><CENTER>The result of a direct action returned nothing.</CENTER></BODY></HTML>"];
  LOGObjectFnStop();
  return response;
};


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

-(void)setAllowsContentInputStream:(BOOL)yn
{
  _allowsContentInputStream = yn;
};

-(BOOL)allowsContentInputStream
{
  return _allowsContentInputStream;
};

-(void)setDisplayExceptionPages:(BOOL)yn
{
  _displayExceptionPages=yn;
};

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


