/** GSWDisplayGroup.h - <title>GSWeb: Class GSWDisplayGroup</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
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

#if !GDL2
   #ifdef TCSDB
      #import <TCSimpleDB/TCSimpleDB.h>
      #import <TCSimpleDB/EODefines.h>
   #else // TCSDB
      #include <eoaccess/EOModel.h>
      #include <eoaccess/EOEntity.h>
      #include <eoaccess/EOAttribute.h>
      #include <eoaccess/EOAttributeOrdering.h>
      #include <eoaccess/EORelationship.h>
      #include <eoaccess/EOQualifier.h>

      #include <eoaccess/EOAdaptor.h>
      #include <eoaccess/EOAdaptorContext.h>
      #include <eoaccess/EOAdaptorChannel.h>

      #include <eoaccess/EODatabase.h>
      #include <eoaccess/EODatabaseContext.h>
      #include <eoaccess/EODatabaseChannel.h>
      #include <eoaccess/EODataSources.h>
      #include <eoaccess/EODatabaseDataSource.h>

      #include <eoaccess/EOGenericRecord.h>
      #include <eoaccess/EONull.h>
      #include <eoaccess/EOSQLExpression.h>

      @class EOKeyValueUnarchiver;

      #define EODataSource EODatabaseDataSource
   #endif
#else
   #import <EOControl/EOQualifier.h>
   #import <EOControl/EOEditingContext.h>
   #import <EOControl/EODataSource.h>
   #import <EOControl/EODetailDataSource.h>
   #import <EOControl/EOKeyValueArchiver.h>
   #import <EOControl/EONull.h>
   #import <EOAccess/EODatabaseDataSource.h>
#endif

@interface GSWDisplayGroup : NSObject <NSCoding>
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
  EOQualifier* _qualifier;
  NSArray* _localKeys;
  NSDictionary* _insertedObjectDefaultValues;
  NSMutableArray* _savedAllObjects;
  NSMutableDictionary* _queryMatch;
  NSMutableDictionary* _queryMin;
  NSMutableDictionary* _queryMinMatch;
  NSMutableDictionary*_queryMax;
  NSMutableDictionary*_queryMaxMatch;
  NSMutableDictionary*_queryOperator;
  NSString* _defaultStringMatchOperator;
  NSString* _defaultStringMatchFormat;
  NSMutableDictionary*_queryBindings;
  unsigned _numberOfObjectsPerBatch;
  unsigned _batchIndex;
  struct {
    unsigned int selectFirstObject:1;
    unsigned int autoFetch:1;
    unsigned int validateImmediately:1;
    unsigned int queryMode:1;
    unsigned int fetchAll:1;
    unsigned int _reserved:27;
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

- (NSArray *)allObjects;
- (NSArray *)allQualifierOperators;
- (unsigned)batchCount;
- (BOOL)buildsQualifierFromInput;
- (BOOL)clearSelection;
- (unsigned)currentBatchIndex;
- (EODataSource *)dataSource;
- (NSString *)defaultStringMatchFormat;
- (NSString *)defaultStringMatchOperator;
- (id)delegate;
- (id)delete;
- (BOOL)deleteObjectAtIndex:(unsigned)index;
- (BOOL)deleteSelection;
- (NSString *)detailKey;
- (id)displayBatchContainingSelectedObject;
- (NSArray *)displayedObjects;
- (id)displayNextBatch;
- (id)displayPreviousBatch;
- (BOOL)endEditing;
- (id)executeQuery;
- (id)fetch;
- (BOOL)fetchesOnLoad;
- (BOOL)hasDetailDataSource;
- (BOOL)hasMultipleBatches;
- (unsigned)indexOfFirstDisplayedObject;
- (unsigned)indexOfLastDisplayedObject;
- (id)init;
- (id)initWithKeyValueUnarchiver:(EOKeyValueUnarchiver*)unarchiver;
- (void)awakeFromKeyValueUnarchiver:(EOKeyValueUnarchiver*)object;
- (NSMutableDictionary *)inputObjectForQualifier;
- (BOOL)inQueryMode;
- (void)editingContext:(id)editingContext
   presentErrorMessage:(id)msg;
- (id)insert;
- (id)insertAfterLastObject;
- (NSDictionary *)insertedObjectDefaultValues;
- (void)insertObject:object
	     atIndex:(unsigned)index;
- (id)insertObjectAtIndex:(unsigned)index;
- (EOQualifier *)lastQualifierFromInputValues;
- (NSArray *)localKeys;
- (id)masterObject;
- (unsigned)numberOfObjectsPerBatch;
- (EOQualifier *)qualifier;
- (EOQualifier *)qualifierFromInputValues;
- (EOQualifier *)qualifierFromQueryValues;
- (void)qualifyDataSource;
- (void)qualifyDisplayGroup;
- (NSMutableDictionary*)queryBindings;
- (NSMutableDictionary*)queryMatch;
- (NSMutableDictionary*)queryMax;
- (NSMutableDictionary*)queryMaxMatch;
- (NSMutableDictionary*)queryMin;
- (NSMutableDictionary*)queryMinMatch;
- (NSMutableDictionary*)queryOperator;
- (void)redisplay;
- (NSArray *)relationalQualifierOperators;
- (NSMutableDictionary *)secondObjectForQualifier;
- (id)selectedObject;
- (void)setSelectedObject:(id)object;
- (NSArray *)selectedObjects;
- (NSArray *)selectionIndexes;
- (id)selectFirst;
- (id)selectNext;
- (BOOL)selectObject:(id)object;
- (BOOL)selectObjectsIdenticalTo:(NSArray *)objects;
- (BOOL)selectObjectsIdenticalTo:(NSArray *)objects
	    selectFirstOnNoMatch:(BOOL)flag;
- (id)selectPrevious;
- (BOOL)selectsFirstObjectAfterFetch;
- (void)setBuildsQualifierFromInput:(BOOL)flag;
- (void)setCurrentBatchIndex:(unsigned)index;
- (void)setDataSource:(EODataSource *)dataSource;
- (void)setDefaultStringMatchFormat:(NSString *)format;
- (void)setDefaultStringMatchOperator:(NSString *)operator;
- (void)setDelegate:(id)object;
- (void)setDetailKey:(NSString *)detailKey;
- (void)setFetchesOnLoad:(BOOL)flag;
- (void)setInQueryMode:(BOOL)flag;
- (void)setInsertedObjectDefaultValues:(NSDictionary *)defaultValues;
-(void)setQueryOperator:(NSDictionary*)qo;
- (void)setLocalKeys:(NSArray *)keys;
- (void)setMasterObject:(id)masterObject;
- (void)setNumberOfObjectsPerBatch:(unsigned)count;
- (void)setObjectArray:(NSArray *)objects;
- (void)setQualifier:(EOQualifier *)qualifier;
- (BOOL)setSelectionIndexes:(NSArray *)selection;
- (void)setSelectsFirstObjectAfterFetch:(BOOL)flag;
- (void)setSortOrderings:(NSArray *)orderings;
- (void)setValidatesChangesImmediately:(BOOL)flag;
- (NSArray *)sortOrderings;
- (void)updateDisplayedObjects;
- (BOOL)validatesChangesImmediately;

@end

// By Delegate

@interface NSObject (GSWDisplayGroupDelegation)

-(void)displayGroup:(GSWDisplayGroup*)displayGroup
createObjectFailedForDataSource:(id)dataSource;

-(void)displayGroup:(GSWDisplayGroup*)displayGroup
    didDeleteObject:(id)object;

-(void)displayGroup:(GSWDisplayGroup*)displayGroup
    didFetchObjects:(NSArray*)objects;

-(void)displayGroup:(GSWDisplayGroup*)displayGroup
    didInsertObject:(id)object;

-(void)displayGroup:(GSWDisplayGroup*)displayGroup
	didSetValue:(id)value
	  forObject:(id)object
		key:(NSString*)key;

-(NSArray*)displayGroup:(GSWDisplayGroup*)displayGroup
 displayArrayForObjects:(NSArray*)objects;

-(BOOL)displayGroup:(GSWDisplayGroup*)displayGroup
shouldChangeSelectionToIndexes:(NSArray*)newIndexes;

-(BOOL)displayGroup:(GSWDisplayGroup*)displayGroup
 shouldInsertObject:object
	    atIndex:(unsigned)index;

-(BOOL)displayGroup:(GSWDisplayGroup*)displayGroup
 shouldDeleteObject:object;

-(BOOL)displayGroup:(GSWDisplayGroup*)displayGroup
shouldRedisplayForEditingContextChangeNotification:(NSNotification*)notification;

-(BOOL)displayGroup:(GSWDisplayGroup*)displayGroup
shouldRefetchForInvalidatedAllObjectsNotification:(NSNotification*)notification;

-(void)displayGroupDidChangeDataSource:(GSWDisplayGroup*)displayGroup;
-(void)displayGroupDidChangeSelectedObjects:(GSWDisplayGroup*)displayGroup;
-(void)displayGroupDidChangeSelection:(GSWDisplayGroup*)displayGroup;
-(BOOL)displayGroupShouldFetch:(GSWDisplayGroup*)displayGroup;

@end

#endif //_GSWDisplayGroup_h__
