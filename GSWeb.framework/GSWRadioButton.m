/** GSWRadioButton.m - <title>GSWeb: Class GSWRadioButton</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

#include <GSWeb/GSWeb.h>

/**
Bindings

        value		Value for "value" tag of the element. If none, GNUstepWeb generate one

        selection	During appendTo... if it's evaluation equal value evalutaion, the button is checked. 
        		During takeValue..., it takes value evaluated value (or contextID if no value)

        checked		During appendTo... if it's evaluated to YES, the button is checked. 
        		During takeValue..., it takes YES if button is checked, NO otherwise.

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the button appear inactivated.
**/

//====================================================================
@implementation GSWRadioButton

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  NSMutableDictionary* tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ _elements=%@",
               aName,associations,elements);
  [tmpAssociations setObject:[GSWAssociation associationWithValue:@"radio"]
				 forKey:@"type"];
  [tmpAssociations removeObjectForKey:selection__Key];
  [tmpAssociations removeObjectForKey:checked__Key];
  if ((self=[super initWithName:aName
                   associations:tmpAssociations
                   contentElements:nil]))
    {
      _selection=[[associations objectForKey:selection__Key
                                withDefaultObject:[_selection autorelease]] retain];
      if (_selection && ![_selection isValueSettable])
        {
          ExceptionRaise0(@"GSWRadioButton",@"'selection' parameter must be settable");
        };

      _checked=[[associations objectForKey:checked__Key
                              withDefaultObject:[_checked autorelease]] retain];
      if (_checked && ![_checked isValueSettable])
        {
          ExceptionRaise0(@"GSWRadioButton",@"'checked' parameter must be settable");
        };
      if (!_checked)
        {
          if (!_value || !_selection)
            {
              ExceptionRaise0(@"GSWRadioButton",
                              @"if you don't specify 'checked' parameter, you have to specify 'value' and 'selection' parameter");
            };
        };
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_checked);
  DESTROY(_selection);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_get_class_name(self),
                   (void*)self];
};

@end

//====================================================================
@implementation GSWRadioButton (GSWRadioButtonA)

/** return the value used in appendValueToResponse:inContext: **/
-(id)valueInContext:(GSWContext*)context
{
  id value=nil;
  LOGObjectFnStartC("GSWCheckBox");
  // use _value evaluation or contextID
  if (_value)
    value=[super valueInContext:context];
  else
    value=[context elementID];
  NSDebugMLLog(@"gswdync",@"value=%@",value);
  LOGObjectFnStopC("GSWCheckBox");
  return value;
};

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response
                                      inContext:(GSWContext*)context
{
  //OK
  GSWComponent* component=[context component];
  BOOL disabledInContext=[self disabledInContext:context];
  if (!disabledInContext)
    {
      BOOL isChecked=NO;
      [self appendValueToResponse:response
            inContext:context];
      [self appendNameToResponse:response
            inContext:context];

      NSDebugMLLog(@"gswdync",@"_value=%@",_value);
      NSDebugMLLog(@"gswdync",@"_selection=%@",_selection);
      NSDebugMLLog(@"gswdync",@"_checked=%@",_checked);
      if (_value && _selection)
        {
          id valueValue=[_value valueInComponent:component];
          NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
          if (valueValue)
            {
              id selectionValue=[_selection valueInComponent:component];
              NSDebugMLLog(@"gswdync",@"selectionValue=%@",selectionValue);
              if (selectionValue)
                {
                  NSString* valueValueString=[NSString stringWithFormat:@"%@",valueValue];
                  NSString* selectionValueString=[NSString stringWithFormat:@"%@",selectionValue];
                  isChecked=SBIsValueEqual(selectionValueString,valueValueString);
                };
            };
        }
      else if (_checked)
        isChecked=[self evaluateCondition:_checked
                        inContext:context];
      NSDebugMLLog(@"gswdync",@"isChecked=%s",(isChecked ? "YES" : "NO"));

      if (isChecked)
        [response _appendContentAsciiString:@" checked"];
    };
};
@end

//====================================================================
@implementation GSWRadioButton (GSWRadioButtonB)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //OK
  BOOL disabledInContext=NO;
  LOGObjectFnStart();
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);
  disabledInContext=[self disabledInContext:context];
  if (!disabledInContext)
    {
      if ([context _wasFormSubmitted])
        {
          GSWComponent* component=[context component];
          NSString* name=nil;
          id formValue=nil;
          id valueValue=nil;
          BOOL isChecked=NO;
          name=[self nameInContext:context];
          NSDebugMLLog(@"gswdync",@"name=%@",name);
          formValue=[request formValueForKey:name];
          NSDebugMLLog(@"gswdync",@"formValue for %@=%@",name,formValue);

          if (_value)
            valueValue=[_value valueInComponent:component];
          else
            valueValue=[context elementID];
            
          if (formValue && valueValue)
            {
              NSString* valueValueString=[NSString stringWithFormat:@"%@",valueValue];
              isChecked=SBIsValueEqual(formValue,valueValueString);
            };
          NSDebugMLLog(@"gswdync",@"isChecked=%s",(isChecked ? "YES" : "NO"));

          // as RadioButtons are usually grouped, don't set nil to selection when
          // this  radio button is not checked because we may erase previous 
          // checked radio button selection
          if (_value && _selection && isChecked) 
            {
              NS_DURING
                {
                  [_selection setValue:(isChecked ? valueValue : nil)
                              inComponent:component];
                };
              NS_HANDLER
                {
                  LOGException(@"GSWRadioButton _selection=%@ valueValue=%@ exception=%@",
                               _selection,valueValue,localException);
                  if (WOStrictFlag)
                    {
                      [localException raise];
                    }
                  else
                    {
                      [self handleValidationException:localException
                            inContext:context];
                    };
                }
              NS_ENDHANDLER;
            }

          if (_checked)
            {
              NS_DURING
                {
                  [_checked setValue:[NSNumber numberWithBool:isChecked]
                            inComponent:component];
                };
              NS_HANDLER
                {
                  LOGException(@"GSWRadioButton _checked=%@ exception=%@",
                               _checked,localException);
                  if (WOStrictFlag)
                    {
                      [localException raise];
                    }
                  else
                    {
                      [self handleValidationException:localException
                            inContext:context];
                    };
                }
              NS_ENDHANDLER;
            };
        };
    };
  LOGObjectFnStop();
};

@end
