/* GSWString.c - GSWeb: Adaptors: String
   Copyright (C) 1999, 2000, 2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 	Jully 1999
   
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

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <sys/param.h>

#include "config.h"
#include "GSWUtil.h"
#include "GSWString.h"


//--------------------------------------------------------------------
GSWString *
GSWString_New()
{
  GSWString *pString = malloc(sizeof(GSWString));
  memset(pString,0,sizeof(GSWString));
  return pString;
};

//--------------------------------------------------------------------
void
GSWString_Free(GSWString *p_pString)
{
  if (p_pString)
    {
      if (p_pString->pszData)
	{
	  free(p_pString->pszData);
	  p_pString->pszData=NULL;
	};
      free(p_pString);
    };
};

//--------------------------------------------------------------------
int
GSWString_Len(GSWString *p_pString)
{
  return p_pString->iLen;
};

//--------------------------------------------------------------------
void
GSWString_Detach(GSWString *p_pString)
{
  memset(p_pString,0,sizeof(GSWString));
};

//--------------------------------------------------------------------
void
GSWString_GrowUpToSize(GSWString *p_pString,
		       int        p_iSize)
{
  if (p_iSize>p_pString->iSize)
    {
      if (!p_pString->pszData)
	{
	  p_pString->iSize=max(p_iSize,4096);
	  p_pString->pszData=malloc(p_pString->iSize);
	}
      else
	{
	  p_pString->iSize=max(p_iSize,4096);
	  p_pString->pszData=realloc(p_pString->pszData,p_pString->iSize);
	};
    };
};

//--------------------------------------------------------------------
void
GSWString_Append(GSWString  *p_pString,
		 CONST char *p_pszString)
{
  int iLen = strlen(p_pszString);	
  GSWString_GrowUpToSize(p_pString,p_pString->iLen+iLen+1);
  memcpy(p_pString->pszData+p_pString->iLen,p_pszString,iLen+1);
  p_pString->iLen+=iLen;
};

//--------------------------------------------------------------------
void
GSWString_SearchReplace(GSWString  *p_pString,
			CONST char *p_pszSearch,
			CONST char *p_pszReplace)
{
  int iSearchLen=SafeStrlen(p_pszSearch);
  if (iSearchLen>0)
    {
      char *p=strstr(p_pString->pszData,p_pszSearch);
      if (p)
	{
	  int iIndex=0;
	  int iReplaceLen=SafeStrlen(p_pszReplace);
	  int iDiff=iReplaceLen-iSearchLen;
	  while(p)
	    {
	      iIndex=p-p_pString->pszData;
	      if (iDiff>0)
		GSWString_GrowUpToSize(p_pString,p_pString->iSize+iDiff);
	      if (iDiff!=0)
		memmove(p_pString->pszData+iIndex+iReplaceLen,
			p_pString->pszData+iIndex+iSearchLen,
			p_pString->iLen-iIndex-iSearchLen+1);
	      if (iReplaceLen>0)
		memcpy(p_pString->pszData+iIndex,p_pszReplace,iReplaceLen);
	      p_pString->iLen+=iDiff;
	      p=strstr(p_pString->pszData+iIndex+iReplaceLen,p_pszSearch);
	    };
	};
    };
};
