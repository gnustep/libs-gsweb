/** GSWDefaultAdaptorThread.h - GSWeb: Class GSWDefaultAdaptorThread
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
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
**/

// $Id$

#ifndef _GSWDefaultAdaptorThread_h__
	#define _GSWDefaultAdaptorThread_h__


//==============================================================================
@interface GSWDefaultAdaptorThread: NSObject
{
  GSWApplication* _application;
  GSWAdaptor* _adaptor;
  NSFileHandle* _stream;
  NSAutoreleasePool* _pool;
  BOOL _keepAlive;
  NSRunLoop* _currentRunLoop;
  NSDate* _runLoopDate;
  BOOL _isMultiThread;
  NSDate* _creationDate;
  NSDate* _runDate;
  NSDate* _dispatchRequestDate;
  NSDate* _sendResponseDate;
  int _requestNamingConv;//GSWNAMES_INDEX or WONAMES_INDEX
}

-(id)initWithApp:(GSWApplication*)application
     withAdaptor:(GSWAdaptor*)adaptor
      withStream:(NSFileHandle*)stream;

-(void)run:(id)nothing;

-(GSWAdaptor*)adaptor;
-(NSAutoreleasePool*)pool;
-(void)setPool:(NSAutoreleasePool*)pool
   destroyLast:(BOOL)destroy;

+(NSMutableArray*)completeLinesWithData:(NSMutableData*)data
                  returnedConsumedCount:(int*)consumedCount
                 returnedHeadersEndFlag:(BOOL*)headersEndFlag;

-(BOOL)readRequestReturnedRequestLine:(NSString**)requestLine
                      returnedHeaders:(NSDictionary**)headers
                         returnedData:(NSData**)data;
-(GSWRequest*)createRequestFromRequestLine:(NSString*)requestLine
                                   headers:(NSDictionary*)headers
                                      data:(NSData*)data;
-(void)sendResponse:(GSWResponse*)response;
-(void)threadExited;
+(id)threadExited:(NSNotification*)notif;
-(NSDate*)creationDate;
-(BOOL)isExpired;

+(void)sendResponse:(GSWResponse*)response
           toStream:(NSFileHandle*)aStream
     withNamingConv:(int)requestNamingConv;

+(void)sendRetryLasterResponseToStream:(NSFileHandle*)stream;
+(void)sendConnectionRefusedResponseToStream:(NSFileHandle*)stream
                                 withMessage:(NSString*)message;
@end

#endif
