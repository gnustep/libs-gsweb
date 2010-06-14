/** GSWPngImageInfo.m - <title>GSWeb: Class GSWImageInfo</title>

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
RCS_ID("$Id: GSWImageInfo.m 25027 2009-04-05 13:00:10Z ayers $")

#ifdef HAVE_LIBPNG
#include <png.h>
#endif

#include "GSWeb.h"

#ifdef HAVE_LIBPNG
typedef struct
{
  NSData *data;
  unsigned int offset;
} reader_struct_t;

static void
reader_func(png_structp png_struct,
	    png_bytep data,
	    png_size_t length)
{
  reader_struct_t *r = png_get_io_ptr(png_struct);

  if (r->offset + length > [r->data length])
    {
      png_error(png_struct, "end of buffer");
      return;
    }
  memcpy(data, [r->data bytes] + r->offset, length);
  r->offset += length;
}
#endif

@implementation GSWPngImageInfo
-(id)initWithContentsOfFile: (NSString *)path
{
#ifdef HAVE_LIBPNG
#warning HAVE_LIBPNG
  if ((self = [super init]))
    {
      NSData *data = [NSData dataWithContentsOfFile: path];
      const png_bytep bytes = (png_bytep)[data bytes];
      size_t len = [data length];

      if (!png_sig_cmp(bytes,0,len))
	{
	  png_structp png_struct;
	  png_infop png_info, png_end_info;
	  reader_struct_t reader;

	  png_struct = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	  png_info = png_create_info_struct(png_struct);
	  png_end_info = png_create_info_struct(png_struct);

	  if (setjmp(png_jmpbuf(png_struct)))
	    {
	      png_destroy_read_struct(&png_struct, &png_info, &png_end_info);
	      RELEASE(self);
	      return nil;
	    }

	  reader.data = data;
	  reader.offset = 0;

	  png_set_read_fn(png_struct, &reader, reader_func);
	  png_read_info(png_struct, png_info);

	  DESTROY(_widthString);
	  DESTROY(_heightString);
	  _width = png_get_image_width(png_struct, png_info);
	  _height = png_get_image_height(png_struct, png_info);

	  png_destroy_read_struct(&png_struct, &png_info, &png_end_info);
	}
    }
#else
  GSOnceMLog(@"PNG support not configured for GSWeb.");
  DESTROY(self);
#endif

  return self;
}
@end

