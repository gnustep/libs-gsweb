/** GSWInput.m - <title>GSWeb: Class GSWInput</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
   
   $Revision$
   $Date$
   $Id$

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

#include "GSWeb.h"
#include "GSWPrivate.h"

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWInput

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWInput class])
    {
      standardClass=[GSWInput class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSMutableArray*) elements
{
  self = [super initWithName:aName associations:associations contentElements: elements];
  if (!self) {
    return nil;
  }

  ASSIGN(_disabled, [_associations objectForKey: disabled__Key]);
  if (_disabled != nil) {
    [_associations removeObjectForKey: disabled__Key];
  }
  ASSIGN(_name, [_associations objectForKey: name__Key]);
  if (_name != nil) {
    [_associations removeObjectForKey: name__Key];
  }
  ASSIGN(_value, [_associations objectForKey: value__Key]);
  if (_value != nil) {
    [_associations removeObjectForKey: value__Key];
  }
  ASSIGN(_escapeHTML, [_associations objectForKey: escapeHTML__Key]);
  if (_escapeHTML != nil) {
    [_associations removeObjectForKey: escapeHTML__Key];
  }

  return self;
}

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  self = [super initWithName:aName associations:associations template: template];
  if (!self) {
    return nil;
  }

  ASSIGN(_disabled, [_associations objectForKey: disabled__Key]);
  if (_disabled != nil) {
    [_associations removeObjectForKey: disabled__Key];
  }
  ASSIGN(_name, [_associations objectForKey: name__Key]);
  if (_name != nil) {
    [_associations removeObjectForKey: name__Key];
  }
  ASSIGN(_value, [_associations objectForKey: value__Key]);
  if (_value != nil) {
    [_associations removeObjectForKey: value__Key];
  }
  ASSIGN(_escapeHTML, [_associations objectForKey: escapeHTML__Key]);
  if (_escapeHTML != nil) {
    [_associations removeObjectForKey: escapeHTML__Key];
  }

  return self;
}

-(NSString*) type
{
  return nil;
}

- (NSString*) constantAttributesRepresentation
{
  if (_constantAttributesRepresentation == nil) {
    NSString * s = [self type];
    if (s != nil) {
      [super constantAttributesRepresentation];
      NSMutableString * buffer = [NSMutableString stringWithCapacity:256];
      if (_constantAttributesRepresentation != nil) {
        [buffer appendString:_constantAttributesRepresentation];
      }
      [buffer appendString:@" "];
      [buffer appendString:@"type"];
      [buffer appendString:@"=\""];
      [buffer appendString:s];
      [buffer appendString:@"\""];
      ASSIGN(_constantAttributesRepresentation,buffer);
    }
  }
  return [super constantAttributesRepresentation];
}

- (BOOL) disabledInComponent:(GSWComponent*) component
{
  return ((_disabled != nil) && ([_disabled boolValueInComponent: component]));
}

-(NSString*)nameInContext:(GSWContext*)context
{
  NSString * s = nil;

  if (_name != nil) {
    GSWComponent * component = GSWContext_component(context);

    id obj = [_name valueInComponent:component];
    if (obj != nil) {
      return obj; // stringValue? 
    }
  }
  s = [context elementID];
  if (s != nil) {
    return s;
  } else {
    [NSException raise:NSInvalidArgumentException
          format:@"%s: Cannot evaluate 'name' attribute, and context element ID is nil.",
                               __PRETTY_FUNCTION__];
  }
}

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  id obj = nil;
  GSWComponent * component = GSWContext_component(context);
  
  if ((![self disabledInComponent: component]) && ([context _wasFormSubmitted])) {
    NSString * s1 = [self nameInContext:context];
    if (s1 != nil) {
      NSString * s = [request stringFormValueForKey:s1];
              [_value setValue: s
                      inComponent:component];
    }
  }
}

- (BOOL) _shouldEscapeHTML:(GSWComponent *) component
{
  BOOL flag = YES;
  if (_escapeHTML != nil) {
    flag = [_escapeHTML boolValueInComponent:component];
  }
  return flag;
}

- (void) _appendNameAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*)context
{
  GSWComponent * component = nil;
  NSString  * s = [self nameInContext:context];
  if (s != nil) {
    component = GSWContext_component(context);
    [response _appendTagAttribute: name__Key
                            value: s
       escapingHTMLAttributeValue: [self _shouldEscapeHTML:component]];
    
  }
}

- (void) _appendValueAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  if (_value != nil)
  {
    id obj = [_value valueInComponent:component];
    id obj1 = nil;
    if (obj != nil) {
      NSString * s = obj; // stringValue?? 
      [response _appendTagAttribute: value__Key
                              value: s
         escapingHTMLAttributeValue: [self _shouldEscapeHTML:component]];
    }
  }
}

-(void) appendAttributesToResponse:(GSWResponse *) response
                            inContext:(GSWContext*) context
{
  [super appendAttributesToResponse: response
                          inContext: context];

  if ([self disabledInComponent:GSWContext_component(context)]) {
    GSWResponse_appendContentCharacter(response,' ');
    GSWResponse_appendContentAsciiString(response, disabled__Key);
  }
  [self _appendValueAttributeToResponse: response
                              inContext: context];
  [self _appendNameAttributeToResponse: response
                             inContext: context];
}


-(void)dealloc
{
  DESTROY(_disabled);
  DESTROY(_name);
  DESTROY(_value);
  DESTROY(_escapeHTML);

  [super dealloc];
}

@end
