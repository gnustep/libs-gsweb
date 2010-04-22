/** GSWRepetition.m - <title>GSWeb: Class GSWRepetition</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
   $Revision$
   $Date$
   
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
#include "GSWPrivate.h"

static SEL prepareIterationSEL=NULL;
static SEL objectAtIndexSEL = NULL;
static SEL setValueInComponentSEL = NULL;

//====================================================================
@implementation GSWRepetition

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWRepetition class])
    {
      prepareIterationSEL=@selector(_prepareIterationWithIndex:startIndex:stopIndex:list:listCount:listObjectAtIndexIMP:itemSetValueIMP:indexSetValueIMP:component:inContext:);
      objectAtIndexSEL=@selector(objectAtIndex:);
      setValueInComponentSEL=@selector(setValue:inComponent:);
    };
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{         
  self = [super initWithName:nil associations:nil template: template];
  if (!self) {
    return nil;
  }  

  ASSIGN(_list, [associations objectForKey: list__Key]);
  ASSIGN(_item, [associations objectForKey: item__Key]);
  ASSIGN(_count, [associations objectForKey: count__Key]);
  ASSIGN(_index, [associations objectForKey: index__Key]);

  if (!WOStrictFlag) {
    ASSIGN(_startIndex, [associations objectForKey: startIndex__Key]);
    ASSIGN(_stopIndex, [associations objectForKey: stopIndex__Key]);
  }

  if (_list == nil && _count == nil) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: Missing 'list' or 'count' attribute.",
                            __PRETTY_FUNCTION__];  
  }
  if (_list != nil && _item == nil) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: Missing 'item' attribute with 'list' attribute.",
                            __PRETTY_FUNCTION__];  
  }
  if (_list != nil && _count != nil) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: Illegal use of 'count' attribute with 'list' attribute.",
                            __PRETTY_FUNCTION__];  
  }
  if (_count != nil && (_list != nil || _item != nil)) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: Illegal use of 'list' or 'item' attribute with 'count' attribute.",
                            __PRETTY_FUNCTION__];    
  }
  if (_item != nil && (![_item isValueSettable])) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: The 'item' attribute must be settable.",
                            __PRETTY_FUNCTION__];    
  }
  if (_index != nil && (![_index isValueSettable])) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: The 'index' attribute must be settable.",
                            __PRETTY_FUNCTION__];    
  }

  return self;
};


//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_count);
  DESTROY(_index);
  DESTROY(_startIndex);
  DESTROY(_stopIndex);

  [super dealloc];
}

-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p list:%@ item:%@ count:%@ index:%@>",
                   object_getClassName(self),
                   (void*)self,
                   _list, _item, _count, _index];
};



static inline void _prepareForIterationWithIndex(int i, int j, NSArray * array, GSWContext * context, 
                                     GSWComponent *component, GSWAssociation* item, GSWAssociation* index)
{
  if (item != nil) {
    id obj = [array objectAtIndex:i];
    [item _setValueNoValidation:obj 
                    inComponent:component];
  }
  if (index != nil) {
    [index _setValueNoValidation:[NSNumber numberWithInt:i] 
                     inComponent:component];
  }
  if (i != 0) {
    [context incrementLastElementIDComponent];
  } else {
    [context appendZeroElementIDComponent];  
  }
}

static inline void _cleanupAfterIteration(GSWContext * context, 
                      GSWComponent * component, int i, GSWAssociation* item, GSWAssociation* index)
{
  if (item != nil) {
    [item _setValueNoValidation:nil 
                    inComponent:component];
  }
  if (index != nil) {
    [index _setValueNoValidation:[NSNumber numberWithInt:i] 
                     inComponent:component];
  }
  [context deleteLastElementIDComponent];  
}



//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  NSArray      * myArray = nil;
  NSNumber     * countValue = nil;
  unsigned int count = 0;
  unsigned int i = 0;
  
  if (_list != nil) {
    myArray = [_list valueInComponent:component];
    if (myArray != nil)
    count = [myArray count];
  } else {
    countValue = [_count valueInComponent:component];
    if (countValue != nil) {
      count = [countValue intValue];
    } 
  }
  for (i = 0; i < count; i++) {
    _prepareForIterationWithIndex(i, count, myArray, context, component,_item, _index);
    [super appendChildrenToResponse:response
              inContext:context];
  }

  if (count > 0) {
    _cleanupAfterIteration(context, component, count, _item, _index);
  }
}


static inline NSString* _indexStringForSenderAndElement(NSString * senderStr, NSString * elementStr)
{
  int elementLen = [elementStr length]+ 1;
  int senderLen = [senderStr length];
  
  NSRange myRange = [senderStr rangeOfString:@"." 
                                     options:0
                                       range:NSMakeRange(elementLen, (senderLen - elementLen))];
                                       

//  NSLog(@"elementLen:%d", elementLen);
//  NSLog(@"senderLen:%d", senderLen);

  if (myRange.location == NSNotFound) {
    return [senderStr substringFromIndex: elementLen];
  } else {
//  NSLog(@"found myRange.location:%d", myRange.location);
    return [senderStr substringWithRange: NSMakeRange(elementLen, myRange.location-elementLen)];
  }
  return nil;
}


-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  GSWElement   * element   = nil;
  NSString     * indexStr  = nil;

  NSString     * senderID     = [context senderID];
  NSString     * elementID    = [context elementID];
  NSArray      * arrayValue   = nil;
  id             currentValue = nil;
  int            count        = 0;
  int            k            = 0;
  
  if ([senderID hasPrefix:elementID]) {
    int i = [elementID length];
    // code taken from http://www.unicode.org/charts/PDF/U0000.pdf
    // '.'
    if (([senderID length] > i) && ([senderID characterAtIndex:i] == 0x002e)) {
      indexStr = _indexStringForSenderAndElement(senderID, elementID);
//      NSLog(@"indexStr is '%@' senderID:'%@' elementID:'%@'", indexStr, senderID, elementID);
    }
  }

  if (indexStr != nil) {
    int i = [indexStr intValue];
    if (_list != nil) {
      arrayValue = [_list valueInComponent:component];

      if (arrayValue != nil) {
          if ((i >= 0) && (i < [arrayValue count])) {
            currentValue = [arrayValue objectAtIndex:i];
          }
        if (_item != nil) {
          [_item _setValueNoValidation:currentValue
                           inComponent:component];
        }
      }
    }
    if (_index != nil) {
      [_index _setValueNoValidation:[NSNumber numberWithInt:i]
                        inComponent:component];
    }
    [context appendElementIDComponent: indexStr];
    element = [super invokeActionForRequest:request
                                  inContext:context];
    [context deleteLastElementIDComponent];
  } else {
    count = 0;

    if (_list != nil) {
      arrayValue = [_list valueInComponent:component];
      count =  [arrayValue count];
    } else {
      id countValue = [_count valueInComponent:component];
      if (countValue != nil) {
        count = [countValue intValue];    // or first into a string?
      } else {
       NSLog(@"%s:'count' evaluated to nil in component %@. Repetition count reset to zero.",
             __PRETTY_FUNCTION__, component);
      }
    }
    
    for (k = 0; k < count && element == nil; k++) {
      _prepareForIterationWithIndex(k, count, arrayValue, context, component, _item, _index);
      element = [super invokeActionForRequest:request
                                    inContext:context];
      
    }

    if (count > 0) {
      _cleanupAfterIteration(context, component, count, _item, _index);
    }
  }
  return element;
};

- (void) takeValuesFromRequest:(GSWRequest *) request
                     inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  NSArray      * arrayValue   = nil;
  id             countValue   = nil;
  int            i            = 0;

  int count = 0;

  if (_list != nil) {
    arrayValue = [_list valueInComponent:component];
    if (arrayValue != nil) {
      count = [arrayValue count];
    }
  } else {
    countValue = [_count valueInComponent:component];
    if (countValue != nil) {
      count = [countValue intValue];    // or first into a string?
    } else {
      NSLog(@"%s: 'count' evaluated to nil in %@. Resetting to zero. (%@)",
                              __PRETTY_FUNCTION__, component, _count);  
    }
  }
  for (i = 0; i < count; i++) {

    _prepareForIterationWithIndex(i, count, arrayValue, context, component,_item, _index);

    [super takeValuesFromRequest:request
                       inContext:context];
    
  }

  if (count > 0)
  {
    _cleanupAfterIteration(context, component, count, _item, _index);
  }
}



@end

