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
    value=GSWContext_elementID(context);
  NSDebugMLLog(@"gswdync",@"value=%@",value);
  LOGObjectFnStopC("GSWCheckBox");
  return value;
};

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext
{
  GSWComponent* component=GSWContext_component(aContext);
  BOOL disabledInContext=[self disabledInComponent:component];
  if (!disabledInContext)
    {
      BOOL isChecked=NO;
      [self appendValueToResponse:aResponse
            inContext:aContext];
      [self appendNameToResponse:aResponse
            inContext:aContext];

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
                  NSString* valueValueString=NSStringWithObject(valueValue);
                  NSString* selectionValueString=NSStringWithObject(selectionValue);
                  isChecked=SBIsValueEqual(selectionValueString,valueValueString);
                };
            };
        }
      else if (_checked)
        {
          isChecked=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                             standardEvaluateConditionInContextIMP,
                                                             _checked,aContext);
        };
      NSDebugMLLog(@"gswdync",@"isChecked=%s",(isChecked ? "YES" : "NO"));

      if (isChecked)
        GSWResponse_appendContentAsciiString(aResponse,@" checked");
    };
};
@end

//====================================================================
@implementation GSWRadioButton (GSWRadioButtonB)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext
{
  //OK
  BOOL disabledInContext=NO;
  GSWComponent * component = GSWContext_component(aContext);
  
  LOGObjectFnStart();
  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);
  disabledInContext=[self disabledInComponent:component];
  if (!disabledInContext)
    {
      if ([aContext _wasFormSubmitted])
        {
          GSWComponent* component=GSWContext_component(aContext);
          NSString* name=nil;
          id formValue=nil;
          id valueValue=nil;
          BOOL isChecked=NO;
          name=[self nameInContext:aContext];
          NSDebugMLLog(@"gswdync",@"name=%@",name);
          formValue=[request formValueForKey:name];
          NSDebugMLLog(@"gswdync",@"formValue for %@=%@",name,formValue);

          if (_value)
            valueValue=[_value valueInComponent:component];
          else
            valueValue=GSWContext_elementID(aContext);
            
          if (formValue && valueValue)
            {
              NSString* valueValueString=NSStringWithObject(valueValue);
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
                            inContext:aContext];
                    };
                }
              NS_ENDHANDLER;
            }

          if (_checked)
            {
              NS_DURING
                {
                  [_checked setValue:(isChecked ? GSWNumberYes : GSWNumberNo)
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
                            inContext:aContext];
                    };
                }
              NS_ENDHANDLER;
            };
        };
    };
  LOGObjectFnStop();
};

@end
