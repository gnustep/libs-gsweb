/* GSWRadioButtonList.h - GSWeb: Class GSWRadioButtonList
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

#ifndef _GSWRadioButtonList_h__
	#define _GSWRadioButtonList_h__


@interface GSWRadioButtonList: GSWInput
{
  GSWAssociation* list;
  GSWAssociation* item;
  GSWAssociation* index;
  GSWAssociation* selection;
  GSWAssociation* prefix;
  GSWAssociation* suffix;
  GSWAssociation* displayString;
  GSWAssociation* escapeHTML;
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
@interface GSWRadioButtonList (GSWRadioButtonListA)
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
@interface GSWRadioButtonList (GSWRadioButtonListB)
-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping;
-(BOOL)appendStringAtLeft:(id)_unkwnon
			  withMapping:(char*)_mapping;
-(BOOL)compactHTMLTags;
@end


#endif //_GSWRadioButtonList_h__
