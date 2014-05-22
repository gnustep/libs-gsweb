/** GSWDynamicGroup.m - <title>GSWeb: Class GSWDynamicGroup</title>

   Copyright (C) 2005-2006 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de>
   Date: Dec 2005
   
   $Revision: 1.17 $
   $Date: 2004/12/31 14:33:16 $

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

RCS_ID("$Id: GSWDynamicGroup.m,v 1.17 2004/12/31 14:33:16 mguesdon Exp $")

#include "GSWeb.h"
#include "GSWPrivate.h"

static Class GSWHTMLBareStringClass = Nil;

//====================================================================
@implementation GSWDynamicGroup

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWDynamicGroup class])
    {
      GSWHTMLBareStringClass = [GSWHTMLBareString class];
    };
};

//--------------------------------------------------------------------
+ (GSWDynamicGroup*) emptyGroup
{
  GSWDynamicGroup * theGroup = [GSWDynamicGroup alloc];
  
  theGroup = [theGroup initWithName:nil
                       associations:nil
                           template:nil];
  
  return AUTORELEASE(theGroup);
}


//--------------------------------------------------------------------
-(NSMutableArray*) childrenElements
{
  return _children;
}

//--------------------------------------------------------------------
- (void) _initChildrenFromTemplate:(GSWElement*) element
{
  NSMutableArray * array = nil;
  if (element)
    {
      // [element isKindOfClass:[GSWDynamicGroup class]] 
      if ([element isKindOfClass:[GSWHTMLStaticGroup class]])
	{
	  array = [(GSWDynamicGroup*) element childrenElements];
	  //NSLog(@"%s element is %@ array is %@", __PRETTY_FUNCTION__, element, array);      
	}
      // normally, this should be called only if the above isKindOfClass is NO.
      // BUT some elements seem be parsed wrong/different than in WO.
      if (array == nil)
	{
	  array = [NSMutableArray array];
	  [array addObject:element];
	}
    }
  DESTROY(_children);
  if ([array count] > 0)
    ASSIGN(_children,array);
}


//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  if ((self=[super initWithName:nil
		   associations:nil   
		   template:nil]))
    {
      [self _initChildrenFromTemplate:template];
    }
  return self;
}

//--------------------------------------------------------------------
// YES it is called like that
// initWithName:associations:contentElements
// NOT initWithName: attributeAssociations: contentElements:
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSMutableArray*) children
{
  if ((self=[super initWithName:nil
		   associations:nil   
                   template:nil]))
    {
      DESTROY(_children);
      if ([children count] > 0)
	ASSIGN(_children, children);
    }
  return self;
}

//--------------------------------------------------------------------
-(void) dealloc
{
  DESTROY(_children);

  [super dealloc];
}

//--------------------------------------------------------------------
-(void) addChildElement:(id) element
{
  if (_children == nil)
    _children = [NSMutableArray new];
  [_children addObject:element];
}

//--------------------------------------------------------------------
- (BOOL) hasChildrenElements
{
  return ([_children count] > 0 ? YES : NO);
}

//--------------------------------------------------------------------
-(void) takeChildrenValuesFromRequest:(GSWRequest*)request
                            inContext:(GSWContext*)aContext
{
  if ([self hasChildrenElements])
    {
      NSUInteger c = [_children count];
      int i = 0;
      IMP oaiIMP=NULL;
      
      GSWContext_appendZeroElementIDComponent(aContext);
      
      for (i=0; i < c; i++)
	{
	  GSWElement * element = GSWeb_objectAtIndexWithImpPtr(_children,&oaiIMP,i);
	  if (i>0)
	    GSWContext_incrementLastElementIDComponent(aContext);
	  [element takeValuesFromRequest: request 
		   inContext: aContext];
	}
      
      GSWContext_deleteLastElementIDComponent(aContext);
    }
}

//--------------------------------------------------------------------
-(void) takeValuesFromRequest:(GSWRequest*)request
                    inContext:(GSWContext*)aContext
{
  [self takeChildrenValuesFromRequest:request
                            inContext:aContext];
}

//--------------------------------------------------------------------
-(id <GSWActionResults>) invokeChildrenActionForRequest:(GSWRequest*)request
					      inContext:(GSWContext*)aContext

{
  id actionresults = nil;

  if ([self hasChildrenElements])
    {
      NSUInteger c = [_children count];
      int i = 0;
      IMP oaiIMP=NULL;
      
      GSWContext_appendZeroElementIDComponent(aContext);
      
      for (i=0; i < c && actionresults == nil; i++)
	{
	  GSWElement * element = GSWeb_objectAtIndexWithImpPtr(_children,&oaiIMP,i);
	  if (i>0)
	    GSWContext_incrementLastElementIDComponent(aContext);
	  if ([element class] != GSWHTMLBareStringClass)
	    {      
	      actionresults = [element invokeActionForRequest: request 
				       inContext: aContext];
	    }
	}
      GSWContext_deleteLastElementIDComponent(aContext);
  }
  return actionresults;
}

//--------------------------------------------------------------------
-(id <GSWActionResults>) invokeActionForRequest:(GSWRequest*)request
                                    inContext:(GSWContext*)aContext
{
  return  [self invokeChildrenActionForRequest:request
		inContext:aContext];
}

//--------------------------------------------------------------------
-(void) appendChildrenToResponse:(GSWResponse*) response
                       inContext:(GSWContext*)aContext
{
  if ([self hasChildrenElements])
    {
      NSUInteger c = [_children count];
      int i = 0;
      IMP oaiIMP=NULL;
    
      GSWContext_appendZeroElementIDComponent(aContext);
      
      for (i=0; i < c; i++)
	{
	  GSWElement * element = GSWeb_objectAtIndexWithImpPtr(_children,&oaiIMP,i);
	  if (i>0)
	    GSWContext_incrementLastElementIDComponent(aContext);
	  [element appendToResponse: response
		   inContext: aContext];
	  
	}
      GSWContext_deleteLastElementIDComponent(aContext);
    }
}

//--------------------------------------------------------------------
-(void) appendToResponse:(GSWResponse*) response
               inContext:(GSWContext*)aContext
{
  [self appendChildrenToResponse: response
                       inContext: aContext];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p children:%@>",
                   object_getClassName(self),
                   (void*)self,
                   _children];
};


@end
