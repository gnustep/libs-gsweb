/* GSWHyperlink.h - GSWeb: Class GSWHyperlink
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

#ifndef _GSWHyperlink_h__
	#define _GSWHyperlink_h__


@interface GSWHyperlink: GSWDynamicElement
{
  GSWAssociation* action;
  GSWAssociation* string;
  GSWAssociation* pageName;
  GSWAssociation* href;
  GSWAssociation* disabled;
  GSWAssociation* fragmentIdentifier;
  GSWAssociation* queryDictionary;
  GSWAssociation* actionClass;
  GSWAssociation* directActionName;
//GSWeb Additions {
  GSWAssociation* enabled;
  GSWAssociation* displayDisabled;
  GSWAssociation* redirectURL;
  NSDictionary* pageSetVarAssociations;
  GSWAssociation* pageSetVarAssociationsDynamic;
// }
  NSDictionary* otherQueryAssociations;
  NSDictionary* otherAssociations;

//GSWeb Additions {
  GSWAssociation* filename;
  GSWAssociation* framework;
  GSWAssociation* data;
  GSWAssociation* mimeType;
  GSWAssociation* key;
// }
  GSWElement* children;
};

-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
		 template:(GSWElement*)templateElement_;
-(void)dealloc;
-(NSString*)description;
@end

@interface GSWHyperlink (GSWHyperlinkA)
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;
#if !GSWEB_STRICT
-(NSString*)frameworkNameInContext:(GSWContext*)context_;
#endif
-(void)_appendCGIActionURLToResponse:(GSWResponse*)response_
						   inContext:(GSWContext*)context_;
-(id)computeActionStringInContext:(GSWContext*)context_;
-(void)_appendQueryStringToResponse:(GSWResponse*)response_
						   inContext:(GSWContext*)context_;
-(NSDictionary*)computeQueryDictionaryInContext:(GSWContext*)context_;
-(NSString*)hrefInContext:(GSWContext*)context_; //NDFN

@end

@interface GSWHyperlink (GSWHyperlinkB)
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_;
@end

#endif //_GSWHyperlink_h__
