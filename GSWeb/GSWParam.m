/** GSWParam.m - <title>GSWeb: Class GSWParam</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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
#include <GNUstepBase/NSObject+GNUstepBase.h>

//====================================================================
@implementation GSWParam

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)inAssociations
  contentElements:(NSMutableArray*)elements
           target:(id)target
              key:(NSString*)key
treatNilValueAsGSWNull:(BOOL)treatNilValueAsGSWNull
{
  NSMutableDictionary* associations=nil;

  _treatNilValueAsGSWNull = treatNilValueAsGSWNull;
  ASSIGN(_target,target);
  ASSIGN(_targetKey,key);

  associations=[NSMutableDictionary dictionaryWithDictionary:inAssociations];

  _action = [[inAssociations objectForKey:action__Key
                             withDefaultObject:[_action autorelease]] retain];

  _value = [[inAssociations objectForKey:value__Key
                          withDefaultObject:[_value autorelease]] retain];

  [associations removeObjectForKey:action__Key];
  [associations removeObjectForKey:value__Key];

  if ((self=[super initWithName:aName
                   associations:associations
                   contentElements:elements]))
    {
      if (!_target)
        {
          if (_value)
            {
              if (_action)
                {
                  ExceptionRaise(@"GSWParam",@"You can't specify 'value' and 'action' together. componentAssociations:%@",
                                 inAssociations);
                };
            }
          else if (!_action)
            {
              ExceptionRaise(@"GSWParam",@"You have to specify 'value' or 'action'. componentAssociations:%@",
                             inAssociations);
            };
        };
    };
  return self;
};

//--------------------------------------------------------------------

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSMutableArray*)elements
{
  return [self initWithName:aName
               associations:associations
               contentElements:elements
               target:nil
               key:nil
               treatNilValueAsGSWNull:NO];
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_action);
  DESTROY(_value);
  DESTROY(_target);
  DESTROY(_targetKey);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------

-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext
{
  GSWElement* element=nil;


  if (_action
      && [GSWContext_elementID(aContext) isEqualToString:GSWContext_senderID(aContext)])
    {
      GSWComponent* component=GSWContext_component(aContext);

      element = [_action valueInComponent:component];

      if (!element)
        element = [aContext page];
    };


  return element;
};


//--------------------------------------------------------------------
-(id)valueInComponent:(GSWComponent*)component
{
  id value=nil;


  if (_target)
    value=[_target valueForKey:_targetKey];
  else if (_value)
    value=[_value valueInComponent:component];


  return value;
};


//--------------------------------------------------------------------
+(BOOL)escapeHTML
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
+(BOOL)hasGSWebObjectsAssociations
{

  return YES;
};

@end
