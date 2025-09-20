/* GSWAdaptor.h - GSWeb: Class GSWAdaptor
   Copyright (C) 1999-2002 Free Software Foundation, Inc.

   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
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

#ifndef _GSWAdaptor_h__
	#define _GSWAdaptor_h__

#include <Foundation/NSObject.h>
@class NSDictionary;

//====================================================================
// GSWAdaptor

/**
 * GSWAdaptor is the base class for all adaptors in GSWeb applications.
 * Adaptors serve as the bridge between web servers and GSWeb applications,
 * handling the communication protocol and request/response processing.
 * They are responsible for receiving HTTP requests from web servers,
 * converting them into GSWeb request objects, and sending back the
 * appropriate responses. Different adaptor implementations can support
 * various web server interfaces and deployment configurations.
 */
@interface GSWAdaptor: NSObject

/**
 * Initializes a new adaptor instance with the specified name and
 * configuration arguments. The name typically identifies the adaptor
 * type, while the arguments dictionary contains configuration parameters
 * specific to the adaptor implementation.
 */
-(id)initWithName:(NSString*)name
        arguments:(NSDictionary*)arguments;

/**
 * Registers the adaptor to receive system events and notifications.
 * This method sets up the necessary event handling mechanisms for
 * the adaptor to function properly within the web server environment.
 */
-(void)registerForEvents;

/**
 * Unregisters the adaptor from system events and notifications.
 * This method cleans up event handling resources and should be called
 * when the adaptor is being shut down or destroyed.
 */
-(void)unregisterForEvents;

/**
 * Returns whether the adaptor can handle multiple requests concurrently.
 * Adaptors that return YES can process multiple requests simultaneously,
 * while those returning NO must process requests sequentially.
 */
-(BOOL)dispatchesRequestsConcurrently;

/**
 * Returns the port number on which the adaptor is listening for
 * incoming requests. This is typically used for network-based
 * communication with web servers.
 */
-(int)port;

// deprecated since?
/**
 * Deprecated method that processes a single request cycle.
 * This method has been deprecated in favor of more sophisticated
 * request handling mechanisms.
 */
-(void)runOnce;

/**
 * Deprecated method that returns whether the adaptor is busy
 * processing a single request. This method has been deprecated
 * along with runOnce.
 */
-(BOOL)doesBusyRunOnce;

/**
 * Deprecated method that returns whether multi-threading is enabled
 * for the adaptor. This method has been deprecated in favor of
 * dispatchesRequestsConcurrently.
 */
-(BOOL)isMultiThreadEnabled;

@end

//====================================================================
/**
 * Category containing deprecated functionality for GSWAdaptor.
 * This category provides legacy methods that were used in older
 * versions of GSWeb but have since been superseded by more modern
 * approaches to adaptor configuration and port management.
 */
@interface GSWAdaptor (GSWAdaptorOldFn)

/**
 * Deprecated method that registers a specific port for an application
 * with the given name. This method was used in earlier versions for
 * port management but has been replaced by more sophisticated
 * configuration mechanisms.
 */
-(void)	registerPort:(int)port
 forApplicationNamed:(NSString*)applicationName;
@end

// FIXME: check if that exists:
// -(id)workerThreadCount;
//-(void)adaptorThreadExited:(GSWDefaultAdaptorThread*)adaptorThread;

#endif //_GSWAdaptor_h__
