/** GSWRadioButton.m - <title>GSWeb: Class GSWRadioButton</title>

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
              ExceptionRaise0(@"GSWRadioButton",@"if you don't specify 'checked' parameter, you have to specify 'value' and 'selection' parameter");
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
      if (_checked)
        {
          isChecked=[self evaluateCondition:_checked
                          inContext:context];
        }
      else if (_value)
        {
          id valueValue=[_value valueInComponent:component];
          id selectionValue=[_selection valueInComponent:component];
          isChecked=SBIsValueEqual(selectionValue,valueValue);
        };
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
  disabledInContext=[self disabledInContext:context];
  if (!disabledInContext)
    {
      if ([context _wasFormSubmitted])
        {
          BOOL isEqual=NO;
          GSWComponent* component=[context component];
          NSString* name=nil;
          id formValue=nil;
          id valueValue=nil;
          BOOL checkChecked=NO;
          name=[self nameInContext:context];
          NSDebugMLLog(@"gswdync",@"name=%@",name);
          formValue=[request formValueForKey:name];
          valueValue=[_value valueInComponent:component];
          //TODO if checked !
          isEqual=SBIsValueEqual(formValue,valueValue);
          if (isEqual)
            {
              checkChecked=YES;
              if (_selection)
                {
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
                    [_selection setValue:valueValue
                                inComponent:component];
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
                [_checked setValue:checkedValue
                          inComponent:component];
            };
        };
    };
  LOGObjectFnStop();
};

@end
