/* GSWSubmitButton.m - GSWeb: Class GSWSubmitButton
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
@implementation GSWSubmitButton

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)_elements
{
  NSMutableDictionary* _associations=[NSMutableDictionary dictionaryWithDictionary:associations_];
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"name_=%@ associations_:%@ _elements=%@",name_,associations_,_elements);
  [_associations setObject:[GSWAssociation associationWithValue:@"submit"]
				 forKey:@"type"];
  [_associations removeObjectForKey:action__Key];
  [_associations removeObjectForKey:actionClass__Key];
  [_associations removeObjectForKey:directActionName];

  if (![_associations objectForKey:value__Key])
	[_associations setObject:[GSWAssociation associationWithValue:@"submit"]
				   forKey:value__Key];

  if ((self=[super initWithName:name_
				   associations:_associations
				   contentElements:nil]))
	{
	  action = [[associations_ objectForKey:action__Key
									  withDefaultObject:[action autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWSumbitButton: action=%@",action);
	  actionClass = [[associations_ objectForKey:actionClass__Key
									  withDefaultObject:[actionClass autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWSumbitButton: actionClass=%@",actionClass);
	  directActionName = [[associations_ objectForKey:directActionName__Key
									  withDefaultObject:[directActionName autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWSumbitButton: directActionName=%@",directActionName);
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(action);
  DESTROY(actionClass);
  DESTROY(directActionName);
  [super dealloc];
};

@end

//====================================================================
@implementation GSWSubmitButton (GSWSubmitButtonA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
  LOGObjectFnStart();
  [super appendToResponse:response_
		 inContext:context_];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  //OK
  GSWElement* _element=nil;
  BOOL _disabled=NO;
  LOGObjectFnStart();
  _disabled=[self disabledInContext:context_];
  if (!_disabled)
	{
	  BOOL _wasFormSubmitted=[context_ _wasFormSubmitted];
	  if (_wasFormSubmitted)
		{
		  BOOL _invoked=NO;
		  GSWComponent* _component=[context_ component];
		  BOOL _isMultipleSubmitForm=[context_ _isMultipleSubmitForm];
		  if (_isMultipleSubmitForm)
			{
			  NSString* _nameInContext=[self nameInContext:context_];
			  NSString* _formValue=[request_ formValueForKey:_nameInContext];
			  NSDebugMLLog(@"gswdync",@"_formValue=%@",_formValue);
			  if (_formValue)
				_invoked=YES;
			}
		  else
			_invoked=YES;
		  if (_invoked)
			{
			  id _actionValue=nil;
			  NSDebugMLLog0(@"gswdync",@"Invoked Object Found !!");
			  [context_ _setActionInvoked:1];
			  _actionValue=[action valueInComponent:_component];
			  if (_actionValue)
				  _element=_actionValue;
			  if (!_element)
				_element=[context_ page];
			};
		};
	};
  LOGObjectFnStop();
  return _element;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //Does Nothing ?
};
 
//--------------------------------------------------------------------
-(void)appendNameToResponse:(GSWResponse*)_response
				   inContext:(GSWContext*)_context
{
  //OK
  //Here we call parent (GSWInput) method instead of doing it by ourself (as GSW)
  [super appendNameToResponse:_response
		 inContext:_context];
};

//--------------------------------------------------------------------
-(void)_appendActionClassAndNameToResponse:(GSWResponse*)_response
								 inContext:(GSWContext*)_context
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

