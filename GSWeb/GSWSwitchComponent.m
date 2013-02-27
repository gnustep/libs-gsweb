/** GSWSwitchComponent.m - <title>GSWeb: Class GSWSwitchComponent</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

//====================================================================
@implementation GSWSwitchComponent

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement
{
  if ((self=[super initWithName:aName
                   associations:associations
                   template:nil]))
    {
      NSMutableDictionary* tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];

      [tmpAssociations removeObjectForKey:GSWComponentName__Key[GSWebNamingConv]];

      [tmpAssociations removeObjectForKey:componentName__Key];
      
      _componentName = [[associations objectForKey:GSWComponentName__Key[GSWebNamingConv]
                                     withDefaultObject:[_componentName autorelease]] retain];

      if (!_componentName)
        {
          _componentName = [[associations objectForKey:componentName__Key
                                          withDefaultObject:[_componentName autorelease]] retain];
        }

      ASSIGN(_componentAttributes,[NSDictionary dictionaryWithDictionary:tmpAssociations]);      
      ASSIGN(_template,templateElement);
      
      _componentCache=[NSMutableDictionary new];
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_componentName);
  DESTROY(_componentAttributes);
  DESTROY(_template);
  DESTROY(_componentCache);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
				   object_getClassName(self),
				   (void*)self];
};

@end

//====================================================================
@implementation GSWSwitchComponent (GSWSwitchComponentA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)aContext
{
  GSWElement* element=nil;
  NSString* elementNameInContext=nil;

  GSWStartElement(aContext);
  GSWSaveAppendToResponseElementID(aContext);
  elementNameInContext=[self _elementNameInContext:aContext];
  GSWContext_appendElementIDComponent(aContext,elementNameInContext);
  if ([elementNameInContext length]==0)
    {
      ExceptionRaise(@"GSWSwitchComponent",@"ComponentName Value is null ! componentName: %@",
                     _componentName);
    };
  element=[self _realComponentWithName:elementNameInContext
                inContext:aContext];
  [element appendToResponse:response
           inContext:aContext];
  GSWContext_deleteLastElementIDComponent(aContext);
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)aContext
{
    id <GSWActionResults, NSObject> resultElement=nil;
    GSWElement* element=nil;
    NSString* elementNameInContext=nil;
    
    GSWStartElement(aContext);
    GSWAssertCorrectElementID(aContext);
    elementNameInContext=[self _elementNameInContext:aContext];
    GSWContext_appendElementIDComponent(aContext,elementNameInContext);
    if ([elementNameInContext length]==0)
    {
        ExceptionRaise(@"GSWSwitchComponent",@"ComponentName Value is null ! componentName: %@",
                       _componentName);
    };
    element=[self _realComponentWithName:elementNameInContext
                               inContext:aContext];
    resultElement = (id <GSWActionResults, NSObject>) [element invokeActionForRequest:request
                                                                           inContext:aContext];
    GSWContext_deleteLastElementIDComponent(aContext);
    
    return resultElement;
}

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext
{
  GSWElement* element=nil;
  NSString* elementNameInContext=nil;

  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);
  elementNameInContext=[self _elementNameInContext:aContext];
  GSWContext_appendElementIDComponent(aContext,elementNameInContext);
  if ([elementNameInContext length]==0)
    {
      ExceptionRaise(@"GSWSwitchComponent",@"ComponentName Value is null ! componentName: %@",
                     _componentName);
    };
  element=[self _realComponentWithName:elementNameInContext
                inContext:aContext];
  [element takeValuesFromRequest:aRequest
           inContext:aContext];
  GSWContext_deleteLastElementIDComponent(aContext);
};

//-------------------------------------------------------------------- 
/** returns a GSWComponentReference representing component named aName 
if the component has already been created, it get it from the cache; otherwise, it is created.
**/
-(GSWElement*)_realComponentWithName:(NSString*)aName
                           inContext:(GSWContext*)aContext
{
  GSWElement* element=nil;
  NSArray* languages=nil;
  GSWComponent* component=nil;

  component=GSWContext_component(aContext);

  if ([aName length]==0)
    {      
      ExceptionRaise(@"GSWSwitchComponent",
                     @"ComponentName is null. componentNameKey='%@' declarationName=%@ currentComponentName=%@",
                     _componentName,[self declarationName],[component name]);
    }
  else
    {
      element=[_componentCache objectForKey:aName];
      if (!element)
        {
          languages=[aContext languages];
          element=[GSWApp dynamicElementWithName:aName
                          associations:_componentAttributes
                          template:_template
                          languages:languages];
          if (element)
            {
              [_componentCache setObject:element
                               forKey:aName];
            }
          else
            {
              ExceptionRaise(@"GSWSwitchComponent",
                             @"GSWSwitchComponent %p (declarationName=%@): Creation failed for element named:%@",
                             self,[self declarationName],aName);
            };
        };
    };

  return element;
};

//-------------------------------------------------------------------- 
/** returns the element name by resolving _componentName association **/
-(NSString*)_elementNameInContext:(GSWContext*)aContext
{
  GSWComponent* component=nil;
  NSString* componentNameValue=nil;

  component=GSWContext_component(aContext);

  componentNameValue=[_componentName valueInComponent:component];

  return componentNameValue;
};

@end

