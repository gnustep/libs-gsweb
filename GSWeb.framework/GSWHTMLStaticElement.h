/** GSWHTMLStaticElement.h - <title>GSWeb: Class GSWHTMLStaticElement</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
   
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

#ifndef _GSWHTMLStaticElement_h__
	#define _GSWHTMLStaticElement_h__


//====================================================================
@interface GSWHTMLStaticElement: GSWElement
{
  NSData* _elementsMap;
  NSArray* _htmlBareStrings;
  NSArray* _dynamicChildren;
  NSString* _elementName;
};

-(NSString*)elementName;
-(NSArray*)dynamicChildren;
-(NSArray*)htmlBareStrings;
-(NSData*)elementsMap;

-(id)_initWithElementsMap:(NSData*)_elementsMap
          htmlBareStrings:(NSArray*)htmlBareStrings
          dynamicChildren:(NSArray*)dynamicChildren;

-(id)		initWithName:(NSString*)elementName
	 attributeDictionary:(NSDictionary*)attributeDictionary
             contentElements:(NSArray*)elements;

-(id)		initWithName:(NSString*)elementName
		 attributeString:(NSString*)attributeString
		 contentElements:(NSArray*)elements;

-(void)dealloc;

-(void)_setEndOfHTMLTag:(unsigned int)unknown;

-(NSString*)description;

@end

//====================================================================
@interface GSWHTMLStaticElement (GSWHTMLStaticElementA)
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context;

-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
      elementsFromIndex:(unsigned int)fromIndex
                toIndex:(unsigned int)toIndex;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context;

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context; 

@end

//====================================================================
@interface GSWHTMLStaticElement (GSWHTMLStaticElementB)
-(BOOL)compactHTMLTags;
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping;
-(BOOL)appendStringAtLeft:(id)unkwnon
              withMapping:(char*)mapping;
-(BOOL)canBeFlattenedAtInitialization;

@end

//====================================================================
@interface GSWHTMLStaticElement (GSWHTMLStaticElementC)
+(BOOL)charactersNeedingQuotes;
+(void)addURLAttribute:(id)attribute
	   forElementNamed:(NSString*)name;
+(id)urlsForElementNamed:(NSString*)name;
@end

//====================================================================
@interface GSWHTMLStaticElement (GSWHTMLStaticElementD)
+(NSDictionary*)attributeDictionaryForString:(NSString*)string;
+(NSString*)stringForAttributeDictionary:(NSDictionary*)attributeDictionary;
+(GSWElement*)elementWithName:(NSString*)name
              attributeString:(NSString*)attributeString
              contentElements:(NSArray*)elements;

@end

//====================================================================
@interface GSWHTMLStaticElement (GSWHTMLStaticElementE)
+(GSWElement*)elementWithName:(NSString*)name
          attributeDictionary:(NSDictionary*)attributeDictionary
              contentElements:(NSArray*)elements;

+(Class)_elementClassForName:(NSString*)name;
+(void)setElementClass:(Class)class
               forName:(NSString*)name;
+(GSWElement*)_theEmptyElement;

@end 

#endif //_GSWHTMLStaticElement_h__
