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

//GSWeb Additions {
  GSWAssociation * _imageMapString;
  GSWAssociation * _imageMapRegions;
// }
  GSWAssociation * _file;              // this is imageMapFile
  GSWAssociation * _action;
  GSWAssociation * _href;
  GSWAssociation * _src;
  GSWAssociation * _xAssoc;
  GSWAssociation * _yAssoc;
  GSWAssociation * _target;
  GSWAssociation * _filename;
  GSWAssociation * _framework;
  GSWAssociation * _data;
  GSWAssociation * _mimeType;
  GSWAssociation * _key;
  GSWAssociation * _width;
  GSWAssociation * _height;
  GSWAssociation * _secure;
  GSWAssociation * _actionClass;
  GSWAssociation * _directActionName;
  NSDictionary   * _sessionIDQueryAssociations;

};


-(GSWAssociation*)hitTestX:(int)x
                         y:(int)y
                 inRegions:(NSArray*)regions;

-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)aContext;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)aContext;
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext; 

//-(NSString*)frameworkNameInContext:(GSWContext*)aContext;


-(void)_appendCGIActionURLToResponse:(GSWResponse*)aResponse
                           inContext:(GSWContext*)aContext;

@end

#endif //_GSWActiveImage_h__
