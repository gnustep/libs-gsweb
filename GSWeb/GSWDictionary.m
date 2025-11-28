/** GSWDictionary.m
 
 Copyright (C) 2007 Free Software Foundation, Inc.
 
 Written by:    David Wetzel <dave@turbocat.de>
 Date:     20-Dec-2017
 
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
 **/

#include <Foundation/Foundation.h>
#include "GSWDictionary.h"

#define GLUESTRING @"🎃"

@implementation GSWDictionary

-(void) dealloc
{
    DESTROY(_storageDict);
    
    [super dealloc];
}

+ (instancetype) dictionary
{
    return AUTORELEASE([[self alloc] init]);
}

- (instancetype) init
{
    self = [super init];
    _storageDict = [NSMutableDictionary new];
    
    return self;
}

- (NSUInteger) count
{
    return [_storageDict count];
}

- (NSString*) combindedKeyWithKeys:(NSString**) keys
                             count:(unsigned)count
{
    unsigned i = 0;
    NSMutableString * returnStr = [NSMutableString string];
    
    for (; i < count; i++) {
        [returnStr appendString:keys[i]];
        if (i< count -1) {
            [returnStr appendString:GLUESTRING];
        }
    }
    
    return returnStr;
}

- (NSString*) combindedKeyWithKeys:(NSArray*) keys
{
    return [keys componentsJoinedByString:GLUESTRING];
}

-(id) objectForKeys:(id*)keys
              count:(unsigned)count
{
    id object=nil;
    
    if (count == 0) {
        return nil;
    }
    object = [_storageDict objectForKey:[self combindedKeyWithKeys:keys
                                                             count:count]];
    return object;
}

-(id)objectForKeys:(id)keys,...;
{
    id object;
    
    GS_USEIDLIST(keys,object = [self objectForKeys:__objects
                                            count: __count]);
    return object;
}

-(id)objectForKeyArray:(NSArray*)keys
{
    id returnObj = nil;
    unsigned count = [keys count];
    if (count == 0) {
        return nil;
    }

    NSRange range = NSMakeRange(0, count);
    id * myKeys = malloc(sizeof(id) * range.length);
    [keys getObjects:myKeys range:range];
    returnObj = [self objectForKeys:myKeys
                              count:count];
    free(myKeys);
    
    return returnObj;
}


-(void)setObject:(id)object
         forKeys:(id)keys,...
{
    NSString * myKey;
    
    GS_USEIDLIST(keys,myKey = [self combindedKeyWithKeys:__objects
                                                   count: __count]);

    [_storageDict setObject:object
                     forKey:myKey];
}


-(void)setObject:(id)object
         forKeyArray:(NSArray*)keys
{
    unsigned count = [keys count];
    NSString * myKey;
    
    if ((!object) || (!keys) || (count < 1)) {
        [NSException raise:NSInvalidArgumentException
                    format:@"%s:need object and keys",__PRETTY_FUNCTION__];
    }
    
    NSRange range = NSMakeRange(0, count);
    id * myKeys = malloc(sizeof(id) * range.length);
    [keys getObjects:myKeys range:range];

    myKey = [self combindedKeyWithKeys:myKeys
                                 count:count];
    free(myKeys);
    [_storageDict setObject:object
                     forKey:myKey];
}

- (void)removeObjectForKeyArray:(NSArray*)keys
{
    unsigned count = [keys count];
    if ((!keys) || (count < 1)) {
        return;
    }
    NSString * myKey;
    NSRange range = NSMakeRange(0, count);
    id * myKeys = malloc(sizeof(id) * range.length);
    [keys getObjects:myKeys range:range];
    myKey = [self combindedKeyWithKeys:myKeys
                                 count:count];
    free(myKeys);

    [_storageDict removeObjectForKey:myKey];
}

- (void)removeObjectForKeys:(NSString*)keys,...
{
    NSString * myKey;
    
    GS_USEIDLIST(keys,myKey = [self combindedKeyWithKeys:__objects
                                                   count: __count]);

    [_storageDict removeObjectForKey:myKey];
}


@end
