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

#if GDL2 // GDL2 implementation

//--------------------------------------------------------------------
//	init

- init
{
  if ((self = [super init]))
    {
      _allObjects = [[NSMutableArray alloc] initWithCapacity:16];
      _displayedObjects = [[NSMutableArray alloc] initWithCapacity:16];
      _selectedObjects = [[NSMutableArray alloc] initWithCapacity:8];

      _queryMatch    = [[NSMutableDictionary alloc] initWithCapacity:8];
      _queryMin      = [[NSMutableDictionary alloc] initWithCapacity:8];
      _queryMax      = [[NSMutableDictionary alloc] initWithCapacity:8];
      _queryOperator = [[NSMutableDictionary alloc] initWithCapacity:8];

      _queryBindings = [[NSMutableDictionary alloc] initWithCapacity:8];

      //  _selection = 1; //????

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

      //_selection=NSArray * object:0xf78b80 Description:()
      //_insertedObjectDefaultValues=NSDictionary * object:0xf78b60 Description:{}
      ASSIGN(_defaultStringMatchOperator,@"caseInsensitiveLike");
      ASSIGN(_defaultStringMatchFormat,@"%@");

      [self setSelectsFirstObjectAfterFetch:YES];
    };
  return self;
};

-(id)initWithKeyValueUnarchiver:(EOKeyValueUnarchiver*)unarchiver
{
/*
Description: <EOKeyValueUnarchiver: 0x1a84d20>
																						--[1] Dumping object 0x1a84d20 of Class EOKeyValueUnarchiver
																					_propertyList=NSDictionary * object:0x1057850 Description:{
    class = WODisplayGroup; 
    dataSource = {
        class = EODatabaseDataSource; 
        editingContext = session.defaultEditingContext; 
        fetchSpecification = {class = EOFetchSpecification; entityName = MovieMedia; isDeep = YES; }; 
    }; 
    formatForLikeQualifier = "%@*"; 
    _numberOfObjectsPerBatch = 10; 
    selectsFirstObjectAfterFetch = YES; 
}
																					_parent=id object:0x0 Description:*nil*
																					_nextParent=id object:0x0 Description:*nil*
																					_allUnarchivedObjects=NSMutableArray * object:0x1a85920 Description:()
																					_delegate=id object:0x1a84ff0 Description:<WOBundleUnarchiverDelegate: 0x1a84ff0>
																					_awakenedObjects=struct ? {...} * PTR
																					isa=Class Class:EOKeyValueUnarchiver

*/
  if ((self=[self init]))
    {
      LOGObjectFnStop();
      [self setNumberOfObjectsPerBatch:
              [unarchiver decodeIntForKey:@"numberOfObjectsPerBatch"]];
      [self setFetchesOnLoad:
              [unarchiver decodeBoolForKey:@"fetchesOnLoad"]];
      [self setValidatesChangesImmediately:
              [unarchiver decodeBoolForKey:@"validatesChangesImmediately"]];
      [self setSelectsFirstObjectAfterFetch:
              [unarchiver decodeBoolForKey:@"selectsFirstObjectAfterFetch"]];
      [self setLocalKeys:
              [unarchiver decodeObjectForKey:@"localKeys"]];
      //Don't call setDataSource: because we're not ready !
      ASSIGN(_dataSource,[unarchiver decodeObjectForKey:@"dataSource"]);        
      [self setSortOrderings:
              [unarchiver decodeObjectForKey:@"sortOrderings"]];
      [self setQualifier:
              [unarchiver decodeObjectForKey:@"qualifier"]];
      [self setDefaultStringMatchFormat:
              [unarchiver decodeObjectForKey:@"formatForLikeQualifier"]];
      [self setInsertedObjectDefaultValues:
              [unarchiver decodeObjectForKey:@"insertedObjectDefaultValues"]];

      [self finishInitialization];
      LOGObjectFnStop();
    };
  return self;
};


-(void)awakeFromKeyValueUnarchiver:(EOKeyValueUnarchiver*)unarchiver
{
  LOGObjectFnStart();
  if (_dataSource)
    [unarchiver ensureObjectAwake:_dataSource];
  if ([self fetchesOnLoad])
    {
//      [self fetch];//?? NO: fetch "each time it is loaded in web browser"
    };
  LOGObjectFnStop();
};


-(void)finishInitialization
{
  LOGObjectFnStart();
  [self _setUpForNewDataSource];
  //Finished ?
  LOGObjectFnStop();
};

-(void)_setUpForNewDataSource
{
  LOGObjectFnStart();
  // call [_dataSource editingContext];
  //Finished ?
  LOGObjectFnStop();
};
	
-(void)encodeWithKeyValueArchiver:(id)object_
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};

-(void)_presentAlertWithTitle:(id)title
                      message:(id)msg
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};

-(void)_addQualifiersToArray:(id)array_
                   forValues:(id)values_
            operatorSelector:(SEL)selector_
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};

-(id)_qualifierForKey:(id)key
                value:(id)value
     operatorSelector:(SEL)selector_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

-(BOOL)_deleteObjectsAtIndexes:(id)indexes_
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return NO;
};


-(BOOL)_deleteObject:(id)object_
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return NO;
};

-(int)_selectionIndex
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return 0;
};


-(void)_lastObserverNotified:(id)object_
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};


-(void)_beginObserverNotification:(id)object_
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};

-(void)_notifySelectionChanged
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};



-(void)_notifyRowChanged:(int)row_
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};



-(id)_notify:(SEL)selector_
        with:(id)object1
        with:(id)object2

{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;
};


-(id)_notify:(SEL)selector_
        with:(id)object_
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;
};


-(id)undoManager
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;
};

-(void)objectsInvalidatedInEditingContext:(id)object_
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};


-(void)objectsChangedInEditingContext:(id)object_
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};


-(void)_changedInEditingContext:(NSNotification *)notification
{
  BOOL redisplay = YES;
  LOGObjectFnStart();

  if(_delegateRespondsTo.shouldRedisplay == YES)
    redisplay = [self displayGroup:self
		      shouldRedisplayForEditingContextChangeNotification:notification];

  if(redisplay == YES)
    [self redisplay];
  LOGObjectFnStop();
}

-(void)_invalidatedAllObjectsInStore:(NSNotification *)notification
{
  BOOL refetch = YES;
  LOGObjectFnStart();

  if(_delegateRespondsTo.shouldRefetchObjects == YES)
    refetch = [self displayGroup:self
		    shouldRefetchForInvalidatedAllObjectsNotification:
		      notification];

  if(refetch == YES)
    [self fetch];
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  delegate = nil;

  DESTROY(_dataSource);

  DESTROY(_allObjects);
  DESTROY(_displayedObjects);
  DESTROY(_selection);
  DESTROY(_selectedObjects);
  DESTROY(_sortOrdering);
  DESTROY(_qualifier);
  DESTROY(_localKeys);

  DESTROY(_insertedObjectDefaultValues);
  DESTROY(_savedAllObjects);

  DESTROY(_queryMatch);
  DESTROY(_queryMin);
  DESTROY(_queryMax);
  DESTROY(_queryOperator);

  DESTROY(_defaultStringMatchOperator);
  DESTROY(_defaultStringMatchFormat);

  DESTROY(_queryBindings);

  [super dealloc];
}

//--------------------------------------------------------------------
//	allObjects

- (NSArray *)allObjects
{
  return _allObjects;
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
  unsigned batchCount=0;
  unsigned count=0;
  LOGObjectFnStart();

  if(!_numberOfObjectsPerBatch)
    batchCount=1;
  else
    {
      count = [_allObjects count];
      if(!count)
        batchCount=1;
      else
        batchCount=(count / _numberOfObjectsPerBatch) +
          (count % _numberOfObjectsPerBatch ? 1 : 0);
    };
  LOGObjectFnStop();
  return batchCount;
}

//--------------------------------------------------------------------
//	buildsQualifierFromInput

-(BOOL)buildsQualifierFromInput
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return NO;
};

//--------------------------------------------------------------------
//	clearSelection

- (BOOL)clearSelection
{
  BOOL result=NO;
  LOGObjectFnStart();
  result=[self setSelectionIndexes:[NSArray array]];
  LOGObjectFnStop();
  return result;
}

//--------------------------------------------------------------------
//	currentBatchIndex

- (unsigned)currentBatchIndex
{
  return _batchIndex;
}

//--------------------------------------------------------------------
//	dataSource

- (EODataSource *)dataSource
{
  return _dataSource;
}

//--------------------------------------------------------------------
//	setDataSource:

- (void)setDataSource:(EODataSource *)dataSource_
{
  EOEditingContext *context=nil;
  LOGObjectFnStart();

  if(_dataSource)
    {
      context = [_dataSource editingContext];
      [context removeEditor:self];
      if([self isEqual:[context messageHandler]] == YES)
	[context setMessageHandler:nil];
    }

  ASSIGN(_dataSource, dataSource_);

  context = [_dataSource editingContext];
  [context addEditor:self];
  if([context messageHandler] == nil)
    [context setMessageHandler:self];

  [_displayedObjects removeAllObjects];

  if(_delegateRespondsTo.didChangeDataSource == YES)
    [delegate displayGroupDidChangeDataSource:self];
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	defaultStringMatchFormat

- (NSString *)defaultStringMatchFormat
{
  return _defaultStringMatchFormat;
}

//--------------------------------------------------------------------
//	defaultStringMatchOperator

- (NSString *)defaultStringMatchOperator
{
  return _defaultStringMatchOperator;
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
  LOGObjectFnStart();
  delegate = delegate_;

  _delegateRespondsTo.createObjectFailed = 
    [delegate respondsToSelector:@selector(displayGroup:createObjectFailedForDataSource:)];
  _delegateRespondsTo.didDeleteObject = 
    [delegate respondsToSelector:@selector(displayGroup:didDeleteObject:)];
  _delegateRespondsTo.didFetchObjects = 
    [delegate respondsToSelector:@selector(displayGroup:didFetchObjects:)];
  _delegateRespondsTo.didInsertObject = 
    [delegate respondsToSelector:@selector(displayGroup:didInsertObject:)];
  _delegateRespondsTo.didSetValueForObject = 
    [delegate respondsToSelector:@selector(displayGroup:didSetValue:forObject:key:)];
  _delegateRespondsTo.displayArrayForObjects = 
    [delegate respondsToSelector:@selector(displayGroup:displayArrayForObjects:)];
  _delegateRespondsTo.shouldChangeSelection = 
    [delegate respondsToSelector:@selector(displayGroup:shouldChangeSelectionToIndexes:)];
  _delegateRespondsTo.shouldInsertObject = 
    [delegate respondsToSelector:@selector(displayGroup:shouldInsertObject:atIndex:)];
  _delegateRespondsTo.shouldDeleteObject = 
    [delegate respondsToSelector:@selector(displayGroup:shouldDeleteObject:)];
  _delegateRespondsTo.shouldRedisplay = 
    [delegate respondsToSelector:@selector(displayGroup:shouldRedisplayForEditingContextChangeNotification:)];
  _delegateRespondsTo.shouldRefetchObjects = 
    [delegate respondsToSelector:@selector(displayGroup:shouldRefetchForInvalidatedAllObjectsNotification:)];
  _delegateRespondsTo.didChangeDataSource = 
    [delegate respondsToSelector:@selector(displayGroupDidChangeDataSource:)];
  _delegateRespondsTo.didChangeSelectedObjects = 
    [delegate respondsToSelector:@selector(displayGroupDidChangeSelectedObjects:)];
  _delegateRespondsTo.didChangeSelection = 
    [delegate respondsToSelector:@selector(displayGroupDidChangeSelection:)];
  _delegateRespondsTo.shouldFetchObjects = 
    [delegate respondsToSelector:@selector(displayGroupShouldFetch:)];
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	delete

- (id)delete
{
  LOGObjectFnStart();
  [self deleteSelection];
  LOGObjectFnStop();
  return nil;//FIXME
}

//--------------------------------------------------------------------
//	deleteObjectAtIndex:

- (BOOL)deleteObjectAtIndex:(unsigned)index
{
  BOOL delete = YES;
  id object=nil;
  LOGObjectFnStart();

  object = [_allObjects objectAtIndex:index];

  if(_delegateRespondsTo.shouldDeleteObject == YES)
    delete = [delegate displayGroup:self
		       shouldDeleteObject:object];

  if(delete)
    {
      [_dataSource deleteObject:object];
      
      if(_delegateRespondsTo.didDeleteObject == YES)
        [delegate displayGroup:self
                  didDeleteObject:object];
    };
  LOGObjectFnStop();
  return delete;
}

//--------------------------------------------------------------------
//	deleteSelection

- (BOOL)deleteSelection
{
  BOOL result=YES;
  BOOL delete = YES;
  NSEnumerator *enumerator=nil;
  id object=nil;
  LOGObjectFnStart();

  enumerator = [_selectedObjects objectEnumerator];
  while((object = [enumerator nextObject]))
    {
      if(_delegateRespondsTo.shouldDeleteObject == YES)
	delete = [delegate displayGroup:self
			   shouldDeleteObject:object];

      if(delete == NO)
	result=NO;
    }
  if (result)
    {
      enumerator = [_selectedObjects objectEnumerator];
      while((object = [enumerator nextObject]))
        {
          [_dataSource deleteObject:object];
          
          if(_delegateRespondsTo.didDeleteObject == YES)
            [delegate displayGroup:self
                      didDeleteObject:object];
        }
    };

  LOGObjectFnStop();
  return result;
}

//--------------------------------------------------------------------
//	detailKey

- (NSString *)detailKey
{
  NSString* detailKey=nil;
  LOGObjectFnStart();

  if([self hasDetailDataSource] == YES)
    detailKey= [(EODetailDataSource *)_dataSource detailKey];

  LOGObjectFnStop();
  return detailKey;
}

//--------------------------------------------------------------------
//	displayBatchContainingSelectedObject

-(id)displayBatchContainingSelectedObject
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;
};

//--------------------------------------------------------------------
//	displayedObjects

- (NSArray *)displayedObjects
{
  return _displayedObjects;
}

//--------------------------------------------------------------------
//	displayNextBatch

- (id)displayNextBatch
{
  int count = [_allObjects count];
  NSRange range;
  LOGObjectFnStart();

  [_displayedObjects removeAllObjects];

  if(!_numberOfObjectsPerBatch || count <= _numberOfObjectsPerBatch)
    {
      _batchIndex = 1;
      [_displayedObjects addObjectsFromArray:_allObjects];
    }
  else
    {
      if(_batchIndex >= [self batchCount])
	{
	  _batchIndex = 1;
	  range.location = 0;
	  range.length = _numberOfObjectsPerBatch;
	}
      else
	{
	  range.location = _batchIndex * _numberOfObjectsPerBatch;
	  range.length = (range.location + _numberOfObjectsPerBatch > count ?
			  count - range.location : _numberOfObjectsPerBatch);
	  _batchIndex++;
	}

      [_displayedObjects addObjectsFromArray:[_allObjects
					      subarrayWithRange:range]];
    }

  [self clearSelection];

  LOGObjectFnStop();
  return nil;//FIXME
}

//--------------------------------------------------------------------
//	displayPreviousBatch

- (id)displayPreviousBatch
{
  int count = [_allObjects count];
  NSRange range;
  LOGObjectFnStart();

  [_displayedObjects removeAllObjects];

  if(!_numberOfObjectsPerBatch || count <= _numberOfObjectsPerBatch)
    {
      _batchIndex = 1;
      [_displayedObjects addObjectsFromArray:_allObjects];
    }
  else
    {
      if(_batchIndex == 1)
	{
	  _batchIndex = [self batchCount];
	  range.location = (_batchIndex-1) * _numberOfObjectsPerBatch;

	  range.length = (range.location + _numberOfObjectsPerBatch > count ?
			  count - range.location : _numberOfObjectsPerBatch);
	}
      else
	{
	  _batchIndex--;
	  range.location = (_batchIndex-1) *  _numberOfObjectsPerBatch;
	  range.length = _numberOfObjectsPerBatch;
	}

      [_displayedObjects addObjectsFromArray:[_allObjects
					      subarrayWithRange:range]];
    }

  [self clearSelection];

  LOGObjectFnStop();
  return nil;//FIXME
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
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;
};

//--------------------------------------------------------------------
//	fetch

- (id)fetch
{
  BOOL fetch = YES;
  LOGObjectFnStart();

  if(_delegateRespondsTo.shouldFetchObjects == YES)
    fetch = [delegate displayGroupShouldFetch:self];
  NSDebugMLog(@"fetch=%d",(int)fetch);

  if(fetch)
    {
      NSArray* objects=nil;
      NSDebugMLog(@"_dataSource=%@",_dataSource);
      objects=[_dataSource fetchObjects];
      NSDebugMLog(@"objects=%@",objects);
      [self setObjectArray:objects];

      if(_delegateRespondsTo.didFetchObjects == YES)
        [delegate displayGroup:self
                  didFetchObjects:_allObjects];
    };
  LOGObjectFnStop();
  return nil;//FIXME
}

//--------------------------------------------------------------------
//	fetchesOnLoad

- (BOOL)fetchesOnLoad
{
  return _flags.autoFetch;
}

//--------------------------------------------------------------------
//	hasDetailDataSource

- (BOOL)hasDetailDataSource
{
  return [_dataSource isKindOfClass:[EODetailDataSource class]];
}

//--------------------------------------------------------------------
//	hasMultipleBatches

- (BOOL)hasMultipleBatches
{
  return !_flags.fetchAll;
}

//--------------------------------------------------------------------
//	inputObjectForQualifier

-(NSMutableDictionary*)inputObjectForQualifier
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;
};

//--------------------------------------------------------------------
//	indexOfFirstDisplayedObject;

- (unsigned)indexOfFirstDisplayedObject
{
  int indexOfFirstDisplayedObject=0;
  int batch = 0;
  LOGObjectFnStart();

  batch=[self currentBatchIndex];
  indexOfFirstDisplayedObject=((batch-1) * _numberOfObjectsPerBatch);

  LOGObjectFnStop();
  return indexOfFirstDisplayedObject;
}

//--------------------------------------------------------------------
//	indexOfLastDisplayedObject;

- (unsigned)indexOfLastDisplayedObject
{
  int indexOfLastDisplayedObject=0;
  int batch = 0;
  LOGObjectFnStart();
  batch=[self currentBatchIndex];

  indexOfLastDisplayedObject=((batch-1) * _numberOfObjectsPerBatch) + [_displayedObjects count];
  LOGObjectFnStop();
  return indexOfLastDisplayedObject;
}

//--------------------------------------------------------------------
//	inQueryMode

- (BOOL)inQueryMode
{
  return _flags.queryMode;
}

//--------------------------------------------------------------------
-(void)editingContext:(id)editingContext_
  presentErrorMessage:(id)msg
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	insert

- (id)insert
{
  unsigned index=0, count=0;
  LOGObjectFnStart();
  count = [_allObjects count];

  if([_selection count])
    index = [[_selection objectAtIndex:0] unsignedIntValue]+1;

  if(!count)
    index = 0;
  if(count <= index)
    index = count - 1;

  [self insertObjectAtIndex:index];

  LOGObjectFnStop();
  return nil;//FIXME
}

//--------------------------------------------------------------------
//	insertedObjectDefaultValues

- (NSDictionary *)insertedObjectDefaultValues
{
  return _insertedObjectDefaultValues;
}

//--------------------------------------------------------------------
//	insertObject:atIndex:

- (void)insertObject:anObject
	     atIndex:(unsigned)index
{
  BOOL insert = YES;
  LOGObjectFnStart();
  if(_delegateRespondsTo.shouldInsertObject == YES)
    insert = [delegate displayGroup:self
		       shouldInsertObject:anObject
		       atIndex:index];

  if(insert)
    {
      [_dataSource insertObject:anObject];
      
      [_allObjects insertObject:anObject atIndex:index];
      [self setCurrentBatchIndex:_batchIndex];
      
      if(_delegateRespondsTo.didInsertObject == YES)
        [delegate displayGroup:self
                  didInsertObject:anObject];

      [self setSelectionIndexes:
              [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:index]]];
    };
}

//--------------------------------------------------------------------
//	insertObjectAtIndex:

- (id)insertObjectAtIndex:(unsigned)index
{
  id object=nil;
  LOGObjectFnStart();

  object = [_dataSource createObject];
  if(object == nil)
    {
      if(_delegateRespondsTo.createObjectFailed == YES)
	[delegate displayGroup:self
		  createObjectFailedForDataSource:_dataSource];
    }
  else
    {
      [object takeValuesFromDictionary:[self _insertedObjectDefaultValues]];
      [self insertObject:object atIndex:index];
    };
  LOGObjectFnStop();
  return object;
}

//--------------------------------------------------------------------
//	lastQualifierFromInputValues

-(EOQualifier*)lastQualifierFromInputValues
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;
};

//--------------------------------------------------------------------
//	localKeys

- (NSArray *)localKeys
{
  return _localKeys;
}

-(BOOL)usesOptimisticRefresh
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return NO;
};



-(void)setUsesOptimisticRefresh:(id)object_
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};

-(void)awakeFromNib
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};


//--------------------------------------------------------------------
//	masterObject

- (id)masterObject
{
  id obj=nil;
  LOGObjectFnStart();

  if([self hasDetailDataSource] == YES)
    obj=[(EODetailDataSource *)_dataSource masterObject];

  LOGObjectFnStop();
  return obj;
}

//--------------------------------------------------------------------
//	numberOfObjectsPerBatch

- (unsigned)numberOfObjectsPerBatch
{
  return _numberOfObjectsPerBatch;
}

//--------------------------------------------------------------------
//	qualifier

- (EOQualifier *)qualifier
{
  return _qualifier;
}

//--------------------------------------------------------------------
//	qualifierFromInputValues

-(EOQualifier*)qualifierFromInputValues
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;
};

//--------------------------------------------------------------------
//	qualifierFromQueryValues

- (EOQualifier *)qualifierFromQueryValues
{
  EOQualifier* resultQualifier=nil;
  NSMutableArray *array=nil;
  NSEnumerator *enumerator=nil;
  NSString *key=nil;
  NSString *op=nil;
  SEL operatorSelector=nil;
  LOGObjectFnStart();

  array = [NSMutableArray arrayWithCapacity:8];

  enumerator = [_queryMatch keyEnumerator];
  while((key = [enumerator nextObject]))
    {
      op = [_queryOperator objectForKey:key];

      if(op == nil)
	operatorSelector = EOQualifierOperatorEqual;
      else
	operatorSelector = [EOQualifier operatorSelectorForString:op];

      [array addObject:[[[EOKeyValueQualifier alloc]
			  initWithKey:key
			  operatorSelector:operatorSelector
			  value:[_queryMatch objectForKey:key]] autorelease]];
    }

  enumerator = [_queryMax keyEnumerator];
  while((key = [enumerator nextObject]))
    {
      [array addObject:[[[EOKeyValueQualifier alloc]
			  initWithKey:key
			  operatorSelector:EOQualifierOperatorLessThan
			  value:[_queryMax objectForKey:key]] autorelease]];
    }

  enumerator = [_queryMin keyEnumerator];
  while((key = [enumerator nextObject]))
    {
      [array addObject:[[[EOKeyValueQualifier alloc]
			  initWithKey:key
			  operatorSelector:EOQualifierOperatorGreaterThan
			  value:[_queryMin objectForKey:key]] autorelease]];
    }
  resultQualifier=[[[EOAndQualifier alloc] initWithQualifierArray:array] autorelease];
  LOGObjectFnStop();
  return resultQualifier;
}

//--------------------------------------------------------------------
//	qualifyDataSource

- (void)qualifyDataSource
{
  LOGObjectFnStart();
  [_dataSource setQualifier:[self qualifierFromQueryValues]];

  _flags.queryMode = NO;
  [self fetch];

  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	qualifyDisplayGroup

- (void)qualifyDisplayGroup
{
  LOGObjectFnStart();
  [self setQualifier:[self qualifierFromQueryValues]];

  [self updateDisplayedObjects];
  _flags.queryMode = NO;
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	queryBindings

- (NSMutableDictionary *)queryBindings
{
  return _queryBindings;
}

//--------------------------------------------------------------------
//	queryMatch

- (NSMutableDictionary *)queryMatch
{
  return _queryMatch;
}

//--------------------------------------------------------------------
//	queryMax

- (NSMutableDictionary *)queryMax
{
  return _queryMax;
}

//--------------------------------------------------------------------
//	queryMin

- (NSMutableDictionary *)queryMin
{
  return _queryMin;
}

//--------------------------------------------------------------------
//	queryOperator

- (NSMutableDictionary *)queryOperator
{
  return _queryOperator;
}

//--------------------------------------------------------------------
//	redisplay

-(void)redisplay
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
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
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;
};

//--------------------------------------------------------------------
//	selectedObject

- (id)selectedObject
{
  id obj=nil;
  LOGObjectFnStart();
  if([_selectedObjects count])
    obj=[_selectedObjects objectAtIndex:0];

  LOGObjectFnStop();
  return obj;
}

//--------------------------------------------------------------------
//	selectedObjects

- (NSArray *)selectedObjects
{
  return _selectedObjects;
}

//--------------------------------------------------------------------
//	selectionIndexes

- (NSArray *)selectionIndexes
{
  return _selection;
}

//--------------------------------------------------------------------
//	selectNext

- (id)selectNext
{
  unsigned index=0;
  id obj=nil;
  LOGObjectFnStart();

  if([_allObjects count]>0)
    {
      if(![_selectedObjects count])
        [self setSelectionIndexes:
                [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:0]]];
      else
        {
          obj = [_selectedObjects objectAtIndex:0];
          
          if([obj isEqual:[_displayedObjects lastObject]] == YES)
            {
              index = [_allObjects indexOfObject:[_displayedObjects
                                                   objectAtIndex:0]];
              
              [self setSelectionIndexes:
                      [NSArray arrayWithObject:
                                 [NSNumber numberWithUnsignedInt:index]]];
            }
          else
            {
              index = [_allObjects indexOfObject:obj]+1;
              
              if(index >= [_allObjects count])
                index = 0;
              
              [self setSelectionIndexes:
                      [NSArray arrayWithObject:
                                 [NSNumber numberWithUnsignedInt:index]]];
            };
        };
    };
  LOGObjectFnStop();
  return nil;//FIXME
}

//--------------------------------------------------------------------
//	selectObject:

- (BOOL)selectObject:(id)object
{
  BOOL result=NO;
  LOGObjectFnStart();
  if([_allObjects containsObject:object] == NO)
    result=NO;
  else
    result=[self setSelectionIndexes:
                   [NSArray arrayWithObject:
                              [NSNumber numberWithUnsignedInt:
                                          [_allObjects
                                            indexOfObject:object]]]];
  LOGObjectFnStop();
  return result;
}

//--------------------------------------------------------------------
//	selectObjectsIdenticalTo:

- (BOOL)selectObjectsIdenticalTo:(NSArray *)objects
{
  BOOL result=NO;
  NSMutableArray *array=nil;
  NSEnumerator *objsEnum=nil;
  NSEnumerator *dispEnum=nil;
  id object=nil;
  id dispObj=nil;
  LOGObjectFnStart();

  array = [NSMutableArray arrayWithCapacity:8];

  objsEnum = [objects objectEnumerator];
  while((object = [objsEnum nextObject]))
    {
      dispEnum = [_displayedObjects objectEnumerator];
      while((dispObj = [dispEnum nextObject]))
	{
	  if(dispObj == object)
	    {
	      [array addObject:[NSNumber numberWithUnsignedInt:
					   [_allObjects indexOfObject:object]]];
	      break;
	    };
	};

      if(dispObj == nil)
	{
	  [array removeAllObjects];
	  break;
	};
    };
  result=[self setSelectionIndexes:array];
  LOGObjectFnStop();
  return result;
}

//--------------------------------------------------------------------
//	selectObjectsIdenticalTo:selectFirstOnNoMatch:

- (BOOL)selectObjectsIdenticalTo:(NSArray *)objects
	    selectFirstOnNoMatch:(BOOL)flag
{
  BOOL result=NO;
  unsigned index=0;
  LOGObjectFnStart();
  if([self selectObjectsIdenticalTo:objects] == NO && flag == YES)
    {
      if(![_selectedObjects count] &&
	 [_displayedObjects count])
	{
	  index = [_allObjects indexOfObject:[_displayedObjects
					      objectAtIndex:0]];
	  [self setSelectionIndexes:
		  [NSArray arrayWithObject:[NSNumber
					     numberWithUnsignedInt:index]]];
	  result=YES;
	}
      else
        result=NO;
    }
  else
    result=YES;
  LOGObjectFnStop();
  return result;
}

//--------------------------------------------------------------------
//	selectPrevious

- (id)selectPrevious
{
  unsigned index=0;
  id obj=nil;
  LOGObjectFnStart();

  if([_allObjects count]>0)
    {
      if(![_selectedObjects count])
        [self setSelectionIndexes:
                [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:0]]];
      else
        {
          obj = [_selectedObjects objectAtIndex:0];
          
          if([obj isEqual:[_displayedObjects objectAtIndex:0]] == YES)
            {
              index = [_allObjects indexOfObject:[_displayedObjects lastObject]];
              
              [self setSelectionIndexes:
                      [NSArray arrayWithObject:
                                 [NSNumber numberWithUnsignedInt:index]]];
            }
          else
            {
              index = [_allObjects indexOfObject:obj]-1;
              
              if(!index || index >= [_allObjects count])
                index = [_allObjects count] - 1;
              
              [self setSelectionIndexes:
                      [NSArray arrayWithObject:
                                 [NSNumber numberWithUnsignedInt:index]]];
            };
        };
    };
  LOGObjectFnStop();
  return nil;
}

//--------------------------------------------------------------------
//	selectsFirstObjectAfterFetch

- (BOOL)selectsFirstObjectAfterFetch
{
  LOGObjectFnStart();
  return _flags.selectFirstObject;
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setBuildsQualifierFromInput:

- (void)setBuildsQualifierFromInput:(BOOL)flag
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	setCurrentBatchIndex:

- (void)setCurrentBatchIndex:(unsigned)index_
{
  unsigned batchCount, num;
  int i;
  LOGObjectFnStart();

  if(index_)
    {
      [_displayedObjects removeAllObjects];
      
      batchCount = [self batchCount];
      if(index_ > batchCount)
        index_ = 1;
      
      if(!_numberOfObjectsPerBatch)
        num = [_allObjects count];
      else
        num = _numberOfObjectsPerBatch;
      
      if(num)
        {
          for( i = (index_-1) * num;
               i < index_ * num;
               i++)
            [_displayedObjects addObject:[_allObjects objectAtIndex:i]];
          
          if(_flags.selectFirstObject == YES && [_selection count])
            [self setSelectionIndexes:
                    [NSArray arrayWithObject:
                               [NSNumber numberWithUnsignedInt:
                                           [_allObjects
                                             indexOfObject:
                                               [_displayedObjects objectAtIndex:0]]]]];
        };
    };
  LOGObjectFnStop();
}

-(void)_checkSelectedBatchConsistency
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};


-(BOOL)_allowsNullForKey:(id)key_
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return NO;
};


//--------------------------------------------------------------------
//	setDefaultStringMatchFormat:

- (void)setDefaultStringMatchFormat:(NSString *)format
{
  LOGObjectFnStart();
  ASSIGN(_defaultStringMatchFormat, format);
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setDefaultStringMatchOperator:

- (void)setDefaultStringMatchOperator:(NSString *)operator
{
  LOGObjectFnStart();
  ASSIGN(_defaultStringMatchOperator, operator);
  LOGObjectFnStop();
}


//--------------------------------------------------------------------
//	setDetailKey:

- (void)setDetailKey:(NSString *)detailKey
{
  EODetailDataSource *source=nil;
  LOGObjectFnStart();

  if([self hasDetailDataSource] == YES)
    {
      source = (EODetailDataSource *)_dataSource;
      [source qualifyWithRelationshipKey:detailKey
	      ofObject:[source masterObject]];
    }
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setFetchesOnLoad:

- (void)setFetchesOnLoad:(BOOL)flag
{
  LOGObjectFnStart();
  _flags.autoFetch = flag;
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setInQueryMode:

- (void)setInQueryMode:(BOOL)flag
{
  LOGObjectFnStart();
  _flags.queryMode = flag;
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setInsertedObjectDefaultValues:

- (void)setInsertedObjectDefaultValues:(NSDictionary *)defaultValues
{
  LOGObjectFnStart();
  ASSIGN(_insertedObjectDefaultValues, defaultValues);
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setLocalKeys:

- (void)setLocalKeys:(NSArray *)keys
{
  LOGObjectFnStart();
  ASSIGN(_localKeys, keys);
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setMasterObject:

- (void)setMasterObject:(id)masterObject
{
  EODetailDataSource *source=nil;
  LOGObjectFnStart();

  if([self hasDetailDataSource] == YES)
    {
      source = (EODetailDataSource *)_dataSource;
      [_dataSource qualifyWithRelationshipKey:[source detailKey]
		  ofObject:masterObject];
    }
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setNumberOfObjectsPerBatch:

- (void)setNumberOfObjectsPerBatch:(unsigned)count
{
  LOGObjectFnStart();
//FIXME  call clearSelection

  _numberOfObjectsPerBatch = count;
  _batchIndex=max(1,_batchIndex);
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setObjectArray:

- (void)setObjectArray:(NSArray *)objects
{
  LOGObjectFnStart();
  NSDebugMLog(@"objects=%@",objects);
  [_allObjects removeAllObjects];
  [_allObjects addObjectsFromArray:objects];

  [self updateDisplayedObjects];

  // TODO selection
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setQualifier:

- (void)setQualifier:(EOQualifier *)qualifier_
{
  LOGObjectFnStart();
  ASSIGN(_qualifier, qualifier_);
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setSelectedObject:

- (void)setSelectedObject:(id)object
{
  LOGObjectFnStart();
  [self selectObject:object];
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setSelectedObjects:

- (void)setSelectedObjects:(id)object
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
}
//--------------------------------------------------------------------
//	setSelectionIndexes:

- (BOOL)setSelectionIndexes:(NSArray *)selection_
{
  NSEnumerator *objsEnum;
  NSNumber *number;
  LOGObjectFnStart();

  if(_delegateRespondsTo.shouldChangeSelection == YES)
    if([delegate displayGroup:self
		 shouldChangeSelectionToIndexes:selection_] == NO)
      return NO;

  objsEnum = [selection_ objectEnumerator];
  while((number = [objsEnum nextObject]))
    {
      NS_DURING
	[_allObjects objectAtIndex:[number unsignedIntValue]];
      NS_HANDLER
	return NO;
      NS_ENDHANDLER;
    }

  [_selectedObjects removeAllObjects];

  objsEnum = [selection_ objectEnumerator];
  while((number = [objsEnum nextObject]))
    {
      [_selectedObjects
	addObject:[_allObjects objectAtIndex:[number unsignedIntValue]]];
    }

  ASSIGN(_selection, selection_);

  if(_delegateRespondsTo.didChangeSelection == YES)
    [delegate displayGroupDidChangeSelection:self];

  if(_delegateRespondsTo.didChangeSelectedObjects == YES)
    [delegate displayGroupDidChangeSelectedObjects:self];

  LOGObjectFnStop();
  return YES;
}

//--------------------------------------------------------------------
//	setSelectsFirstObjectAfterFetch:

- (void)setSelectsFirstObjectAfterFetch:(BOOL)flag
{
  LOGObjectFnStart();
  _flags.selectFirstObject = flag;
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setSortOrdering:

- (void)setSortOrderings:(NSArray *)orderings
{
  LOGObjectFnStart();
  ASSIGN(_sortOrdering, orderings);
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setValidatesChangesImmediately:

- (void)setValidatesChangesImmediately:(BOOL)flag
{
  LOGObjectFnStart();
  _flags.validateImmediately = flag;
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	sortOrdering

- (NSArray *)sortOrderings
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _sortOrdering;
}

//--------------------------------------------------------------------
//	updateDisplayedObjects

- (void)updateDisplayedObjects
{
  NSEnumerator *objsEnum=nil;
  id object=nil;
  LOGObjectFnStart();

  [_displayedObjects removeAllObjects];

  if(_delegateRespondsTo.displayArrayForObjects == YES)
    {
      [_displayedObjects
	addObjectsFromArray:[delegate displayGroup:self
				      displayArrayForObjects:_allObjects]];

      return;
    }

  if(_qualifier)
    {
      objsEnum = [_allObjects objectEnumerator];
      while((object = [objsEnum nextObject]))
	{
	  if([_qualifier evaluateWithObject:object] == YES)
	    [_displayedObjects addObject:object];
	}
    }
  else
    {
      _batchIndex = [self batchCount];
      [self displayNextBatch];
    }

  if(_sortOrdering)
    [_displayedObjects sortUsingKeyOrderArray:_sortOrdering];
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	validatesChangesImmediately

- (BOOL)validatesChangesImmediately
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _flags.validateImmediately;
}

- (id)initWithCoder:(NSCoder *)coder
{
  LOGObjectFnStart();
  [self notImplemented:_cmd];
  LOGObjectFnStop();
  return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  LOGObjectFnStart();
  [self notImplemented:_cmd];
  LOGObjectFnStop();
}

#endif

@end
