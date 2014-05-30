/** GSWPopUpButton.m - <title>GSWeb: Class GSWPopUpButton</title>

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
#include "GSWPrivate.h"
#include <GNUstepBase/NSString+GNUstepBase.h>

/**
Bindings

	list		Array of objects that the dynamic element iterate through.

        index		On each iteration the element put the current index in this binding

        item		On each iteration the element take the item at the current index and put it in this binding

        displayString  	String to display for each item.

        value		Value for each OPTION tag 

        selection	Selected object (used to pre-select item and modified to reflect user choice)
        			It contains  object from list, not value binding evaluated one !

        selectedValue	Pre selected value (not object !)

        selectionValue	Selected value (used to pre-select item and modified to reflect user choice)
        			It contains  object from list, not value binding evaluated one !

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the check box appear inactivated.

        escapeHTML	If evaluated to yes, escape displayString

        noSelectionString	If binded, displayed as the first item. If selected, considered as 
        				an empty selection (selection is set to nil, selectionValue too)

**/

//====================================================================
@implementation GSWPopUpButton

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
      GSWAssignAndRemoveAssociation(&_string,_associations,displayString__Key);
      GSWAssignAndRemoveAssociation(&_selection,_associations,selection__Key);
      GSWAssignAndRemoveAssociation(&_noSelectionString,_associations,noSelectionString__Key);
      GSWAssignAndRemoveAssociation(&_selectedValue,_associations,selectedValue__Key);

      if (_list == nil
	  || (_value != nil && (_item == nil && [_item isValueSettable] == NO)) 
	  || ((_string != nil || _item != nil) && _item == nil)
	  || (_selection != nil && [_selection isValueSettable] == NO))
	{	  
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: 'list' must be present. 'item' must not be a constant if 'value' is present. Cannot have 'displayString' or 'value' without 'item'. 'selection' must not be a constant if present.",
		       __PRETTY_FUNCTION__];  
	}
      if (_selection != nil
	  && _selectedValue != nil)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Cannot have both selections and selectedValues.",
		       __PRETTY_FUNCTION__];  
	}
    }
  return self;
}
 
//--------------------------------------------------------------------
-(void) dealloc
{
  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_string);
  DESTROY(_selection);
  DESTROY(_selectedValue);
  DESTROY(_noSelectionString);

  [super dealloc];
}
  
//--------------------------------------------------------------------
-(id) description
{
  return [NSString stringWithFormat:@"<%s %p list:%@ item:%@ string:%@ selections:%@ selectedValue:%@ NoSelectionString:%@ >",
                   object_getClassName(self),
                   (void*)self, 
                   _list, _item, _string, _selection, _selectedValue, _noSelectionString];
};

//--------------------------------------------------------------------
- (void)_slowTakeValuesFromRequest:(GSWRequest*) request
                         inContext:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);
  if (_selection != nil
      && ![self disabledInComponent:component]
      && [context _wasFormSubmitted])
    {
      id selection = nil;
      
      NSString * ctxName = [self nameInContext:context];
      NSString * formValue = [request stringFormValueForKey: ctxName];

      if (formValue != nil 
	  && ![formValue isEqual:@"WONoSelectionString"])
	{
	  NSArray* list = [_list valueInComponent:component];
	  if (list != nil) 
	    {
	      if ([list isKindOfClass:[NSArray class]])
		{
		  NSUInteger listCount = [list count];
		  NSUInteger i = 0;
		  IMP oaiIMP=NULL;

		  for(i=0;i<listCount;i++)
		    {
		      id value = nil;
		      id item = GSWeb_objectAtIndexWithImpPtr(list,&oaiIMP,i);
		      [_item setValue: item
			     inComponent:component];
		      value = [_value valueInComponent:component];
		      if (value != nil)
			{
			  if ([formValue isEqual:NSStringWithObject(value)]) 
			    {
			      selection = item;
			      break;
			    }
			}
		      else
			{
			  NSLog(@"%s:'value' evaluated to nil in component '%@'.\nUnable to select item '%@'",
				__PRETTY_FUNCTION__,component,item);
			}
		    }
		}
	      else
		{
		  [NSException raise:NSInvalidArgumentException
			       format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
			       __PRETTY_FUNCTION__, [list class]];  
		}
	    }
	}
      [_selection setValue:selection
		  inComponent: component];
    }
}

//--------------------------------------------------------------------
- (void) _fastTakeValuesFromRequest:(GSWRequest*) request
                              inContext:(GSWContext*) context
{
  if (_selection != nil)
    {
      GSWComponent * component = GSWContext_component(context);

      if (![self disabledInComponent:component]
	  && [context _wasFormSubmitted])
	{
	  id selection = nil;
	  NSString * ctxName = [self nameInContext:context];
	  NSString * formValue = [request stringFormValueForKey: ctxName];
	  if (formValue != nil)
	    {
	      formValue = [formValue stringByTrimmingSpaces];
	      if (![formValue isEqual:@"WONoSelectionString"])
		{
		  int i = [formValue intValue];
		  NSArray* list = [_list valueInComponent:component];
		  if (list != nil)
		    {
		      if ([list isKindOfClass:[NSArray class]])
			{
			  if (i < [list count]
			      && i >= 0)
			    {
			      selection = [list objectAtIndex:i];
			    }
			}
		      else
			{
			  [NSException raise:NSInvalidArgumentException
				       format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
				       __PRETTY_FUNCTION__, [list class]];  
			}
		    }
		}
	    }
	  [_selection setValue: selection
		      inComponent: component];
	}
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

//--------------------------------------------------------------------
-(void) _appendValueAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*) context
{
  //do nothing
}

//--------------------------------------------------------------------
-(void) appendChildrenToResponse:(GSWResponse *) response
                       inContext:(GSWContext*) context
{
  NSArray * list = nil;
  NSUInteger listCount = 0;
  
  GSWComponent * component = GSWContext_component(context);
  BOOL doEscape = YES;
  
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

  if (_noSelectionString != nil)
    {
      id noSelectionValue = [_noSelectionString valueInComponent:component];
      if (noSelectionValue != nil)
	{
	  GSWResponse_appendContentAsciiString(response,@"\n<option value=\"WONoSelectionString\">");
	  // wo seems to NOT do it right here. They escape always.
	  if (doEscape)
	    GSWResponse_appendContentHTMLConvertString(response,NSStringWithObject(noSelectionValue)); 
	  else
	    GSWResponse_appendContentString(response, NSStringWithObject(noSelectionValue));
	  GSWResponse_appendContentAsciiString(response, @"</option>");
	}
      else
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: 'noSelectionString' evaluated to nil in component '%@'. Did not insert a WONoSelectionString.",
		       __PRETTY_FUNCTION__, component];      
	}
    }
  if (listCount>0)
    {
      NSString* selectedValueString = nil;
      id selection = nil;
      int i=0;
      IMP oaiIMP=NULL;

      if (_selection != nil)
	selection = [_selection valueInComponent:component];
      else if (_selectedValue != nil)
	selectedValueString = NSStringWithObject([_selectedValue valueInComponent:component]);

      for (i = 0; i < listCount; i++)
	{
	  NSString* valueString = nil;
	  NSString* displayString = nil;
	  id item = nil;
	  BOOL isSelected = NO;

	  if (list != nil)
	    item = GSWeb_objectAtIndexWithImpPtr(list,&oaiIMP,i);

	  if (_string != nil
	      || _value != nil)
	    {
	      [_item setValue:item
		     inComponent:component];
	      
	      if (_string != nil)
		{
		  displayString = NSStringWithObject([_string valueInComponent:component]);
		  if (displayString != nil)
		    {
		      if (_value != nil)
			valueString = NSStringWithObject([_value valueInComponent:component]);
		      else
			valueString = displayString;
		    }
		}
	      else
		{
		  valueString = NSStringWithObject([_value valueInComponent:component]);
		  displayString = valueString;
		}
	    }
	  else
	    {
	      displayString = NSStringWithObject(item);
	      valueString = displayString;
	    }
	  GSWResponse_appendContentAsciiString(response,@"\n<option");
	  
	  if (_selection != nil)
	    {
	      if (selection!=nil)
		isSelected = [selection isEqual:item];
	    }
	  else if (_selectedValue != nil)
	    {
	      if (_value != nil)
		{
		  if (selectedValueString)
		    isSelected = [selectedValueString isEqual: valueString];
		}
	      else
		{
		  isSelected = [GSWIntToNSString(i) isEqual:selectedValueString];
		}
	    }

	  if (isSelected)
	    {
	      GSWResponse_appendContentCharacter(response,' ');
	      GSWResponse_appendContentAsciiString(response,@"selected");
	    }
	  
	  if (_value != nil)
	    {
	      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, 
									    value__Key, 
									    valueString, 
									    YES);
	    }
	  else
	    {
	      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
									    value__Key,
									    GSWIntToNSString(i),
									    NO);
	    }
	  GSWResponse_appendContentCharacter(response,'>');
	  if (doEscape)
	    GSWResponse_appendContentHTMLConvertString(response, displayString);
	  else
	    GSWResponse_appendContentString(response, displayString);
	  GSWResponse_appendContentAsciiString(response,@"</option>");
	}
    }
}

@end

