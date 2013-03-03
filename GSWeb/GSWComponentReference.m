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
#include "GSWPrivate.h"

//====================================================================
@implementation GSWComponentReference

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
{
  if (self==[super initWithName:aName
                    associations:associations
                    template:nil]) {
                    
     ASSIGN(_name,aName);
     ASSIGN(_keyAssociations,[NSMutableDictionary dictionaryWithDictionary:associations]);
  }
  return self;
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  if (self==[self initWithName:aName
                   associations:associations])
    {
      ASSIGN(_contentElement,template);
    };

  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_name);
  DESTROY(_keyAssociations);
  DESTROY(_contentElement);
  
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{

  return [NSString stringWithFormat:@"<%@ %p name:%@ associations:%@ contentElement:%@>",
                   [self class],
                   (void*)self,
                   _name,
                   _keyAssociations,
                   _contentElement];
};


-(void)_popComponentFromContext:(GSWContext*)context
{
  GSWComponent* component = GSWContext_component(context);
  GSWComponent* parentcomp = [component parent];
  [component pushValuesToParent];  
  [context _setCurrentComponent:parentcomp];
}



-(void)_pushComponentInContext:(GSWContext*)context
{
  GSWComponent* component = GSWContext_component(context);
  GSWComponent* subComponent = nil;
  NSString* elementID = GSWContext_elementID(context);
  GSWComponentDefinition* subComponentDefinition=nil;

  if (component != nil) {
    subComponent = [component _subcomponentForElementWithID: elementID];
  }
  if (subComponent == nil) {
    subComponentDefinition = [GSWApp _componentDefinitionWithName:_name languages:[context languages]];
   
    subComponent = [subComponentDefinition componentInstanceInContext:context];
    [subComponent _setParent:component
                associations:_keyAssociations
                    template:_contentElement];

    if (component != nil) {
      [component _setSubcomponent:subComponent
                     forElementID:elementID];
    }
    [subComponent _awakeInContext: context];
  } else {
    [subComponent _setParent:component
                associations:_keyAssociations
                    template:_contentElement];
  }

  [subComponent pullValuesFromParent];
  [context _setCurrentComponent:subComponent];

}


-(void)popRefComponentInContext:(GSWContext*)context
{
  NSLog(@"WARNING: %s is deprecated. Use _popComponentFromContext instead.", __PRETTY_FUNCTION__);
  [self _popComponentFromContext: context];
}


-(void) pushRefComponentInContext:(GSWContext*)context
{
  NSLog(@"WARNING: %s is deprecated. Use _pushComponentInContext instead.", __PRETTY_FUNCTION__);
  [self _pushComponentInContext: context];
}



//--------------------------------------------------------------------

-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{

  [self _pushComponentInContext: aContext];
  
  [GSWContext_component(aContext) appendToResponse:aResponse
               inContext:aContext];

  [self _popComponentFromContext:aContext];
}


//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)aContext
{
    id <GSWActionResults, NSObject> element=nil;
    
    [self _pushComponentInContext:aContext];
    
    element  = (id <GSWActionResults, NSObject>) [GSWContext_component(aContext) invokeActionForRequest: request
                                                                                              inContext: aContext];
    [self _popComponentFromContext:aContext];
    
    return element;
    
}

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext
{
  //OK
  GSWComponent* component=nil;
  GSWComponent* componentPrev=nil;
  GSWDeclareDebugElementIDsCount(aContext);


  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);

  componentPrev=GSWContext_component(aContext);
  [self _pushComponentInContext:aContext];
  component=GSWContext_component(aContext);
  if (component)
    {
      [component takeValuesFromRequest:request
                 inContext:aContext];
      [self _popComponentFromContext:aContext];
    }
  else
    [aContext _setCurrentComponent:componentPrev];

  GSWStopElement(aContext);
  GSWAssertDebugElementIDsCount(aContext);

};
 
@end
