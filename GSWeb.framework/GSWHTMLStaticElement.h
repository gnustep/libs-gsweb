/* GSWHTMLStaticElement.h - GSWeb: Class GSWHTMLStaticElement
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Feb 1999
   
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

// $Id$

#ifndef _GSWHTMLStaticElement_h__
	#define _GSWHTMLStaticElement_h__


//====================================================================
@interface GSWHTMLStaticElement: GSWElement
{
  NSData* elementsMap;
  NSArray* htmlBareStrings;
  NSArray* dynamicChildren;
  NSString* elementName;
};

-(NSString*)elementName;
-(NSArray*)dynamicChildren;
-(NSArray*)htmlBareStrings;
-(NSData*)elementsMap;

-(id)_initWithElementsMap:(NSData*)_elementsMap
		  htmlBareStrings:(NSArray*)htmlBareStrings
		  dynamicChildren:(NSArray*)dynamicChildren;

-(id)		initWithName:(NSString*)elementName_
	 attributeDictionary:(NSDictionary*)_attributeDictionary
		 contentElements:(NSArray*)elements_;

-(id)		initWithName:(NSString*)elementName_
		 attributeString:(NSString*)_attributeString
		 contentElements:(NSArray*)elements_;

-(void)dealloc;

-(void)_setEndOfHTMLTag:(unsigned int)_unknown;

-(NSString*)description;

@end

//====================================================================
@interface GSWHTMLStaticElement (GSWHTMLStaticElementA)
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
	  elementsFromIndex:(unsigned int)_fromIndex
				toIndex:(unsigned int)_toIndex;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_;

-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_; 

@end

//====================================================================
@interface GSWHTMLStaticElement (GSWHTMLStaticElementB)
-(BOOL)compactHTMLTags;
-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping;
-(BOOL)appendStringAtLeft:(id)_unkwnon
			  withMapping:(char*)_mapping;
-(BOOL)canBeFlattenedAtInitialization;

@end

//====================================================================
@interface GSWHTMLStaticElement (GSWHTMLStaticElementC)
+(BOOL)charactersNeedingQuotes;
+(void)addURLAttribute:(id)_attribute
	   forElementNamed:(NSString*)_name;
+(id)urlsForElementNamed:(NSString*)_name;
@end

//====================================================================
@interface GSWHTMLStaticElement (GSWHTMLStaticElementD)
+(NSDictionary*)attributeDictionaryForString:(NSString*)_string;
+(NSString*)stringForAttributeDictionary:(NSDictionary*)_attributeDictionary;
+(GSWElement*)elementWithName:(NSString*)_name
			 attributeString:(NSString*)_attributeString
			 contentElements:(NSArray*)elements_;

@end

//====================================================================
@interface GSWHTMLStaticElement (GSWHTMLStaticElementE)
+(GSWElement*)elementWithName:(NSString*)_name
		 attributeDictionary:(NSDictionary*)_attributeDictionary
			 contentElements:(NSArray*)elements_;

+(Class)_elementClassForName:(NSString*)_name;
+(void)setElementClass:(Class)_class
			   forName:(NSString*)_name;
+(GSWElement*)_theEmptyElement;

@end 

#endif //_GSWHTMLStaticElement_h__
