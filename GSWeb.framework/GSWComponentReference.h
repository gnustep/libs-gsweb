/** GSWComponentReference.h - <title>GSWeb: Class GSWComponentReference</title>

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

#ifndef _GSWComponentReference_h__
	#define _GSWComponentReference_h__

//====================================================================
@interface GSWComponentReference: GSWDynamicElement
{
  NSString* _name;
  NSMutableDictionary* _keyAssociations;
  GSWElement* _contentElement;
};

-(void)dealloc;
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations;

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template;
-(NSString*)description;

-(void)popRefComponentInContext:(GSWContext*)aContext;
-(void)pushRefComponentInContext:(GSWContext*)aContext;

-(void)appendToResponse:(GSWResponse*)aResponse
			  inContext:(GSWContext*)aContext;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext;

-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext; 
@end

#endif //_GSWComponentReference_h__
