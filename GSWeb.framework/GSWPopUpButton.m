/* GSWPopUpButton.m - GSWeb: Class GSWPopUpButton
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
@implementation GSWPopUpButton

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)_elements
{
  //OK
  NSMutableDictionary* _associations=nil;
  LOGObjectFnStartC("GSWPopUpButton");
  NSDebugMLLog(@"gswdync",@"name_=%@ associations_:%@ _elements=%@",name_,associations_,_elements);
  _associations=[NSMutableDictionary dictionaryWithDictionary:associations_];
  [_associations removeObjectForKey:list__Key];
  [_associations removeObjectForKey:item__Key];
  [_associations removeObjectForKey:displayString__Key];
  [_associations removeObjectForKey:selection__Key];
#if !GSWEB_STRICT
  [_associations removeObjectForKey:selectionValue__Key];
#endif
  [_associations removeObjectForKey:selectedValue__Key];
  [_associations removeObjectForKey:noSelectionString__Key];
  [_associations removeObjectForKey:escapeHTML__Key];

  if ((self=[super initWithName:name_
				   associations:_associations
				   contentElements:nil]))
	{
	  list=[[associations_ objectForKey:list__Key
							  withDefaultObject:[list autorelease]] retain];
	  item=[[associations_ objectForKey:item__Key
							  withDefaultObject:[item autorelease]] retain];
	  displayString=[[associations_ objectForKey:displayString__Key
								   withDefaultObject:[displayString autorelease]] retain];
	  selection=[[associations_ objectForKey:selection__Key
								   withDefaultObject:[selection autorelease]] retain];
	  if (selection && ![selection isValueSettable])
		{
		  //TODO
		};

#if !GSWEB_STRICT
	  selectionValue=[[associations_ objectForKey:selectionValue__Key
									 withDefaultObject:[selectionValue autorelease]] retain];
	  if (selectionValue && ![selectionValue isValueSettable])
		{
		  //TODO
		};
#endif

	  selectedValue=[[associations_ objectForKey:selectedValue__Key
								   withDefaultObject:[selectedValue autorelease]] retain];
	  noSelectionString=[[associations_ objectForKey:noSelectionString__Key
								   withDefaultObject:[noSelectionString autorelease]] retain];
	  escapeHTML=[[associations_ objectForKey:escapeHTML__Key
								   withDefaultObject:[escapeHTML autorelease]] retain];
	};
  LOGObjectFnStopC("GSWPopUpButton");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(list);
  DESTROY(item);
  DESTROY(displayString);
  DESTROY(selection);
#if !GSWEB_STRICT
  DESTROY(selectionValue);
#endif
  DESTROY(selectedValue);
  DESTROY(noSelectionString);
  DESTROY(escapeHTML);
  [super dealloc];
};


//--------------------------------------------------------------------
-(NSString*)elementName
{
  return @"SELECT";
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
				   object_get_class_name(self),
				   (void*)self];
};

//====================================================================
@implementation GSWPopUpButton (GSWPopUpButtonA)

//#define ENABLE_OPTGROUP
//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
  GSWRequest* _request=nil;
  BOOL _isFromClientComponent=NO;
  GSWComponent* _component=nil;
  NSArray* _listValue=nil;
  id _selectionValue=nil;
  id _selectedValueValue=nil;
  id _valueValue=nil;
  id _itemValue=nil;
  id _displayStringValue=nil;
  BOOL _escapeHTML=YES;
  id _escapeHTMLValue=nil;
  int i=0;
  BOOL _inOptGroup=NO;
#ifndef ENABLE_OPTGROUP
  BOOL _optGroupLabel=NO;
#endif
  LOGObjectFnStartC("GSWPopUpButton");
  _request=[context_ request];
  _isFromClientComponent=[_request isFromClientComponent];
  _component=[context_ component];
  [super appendToResponse:response_
		 inContext:context_];
  _listValue=[list valueInComponent:_component];
  NSDebugMLLog(@"gswdync",@"_listValue=%@",_listValue);
  NSAssert3(!_listValue || [_listValue respondsToSelector:@selector(count)],
			@"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
			list,
			_listValue,
			[_listValue class]);
  _selectionValue=[selection valueInComponent:_component];
  NSDebugMLLog(@"gswdync",@"selection=%@",selection);
  NSDebugMLLog(@"gswdync",@"_selectionValue=%@",_selectionValue);
  _selectedValueValue=[selectedValue valueInComponent:_component];
  NSDebugMLLog(@"gswdync",@"selectedValue=%@",selectedValue);
  NSDebugMLLog(@"gswdync",@"_selectedValueValue=%@",_selectedValueValue);
  if (escapeHTML)
	{
	  _escapeHTMLValue=[escapeHTML valueInComponent:_component];
	  _escapeHTML=boolValueFor(_escapeHTMLValue);
	};
  if (noSelectionString)
	{
	  id _noSelectionStringValue=nil;
	  [response_ _appendContentAsciiString:@"\n<OPTION"];
	  if (selectedValue && !_selectedValueValue)
		{
		  [response_ appendContentCharacter:' '];
		  [response_ _appendContentAsciiString:@"selected"];//TODO
		};
	  [response_ appendContentCharacter:'>'];
	  _noSelectionStringValue=[noSelectionString valueInComponent:_component];
	  if (_escapeHTML)
		_noSelectionStringValue=[GSWResponse stringByEscapingHTMLString:_noSelectionStringValue];
	  [response_ appendContentHTMLString:_noSelectionStringValue];
          // There is no close tag on OPTION
	  //[response_ _appendContentAsciiString:@"</OPTION>"];
	};
  for(i=0;i<[_listValue count];i++)
	{
	  NSDebugMLLog(@"gswdync",@"_inOptGroup=%s",(_inOptGroup ? "YES" : "NO"));
	  _itemValue=[_listValue objectAtIndex:i];
	  if (item)
		[item setValue:_itemValue
			  inComponent:_component];
	  NSDebugMLLog(@"gswdync",@"_itemValue=%@",_itemValue);
	  if (_itemValue)
		{
		  _valueValue=nil;
		  NSDebugMLLog(@"gswdync",@"value=%@",value);
		  if (value)
			{
			  _valueValue=[value valueInComponent:_component];
			  NSDebugMLLog(@"gswdync",@"_valueValue=%@",_valueValue);
			  if (_valueValue)
				{
				  NSDebugMLLog0(@"gswdync",@"Adding OPTION");
				  [response_ _appendContentAsciiString:@"\n<OPTION"];
				  if (selectedValue)
					{
					  BOOL _isEqual=SBIsValueEqual(_valueValue,_selectedValueValue);
					  if (_isEqual)
						{
						  [response_ appendContentCharacter:' '];
						  [response_ _appendContentAsciiString:@"selected"];
						};
					};
				  if (value)
					{
					  [response_ _appendContentAsciiString:@" value=\""];
					  [response_ _appendContentAsciiString:_valueValue];
					  [response_ appendContentCharacter:'"'];
					};
				  [response_ appendContentCharacter:'>'];
				};
			};
		  _displayStringValue=nil;
		  if (displayString)
			{
			  NSDebugMLLog(@"gswdync",@"displayString=%@",displayString);
			  _displayStringValue=[displayString valueInComponent:_component];
			  NSDebugMLLog(@"gswdync",@"_displayStringValue=%@",_displayStringValue);
			};

		  if (_displayStringValue)
			{
			  if (!_valueValue)
				{
				  if (_inOptGroup)
					{
					  NSDebugMLLog0(@"gswdync",@"Adding /OPTGROUP");
#ifdef ENABLE_OPTGROUP
					  [response_ _appendContentAsciiString:@"\n</OPTGROUP>"];
#endif
					  _inOptGroup=NO;
					};
				  NSDebugMLLog0(@"gswdync",@"Adding OPTGROUP");
#ifdef ENABLE_OPTGROUP
				  [response_ _appendContentAsciiString:@"\n<OPTGROUP label=\""];
#else
				  [response_ _appendContentAsciiString:@"\n<OPTION>-- "];
				  _optGroupLabel=YES;
#endif
				  _inOptGroup=YES;
				};
			  //<OPTGROUP label="PortMaster 3">

			  if (_escapeHTML)
				_displayStringValue=[GSWResponse stringByEscapingHTMLString:_displayStringValue];
			  NSDebugMLLog(@"gswdync",@"_displayStringValue=%@",_displayStringValue);
#ifndef ENABLE_OPTGROUP
			  if (_optGroupLabel)
				{
				  _displayStringValue=[NSString stringWithFormat:@"%@ --",_displayStringValue];
				};
#endif
			  [response_ appendContentHTMLString:_displayStringValue];
			};
		  if (_valueValue)
			{
			  //NSDebugMLLog0(@"gswdync",@"Adding /OPTION");
                          // K2- No /OPTION TAG
			  //[response_ _appendContentAsciiString:@"</OPTION>"];
			}
		  else
			{
			  NSDebugMLLog0(@"gswdync",@"Adding > or </OPTION>");
#ifdef ENABLE_OPTGROUP
			  [response_ _appendContentAsciiString:@"\">"];
#else
			  if (_optGroupLabel)
				{
				  //[response_ _appendContentAsciiString:@"</OPTION>"];
				  _optGroupLabel=NO;
				};
#endif
			};
		};
	};
  if (_inOptGroup)
	{
#ifdef ENABLE_OPTGROUP
	  NSDebugMLLog0(@"gswdync",@"Adding /OPTGROUP");
	  [response_ _appendContentAsciiString:@"\n</OPTGROUP>"];
#endif
	  _inOptGroup=NO;
	};
  [response_ _appendContentAsciiString:@"</SELECT>"];
  LOGObjectFnStopC("GSWPopUpButton");
};

//--------------------------------------------------------------------
-(void)appendValueToResponse:(GSWResponse*)response_
					inContext:(GSWContext*)context_
{
  //OK
  //Does nothing !
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //OK
  LOGObjectFnStartC("GSWPopUpButton");
  [self _slowTakeValuesFromRequest:request_
		inContext:context_];
  LOGObjectFnStopC("GSWPopUpButton");
};

//--------------------------------------------------------------------
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request_
						inContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_slowTakeValuesFromRequest:(GSWRequest*)request_
						inContext:(GSWContext*)context_
{
  //OK
  BOOL _disabled=NO;
  BOOL _wasFormSubmitted=NO;
  LOGObjectFnStartC("GSWPopUpButton");
  _disabled=[self disabledInContext:context_];
  if (!_disabled)
	{
	  _wasFormSubmitted=[context_ _wasFormSubmitted];
	  if (_wasFormSubmitted)
		{
		  GSWComponent* _component=nil;
		  NSArray* _listValue=nil;
		  id _valueValue=nil;
		  id _itemValue=nil;
		  NSString* _name=nil;
		  NSArray* _formValues=nil;
		  id _formValue=nil;
		  BOOL _found=NO;
		  int i=0;
		  _component=[context_ component];
		  _name=[self nameInContext:context_];
		  NSDebugMLLog(@"gswdync",@"_name=%@",_name);
		  _formValues=[request_ formValuesForKey:_name];
		  NSDebugMLLog(@"gswdync",@"_formValues=%@",_formValues);
		  if (_formValues && [_formValues count])
			{
			  BOOL _isEqual=NO;
			  _formValue=[_formValues objectAtIndex:0];
			  NSDebugMLLog(@"gswdync",@"_formValue=%@",_formValue);
			  _listValue=[list valueInComponent:_component];
			  NSAssert3(!_listValue || [_listValue respondsToSelector:@selector(count)],
						@"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
						list,
						_listValue,
						[_listValue class]);
			  for(i=0;!_found && i<[_listValue count];i++)
				{
				  _itemValue=[_listValue objectAtIndex:i];
				  NSDebugMLLog(@"gswdync",@"_itemValue=%@",_itemValue);
				  NSDebugMLLog(@"gswdync",@"item=%@",item);
				  if (item)
					[item setValue:_itemValue
						  inComponent:_component];
				  NSDebugMLLog(@"gswdync",@"value=%@",value);
				  if (value)
					_valueValue=[value valueInComponent:_component];
				  NSDebugMLLog(@"gswdync",@"_valueValue=%@ [class=%@] _formValue=%@ [class=%@]",
						 _valueValue,[_valueValue class],
						 _formValue,[_formValue class]);
				  _isEqual=SBIsValueEqual(_valueValue,_formValue);
				  if (_isEqual)
					{
					  NSDebugMLLog(@"gswdync",@"selection=%@",selection);
					  if (selection)
						{
#if !GSWEB_STRICT
						  NS_DURING
							{
							  [selection setValue:_itemValue
										 inComponent:_component];
							};
						  NS_HANDLER
							{
							  [self handleValidationException:localException
									inContext:context_];
							}
						  NS_ENDHANDLER;
#else
						  [selection setValue:_itemValue
									 inComponent:_component];
#endif
						};
#if !GSWEB_STRICT
					  NSDebugMLLog(@"gswdync",@"selectionValue=%@",selectionValue);
					  if (selectionValue)
						{
						  NS_DURING
							{
							  [selectionValue setValue:_valueValue
											  inComponent:_component];
							};
						  NS_HANDLER
							{
							  [self handleValidationException:localException
									inContext:context_];
							}
						  NS_ENDHANDLER;
						};
#endif
					  _found=YES;
					};
				};
			};
		  NSDebugMLLog(@"gswdync",@"_found=%s",(_found ? "YES" : "NO"));
		  if (!_found)
			{
			  if (selection)
				{
#if !GSWEB_STRICT
				  NS_DURING
					{
					  [selection setValue:nil
								 inComponent:_component];
					};
				  NS_HANDLER
					{
					  [self handleValidationException:localException
							inContext:context_];
					}
				  NS_ENDHANDLER;
#else
				  [selection setValue:nil
							 inComponent:_component];
#endif
				};
#if !GSWEB_STRICT
			  if (selectionValue)
				{
				  NS_DURING
					{
					  [selectionValue setValue:nil
									  inComponent:_component];
					};
				  NS_HANDLER
					{
					  [self handleValidationException:localException
							inContext:context_];
					}
				  NS_ENDHANDLER;
				};
#endif
			};
		};
	};
  LOGObjectFnStopC("GSWPopUpButton");
};


@end

//====================================================================
@implementation GSWPopUpButton (GSWPopUpButtonB)
-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};
@end

