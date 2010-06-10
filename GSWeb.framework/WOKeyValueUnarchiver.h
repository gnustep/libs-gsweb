/* -*-objc-*-
 WOKeyValueUnarchiver.h <title>GSWeb: Class WOKeyValueUnarchiver</title>
 
 Copyright (C) 2010 Free Software Foundation, Inc.
 
 Written by:	David Wetzel <dave@turbocat.de>
 
 $Revision: 30607 $
 $Date: 2010-06-07 11:49:24 -0700 (Mo, 07 Jun 2010) $
 $Id: GSWComponent.m 30607 2010-06-07 18:49:24Z dwetzel $
 
 <abstract>
 Basically the same we find in GDL's EOKeyValueUnarchiver.
 Because we might want applications without database, we 
 need it here too.
 </abstract>
 
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

#ifndef __WOKeyValueUnarchiver_h__
#define __WOKeyValueUnarchiver_h__

#ifdef GNUSTEP
#include <Foundation/NSObject.h>
#include <Foundation/NSHashTable.h>
#else
#include <Foundation/Foundation.h>
#endif

@interface WOKeyValueUnarchiver : NSObject 
{
  NSDictionary   *_propertyList;
  id              _parent;
  id              _nextParent;
  NSMutableArray *_allUnarchivedObjects;
  id              _delegate;
  NSHashTable    *_awakenedObjects;
}

- (id)initWithDictionary: (NSDictionary *)dictionary;

- (id)decodeObjectForKey: (NSString *)key;

- (id)decodeObjectReferenceForKey: (NSString *)key;

- (BOOL)decodeBoolForKey: (NSString *)key;

- (int)decodeIntForKey: (NSString *)key;

- (BOOL)isThereValueForKey: (NSString *)key;

- (void)ensureObjectAwake: (id)object;

- (void)finishInitializationOfObjects;

- (void)awakeObjects;

- (id)parent;

- (void)setDelegate: (id)delegate;
- (id)delegate;

- (id)_findTypeForPropertyListDecoding: (id)obj;
- (id)_dictionaryForPropertyList: (NSDictionary *)propList;
- (id)_objectsForPropertyList: (NSArray *)propList;
- (id)_objectForPropertyList: (NSDictionary *)propList;

@end

@interface NSObject (WOKeyValueUnarchiverDelegation)

- (id) unarchiver: (WOKeyValueUnarchiver *)archiver objectForReference: (id)keyPath;

@end

@protocol WOKeyValueArchiving

- (id)initWithKeyValueUnarchiver: (WOKeyValueUnarchiver *)unarchiver;

@end

@interface NSObject(WOKeyValueArchivingAwakeMethods)

- (void)finishInitializationWithKeyValueUnarchiver: (WOKeyValueUnarchiver *)unarchiver;

- (void)awakeFromKeyValueUnarchiver: (WOKeyValueUnarchiver *)unarchiver;

@end 

#endif // __WOKeyValueUnarchiver_h__
