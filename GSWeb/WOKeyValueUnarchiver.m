/* -*-objc-*-
 WOKeyValueUnarchiver.m
 
 Copyright (C) 2010 Free Software Foundation, Inc.
 
 Written by:	David Wetzel <dave@turbocat.de>
 
 $Revision: 30607 $
 $Date: 2010-06-07 11:49:24 -0700 (Mo, 07 Jun 2010) $
 $Id: GSWComponent.m 30607 2010-06-07 18:49:24Z dwetzel $
  
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

#ifdef GNUSTEP
#include <Foundation/NSArray.h>
#include <Foundation/NSDebug.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSEnumerator.h>
#include <Foundation/NSException.h>
#include <Foundation/NSString.h>
#include <Foundation/NSValue.h>
#else
#include <Foundation/Foundation.h>
#endif

#ifndef GNUSTEP
#include <GNUstepBase/GNUstep.h>
#include <GNUstepBase/NSObject+GNUstepBase.h>
#include <GNUstepBase/NSDebug+GNUstepBase.h>
#endif

#include "WOKeyValueUnarchiver.h"

@interface WOKeyValueArchivingContainer : NSObject
{
  id _object;
  id _parent;
  NSDictionary * _propertyList;
}

+ (WOKeyValueArchivingContainer*)keyValueArchivingContainer;
- (void) setPropertyList: (id)propList;
- (id) propertyList;
- (void) setParent: (id)parent;
- (id) parent;
- (void) setObject: (id)object;
- (id) object;

@end

@implementation WOKeyValueArchivingContainer

+ (void)initialize
{
}

+ (WOKeyValueArchivingContainer *)keyValueArchivingContainer
{
  return [[[self alloc] init] autorelease];
}

- (void) setPropertyList: (id)propList
{
  ASSIGN(_propertyList, propList);
}

- (id) propertyList
{
  return _propertyList;
}

- (void) setParent: (id)parent
{
  _parent = parent;
}

- (id) parent
{
  return _parent;
}

- (void) setObject: (id)object
{
  ASSIGN(_object, object);
}

- (id) object
{
  return _object;
}

- (void) dealloc
{
  DESTROY(_object);
  _parent = nil;
  DESTROY(_propertyList);
  
  [super dealloc];
}

@end

@implementation WOKeyValueUnarchiver

/** Inits unarchiver with propertyList 'dictionary' **/
- (id) initWithDictionary: (NSDictionary*)dictionary
{
  if ((self = [super init]))
  {
    ASSIGN(_propertyList, dictionary);
    _allUnarchivedObjects = [NSMutableArray array];
    
    RETAIN(_allUnarchivedObjects);
  }
  
  return self;
}

/** Finalize unarchiving by calling finishInitializationWithKeyValueUnarchiver:
 on all unarchived objects **/
- (void) finishInitializationOfObjects
{
  int i;
  int count = [_allUnarchivedObjects count];
  
  for (i = 0; i < count; i++)
  {
    WOKeyValueArchivingContainer *container;
    id object;
    
    container = [_allUnarchivedObjects objectAtIndex: i];
    object = [container object];
    
    
    
    [object finishInitializationWithKeyValueUnarchiver: self];
  }
}

- (void) dealloc
{
  DESTROY(_propertyList);
  DESTROY(_allUnarchivedObjects);
  
  if (_awakenedObjects)
    NSFreeHashTable(_awakenedObjects);
    
    [super dealloc];
}

/** Finalize unarchiving by calling awakeFromKeyValueUnarchiver: 
 on all unarchived objects **/
- (void) awakeObjects
{
  int i;
  int count = [_allUnarchivedObjects count];
  
  if (!_awakenedObjects)
    _awakenedObjects = NSCreateHashTable(NSNonRetainedObjectHashCallBacks,
                                         count);
    
    for (i = 0; i < count; i++)
    {
      WOKeyValueArchivingContainer *container;
      id object;
      
      
      
      container = [_allUnarchivedObjects objectAtIndex: i];
      object = [container object];
      
      [self ensureObjectAwake:object];
    }
}

/** ensure 'object' is awake 
 (has received -awakeFromKeyValueUnarchiver: message) **/
- (void) ensureObjectAwake: (id)object
{
  if (object)
  {
    if (!NSHashInsertIfAbsent(_awakenedObjects, object))
    {
      
      
      [object awakeFromKeyValueUnarchiver: self];
    }
  }
}

/** Returns unarchived integer which was archived as 'key'.
 0 if no object is found **/
- (int) decodeIntForKey: (NSString*)key
{
  id object = nil;
  
  
  
  object = [_propertyList objectForKey: key];
  
  return (object ? [object intValue] : 0);
}

/** Returns unarchived boolean which was archived as 'key'.
 NO if no object is found **/
- (BOOL) decodeBoolForKey: (NSString*)key
{
  id object=nil;
  
  
  
  object = [_propertyList objectForKey: key];
  
  return (object ? [[_propertyList objectForKey: key] boolValue] : NO);
}

/** Returns unarchived object for the reference archived as 'key'. 
 The receiver gets the object for reference by calling 
 its delegate method -unarchiver:objectForReference: **/
- (id) decodeObjectReferenceForKey: (NSString*)key
{
  id objectReference = nil;
  id object;
  
  
  
  object = [self decodeObjectForKey: key];
  
  if (object)
  {
    objectReference = [_delegate unarchiver: self
                         objectForReference: object];
  }
  
  return objectReference;
}

/** Returns unarchived object for key. 
 The object should be a NSString, NSData, NSArray or NSDictionary or its 
 class instances should implements -initWithKeyValueUnarchiver: **/
- (id) decodeObjectForKey: (NSString*)key
{
  id propListObject;
  id obj = nil;
  
  
  
  propListObject = [_propertyList objectForKey: key];
  
  
  if (propListObject)
  {
    obj = [self _findTypeForPropertyListDecoding: propListObject];
  }
  
  
  
  return obj;
}

/** Returns YES if there's a value for key 'key' **/
- (BOOL) isThereValueForKey: (NSString *)key
{
  return ([_propertyList objectForKey: key] != nil);
}

- (id) _findTypeForPropertyListDecoding: (id)obj
{
  id retVal = nil;
  
  
  
  if ([obj isKindOfClass: [NSDictionary class]])
  {
    NSString *className = [obj objectForKey: @"class"];
    
    if (className)
      retVal = [self _objectForPropertyList: obj];
    else
      retVal = [self _dictionaryForPropertyList: obj];
    
    if (!retVal)
    {
      //TODO
      
    }
  }
  else if ([obj isKindOfClass: [NSArray class]])
    retVal = [self _objectsForPropertyList: obj];
    else
      retVal=obj;
      
      return retVal;
}

- (id) _dictionaryForPropertyList: (NSDictionary*)propList
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSEnumerator *enumerator = [propList keyEnumerator];
  id key;
  
  while ((key = [enumerator nextObject]))
  {
    id object;
    id retObject;
    
    
    
    object = [propList objectForKey: key];
    
    
    retObject = [self _findTypeForPropertyListDecoding: object];
    
    
    if (!retObject)
    {
      
      //TODO
    }
    else
      [dict setObject: retObject
               forKey: key];
  }
  
  return dict;
}

- (id) _objectsForPropertyList: (NSArray*)propList
{
  NSMutableArray *newObjects = [NSMutableArray array];
  id              object = nil;
  NSEnumerator	 *propListEnum;
  id		  propListObject;
  
  
  
  if (propList && (propListEnum = [propList objectEnumerator]))
  {
    while ((propListObject = [propListEnum nextObject]))
    {
      object = [self _findTypeForPropertyListDecoding: propListObject];
      
      if (object)
	    {
	      [newObjects addObject: object];
	    }
    }
  }
  
  
  
  return newObjects;
}

- (id) _objectForPropertyList: (NSDictionary*)propList
{
  WOKeyValueArchivingContainer *container = nil;
  NSString *className = nil;
  Class objectClass = Nil;
  id object = nil;
  NSDictionary *oldPropList = AUTORELEASE(_propertyList);
  
  _propertyList = RETAIN(propList); //Because dealloc may try to release it
  
  
  
  NS_DURING
  {
    className = [propList objectForKey: @"class"];
    objectClass = NSClassFromString(className);  
    
    NSAssert1(objectClass, @"ERROR: No class named '%@'", className);
    
    object = [[[objectClass alloc] initWithKeyValueUnarchiver: self]
              autorelease];
    container = [WOKeyValueArchivingContainer keyValueArchivingContainer];
    
    [container setObject: object];
    [container setParent: nil]; //TODO VERIFY
    [container setPropertyList: propList];
    
    [_allUnarchivedObjects addObject: container];
  }
  NS_HANDLER
  {
    NSDebugMLLog(@"gsdb", @"WOKeyValueUnarchiver" @"EXCEPTION:%@ (%@) [%s %d]",
                 localException,
                 [localException reason],
                 __FILE__,
                 __LINE__);
    
    //Restaure the original propertyList
    _propertyList = RETAIN(oldPropList);
    
    AUTORELEASE(propList);
    [localException raise];
  }
  NS_ENDHANDLER;
  
  _propertyList = RETAIN(oldPropList);
  
  AUTORELEASE(propList);
  
  
  
  
  return object;
}

/** Returns the parent object for the currently unarchiving object. 
 **/
- (id) parent
{
  return _parent;
}

/** Returns receiver's delegate **/
- (id) delegate
{
  return _delegate;
}

/** Set the receiver's delegate **/
- (void) setDelegate:(id)delegate
{
  _delegate=delegate;
}

@end


@implementation NSObject (WOKeyValueUnarchiverDelegation)

/** 
 * Returns an object for archived 'reference'.
 * Implemented by WOKeyValueUnarchiver's delegate.
 */
- (id)unarchiver: (WOKeyValueUnarchiver*)archiver 
objectForReference: (id)keyPath
{
  [self subclassResponsibility:_cmd];
  return nil;
}

@end


@implementation NSObject(WOKeyValueArchivingAwakeMethods) 

- (void)finishInitializationWithKeyValueUnarchiver: (WOKeyValueUnarchiver *)unarchiver
{
  //Does nothing ?
  return;
}

- (void)awakeFromKeyValueUnarchiver: (WOKeyValueUnarchiver *)unarchiver
{
  //Does nothing ?
  return;
}

@end 
