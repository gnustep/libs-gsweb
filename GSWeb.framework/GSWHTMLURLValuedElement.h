/** GSWHTMLURLValuedElement.m - <title>GSWeb: Class GSWHTMLURLValuedElement</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Apr 1999
   
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

#ifndef _GSWHTMLURLValuedElement_h__
	#define _GSWHTMLURLValuedElement_h__


@interface GSWHTMLURLValuedElement: GSWHTMLDynamicElement
{
  GSWAssociation* _src;
  GSWAssociation* _value;
  GSWAssociation* _pageName;
//GSWeb Additions {
  NSDictionary* _pageSetVarAssociations;
  GSWAssociation* _pageSetVarAssociationsDynamic;
  GSWAssociation* _cidStore;
  GSWAssociation* _cidKey;
  NSDictionary* _otherPathQueryAssociations;
// }
  GSWAssociation* _filename;
  GSWAssociation* _framework;
  GSWAssociation* _data;
  GSWAssociation* _mimeType;
  GSWAssociation* _key;
  GSWAssociation* _actionClass;
  GSWAssociation* _directActionName;
  GSWAssociation* _queryDictionary;
  NSDictionary* _otherQueryAssociations;
};

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements;

-(NSString*)valueAttributeName;
-(NSString*)urlAttributeName;
@end

@interface GSWHTMLURLValuedElement (GSWHTMLURLValuedElementA)
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext; 
@end

@interface GSWHTMLURLValuedElement (GSWHTMLURLValuedElementB)
//NDFN
-(void)appendURLToResponse:(GSWResponse*)aResponse
                 inContext:(GSWContext*)aContext;
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext; 
-(void)_appendCGIActionURLToResponse:(GSWResponse*)aResponse
                           inContext:(GSWContext*)aContext; 
-(NSString*)computeActionStringInContext:(GSWContext*)aContext; 
-(NSDictionary*)computeQueryDictionaryInContext:(GSWContext*)aContext; 
-(NSString*)frameworkNameInContext:(GSWContext*)aContext;
@end

#endif // _GSWHTMLURLValuedElement_h__
