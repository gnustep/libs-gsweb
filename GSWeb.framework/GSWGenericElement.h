/* GSWGenericElement.h - GSWeb: Class GSWGenericElement
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

// $Id$

#ifndef _GSWGenericElement_h__
	#define _GSWGenericElement_h__

//OK
//====================================================================
@interface GSWGenericElement: GSWDynamicElement
{
  GSWAssociation* elementName;
  GSWAssociation* name;
  GSWAssociation* omitTags;
  GSWAssociation* formValue;
  GSWAssociation* formValues;
  GSWAssociation* invokeAction;
  GSWAssociation* elementId;
  GSWAssociation* otherTagString;
  NSDictionary* otherAssociations;
  BOOL hasFormValues;
};

-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
		 template:(GSWElement*)templateElement_;
-(void)dealloc;
-(NSString*)description;

-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_;

-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_; 

-(id)_elementNameAppenedToResponse:(GSWResponse*)response_
						 inContext:(GSWContext*)context_;
-(void)_appendTagWithName:(NSString*)name_
			   toResponse:(GSWResponse*)response_
				inContext:(GSWContext*)context_;
-(void)_appendOtherAttributesToResponse:(GSWResponse*)response_
							  inContext:(GSWContext*)context_;
-(NSString*)_elementNameInContext:(GSWContext*)context_;
@end

#endif //_GSWGenericElement_h__
