/** GSWGenericElement.m - <title>GSWeb: Class GSWGenericElement</title>

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
@implementation GSWGenericElement

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement
{
  if ((self=[super initWithName: name
		   associations: associations
		   template: templateElement]))
    {
      NSMutableDictionary *dict;

      ASSIGN(_name, [associations objectForKey: name__Key]);
      ASSIGN(_omitTags, [associations objectForKey: omitTags__Key]);
      ASSIGN(_formValue, [associations objectForKey: formValue__Key]);
      ASSIGN(_formValues, [associations objectForKey: formValues__Key]);
      ASSIGN(_invokeAction, [associations objectForKey: invokeAction__Key]);
      ASSIGN(_elementID, [associations objectForKey: elementID__Key]);
      ASSIGN(_otherTagString, [associations objectForKey: otherTagString__Key]);

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

      dict = AUTORELEASE([associations mutableCopy]);

      [dict removeObjectForKey: name__Key];
      [dict removeObjectForKey: omitTags__Key];
      [dict removeObjectForKey: formValue__Key];
      [dict removeObjectForKey: formValues__Key];
      [dict removeObjectForKey: invokeAction__Key];
      [dict removeObjectForKey: elementID__Key];
      [dict removeObjectForKey: otherTagString__Key];

      ASSIGNCOPY(_otherAssociations, dict);
    }

  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  RELEASE (_name);
  RELEASE (_omitTags);
  RELEASE (_formValue);
  RELEASE (_formValues);
  RELEASE (_invokeAction);
  RELEASE (_elementID);
  RELEASE (_otherTagString);
  RELEASE (_otherAssociations);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"%@(%p)\n(%@)", 
		   NSStringFromClass([self class]), self, _otherAssociations];
};

//--------------------------------------------------------------------

-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  [self _elementNameAppendToResponse: response inContext: context];
};

//--------------------------------------------------------------------

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
{
  GSWElement *element;
  GSWComponent *comp;

  element = nil;
  comp = [context component];
  if (_invokeAction != nil
      && [_invokeAction isImplementedForComponent: comp])
    {
      NSString *elementID;
      NSString *senderID;

      elementID = [context elementID];
      senderID = [context senderID];

      if ([elementID isEqualToString: senderID])
	{
	  id nameValue;
	  id formValue;

	  /* This implicitly also tests _hasFormValues 
	     as then we must have a _name,
	     but since we need the _name anyway,
	     we can skip the extra test. */
	  if (_name == nil)
	    {
	      return element;
	    }

	  nameValue = [_name valueInComponent: comp];
	  formValue = [request formValueForKey: nameValue];

	  if (formValue == nil)
	    {
	      return element;
	    }
	}

      if (_elementID != nil)
	{
	  [_elementID setValue: [elementID description]
		      inComponent: comp];
	}
      element = [_invokeAction valueInComponent: comp];
      if (element != nil)
	{
	  return element;
	}
      element = [context page];
    }

  return element;
};

//--------------------------------------------------------------------

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  if (_hasFormValues)
    {
      GSWComponent *comp;
      NSString *elementID;
      id nameValue;

      comp = [context component];
      elementID = [context elementID];
      nameValue = [_name valueInComponent: comp];
      if (_elementID != nil)
	{
	  [_elementID setValue: [elementID description]
		      inComponent: comp];
	}
      if (_formValue != nil)
	{ 
	  [_formValue setValue: [request formValueForKey: nameValue]
		      inComponent: comp];
	}
      if (_formValues != nil)
	{
	  [_formValue setValue: [request formValuesForKey: nameValue]
		      inComponent: comp];
	}
    }
};

//-------------------------------------------------------------------- 

-(id)_elementNameAppendToResponse:(GSWResponse*)response
			inContext:(GSWContext*)context
{
  NSString *elementName;

  if (_elementID != nil)
    {
      [_elementID setValue: [[context elementID] description]
		  inComponent: [context component]];
    }

  elementName = [self _elementNameInContext: context];

  if (elementName != nil)
    {
      [self _appendTagWithName: elementName 
	    toResponse: response 
	    inContext: context];
    }

  return elementName;
};

//--------------------------------------------------------------------
-(void)_appendTagWithName:(NSString*)name
               toResponse:(GSWResponse*)response
                inContext:(GSWContext*)context
{
  GSWComponent *comp;

  comp = [context component];
  [response appendContentCharacter:'<'];
  [response appendContentString: name];
  if (_name != nil)
    {
      NSString *compName = [_name valueInComponent: comp];
      [response _appendContentAsciiString: @" name=\""];
      [response appendContentString: compName];
      [response appendContentCharacter: '"'];
    }
  if (_otherAssociations != nil)
    {
      [self _appendOtherAttributesToResponse: response 
	    inContext: context];
    }
  if (_otherTagString != nil)
    {
      NSString *oTagComp = [_otherTagString valueInComponent: comp];
      if (oTagComp != nil && [oTagComp length])
	{
	  [response appendContentCharacter: ' '];
	  [response appendContentString: oTagComp];
	}
    }
  [response appendContentCharacter: '>'];

};

//--------------------------------------------------------------------
-(void)_appendOtherAttributesToResponse:(GSWResponse*)response
                              inContext:(GSWContext*)context
{
  GSWComponent *comp;
  NSEnumerator *keyEnum;
  NSString *key;

  comp = [context component];
  keyEnum = [_otherAssociations keyEnumerator];

  while ((key = [keyEnum nextObject]))
    {
      GSWAssociation *assoc;
      id val;
      NSString *desc;

      assoc = [_otherAssociations objectForKey: key];
      val = [assoc valueInComponent: comp];
      if (val != nil)
	{
	  desc = [val description];
	  [response _appendTagAttribute: key 
		    value: desc
		    escapingHTMLAttributeValue:NO];
	}
    }
  
};

//--------------------------------------------------------------------
-(NSString*)_elementNameInContext:(GSWContext*)context
{
   if (_elementName)
    {
      BOOL omit = NO;

      if (_omitTags)
	{
	  omit = [self evaluateCondition: _omitTags inContext: context];
	}

      if (omit == NO)
	{
	  return [_elementName valueInComponent: [context component]];
	}
    }
  return nil;
};

//--------------------------------------------------------------------
@end
