/** GSWString.m - <title>GSWeb: Class GSWString</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        Jan 1999
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

static SEL formattedValueInContextSEL = NULL;

static IMP standardFormattedValueInContextIMP = NULL;
static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWString

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWString class])
    {
      standardClass=[GSWString class];
      formattedValueInContextSEL=@selector(formattedValueInContext:);

      standardFormattedValueInContextIMP = 
        [self instanceMethodForSelector:formattedValueInContextSEL];
      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  //OK
  LOGObjectFnStartC("GSWString");
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ elements=%@",
               aName,associations,elements);
  if ((self=[super initWithName:nil
                   associations:nil
                   contentElements:nil]))
    {
      _value = [[associations objectForKey:value__Key
                               withDefaultObject:[_value autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWString: value=%@",_value);

      _dateFormat = [[associations objectForKey:dateFormat__Key
                                    withDefaultObject:[_dateFormat autorelease]] retain];

      NSDebugMLLog(@"gswdync",@"GSWString: dateFormat=%@",_dateFormat);

      _numberFormat = [[associations objectForKey:numberFormat__Key
                                     withDefaultObject:[_numberFormat autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWString: numberFormat=%@",_numberFormat);

      _escapeHTML = [[associations objectForKey:escapeHTML__Key
                                    withDefaultObject:[_escapeHTML autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWString: escapeHTML=%@",_escapeHTML);

      if (!WOStrictFlag)
        {
          _convertHTML = [[associations objectForKey:convertHTML__Key
                                         withDefaultObject:[_convertHTML autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"GSWString: convertHTML=%@",_convertHTML);
              
          _convertHTMLEntities = [[associations objectForKey:convertHTMLEntities__Key
                                                 withDefaultObject:[_convertHTMLEntities autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"GSWString: convertHTMLEntities=%@",_convertHTMLEntities);
        };
      
      _formatter = [[associations objectForKey:formatter__Key
                                   withDefaultObject:[_formatter autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWString: formatter=%@",_formatter);
    };
  LOGObjectFnStopC("GSWString");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_value);
  DESTROY(_dateFormat);
  DESTROY(_numberFormat);
  DESTROY(_escapeHTML);
  DESTROY(_convertHTML); //GSWeb Only
  DESTROY(_convertHTMLEntities); //GSWeb Only
  DESTROY(_formatter);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - value=%@ dateFormat=%@ numberFormat=%@ escapeHTML=%@ formatter=%@>",
                   object_get_class_name(self),
                   (void*)self,
                   _value,
                   _dateFormat,
                   _numberFormat,
                   _escapeHTML,
                   _formatter];
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  //OK
  NSString* formattedValue=nil;
  GSWRequest* request=nil;
  BOOL isFromClientComponent=NO;
  GSWComponent* component=nil;

  LOGObjectFnStartC("GSWString");

  GSWStartElement(aContext);
  GSWSaveAppendToResponseElementID(aContext);

  request=[aContext request];
  isFromClientComponent=[request isFromClientComponent];
  component=GSWContext_component(aContext);

  if (object_get_class(self)==standardClass)
    formattedValue=(*standardFormattedValueInContextIMP)(self,formattedValueInContextSEL,aContext);
  else
    formattedValue=[self formattedValueInContext:aContext];

  if (formattedValue)
    {
      BOOL escapeHTMLValue=YES;
      BOOL convertHTMLValue=NO;
      BOOL convertHTMLEntitiesValue=NO;

      if (!WOStrictFlag && _convertHTML)
        {
          convertHTMLValue=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                                    standardEvaluateConditionInContextIMP,
                                                                    _convertHTML,aContext);
        };

      if (!WOStrictFlag)
        {
          if (!convertHTMLValue)
            {
              if (_convertHTMLEntities)
                {
                  convertHTMLEntitiesValue=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                                                    standardEvaluateConditionInContextIMP,
                                                                                    _convertHTMLEntities,aContext);
                };
              if (!convertHTMLEntitiesValue)
                {
                  if (_escapeHTML)
                    {
                      escapeHTMLValue=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                                               standardEvaluateConditionInContextIMP,
                                                                               _escapeHTML,aContext);
                    };
                };
            };
        }
      else if (_escapeHTML)
        {
          escapeHTMLValue=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                                   standardEvaluateConditionInContextIMP,
                                                                   _escapeHTML,aContext);
        };

      if (!WOStrictFlag && convertHTMLValue)
        GSWResponse_appendContentHTMLConvertString(aResponse,formattedValue);
      else if (!WOStrictFlag && convertHTMLEntitiesValue)
        GSWResponse_appendContentHTMLEntitiesConvertString(aResponse,formattedValue);
      else if (escapeHTMLValue)
        GSWResponse_appendContentHTMLString(aResponse,formattedValue);
      else
        GSWResponse_appendContentString(aResponse,formattedValue);
    };

  GSWStopElement(aContext);

  LOGObjectFnStopC("GSWString");
};

//--------------------------------------------------------------------
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)appendStringAtLeft:(id)unkwnon
              withMapping:(char*)mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(NSFormatter*)formatterForComponent:(GSWComponent*)component
                               value:(id)value
{
  //OK
  id formatValue = nil;
  NSFormatter* formatter = nil;
  LOGObjectFnStartC("GSWString");
  if (_dateFormat)
    {
      NSDebugMLLog(@"gswdync",@"DateFormat");
      formatValue=[_dateFormat valueInComponent:component];
      if (formatValue)
        formatter=[[[NSDateFormatter alloc]initWithDateFormat:formatValue
                                           allowNaturalLanguage:YES]autorelease];
    }
  else if (_numberFormat)
    {
      NSDebugMLLog(@"gswdync",@"NumberFormat");
      formatValue=[_numberFormat valueInComponent:component];
      if (formatValue)
        {
          //TODO
          /*		  _formatter=[[NSNumberFormatter new]autorelease];
                          [_formatter setFormat:_formatValue];
          */
        };
    }
  else
    {
      NSDebugMLLog(@"gswdync",@"Formatter");
      formatter=[_formatter valueInComponent:component];
    };
  NSDebugMLLog(@"gswdync",@"formatter=%@",formatter);
  LOGObjectFnStopC("GSWString");
  return formatter;
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
// return formatted value
-(NSString*)formattedValueInContext:(GSWContext*)aContext
{
  NSString* formattedValue=nil;
  GSWComponent* component=nil;
  id valueValue = nil;

  LOGObjectFnStartC("GSWString");

  component=GSWContext_component(aContext);

  NSDebugMLLog(@"gswdync",@"GSWString: value=%@",_value);

  valueValue = [_value valueInComponent:component];
  NSDebugMLLog(@"gswdync",@"GSWString: valueValue=%@",valueValue);

  if (valueValue)
    {
      NSFormatter* formatter=[self formatterForComponent:component
                                   value:valueValue];
      if (!formatter)
        {
          formattedValue=valueValue;
          // if we dont do this we get an exception on NSNumbers later. dave at turbocat.de
          if ([formattedValue isKindOfClass:[NSNumber class]])
            {
              formattedValue = [(id)formattedValue stringValue];
            } 
        }
      else
        {
          formattedValue=[formatter stringForObjectValue:valueValue];
          NSDebugMLLog(@"gswdync",@"valueValue=%@ formattedValue=%@",valueValue,formattedValue);
        };
    }

  LOGObjectFnStopC("GSWString");

  return formattedValue;
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
