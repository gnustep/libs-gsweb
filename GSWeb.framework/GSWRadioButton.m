/* GSWRadioButton.m - GSWeb: Class GSWRadioButton
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

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWRadioButton

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)_elements
{
  NSMutableDictionary* _associations=[NSMutableDictionary dictionaryWithDictionary:associations_];
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"name_=%@ associations_:%@ _elements=%@",name_,associations_,_elements);
  [_associations setObject:[GSWAssociation associationWithValue:@"radio"]
				 forKey:@"type"];
  [_associations removeObjectForKey:selection__Key];
  [_associations removeObjectForKey:checked__Key];
  if ((self=[super initWithName:name_
				   associations:_associations
				   contentElements:nil]))
	{
	  selection=[[associations_ objectForKey:selection__Key
								   withDefaultObject:[selection autorelease]] retain];
	  if (selection && ![selection isValueSettable])
		{
		  ExceptionRaise0(@"GSWRadioButton",@"'selection' parameter must be settable");
		};
	  checked=[[associations_ objectForKey:checked__Key
								 withDefaultObject:[checked autorelease]] retain];
	  if (checked && ![checked isValueSettable])
		{
		  ExceptionRaise0(@"GSWRadioButton",@"'checked' parameter must be settable");
		};
	  if (!checked)
		{
		  if (!value || !selection)
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
  DESTROY(checked);
  DESTROY(selection);
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
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
									inContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _component=[context_ component];
  BOOL _disabledInContext=[self disabledInContext:context_];
  if (!_disabledInContext)
	{
	  BOOL _checked=NO;
	  [self appendValueToResponse:response_
			inContext:context_];
	  [self appendNameToResponse:response_
			inContext:context_];
	  if (checked)
		{
		  _checked=[self evaluateCondition:checked
						 inContext:context_];
		}
	  else if (value)
		{
		  id _valueValue=[value valueInComponent:_component];
		  id _selectionValue=[selection valueInComponent:_component];
		  _checked=SBIsValueEqual(_selectionValue,_valueValue);
		};
	  if (_checked)
		[response_ _appendContentAsciiString:@" checked"];
	};
};
@end

//====================================================================
@implementation GSWRadioButton (GSWRadioButtonB)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //OK
  BOOL _disabledInContext=NO;
  LOGObjectFnStart();
  _disabledInContext=[self disabledInContext:context_];
  if (!_disabledInContext)
	{
	  if ([context_ _wasFormSubmitted])
		{
		  BOOL _isEqual=NO;
		  GSWComponent* _component=[context_ component];
		  NSString* _name=nil;
		  id _formValue=nil;
		  id _valueValue=nil;
		  BOOL _checkChecked=NO;
		  _name=[self nameInContext:context_];
		  NSDebugMLLog(@"gswdync",@"_name=%@",_name);
		  _formValue=[request_ formValueForKey:_name];
		  _valueValue=[value valueInComponent:_component];
		  //TODO if checked !
		  _isEqual=SBIsValueEqual(_formValue,_valueValue);
		  if (_isEqual)
			{
			  _checkChecked=YES;
			  if (selection)
				{
#if !GSWEB_STRICT
				  NS_DURING
					{
					  [selection setValue:_valueValue
								 inComponent:_component];
					};
				  NS_HANDLER
					{
					  [self handleValidationException:localException
							inContext:context_];
					}
				  NS_ENDHANDLER;
#else
				  [selection setValue:_valueValue
							 inComponent:_component];
#endif
				};
			};
		  if (checked)
			{
			  id _checkedValue=[NSNumber numberWithBool:_checkChecked];
			  NSDebugMLLog(@"gswdync",@"_checkedValue=%@",_checkedValue);
#if !GSWEB_STRICT
			  NS_DURING
				{
				  [checked setValue:_checkedValue
						   inComponent:_component];
				};
			  NS_HANDLER
				{
				  [self handleValidationException:localException
						inContext:context_];
				}
			  NS_ENDHANDLER;
#else
			  [checked setValue:_checkedValue
					   inComponent:_component];
#endif
			};
		};
	};
  LOGObjectFnStop();
};

@end
