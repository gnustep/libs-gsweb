/* GSWList.h - GSWeb: List
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

#ifndef _GSWList_h__
#define _GSWList_h__


#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

typedef struct _GSWList
{
  unsigned int uCount;
  unsigned int uCapacity;
  void       **ppElements;
} GSWList;

unsigned int GSWList_Count(GSWList *p_pList);

GSWList *GSWList_New(unsigned int p_uCapacity);	
void GSWList_Free(GSWList *p_pList, BOOL p_fFreeElements);

void GSWList_Add(GSWList *p_pList, void *p_pElement);	
void GSWList_Remove(GSWList *p_pList, void *p_pElement);
void GSWList_RemoveAtIndex(GSWList *p_pList, int p_iIndex);
void GSWList_SetCapacity(GSWList *p_pList, unsigned int p_uCapacity);
void GSWList_Sort(GSWList *p_pList,int (*compare)(CONST void *, CONST void *));
void *GSWList_BSearch(GSWList    *p_pList,
		      CONST void *p_pKey,
		      int (*compare)(CONST void *, CONST void *));

void *GSWList_ElementAtIndex(GSWList *p_pList,int p_iIndex);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // _GSWList_h__
