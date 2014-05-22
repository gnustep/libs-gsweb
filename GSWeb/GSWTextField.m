/** GSWTextField.m - <title>GSWeb: Class GSWTextField</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

//====================================================================
@implementation GSWTextField

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  if ((self = [super initWithName:@"input"
		     associations:associations
		     template: template]))
    {
      if (_value == nil
	  || ![_value isValueSettable])
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: 'value' attribute not present or is a constant",
		       __PRETTY_FUNCTION__];
	}
      GSWAssignAndRemoveAssociation(&_formatter,_associations,formatter__Key);
      GSWAssignAndRemoveAssociation(&_dateFormat,_associations,dateFormat__Key);
      GSWAssignAndRemoveAssociation(&_numberFormat,_associations,numberFormat__Key);
      GSWAssignAndRemoveAssociation(&_useDecimalNumber,_associations,useDecimalNumber__Key);

      if (_dateFormat != nil
	  && _numberFormat != nil)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Cannot have 'dateFormat' and 'numberFormat' attributes at the same time.",
		       __PRETTY_FUNCTION__];
	}
    }
  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_dateFormat);
  DESTROY(_numberFormat);
  DESTROY(_useDecimalNumber);
  DESTROY(_formatter);
  [super dealloc];
};

- (NSString*) type
{
  return @"text";
}


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
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  id         resultValue = nil;
  NSString * errorDscr = nil;

  GSWComponent * component = GSWContext_component(context);
  
  if (![self disabledInComponent: component]
      && [context _wasFormSubmitted])
    {
      NSString * nameCtx = [self nameInContext:context];
      if (nameCtx != nil)
	{
	  NSString* value = [request stringFormValueForKey: nameCtx];
	  if (value != nil)
	    {
	      NSFormatter * formatter = nil;
	      if ([value length] > 0)
		formatter = [self formatterForComponent:component];
        
	      if (formatter != nil)
		{
                  if ([formatter getObjectValue:&resultValue
				 forString:value
				 errorDescription:&errorDscr])
		    {
		      if (!resultValue)
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

                      exception=[NSException exceptionWithName:@"EOValidationException"
                                             reason:errorDscr
                                             userInfo:[NSDictionary 
                                                        dictionaryWithObjectsAndKeys:
                                                          (resultValue ? resultValue : (id)@"nil"), @"EOValidatedObjectUserInfoKey",
                                                        valueKeyPath,@"EOValidatedPropertyUserInfoKey",
                                                        nil,nil]];
                      [component validationFailedWithException:exception
                                 value:resultValue
                                 keyPath:valueKeyPath];
                    }                    
                    
		  if (value != nil
		      && _useDecimalNumber != nil
		      && [_useDecimalNumber boolValueInComponent:component])
		    {
		      // not tested! maybe we need a stringValue here first? dw
		      resultValue = [NSDecimalNumber decimalNumberWithString: value];
		    }
		} 
	      else
		{ // no formatter
		  resultValue=value;
		  if ([resultValue length] == 0)
		    resultValue = nil;
		}
	    }
	  [_value setValue:resultValue
		  inComponent:component];
	}
    }
}

//--------------------------------------------------------------------
-(void) _appendValueAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*) context
{
 GSWComponent * component = GSWContext_component(context);
 id value = [_value valueInComponent:component];

 if (value != nil)
   {
     NSFormatter* formatter = [self formatterForComponent:component];
     id formattedValue=nil;
     if (formatter != nil)
       {
	 NS_DURING
	   {
	     formattedValue=[formatter stringForObjectValue:value];
	   }
	 NS_HANDLER
	   {
	     formattedValue = nil;
	     NSLog(@"%s: value '%@' cannot be formatted.",
		   __PRETTY_FUNCTION__, value);
	   }
	 NS_ENDHANDLER;
       }
     if (formattedValue == nil)
       formattedValue = NSStringWithObject(value);

     GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, value__Key, formattedValue, YES);
   }
}

//--------------------------------------------------------------------
-(void) _appendCloseTagToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
}

@end
