/** GSWActionRequestHandler.h - <title>GSWeb: Class GSWActionRequestHandler</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.

   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 1999

   $Revision$
   $Date$

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

// $Id$

#ifndef _GSWActionRequestHandler_h__
	#define _GSWActionRequestHandler_h__


/**
 * GSWActionRequestHandler is a specialized request handler that processes
 * direct action requests in GSWeb applications. It extends GSWRequestHandler
 * to handle URLs that specify action classes and method names directly,
 * enabling stateless request processing and bookmarkable URLs. This handler
 * is responsible for parsing action URLs, instantiating the appropriate
 * action classes, and invoking the specified action methods.
 */
@interface GSWActionRequestHandler: GSWRequestHandler
{
  NSString* _actionClassName;
  NSString* _defaultActionName;
  Class _actionClassClass;
  BOOL _shouldAddToStatistics;
};

/**
 * Returns the default action class name used when no specific
 * action class is specified in the request URL.
 */
-(NSString*)defaultActionClassName;

/**
 * Returns the default action method name used when no specific
 * action method is specified in the request URL.
 */
-(NSString*)defaultDefaultActionName;

/**
 * Returns whether action requests should be added to application
 * statistics by default.
 */
-(BOOL)defaultShouldAddToStatistics;

/**
 * Initializes a new action request handler with the specified
 * default action class name, default action method name, and
 * statistics tracking preference.
 */
-(id)initWithDefaultActionClassName:(NSString*)defaultActionClassName
                  defaultActionName:(NSString*)defaultActionName
              shouldAddToStatistics:(BOOL)shouldAddToStatistics;

/**
 * Registers that an action request is about to be handled.
 * This method is typically called for monitoring and statistics purposes.
 */
-(void)registerWillHandleActionRequest;

/**
 * Registers that an action request has been handled with the
 * specified action name for monitoring and statistics purposes.
 */
-(void)registerDidHandleActionRequestWithActionNamed:(NSString*)actionName;

/**
 * Main entry point for handling incoming requests. This method
 * processes the request and returns an appropriate response.
 */
-(GSWResponse*)handleRequest:(GSWRequest*)aRequest;

/**
 * Extracts and returns the path components from the request
 * that are relevant to action request handling.
 */
-(NSArray*)getRequestHandlerPathForRequest:(GSWRequest*)aRequest;

/**
 * Class method that returns the action class for the specified
 * class name string.
 */
+(Class)_actionClassForName:(NSString*)name;

/**
 * Parses the request path to determine the action class name,
 * action class, and action method name, storing the results
 * in the provided pointers.
 */
-(void)getRequestActionClassNameInto:(NSString**)actionClassNamePtr
                           classInto:(Class*)actionClassPtr
                            nameInto:(NSString**)actionNamePtr
                             forPath:(NSArray*)path;

/**
 * Internal method that performs the actual request handling
 * after initial processing and validation.
 */
-(GSWResponse*)_handleRequest:(GSWRequest*)aRequest;


/**
 * Generates a null response, typically used when no content
 * needs to be returned to the client.
 */
-(GSWResponse*)generateNullResponse;

/**
 * Generates a response that refuses the request, typically
 * used when the request cannot be processed for some reason.
 */
-(GSWResponse*)generateRequestRefusalResponseForRequest:(GSWRequest*)aRequest;

/**
 * Generates an error response when an exception occurs during
 * action processing. The response includes error information
 * and is generated within the specified context.
 */
-(GSWResponse*)generateErrorResponseWithException:(NSException*)error
                                        inContext:(GSWContext*)aContext;

@end

//====================================================================
/**
 * Category providing class methods for creating GSWActionRequestHandler
 * instances with various configurations. This category simplifies the
 * instantiation process by providing convenient factory methods.
 */
@interface GSWActionRequestHandler (GSWRequestHandlerClassA)

/**
 * Returns a new action request handler instance with default
 * configuration settings.
 */
+(id)handler;

/**
 * Returns a new action request handler instance configured with
 * the specified default action class name, default action method name,
 * and statistics tracking preference.
 */
+(GSWActionRequestHandler*)handlerWithDefaultActionClassName:(NSString*)defaultActionClassName
                                           defaultActionName:(NSString*)defaultActionName
                                       shouldAddToStatistics:(BOOL)shouldAddToStatistics;
@end




#endif //GSWActionRequestHandler
