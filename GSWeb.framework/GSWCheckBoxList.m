/* GSWCheckBoxList.m - GSWeb: Class GSWCheckBoxList
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
@implementation GSWCheckBoxList

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_
{
  NSMutableDictionary* _associations=[NSMutableDictionary dictionaryWithDictionary:associations_];
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"name_=%@ associations_:%@ elements_=%@",name_,associations_,elements_);
  defaultEscapeHTML=1;
  [_associations removeObjectForKey:list__Key];
  [_associations removeObjectForKey:item__Key];
  [_associations removeObjectForKey:index__Key];
  [_associations removeObjectForKey:prefix__Key];
  [_associations removeObjectForKey:suffix__Key];
  [_associations removeObjectForKey:selections__Key];
  [_associations removeObjectForKey:displayString__Key];
  [_associations removeObjectForKey:escapeHTML__Key];
  if ((self=[super initWithName:name_
				   associations:_associations
				   contentElements:nil]))
	{
	  list = [[associations_ objectForKey:list__Key
							 withDefaultObject:[list autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"list=%@",list);

	  item = [[associations_ objectForKey:item__Key
							 withDefaultObject:[item autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"item=%@",item);
	  if (item && ![item isValueSettable])
		{
		  ExceptionRaise0(@"GSWCheckBox",@"'item' parameter must be settable");
		};

	  value = [[associations_ objectForKey:value__Key
							  withDefaultObject:[value autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"value=%@",value);

	  index = [[associations_ objectForKey:index__Key
							  withDefaultObject:[index autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"index=%@",index);
	  if (index && ![index isValueSettable])
		{
		  ExceptionRaise0(@"GSWCheckBox",@"'index' parameter must be settable");
		};
	  
	  prefix = [[associations_ objectForKey:prefix__Key
							   withDefaultObject:[prefix autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"prefix=%@",prefix);

	  suffix = [[associations_ objectForKey:suffix__Key
							   withDefaultObject:[suffix autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"suffix=%@",suffix);

	  selections = [[associations_ objectForKey:selections__Key
								   withDefaultObject:[selections autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"selections=%@",selections);
	  if (![selections isValueSettable])
		{
		  ExceptionRaise0(@"GSWCheckBox",@"'selection' parameter must be settable");
		};

	  displayString = [[associations_ objectForKey:displayString__Key
									  withDefaultObject:[displayString autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"displayString=%@",displayString);
	  
	  escapeHTML = [[associations_ objectForKey:escapeHTML__Key
								   withDefaultObject:[escapeHTML autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"escapeHTML=%@",escapeHTML);
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(list);
  DESTROY(item);
  DESTROY(index);
  DESTROY(selections);
  DESTROY(prefix);
  DESTROY(suffix);
  DESTROY(displayString);
  DESTROY(escapeHTML);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
				   object_get_class_name(self),
				   (void*)self];
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return @"INPUT";
};

@end

//====================================================================
@implementation GSWCheckBoxList (GSWCheckBoxListA)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //OK
  LOGObjectFnStartC("GSWCheckBoxList");
  [self _slowTakeValuesFromRequest:request_
		inContext:context_];
  LOGObjectFnStopC("GSWCheckBoxList");
};

//-----------------------------------------------------------------------------------
-(void)_slowTakeValuesFromRequest:(GSWRequest*)request_
						inContext:(GSWContext*)context_
{
  //OK
  BOOL _disabledInContext=NO;
  LOGObjectFnStartC("GSWCheckBoxList");
  _disabledInContext=[self disabledInContext:context_];
  if (!_disabledInContext)
	{
	  if ([context_ _wasFormSubmitted])
		{
		  GSWComponent* _component=[context_ component];
		  NSArray* _listValue=nil;
		  NSMutableArray* _selections=nil;
		  NSString* _name=nil;
		  NSArray* _formValues=nil;
		  id _valueValue=nil;
		  int i=0;
		  _name=[self nameInContext:context_];
		  NSDebugMLLog(@"gswdync",@"_name=%@",_name);
		  _formValues=[request_ formValuesForKey:_name];
		  NSDebugMLLog(@"gswdync",@"_formValues=%@",_formValues);
		  _listValue=[list valueInComponent:_component];
		  NSAssert3(!_listValue || [_listValue respondsToSelector:@selector(count)],
					@"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
					list,
					_listValue,
					[_listValue class]);
		  NSDebugMLLog(@"gswdync",@"_listValue=%@",_listValue);
		  for(i=0;i<[_listValue count];i++)
			{
			  NSDebugMLLog(@"gswdync",@"item=%@",item);
			  NSDebugMLLog(@"gswdync",@"index=%@",index);
			  if (item)
				[item setValue:[_listValue objectAtIndex:i]
					  inComponent:_component];
			  else if (index)
				[index setValue:[NSNumber numberWithShort:i]
					   inComponent:_component];
			  NSDebugMLLog(@"gswdync",@"value=%@",value);
			  if (value)
				{
				  _valueValue=[value valueInComponent:_component];
				  NSDebugMLLog(@"gswdync",@"_valueValue=%@",_valueValue);
				  if (_valueValue)
					{
					  BOOL _found=[_formValues containsObject:_valueValue];
					  NSDebugMLLog(@"gswdync",@"_found=%s",(_found ? "YES" : "NO"));
					  if (_found)
						{
						  if (!_selections)
							_selections=[NSMutableArray array];
						  [_selections addObject:[item valueInComponent:_component]];
						};
					};
				};
			};
		  NSDebugMLLog(@"gswdync",@"_component=%@",_component);
		  NSDebugMLLog(@"gswdync",@"_selections=%d",_selections);
		  NSDebugMLLog(@"gswdync",@"selections=%@",selections);
		  GSWLogAssertGood(_component);
#if !GSWEB_STRICT
		  NS_DURING
			{
			  [selections setValue:_selections
						  inComponent:_component];
			};
		  NS_HANDLER
			{
			  [self handleValidationException:localException
					inContext:context_];
			}
		  NS_ENDHANDLER;
#else
		  [selections setValue:_selections
					  inComponent:_component];
#endif
		};
	};
  LOGObjectFnStopC("GSWCheckBoxList");
};

//-----------------------------------------------------------------------------------
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request_
						inContext:(GSWContext*)context_
{
  LOGObjectFnStartC("GSWCheckBoxList");
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStopC("GSWCheckBoxList");
};
//-----------------------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
  GSWRequest* _request=nil;
  BOOL _isFromClientComponent=NO;
  NSString* _name=nil;
  GSWComponent* _component=nil;
  NSArray* _selectionsValue=nil;
  LOGObjectFnStartC("GSWCheckBoxList");
  _request=[context_ request];
  _isFromClientComponent=[_request isFromClientComponent];
  _name=[self nameInContext:context_];
  _component=[context_ component];
  _selectionsValue=[selections valueInComponent:_component];
  if (_selectionsValue && ![_selectionsValue isKindOfClass:[NSArray class]])
	{
	   ExceptionRaise(@"GSWCheckBoxList",
					  @"GSWCheckBoxList: selections is not a NSArray: %@ %@",
					  _selectionsValue,
					  [_selectionsValue class]);
	}
  else
	{
	  int i=0;
	  id _displayStringValue=nil;
	  id _prefixValue=nil;
	  id _suffixValue=nil;
	  id _valueValue=nil;
	  NSArray* _listValue=[list valueInComponent:_component];
	  NSAssert3(!_listValue || [_listValue respondsToSelector:@selector(count)],
				@"The list (%@) (%@ of class:%@) doesn't  respond to 'count'",
				list,
				_listValue,
				[_listValue class]);
	  for(i=0;i<[_listValue count];i++)
		{
		  [item setValue:[_listValue objectAtIndex:i]
				inComponent:_component];
		  _prefixValue=[prefix valueInComponent:_component];
		  _suffixValue=[suffix valueInComponent:_component];
		  [index setValue:[NSNumber numberWithShort:i]
				 inComponent:_component];
		  _displayStringValue=[displayString valueInComponent:_component];
		  [response_ appendContentString:@"<INPUT NAME=\""];
		  [response_ appendContentString:_name];
		  [response_ appendContentString:@"\" TYPE=checkbox VALUE=\""];
		  _valueValue=[value valueInComponent:_component];
		  [response_ appendContentHTMLAttributeValue:_valueValue];
		  [response_ appendContentCharacter:'"'];
		  //TODOV
		  if ([_selectionsValue containsObject:_valueValue])
			[response_ appendContentString:@"\" CHECKED"];
		  [response_ appendContentCharacter:'>'];
		  [response_ appendContentString:_prefixValue];
		  [response_ appendContentHTMLString:_displayStringValue];
		  [response_ appendContentString:_suffixValue];
		};
	};
  LOGObjectFnStopC("GSWCheckBoxList");
};

@end

//====================================================================
@implementation GSWCheckBoxList (GSWCheckBoxListB)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
									inContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWCheckBoxList (GSWCheckBoxListC)
-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

-(BOOL)appendStringAtLeft:(id)_unkwnon
			  withMapping:(char*)_mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

-(BOOL)compactHTMLTags
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

@end
