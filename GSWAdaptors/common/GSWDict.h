/* GSWDict.h - GSWeb: Dictionary
   Copyright (C) 1999, 2000, 2003 Free Software Foundation, Inc.
   
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

#ifndef _GSWDict_h__
#define _GSWDict_h__

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

#include "GSWList.h"

typedef struct _GSWDictElem
{
  CONST char *pszKey;
  CONST void *pValue;
  BOOL        fValueOwner;
} GSWDictElem;

typedef struct _GSWDict
{
  unsigned int uCount;
  unsigned int uCapacity;
  GSWDictElem *pElems;
} GSWDict;

#define	GSWDict_Initialized()	((GSWDict){0,0,NULL})

GSWDict	*GSWDict_New(unsigned int p_uCapacity);

void GSWDict_Free(GSWDict *p_pDict);
void GSWDict_FreeElements(GSWDict *p_pDict);
void GSWDict_Add(GSWDict    *p_pDict,
		 CONST char *p_pszKey,
		 CONST void *p_pValue,
		 BOOL        p_fValueOwner);
void GSWDict_AddString(GSWDict    *p_pDict,
		       CONST char *p_pszKey,
		       CONST char *p_pValue,
		       BOOL        p_fValueOwner);
void GSWDict_AddStringDup(GSWDict    *p_pDict,
			  CONST char *p_pszKey,
			  CONST char *p_pValue);
void GSWDict_RemoveKey(GSWDict    *p_pDict,
		       CONST char *p_pszKey);
CONST void* GSWDict_ValueForKey(GSWDict    *p_pDict,
				CONST char *p_pszKey);
unsigned int GSWDict_Count(GSWDict *p_pDict);

void GSWDict_PerformForAllElem(GSWDict *p_pDict,
			       void (*pFN)(GSWDictElem *p_pElem,void *p_pData),
			       void    *p_pData);

//Free the list but Do Not Free Elements
GSWList* GSWDict_AllKeys(GSWDict *p_pDict);

void GSWDict_Log(GSWDict *p_pDict,
                 void    *p_pLogServerData);

#ifdef __cplusplus
} // end of C header
#endif //_cplusplus

#endif // _GSWDict_h__

