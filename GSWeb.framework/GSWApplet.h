/** GSWApplet.h - <title>GSWeb: Class GSWApplet</title>

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

#ifndef _GSWApplet_h__
	#define _GSWApplet_h__

//OK
//====================================================================
@interface GSWApplet: GSWHTMLDynamicElement
{
  NSMutableDictionary* _clientSideAttributes;
  NSString* _elementID;
  NSString* _url;
  NSString* _contextID;
  NSMutableDictionary* _snapshots;
  GSWAssociation* _archive;
  GSWAssociation* _archiveNames;
  GSWAssociation* _agcArchive;
  GSWAssociation* _agcArchiveNames;
  GSWAssociation* _codeBase;
};

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements;

-(void)dealloc;

-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping;

-(id)		paramWithName:(id)name
                        value:(id)value
                       target:(id)target
                          key:(id)key
       treatNilValueAsGSWNull:(BOOL)treatNilValueAsGSWNull;

-(NSString*)elementName;
-(id)contextID;
-(void)setContextID:(id)contextID;
-(id)url;
-(void)setURL:(id)url;
-(NSString*)elementID;
-(void)setElementID:(NSString*)elementID;
@end

//====================================================================
@interface GSWApplet (GSWAppletA)
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext;

-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext; 
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext;
-(void)_computeAgcArchiveStringInContext:(GSWContext*)aContext;
-(id)_agcArchiveURLsListInContext:(GSWContext*)aContext;
-(id)_archiveURLsListInContext:(GSWContext*)aContext;
-(id)_agcArchiveNamesListInContext:(GSWContext*)aContext;
-(id)_archiveNamesListInContext:(GSWContext*)aContext;
-(void)_deallocForComponent:(id)component;
-(void)_awakeForComponent:(id)component;

+(BOOL)hasGSWebObjectsAssociations;
@end


#endif //_GSWApplet_h__
