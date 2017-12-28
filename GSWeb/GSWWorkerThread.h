/** Implementation GSWWorkerThread for GNUStep
   Copyright (C) 2007 Free Software Foundation, Inc.

   Written by:  David Wetzel <dave@turbocat.de>
   Date: 2007

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

// $Id: GSWToggle.h 14202 2002-07-27 23:48:47Z mguesdon $

#ifndef _GSWWorkerThread_h__
	#define _GSWWorkerThread_h__

#import <Foundation/NSObject.h>
#include "GSWWOCompatibility.h"


@class GSWApplication;
@class GSWDefaultAdaptor;
@class NSRunLoop;
@class NSFileHandle;
@class NSThread;
@class NSAutoreleasePool;
@class GSWAdaptor;

@interface GSWWorkerThread: NSObject
{
  GSWApplication    *_app;
  GSWDefaultAdaptor *_mtAdaptor;          // 4.5
  NSRunLoop         *_currentRunLoop;      // 4.5
  NSFileHandle      * _serverSocket;        // rename to _serverFileHandle
  // called int _currentSocket in 4.5 
  NSFileHandle      *_currentSocket;       // rename to _currentFileHandle
  NSThread          * _t;
  NSAutoreleasePool * _pool;
  BOOL             _keepAlive;            // 4.5
  int               _maxSocketIdleTime;
  BOOL              _errorOnRead;
  BOOL              _dispatchError;
  BOOL              _runFlag;
  BOOL              _processingRequest;
  BOOL              _restricted;
  long              _expTime;
  int               _reqCount;
  BOOL              _logOnce;
  BOOL              _isMultiThreadEnabled;  // gsw only
  
  // verified in 4.5:
//  id                 _selfId;
//  WODefaultAdaptor *_mtAdaptor; 
//  NSRunLoop        *_currentRunLoop;
//  int              _currentSocket;
//  id               _inputBuffer;
//  int              _inputBufferLength;
//  int              _inputBufferIndex;
//  BOOL             _keepAlive;
//  BOOL             _errorOnRead;
//  BOOL             _runFlag;
}

-(id)initWithApp:(GSWApplication*)application
         adaptor:(GSWAdaptor*)adaptor
          stream:(NSFileHandle*)stream;

-(void)runOnce;


@end

#endif // _GSWWorkerThread_h__

