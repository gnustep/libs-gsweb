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
      int associationsCount=[associations count];
      ASSIGN(_name,aName);
      if (associationsCount>0)
        {
          NSMutableArray* tmpArray=[NSMutableArray array];
          int i=0;
          ASSIGN(_associationsKeys,[associations allKeys]);
          for(i=0;i<associationsCount;i++)
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
  subComponent=GSWContext_component(context);
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
  component=GSWContext_component(context);
  elementID=GSWContext_elementID(context);
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
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  //OK
  GSWComponent* component=nil;
  GSWComponent* componentPrev=nil;
  GSWDeclareDebugElementIDsCount(aContext);

  LOGObjectFnStart();

  GSWStartElement(aContext);
  GSWSaveAppendToResponseElementID(aContext);

  GSWResponse_appendDebugCommentContentString(aResponse,
                                              ([NSString stringWithFormat:@"declarationName=%@ ID=%@ name=%@",
                                                         [self declarationName],
                                                         GSWContext_elementID(aContext),
                                                         _name]));
  componentPrev=GSWContext_component(aContext);
  [self pushRefComponentInContext:aContext];
  component=GSWContext_component(aContext);
  if (component)
    {
      [component appendToResponse:aResponse
                 inContext:aContext];
      [self popRefComponentInContext:aContext];
    }
  else
    [aContext _setCurrentComponent:componentPrev];

  GSWStopElement(aContext);
  GSWAssertDebugElementIDsCount(aContext);

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)aContext
{
  GSWElement* element=nil;
  GSWComponent* component=nil;
  GSWComponent* componentPrev=nil;
  GSWDeclareDebugElementIDsCount(aContext);

  LOGObjectFnStart();

  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);

  NSDebugMLLog(@"gswdync",@"name=%@ senderId=%@",
               _name,GSWContext_senderID(aContext));

  componentPrev=GSWContext_component(aContext);
  [self pushRefComponentInContext:aContext];

  component=GSWContext_component(aContext);
  if (component)
    {
      if ([self prefixMatchSenderIDInContext:aContext]) //Avoid trying to find action if we are not the good component
        {
          element=[component invokeActionForRequest:request
                             inContext:aContext];
          NSAssert4(!element || [element isKindOfClass:[GSWElement class]],
                    @"Name= %@, from: %@, Element is a %@ not a GSWElement: %@",
                    _name,
                    component,
                    [element class],
                    element);
        };
      [self popRefComponentInContext:aContext];
    }
  else
    [aContext _setCurrentComponent:componentPrev];

  GSWStopElement(aContext);
  GSWAssertDebugElementIDsCount(aContext);

  LOGObjectFnStop();

  return element;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext
{
  //OK
  GSWComponent* component=nil;
  GSWComponent* componentPrev=nil;
  GSWDeclareDebugElementIDsCount(aContext);

  LOGObjectFnStart();

  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);

  componentPrev=GSWContext_component(aContext);
  [self pushRefComponentInContext:aContext];
  component=GSWContext_component(aContext);
  if (component)
    {
      [component takeValuesFromRequest:request
                 inContext:aContext];
      [self popRefComponentInContext:aContext];
    }
  else
    [aContext _setCurrentComponent:componentPrev];

  GSWStopElement(aContext);
  GSWAssertDebugElementIDsCount(aContext);

  LOGObjectFnStop();
};
 
@end
