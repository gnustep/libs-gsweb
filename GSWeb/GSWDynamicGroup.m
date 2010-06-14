/** GSWDynamicGroup.m - <title>GSWeb: Class GSWDynamicGroup</title>

   Copyright (C) 2005-2006 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de>
   Date: Dec 2005
   
   $Revision: 1.17 $
   $Date: 2004/12/31 14:33:16 $

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

RCS_ID("$Id: GSWDynamicGroup.m,v 1.17 2004/12/31 14:33:16 mguesdon Exp $")

#include "GSWeb.h"

static Class GSWHTMLBareStringClass = Nil;

//====================================================================
@implementation GSWDynamicGroup

+ (void) initialize
{
  if (self == [GSWDynamicGroup class])
    {
      GSWHTMLBareStringClass = [GSWHTMLBareString class];
    };
};


+ (GSWDynamicGroup*) emptyGroup
{
  GSWDynamicGroup * theGroup = [GSWDynamicGroup alloc];
  
  theGroup = [theGroup initWithName:nil
                       associations:nil
                           template:nil];
  
  return AUTORELEASE(theGroup);
}


-(NSMutableArray*) childrenElements
{
  return _children;
}

- (void) _initChildrenFromTemplate:(GSWElement*) element
{
  NSMutableArray * array = nil;
  if (element) {
  
    // [element isKindOfClass:[GSWDynamicGroup class]] 
    if ([element isKindOfClass:[GSWHTMLStaticGroup class]]) {
      array = [(GSWDynamicGroup*) element childrenElements];
//NSLog(@"%s element is %@ array is %@", __PRETTY_FUNCTION__, element, array);      
    }
    // normally, this should be called only if the above isKindOfClass is NO.
    // BUT some elements seem be parsed wrong/different than in WO.
    if (array == nil) {
      array = [NSMutableArray array];
      [array addObject:element];
    }
  }
  DESTROY(_children);
  if ((array) && ([array count] > 0)) {
    ASSIGN(_children,array);
  }
}


-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  id ourid = [super initWithName:nil
                    associations:nil   
                        template:nil];
                   
  if (! ourid) {
    [self release];
    return nil;
  }                 
                           
  [ourid _initChildrenFromTemplate:template];
  
  return ourid;
}

// YES it is called like that
// initWithName:associations:contentElements
// NOT initWithName: attributeAssociations: contentElements:

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSMutableArray*) children
{
  id ourid = [super initWithName:nil
                associations:nil   
                   template:nil];

  DESTROY(_children);

  if (! ourid) {
    [self release];
    return nil;
  }                 
                           
  if ((children) && ([children count] > 0)) {
    ASSIGN(_children, children);
  }
  return ourid;
}

-(void) dealloc
{
  DESTROY(_children);

  [super dealloc];
}

-(void) addChildElement:(id) element
{
  if (_children == nil) {
    _children = [NSMutableArray new];
  }
  [_children addObject:element];
}

- (BOOL) hasChildrenElements
{
  return ((_children != nil) && ([_children count] > 0));
}

-(void) takeChildrenValuesFromRequest:(GSWRequest*)request
                            inContext:(GSWContext*)aContext
{
  if ([self hasChildrenElements]) {
    int i = [_children count];
    int j = 0;

    [aContext appendZeroElementIDComponent];
    
    for (; j < i; j++) {
      GSWElement * element = [_children objectAtIndex:j];
      [element takeValuesFromRequest: request 
                           inContext: aContext];
      [aContext incrementLastElementIDComponent];
    }

    [aContext deleteLastElementIDComponent];
  }
}

-(void) takeValuesFromRequest:(GSWRequest*)request
                    inContext:(GSWContext*)aContext

{
  [self takeChildrenValuesFromRequest:request
                            inContext:aContext];
}

-(id <GSWActionResults>) invokeChildrenAction:(GSWRequest*)request
                                    inContext:(GSWContext*)aContext

{
  id actionresults = nil;
  if ([self hasChildrenElements]) {
    int kidsCount = [_children count];
    int j = 0;
    
    [aContext appendZeroElementIDComponent];

    for (; (j < kidsCount) && (actionresults == nil); j++) {
      GSWElement * element = [_children objectAtIndex:j];
      if ([element class] != GSWHTMLBareStringClass) {
      
        actionresults = [element invokeActionForRequest: request 
                                              inContext: aContext];
      }
      [aContext incrementLastElementIDComponent];
    }
    [aContext deleteLastElementIDComponent];
  }
  return actionresults;
}

-(id <GSWActionResults>) invokeActionForRequest:(GSWRequest*)request
                                    inContext:(GSWContext*)aContext
{
  return [self  invokeChildrenAction:request
                           inContext:aContext];
}

-(void) appendChildrenToResponse:(GSWResponse*) response
                       inContext:(GSWContext*)aContext
{
  if ([self hasChildrenElements]) {
    int kidsCount = [_children count];
    int j = 0;
    
    [aContext appendZeroElementIDComponent];

    for (; j < kidsCount; j++) {
      GSWElement * element = [_children objectAtIndex:j];
      [element appendToResponse: response
                      inContext: aContext];
      
      [aContext incrementLastElementIDComponent];
    }
    [aContext deleteLastElementIDComponent];
  }
}

-(void) appendToResponse:(GSWResponse*) response
               inContext:(GSWContext*)aContext
{
  [self appendChildrenToResponse: response
                       inContext: aContext];
}

-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p children:%@>",
                   object_getClassName(self),
                   (void*)self,
                   _children];
};


@end
