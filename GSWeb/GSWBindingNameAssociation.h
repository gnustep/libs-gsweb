/** GSWBindingNameAssociation.h - <title>GSWeb: Class GSWBindingNameAssociation</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.

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

/**
 * Specialized association class that provides binding name resolution within
 * component hierarchies. GSWBindingNameAssociation extends GSWAssociation to
 * handle cases where binding values need to be resolved through parent component
 * binding names rather than direct key paths.
 *
 * This association type is particularly useful for implementing component
 * composition patterns where child components need to access binding values
 * from their parent components. It maintains both a parent binding name and
 * a key path to enable flexible value resolution strategies.
 *
 * Key features:
 * - Parent binding name tracking for hierarchical value resolution
 * - Key path support for nested property access
 * - Component-aware value resolution and assignment
 * - Integration with GSWeb's binding mechanism for component composition
 */

// $Id$

#ifndef _GSWBindingNameAssociation_h__
	#define _GSWBindingNameAssociation_h__

//====================================================================
/**
 * GSWBindingNameAssociation provides specialized binding resolution for
 * component hierarchies where values need to be resolved through parent
 * component bindings. This class extends GSWAssociation to support
 * binding name indirection and hierarchical value resolution patterns
 * common in component composition scenarios.
 */
@interface GSWBindingNameAssociation : GSWAssociation
{
  NSString* _parentBindingName;  /** The name of the binding in the parent component */
  NSString* _keyPath;           /** The key path for value resolution within the binding context */
};

/**
 * Initializes a new binding name association with the specified key path.
 * The key path is used for resolving values within the binding context
 * once the parent binding name has been resolved to its target object.
 */
-(id)initWithKeyPath:(NSString*)keyPath;

/**
 * Returns whether this association is implemented for the specified component.
 * This method checks if the parent binding name can be resolved within the
 * component's binding context and whether the resulting binding is available
 * and functional.
 */
-(BOOL)isImplementedForComponent:(GSWComponent*)object;

/**
 * Returns whether this association represents a constant value. For binding
 * name associations, this depends on the nature of both the parent binding
 * and the key path resolution - typically returns NO as these associations
 * resolve dynamically through the component hierarchy.
 */
-(BOOL)isValueConstant;

/**
 * Returns whether this association's value can be set. The settability
 * depends on whether the resolved parent binding supports value assignment
 * and whether the key path points to a settable property within the
 * binding's target object.
 */
-(BOOL)isValueSettable;

/**
 * Resolves and returns the value represented by this association within
 * the specified component context. This involves resolving the parent
 * binding name to its target object, then applying the key path to
 * retrieve the final value.
 */
-(id)valueInComponent:(GSWComponent*)component;

/**
 * Sets the value represented by this association within the specified
 * component context. This involves resolving the parent binding name
 * to its target object, then using the key path to set the value on
 * the appropriate property of that object.
 */
-(void)setValue:(id)value
    inComponent:(GSWComponent*)component;
@end

#endif //_GSWBindingNameAssociation_h__



