/** GSWRepetition.m - <title>GSWeb: Class GSWRepetition</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
   $Revision$
   $Date$
   
   <abstract></abstract>

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

//====================================================================
@implementation GSWRepetition

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{         
  if ((self = [super initWithName:nil
		     associations:nil
		     template: template]))
    {
      ASSIGN(_list, [associations objectForKey: list__Key]);
      ASSIGN(_item, [associations objectForKey: item__Key]);
      ASSIGN(_count, [associations objectForKey: count__Key]);
      ASSIGN(_index, [associations objectForKey: index__Key]);
      
      if (!WOStrictFlag)
	{
	  ASSIGN(_startIndex, [associations objectForKey: startIndex__Key]);
	  ASSIGN(_stopIndex, [associations objectForKey: stopIndex__Key]);
	}
      
      if (_list == nil 
	  && _count == nil)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Missing 'list' or 'count' attribute.",
		       __PRETTY_FUNCTION__];  
	}
      if (_list != nil
	  && _item == nil)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Missing 'item' attribute with 'list' attribute.",
		       __PRETTY_FUNCTION__];  
	}
      if (_list != nil
	  && _count != nil)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Illegal use of 'count' attribute with 'list' attribute.",
		       __PRETTY_FUNCTION__];  
	}
      if (_count != nil
	  && (_list != nil
	      || _item != nil))
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Illegal use of 'list' or 'item' attribute with 'count' attribute.",
                            __PRETTY_FUNCTION__];    
	}
      if (_item != nil
	  && ![_item isValueSettable])
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: The 'item' attribute must be settable.",
		       __PRETTY_FUNCTION__];    
	}
      if (_index != nil
	  && ![_index isValueSettable])
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: The 'index' attribute must be settable.",
		       __PRETTY_FUNCTION__];    
	}
    }

  return self;
};


//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_count);
  DESTROY(_index);
  DESTROY(_startIndex);
  DESTROY(_stopIndex);

  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p list:%@ item:%@ count:%@ index:%@>",
                   object_getClassName(self),
                   (void*)self,
                   _list, _item, _count, _index];
};

//--------------------------------------------------------------------
static inline void _prepareForIterationWithIndex(BOOL isFirst,
						 int i, 
						 int count, 
						 NSArray * list, 
						 IMP* oaiIMPPtr,
						 GSWContext * context, 
						 GSWComponent *component, 
						 GSWAssociation* item, 
						 GSWAssociation* index)
{
  if (item != nil)
    {
      id obj = GSWeb_objectAtIndexWithImpPtr(list,oaiIMPPtr,i);
      [item _setValueNoValidation:obj 
	    inComponent:component];
    }
  if (index != nil)
    {
      [index _setValueNoValidation:GSWIntNumber(i)
	     inComponent:component];
    }
  if (isFirst)
    GSWContext_appendZeroElementIDComponent(context);
  else
    GSWContext_incrementLastElementIDComponent(context);
}

//--------------------------------------------------------------------
static inline void _cleanupAfterIteration(GSWContext * context, 
					  GSWComponent * component, 
					  int i, 
					  GSWAssociation* item, 
					  GSWAssociation* index)
{
  if (item != nil)
    {
      [item _setValueNoValidation:nil 
	    inComponent:component];
    }
  if (index != nil)
    {
      [index _setValueNoValidation:GSWIntNumber(i)
	     inComponent:component];
    }
  GSWContext_deleteLastElementIDComponent(context);
}

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  NSArray      * list = nil;
  NSUInteger count = 0;
  NSUInteger i = 0;
  BOOL isFirst = YES;
  IMP oaiIMP=NULL;
  
  if (_list != nil)
    {
      list = [_list valueInComponent:component];
      if (list != nil)
	count = [list count];
    }
  else
    {
      count = [[_count valueInComponent:component] intValue];
    }

  if (_startIndex != nil)
    i=[[_startIndex valueInComponent:component] intValue];

  if (_stopIndex != nil)
    {
      NSUInteger stopIndex=[[_stopIndex valueInComponent:component] intValue];
      if (stopIndex<count)
	count=stopIndex+1;
    }

  for (; i < count; i++)
    {
      _prepareForIterationWithIndex(isFirst, i, count, list, &oaiIMP, context, component,_item, _index);
      [super appendChildrenToResponse:response
	     inContext:context];
      isFirst=NO;
    }

  if (!isFirst)
    _cleanupAfterIteration(context, component, count, _item, _index);
}


static inline NSString* _indexStringForSenderAndElement(NSString * senderStr, NSString * elementStr)
{
  int elementLen = [elementStr length]+ 1;
  int senderLen = [senderStr length];
  
  NSRange myRange = [senderStr rangeOfString:@"." 
                                     options:0
                                       range:NSMakeRange(elementLen, (senderLen - elementLen))];
                                       

//  NSLog(@"elementLen:%d", elementLen);
//  NSLog(@"senderLen:%d", senderLen);

  if (myRange.location == NSNotFound)
    return [senderStr substringFromIndex: elementLen];
  else 
    {
      //  NSLog(@"found myRange.location:%d", myRange.location);
      return [senderStr substringWithRange: NSMakeRange(elementLen, myRange.location-elementLen)];
    }
}

//--------------------------------------------------------------------
-(id <GSWActionResults>)invokeActionForRequest:(GSWRequest*)request
				     inContext:(GSWContext*)context
{
  id <GSWActionResults, NSObject> element   = nil;
  GSWComponent * component = GSWContext_component(context);
  NSString     * indexStr  = nil;
  NSString     * senderID     = [context senderID];
  NSString     * elementID    = [context elementID];
  
  if ([senderID hasPrefix:elementID])
    {
      int i = [elementID length];
      // code taken from http://www.unicode.org/charts/PDF/U0000.pdf
      // '.'
      if (([senderID length] > i) && ([senderID characterAtIndex:i] == 0x002e))
	{
	  indexStr = _indexStringForSenderAndElement(senderID, elementID);
	  //      NSLog(@"indexStr is '%@' senderID:'%@' elementID:'%@'", indexStr, senderID, elementID);
	}
    }

  if (indexStr != nil) 
    {
      int i = [indexStr intValue];
      if (_startIndex != nil)
	i+=[[_startIndex valueInComponent:component] intValue];

      if (_list != nil)
	{
	  NSArray* list = [_list valueInComponent:component];
	  	  
	  if (list != nil)
	    {
	      IMP oaiIMP=NULL;
	      int stopIndex = 0;
	      id currentValue = nil;
	      NSUInteger count = [list count];
	      if (_stopIndex)
		{
		  stopIndex=[[_stopIndex valueInComponent:component] intValue];
		  if (stopIndex<count)
		    count=stopIndex+1;
		}
	      if (i >= 0
		  && i < count)
		{
		  currentValue = GSWeb_objectAtIndexWithImpPtr(list,&oaiIMP,i);
		}
	      if (_item != nil)
		{
		  [_item _setValueNoValidation:currentValue
			 inComponent:component];
		}
	    }
	}
      if (_index != nil)
	{
	  [_index _setValueNoValidation:GSWIntNumber(i)
		  inComponent:component];
	}
      GSWContext_appendElementIDComponent(context,indexStr);
      element = (id <GSWActionResults, NSObject>) [super invokeActionForRequest:request
							 inContext:context];
      GSWContext_deleteLastElementIDComponent(context);
    }
  else
    {
      BOOL isFirst=YES;
      NSUInteger count = 0;
      NSUInteger k = 0;
      NSArray* list = nil;
      IMP oaiIMP=NULL;

      if (_list != nil)
	{
	  list = [_list valueInComponent:component];
	  count =  [list count];
	}
      else
	{
	  id countValue = [_count valueInComponent:component];
	  if (countValue != nil)
	    {
	      count = [countValue intValue];    // or first into a string?
	    }
	  else
	    {
	      NSLog(@"%s:'count' evaluated to nil in component %@. Repetition count reset to zero.",
		    __PRETTY_FUNCTION__, component);
	    }
	}
      if (_startIndex != nil)
	k=[[_startIndex valueInComponent:component] intValue];

      if (_stopIndex != nil)
	{
	  NSUInteger stopIndex=[[_stopIndex valueInComponent:component] intValue];
	  if (stopIndex<count)
	    count=stopIndex+1;
	}
    
      for (; k < count && element == nil; k++)
	{
	  _prepareForIterationWithIndex(isFirst,k, count, list, &oaiIMP, context, component, _item, _index);
	  element = (id <GSWActionResults, NSObject>) [super invokeActionForRequest:request
							     inContext:context];
	  isFirst=NO;
	}

      if (!isFirst)
	_cleanupAfterIteration(context, component, count, _item, _index);
    }
  return element;
};

//--------------------------------------------------------------------
- (void) takeValuesFromRequest:(GSWRequest *) request
                     inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  NSArray      * list   = nil;
  NSUInteger     i      = 0;
  NSUInteger     count = 0;
  BOOL           isFirst = YES;
  IMP            oaiIMP=NULL;

  if (_list != nil)
    {
      list = [_list valueInComponent:component];
      if (list != nil)
	count = [list count];    
    } 
  else
    {
      id countValue = [_count valueInComponent:component];
      if (countValue != nil)
	count = [countValue intValue];    // or first into a string?
      else
	{
	  NSLog(@"%s: 'count' evaluated to nil in %@. Resetting to zero. (%@)",
		__PRETTY_FUNCTION__, component, _count);  
	}
    }

  if (_startIndex != nil)
    i=[[_startIndex valueInComponent:component] intValue];

  if (_stopIndex != nil)
    {
      NSUInteger stopIndex=[[_stopIndex valueInComponent:component] intValue];
      if (stopIndex<count)
	count=stopIndex+1;
    }

  for (i = 0; i < count; i++)
    {      
      _prepareForIterationWithIndex(isFirst, i, count, list, &oaiIMP, context, component,_item, _index);
      
      [super takeValuesFromRequest:request
	     inContext:context];
      isFirst=NO;
    }

  if (!isFirst)
    _cleanupAfterIteration(context, component, count, _item, _index);
}



@end

