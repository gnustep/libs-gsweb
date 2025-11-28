/** GSWDefaultAdaptor.m - <title>GSWeb: Class GSWDefaultAdaptor</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999

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
#include "GSWDefaultAdaptor.h"

#include <Foundation/NSFileHandle.h>
#include <Foundation/NSLock.h>

#include "GSWeb.h"

#include "GSWWorkerThread.h"
#include <GNUstepBase/NSObject+GNUstepBase.h>

#ifndef GNUSTEP
#include <GNUstepBase/NSFileHandle+GNUstepBase.h>
#endif


//#if HAVE_LIBWRAP
//#include <tcpd.h>
//#include <syslog.h>
//#endif


//#if HAVE_LIBWRAP
//int deny_severity = LOG_WARNING;
//int allow_severity = LOG_INFO;
///*static*/ void twist_option(char   *value,struct request_info *request)
//{
//};
//#endif
       

static GSWResponse * static_lastDitchErrorResponse = nil;

//====================================================================
@implementation GSWDefaultAdaptor

+ (void) initialize
{
  if (self == [GSWDefaultAdaptor class]) {
    if (static_lastDitchErrorResponse == nil) {  
      static_lastDitchErrorResponse = [GSWResponse new];
      [static_lastDitchErrorResponse setStatus:500];
      [static_lastDitchErrorResponse appendContentString:@"An Internal Server Error Has Occurred."];    
    }
  }
}

+(GSWResponse*) _lastDitchErrorResponse 
{
  return static_lastDitchErrorResponse;
}

-(id)initWithName:(NSString*)name
        arguments:(NSDictionary*)arguments
{
  if ((self=[super initWithName:name
                   arguments:arguments]))
    {
      _fileHandle=nil;
      _threads=[NSMutableArray new];
      _waitingThreads=[NSMutableArray new];
      _selfLock=[NSLock new];
      _port=[[arguments objectForKey:GSWOPT_Port[GSWebNamingConv]] intValue];
      ASSIGN(_host,[arguments objectForKey:GSWOPT_Host[GSWebNamingConv]]);
      //  [self setInstance:_instance];
      _queueSize=[[arguments objectForKey:GSWOPT_ListenQueueSize[GSWebNamingConv]] intValue];
      _workerThreadCount=[[arguments objectForKey:GSWOPT_WorkerThreadCount[GSWebNamingConv]] intValue];
      _workerThreadCountMin=[[arguments objectForKey:GSWOPT_WorkerThreadCountMin[GSWebNamingConv]] intValue];
      _workerThreadCountMax=[[arguments objectForKey:GSWOPT_WorkerThreadCountMax[GSWebNamingConv]] intValue];
      _isMultiThreadEnabled=[[arguments objectForKey:GSWOPT_MultiThreadEnabled] boolValue];
      ASSIGN(_adaptorHost,[arguments objectForKey:GSWOPT_AdaptorHost[GSWebNamingConv]]);
      
      if ((_workerThreadCountMax <1) || (_isMultiThreadEnabled == NO)) {
        _workerThreadCountMax = 0;
        _isMultiThreadEnabled = NO;
      }
      
      if (_isMultiThreadEnabled) {
	int	i;

        for (i=0; i < _workerThreadCountMax; i++) {
          GSWWorkerThread * thread = [GSWWorkerThread alloc];
          thread = [thread initWithApp:GSWApp
                               adaptor:self
                                stream:nil];
          [_threads addObject: thread];
          [thread release];
        }
      }

    }
  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  //TODO? DESTROY(listenPortObject);
  DESTROY(_host);
  DESTROY(_adaptorHost);
  DESTROY(_fileHandle);
  DESTROY(_threads);
  DESTROY(_waitingThreads);
  DESTROY(_selfLock);

  [super dealloc];
}

//--------------------------------------------------------------------
-(void)registerForEvents
{
  SYNCHRONIZED(_selfLock) {
    NSAssert(!_fileHandle,@"fileHandle already exists");
    if (!_host) {
        ASSIGN(_host, @"localhost");
    }
    _fileHandle=[[NSFileHandle fileHandleAsServerAtAddress:_host
                               service:GSWIntToNSString(_port)
  			                      protocol:@"tcp"] retain];
  
    NSAssert(_fileHandle,@"No fileHandle to wait for connections");
  
    [[NSNotificationCenter defaultCenter] addObserver:self
                                    				 selector:@selector(announceNewConnection:)
                                      				   name:NSFileHandleConnectionAcceptedNotification
                                    					 object:_fileHandle];
  
    [_fileHandle acceptConnectionInBackgroundAndNotify];
    
  #ifndef __APPLE__
    NSAssert([_fileHandle readInProgress],@"No [_fileHandle readInProgress]");
//    NSDebugDeepMLog(@"%@ - B readInProgress=%d", GSCurrentThread(),(int)[_fileHandle readInProgress]);
  #endif
  
  NSLog(@"Thread XX Waiting for connections on %@:%d.",
//  [GSCurrentThread() description],
  _host,
  _port);
#if 0
    [GSWApplication statusLogWithFormat:
  		    @"Thread %@: Waiting for connections on %@:%d.",
                    [GSCurrentThread() description],
                    _host,
                    _port];
#endif
  }
  END_SYNCHRONIZED;
}

//PRIVATE use only if locked!
void _workOnHandle(NSFileHandle* handle, id adaptor, NSMutableArray* threadArray, BOOL isMultiThreadEnabled) 
{
  GSWWorkerThread * thread = [GSWWorkerThread alloc];

  thread = [thread initWithApp:GSWApp 
                       adaptor:adaptor
                        stream:handle];
  if (isMultiThreadEnabled) { 
    [threadArray addObject: thread];
  }
  [thread release];
  
}

//PRIVATE use only if locked!
void _queueWorkOnHandle(NSFileHandle* handle, NSMutableArray* waitingThreadArray) {
  [waitingThreadArray insertObject: handle 
                           atIndex: [waitingThreadArray count]];
}


- (void) workerThreadFinished:(GSWWorkerThread*) thread
{
  [_selfLock lock];
  if ([_waitingThreads count]) {
    [thread setServerSocket:[_waitingThreads objectAtIndex:0]];
    [_waitingThreads removeObjectAtIndex:0];
  }
  [_selfLock unlock];

}

//PRIVATE!
// we are locked when we do this.
-(void) _lockedShutdownThreads
{
  NS_DURING {
// loop throuh all threads and quit all not working ones until all shutdown
  } 
  NS_HANDLER {
  }
  NS_ENDHANDLER; 
}

//--------------------------------------------------------------------
-(void)unregisterForEvents
{
  SYNCHRONIZED(_selfLock) {
    NSAssert(_fileHandle,@"not registered");

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                          name:NSFileHandleConnectionAcceptedNotification
                                          object:_fileHandle];
    _shouldGrow = NO;
    
    [self _lockedShutdownThreads];
  
    DESTROY(_fileHandle);

  }
  END_SYNCHRONIZED;
}


//--------------------------------------------------------------------

//--------------------------------------------------------------------
-(BOOL)doesBusyRunOnce
{
  //call _runOnce
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)dispatchesRequestsConcurrently
{
  return YES;
};

//--------------------------------------------------------------------
-(int)port
{
  return _port;
};

//--------------------------------------------------------------------
-(NSString*)host
{
  return _host;
};


//--------------------------------------------------------------------
-(id)workerThreadCount
{
  return GSWIntNumber(_workerThreadCount);
}

// Use locked only
- (GSWWorkerThread*) _nextFreeThread
{
  for (GSWWorkerThread *thread in _threads) {
    if ([thread isWorking] == NO) {
      return thread;
    }
  }
  return nil;
}

-(void)announceNewConnection:(NSNotification*)notification
{
  NSFileHandle     *listenHandle=nil;
  NSFileHandle     *inStream = nil;
  NSString* connRefusedMessage=nil;
  
  listenHandle=[notification object];
  
  inStream = [[notification userInfo] objectForKey:@"NSFileHandleNotificationFileHandleItem"];
  // we want future Notifications.
  [listenHandle acceptConnectionInBackgroundAndNotify];
  
  if (![self isConnectionAllowedWithHandle:inStream
                           returnedMessage:&connRefusedMessage]) {
    // don't waste any time
    [inStream closeFile];
    return;
  }
  
  [_selfLock lock];
  
  GSWWorkerThread * thread = nil;
  
  if (_isMultiThreadEnabled) {
    thread = [self _nextFreeThread];
    
    if (thread) {
      [thread setServerSocket:inStream];
    } else {
      _queueWorkOnHandle(inStream, _waitingThreads);
    }

  } else {
    _workOnHandle(inStream,self, _threads, _isMultiThreadEnabled);
  }
  [_selfLock unlock];
  
}

-(NSFileHandle*)fileHandle
{
  return _fileHandle;
}

-(id)announceBrokenConnection:(id)notification
{
  [self notImplemented: _cmd];	//TODOFN
  NSDebugMLLog(@"trace",@"announceBrokenConnection");
//  [self shutDownConnectionWithSocket:[in_port _port_socket]];
  return self;
}


-(BOOL)isConnectionAllowedWithHandle:(NSFileHandle*)handle
                     returnedMessage:(NSString**)retMessage
{
  BOOL allowed=YES;
  if ([_adaptorHost length]>0)
    {
      NSString* connAddress=[handle socketAddress];

      if ([connAddress isEqualToString:_adaptorHost] == NO) {
          [GSWApplication statusLogErrorWithFormat:@"REFUSED connection from: %@ (Allowed: %@)",
                          connAddress,_adaptorHost];
          allowed=NO;
          if (retMessage)
            *retMessage=@"host denied";//TODO
          //TODO
        };
    }
  else
    {
#if 0 //HAVE_LIBWRAP
      NSString* appName=nil;
      struct request_info libwrapRequestInfo;
      memset(&libwrapRequestInfo, 0, sizeof(libwrapRequestInfo));

      appName = [[GSWApplication application] name];
      request_init(&libwrapRequestInfo, RQ_DAEMON,
		   [appName cString], RQ_FILE, [handle fileDescriptor], 0);
      
      fromhost(&libwrapRequestInfo);      
      if (STR_EQ(eval_hostname(libwrapRequestInfo.client), "") //!paranoid
	  || !hosts_access(&libwrapRequestInfo)) 
        {
          allowed = NO;
          if (retMessage)
	    {
	      *retMessage = @"libwrap denied";//TODO
	    }
          [GSWApplication statusDebugWithFormat:
			    @"libwrap: %@ REFUSED connection from: %s (%s)",
                          appName,
                          libwrapRequestInfo.client[0].name,
                          libwrapRequestInfo.client[0].addr];
        }
      else
        {
          [GSWApplication statusDebugWithFormat:
			    @"libwrap: %@ ACCEPTED connection from: %s (%s)",
                          appName,
                          libwrapRequestInfo.client[0].name,
                          libwrapRequestInfo.client[0].addr];
        }
#endif
    };
  return allowed;
};

// this is not changed after init, so there is no need for a lock
- (BOOL) isMultiThreadEnabled
{
  return _isMultiThreadEnabled;
}

-(void)stop
{
  [self notImplemented: _cmd];	//TODOFN
};

-(void)run
{
  [self notImplemented: _cmd];	//TODOFN
};

-(void)_runOnce
{
  [self notImplemented: _cmd];	//TODOFN
};

// WO 5:Use the user default WOListenQueueSize instead
// we did not have it. added to make compiler happy.
-(void)setListenQueueSize:(id)listenQueueSize;
{
  NSLog(@"%s is depricated. Use the user default WOListenQueueSize instead.",__PRETTY_FUNCTION__);
}

// CHECKME: find out if we really need this. -- dw
-(void)setWorkerThreadCountMax:(id)workerThreadCount
{
}

// CHECKME: find out if we really need this. -- dw
-(id)workerThreadCountMax
{
  return [NSNumber numberWithInt:_workerThreadCountMax];
}

// CHECKME: find out if we really need this. -- dw
-(void)setWorkerThreadCountMin:(id)workerThreadCount
{
}

// CHECKME: find out if we really need this. -- dw
-(id)workerThreadCountMin
{
  return [NSNumber numberWithInt:1];
}

// CHECKME: find out if we really need this. -- dw
-(void)setWorkerThreadCount:(id)workerThreadCount
{
}

-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p host: %@ port: %d adaptorHost: %@>",
          object_getClassName(self),
          (void*)self, 
          _host,
          _port,
          _adaptorHost];
}


@end
