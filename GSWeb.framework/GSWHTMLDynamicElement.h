/* GSWHTMLDynamicElement.h - GSWeb: Class GSWHTMLDynamicElement
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

#ifndef _GSWHTMLDynamicElement_h__
	#define _GSWHTMLDynamicElement_h__


//====================================================================
@interface GSWHTMLDynamicElement: GSWDynamicElement
{
  NSData* elementsMap;
  NSArray* htmlBareStrings;
  NSArray* dynamicChildren;
  NSArray* attributeAssociations;
};
-(NSString*)elementName;
-(NSArray*)dynamicChildren;
-(NSArray*)htmlBareStrings;
-(NSData*)elementsMap;
-(NSArray*)attributeAssociations;

-(id)_initWithElementsMap:(NSData*)_elementsMap
		  htmlBareStrings:(NSArray*)_htmlBareStrings
		  dynamicChildren:(NSArray*)_dynamicChildren
	attributeAssociations:(NSArray*)_attributeAssociations;

-(id)		initWithName:(NSString*)elementName_
			associations:(NSDictionary*)associations_
		 contentElements:(NSArray*)elements_;

-(id)		initWithName:(NSString*)elementName_
   attributeAssociations:(NSDictionary*)attributeAssociations_
		 contentElements:(NSArray*)elements_;

-(id)		initWithName:(NSString*)elementName_
			associations:(NSDictionary*)associations_
				template:(GSWElement*)templateElement_;

-(void)dealloc;

-(void)_setEndOfHTMLTag:(unsigned int)_unknown;

-(NSString*)description;
-(void)setHtmlBareStrings:(NSArray*)_htmlBareStrings;

@end

//====================================================================
@interface GSWHTMLDynamicElement (GSWHTMLDynamicElementA)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
									inContext:(GSWContext*)context_;
-(unsigned int)GSWebObjectsAssociationsCount;
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
@interface GSWHTMLDynamicElement (GSWHTMLDynamicElementB)
-(BOOL)compactHTMLTags;
-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping;
-(BOOL)appendStringAtLeft:(id)_unkwnon
			  withMapping:(char*)_mapping;
-(BOOL)canBeFlattenedAtInitialization;
@end

//====================================================================
@interface GSWHTMLDynamicElement (GSWHTMLDynamicElementC)
+(void)setDynamicElementCompaction:(BOOL)_flag;
+(BOOL)escapeHTML;
+(BOOL)hasGSWebObjectsAssociations;
@end

#endif
