/** NSNonBlockingFileHandle.m - <title>GSWeb: NSNonBlockingFileHandle</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

#include <time.h>
#include <sys/time.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <signal.h>

#include <sys/file.h>
#include <sys/stat.h>
#include <sys/fcntl.h>
#include <sys/ioctl.h>
#include <netdb.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#ifdef SOLARIS
#include <sys/filio.h>
#include <limits.h>
#endif
#include <Foundation/Foundation.h>
#include "NSNonBlockingFileHandle.h"
#include "GSWeb.h"
#include "GSWUtils.h"

@implementation NSFileHandle (CFRNonBlockingIO)


//Returns an NSData object containing all of the currently available data. 
// Does not block if there is no data; returns nil instead.
-(NSData*)availableDataNonBlocking
{
  NSData* data=nil;
  LOGObjectFnStart();
  data=[self readDataOfLengthNonBlocking: UINT_MAX];
  LOGObjectFnStop();
  return data;
};

// Returns an NSData object containing all of the currently available data. 
//  Does not block if there is no data; returns nil instead. 
//  Cover for #{-availableDataNonBlocking}.
-(NSData*)readDataToEndOfFileNonBlocking
{
  NSData* data=nil;
  LOGObjectFnStart();
  data=[self readDataOfLengthNonBlocking: UINT_MAX];
  LOGObjectFnStop();
  return data;
};

-(unsigned int)_availableByteCountNonBlocking
{
  int numBytes=0;
  int fd = 0;
  LOGObjectFnStart();
  fd=[self fileDescriptor];

  if (ioctl(fd, FIONREAD, (char *) &numBytes) == -1)
    {
      LOGException0(@"NSFileHandleOperationException ioctl() Err");
      [NSException raise: NSFileHandleOperationException
                   format: @"ioctl() Err # %d", (int)errno];
    };
  LOGObjectFnStop();
  return numBytes;
};

// Reads up to length bytes of data from the file handle. 
// If no data is available, returns nil. Does not block.
-(NSData*)readDataOfLengthNonBlocking:(unsigned int)length
{
  NSData* data=nil;
  unsigned int readLength=0;
  LOGObjectFnStart();

  readLength = [self _availableByteCountNonBlocking];
  NSDebugMLog(@"readLength=%u",readLength);
  readLength = (readLength < length) ? readLength : length;
  
  if (readLength>0)
    {
      data=[self readDataOfLength: readLength];
      NSDebugMLog(@"[data length]=%u",[data length]);
    };
  LOGObjectFnStop();
  return data;
}

@end
