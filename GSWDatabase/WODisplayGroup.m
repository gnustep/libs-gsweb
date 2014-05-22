/** WODisplayGroup.m - <title>GSWeb: Class WODisplayGroup</title>
 
 Copyright (C) 1999-2004 Free Software Foundation, Inc.
 
 Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
 Mirko Viviani <mirko.viviani@rccr.cremona.it>
 Date: 	Jan 1999
 
 $Revision$
 $Date$
 $Id$
 
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

//#include "config.h"

#include "WODisplayGroup.h"

@class EOUndoManager;

#ifndef GNUSTEP
#include <GNUstepBase/NSObject+GNUstepBase.h>
#endif

#include <WebObjects/WebObjects.h>
#include <EOControl/EOSortOrdering.h>
#include <EOControl/EOClassDescription.h>

static NSArray* globalStringQualifierOperators=nil;
static NSArray* globalAllQualifierOperators=nil;
static NSString* globalDefaultStringMatchFormat = nil;
static NSString* globalDefaultStringMatchOperator = nil;
static BOOL globalDefaultForValidatesChangesImmediately = NO;


//====================================================================
@interface WODisplayGroup (Private)
-(void)finishInitialization;
-(void)_setUpForNewDataSource;
-(void) editingContext:(EOEditingContext*)editingContext
   presentErrorMessage:(NSString*)msg;
-(void)_presentAlertWithTitle:(NSString *)title
                      message:(NSString *)msg;
-(void)_addQualifiersToArray:(NSMutableArray*)array
                   forValues:(NSDictionary*)values
            operatorSelector:(SEL)sel;
-(EOQualifier*)_qualifierForKey:(id)key
                          value:(id)value
               operatorSelector:(SEL)sel;
@end


@interface NSArray (Indexes)
-(NSArray*)indexesOfObjectsIdenticalTo:(NSArray*)objects;
@end

//====================================================================
@implementation WODisplayGroup

+ (void)initialize
{
  if (self == [WODisplayGroup class])
  {
    if (!globalStringQualifierOperators)
      ASSIGN(globalStringQualifierOperators,([NSArray arrayWithObjects:@"starts with",
                                              @"contains",
                                              @"ends with", 
                                              @"is", 
                                              @"like",
                                              nil]));
    
    if (!globalAllQualifierOperators)
      ASSIGN(globalAllQualifierOperators,
             ([globalStringQualifierOperators 
               arrayByAddingObjectsFromArray:
               [EOQualifier relationalQualifierOperators]]));
    
    if (!globalDefaultStringMatchFormat)
      ASSIGN(globalDefaultStringMatchFormat,@"%@*");
    
    if (!globalDefaultStringMatchOperator)
      ASSIGN(globalDefaultStringMatchOperator,@"caseInsensitiveLike");
  }
}

+(WODisplayGroup*)displayGroup
{
  WODisplayGroup* displayGroup=[[[self alloc] init] autorelease];
  [displayGroup finishInitialization];
  return displayGroup;
}

//--------------------------------------------------------------------
//	init

- (id)init
{
  if ((self = [super init]))
  {
    _allObjects = [[NSMutableArray alloc] initWithCapacity:16];
    _displayedObjects = [[NSMutableArray alloc] initWithCapacity:16];
    _selectedObjects = [[NSMutableArray alloc] initWithCapacity:8];
    _selection = [[NSMutableArray alloc] initWithCapacity:8];
    
    _queryMatch    = [[NSMutableDictionary alloc] initWithCapacity:8];
    _queryNotMatch = [[NSMutableDictionary alloc] initWithCapacity:8];
    _queryMin      = [[NSMutableDictionary alloc] initWithCapacity:8];
    _queryMinMatch = [[NSMutableDictionary alloc] initWithCapacity:8];
    _queryMax      = [[NSMutableDictionary alloc] initWithCapacity:8];
    _queryMaxMatch = [[NSMutableDictionary alloc] initWithCapacity:8];
    _queryOperator = [[NSMutableDictionary alloc] initWithCapacity:8];
    _queryKeyValueQualifierClassName 
    = [[NSMutableDictionary alloc] initWithCapacity:8];
    
    _queryBindings = [[NSMutableDictionary alloc] initWithCapacity:8];
    
    [self setCurrentBatchIndex:1];
    
    ASSIGN(_defaultStringMatchOperator,
           [[self class]globalDefaultStringMatchOperator]);
    ASSIGN(_defaultStringMatchFormat,
           [[self class]globalDefaultStringMatchFormat]);
    
    [self setFetchesOnLoad:YES];
    [self setSelectsFirstObjectAfterFetch:YES];
  }
  return self;
}

-(id)initWithKeyValueUnarchiver:(EOKeyValueUnarchiver*)unarchiver
{
  if ((self=[self init]))
  {
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
     [unarchiver decodeObjectForKey:@"sortOrdering"]];
    [self setQualifier:
     [unarchiver decodeObjectForKey:@"qualifier"]];
    [self setAuxiliaryQueryQualifier:
     [unarchiver decodeObjectForKey:@"auxiliaryQueryQualifier"]];
    [self setDefaultStringMatchFormat:
     [unarchiver decodeObjectForKey:@"formatForLikeQualifier"]];
    [self setInsertedObjectDefaultValues:
     [unarchiver decodeObjectForKey:@"insertedObjectDefaultValues"]];
    [self setQueryOperator:[unarchiver decodeObjectForKey:@"queryOperator"]];
    [self setQueryKeyValueQualifierClassName:[unarchiver decodeObjectForKey:@"queryKeyValueQualifierClassName"]];
    [self finishInitialization];
  }
  return self;
}

- (void)setNilValueForKey:(NSString *)key
{
  if ([key isEqualToString:@"numberOfObjectsPerBatch"])
    [self setNumberOfObjectsPerBatch:0];
  else
    [super setNilValueForKey:key];
}

-(NSString*)description
{
  NSString* dscr=nil;
  dscr=[NSString stringWithFormat:@"<%s %p - \n",
        object_getClassName(self),
        (void*)self];
  
  dscr=[dscr stringByAppendingFormat:@"numberOfObjectsPerBatch:[%d]\n",
        _numberOfObjectsPerBatch];
  dscr=[dscr stringByAppendingFormat:@"fetchesOnLoad:[%s]\n",
        _flags.autoFetch ? "YES" : "NO"];
  dscr=[dscr stringByAppendingFormat:@"validatesChangesImmediately:[%s]\n",
        _flags.validateImmediately ? "YES" : "NO"];
  dscr=[dscr stringByAppendingFormat:@"selectsFirstObjectAfterFetch:[%s]\n",
        _flags.selectFirstObject ? "YES" : "NO"];
  dscr=[dscr stringByAppendingFormat:@"localKeys:[%@]\n",
        _localKeys];
  dscr=[dscr stringByAppendingFormat:@"dataSource:[%@]\n",
        _dataSource];
  dscr=[dscr stringByAppendingFormat:@"sortOrdering:[%@]\n",
        _sortOrdering];
  dscr=[dscr stringByAppendingFormat:@"qualifier:[%@]\n",
        _qualifier];
  dscr=[dscr stringByAppendingFormat:@"qualifier:[%@]\n",
        _auxiliaryQueryQualifier];
  dscr=[dscr stringByAppendingFormat:@"formatForLikeQualifier:[%@]\n",
        _defaultStringMatchFormat];
  dscr=[dscr stringByAppendingFormat:@"insertedObjectDefaultValues:[%@]\n",
        _insertedObjectDefaultValues];
  dscr=[dscr stringByAppendingFormat:@"queryMatch:[%@]\n",
        _queryMatch];
  dscr=[dscr stringByAppendingFormat:@"queryNotMatch:[%@]\n",
        _queryNotMatch];
  dscr=[dscr stringByAppendingFormat:@"queryMin:[%@]\n",
        _queryMin];
  dscr=[dscr stringByAppendingFormat:@"queryMinMatch:[%@]\n",
        _queryMinMatch];
  dscr=[dscr stringByAppendingFormat:@"queryMax:[%@]\n",
        _queryMax];
  dscr=[dscr stringByAppendingFormat:@"queryMaxMatch:[%@]\n",
        _queryMaxMatch];
  dscr=[dscr stringByAppendingFormat:@"queryOperator:[%@]\n",
        _queryOperator];
  dscr=[dscr stringByAppendingFormat:@"queryKeyValueQualifierClassName:[%@]\n",
        _queryKeyValueQualifierClassName];
  dscr=[dscr stringByAppendingFormat:@"defaultStringMatchOperator:[%@]\n",
        _defaultStringMatchOperator];
  dscr=[dscr stringByAppendingFormat:@"defaultStringMatchFormat:[%@]\n",
        _defaultStringMatchFormat];
  dscr=[dscr stringByAppendingFormat:@"queryBindings:[%@]\n",
        _queryBindings];
  dscr=[dscr stringByAppendingString:@">"];
  return dscr;
}


-(void)awakeFromKeyValueUnarchiver:(EOKeyValueUnarchiver*)unarchiver
{
  if (_dataSource)
    [unarchiver ensureObjectAwake:_dataSource];
  if ([self fetchesOnLoad])
  {
    NSLog(@"***** awakeFromKeyValueUnarchiver in WODisplayGroup is called *****");
    [self fetch];
  }
}

-(void)encodeWithKeyValueArchiver:(EOKeyValueArchiver*)archiver
{
  
  [archiver encodeInt:_numberOfObjectsPerBatch
               forKey:@"numberOfObjectsPerBatch"];
  [archiver encodeBool:[self fetchesOnLoad]
                forKey:@"fetchesOnLoad"];
  [archiver encodeBool:[self validatesChangesImmediately]
                forKey:@"validatesChangesImmediately"];
  [archiver encodeBool:[self selectsFirstObjectAfterFetch]
                forKey:@"selectsFirstObjectAfterFetch"];
  [archiver encodeObject:[self localKeys]
                  forKey:@"localKeys"];
  [archiver encodeObject:_dataSource
                  forKey:@"dataSource"];
  [archiver encodeObject:_sortOrdering
                  forKey:@"sortOrdering"];
  [archiver encodeObject:_qualifier
                  forKey:@"qualifier"];
  [archiver encodeObject:_auxiliaryQueryQualifier
                  forKey:@"auxiliaryQueryQualifier"];
  [archiver encodeObject:[self defaultStringMatchFormat]
                  forKey:@"formatForLikeQualifier"];
  [archiver encodeObject:_insertedObjectDefaultValues
                  forKey:@"insertedObjectDefaultValues"];
  
}

-(BOOL)_deleteObject:(id)object
{
  BOOL result=NO;
  
  
  if(_delegateRespondsTo.shouldDeleteObject
     && ![_delegate displayGroup:self
              shouldDeleteObject:object])
    result=NO;
  else
  {
    BOOL deletionOK=NO;
    NS_DURING
    {
      if(_dataSource)
        [_dataSource deleteObject:object];
      deletionOK=YES;
    }
    NS_HANDLER
    {
      NSLog(@"EXCEPTION: %@",localException);
      [self _presentAlertWithTitle:@"Error Deleting Object"
                           message:[localException reason]];
      result=NO;
    }
    NS_ENDHANDLER;
    if (deletionOK)
    {
      EOUndoManager* undoManager=[self undoManager];
      if (undoManager)
      {
        [undoManager registerUndoWithTarget:self
                                   selector:@selector(_selectObjects:)
                                        arg:[self selectedObjects]];
        
        [undoManager registerUndoWithTarget:self
                                   selector:@selector(_insertObjectWithObjectAndIndex:)
                                        arg:[NSArray arrayWithObjects:object,
                                             GSWIntNumber([_displayedObjects indexOfObjectIdenticalTo:object]),
                                             nil]];
      }
      
      [_displayedObjects removeObjectIdenticalTo:object];
      [_allObjects removeObjectIdenticalTo:object];
      
      [self selectObjectsIdenticalTo:[self selectedObjects]
                selectFirstOnNoMatch:NO];
      
      if (_delegateRespondsTo.didDeleteObject)
        [_delegate displayGroup:self
                didDeleteObject:object];
      
      [self redisplay];
      
      result=YES;
    }
  }
  return result;
}

-(BOOL)_deleteObjects:(NSArray*)objects
{
  BOOL result=NO;
  int objectsCount = 0;
  objectsCount = [objects count];
  if (objectsCount>0)
  {
    int i=0;
    result = YES;
    for(i=0;i<objectsCount;i++)
    {
      id object=[objects objectAtIndex:i];
      if (![self _deleteObject:object])
        result = NO;
    }
  }
  return result;
}

-(BOOL) _deleteObjectsAtIndexes:(NSArray*)indexes
{
    BOOL result = NO;
    
    if ([indexes count] > 0)
    {
        NSEnumerator      * idxEnumer = [indexes objectEnumerator];
        NSMutableArray    * objects   = [NSMutableArray array];
        NSNumber          * idx       = nil;
        
        while ((idx = [idxEnumer nextObject])) {
            [objects addObject:[_displayedObjects objectAtIndex:[idx intValue]]];
        }
        
        result=[self _deleteObjects:objects];
    }
    
    return result;
}

-(void)_insertObjectWithObjectAndIndex:(NSArray*)objectAndIndex
{
  id object=nil;
  NSNumber* indexObject=nil;
  int index=0;
  
  
  NSAssert1([objectAndIndex count]==0,
            @"Bad Array : %@",objectAndIndex);
  
  object = [objectAndIndex objectAtIndex:0];
  
  indexObject = [objectAndIndex objectAtIndex:1];
  
  index = [indexObject intValue];
  
  [self insertObject:object
             atIndex:index];
  
}

/** Returns 1st index of selection if any, -1 otherwise **/
-(int)_selectionIndex
{
  int index=-1;
  
  
  if ([_selection count]>0)
    index=[[_selection objectAtIndex:0] intValue];
  
  
  return index;
}

-(void)_lastObserverNotified:(id)object
{
  _flags.didChangeContents = NO;
  _flags.didChangeSelection = NO;
  _updatedObjectIndex = -2;
  [EOObserverCenter notifyObserversObjectWillChange:nil];
}


-(void)_beginObserverNotification:(id)object
{
  if(!_flags.haveFetched && _flags.autoFetch)
    [self fetch];
}

-(void)_notifySelectionChanged
{
  
  _flags.didChangeSelection = YES;
  
  if (_delegateRespondsTo.didChangeSelection)
    [_delegate displayGroupDidChangeSelection:self];
  
  [self willChange];
  
}

-(void)_notifyRowChanged:(int)row
{
  
  if(row!=_updatedObjectIndex)
    _updatedObjectIndex = _updatedObjectIndex != -2 ? -1 : row;
  
  _flags.didChangeContents = YES;
  
  [self willChange];
  
}

-(void)willChange
{
  [EOObserverCenter notifyObserversObjectWillChange:self];
  [EOObserverCenter notifyObserversObjectWillChange:nil];
}


-(id)_notify:(SEL)selector
        with:(id)object1
        with:(id)object2

{
  //TODOFN
  if (selector==@selector(displayGroup:didFetchObjects:)) //TODO ????
  {
    //Do it on object1
    if(_delegateRespondsTo.didFetchObjects)
      [_delegate displayGroup:object1
              didFetchObjects:object2];
  }
  else
  {
    [self notImplemented: _cmd];	//TODOFN
  }
  return self; //??
}


-(id)_notify:(SEL)selector
        with:(id)object
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
}


-(EOUndoManager*)undoManager
{
  EOUndoManager* undoManager=nil;
  undoManager=(EOUndoManager*)[[_dataSource editingContext] undoManager];
  return undoManager;
}

/** Called when objects invalidated in dataSource editing context **/
-(void)objectsInvalidatedInEditingContext:(NSNotification*)notification
{
  BOOL refetch = YES;
  
  if(_delegateRespondsTo.shouldRefetchObjects == YES)
    refetch = [_delegate displayGroup:self
shouldRefetchForInvalidatedAllObjectsNotification:
               notification];
  
  if(refetch == YES)
    [self fetch];
}

/** Called when objects changed in dataSource editing context **/
-(void)objectsChangedInEditingContext:(NSNotification*)notification
{
  BOOL isAllObjectsChanged = NO;
  
  if(_delegateRespondsTo.shouldRedisplay == YES)
    isAllObjectsChanged = [_delegate displayGroup:self
shouldRedisplayForEditingContextChangeNotification:notification];
  else
  {
    NSArray* deletedObjects=nil;
    int deletedObjectsCount = 0;
    
    deletedObjects = [[notification userInfo] objectForKey:@"deleted"];
    deletedObjectsCount=[deletedObjects count];
    
    if (deletedObjectsCount>0)
    {
      int i = 0;
      NSMutableSet* allObjectsSet = (NSMutableSet*)[NSMutableSet setWithArray:_allObjects];
      
      NSMutableSet* displayedObjectsSet = nil;
      BOOL isDisplayedObjectsChanged = NO;
      
      NSMutableSet* selectedObjectsSet = nil;
      BOOL isSelectedObjectsChanged = NO;
      
      for(i=0;i<deletedObjectsCount;i++)
      {
        id object = [deletedObjects objectAtIndex:i];
        
        // Do we need to remove deleted object from _allObjects ?
        if ([allObjectsSet containsObject:object]) 
        {
          [allObjectsSet removeObject:object]; // Remove it
          isAllObjectsChanged = YES; // will have to update _allObjects
          
          // We also have to check displayed objects
          if (!displayedObjectsSet)
            displayedObjectsSet = (NSMutableSet*)[NSMutableSet setWithArray:_displayedObjects];
          
          if ([displayedObjectsSet containsObject:object])
          {
            [displayedObjectsSet removeObject:object];
            isDisplayedObjectsChanged = YES;
            
            // And we also have to check selected objects
            if (!selectedObjectsSet)
              selectedObjectsSet = (NSMutableSet*)[NSMutableSet setWithArray:_selectedObjects];
            
            if ([selectedObjectsSet containsObject:object])
            {
              [selectedObjectsSet removeObject:object];
              isSelectedObjectsChanged = YES;
            }
          }
        }
      }
      
      // Now, if something changed, apply changes
      if (isAllObjectsChanged)
      {
        // Set new _allObjects
        ASSIGN(_allObjects,([NSMutableArray arrayWithArray:[allObjectsSet allObjects]]));
        
        if (isDisplayedObjectsChanged)
        {
          // Remove deleted (no more selected objects)
          for(i=[_displayedObjects count]-1;i>=0;i--)
          {
            id object = [_displayedObjects objectAtIndex:i];
            if (![displayedObjectsSet containsObject:object])
              [_displayedObjects removeObjectAtIndex:i];
          }
          
          if (isSelectedObjectsChanged)
          {
            ASSIGN(_selectedObjects,
                   ([NSMutableArray arrayWithArray:[selectedObjectsSet allObjects]]));
          }
          ASSIGN(_selection,([_displayedObjects 
                              indexesOfObjectsIdenticalTo:_selectedObjects]));
        }
      }
    }
  }
  if (isAllObjectsChanged)
    [self redisplay];
}

//--------------------------------------------------------------------
- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [[self undoManager]removeAllActionsWithTarget:self];
  
  _delegate = nil;
  
  DESTROY(_dataSource);
  
  DESTROY(_allObjects);
  DESTROY(_displayedObjects);
  DESTROY(_selection);
  DESTROY(_selectedObjects);
  DESTROY(_sortOrdering);
  DESTROY(_qualifier);
  DESTROY(_auxiliaryQueryQualifier);
  DESTROY(_localKeys);
  
  DESTROY(_insertedObjectDefaultValues);
  DESTROY(_savedAllObjects);
  
  DESTROY(_queryMatch);
  DESTROY(_queryNotMatch);
  DESTROY(_queryMin);
  DESTROY(_queryMinMatch);
  DESTROY(_queryMax);
  DESTROY(_queryMaxMatch);
  DESTROY(_queryOperator);
  DESTROY(_queryKeyValueQualifierClassName);
  
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
  return globalAllQualifierOperators;
}

//--------------------------------------------------------------------
//	stringQualifierOperators

- (NSArray *)stringQualifierOperators
{
  return globalStringQualifierOperators;
}

+(NSString*)globalDefaultStringMatchOperator
{
  return globalDefaultStringMatchOperator;
}

+(void)setGlobalDefaultStringMatchOperator:(NSString*)operatorString
{
  ASSIGN(globalDefaultStringMatchOperator,operatorString);
}

+(NSString*)globalDefaultStringMatchFormat
{
  return globalDefaultStringMatchFormat;
}

+(void)setGlobalDefaultStringMatchFormat:(NSString*)format
{
  ASSIGN(globalDefaultStringMatchFormat,format);
}

+(BOOL)globalDefaultForValidatesChangesImmediately
{
  return globalDefaultForValidatesChangesImmediately;
}

+(void)setGlobalDefaultForValidatesChangesImmediately:(BOOL)flag
{
  globalDefaultForValidatesChangesImmediately = flag;
}

//--------------------------------------------------------------------
//	batchCount

- (unsigned)batchCount
{
  unsigned batchCount=0;
  
  if(_numberOfObjectsPerBatch==0)
    batchCount=1;
  else
  {
    unsigned count = [_displayedObjects count];
    if(count==0)
      batchCount=1;
    else
      batchCount=(count / _numberOfObjectsPerBatch) +
      (count % _numberOfObjectsPerBatch ? 1 : 0);
  }
  return batchCount;
}

//--------------------------------------------------------------------
//	buildsQualifierFromInput

-(BOOL)buildsQualifierFromInput
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
}

//--------------------------------------------------------------------
//	clearSelection

- (BOOL)clearSelection
{
  BOOL result=NO;
  
  result=[self setSelectionIndexes:[NSArray array]];
  
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

- (void)setDataSource:(EODataSource *)dataSource
{
  if (dataSource!=_dataSource)
  {
    if (_dataSource)
    {
      EOEditingContext *editingContext = [_dataSource editingContext];
      if (editingContext)
      {
        [editingContext removeEditor:self];
        if([self isEqual:[editingContext messageHandler]] == YES)
          [editingContext setMessageHandler:nil];
      }
    }
    
    ASSIGN(_dataSource,dataSource);
    [self _setUpForNewDataSource];
    /*
     context = [_dataSource editingContext];
     [context addEditor:self];
     if([context messageHandler] == nil)
     [context setMessageHandler:self];
     [_displayedObjects removeAllObjects];
     */
    [self setObjectArray:nil];
    if(_delegateRespondsTo.didChangeDataSource == YES)
      [_delegate displayGroupDidChangeDataSource:self];
  }
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
  return _delegate;
}

//--------------------------------------------------------------------
//	setDelegate:

- (void)setDelegate:(id)delegate
{
  _delegate = delegate;
  
  _delegateRespondsTo.createObjectFailed = 
  [_delegate respondsToSelector:@selector(displayGroup:createObjectFailedForDataSource:)];
  _delegateRespondsTo.didDeleteObject = 
  [_delegate respondsToSelector:@selector(displayGroup:didDeleteObject:)];
  _delegateRespondsTo.didFetchObjects = 
  [_delegate respondsToSelector:@selector(displayGroup:didFetchObjects:)];
  _delegateRespondsTo.didInsertObject = 
  [_delegate respondsToSelector:@selector(displayGroup:didInsertObject:)];
  _delegateRespondsTo.didSetValueForObject = 
  [_delegate respondsToSelector:@selector(displayGroup:didSetValue:forObject:key:)];
  _delegateRespondsTo.displayArrayForObjects = 
  [_delegate respondsToSelector:@selector(displayGroup:displayArrayForObjects:)];
  _delegateRespondsTo.shouldChangeSelection = 
  [_delegate respondsToSelector:@selector(displayGroup:shouldChangeSelectionToIndexes:)];
  _delegateRespondsTo.shouldInsertObject = 
  [_delegate respondsToSelector:@selector(displayGroup:shouldInsertObject:atIndex:)];
  _delegateRespondsTo.shouldDeleteObject = 
  [_delegate respondsToSelector:@selector(displayGroup:shouldDeleteObject:)];
  _delegateRespondsTo.shouldRedisplay = 
  [_delegate respondsToSelector:@selector(displayGroup:shouldRedisplayForEditingContextChangeNotification:)];
  _delegateRespondsTo.shouldRefetchObjects = 
  [_delegate respondsToSelector:@selector(displayGroup:shouldRefetchForInvalidatedAllObjectsNotification:)];
  _delegateRespondsTo.didChangeDataSource = 
  [_delegate respondsToSelector:@selector(displayGroupDidChangeDataSource:)];
  _delegateRespondsTo.didChangeSelectedObjects = 
  [_delegate respondsToSelector:@selector(displayGroupDidChangeSelectedObjects:)];
  _delegateRespondsTo.didChangeSelection = 
  [_delegate respondsToSelector:@selector(displayGroupDidChangeSelection:)];
  _delegateRespondsTo.shouldFetchObjects = 
  [_delegate respondsToSelector:@selector(displayGroupShouldFetch:)];
}

//--------------------------------------------------------------------
//	delete

- (id)delete
{
  [self deleteSelection];
  [self displayBatchContainingSelectedObject];
  return nil;//return nil for direct .gswd actions ==> same page
}

//--------------------------------------------------------------------
//	deleteObjectAtIndex:

- (BOOL)deleteObjectAtIndex:(unsigned)index
{
  BOOL result=NO;
  [self endEditing];
  result=[self _deleteObject:[_allObjects objectAtIndex:index]];
  return result;
}

//--------------------------------------------------------------------
//	deleteSelection

- (BOOL)deleteSelection
{
  BOOL result=NO;
  [self endEditing];
  result=[self _deleteObjectsAtIndexes:[self selectionIndexes]];
  return result;
}

//--------------------------------------------------------------------
//	detailKey

- (NSString *)detailKey
{
  NSString* detailKey=nil;
  
  if([self hasDetailDataSource] == YES)
    detailKey= [(EODetailDataSource *)_dataSource detailKey];
  
  return detailKey;
}

//--------------------------------------------------------------------
//	displayBatchContainingSelectedObject

-(id)displayBatchContainingSelectedObject
{
  int newBatchIndex = 1;
  int selectionIndex = 0;
  
  
  selectionIndex=[self _selectionIndex];
  
  if ([self batchCount]>0 && _numberOfObjectsPerBatch != 0)
    newBatchIndex = selectionIndex / _numberOfObjectsPerBatch + 1;
  
  if(newBatchIndex!=_batchIndex)
  {
    [self setCurrentBatchIndex:newBatchIndex];
  }
  
  return nil;
}

//--------------------------------------------------------------------
//	displayedObjects

/** Returns currently displayed objects for the current batch **/

- (NSArray *)displayedObjects
{
  NSArray* displayedObjects=nil;
  int displayedObjectsCount = 0;
  
  displayedObjectsCount = [_displayedObjects count];
  
  if (_numberOfObjectsPerBatch == 0 || _numberOfObjectsPerBatch>=displayedObjectsCount)
    displayedObjects=_displayedObjects;
  else
  {
    int currentBatchIndex = [self currentBatchIndex];
    int startIndex=(currentBatchIndex - 1) * _numberOfObjectsPerBatch;
    
    if( displayedObjectsCount > (currentBatchIndex * _numberOfObjectsPerBatch))
      displayedObjectsCount = currentBatchIndex * _numberOfObjectsPerBatch;
    
    displayedObjects=[_displayedObjects subarrayWithRange:NSMakeRange(startIndex,displayedObjectsCount-startIndex)];
  }
  
  
  return displayedObjects;
}

//--------------------------------------------------------------------
//	allDisplayedObjects

/** Returns all displayed objects
 Objects are filtered and sorted (unlike allObjects) and this array contains objetcs 
 of all Batches, not only the current one.
 **/

- (NSArray *)allDisplayedObjects
{
  return _displayedObjects;
}

//--------------------------------------------------------------------
//	displayFirstBatch

- (id)displayFirstBatch
{
  
  if (_numberOfObjectsPerBatch>0)
  {
    [self setCurrentBatchIndex:1];
    [self clearSelection];
  }
  
  return nil;//return nil for direct .gswd actions ==> same page
}

//--------------------------------------------------------------------
//	displayNextBatch

- (id)displayNextBatch
{
  if (_numberOfObjectsPerBatch>0)
  {
    [self setCurrentBatchIndex:_batchIndex+1];
    [self clearSelection];
  }
  
  return nil;//return nil for direct .gswd actions ==> same page
}

//--------------------------------------------------------------------
//	displayPreviousBatch

- (id)displayPreviousBatch
{
  
  if (_numberOfObjectsPerBatch>0)
  {
    [self setCurrentBatchIndex:_batchIndex-1];
    [self clearSelection];
  }
  
  return nil;//return nil for direct .gswd actions ==> same page
}

//--------------------------------------------------------------------
//	displayLastBatch

- (id)displayLastBatch
{
  if (_numberOfObjectsPerBatch>0)
  {
    int batchCount=0;
    batchCount=[self batchCount];
    
    [self setCurrentBatchIndex:batchCount];
    [self clearSelection];
  }
  return nil;//return nil for direct .gswd actions ==> same page
}

//--------------------------------------------------------------------
/** Returns YES if batchCount>0 and current batch index>1 **/
- (BOOL)canDisplayFirstBatch
{
  BOOL canDisplayFirstBatch=NO;
  
  if(_numberOfObjectsPerBatch>0)
  {
    canDisplayFirstBatch=(_batchIndex>1);
  }
  
  
  return canDisplayFirstBatch;
}

//--------------------------------------------------------------------
/** Returns YES if batchCount>0 and current batch index < batch count **/
- (BOOL)canDisplayNextBatch
{
  BOOL canDisplayNextBatch=NO;
  
  
  if(_numberOfObjectsPerBatch>0)
  {
    int batchCount=[self batchCount];
    canDisplayNextBatch=(_batchIndex<batchCount);
  }
  
  
  return canDisplayNextBatch;
}

//--------------------------------------------------------------------
/** Returns YES if batchCount>0 and current batch index > 1 **/
- (BOOL)canDisplayPreviousBatch
{
  BOOL canDisplayPreviousBatch=NO;
  
  
  if(_numberOfObjectsPerBatch>0)
  {
    canDisplayPreviousBatch=(_batchIndex>1);
  }
  
  
  return canDisplayPreviousBatch;
}

//--------------------------------------------------------------------
/** Returns YES if batchCount>0 and current batch index < batch count **/
- (BOOL)canDisplayLastBatch
{
  BOOL canDisplayLastBatch=NO;
  
  
  if(_numberOfObjectsPerBatch>0)
  {
    int batchCount=[self batchCount];
    canDisplayLastBatch=(_batchIndex<batchCount);
  }
  
  
  return canDisplayLastBatch;
}

//--------------------------------------------------------------------
//	endEditing
// deprecatd
- (BOOL)endEditing
{
  return YES;
}

//--------------------------------------------------------------------
//	executeQuery

-(id)executeQuery
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;//return nil for direct .gswd actions ==> same page
}

//--------------------------------------------------------------------
//	fetch

- (id)fetch
{
  
  _flags.haveFetched = YES;
  if (_dataSource)
  {
    if ([self endEditing])
    {
      if(!_delegateRespondsTo.shouldFetchObjects
         || [_delegate displayGroupShouldFetch:self])
      {
        EOUndoManager* undoManager=nil;
        NSArray *objects=nil;
        
        [[NSNotificationCenter defaultCenter] 
         postNotificationName:@"WODisplayGroupWillFetch" //TODO Name
         object:self];
        
        undoManager=[self undoManager];
        [undoManager removeAllActionsWithTarget:self];
        
        if (_flags.isCustomDataSourceClass 
            && [_dataSource respondsToSelector:@selector(setQualifierBindings:)])
        {
          [_dataSource setQualifierBindings:_queryBindings];
        }
        
        NS_DURING
        {
          objects = [_dataSource fetchObjects];
          [self setObjectArray:objects];
          objects=nil;
        }
        NS_HANDLER
        {
          NSLog(@"%@ (%@)",localException,[localException reason]);
          RETAIN(localException);
          AUTORELEASE(localException);
          [localException raise];
        }
        NS_ENDHANDLER;
        
        if (_delegateRespondsTo.didFetchObjects)
          [_delegate displayGroup:self
                  didFetchObjects:_allObjects];
      }
    }
  }
  return nil;//return nil for direct .gswd actions ==> same page
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
/** returns YES if the displayGroup paginates display (batchCount>1), false otherwise **/

- (BOOL)hasMultipleBatches
{
  return ([self batchCount]>1);
}

//--------------------------------------------------------------------
//	inputObjectForQualifier

-(NSMutableDictionary*)inputObjectForQualifier
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
}

//--------------------------------------------------------------------
//	indexOfFirstDisplayedObject;

- (unsigned)indexOfFirstDisplayedObject
{
  int indexOfFirstDisplayedObject=0;
  
  indexOfFirstDisplayedObject=(([self currentBatchIndex]-1) * _numberOfObjectsPerBatch);
  
  return indexOfFirstDisplayedObject;
}

//--------------------------------------------------------------------
//	indexOfLastDisplayedObject;

- (unsigned)indexOfLastDisplayedObject
{
  int indexOfLastDisplayedObject=0;
  int allObjectsCount=0;
  
  
  allObjectsCount=[_allObjects count];  
  
  if (_numberOfObjectsPerBatch==0)
    indexOfLastDisplayedObject=allObjectsCount-1;
  else
  {
    int index = _numberOfObjectsPerBatch * [self currentBatchIndex];
    indexOfLastDisplayedObject=(allObjectsCount>index ? index : allObjectsCount-1);
  }
  
  
  return indexOfLastDisplayedObject;
}

//--------------------------------------------------------------------
//	inQueryMode

- (BOOL)inQueryMode
{
  return (_savedAllObjects!=nil);
}

////Deprecated
//--------------------------------------------------------------------
//-(void)editingContext:(EOEditingContext*)editingContext
//  presentErrorMessage:(NSString*)message
//{
//  [self _presentAlertWithTitle:@"Editing Context Error"
//                       message:message];
//}

//--------------------------------------------------------------------
//	insert

- (id)insert
{
  unsigned index=0, count=0;
  count = [_allObjects count];
  
  if([_selection count])
    index = [[_selection objectAtIndex:0] unsignedIntValue]+1;
  
  index=max(0,index);
  index=min(count,index);
  
  [self insertObjectAtIndex:index];
  [self displayBatchContainingSelectedObject];
  
  return nil;//return nil for direct .gswd actions ==> same page
}

//--------------------------------------------------------------------

- (id)insertAfterLastObject
{
  int index= [_displayedObjects count];
  return [self insertObjectAtIndex:index];
}

//--------------------------------------------------------------------
//	insertedObjectDefaultValues

- (NSDictionary *)insertedObjectDefaultValues
{
  return _insertedObjectDefaultValues;
}

//--------------------------------------------------------------------
//	insertObject:atIndex:

- (void)insertObject:(id)anObject
             atIndex:(unsigned)index
{
  
  if ([self endEditing])
  {
    if (index>[_displayedObjects count])
    {
      [[NSException exceptionWithName:NSInvalidArgumentException
                               reason:[NSString stringWithFormat:@"%@ %@: index %u is beyond the bounds of %d",
                                       [self class],NSStringFromSelector(_cmd),
                                       index,[_displayedObjects count]]
                             userInfo:nil] raise];
    }
    else if (_delegateRespondsTo.shouldInsertObject == YES
             && ![_delegate displayGroup:self
                      shouldInsertObject:anObject
                                 atIndex:index])
    {
      // to nothing more
    }
    else
    {
      BOOL insertionOK=NO;
      NS_DURING
      {
        if (_dataSource)
          [_dataSource insertObject:anObject];
        insertionOK=YES;
      }
      NS_HANDLER
      {
        NSLog(@"EXCEPTION: %@",localException);
        [self _presentAlertWithTitle:@"Error Inserting Object"
                             message:[localException reason]];
      }
      NS_ENDHANDLER;
      if (insertionOK)
      {
        EOUndoManager* undoManager=[self undoManager];
        if (undoManager)
        {
          [undoManager registerUndoWithTarget:self
                                     selector:@selector(_selectObjects:)
                                          arg:[self selectedObjects]];
          [undoManager registerUndoWithTarget:self
                                     selector:@selector(_deleteObject:)
                                          arg:anObject];
        }
        [_displayedObjects insertObject:anObject
                                atIndex:index];
        [_allObjects insertObject:anObject
                          atIndex:index];
        [self redisplay];
        
        if (_delegateRespondsTo.didInsertObject)
          [_delegate displayGroup:self
                  didInsertObject:anObject];
        [self selectObjectsIdenticalTo:[NSArray arrayWithObject:anObject]];
      }
    }
  }
}

//--------------------------------------------------------------------
//	insertNewObjectAtIndex:

- (id)insertNewObjectAtIndex:(unsigned)index
{
  id object=nil;
  object=[self insertObjectAtIndex:index];
  return object;
}

//--------------------------------------------------------------------
//	insertObjectAtIndex:

- (id)insertObjectAtIndex:(unsigned)index
{
  id object=nil;
  
  if ([self endEditing])
  {
    object = [_dataSource createObject];
    
    if (!object)
    {
      if(_delegateRespondsTo.createObjectFailed == YES)
        [_delegate displayGroup:self
createObjectFailedForDataSource:_dataSource];
      else
        [self _presentAlertWithTitle:@"Error Inserting Object"
                             message:@"Data source didn't created object"];
    }
    else
    {
      [object takeValuesFromDictionary:[self insertedObjectDefaultValues]];
      
      [self insertObject:object
                 atIndex:index];
    }
  }
  return object;
}

//--------------------------------------------------------------------
//	lastQualifierFromInputValues

-(EOQualifier*)lastQualifierFromInputValues
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
}

//--------------------------------------------------------------------
//	localKeys

- (NSArray *)localKeys
{
  return _localKeys;
}

-(BOOL)usesOptimisticRefresh
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
}



-(void)setUsesOptimisticRefresh:(id)object_
{
  [self notImplemented: _cmd];	//TODOFN
}

-(void)awakeFromNib
{
  [self notImplemented: _cmd];	//TODOFN
}


//--------------------------------------------------------------------
//	masterObject

- (id)masterObject
{
  id obj=nil;
  
  if([self hasDetailDataSource] == YES)
    obj=[(EODetailDataSource *)_dataSource masterObject];
  
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
- (EOQualifier *)_auxiliaryQueryQualifier
{
  return _auxiliaryQueryQualifier;
}

//--------------------------------------------------------------------
//	qualifierFromInputValues

-(EOQualifier*)qualifierFromInputValues
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
}

//--------------------------------------------------------------------
//	qualifierFromQueryValues

- (EOQualifier *)qualifierFromQueryValues
{
  EOQualifier* resultQualifier=nil;
  NSMutableArray *array=nil;
  
  array = [NSMutableArray arrayWithCapacity:8];
  
  [self _addQualifiersToArray:array
                    forValues:_queryMax
             operatorSelector:EOQualifierOperatorLessThan];
  [self _addQualifiersToArray:array
                    forValues:_queryMaxMatch
             operatorSelector:EOQualifierOperatorLessThanOrEqualTo];
  [self _addQualifiersToArray:array
                    forValues:_queryMin
             operatorSelector:EOQualifierOperatorGreaterThan];
  [self _addQualifiersToArray:array
                    forValues:_queryMinMatch
             operatorSelector:EOQualifierOperatorGreaterThanOrEqualTo];
  [self _addQualifiersToArray:array
                    forValues:_queryNotMatch
             operatorSelector:EOQualifierOperatorNotEqual];
  [self _addQualifiersToArray:array
                    forValues:_queryMatch
             operatorSelector:EOQualifierOperatorEqual];
  if (_auxiliaryQueryQualifier)
    [array addObject:_auxiliaryQueryQualifier];
  
  if ([array count]==1)
    resultQualifier=[array objectAtIndex:0];
  else if ([array count]>1)
    resultQualifier=[[[EOAndQualifier alloc] initWithQualifierArray:array] autorelease];
  
  return resultQualifier;
}

//--------------------------------------------------------------------
//	qualifyDataSource

- (void)qualifyDataSource
{
  EOQualifier* qualifier=nil;
  
  
  NS_DURING //for trace purpose
  {
    SEL setQualifierSel=NULL;
    
    [self endEditing];
    
    [self setInQueryMode:NO];
    
    qualifier=[self qualifierFromQueryValues];
    
    if (_flags.isCustomDataSourceClass)
    {
      if ([_dataSource respondsToSelector:@selector(setAuxiliaryQualifier:)])
        setQualifierSel=@selector(setAuxiliaryQualifier:);
      else if ([_dataSource respondsToSelector:@selector(setQualifier:)])
        setQualifierSel=@selector(setQualifier:);
    }
    
    if (setQualifierSel)
      [_dataSource performSelector:setQualifierSel
                        withObject:qualifier];

    [self fetch];
    
    [self setCurrentBatchIndex:1];
  }
  NS_HANDLER
  {
    NSLog(@"%@ (%@)",localException,[localException reason]);
    [localException raise];
  }
  NS_ENDHANDLER;
}

//--------------------------------------------------------------------
//	qualifyDisplayGroup

- (void)qualifyDisplayGroup
{
  EOQualifier* qualifier=nil;
  [self setInQueryMode:NO];
  qualifier=[self qualifierFromQueryValues];
  
  [self setQualifier:qualifier];
  
  [self updateDisplayedObjects];
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
//	queryNotMatch

- (NSMutableDictionary *)queryNotMatch
{
  return _queryNotMatch;
}

//--------------------------------------------------------------------
//	queryMax

- (NSMutableDictionary *)queryMax
{
  return _queryMax;
}

//--------------------------------------------------------------------
//	queryMaxMatch

- (NSMutableDictionary *)queryMaxMatch
{
  return _queryMaxMatch;
}

//--------------------------------------------------------------------
//	queryMin

- (NSMutableDictionary *)queryMin
{
  return _queryMin;
}

//--------------------------------------------------------------------
//	queryMinMatch

- (NSMutableDictionary *)queryMinMatch
{
  return _queryMinMatch;
}

//--------------------------------------------------------------------
//	queryOperator

- (NSMutableDictionary *)queryOperator
{
  return _queryOperator;
}

//--------------------------------------------------------------------
//	queryOperator

- (NSMutableDictionary *)queryKeyValueQualifierClassName
{
  return _queryKeyValueQualifierClassName;
}

//--------------------------------------------------------------------
//	redisplay

-(void)redisplay
{
  [self _notifyRowChanged:-1];
}

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
  [self notImplemented: _cmd];	//TODOFN
  return nil;
}

//--------------------------------------------------------------------
//	selectedObject

- (id)selectedObject
{
  id obj=nil;
  
  if([_selectedObjects count]>0)
    obj=[_selectedObjects objectAtIndex:0];
  
  return obj;
}

//--------------------------------------------------------------------
//	selectedObjects

- (NSArray *)selectedObjects
{
    if (!_selectedObjects) {
        NSEnumerator      * idxEnumer = [_selection objectEnumerator];
        NSMutableArray    * objects   = [NSMutableArray array];
        NSNumber          * idx       = nil;
        
        while ((idx = [idxEnumer nextObject])) {
            [objects addObject:[_displayedObjects objectAtIndex:[idx intValue]]];
        }
        
//        ASSIGN(_selectedObjects,([_displayedObjects objectsAtIndexes:_selection]));
        ASSIGN(_selectedObjects, objects);
    }
  
  return _selectedObjects;
}

//--------------------------------------------------------------------
//	selectionIndexes

- (NSArray *)selectionIndexes
{
  return _selection;
}

//--------------------------------------------------------------------
//	selectFirst

- (id)selectFirst
{
  
  if([_allObjects count]>0)
  {
    [self setSelectionIndexes:[NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:0]]];
  }
  
  return nil;//return nil for direct .gswd actions ==> same page
}  

//--------------------------------------------------------------------
//	selectNext

- (id)selectNext
{
  
  if ([_allObjects count]>0)
  {
    int nextIndex=0;
    if([_selection count]>0)
    {
      nextIndex=[[_selection objectAtIndex:0] intValue];
      nextIndex++;
      if (nextIndex>=[_displayedObjects count]) // passed the end
        nextIndex=0; // ==> back to the beginning
    }
    [self setSelectionIndexes:
     [NSArray arrayWithObject:
      GSWIntNumber(nextIndex)]];
  }
  
  return nil;//return nil for direct .gswd actions ==> same page
}

//--------------------------------------------------------------------
//	selectObject:

- (BOOL)selectObject:(id)object
{
  BOOL result=NO;
  
  result=[self selectObjectsIdenticalTo:
          [NSArray arrayWithObject:object]];
  
  return result;
}

//--------------------------------------------------------------------
//	selectObjectsIdenticalTo:

- (BOOL)selectObjectsIdenticalTo:(NSArray *)objects
{ 
  BOOL result=NO;
  NSArray* selectionIndexes = nil;
  
  selectionIndexes = [_displayedObjects indexesOfObjectsIdenticalTo:objects];
  
  result = [self setSelectionIndexes:selectionIndexes];
  
  if([objects count]>0 && [selectionIndexes count]==0)
    result=NO;
  
  return result;
}

//--------------------------------------------------------------------
//	selectObjectsIdenticalTo:selectFirstOnNoMatch:

- (BOOL)selectObjectsIdenticalTo:(NSArray *)objects
            selectFirstOnNoMatch:(BOOL)selectFirstOnNoMatch
{
  BOOL result=NO;
  NSArray* selectionIndexes = nil;
  
  selectionIndexes = [_displayedObjects indexesOfObjectsIdenticalTo:objects];
  
  if ([selectionIndexes count]==0)
  {
    if (selectFirstOnNoMatch && [_displayedObjects count]>0)
      selectionIndexes=[NSArray arrayWithObject:GSWIntNumber(0)];
  }
  result = [self setSelectionIndexes:selectionIndexes];
  
  return result;
}

//--------------------------------------------------------------------
//	selectPrevious

- (id)selectPrevious
{
  
  if ([_allObjects count]>0)
  {
    int previousIndex=0;
    if([_selection count]>0)
    {
      previousIndex=[[_selection objectAtIndex:0] intValue];
      previousIndex--;
      if (previousIndex<=0) // too low ?
        previousIndex=[_displayedObjects count]-1; // ==> to the end
    }
    [self setSelectionIndexes:
     [NSArray arrayWithObject:
      GSWIntNumber(previousIndex)]];
  }
  
  return nil;
}

//--------------------------------------------------------------------
//	selectsFirstObjectAfterFetch

- (BOOL)selectsFirstObjectAfterFetch
{
  return _flags.selectFirstObject;
}

//--------------------------------------------------------------------
//	setBuildsQualifierFromInput:

- (void)setBuildsQualifierFromInput:(BOOL)flag
{
  [self notImplemented: _cmd];	//TODOFN
}

//--------------------------------------------------------------------
//	setCurrentBatchIndex:

- (void)setCurrentBatchIndex:(unsigned)index
{
  
  if(_numberOfObjectsPerBatch>0)
  {
    int batchCount=[self batchCount];

    if (index<1)
      _batchIndex=(batchCount>0 ?  batchCount : 1);
    else if (index>batchCount)
      _batchIndex=1;
    else
      _batchIndex=index;
  }
}

-(void)_checkSelectedBatchConsistency
{
  [self notImplemented: _cmd];	//TODOFN
}


-(BOOL)_allowsNullForKey:(id)key
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
}


//--------------------------------------------------------------------
//	setDefaultStringMatchFormat:

- (void)setDefaultStringMatchFormat:(NSString *)format
{
  NSRange range;
  // This must contains value format string
  range=[format rangeOfString:@"%@"];
  if (range.length==0)
  {
    [[NSException exceptionWithName:NSInvalidArgumentException
                             reason:[NSString stringWithFormat:@"defaultStringMatchFormat '%@' must contains value format string (i.e. %%@).",
                                     format]
                           userInfo:nil] raise];
  }
  else
  {
    ASSIGN(_defaultStringMatchFormat, format);
  }
}

//--------------------------------------------------------------------
//	setDefaultStringMatchOperator:

- (void)setDefaultStringMatchOperator:(NSString *)operator
{
  ASSIGN(_defaultStringMatchOperator, operator);
}

//--------------------------------------------------------------------
//	setDetailKey:

- (void)setDetailKey:(NSString *)detailKey
{
  
  if([self hasDetailDataSource] == YES)
  {
    /*
     EODetailDataSource *source=nil;
     source = (EODetailDataSource *)_dataSource;
     [source qualifyWithRelationshipKey:detailKey
     ofObject:[source masterObject]];
     */
    [(EODetailDataSource*)_dataSource setDetailKey:detailKey];
  }
}

//--------------------------------------------------------------------
//	setFetchesOnLoad:

- (void)setFetchesOnLoad:(BOOL)flag
{
  _flags.autoFetch = flag;
}

//--------------------------------------------------------------------
//	setInQueryMode:
// Deprectaed
- (void)setInQueryMode:(BOOL)flag
{
  if( flag != [self inQueryMode])
  {
    if(flag)
    {
      ASSIGN(_savedAllObjects,_allObjects);
      [self setObjectArray:[NSArray arrayWithObject:_queryMatch]];
      [self selectObject:_queryMatch];
    } 
    else
    {
      NSMutableArray* savedAllObjects=_savedAllObjects;
      RETAIN(savedAllObjects);
      AUTORELEASE(savedAllObjects);
      DESTROY(_savedAllObjects);
      [self setObjectArray:savedAllObjects];
    }
  }
}

//--------------------------------------------------------------------
//	setInsertedObjectDefaultValues:

- (void)setInsertedObjectDefaultValues:(NSDictionary *)defaultValues
{
  ASSIGN(_insertedObjectDefaultValues, defaultValues);
}

//--------------------------------------------------------------------
//	setLocalKeys:

- (void)setLocalKeys:(NSArray *)keys
{
  ASSIGN(_localKeys, keys);
}

//--------------------------------------------------------------------
/** sets query operators **/
-(void)setQueryOperator:(NSDictionary*)qo
{
  NSAssert1((!qo || [qo isKindOfClass:[NSDictionary class]]),
            @"queryOperator is not a dictionary but a %@",
            [qo class]);
  [_queryOperator removeAllObjects];
  if (qo)
    [_queryOperator addEntriesFromDictionary:qo];
}

//--------------------------------------------------------------------
/** add a query operator **/
- (void)addQueryOperator:(NSString*)value
                  forKey:(NSString*)operatorKey
{
  [_queryOperator setObject:value
                     forKey:operatorKey];
}

//--------------------------------------------------------------------
-(void)setQueryKeyValueQualifierClassName:(NSDictionary*)qo
{
  NSAssert1((!qo || [qo isKindOfClass:[NSDictionary class]]),
            @"queryOperatorKeyValueClass is not a dictionary but a %@",
            [qo class]);
  [_queryKeyValueQualifierClassName removeAllObjects];
  if (qo)
    [_queryKeyValueQualifierClassName addEntriesFromDictionary:qo];
}


//--------------------------------------------------------------------
//	setMasterObject:

- (void)setMasterObject:(id)masterObject
{
  EODetailDataSource *source=nil;

  if([self hasDetailDataSource] == YES)
  {
    source = (EODetailDataSource *)_dataSource;

    [_dataSource qualifyWithRelationshipKey:[source detailKey]
                                   ofObject:masterObject];
    if ([self fetchesOnLoad])
    {
      [self fetch];
    }
  }
}

//--------------------------------------------------------------------
//	setNumberOfObjectsPerBatch:

- (void)setNumberOfObjectsPerBatch:(unsigned)count
{
  if(count!=_numberOfObjectsPerBatch)
  {
    [self clearSelection];
    _numberOfObjectsPerBatch = count;
    _batchIndex = 1;
  }
}

//--------------------------------------------------------------------
//	setObjectArray:

- (void)setObjectArray:(NSArray *)objects
{
  NSMutableArray* selectedObjects = nil;
  
  
  selectedObjects = (NSMutableArray*)[self selectedObjects];
  RETAIN(selectedObjects);
  AUTORELEASE(selectedObjects);
  
  if (objects)
    ASSIGN(_allObjects,[NSMutableArray arrayWithArray:objects]);
  else
    ASSIGN(_allObjects,[NSMutableArray array]);
  
  [self updateDisplayedObjects];
  
  [self selectObjectsIdenticalTo:selectedObjects
            selectFirstOnNoMatch:[self selectsFirstObjectAfterFetch]];
  
  [self redisplay];
  
}

//--------------------------------------------------------------------
//	setQualifier:

- (void)setQualifier:(EOQualifier *)qualifier
{
  ASSIGN(_qualifier, qualifier);
}

//--------------------------------------------------------------------
//	setAuxiliaryQueryQualifier:

- (void)setAuxiliaryQueryQualifier:(EOQualifier *)qualifier
{
  ASSIGN(_auxiliaryQueryQualifier, qualifier);
}

//--------------------------------------------------------------------
//	setSelectedObject:

- (void)setSelectedObject:(id)object
{
  if (object)
    [self setSelectedObjects:[NSArray arrayWithObject:object]];
  else
    [self clearSelection];
}

//--------------------------------------------------------------------
//	setSelectedObjects:

- (void)setSelectedObjects:(NSArray *)objects
{
  
  ASSIGN(_selectedObjects,([NSMutableArray arrayWithArray:objects]));
  ASSIGN(_selection,([_displayedObjects indexesOfObjectsIdenticalTo:_selectedObjects]));
  
}

//--------------------------------------------------------------------
//	setSelectionIndexes:

- (BOOL)setSelectionIndexes:(NSArray *)selection
{
  BOOL retValue=NO;
  NSMutableArray* selectedObjects = nil;
  NSArray* sortedSelection = nil;
  BOOL isSelectionChanged = NO;
  BOOL isSelectedObjectsChanged = NO;
  
  if([selection count]>1)
  {
    sortedSelection = [selection sortedArrayUsingSelector:@selector(compare:)];
  }
  else if([_displayedObjects count]>0)
    sortedSelection = [NSArray arrayWithArray:selection];
  else
    sortedSelection = [NSArray array];
  
  selectedObjects = [[[_displayedObjects objectsAtIndexes:
		[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [sortedSelection count])]]
		mutableCopy]autorelease];
  isSelectedObjectsChanged = ![selectedObjects isEqual:_selectedObjects];
  isSelectionChanged = ![sortedSelection isEqual:_selection];
  if (!isSelectionChanged && !isSelectedObjectsChanged)
    retValue=YES;
  else
  {
    if (![self endEditing])
      retValue=NO;
    else
    {
      if(_delegateRespondsTo.shouldChangeSelection == YES 
         && [_delegate displayGroup:self
     shouldChangeSelectionToIndexes:sortedSelection] == NO)
        retValue=NO;
      else 
      {
        if (isSelectionChanged)
          ASSIGN(_selection,sortedSelection);
        if (isSelectedObjectsChanged)
        {
          ASSIGN(_selectedObjects,selectedObjects);
          if(_delegateRespondsTo.didChangeSelectedObjects == YES)
            [_delegate displayGroupDidChangeSelectedObjects:self];
        }
        [self _notifySelectionChanged];
        retValue=YES;
      }
    }
  }  
  
  return retValue;
}


//--------------------------------------------------------------------
//	setSelectsFirstObjectAfterFetch:

- (void)setSelectsFirstObjectAfterFetch:(BOOL)flag
{
  _flags.selectFirstObject = flag;
}

//--------------------------------------------------------------------
//	setSortOrdering:

- (void)setSortOrderings:(NSArray *)orderings
{
  ASSIGN(_sortOrdering, orderings);
}

//--------------------------------------------------------------------
//	setValidatesChangesImmediately:

- (void)setValidatesChangesImmediately:(BOOL)flag
{
  _flags.validateImmediately = flag;
}

//--------------------------------------------------------------------
//	sortOrdering

- (NSArray *)sortOrderings
{
  return _sortOrdering;
}

//--------------------------------------------------------------------
//	updateDisplayedObjects

- (void)updateDisplayedObjects
{
  NSMutableArray* selectedObjects = nil;
  NSArray* newDisplayedObjects = nil;
  
  selectedObjects = (NSMutableArray*)[self selectedObjects];
  newDisplayedObjects = _allObjects;
  
  // Let's delegate doing the job ?
  if (_delegateRespondsTo.displayArrayForObjects == YES)
  {
    newDisplayedObjects = [_delegate displayGroup:self
                           displayArrayForObjects:newDisplayedObjects];
  }
  else
  {
    // Filter ?
    if (_qualifier)
    {
      newDisplayedObjects=[newDisplayedObjects 
                           filteredArrayUsingQualifier:_qualifier];
    }
    // Sort ?
    if (_sortOrdering)
    {
      newDisplayedObjects=[newDisplayedObjects
                           sortedArrayUsingKeyOrderArray:_sortOrdering];
    }
  }
  ASSIGN(_displayedObjects,([NSMutableArray arrayWithArray:newDisplayedObjects]));
  
  [self selectObjectsIdenticalTo:selectedObjects
            selectFirstOnNoMatch:NO];
  [self redisplay];
  /*
   NSEnumerator *objsEnum=nil;
   id object=nil;
   
   //TODO
   //self selectedObjects //() 
   //self allObjects 
   //self selectObjectsIdenticalTo:_selection selectFirstOnNoMatch:0
   //self redisplay
   //STOP
   [_displayedObjects removeAllObjects];
   
   if(_delegateRespondsTo.displayArrayForObjects == YES)
   {
   [_displayedObjects addObjectsFromArray:[_delegate displayGroup:self
   displayArrayForObjects:_allObjects]];
   }
   else
   {
   if(_qualifier)
   {
   objsEnum = [_allObjects objectEnumerator];
   while((object = [objsEnum nextObject]))
   {
   if ([_qualifier evaluateWithObject:object] == YES)
   [_displayedObjects addObject:object];
   }
   }
   else
   {
   _batchIndex = [self batchCount];
   NSDebugMLog(@"_batchIndex=%d",_batchIndex);
   [self displayNextBatch];
   }
   
   NSDebugMLLog(@"GSWDisplayGroup",@"_sortOrdering=%@",_sortOrdering);
   if(_sortOrdering)
   [_displayedObjects sortUsingKeyOrderArray:_sortOrdering];
   }
   */
}

//--------------------------------------------------------------------
//	validatesChangesImmediately

- (BOOL)validatesChangesImmediately
{
  return _flags.validateImmediately;
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


@end

//#if HAVE_GDL2 // GDL2 implementation
//====================================================================
@implementation GSWDisplayGroup (Private)
-(void)finishInitialization
{
  if (!_flags.isInitialized)
  {
    [self _setUpForNewDataSource];
    _flags.isInitialized=YES;
  }
}

/** Returns YES if aClass equals EODetailDataSource or EOArrayDataSource class **/
-(BOOL)_isCustomDataSourceClass:(Class)aClass
{
  return (aClass!=[EODetailDataSource class]
          /*&& aClass!=[EOArrayDataSource class]*/); //EOArrayDataSource has to be added in GDL2
}

-(void)_setUpForNewDataSource
{
  if(_dataSource)
  {
    EOEditingContext* editingContext = nil;
    // Set flags to detect customer dataSource
    _flags.isCustomDataSourceClass = [self _isCustomDataSourceClass:[_dataSource class]];
    
    // Add self as observer on dataSource editingContext
    editingContext = [_dataSource editingContext];
    if(editingContext)
    {
      [[NSNotificationCenter defaultCenter]
       addObserver:self
       selector:@selector(objectsChangedInEditingContext:)
       name:EOObjectsChangedInEditingContextNotification
       object:editingContext];
      [[NSNotificationCenter defaultCenter]
       addObserver:self
       selector:@selector(objectsInvalidatedInEditingContext:)
       name:EOInvalidatedAllObjectsInStoreNotification
       object:editingContext];
    }
  }
}

-(void)editingContext:(EOEditingContext*)editingContext
  presentErrorMessage:(NSString*)message
{
  [self _presentAlertWithTitle:@"Editing context error"
                       message:message];
}

-(void)_presentAlertWithTitle:(NSString*)title
                      message:(NSString*)message
{
  NSLog(@"%@ %@: %@",
        NSStringFromClass([self class]),
        title,message);
}

-(void)_addQualifiersToArray:(NSMutableArray*)array
                   forValues:(NSDictionary*)values
            operatorSelector:(SEL)sel
{
  NSEnumerator *enumerator=nil;
  NSString *key=nil;

  enumerator = [values keyEnumerator];
  
  while((key = [enumerator nextObject]))
  {
    EOQualifier* qualifier=nil;
    id value=[values objectForKey:key];

    qualifier=[self _qualifierForKey:key
                               value:value
                    operatorSelector:sel];

    if (qualifier)
      [array addObject:qualifier];
  }
}


-(EOQualifier*)_qualifierForKey:(id)key
                          value:(id)value
               operatorSelector:(SEL)operatorSelector
{
  EOQualifier* qualifier=nil;
  NSException* validateException=nil;
    
  // Get object class description
  EOClassDescription* cd=[_dataSource classDescriptionForObjects];
  
  // Validate the value against object class description
  validateException=[cd validateValue:&value
			forKey:key];

  if (validateException)
    {
      if ([[validateException name] isEqualToString:EOValidationException])
	{
	  //Don't raise exception, just log it
	  NSLog(@"Exception during value validation for key: '%@': %@",key,validateException);
	}
      else
	[validateException raise];
    }

  NSString* qualifierClassName=[_queryKeyValueQualifierClassName objectForKey:key];
  Class qualifierClass=Nil;

  if ([qualifierClassName length]>0)
    {
      qualifierClass=NSClassFromString(qualifierClassName);
      NSAssert1(qualifierClass,@"No qualifier class named %@",qualifierClassName);
      NSAssert1([qualifierClass instancesRespondToSelector:@selector(initWithKey:operatorSelector:value:)],
                @"Qualifier class %@ instance does not responds to -initWithKey:operatorSelector:value:",
                qualifierClassName);
    }
  else
    qualifierClass=[EOKeyValueQualifier class];
  
  // If the selector is the equal operator
  if (sel_isEqual(operatorSelector, EOQualifierOperatorEqual))
    {
      // Search if there's a specific defined operator for it
      NSString* operatorString=[_queryOperator objectForKey:key];
      
      // If value is a string, try to do handle string specific operators
      if([value isKindOfClass:[NSString class]])
	{
	  // 'Basic' equal operator
	  if ([operatorString isEqualToString:@"is"])
	    {
	      operatorString = @"=";
	    }
	  else
	    {
	      NSString* stringValue = (NSString*)value;
	      // Other string operators don't care about empry string
	      
	      if ([stringValue length]==0)
		{
		  // So ends here and we'll return a nil qualifier
		  key=nil; 
		  value=nil;
		  operatorString=nil;
		}
	      else if ([operatorString length]==0) // ==> defaultStringMatchOperator with defaultStringMatchFormat
		{
		  value=[NSString stringWithFormat:_defaultStringMatchFormat,
				  value];
		  operatorString = _defaultStringMatchOperator;
		}
	      else if ([operatorString isEqualToString:@"starts with"])
		{
		  value=[NSString stringWithFormat:@"%@*",
				  value];
		  operatorString = _defaultStringMatchOperator;
		} 
	      else if ([operatorString isEqualToString:@"ends with"])
		{
		  value=[NSString stringWithFormat:@"*%@",
				  value];
		  operatorString = _defaultStringMatchOperator;
		} 
	      else if([operatorString isEqualToString:@"contains"])
		{
		  value=[NSString stringWithFormat:@"*%@*",
				  value];
		  operatorString = _defaultStringMatchOperator;
		}
	    }
	}
      else
	{
	  if ([operatorString length]==0)
	    operatorString = @"=";
	}
      operatorSelector = [qualifierClass operatorSelectorForString:operatorString];
    }
  
  if (key || operatorSelector || value) // qualifier returned will be nil when we have to discard it
    {
      if (operatorSelector)
	{
	  qualifier=[[[qualifierClass alloc]
		       initWithKey:key
		       operatorSelector:operatorSelector
		       value:value] autorelease];
	}
      else
	{
	  NSLog(@"Error: Qualifier (%@) null selector for %@ %@ %@. Discard it !",
		qualifierClass,key,[_queryOperator objectForKey:key],value);
	}
    }
  return qualifier;
}

@end

//#endif

@implementation NSArray (Indexes)
-(NSArray*)indexesOfObjectsIdenticalTo:(NSArray*)objects
{
  NSArray* indexes=nil;
  int selfCount=0;
  
  selfCount=[self count];
  if (selfCount>0)
  {
    int objectsCount=[objects count];
    if (objectsCount>0)
    {
      NSMutableArray* tmpIndexes=nil;
      int i=0;
      for(i=0;i<objectsCount;i++)
      {
        id object=[objects objectAtIndex:i];
        NSUInteger index=[self indexOfObjectIdenticalTo:object];
        if (index!=NSNotFound)
        {
          NSNumber* indexObject=GSWIntNumber((int)index);
          if (tmpIndexes)
            [tmpIndexes addObject:indexObject];
          else
            tmpIndexes=(NSMutableArray*)[NSMutableArray arrayWithObject:indexObject];
        }
      }
      if (tmpIndexes)
        indexes=[NSArray arrayWithArray:tmpIndexes];
    }
  }
  if (!indexes)
    indexes=[NSArray array];

  return indexes;
}

@end

