/** GSWHTTPIO.h - GSWeb: Class GSWHTTPIO
 
 Copyright (C) 2007 Free Software Foundation, Inc.
 
 Written by:	David Wetzel <dave@turbocat.de>
 Date: 	12.11.2007
 
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
 **/

#ifndef _GSWHTTPIO_h__
#define _GSWHTTPIO_h__
#import <Foundation/NSObject.h>
#include "GSWWOCompatibility.h"

@class NSFileHandle;
@class GSWRequest;
@class GSWResponse;


@interface GSWHTTPIO : NSObject {

}

+ _setAlwaysAppendContentLength:(BOOL) yn;

+ (BOOL) _alwaysAppendContentLength;
  
+ (GSWRequest*) readRequestFromFromHandle:(NSFileHandle*) fh;

+ (void) sendResponse:(GSWResponse*) response
             toHandle:(NSFileHandle*) fh
              request:(GSWRequest*) request;

@end

#endif // _GSWHTTPIO_h__
