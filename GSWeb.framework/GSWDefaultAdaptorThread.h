/* GSWDefaultAdaptorThread.h - GSWeb: Class GSWDefaultAdaptorThread
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

// $Id$

#ifndef _GSWDefaultAdaptorThread_h__
	#define _GSWDefaultAdaptorThread_h__


//==============================================================================
@interface GSWDefaultAdaptorThread: NSObject
{
  GSWApplication* application;
  GSWAdaptor* adaptor;
  NSFileHandle* stream;
  NSAutoreleasePool* pool;
  BOOL keepAlive;
  NSRunLoop* currentRunLoop;
  NSDate* runLoopDate;
  BOOL isMultiThread;
  NSDate* creationDate;
  NSDate* runDate;
  NSDate* dispatchRequestDate;
  NSDate* sendResponseDate;
  int requestNamingConv;//GSWNAMES_INDEX or WONAMES_INDEX
}

-(id)initWithApp:(GSWApplication*)_application
	 withAdaptor:(GSWAdaptor*)_adaptor
	  withStream:(NSFileHandle*)stream_;

-(void)run:(id)void_;

-(GSWAdaptor*)adaptor;
-(NSAutoreleasePool*)pool;
-(void)setPool:(NSAutoreleasePool*)pool_
   destroyLast:(BOOL)destroy_;

+(NSMutableArray*)completeLinesWithData:(NSMutableData*)data_
				  returnedConsumedCount:(int*)consumedCount_
				 returnedHeadersEndFlag:(BOOL*)headersEndFlag_;
-(BOOL)readRequestReturnedRequestLine:(NSString**)requestLine_
					  returnedHeaders:(NSDictionary**)headers_
						 returnedData:(NSData**)data_;
-(GSWRequest*)createRequestFromRequestLine:(NSString*)requestLine_
								   headers:(NSDictionary*)headers_
									  data:(NSData*)data_;
-(void)sendResponse:(GSWResponse*)response;
-(void)threadExited;
+(id)threadExited:(NSNotification*)notif_;
-(NSDate*)creationDate;
-(BOOL)isExpired;
@end

#endif
