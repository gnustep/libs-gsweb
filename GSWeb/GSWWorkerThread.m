/** Implementation GSWWorkerThread for GNUStep
   Copyright (C) 2007 Free Software Foundation, Inc.

   Written by:  David Wetzel <dave@turbocat.de>
   Date: 1997

   This file is part of the GNUstep Web Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.
   */

#ifndef GNUSTEP
#include <GNUstepBase/GNUstep.h>
#include <GNUstepBase/NSDebug+GNUstepBase.h>
#endif

#include <Foundation/Foundation.h>
#include <Foundation/NSThread.h>
#include <sys/socket.h>

#include "GSWWOCompatibility.h"
#include "GSWWorkerThread.h"
#include "GSWPrivate.h"
#include "GSWDefines.h"
#include "GSWConstants.h"
#include "GSWUtils.h"
#include "GSWDebug.h"
#include "GSWRequest.h"
#include "GSWApplication.h"
#include "GSWAdaptor.h"
#include "GSWDefaultAdaptor.h"
#include "GSWResponse.h"
#include "GSWHTTPIO.h"

static NSString *REQUEST_ID = @"x-webobjects-request-id";

@implementation GSWWorkerThread

+ (void) initialize
{
  if (self == [GSWWorkerThread class])
  {
  }
}

- (void)setServerSocket:(NSFileHandle*)stream
{
  [_queueCondition lock];
  ASSIGN(_serverSocket,stream);
  [_queueCondition signal];
  [_queueCondition unlock];
}

-(void)dealloc
{
// TODO: add vars!
  DESTROY(_serverSocket);
  DESTROY(_currentSocket);
  DESTROY(_queueCondition);
  _app = nil;
  _mtAdaptor = nil;

    [super dealloc];
}


-(id)initWithApp:(GSWApplication*)application
         adaptor:(GSWAdaptor*)adaptor
          stream:(NSFileHandle*)stream
{
  if ((self = [self init])) {
    _runFlag = NO;
    _app = application;
    _mtAdaptor = (GSWDefaultAdaptor*)adaptor;
    ASSIGN(_serverSocket,stream);
    _keepAlive=NO;
    _maxSocketIdleTime=900; // 300 ms
    _isMultiThreadEnabled = [adaptor isMultiThreadEnabled];
    
    if (_isMultiThreadEnabled) {
      _queueCondition = [[NSCondition alloc] init];
      
      _t = [[NSThread alloc] initWithTarget:self
                                   selector:@selector(checkForWork)
                                     object:nil];
      
      [_t start];
      [_t autorelease];
    } else {
      _runFlag = YES;
      _pool = [[NSAutoreleasePool alloc] init];
      [self runOnce];
      DESTROY(_pool);
    }
    
  }
  return self;
}

- (void)threadWillExit:(NSNotification*)notification
{
    _mtAdaptor = nil;
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

//PRIVATE!
- (void) _closeSocket
{
  if (_currentSocket == nil) {
    return;
  }
  [_currentSocket closeFile];
  _currentSocket = nil;
}  

- (void) checkForWork
{
  while (![[NSThread currentThread] isCancelled]) {
    [_queueCondition lock];
    [_queueCondition wait];
    
    if (_serverSocket == nil) {
      [_queueCondition unlock];
      continue;
    } else {
      _runFlag = YES;
    }
    [_queueCondition unlock];
    _pool = [[NSAutoreleasePool alloc] init];
    [self runOnce];
    DESTROY(_pool);
    DESTROY(_serverSocket);
    [_mtAdaptor workerThreadFinished:self];
  }
}

-(void)runOnce
{
  GSWRequest      *request = nil;
  struct timeval  timeout;
  GSWResponse     *response;
  
  if ((!_runFlag) || (_serverSocket == nil)) {
    return;
  }
  
  _errorOnRead = NO;
  // _maxSocketIdleTime is milisecs!
  timeout.tv_sec = 0;
  timeout.tv_usec = _maxSocketIdleTime * 1000;
  
  NS_DURING {
    setsockopt([_serverSocket fileDescriptor], SOL_SOCKET, SO_RCVTIMEO, &timeout,sizeof(timeout));
    
    request = [GSWHTTPIO readRequestFromFromHandle: _serverSocket];
  } NS_HANDLER {
    _errorOnRead = YES;
    NSLog(@"%s -- dropping connection reason: %@",__PRETTY_FUNCTION__, [localException reason]);
  } NS_ENDHANDLER;
  
  // "womp" is the request handler key used by the WOTaskD contacing your app
  if ((_errorOnRead || (request == nil)) ||
      ((([[_app class] isDirectConnectEnabled] == NO) && ([request isUsingWebServer] == NO)) &&
       ([@"womp" isEqual:[request requestHandlerKey]] == NO))) {
        goto done;
      }
  _processingRequest = YES;
  _dispatchError = NO;
  
  NS_DURING {
    response = [_app dispatchRequest:request];
  } NS_HANDLER {
    NSLog(@"%s -- Exception occurred while responding to client: %@",
          __PRETTY_FUNCTION__, [localException description]);
    _dispatchError = YES;
    response = [GSWDefaultAdaptor _lastDitchErrorResponse];
  } NS_ENDHANDLER;
  
  if (response) {
    NSString * reqid = [request headerForKey:REQUEST_ID];
    if (reqid) {
      [response setHeader:reqid forKey:REQUEST_ID];
    }
    NS_DURING {
      [GSWHTTPIO sendResponse:response
                     toHandle: _serverSocket
                      request:request];
    } NS_HANDLER {
      NSLog(@"%s -- Exception while sending response: %@",
            __PRETTY_FUNCTION__, [localException description]);
    } NS_ENDHANDLER;
  }
  
done:
  
  [self _closeSocket];
  
  _processingRequest = NO;
  _runFlag = NO;
  
}


// -[WOWorkerThread runLoopOnce]
// -[WOWorkerThread runOnce]
// -[WOWorkerThread run]
// -[WOWorkerThread stop]
// -[WOWorkerThread(WOWkrObjRequestHandling) readLine:withLength:]
// -[WOWorkerThread(WOWkrObjRequestHandling) readBlob:withLength:]
// -[WOWorkerThread(WOWkrObjRequestHandling) readRequest]
// -[WOWorkerThread(WOWkrObjRequestHandling) sendResponse:]


- (NSString*) description
{
  return [NSString stringWithFormat:@"<%s %p socket:%@ isWorking:%s>",
                   object_getClassName(self),
          (void*)self, _serverSocket, _runFlag ? "YES" : "NO"];
}

-(BOOL)isWorking
{
  return _runFlag;
}

@end
@implementation GSWWorkerThread (WorkerThreadDepricated)

-(id)initWithApp:(GSWApplication*)application
     withAdaptor:(GSWAdaptor*)adaptor
      withStream:(NSFileHandle*)stream
{
  NSLog(@"%s is depricated use initWithApp:adaptor:stream: instead.",__PRETTY_FUNCTION__);
  return [self initWithApp: application adaptor:adaptor stream:stream];
}

// this exists in WO 4.5
- (id) initWithApp:(GSWApplication*) app andMtAdaptor:(GSWAdaptor*) adaptor restricted:(void*) rst
{
  return [self initWithApp:app adaptor:adaptor stream:rst];
}

@end
