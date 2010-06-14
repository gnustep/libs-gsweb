/** GSWCheckBoxList.m - <title>GSWeb: Class GSWCheckBoxList</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$

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

/**
Bindings

	list		Array of objects that the dynamic element iterate through.

        index		On each iteration the element put the current index in this binding

        item		On each iteration the element take the item at the current index and put it in this binding

        displayString  	String to display for each check box.

        value		Value for the INPUT tag for each check box

        prefix		An html string to insert before each value.

        suffix		An html string to insert after each value.

        selections	Array of selected objects (used to pre-check checkboxes and modified to reflect user choices)
        			It contains  objects from list, not value binding evaluated ones !

        selectionValues	Array of selected values (used to pre-check checkboxes and modified to reflect user choices)
        			It contains evaluated values binding !

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the check box appear inactivated.

        escapeHTML	If evaluated to yes, escape displayString

        isDisplayStringBefore If evaluated to no, displayString is displayed after radio button. 
**/

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWCheckBoxList

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWCheckBoxList class])
    {
      standardClass=[GSWCheckBoxList class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{         
  self = [super initWithName:aName associations:associations template: template];
  if (!self) {
    return nil;
  }  

  _loggedSlow = NO;

  ASSIGN(_list, [_associations objectForKey: list__Key]);
  if (_list != nil) {
    [_associations removeObjectForKey: list__Key];
  }
  ASSIGN(_item, [_associations objectForKey: item__Key]);
  if (_item != nil) {
    [_associations removeObjectForKey: item__Key];
  }
  ASSIGN(_index, [_associations objectForKey: index__Key]);
  if (_index != nil) {
    [_associations removeObjectForKey: index__Key];
  }
  ASSIGN(_selections, [_associations objectForKey: selections__Key]);
  if (_selections != nil) {
    [_associations removeObjectForKey: selections__Key];
  }
  ASSIGN(_prefix, [_associations objectForKey: prefix__Key]);
  if (_prefix != nil) {
    [_associations removeObjectForKey: prefix__Key];
  }
  ASSIGN(_suffix, [_associations objectForKey: suffix__Key]);
  if (_suffix != nil) {
    [_associations removeObjectForKey: suffix__Key];
  }
  ASSIGN(_displayString, [_associations objectForKey: displayString__Key]);
  if (_displayString != nil) {
    [_associations removeObjectForKey: displayString__Key];
  }
  ASSIGN(_escapeHTML, [_associations objectForKey: escapeHTML__Key]);
  if (_escapeHTML != nil) {
    [_associations removeObjectForKey: escapeHTML__Key];
  }

  if (_displayString == nil) {
    ASSIGN(_displayString, [_associations objectForKey: value__Key]);
    if (_displayString != nil) {
      [_associations removeObjectForKey: value__Key];
    }
    _defaultEscapeHTML = NO;
  } else {
    _defaultEscapeHTML = YES;
  }


  if ((_list == nil) || ((_value != nil || _displayString != nil) && ((_item == nil) || (![_item isValueSettable]))) || 
      ((_selections != nil) && (![_selections isValueSettable]))) {

    [NSException raise:NSInvalidArgumentException
                format:@"%s: 'list' must be present. 'item' must not be a constant if 'displayString' or 'value' is present.  'selection' must not be a constant if present.",
                            __PRETTY_FUNCTION__];  
  }

  return self;
}


-(void)dealloc
{
  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_index);
  DESTROY(_selections);
  DESTROY(_prefix);
  DESTROY(_suffix);
  DESTROY(_displayString);

  [super dealloc];
}

-(id) description
{
  return [NSString stringWithFormat:@"<%s %p list:%@ item:%@ index:%@ selections:%@ prefix:%@ suffix:%@ displayString:%@ escapeHTML:%@>",
                   object_getClassName(self),
                   (void*)self, 
                   _list, _item, _index,
                   _selections, _prefix, _suffix, _displayString, _escapeHTML];
}

-(NSString*)elementName
{
  return @"input";
}


-(void)_slowTakeValuesFromRequest:(GSWRequest*)request
			inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  if ((_selections != nil) && (![self disabledInComponent:component]) && ([context _wasFormSubmitted])) {    
    NSString * ctxName = [self nameInContext:context];
    NSArray * formValues = [request formValuesForKey: ctxName];
    NSMutableArray * mutArray = nil;
    int              count    = 0;
    int              count2    = 0;
    int              i        = 0;
    
    if ((formValues != nil) && (count = [formValues count])) {
      mutArray = [NSMutableArray arrayWithCapacity:count];
    } else {
      mutArray = [NSMutableArray arrayWithCapacity:5];
    }  

    if ((formValues != nil) && (count > 0)) {
      
      id listValue = [_list valueInComponent:component];
      
      if ([listValue isKindOfClass:[NSArray class]] == NO) {
        [NSException raise:NSInvalidArgumentException
                    format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
                            __PRETTY_FUNCTION__, [listValue class]];  
      }
      
      count2 = [listValue count];

      for (i = 0; i < count2; i++) {
        id obj1 = [(NSArray*) listValue objectAtIndex:i];
        id obj2 = nil;

        [_item setValue:obj1 inComponent: component];

        obj2= [_value valueInComponent:component];
        if (obj2 != nil) {
          if ([formValues containsObject:obj2]) {
            [mutArray addObject:obj1];
          }
        } else {
          NSLog(@"%s 'value' evaluated to nil in component %@.\nUnable to select item %@",
                __PRETTY_FUNCTION__, self, obj1);
        }
      }

    }
    [_selections setValue:mutArray inComponent: component];
  }
}

-(void)_fastTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  
  if ((_selections != nil) && (![self disabledInComponent:component]) && ([context _wasFormSubmitted])) {    

    NSString       * ctxName = [self nameInContext:context];
    NSArray        * formValues = [request formValuesForKey: ctxName];
    int              count = 0;
    int              i = 0;
    NSMutableArray * mutablearray;
    
    count = (formValues == nil) ? 0 : [formValues count];
    mutablearray = [NSMutableArray arrayWithCapacity:count];


    if (count > 0) {
      id listValue = [_list valueInComponent:component];
      
      if ([listValue isKindOfClass:[NSArray class]] == NO) {
        [NSException raise:NSInvalidArgumentException
                    format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
                            __PRETTY_FUNCTION__, [listValue class]];  
      }

      for (i = 0; i < count; i++) {
        int j = [NSStringWithObject([formValues objectAtIndex:i]) intValue];
        [mutablearray addObject:[listValue objectAtIndex:j]];
      }
    }
    [_selections setValue:mutablearray inComponent: component];
  }
}

-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  int            count           = 0;
  int            j               = 0;
  GSWComponent * component       = GSWContext_component(context);
  BOOL           doEscape;
  NSString     * ctxName         = [self nameInContext:context];
  id             listValue       = [_list valueInComponent:component];
  id             selectionsValue = nil;
  
  doEscape = (_escapeHTML == nil) ? _defaultEscapeHTML : [_escapeHTML boolValueInComponent:component];
  
  if ([listValue isKindOfClass:[NSArray class]] == NO) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
                        __PRETTY_FUNCTION__, [listValue class]];  
  }
  
  selectionsValue = _selections == nil ? nil : [_selections valueInComponent:component];
  
  if (selectionsValue != nil) {
    count = [selectionsValue count];
  }

  for (j = 0; j < count; j++) {
    NSString * prefixStr = nil;
    NSString * suffixStr = nil;
    NSString * dispStr = nil;
    id        obj2     = nil;
    id        displayValue     = nil;
    id        valueValue       = nil;

    if ((_prefix != nil)) {
      prefixStr = NSStringWithObject([_prefix valueInComponent:component]);
    }

    if ((_suffix != nil)) {
      suffixStr = NSStringWithObject([_suffix valueInComponent:component]);
    }
    
    if (_index != nil) {
      [_index setValue:GSWIntToNSString(j)
           inComponent:component];
    }

    obj2 = [listValue objectAtIndex:j];

    if ((_item != nil) && (_displayString != nil)) {
      [_item setValue:obj2
          inComponent:component];

      displayValue = [_displayString valueInComponent:component];

      if (displayValue == nil) {
        dispStr = NSStringWithObject(obj2);
        NSLog(@"%s: 'displayString' evaluated to nil in component %@. Using %@", 
              __PRETTY_FUNCTION__, component, dispStr);
      } else {
        dispStr = NSStringWithObject(displayValue);
      }
    } else {
      dispStr = NSStringWithObject(obj2);
    }
    GSWResponse_appendContentAsciiString(response, @"<input name=\"");
    GSWResponse_appendContentString(response,ctxName);
    GSWResponse_appendContentAsciiString(response,@"\" type=checkbox value=\"");

    if (_value != nil)
    {
      valueValue = [_value valueInComponent:component];
      if (valueValue != nil) {
        GSWResponse_appendContentHTMLConvertString(response, NSStringWithObject(valueValue));
      } else {
        NSLog(@"%s: 'value' evaluated to nil in component %@. Using to index.",
              __PRETTY_FUNCTION__, self);
      }
    }
    if (valueValue == nil) {
      GSWResponse_appendContentAsciiString(response,GSWIntToNSString(j));
    }
    if ([selectionsValue containsObject:obj2]) {
      GSWResponse_appendContentAsciiString(response,@"\" checked>");
    } else {
      GSWResponse_appendContentAsciiString(response,@"\">");
    }
    if (prefixStr != nil) {
      GSWResponse_appendContentString(response,prefixStr);
    }
    if (doEscape)
    {
      GSWResponse_appendContentHTMLConvertString(response,dispStr);
    } else {
      GSWResponse_appendContentString(response,dispStr);
    }
    if (suffixStr != nil) {
      GSWResponse_appendContentString(response,suffixStr);
    }
  } // for

}

-(BOOL)appendStringAtRight:(id)_unkwnon
               withMapping:(char*)_mapping
{
  return NO;
}

-(BOOL)appendStringAtLeft:(id)_unkwnon
              withMapping:(char*)_mapping
{
  return NO;
}

-(BOOL)compactHTMLTags
{
  return NO;
}

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  if (_value != nil) {
    if (!_loggedSlow) {
      NSLog(@"%s Warning: Avoid using the 'value' binding as it is much slower than omitting it, and it is just cosmetic.",
            __PRETTY_FUNCTION__);
      _loggedSlow = YES;
    }
    [self _slowTakeValuesFromRequest:request inContext:context];
  } else {
    [self _fastTakeValuesFromRequest:request inContext:context];
  }
}

@end
