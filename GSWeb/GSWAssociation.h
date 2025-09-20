/** GSWAssociation.h - <title>GSWeb: Class GSWAssociation</title>

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

// $Id$

/**
 * The GSWAssociation class represents values of GSWeb attributes specified in
 * declaration files (.gswd). Association objects serve as binding mechanisms between
 * component attributes and their values, handling both constant values and dynamic
 * key paths that resolve to component properties or methods.
 *
 * GSWAssociation objects get or set values according to value keys. For example:
 *
 * MyString1: GSWString {
 *   value = "aLabel";      // Constant string value
 * };
 *
 * MyString2: GSWString {
 *   value = label;         // Dynamic key path to component property
 * };
 *
 * MyString3: GSWString {
 *   value = myMember.label; // Nested key path through component hierarchy
 * };
 *
 * At runtime, the GSWeb parser scans HTML templates (.html) and their declarations
 * (.gswd) to create dynamic element objects. The association handles value resolution:
 * - Constant values (quoted strings) are returned as-is
 * - Simple key paths resolve through the component's valueForKey: mechanism
 * - Nested key paths traverse object hierarchies using key-value coding
 *
 * Special Features:
 * - Negation: Prefix key path with "!" to negate boolean results
 * - Debug logging: Comprehensive logging support for binding operations
 * - Type flexibility: Handles various value types with appropriate conversions
 */

#ifndef _GSWAssociation_h__
	#define _GSWAssociation_h__

//====================================================================
/**
 * The main GSWAssociation class that handles value binding and resolution
 * for GSWeb components. This class serves as the foundation for all binding
 * operations in the GSWeb framework, providing mechanisms to get and set
 * values through key paths, handle constant values, and manage debugging
 * and logging functionality.
 */
@interface GSWAssociation : NSObject <NSCopying>
{
  BOOL _debugEnabled;        /** Enable debug logging for this association */
  BOOL _negate;             /** Whether to negate boolean results (GSWeb extension) */
  NSString* _bindingName;   /** The name of the binding attribute */
  NSString* _declarationName; /** The name of the declaration containing this association */
  NSString* _declarationType; /** The type of the declaration (element class name) */
};

/**
 * Returns the value represented by this association within the context
 * of the specified component. This is the primary method for value
 * resolution, handling both constant values and key path evaluation.
 * If negation is enabled, boolean results are negated before returning.
 */
-(id)valueInComponent:(GSWComponent*)component;

/**
 * Returns the boolean value represented by this association within the
 * context of the specified component. Non-boolean values are converted
 * to boolean using standard Objective-C truthiness rules.
 */
- (BOOL) boolValueInComponent:(GSWComponent*)component;

/**
 * Sets the value represented by this association within the context
 * of the specified component. This method is only effective for
 * settable associations (those representing key paths rather than
 * constant values).
 */
-(void)setValue:(id)value
    inComponent:(GSWComponent*)component;
/**
 * Returns whether this association represents a constant value rather
 * than a dynamic key path. Constant associations always return the
 * same value regardless of component state.
 */
-(BOOL)isValueConstant;

/**
 * Returns whether this association represents a settable key path.
 * Only key path associations (not constant values) are settable,
 * and only if the key path resolves to a settable property.
 */
-(BOOL)isValueSettable;

/**
 * Returns whether this association's value is settable within the
 * context of the specified component. This provides component-specific
 * settability checking beyond the general isValueSettable method.
 */
-(BOOL)isValueSettableInComponent:(GSWComponent*) comp;

/**
 * Returns whether this association represents a constant value within
 * the context of the specified component. This provides component-specific
 * constant checking beyond the general isValueConstant method.
 */
-(BOOL)isValueConstantInComponent:(GSWComponent*) comp;

// YES if we negate the result before returnig it.
/**
 * Returns whether this association negates boolean results before returning them.
 * This is a GSWeb extension feature that allows boolean key paths to be negated
 * by prefixing them with "!" in the declaration.
 */
-(BOOL)negate;

/**
 * Sets whether this association should negate boolean results before returning them.
 * When enabled, boolean values returned by valueInComponent: and boolValueInComponent:
 * will be logically inverted.
 */
-(void) setNegate:(BOOL) yn;


/**
 * Returns a string description of this association, typically showing
 * the key path or constant value it represents. Used for debugging
 * and logging purposes.
 */
-(NSString*)description;

/**
 * Returns the name of the binding attribute that this association
 * represents within a component declaration. For example, "value"
 * in a GSWString's value binding.
 */
-(NSString*)bindingName;

/**
 * Returns the name of the declaration that contains this association.
 * This is typically the identifier used in the .gswd file for the
 * dynamic element containing this binding.
 */
-(NSString*)declarationName;

/**
 * Returns the type of the declaration that contains this association.
 * This corresponds to the element class name (e.g., "GSWString",
 * "GSWConditional") in the component declaration.
 */
-(NSString*)declarationType;

/**
 * Sets the association class to use for a specific handler type.
 * This allows customization of association behavior for different
 * types of bindings or value sources.
 */
+(void)setClasse:(Class)class
      forHandler:(NSString*)handler;

/**
 * Adds a class to the list of log handler classes. Log handlers
 * can monitor and process association operations for debugging
 * and analysis purposes.
 */
+(void)addLogHandlerClasse:(Class)class;

/**
 * Removes a class from the list of log handler classes, stopping
 * its participation in association operation logging.
 */
+(void)removeLogHandlerClasse:(Class)class;

/**
 * Creates and returns a new association representing the specified constant value.
 * The association will always return this value regardless of component context
 * and will not be settable.
 */
+(GSWAssociation*)associationWithValue:(id)value;

/**
 * Creates and returns a new association representing the specified key path.
 * The association will resolve the key path within component contexts and
 * may be settable depending on the key path structure.
 */
+(GSWAssociation*)associationWithKeyPath:(NSString*)keyPath;

//NDFN
/**
 * Creates and returns a new association from a string representation.
 * The string is parsed to determine whether it represents a constant value
 * (quoted strings) or a key path, with appropriate association type created.
 */
+(GSWAssociation*)associationFromString:(NSString*)string;


// returns the binding String as in the wod.
/**
 * Returns the binding string representation as it appears in the .gswd file.
 * This provides the original declaration syntax for this association,
 * useful for debugging and development tools.
 */
- (NSString*) bindingInComponent:(GSWComponent*) component;

/**
 * Returns whether this association is implemented for the specified component.
 * This checks if the association's key path can be resolved within the
 * component's context, indicating whether the binding will function correctly.
 */
-(BOOL)isImplementedForComponent:(NSObject*)component;


/**
 * Returns the key path string that this association represents.
 * For constant value associations, this may return nil or an
 * internal representation. For key path associations, returns
 * the actual key path used for value resolution.
 */
-(NSString*)keyPath;

/**
 * Logs synchronization from component to parent, recording the value
 * being synchronized and the component context. Used for debugging
 * bidirectional binding operations.
 */
-(void)logSynchronizeComponentToParentForValue:(id)value
                                   inComponent:(GSWComponent*)component;

/**
 * Logs synchronization from parent to component, recording the value
 * being synchronized and the component context. Used for debugging
 * bidirectional binding operations.
 */
-(void)logSynchronizeParentToComponentForValue:(id)value
                                   inComponent:(GSWComponent*)component;

/**
 * Internal method to log value retrieval operations. Records when
 * values are pulled from this association within a component context,
 * useful for debugging and performance analysis.
 */
-(void)_logPullValue:(id)value
	 inComponent:(GSWComponent*) component;

/**
 * Internal method to log value assignment operations. Records when
 * values are pushed to this association within a component context,
 * useful for debugging and performance analysis.
 */
-(void)_logPushValue:(id)value
	 inComponent:(GSWComponent*) component;

/**
 * Returns a detailed debug description of this association, including
 * its type, key path or value, and current configuration. More verbose
 * than the standard description method.
 */
-(NSString*)debugDescription;

/**
 * Enables debug logging for this association when used with the specified
 * binding name, declaration name, and declaration type. When enabled,
 * the association will log detailed information about its operations.
 */
-(void)setDebugEnabledForBinding:(NSString*)bindingName
                 declarationName:(NSString*)declarationName
                 declarationType:(NSString*)declarationType;

/**
 * Class method that directly retrieves a value from a component using
 * the specified key path. This is a convenience method that performs
 * key path resolution without requiring an association object.
 */
+(id)valueInComponent:(GSWComponent*)component
           forKeyPath:(NSString*)keyPath;

/**
 * Class method that directly sets a value in a component using the
 * specified key path. This is a convenience method that performs
 * key path assignment without requiring an association object.
 */
+(void)setValue:(id)value
    inComponent:(GSWComponent*)component
     forKeyPath:(NSString*)keyPath;

@end

//===================================================================================
/**
 * Category extending NSDictionary with association-related functionality.
 * This category provides methods for working with dictionaries that contain
 * associations as values, enabling batch operations and debugging support
 * for association collections commonly used in component bindings.
 */
@interface NSDictionary (GSWAssociation)

/**
 * Returns whether debug logging is enabled for associations in this dictionary
 * within the context of the specified component. Checks the debug state of
 * association values contained in the dictionary.
 */
-(BOOL)isAssociationDebugEnabledInComponent:(GSWComponent*)component;

/**
 * Enables debug logging for all associations contained as values in this
 * dictionary. This is a convenience method for batch enabling debug mode
 * on multiple associations simultaneously.
 */
-(void)associationsSetDebugEnabled;

/**
 * Transfers values from one object to another using the associations in this
 * dictionary as the transfer mechanism. Each association key-value pair
 * defines how values are copied between objects.
 */
-(void)associationsSetValuesFromObject:(id)from
                              inObject:(id)to;

/**
 * Returns a new dictionary containing associations from this dictionary that
 * do not have keys matching the specified prefix. Associations with matching
 * prefixes are removed from the provided mutable dictionary if specified.
 */
-(NSDictionary*)associationsWithoutPrefix:(NSString*)prefix
                               removeFrom:(NSMutableDictionary*)removeFrom;

/**
 * Returns a new dictionary where string values in this dictionary are replaced
 * with corresponding association objects. This is typically used during parsing
 * to convert string declarations into executable associations.
 */
-(NSDictionary*)dictionaryByReplacingStringsWithAssociations;

@end

//===================================================================================
/**
 * Category extending NSArray with association-related functionality.
 * This category provides methods for working with arrays that contain
 * string representations of associations, enabling conversion from
 * parsed declarations to executable association objects.
 */
@interface NSArray (GSWAssociation)

/**
 * Returns a new array where string elements in this array are replaced
 * with corresponding association objects. This is typically used during
 * parsing to convert string declarations into executable associations
 * for array-based bindings.
 */
-(NSArray*)arrayByReplacingStringsWithAssociations;

@end
#endif //_GSWAssociation_h__



