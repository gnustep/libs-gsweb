/* GSWCheckBoxList.h - GSWeb: Class GSWCheckBoxList
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

#ifndef _GSWCheckBoxList_h__
	#define _GSWCheckBoxList_h__

//====================================================================
@interface GSWCheckBoxList: GSWInput
{
  GSWAssociation* list;
  GSWAssociation* item;
  GSWAssociation* index;
  GSWAssociation* selections;
  GSWAssociation* prefix;
  GSWAssociation* suffix;
  GSWAssociation* displayString;
  GSWAssociation* escapeHTML;
  GSWAssociation* itemDisabled;
  BOOL defaultEscapeHTML;
};

-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_;
-(void)dealloc;

-(NSString*)description;
-(NSString*)elementName;


@end

//====================================================================
@interface GSWCheckBoxList (GSWCheckBoxListA)
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;

-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_; 
-(void)_slowTakeValuesFromRequest:(GSWRequest*)request_
						inContext:(GSWContext*)context_; 
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request_
						inContext:(GSWContext*)context_; 
@end

//====================================================================
@interface GSWCheckBoxList (GSWCheckBoxListB)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
									inContext:(GSWContext*)context_;
@end

//====================================================================
@interface GSWCheckBoxList (GSWCheckBoxListC)
-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping;
-(BOOL)appendStringAtLeft:(id)_unkwnon
			  withMapping:(char*)_mapping;
-(BOOL)compactHTMLTags;
@end


#endif //_GSWCheckBoxList_h__
