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
     associations:(NSMutableDictionary*)associations
         template:(GSWElement*)template
{
  self = [super initWithName:nil associations:nil template:nil];
  if (!self) {
    return nil;
  }
  ASSIGN(_value, [associations objectForKey: value__Key]);
  if (_value == nil) {
      [NSException raise:NSInvalidArgumentException
                  format:@"%s: no 'value' attribute specified.",
                              __PRETTY_FUNCTION__];
   }
  ASSIGN(_valueWhenEmpty, [associations objectForKey: valueWhenEmpty__Key]);
  ASSIGN(_escapeHTML, [associations objectForKey: escapeHTML__Key]);
  ASSIGN(_dateFormat, [associations objectForKey: dateFormat__Key]);
  ASSIGN(_numberFormat, [associations objectForKey: numberFormat__Key]);
  ASSIGN(_formatter, [associations objectForKey: formatter__Key]);
  
  if ((_dateFormat != nil) || (_numberFormat != nil) || (_formatter != nil)) {
    _shouldFormat = YES;
  } else {
    _shouldFormat = NO;
  }
  if ((_dateFormat != nil) && (_numberFormat != nil) || (_formatter != nil) && 
      (_dateFormat != nil) || (_formatter != nil) && (_numberFormat != nil)) {
      
     [NSException raise:NSInvalidArgumentException
             format:@"%s: Cannot have 'dateFormat' and 'numberFormat' attributes at the same time.",
                                  __PRETTY_FUNCTION__];
  }

  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_dateFormat);
  DESTROY(_numberFormat);
  DESTROY(_formatter);
  DESTROY(_value);
  DESTROY(_escapeHTML); 
  DESTROY(_valueWhenEmpty);
  
  [super dealloc];
}

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

// TODO: put that into a superclass, bulid a cache?

-(NSFormatter*)formatterForComponent:(GSWComponent*)component
{
  //OK
  id formatValue = nil;
  id formatter = nil;
  if (_dateFormat)
    {
      formatValue=[_dateFormat valueInComponent:component];
      if (formatValue)
        formatter=[[[NSDateFormatter alloc]initWithDateFormat:formatValue
                                           allowNaturalLanguage:YES]autorelease];
    }
  else if (_numberFormat)
    {
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
      formatter=[_formatter valueInComponent:component];
    };
  return formatter;
};


//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  GSWComponent* component = GSWContext_component(context);
  NSString* formattedValue=nil;
  id valueValue = nil;
  NSString * errorDscr = nil;
  BOOL flag = YES;
  
  if (_value != nil) {
   valueValue = [_value valueInComponent:component];
   if (_shouldFormat) {
     NSFormatter* formatter=[self formatterForComponent:component];
     if (formatter != nil) {
       NS_DURING
        formattedValue=[formatter stringForObjectValue:valueValue];
       NS_HANDLER
         formattedValue = nil;
         NSLog(@"%s: value '%@' of class '%@' cannot be formatted.",
                              __PRETTY_FUNCTION__, valueValue, [valueValue class]);
       NS_ENDHANDLER
      }
    }
    if (formattedValue == nil) {
        formattedValue = valueValue;
    }

  } else {
    NSLog(@"%s:WARNING value binding is nil!", __PRETTY_FUNCTION__);
    return;
  }
  
  if ((formattedValue != nil) && ([formattedValue isKindOfClass:[NSNumber class]])) {
   // if we dont do this we get an exception on NSNumbers later. 
   formattedValue = [(id) formattedValue stringValue];
  } else {
   formattedValue = [(id) formattedValue description];
  }
  if ((formattedValue == nil || [formattedValue length] == 0) && _valueWhenEmpty != nil) {
    formattedValue = [_valueWhenEmpty valueInComponent:component];
    GSWResponse_appendContentString(response, formattedValue);
  } else {
    if (formattedValue != nil) {
      if (_escapeHTML != nil) {
        flag = [_escapeHTML boolValueInComponent:component];
      }
      if (flag) {
        GSWResponse_appendContentHTMLConvertString(response, formattedValue);
      } else {
        GSWResponse_appendContentString(response, formattedValue);
      }
    }
  }
};

@end
