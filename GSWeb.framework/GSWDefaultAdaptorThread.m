/** GSWDefaultAdaptorThread.m - <title>GSWeb: Class GSWDefaultAdaptorThread</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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
#define ADAPTOR_THREAD_TIME_OUT  (5*60) // in seconds. threads waiting for more than 5 minutes are not processed

static SEL objectAtIndexSEL=NULL;
static SEL appendDataSEL=NULL;
static NSData* lineFeedData=nil;
//====================================================================
@implementation GSWDefaultAdaptorThread

+ (void) initialize
{
  if (self == [GSWDefaultAdaptorThread class])
    {
      objectAtIndexSEL=@selector(objectAtIndex:);
      appendDataSEL=@selector(appendData:);
      ASSIGN(lineFeedData,([[NSString stringWithString:@"\n"]
                             dataUsingEncoding:NSASCIIStringEncoding]));
    };
};
//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
    {
      _creationTS=GSWTime_now();
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
      GSWLogMemC("dealloc pool");
      GSWLogMemCF("Destroy NSAutoreleasePool: %p. %@",
		  _pool, GSCurrentThread());
      DESTROY(_pool);
      GSWLogMemC("end dealloc pool");
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

  _pool=[NSAutoreleasePool new];
  GSWLogMemCF("New NSAutoreleasePool: %p",_pool);
#ifdef GSWDEBUG_DEEP
  [GSWApplication logWithFormat:@"pool allocated!"];
#endif

  _runTS=GSWTime_now();
  _beginDispatchRequestTS=GSWTime_zero();
  _endDispatchRequestTS=GSWTime_zero();
  _sendResponseTS=GSWTime_zero();

#ifdef GSWDEBUG_DEEP
  [GSWApplication statusLogWithFormat:@"Thread run START"];
#endif
  if (_isMultiThread)
    {
      threadDictionary=GSCurrentThreadDictionary();
      [threadDictionary setObject:self
                        forKey:GSWThreadKey_DefaultAdaptorThread];
      [[NSNotificationCenter defaultCenter] addObserver:[self class]
                                            selector:@selector(threadExited:)
                                            name:NSThreadWillExitNotification
                                            object:[NSThread currentThread]];
      /*
        [NotificationDispatcher addObserver:[self class]
        selector:@selector(threadExited:)
        name:NSThreadWillExitNotification
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
          _beginDispatchRequestTS=GSWTime_now();
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
          _endDispatchRequestTS=GSWTime_now();
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
  NSDebugMLog(@"GSWDefaultAdaptorThread: %@ run end",
              GSCurrentThread());
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
  GSWLogDeepC("threadExited");
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
                                        name:NSThreadWillExitNotification
                                        object:thread];
  /*  [NotificationDispatcher removeObserver:self
      name:NSThreadWillExitNotification
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
                      int newLinesCount=[newLines count];
                      for(i=0;i<newLinesCount;i++)
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
	      /* Because +date returns (id) we use the variable
	         to insure the compiler finds the correct signature.  */
	      NSDate *now = [NSDate date];
              isElapsed	=[now compare: maxDate]==NSOrderedDescending;
              if (!isElapsed)
                {
                  NSTimeIntervalSleep(sleepTime);//Is this the good method ? //TODOV
		  now = [NSDate date];
                  isElapsed=[now compare:maxDate]==NSOrderedDescending;
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
  int requestLineLength=0;

  LOGObjectFnStart();

  NSDebugDeepMLog0(@"GSWDefaultAdaptorThread: createRequestFromData");
  NSDebugDeepMLLog(@"low",@"requestLine:%@",requestLine);

  requestLineLength=[requestLine length];
  if (requestLineLength==0)
    {
      ExceptionRaise(@"GSWDefaultAdaptorThread",
                     @"bad request first line: '%@'",
                     requestLine);
    }
  else
    {
      NSRange spaceRange;
      NSRange urlRange;
      NSString* method=nil;
      NSString* url=nil;
      NSString* protocolString=nil;
      NSArray* protocol=nil;

      spaceRange=[requestLine rangeOfString:@" "];
      if (spaceRange.length==0 || spaceRange.location+spaceRange.length>=requestLineLength)
        {
          ExceptionRaise(@"GSWDefaultAdaptorThread",
                         @"bad request first line: No method or no protocol '%@'",
                         requestLine);
        }
      else
        {
          method=[requestLine substringToIndex:spaceRange.location];
          urlRange.location=spaceRange.location+spaceRange.length;//+1 to skip space
          spaceRange=[requestLine rangeOfString:@" "
                                  options:NSBackwardsSearch
                                  range:NSMakeRange(urlRange.location,requestLineLength-urlRange.location)];
          if (spaceRange.length==0 || spaceRange.location<=urlRange.location)
            {
              ExceptionRaise(@"GSWDefaultAdaptorThread",
                             @"bad request first line: No protocol or no url '%@'",
                             requestLine);
            }
          else
            {
              protocolString=[requestLine substringFromIndex:spaceRange.location+spaceRange.length];
              protocol=[protocolString componentsSeparatedByString:@"/"];
              urlRange.length=spaceRange.location-urlRange.location;
              url=[requestLine substringFromRange:urlRange];

              NSDebugDeepMLLog(@"info",@"method=%@",method);
              NSDebugDeepMLLog(@"info",@"url=%@",url);
              NSDebugDeepMLLog(@"info",@"protocolString=%@",protocolString);
              if ([protocol count]!=2)
                {
                  ExceptionRaise0(@"GSWDefaultAdaptorThread",@"bad request first line (HTTP)");
                }
              else
                {
                  NSString* httpVersion=[protocol objectAtIndex:1];
                  [GSWApplication statusLogWithFormat:@"RemoteAddress=%@ Method=%@ Protocol=%@ httpVersion=%@ uri=%@",
                                  _remoteAddress,method,protocolString,httpVersion,url];
              
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
        };
    };

  LOGObjectFnStop();
  return request;
};

//--------------------------------------------------------------------
/** Send response 'response' to current stream using current naming convention **/
-(void)sendResponse:(GSWResponse*)response
{
  NSString* anHeader=nil;

  LOGObjectFnStart();

  _sendResponseTS=GSWTime_now();
  
  // Based on requestTS
  anHeader=[NSString stringWithFormat:@"%@: applicationThreadCreation=+%0.3fs applicationThreadRun=+%0.3fs applicationBeginDispatchRequest=+%0.3fs applicationEndDispatchRequest=+%0.3fs applicationDispatchRequest=%0.3fs applicationBeginSendResponse=+%0.3fs applicationTimeSpent=%0.3fs",
                     GSWHTTPHeader_AdaptorStats[_requestNamingConv],
                     GSWTime_floatSec(_creationTS-_requestTS),
                     GSWTime_floatSec(_runTS-_requestTS),
                     GSWTime_floatSec(_beginDispatchRequestTS-_requestTS),
                     GSWTime_floatSec(_endDispatchRequestTS-_requestTS),
                     GSWTime_floatSec(_endDispatchRequestTS-_beginDispatchRequestTS),
                     GSWTime_floatSec(_sendResponseTS-_requestTS),
                     GSWTime_floatSec(_sendResponseTS-_requestTS)];
  
  [[self class]sendResponse:response
               toStream:_stream
               withNamingConv:_requestNamingConv
               withAdditionalHeaderLines:[NSArray arrayWithObject:anHeader]
               withRemoteAddress:_remoteAddress];
  ASSIGN(_stream,nil);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
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
      IMP objectAtIndexIMP=NULL;
      int addHeadersCount=[addHeaders count];
      int headerN=0;
      int headerNForKey=0;
      NSMutableData* responseData=(NSMutableData*)[NSMutableData data];
      IMP appendDataIMP=[responseData methodForSelector:appendDataSEL];
      NSArray* headerKeys=[response headerKeys];
      int headerKeysCount=[headerKeys count];
      NSArray* headersForKey=nil;
      NSString* key=nil;
      NSString* anHeader=nil;
      NSString* head=[NSString stringWithFormat:@"HTTP/%@ %d %@ %@\n",
                               [response httpVersion],
                               [response status],
                               GSWHTTPHeader_Response_OK,
                               GSWHTTPHeader_Response_HeaderLineEnd[requestNamingConv]];

      NSDebugDeepMLLog(@"low",@"head:%@",head);
      NSDebugDeepMLLog(@"low",@"responseData:%@",responseData);

      (*appendDataIMP)(responseData,appendDataSEL,
                       [head dataUsingEncoding:NSASCIIStringEncoding]);
      NSDebugDeepMLLog(@"low",@"responseData:%@",responseData);

      objectAtIndexIMP=[headerKeys methodForSelector:objectAtIndexSEL];
      for(headerN=0;headerN<headerKeysCount;headerN++)
        {
          int headersForKeyCount=0;
          key=(*objectAtIndexIMP)(headerKeys,objectAtIndexSEL,headerN);
          headersForKey=[response headersForKey:key];
          headersForKeyCount=[headersForKey count];
          for(headerNForKey=0;headerNForKey<headersForKeyCount;headerNForKey++)
            {
              anHeader=[NSString stringWithFormat:@"%@: %@\n",
                                 key,
                                 [headersForKey  objectAtIndex:headerNForKey]];

              (*appendDataIMP)(responseData,appendDataSEL,
                               [anHeader dataUsingEncoding:NSASCIIStringEncoding]);

              NSDebugDeepMLLog(@"low",@"anHeader:%@",anHeader);
              NSDebugDeepMLLog(@"low",@"responseData:%@",responseData);
            };
        };

      objectAtIndexIMP=[addHeaders methodForSelector:objectAtIndexSEL];
      for(headerN=0;headerN<addHeadersCount;headerN++)
        {
          (*appendDataIMP)(responseData,appendDataSEL,
                           [(*objectAtIndexIMP)(addHeaders,objectAtIndexSEL,headerN)
                                               dataUsingEncoding:NSASCIIStringEncoding]);
          (*appendDataIMP)(responseData,appendDataSEL,lineFeedData);
        };

      NSDebugDeepMLLog(@"low",@"empty:%@",empty);
      NSDebugDeepMLLog(@"low",@"responseData:%@",responseData);

      // Headers/Content separator
      (*appendDataIMP)(responseData,appendDataSEL,lineFeedData);
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


      if (ok)
        {
          NSData* responseContent=[response content];
          int responseContentLength=[responseContent length];
          if (responseContentLength>0)
            {
              [responseData setLength:responseContentLength];
              [responseData setData:responseContent];
              
              NSDebugDeepMLLog(@"low",@"responseContent:%@",responseContent);
              NSDebugDeepMLLog(@"low",@"responseContentLength=%d",responseContentLength);
              NSDebugDeepMLLog(@"low",@"Response content String NSASCIIStringEncoding:%@",
                               [[[NSString alloc] initWithData:responseContent
                                                  encoding:NSASCIIStringEncoding]
                                 autorelease]);
              NSDebugDeepMLLog(@"low",@"Response content String :%@",
                               [[[NSString alloc] initWithData:responseContent
                                                  encoding:[response contentEncoding]]
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
    };
  [aStream closeFile];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
/** Returns thread creation TS **/
-(GSWTime)creationTS
{
  return _creationTS;
};

//--------------------------------------------------------------------
/** Returns YES if the thread has expired (timed out) **/
-(BOOL)isExpired
{
  time_t elapsedSeconds=GSWTime_secPart(GSWTime_now()-_creationTS);
  BOOL isExpired=(elapsedSeconds>ADAPTOR_THREAD_TIME_OUT);
  NSDebugDeepMLog(@"EXPIRED %@ %d isExpired=%d",
                  _creationTS,
                  elapsedSeconds,
                  isExpired);
  return isExpired;
};

//--------------------------------------------------------------------
-(void)setRequestTS:(GSWTime)requestTS
{
  _requestTS=requestTS;
};

//--------------------------------------------------------------------
-(NSFileHandle*)stream
{
  return _stream;
};

//--------------------------------------------------------------------
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
  NSDebugDeepMLog0(@"sendResponse:");
  [self sendResponse:response
        toStream:stream
        withNamingConv:GSWNAMES_INDEX
        withAdditionalHeaderLines:nil
        withRemoteAddress:nil];
  LOGDEEPClassFnStop();
  GSWLogMemCF("Destroy NSAutoreleasePool: %p",pool);
  DESTROY(pool);
};

//--------------------------------------------------------------------
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
  NSDebugDeepMLog0(@"sendResponse:");
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

