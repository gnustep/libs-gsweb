/** GSWGenericContainer.m - <title>GSWeb: Class GSWGenericContainer</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

static Class GSWHTMLBareStringClass = Nil;

//====================================================================
@implementation GSWGenericContainer

+ (void) initialize
{
  if (self == [GSWGenericContainer class])
    {
      GSWHTMLBareStringClass = [GSWHTMLBareString class];
    };
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement
{
  if ((self=[super initWithName:aName
                   associations:associations
                   template:templateElement]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext
{
  //Call super and next children because it inherit from GSWGenericElement
  [super takeValuesFromRequest:aRequest
	 inContext:aContext];
  [self takeChildrenValuesFromRequest:aRequest
	inContext:aContext];
}

//--------------------------------------------------------------------
-(id <GSWActionResults>)invokeActionForRequest:(GSWRequest*)aRequest
				     inContext:(GSWContext*)aContext
{
  //Call super and next children because it inherit from GSWGenericElement
  id <GSWActionResults> actionResult = [super invokeActionForRequest:aRequest
					      inContext:aContext];
  if (actionResult == nil)
    {    
      actionResult = [self invokeChildrenActionForRequest:aRequest
			   inContext:aContext];
    }
  return actionResult;
}

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  //Call super and next children because it inherit from GSWGenericElement
  NSString* elementName = nil;
  [super appendToResponse:aResponse
	 inContext:aContext];

  //get elementName after super appendToResponse:inContext: because GSWGenericElement set elementName in it !
  elementName = [self elementName];

  [self appendChildrenToResponse:aResponse
	inContext:aContext];

  if (elementName != nil)
    {
      GSWResponse_appendContentCharacter(aResponse,'<');
      GSWResponse_appendContentCharacter(aResponse,'/');
      GSWResponse_appendContentString(aResponse,elementName);
      GSWResponse_appendContentCharacter(aResponse,'>');
    }
}

@end

