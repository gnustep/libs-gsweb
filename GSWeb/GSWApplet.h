/** GSWApplet.h - <title>GSWeb: Class GSWApplet</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.

   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999

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

#ifndef _GSWApplet_h__
	#define _GSWApplet_h__

//OK
//====================================================================
/**
 * GSWApplet is a dynamic element that generates HTML applet tags for
 * embedding Java applets in GSWeb applications. It extends GSWHTMLDynamicElement
 * to provide comprehensive support for Java applet deployment, including
 * archive management, parameter passing, and client-side attribute handling.
 * This component manages both traditional applet archives and AGC (Apple
 * Generic Container) archives, making it suitable for various Java deployment
 * scenarios in web applications.
 */
@interface GSWApplet: GSWHTMLDynamicElement
{
  NSMutableDictionary* _clientSideAttributes;
  NSString* _elementID;
  NSString* _url;
  NSString* _contextID;
  NSMutableDictionary* _snapshots;
  GSWAssociation* _archive;
  GSWAssociation* _archiveNames;
  GSWAssociation* _agcArchive;
  GSWAssociation* _agcArchiveNames;
  GSWAssociation* _codeBase;
};

/**
 * Initializes a new GSWApplet instance with the specified name,
 * associations dictionary, and content elements. The associations
 * define the applet's parameters and configuration, while content
 * elements represent nested HTML content.
 */
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements;

/**
 * Deallocates the applet instance and cleans up associated resources,
 * including client-side attributes and snapshot data.
 */
-(void)dealloc;

/**
 * Internal method that appends string content at the right position
 * using the specified mapping. This method is used for specialized
 * content positioning within the applet element.
 */
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping;

/**
 * Creates and returns a parameter object with the specified name,
 * value, target, and key. The treatNilValueAsGSWNull flag determines
 * how nil values are handled during parameter creation.
 */
-(id)		paramWithName:(id)name
                        value:(id)value
                       target:(id)target
                          key:(id)key
       treatNilValueAsGSWNull:(BOOL)treatNilValueAsGSWNull;

/**
 * Returns the HTML element name used for this applet component,
 * typically "applet".
 */
-(NSString*)elementName;

/**
 * Returns the current context ID associated with this applet instance.
 */
-(id)contextID;

/**
 * Sets the context ID for this applet instance.
 */
-(void)setContextID:(id)contextID;

/**
 * Returns the URL associated with this applet.
 */
-(id)url;

/**
 * Sets the URL for this applet instance.
 */
-(void)setURL:(id)url;

/**
 * Returns the unique element ID for this applet instance.
 */
-(NSString*)elementID;

/**
 * Sets the unique element ID for this applet instance.
 */
-(void)setElementID:(NSString*)elementID;
@end

//====================================================================
/**
 * Category providing core functionality for GSWApplet request/response
 * handling and archive management. This category contains the main
 * methods for processing HTTP requests, generating responses, and
 * managing both traditional and AGC archive configurations.
 */
@interface GSWApplet (GSWAppletA)

/**
 * Appends the applet's HTML representation to the response within
 * the specified context. This method generates the complete applet
 * tag with all necessary parameters and attributes.
 */
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext;

/**
 * Invokes the appropriate action for the incoming request within
 * the specified context. Returns the element that should handle
 * the action, if any.
 */
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext;

/**
 * Takes values from the incoming request and processes them within
 * the specified context. This method handles form data and parameter
 * values related to the applet.
 */
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext;

/**
 * Appends GSWeb-specific object associations to the response.
 * This method adds framework-specific parameters and configurations
 * to the applet output.
 */
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext;

/**
 * Computes and prepares the AGC archive string within the specified
 * context. This internal method processes AGC archive configurations
 * for Apple-specific deployment scenarios.
 */
-(void)_computeAgcArchiveStringInContext:(GSWContext*)aContext;

/**
 * Returns a list of AGC archive URLs within the specified context.
 * This method resolves and collects all AGC archive locations.
 */
-(id)_agcArchiveURLsListInContext:(GSWContext*)aContext;

/**
 * Returns a list of traditional archive URLs within the specified
 * context. This method resolves standard Java archive locations.
 */
-(id)_archiveURLsListInContext:(GSWContext*)aContext;

/**
 * Returns a list of AGC archive names within the specified context.
 * This method collects the names of all AGC archives to be loaded.
 */
-(id)_agcArchiveNamesListInContext:(GSWContext*)aContext;

/**
 * Returns a list of traditional archive names within the specified
 * context. This method collects standard Java archive names.
 */
-(id)_archiveNamesListInContext:(GSWContext*)aContext;

/**
 * Performs cleanup operations when the applet is deallocated for
 * the specified component. This internal method ensures proper
 * resource management.
 */
-(void)_deallocForComponent:(id)component;

/**
 * Performs initialization operations when the applet is awakened
 * for the specified component. This internal method sets up
 * necessary resources and configurations.
 */
-(void)_awakeForComponent:(id)component;

/**
 * Class method that returns whether the applet class has GSWeb-specific
 * object associations. This determines if additional framework-specific
 * processing is required.
 */
+(BOOL)hasGSWebObjectsAssociations;
@end


#endif //_GSWApplet_h__
