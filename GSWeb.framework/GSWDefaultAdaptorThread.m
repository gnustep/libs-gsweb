/* GSWDefaultAdaptorThread.m - GSWeb: Class GSWDefaultAdaptorThread
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Feb 1999
   
   This file is part of the GNUstep Web Library.
   
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
*/

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>
#include <unistd.h>
#include "NSNonBlockingFileHandle.h"
//====================================================================
@implementation GSWDefaultAdaptorThread

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
    {
      ASSIGN(creationDate,[NSDate date]);
      requestNamingConv=GSWebNamingConv;//GSWNAMES_INDEX or WONAMES_INDEX
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithApp:(GSWApplication*)application_
	 withAdaptor:(GSWAdaptor*)adaptor_
	  withStream:(NSFileHandle*)stream_
{
  if ((self=[self init]))
	{
	  application=application_;
	  adaptor=adaptor_;
	  ASSIGN(stream,stream_);
	  keepAlive=NO;
	  isMultiThread=[adaptor isMultiThreadEnabled];
	  NSDebugMLLog(@"info",@"isMultiThread=%d",(int)isMultiThread);
	};
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("dealloc GSWDefaultAdaptorThread");
  DESTROY(stream);
  GSWLogC("release dates");
  DESTROY(creationDate);
  DESTROY(runDate);
  DESTROY(dispatchRequestDate);
  DESTROY(sendResponseDate);
  GSWLogC("release pool");
//  DESTROY(pool);
  [super dealloc];
  GSWLogC("dealloc GSWDefaultAdaptorThread end");
};

//--------------------------------------------------------------------
-(GSWAdaptor*)adaptor
{
  return adaptor;
};

//--------------------------------------------------------------------
-(NSAutoreleasePool*)pool
{
  return pool;
};

//--------------------------------------------------------------------
-(void)setPool:(NSAutoreleasePool*)pool_
   destroyLast:(BOOL)destroy_
{
  if (destroy_)
	{
	  DESTROY(pool);
	};
  pool=pool_;
};

//--------------------------------------------------------------------
-(void)run:(id)void_
{
  BOOL _requestOk=NO;
  NSMutableDictionary* _threadDictionary=nil;
  NSString* _requestLine=nil;
  NSDictionary* _headers=nil;
  NSData* _data=nil;
  ASSIGN(runDate,[NSDate date]);
  DESTROY(dispatchRequestDate);
  DESTROY(sendResponseDate);
#ifdef DEBUG
  [GSWApplication statusLogWithFormat:@"Thread run START"];
#endif
  pool=[NSAutoreleasePool new];
#ifdef DEBUG
  [GSWApplication logWithFormat:@"pool allocated!"];
#endif
  if (isMultiThread)
	{
	  _threadDictionary=GSCurrentThreadDictionary();
	  [_threadDictionary setObject:self
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
  NSDebugMLLog(@"low",@"application:%@",application);

  NS_DURING
	{
	  _requestOk=[self readRequestReturnedRequestLine:&_requestLine
					   returnedHeaders:&_headers
					   returnedData:&_data];
	}
  NS_HANDLER
	{
	  LOGException(@"GSWDefaultAdaptorThread: readRequestFromStream Exception:%@ (%@)",localException,[localException reason]);
	}
  NS_ENDHANDLER;
  if (!_requestOk)
	{
	  //TODO
	}
  else
	{
	  GSWRequest* request=nil;
	  GSWResponse* response=nil;
	  NSDebugMLLog(@"info",@"GSWDefaultAdaptorThread: runWithStream requestLine=%@ _headers=%@ _data=%@",
				   _requestLine,
				   _headers,
				   _data);
	  NS_DURING
		{
		  request=[self createRequestFromRequestLine:_requestLine
						headers:_headers
						data:_data];
		}
	  NS_HANDLER
		{
		  LOGException(@"GSWDefaultAdaptorThread: createRequestFromData Exception:%@ (%@)",localException,[localException reason]);
		}
	  NS_ENDHANDLER;
	  if (request)
		{
		  //call  application resourceRequestHandlerKey (retourne wr)
		  //call requets requestHandlerKey (retorune nil)
		  NSDebugMLLog(@"info",@"GSWDefaultAdaptorThread: run handleRequest:%@",request);
		  ASSIGN(dispatchRequestDate,[NSDate date]);
		  NS_DURING
			{
			  response=[application dispatchRequest:request];
			}
		  NS_HANDLER
			{
			  BOOL _isApplicationRequestHandlingLocked=[application isRequestHandlingLocked];
			  LOGException(@"GSWDefaultAdaptorThread: dispatchRequest Exception:%@ (%@)%s",
						   localException,
						   [localException reason],
						   _isApplicationRequestHandlingLocked ? " Request Handling Locked !" : "");
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
			  ASSIGN(sendResponseDate,[NSDate date]);
			  NS_DURING
				{
				  [self sendResponse:response];
				}
			  NS_HANDLER
				{
				  LOGException(@"GSWDefaultAdaptorThread: sendResponse Exception:%@ (%@)",localException,[localException reason]);
				}
			  NS_ENDHANDLER;
			  NSDebugMLLog(@"low",@"application:%@",application);
			  AUTORELEASE(response);
			};
		};
	};
  NSDebugMLog0(@"GSWDefaultAdaptorThread: run end");
  NSDebugMLLog(@"low",@"application:%@",application);
  LOGObjectFnStop();
#ifdef DEBUG
  [GSWApplication statusLogWithFormat:@"threadWillExit START"];
#endif
  [application threadWillExit];
#ifdef DEBUG
  [GSWApplication statusLogWithFormat:@"threadWillExit STOP"];
#endif
  if (isMultiThread)
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
  NSDebugMLLog(@"low",@"[_defaultAdaptorThread retainCount=%d",
			   (int)[self retainCount]);
  [adaptor adaptorThreadExited:self];
  [self setPool:nil
		destroyLast:YES];
//  LOGObjectFnStop();
  GSWLogC("threadExited");
};

//--------------------------------------------------------------------
+(id)threadExited:(NSNotification*)notif_
{
  NSThread* _thread=nil;
  NSMutableDictionary* _threadDict=nil;
  GSWDefaultAdaptorThread* _adaptorThread=nil;
  GSWLogC("Start threadExited:");
  NSAssert([NSThread isMultiThreaded],@"No MultiThread !");
  NSDebugMLLog(@"low",@"notif_=%@",notif_);
  _thread=[notif_ object];
  NSDebugMLLog(@"low",@"_thread=%@",_thread);
  _threadDict = [_thread threadDictionary];
  NSDebugMLLog(@"low",@"_threadDict=%@",_threadDict);
  _adaptorThread=[_threadDict objectForKey:GSWThreadKey_DefaultAdaptorThread];
  NSDebugMLLog(@"low",@"_adaptorThread=%@",_adaptorThread);
  [_threadDict removeObjectForKey:GSWThreadKey_DefaultAdaptorThread];
  [[NSNotificationCenter defaultCenter] removeObserver:self
										name:NSThreadExiting//NSThreadWillExitNotification
										object:_thread];
/*  [NotificationDispatcher removeObserver:self
						  name:NSThreadExiting//NSThreadWillExitNotification
						  object:_thread];
*/
  [_adaptorThread threadExited];
  GSWLogC("Stop threadExited:");
  GSWLogC("threadExited really exit");
  return nil; //??
};

//--------------------------------------------------------------------
+(NSMutableArray*)completeLinesWithData:(NSMutableData*)data_
				  returnedConsumedCount:(int*)consumedCount_
				 returnedHeadersEndFlag:(BOOL*)headersEndFlag_
{
  NSMutableArray* _lines=nil;
  int _length=0;
  LOGClassFnStart();
  _length=[data_ length];
  if (_length>0)
	{
	  NSRange _range=NSMakeRange(0,0);
	  int i=0;
	  char* _dataBytes=(char*)[data_ mutableBytes];
	  BOOL _endHeaders=NO;
	  while(!_endHeaders && i<_length)
		{
		  if (_dataBytes[i]=='\n')
			{
			  if (_range.length>0)
				{
				  NSString* tmpString=[[[NSString alloc]initWithData:[data_ subdataWithRange:_range]
														encoding:NSASCIIStringEncoding]autorelease];
				  if (!_lines)
					_lines=[NSMutableArray array];
				  [_lines addObject:tmpString];
				}
			  else // End Header
				{
				  _endHeaders=YES;
				};
			  _range.location=i+1;
			  _range.length=0;
			}
		  else
			  _range.length++;
		  i++;
		};
	  _range.length=_length-_range.location;
	  if (_range.length>0)
		memcpy(_dataBytes,_dataBytes+_range.location,_range.length);
	  [data_ setLength:_range.length];
	  if (consumedCount_)
		*consumedCount_=_length-_range.length;
	  if (headersEndFlag_)
		*headersEndFlag_=_endHeaders;
	};
  LOGClassFnStop();
  return _lines;
};

//--------------------------------------------------------------------
-(BOOL)readRequestReturnedRequestLine:(NSString**)requestLine_
					  returnedHeaders:(NSDictionary**)headers_
						 returnedData:(NSData**)data_
{
  BOOL ok=NO;
  LOGObjectFnStart();
  if (!stream)
	{
	  ExceptionRaise0(@"GSWDefaultAdaptorThread",@"no stream");
	}
  else
	{
#define REQUEST_METHOD__UNKNOWN	0
#define REQUEST_METHOD__GET	1
#define REQUEST_METHOD__POST	2
	  NSMutableData* _pendingData=nil;
	  NSDate* maxDate=[NSDate dateWithTimeIntervalSinceNow:360]; //360s
	  NSData* dataBlock=nil;
	  int sleepTime=250; //250ms
	  int readenBytesNb=0;
	  int headersBytesNb=0;
	  int dataBytesNb=0;
	  int dataBlockLength=0;
	  int contentLength=-1;
	  int _requestMethod=REQUEST_METHOD__UNKNOWN;
	  BOOL _isRequestLineSetted=NO;
	  BOOL _isDataStep=NO;
	  BOOL _isAllDataReaden=NO;
	  BOOL _isElapsed=NO;
	  NSMutableDictionary* _headers=nil;
	  NSString* _userAgent=nil;
	  NSString* _remoteAddr=nil;
	  NSDebugMLog0(@"dataBlock try reading");
	  do
		{
		  dataBlock=[stream availableDataNonBlocking];
		  dataBlockLength=[dataBlock length];
                  NSDebugMLog(@"dataBlockLength=%i",dataBlockLength);
		  if (dataBlockLength>0)
			{
			  readenBytesNb+=dataBlockLength;
			  if (!_pendingData)
				_pendingData=(NSMutableData*)[NSMutableData data];
			  [_pendingData appendData:dataBlock];
			  if (_isDataStep)
				dataBytesNb=[_pendingData length];
			  else
				{
				  int _newBytesCount=0;
				  NSMutableArray* _newLines=[GSWDefaultAdaptorThread completeLinesWithData:_pendingData
																	 returnedConsumedCount:&_newBytesCount
																	 returnedHeadersEndFlag:&_isDataStep];
				  NSDebugMLLog(@"low",@"newLines=%@ isDataStep=%s newBytesCount=%d",
							   _newLines,
							   _isDataStep ? "YES" : "NO",
							   _newBytesCount);
				  headersBytesNb+=_newBytesCount;
				  if (_newLines)
					{
					  int i=0;
					  for(i=0;i<[_newLines count];i++)
						{
						  NSString* _line=[_newLines objectAtIndex:i];
						  NSDebugMLLog(@"low",@"Line:%@",_line);
						  NSAssert([_line length]>0,@"No line length");
						  if (!_isRequestLineSetted)
							{
							  *requestLine_=_line;
							  _isRequestLineSetted=YES;
							}
						  else
							{
							  NSString* _key=nil;
							  NSString* _value=nil;
							  NSArray* _newValue=nil;
							  NSArray* _prevValue=nil;
							  NSRange _keyRange=[_line rangeOfString:@":"];
							  if (_keyRange.length<=0)
								{
								  _key=_line;
								  NSDebugMLLog(@"low",@"key:%@",_key);
								  _value=[NSString string];
								}
							  else
								{
								  _key=[_line substringToIndex:_keyRange.location];
								  NSDebugMLLog(@"low",@"key:%@",_key);
								  _key=[[_key stringByTrimmingSpaces] lowercaseString];
								  if (_keyRange.location+1<[_line length])
									{
									  _value=[_line substringFromIndex:_keyRange.location+1];
									  _value=[_value stringByTrimmingSpaces];
									}
								  else
									_value=[NSString string];
								  NSDebugMLLog(@"low",@"_value:%@",_value);
								};
                                                          NSDebugMLLog(@"low",@"key:%@ value:%@",_key,_value);
							  if ([_key isEqualToString:GSWHTTPHeader_ContentLength])
								contentLength=[_value intValue];
							  else if ([_key isEqualToString:GSWHTTPHeader_Method[GSWNAMES_INDEX]]
                                                                   || [_key isEqualToString:GSWHTTPHeader_Method[WONAMES_INDEX]])
							    {
							      if ([_value isEqualToString:GSWHTTPHeader_MethodPost])
								_requestMethod=REQUEST_METHOD__POST;
							      else if ([_value isEqualToString:GSWHTTPHeader_MethodGet])
								_requestMethod=REQUEST_METHOD__GET;
							      else
								{
								  NSAssert1(NO,@"Unknown method %@",_value);
								};
							    }
							  else if ([_key isEqualToString:GSWHTTPHeader_UserAgent])
							    _userAgent=_value;
							  else if ([_key isEqualToString:GSWHTTPHeader_RemoteAddress[GSWNAMES_INDEX]]
                                                                   ||[_key isEqualToString:GSWHTTPHeader_RemoteAddress[WONAMES_INDEX]])
							    _remoteAddr=_value;
                                                          if ([_key isEqualToString:GSWHTTPHeader_AdaptorVersion[GSWNAMES_INDEX]]
                                                              || [_key isEqualToString:GSWHTTPHeader_ServerName[GSWNAMES_INDEX]])
                                                              requestNamingConv=GSWNAMES_INDEX;
                                                          else if ([_key isEqualToString:GSWHTTPHeader_AdaptorVersion[WONAMES_INDEX]]
                                                                   || [_key isEqualToString:GSWHTTPHeader_ServerName[WONAMES_INDEX]])
                                                            requestNamingConv=WONAMES_INDEX;

							  _prevValue=[_headers objectForKey:_key];
							  NSDebugMLLog(@"low",@"_prevValue:%@",_prevValue);
							  if (_prevValue)
								_newValue=[_prevValue arrayByAddingObject:_value];
							  else
								_newValue=[NSArray arrayWithObject:_value];
							  if (!_headers)
								_headers=[NSMutableDictionary dictionary];
							  [_headers setObject:_newValue
										forKey:_key];
							};
						};
					};
				};
			};
                  NSDebugMLog(@"_requestMethod=%d",_requestMethod);
		  dataBytesNb=[_pendingData length];
		  if (_isDataStep)
		    {
		      if (_requestMethod==REQUEST_METHOD__GET)
				_isAllDataReaden=YES;
		      else if (_requestMethod==REQUEST_METHOD__POST)
				_isAllDataReaden=(dataBytesNb>=contentLength);
		    };
		  if (!_isAllDataReaden)
			{
			  _isElapsed=[[NSDate date]compare:maxDate]==NSOrderedDescending;
			  if (!_isElapsed)
				{
				  usleep(sleepTime);//Is this the good method ? //TODOV
				  _isElapsed=[[NSDate date]compare:maxDate]==NSOrderedDescending;
				};
			};
		} while (!_isAllDataReaden && !_isElapsed);
	  NSDebugMLog(@"GSWDefaultAdaptor: _userAgent=%@ _remoteAddr=%@ _isAllDataReaden=%s _isElapsed=%s readenBytesNb=%d contentLength=%d dataBytesNb=%d headersBytesNb=%d",
				  _userAgent,
				  _remoteAddr,
				  _isAllDataReaden ? "YES" : "NO",
				  _isElapsed ? "YES" : "NO",
				  readenBytesNb,
				  contentLength,
				  dataBytesNb,
				  headersBytesNb);
	  ok=_isAllDataReaden;
	  if (_isAllDataReaden)
		{
		  *headers_=[[_headers copy] autorelease];
		  if ([_pendingData length]>0)
			*data_=[_pendingData copy];
		  else
			*data_=nil;			
		}
	  else
		{
		  *requestLine_=nil;
		  *headers_=nil;
		  *data_=nil;
		};
	}
  LOGObjectFnStop();
  return ok;
};

//--------------------------------------------------------------------
-(GSWRequest*)createRequestFromRequestLine:(NSString*)requestLine_
								   headers:(NSDictionary*)headers_
									  data:(NSData*)data_
{
  GSWRequest* _request=nil;
  NSArray* _requestLineArray=nil;
  LOGObjectFnStart();
  NSDebugMLog0(@"GSWDefaultAdaptorThread: createRequestFromData");
  _requestLineArray=[requestLine_ componentsSeparatedByString:@" "];
  NSDebugMLLog(@"low",@"requestLine:%@",requestLine_);
  NSDebugMLLog(@"info",@"_requestLineArray:%@",_requestLineArray);
  if ([_requestLineArray count]!=3)
	{
	  ExceptionRaise0(@"GSWDefaultAdaptorThread",@"bad request first line (elements count != 3)");
	}
  else
	{
	  NSString* method=[_requestLineArray objectAtIndex:0];
	  NSString* url=[_requestLineArray objectAtIndex:1];
	  NSArray* http=[[_requestLineArray objectAtIndex:2] componentsSeparatedByString:@"/"];
	  NSDebugMLLog(@"info",@"method=%@",method);
	  NSDebugMLLog(@"info",@"url=%@",url);
	  NSDebugMLLog(@"info",@"http=%@",http);
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
		  _request=[[[GSWRequest alloc] initWithMethod:method
										uri:url
										httpVersion:httpVersion
										headers:headers_
										content:data_
										userInfo:nil]
					 autorelease];
/*			};*/
		};
	};
  LOGObjectFnStop();
  return _request;
};

//--------------------------------------------------------------------
-(void)sendResponse:(GSWResponse*)response
{
  LOGObjectFnStart();
  [response willSend];
  if (response)
	{
	  int headerN=0;
	  int headerNForKey=0;
	  NSMutableData* responseData=[[NSMutableData new]autorelease];
	  NSArray* headerKeys=[response headerKeys];
	  NSArray* headersForKey=nil;
	  NSString* key=nil;
	  NSString* anHeader=nil;
	  NSString* head=[NSString stringWithFormat:@"HTTP/%@ %d %@%@\n",
							   [response httpVersion],
							   [response status],
							   GSWHTTPHeader_Response_OK,
							   GSWHTTPHeader_Response_HeaderLineEnd[requestNamingConv]];
/*	  NSString* cl=[NSString stringWithFormat:@"%@: %d\n",
							 GSWHTTPHeader_ContentLength,
							 [[response content] length]];
*/
	  NSString* empty=[NSString stringWithString:@"\n"];
	  NSDebugMLLog(@"low",@"head:%@",head);
	  [responseData appendData:[head dataUsingEncoding:NSASCIIStringEncoding]];
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
			  NSDebugMLLog(@"low",@"anHeader:%@",anHeader);
			};
		};
//	  NSDebugMLLog(@"low",@"cl:%@",cl);
	  NSDebugMLLog(@"low",@"empty:%@",empty);
//	  [responseData appendData:[cl dataUsingEncoding:NSASCIIStringEncoding]];
	  [responseData appendData:[empty dataUsingEncoding:NSASCIIStringEncoding]];
                 
	  [stream writeData:responseData];
	  if ([[response content] length]>0)
		{
		  [responseData setLength:[[response content] length]];
		  [responseData setData:[response content]];
                         
		  NSDebugMLLog(@"low",@"[response content]:%@",[response content]);
		  NSDebugMLLog(@"low",@"[[response content] length]=%d",[[response content] length]);
		  NSDebugMLLog(@"[[response content] length]=%d",[[response content] length]);
		  NSDebugMLLog(@"low",@"Response content String NSASCIIStringEncoding:%@",[[[NSString alloc] initWithData:[response content]
																						encoding:NSASCIIStringEncoding]
																	   autorelease]);
		  NSDebugMLLog(@"low",@"Response content String :%@",[[[NSString alloc] initWithData:[response content]
																 encoding:NSISOLatin1StringEncoding]
												  autorelease]);
		  [stream writeData:responseData];
		  NSDebugMLog0(@"Response content Written");
		};
	  [stream closeFile];
	};
  LOGObjectFnStop();
};

@end
