/* GSWCheckBox.m - GSWeb: Class GSWCheckBox
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
@implementation GSWCheckBox

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)_elements
{
  NSMutableDictionary* _associations=[NSMutableDictionary dictionaryWithDictionary:associations_];
  LOGObjectFnStartC("GSWCheckBox");
  NSDebugMLLog(@"gswdync",@"name_=%@ associations_:%@ _elements=%@",name_,associations_,_elements);
  [_associations setObject:[GSWAssociation associationWithValue:@"checkbox"]
				 forKey:@"type"];
  [_associations removeObjectForKey:selection__Key];
  [_associations removeObjectForKey:checked__Key];
  if ((self=[super initWithName:name_
				   associations:_associations
				   contentElements:nil]))
	{
	  //TODOV
	  selection=[[associations_ objectForKey:selection__Key
								   withDefaultObject:[selection autorelease]] retain];
	  if (selection && ![selection isValueSettable])
		{
		  ExceptionRaise0(@"GSWCheckBox",@"'selection' parameter must be settable");
		};
	  checked=[[associations_ objectForKey:checked__Key
								 withDefaultObject:[checked autorelease]] retain];
	  if (checked && ![checked isValueSettable])
		{
		  ExceptionRaise0(@"GSWCheckBox",@"'checked' parameter must be settable");
		};
	  if (!checked)
		{
		  if (!value || !selection)
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
@implementation GSWCheckBox (GSWCheckBoxA)

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)_response
									  inContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _component=nil;
  BOOL _disabledInContext=NO;
  LOGObjectFnStartC("GSWCheckBox");
  _component=[context_ component];
  _disabledInContext=[self disabledInContext:context_];
  if (!_disabledInContext)
	{
	  BOOL _checked=NO;
	  [self appendValueToResponse:_response
			inContext:context_];
	  [self appendNameToResponse:_response
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
		[_response _appendContentAsciiString:@" checked"];
	};
  LOGObjectFnStopC("GSWCheckBox");
};

@end

//====================================================================
@implementation GSWCheckBox (GSWCheckBoxB)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //OK
  BOOL _disabledInContext=NO;
  LOGObjectFnStartC("GSWCheckBox");
  _disabledInContext=[self disabledInContext:context_];
  if (!_disabledInContext)
	{
	  if ([context_ _wasFormSubmitted])
		{
		  GSWComponent* _component=[context_ component];
		  NSString* _name=nil;
		  NSArray* _formValues=nil;
//		  GSWElementIDString* _elementID=nil;
		  BOOL _checkChecked=NO;
		  _name=[self nameInContext:context_];
		  NSDebugMLLog(@"gswdync",@"_name=%@",_name);
		  _formValues=[request_ formValuesForKey:_name];
//		  _elementID=[[context_ elementID] copy]; //!! when release ?
		  //???
		  NSDebugMLLog(@"gswdync",@"_formValues=%@",_formValues);
		  if (_formValues && [_formValues count])
			{
			  NSDebugMLLog(@"gswdync",@"[_formValues objectAtIndex:0]=%@",[_formValues objectAtIndex:0]);
			  _checkChecked=YES;
			  if (selection)
				{
				  //TODOV
				  id _valueValue=[value valueInComponent:_component];
                                  if (!WOStrictFlag)
                                    {
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
                                    }
                                  else
                                    {
                                      [selection setValue:_valueValue
                                                 inComponent:_component];
                                    };
				};
			};
		  if (checked)
			{
			  id _checkedValue=[NSNumber numberWithBool:_checkChecked];
			  NSDebugMLLog(@"gswdync",@"_checkedValue=%@",_checkedValue);
                          if (!WOStrictFlag)
                            {
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
                            }
                          else
                            {
                              [checked setValue:_checkedValue
                                       inComponent:_component];
                            };
			};
		};
	};
  LOGObjectFnStopC("GSWCheckBox");
};

@end


