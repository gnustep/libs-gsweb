/** GSWHTMLDynamicElement.h - <title>GSWeb: Class GSWHTMLDynamicElement</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
   
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

#ifndef _GSWHTMLDynamicElement_h__
	#define _GSWHTMLDynamicElement_h__


//====================================================================
@interface GSWHTMLDynamicElement: GSWDynamicElement
{
  NSData* _elementsMap;
  NSArray* _htmlBareStrings;
  NSArray* _dynamicChildren;
  NSArray* _attributeAssociations;
};
-(NSString*)elementName;
-(NSArray*)dynamicChildren;
-(NSArray*)htmlBareStrings;
-(NSData*)elementsMap;
-(NSArray*)attributeAssociations;

-(id)_initWithElementsMap:(NSData*)elementsMap
          htmlBareStrings:(NSArray*)htmlBareStrings
          dynamicChildren:(NSArray*)dynamicChildren
    attributeAssociations:(NSArray*)attributeAssociations;

-(id)initWithName:(NSString*)elementName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements;

-(id)initWithName:(NSString*)elementName
attributeAssociations:(NSDictionary*)attributeAssociations
  contentElements:(NSArray*)elements;

-(id)initWithName:(NSString*)elementName
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement;

-(void)dealloc;

-(void)_setEndOfHTMLTag:(unsigned int)unknown;

-(NSString*)description;
-(void)setHtmlBareStrings:(NSArray*)htmlBareStrings;

@end

//====================================================================
@interface GSWHTMLDynamicElement (GSWHTMLDynamicElementA)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext;
-(unsigned int)GSWebObjectsAssociationsCount;
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext;
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
      elementsFromIndex:(unsigned int)fromIndex
                toIndex:(unsigned int)toIndex;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext;

-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext; 
@end

//====================================================================
@interface GSWHTMLDynamicElement (GSWHTMLDynamicElementB)
-(BOOL)compactHTMLTags;
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping;
-(BOOL)appendStringAtLeft:(id)unkwnon
              withMapping:(char*)mapping;
-(BOOL)canBeFlattenedAtInitialization;
@end

//====================================================================
@interface GSWHTMLDynamicElement (GSWHTMLDynamicElementC)
+(void)setDynamicElementCompaction:(BOOL)flag;
+(BOOL)escapeHTML;
+(BOOL)hasGSWebObjectsAssociations;
@end

#endif
