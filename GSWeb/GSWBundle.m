/** GSWBundle.m -  <title>GSWeb: Class GSWBundle</title>
 
 Copyright (C) 1999-2004 Free Software Foundation, Inc.
 
 Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
 Date: 	Mar 1999
 Written by: David Wetzel <dave@turbocat.de>
 
 $Revision$
 $Date$
 $Id$
 
 <abstract></abstract>
 
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
#include <GNUstepBase/NSObject+GNUstepBase.h>
#include "WOKeyValueUnarchiver.h"
#include <GNUstepBase/GSMime.h>



@implementation NSBundle (WOResourceManagement)

-(void)initializeObject:(id)anObject
            fromArchive:(NSDictionary*)anArchive
{
    NSDictionary          * variableDefinitions = nil;
    WOKeyValueUnarchiver  * unarchiver;
    
    unarchiver = [[WOKeyValueUnarchiver alloc] initWithDictionary: anArchive];
    AUTORELEASE(unarchiver);
    
    [unarchiver setDelegate:anObject];
    
    variableDefinitions = (NSDictionary*) [unarchiver decodeObjectForKey:@"variables"];
    [unarchiver finishInitializationOfObjects];
    [unarchiver awakeObjects];
    
    if (variableDefinitions)
    {
      NSString     * varName;
      id             varValue;
      NSEnumerator * keyEnumer = [variableDefinitions keyEnumerator];
      
      while ((varName = [keyEnumer nextObject])) {
        varValue = [variableDefinitions objectForKey:varName];
        
        [anObject setValue:varValue
                    forKey:varName];
      }
    }
}

@end


@implementation GSWBundleUnarchiverDelegate

- (void) dealloc
{
  [super dealloc];
}

- (id) unarchiver:(NSKeyedUnarchiver*)unarchiver objectForReference:(NSString*)keyPath
{
  return [_object valueForKeyPath:keyPath];
}

- (id) initWithObject:(id)object
{
  if ((self=[super init]))
    {
      _object=object;
    }
  return self;
}

@end


