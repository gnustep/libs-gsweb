/** GSWDisplayGroup.m - <title>GSWeb: Class GSWDisplayGroup</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"
@class EOUndoManager;

#if HAVE_GDL2 // GDL2 implementation
#include <EOControl/EOSortOrdering.h>
#include <EOControl/EOClassDescription.h>

static NSArray* globalStringQualifierOperators=nil;
static NSArray* globalAllQualifierOperators=nil;
static NSString* globalDefaultStringMatchFormat = nil;
static NSString* globalDefaultStringMatchOperator = nil;
static BOOL globalDefaultForValidatesChangesImmediately = NO;
                                               

//====================================================================
@interface GSWDisplayGroup (Private)
-(void)finishInitialization;
-(void)_setUpForNewDataSource;
-(void)_presentAlertWithTitle:(id)title
                      message:(id)msg;
-(void)_addQualifiersToArray:(NSMutableArray*)array
                   forValues:(NSDictionary*)values
            operatorSelector:(SEL)sel;
-(EOQualifier*)_qualifierForKey:(id)key
                          value:(id)value
               operatorSelector:(SEL)sel;
@end

#endif

@interface NSArray (Indexes)
-(NSArray*)indexesOfObjectsIdenticalTo:(NSArray*)objects;
-(NSArray*)objectsAtIndexes:(NSArray*)indexes;
@end

//====================================================================
@implementation GSWDisplayGroup

#if HAVE_GDL2 // GDL2 implementation

+ (void)initialize
{
  if (self == [GSWDisplayGroup class])
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
    };
}

+(GSWDisplayGroup*)displayGroup
{
  GSWDisplayGroup* displayGroup=[[[self alloc] init] autorelease];
  [displayGroup finishInitialization];
  return displayGroup;
};

//--------------------------------------------------------------------
//	init

- init
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
      NSDebugMLLog(@"gswdisplaygroup",@"_queryOperator=%@",_queryOperator);
      _queryOperator = [[NSMutableDictionary alloc] initWithCapacity:8];
      NSDebugMLLog(@"gswdisplaygroup",@"_queryOperator=%@",_queryOperator);
      _queryKeyValueQualifierClassName = [[NSMutableDictionary alloc] initWithCapacity:8];

      _queryBindings = [[NSMutableDictionary alloc] initWithCapacity:8];

      [self setCurrentBatchIndex:1];

      ASSIGN(_defaultStringMatchOperator,[[self class]globalDefaultStringMatchOperator]);
      ASSIGN(_defaultStringMatchFormat,[[self class]globalDefaultStringMatchFormat]);
      NSDebugMLLog(@"gswdisplaygroup",@"_defaultStringMatchOperator=%@",_defaultStringMatchOperator);
      NSDebugMLLog(@"gswdisplaygroup",@"_defaultStringMatchFormat=%@",_defaultStringMatchFormat);

      [self setSelectsFirstObjectAfterFetch:YES];
    };
  return self;
};

-(id)initWithKeyValueUnarchiver:(EOKeyValueUnarchiver*)unarchiver
{
  if ((self=[self init]))
    {
      LOGObjectFnStart();
      NSDebugMLLog(@"gswdisplaygroup",@"GSWDisplayGroup %p",self);
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
      NSDebugMLLog(@"gswdisplaygroup",@"GSWDisplayGroup %p : %@",self,self);
      LOGObjectFnStop();
    };
  return self;
};

-(void)unableToSetNilForKey:(NSString*)key
{
  if ([key isEqualToString:@"numberOfObjectsPerBatch"])
    [self setNumberOfObjectsPerBatch:0];
  else
    [super unableToSetNilForKey:key];
}

-(NSString*)description
{
  NSString* dscr=nil;
  GSWLogAssertGood(self);
  NSDebugMLLog(@"gswdisplaygroup",@"GSWDisplayGroup description Self=%p",self);
  dscr=[NSString stringWithFormat:@"<%s %p - \n",
                  object_get_class_name(self),
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
};


-(void)awakeFromKeyValueUnarchiver:(EOKeyValueUnarchiver*)unarchiver
{
  LOGObjectFnStart();
  if (_dataSource)
    [unarchiver ensureObjectAwake:_dataSource];
  if ([self fetchesOnLoad])
    {
      NSLog(@"***** awakeFromKeyValueUnarchiver in GSWDisplayGroup is called *****");
      [self fetch];
    };
  LOGObjectFnStop();
};

-(void)encodeWithKeyValueArchiver:(EOKeyValueArchiver*)archiver
{
  LOGObjectFnStart();
  
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

  LOGObjectFnStop();
};

-(BOOL)_deleteObject:(id)object
{
  BOOL result=NO;

  LOGObjectFnStart();

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
                                        [NSNumber numberWithInt:[_displayedObjects indexOfObjectIdenticalTo:object]],
                                        nil]];
            };

          [_displayedObjects removeObjectIdenticalTo:object];
          [_allObjects removeObjectIdenticalTo:object];

          [self selectObjectsIdenticalTo:[self selectedObjects]
                selectFirstOnNoMatch:NO];

          if (_delegateRespondsTo.didDeleteObject)
            [_delegate displayGroup:self
                       didDeleteObject:object];

          [self redisplay];

          result=YES;
        };
    };
  LOGObjectFnStop();
  return result;
};

-(BOOL)_deleteObjects:(NSArray*)objects
{
  BOOL result=NO;
  int objectsCount = 0;
  LOGObjectFnStart();
  objectsCount = [objects count];
  if (objectsCount>0)
    {
      result = YES;
      int i=0;
      for(i=0;i<objectsCount;i++)
        {
          id object=[objects objectAtIndex:i];
          if (![self _deleteObject:object])
            result = NO;
        };
    };
  LOGObjectFnStop();
  return result;
};

-(BOOL)_deleteObjectsAtIndexes:(NSArray*)indexes
{
  BOOL result=NO;
  int indexesCount = 0;

  LOGObjectFnStart();

  indexesCount = [indexes count];
  if (indexesCount>0)
    {
      NSArray* objects=[_displayedObjects objectsAtIndexes:indexes];
      result=[self _deleteObjects:objects];
    };

  LOGObjectFnStop();

  return result;
};

-(void)_insertObjectWithObjectAndIndex:(NSArray*)objectAndIndex
{
  id object=nil;
  NSNumber* indexObject=nil;
  int index=0;

  LOGObjectFnStart();

  NSAssert1([objectAndIndex count]==0,
            @"Bad Array : %@",objectAndIndex);

  object = [objectAndIndex objectAtIndex:0];

  indexObject = [objectAndIndex objectAtIndex:1];

  index = [indexObject intValue];

  [self insertObject:object
        atIndex:index];

  LOGObjectFnStop();
}

/** Returns 1st index of selection if any, -1 otherwise **/
-(int)_selectionIndex
{
  int index=-1;

  LOGObjectFnStart();

  if ([_selection count]>0)
    index=[[_selection objectAtIndex:0] intValue];

  LOGObjectFnStop();

  return index;
};

-(void)_lastObserverNotified:(id)object
{
  LOGObjectFnStart();
  _flags.didChangeContents = NO;
  _flags.didChangeSelection = NO;
  _updatedObjectIndex = -2;
  [EOObserverCenter notifyObserversObjectWillChange:nil];
  LOGObjectFnStop();
};


-(void)_beginObserverNotification:(id)object
{
  LOGObjectFnStart();
  if(!_flags.haveFetched && _flags.autoFetch)
    [self fetch];
  LOGObjectFnStop();
};

-(void)_notifySelectionChanged
{
  LOGObjectFnStart();

  _flags.didChangeSelection = YES;

  if (_delegateRespondsTo.didChangeSelection)
    [_delegate displayGroupDidChangeSelection:self];

  [self willChange];

  LOGObjectFnStop();
};

-(void)_notifyRowChanged:(int)row
{
  LOGObjectFnStart();

  if(row!=_updatedObjectIndex)
    _updatedObjectIndex = _updatedObjectIndex != -2 ? -1 : row;

  _flags.didChangeContents = YES;

  [self willChange];

  LOGObjectFnStop();
};

-(void)willChange
{
  [EOObserverCenter notifyObserversObjectWillChange:self];
  [EOObserverCenter notifyObserversObjectWillChange:nil];
}


-(id)_notify:(SEL)selector
        with:(id)object1
        with:(id)object2

{
  LOGObjectFnStart();
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
      LOGObjectFnNotImplemented();	//TODOFN
    };
  LOGObjectFnStop();
  return self; //??
};


-(id)_notify:(SEL)selector
        with:(id)object
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;
};


-(EOUndoManager*)undoManager
{
  EOUndoManager* undoManager=nil;
  LOGObjectFnStart();
  undoManager=(EOUndoManager*)[[_dataSource editingContext] undoManager];
  LOGObjectFnStop();
  return undoManager;
};

/** Called when objects invalidated in dataSource editing context **/
-(void)objectsInvalidatedInEditingContext:(NSNotification*)notification
{
  BOOL refetch = YES;
  LOGObjectFnStart();

  if(_delegateRespondsTo.shouldRefetchObjects == YES)
    refetch = [_delegate displayGroup:self
		    shouldRefetchForInvalidatedAllObjectsNotification:
		      notification];

  if(refetch == YES)
    [self fetch];
  LOGObjectFnStop();
}

/** Called when objects changed in dataSource editing context **/
-(void)objectsChangedInEditingContext:(NSNotification*)notification
{
  BOOL isAllObjectsChanged = NO;
  LOGObjectFnStart();
  
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
                        };
                    };
                };
            };
      
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
                    };
                  ASSIGN(_selection,([_displayedObjects 
                                       indexesOfObjectsIdenticalTo:_selectedObjects]));
                };
            };
        };
    };
  if (isAllObjectsChanged)
    [self redisplay];
  LOGObjectFnStop();
};

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
  NSDebugMLLog(@"gswdisplaygroup",@"globalDefaultStringMatchOperator=%@",globalDefaultStringMatchOperator);
  return globalDefaultStringMatchOperator;
}

+(void)setGlobalDefaultStringMatchOperator:(NSString*)operatorString
{
  ASSIGN(globalDefaultStringMatchOperator,operatorString);
  NSDebugMLLog(@"gswdisplaygroup",@"globalDefaultStringMatchOperator=%@",globalDefaultStringMatchOperator);
}

+(NSString*)globalDefaultStringMatchFormat
{
  NSDebugMLLog(@"gswdisplaygroup",@"globalDefaultStringMatchFormat=%@",globalDefaultStringMatchFormat);
  return globalDefaultStringMatchFormat;
}

+(void)setGlobalDefaultStringMatchFormat:(NSString*)format
{
  ASSIGN(globalDefaultStringMatchFormat,format);
  NSDebugMLLog(@"gswdisplaygroup",@"globalDefaultStringMatchFormat=%@",globalDefaultStringMatchFormat);
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
  LOGObjectFnStart();

  if(_numberOfObjectsPerBatch==0)
    batchCount=1;
  else
    {
      unsigned count = [_allObjects count];
      if(count==0)
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

- (void)setDataSource:(EODataSource *)dataSource
{
  LOGObjectFnStart();
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
        };

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
    };
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	defaultStringMatchFormat

- (NSString *)defaultStringMatchFormat
{
  NSDebugMLLog(@"gswdisplaygroup",@"_defaultStringMatchFormat=%@",_defaultStringMatchFormat);
  return _defaultStringMatchFormat;
}

//--------------------------------------------------------------------
//	defaultStringMatchOperator

- (NSString *)defaultStringMatchOperator
{
  NSDebugMLLog(@"gswdisplaygroup",@"_defaultStringMatchOperator=%@",_defaultStringMatchOperator);
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
  LOGObjectFnStart();
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
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	delete

- (id)delete
{
  LOGObjectFnStart();
  [self deleteSelection];
  [self displayBatchContainingSelectedObject];
  LOGObjectFnStop();
  return nil;//return nil for direct .gswd actions ==> same page
}

//--------------------------------------------------------------------
//	deleteObjectAtIndex:

- (BOOL)deleteObjectAtIndex:(unsigned)index
{
  BOOL result=NO;
  LOGObjectFnStart();
  [self endEditing];
  result=[self _deleteObject:[_allObjects objectAtIndex:index]];
  LOGObjectFnStop();
  return result;
};

//--------------------------------------------------------------------
//	deleteSelection

- (BOOL)deleteSelection
{
  BOOL result=NO;
  LOGObjectFnStart();
  [self endEditing];
  result=[self _deleteObjectsAtIndexes:[self selectionIndexes]];
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
  int newBatchIndex = 1;

  LOGObjectFnStart();

  int selectionIndex=[self _selectionIndex];

  if ([self batchCount]>0)
    newBatchIndex = selectionIndex / _numberOfObjectsPerBatch + 1;

  if(newBatchIndex!=_batchIndex)
    {
      [self setCurrentBatchIndex:newBatchIndex];
    };

  LOGObjectFnStop();
  return nil;
};

//--------------------------------------------------------------------
//	displayedObjects

/** Returns currently displayed objects for the current batch **/

- (NSArray *)displayedObjects
{
  NSArray* displayedObjects=nil;
  int displayedObjectsCount = 0;
  
  LOGObjectFnStart();

  GSWLogAssertGood(_displayedObjects);
  displayedObjectsCount = [_displayedObjects count];

  NSDebugMLLog(@"gswdisplaygroup",@"_numberOfObjectsPerBatch=%d",_numberOfObjectsPerBatch);
  NSDebugMLLog(@"gswdisplaygroup",@"displayedObjectsCount=%d",displayedObjectsCount);

  if (_numberOfObjectsPerBatch == 0 || _numberOfObjectsPerBatch>=displayedObjectsCount)
    displayedObjects=_displayedObjects;
  else
    {
      int currentBatchIndex = [self currentBatchIndex];
      int startIndex=(currentBatchIndex - 1) * _numberOfObjectsPerBatch;
      NSDebugMLLog(@"gswdisplaygroup",@"currentBatchIndex=%d",currentBatchIndex);
      NSDebugMLLog(@"gswdisplaygroup",@"startIndex=%d",startIndex);

      if( displayedObjectsCount > (currentBatchIndex * _numberOfObjectsPerBatch))
        displayedObjectsCount = currentBatchIndex * _numberOfObjectsPerBatch;
      NSDebugMLLog(@"gswdisplaygroup",@"displayedObjectsCount=%d",displayedObjectsCount);

      displayedObjects=[_displayedObjects subarrayWithRange:NSMakeRange(startIndex,displayedObjectsCount-startIndex)];
    };

  LOGObjectFnStop();

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
};

//--------------------------------------------------------------------
//	displayNextBatch

- (id)displayNextBatch
{
  LOGObjectFnStart();

  NSDebugMLLog(@"gswdisplaygroup",@"_numberOfObjectsPerBatch=%d",_numberOfObjectsPerBatch);
  if (_numberOfObjectsPerBatch>0)
    {
      [self setCurrentBatchIndex:_batchIndex+1];
      [self clearSelection];
    };

  LOGObjectFnStop();
  return nil;//return nil for direct .gswd actions ==> same page
}

//--------------------------------------------------------------------
//	displayPreviousBatch

- (id)displayPreviousBatch
{
  LOGObjectFnStart();

  if (_numberOfObjectsPerBatch>0)
    {
      [self setCurrentBatchIndex:_batchIndex-1];
      [self clearSelection];
    };

  LOGObjectFnStop();
  return nil;//return nil for direct .gswd actions ==> same page
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
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
  return nil;//return nil for direct .gswd actions ==> same page
};

//--------------------------------------------------------------------
//	fetch

- (id)fetch
{
  LOGObjectFnStart();

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
              NSAutoreleasePool* arp = nil;

              [[NSNotificationCenter defaultCenter] 
                postNotificationName:@"WODisplayGroupWillFetch" //TODO Name
                object:self];

              undoManager=[self undoManager];
              [undoManager removeAllActionsWithTarget:self];

              if (_flags.isCustomDataSourceClass 
                  && [_dataSource respondsToSelector:@selector(setQualifierBindings:)])
                {
                  [_dataSource setQualifierBindings:_queryBindings];
                };

              arp = [NSAutoreleasePool new];
              NS_DURING
                {
                  objects = [_dataSource fetchObjects];
                  [self setObjectArray:objects];
                  objects=nil;
                }
              NS_HANDLER
                {
                  NSLog(@"%@ (%@)",localException,[localException reason]);
                  LOGException(@"%@ (%@)",localException,[localException reason]);
                  RETAIN(localException);
                  DESTROY(arp);
                  AUTORELEASE(localException);
                  [localException raise];
                }
              NS_ENDHANDLER;
              DESTROY(arp);

              if (_delegateRespondsTo.didFetchObjects)
                [_delegate displayGroup:self
                           didFetchObjects:_allObjects];
            };
        };
    };
  LOGObjectFnStop();
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
  LOGObjectFnStart();

  indexOfFirstDisplayedObject=(([self currentBatchIndex]-1) * _numberOfObjectsPerBatch);

  LOGObjectFnStop();
  return indexOfFirstDisplayedObject;
}

//--------------------------------------------------------------------
//	indexOfLastDisplayedObject;

- (unsigned)indexOfLastDisplayedObject
{
  int indexOfLastDisplayedObject=0;
  int allObjectsCount=0;

  LOGObjectFnStart();

  allObjectsCount=[_allObjects count];  

  if (_numberOfObjectsPerBatch==0)
    indexOfLastDisplayedObject=allObjectsCount-1;
  else
    {
      int index = _numberOfObjectsPerBatch * [self currentBatchIndex];
      indexOfLastDisplayedObject=(allObjectsCount>index ? index : allObjectsCount-1);
    };

  LOGObjectFnStop();

  return indexOfLastDisplayedObject;
}

//--------------------------------------------------------------------
//	inQueryMode

- (BOOL)inQueryMode
{
  return (_savedAllObjects!=nil);
}

//--------------------------------------------------------------------
-(void)editingContext:(EOEditingContext*)editingContext
  presentErrorMessage:(NSString*)message
{
  LOGObjectFnStart();
  [self _presentAlertWithTitle:@"Editing Context Error"
        message:message];
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

  index=max(0,index);
  index=min(count,index);

  NSDebugMLog(@"INSERT Index=%d",index);
  [self insertObjectAtIndex:index];
  [self displayBatchContainingSelectedObject];

  LOGObjectFnStop();
  return nil;//return nil for direct .gswd actions ==> same page
}

//--------------------------------------------------------------------

- (id)insertAfterLastObject
{
  int index= [_allObjects count];
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
  LOGObjectFnStart();

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
                };
              [_displayedObjects insertObject:anObject
                                 atIndex:index];
              [_allObjects insertObject:anObject
                           atIndex:index];
              [self redisplay];
              
              if (_delegateRespondsTo.didInsertObject)
                [_delegate displayGroup:self
                           didInsertObject:anObject];
              [self selectObjectsIdenticalTo:[NSArray arrayWithObject:anObject]];
            };
        };
    };
}

//--------------------------------------------------------------------
//	insertNewObjectAtIndex:

- (id)insertNewObjectAtIndex:(unsigned)index
{
  id object=nil;
  LOGObjectFnStart();
  object=[self insertObjectAtIndex:index];
  LOGObjectFnStop();
  return object;
}

//--------------------------------------------------------------------
//	insertObjectAtIndex:

- (id)insertObjectAtIndex:(unsigned)index
{
  id object=nil;
  LOGObjectFnStart();

  if ([self endEditing])
    {
      NSDebugMLLog(@"gswdisplaygroup",@"Will [_dataSource createObject]");
      object = [_dataSource createObject];
      NSDebugMLLog(@"gswdisplaygroup",@"End [_dataSource createObject]. Object %p=%@",
                   object,object);
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
          NSDebugMLLog(@"gswdisplaygroup",@"Will insertObject:AtIndex:");
          [self insertObject:object
                atIndex:index];
          NSDebugMLLog(@"gswdisplaygroup",@"End insertObject:AtIndex:");
        };
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
- (EOQualifier *)_auxiliaryQueryQualifier
{
  return _auxiliaryQueryQualifier;
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
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdisplaygroup",@"_queryMatch=%@",
               _queryMatch);
  NSDebugMLLog(@"gswdisplaygroup",@"_queryNotMatch=%@",
               _queryNotMatch);
  NSDebugMLLog(@"gswdisplaygroup",@"_queryMin=%@",
               _queryMin);
  NSDebugMLLog(@"gswdisplaygroup",@"_queryMax=%@",
               _queryMax);
  NSDebugMLLog(@"gswdisplaygroup",@"_queryMinMatch=%@",
               _queryMinMatch);
  NSDebugMLLog(@"gswdisplaygroup",@"_queryMaxMatch=%@",
               _queryMaxMatch);
  NSDebugMLLog(@"gswdisplaygroup",@"_defaultStringMatchOperator=%@ EOQualifier sel:%p",
               _defaultStringMatchOperator,
               (void*)[EOQualifier operatorSelectorForString:_defaultStringMatchOperator]);

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

  NSDebugMLLog(@"gswdisplaygroup",@"array=%@",array);
  if ([array count]==1)
    resultQualifier=[array objectAtIndex:0];
  else if ([array count]>1)
    resultQualifier=[[[EOAndQualifier alloc] initWithQualifierArray:array] autorelease];
  NSDebugMLLog(@"gswdisplaygroup",@"resultQualifier=%@",resultQualifier);
  LOGObjectFnStop();
  return resultQualifier;
}

//--------------------------------------------------------------------
//	qualifyDataSource

- (void)qualifyDataSource
{
  EOQualifier* qualifier=nil;

  LOGObjectFnStart();

  NS_DURING //for trace purpose
    {
      SEL setQualifierSel=NULL;

      [self endEditing];

      [self setInQueryMode:NO];

      qualifier=[self qualifierFromQueryValues];
      NSDebugMLLog(@"gswdisplaygroup",@"qualifier=%@",qualifier);

      NSDebugMLLog(@"gswdisplaygroup",@"_dataSource=%@",_dataSource);
      if (_flags.isCustomDataSourceClass)
        {
          if ([_dataSource respondsToSelector:@selector(setAuxiliaryQualifier:)])
            setQualifierSel=@selector(setAuxiliaryQualifier:);
          else if ([_dataSource respondsToSelector:@selector(setQualifier:)])
            setQualifierSel=@selector(setQualifier:);
        };

      if (setQualifierSel)
        [_dataSource performSelector:setQualifierSel
                     withObject:qualifier];

      NSDebugMLLog0(@"gswdisplaygroup",@"Will fetch");
      [self fetch];
      NSDebugMLLog0(@"gswdisplaygroup",@"End fetch");

      [self setCurrentBatchIndex:1];
    }
  NS_HANDLER
    {
      NSLog(@"%@ (%@)",localException,[localException reason]);
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    }
  NS_ENDHANDLER;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	qualifyDisplayGroup

- (void)qualifyDisplayGroup
{
  EOQualifier* qualifier=nil;
  LOGObjectFnStart();
  [self setInQueryMode:NO];
  qualifier=[self qualifierFromQueryValues];
  NSDebugMLLog(@"gswdisplaygroup",@"qualifier=%@",qualifier);
  [self setQualifier:qualifier];

  NSDebugMLLog0(@"gswdisplaygroup",@"updateDisplayedObjects");
  [self updateDisplayedObjects];
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
  LOGObjectFnStart();
  [self _notifyRowChanged:-1];
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
  NSDebugMLLog(@"gswdisplaygroup",@"_selectedObjects count=%d",[_selectedObjects count]);
  if([_selectedObjects count]>0)
    obj=[_selectedObjects objectAtIndex:0];
  NSDebugMLLog(@"gswdisplaygroup",@"selectedObject=%@",obj);

  LOGObjectFnStop();
  return obj;
}

//--------------------------------------------------------------------
//	selectedObjects

- (NSArray *)selectedObjects
{
  if (!_selectedObjects)
    ASSIGN(_selectedObjects,([_displayedObjects objectsAtIndexes:_selection]));

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
  LOGObjectFnStart();

  if([_allObjects count]>0)
    {
      [self setSelectionIndexes:[NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:0]]];
    };

  LOGObjectFnStop();
  return nil;//return nil for direct .gswd actions ==> same page
};  

//--------------------------------------------------------------------
//	selectNext

- (id)selectNext
{
  LOGObjectFnStart();

  if ([_allObjects count]>0)
    {
      int nextIndex=0;
      if([_selection count]>0)
        {
          nextIndex=[[_selection objectAtIndex:0] intValue];
          nextIndex++;
          if (nextIndex>=[_displayedObjects count]) // passed the end
            nextIndex=0; // ==> back to the beginning
        };
      [self setSelectionIndexes:
              [NSArray arrayWithObject:
                         [NSNumber numberWithInt:nextIndex]]];
    };

  LOGObjectFnStop();
  return nil;//return nil for direct .gswd actions ==> same page
}

//--------------------------------------------------------------------
//	selectObject:

- (BOOL)selectObject:(id)object
{
  BOOL result=NO;
  LOGObjectFnStart();
  
  result=[self selectObjectsIdenticalTo:
                 [NSArray arrayWithObject:object]];

  LOGObjectFnStop();
  return result;
}

//--------------------------------------------------------------------
//	selectObjectsIdenticalTo:

- (BOOL)selectObjectsIdenticalTo:(NSArray *)objects
{ 
  BOOL result=NO;
  NSArray* selectionIndexes = nil;

  LOGObjectFnStart();
  GSWLogAssertGood(_displayedObjects);
  selectionIndexes = [_displayedObjects indexesOfObjectsIdenticalTo:objects];

  result = [self setSelectionIndexes:selectionIndexes];

  if([objects count]>0 && [selectionIndexes count]==0)
    result=NO;

  LOGObjectFnStop();
  return result;
}

//--------------------------------------------------------------------
//	selectObjectsIdenticalTo:selectFirstOnNoMatch:

- (BOOL)selectObjectsIdenticalTo:(NSArray *)objects
            selectFirstOnNoMatch:(BOOL)selectFirstOnNoMatch
{
  BOOL result=NO;
  NSArray* selectionIndexes = nil;

  LOGObjectFnStart();

  GSWLogAssertGood(_displayedObjects);
  GSWLogAssertGood(objects);
  NSDebugMLLog(@"gswdisplaygroup",@"_displayedObjects count]=%d",[_displayedObjects count]);
  NSDebugMLLog(@"gswdisplaygroup",@"objects count]=%d",[objects count]);
  selectionIndexes = [_displayedObjects indexesOfObjectsIdenticalTo:objects];
  NSDebugMLLog(@"gswdisplaygroup",@"selectionIndexes count]=%d",[selectionIndexes count]);

  if ([selectionIndexes count]==0)
    {
      if (selectFirstOnNoMatch && [_displayedObjects count]>0)
        selectionIndexes=[NSArray arrayWithObject:[NSNumber numberWithInt:0]];
    };
  NSDebugMLLog(@"gswdisplaygroup",@"selectionIndexes count]=%d",[selectionIndexes count]);
  result = [self setSelectionIndexes:selectionIndexes];
  NSDebugMLLog(@"gswdisplaygroup",@"selectionIndexes count]=%d",[selectionIndexes count]);

  LOGObjectFnStop();
  return result;
}

//--------------------------------------------------------------------
//	selectPrevious

- (id)selectPrevious
{
  LOGObjectFnStart();

  if ([_allObjects count]>0)
    {
      int previousIndex=0;
      if([_selection count]>0)
        {
          previousIndex=[[_selection objectAtIndex:0] intValue];
          previousIndex--;
          if (previousIndex<=0) // too low ?
            previousIndex=[_displayedObjects count]-1; // ==> to the end
        };
      [self setSelectionIndexes:
              [NSArray arrayWithObject:
                         [NSNumber numberWithInt:previousIndex]]];
    };

  LOGObjectFnStop();
  return nil;
}

//--------------------------------------------------------------------
//	selectsFirstObjectAfterFetch

- (BOOL)selectsFirstObjectAfterFetch
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _flags.selectFirstObject;
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

- (void)setCurrentBatchIndex:(unsigned)index
{
  LOGObjectFnStart();

  NSDebugMLLog(@"gswdisplaygroup",@"index=%d",index);
  NSDebugMLLog(@"gswdisplaygroup",@"_numberOfObjectsPerBatch=%d",_numberOfObjectsPerBatch);
  if(_numberOfObjectsPerBatch>0)
    {
      int batchCount=[self batchCount];
      NSDebugMLLog(@"gswdisplaygroup",@"batchCount=%d",batchCount);
      if (index<1)
        _batchIndex=(batchCount>0 ?  batchCount : 1);
      else if (index>batchCount)
        _batchIndex=1;
      else
        _batchIndex=index;
      NSDebugMLLog(@"gswdisplaygroup",@"_batchIndex=%d",_batchIndex);
    };
  LOGObjectFnStop();
}

-(void)_checkSelectedBatchConsistency
{
  LOGObjectFnStart();
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};


-(BOOL)_allowsNullForKey:(id)key
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
  // This must contains value format string
  NSRange range=[format rangeOfString:@"%@"];
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
    };
  NSDebugMLLog(@"gswdisplaygroup",@"_defaultStringMatchFormat=%@",_defaultStringMatchFormat);
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setDefaultStringMatchOperator:

- (void)setDefaultStringMatchOperator:(NSString *)operator
{
  LOGObjectFnStart();
  ASSIGN(_defaultStringMatchOperator, operator);
  NSDebugMLLog(@"gswdisplaygroup",@"_defaultStringMatchOperator=%@",_defaultStringMatchOperator);
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setDetailKey:

- (void)setDetailKey:(NSString *)detailKey
{
  LOGObjectFnStart();

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
// Deprectaed
- (void)setInQueryMode:(BOOL)flag
{
  LOGObjectFnStart();
  if( flag != [self inQueryMode])
    {
      if(flag)
        {
          GSWLogAssertGood(_allObjects);
          ASSIGN(_savedAllObjects,_allObjects);
          [self setObjectArray:[NSArray arrayWithObject:_queryMatch]];
          [self selectObject:_queryMatch];
        } 
      else
        {
          NSMutableArray* savedAllObjects=_savedAllObjects;
          GSWLogAssertGood(savedAllObjects);
          GSWLogAssertGood(_allObjects);
          RETAIN(savedAllObjects);
          AUTORELEASE(savedAllObjects);
          DESTROY(_savedAllObjects);
          [self setObjectArray:savedAllObjects];
        }
    }
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
/** sets query operators **/
-(void)setQueryOperator:(NSDictionary*)qo
{
  NSAssert1((!qo || [qo isKindOfClass:[NSDictionary class]]),
            @"queryOperator is not a dictionary but a %@",
            [qo class]);
  [_queryOperator removeAllObjects];
  if (qo)
    [_queryOperator addEntriesFromDictionary:qo];
};

-(void)setQueryKeyValueQualifierClassName:(NSDictionary*)qo
{
  NSAssert1((!qo || [qo isKindOfClass:[NSDictionary class]]),
            @"queryOperatorKeyValueClass is not a dictionary but a %@",
            [qo class]);
  [_queryKeyValueQualifierClassName removeAllObjects];
  if (qo)
    [_queryKeyValueQualifierClassName addEntriesFromDictionary:qo];
};


//--------------------------------------------------------------------
//	setMasterObject:

- (void)setMasterObject:(id)masterObject
{
  EODetailDataSource *source=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdisplaygroup",@"masterObject=%@",masterObject);
  if([self hasDetailDataSource] == YES)
    {
      source = (EODetailDataSource *)_dataSource;
      NSDebugMLLog(@"gswdisplaygroup",@"source=%@",source);
      NSDebugMLLog(@"gswdisplaygroup",@"[source detailKey]=%@",[source detailKey]);
      [_dataSource qualifyWithRelationshipKey:[source detailKey]
		  ofObject:masterObject];
      if ([self fetchesOnLoad])
        {
          NSDebugMLLog(@"gswdisplaygroup",@"will fetch");
          [self fetch];
        };
    };
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setNumberOfObjectsPerBatch:

- (void)setNumberOfObjectsPerBatch:(unsigned)count
{
  LOGObjectFnStart();
  if(count!=_numberOfObjectsPerBatch)
    {
      [self clearSelection];
      _numberOfObjectsPerBatch = count;
      _batchIndex = 1;
    };
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setObjectArray:

- (void)setObjectArray:(NSArray *)objects
{
  NSMutableArray* selectedObjects = nil;

  LOGObjectFnStart();

  GSWLogAssertGood(_allObjects);
  GSWLogAssertGood(objects);
  selectedObjects = (NSMutableArray*)[self selectedObjects];
  RETAIN(selectedObjects);
  AUTORELEASE(selectedObjects);
  GSWLogAssertGood(selectedObjects);
  NSDebugMLLog(@"gswdisplaygroup",@"selectedObjects count]=%d",[selectedObjects count]);
  NSDebugMLLog(@"gswdisplaygroup",@"_allObjects count]=%d",[_allObjects count]);
  NSDebugMLLog(@"gswdisplaygroup",@"objects count]=%d",[objects count]);

  if (objects)
    ASSIGN(_allObjects,[NSMutableArray arrayWithArray:objects]);
  else
    ASSIGN(_allObjects,[NSMutableArray array]);
  GSWLogAssertGood(selectedObjects);
  GSWLogAssertGood(_allObjects);
  NSDebugMLLog(@"gswdisplaygroup",@"selectedObjects count]=%d",[selectedObjects count]);
  NSDebugMLLog(@"gswdisplaygroup",@"_allObjects count]=%d",[_allObjects count]);

  [self updateDisplayedObjects];
  GSWLogAssertGood(selectedObjects);
  GSWLogAssertGood(_allObjects);
  NSDebugMLLog(@"gswdisplaygroup",@"selectedObjects count]=%d",[selectedObjects count]);
  NSDebugMLLog(@"gswdisplaygroup",@"_allObjects count]=%d",[_allObjects count]);

  [self selectObjectsIdenticalTo:selectedObjects
        selectFirstOnNoMatch:[self selectsFirstObjectAfterFetch]];

  [self redisplay];

  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setQualifier:

- (void)setQualifier:(EOQualifier *)qualifier
{
  LOGObjectFnStart();
  ASSIGN(_qualifier, qualifier);
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setAuxiliaryQueryQualifier:

- (void)setAuxiliaryQueryQualifier:(EOQualifier *)qualifier
{
  LOGObjectFnStart();
  ASSIGN(_auxiliaryQueryQualifier, qualifier);
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setSelectedObject:

- (void)setSelectedObject:(id)object
{
  LOGObjectFnStart();
  if (object)
    [self setSelectedObjects:[NSArray arrayWithObject:object]];
  else
    [self clearSelection];
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	setSelectedObjects:

- (void)setSelectedObjects:(NSArray *)objects
{
  LOGObjectFnStart();

  GSWLogAssertGood(objects);
  GSWLogAssertGood(_selectedObjects);
  GSWLogAssertGood(_selection);
  ASSIGN(_selectedObjects,([NSMutableArray arrayWithArray:objects]));
  ASSIGN(_selection,([_displayedObjects indexesOfObjectsIdenticalTo:_selectedObjects]));

  LOGObjectFnStop();
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

  LOGObjectFnStart();

  GSWLogAssertGood(selection);
  NSDebugMLLog(@"gswdisplaygroup",@"selection count]=%d",[selection count]);
  GSWLogAssertGood(_displayedObjects);
  NSDebugMLLog(@"gswdisplaygroup",@"_displayedObjects count]=%d",[_displayedObjects count]);
  if([selection count]>1)
    {
      sortedSelection = [selection sortedArrayUsingSelector:@selector(compare:)];
    }
  else if([_displayedObjects count]>0)
    sortedSelection = [NSArray arrayWithArray:selection];
  else
    sortedSelection = [NSArray array];
  NSDebugMLLog(@"gswdisplaygroup",@"sortedSelection count]=%d",[sortedSelection count]);

  selectedObjects = [[[_displayedObjects objectsAtIndexes:sortedSelection] mutableCopy]autorelease];
  NSDebugMLLog(@"gswdisplaygroup",@"selectedObjects count]=%d",[selectedObjects count]);
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
                };
              [self _notifySelectionChanged];
              retValue=YES;
            };
        };
    };
  NSDebugMLLog(@"gswdisplaygroup",@"_selection count]=%d",[_selection count]);

  LOGObjectFnStop();

  return retValue;
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
  NSMutableArray* selectedObjects = nil;
  NSArray* newDisplayedObjects = nil;

  LOGObjectFnStart();
  NSDebugMLLog(@"gswdisplaygroup",@"START updateDisplayedObjects");
  
  selectedObjects = (NSMutableArray*)[self selectedObjects];
  GSWLogAssertGood(selectedObjects);
  newDisplayedObjects = _allObjects;
  GSWLogAssertGood(newDisplayedObjects);
  NSDebugMLLog(@"gswdisplaygroup",@"[newDisplayedObjects count]=%d",
               [newDisplayedObjects count]);

  // Let's delegate doing the job ?
  if (_delegateRespondsTo.displayArrayForObjects == YES)
    {
      newDisplayedObjects = [_delegate displayGroup:self
                                       displayArrayForObjects:newDisplayedObjects];
    }
  else
    {
      NSDebugMLLog(@"gswdisplaygroup",@"_qualifier=%d",
                   _qualifier);
      // Filter ?
      if (_qualifier)
        {
          newDisplayedObjects=[newDisplayedObjects 
                                filteredArrayUsingQualifier:_qualifier];
          NSDebugMLLog(@"gswdisplaygroup",@"[newDisplayedObjects count]=%d",
                       [newDisplayedObjects count]);
        };
      NSDebugMLLog(@"gswdisplaygroup",@"_sortOrdering=%d",
                   _sortOrdering);
      // Sort ?
      if (_sortOrdering)
        {
          newDisplayedObjects=[newDisplayedObjects
                                sortedArrayUsingKeyOrderArray:_sortOrdering];
          NSDebugMLLog(@"gswdisplaygroup",@"[newDisplayedObjects count]=%d",
                       [newDisplayedObjects count]);
        };
    };
  ASSIGN(_displayedObjects,([NSMutableArray arrayWithArray:newDisplayedObjects]));
  NSDebugMLLog(@"gswdisplaygroup",@"[_displayedObjects count]=%d",
               [_displayedObjects count]);
  
  [self selectObjectsIdenticalTo:selectedObjects
        selectFirstOnNoMatch:NO];
  [self redisplay];
  NSDebugMLLog(@"gswdisplaygroup",@"STOP updateDisplayedObjects");
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

      NSDebugMLLog(@"gswdisplaygroup",@"_sortOrdering=%@",_sortOrdering);
      if(_sortOrdering)
        [_displayedObjects sortUsingKeyOrderArray:_sortOrdering];
    };
*/
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

#if HAVE_GDL2 // GDL2 implementation
//====================================================================
@implementation GSWDisplayGroup (Private)
-(void)finishInitialization
{
  LOGObjectFnStart();
  if (!_flags.isInitialized)
    {
      [self _setUpForNewDataSource];
      _flags.isInitialized=YES;
    };
  LOGObjectFnStop();
};

/** Returns YES if aClass equals EODetailDataSource or EOArrayDataSource class **/
-(BOOL)_isCustomDataSourceClass:(Class)aClass
{
  return (aClass!=[EODetailDataSource class]
          /*&& aClass!=[EOArrayDataSource class]*/); //EOArrayDataSource has to be added in GDL2
}

-(void)_setUpForNewDataSource
{
  LOGObjectFnStart();
  if(_dataSource)
    {
      // Set flags to detect customer dataSource
      _flags.isCustomDataSourceClass = [self _isCustomDataSourceClass:[_dataSource class]];

      // Add self as observer on dataSource editingContext
      EOEditingContext* editingContext = [_dataSource editingContext];
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
        };
    }
  LOGObjectFnStop();
};

//Deprecated
-(void)editingContext:(EOEditingContext*)editingContext
  presentErrorMessage:(NSString*)message
{
  [self _presentAlertWithTitle:@"Editing context error"
        message:message];
};

-(void)_presentAlertWithTitle:(NSString*)title
                      message:(NSString*)message
{
  LOGObjectFnStart();
  NSLog(@"%@ %@: %@",
        NSStringFromClass([self class]),
        title,message);
  LOGObjectFnStop();
};

-(void)_addQualifiersToArray:(NSMutableArray*)array
                   forValues:(NSDictionary*)values
            operatorSelector:(SEL)sel
{
  NSEnumerator *enumerator=nil;
  NSString *key=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdisplaygroup",@"array=%@",array);
  NSDebugMLLog(@"gswdisplaygroup",@"values=%@",values);
  NSDebugMLLog(@"gswdisplaygroup",@"operatorSelector=%p: %@",
               (void*)sel,
               NSStringFromSelector(sel));
  enumerator = [values keyEnumerator];
  while((key = [enumerator nextObject]))
    {
      EOQualifier* qualifier=nil;
      id value=[values objectForKey:key];
      NSDebugMLLog(@"gswdisplaygroup",@"key=%@ value=%@",key,value);
      qualifier=[self _qualifierForKey:key
                      value:value
                      operatorSelector:sel];
      NSDebugMLLog(@"gswdisplaygroup",@"qualifier=%@",qualifier);
      if (qualifier)
        [array addObject:qualifier];
    };
  NSDebugMLLog(@"gswdisplaygroup",@"array=%@",array);
  LOGObjectFnStop();
};


-(EOQualifier*)_qualifierForKey:(id)key
                          value:(id)value
               operatorSelector:(SEL)operatorSelector
{
  EOClassDescription* cd=nil;
  EOQualifier* qualifier=nil;
  NSException* validateException=nil;
  LOGObjectFnStart();

  NSDebugMLLog(@"gswdisplaygroup",@"value=%@",value);
  NSDebugMLLog(@"gswdisplaygroup",@"operatorSelector=%p: %@",
               (void*)operatorSelector,
               NSStringFromSelector(operatorSelector));

  // Get object class description
  cd=[_dataSource classDescriptionForObjects];

  // Validate the value against object class description
  validateException=[cd validateValue:&value
                        forKey:key];
  NSDebugMLLog(@"gswdisplaygroup",@"validateException=%@",validateException);

  if (validateException)
    {
      [validateException raise]; //VERIFY
    }
  else
    {
      NSString* qualifierClassName=[_queryKeyValueQualifierClassName objectForKey:key];
      Class qualifierClass=Nil;
      NSDebugMLLog(@"gswdisplaygroup",@"key=%@",key);
      NSDebugMLLog(@"gswdisplaygroup",@"_queryKeyValueQualifierClassName=%@",_queryKeyValueQualifierClassName);
      NSDebugMLLog(@"gswdisplaygroup",@"qualifierClassName=%@",qualifierClassName);
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
      NSDebugMLLog(@"gswdisplaygroup",@"operatorSelector=%p: %@",
                   (void*)operatorSelector,
                   NSStringFromSelector(operatorSelector));
      NSDebugMLLog(@"gswdisplaygroup",@"EOQualifierOperatorEqual=%p: %@",
                   (void*)EOQualifierOperatorEqual,
                   NSStringFromSelector(EOQualifierOperatorEqual));
      
      // If the selector is the equal operator
      if (sel_eq(operatorSelector, EOQualifierOperatorEqual))
        {
          // Search if there's a specific defined operator for it
          NSString* operatorString=[_queryOperator objectForKey:key];
          NSDebugMLLog(@"gswdisplaygroup",@"key=%@",key);
          NSDebugMLLog(@"gswdisplaygroup",@"_queryOperator=%@",_queryOperator);
          NSDebugMLLog(@"gswdisplaygroup",@"operatorString=%@",operatorString);
          NSDebugMLLog(@"gswdisplaygroup",@"[value isKindOfClass:[NSString class]]=%d",
                       [value isKindOfClass:[NSString class]]);

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
                  NSDebugMLLog(@"gswdisplaygroup",@"stringValue=%@",stringValue);
                  if ([stringValue length]==0)
                    {
                      // So ends here and we'll return a nil qualifier
                      key=nil; 
                      value=nil;
                      operatorString=nil;
                    }
                  else if ([operatorString length]==0) // ==> defaultStringMatchOperator with defaultStringMatchFormat
                    {
                      NSDebugMLLog(@"gswdisplaygroup",@"_defaultStringMatchFormat=%@",_defaultStringMatchFormat);
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
                    };
                };
            }
          else
            {
              NSDebugMLLog(@"gswdisplaygroup",@"! string value");
              if ([operatorString length]==0)
                operatorString = @"=";
            };
          NSDebugMLLog(@"gswdisplaygroup",@"operatorString=%@",operatorString);
          operatorSelector = [qualifierClass operatorSelectorForString:operatorString];
          NSDebugMLLog(@"gswdisplaygroup",@"operatorSelector=%p: %@",
                       (void*)operatorSelector,
                       NSStringFromSelector(operatorSelector));
        };
      NSDebugMLLog(@"gswdisplaygroup",@"%@ %@ %@",
                   key,
                   NSStringFromSelector(operatorSelector),
                   value);
      if (key || operatorSelector || value) // qualifier returned will be nil when we have to discard it
        {
          if (operatorSelector)
            {
              qualifier=[[[qualifierClass alloc]
                           initWithKey:key
                           operatorSelector:operatorSelector
                           value:value] autorelease];
              NSDebugMLLog(@"gswdisplaygroup",@"qualifier=%@",qualifier);
            }
          else
            {
              NSLog(@"Error: Qualifier (%@) null selector for %@ %@ %@. Discard it !",
                    qualifierClass,key,[_queryOperator objectForKey:key],value);
            };
        };
    };
  NSDebugMLLog(@"gswdisplaygroup",@"qualifier=%@",qualifier);
  return qualifier;
};
	
@end

#endif

@implementation NSArray (Indexes)
-(NSArray*)indexesOfObjectsIdenticalTo:(NSArray*)objects
{
  NSArray* indexes=nil;
  int selfCount=0;
  GSWLogAssertGood(objects);
  GSWLogAssertGood(self);
  NSDebugMLLog(@"gswdisplaygroup",@"objects count]=%d",[objects count]);
  NSDebugMLLog(@"gswdisplaygroup",@"self count]=%d",[self count]);
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
              unsigned int index=[self indexOfObjectIdenticalTo:object];
              if (index!=NSNotFound)
                {
                  NSNumber* indexObject=[NSNumber numberWithInt:(int)index];
                  if (tmpIndexes)
                    [tmpIndexes addObject:indexObject];
                  else
                    tmpIndexes=(NSMutableArray*)[NSMutableArray arrayWithObject:indexObject];
                };
            };
          if (tmpIndexes)
            indexes=[NSArray arrayWithArray:tmpIndexes];
        };
    };
  if (!indexes)
    indexes=[NSArray array];
  NSDebugMLLog(@"gswdisplaygroup",@"indexes count]=%d",[indexes count]);
  return indexes;
};

-(NSArray*)objectsAtIndexes:(NSArray*)indexes
{
  NSArray* objects=nil;
  int selfCount=0;
  GSWLogAssertGood(self);
  GSWLogAssertGood(indexes);
  NSDebugMLLog(@"gswdisplaygroup",@"indexes count]=%d",[indexes count]);
  NSDebugMLLog(@"gswdisplaygroup",@"self count]=%d",[self count]);
  selfCount=[self count];
  if ([self count]>0)
    {
      int indexesCount=[indexes count];
      if (indexesCount>0)
        {
          NSMutableArray* tmpObjects=nil;
          int i=0;
          for(i=0;i<indexesCount;i++)
            {
              id indexObject=[indexes objectAtIndex:i];
              int index=[indexObject intValue];
              if (index<selfCount)
                {
                  id object=[self objectAtIndex:index];
                  if (tmpObjects)
                    [tmpObjects addObject:object];
                  else
                    tmpObjects=(NSMutableArray*)[NSMutableArray arrayWithObject:object];
                };
            };
          if (tmpObjects)
            objects=[NSArray arrayWithArray:tmpObjects];
        };
    };
  if (!objects)
    objects=[NSArray array];
  NSDebugMLLog(@"gswdisplaygroup",@"objects count]=%d",[objects count]);
  return objects;
};
@end

