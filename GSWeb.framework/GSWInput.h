/** GSWInput.h - <title>GSWeb: Class GSWInput</title>

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

#ifndef _GSWInput_h__
	#define _GSWInput_h__


//====================================================================
@interface GSWInput: GSWHTMLDynamicElement
{
  GSWAssociation* _disabled;
//GSWeb Additions {
  GSWAssociation* _enabled;
//}
  GSWAssociation* _name;
  GSWAssociation* _value;
//GSWeb Additions {
  GSWAssociation* _handleValidationException;
// }
//GSWeb Additions {
  GSWAssociation* _tcEscapeHTML;
// }
};

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements;
-(void)dealloc;
-(NSString*)elementName;

@end

//====================================================================
@interface GSWInput (GSWInputA)

/** Return the name for html output. 
If no name is binded, it return the context id **/
-(NSString*)nameInContext:(GSWContext*)context;

//--------------------------------------------------------------------
/** return the value used in appendValueToResponse:inContext: **/
-(id)valueInContext:(GSWContext*)context;

/** Return YES if element is disabled, NO otherwise, 
depending on disabled/enabled binding
**/
-(BOOL)disabledInContext:(GSWContext*)context;
@end

//====================================================================
@interface GSWInput (GSWInputB)
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context; 

@end

//====================================================================
@interface GSWInput (GSWInputC)
/** Append the following elements to response:
    tag
    name (by calling -appendNameToResponse:inContext:)
    value (by calling -appendValueToResponse:inContext:)
    and others specified tag properties
**/
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response
                                      inContext:(GSWContext*)context;

/** Append value property to response. 
(Called by -appendGSWebObjectsAssociationsToResponse:inContext:)
**/
-(void)appendValueToResponse:(GSWResponse*)response
                   inContext:(GSWContext*)context;

/** Append name property to response.
name come from -nameInContext:
*/
-(void)appendNameToResponse:(GSWResponse*)response
                  inContext:(GSWContext*)context;

@end

//====================================================================
@interface GSWInput (GSWInputD)
+(BOOL)hasGSWebObjectsAssociations;
@end

//====================================================================
@interface GSWInput (GSWInputE)

#if !GSWEB_STRICT
-(void)handleValidationException:(NSException*)exception
                       inContext:(GSWContext*)context;
#endif
@end

#endif //GSWInput
