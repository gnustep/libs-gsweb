/** GSWRadioButton.m - <title>GSWeb: Class GSWRadioButton</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$
   $Id$

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

#include "GSWeb.h"

/**
Bindings

        value		Value for "value" tag of the element. If none, GNUstepWeb generate one

        selection	During appendTo... if it's evaluation equal value evalutaion, the button is checked. 
        		During takeValue..., it takes value evaluated value (or contextID if no value)

        checked		During appendTo... if it's evaluated to YES, the button is checked. 
        		During takeValue..., it takes YES if button is checked, NO otherwise.

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the button appear inactivated.

        enabled		If evaluated to no, the button appear inactivated.
**/

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWRadioButton

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWRadioButton class])
    {
      standardClass=[GSWRadioButton class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  self = [super initWithName:@"input" associations:associations template: template];
  if (!self) {
    return nil;
  }

  ASSIGN(_selection, [_associations objectForKey: selection__Key]);

  if (_selection != nil) {
    [_associations removeObjectForKey: selection__Key];
  }
  
  if (_selection && ![_selection isValueSettable]) {
    ExceptionRaise0(@"GSWRadioButton",@"'selection' parameter must be settable");
  }

  ASSIGN(_checked, [_associations objectForKey: checked__Key]);

  if (_checked != nil) {
    [_associations removeObjectForKey: checked__Key];
  }

  if (_checked && ![_checked isValueSettable]) {
    ExceptionRaise0(@"GSWRadioButton",@"'checked' parameter must be settable");
  };
  
  if ((!_checked) && ((!_value) && (!_selection)))
  {
    ExceptionRaise0(@"GSWRadioButton",
                    @"if you don't specify 'checked' parameter, you have to specify 'value' and 'selection' parameter");
  }
            
  return self;
}

//  [tmpAssociations removeObjectForKey:selection__Key];
//  [tmpAssociations removeObjectForKey:checked__Key];


-(void)dealloc
{
  DESTROY(_checked);
  DESTROY(_selection);
  [super dealloc];
}

-(id) description
{
  return [NSString stringWithFormat:@"<%s %p checked:%@ selection:%@ disabled:%@ name:%@ value:%@>",
                   object_getClassName(self),
                   (void*)self, 
                   _checked, _selection, _disabled, _name, _value];
};

- (NSString*) type
{
  return @"radio";
}

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  GSWComponent* component  = GSWContext_component(context);
  BOOL          isChecked  = NO;
  id            valueValue = nil;

  if ((![self disabledInComponent:component]) && ([context _wasFormSubmitted])) {

    NSString * nameCtx = [self nameInContext:context];

    if (nameCtx != nil) {
      NSString* value      = [request stringFormValueForKey: nameCtx];
      
      if (_value != nil) {
         valueValue = [_value valueInComponent:component];
      } else {
         valueValue = [context elementID];
      }
      
      isChecked = [value isEqual:NSStringWithObject(valueValue)];

      if (isChecked && _selection != nil && _value != nil) {
        [_selection setValue: valueValue
                 inComponent: component];
      }

      if (_checked != nil) {
        [_checked setValue: (isChecked ? GSWNumberYes : GSWNumberNo)
               inComponent: component];
      }

    }
  }
}

-(void) _appendCloseTagToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
// nothing!
}

- (void) appendAttributesToResponse:(GSWResponse*)response
                inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  id             valueValue = nil;
  id             selectionValue = nil;

  [super appendAttributesToResponse:response inContext:context];

  if (_value != nil) {
    valueValue = [_value valueInComponent:component];
    if (valueValue != nil && _selection != nil) {
      selectionValue = [_selection valueInComponent:component];
      if ((selectionValue != nil) && [selectionValue isEqual: valueValue]) {
        GSWResponse_appendContentCharacter(response,' ');
        GSWResponse_appendContentAsciiString(response,@"checked");
      }
    }
  } else { // _value == nil
    GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, value__Key, [context elementID], NO);  
  }
  if ((_checked != nil) && [_checked boolValueInComponent:component]) {
     GSWResponse_appendContentCharacter(response,' ');
     GSWResponse_appendContentAsciiString(response,@"checked");
  }
}


@end
