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
#include "GSWDict.h"

void
GSWDict_SetCapacity(GSWDict *p_pDict,unsigned int p_uCapacity)
{
  if (!p_pDict)
    {
      GSWLog(GSW_CRITICAL,NULL,"NULL GSWDict");
    }
  else
    {
      p_uCapacity=max(16,p_uCapacity);
      if (p_uCapacity>p_pDict->uCapacity)
	{
	  if (p_pDict->pElems)
	    p_pDict->pElems = realloc(p_pDict->pElems,
				      p_uCapacity*sizeof(GSWDictElem));
	  else
	    p_pDict->pElems = malloc(p_uCapacity*sizeof(GSWDictElem));
	  p_pDict->uCapacity = p_uCapacity;
	};
    };
};

GSWDict	*
GSWDict_New(unsigned int p_uCapacity)
{
  GSWDict *pDict = malloc(sizeof(GSWDict));
  memset(pDict,0,sizeof(GSWDict));
  GSWDict_SetCapacity(pDict,max(16,p_uCapacity));  
  return pDict;
};

void
GSWDict_FreeElem(GSWDictElem *p_pElem,void *p_pData)
{
  if (!p_pElem)
    {
      GSWLog(GSW_CRITICAL,NULL,"NULL GSWDict pElem");
    }
  else
    {
      if (p_pElem->pszKey)
	{
	  free((char *)p_pElem->pszKey);
	  p_pElem->pszKey=NULL;
	};
      if (p_pElem->pValue && p_pElem->fValueOwner)
	{
	  free((void *)p_pElem->pValue);
	};
      p_pElem->pValue=NULL;
    };
};

void
GSWDict_FreeElements(GSWDict *p_pDict)
{
  GSWDict_PerformForAllElem(p_pDict,GSWDict_FreeElem,NULL);
};

void
GSWDict_Free(GSWDict *p_pDict)
{
  if (!p_pDict)
    {
      GSWLog(GSW_ERROR,NULL,"NULL GSWDict");
    }
  else
    {
      GSWDict_FreeElements(p_pDict);
      if (p_pDict->pElems)
	free(p_pDict->pElems);
      free(p_pDict);
    };
};


static GSWDictElem *
GSWDict_FindFirstNullKey(GSWDict *p_pDict) 
{
  int          i=0;
  GSWDictElem *pElem=NULL;
  for (pElem=p_pDict->pElems;i<p_pDict->uCount;i++,pElem++)
    if (!pElem->pszKey)
      return pElem;
  return NULL;
};

unsigned int
GSWDict_Count(GSWDict *p_pDict)
{
  unsigned int uCount=0;
  if (!p_pDict)
    {
      GSWLog(GSW_CRITICAL,NULL,"NULL GSWDict");
    }
  else
    {
      int i=0;
      GSWDictElem *pElem=NULL;
      for (pElem=p_pDict->pElems;i<p_pDict->uCount;i++,pElem++)
	if (pElem->pszKey)
	  uCount++;
    };
  return uCount;
};

void
GSWDict_Add(GSWDict    *p_pDict,
	    CONST char *p_pszKey,
	    CONST void *p_pValue,
	    BOOL p_fValueOwner)
{
  GSWDictElem *pElem=NULL;
  if (!p_pDict)
    {
      GSWLog(GSW_CRITICAL,NULL,"NULL GSWDict");
    }
  else
    {
      if (p_pDict->uCount>=p_pDict->uCapacity)
	{
	  pElem=GSWDict_FindFirstNullKey(p_pDict);
	  if (!pElem)
	    {	
	      GSWDict_SetCapacity(p_pDict,p_pDict->uCapacity*2);
	      pElem=p_pDict->pElems+p_pDict->uCount;
	      p_pDict->uCount++;
	    };
	}
      else
	{
	  pElem=p_pDict->pElems+p_pDict->uCount;
	  p_pDict->uCount++;
	};
      if (!pElem)
	{
	  GSWLog(GSW_CRITICAL,NULL,"No pElem in GSWDict Add");
	};
      pElem->pszKey=strdup(p_pszKey);
      pElem->pValue=p_pValue;
      pElem->fValueOwner=p_fValueOwner;
    };
};

void
GSWDict_AddString(GSWDict    *p_pDict,
		  CONST char *p_pszKey,
		  CONST char *p_pszValue,
		  BOOL p_fValueOwner)
{
  GSWDict_Add(p_pDict,p_pszKey,(void *)p_pszValue,p_fValueOwner);
};

void
GSWDict_AddStringDup(GSWDict    *p_pDict,
		     CONST char *p_pszKey,
		     CONST char *p_pValue)
{
  GSWDict_Add(p_pDict,p_pszKey,strdup(p_pValue),TRUE);
};

static GSWDictElem *
GSWDict_FindKey(GSWDict    *p_pDict,
		CONST char *p_pszKey)
{
  int iIndex=0;
  GSWDictElem *pElem=NULL;
  if (!p_pDict)
    {
      GSWLog(GSW_CRITICAL,NULL,"NULL GSWDict");
    }
  else
    {
      for (pElem=p_pDict->pElems;iIndex<p_pDict->uCount;iIndex++,pElem++)
	if (pElem->pszKey && strcasecmp(pElem->pszKey,p_pszKey)==0)
	  return pElem;
    };
  return NULL;
};

void
GSWDict_RemoveKey(GSWDict    *p_pDict,
		  CONST char *p_pszKey)
{
  GSWDictElem *pElem=GSWDict_FindKey(p_pDict,p_pszKey);
  if (pElem)
    GSWDict_FreeElem(pElem,NULL);
}

CONST void *
GSWDict_ValueForKey(GSWDict    *p_pDict,
		    CONST char *p_pszKey)
{
  GSWDictElem *pElem=GSWDict_FindKey(p_pDict,p_pszKey);
  return (pElem) ? pElem->pValue : NULL;
};

void
GSWDict_PerformForAllElem(GSWDict *p_pDict,
			  void (*pFN)(GSWDictElem *p_pElem,void *p_pData),
			  void *p_pData)
{
  if (!p_pDict)
    {
      GSWLog(GSW_CRITICAL,NULL,"NULL GSWDict");
    }
  else
    {
      int i=0;
      GSWDictElem *pElem=NULL;
      for (pElem=p_pDict->pElems;i<p_pDict->uCount;i++,pElem++)
	{
	  if (pElem->pszKey)
	    pFN(pElem,p_pData);
	};
    };
};

GSWList *
GSWDict_AllKeys(GSWDict *p_pDict)
{
  GSWList *pList=NULL;
  if (!p_pDict)
    {
      GSWLog(GSW_CRITICAL,NULL,"NULL GSWDict");
    }
  else
    {
      int i=0;
      GSWDictElem *pElem=NULL;
      pList=GSWList_New(p_pDict->uCount);	
      for (pElem=p_pDict->pElems;i<p_pDict->uCount;i++,pElem++)
	{
	  if (pElem->pszKey)
	    GSWList_Add(pList,pElem->pszKey);
	};
    };
  return pList;
};

static void GSWDict_LogStringElem(GSWDictElem *p_pElem,
                                  void        *p_pLogServerData)
{
      GSWLog(GSW_DEBUG,p_pLogServerData,"%s=%s",p_pElem->pszKey,p_pElem->pValue);  
};

void GSWDict_Log(GSWDict *p_pDict,
                 void    *p_pLogServerData)
{
  GSWDict_PerformForAllElem(p_pDict,
			    GSWDict_LogStringElem,
			    p_pLogServerData);
};

