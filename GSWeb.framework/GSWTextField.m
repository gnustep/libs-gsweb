/** GSWTextField.m - <title>GSWeb: Class GSWTextField</title>

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
@implementation GSWTextField

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
	 associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  NSMutableDictionary* tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
  LOGObjectFnStartC("GSWTextField");
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ elements=%@",aName,associations,elements);
  [tmpAssociations setObject:[GSWAssociation associationWithValue:@"text"]
                   forKey:@"type"];
  [tmpAssociations removeObjectForKey:dateFormat__Key];
  [tmpAssociations removeObjectForKey:numberFormat__Key];
  [tmpAssociations removeObjectForKey:useDecimalNumber__Key];
  [tmpAssociations removeObjectForKey:formatter__Key];
  if ((self=[super initWithName:aName
                   associations:tmpAssociations
                   contentElements:nil])) //No Childs!
    {
      _dateFormat = [[associations objectForKey:dateFormat__Key
                                   withDefaultObject:[_dateFormat autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWTextField: dateFormat=%@",_dateFormat);
      _numberFormat = [[associations objectForKey:numberFormat__Key
                                      withDefaultObject:[_numberFormat autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWTextField: numberFormat=%@",_numberFormat);
      _useDecimalNumber = [[associations objectForKey:useDecimalNumber__Key
                                         withDefaultObject:[_useDecimalNumber autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWTextField: useDecimalNumber=%@",_useDecimalNumber);
      _formatter = [[associations objectForKey:formatter__Key
                                  withDefaultObject:[_formatter autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWTextField: formatter=%@",_formatter);
    };
  LOGObjectFnStopC("GSWTextField");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_dateFormat);
  DESTROY(_numberFormat);
  DESTROY(_useDecimalNumber);
  DESTROY(_formatter);
  [super dealloc];
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //OK
  BOOL disabledValue=NO;
  LOGObjectFnStartC("GSWTextField");
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);
  disabledValue=[self disabledInContext:context];
  if (!disabledValue)
    {
      BOOL wasFormSubmitted=[context _wasFormSubmitted];
      if (wasFormSubmitted)
        {
          GSWComponent* component=[context component];
          NSString* nameInContext=[self nameInContext:context];
          NSString* value=[request formValueForKey:nameInContext];
          id resultValue=nil;
          NSDebugMLLog(@"gswdync",@"nameInContext=%@",nameInContext);
          NSDebugMLLog(@"gswdync",@"value=%@",value);
          if (value)
            {
              NSFormatter* formatter=[self formatterForComponent:component];
              NSDebugMLLog(@"gswdync",@"formatter=%@",formatter);
              if (formatter)
                {
                  NSString* errorDscr=nil;
                  if ([formatter getObjectValue:&resultValue
                                  forString:value
                                  errorDescription:&errorDscr])
                    {
                      if (value && !resultValue)
                        {
                          NSWarnLog(@"There's a value (%@ of class %@) but no formattedValue with formater %@",
                                    value,
                                    [value class],
                                    formatter);
                        };
                    }
                  else
                    {
                      NSException* exception=nil;
                      NSString* valueKeyPath=[_value keyPath];
                      LOGException(@"EOValidationException resultValue=%@ valueKeyPath=%@",
                                   resultValue,valueKeyPath);
                      exception=[NSException exceptionWithName:@"EOValidationException"
                                             reason:errorDscr /*_exceptionDscr*/
                                             userInfo:[NSDictionary 
                                                        dictionaryWithObjectsAndKeys:
                                                          (resultValue ? resultValue : @"nil"),@"EOValidatedObjectUserInfoKey",
                                                        valueKeyPath,@"EOValidatedPropertyUserInfoKey",
                                                        nil,nil]];
                      [component validationFailedWithException:exception
                                 value:resultValue
                                 keyPath:valueKeyPath];
                    };
                }
              else
                resultValue=value;
            };
          NSDebugMLLog(@"gswdync",@"resultValue=%@",resultValue);

          // Turbocat
          if (NO)//([self _isFormattedValueInComponent:component
             //       equalToFormattedValue:value]) 
            {
              // does nothing, old formatted values are equal
            } 
          else 
            {              
              NS_DURING
                {
                  [_value setValue:resultValue
                          inComponent:component];
                }
              NS_HANDLER
                {
                  LOGException(@"GSWTextField _value=%@ resultValue=%@ exception=%@",
                               _value,resultValue,localException);
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
  GSWStopElement(context);
  LOGObjectFnStopC("GSWTextField");
};

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response
                                      inContext:(GSWContext*)context
{
  //OK
  id valueValue=nil;
  id formattedValue=nil;
  NSFormatter* formatter=nil;
  GSWComponent* component=nil;
  id valueTmp=nil;
  LOGObjectFnStartC("GSWTextField");
  component=[context component];
  //To avoid input value printing (stupid original hack !)
  valueTmp=_value;
  _value=nil;
  [super appendGSWebObjectsAssociationsToResponse:response
		 inContext:context];
  //To avoid input value printing (stupid original hack !)
  _value=valueTmp;
  valueTmp=nil;
  valueValue=[_value valueInComponent:component];
  formatter=[self formatterForComponent:component];
  if (!formatter)
    {
      NSDebugMLog0(@"No Formatter");
      formattedValue=valueValue;
    }
  else
    {
      formattedValue=[formatter stringForObjectValue:valueValue];
    };
  [response appendContentCharacter:' '];
  [response _appendContentAsciiString:@"value"];
  [response appendContentCharacter:'='];
  [response appendContentCharacter:'"'];
  [response appendContentHTMLAttributeValue:formattedValue];
  [response appendContentCharacter:'"'];
  LOGObjectFnStopC("GSWTextField");
};

//--------------------------------------------------------------------
-(NSFormatter*)formatterForComponent:(GSWComponent*)component
{
  //OK
  id formatValue = nil;
  id formatter = nil;
  LOGObjectFnStartC("GSWTextField");
  if (_dateFormat)
    {
      NSDebugMLog0(@"DateFormat");
      formatValue=[_dateFormat valueInComponent:component];
      if (formatValue)
        formatter=[[[NSDateFormatter alloc]initWithDateFormat:formatValue
                                           allowNaturalLanguage:YES]autorelease];
    }
  else if (_numberFormat)
    {
      NSDebugMLog0(@"NumberFormat");
      formatValue=[_numberFormat valueInComponent:component];
      if (formatValue)
        {
          //TODO
          /*
            formatter=[[NSNumberFormatter new]autorelease];
            [formatter setFormat:formatValue];
          */
        };
    }
  else
    {
      NSDebugMLog0(@"Formatter");
      formatter=[_formatter valueInComponent:component];
    };
  LOGObjectFnStopC("GSWTextField");
  return formatter;
};

@end

//====================================================================
@implementation GSWTextField (TurbocatAdditions)

//--------------------------------------------------------------------
- (BOOL)_isFormattedValueInComponent:(GSWComponent *)component  
               equalToFormattedValue:(NSString *)newFormattedValue 
{
  BOOL isFormattedValue=NO;

  if (newFormattedValue) 
    {
      id valueValue=nil;
      id formattedValue=nil;
      NSFormatter* formatter=nil;

      // get own value
      valueValue=[_value valueInComponent:component];
      formatter=[self formatterForComponent:component];
      if (!formatter)
        formattedValue=valueValue;
      else
        {
          formattedValue=[formatter stringForObjectValue:valueValue];
          if (valueValue && !formattedValue)
            {
              NSWarnLog(@"There's a value (%@ of class %@) but no formattedValue with formater %@",
                        valueValue,
                        [valueValue class],
                        formatter);
            };
        };
      if (formattedValue && [newFormattedValue isEqualToString:formattedValue]) 
        {
          NSLog(@"### GSWTextField : are EQUAL ###");
          isFormattedValue=YES;
        }
    };
  return isFormattedValue;
}

@end
