/* GSWComponentReference.m - GSWeb: Class GSWComponentReference
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
   This file is part of the GNUstep Web Library.
   
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
*/

static char rcsId[] = "$Id$";

#include <gsweb/GSWeb.framework/GSWeb.h>

//====================================================================
@implementation GSWComponentReference

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
{
  LOGObjectFnStart();
  //OK
  NSDebugMLLog(@"gswdync",@"name:%@",name);
  NSDebugMLLog(@"gswdync",@"associations_:%@",associations_);
  if ((self==[super initWithName:name_
					associations:associations_
					template:nil]))
	{
	  ASSIGN(name,name_);
	  if (associations_ && [associations_ count])
		{
		  NSMutableArray* tmpArray=[NSMutableArray array];
		  int i=0;
		  ASSIGN(associationsKeys,[associations_ allKeys]);
		  for(i=0;i<[associationsKeys count];i++)
			{
			  [tmpArray addObject:[associations_ objectForKey:[associationsKeys objectAtIndex:i]]];
			};
		  ASSIGN(associations,[NSArray arrayWithArray:tmpArray]);
		};
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
		 template:(GSWElement*)_template
{
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"name:%@",name);
  NSDebugMLLog(@"gswdync",@"associations_:%@",associations_);
  NSDebugMLLog(@"gswdync",@"_template:%@",_template);
  if ((self==[self initWithName:name_
				   associations:associations_]))
	{
	  ASSIGN(contentElement,_template);
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWComponentReference");
  GSWLogC("Destroy name");
  DESTROY(name);
  GSWLogC("Destroy associationsKeys");
  DESTROY(associationsKeys);
  GSWLogC("Destroy associations");
  DESTROY(associations);
  GSWLogC("Destroy contentElement");
  DESTROY(contentElement);
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
				   name,
				   associationsKeys,
				   associations,
				   contentElement];
};

@end

//====================================================================
@implementation GSWComponentReference (GSWComponentReferenceA)
-(void)popRefComponentInContext:(GSWContext*)_context
{
  //OK
  GSWComponent* _subComponent=nil;
  GSWComponent* _component=nil;
  LOGObjectFnStart();
  _subComponent=[_context component];
  _component=[_subComponent parent];
  [_subComponent synchronizeComponentToParent];
  [_context _setCurrentComponent:_component];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)pushRefComponentInContext:(GSWContext*)_context
{
  //OK
  GSWComponent* _subComponent=nil;
  GSWComponentDefinition* _subComponentDefinition=nil;
  GSWComponent* _component=nil;
  NSString* _elementID=nil;
  LOGObjectFnStart();
  _component=[_context component];
  _elementID=[_context elementID];
  NSDebugMLLog(@"gswdync",@"_elementID:%@",_elementID);
  _subComponent=[_component subComponentForElementID:_elementID];
  NSDebugMLLog(@"gswdync",@"_subComponent:%@",_subComponent);
  if (!_subComponent)
	{
	  NSArray* _languages=[_context languages];
	  NSDebugMLLog(@"gswdync",@"name:%@",name);
	  NSDebugMLLog(@"gswdync",@"pushRefComponentInContext comporef=%p parent=%p",
					 (void*)self,
			 (void*)_component);
	  _subComponentDefinition=[GSWApp componentDefinitionWithName:name
									  languages:_languages];
	  NSDebugMLLog(@"gswdync",@"_subComponentDefinition=%@",_subComponentDefinition);
	  if (_subComponentDefinition)
		{
		  _subComponent=[_subComponentDefinition componentInstanceInContext:_context];
		  NSDebugMLLog(@"gswdync",@"_subComponent:%@",_subComponent);
		  if (_subComponent)
			{
			  NSDebugMLLog(@"gswdync",@"SETPARENT comporef=%p parent=%p component=%p",
					 (void*)self,
					 (void*)_component,
					 (void*)_subComponent);
			  [_subComponent setParent:_component
							 associationsKeys:associationsKeys
							 associations:associations
							 template:contentElement];
			}
		  else
			{
			  ExceptionRaise(@"GSWComponentReference: subcomponent instance creation failed in '@'",name);
			};
		}
	  else
		{
		  ExceptionRaise(@"GSWComponentReference: can't find subcomponent definition in '@'",name);
		};
	  if (_subComponent)
		{
		  [_component setSubComponent:_subComponent
					  forElementID:_elementID];
		  [_subComponent awakeInContext:_context];
		};
	};
  if (_subComponent)
	{
	  [_subComponent synchronizeParentToComponent];
	};
  [_context _setCurrentComponent:_subComponent];

  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWComponentReference (GSWRequestHandling)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _component=nil;
  GSWComponent* _componentPrev=nil;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  _componentPrev=[context_ component];
  [self pushRefComponentInContext:context_];
  if ([context_ component])
	{
	  _component=[context_ component];
	  [_component appendToResponse:response_
				  inContext:context_];
	  [self popRefComponentInContext:context_];
	}
  else
	[context_ _setCurrentComponent:_componentPrev];
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],
		   @"GSWComponentReference appendToResponse: bad elementID");
#endif
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  GSWElement* _element=nil;
  GSWComponent* _component=nil;
  GSWComponent* _componentPrev=nil;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  _componentPrev=[context_ component];
  [self pushRefComponentInContext:context_];
  if ([context_ component])
	{
	  NSString* _senderID=nil;
	  NSString* _elementID=nil;
	  _senderID=[context_ senderID];
	  _elementID=[context_ elementID];
	  NSDebugMLLog(@"gswdync",@"_senderID=%@",_senderID);
	  NSDebugMLLog(@"gswdync",@"_elementID=%@",_elementID);
	  if ([_senderID hasPrefix:_elementID]) //Avoid trying to find action if we are not the good component
		{
		  _component=[context_ component];
		  _element=[_component invokeActionForRequest:request_
							   inContext:context_];
		};
	  [self popRefComponentInContext:context_];
	}
  else
	[context_ _setCurrentComponent:_componentPrev];
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWComponentReference invokeActionForRequest: bad elementID");
#endif
  LOGObjectFnStop();
  return _element;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _component=nil;
  GSWComponent* _componentPrev=nil;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  _componentPrev=[context_ component];
  [self pushRefComponentInContext:context_];
  if ([context_ component])
	{
	  _component=[context_ component];
	  [_component takeValuesFromRequest:request_
				  inContext:context_];
	  [self popRefComponentInContext:context_];
	}
  else
	[context_ _setCurrentComponent:_componentPrev];
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWComponentReference takeValuesFromRequest: bad elementID");
#endif
  LOGObjectFnStop();
};
 
@end
