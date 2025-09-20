/** GSWDisplayGroup.h - <title>GSWeb: Class GSWDisplayGroup</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.

   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999

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

#ifndef _GSWDisplayGroup_h__
#define _GSWDisplayGroup_h__

#include <EOControl/EOQualifier.h>
#include <EOControl/EOEditingContext.h>
#include <EOControl/EODataSource.h>
#include <EOControl/EODetailDataSource.h>
#include <EOControl/EOKeyValueArchiver.h>
#include <EOControl/EONull.h>
#include <EOControl/EODeprecated.h>
#include <EOAccess/EODatabaseDataSource.h>

#ifndef GSWDisplayGroup
#define GSWDisplayGroup WODisplayGroup
#endif

/**
 * WODisplayGroup is a powerful controller class that manages a collection
 * of objects for display in web applications. It provides functionality
 * for fetching, filtering, sorting, and batch display of objects from
 * an EODataSource. The display group acts as an intermediary between
 * data sources and the user interface, handling object selection,
 * qualification, and batch navigation.
 */
@interface WODisplayGroup : NSObject <NSCoding>
{
  id _delegate;
/*
     objects (array) supplied by the EODataSource
     EOQualifier and EOSortOrderings to filter the objects for display
     Array of selection indexes

*/
  EODataSource* _dataSource;
  NSMutableArray* _allObjects;
  NSMutableArray* _displayedObjects;
  NSMutableArray* _selectedObjects;
  NSArray* _selection;
  NSArray* _sortOrdering;
  EOQualifier* _qualifier; /** qualifier used to in memory filter after fetch **/
  EOQualifier* _auxiliaryQueryQualifier; /** qualifier used when qualifying dataSource (added to query qualifiers) **/
  NSArray* _localKeys;
  NSDictionary* _insertedObjectDefaultValues;
  NSMutableArray* _savedAllObjects;
  NSMutableDictionary* _queryMatch;
  NSMutableDictionary* _queryNotMatch;
  NSMutableDictionary* _queryMin;
  NSMutableDictionary* _queryMinMatch;
  NSMutableDictionary* _queryMax;
  NSMutableDictionary* _queryMaxMatch;
  NSMutableDictionary* _queryOperator;
  NSMutableDictionary* _queryKeyValueQualifierClassName;
  NSString* _defaultStringMatchOperator;
  NSString* _defaultStringMatchFormat;
  NSMutableDictionary*_queryBindings;
  int _updatedObjectIndex;
  unsigned _numberOfObjectsPerBatch;
  unsigned _batchIndex;
  struct {
    unsigned int selectFirstObject:1;
    unsigned int autoFetch:1;
    unsigned int validateImmediately:1;
    unsigned int fetchAll:1;
    unsigned int isCustomDataSourceClass:1;
    unsigned int isInitialized:1;
    unsigned int didChangeContents:1;
    unsigned int didChangeSelection:1;
    unsigned int haveFetched:1;
    unsigned int _reserved:23;
  } _flags;
  struct {
    unsigned int didChangeDataSource:1;
    unsigned int displayArrayForObjects:1;
    unsigned int selectsFirstObjectAfterFetch:1;
    unsigned int shouldChangeSelection:1;
    unsigned int didChangeSelection:1;
    unsigned int didChangeSelectedObjects:1;
    unsigned int createObjectFailed:1;
    unsigned int shouldInsertObject:1;
    unsigned int didInsertObject:1;
    unsigned int shouldFetchObjects:1;
    unsigned int didFetchObjects:1;
    unsigned int shouldDeleteObject:1;
    unsigned int didDeleteObject:1;
    unsigned int didSetValueForObject:1;
    unsigned int shouldRedisplay:1;
    unsigned int shouldRefetchObjects:1;
    unsigned int _reserved:16;
  } _delegateRespondsTo;
};

/**
 * Returns a new autoreleased display group instance.
 */
+ (GSWDisplayGroup* )displayGroup;

/**
 * Returns the undo manager associated with the display group's
 * editing context.
 */
- (EOUndoManager *)undoManager;

/**
 * Returns all objects managed by the display group, regardless
 * of any current filtering or qualification.
 */
- (NSArray *)allObjects;

/**
 * Returns an array of all available qualifier operators that
 * can be used for building qualifiers.
 */
- (NSArray *)allQualifierOperators;

/**
 * Returns the total number of batches available for the current
 * set of displayed objects.
 */
- (unsigned)batchCount;

/**
 * Returns whether the display group builds qualifiers from
 * input values automatically.
 */
- (BOOL)buildsQualifierFromInput;

/**
 * Clears the current selection, deselecting all objects.
 */
- (BOOL)clearSelection;

/**
 * Returns the index of the currently displayed batch.
 */
- (unsigned)currentBatchIndex;

/**
 * Returns the data source that provides objects to the display group.
 */
- (EODataSource *)dataSource;

/**
 * Returns the default string match format used for string comparisons
 * in qualifiers.
 */
- (NSString *)defaultStringMatchFormat;

/**
 * Returns the default string match operator used for string comparisons
 * in qualifiers.
 */
- (NSString *)defaultStringMatchOperator;

/**
 * Returns the global default string match operator used by all
 * display groups.
 */
+ (NSString*)globalDefaultStringMatchOperator;

/**
 * Sets the global default string match operator for all display groups.
 */
+ (void)setGlobalDefaultStringMatchOperator:(NSString *)operatorString;

/**
 * Returns the global default string match format used by all
 * display groups.
 */
+ (NSString *)globalDefaultStringMatchFormat;

/**
 * Sets the global default string match format for all display groups.
 */
+ (void)setGlobalDefaultStringMatchFormat:(NSString *)format;

/**
 * Returns the global default setting for immediate change validation.
 */
+ (BOOL)globalDefaultForValidatesChangesImmediately;

/**
 * Sets the global default for immediate change validation.
 */
+ (void)setGlobalDefaultForValidatesChangesImmediately:(BOOL)flag;

/**
 * Returns the display group's delegate object.
 */
- (id)delegate;

/**
 * Deletes the currently selected objects from the display group.
 */
- (id)delete;

/**
 * Deletes the object at the specified index from the display group.
 */
- (BOOL)deleteObjectAtIndex:(unsigned)index;

/**
 * Deletes all currently selected objects.
 */
- (BOOL)deleteSelection;

/**
 * Returns the detail key used when the display group is configured
 * as a detail display group.
 */
- (NSString *)detailKey;

/**
 * Displays the batch containing the currently selected object.
 */
- (id)displayBatchContainingSelectedObject;

/**
 * Returns the array of objects currently being displayed,
 * considering batching constraints.
 */
- (NSArray *)displayedObjects;

/**
 * Returns all objects that would be displayed without batching
 * constraints applied.
 */
- (NSArray *)allDisplayedObjects;

/**
 * Displays the first batch of objects.
 */
- (id)displayFirstBatch;

/**
 * Displays the next batch of objects.
 */
- (id)displayNextBatch;

/**
 * Displays the previous batch of objects.
 */
- (id)displayPreviousBatch;

/**
 * Displays the last batch of objects.
 */
- (id)displayLastBatch;

/**
 * Returns whether the first batch can be displayed.
 */
- (BOOL)canDisplayFirstBatch;

/**
 * Returns whether the next batch can be displayed.
 */
- (BOOL)canDisplayNextBatch;

/**
 * Returns whether the previous batch can be displayed.
 */
- (BOOL)canDisplayPreviousBatch;

/**
 * Returns whether the last batch can be displayed.
 */
- (BOOL)canDisplayLastBatch;

/**
 * Ends editing mode and commits any pending changes.
 */
- (BOOL)endEditing;

/**
 * Executes a query using the current qualifier and updates
 * the displayed objects.
 */
- (id)executeQuery;

/**
 * Fetches objects from the data source and updates the
 * display group's object array.
 */
- (id)fetch;

/**
 * Returns whether the display group automatically fetches
 * objects when loaded.
 */
- (BOOL)fetchesOnLoad;

/**
 * Returns whether the display group has a detail data source
 * configuration.
 */
- (BOOL)hasDetailDataSource;

/**
 * Returns whether the display group has multiple batches
 * of objects to display.
 */
- (BOOL)hasMultipleBatches;

/**
 * Returns the index of the first object in the currently
 * displayed batch.
 */
- (unsigned)indexOfFirstDisplayedObject;

/**
 * Returns the index of the last object in the currently
 * displayed batch.
 */
- (unsigned)indexOfLastDisplayedObject;

/**
 * Initializes a new display group instance.
 */
- (id)init;

/**
 * Initializes the display group from a key-value unarchiver.
 */
- (id)initWithKeyValueUnarchiver:(EOKeyValueUnarchiver*)unarchiver;

/**
 * Completes initialization after unarchiving from a key-value
 * unarchiver.
 */
- (void)awakeFromKeyValueUnarchiver:(EOKeyValueUnarchiver*)object;

/**
 * Returns a mutable dictionary containing input values for
 * building qualifiers.
 */
- (NSMutableDictionary *)inputObjectForQualifier;

/**
 * Returns whether the display group is currently in query mode.
 */
- (BOOL)inQueryMode;

/**
 * Inserts a new object at the end of the object array.
 */
- (id)insert;

/**
 * Inserts a new object after the last object in the array.
 */
- (id)insertAfterLastObject;

/**
 * Returns the default values dictionary used when inserting
 * new objects.
 */
- (NSDictionary *)insertedObjectDefaultValues;

/**
 * Inserts the specified object at the given index in the
 * object array.
 */
- (void)insertObject:object
	     atIndex:(unsigned)index;

/**
 * Inserts a new object at the specified index.
 */
- (id)insertObjectAtIndex:(unsigned)index;

/**
 * Returns the last qualifier built from input values.
 */
- (EOQualifier *)lastQualifierFromInputValues;

/**
 * Returns the array of local keys used for qualification.
 */
- (NSArray *)localKeys;

/**
 * Returns the master object when the display group is configured
 * as a detail display group.
 */
- (id)masterObject;

/**
 * Returns the maximum number of objects displayed per batch.
 */
- (unsigned)numberOfObjectsPerBatch;

/**
 * Returns the qualifier used to filter objects in memory
 * after fetching.
 */
- (EOQualifier *)qualifier;

/**
 * Returns the auxiliary query qualifier used when qualifying
 * the data source.
 */
- (EOQualifier *)_auxiliaryQueryQualifier;

/**
 * Builds and returns a qualifier from current input values.
 */
- (EOQualifier *)qualifierFromInputValues;

/**
 * Builds and returns a qualifier from current query values.
 */
- (EOQualifier *)qualifierFromQueryValues;

/**
 * Applies qualification to the data source.
 */
- (void)qualifyDataSource;

/**
 * Applies qualification to the display group's objects.
 */
- (void)qualifyDisplayGroup;

/**
 * Returns the mutable dictionary of query bindings.
 */
- (NSMutableDictionary*)queryBindings;

/**
 * Returns the mutable dictionary of query match values.
 */
- (NSMutableDictionary*)queryMatch;

/**
 * Returns the mutable dictionary of query non-match values.
 */
- (NSMutableDictionary*)queryNotMatch;

/**
 * Returns the mutable dictionary of query maximum values.
 */
- (NSMutableDictionary*)queryMax;

/**
 * Returns the mutable dictionary of query maximum match values.
 */
- (NSMutableDictionary*)queryMaxMatch;

/**
 * Returns the mutable dictionary of query minimum values.
 */
- (NSMutableDictionary*)queryMin;

/**
 * Returns the mutable dictionary of query minimum match values.
 */
- (NSMutableDictionary*)queryMinMatch;

/**
 * Returns the mutable dictionary of query operators.
 */
- (NSMutableDictionary*)queryOperator;

/**
 * Returns the mutable dictionary of key-value qualifier class names.
 */
- (NSMutableDictionary*)queryKeyValueQualifierClassName;

/**
 * Forces the display group to redisplay its objects.
 */
- (void)redisplay;

/**
 * Returns an array of available relational qualifier operators.
 */
- (NSArray *)relationalQualifierOperators;

/**
 * Returns a mutable dictionary containing the second object
 * for building qualifiers.
 */
- (NSMutableDictionary *)secondObjectForQualifier;

/**
 * Returns the currently selected object, or nil if no object
 * is selected or multiple objects are selected.
 */
- (id)selectedObject;

/**
 * Sets the single selected object.
 */
- (void)setSelectedObject:(id)object;

/**
 * Sets the array of selected objects.
 */
- (void)setSelectedObjects:(NSArray *)objects;

/**
 * Returns an array of currently selected objects.
 */
- (NSArray *)selectedObjects;

/**
 * Returns an array of indexes for currently selected objects.
 */
- (NSArray *)selectionIndexes;

/**
 * Selects the first object in the displayed objects array.
 */
- (id)selectFirst;

/**
 * Selects the next object after the current selection.
 */
- (id)selectNext;

/**
 * Selects the specified object if it exists in the display group.
 */
- (BOOL)selectObject:(id)object;

/**
 * Selects objects that are identical to those in the provided array.
 */
- (BOOL)selectObjectsIdenticalTo:(NSArray *)objects;

/**
 * Selects objects identical to those in the provided array,
 * optionally selecting the first object if no match is found.
 */
- (BOOL)selectObjectsIdenticalTo:(NSArray *)objects
	    selectFirstOnNoMatch:(BOOL)flag;

/**
 * Selects the previous object before the current selection.
 */
- (id)selectPrevious;

/**
 * Returns whether the display group automatically selects
 * the first object after fetching.
 */
- (BOOL)selectsFirstObjectAfterFetch;

/**
 * Sets whether the display group should build qualifiers
 * from input values automatically.
 */
- (void)setBuildsQualifierFromInput:(BOOL)flag;

/**
 * Sets the current batch index for display.
 */
- (void)setCurrentBatchIndex:(unsigned)index;

/**
 * Sets the data source that provides objects to the display group.
 */
- (void)setDataSource:(EODataSource *)dataSource;

/**
 * Sets the default string match format for string comparisons.
 */
- (void)setDefaultStringMatchFormat:(NSString *)format;

/**
 * Sets the default string match operator for string comparisons.
 */
- (void)setDefaultStringMatchOperator:(NSString *)operator;

/**
 * Sets the display group's delegate object.
 */
- (void)setDelegate:(id)object;

/**
 * Sets the detail key used when the display group is configured
 * as a detail display group.
 */
- (void)setDetailKey:(NSString *)detailKey;

/**
 * Sets whether the display group should automatically fetch
 * objects when loaded.
 */
- (void)setFetchesOnLoad:(BOOL)flag;

/**
 * Sets whether the display group is in query mode.
 */
- (void)setInQueryMode:(BOOL)flag;

/**
 * Sets the default values used when inserting new objects.
 */
- (void)setInsertedObjectDefaultValues:(NSDictionary *)defaultValues;

/**
 * Sets the query operators dictionary.
 */
- (void)setQueryOperator:(NSDictionary*)qo;

/**
 * Adds a query operator value for the specified key.
 */
- (void)addQueryOperator:(NSString*)value
                  forKey:(NSString*)operatorKey;

/**
 * Sets the key-value qualifier class names dictionary.
 */
- (void)setQueryKeyValueQualifierClassName:(NSDictionary*)qo;

/**
 * Sets the array of local keys used for qualification.
 */
- (void)setLocalKeys:(NSArray *)keys;

/**
 * Sets the master object for detail display group configuration.
 */
- (void)setMasterObject:(id)masterObject;

/**
 * Sets the maximum number of objects to display per batch.
 */
- (void)setNumberOfObjectsPerBatch:(unsigned)count;

/**
 * Sets the array of objects managed by the display group.
 */
- (void)setObjectArray:(NSArray *)objects;

/**
 * Sets the qualifier used to filter objects in memory.
 */
- (void)setQualifier:(EOQualifier *)qualifier;

/**
 * Sets the auxiliary query qualifier used when qualifying
 * the data source.
 */
- (void)setAuxiliaryQueryQualifier:(EOQualifier *)qualifier;

/**
 * Sets the selection using an array of indexes.
 */
- (BOOL)setSelectionIndexes:(NSArray *)selection;

/**
 * Sets whether the display group should automatically select
 * the first object after fetching.
 */
- (void)setSelectsFirstObjectAfterFetch:(BOOL)flag;

/**
 * Sets the sort orderings used to sort the displayed objects.
 */
- (void)setSortOrderings:(NSArray *)orderings;

/**
 * Sets whether changes should be validated immediately.
 */
- (void)setValidatesChangesImmediately:(BOOL)flag;

/**
 * Returns the array of sort orderings used to sort objects.
 */
- (NSArray *)sortOrderings;

/**
 * Updates the array of displayed objects based on current
 * qualification and sorting criteria.
 */
- (void)updateDisplayedObjects;

/**
 * Returns whether the display group validates changes immediately.
 */
- (BOOL)validatesChangesImmediately;

@end

/**
 * Category defining delegate methods for GSWDisplayGroup.
 * These methods allow objects to respond to various display group
 * events and customize display group behavior.
 */
@interface NSObject (GSWDisplayGroupDelegation)

/**
 * Notifies the delegate when object creation failed for the
 * specified data source.
 */
-(void)displayGroup:(GSWDisplayGroup*)displayGroup
createObjectFailedForDataSource:(id)dataSource;

/**
 * Notifies the delegate when an object has been deleted
 * from the display group.
 */
-(void)displayGroup:(GSWDisplayGroup*)displayGroup
    didDeleteObject:(id)object;

/**
 * Notifies the delegate when objects have been fetched
 * from the data source.
 */
-(void)displayGroup:(GSWDisplayGroup*)displayGroup
    didFetchObjects:(NSArray*)objects;

/**
 * Notifies the delegate when an object has been inserted
 * into the display group.
 */
-(void)displayGroup:(GSWDisplayGroup*)displayGroup
    didInsertObject:(id)object;

/**
 * Notifies the delegate when a value has been set for
 * a specific key on an object.
 */
-(void)displayGroup:(GSWDisplayGroup*)displayGroup
	didSetValue:(id)value
	  forObject:(id)object
		key:(NSString*)key;

/**
 * Allows the delegate to provide a custom display array
 * for the given objects.
 */
-(NSArray*)displayGroup:(GSWDisplayGroup*)displayGroup
 displayArrayForObjects:(NSArray*)objects;

/**
 * Allows the delegate to control whether the selection
 * should change to the specified indexes.
 */
-(BOOL)displayGroup:(GSWDisplayGroup*)displayGroup
shouldChangeSelectionToIndexes:(NSArray*)newIndexes;

/**
 * Allows the delegate to control whether an object should
 * be inserted at the specified index.
 */
-(BOOL)displayGroup:(GSWDisplayGroup*)displayGroup
 shouldInsertObject:object
	    atIndex:(unsigned)index;

/**
 * Allows the delegate to control whether the specified
 * object should be deleted.
 */
-(BOOL)displayGroup:(GSWDisplayGroup*)displayGroup
 shouldDeleteObject:object;

/**
 * Allows the delegate to control whether the display group
 * should redisplay in response to editing context changes.
 */
-(BOOL)displayGroup:(GSWDisplayGroup*)displayGroup
shouldRedisplayForEditingContextChangeNotification:(NSNotification*)notification;

/**
 * Allows the delegate to control whether the display group
 * should refetch objects when all objects are invalidated.
 */
-(BOOL)displayGroup:(GSWDisplayGroup*)displayGroup
shouldRefetchForInvalidatedAllObjectsNotification:(NSNotification*)notification;

/**
 * Notifies the delegate when the display group's data source
 * has changed.
 */
-(void)displayGroupDidChangeDataSource:(GSWDisplayGroup*)displayGroup;

/**
 * Notifies the delegate when the display group's selected
 * objects have changed.
 */
-(void)displayGroupDidChangeSelectedObjects:(GSWDisplayGroup*)displayGroup;

/**
 * Notifies the delegate when the display group's selection
 * has changed.
 */
-(void)displayGroupDidChangeSelection:(GSWDisplayGroup*)displayGroup;

/**
 * Allows the delegate to control whether the display group
 * should fetch objects from its data source.
 */
-(BOOL)displayGroupShouldFetch:(GSWDisplayGroup*)displayGroup;

@end

#endif //_GSWDisplayGroup_h__
