/* GSWDict.c - GSWeb: Dictionary
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

#include <string.h>
#include <stdlib.h>
#include <string.h>

#include "config.h"
#include "GSWUtil.h"
#include "GSWList.h"

unsigned int
GSWList_Count(GSWList *p_pList)
{
  return p_pList->uCount;
};

GSWList *
GSWList_New(unsigned int p_uCapacity)
{
  GSWList *pList=calloc(1,sizeof(GSWList));
  if (pList && p_uCapacity>0)  
    GSWList_SetCapacity(pList,p_uCapacity);
  return pList;
};

void
GSWList_FreeElements(GSWList *p_pList)
{
  if (p_pList)
    {
      unsigned int i=0;
      for(i=0;i<p_pList->uCount;i++)
	{
	  free(p_pList->ppElements[i]);
	  p_pList->ppElements[i]=NULL;
	};
      p_pList->uCount=0;
    };
};

void
GSWList_Free(GSWList *p_pList,
	     BOOL     p_fFreeElements)
{
  if (p_pList)
    {
      if (p_pList->ppElements)
	{
	  if (p_fFreeElements)
	    GSWList_FreeElements(p_pList);
	  free(p_pList->ppElements);
	  p_pList->ppElements=NULL;
	};
      free(p_pList);
    };
};


void
GSWList_Add(GSWList *p_pList,
	    void    *p_pElement)
{
  if (p_pList->uCount>=p_pList->uCapacity)
    GSWList_SetCapacity(p_pList,
			(p_pList->uCapacity) ? p_pList->uCapacity*2 : 16);
  p_pList->ppElements[p_pList->uCount] = p_pElement;
  p_pList->uCount++;
};

void
GSWList_RemoveAtIndex(GSWList *p_pList,
		      int      p_iIndex)
{
  if (p_iIndex>=0 && p_iIndex<p_pList->uCount)
    {
      p_pList->uCount--;
      for (;p_iIndex<p_pList->uCount;p_iIndex++)
	p_pList->ppElements[p_iIndex]=p_pList->ppElements[p_iIndex+1];
    };
};

void
GSWList_Remove(GSWList *p_pList,
	       void    *p_pElement)
{
  int i;
  for (i=0;i<p_pList->uCount;i++)
    {
      if (p_pList->ppElements[i]==p_pElement)
	{
	  GSWList_RemoveAtIndex(p_pList,i);
	  i=p_pList->uCount;
	};
    };
};

	
void
GSWList_SetCapacity(GSWList     *p_pList,
		    unsigned int p_uCapacity)
{
  if (p_uCapacity>p_pList->uCapacity)
    {
      if (p_pList->ppElements)
	p_pList->ppElements=realloc(p_pList->ppElements,
				    p_uCapacity*sizeof(void *));
      else 
	p_pList->ppElements=calloc(p_uCapacity, sizeof(void *));
	  p_pList->uCapacity=p_uCapacity;
	};
};

void
GSWList_Sort(GSWList *p_pList,
	     int (*compare)(CONST void *, CONST void *))
{
  if (p_pList->uCount>1)
    qsort(p_pList->ppElements,p_pList->uCount,sizeof(void *), compare);
}

void *
GSWList_BSearch(GSWList    *p_pList,
		CONST void *p_pKey,
		int (*compare)(CONST void *, CONST void *))
{
  void **ppElement=NULL;
  if (p_pList->uCount>0)
    ppElement=bsearch(p_pKey,
		      p_pList->ppElements,
		      p_pList->uCount,
		      sizeof(void *),
		      compare);
  return (ppElement) ? *ppElement : NULL;
};

void *
GSWList_ElementAtIndex(GSWList *p_pList,
		       int      p_iIndex)
{
  if (p_iIndex>=0 && p_iIndex<p_pList->uCount)
    return p_pList->ppElements[p_iIndex];
  else
    return NULL;
};
