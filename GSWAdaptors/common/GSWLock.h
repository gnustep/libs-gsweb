/* GSWLock.h - GSWeb: Lock
   Copyright (C) 1999, 2000 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 	July 1999
   
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

#ifndef _GSWLock_h__
#define _GSWLock_h__


#ifdef __cplusplus
extern "C" {
#endif // __cplusplus


// Apache has no theading for old versions
#define	GSWLock	void*
#define	GSWLock_Init(TheLock)
#define	GSWLock_Lock(TheLock)
#define	GSWLock_Unlock(TheLock)
#define	GSWLock_Free(TheLock)
#define	GSWLock_Sleep(SecNb)	sleep(SecNb)

#ifdef __cplusplus
}
#endif // __cplusplus

#endif	// _GSWLock_h__
