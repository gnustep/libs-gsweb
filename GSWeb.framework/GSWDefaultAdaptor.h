/* GSWDefaultAdaptor.h - GSWeb: Class GSWDefaultAdaptor
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
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

#ifndef _GSWDefaultAdaptor_h__
	#define _GSWDefaultAdaptor_h__

extern int iBlock;
//====================================================================
// GSWDefaultAdaptor

@interface GSWDefaultAdaptor: GSWAdaptor
{
  int port;
  NSString* host;
  int instance;
  int queueSize;
  int workerThreadCount;
  BOOL isMultiThreadEnabled;
  NSFileHandle* fileHandle;
  NSMutableArray* waitingThreads;
  NSMutableArray* threads;
  NSLock* selfLock;
  BOOL blocked;
};

-(void)dealloc;
-(id)initWithName:(NSString*)name_
		arguments:(NSDictionary*)arguments;

-(void)registerForEvents;
-(void)unregisterForEvents;

-(void)logWithFormat:(NSString*)_format,...;
+(void)logWithFormat:(NSString*)_format,...;

-(void)runOnce;
-(BOOL)doesBusyRunOnce;
-(BOOL)dispatchesRequestsConcurrently;
-(int)port;
-(NSString*)host;
-(void)adaptorThreadExited:(GSWDefaultAdaptorThread*)adaptorThread_;
-(BOOL)tryLock;
-(void)unlock;

-(void)setWorkerThreadCount:(id)workerThreadCount_;
-(id)workerThreadCount;
-(void)setListenQueueSize:(id)listenQueueSize_;
-(BOOL)isMultiThreadEnabled;

@end

//====================================================================
@interface GSWDefaultAdaptor (GSWDefaultAdaptorA)
-(void)stop;
-(void)run;
-(void)_runOnce;
@end
#endif //_GSWDefaultAdaptor_h__
