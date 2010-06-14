/** GSWImageButton.h - <title>GSWeb: Class GSWImageButton</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

#ifndef _GSWImageButton_h__
	#define _GSWImageButton_h__


//====================================================================
@interface GSWImageButton: GSWInput
{
  GSWAssociation* _imageMapFileName;
//GSWeb Additions {
  GSWAssociation* _imageMapString;
  GSWAssociation* _imageMapRegions;
  GSWAssociation* _cidStore;
  GSWAssociation* _cidKey;
// }
  GSWAssociation* _action;
  GSWAssociation* _actionClass;
  GSWAssociation* _directActionName;
  GSWAssociation* _xAssoc;
  GSWAssociation* _yAssoc;
  GSWAssociation* _filename;
  GSWAssociation* _framework;
  GSWAssociation* _src;
  GSWAssociation* _data;
  GSWAssociation* _mimeType;
  GSWAssociation* _key;
  GSWAssociation* _width;
  GSWAssociation* _height;
};

-(void)dealloc;

-(GSWAssociation*)hitTestX:(int)x
                         y:(int)y
                 inRegions:(NSArray*)regions;

-(id)_imageURLInContext:(GSWContext*)context;

-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context;

-(void)_appendDirectActionToResponse:(GSWResponse*)response
                           inContext:(GSWContext*)context;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context;

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context;

//-(NSString*)frameworkNameInContext:(GSWContext*)context;

@end

#endif //_GSWImageButton_h__
