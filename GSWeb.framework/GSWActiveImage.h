/** GSWActiveImage.h - <title>GSWeb: Class GSWActiveImage</title>
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
   $Revision$
   $Date$
   
   <abstract></abstract>

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

#ifndef _GSWActiveImage_h__
	#define _GSWActiveImage_h__

//====================================================================
@interface GSWActiveImage: GSWInput
{
  GSWAssociation* _imageMapFileName;

//GSWeb Additions {
  GSWAssociation* _imageMapString;
  GSWAssociation* _imageMapRegions;
// }
  GSWAssociation* _action;
  GSWAssociation* _href;
  GSWAssociation* _src;
  GSWAssociation* _xAssoc;
  GSWAssociation* _yAssoc;
  GSWAssociation* _target;
  GSWAssociation* _filename;
  GSWAssociation* _framework;
  GSWAssociation* _data;
  GSWAssociation* _mimeType;
  GSWAssociation* _key;
};

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements;
-(NSString*)elementName;
-(NSString*)description;
-(void)dealloc;

@end

//====================================================================
@interface GSWActiveImage (GSWActiveImageA)
-(GSWAssociation*)hitTestX:(int)x
                         y:(int)y
                 inRegions:(NSArray*)regions;
@end

//====================================================================
@interface GSWActiveImage (GSWActiveImageB)
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)aContext;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)aContext;
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext; 

-(NSString*)frameworkNameInContext:(GSWContext*)aContext;
-(NSString*)imageSourceInContext:(GSWContext*)aContext; //NDFN
-(NSString*)hrefInContext:(GSWContext*)aContext; //NDFN
@end

//====================================================================
@interface GSWActiveImage (GSWActiveImageC)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
                                      inContext:(GSWContext*)aContext;
@end

//====================================================================
@interface GSWActiveImage (GSWActiveImageD)
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping;
-(BOOL)appendStringAtLeft:(id)unkwnon
              withMapping:(char*)mapping;
@end

#endif //_GSWActiveImage_h__
