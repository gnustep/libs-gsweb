/** GSWCheckBox.m - <title>GSWeb: Class GSWCheckBox</title>

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

#include "GSWeb.h"

/**
Bindings

        value		Value for "valing" tag of the element. If none, GNUstepWeb generate one

        selection	During appendTo... if it's evaluation equal value evalutaion, the check box is checked. 
        		During takeValue..., it takes value evaluated value (or contextID if no value)

        checked		During appendTo... if it's evaluated to YES, the check box is checked. 
        		During takeValue..., it takes YES if checkbox is checked, NO otherwise.

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the check box appear inactivated.
**/

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWCheckBox

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWCheckBox class])
    {
      standardClass=[GSWCheckBox class];

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
  LOGObjectFnStartC("GSWCheckBox");
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ _elements=%@",aName,associations,elements);
  [tmpAssociations setObject:[GSWAssociation associationWithValue:@"checkbox"]
                   forKey:@"type"];
  [tmpAssociations removeObjectForKey:selection__Key];
  [tmpAssociations removeObjectForKey:checked__Key];
  if ((self=[super initWithName:aName
                   associations:tmpAssociations
                   contentElements:nil]))
    {
      //TODOV
      _selection=[[associations objectForKey:selection__Key
                                withDefaultObject:[_selection autorelease]] retain];
      if (_selection && ![_selection isValueSettable])
        {
          ExceptionRaise0(@"GSWCheckBox",@"'selection' parameter must be settable");
        };
      _checked=[[associations objectForKey:checked__Key
                              withDefaultObject:[_checked autorelease]] retain];
      if (_checked && ![_checked isValueSettable])
        {
          ExceptionRaise0(@"GSWCheckBox",@"'checked' parameter must be settable");
        };
      if (!_checked)
        {
          if (!_value || !_selection)
            {
              ExceptionRaise0(@"GSWCheckBox",
                              @"If you don't specify 'checked' parameter, you have to specify 'value' and 'selection' parameter");
            };
        };
    };
  LOGObjectFnStopC("GSWCheckBox");
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
@implementation GSWCheckBox (GSWCheckBoxA)

//--------------------------------------------------------------------
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
  //OK
  GSWComponent* component=nil;
  BOOL disabledInContext=NO;
  BOOL isChecked=NO;
  LOGObjectFnStartC("GSWCheckBox");
  component=GSWContext_component(aContext);
  disabledInContext=[self disabledInContext:aContext];
  NSDebugMLLog(@"gswdync",@"disabledInContext=%d",disabledInContext);

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

  if (disabledInContext) 
    GSWResponse_appendContentString(aResponse,@" disabled");

  LOGObjectFnStopC("GSWCheckBox");
};

@end

//====================================================================
@implementation GSWCheckBox (GSWCheckBoxB)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext
{
  //OK
  BOOL disabledInContext=NO;
  LOGObjectFnStartC("GSWCheckBox");
  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);
  disabledInContext=[self disabledInContext:aContext];
  if (!disabledInContext)
    {
      if ([aContext _wasFormSubmitted])
        {
          GSWComponent* component=GSWContext_component(aContext);
          NSString* name=nil;
          NSArray* formValues=nil;
          id valueValue=nil;
          BOOL isChecked=NO;
          name=[self nameInContext:aContext];
          formValues=[request formValuesForKey:name];
          NSDebugMLLog(@"gswdync",@"formValues for %@=%@",name,formValues);

          NSDebugMLLog(@"gswdync",@"_value=%@",_value);
          if (_value)
            valueValue=[_value valueInComponent:component];
          else
            valueValue=GSWContext_elementID(aContext);
          NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
            
          if (formValues && [formValues count]>0 && valueValue)
            {
              NSString* valueValueString=NSStringWithObject(valueValue);
              isChecked=[formValues containsObject:valueValueString];
            };
          NSDebugMLLog(@"gswdync",@"isChecked=%s",(isChecked ? "YES" : "NO"));

          if (_value && _selection)
            {
              NS_DURING
                {
                  [_selection setValue:(isChecked ? valueValue : nil)
                              inComponent:component];
                };
              NS_HANDLER
                {
                  LOGException(@"GSWCheckBox _selection=%@ valueValue=%@ exception=%@",
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
                  LOGException(@"GSWCheckBox _checked=%@ exception=%@",
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
  GSWStopElement(aContext);
  GSWAssertIsElementID(aContext);
  LOGObjectFnStopC("GSWCheckBox");
};

@end


