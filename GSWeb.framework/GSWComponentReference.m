/* GSWComponentReference.m - <title>GSWeb: Class GSWComponentReference</title>

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
@implementation GSWComponentReference

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
{
  LOGObjectFnStart();
  //OK
  NSDebugMLLog(@"gswdync",@"aName:%@",aName);
  NSDebugMLLog(@"gswdync",@"associations:%@",associations);
  if ((self==[super initWithName:aName
                    associations:associations
                    template:nil]))
    {
      ASSIGN(_name,aName);
      if (associations && [associations count])
        {
          NSMutableArray* tmpArray=[NSMutableArray array];
          int i=0;
          ASSIGN(_associationsKeys,[associations allKeys]);
          for(i=0;i<[_associationsKeys count];i++)
            {
              [tmpArray addObject:[associations objectForKey:[_associationsKeys objectAtIndex:i]]];
            };
          ASSIGN(_associations,[NSArray arrayWithArray:tmpArray]);
        };
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"aName:%@",aName);
  NSDebugMLLog(@"gswdync",@"associations:%@",associations);
  NSDebugMLLog(@"gswdync",@"template:%@",template);
  if ((self==[self initWithName:aName
                   associations:associations]))
    {
      ASSIGN(_contentElement,template);
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWComponentReference");
  GSWLogC("Destroy name");
  DESTROY(_name);
  GSWLogC("Destroy associationsKeys");
  DESTROY(_associationsKeys);
  GSWLogC("Destroy associations");
  DESTROY(_associations);
  GSWLogC("Destroy contentElement");
  DESTROY(_contentElement);
  GSWLogC("Dealloc GSWComponentReference Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWComponentReference");
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%@ %p name:%@ associationsKeys:%@ associations:%@ contentElement:%@>",
                   [self class],
                   (void*)self,
                   _name,
                   _associationsKeys,
                   _associations,
                   _contentElement];
};

@end

//====================================================================
@implementation GSWComponentReference (GSWComponentReferenceA)
-(void)popRefComponentInContext:(GSWContext*)context
{
  //OK
  GSWComponent* subComponent=nil;
  GSWComponent* component=nil;
  LOGObjectFnStart();
  subComponent=[context component];
  component=[subComponent parent];
  [subComponent synchronizeComponentToParent];
  [context _setCurrentComponent:component];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)pushRefComponentInContext:(GSWContext*)context
{
  //OK
  GSWComponent* subComponent=nil;
  GSWComponentDefinition* subComponentDefinition=nil;
  GSWComponent* component=nil;
  NSString* elementID=nil;
  LOGObjectFnStart();
  component=[context component];
  elementID=[context elementID];
  NSDebugMLLog(@"gswdync",@"_elementID:%@",elementID);
  subComponent=[component subComponentForElementID:elementID];
  NSDebugMLLog(@"gswdync",@"subComponent:%@",subComponent);
  if (!subComponent)
    {
      NSArray* languages=[context languages];
      NSDebugMLLog(@"gswdync",@"name:%@",_name);
      NSDebugMLLog(@"gswdync",@"pushRefComponentInContext comporef=%p parent=%p",
                   (void*)self,
                   (void*)component);
      subComponentDefinition=[GSWApp componentDefinitionWithName:_name
                                     languages:languages];
      NSDebugMLLog(@"gswdync",@"subComponentDefinition=%@",subComponentDefinition);
      if (subComponentDefinition)
        {
          subComponent=[subComponentDefinition componentInstanceInContext:context];
          NSDebugMLLog(@"gswdync",@"subComponent:%@",subComponent);
          if (subComponent)
            {
              NSDebugMLLog(@"gswdync",@"SETPARENT comporef=%p parent=%p component=%p",
                           (void*)self,
                           (void*)component,
                           (void*)subComponent);
			  [subComponent setParent:component
                                        associationsKeys:_associationsKeys
                                        associations:_associations
                                        template:_contentElement];
            }
          else
            {
              ExceptionRaise(@"GSWComponentReference: subcomponent instance creation failed in '@'",
                             _name);
            };
        }
      else
        {
          ExceptionRaise(@"GSWComponentReference: can't find subcomponent definition in '@'",
                         _name);
        };
      if (subComponent)
        {
          [component setSubComponent:subComponent
                     forElementID:elementID];
          [subComponent awakeInContext:context];
        };
    };
  if (subComponent)
    {
      [subComponent synchronizeParentToComponent];
    };
  [context _setCurrentComponent:subComponent];

  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWComponentReference (GSWRequestHandling)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
			  inContext:(GSWContext*)context
{
  //OK
  GSWComponent* component=nil;
  GSWComponent* componentPrev=nil;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStart();
  GSWStartElement(context);
  GSWSaveAppendToResponseElementID(context);
  [response appendDebugCommentContentString:[NSString stringWithFormat:@"declarationName=%@ ID=%@ name=%@",
                                                      [self declarationName],
                                                      [context elementID],
                                                      _name]];
  componentPrev=[context component];
  [self pushRefComponentInContext:context];
  if ([context component])
    {
      component=[context component];
      [component appendToResponse:response
                 inContext:context];
      [self popRefComponentInContext:context];
    }
  else
    [context _setCurrentComponent:componentPrev];
  GSWStopElement(context);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],
           @"GSWComponentReference appendToResponse: bad elementID");
#endif
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
{
  GSWElement* element=nil;
  GSWComponent* component=nil;
  GSWComponent* componentPrev=nil;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStart();
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);
  NSDebugMLLog(@"gswdync",@"name=%@ senderId=%@",
               _name,[context senderID]);
  componentPrev=[context component];
  [self pushRefComponentInContext:context];
  if ([context component])
    {
      if ([self prefixMatchSenderIDInContext:context]) //Avoid trying to find action if we are not the good component
        {
          component=[context component];
          element=[component invokeActionForRequest:request
                              inContext:context];
          NSAssert4(!element || [element isKindOfClass:[GSWElement class]],
                    @"Name= %@, from: %@, Element is a %@ not a GSWElement: %@",
                    _name,
                    component,
                    [element class],
                    element);
        };
      [self popRefComponentInContext:context];
    }
  else
    [context _setCurrentComponent:componentPrev];
  GSWStopElement(context);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],
           @"GSWComponentReference invokeActionForRequest: bad elementID");
#endif
  LOGObjectFnStop();
  return element;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //OK
  GSWComponent* component=nil;
  GSWComponent* componentPrev=nil;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStart();
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);
  componentPrev=[context component];
  [self pushRefComponentInContext:context];
  if ([context component])
    {
      component=[context component];
      [component takeValuesFromRequest:request
				  inContext:context];
      [self popRefComponentInContext:context];
    }
  else
    [context _setCurrentComponent:componentPrev];
  GSWStopElement(context);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],
           @"GSWComponentReference takeValuesFromRequest: bad elementID");
#endif
  LOGObjectFnStop();
};
 
@end
