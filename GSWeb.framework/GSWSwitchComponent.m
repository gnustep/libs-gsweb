/* GSWSwitchComponent.m - GSWeb: Class GSWSwitchComponent
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

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWSwitchComponent

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
		 template:(GSWElement*)templateElement_
{
  LOGObjectFnStartC("GSWSwitchComponent");
  if ((self=[super initWithName:name_
				   associations:associations_
				   template:nil]))
	{
	  NSMutableDictionary* _associations=[NSMutableDictionary dictionaryWithDictionary:associations_];
	  [_associations removeObjectForKey:GSWComponentName__Key];

	  componentName = [[associations_ objectForKey:GSWComponentName__Key
									  withDefaultObject:[componentName autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWSwitchComponent: componentName=%@",componentName);

	  ASSIGN(componentAttributes,[NSDictionary dictionaryWithDictionary:_associations]);
	  NSDebugMLLog(@"gswdync",@"GSWSwitchComponent: componentAttributes=%@",componentAttributes);

	  ASSIGN(template,templateElement_);
	  NSDebugMLLog(@"gswdync",@"GSWSwitchComponent: template=%@",template);

	  componentCache=[NSMutableDictionary new];
	};
  LOGObjectFnStopC("GSWSwitchComponent");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(componentName);
  DESTROY(componentAttributes);
  DESTROY(template);
  DESTROY(componentCache);
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
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  GSWElement* _element=nil;
  NSString* _elementNameInContext=nil;
  LOGObjectFnStartC("GSWSwitchComponent");
  _elementNameInContext=[self _elementNameInContext:context_];
  [context_ appendElementIDComponent:_elementNameInContext];
  _element=[self _realComponentWithName:_elementNameInContext
				 inContext:context_];
  [_element appendToResponse:response_
			inContext:context_];
  [context_ deleteLastElementIDComponent];
  LOGObjectFnStopC("GSWSwitchComponent");
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  GSWElement* _resultElement=nil;
  GSWElement* _element=nil;
  NSString* _elementNameInContext=nil;
  LOGObjectFnStartC("GSWSwitchComponent");
  _elementNameInContext=[self _elementNameInContext:context_];
  [context_ appendElementIDComponent:_elementNameInContext];
  _element=[self _realComponentWithName:_elementNameInContext
				 inContext:context_];
  _resultElement=[_element invokeActionForRequest:request_
						   inContext:context_];
  [context_ deleteLastElementIDComponent];
  LOGObjectFnStopC("GSWSwitchComponent");
  return _resultElement;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  GSWElement* _element=nil;
  NSString* _elementNameInContext=nil;
  LOGObjectFnStartC("GSWSwitchComponent");
  _elementNameInContext=[self _elementNameInContext:context_];
  [context_ appendElementIDComponent:_elementNameInContext];
  _element=[self _realComponentWithName:_elementNameInContext
				 inContext:context_];
  [_element takeValuesFromRequest:request_
			inContext:context_];
  [context_ deleteLastElementIDComponent];
  LOGObjectFnStopC("GSWSwitchComponent");
};

//-------------------------------------------------------------------- 
-(GSWElement*)_realComponentWithName:(NSString*)name_
						   inContext:(GSWContext*)context_
{
  GSWElement* _element=nil;
  NSArray* _languages=nil;
  LOGObjectFnStartC("GSWSwitchComponent");
  if (!name_)
	{
	  ExceptionRaise0(@"GSWSwitchComponent",@"ComponentName is null !");
	}
  else
	{
	  _element=[componentCache objectForKey:name_];
	  if (!_element)
		{
		  _languages=[context_ languages];
		  _element=[GSWApp dynamicElementWithName:name_
						   associations:componentAttributes
						   template:template
						   languages:_languages];
		  if (_element)
			[componentCache setObject:_element
							forKey:name_];
		  else
			{
			  ExceptionRaise(@"GSWSwitchComponent: Creation failed for element named:%@",
							 name_);
			};
		};
	};
  LOGObjectFnStopC("GSWSwitchComponent");
  return _element;
};

//-------------------------------------------------------------------- 
-(NSString*)_elementNameInContext:(GSWContext*)context_
{
  GSWComponent* _component=nil;
  NSString* _componentNameValue=nil;
  LOGObjectFnStartC("GSWSwitchComponent");
  _component=[context_ component];
  _componentNameValue=[componentName valueInComponent:_component];
  LOGObjectFnStopC("GSWSwitchComponent");
  return _componentNameValue;
};

@end

