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

#include "GSWDynamicGroup.h"

//====================================================================
@interface GSWHTMLDynamicElement: GSWDynamicGroup
{
  NSString            * _dynElementName;
  NSMutableDictionary * _nonURLAttributeAssociations;
  NSMutableDictionary * _urlAttributeAssociations;
  NSString            * _constantAttributesRepresentation;
  NSMutableDictionary * _associations;
  BOOL                  _finishedInitialization;
  GSWAssociation      * _secure;
}

+ (NSString*) _frameworkNameForAssociation: (GSWAssociation*)association 
                               inComponent: (GSWComponent *) component;

- (NSDictionary*) computeQueryDictionaryWithActionClassAssociation: (GSWAssociation*)actionClass
                                       directActionNameAssociation: (GSWAssociation*)directActionName
                                        queryDictionaryAssociation: (GSWAssociation*)queryDictionary
                                            otherQueryAssociations: (NSDictionary*)otherQueryAssociations 
                                                         inContext: (GSWContext*)context;

- (NSDictionary*) computeQueryDictionaryWithRequestHandlerPath: (NSString*) aRequestHandlerPath 
                                    queryDictionaryAssociation: (GSWAssociation*) queryDictionary
                                        otherQueryAssociations: (NSDictionary*) otherQueryAssociations 
                                                     inContext: (GSWContext*) context;

-(NSString*)computeActionStringWithActionClassAssociation:(GSWAssociation*)actionClass
                             directActionNameAssociation:(GSWAssociation*)directActionName
                                               inContext:(GSWContext*)context;

-(void) appendNonURLAttributesToResponse:(GSWResponse*) response
                               inContext:(GSWContext*) context;

-(void) appendURLAttributesToResponse:(GSWResponse*) response
                            inContext:(GSWContext*) context;
                                                         
-(void) appendConstantAttributesToResponse:(GSWResponse*) response
                                 inContext:(GSWContext*)aContext;

-(void) appendAttributesToResponse:(GSWResponse *) response
                            inContext:(GSWContext*) context;

-(void) _appendOpenTagToResponse:(GSWResponse *) response
                       inContext:(GSWContext*) context;

-(void) _appendCloseTagToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context;
                            
- (NSString*) constantAttributesRepresentation;

- (NSString*) elementName;

- (BOOL) secureInContext:(GSWContext*) context;

@end
#endif
