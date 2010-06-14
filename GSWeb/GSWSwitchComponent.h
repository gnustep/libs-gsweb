/** GSWSwitchComponent.h - <title>GSWeb: Class GSWSwitchComponent</title>
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

// $Id$

#ifndef _GSWSwitchComponent_h__
	#define _GSWSwitchComponent_h__

//====================================================================
@interface GSWSwitchComponent: GSWDynamicElement
{
  GSWAssociation* _componentName;
  NSDictionary* _componentAttributes;
  GSWElement* _template;
  NSMutableDictionary* _componentCache;
};

-(void)dealloc;
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement;
-(NSString*)description;

@end

@interface GSWSwitchComponent (GSWSwitchComponentA)
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext;

-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext; 
-(GSWElement*)_realComponentWithName:(NSString*)name
                           inContext:(GSWContext*)aContext;
-(NSString*)_elementNameInContext:(GSWContext*)aContext; 
@end


#endif //_GSWSwitchComponent_h__
