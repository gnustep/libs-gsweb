/** GSWSwitchComponent.m - <title>GSWeb: Class GSWSwitchComponent</title>
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWSwitchComponent

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement
{
  LOGObjectFnStartC("GSWSwitchComponent");
  if ((self=[super initWithName:aName
                   associations:associations
                   template:nil]))
    {
      NSMutableDictionary* tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
      NSDebugMLLog(@"gswdync",@"GSWSwitchComponent %p (defName=%@): tmpAssociations=%@",
                   self,[self definitionName],tmpAssociations);
      NSDebugMLLog(@"gswdync",@"GSWSwitchComponent %p (defName=%@): GSWComponentName__Key=%@",
                   self,[self definitionName],GSWComponentName__Key[GSWebNamingConv]);
      [tmpAssociations removeObjectForKey:GSWComponentName__Key[GSWebNamingConv]];
      NSDebugMLLog(@"gswdync",@"GSWSwitchComponent %p (defName=%@): componentName__Key=%@",
                   self,[self definitionName],componentName__Key);
      [tmpAssociations removeObjectForKey:componentName__Key];
      
      _componentName = [[associations objectForKey:GSWComponentName__Key[GSWebNamingConv]
                                     withDefaultObject:[_componentName autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWSwitchComponent %p (defName=%@): componentName=%@",
                   self,[self definitionName],_componentName);
      if (!_componentName)
        {
          _componentName = [[associations objectForKey:componentName__Key
                                          withDefaultObject:[_componentName autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"GSWSwitchComponent %p (defName=%@): componentName=%@",
                       self,[self definitionName],_componentName);
        }

      ASSIGN(_componentAttributes,[NSDictionary dictionaryWithDictionary:tmpAssociations]);
      NSDebugMLLog(@"gswdync",@"GSWSwitchComponent %p (defName=%@): componentAttributes=%@",
                   self,[self definitionName],_componentAttributes);
      
      ASSIGN(_template,templateElement);
      NSDebugMLLog(@"gswdync",@"GSWSwitchComponent %p (defName=%@): template=%@",
                   self,[self definitionName],_template);
      
      _componentCache=[NSMutableDictionary new];
    };
  LOGObjectFnStopC("GSWSwitchComponent");
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
				   object_get_class_name(self),
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
  LOGObjectFnStartC("GSWSwitchComponent");
  GSWStartElement(aContext);
  GSWSaveAppendToResponseElementID(aContext);
  elementNameInContext=[self _elementNameInContext:aContext];
  [aContext appendElementIDComponent:elementNameInContext];
  element=[self _realComponentWithName:elementNameInContext
                inContext:aContext];
  [element appendToResponse:response
           inContext:aContext];
  [aContext deleteLastElementIDComponent];
  LOGObjectFnStopC("GSWSwitchComponent");
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)aContext
{
  GSWElement* resultElement=nil;
  GSWElement* element=nil;
  NSString* elementNameInContext=nil;
  LOGObjectFnStartC("GSWSwitchComponent");
  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);
  elementNameInContext=[self _elementNameInContext:aContext];
  [aContext appendElementIDComponent:elementNameInContext];
  element=[self _realComponentWithName:elementNameInContext
				 inContext:aContext];
  resultElement=[element invokeActionForRequest:request
                           inContext:aContext];
  [aContext deleteLastElementIDComponent];
  LOGObjectFnStopC("GSWSwitchComponent");
  return resultElement;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext
{
  GSWElement* element=nil;
  NSString* elementNameInContext=nil;
  LOGObjectFnStartC("GSWSwitchComponent");
  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);
  elementNameInContext=[self _elementNameInContext:aContext];
  [aContext appendElementIDComponent:elementNameInContext];
  element=[self _realComponentWithName:elementNameInContext
                inContext:aContext];
  [element takeValuesFromRequest:aRequest
           inContext:aContext];
  [aContext deleteLastElementIDComponent];
  LOGObjectFnStopC("GSWSwitchComponent");
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
  LOGObjectFnStartC("GSWSwitchComponent");
  component=[aContext component];
  NSDebugMLLog(@"gswdync",@"GSWSwitchComponent %p (defName=%@): componentName=%@ parent=%@",
               self,[self definitionName],_componentName,[component parent]);
  if (!aName)
    {      
      ExceptionRaise0(@"GSWSwitchComponent",@"ComponentName is null !");
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
              ExceptionRaise(@"GSWSwitchComponent %p (defName=%@): Creation failed for element named:%@",
                             self,[self definitionName],aName);
            };
        };
    };
  LOGObjectFnStopC("GSWSwitchComponent");
  return element;
};

//-------------------------------------------------------------------- 
/** returns the element name by resolving _componentName association **/
-(NSString*)_elementNameInContext:(GSWContext*)aContext
{
  GSWComponent* component=nil;
  NSString* componentNameValue=nil;
  LOGObjectFnStartC("GSWSwitchComponent");
  component=[aContext component];
  NSDebugMLLog(@"gswdync",@"GSWSwitchComponent %p (defName=%@): componentName=%@",
               self,[self definitionName],_componentName);
  componentNameValue=[_componentName valueInComponent:component];
  NSDebugMLLog(@"gswdync",@"GSWSwitchComponent %p (defName=%@): componentNameValue=%@",
               self,[self definitionName],componentNameValue);
  LOGObjectFnStopC("GSWSwitchComponent");
  return componentNameValue;
};

@end

