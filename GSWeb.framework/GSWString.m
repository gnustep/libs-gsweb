/* GSWString.m - GSWeb: Class GSWString
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

@implementation GSWString

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)_elements
{
  //OK
  LOGObjectFnStartC("GSWString");
  NSDebugMLLog(@"gswdync",@"name_=%@ associations_:%@ _elements=%@",name_,associations_,_elements);
  if ((self=[super initWithName:nil
				   associations:nil
				   contentElements:nil]))
	{
	  value = [[associations_ objectForKey:value__Key
								 withDefaultObject:[value autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWString: value=%@",value);

	  dateFormat = [[associations_ objectForKey:dateFormat__Key
									  withDefaultObject:[dateFormat autorelease]] retain];

	  NSDebugMLLog(@"gswdync",@"GSWString: dateFormat=%@",dateFormat);

	  numberFormat = [[associations_ objectForKey:numberFormat__Key
										withDefaultObject:[numberFormat autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWString: numberFormat=%@",numberFormat);

	  escapeHTML = [[associations_ objectForKey:escapeHTML__Key
									  withDefaultObject:[escapeHTML autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWString: escapeHTML=%@",escapeHTML);

          if (!WOStrictFlag)
            {
              convertHTML = [[associations_ objectForKey:convertHTML__Key
                                            withDefaultObject:[convertHTML autorelease]] retain];
              NSDebugMLLog(@"gswdync",@"GSWString: convertHTML=%@",convertHTML);
              
              convertHTMLEntities = [[associations_ objectForKey:convertHTMLEntities__Key
                                                    withDefaultObject:[convertHTMLEntities autorelease]] retain];
              NSDebugMLLog(@"gswdync",@"GSWString: convertHTMLEntities=%@",convertHTMLEntities);
            };

	  formatter = [[associations_ objectForKey:formatter__Key
								  withDefaultObject:[formatter autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWString: formatter=%@",formatter);

	};
  LOGObjectFnStopC("GSWString");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(value);
  DESTROY(dateFormat);
  DESTROY(numberFormat);
  DESTROY(escapeHTML);
  DESTROY(convertHTML); //GSWeb Only
  DESTROY(convertHTMLEntities); //GSWeb Only
  DESTROY(formatter);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - value=%@ dateFormat=%@ numberFormat=%@ escapeHTML=%@ formatter=%@>",
				   object_get_class_name(self),
				   (void*)self,
				   value,
				   dateFormat,
				   numberFormat,
				   escapeHTML,
				   formatter];
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
  NSString* _formattedValue=nil;
  GSWRequest* _request=nil;
  BOOL _isFromClientComponent=NO;
  GSWComponent* _component=nil;
  id _valueValue = nil;
  LOGObjectFnStartC("GSWString");
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  _request=[context_ request];
  _isFromClientComponent=[_request isFromClientComponent];
  _component=[context_ component];
  NSDebugMLLog(@"gswdync",@"GSWString: _component=%@",_component);
  NSDebugMLLog(@"gswdync",@"GSWString: value=%@",value);
  _valueValue = [value valueInComponent:_component];
  NSDebugMLLog(@"gswdync",@"GSWString: _valueValue=%@",_valueValue);
  if (_valueValue)
	{
	  BOOL _escapeHTMLValue=YES;
	  BOOL _convertHTMLValue=NO;
	  BOOL _convertHTMLEntitiesValue=NO;
	  NSFormatter* _formatter=[self formatterForComponent:_component
									value:_valueValue];
	  if (!_formatter)
		{
		  _formattedValue=_valueValue;
		}
	  else
		{
		  _formattedValue=[_formatter stringForObjectValue:_valueValue];
		};

	  if (!WOStrictFlag && convertHTML)
		_convertHTMLValue=[self evaluateCondition:convertHTML
								inContext:context_];
	  if (!WOStrictFlag)
            {
              if (!_convertHTMLValue)
		{
		  if (convertHTMLEntities)
			_convertHTMLEntitiesValue=[self evaluateCondition:convertHTMLEntities
											inContext:context_];
		  if (!_convertHTMLEntitiesValue)
			{
			  if (escapeHTML)
				_escapeHTMLValue=[self evaluateCondition:escapeHTML
									   inContext:context_];
			};
		};
            }
          else if (escapeHTML)
            _escapeHTMLValue=[self evaluateCondition:escapeHTML
                                   inContext:context_];

	  if (!WOStrictFlag && _convertHTMLValue)
		[response_ appendContentHTMLConvertString:_formattedValue];
	  else if (!WOStrictFlag && _convertHTMLEntitiesValue)
		[response_ appendContentHTMLEntitiesConvertString:_formattedValue];
	  else if (_escapeHTMLValue)
            [response_ appendContentHTMLString:_formattedValue];
          else
            [response_ appendContentString:_formattedValue];
	};
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
  LOGObjectFnStopC("GSWString");
};

//--------------------------------------------------------------------
-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)appendStringAtLeft:(id)_unkwnon
			  withMapping:(char*)_mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(NSFormatter*)formatterForComponent:(GSWComponent*)_component
							   value:(id)value_
{
  //OK
  id _formatValue = nil;
  NSFormatter* _formatter = nil;
  LOGObjectFnStartC("GSWString");
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
/*		  _formatter=[[NSNumberFormatter new]autorelease];
		  [_formatter setFormat:_formatValue];
*/
		};
	}
  else
	{
	  NSDebugMLog0(@"Formatter");
	  _formatter=[formatter valueInComponent:_component];
	};
  LOGObjectFnStopC("GSWString");
  return _formatter;
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};


@end

//====================================================================

@implementation GSWString (GSWStringA)

//--------------------------------------------------------------------
+(BOOL)hasGSWebObjectsAssociations
{
  return YES;
};

@end
