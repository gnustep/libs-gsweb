/** GSWRecording.m - <title>GSWeb: Class GSWRecording</title>

   Copyright (C) 2004 Free Software Foundation, Inc.
   
   Written by:  Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        Aug 2003

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
#include "GSWRecording.h"

//====================================================================
@implementation GSWRecording

//--------------------------------------------------------------------
-(void)_setRecordingPath:(NSString*)recordingPath
{
  LOGObjectFnStart();

  NSDebugMLog(@"recordingPath=%@",recordingPath);

  if (recordingPath)
    {
      int i=0;
      NSString* basePath=nil;
      NSFileManager* fileManager=[NSFileManager defaultManager];
      // path cound be application recording path (ending by .rec) or general path
      
      if ([[recordingPath pathExtension]isEqualToString:@"rec"])
        basePath=[recordingPath stringByDeletingPathExtension]; // application path
      else
        {
          // Build application path
          BOOL isDirectory=NO;
          if ([fileManager fileExistsAtPath:recordingPath
                           isDirectory:&isDirectory]
              && isDirectory)
            {
              // /recordingPath/AppName/
              basePath=[recordingPath stringByAppendingPathComponent:[[GSWApplication application] name]];
            }
          else
            {
              basePath=recordingPath;
            };
        };

      NSDebugMLog(@"basePath=%@",basePath);

      recordingPath=[basePath stringByAppendingPathExtension:@"rec"];

      NSDebugMLog(@"recordingPath=%@",recordingPath);

      i=0;
      while([fileManager fileExistsAtPath:recordingPath])
          recordingPath=[[NSString stringWithFormat:@"%@-%d",basePath,i++]stringByAppendingPathExtension:@"rec"];
      
      ASSIGN(_recordingPath,recordingPath);
      NSDebugMLog(@"_recordingPath=%@",_recordingPath);
      
      if (![fileManager createDirectoryAtPath:_recordingPath
                        attributes:nil])
        {
          ExceptionRaise(@"GSWRecording: can't create directory '%@'",_recordingPath);
        };
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
    {
      NSString* recordingPath=nil;
      NSNotificationCenter* defaultCenter=nil;

      recordingPath=[[[GSWApplication application] class]recordingPath];
      [self _setRecordingPath:recordingPath];

      // Register observers
      defaultCenter=[NSNotificationCenter defaultCenter];
      [defaultCenter addObserver:self
                     selector:@selector(_applicationWillDispatchRequest:)
                     name:@"ApplicationWillDispatchRequestNotification"
                     object:nil];
      [defaultCenter addObserver:self
                     selector:@selector(_applicationDidDispatchRequest:)
                     name:@"ApplicationDidDispatchRequestNotification"
                     object:nil];
      
      //TODO          wildcards = "/##*##/##*##/" with Application name() + ".gswa/##*##/"
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_request);
  DESTROY(_recordingPath);
  DESTROY(_wildcards);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)_headersStringForMessage:(GSWMessage*)message
{
  NSMutableString* headersString=[NSMutableString string];
  NSArray* headerKeys=nil;
  int i=0;
  int count=0;

  LOGObjectFnStart();

  headerKeys=[message headerKeys];
  count=[headerKeys count];

  for(i=0;i<count;i++)
    {
      NSString* headerKey=[headerKeys objectAtIndex:i];

      if (![headerKey isEqualToString:@"x-gsweb-request-id"])
        {
          NSArray* headerValues=[message headersForKey:headerKey];
          int headerValuesCount=[headerValues count];
          int j=0;
          for(j=0;j<headerValuesCount;j++)
            {
              id value = [headerValues objectAtIndex:j];
              [headersString appendFormat:@"%@: %@\r\n",headerKey,value];
            };          
        };
    };

  if ([message isKindOfClass:[GSWRequest class]])
    [headersString appendString:@"x-gsweb-recording: on\r\n"];

  [headersString appendString:@"\r\n"];

  LOGObjectFnStop();
  return headersString;
}


//--------------------------------------------------------------------
-(GSWResponse*)_wildcardedResponse:(GSWResponse*)response
{
  NSString* sessionID = nil;
  NSMutableData* contentData = nil;
  int contentLength=0;
  NSString* applicationURLPrefix=nil;
  NSStringEncoding contentEncoding=NSUTF8StringEncoding;

  LOGObjectFnStart();

  response = (GSWResponse*)[[response copy]autorelease];
  sessionID = [response headerForKey:GSWHTTPHeader_RecordingSessionID[GSWebNamingConv]];
  NSDebugMLLog(@"GSWRecording",@"sessionID=%@",sessionID);
  contentEncoding=[response contentEncoding];
  contentData = [[[response content] mutableCopy]autorelease];
  contentLength=[contentData length];

  // Replace sessionID by ##GSWSESSIONID##
  if (sessionID)
    {
      [contentData replaceOccurrencesOfData:[sessionID dataUsingEncoding:contentEncoding]
                   withData:[@"##GSWSESSIONID##" dataUsingEncoding:contentEncoding]
                   range:NSMakeRange(0,[contentData length])];
    };

  applicationURLPrefix=[_request _applicationURLPrefix];
  NSDebugMLLog(@"GSWRecording",@"applicationURLPrefix=%@",
               applicationURLPrefix);
  NSAssert(applicationURLPrefix,@"No applicationURLPrefix");

  [contentData replaceOccurrencesOfData:[applicationURLPrefix dataUsingEncoding:contentEncoding]
                 withData:[@"##GSWAPPURLPREFIX##" dataUsingEncoding:contentEncoding]
                 range:NSMakeRange(0,[contentData length])];

  // Set new Content Length
  [response setHeader:GSWIntToNSString([contentData length])
            forKey:@"GSWHTTPHeader_ContentLength"];
  [response setHeader:GSWIntToNSString(contentLength)
            forKey:@"x-gsweb-unwildcarded-content-length"];
  [response setContent:contentData];

  LOGObjectFnStop();
  return response;
}

//--------------------------------------------------------------------
-(void)saveRequest:(GSWRequest*)request
{
  LOGObjectFnStart();

  NSDebugMLog(@"_recordingStep=%d",_recordingStep);  

  ASSIGN(_request,request);

  NSDebugMLog(@"request=%p",request);  

  if (request)
    {
      NSString* headerString=nil;
      NSString* requestString=nil;

      NSString* requestURI=[_request uri];
      NSString* filePath= [_recordingPath stringByAppendingPathComponent:
                                            [NSString stringWithFormat:@"%0.6d-request",_recordingStep]];

      [GSWApplication logWithFormat:@"Saving Request into '%@'",filePath];

      headerString = [NSString stringWithFormat:@"%@ %@ %@\r\n%@",
                               [_request method],
                               requestURI,
                               [_request httpVersion],
                               [self _headersStringForMessage:_request]];
      NSDebugMLog(@"  headerString=%@",  headerString);  
      requestString = [headerString stringByAppendingString:[request contentString]];

      [requestString writeToFile:filePath
                     atomically:NO];
    };

  LOGObjectFnStop();
}

//--------------------------------------------------------------------
-(void)saveResponse:(GSWResponse*)response
{
  NSString* filePath=nil;
  NSString* responseString=nil;
  NSString* headerString=nil;

  LOGObjectFnStart();

  NSDebugMLog(@"_recordingStep=%d",_recordingStep);  

  NSDebugMLLog(@"GSWRecording",@"recordingSessionID=%@",
               [response headerForKey:GSWHTTPHeader_RecordingSessionID[GSWebNamingConv]]);

  response = [self _wildcardedResponse:response];

  filePath= [_recordingPath stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"%0.6d-response",_recordingStep]];

  [GSWApplication logWithFormat:@"Saving Response into '%@'",filePath];

  headerString=[NSString stringWithFormat:@"%@ %u %@\r\n%@",
                         [response httpVersion],
                         (unsigned int)[response status],
                         GSWHTTPHeader_Response_HeaderLineEnd[GSWebNamingConv],
                         [self _headersStringForMessage:response]];

  NSDebugMLog(@"headerString=%@",headerString);  

  responseString = [headerString stringByAppendingString:[response contentString]];

  [responseString writeToFile:filePath
                  atomically:NO];
  _recordingStep++;

  NSDebugMLog(@"_recordingStep=%d",_recordingStep);  

  LOGObjectFnStop();
}

//--------------------------------------------------------------------
-(void)_applicationWillDispatchRequest:(NSNotification*)notification
{
  GSWRequest* request=nil;

  LOGObjectFnStart();

  // Get the request
  request = (GSWRequest*)[notification object];

  NSDebugMLog(@"request=%p",request);  

  // Save it
  [self saveRequest:request];

  LOGObjectFnStop();
}

//--------------------------------------------------------------------
-(void)_applicationDidDispatchRequest:(NSNotification*)notification
{
  LOGObjectFnStart();

  NSDebugMLog(@"_request=%p",_request);  

  if (_request)
    {
      // Get the response
      GSWResponse* response = (GSWResponse*)[notification object];

      // Save it
      [self saveResponse:response];
    }

  LOGObjectFnStop();
};

@end
