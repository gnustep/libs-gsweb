/* GSWApplet.h - GSWeb: Class GSWApplet
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

#ifndef _GSWApplet_h__
	#define _GSWApplet_h__

//OK
//====================================================================
@interface GSWApplet: GSWHTMLDynamicElement
{
  NSMutableDictionary* clientSideAttributes;
  NSString* elementID;
  NSString* url;
  NSString* contextID;
  NSMutableDictionary* snapshots;
  GSWAssociation* archive;
  GSWAssociation* archiveNames;
  GSWAssociation* agcArchive;
  GSWAssociation* agcArchiveNames;
  GSWAssociation* codeBase;
};

-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_;

-(void)dealloc;

-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping;

-(id)		paramWithName:(id)name_
					value:(id)value_
				   target:(id)target_
					  key:(id)key_
	treatNilValueAsGSWNull:(BOOL)treatNilValueAsGSWNull_;

-(NSString*)elementName;
-(id)contextID;
-(void)setContextID:(id)contextID_;
-(id)url;
-(void)setURL:(id)url_;
-(NSString*)elementID;
-(void)setElementID:(NSString*)elementID_;
@end

//====================================================================
@interface GSWApplet (GSWAppletA)
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_;

-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_; 
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
									  inContext:(GSWContext*)context_;
-(void)_computeAgcArchiveStringInContext:(GSWContext*)context_;
-(id)_agcArchiveURLsListInContext:(GSWContext*)context_;
-(id)_archiveURLsListInContext:(GSWContext*)context_;
-(id)_agcArchiveNamesListInContext:(GSWContext*)context_;
-(id)_archiveNamesListInContext:(GSWContext*)context_;
-(void)_deallocForComponent:(id)component_;
-(void)_awakeForComponent:(id)component_;

+(BOOL)hasGSWebObjectsAssociations;
@end


#endif //_GSWApplet_h__
