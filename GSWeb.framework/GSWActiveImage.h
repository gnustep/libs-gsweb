/* GSWActiveImage.h - GSWeb: Class GSWActiveImage
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

#ifndef _GSWActiveImage_h__
	#define _GSWActiveImage_h__

//====================================================================
@interface GSWActiveImage: GSWInput
{
  GSWAssociation* imageMapFileName;

//GSWeb Additions {
  GSWAssociation* imageMapString;
  GSWAssociation* imageMapRegions;
// }
  GSWAssociation* action;
  GSWAssociation* href;
  GSWAssociation* src;
  GSWAssociation* xAssoc;
  GSWAssociation* yAssoc;
  GSWAssociation* target;
  GSWAssociation* filename;
  GSWAssociation* framework;
  GSWAssociation* data;
  GSWAssociation* mimeType;
  GSWAssociation* key;
};

-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_;
-(NSString*)elementName;
-(NSString*)description;
-(void)dealloc;

@end

//====================================================================
@interface GSWActiveImage (GSWActiveImageA)
-(GSWAssociation*)hitTestX:(int)x_
						 y:(int)y_
				 inRegions:(NSArray*)regions_;
@end

//====================================================================
@interface GSWActiveImage (GSWActiveImageB)
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_;
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_; 

-(NSString*)frameworkNameInContext:(GSWContext*)context_;
-(NSString*)imageSourceInContext:(GSWContext*)context_; //NDFN
-(NSString*)hrefInContext:(GSWContext*)context_; //NDFN
@end

//====================================================================
@interface GSWActiveImage (GSWActiveImageC)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
									inContext:(GSWContext*)context_;
@end

//====================================================================
@interface GSWActiveImage (GSWActiveImageD)
-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping;
-(BOOL)appendStringAtLeft:(id)_unkwnon
			  withMapping:(char*)_mapping;
@end

#endif //_GSWActiveImage_h__
