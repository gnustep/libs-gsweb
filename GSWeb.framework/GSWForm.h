/* GSWForm.h - GSWeb: Class GSWForm
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

#ifndef _GSWForm_h__
	#define _GSWForm_h__

//OK
@interface GSWForm: GSWHTMLDynamicElement
{
  GSWAssociation* action;
  GSWAssociation* href;
  GSWAssociation* multipleSubmit;
  GSWAssociation* actionClass;
  GSWAssociation* directActionName;
  GSWAssociation* queryDictionary;
//GSWeb Additions {
  GSWAssociation* disabled;
  GSWAssociation* enabled;
// }
  NSDictionary* otherQueryAssociations;
};

-(id)description;
-(id)elementName;
-(void)dealloc;

-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_;
@end


@interface GSWForm (GSWFormA)
#if !GSWEB_STRICT
-(BOOL)disabledInContext:(GSWContext*)_context;
#endif
-(BOOL)compactHTMLTags;
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;
-(void)_appendHiddenFieldsToResponse:(GSWResponse*)response_
						   inContext:(GSWContext*)context_;
-(NSDictionary*)computeQueryDictionaryInContext:(GSWContext*)context_;
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_;
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_; 
@end

@interface GSWForm (GSWFormB)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
						   inContext:(GSWContext*)context_;
-(void)_appendCGIActionToResponse:(GSWResponse*)response_
						   inContext:(GSWContext*)context_;
@end

@interface GSWForm (GSWFormC)
+(BOOL)hasGSWebObjectsAssociations;
@end

#endif //_GSWForm_h__
