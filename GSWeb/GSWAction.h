/** GSWAction.h - <title>GSWeb: Class GSWAction</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.

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

#ifndef _GSWAction_h__
	#define _GSWAction_h__


//====================================================================
/**
 * GSWAction is the base class for handling direct actions in GSWeb applications.
 * Direct actions provide a way to bypass the typical component-based request
 * handling and allow for direct method invocation based on URL parameters.
 * Actions are stateless and don't maintain session information unless explicitly
 * accessed, making them suitable for bookmarkable URLs and RESTful interfaces.
 */
@interface GSWAction : NSObject
{
  @private
    GSWContext* _context;
};

/**
 * Initializes a new action instance with the specified request.
 * The action uses the request to determine the appropriate session
 * and context for processing.
 */
-(id)initWithRequest:(GSWRequest*)aRequest;

/**
 * Returns the request object associated with this action.
 */
-(GSWRequest*)request;

/**
 * Returns the existing session without creating a new one if none exists.
 * This method returns nil if no session is currently active.
 */
-(GSWSession*)existingSession;

/**
 * Returns the existing session with the specified session ID.
 * This method returns nil if no session exists with the given ID.
 */
-(GSWSession*)existingSessionWithSessionID:(NSString*)aSessionID;

/**
 * Returns the current session, creating one if necessary.
 * Unlike existingSession, this method will create a new session
 * if one doesn't already exist.
 */
-(GSWSession*)session;

/**
 * Returns the application instance associated with this action.
 */
-(GSWApplication*)application;

/**
 * Creates and returns a component instance with the specified name.
 * This is typically used to generate response pages from action methods.
 */
-(GSWComponent*)pageWithName:(NSString*)pageName;

/**
 * Class method that determines whether the specified action name
 * corresponds to a valid action method in the given class.
 */
+(BOOL)_isActionNamed:(NSString*)actionName
        actionOfClass:(Class)actionClass;

/**
 * Class method that returns the selector for the specified action name
 * within the given class.
 */
+(SEL)_selectorForActionNamed:(NSString*)actionName
                      inClass:(Class)class;

/**
 * Returns the selector for the specified action name within this
 * action instance's class.
 */
-(SEL)_selectorForActionNamed:(NSString*)actionName;

/**
 * Performs the action method with the specified name and returns
 * the result. The result must conform to the GSWActionResults protocol.
 */
-(id <GSWActionResults>)performActionNamed:(NSString*)actionName;

/** Returns YES if self reponds to actionName **/
-(BOOL)isActionNamed:(NSString*)actionName;

/**
 * Extracts and returns the session ID from the specified request.
 * This method is used internally to identify existing sessions.
 */
-(NSString*)sessionIDForRequest:(GSWRequest*)aRequest;

/**
 * Initializes the session ID in the context based on the current request.
 * This is an internal method used during action processing.
 */
-(void)_initializeRequestSessionIDInContext:(GSWContext*)aContext;

@end

//====================================================================
/**
 * Category providing additional context and session access methods
 * for GSWAction instances. These methods offer alternative ways
 * to access the action's context and session objects.
 */
@interface GSWAction (GSWActionA)

/**
 * Returns the context associated with this action.
 */
-(GSWContext*)context;

/**
 * Returns the private context instance associated with this action.
 * This is typically used internally by the framework.
 */
-(GSWContext*)_context;

/**
 * Returns the current session associated with this action.
 */
-(GSWSession*)session;

/**
 * Returns the private session instance associated with this action.
 * This is typically used internally by the framework.
 */
-(GSWSession*)_session;
@end

//====================================================================
/**
 * Category providing debugging and logging functionality for GSWAction
 * instances. These methods allow actions to output diagnostic information
 * during development and debugging phases.
 */
@interface GSWAction (GSWDebugging)

/**
 * Logs the specified string to the application's log output.
 */
-(void)logWithString:(NSString*)string;

/**
 * Logs a formatted message to the application's log output.
 * Accepts variable arguments like printf-style formatting.
 */
-(void)logWithFormat:(NSString*)format,...;

/**
 * Class method that logs a formatted message to the application's
 * log output. Accepts variable arguments like printf-style formatting.
 */
+(void)logWithFormat:(NSString*)format,...;

/**
 * Outputs a debug message with the specified string.
 * This is typically used for internal debugging purposes.
 */
-(void)_debugWithString:(NSString*)string;

/**
 * Outputs a formatted debug message with variable arguments.
 * This method provides printf-style formatting for debug output.
 */
-(void)debugWithFormat:(NSString*)format,...;
@end

#endif //_GSWAction_h__

