/** GSWPopUpButton.m - <title>GSWeb: Class GSWPopUpButton</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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

        displayString  	String to display for each item.

        value		Value for each OPTION tag 

        selection	Selected object (used to pre-select item and modified to reflect user choice)
        			It contains  object from list, not value binding evaluated one !

        selectedValue	Pre selected value (not object !)

        selectionValue	Selected value (used to pre-select item and modified to reflect user choice)
        			It contains  object from list, not value binding evaluated one !

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the check box appear inactivated.

        escapeHTML	If evaluated to yes, escape displayString

        noSelectionString	If binded, displayed as the first item. If selected, considered as 
        				an empty selection (selection is set to nil, selectionValue too)

**/

//====================================================================
@implementation GSWPopUpButton

static SEL objectAtIndexSEL = NULL;
static SEL setValueInComponentSEL = NULL;
static SEL valueInComponentSEL = NULL;

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWPopUpButton class])
    {
      objectAtIndexSEL=@selector(objectAtIndex:);
      setValueInComponentSEL=@selector(setValue:inComponent:);
      valueInComponentSEL=@selector(valueInComponent:);
    };
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{         
  self = [super initWithName:@"select" associations:associations template: template];
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
  ASSIGN(_string, [_associations objectForKey: displayString__Key]);
  if (_string != nil) {
    [_associations removeObjectForKey: displayString__Key];
  }
  ASSIGN(_selection, [_associations objectForKey: selection__Key]);
  if (_selection != nil) {
    [_associations removeObjectForKey: selection__Key];
  }
  ASSIGN(_noSelectionString, [_associations objectForKey: noSelectionString__Key]);
  if (_noSelectionString != nil) {
    [_associations removeObjectForKey: noSelectionString__Key];
  }
  ASSIGN(_selectedValue, [_associations objectForKey: selectedValue__Key]);
  if (_selectedValue != nil) {
    [_associations removeObjectForKey:selectedValue__Key];
  }

  if ((_list == nil) || (_value != nil || _string != nil) && ((_item == nil) || (![_item isValueSettable])) || 
      (_selection != nil) && (![_selection isValueSettable])) {

    [NSException raise:NSInvalidArgumentException
                format:@"%s: 'list' must be present. 'item' must not be a constant if 'value' is present.  Cannot have 'displayString' or 'value' without 'item'.  'selection' must not be a constant if present.",
                            __PRETTY_FUNCTION__];  
  }
  if ((_selection != nil) && (_selectedValue != nil)) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: Cannot have both selections and selectedValues.",
                            __PRETTY_FUNCTION__];  
  }
  return self;
}
 
-(void) dealloc
{
  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_string);
  DESTROY(_selection);
  DESTROY(_selectedValue);
  DESTROY(_noSelectionString);

  [super dealloc];
}
  
-(id) description
{
  return [NSString stringWithFormat:@"<%s %p list:%@ item:%@ string:%@ selections:%@ selectedValue:%@ NoSelectionString:%@ >",
                   object_get_class_name(self),
                   (void*)self, 
                   _list, _item, _string, _selection, _selectedValue, _noSelectionString];
};

- (void)_slowTakeValuesFromRequest:(GSWRequest*) request
                         inContext:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);
  if ((_selection != nil) && (![self disabledInComponent:component]) && ([context _wasFormSubmitted])) {
    id obj = nil;
    id itemValue = nil;
    id valueValue = nil;
    
    NSString * ctxName = [self nameInContext:context];
    NSString * formValue = [request stringFormValueForKey: ctxName];
    if (formValue != nil && (![formValue isEqual:@"WONoSelectionString"])) {
      id compoValue = [_list valueInComponent:component];
      if (compoValue != nil) {
        if ([compoValue isKindOfClass:[NSArray class]]) {
          NSArray * valueArray = (NSArray*)compoValue;
          int i = [valueArray count];
          int k = 0;
          while (YES) {
            if (k >= i) {
              break;
            }
            itemValue = [valueArray objectAtIndex:k];
            [_item setValue: itemValue inComponent:component];  // ???
            valueValue = [_value valueInComponent:component];
            if (valueValue != nil) {
              if ([formValue isEqual:valueValue]) {       // stringValue?
                obj = itemValue;
                break;
              }
            } else {
              NSLog(@"%s:'value' evaluated to nil in component '%@'.\nUnable to select item '%@'",
                    __PRETTY_FUNCTION__,
                    component,
                    itemValue);
            }
            k++;
          }
        } else {
            [NSException raise:NSInvalidArgumentException
                format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
                            __PRETTY_FUNCTION__, [compoValue class]];  
        }
      }
    }
    [_selection setValue:obj inComponent: component];
  }
}

- (void) _fastTakeValuesFromRequest:(GSWRequest*) request
                              inContext:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);

  if ((_selection != nil) && (![self disabledInComponent:component]) && ([context _wasFormSubmitted])) {
    id obj = nil;
    NSString * ctxName = [self nameInContext:context];
    NSString * formValue = [request stringFormValueForKey: ctxName];
    if (formValue != nil) {
      formValue = [formValue stringByTrimmingSpaces];
      if (![formValue isEqual:@"WONoSelectionString"]) {
        int i = [formValue intValue];
        id compoValue = [_list valueInComponent:component];
        if (compoValue != nil) {
          if ([compoValue isKindOfClass:[NSArray class]]) {
            NSArray * valueArray = compoValue;
            if ((i < [valueArray count]) && (i >= 0)) {
              obj = [valueArray objectAtIndex:i];
            }
          } else {
            [NSException raise:NSInvalidArgumentException
                format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
                            __PRETTY_FUNCTION__, [compoValue class]];  
          }
        }
      }
    }
    [_selection setValue:obj inComponent: component];
  }
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

-(void) _appendValueAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*) context
{
}

-(void) appendChildrenToResponse:(GSWResponse *) response
                       inContext:(GSWContext*) context
{
  BOOL flag = NO;
  NSArray * valueArray = nil;
  int j = 0;
  id obj = nil;
  BOOL isSelected = NO;
  id compoValue = nil;
  int i = 0;
  NSString * valueValue = nil;
  NSString * s1 = nil;
  id arrayObj = nil;
  
  GSWComponent * component = GSWContext_component(context);
  BOOL doEscape = YES;
  
  if (_escapeHTML != nil) {
    doEscape = [_escapeHTML boolValueInComponent:component];
  }
  compoValue = [_list valueInComponent:component];
  if (compoValue != nil) {
    if ([compoValue isKindOfClass:[NSArray class]]) {
      valueArray = compoValue;
      j = [valueArray count];
    } else {
      [NSException raise:NSInvalidArgumentException
                  format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
                           __PRETTY_FUNCTION__, [compoValue class]];      
    }
  }
  if (_noSelectionString != nil) {
    id noSelectionValue = [_noSelectionString valueInComponent:component];
    if (noSelectionValue != nil) {
      GSWResponse_appendContentAsciiString(response,@"\n<option value=\"WONoSelectionString\">");
      // wo seems to NOT do it right here. They escape always.
      if (doEscape) {
        GSWResponse_appendContentHTMLConvertString(response, [noSelectionValue description]); 
      } else {
        GSWResponse_appendContentString(response, [noSelectionValue description]);
      }
      GSWResponse_appendContentAsciiString(response, @"</option>");
    } else {
      [NSException raise:NSInvalidArgumentException
                  format:@"%s: 'noSelectionString' evaluated to nil in component '%@'. Did not insert a WONoSelectionString.",
                           __PRETTY_FUNCTION__, component];      
    }
  }
  if (_selection != nil) {
    obj = [_selection valueInComponent:component];
  } else {
    if (_selectedValue != nil) {
      compoValue = [_selectedValue valueInComponent:component];
    }
  }
  for (i = 0; i < j; i++) {
    valueValue = nil;
    s1 = nil;
    arrayObj = nil;
    if (valueArray != nil) {
      arrayObj = [valueArray objectAtIndex:i];
    }
    if ((_string != nil) || (_value != nil)) {
      [_item setValue:arrayObj inComponent:component];
      if (_string != nil) {
        id obj5 = [_string valueInComponent:component];
        if (obj5 != nil) {
          s1 = obj5;   // stringValue??
          if (_value != nil) {
            id obj7 = [_value valueInComponent:component];
            if (obj7 != nil) {
              valueValue = obj7;  // stringValue?
            }
          } else {
            valueValue = s1;
          }
        }
      } else {
        id obj6 = [_value valueInComponent:component];
        if (obj6 != nil) {
          valueValue = obj6; // stringValue?
          s1 = valueValue;
        }
      }
    } else {
      s1 = arrayObj; // stringValue?
      valueValue = s1;
    }
    GSWResponse_appendContentAsciiString(response,@"\n<option");
    if (_selection != nil) {
      isSelected = (obj == nil) ? NO : [obj isEqual:arrayObj];
    } else {
      if (_selectedValue != nil) {
        if (_value != nil) {
          isSelected = compoValue == nil ? NO : [compoValue isEqual: valueValue];
        } else {
          isSelected = [GSWIntToNSString(i) isEqual:compoValue];
        }
      }
    }
    if (isSelected) {
      GSWResponse_appendContentCharacter(response,' ');
      GSWResponse_appendContentAsciiString(response,@"selected");
    }
    if (_value != nil) {
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, value__Key, valueValue, YES);
      
    } else {
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, value__Key, GSWIntToNSString(i), NO);
    }
    GSWResponse_appendContentCharacter(response,'>');
    if (doEscape) {
      GSWResponse_appendContentHTMLConvertString(response, s1);
    } else {
      GSWResponse_appendContentString(response, s1);
    }
    GSWResponse_appendContentAsciiString(response,@"</option>");
  }

}


@end

