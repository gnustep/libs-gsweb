/** GSWRadioButtonList.m - <title>GSWeb: Class GSWRadioButtonList</title>

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
#include "GSWPrivate.h"

/**
Bindings

	list		Array of objects that the dynamic element iterate through.

        index		On each iteration the element put the current index in this binding

        item		On each iteration the element take the item at the current index and put it in this binding

        displayString  	String to display for each radio button.

        value		Value for the INPUT tag for each radio button

        prefix		An html string to insert before each value.

        suffix		An html string to insert after each value.

        selection	Selected object (used to pre-check radio button and modified to reflect user choice)
        			It contains  object from list, not value binding evaluated one !

        selectionValue	Selected value (used to pre-check radio button and modified to reflect user choice)
        			It contains evaluated value binding !

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the radio button appear inactivated.

        escapeHTML	If evaluated to yes, escape displayString

        isDisplayStringBefore If evaluated to yes, displayString is displayed before radio button
**/

//static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWRadioButtonList

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWRadioButtonList class])
    {
      standardClass=[GSWRadioButtonList class];
    }
}

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{         
  if ((self = [super initWithName:aName
		     associations:associations
		     template: template]))
    {
      _loggedSlow = NO;

      GSWAssignAndRemoveAssociation(&_suffix,_associations,suffix__Key);
      GSWAssignAndRemoveAssociation(&_index,_associations,index__Key);
      GSWAssignAndRemoveAssociation(&_list,_associations,list__Key);
      GSWAssignAndRemoveAssociation(&_item,_associations,item__Key);
      GSWAssignAndRemoveAssociation(&_selection,_associations,selection__Key);
      GSWAssignAndRemoveAssociation(&_prefix,_associations,prefix__Key);
      GSWAssignAndRemoveAssociation(&_displayString,_associations,displayString__Key);
      
      if (_displayString == nil)
	{
	  ASSIGN(_displayString, _value);
	  _defaultEscapeHTML = NO;
	}
      else
	{
	  _defaultEscapeHTML = YES;
	}
      if (((_list == nil || (_displayString != nil || _value != nil)) 
	   && (_item == nil || ![_item isValueSettable])) 
	  || (_selection != nil && ![_selection isValueSettable]))
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: 'list' must be present. 'item' must not be a constant if 'displayString' or 'value' is present.  'selections' must not be a constant if present.",
		       __PRETTY_FUNCTION__];      
	} 
    }
  return self;
}

//-----------------------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_index);
  DESTROY(_selection);
  DESTROY(_prefix);
  DESTROY(_suffix);
  DESTROY(_displayString);

  [super dealloc];
}

//--------------------------------------------------------------------
-(id) description
{
  return [NSString stringWithFormat:@"<%s %p list:%@ item:%@ index:%@ selection:%@ prefix:%@ suffix:%@ displayString:%@ escapeHTML:%@>",
                   object_getClassName(self),
                   (void*)self, 
                   _list, _item, _index,
                   _selection, _prefix, _suffix, _displayString, _escapeHTML];
}

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return @"INPUT";
};

//--------------------------------------------------------------------
-(void)_slowTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);

  if (![self disabledInComponent:component]
      && [context _wasFormSubmitted])
    {
      id         selection = nil;
      NSString * ctxName = [self nameInContext:context];
      NSString * formValue = [request stringFormValueForKey: ctxName];
      
      if (formValue != nil)
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
	      int i = 0;
	      NSUInteger count = [list count];
	      IMP list_oaiIMP=NULL;
	      for (i = 0; i < count; i++)
		{
		  id value= nil;
		  id item = GSWeb_objectAtIndexWithImpPtr(list,&list_oaiIMP,i);

		  [_item setValue:item
			 inComponent:component];

		  value = [_value valueInComponent:component];
		  if (value == nil)
		    {
		      NSLog(@"%s: 'value' evaluated to nil in component %@ Unable to select item %@",
			    __PRETTY_FUNCTION__,self,item);
		    }
		  else if ([formValue isEqual:NSStringWithObject(value)]) 
		    {
		      selection = item;
		      break;
		    }
		}
	    }
	}
      [_selection setValue:selection
		  inComponent:component];
    }
}

//-----------------------------------------------------------------------------------
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);

  if (_selection != nil
      && ![self disabledInComponent:component]
      && [context _wasFormSubmitted])
    {
      id         selection = nil;
      NSString * ctxName = [self nameInContext:context];
      NSString * formValue = [request stringFormValueForKey: ctxName];
      
      if (formValue != nil)
	{
	  NSArray* list = [_list valueInComponent:component];
	  
	  if ([list isKindOfClass:[NSArray class]] == NO)
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
			   __PRETTY_FUNCTION__, [list class]];  
	    }
	  
	  selection = [list objectAtIndex:[formValue intValue]];
	}
      [_selection setValue:selection
		  inComponent:component];
    }
}

//-----------------------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  GSWComponent * component       = GSWContext_component(context);
  NSArray*       list       = [_list valueInComponent:component];

  if (list!=nil)
    {
      if ([list isKindOfClass:[NSArray class]] == NO)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
		       __PRETTY_FUNCTION__, [list class]];  
	}
      else
	{
	  NSUInteger count=[list count];
	  if (count>0)
	    {
	      int i = 0;
	      BOOL doEscape = (_escapeHTML == nil) ? _defaultEscapeHTML : [_escapeHTML boolValueInComponent:component];
	      NSString* ctxName  = [self nameInContext:context];
	      id selection = [_selection valueInComponent:component];
	      IMP list_oaiIMP=NULL;
	      BOOL isDisabled=[self disabledInComponent:GSWContext_component(context)];
	      BOOL hasConstantAttributes=[self hasConstantAttributes];
	      BOOL hasNonURLAttributes=[self hasNonURLAttributes];
	      BOOL hasURLAttributes=[self hasURLAttributes];
  
	      for (i = 0; i < count; i++)
		{
		  NSString * prefixStr = nil;
		  NSString * suffixStr =  nil;
		  NSString * dispStr = nil;
		  id        displayValue     = nil;
		  id        value = nil;
		  id        item    = nil;  
		  
		  if (_index != nil)
		    {
		      [_index setValue:GSWIntToNSString(i)
			      inComponent:component];
		    }
		  
		  if (_prefix != nil)
		    prefixStr = NSStringWithObject([_prefix valueInComponent:component]);
		  
		  if (_suffix != nil)
		    suffixStr = NSStringWithObject([_suffix valueInComponent:component]);
		  
		  item = GSWeb_objectAtIndexWithImpPtr(list,&list_oaiIMP,i);
		  
		  if (_item != nil
		      && _displayString != nil)
		    {
		      [_item setValue:item
			     inComponent:component];
		      displayValue = [_displayString valueInComponent:component];
		      
		      if (displayValue == nil)
			{
			  dispStr = NSStringWithObject(item);
			  NSLog(@"%s: 'displayString' evaluated to nil in component %@. Using %@", 
				__PRETTY_FUNCTION__, component, dispStr);
			}
		      else
			dispStr = NSStringWithObject(displayValue);	
		    }
		  else
		    dispStr = NSStringWithObject(item);
		  
		  GSWResponse_appendContentAsciiString(response, @"<input name=\"");
		  GSWResponse_appendContentString(response,ctxName);
		  GSWResponse_appendContentAsciiString(response, @"\" type=radio value=\"");
		  
		  if (_value != nil)
		    {
		      value = [_value valueInComponent:component];
		      if (value != nil)
			GSWResponse_appendContentHTMLConvertString(response,NSStringWithObject(value));
		      else
			{
			  NSLog(@"%s: 'value' evaluated to nil in component %@. Using index", 
				__PRETTY_FUNCTION__, component);
			}
		    }

		  if (value == nil)
		    GSWResponse_appendContentAsciiString(response,GSWIntToNSString(i));
		  
		  if (selection != nil 
		      && [selection isEqual:item])
		    GSWResponse_appendContentAsciiString(response,@"\" checked");
		  else
		    GSWResponse_appendContentAsciiString(response,@"\"");
		  
		  if (isDisabled)
		    GSWResponse_appendContentAsciiString(response,@" disabled");
		  
		  //append other associations (like id, onChange, ...)
		  if (hasConstantAttributes)
		    {
		      [self appendConstantAttributesToResponse: response 
			    inContext: context];
		    }
		  
		  if (hasNonURLAttributes)
		    {
		      [self appendNonURLAttributesToResponse: response
			    inContext: context];
		    }
		  
		  if (hasURLAttributes)
		    {
		      [self appendURLAttributesToResponse: response
			    inContext: context];
		    }
		  
		  GSWResponse_appendContentCharacter(response,'>');
	      
		  if (prefixStr != nil)
		    GSWResponse_appendContentString(response,prefixStr);
		  
		  if (doEscape)
		    GSWResponse_appendContentHTMLConvertString(response, dispStr);
		  else
		    GSWResponse_appendContentString(response,dispStr);
		  
		  if (suffixStr != nil)
		    GSWResponse_appendContentString(response,suffixStr);
		}
	    }
	}
    }
}

//-----------------------------------------------------------------------------------
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping
{
  return NO;
};

//-----------------------------------------------------------------------------------
-(BOOL)appendStringAtLeft:(id)unkwnon
              withMapping:(char*)mapping
{
  return NO;
};

//-----------------------------------------------------------------------------------
-(BOOL)compactHTMLTags
{
  return NO;
};

//-----------------------------------------------------------------------------------
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
      [self _slowTakeValuesFromRequest:request inContext:context];
    }
  else
    [self _fastTakeValuesFromRequest:request inContext:context];
}

@end
