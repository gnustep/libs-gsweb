/** NSData+Compress.m - <title>GSWeb: NSData / zlib</title>

   Copyright (C) 2003 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	May 2003
   
   $Revision$
   $Date$
   $Id$

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

RCS_ID("$Id$")

#include "GSWeb.h"
#ifdef HAVE_LIBZ
#include <zlib.h>

void GZPutLong(void* ptr,uLong value)
{
  int n;
  for (n = 0; n < 4; n++) 
    {
      ((unsigned char*)ptr)[n]=(value & 0xff);
      value >>= 8;
    }
};

static char gzMagic[2]= {0x1f, 0x8b}; // gzip magic header
static int gzHeaderSize=10;

//====================================================================
@implementation NSData (GSWZLib)

- (NSData *)deflate
{
  NSMutableData *outData=nil;
  z_stream c_stream; // compression stream
  int err=Z_OK;
  unsigned int selfLength=[self length];

  memset (&c_stream, 0, sizeof(c_stream));
  
  err = deflateInit2(&c_stream,           /* z_streamp strm */
                     4,                   /* int level */
                     Z_DEFLATED,          /* int method */
                     -15,                 /* int windowBits */
                     8,                   /* int memLevel */
                     Z_DEFAULT_STRATEGY); /* int strategy */
  if (err!=Z_OK)
    {
//      LOGError(@"deflateInit2 error: %d",err);
    }
  else
    {
      const void* inBytes=[self bytes];
      unsigned int capacity = max(1024, selfLength/10);
      NSMutableData* outTempData
	= [NSMutableData dataWithCapacity: capacity];
      void* outTempBytes=[outTempData mutableBytes];
      void* outBytes=NULL;
      uLong crc = crc32(0L, Z_NULL, 0);
      unsigned flushedData=0;

      crc = crc32(crc,inBytes,selfLength);//calculate crc
      outData = [NSMutableData dataWithCapacity: gzHeaderSize];

          // gzip nead header !                      
      [outData setLength: gzHeaderSize];
      outBytes = [outData mutableBytes];

      ((unsigned char*)outBytes)[0] = gzMagic[0];
      ((unsigned char*)outBytes)[1] = gzMagic[1];
      ((unsigned char*)outBytes)[2] = Z_DEFLATED;
      ((unsigned char*)outBytes)[3] = 0; //flags
      ((unsigned char*)outBytes)[4] = 0; //time
      ((unsigned char*)outBytes)[5] = 0;//time
      ((unsigned char*)outBytes)[6] = 0;//time
      ((unsigned char*)outBytes)[7] = 0;//time
      ((unsigned char*)outBytes)[8] = 2;//binary        
      ((unsigned char*)outBytes)[9] = 0x3;//OS

      c_stream.next_in = (Bytef *)inBytes;
      c_stream.avail_in = (uInt)selfLength;
      
      [outTempData setLength: capacity];
      c_stream.next_out = outTempBytes;
      c_stream.avail_out = (uInt)[outTempData length];
      do
        {
          err = deflate(&c_stream, Z_NO_FLUSH);
          if (err!=Z_OK)
            {
              //LOGError(@"deflate error: %d",err);
            }
          else
            {
              if (c_stream.avail_out==0)
                {
                  [outData appendData:outTempData];
                  flushedData+=[outTempData length];

                  c_stream.next_out = outTempBytes;
                  c_stream.avail_out = (uInt)[outTempData length];
                };
            };
        }
      while (c_stream.avail_in>0 && err==Z_OK);
      if (err==Z_OK)
        {
          do 
            {
              err = deflate(&c_stream, Z_FINISH);
              if (err==Z_STREAM_END || err==Z_OK)
                {
                  [outTempData setLength:c_stream.total_out-flushedData];
                  [outData appendData:outTempData];
                  flushedData+=[outTempData length];
                  
                  c_stream.next_out = outTempBytes;
                  c_stream.avail_out = (uInt)[outTempData length];
                }
              else
                {
                  //LOGError(@"deflate error: %d",err);
                };
            } while (err == Z_OK);
        };
      if (err==Z_STREAM_END || err==Z_OK)
        {
          [outTempData setLength:8];
          GZPutLong(outTempBytes, crc);
          GZPutLong(outTempBytes+4, selfLength);
          [outData appendData:outTempData];
        };
      err = deflateEnd(&c_stream);
      if (err!=Z_OK)
        {
          //LOGError(@"deflateEnd error: %d",err);
        }
    };
  return outData;
}

@end

#endif

