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


#endif /* __GSWeb_GSWDefines_h__ */

