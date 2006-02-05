/** GSWPasswordField.m - <title>GSWeb: Class GSWPasswordField</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
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
@implementation GSWPasswordField

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  self = [super initWithName:@"input" associations:associations template: template];
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

- (NSString*) type
{
  return @"password";
}

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  if ((![self disabledInComponent: component]) && ([context _wasFormSubmitted])) {
    NSString * nameCtx = [self nameInContext:context];
    if (nameCtx != nil) {
      NSString* value = [request stringFormValueForKey: nameCtx];
      [_value setValue: value
           inComponent:component];
    }
  }
}

-(void) _appendCloseTagToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
}


@end
