/* GSWInput.h - GSWeb: Class GSWInput
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

#ifndef _GSWInput_h__
	#define _GSWInput_h__


//====================================================================
@interface GSWInput: GSWHTMLDynamicElement
{
  GSWAssociation* disabled;
//GSWeb Additions {
  GSWAssociation* enabled;
//}
  GSWAssociation* name;
  GSWAssociation* value;
//GSWeb Additions {
  GSWAssociation* handleValidationException;
// }
};

-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_;
-(void)dealloc;
-(NSString*)elementName;

@end

//====================================================================
@interface GSWInput (GSWInputA)
-(NSString*)nameInContext:(GSWContext*)context_;
-(NSString*)valueInContext:(GSWContext*)context_;
-(void)resetAutoValue;
-(BOOL)disabledInContext:(GSWContext*)context_;
@end

//====================================================================
@interface GSWInput (GSWInputB)
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_; 

@end

//====================================================================
@interface GSWInput (GSWInputC)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
									inContext:(GSWContext*)context_;
-(void)appendValueToResponse:(GSWResponse*)response_
				   inContext:(GSWContext*)context_;
-(void)appendNameToResponse:(GSWResponse*)response_
				  inContext:(GSWContext*)context_;

@end

//====================================================================
@interface GSWInput (GSWInputD)
+(BOOL)hasGSWebObjectsAssociations;
@end

//====================================================================
@interface GSWInput (GSWInputE)

#if !GSWEB_STRICT
-(void)handleValidationException:(NSException*)exception_
					   inContext:(GSWContext*)context_;
#endif
@end

#endif //GSWInput
