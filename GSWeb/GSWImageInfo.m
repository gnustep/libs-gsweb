/** GSWImageInfo.m - <title>GSWeb: Class GSWImageInfo</title>

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

#include "config.h"

#include "GSWeb.h"

@interface GSWJpegImageInfo : GSWImageInfo
-(id)initWithContentsOfFile: (NSString *)path;
@end
@interface GSWGifImageInfo : GSWImageInfo
-(id)initWithContentsOfFile: (NSString *)path;
@end

@implementation GSWJpegImageInfo
-(id)initWithContentsOfFile: (NSString *)path
{
  NSLog(@"TODO:[%@ %@] %s:%d",NSStringFromClass([self class]),NSStringFromSelector(_cmd),__FILE__,__LINE__);
  DESTROY(self);
  return self;
}
@end
@implementation GSWGifImageInfo
-(id)initWithContentsOfFile: (NSString *)path
{
  NSLog(@"TODO:[%@ %@] %s:%d",NSStringFromClass([self class]),NSStringFromSelector(_cmd),__FILE__,__LINE__);
  DESTROY(self);
  return self;
}
@end

@implementation GSWImageInfo
static NSDictionary *extensionClassDict = nil;

+ (void)initialize
{
  extensionClassDict
    = [[NSDictionary alloc]initWithObjectsAndKeys:
			     [GSWJpegImageInfo class], @"jpg",
			   [GSWJpegImageInfo class], @"jpeg",
			   [GSWGifImageInfo class], @"gif",
			   [GSWPngImageInfo class], @"png",
			   nil];
}

+ (GSWImageInfo *)imageInfoWithFile: (NSString*)filename
{
  NSString *extension = [filename pathExtension];
  Class cls = [self subclassForExtension: extension];
  return [[[cls alloc] initWithContentsOfFile: filename] autorelease];
}
+ (NSArray *)supportedExtensions
{
  return [extensionClassDict allKeys];
}
+ (BOOL)isSupportedExtension:(NSString *)extension
{
  return [extensionClassDict objectForKey: extension] ? YES : NO;
}
+ (BOOL)pathHasSupportedExtension:(NSString *)path
{
  NSString *extension = [path pathExtension];
  return [extensionClassDict objectForKey: extension] ? YES : NO;
}
+ (Class)subclassForExtension:(NSString *)extension
{
  return [extensionClassDict objectForKey: extension];
}

- (unsigned int)width
{
  return _width;
}
- (unsigned int)height
{
  return _height;
}
- (NSString*)widthString
{
  if (!_widthString)
    {
      _widthString = [[NSString alloc] initWithFormat:@"%u",_width];
    }
  return _widthString;
}
- (NSString*)heightString
{
  if (!_heightString)
    {
      _heightString = [[NSString alloc] initWithFormat:@"%u",_height];
    }
  return _heightString;
}
- (void)dealloc
{
  DESTROY(_widthString);
  DESTROY(_heightString);
  [super dealloc];
}

@end
