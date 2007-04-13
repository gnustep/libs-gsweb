/** GSWBrowser.m - <title>GSWeb: Class GSWBrowser</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de>
   Date: 	Oct 2006
   
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

        value		Value for each OPTION tag 

        selections	Array of selected objects (used to pre-select items and modified to reflect user choices)
        			It contains  objects from list, not value binding evaluated ones !

        selectedValues	Array of pre selected values (not objects !)

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the check box appear inactivated.

        escapeHTML	If evaluated to yes, escape displayString

        size		show 'size' iems at one time. Default=5. Must be > 1

        multiple	multiple selection allowed
**/

//====================================================================
@implementation GSWBrowser

static SEL objectAtIndexSEL = NULL;
static SEL setValueInComponentSEL = NULL;
static SEL valueInComponentSEL = NULL;

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWBrowser class])
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
  ASSIGN(_displayString, [_associations objectForKey: displayString__Key]);
  if (_displayString != nil) {
    [_associations removeObjectForKey: displayString__Key];
  }
  ASSIGN(_selections, [_associations objectForKey: selections__Key]);
  if (_selections != nil) {
    [_associations removeObjectForKey: selections__Key];
  }
  ASSIGN(_multiple, [_associations objectForKey: multiple__Key]);
  if (_multiple != nil) {
    [_associations removeObjectForKey: multiple__Key];
  }
  ASSIGN(_size, [_associations objectForKey: size__Key]);
  if (_size != nil) {
    [_associations removeObjectForKey: size__Key];
  }
  ASSIGN(_selectedValues, [_associations objectForKey: selectedValues__Key]);
  if (_selectedValues != nil) {
    [_associations removeObjectForKey: selectedValues__Key];
  }
  ASSIGN(_escapeHTML, [_associations objectForKey: escapeHTML__Key]);
  if (_escapeHTML != nil) {
    [_associations removeObjectForKey: escapeHTML__Key];
  }
  
  if ((_list == nil) || (_value != nil || _displayString != nil) && 
        ((_item == nil) || (![_item isValueSettable])) || 
        ((_selections != nil) && (![_selections isValueSettable]))) {

    [NSException raise:NSInvalidArgumentException
                format:@"%s: 'list' must be present. 'item' must not be a constant if 'value' is present.  Cannot have 'displayString' or 'value' without 'item'.  'selection' must not be a constant if present.",
                            __PRETTY_FUNCTION__];  
  }
  if ((_selections != nil) && (_selectedValues != nil)) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: Cannot have both selections and selectedValues.",
                            __PRETTY_FUNCTION__];  
  }
  return self;
}


-(void)dealloc
{

  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_displayString);
  DESTROY(_selections);
  DESTROY(_selectedValues);
  DESTROY(_size);
  DESTROY(_multiple);

  [super dealloc];
};


-(id) description
{
  return [NSString stringWithFormat:@"<%s %p list:%@ item:%@ displayString:%@ selections:%@ selectedValues:%@ multiple:%@ size:%@ escapeHTML:%@>",
                   object_get_class_name(self),
                   (void*)self, 
                   _list, _item, _displayString, _selections, _selectedValues, _multiple,
                   _size, _escapeHTML];
};



/*
 On WO it looks like that when value is not bound:

 <SELECT name="4.2.7" size=5 multiple>
 <OPTION value="0">blau</OPTION>
 <OPTION value="1">braun</OPTION>
 <OPTION selected value="2">gruen</OPTION>
 <OPTION value="3">marineblau</OPTION>
 <OPTION value="4">schwarz</OPTION>
 <OPTION value="5">silber</OPTION>
 <OPTION value="6">weiss</OPTION></SELECT>

 */
-(void) appendChildrenToResponse:(GSWResponse *) response
                       inContext:(GSWContext*) context
{
  NSArray           * valueArray  = nil;
  NSArray           * selectionsArray  = nil;
  int                 listCount   = 0;
  id                  obj         = nil;
  BOOL                isSelected  = NO;
  id                  compoValue  = nil;
  int                 i           = 0;
  NSString          * valueValue  = nil;
  NSString          * s1          = nil;
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
      listCount = [valueArray count];
    } else {
      [NSException raise:NSInvalidArgumentException
                  format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
                           __PRETTY_FUNCTION__, [compoValue class]];      
    }
  }

  if (_selections != nil) {
    selectionsArray = [_selections valueInComponent:component];
  } else {
    if (_selectedValues != nil) {
      selectionsArray = [_selectedValues valueInComponent:component];
    }
  }

  for (i = 0; i < listCount; i++) {
    valueValue = nil;
    s1 = nil;
    arrayObj = nil;
    if (valueArray != nil) {
      arrayObj = [valueArray objectAtIndex:i];
    }
    if ((_displayString != nil) || (_value != nil)) {
      [_item setValue:arrayObj inComponent:component];
      if (_displayString != nil) {
        id obj5 = [_displayString valueInComponent:component];
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
    if (selectionsArray != nil) {
      isSelected = (arrayObj == nil) ? NO : [selectionsArray containsObject:arrayObj];
    } else {
        if (_value != nil) {
          isSelected = compoValue == nil ? NO : [compoValue isEqual: valueValue];
        } else {
          isSelected = [GSWIntToNSString(i) isEqual:compoValue];
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


-(void) _appendValueAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*) context
{
}

-(void) appendAttributesToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
  id             sizeValue = nil;
  int            sizeInt   = 5;
  GSWComponent * component = GSWContext_component(context);

  [super appendAttributesToResponse:response 
                          inContext:context];


  if (_size != nil) {
    sizeValue = [_size valueInComponent:component];
    sizeInt   = [sizeValue intValue];
    sizeValue = GSWIntToNSString(sizeInt);
  }

  if (_size == nil || sizeValue == nil || (sizeInt < 2)) {
    sizeValue = GSWIntToNSString(5);
  }

  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, size__Key, sizeValue, NO);

  if (_multiple != nil && ([_multiple boolValueInComponent:component])) {
    GSWResponse_appendContentCharacter(response,' ');
    GSWResponse_appendContentAsciiString(response,@"multiple");
  }
}

- (void)_slowTakeValuesFromRequest:(GSWRequest*) request
                         inContext:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);

  if ((_selections != nil) && (![self disabledInComponent:component]) && ([context _wasFormSubmitted])) {

    NSString       * ctxName         = [self nameInContext:context];
    NSArray        * formValues      = [request formValuesForKey: ctxName];
    NSArray        * listValue       = nil;
    BOOL             multipe         = NO;
    int              count           = 0;    
    NSMutableArray * mutArray        = [NSMutableArray array];
    
    if (formValues != nil) {
      int      i = 0;    

      count      = [formValues count];

      if (count) {
        if (_multiple != nil) {
          multipe = [_multiple boolValueInComponent:component];
        }
       
        if (_list != nil) {
            listValue = [_list valueInComponent:component];
            if ([listValue isKindOfClass:[NSArray class]] == NO) {
              [NSException raise:NSInvalidArgumentException
                          format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
                                  __PRETTY_FUNCTION__, [listValue class]];  
            }
  
          for (i = 0; i < count; i++) {
            id valueValue = nil;
            id obj1       = [listValue objectAtIndex:i];
  
            [_item setValue:obj1 inComponent: component];
  
            valueValue = [_value valueInComponent:component];
            if (valueValue != nil) {
              if (![formValues containsObject:NSStringWithObject(valueValue)]) {
                continue;
              }
              [mutArray addObject:obj1];
              if (!multipe) {
                break;
              }
            } else {
              NSLog(@"%s: 'value' evaluated to null in component %@, %@",
                           __PRETTY_FUNCTION__, component, self);
            }
          }     // for
        }       // _list != nil
      }
    }
    [_selections setValue:mutArray inComponent: component];
  }
}


- (void) _fastTakeValuesFromRequest:(GSWRequest*) request
                          inContext:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);

  if ((_selections != nil) && (![self disabledInComponent:component]) && ([context _wasFormSubmitted])) {
    NSString       * ctxName         = [self nameInContext:context];
    NSArray        * formValues      = [request formValuesForKey: ctxName];
    NSArray        * listValue       = nil;
    int              count           = 0;    
    int              i               = 0;    
    NSMutableArray * mutArray        = nil;
    NSArray        * selectionsValue = nil;

    if (formValues != nil) {
      count    = [formValues count];
      mutArray = [NSMutableArray arrayWithCapacity:count];
      
      if ((_list != nil) && (count > 0)) {
          listValue = [_list valueInComponent:component];
          if ([listValue isKindOfClass:[NSArray class]] == NO) {
            [NSException raise:NSInvalidArgumentException
                        format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
                                __PRETTY_FUNCTION__, [listValue class]];  
          }
      }
      
       for (i = 0; i < count; i++) {
          id s1 = (NSString*) [formValues objectAtIndex:i];
          int k = [s1 intValue];
          id obj1 = nil;
          if (listValue != nil) {
            id valueValue = [listValue objectAtIndex:k];
            [mutArray addObject:valueValue];
          } 
       }
           
       [_selections setValue:mutArray inComponent: component];

    }
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


@end
