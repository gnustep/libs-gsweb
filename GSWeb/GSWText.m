/** GSWText.m - <title>GSWeb: Class GSWText</title>

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

#include "GSWeb.h"

//====================================================================
@implementation GSWText

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  if ((self = [super initWithName:@"textarea"
		     associations:associations
		     template: nil]))
    {
      if (_value == nil
	  || ![_value isValueSettable])
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: 'value' attribute not present or is a constant",
		       __PRETTY_FUNCTION__];
	}
    }
  return self;
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_getClassName(self),
                   (void*)self];
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return @"textarea";
}

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  
  if (![self disabledInComponent: component]
      && [context _wasFormSubmitted])
    {
      NSString * nameCtx = [self nameInContext:context];
      if (nameCtx != nil)
	{
	  [_value setValue: [request stringFormValueForKey: nameCtx]
		  inComponent:component];
	}
    }
}

//--------------------------------------------------------------------
-(void) _appendValueAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*) context
{
  // nothing!
}

//--------------------------------------------------------------------
// Replace \r\n by \n
-(NSString*)_filterSoftReturnsFromString:(NSString*)string
{
  NSString* result=nil;
  
  if (string!=nil)
    {
      NSUInteger len = [string length];
      if (len==0)
	result=string;
      else
	{
	  NSMutableString * myTmpStr = [NSMutableString stringWithString: string];
  
	  while (YES)
	    {
	      NSRange range = [myTmpStr rangeOfString:@"\r\n"];
	      if (range.length>0)
		[myTmpStr replaceCharactersInRange: range withString:@"\n"];
	      else
		break;    
	    }
	  result=[NSString stringWithString: myTmpStr];
	}
    }
  return result;
};


//--------------------------------------------------------------------
-(void) appendChildrenToResponse:(GSWResponse*) response
                       inContext:(GSWContext*) context
{
  id value = [_value valueInComponent:GSWContext_component(context)];
  if (value != nil)
    GSWResponse_appendContentHTMLString(response, [self _filterSoftReturnsFromString:NSStringWithObject(value)]);
}


@end
