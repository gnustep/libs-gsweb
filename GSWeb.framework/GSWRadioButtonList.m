/** GSWRadioButtonList.m - <title>GSWeb: Class GSWRadioButtonList</title>

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

        displayString  	String to display for each radio button.

        value		Value for the INPUT tag for each radio button

        prefix		An html string to insert before each value.

        suffix		An html string to insert after each value.

        selection	Selected object (used to pre-check radio button and modified to reflect user choice)
        			It contains  object from list, not value binding evaluated one !

        selectionValue	Selected value (used to pre-check radio button and modified to reflect user choice)
        			It contains evaluated value binding !

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the radio button appear inactivated.

        escapeHTML	If evaluated to yes, escape displayString

        isDisplayStringBefore If evaluated to yes, displayString is displayed before radio button
**/

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWRadioButtonList

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWRadioButtonList class])
    {
      standardClass=[GSWRadioButtonList class];
    }
}

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{         
  GSWAssociation * valueAssoc = nil;

  self = [super initWithName:aName associations:associations template: template];
  if (!self) {
    return nil;
  }  

  _loggedSlow = NO;

  ASSIGN(_suffix, [_associations objectForKey: suffix__Key]);
  if (_suffix != nil) {
    [_associations removeObjectForKey: suffix__Key];
  }


  ASSIGN(_index, [_associations objectForKey: index__Key]);
  if (_index != nil) {
    [_associations removeObjectForKey: index__Key];
  }

  ASSIGN(_list, [_associations objectForKey: list__Key]);
  if (_list != nil) {
    [_associations removeObjectForKey: list__Key];
  }

  ASSIGN(_item, [_associations objectForKey: item__Key]);
  if (_item != nil) {
    [_associations removeObjectForKey: item__Key];
  }

  ASSIGN(_selection, [_associations objectForKey: selection__Key]);
  if (_selection != nil) {
    [_associations removeObjectForKey: item__Key];
  }

  ASSIGN(_prefix, [_associations objectForKey: prefix__Key]);
  if (_prefix != nil) {
    [_associations removeObjectForKey: prefix__Key];
  }

  ASSIGN(_displayString, [_associations objectForKey: displayString__Key]);
  if (_displayString != nil) {
    [_associations removeObjectForKey: displayString__Key];
  }

  ASSIGN(_escapeHTML, [_associations objectForKey: escapeHTML__Key]);
  if (_escapeHTML != nil) {
    [_associations removeObjectForKey: escapeHTML__Key];
  }

  if ((valueAssoc = [_associations objectForKey: value__Key])) {
        [_associations removeObjectForKey: value__Key];
  }
  
  if (_displayString == nil)
  {
    ASSIGN(_displayString, valueAssoc);
    _defaultEscapeHTML = NO;
  } else {
    _defaultEscapeHTML = YES;
  }
  if ((_list == nil) || (_displayString != nil || _value != nil) &&
     (_item == nil || (![_item isValueSettable])) ||
     (_selection != nil && (![_selection isValueSettable])))
  {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: 'list' must be present. 'item' must not be a constant if 'displayString' or 'value' is present.  'selections' must not be a constant if present.",
                            __PRETTY_FUNCTION__];      
  } 
  
  return self;
}

//-----------------------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_index);
  DESTROY(_selection);
  DESTROY(_prefix);
  DESTROY(_suffix);
  DESTROY(_displayString);

  [super dealloc];
}

-(id) description
{
  return [NSString stringWithFormat:@"<%s %p list:%@ item:%@ index:%@ selection:%@ prefix:%@ suffix:%@ displayString:%@ escapeHTML:%@>",
                   object_get_class_name(self),
                   (void*)self, 
                   _list, _item, _index,
                   _selection, _prefix, _suffix, _displayString, _escapeHTML];
}

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return @"INPUT";
};



-(void)_slowTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);

  if ((![self disabledInComponent:component]) && ([context _wasFormSubmitted])) {    
    NSString * ctxName = [self nameInContext:context];
    NSString * formValue = [request stringFormValueForKey: ctxName];
    int        count    = 0;
    int        i        = 0;
    id         itemValue = nil;
    id         valueValue = nil;
    id         selValue = nil;

    if (formValue != nil) {
      NSArray* listValue = [_list valueInComponent:component];

      if ([listValue isKindOfClass:[NSArray class]] == NO) {
        [NSException raise:NSInvalidArgumentException
                    format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
                            __PRETTY_FUNCTION__, [listValue class]];  
      }

      count = [listValue count];
      for (i = 0; i < count; i++) {
        itemValue = [listValue objectAtIndex:i];
        [_item setValue:itemValue
            inComponent:component];
        valueValue = [_value valueInComponent:component];
        if (valueValue == nil) {
          continue;
        }
        if ([formValue isEqual:valueValue]) {
          selValue = itemValue;
          break;
        }
        NSLog(@"%s: 'value' evaluated to nil in component %@ Unable to select item %@",
              __PRETTY_FUNCTION__,self,itemValue);
      }

    }
    [_selection setValue:selValue
             inComponent:component];

  }
}

//-----------------------------------------------------------------------------------
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);

  if ((_selection != nil) && ((![self disabledInComponent:component]) && ([context _wasFormSubmitted]))) {

    NSArray* listValue = nil;
    id         selValue = nil;
    NSString * ctxName = [self nameInContext:context];
    NSString * formValue = [request stringFormValueForKey: ctxName];
    
    if (formValue != nil) {
      NSArray* listValue = [_list valueInComponent:component];

      if ([listValue isKindOfClass:[NSArray class]] == NO) {
        [NSException raise:NSInvalidArgumentException
                    format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
                            __PRETTY_FUNCTION__, [listValue class]];  
      }

      selValue = [listValue objectAtIndex:[formValue intValue]];
    }
    [_selection setValue:selValue
             inComponent:component];
  }
}

//-----------------------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  id             selectionsValue = nil;
  int i = 0;
  int j = 0;
  BOOL           doEscape;
  int            count           = 0;
  GSWComponent * component       = GSWContext_component(context);
  NSString     * ctxName         = [self nameInContext:context];
  id             listValue       = [_list valueInComponent:component];
  id             currentValue    = nil;  
  id             valueValue      = nil;

  if ([listValue isKindOfClass:[NSArray class]] == NO) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
                        __PRETTY_FUNCTION__, [listValue class]];  
  }

  doEscape = (_escapeHTML == nil) ? _defaultEscapeHTML : [_escapeHTML boolValueInComponent:component];


  selectionsValue = _selection == nil ? nil : [_selection valueInComponent:component];
  
  if (selectionsValue != nil) {
    count = [selectionsValue count];
  }

  for (j = 0; j < count; j++)
  {
    if (_index != nil) {
      [_index setValue:GSWIntToNSString(j)
           inComponent:component];
    }
    NSString * prefixStr = _prefix == nil ? nil : NSStringWithObject([_prefix valueInComponent:component]);
    NSString * suffixStr = _suffix == nil ? nil : NSStringWithObject([_suffix valueInComponent:component]);
    id        displayValue     = nil;
    NSString * dispStr = nil;

    currentValue = [listValue objectAtIndex:j];

    if ((_item != nil) && (_displayString != nil)) {
      [_item setValue:currentValue inComponent:component];
      displayValue = [_displayString valueInComponent:component];

      if (displayValue == nil) {
        dispStr = NSStringWithObject(currentValue);
        NSLog(@"%s: 'displayString' evaluated to nil in component %@. Using %@", 
              __PRETTY_FUNCTION__, component, dispStr);
      } else {
        dispStr = NSStringWithObject(displayValue);
      }
    } else {
      dispStr = NSStringWithObject(currentValue);
    }
    GSWResponse_appendContentAsciiString(response, @"<input name=\"");
    GSWResponse_appendContentString(response,ctxName);
    GSWResponse_appendContentAsciiString(response, @"\" type=radio value=\"");

    if (_value != nil) {
      valueValue = [_value valueInComponent:component];
      if (valueValue != nil) {
        GSWResponse_appendContentHTMLConvertString(response,NSStringWithObject(valueValue));
      } else {
        NSLog(@"%s: 'value' evaluated to nil in component %@. Using index", 
              __PRETTY_FUNCTION__, component);
      }
    }
    if (valueValue == nil) {
      GSWResponse_appendContentString(response,ctxName);
      GSWResponse_appendContentAsciiString(response,GSWIntToNSString(j));
    }
    if ((selectionsValue != nil) && ([selectionsValue isEqual:currentValue])) {
      GSWResponse_appendContentAsciiString(response,@"\" checked>");
    } else {
      GSWResponse_appendContentAsciiString(response,@"\">");
    }
    if (prefixStr != nil) {
      GSWResponse_appendContentString(response,prefixStr);
    }
    if (doEscape) {
      GSWResponse_appendContentHTMLConvertString(response, dispStr);
    } else {
      GSWResponse_appendContentString(response,dispStr);
    }
    if (suffixStr != nil)
    {
      GSWResponse_appendContentString(response,suffixStr);
    }
  }

}

-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping
{
  return NO;
};

-(BOOL)appendStringAtLeft:(id)unkwnon
              withMapping:(char*)mapping
{
  return NO;
};

-(BOOL)compactHTMLTags
{
  return NO;
};

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
