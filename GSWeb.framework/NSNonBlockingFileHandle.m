/* NSNonBlockingFileHandle.m - NSNonBlockingFileHandle
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
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
*/

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
#include <GSWeb/GSWeb.h>
#include "GSWUtils.h"

@implementation NSFileHandle (CFRNonBlockingIO)


//Returns an NSData object containing all of the currently available data. 
// Does not block if there is no data; returns nil instead.
-(NSData*)availableDataNonBlocking
{
  NSData* _data=nil;
  LOGObjectFnStart();
  _data=[self readDataOfLengthNonBlocking: UINT_MAX];
  LOGObjectFnStop();
  return _data;
};

// Returns an NSData object containing all of the currently available data. 
//  Does not block if there is no data; returns nil instead. 
//  Cover for #{-availableDataNonBlocking}.
-(NSData*)readDataToEndOfFileNonBlocking
{
  NSData* _data=nil;
  LOGObjectFnStart();
  _data=[self readDataOfLengthNonBlocking: UINT_MAX];
  LOGObjectFnStop();
  return _data;
};

-(unsigned int)_availableByteCountNonBlocking
{
  int numBytes;
  int fd = 0;
  LOGObjectFnStart();
  fd=[self fileDescriptor];

  if(ioctl(fd, FIONREAD, (char *) &numBytes) == -1)
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
  NSData* _data=nil;
  unsigned int readLength;
  LOGObjectFnStart();

  readLength = [self _availableByteCountNonBlocking];
  readLength = (readLength < length) ? readLength : length;
  
  if (readLength>0)
	_data=[self readDataOfLength: readLength];
  LOGObjectFnStop();
  return _data;
}

@end
