/** GSWDefaultAdaptor.h - GSWeb: Class GSWDefaultAdaptor

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999

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

#ifndef _GSWDefaultAdaptor_h__
	#define _GSWDefaultAdaptor_h__

GSWEB_EXPORT int iBlock;
//====================================================================
// GSWDefaultAdaptor

@interface GSWDefaultAdaptor: GSWAdaptor
{
  int _port;
  NSString* _host;
  NSString* _adaptorHost;
  int _instance;
  int _queueSize;
  int _workerThreadCount;
  int _workerThreadCountMin;
  int _workerThreadCountMax;
  BOOL _isMultiThreadEnabled;
  NSFileHandle* _fileHandle;
  NSMutableArray* _waitingThreads;
  NSMutableArray* _threads;
  NSLock* _selfLock;
  BOOL _blocked;
}

-(id)initWithName:(NSString*)name
        arguments:(NSDictionary*)arguments;

-(void)registerForEvents;
-(void)unregisterForEvents;

-(void)runOnce;
-(BOOL)doesBusyRunOnce;
-(BOOL)dispatchesRequestsConcurrently;
-(int)port;
-(NSString*)host;
-(void)adaptorThreadExited:(GSWDefaultAdaptorThread*)adaptorThread;
-(BOOL)tryLock;
-(void)unlock;

-(void)setWorkerThreadCount:(id)workerThreadCount;
-(id)workerThreadCount;
-(void)setWorkerThreadCountMin:(id)workerThreadCount;
-(id)workerThreadCountMin;
-(void)setWorkerThreadCountMax:(id)workerThreadCount;
-(id)workerThreadCountMax;
-(void)setListenQueueSize:(id)listenQueueSize;
-(BOOL)isMultiThreadEnabled;
-(BOOL)isConnectionAllowedWithHandle:(NSFileHandle*)handle
                     returnedMessage:(NSString**)retMessage;

@end

//====================================================================
@interface GSWDefaultAdaptor (GSWDefaultAdaptorA)
-(void)stop;
-(void)run;
-(void)_runOnce;
@end
#endif //_GSWDefaultAdaptor_h__
