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

RCS_ID("$Id$")

#include "GSWeb.h"

//====================================================================
@implementation GSWText

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  self = [super initWithName:@"textarea" associations:associations template: nil];
  if (!self) {
    return nil;
  }

  if ((_value == nil) || (![_value isValueSettable])) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: 'value' attribute not present or is a constant",
                            __PRETTY_FUNCTION__];
  }

  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  [super dealloc];
};

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
  return @"textarea";
};

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  id         resultValue = nil;

  GSWComponent * component = GSWContext_component(context);
  
  if ((![self disabledInComponent: component]) && ([context _wasFormSubmitted])) {
    NSString * nameCtx = [self nameInContext:context];
    if (nameCtx != nil) {
      [_value setValue: [request stringFormValueForKey: nameCtx]
           inComponent:component];
    }
  }
}

-(void) _appendValueAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*) context
{
// nothing!
}

// Replace \r\n by \n
-(NSString*)_filterSoftReturnsFromString:(NSString*)string
{
  NSRange range;
  NSMutableString * myTmpStr = nil;
  unsigned len = 0;
  
  if (!string) {
    return nil;
  }
  len = [string length];
  if (len<1) {
    return string;
  }
 
  myTmpStr = [NSMutableString stringWithCapacity: len];
  [myTmpStr setString: string];
  
  while (YES) {
    range = [myTmpStr rangeOfString:@"\r\n"];
    if (range.length>0) {
      [myTmpStr replaceCharactersInRange: range withString:@"\n"];
    } else {
      break;
    }
  }
  return [NSString stringWithString: myTmpStr];
};


-(void) appendChildrenToResponse:(GSWResponse*) response
                       inContext:(GSWContext*) context
{
  id valueValue = [_value valueInComponent:GSWContext_component(context)];
  if (valueValue != nil) {
    GSWResponse_appendContentHTMLString(response, [self _filterSoftReturnsFromString:valueValue]);
  }
}


@end
