/* GSWDisplayGroup.m - GSWeb: Class GSWDisplayGroup
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
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


