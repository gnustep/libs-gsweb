/** GSWDefaultAdaptorThread.m - <title>GSWeb: Class GSWDefaultAdaptorThread</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        Feb 1999

   $Revision$
   $Date$
   $Id$
   
   <abstract></abstract>

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
#include <unistd.h>
#include <math.h> //for fabs
#include "NSNonBlockingFileHandle.h"
#define ADAPTOR_THREAD_TIME_OUT  (5*60) //threads waiting for more than 5 minutes are not processed

//====================================================================
@implementation GSWDefaultAdaptorThread

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
    {
      ASSIGN(_creationDate,[NSDate date]);
      _requestNamingConv=GSWebNamingConv;//GSWNAMES_INDEX or WONAMES_INDEX
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithApp:(GSWApplication*)application
     withAdaptor:(GSWAdaptor*)adaptor
      withStream:(NSFileHandle*)stream
{
  if ((self=[self init]))
    {
      _application=application;
      _adaptor=adaptor;
      ASSIGN(_stream,stream);
      _keepAlive=NO;
      _isMultiThread=[adaptor isMultiThreadEnabled];
      NSDebugDeepMLLog(@"info",@"isMultiThread=%d",(int)_isMultiThread);
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogMemC("dealloc GSWDefaultAdaptorThread");
  DESTROY(_stream);
  GSWLogMemC("release dates");
  DESTROY(_creationDate);
  DESTROY(_runDate);
  DESTROY(_dispatchRequestDate);
  DESTROY(_sendResponseDate);
  DESTROY(_remoteAddress);
  GSWLogMemC("release pool");
//  DESTROY(_pool);
  GSWLogMemC("super dealloc");
  [super dealloc];
  GSWLogMemC("dealloc GSWDefaultAdaptorThread end");
};

//--------------------------------------------------------------------
-(GSWAdaptor*)adaptor
{
  return _adaptor;
};

//--------------------------------------------------------------------
-(NSAutoreleasePool*)pool
{
  return _pool;
};

//--------------------------------------------------------------------
-(void)setPool:(NSAutoreleasePool*)pool
   destroyLast:(BOOL)destroy
{
  if (destroy)
    {
      GSWLogMemC("dealloc pool\n");
      GSWLogMemCF("Destroy NSAutoreleasePool: %p. ThreadID=%p",_pool,(void*)objc_thread_id());
      DESTROY(_pool);
      GSWLogMemC("end dealloc pool\n");
    };
  _pool=pool;
};

//--------------------------------------------------------------------
-(void)run:(id)nothing
{
  BOOL requestOk=NO;
  NSMutableDictionary* threadDictionary=nil;
  NSString* requestLine=nil;
  NSDictionary* headers=nil;
  NSData* data=nil;
  ASSIGN(_runDate,[NSDate date]);
  DESTROY(_dispatchRequestDate);
  DESTROY(_sendResponseDate);
#ifdef GSWDEBUG_DEEP
  [GSWApplication statusLogWithFormat:@"Thread run START"];
#endif
  _pool=[NSAutoreleasePool new];
  GSWLogMemCF("New NSAutoreleasePool: %p",_pool);
#ifdef GSWDEBUG_DEEP
  [GSWApplication logWithFormat:@"pool allocated!"];
#endif
  if (_isMultiThread)
    {
      threadDictionary=GSCurrentThreadDictionary();
      [threadDictionary setObject:self
                        forKey:GSWThreadKey_DefaultAdaptorThread];
      [[NSNotificationCenter defaultCenter] addObserver:[self class]
                                            selector:@selector(threadExited:)
                                            name:NSThreadExiting//NSThreadWillExitNotification
                                            object:[NSThread currentThread]];
      /*
        [NotificationDispatcher addObserver:[self class]
        selector:@selector(threadExited:)
        name:NSThreadExiting//NSThreadWillExitNotification
        object:[NSThread currentThread]];
      */
    };
  NSDebugDeepMLLog(@"low",@"application:%@",_application);

  NS_DURING
    {
      requestOk=[self readRequestReturnedRequestLine:&requestLine
                      returnedHeaders:&headers
                      returnedData:&data];
    }
  NS_HANDLER
    {
      LOGException(@"GSWDefaultAdaptorThread: readRequestFromStream Exception:%@ (%@)",
                   localException,[localException reason]);
    }
  NS_ENDHANDLER;
  if (!requestOk)
    {
      //TODO
    }
  else
    {
      GSWRequest* request=nil;
      GSWResponse* response=nil;
      NSDebugMLLog(@"info",@"GSWDefaultAdaptorThread: runWithStream requestLine=%@ headers=%@ data=%@",
                   requestLine,
                   headers,
                   data);
      NS_DURING
        {
          request=[self createRequestFromRequestLine:requestLine
                        headers:headers
                        data:data];
        }
      NS_HANDLER
        {
          NSDebugMLog(@"localException=%@",localException);
          LOGException(@"GSWDefaultAdaptorThread: createRequestFromData Exception:%@ (%@)",
                       localException,[localException reason]);
        }
      NS_ENDHANDLER;
      if (request)
        {
          //call  application resourceRequestHandlerKey (retourne wr)
          //call requets requestHandlerKey (retorune nil)
          NSDebugMLLog(@"info",@"GSWDefaultAdaptorThread: run handleRequest:%@",request);
          ASSIGN(_dispatchRequestDate,[NSDate date]);
          NS_DURING
            {
              response=[_application dispatchRequest:request];
            }
          NS_HANDLER
            {
              BOOL isApplicationRequestHandlingLocked=[_application isRequestHandlingLocked];
              LOGException(@"GSWDefaultAdaptorThread: dispatchRequest Exception:%@ (%@)%s",
                           localException,
                           [localException reason],
                           isApplicationRequestHandlingLocked ? " Request Handling Locked !" : "");
            }
          NS_ENDHANDLER;
          if (!response)
            {
              response=[GSWResponse responseWithMessage:@"Application returned no response"
                                    inContext:nil
                                    forRequest:request];
              [response _finalizeInContext:nil]; //DO Call _finalizeInContext: !
            };
          if (response)
            {
              RETAIN(response);
              ASSIGN(_sendResponseDate,[NSDate date]);
              NS_DURING
                {
                  [self sendResponse:response];
                }
              NS_HANDLER
                {
                  LOGException(@"GSWDefaultAdaptorThread: sendResponse Exception:%@ (%@)",
                               localException,
                               [localException reason],
                               [localException userInfo]);
                }
              NS_ENDHANDLER;
              NSDebugMLLog(@"low",@"application:%@",_application);
              AUTORELEASE(response);
            };
        };
    };
  NSDebugMLog(@"GSWDefaultAdaptorThread: ThreadID=%p run end",
              (void*)objc_thread_id());
  NSDebugMLLog(@"low",@"application:%@",
               _application);
  LOGObjectFnStop();
#ifdef DEBUG
  [GSWApplication statusLogWithFormat:@"threadWillExit START"];
#endif
  [_application threadWillExit];
#ifdef DEBUG
  [GSWApplication statusLogWithFormat:@"threadWillExit STOP"];
#endif
  if (_isMultiThread)
    {
      NSAssert([NSThread isMultiThreaded],@"No MultiThread !");
      [NSThread exit]; //???
    }
  else
    [self threadExited];
#ifdef DEBUG
  [GSWApplication statusLogWithFormat:@"run STOP"];
#endif
};

//--------------------------------------------------------------------
-(void)threadExited
{
//  LOGObjectFnStart();
//  NSDebugMLLog0(@"trace",@"GSWDefaultAdaptorThread: threadExited method");
//  NSDebugMLLog(@"low",@"[_defaultAdaptorThread retainCount=%d",
//			   (int)[self retainCount]);
  [_adaptor adaptorThreadExited:self];
  GSWLogMemCF("Will Destroy NSAutoreleasePool: %p",_pool);
  [self setPool:nil
        destroyLast:YES];
//  LOGObjectFnStop();
  GSWLogDeepC("threadExited\n");
};

//--------------------------------------------------------------------
+(id)threadExited:(NSNotification*)notif
{
  NSThread* thread=nil;
  NSMutableDictionary* threadDict=nil;
  GSWDefaultAdaptorThread* adaptorThread=nil;
  GSWLogDeepC("Start threadExited:");
  NSAssert([NSThread isMultiThreaded],@"No MultiThread !");
  NSDebugMLLog(@"low",@"notif=%@",notif);
  thread=[notif object];
  NSDebugMLLog(@"low",@"thread=%@",thread);
  threadDict = [thread threadDictionary];
  NSDebugMLLog(@"low",@"threadDict=%@",threadDict);
  adaptorThread=[threadDict objectForKey:GSWThreadKey_DefaultAdaptorThread];
  NSDebugMLLog(@"low",@"adaptorThread=%@",adaptorThread);
  [threadDict removeObjectForKey:GSWThreadKey_DefaultAdaptorThread];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                        name:NSThreadExiting//NSThreadWillExitNotification
                                        object:thread];
  /*  [NotificationDispatcher removeObserver:self
      name:NSThreadExiting//NSThreadWillExitNotification
      object:_thread];
  */
  [adaptorThread threadExited];
  GSWLogDeepC("Stop threadExited:");
  GSWLogDeepC("threadExited really exit");
  return nil; //??
};

//--------------------------------------------------------------------
+(NSMutableArray*)completeLinesWithData:(NSMutableData*)data
                  returnedConsumedCount:(int*)consumedCount
                 returnedHeadersEndFlag:(BOOL*)headersEndFlag
{
  NSMutableArray* lines=nil;
  int length=0;
  LOGClassFnStart();
  length=[data length];
  if (length>0)
    {
      NSRange range=NSMakeRange(0,0);
      int i=0;
      char* dataBytes=(char*)[data mutableBytes];
      BOOL endHeaders=NO;
      while(!endHeaders && i<length)
        {
          if (dataBytes[i]=='\n')
            {
              if (range.length>0)
                {
                  NSString* tmpString=[[[NSString alloc]initWithData:[data subdataWithRange:range]
                                                        encoding:NSASCIIStringEncoding]autorelease];
                  if (!lines)
                    lines=[NSMutableArray array];
                  [lines addObject:tmpString];
                }
              else // End Header
                {
                  endHeaders=YES;
                };
              range.location=i+1;
              range.length=0;
            }
          else
            range.length++;
          i++;
        };
      range.length=length-range.location;
      if (range.length>0)
        memcpy(dataBytes,dataBytes+range.location,range.length);
      [data setLength:range.length];
      if (consumedCount)
        *consumedCount=length-range.length;
      if (headersEndFlag)
        *headersEndFlag=endHeaders;
    };
  LOGClassFnStop();
  return lines;
};

//--------------------------------------------------------------------
/** read request from crrent stream and put request line, headers and data in 
    'requestLinePtr', 'headersPtr', 'dataPtr'. Returns YES if it's OK, NO otherwise 
**/
-(BOOL)readRequestReturnedRequestLine:(NSString**)requestLinePtr
                      returnedHeaders:(NSDictionary**)headersPtr
                         returnedData:(NSData**)dataPtr
{
  BOOL ok=NO;
  LOGObjectFnStart();
  if (!_stream)
    {
      ExceptionRaise0(@"GSWDefaultAdaptorThread",@"no stream");
    }
  else
    {
#define REQUEST_METHOD__UNKNOWN	0
#define REQUEST_METHOD__GET	1
#define REQUEST_METHOD__POST	2
      NSMutableData* pendingData=nil;
      NSDate* maxDate=[NSDate dateWithTimeIntervalSinceNow:360]; //360s
      NSData* dataBlock=nil;
      double sleepTime=0.250; //250ms
      int readenBytesNb=0;
      int headersBytesNb=0;
      int dataBytesNb=0;
      int dataBlockLength=0;
      int contentLength=-1;
      int requestMethod=REQUEST_METHOD__UNKNOWN;
      BOOL isRequestLineSetted=NO;
      BOOL isDataStep=NO;
      BOOL isAllDataReaden=NO;
      BOOL isElapsed=NO;
      NSMutableDictionary* headers=nil;
      NSString* userAgent=nil;
      NSString* remoteAddr=nil;
      NSDebugDeepMLog0(@"dataBlock try reading");
      do
        {
          dataBlock=[_stream availableDataNonBlocking];
          dataBlockLength=[dataBlock length];
          NSDebugDeepMLog(@"dataBlockLength=%i",dataBlockLength);
          if (dataBlockLength>0)
            {
              readenBytesNb+=dataBlockLength;
              if (!pendingData)
                pendingData=(NSMutableData*)[NSMutableData data];
              [pendingData appendData:dataBlock];
              if (isDataStep)
                dataBytesNb=[pendingData length];
              else
                {
                  int newBytesCount=0;
                  NSMutableArray* newLines=[GSWDefaultAdaptorThread completeLinesWithData:pendingData
                                                                    returnedConsumedCount:&newBytesCount
                                                                    returnedHeadersEndFlag:&isDataStep];
                  NSDebugDeepMLLog(@"low",@"newLines=%p",newLines);
                  NSDebugDeepMLLog(@"low",@"newLines=%@",newLines);
                  NSDebugDeepMLLog(@"low",@"isDataStep=%s newBytesCount=%d",
                                   isDataStep ? "YES" : "NO",
                                   newBytesCount);
                  headersBytesNb+=newBytesCount;
                  if (newLines)
                    {
                      int i=0;
                      for(i=0;i<[newLines count];i++)
                        {
                          NSString* line=[newLines objectAtIndex:i];
                          NSDebugDeepMLLog(@"low",@"Line=%@",line);
                          NSAssert([line length]>0,@"No line length");
                          if (!isRequestLineSetted)
                            {
                              *requestLinePtr=line;
                              isRequestLineSetted=YES;
                            }
                          else
                            {
                              NSString* key=nil;
                              NSString* value=nil;
                              NSArray* newValue=nil;
                              NSArray* prevValue=nil;
                              NSRange keyRange=[line rangeOfString:@":"];
                              if (keyRange.length<=0)
                                {
                                  key=line;
                                  NSDebugDeepMLLog(@"low",@"key=%@",key);
                                  value=[NSString string];
                                }
                              else
                                {
                                  key=[line substringToIndex:keyRange.location];
                                  NSDebugDeepMLLog(@"low",@"location=%d key=%@",
                                                   keyRange.location,
                                                   key);
                                  key=[[key stringByTrimmingSpaces] lowercaseString];
                                  NSDebugDeepMLLog(@"low",@"location=%d line length=%d key=%@",
                                               keyRange.location,
                                               [line length],
                                               key);
                                  if (keyRange.location+1<[line length])
                                    {
                                      value=[line substringFromIndex:keyRange.location+1];
                                      NSDebugDeepMLLog(@"low",@"value lengt=%d value=*%@*",
                                                   [value length],
                                                   value);
                                      value=[value stringByTrimmingSpaces];
                                      NSDebugDeepMLLog(@"low",@"value=%@",
                                                   value);
                                    }
                                  else
                                    value=[NSString string];
                                  NSDebugDeepMLLog(@"low",@"value:%@",value);
                                };
                              NSDebugDeepMLLog(@"low",@"key:%@ value:%@",key,value);
                              if ([key isEqualToString:GSWHTTPHeader_ContentLength])
                                contentLength=[value intValue];
                              else if ([key isEqualToString:GSWHTTPHeader_Method[GSWNAMES_INDEX]]
                                       || [key isEqualToString:GSWHTTPHeader_Method[WONAMES_INDEX]])
                                {
                                  if ([value isEqualToString:GSWHTTPHeader_MethodPost])
                                    requestMethod=REQUEST_METHOD__POST;
                                  else if ([value isEqualToString:GSWHTTPHeader_MethodGet])
                                    requestMethod=REQUEST_METHOD__GET;
                                  else
                                    {
                                      NSAssert1(NO,@"Unknown method %@",value);
                                    };
                                }
                              else if ([key isEqualToString:GSWHTTPHeader_UserAgent])
                                userAgent=value;
                              else if ([key isEqualToString:GSWHTTPHeader_RemoteAddress[GSWNAMES_INDEX]]
                                       ||[key isEqualToString:GSWHTTPHeader_RemoteAddress[WONAMES_INDEX]])
                                remoteAddr=value;
                              if ([key isEqualToString:GSWHTTPHeader_AdaptorVersion[GSWNAMES_INDEX]]
                                  || [key isEqualToString:GSWHTTPHeader_ServerName[GSWNAMES_INDEX]])
                                _requestNamingConv=GSWNAMES_INDEX;
                              else if ([key isEqualToString:GSWHTTPHeader_AdaptorVersion[WONAMES_INDEX]]
                                       || [key isEqualToString:GSWHTTPHeader_ServerName[WONAMES_INDEX]])
                                _requestNamingConv=WONAMES_INDEX;
                                  
                              prevValue=[headers objectForKey:key];
                              NSDebugDeepMLLog(@"low",@"prevValue:%@",prevValue);
                              if (prevValue)
                                newValue=[prevValue arrayByAddingObject:value];
                              else
                                newValue=[NSArray arrayWithObject:value];
                              if (!headers)
                                headers=(NSMutableDictionary*)[NSMutableDictionary dictionary];
                              [headers setObject:newValue
                                       forKey:key];
                            };
                        };
                    };
                };
            };
          NSDebugDeepMLog(@"requestMethod=%d",requestMethod);
          dataBytesNb=[pendingData length];
          if (isDataStep)
            {
              if (requestMethod==REQUEST_METHOD__GET)
                isAllDataReaden=YES;
              else if (requestMethod==REQUEST_METHOD__POST)
                isAllDataReaden=(dataBytesNb>=contentLength);
            };
          if (!isAllDataReaden)
            {
              isElapsed=[[NSDate date]compare:maxDate]==NSOrderedDescending;
              if (!isElapsed)
                {
                  NSTimeIntervalSleep(sleepTime);//Is this the good method ? //TODOV
                  isElapsed=[[NSDate date]compare:maxDate]==NSOrderedDescending;
                };
            };
        } while (!isAllDataReaden && !isElapsed);
      ASSIGN(_remoteAddress,remoteAddr);
      NSDebugDeepMLog(@"GSWDefaultAdaptor: userAgent=%@ remoteAddr=%@ isAllDataReaden=%s isElapsed=%s readenBytesNb=%d contentLength=%d dataBytesNb=%d headersBytesNb=%d",
                  userAgent,
                  remoteAddr,
                  isAllDataReaden ? "YES" : "NO",
                  isElapsed ? "YES" : "NO",
                  readenBytesNb,
                  contentLength,
                  dataBytesNb,
                  headersBytesNb);
      ok=isAllDataReaden;
      if (isAllDataReaden)
        {
          *headersPtr=[[headers copy] autorelease];
          if ([pendingData length]>0)
            *dataPtr=[pendingData copy];
          else
            *dataPtr=nil;			
        }
      else
        {
          *requestLinePtr=nil;
          *headersPtr=nil;
          *dataPtr=nil;
        };
    }
  LOGObjectFnStop();
  return ok;
};

//--------------------------------------------------------------------
/** return a created request build with 'requestLine', 'headers' and 'data' **/
-(GSWRequest*)createRequestFromRequestLine:(NSString*)requestLine
                                   headers:(NSDictionary*)headers
                                      data:(NSData*)data
{
  GSWRequest* request=nil;
  NSArray* requestLineArray=nil;
  LOGObjectFnStart();
  NSDebugDeepMLog0(@"GSWDefaultAdaptorThread: createRequestFromData");
  requestLineArray=[requestLine componentsSeparatedByString:@" "];
  NSDebugDeepMLLog(@"low",@"requestLine:%@",requestLine);
  NSDebugDeepMLLog(@"info",@"requestLineArray:%@",requestLineArray);
  if ([requestLineArray count]!=3)
    {
      ExceptionRaise(@"GSWDefaultAdaptorThread",
                     @"bad request first line (elements count %d != 3). requestLine: '%@'.RequestLineArray: %@",
                     [requestLineArray count],
                     requestLine,
                     requestLineArray);
    }
  else
    {
      NSString* method=[requestLineArray objectAtIndex:0];
      NSString* url=[requestLineArray objectAtIndex:1];
      NSArray* http=[[requestLineArray objectAtIndex:2] componentsSeparatedByString:@"/"];
      [GSWApplication statusLogWithFormat:@"RemoteAddress=%@ Request uri=%@",_remoteAddress,url];

      NSDebugDeepMLLog(@"info",@"method=%@",method);
      NSDebugDeepMLLog(@"info",@"url=%@",url);
      NSDebugDeepMLLog(@"info",@"http=%@",http);
      if ([http count]!=2)
        {
          ExceptionRaise0(@"GSWDefaultAdaptorThread",@"bad request first line (HTTP)");
        }
      else
        {
          NSString* httpVersion=[http objectAtIndex:1];
          /*		  if (isHeaderKeysEqual(method,GSWHTTPHeader_MethodPost))
                          {
          */
          request=[_application createRequestWithMethod:method
                                uri:url
                                httpVersion:httpVersion
                                headers:headers
                                content:data
                                userInfo:nil];
          /*			};*/
        };
    };
  LOGObjectFnStop();
  return request;
};

//--------------------------------------------------------------------
/** Send response 'response' to current stream using current naming convention **/
-(void)sendResponse:(GSWResponse*)response
{
  NSMutableArray* headers=nil;
  NSString* anHeader=nil;
  NSTimeInterval ti=0;
  LOGObjectFnStart();
  
#ifndef NDEBUG
  headers=[NSMutableArray array];
  anHeader=[NSString stringWithFormat:@"GSWRunDate: %@\n",
                     [_runDate descriptionWithCalendarFormat:@"%d/%m/%Y %H:%M:%S.%F"
                               timeZone:nil
                               locale:nil]];
  [headers addObject:anHeader];
  anHeader=[NSString stringWithFormat:@"GSWDispatchRequestDate: %@\n",
                     [_dispatchRequestDate descriptionWithCalendarFormat:@"%d/%m/%Y %H:%M:%S.%F"
                                           timeZone:nil
                                           locale:nil]];
  [headers addObject:anHeader];
  anHeader=[NSString stringWithFormat:@"GSWSendResponseDate: %@\n",
                     [_sendResponseDate descriptionWithCalendarFormat:@"%d/%m/%Y %H:%M:%S.%F"
                                        timeZone:nil
                                        locale:nil]];
  [headers addObject:anHeader];
  
  ti=[_dispatchRequestDate timeIntervalSinceDate:_runDate];
  anHeader=[NSString stringWithFormat:@"GSWDispatchRequestDate-GSWRunDate: %.3f seconds (%.1f minutes)\n",
                     ti,(double)(ti/60)];
  
  [headers addObject:anHeader];
  ti=[_sendResponseDate timeIntervalSinceDate:_runDate];
  anHeader=[NSString stringWithFormat:@"GSWSendResponseDate-GSWRunDate: %.3f seconds (%.1f minutes)\n",
                     ti,(double)(ti/60)];
  [headers addObject:anHeader];
  ti=[_sendResponseDate timeIntervalSinceDate:_dispatchRequestDate];
  anHeader=[NSString stringWithFormat:@"GSWSendResponseDate-GSWDispatchRequestDate: %.3f seconds (%.1f minutes)\n",
                     ti,(double)(ti/60)];
  [headers addObject:anHeader];
#endif
  [[self class]sendResponse:response
               toStream:_stream
               withNamingConv:_requestNamingConv
               withAdditionalHeaderLines:headers
               withRemoteAddress:_remoteAddress];
  ASSIGN(_stream,nil);
  LOGObjectFnStop();
};

/** send response 'response' to stream 'aStream' using naming convention 'requestNamingConv' 
Note: the stream is closed at the end of the write 
**/
+(void)sendResponse:(GSWResponse*)response
           toStream:(NSFileHandle*)aStream
     withNamingConv:(int)requestNamingConv
withAdditionalHeaderLines:(NSArray*)addHeaders
  withRemoteAddress:(NSString*)remoteAddress
{
  BOOL ok=YES;
  LOGObjectFnStart();
  NSDebugDeepMLLog(@"low",@"response:%p",response);
  [response willSend];
  if (response)
    {
      int headerN=0;
      int headerNForKey=0;
      NSMutableData* allResponseData=nil;//to store response
      NSMutableData* responseData=(NSMutableData*)[NSMutableData data];
      NSArray* headerKeys=[response headerKeys];
      NSArray* headersForKey=nil;
      NSString* key=nil;
      NSString* anHeader=nil;
      NSString* head=[NSString stringWithFormat:@"HTTP/%@ %d %@ %@\n",
                               [response httpVersion],
                               [response status],
                               GSWHTTPHeader_Response_OK,
                               GSWHTTPHeader_Response_HeaderLineEnd[requestNamingConv]];
      NSString* empty=[NSString stringWithString:@"\n"];

      NSDebugDeepMLLog(@"low",@"head:%@",head);
      NSDebugDeepMLLog(@"low",@"responseData:%@",responseData);
      [responseData appendData:[head dataUsingEncoding:NSASCIIStringEncoding]];
      NSDebugDeepMLLog(@"low",@"responseData:%@",responseData);
      for(headerN=0;headerN<[headerKeys count];headerN++)
        {
          key=[headerKeys objectAtIndex:headerN];
          headersForKey=[response headersForKey:key];
          for(headerNForKey=0;headerNForKey<[headersForKey count];headerNForKey++)
            {
              anHeader=[NSString stringWithFormat:@"%@: %@\n",
                                 key,
                                 [headersForKey  objectAtIndex:headerNForKey]];
              [responseData appendData:[anHeader dataUsingEncoding:NSASCIIStringEncoding]];
              NSDebugDeepMLLog(@"low",@"anHeader:%@",anHeader);
              NSDebugDeepMLLog(@"low",@"responseData:%@",responseData);
            };
        };
      for(headerN=0;headerN<[addHeaders count];headerN++)
        [responseData appendData:[[addHeaders objectAtIndex:headerN]dataUsingEncoding:NSASCIIStringEncoding]];

      //	  NSDebugDeepMLLog(@"low",@"cl:%@",cl);
      NSDebugDeepMLLog(@"low",@"empty:%@",empty);
      //	  [responseData appendData:[cl dataUsingEncoding:NSASCIIStringEncoding]];
      NSDebugDeepMLLog(@"low",@"responseData:%@",responseData);
      [responseData appendData:[empty dataUsingEncoding:NSASCIIStringEncoding]];
      NSDebugDeepMLLog(@"low",@"responseData:%@",responseData);
      
      NS_DURING
        {
          [aStream writeData:responseData];
        }
      NS_HANDLER
        {
          ok=NO;
          LOGException(@"GSWDefaultAdaptorThread: sendResponse Exception:%@ (%@)",
                       localException,[localException reason]);
          NSDebugMLog(@"EXCEPTION GSWDefaultAdaptorThread: sendResponse Exception:%@ (%@)",
                      localException,[localException reason]);
          [GSWApplication statusLogWithFormat:@"\nException while sending response\n"];
        }
      NS_ENDHANDLER;
      if (ok && [[response content] length]>0)
        {
          [responseData setLength:[[response content] length]];
          [responseData setData:[response content]];
          
          NSDebugDeepMLLog(@"low",@"[response content]:%@",[response content]);
          NSDebugDeepMLLog(@"low",@"[[response content] length]=%d",[[response content] length]);
          NSDebugDeepMLLog(@"low",@"Response content String NSASCIIStringEncoding:%@",
                           [[[NSString alloc] initWithData:[response content]
                                              encoding:NSASCIIStringEncoding]
                             autorelease]);
          NSDebugDeepMLLog(@"low",@"Response content String :%@",
                           [[[NSString alloc] initWithData:[response content]
                                              encoding:NSISOLatin1StringEncoding]
                             autorelease]);

          NS_DURING
            {
              [aStream writeData:responseData];
              [GSWApplication statusLogWithFormat:@"\nResponse Sent\n"];
            }
          NS_HANDLER
            {
              ok=NO;
              LOGException(@"GSWDefaultAdaptorThread: sendResponse Exception:%@ (%@)",
                           localException,[localException reason]);
              NSDebugMLog(@"EXCEPTION GSWDefaultAdaptorThread: sendResponse Exception:%@ (%@)",
                          localException,[localException reason]);
              [GSWApplication statusLogWithFormat:@"\nException while sending response\n"];
            }
          NS_ENDHANDLER;
          NSDebugDeepMLLog0(@"info",@"Response content Written");
        };
    };
  [aStream closeFile];
  LOGObjectFnStop();
};

/** Returns thread creation date **/
-(NSDate*)creationDate
{
  return _creationDate;
};

/** Returns YES if the thread has expired (timed out) **/
-(BOOL)isExpired
{
  BOOL isExpired=(fabs([_creationDate timeIntervalSinceNow])>ADAPTOR_THREAD_TIME_OUT);
  NSDebugDeepMLog(@"EXPIRED %@ %f isExpired=%d\n",//connectOK=%d isExpired=%d\n",
                  _creationDate,
                  [_creationDate timeIntervalSinceNow],
                  //(int)(((UnixFileHandle*)stream)->connectOK),
                  isExpired);
  return isExpired;
};

-(NSFileHandle*)stream
{
  return _stream;
};

+(void)sendRetryLasterResponseToStream:(NSFileHandle*)stream
{
  GSWResponse* response=nil;
  NSAutoreleasePool* pool=nil;
  pool=[NSAutoreleasePool new];
  GSWLogMemCF("New NSAutoreleasePool: %p",pool);
  LOGDEEPClassFnStart();
  response=[GSWResponse responseWithMessage:@"Temporary unavailable"
                        inContext:nil
			forRequest:nil
                        forceFinalize:YES];
  [response setStatus:503];//503=Service Unavailable
  NSDebugDeepMLog0(@"sendResponse:\n");
  [self sendResponse:response
        toStream:stream
        withNamingConv:GSWNAMES_INDEX
        withAdditionalHeaderLines:nil
        withRemoteAddress:nil];
  LOGDEEPClassFnStop();
  GSWLogMemCF("Destroy NSAutoreleasePool: %p",pool);
  DESTROY(pool);
};

+(void)sendConnectionRefusedResponseToStream:(NSFileHandle*)stream
                                 withMessage:(NSString*)message
{
  GSWResponse* response=nil;
  NSAutoreleasePool* pool=nil;
  pool=[NSAutoreleasePool new];
  GSWLogMemCF("New NSAutoreleasePool: %p",pool);
  LOGDEEPClassFnStart();
  response=[GSWResponse responseWithMessage:message
                        inContext:nil
			forRequest:nil
                        forceFinalize:YES];
  [response setStatus:503];//503=Service Unavailable
  NSDebugDeepMLog0(@"sendResponse:\n");
  [self sendResponse:response
        toStream:stream
        withNamingConv:GSWNAMES_INDEX
        withAdditionalHeaderLines:nil
        withRemoteAddress:nil];
  LOGDEEPClassFnStop();
  GSWLogMemCF("Destroy NSAutoreleasePool: %p",pool);
  DESTROY(pool);
};

@end
