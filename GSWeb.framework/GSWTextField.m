/* GSWTextField.h - GSWeb: Class GSWTextField
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
   This file is part of the GNUstep Web Library.
   
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
*/

static char rcsId[] = "$Id$";

#include <gsweb/GSWeb.framework/GSWeb.h>

//====================================================================
@implementation GSWTextField

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_
{
  NSMutableDictionary* _associations=[NSMutableDictionary dictionaryWithDictionary:associations_];
  LOGObjectFnStartC("GSWTextField");
  NSDebugMLLog(@"gswdync",@"name_=%@ associations_:%@ elements_=%@",name_,associations_,elements_);
  [_associations setObject:[GSWAssociation associationWithValue:@"text"]
				 forKey:@"type"];
  [_associations removeObjectForKey:dateFormat__Key];
  [_associations removeObjectForKey:numberFormat__Key];
  [_associations removeObjectForKey:useDecimalNumber__Key];
  [_associations removeObjectForKey:formatter__Key];
  if ((self=[super initWithName:name_
				   associations:_associations
				   contentElements:nil])) //No Childs!
	{
	  dateFormat = [[associations_ objectForKey:dateFormat__Key
								   withDefaultObject:[dateFormat autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWTextField: dateFormat=%@",dateFormat);
	  numberFormat = [[associations_ objectForKey:numberFormat__Key
									  withDefaultObject:[numberFormat autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWTextField: numberFormat=%@",numberFormat);
	  useDecimalNumber = [[associations_ objectForKey:useDecimalNumber__Key
									  withDefaultObject:[useDecimalNumber autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWTextField: useDecimalNumber=%@",useDecimalNumber);
	  formatter = [[associations_ objectForKey:formatter__Key
									  withDefaultObject:[formatter autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWTextField: formatter=%@",formatter);
	};
  LOGObjectFnStopC("GSWTextField");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(dateFormat);
  DESTROY(numberFormat);
  DESTROY(useDecimalNumber);
  DESTROY(formatter);
  [super dealloc];
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //OK
  BOOL _disabled=NO;
  LOGObjectFnStartC("GSWTextField");
  GSWAssertCorrectElementID(context_);// Debug Only
  _disabled=[self disabledInContext:context_];
  if (!_disabled)
	{
	  BOOL _wasFormSubmitted=[context_ _wasFormSubmitted];
	  if (_wasFormSubmitted)
		{
		  GSWComponent* _component=[context_ component];
		  NSString* _nameInContext=[self nameInContext:context_];
		  NSString* _value=[request_ formValueForKey:_nameInContext];
		  id _resultValue=nil;
		  NSDebugMLLog(@"gswdync",@"_nameInContext=%@",_nameInContext);
		  NSDebugMLLog(@"gswdync",@"_value=%@",_value);
		  if (_value)
			{
			  NSFormatter* _formatter=[self formatterForComponent:_component];
			  NSDebugMLLog(@"gswdync",@"_formatter=%@",_formatter);
			  if (_formatter)
				{
				  NSString* _errorDscr=nil;
				  if (![_formatter getObjectValue:&_resultValue
								   forString:_value
								   errorDescription:&_errorDscr])
					{
					  NSException* _exception=nil;
					  NSString* _valueKeyPath=[value keyPath];
					  LOGException(@"EOValidationException _resultValue=%@ _valueKeyPath=%@",_resultValue,_valueKeyPath);
					  _exception=[NSException exceptionWithName:@"EOValidationException"
											  reason:_errorDscr /*_exceptionDscr*/
											  userInfo:[NSDictionary 
														 dictionaryWithObjectsAndKeys:
														   (_resultValue ? _resultValue : @"nil"),@"EOValidatedObjectUserInfoKey",
														 _valueKeyPath,@"EOValidatedPropertyUserInfoKey",
														 nil,nil]];
					  [_component validationFailedWithException:_exception
								  value:_resultValue
								  keyPath:_valueKeyPath];
					};
				}
			  else
				_resultValue=_value;
			};
		  NSDebugMLLog(@"gswdync",@"_resultValue=%@",_resultValue);
#if !GSWEB_STRICT
		  NS_DURING
			{
			  [value setValue:_resultValue
					 inComponent:_component];
			};
	  	  NS_HANDLER
			{
			  [self handleValidationException:localException
					inContext:context_];
			}
		  NS_ENDHANDLER;
#else
		  [value setValue:_resultValue
				 inComponent:_component];		  
#endif

		};
	};
  LOGObjectFnStopC("GSWTextField");
};

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)_response
									inContext:(GSWContext*)context_
{
  //OK
  id _valueValue=nil;
  id _formattedValue=nil;
  NSFormatter* _formatter=nil;
  GSWComponent* _component=nil;
  id _valueTmp=nil;
  LOGObjectFnStartC("GSWTextField");
  _component=[context_ component];
  //To avoid input value printing (stupid original hack !)
  _valueTmp=value;
  value=nil;
  [super appendGSWebObjectsAssociationsToResponse:_response
		 inContext:context_];
  //To avoid input value printing (stupid original hack !)
  value=_valueTmp;
  _valueTmp=nil;
  _valueValue=[value valueInComponent:_component];
  _formatter=[self formatterForComponent:_component];
  if (!_formatter)
	{
	  NSDebugMLog0(@"No Formatter");
	  _formattedValue=_valueValue;
	}
  else
	{
	  _formattedValue=[_formatter stringForObjectValue:_valueValue];
	};
  [_response appendContentCharacter:' '];
  [_response _appendContentAsciiString:@"value"];
  [_response appendContentCharacter:'='];
  [_response appendContentCharacter:'"'];
  [_response appendContentHTMLAttributeValue:_formattedValue];
  [_response appendContentCharacter:'"'];
  LOGObjectFnStopC("GSWTextField");
};

//--------------------------------------------------------------------
-(NSFormatter*)formatterForComponent:(GSWComponent*)_component
{
  //OK
  id _formatValue = nil;
  id _formatter = nil;
  LOGObjectFnStartC("GSWTextField");
  if (dateFormat)
	{
	  NSDebugMLog0(@"DateFormat");
	  _formatValue=[dateFormat valueInComponent:_component];
	  if (_formatValue)
		_formatter=[[[NSDateFormatter alloc]initWithDateFormat:_formatValue
										   allowNaturalLanguage:YES]autorelease];
	}
  else if (numberFormat)
	{
	  NSDebugMLog0(@"NumberFormat");
	  _formatValue=[numberFormat valueInComponent:_component];
	  if (_formatValue)
		{
//TODO
/*
		  _formatter=[[NSNumberFormatter new]autorelease];
		  [_formatter setFormat:_formatValue];
*/
		};
	}
  else
	{
	  NSDebugMLog0(@"Formatter");
	  _formatter=[formatter valueInComponent:_component];
	};
  LOGObjectFnStopC("GSWTextField");
  return _formatter;
};

@end

