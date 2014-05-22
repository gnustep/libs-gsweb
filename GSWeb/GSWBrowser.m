/** GSWBrowser.m - <title>GSWeb: Class GSWBrowser</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de>
   Date: 	Oct 2006
   
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
#include "GSWPrivate.h"

/**
Bindings

	list		Array of objects that the dynamic element iterate through.

        index		On each iteration the element put the current index in this binding

        item		On each iteration the element take the item at the current index and put it in this binding

        displayString  	String to display for each check box.

        value		Value for each OPTION tag 

        selections	Array of selected objects (used to pre-select items and modified to reflect user choices)
        			It contains  objects from list, not value binding evaluated ones !

        selectedValues	Array of pre selected values (not objects !)

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the check box appear inactivated.

        escapeHTML	If evaluated to yes, escape displayString

        size		show 'size' iems at one time. Default=5. Must be > 1

        multiple	multiple selection allowed
**/

//====================================================================
@implementation GSWBrowser

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{         
  if ((self = [super initWithName:@"select"
		     associations:associations
		     template: template]))
    {
      _loggedSlow = NO;

      GSWAssignAndRemoveAssociation(&_list,_associations,list__Key);
      GSWAssignAndRemoveAssociation(&_item,_associations,item__Key);
      GSWAssignAndRemoveAssociation(&_displayString,_associations,displayString__Key);
      GSWAssignAndRemoveAssociation(&_selections,_associations,selections__Key);
      GSWAssignAndRemoveAssociation(&_multiple,_associations,multiple__Key);
      GSWAssignAndRemoveAssociation(&_size,_associations,size__Key);
      GSWAssignAndRemoveAssociation(&_selectedValues,_associations,selectedValues__Key);
      GSWAssignAndRemoveAssociation(&_escapeHTML,_associations,escapeHTML__Key);

      if (_list == nil || ((_value != nil || _displayString != nil) && 
        ((_item == nil || ![_item isValueSettable]))) || 
	  (_selections != nil && ![_selections isValueSettable]))
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: 'list' must be present. 'item' must not be a constant if 'value' is present.  Cannot have 'displayString' or 'value' without 'item'.  'selection' must not be a constant if present.",
		       __PRETTY_FUNCTION__];  
	}
      if (_selections != nil
	  && _selectedValues != nil)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Cannot have both selections and selectedValues.",
		       __PRETTY_FUNCTION__];  
	}
    }
  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_displayString);
  DESTROY(_selections);
  DESTROY(_selectedValues);
  DESTROY(_size);
  DESTROY(_multiple);

  [super dealloc];
};


//--------------------------------------------------------------------
-(id) description
{
  return [NSString stringWithFormat:@"<%s %p list:%@ item:%@ displayString:%@ selections:%@ selectedValues:%@ multiple:%@ size:%@ escapeHTML:%@>",
                   object_getClassName(self),
                   (void*)self, 
                   _list, _item, _displayString, _selections, _selectedValues, _multiple,
                   _size, _escapeHTML];
};



//--------------------------------------------------------------------
/*
 On WO it looks like that when value is not bound:

 <SELECT name="4.2.7" size=5 multiple>
 <OPTION value="0">blau</OPTION>
 <OPTION value="1">braun</OPTION>
 <OPTION selected value="2">gruen</OPTION>
 <OPTION value="3">marineblau</OPTION>
 <OPTION value="4">schwarz</OPTION>
 <OPTION value="5">silber</OPTION>
 <OPTION value="6">weiss</OPTION></SELECT>

 */
-(void) appendChildrenToResponse:(GSWResponse *) response
                       inContext:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);
  BOOL doEscape = YES;
  NSArray* list = nil;
  NSUInteger listCount = 0;
  NSArray* selections = nil;
  int i = 0;
  IMP oaiIMP=NULL;

  if (_escapeHTML != nil) 
    doEscape = [_escapeHTML boolValueInComponent:component];

  list = [_list valueInComponent:component];
  if (list != nil)
    {
      if ([list isKindOfClass:[NSArray class]])
	{
	  listCount = [list count];
	}
      else
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
		       __PRETTY_FUNCTION__, [list class]];      
	}
    }

  if (_selections != nil)
    selections = [_selections valueInComponent:component];
  else if (_selectedValues != nil)
    selections = [_selectedValues valueInComponent:component];

  for (i = 0; i < listCount; i++)
    {
      NSString* displayString=nil;
      id item = nil;
      BOOL isSelected=NO;
      NSString* valueString = nil;
      id value = nil;

      if (list != nil)
	item = GSWeb_objectAtIndexWithImpPtr(list,&oaiIMP,i);
      
      if (_displayString != nil
	  || _value != nil)
	{
	  [_item setValue:item
		 inComponent:component];

	  if (_displayString != nil)
	    {
	      displayString = [_displayString valueInComponent:component];
	      if (displayString!=nil)
		{
		  if (_value != nil)
		    {
		      value = [_value valueInComponent:component];
		      valueString = NSStringWithObject(value);
		    }
		  else
		    {
		      value = displayString;
		      valueString = NSStringWithObject(displayString);
		    }
		  displayString=NSStringWithObject(displayString);
		}
	    }
	  else
	    {
	      value = [_value valueInComponent:component];
	      if (value != nil)
		{
		  valueString=NSStringWithObject(value);
		  displayString = valueString;
		}
	    }
	}
      else
	{
	  value = item;
	  valueString = NSStringWithObject(item);
	  displayString = valueString;
	}

      GSWResponse_appendContentAsciiString(response,@"\n<option");
      if (_selections != nil)
	{
	  if (item
	      && selections)
	    isSelected = [selections containsObject:item];
	}
      else
	{
	  if (_value != nil)
	    {
	      if (item
		  && selections)
		isSelected = [selections containsObject:value];
	    }
	  else
	    isSelected = [selections containsObject:GSWIntToNSString(i)];
	}
      if (isSelected)
	GSWResponse_appendContentAsciiString(response,@" selected");

      if (_value != nil)
	GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, value__Key, valueString, YES);
      else
	GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, value__Key, GSWIntToNSString(i), NO);
    
      GSWResponse_appendContentCharacter(response,'>');
      if (doEscape)
	GSWResponse_appendContentHTMLConvertString(response, displayString);
      else
	GSWResponse_appendContentString(response, displayString);
    
      GSWResponse_appendContentAsciiString(response,@"</option>");
    }
}


//--------------------------------------------------------------------
-(void) _appendValueAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*) context
{
  //Do nothing
}

//--------------------------------------------------------------------
-(void) appendAttributesToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
  id             sizeValue = nil;
  int            sizeInt   = 5;
  GSWComponent * component = GSWContext_component(context);

  [super appendAttributesToResponse:response 
                          inContext:context];

  if (_size != nil)
    {
      sizeValue = [_size valueInComponent:component];
      sizeInt   = [sizeValue intValue];
      sizeValue = GSWIntToNSString(sizeInt);
    }

  if (_size == nil
      || sizeValue == nil
      || sizeInt < 2)
    {
      sizeValue = GSWIntToNSString(5);
    }

  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, size__Key, sizeValue, NO);

  if (_multiple != nil
      && [_multiple boolValueInComponent:component])
    {
      GSWResponse_appendContentAsciiString(response,@" multiple");
    }
}

//--------------------------------------------------------------------
- (void)_slowTakeValuesFromRequest:(GSWRequest*) request
                         inContext:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);

  if (_selections != nil
      && ![self disabledInComponent:component]
      && [context _wasFormSubmitted])
    {      
      NSString       * ctxName    = [self nameInContext:context];
      NSArray        * formValues = [request formValuesForKey: ctxName];
      NSArray        * selections = nil;
      
      if (formValues != nil)
	{
	  NSUInteger formValuesCount = [formValues count];

	  if (formValuesCount>0)
	    {
	      if (_list != nil)
		{
		  NSArray* list = [_list valueInComponent:component];
		  if ([list isKindOfClass:[NSArray class]] == NO)
		    {
		      [NSException raise:NSInvalidArgumentException
				   format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
				   __PRETTY_FUNCTION__, [list class]];  
		    }
		  else
		    {
		      NSUInteger listCount = [list count];
		      int i=0;
		      IMP oaiIMP=NULL;
		      BOOL multiple = NO;
		      if (_multiple != nil)
			multiple = [_multiple boolValueInComponent:component];
       
		      for (i = 0; i < listCount; i++)
			{
			  id value = nil;
			  id item = GSWeb_objectAtIndexWithImpPtr(list,&oaiIMP,i);
			  
			  [_item setValue:item
				 inComponent: component];
			  
			  value = [_value valueInComponent:component];
			  if (value != nil) 
			    {
			      if ([formValues containsObject:NSStringWithObject(value)])
				{
				  if (selections==nil)
				    selections=[NSMutableArray array];
				  [(NSMutableArray*)selections addObject:item];
				  if (!multiple)
				    break;
				}
			    }
			  else
			    {
			      NSLog(@"%s: 'value' evaluated to null in component %@, %@",
				    __PRETTY_FUNCTION__, component, self);
			    }
			}
		    }
		}
	    }
	}
      if (selections==nil)
	selections = [NSArray array];
      [_selections setValue:selections
		   inComponent: component];
    }
}


//--------------------------------------------------------------------
- (void) _fastTakeValuesFromRequest:(GSWRequest*) request
                          inContext:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);

  if (_selections != nil
      && ![self disabledInComponent:component]
      && [context _wasFormSubmitted])
    {
      NSString       * ctxName         = [self nameInContext:context];
      NSArray        * formValues      = [request formValuesForKey: ctxName];
      NSArray        * selections      = nil;
      
      if (formValues != nil)
	{
	  int formValuesCount = [formValues count];
	  if (formValuesCount>0)
	    {
	      NSArray* list = nil;

	      if (_list != nil)
		{
		  list = [_list valueInComponent:component];
		  if ([list isKindOfClass:[NSArray class]] == NO)
		    {
		      [NSException raise:NSInvalidArgumentException
				   format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
				   __PRETTY_FUNCTION__, [list class]];  
		    }
		  else
		    {
		      IMP formValues_oaiIMP=NULL;
		      IMP list_oaiIMP=NULL;
		      int i=0;
		      BOOL multiple = NO;
		      if (_multiple != nil)
			multiple = [_multiple boolValueInComponent:component];

		      for (i = 0; i < formValuesCount; i++)
			{
			  NSString* formValue = GSWeb_objectAtIndexWithImpPtr(formValues,&formValues_oaiIMP,i);
			  int intFormValue = [formValue intValue];
			  if (list != nil)
			    {
			      id item = GSWeb_objectAtIndexWithImpPtr(list,&list_oaiIMP,intFormValue);
			      if (selections==nil)
				selections=[NSMutableArray array];
			      [(NSMutableArray*)selections addObject:item];
			    } 
			  if (!multiple)
			    break;
			}
		    }
		}
	    }
	}

      if (selections==nil)
	selections = [NSArray array];

      [_selections setValue:selections
		   inComponent: component];
    }
}

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  if (_value != nil)
    {
      if (!_loggedSlow)
	{
	  NSLog(@"%s Warning: Avoid using the 'value' binding as it is much slower than omitting it, and it is just cosmetic.",
		__PRETTY_FUNCTION__);
	  _loggedSlow = YES;
	}
      [self _slowTakeValuesFromRequest:request
	    inContext:context];
    } 
  else
    {
      [self _fastTakeValuesFromRequest:request 
	    inContext:context];
    }
}


@end
