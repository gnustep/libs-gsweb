/* -*-objc-*-
   GSWDefines.h

   Copyright (C) 2004 Free Software Foundation, Inc.

   Author: Sung Jin Chun <chunsj@embian.com>

   This file is part of the GNUstepWeb Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, write to the Free Software Foundation,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

#ifndef __GSWeb_GSWDefines_h__
#define __GSWeb_GSWDefines_h__

#ifdef GNUSTEP_WITH_DLL

#if BUILD_GSWeb_DLL
#  define GSWEB_EXPORT  __declspec(dllexport)
#  define GSWEB_DECLARE __declspec(dllexport) 
#else
#  define GSWEB_EXPORT  extern __declspec(dllimport)
#  define GSWEB_DECLARE __declspec(dllimport) 
#endif

#else /* GNUSTEP_WITH[OUT]_DLL */

#  define GSWEB_EXPORT extern
#  define GSWEB_DECLARE 

#endif


/*
  The following macros are for use of locks together with exception handling.
  A synchronized block is properly 'unlocked' even if an exception occures.
  It is used this way:

    SYNCHRONIZED(MyObject) {
      THROW(MyException..);
    }
    END_SYNCHRONIZED;

  Where MyObject must be an object that conforms to the NSObject and NSLocking
  protocol.
  This is much different to

    [MyObject lock];
    {
      THROW(MyException..);
    }
    [MyObject unlock];

  which leaves the lock locked when an exception happens.
*/

#if defined(DEBUG_SYNCHRONIZED)

#define SYNCHRONIZED(__lock__) \
  { \
    id<NSObject,NSLocking> __syncLock__ = [__lock__ retain]; \
    [__syncLock__ lock]; \
    fprintf(stderr, "0x%08X locked in %s.\n", \
            (unsigned)__syncLock__, __PRETTY_FUNCTION__); \
    NS_DURING {

#define END_SYNCHRONIZED \
    } \
    NS_HANDLER { \
      fprintf(stderr, "0x%08X exceptional unlock in %s exception %s.\n", \
              (unsigned)__syncLock__, __PRETTY_FUNCTION__,\
              [[localException description] cString]); \
      [__syncLock__ unlock]; \
      [__syncLock__ release]; __syncLock__ = nil; \
      [localException raise]; \
    } \
    NS_ENDHANDLER; \
    fprintf(stderr, "0x%08X unlock in %s.\n", \
            (unsigned)__syncLock__, __PRETTY_FUNCTION__); \
    [__syncLock__ unlock]; \
    [__syncLock__ release];  __syncLock__ = nil; \
  }

#else

#define SYNCHRONIZED(__lock__) \
  { \
    id<NSObject,NSLocking> __syncLock__ = [__lock__ retain]; \
    [__syncLock__ lock]; \
    NS_DURING {

#define END_SYNCHRONIZED \
    } \
    NS_HANDLER { \
      [__syncLock__ unlock]; \
      [__syncLock__ release]; \
      [localException raise]; \
    } \
    NS_ENDHANDLER; \
    [__syncLock__ unlock]; \
    [__syncLock__ release]; \
  }

#endif


#endif /* __GSWeb_GSWDefines_h__ */

