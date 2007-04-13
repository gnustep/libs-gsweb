/** GSWFileUpload.h - <title>GSWeb: Class GSWFileUpload</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Sept 1999
   
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

#ifndef _GSWFileUpload_h__
	#define _GSWFileUpload_h__

//====================================================================
@interface GSWFileUpload: GSWInput
{
  GSWAssociation* _data;
  GSWAssociation* _filepath;
  // these are new in 5.x
  GSWAssociation* _mimeType;
  GSWAssociation* _copyData;
  GSWAssociation* _inputStream;
  GSWAssociation* _outputStream;
  GSWAssociation* _bufferSize;
  GSWAssociation* _streamToFilePath;
  GSWAssociation* _overwrite;
  GSWAssociation* _finalFilePath;
  
};

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements;

@end

#endif // _GSWFileUpload_h__
