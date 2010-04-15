/** NSObject+XML.h - <title>GSWeb: NSObject+XML</title>
 
 Copyright (C) 2010 Free Software Foundation, Inc.
 
 Written by:	David Wetzel <dave@turbocat.de>
 Date: Feb 2010
 
 $Revision: 1.17 $
 $Date: 2004/12/31 14:33:16 $
 
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

#ifndef _NSObject_GSWXML_
#define _NSObject_GSWXML_

#include <Foundation/NSObject.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSDictionary.h>

@interface NSObject (GSWXML)
- (NSString*) encodeXMLPrefix;

- (NSString*) encodeXMLSuffix;

- (NSString*) encodeXML;


@end


@interface NSArray (GSWXML)
- (NSString*) encodeXMLRootObjectForKey:(NSString*) key;

@end


@interface NSDictionary (GSWXML)
- (NSString*) encodeXMLRootObjectForKey:(NSString*) key;

@end

#endif // _NSObject_GSWXML_
