/* GSWDisplayGroup.m - GSWeb: Class GSWDisplayGroup
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
                Mirko Viviani <mirko.viviani@rccr.cremona.it>
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

static char rcsId[] = "$Id$";

#include <gsweb/GSWeb.framework/GSWeb.h>


//====================================================================
@implementation GSWDisplayGroup

#if !GDL2
//--------------------------------------------------------------------
//	init

-(id)init
{
  self=[super init];
  delegate=nil;
    LOGObjectFnNotImplemented();	//TODOFN
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  delegate=nil; //NO retain !!
  [super dealloc];
}

//--------------------------------------------------------------------
//	allObjects

-(NSArray*)allObjects
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	allQualifierOperators

-(NSArray*)allQualifierOperators
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	batchCount

-(unsigned)batchCount
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	buildsQualifierFromInput

-(BOOL)buildsQualifierFromInput
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	clearSelection

-(BOOL)clearSelection
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	currentBatchIndex

-(unsigned)currentBatchIndex
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	dataSource

-(EODataSource*)dataSource
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setDataSource:

-(void)setDataSource:(EODataSource*)dataSource_
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	defaultStringMatchFormat

-(NSString*)defaultStringMatchFormat
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	defaultStringMatchOperator

-(NSString*)defaultStringMatchOperator
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	delegate

-(id)delegate
{
  return delegate;
};

//--------------------------------------------------------------------
//	setDelegate:

-(void)setDelegate:(id)object_
{
  delegate=object_;//NO Retain !
};

//--------------------------------------------------------------------
//	delete

-(id)delete
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	deleteObjectAtIndex:

-(BOOL)deleteObjectAtIndex:(unsigned)index
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	deleteSelection

-(BOOL)deleteSelection
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	detailKey

-(NSString*)detailKey
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	displayBatchContainingSelectedObject

-(id)displayBatchContainingSelectedObject
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	displayedObjects

-(NSArray*)displayedObjects
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	displayNextBatch

-(id)displayNextBatch
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	displayPreviousBatch

-(id)displayPreviousBatch
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	endEditing

-(BOOL)endEditing
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	executeQuery

-(id)executeQuery
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	fetch

-(id)fetch
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	fetchesOnLoad

-(BOOL)fetchesOnLoad
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	hasDetailDataSource

-(BOOL)hasDetailDataSource
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	hasMultipleBatches

-(BOOL) hasMultipleBatches
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	inputObjectForQualifier

-(NSMutableDictionary*)inputObjectForQualifier
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	inQueryMode

-(BOOL)inQueryMode
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	insert

-(id)insert
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	insertedObjectDefaultValues

-(NSDictionary*)insertedObjectDefaultValues
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	insertObject:atIndex:

-(void)insertObject:anObject
			atIndex:(unsigned)index_
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	insertObjectAtIndex:

-(id)insertObjectAtIndex:(unsigned)index_
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	lastQualifierFromInputValues

-(EOQualifier*)lastQualifierFromInputValues
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	localKeys

-(NSArray*)localKeys
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	masterObject

-(id)masterObject
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	numberOfObjectsPerBatch

-(unsigned)numberOfObjectsPerBatch
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	qualifier

-(EOQualifier*)qualifier
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	qualifierFromInputValues

-(EOQualifier*)qualifierFromInputValues
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	qualifierFromQueryValues

-(EOQualifier*)qualifierFromQueryValues
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	qualifyDataSource

-(void)qualifyDataSource
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	qualifyDisplayGroup

-(void)qualifyDisplayGroup
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	queryMatch

-(NSMutableDictionary*)queryMatch
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	queryMax

-(NSMutableDictionary*)queryMax
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	queryMin

-(NSMutableDictionary*)queryMin
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	queryOperator

-(NSMutableDictionary*)queryOperator
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	redisplay

-(void)redisplay
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	relationalQualifierOperators

-(void)relationalQualifierOperators
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	secondObjectForQualifier

-(NSMutableDictionary*)secondObjectForQualifier
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	selectedObject

-(id)selectedObject
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	selectedObjects

-(NSArray*)selectedObjects
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	selectionIndexes

-(NSArray*)selectionIndexes
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	selectNext

-(id)selectNext
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	selectObject:

-(BOOL)selectObject:(id)object
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	selectObjectsIdenticalTo:

-(BOOL)selectObjectsIdenticalTo:(NSArray*)objects
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	selectObjectsIdenticalTo:selectFirstOnNoMatch:

-(BOOL)selectObjectsIdenticalTo:(NSArray*)objects
		   selectFirstOnNoMatch:(BOOL)flag
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	selectPrevious

-(id)selectPrevious
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	selectsFirstObjectAfterFetch

-(BOOL)selectsFirstObjectAfterFetch
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setBuildsQualifierFromInput:

-(void)setBuildsQualifierFromInput:(BOOL)flag
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setCurrentBatchIndex:

-(void)setCurrentBatchIndex:(unsigned)index_
{
    LOGObjectFnNotImplemented();	//TODOFN
};


//--------------------------------------------------------------------
//	setDefaultStringMatchFormat:

-(void)setDefaultStringMatchFormat:(NSString*)format
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setDefaultStringMatchOperator:

-(void)setDefaultStringMatchOperator:(NSString*)operator
{
    LOGObjectFnNotImplemented();	//TODOFN
};


//--------------------------------------------------------------------
//	setDetailKey:

-(void)setDetailKey:(NSString*)detailKey
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setFetchesOnLoad:

-(void)setFetchesOnLoad:(BOOL)flag
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setInQueryMode:

-(void)setInQueryMode:(BOOL)flag
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setInsertedObjectDefaultValues:

-(void)setInsertedObjectDefaultValues:(NSDictionary*)defaultValues
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setLocalKeys:

-(void)setLocalKeys:(NSArray*)keys
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setMasterObject:

-(void)setMasterObject:(id)masterObject
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setNumberOfObjectsPerBatch:

-(void)setNumberOfObjectsPerBatch:(unsigned)count
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setObjectArray:

-(void)setObjectArray:(NSArray*)objects
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setQualifier:

-(void)setQualifier:(EOQualifier*)qualifier_
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setSelectionIndexes:

-(BOOL)setSelectionIndexes:(NSArray*)selection
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setSelectsFirstObjectAfterFetch:

-(void)setSelectsFirstObjectAfterFetch:(BOOL)flag
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setSortOrdering:

-(void)setSortOrdering:(NSArray*)orderings
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setValidatesChangesImmediately:

-(void)setValidatesChangesImmediately:(BOOL)flag
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	sortOrdering

-(NSArray*)sortOrdering
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	updateDisplayedObjects

-(void)updateDisplayedObjects
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	validatesChangesImmediately

-(BOOL)validatesChangesImmediately
{
    LOGObjectFnNotImplemented();	//TODOFN
};

#else /* GDL2 implementation */

//--------------------------------------------------------------------
//	init

- init
{
  self = [super init];

  allObjects = [[NSMutableArray alloc] initWithCapacity:16];
  displayedObjects = [[NSMutableArray alloc] initWithCapacity:16];
  selectedObjects = [[NSMutableArray alloc] initWithCapacity:8];

  queryMatch    = [[NSMutableDictionary alloc] initWithCapacity:8];
  queryMin      = [[NSMutableDictionary alloc] initWithCapacity:8];
  queryMax      = [[NSMutableDictionary alloc] initWithCapacity:8];
  queryOperator = [[NSMutableDictionary alloc] initWithCapacity:8];

  queryBindings = [[NSMutableDictionary alloc] initWithCapacity:8];

  batchIndex = 1;

  [[NSNotificationCenter defaultCenter]
    addObserver:self
    selector:@selector(_changedInEditingContext:)
    name:EOObjectsChangedInEditingContextNotification
    object:nil];

  [[NSNotificationCenter defaultCenter]
    addObserver:self
    selector:@selector(_invalidatedAllObjectsInStore:)
    name:EOInvalidatedAllObjectsInStoreNotification
    object:nil];

  return self;
}

- _changedInEditingContext:(NSNotification *)notification
{
  BOOL redisplay = YES;

  if(delegateRespondsTo.shouldRedisplay == YES)
    redisplay = [self displayGroup:self
		      shouldRedisplayForEditingContextChangeNotification:notification];

  if(redisplay == YES)
    [self redisplay];
}

- _invalidatedAllObjectsInStore:(NSNotification *)notification
{
  BOOL refetch = YES;

  if(delegateRespondsTo.shouldRefetchObjects == YES)
    refetch = [self displayGroup:self
		    shouldRefetchForInvalidatedAllObjectsNotification:
		      notification];

  if(refetch == YES)
    [self fetch];
}

//--------------------------------------------------------------------
- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  delegate = nil;

  DESTROY(dataSource);

  DESTROY(allObjects);
  DESTROY(displayedObjects);
  DESTROY(selection);
  DESTROY(selectedObjects);
  DESTROY(sortOrdering);
  DESTROY(qualifier);
  DESTROY(localKeys);

  DESTROY(insertedObjectDefaultValues);
  DESTROY(savedAllObjects);

  DESTROY(queryMatch);
  DESTROY(queryMin);
  DESTROY(queryMax);
  DESTROY(queryOperator);

  DESTROY(defaultStringMatchOperator);
  DESTROY(defaultStringMatchFormat);

  DESTROY(queryBindings);

  [super dealloc];
}

//--------------------------------------------------------------------
//	allObjects

- (NSArray *)allObjects
{
  return allObjects;
}

//--------------------------------------------------------------------
//	allQualifierOperators

- (NSArray *)allQualifierOperators
{
  return [EOQualifier allQualifierOperators];
}

//--------------------------------------------------------------------
//	batchCount

- (unsigned)batchCount
{
  unsigned count;

  if(!numberOfObjectsPerBatch)
    return 1;

  count = [allObjects count];

  if(!count)
    return 1;

  return (count / numberOfObjectsPerBatch) +
    (count % numberOfObjectsPerBatch ? 1 : 0);
}

//--------------------------------------------------------------------
//	buildsQualifierFromInput

-(BOOL)buildsQualifierFromInput
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	clearSelection

- (BOOL)clearSelection
{
  return [self setSelectionIndexes:[NSArray array]];
}

//--------------------------------------------------------------------
//	currentBatchIndex

- (unsigned)currentBatchIndex
{
  return batchIndex;
}

//--------------------------------------------------------------------
//	dataSource

- (EODataSource *)dataSource
{
  return dataSource;
}

//--------------------------------------------------------------------
//	setDataSource:

- (void)setDataSource:(EODataSource *)dataSource_
{
  EOEditingContext *context;

  if(dataSource)
    {
      context = [dataSource editingContext];
      [context removeEditor:self];
      if([self isEqual:[context messageHandler]] == YES)
	[context setMessageHandler:nil];
    }

  ASSIGN(dataSource, dataSource_);

  context = [dataSource editingContext];
  [context addEditor:self];
  if([context messageHandler] == nil)
    [context setMessageHandler:self];

  [displayedObjects removeAllObjects];

  if(delegateRespondsTo.didChangeDataSource == YES)
    [delegate displayGroupDidChangeDataSource:self];
}

//--------------------------------------------------------------------
//	defaultStringMatchFormat

- (NSString *)defaultStringMatchFormat
{
  return defaultStringMatchFormat;
}

//--------------------------------------------------------------------
//	defaultStringMatchOperator

- (NSString *)defaultStringMatchOperator
{
  return defaultStringMatchOperator;
}

//--------------------------------------------------------------------
//	delegate

- (id)delegate
{
  return delegate;
}

//--------------------------------------------------------------------
//	setDelegate:

- (void)setDelegate:(id)delegate_
{
  delegate = delegate_;

  delegateRespondsTo.createObjectFailed = 
    [delegate respondsToSelector:@selector(displayGroup:createObjectFailedForDataSource:)];
  delegateRespondsTo.didDeleteObject = 
    [delegate respondsToSelector:@selector(displayGroup:didDeleteObject:)];
  delegateRespondsTo.didFetchObjects = 
    [delegate respondsToSelector:@selector(displayGroup:didFetchObjects:)];
  delegateRespondsTo.didInsertObject = 
    [delegate respondsToSelector:@selector(displayGroup:didInsertObject:)];
  delegateRespondsTo.didSetValueForObject = 
    [delegate respondsToSelector:@selector(displayGroup:didSetValue:forObject:key:)];
  delegateRespondsTo.displayArrayForObjects = 
    [delegate respondsToSelector:@selector(displayGroup:displayArrayForObjects:)];
  delegateRespondsTo.shouldChangeSelection = 
    [delegate respondsToSelector:@selector(displayGroup:shouldChangeSelectionToIndexes:)];
  delegateRespondsTo.shouldInsertObject = 
    [delegate respondsToSelector:@selector(displayGroup:shouldInsertObject:atIndex:)];
  delegateRespondsTo.shouldDeleteObject = 
    [delegate respondsToSelector:@selector(displayGroup:shouldDeleteObject:)];
  delegateRespondsTo.shouldRedisplay = 
    [delegate respondsToSelector:@selector(displayGroup:shouldRedisplayForEditingContextChangeNotification:)];
  delegateRespondsTo.shouldRefetchObjects = 
    [delegate respondsToSelector:@selector(displayGroup:shouldRefetchForInvalidatedAllObjectsNotification:)];
  delegateRespondsTo.didChangeDataSource = 
    [delegate respondsToSelector:@selector(displayGroupDidChangeDataSource:)];
  delegateRespondsTo.didChangeSelectedObjects = 
    [delegate respondsToSelector:@selector(displayGroupDidChangeSelectedObjects:)];
  delegateRespondsTo.didChangeSelection = 
    [delegate respondsToSelector:@selector(displayGroupDidChangeSelection:)];
  delegateRespondsTo.shouldFetchObjects = 
    [delegate respondsToSelector:@selector(displayGroupShouldFetch:)];
}

//--------------------------------------------------------------------
//	delete

- (id)delete
{
  [self deleteSelection];
  return nil;
}

//--------------------------------------------------------------------
//	deleteObjectAtIndex:

- (BOOL)deleteObjectAtIndex:(unsigned)index
{
  BOOL delete = YES;
  id object;

  object = [allObjects objectAtIndex:index];

  if(delegateRespondsTo.shouldDeleteObject == YES)
    delete = [delegate displayGroup:self
		       shouldDeleteObject:object];

  if(delete == NO)
    return NO;

  [dataSource deleteObject:object];

  if(delegateRespondsTo.didDeleteObject == YES)
    [delegate displayGroup:self
	      didDeleteObject:object];

  return YES;
}

//--------------------------------------------------------------------
//	deleteSelection

- (BOOL)deleteSelection
{
  BOOL delete = YES;
  NSEnumerator *enumerator;
  id object;

  enumerator = [selectedObjects objectEnumerator];
  while((object = [enumerator nextObject]))
    {
      if(delegateRespondsTo.shouldDeleteObject == YES)
	delete = [delegate displayGroup:self
			   shouldDeleteObject:object];

      if(delete == NO)
	return NO;
    }

  enumerator = [selectedObjects objectEnumerator];
  while((object = [enumerator nextObject]))
    {
      [dataSource deleteObject:object];

      if(delegateRespondsTo.didDeleteObject == YES)
	[delegate displayGroup:self
		  didDeleteObject:object];
    }

  return YES;
}

//--------------------------------------------------------------------
//	detailKey

- (NSString *)detailKey
{
  if([self hasDetailDataSource] == YES)
    return [(EODetailDataSource *)dataSource detailKey];

  return nil;
}

//--------------------------------------------------------------------
//	displayBatchContainingSelectedObject

-(id)displayBatchContainingSelectedObject
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	displayedObjects

- (NSArray *)displayedObjects
{
  return displayedObjects;
}

//--------------------------------------------------------------------
//	displayNextBatch

- (id)displayNextBatch
{
  int count = [allObjects count];
  NSRange range;

  [displayedObjects removeAllObjects];

  if(!numberOfObjectsPerBatch || count <= numberOfObjectsPerBatch)
    {
      batchIndex = 1;
      [displayedObjects addObjectsFromArray:allObjects];
    }
  else
    {
      if(batchIndex >= [self batchCount])
	{
	  batchIndex = 1;
	  range.location = 0;
	  range.length = numberOfObjectsPerBatch;
	}
      else
	{
	  range.location = batchIndex * numberOfObjectsPerBatch;
	  range.length = (range.location + numberOfObjectsPerBatch > count ?
			  count - range.location : numberOfObjectsPerBatch);
	  batchIndex++;
	}

      [displayedObjects addObjectsFromArray:[allObjects
					      subarrayWithRange:range]];
    }

  [self clearSelection];

  return nil;
}

//--------------------------------------------------------------------
//	displayPreviousBatch

- (id)displayPreviousBatch
{
  int count = [allObjects count];
  NSRange range;

  [displayedObjects removeAllObjects];

  if(!numberOfObjectsPerBatch || count <= numberOfObjectsPerBatch)
    {
      batchIndex = 1;
      [displayedObjects addObjectsFromArray:allObjects];
    }
  else
    {
      if(batchIndex == 1)
	{
	  batchIndex = [self batchCount];
	  range.location = (batchIndex-1) * numberOfObjectsPerBatch;

	  range.length = (range.location + numberOfObjectsPerBatch > count ?
			  count - range.location : numberOfObjectsPerBatch);
	}
      else
	{
	  batchIndex--;
	  range.location = (batchIndex-1) *  numberOfObjectsPerBatch;
	  range.length = numberOfObjectsPerBatch;
	}

      [displayedObjects addObjectsFromArray:[allObjects
					      subarrayWithRange:range]];
    }

  [self clearSelection];

  return nil;
}

//--------------------------------------------------------------------
//	endEditing

- (BOOL)endEditing
{
  return YES;
}

//--------------------------------------------------------------------
//	executeQuery

-(id)executeQuery
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	fetch

- (id)fetch
{
  BOOL fetch = YES;

  if(delegateRespondsTo.shouldFetchObjects == YES)
    fetch = [delegate displayGroupShouldFetch:self];

  if(fetch == NO)
    return nil;

  [self setObjectArray:[dataSource fetchObjects]];

  if(delegateRespondsTo.didFetchObjects == YES)
    [delegate displayGroup:self
	      didFetchObjects:allObjects];

  return nil;
}

//--------------------------------------------------------------------
//	fetchesOnLoad

- (BOOL)fetchesOnLoad
{
  return flags.autoFetch;
}

//--------------------------------------------------------------------
//	hasDetailDataSource

- (BOOL)hasDetailDataSource
{
  return [dataSource isKindOfClass:[EODetailDataSource class]];
}

//--------------------------------------------------------------------
//	hasMultipleBatches

- (BOOL)hasMultipleBatches
{
  return !flags.fetchAll;
}

//--------------------------------------------------------------------
//	inputObjectForQualifier

-(NSMutableDictionary*)inputObjectForQualifier
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	indexOfFirstDisplayedObject;

- (unsigned)indexOfFirstDisplayedObject
{
  int batch = [self currentBatchIndex];

  return ((batch-1) * numberOfObjectsPerBatch);
}

//--------------------------------------------------------------------
//	indexOfLastDisplayedObject;

- (unsigned)indexOfLastDisplayedObject
{
  int batch = [self currentBatchIndex];

  return ((batch-1) * numberOfObjectsPerBatch) + [displayedObjects count];
}

//--------------------------------------------------------------------
//	inQueryMode

- (BOOL)inQueryMode
{
  return flags.queryMode;
}

//--------------------------------------------------------------------
//	insert

- (id)insert
{
  unsigned index=0, count;

  count = [allObjects count];

  if([selection count])
    index = [[selection objectAtIndex:0] unsignedIntValue]+1;

  if(!count)
    index = 0;
  if(count <= index)
    index = count - 1;

  [self insertObjectAtIndex:index];

  return nil;
}

//--------------------------------------------------------------------
//	insertedObjectDefaultValues

- (NSDictionary *)insertedObjectDefaultValues
{
  return insertedObjectDefaultValues;
}

//--------------------------------------------------------------------
//	insertObject:atIndex:

- (void)insertObject:anObject
	     atIndex:(unsigned)index
{
  BOOL insert = YES;

  if(delegateRespondsTo.shouldInsertObject == YES)
    insert = [delegate displayGroup:self
		       shouldInsertObject:anObject
		       atIndex:index];

  if(insert == NO)
    return;

  [dataSource insertObject:anObject];

  [allObjects insertObject:anObject atIndex:index];
  [self setCurrentBatchIndex:batchIndex];

  if(delegateRespondsTo.didInsertObject == YES)
    [delegate displayGroup:self
	      didInsertObject:anObject];

  [self setSelectionIndexes:
	  [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:index]]];
}

//--------------------------------------------------------------------
//	insertObjectAtIndex:

- (id)insertObjectAtIndex:(unsigned)index
{
  id object;

  object = [dataSource createObject];
  if(object == nil)
    {
      if(delegateRespondsTo.createObjectFailed == YES)
	[delegate displayGroup:self
		  createObjectFailedForDataSource:dataSource];

      return nil;
    }

  [object takeValuesFromDictionary:[self insertedObjectDefaultValues]];

  [self insertObject:object atIndex:index];

  return object;
}

//--------------------------------------------------------------------
//	lastQualifierFromInputValues

-(EOQualifier*)lastQualifierFromInputValues
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	localKeys

- (NSArray *)localKeys
{
  return localKeys;
}

//--------------------------------------------------------------------
//	masterObject

- (id)masterObject
{
  if([self hasDetailDataSource] == YES)
    return [(EODetailDataSource *)dataSource masterObject];

  return nil;
}

//--------------------------------------------------------------------
//	numberOfObjectsPerBatch

- (unsigned)numberOfObjectsPerBatch
{
  return numberOfObjectsPerBatch;
}

//--------------------------------------------------------------------
//	qualifier

- (EOQualifier *)qualifier
{
  return qualifier;
}

//--------------------------------------------------------------------
//	qualifierFromInputValues

-(EOQualifier*)qualifierFromInputValues
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	qualifierFromQueryValues

- (EOQualifier *)qualifierFromQueryValues
{
  NSMutableArray *array;
  NSEnumerator *enumerator;
  NSString *key, *op;
  SEL operatorSelector;

  array = [NSMutableArray arrayWithCapacity:8];

  enumerator = [queryMatch keyEnumerator];
  while((key = [enumerator nextObject]))
    {
      op = [queryOperator objectForKey:key];

      if(op == nil)
	operatorSelector = EOQualifierOperatorEqual;
      else
	operatorSelector = [EOQualifier operatorSelectorForString:op];

      [array addObject:[[[EOKeyValueQualifier alloc]
			  initWithKey:key
			  operatorSelector:operatorSelector
			  value:[queryMatch objectForKey:key]] autorelease]];
    }

  enumerator = [queryMax keyEnumerator];
  while((key = [enumerator nextObject]))
    {
      [array addObject:[[[EOKeyValueQualifier alloc]
			  initWithKey:key
			  operatorSelector:EOQualifierOperatorLessThan
			  value:[queryMax objectForKey:key]] autorelease]];
    }

  enumerator = [queryMin keyEnumerator];
  while((key = [enumerator nextObject]))
    {
      [array addObject:[[[EOKeyValueQualifier alloc]
			  initWithKey:key
			  operatorSelector:EOQualifierOperatorGreaterThan
			  value:[queryMin objectForKey:key]] autorelease]];
    }

  return [[[EOAndQualifier alloc] initWithQualifierArray:array] autorelease];
}

//--------------------------------------------------------------------
//	qualifyDataSource

- (void)qualifyDataSource
{
  [dataSource setQualifier:[self qualifierFromQueryValues]];

  flags.queryMode = NO;
  [self fetch];

    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	qualifyDisplayGroup

- (void)qualifyDisplayGroup
{
  [self setQualifier:[self qualifierFromQueryValues]];

  [self updateDisplayedObjects];
  flags.queryMode = NO;
}

//--------------------------------------------------------------------
//	queryBindings

- (NSMutableDictionary *)queryBindings
{
  return queryBindings;
}

//--------------------------------------------------------------------
//	queryMatch

- (NSMutableDictionary *)queryMatch
{
  return queryMatch;
}

//--------------------------------------------------------------------
//	queryMax

- (NSMutableDictionary *)queryMax
{
  return queryMax;
}

//--------------------------------------------------------------------
//	queryMin

- (NSMutableDictionary *)queryMin
{
  return queryMin;
}

//--------------------------------------------------------------------
//	queryOperator

- (NSMutableDictionary *)queryOperator
{
  return queryOperator;
}

//--------------------------------------------------------------------
//	redisplay

-(void)redisplay
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	relationalQualifierOperators

- (NSArray *)relationalQualifierOperators
{
  return [EOQualifier relationalQualifierOperators];
}

//--------------------------------------------------------------------
//	secondObjectForQualifier

-(NSMutableDictionary*)secondObjectForQualifier
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	selectedObject

- (id)selectedObject
{
  if([selectedObjects count])
    return [selectedObjects objectAtIndex:0];

  return nil;
}

//--------------------------------------------------------------------
//	selectedObjects

- (NSArray *)selectedObjects
{
  return selectedObjects;
}

//--------------------------------------------------------------------
//	selectionIndexes

- (NSArray *)selectionIndexes
{
  return selection;
}

//--------------------------------------------------------------------
//	selectNext

- (id)selectNext
{
  unsigned index;
  id obj;

  if(![allObjects count])
    return nil;

  if(![selectedObjects count])
    [self setSelectionIndexes:
	    [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:0]]];
  else
    {
      obj = [selectedObjects objectAtIndex:0];

      if([obj isEqual:[displayedObjects lastObject]] == YES)
	{
	  index = [allObjects indexOfObject:[displayedObjects
					      objectAtIndex:0]];

	  [self setSelectionIndexes:
		  [NSArray arrayWithObject:
			     [NSNumber numberWithUnsignedInt:index]]];
	}
      else
	{
	  index = [allObjects indexOfObject:obj]+1;

	  if(index >= [allObjects count])
	    index = 0;

	  [self setSelectionIndexes:
		  [NSArray arrayWithObject:
			     [NSNumber numberWithUnsignedInt:index]]];
	}
    }

  return nil;
}

//--------------------------------------------------------------------
//	selectObject:

- (BOOL)selectObject:(id)object
{
  if([allObjects containsObject:object] == NO)
    return NO;

  return [self setSelectionIndexes:
		 [NSArray arrayWithObject:
			    [NSNumber numberWithUnsignedInt:
					[allObjects
					  indexOfObject:object]]]];
}

//--------------------------------------------------------------------
//	selectObjectsIdenticalTo:

- (BOOL)selectObjectsIdenticalTo:(NSArray *)objects
{
  NSMutableArray *array;
  NSEnumerator *objsEnum, *dispEnum;
  id object, dispObj;

  array = [NSMutableArray arrayWithCapacity:8];

  objsEnum = [objects objectEnumerator];
  while((object = [objsEnum nextObject]))
    {
      dispEnum = [displayedObjects objectEnumerator];
      while((dispObj = [dispEnum nextObject]))
	{
	  if(dispObj == object)
	    {
	      [array addObject:[NSNumber numberWithUnsignedInt:
					   [allObjects indexOfObject:object]]];
	      break;
	    }
	}

      if(dispObj == nil)
	{
	  [array removeAllObjects];
	  break;
	}
    }

  return [self setSelectionIndexes:array];
}

//--------------------------------------------------------------------
//	selectObjectsIdenticalTo:selectFirstOnNoMatch:

- (BOOL)selectObjectsIdenticalTo:(NSArray *)objects
	    selectFirstOnNoMatch:(BOOL)flag
{
  unsigned index;

  if([self selectObjectsIdenticalTo:objects] == NO && flag == YES)
    {
      if(![selectedObjects count] &&
	 [displayedObjects count])
	{
	  index = [allObjects indexOfObject:[displayedObjects
					      objectAtIndex:0]];
	  [self setSelectionIndexes:
		  [NSArray arrayWithObject:[NSNumber
					     numberWithUnsignedInt:index]]];

	  return YES;
	}

      return NO;
    }

  return YES;
}

//--------------------------------------------------------------------
//	selectPrevious

- (id)selectPrevious
{
  unsigned index;
  id obj;

  if(![allObjects count])
    return nil;

  if(![selectedObjects count])
    [self setSelectionIndexes:
	    [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:0]]];
  else
    {
      obj = [selectedObjects objectAtIndex:0];

      if([obj isEqual:[displayedObjects objectAtIndex:0]] == YES)
	{
	  index = [allObjects indexOfObject:[displayedObjects lastObject]];

	  [self setSelectionIndexes:
		  [NSArray arrayWithObject:
			     [NSNumber numberWithUnsignedInt:index]]];
	}
      else
	{
	  index = [allObjects indexOfObject:obj]-1;

	  if(!index || index >= [allObjects count])
	    index = [allObjects count] - 1;

	  [self setSelectionIndexes:
		  [NSArray arrayWithObject:
			     [NSNumber numberWithUnsignedInt:index]]];
	}
    }

  return nil;
}

//--------------------------------------------------------------------
//	selectsFirstObjectAfterFetch

- (BOOL)selectsFirstObjectAfterFetch
{
  return flags.selectFirstObject;
}

//--------------------------------------------------------------------
//	setBuildsQualifierFromInput:

- (void)setBuildsQualifierFromInput:(BOOL)flag
{
    LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	setCurrentBatchIndex:

- (void)setCurrentBatchIndex:(unsigned)index_
{
  unsigned batchCount, num;
  int i;

  if(!index_)
    return;

  [displayedObjects removeAllObjects];

  batchCount = [self batchCount];
  if(index_ > batchCount)
    index_ = 1;

  if(!numberOfObjectsPerBatch)
    num = [allObjects count];
  else
    num = numberOfObjectsPerBatch;

  if(!num)
    return;

  for( i = (index_-1) * num;
       i < index_ * num;
       i++)
    [displayedObjects addObject:[allObjects objectAtIndex:i]];

  if(flags.selectFirstObject == YES && [selection count])
    [self setSelectionIndexes:
	    [NSArray arrayWithObject:
		       [NSNumber numberWithUnsignedInt:
				   [allObjects
				     indexOfObject:
				       [displayedObjects objectAtIndex:0]]]]];
}


//--------------------------------------------------------------------
//	setDefaultStringMatchFormat:

- (void)setDefaultStringMatchFormat:(NSString *)format
{
  ASSIGN(defaultStringMatchFormat, format);
}

//--------------------------------------------------------------------
//	setDefaultStringMatchOperator:

- (void)setDefaultStringMatchOperator:(NSString *)operator
{
  ASSIGN(defaultStringMatchOperator, operator);
}


//--------------------------------------------------------------------
//	setDetailKey:

- (void)setDetailKey:(NSString *)detailKey
{
  EODetailDataSource *source;

  if([self hasDetailDataSource] == YES)
    {
      source = (EODetailDataSource *)dataSource;
      [source qualifyWithRelationshipKey:detailKey
	      ofObject:[source masterObject]];
    }
}

//--------------------------------------------------------------------
//	setFetchesOnLoad:

- (void)setFetchesOnLoad:(BOOL)flag
{
  flags.autoFetch = flag;
}

//--------------------------------------------------------------------
//	setInQueryMode:

- (void)setInQueryMode:(BOOL)flag
{
  flags.queryMode = flag;
}

//--------------------------------------------------------------------
//	setInsertedObjectDefaultValues:

- (void)setInsertedObjectDefaultValues:(NSDictionary *)defaultValues
{
  ASSIGN(insertedObjectDefaultValues, defaultValues);
}

//--------------------------------------------------------------------
//	setLocalKeys:

- (void)setLocalKeys:(NSArray *)keys
{
  ASSIGN(localKeys, keys);
}

//--------------------------------------------------------------------
//	setMasterObject:

- (void)setMasterObject:(id)masterObject
{
  EODetailDataSource *source;

  if([self hasDetailDataSource] == YES)
    {
      source = (EODetailDataSource *)dataSource;
      [dataSource qualifyWithRelationshipKey:[source detailKey]
		  ofObject:masterObject];
    }
}

//--------------------------------------------------------------------
//	setNumberOfObjectsPerBatch:

- (void)setNumberOfObjectsPerBatch:(unsigned)count
{
  numberOfObjectsPerBatch = count;
}

//--------------------------------------------------------------------
//	setObjectArray:

- (void)setObjectArray:(NSArray *)objects
{
  [allObjects removeAllObjects];
  [allObjects addObjectsFromArray:objects];

  [self updateDisplayedObjects];

  // TODO selection
}

//--------------------------------------------------------------------
//	setQualifier:

- (void)setQualifier:(EOQualifier *)qualifier_
{
  ASSIGN(qualifier, qualifier_);
}

//--------------------------------------------------------------------
//	setSelectedObject:

- (void)setSelectedObject:(id)object
{
  [self selectObject:object];
}

//--------------------------------------------------------------------
//	setSelectionIndexes:

- (BOOL)setSelectionIndexes:(NSArray *)selection_
{
  NSEnumerator *objsEnum;
  NSNumber *number;

  if(delegateRespondsTo.shouldChangeSelection == YES)
    if([delegate displayGroup:self
		 shouldChangeSelectionToIndexes:selection_] == NO)
      return NO;

  objsEnum = [selection_ objectEnumerator];
  while((number = [objsEnum nextObject]))
    {
      NS_DURING
	[allObjects objectAtIndex:[number unsignedIntValue]];
      NS_HANDLER
	return NO;
      NS_ENDHANDLER;
    }

  [selectedObjects removeAllObjects];

  objsEnum = [selection_ objectEnumerator];
  while((number = [objsEnum nextObject]))
    {
      [selectedObjects
	addObject:[allObjects objectAtIndex:[number unsignedIntValue]]];
    }

  ASSIGN(selection, selection_);

  if(delegateRespondsTo.didChangeSelection == YES)
    [delegate displayGroupDidChangeSelection:self];

  if(delegateRespondsTo.didChangeSelectedObjects == YES)
    [delegate displayGroupDidChangeSelectedObjects:self];

  return YES;
}

//--------------------------------------------------------------------
//	setSelectsFirstObjectAfterFetch:

- (void)setSelectsFirstObjectAfterFetch:(BOOL)flag
{
  flags.selectFirstObject = flag;
}

//--------------------------------------------------------------------
//	setSortOrdering:

- (void)setSortOrdering:(NSArray *)orderings
{
  ASSIGN(sortOrdering, orderings);
}

//--------------------------------------------------------------------
//	setValidatesChangesImmediately:

- (void)setValidatesChangesImmediately:(BOOL)flag
{
  flags.validateImmediately = flag;
}

//--------------------------------------------------------------------
//	sortOrdering

- (NSArray *)sortOrdering
{
  return sortOrdering;
}

//--------------------------------------------------------------------
//	updateDisplayedObjects

- (void)updateDisplayedObjects
{
  NSEnumerator *objsEnum;
  id object;

  [displayedObjects removeAllObjects];

  if(delegateRespondsTo.displayArrayForObjects == YES)
    {
      [displayedObjects
	addObjectsFromArray:[delegate displayGroup:self
				      displayArrayForObjects:allObjects]];

      return;
    }

  if(qualifier)
    {
      objsEnum = [allObjects objectEnumerator];
      while((object = [objsEnum nextObject]))
	{
	  if([qualifier evaluateWithObject:object] == YES)
	    [displayedObjects addObject:object];
	}
    }
  else
    {
      batchIndex = [self batchCount];
      [self displayNextBatch];
    }

  if(sortOrdering)
    [displayedObjects sortUsingKeyOrderArray:sortOrdering];
}

//--------------------------------------------------------------------
//	validatesChangesImmediately

- (BOOL)validatesChangesImmediately
{
  return flags.validateImmediately;
}

- (id)initWithCoder:(NSCoder *)coder
{
  [self notImplemented:_cmd];
  return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [self notImplemented:_cmd];
}

#endif

@end
