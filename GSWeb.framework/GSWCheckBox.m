/** GSWCheckBox.m - <title>GSWeb: Class GSWCheckBox</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWCheckBox

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
              ExceptionRaise0(@"GSWCheckBox",@"If you don't specify 'checked' parameter, you have to specify 'value' and 'selection' parameter");
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
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response
                                      inContext:(GSWContext*)context
{
  //OK
  GSWComponent* component=nil;
  BOOL disabledInContext=NO;
  LOGObjectFnStartC("GSWCheckBox");
  component=[context component];
  disabledInContext=[self disabledInContext:context];
  if (!disabledInContext)
    {
      BOOL checkedValue=NO;
      [self appendValueToResponse:response
            inContext:context];
      [self appendNameToResponse:response
            inContext:context];

      if (_checked)
        {
          checkedValue=[self evaluateCondition:_checked
                             inContext:context];
        }
      else if (_value)
        {
          id valueValue=[_value valueInComponent:component];
          id selectionValue=[_selection valueInComponent:component];
          checkedValue=SBIsValueEqual(selectionValue,valueValue);
        };
      if (checkedValue)
        [response _appendContentAsciiString:@" checked"];
    };
  LOGObjectFnStopC("GSWCheckBox");
};

@end

//====================================================================
@implementation GSWCheckBox (GSWCheckBoxB)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //OK
  BOOL disabledInContext=NO;
  LOGObjectFnStartC("GSWCheckBox");
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);
  disabledInContext=[self disabledInContext:context];
  if (!disabledInContext)
    {
      if ([context _wasFormSubmitted])
        {
          GSWComponent* component=[context component];
          NSString* name=nil;
          NSArray* formValues=nil;
          BOOL checkChecked=NO;
          name=[self nameInContext:context];
          NSDebugMLLog(@"gswdync",@"name=%@",name);
          formValues=[request formValuesForKey:name];
          NSDebugMLLog(@"gswdync",@"formValues=%@",formValues);
          if (formValues && [formValues count])
            {
              NSDebugMLLog(@"gswdync",@"[formValues objectAtIndex:0]=%@",[formValues objectAtIndex:0]);
              checkChecked=YES;
              if (_selection)
                {
                  //TODOV
                  id valueValue=[_value valueInComponent:component];
                  if (!WOStrictFlag)
                    {
                      NS_DURING
                        {
                          [_selection setValue:valueValue
                                      inComponent:component];
                        };
                      NS_HANDLER
                        {
                          [self handleValidationException:localException
                                inContext:context];
                        }
                      NS_ENDHANDLER;
                    }
                  else
                    {
                      [_selection setValue:valueValue
                                  inComponent:component];
                    };
                };
            };
          if (_checked)
            {
              id checkedValue=[NSNumber numberWithBool:checkChecked];
              NSDebugMLLog(@"gswdync",@"checkedValue=%@",checkedValue);
              if (!WOStrictFlag)
                {
                  NS_DURING
                    {
                      [_checked setValue:checkedValue
                                inComponent:component];
                    };
                  NS_HANDLER
                    {
                      [self handleValidationException:localException
                            inContext:context];
                    }
                  NS_ENDHANDLER;
                }
              else
                {
                  [_checked setValue:checkedValue
                            inComponent:component];
                };
            };
        };
    };
  GSWStopElement(context);
  GSWAssertIsElementID(context);
  LOGObjectFnStopC("GSWCheckBox");
};

@end


