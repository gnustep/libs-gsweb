/** GSWImageInfo.h - <title>GSWeb: Class GSWImageInfo</title>

   Copyright (C) 2009 Free Software Foundation, Inc.
   
   Written by:	David Ayers  <ayers@fsfe.org>
   Date: 	April 2009
   
   $Revision: 26815 $
   $Date: 2009-04-05 13:00:10 +0200$

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

// $Id: GSWImageInfo.h 26815 2009-04-05  13:00:10Z ayers $

#ifndef _GSWImageInfo_h__
	#define _GSWImageInfo_h__

@interface GSWImageInfo: NSObject
{
  unsigned int _width;
  unsigned int _height;
  NSString * _widthString;
  NSString * _heightString;
}
+ (GSWImageInfo *)imageInfoWithFile: (NSString*)filename;
+ (NSArray *)supportedExtensions;
+ (BOOL)isSupportedExtension:(NSString *)extenstion;
+ (BOOL)pathHasSupportedExtension:(NSString *)extenstion;
+ (Class)subclassForExtension:(NSString *)extenstion;

- (unsigned int)width;
- (unsigned int)height;
- (NSString*)widthString;
- (NSString*)heightString;

@end


#endif //_GSWImageInfo_h__
