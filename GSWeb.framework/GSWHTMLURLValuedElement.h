/* GSWHTMLURLValuedElement.h - GSWeb: Class GSWHTMLURLValuedElement
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Apr 1999
   
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

#ifndef _GSWHTMLURLValuedElement_h__
	#define _GSWHTMLURLValuedElement_h__


@interface GSWHTMLURLValuedElement: GSWHTMLDynamicElement
{
  GSWAssociation* src;
  GSWAssociation* value;
  GSWAssociation* pageName;
//GSWeb Additions {
  NSDictionary* pageSetVarAssociations;
  GSWAssociation* pageSetVarAssociationsDynamic;
// }
  GSWAssociation* filename;
  GSWAssociation* framework;
  GSWAssociation* data;
  GSWAssociation* mimeType;
  GSWAssociation* key;
  GSWAssociation* actionClass;
  GSWAssociation* directActionName;
  GSWAssociation* queryDictionary;
  NSDictionary* otherQueryAssociations;
};

-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_;
-(void)dealloc;

-(NSString*)valueAttributeName;
-(NSString*)urlAttributeName;
-(NSString*)description;
@end

@interface GSWHTMLURLValuedElement (GSWHTMLURLValuedElementA)
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_; 
@end

@interface GSWHTMLURLValuedElement (GSWHTMLURLValuedElementB)
//NDFN
-(void)appendURLToResponse:(GSWResponse*)response_
				 inContext:(GSWContext*)context_;
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
									inContext:(GSWContext*)context_; 
-(void)_appendCGIActionURLToResponse:(GSWResponse*)response_
						   inContext:(GSWContext*)context_; 
-(id)computeActionStringInContext:(GSWContext*)context_; 
-(id)computeQueryDictionaryInContext:(GSWContext*)context_; 
-(NSString*)frameworkNameInContext:(GSWContext*)context_;
@end

#endif // _GSWHTMLURLValuedElement_h__
