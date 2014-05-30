/** GSWGenericElement.m - <title>GSWeb: Class GSWGenericElement</title>

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

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWGenericElement

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWGenericElement class])
    {
      standardClass=[GSWGenericElement class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

//-----------------------------------------------------------------------------------
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement
{
  if ((self=[super initWithName: name
		   associations: associations
		   template: templateElement]))
    {
      GSWAssignAndRemoveAssociation(&_elementName,_associations,elementName__Key);
      GSWAssignAndRemoveAssociation(&_omitTags,_associations,omitTags__Key);
      GSWAssignAndRemoveAssociation(&_formValue,_associations,formValue__Key);
      GSWAssignAndRemoveAssociation(&_formValues,_associations,formValues__Key);
      GSWAssignAndRemoveAssociation(&_invokeAction,_associations,invokeAction__Key);
      GSWAssignAndRemoveAssociation(&_elementID,_associations,elementID__Key);
      GSWAssignAndRemoveAssociation(&_otherTagString,_associations,otherTagString__Key);
      GSWAssignAndRemoveAssociation(&_name,_associations,name__Key);

      if(_formValue || _formValues)
	{
	  _hasFormValues = YES;
	  if (name == nil)
	    {
	      [NSException raise: NSInvalidArgumentException
			   format: @"%@(%@):Attribute 'name' is manditory "
			           @"when formValue(s) are supplied. (%@)",
			   [self description],
			   NSStringFromSelector(_cmd), 
			   associations];
	    }
	}
    }

  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  RELEASE (_elementName);
  RELEASE (_name);
  RELEASE (_omitTags);
  RELEASE (_formValue);
  RELEASE (_formValues);
  RELEASE (_invokeAction);
  RELEASE (_elementID);
  RELEASE (_otherTagString);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"%@(%p)\n(%@)", 
		   NSStringFromClass([self class]), self, _associations];
};

//--------------------------------------------------------------------
-(NSString*)_elementNameInContext:(GSWContext*)aContext
{
  NSString* elementName = nil;
  if (_elementName)
    {
      BOOL omit = NO;      
      if (_omitTags)
	{
	  omit = GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                          standardEvaluateConditionInContextIMP,
                                                          _omitTags,aContext);
	}
      
      if (omit == NO)
	{
	  elementName=[_elementName valueInComponent:GSWContext_component(aContext)];
	}
    }

  return elementName;
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)aContext
{
  GSWElement *element = nil;
  GSWComponent *component = GSWContext_component(aContext);

  if (_invokeAction != nil
      && [_invokeAction isImplementedForComponent:component])
    {
      NSString *elementID = GSWContext_elementID(aContext);
      NSString *senderID = GSWContext_senderID(aContext);

      NSDebugMLog(@"elementID=%@ senderID=%@",
                  elementID,senderID);

      if ([elementID isEqualToString: senderID])
	{
          if (_elementID != nil)
	    {
              [_elementID setValue: elementID
                          inComponent: component];
	    }

          element = [_invokeAction valueInComponent:component];
          if (element==nil)
            element = [aContext page];
        }
      else if (_name)
        {
          NSString* name = NSStringWithObject([_name valueInComponent:component]);
          id formValue = [request stringFormValueForKey:name];

          if (formValue)
            {
              if(_elementID)
		{
		  [_elementID setValue: elementID
			      inComponent:component];
		}

              element = [_invokeAction valueInComponent: component];
              if (element==nil)
                element = [aContext page];
            };
        };
    }

  return element;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext
{
  if (_hasFormValues)
    {
      GSWComponent *component = GSWContext_component(aContext);
      NSString *elementID = GSWContext_elementID(aContext);
      NSString* name = NSStringWithObject([_name valueInComponent: component]);

      if (_elementID != nil)
	{
	  [_elementID setValue: elementID
		      inComponent: component];
	}
      if (_formValue != nil)
	{ 
	  [_formValue setValue: [request stringFormValueForKey: name]
		      inComponent: component];
	}
      if (_formValues != nil)
	{
	  [_formValue setValue: [request formValuesForKey: name]
		      inComponent: component];
	}
    }

};

//--------------------------------------------------------------------
-(void)appendAttributesToResponse:(GSWResponse*)aResponse
			inContext:(GSWContext*)aContext
{
  GSWComponent *component = GSWContext_component(aContext);
  if (_name != nil)
    {
      NSString* name = NSStringWithObject([_name valueInComponent:component]);
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(aResponse,@"name",name,YES);
    }

  if(_otherTagString != nil)
    {
      NSString* otherTagString = NSStringWithObject([_otherTagString valueInComponent:component]);
      if ([otherTagString length]>0)
	{
	  GSWResponse_appendContentCharacter(aResponse,' ');
	  GSWResponse_appendContentString(aResponse,otherTagString);
	}
    }

  [self appendConstantAttributesToResponse:aResponse
	inContext:aContext];
  [self appendNonURLAttributesToResponse:aResponse
	inContext:aContext];
  [self appendURLAttributesToResponse:aResponse
	inContext:aContext];
}

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  if (aContext != nil
      && aResponse != nil)
    {
      if (_elementID != nil)
        {
	  GSWComponent *component = GSWContext_component(aContext);
	  [_elementID setValue:[aContext elementID]
		      inComponent:component];
        }
      ASSIGN(_dynElementName,([self _elementNameInContext:aContext]));
      if (_dynElementName != nil)
        {
	  GSWResponse_appendContentCharacter(aResponse,'<');
	  GSWResponse_appendContentAsciiString(aResponse,_dynElementName);
	  [self appendAttributesToResponse:aResponse
		inContext:aContext];
	  GSWResponse_appendContentCharacter(aResponse,'>');
	}
    }
};

@end
