/* GSWString.h - GSWeb: Class GSWString
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

#ifndef _GSWString_h__
	#define _GSWString_h__


@interface GSWString: GSWHTMLDynamicElement
{
  GSWAssociation* value;
  GSWAssociation* dateFormat;
  GSWAssociation* numberFormat;
  GSWAssociation* escapeHTML;
//GSWeb Additions {
  GSWAssociation* convertHTML;
  GSWAssociation* convertHTMLEntities;
// }
  GSWAssociation* formatter;
};

-(void)dealloc;

-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_;

-(NSString*)description;

-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;

-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping;
-(BOOL)appendStringAtLeft:(id)_unkwnon
			  withMapping:(char*)_mapping;
-(NSFormatter*)formatterForComponent:(GSWComponent*)_component
							value:(id)value_;
-(NSString*)elementName;
@end

//====================================================================
@interface GSWString (GSWInputA)
+(BOOL)hasGSWebObjectsAssociations;
@end

#endif //_GSWString_h__
