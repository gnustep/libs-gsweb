/** GSWGenericElement.h - <title>GSWeb: Class GSWGenericElement</title>
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

#ifndef _GSWGenericElement_h__
	#define _GSWGenericElement_h__

//OK
//====================================================================
@interface GSWGenericElement: GSWDynamicElement
{
  GSWAssociation* _elementName;
  GSWAssociation* _name;
  GSWAssociation* _omitTags;
  GSWAssociation* _formValue;
  GSWAssociation* _formValues;
  GSWAssociation* _invokeAction;
  GSWAssociation* _elementID;
  GSWAssociation* _otherTagString;
  NSDictionary* _otherAssociations;
  BOOL _hasFormValues;
};

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement;

-(void)dealloc;
-(NSString*)description;

-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context;

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context; 

-(id)_elementNameAppendToResponse:(GSWResponse*)response
                        inContext:(GSWContext*)context;

-(void)_appendTagWithName:(NSString*)name
               toResponse:(GSWResponse*)response
                inContext:(GSWContext*)context;

-(void)_appendOtherAttributesToResponse:(GSWResponse*)response
                              inContext:(GSWContext*)context;

-(NSString*)_elementNameInContext:(GSWContext*)context;
@end

#endif //_GSWGenericElement_h__
