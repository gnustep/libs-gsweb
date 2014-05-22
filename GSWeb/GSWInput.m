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
         template:(GSWElement*)template
{
  if (([super initWithName:aName
	      associations:associations
	      template: template]))
    {
      GSWAssignAndRemoveAssociation(&_disabled,_associations,disabled__Key);
      GSWAssignAndRemoveAssociation(&_name,_associations,name__Key);
      GSWAssignAndRemoveAssociation(&_value,_associations,value__Key);
      GSWAssignAndRemoveAssociation(&_escapeHTML,_associations,escapeHTML__Key);
    }

  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_disabled);
  DESTROY(_name);
  DESTROY(_value);
  DESTROY(_escapeHTML);

  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*) type
{
  return nil;
}

//--------------------------------------------------------------------
- (NSString*) constantAttributesRepresentation
{
  if (_constantAttributesRepresentation == nil)
    {
      NSString * s = [self type];
      if (s != nil)
	{
	  IMP asIMP=NULL;
	  [super constantAttributesRepresentation];
	  NSMutableString * buffer = [NSMutableString stringWithCapacity:256];
	  if (_constantAttributesRepresentation != nil)
	    GSWeb_appendStringWithImpPtr(buffer,&asIMP,_constantAttributesRepresentation);
      
	  GSWeb_appendStringWithImpPtr(buffer,&asIMP,@" type=\"");
	  GSWeb_appendStringWithImpPtr(buffer,&asIMP,s);
	  GSWeb_appendStringWithImpPtr(buffer,&asIMP,@"\"");

	  ASSIGN(_constantAttributesRepresentation,buffer);
	}
    }
  return [super constantAttributesRepresentation];
}

//--------------------------------------------------------------------
- (BOOL) disabledInComponent:(GSWComponent*) component
{
  return (_disabled != nil 
	  && [_disabled boolValueInComponent: component]);
}

//--------------------------------------------------------------------
-(NSString*)nameInContext:(GSWContext*)context
{
  NSString * s = nil;

  if (_name != nil)
    {
      GSWComponent * component = GSWContext_component(context);
      s = NSStringWithObject([_name valueInComponent:component]);
    }
  if (s==nil)
    {
      s = [context elementID];
      if (s == nil)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Cannot evaluate 'name' attribute, and context element ID is nil.",
		       __PRETTY_FUNCTION__];
	}
    }
  return s;
}

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  
  if (![self disabledInComponent: component]
      && [context _wasFormSubmitted])
    {
      NSString* name = [self nameInContext:context];
      if (name != nil)
	{
	  NSString* value = [request stringFormValueForKey:name];
	  [_value setValue: value
		  inComponent:component];
	}
    }
}

//--------------------------------------------------------------------
- (BOOL) _shouldEscapeHTML:(GSWComponent *) component
{
  BOOL flag = YES;
  if (_escapeHTML != nil)
    flag = [_escapeHTML boolValueInComponent:component];
  return flag;
}

//--------------------------------------------------------------------
- (void) _appendNameAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*)context
{
  NSString* name = [self nameInContext:context];
  if (name != nil)
    {
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
								    name__Key,
								    name,
								    YES);
      
    }
}

//--------------------------------------------------------------------
- (void) _appendValueAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*)context
{
  if (_value != nil)
    {
      GSWComponent * component = GSWContext_component(context);
      NSString* value=NSStringWithObject([_value valueInComponent:component]);
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
								    value__Key,
								    value,
								    [self _shouldEscapeHTML:component]);
    }
}

//--------------------------------------------------------------------
-(void) appendAttributesToResponse:(GSWResponse *) response
                            inContext:(GSWContext*) context
{
  [super appendAttributesToResponse: response
                          inContext: context];

  if ([self disabledInComponent:GSWContext_component(context)])
    {
      GSWResponse_appendContentCharacter(response,' ');
      GSWResponse_appendContentAsciiString(response, disabled__Key);
    }
  [self _appendValueAttributeToResponse: response
	inContext: context];
  [self _appendNameAttributeToResponse: response
	inContext: context];
}


@end
