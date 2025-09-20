/** GSWApplication+Defaults.h - <title>GSWeb: GSWApplication+Defaults.h</title>

   Copyright (C) 2013 Free Software Foundation, Inc.

   Written by:	David Wetzel <dave@turbocat.de>

   $Revision: 30698 $
   $Date: 2010-06-13 21:19:25 -0700 (So, 13 Jun 2010) $

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

// $Id: GSWToggle.h 30698 2010-06-14 04:19:25Z dwetzel $

#ifndef _GSWApplication_Defaults_h__
	#define _GSWApplication_Defaults_h__


/**
 * Category extending GSWApplication with user defaults and configuration
 * management functionality. This category provides methods for initializing
 * and managing application defaults, adaptor configuration, and class name
 * settings for core GSWeb components. It handles the integration between
 * NSUserDefaults and the GSWeb application configuration system, allowing
 * applications to be configured through user defaults, command-line arguments,
 * and configuration files.
 */
@interface GSWApplication (GSWApplicationDefaults)

/**
 * Class method that initializes the user defaults keys used by GSWeb
 * applications. This method sets up the standard keys that the framework
 * recognizes for configuration purposes.
 */
+(void)_initUserDefaultsKeys;

/**
 * Class method that initializes the registration domain defaults for
 * the application. This establishes the default values that will be
 * used when no user-specified values are available.
 */
+(void)_initRegistrationDomainDefaults;

/**
 * Initializes the application's adaptors using configuration values
 * from the specified user defaults. This method sets up the web server
 * adaptors based on user default settings.
 */
-(void)_initAdaptorsWithUserDefaults:(NSUserDefaults*)userDefault;

/**
 * Creates and returns a dictionary of arguments derived from user defaults.
 * This method processes user default values and converts them into a
 * format suitable for application configuration.
 */
-(NSDictionary*)_argsDictionaryWithUserDefaults:(NSUserDefaults*)userDefault;

/**
 * Sets the class name to be used for creating response objects throughout
 * the application. This allows customization of the response class used
 * by the GSWeb framework.
 */
-(void)setResponseClassName:(NSString*)className;

/**
 * Returns the current class name used for creating response objects.
 */
-(NSString*)responseClassName;

/**
 * Sets the class name to be used for creating request objects throughout
 * the application. This allows customization of the request class used
 * by the GSWeb framework.
 */
-(void)setRequestClassName:(NSString*)className;

/**
 * Returns the current class name used for creating request objects.
 */
-(NSString*)requestClassName;

/**
 * Sets the class name to be used for creating context objects throughout
 * the application. This allows customization of the context class used
 * by the GSWeb framework.
 */
-(void)setContextClassName:(NSString*)className;

/**
 * Returns the current class name used for creating context objects.
 */
-(NSString*)contextClassName;


@end

#endif //_GSWApplication_Defaults_h__

