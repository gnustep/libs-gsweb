/* GSWBrowser.h - GSWeb: Class GSWBrowser
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

#ifndef _GSWBrowser_h__
	#define _GSWBrowser_h__

//OK
@interface GSWBrowser: GSWInput
{
  GSWAssociation* list;
  GSWAssociation* item;
  GSWAssociation* displayString;
  GSWAssociation* selections;
#if !GSWEB_STRICT
  GSWAssociation* selectionValues;
#endif
  GSWAssociation* selectedValues;
  GSWAssociation* size;
  GSWAssociation* multiple;
  GSWAssociation* escapeHTML;
  BOOL autoValue;//??
};
-(void)dealloc;

-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
		 contentElements:(NSArray*)elements_;
-(NSString*)description;
-(NSString*)elementName;
@end

@interface GSWBrowser (GSWBrowserA)
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;

-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_; 

-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_; 
-(void)_slowTakeValuesFromRequest:(GSWRequest*)request_
						inContext:(GSWContext*)context_; 
-(void)_fastTakeValuesFromRequest:(GSWRequest*)request_
						inContext:(GSWContext*)context_; 
@end

@interface GSWBrowser (GSWBrowserB)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
									inContext:(GSWContext*)context_;

-(void)appendValueToResponse:(GSWResponse*)response_
				   inContext:(GSWContext*)context_;

@end

@interface GSWBrowser (GSWBrowserC)
-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping;
@end
#endif //_GSWBrowser_h__
