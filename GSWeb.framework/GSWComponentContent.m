/* GSWComponentContent.m - GSWeb: Class GSWComponentContent
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
@implementation GSWComponentContent

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _component=nil;
  GSWComponent* _parent=nil;
  GSWElement* _childTemplate=nil;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  _component=[context_ component];
  _childTemplate=[_component _childTemplate];
  _parent=[_component parent];
  [context_ _setCurrentComponent:_parent];
  [_childTemplate appendToResponse:response_
				  inContext:context_];
  [context_ _setCurrentComponent:_component];
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWComponentContent appendToResponse: bad elementID");
#endif
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  //OK
  GSWElement* _element=nil;
  GSWComponent* _component=nil;
  GSWComponent* _parent=nil;
  GSWElement* _childTemplate=nil;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  _component=[context_ component];
  NSDebugMLLog(@"gswdync",@"_component=%@",_component);
  _childTemplate=[_component _childTemplate];
  NSDebugMLLog(@"gswdync",@"_childTemplate=%@",_childTemplate);
  _parent=[_component parent];
  NSDebugMLLog(@"gswdync",@"_parent=%@",_parent);
  [context_ _setCurrentComponent:_parent];
  _element=[_childTemplate invokeActionForRequest:request_
						   inContext:context_];
  [context_ _setCurrentComponent:_component];
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWComponentContent invokeActionForRequest: bad elementID");
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
  GSWComponent* _parent=nil;
  GSWElement* _childTemplate=nil;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  _component=[context_ component];
  _childTemplate=[_component _childTemplate];
  _parent=[_component parent];
  [context_ _setCurrentComponent:_parent];
  [_childTemplate takeValuesFromRequest:request_
				  inContext:context_];
  [context_ _setCurrentComponent:_component];
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWComponentContent takeValuesFromRequest: bad elementID");
#endif
  LOGObjectFnStop();
};

@end


