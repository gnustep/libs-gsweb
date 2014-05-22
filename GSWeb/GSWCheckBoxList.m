/** GSWCheckBoxList.m - <title>GSWeb: Class GSWCheckBoxList</title>

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

        displayString  	String to display for each check box.

        value		Value for the INPUT tag for each check box

        prefix		An html string to insert before each value.

        suffix		An html string to insert after each value.

        selections	Array of selected objects (used to pre-check checkboxes and modified to reflect user choices)
        			It contains  objects from list, not value binding evaluated ones !

        name		Name of the element in the form (should be unique). If not specified, GSWeb assign one.

        disabled	If evaluated to yes, the check box appear inactivated.

        escapeHTML	If evaluated to yes, escape displayString

        isDisplayStringBefore If evaluated to no, displayString is displayed after radio button. 
**/

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWCheckBoxList

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWCheckBoxList class])
    {
      standardClass=[GSWCheckBoxList class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

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

      GSWAssignAndRemoveAssociation(&_list,_associations,list__Key);
      GSWAssignAndRemoveAssociation(&_item,_associations,item__Key);
      GSWAssignAndRemoveAssociation(&_index,_associations,index__Key);
      GSWAssignAndRemoveAssociation(&_selections,_associations,selections__Key);
      GSWAssignAndRemoveAssociation(&_prefix,_associations,prefix__Key);
      GSWAssignAndRemoveAssociation(&_suffix,_associations,suffix__Key);
      GSWAssignAndRemoveAssociation(&_escapeHTML,_associations,escapeHTML__Key);
      GSWAssignAndRemoveAssociation(&_displayString,_associations,displayString__Key);

      if (_displayString==nil)
	{
	  ASSIGN(_displayString, _value);
	  _defaultEscapeHTML = NO;
	} 
      else 
	_defaultEscapeHTML = YES;
      

      if (_list == nil
	  || ((_value != nil || _displayString != nil) 
	      && (_item == nil || ![_item isValueSettable])) 
	  || (_selections != nil && ![_selections isValueSettable])) 
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: 'list' must be present. 'item' must not be a constant if 'displayString' or 'value' is present.  'selection' must not be a constant if present.",
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
  DESTROY(_index);
  DESTROY(_selections);
  DESTROY(_prefix);
  DESTROY(_suffix);
  DESTROY(_displayString);

  [super dealloc];
}

//--------------------------------------------------------------------
-(id) description
{
  return [NSString stringWithFormat:@"<%s %p list:%@ item:%@ index:%@ selections:%@ prefix:%@ suffix:%@ displayString:%@ escapeHTML:%@>",
                   object_getClassName(self),
                   (void*)self, 
                   _list, _item, _index,
                   _selections, _prefix, _suffix, _displayString, _escapeHTML];
}

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return @"input";
}

//--------------------------------------------------------------------
-(void)_slowTakeValuesFromRequest:(GSWRequest*)request
			inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  if (_selections != nil
      && ![self disabledInComponent:component]
      && [context _wasFormSubmitted])
    {
      NSArray* selections = nil;
      NSString * ctxName = [self nameInContext:context];
      NSArray * formValues = [request formValuesForKey: ctxName];
      int       formValuesCount = [formValues count];

      if (formValuesCount>0)
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

	      selections = [NSMutableArray arrayWithCapacity:formValuesCount];      

	      for (i = 0; i < listCount; i++)
		{
		  id item = GSWeb_objectAtIndexWithImpPtr(list,&oaiIMP,i);
		  id value = nil;
		  
		  [_item setValue: item
			 inComponent: component];
		  
		  value = [_value valueInComponent:component];
		  if (value != nil)
		    {
		      if ([formValues containsObject:NSStringWithObject(value)])
			[(NSMutableArray*)selections addObject:item];
		    }
		  else
		    {
		      NSLog(@"%s 'value' evaluated to nil in component %@.\nUnable to select item %@",
			    __PRETTY_FUNCTION__, self, value);
		    }
		}
	    }
	}
      if (selections==nil)
	selections = [NSArray array];
      [_selections setValue: selections
		   inComponent: component];
    }
}

//--------------------------------------------------------------------
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  
  if (_selections != nil
      && ![self disabledInComponent:component]
      && [context _wasFormSubmitted])
    {
      NSArray* selections = nil;
      NSString * ctxName = [self nameInContext:context];
      NSArray * formValues = [request formValuesForKey: ctxName];
      int       formValuesCount = [formValues count];
      if (formValuesCount>0)
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
	      int i=0;
	      IMP formValues_oaiIMP=NULL;
	      IMP list_oaiIMP=NULL;
	      for (i = 0; i < formValuesCount; i++)
		{
		  int itemIndex = [NSStringWithObject(GSWeb_objectAtIndexWithImpPtr(formValues,&formValues_oaiIMP,i)) intValue];
		  [(NSMutableArray*)selections addObject:GSWeb_objectAtIndexWithImpPtr(list,&list_oaiIMP,itemIndex)];
		}
	    }
	}
      if (selections==nil)
	selections = [NSArray array];
      [_selections setValue: selections 
		   inComponent: component];
    }
}

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  GSWComponent * component       = GSWContext_component(context);
  NSArray*       list       = [_list valueInComponent:component];
  
  if ([list isKindOfClass:[NSArray class]] == NO)
    {
      [NSException raise:NSInvalidArgumentException
		   format:@"%s: Evaluating 'list' binding returned a '%@' class and not a NSArray.",
		   __PRETTY_FUNCTION__, [list class]];  
    }
  else
    {
      NSUInteger listCount=[list count];
      if (listCount>0)
	{
	  NSString* ctxName = [self nameInContext:context];
	  int i = 0;
	  BOOL doEscape = NO;
	  id selections = nil;
	  IMP oaiIMP=NULL;
	  
	  if (_escapeHTML==nil)
	    doEscape=_defaultEscapeHTML;
	  else
	    doEscape=[_escapeHTML boolValueInComponent:component];
	  
	  if (_selections!=nil)
	    selections = [_selections valueInComponent:component];  
	  
	  for (i = 0; i < listCount; i++) 
	    {
	      NSString * prefixStr = nil;
	      NSString * suffixStr = nil;
	      NSString * displayString = nil;
	      id        item     = nil;
	      id        value    = nil;
	      
	      if (_prefix != nil)
		prefixStr = NSStringWithObject([_prefix valueInComponent:component]);
	      
	      if (_suffix != nil)
		suffixStr = NSStringWithObject([_suffix valueInComponent:component]);
	      
	      if (_index != nil)
		{
		  [_index setValue:GSWIntToNSString(i)
			  inComponent:component];
		}
	      
	      item = GSWeb_objectAtIndexWithImpPtr(list,&oaiIMP,i);
	      
	      if (_item != nil
		  && _displayString != nil)
		{
		  id displayValue=nil;
		  [_item setValue:item
			 inComponent:component];
		  
		  displayValue= [_displayString valueInComponent:component];
		  
		  if (displayValue == nil)
		    {
		      displayString = NSStringWithObject(displayValue);
		      NSLog(@"%s: 'displayString' evaluated to nil in component %@. Using %@", 
			    __PRETTY_FUNCTION__, component, displayString);
		    }
		  else
		    {
		      displayString = NSStringWithObject(displayValue);
		    }
		}
	      else
		displayString = NSStringWithObject(item);
	      
	      GSWResponse_appendContentAsciiString(response, @"<input name=\"");
	      GSWResponse_appendContentString(response,ctxName);
	      GSWResponse_appendContentAsciiString(response,@"\" type=checkbox value=\"");
	      
	      if (_value != nil)
		{
		  value = [_value valueInComponent:component];
		  if (value != nil) 
		    {
		      GSWResponse_appendContentHTMLConvertString(response, NSStringWithObject(value));
		    }
		  else 
		    {
		      NSLog(@"%s: 'value' evaluated to nil in component %@. Using to index.",
			    __PRETTY_FUNCTION__, self);
		    }
		}
	      if (value == nil) 
		GSWResponse_appendContentAsciiString(response,GSWIntToNSString(i));
	      
	      if ([selections containsObject:item]) 
		GSWResponse_appendContentAsciiString(response,@"\" checked>");
	      else 
		GSWResponse_appendContentAsciiString(response,@"\">");
	      
	      if (prefixStr != nil) 
		GSWResponse_appendContentString(response,prefixStr);
	      
	      if (doEscape)
		GSWResponse_appendContentHTMLConvertString(response,displayString);
	      else 
		GSWResponse_appendContentString(response,displayString);
	      
	      if (suffixStr != nil) 
		GSWResponse_appendContentString(response,suffixStr);
	    } // for
	}
    }
}

//--------------------------------------------------------------------
-(BOOL)appendStringAtRight:(id)_unkwnon
               withMapping:(char*)_mapping
{
  return NO;
}

//--------------------------------------------------------------------
-(BOOL)appendStringAtLeft:(id)_unkwnon
              withMapping:(char*)_mapping
{
  return NO;
}

//--------------------------------------------------------------------
-(BOOL)compactHTMLTags
{
  return NO;
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
      [self _slowTakeValuesFromRequest:request inContext:context];
    }
  else
    [self _fastTakeValuesFromRequest:request inContext:context];
}

@end
