/** GSWTemporaryElement.h - <title>GSWeb: Class GSWRequest</title>

   Copyright (C) 2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 2004
   
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

// $Id$

#ifndef _GSWTemporaryElement_h__
	#define _GSWTemporaryElement_h__

//====================================================================
/** Temporary element which will be converted to a dynamic element **/
@interface GSWTemporaryElement: GSWElement
{
  NSDictionary* 	_properties;	/** Tag properties **/
  GSWTemporaryElement* 	_parent;	/** Parent tag (not retained) **/
  NSMutableArray* 	_children;	/** Children **/
  NSString*		_templateInfo;	/** Parser/Template information (tag position,....) **/
};

+(GSWTemporaryElement*)temporaryElement;

+(GSWTemporaryElement*)temporaryElementOfType:(GSWHTMLRawParserTagType)tagType
                               withProperties:(NSDictionary*)tagProperties
                                 templateInfo:(NSString*)templateInfo
                                       parent:(GSWTemporaryElement*)parent;

-(id)initWithType:(GSWHTMLRawParserTagType)tagType
   withProperties:(NSDictionary*)properties
     templateInfo:(NSString*)templateInfo
           parent:(GSWTemporaryElement*)parent;


/** adds element to children **/
-(void)addChildElement:(GSWElement*)element;


/** Returns parent element **/
-(GSWTemporaryElement*)parentElement;


/** Returns template information **/
-(NSString*)templateInfo;


/** Create a GSWElement representing child elements tree
**/
-(GSWElement*)template;


/** Return Element Name, taken from properties
nil if none is found
**/
-(NSString*)name;


/** Returns real dynamic element usinf declarations to find element type 
Raise an exception if element name is not found or if no declaration is 
found for that element
**/
-(GSWElement*)dynamicElementWithDeclarations:(NSDictionary*)declarations
                                   languages:(NSArray*)languages;


/** Returns real dynamic element using declaration
May raise exception if element can't be created
**/
-(GSWElement*)_elementWithDeclaration:(GSWDeclaration*)declaration
                                 name:(NSString*)name
                           properties:(NSDictionary*)properties
                             template:(GSWElement*)template
                            languages:(NSArray*)languages;

@end

#endif //_GSWTemporaryElement_h__
