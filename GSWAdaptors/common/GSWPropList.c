/* GSWPropList.c - GSWeb: Adaptors: GSWPropList
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		March 2000
   
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
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <errno.h>
#include "config.h"
#include "GSWUtil.h"
#include "GSWDict.h"
#include "GSWString.h"
#include "GSWUtil.h"
#include "GSWPropList.h"

//--------------------------------------------------------------------
CONST char* PLGetType(proplist_t pl)
{
  if (!pl)
	return "NULL";
  else if (PLIsDictionary(pl))
	return "Dictionary";
  else if (PLIsArray(pl))
	return "Array";
  else if (PLIsString(pl))
	return "String";
  else if (PLIsData(pl))
	return "Data";
  else if (PLIsSimple(pl))
	return "Simple";
  else if (PLIsCompound(pl))
	return "Compound";
  else
	return "Unknown";	
};

//--------------------------------------------------------------------
BOOL GSWPropList_TestDictionary(proplist_t pl,
								BOOL p_fErrorIfNotExists,
								CONST char* p_pszKey,
								CONST char* p_pszParents,
								void* p_pLogServerData)
{
  char* pszMsgInfo0=NULL;
  char* pszMsgInfo1=NULL;
  BOOL fOk=TRUE;
  if (pl)
	{
	  if (!PLIsDictionary(pl))
		{
		  CONST char* pszType=PLGetType(pl);
		  pszMsgInfo0=calloc(256+SafeStrlen(pszType),sizeof(char));
		  sprintf(pszMsgInfo0,"is not a dictionary its a %s:",pszType);
		  pszMsgInfo1=PLGetDescription(pl);//We have to free it
		  fOk=FALSE;
		};
	}
  else
	{
	  if (p_fErrorIfNotExists)
		{
		  pszMsgInfo0=strdup("not found");
		  fOk=FALSE;
		};
	};
  if (!fOk)
	{
	  GSWLogSized(GSW_CRITICAL,
				  p_pLogServerData,
				  256+SafeStrlen(p_pszParents)+SafeStrlen(p_pszKey)+SafeStrlen(pszMsgInfo0)+SafeStrlen(pszMsgInfo1),
				  "%s/%s %s %s",
				  (p_pszParents ? p_pszParents : ""),
				  (p_pszKey ? p_pszKey : ""),
				  (pszMsgInfo0 ? pszMsgInfo0 : ""),
				  (pszMsgInfo1 ? pszMsgInfo1 : ""));
	  if (pszMsgInfo0)
		free(pszMsgInfo0);
	  if (pszMsgInfo1)
		free(pszMsgInfo1);
	};
  return fOk;
};

//--------------------------------------------------------------------
BOOL GSWPropList_TestArray(proplist_t pl,
						   BOOL p_fErrorIfNotExists,
						   CONST char* p_pszKey,
						   CONST char* p_pszParents,
						   void* p_pLogServerData)
{
  char* pszMsgInfo0=NULL;
  char* pszMsgInfo1=NULL;
  BOOL fOk=TRUE;
  if (pl)
	{
	  if (!PLIsArray(pl))
		{
		  CONST char* pszType=PLGetType(pl);
		  pszMsgInfo0=calloc(256+SafeStrlen(pszType),sizeof(char));
		  sprintf(pszMsgInfo0,"is not an array its a %s:",pszType);
		  pszMsgInfo1=PLGetDescription(pl);//We have to free it
		  fOk=FALSE;
		};
	}
  else
	{
	  if (p_fErrorIfNotExists)
		{
		  pszMsgInfo0="not found";
		  fOk=FALSE;
		};
	};
  if (!fOk)
	{
	  GSWLogSized(GSW_CRITICAL,
				  p_pLogServerData,
				  256+SafeStrlen(p_pszParents)+SafeStrlen(p_pszKey)+SafeStrlen(pszMsgInfo0)+SafeStrlen(pszMsgInfo1),
				  "%s/%s %s %s",
				  (p_pszParents ? p_pszParents : ""),
				  (p_pszKey ? p_pszKey : ""),
				  (pszMsgInfo0 ? pszMsgInfo0 : ""),
				  (pszMsgInfo1 ? pszMsgInfo1 : ""));
	  if (pszMsgInfo0)
		free(pszMsgInfo0);
	  if (pszMsgInfo1)
		free(pszMsgInfo1);
	};
  return fOk;
};

//--------------------------------------------------------------------
BOOL GSWPropList_TestString(proplist_t pl,
							BOOL p_fErrorIfNotExists,
							CONST char* p_pszKey,
							CONST char* p_pszParents,
							void* p_pLogServerData)
{
  char* pszMsgInfo0=NULL;
  char* pszMsgInfo1=NULL;
  BOOL fOk=TRUE;
  if (pl)
	{
	  if (!PLIsString(pl))
		{
		  CONST char* pszType=PLGetType(pl);
		  pszMsgInfo0=calloc(256+SafeStrlen(pszType),sizeof(char));
		  sprintf(pszMsgInfo0,"is not a string its a %s:",pszType);
		  pszMsgInfo1=PLGetDescription(pl);//We have to free it
		  fOk=FALSE;
		};
	}
  else
	{
	  if (p_fErrorIfNotExists)
		{
		  pszMsgInfo0="not found";
		  fOk=FALSE;
		};
	};
  if (!fOk)
	{
	  GSWLogSized(GSW_CRITICAL,
				  p_pLogServerData,
				  256+SafeStrlen(p_pszParents)+SafeStrlen(p_pszKey)+SafeStrlen(pszMsgInfo0)+SafeStrlen(pszMsgInfo1),
				  "%s/%s %s %s",
				  (p_pszParents ? p_pszParents : ""),
				  (p_pszKey ? p_pszKey : ""),
				  (pszMsgInfo0 ? pszMsgInfo0 : ""),
				  (pszMsgInfo1 ? pszMsgInfo1 : ""));
	  if (pszMsgInfo0)
		free(pszMsgInfo0);
	  if (pszMsgInfo1)
		free(pszMsgInfo1);
	};
  return fOk;
};

//--------------------------------------------------------------------
//Do not destroy the returned proplist !
proplist_t GSWPropList_GetDictionaryEntry(proplist_t p_propListDictionary,
										  CONST char* p_pszKey,
										  CONST char* p_pszParents,
										  BOOL p_fErrorIfNotExists,
										  PLTypeTestFn p_pTestFn,
										  void* p_pLogServerData)
{
  proplist_t propListKey=PLMakeString((char*)p_pszKey);
  proplist_t propList=NULL;
  if (GSWPropList_TestDictionary(p_propListDictionary,TRUE,NULL,p_pszParents,p_pLogServerData))
	{
	  propList=PLGetDictionaryEntry(p_propListDictionary,propListKey);
	  if (p_pTestFn)
		{
		  if (!(*p_pTestFn)(propList,p_fErrorIfNotExists,p_pszKey,p_pszParents,p_pLogServerData))
			propList=NULL;
		};
	};
  PLRelease(propListKey);
  return propList;
};

//--------------------------------------------------------------------
//Do not destroy the returned proplist !
proplist_t GSWPropList_GetArrayElement(proplist_t p_propListArray,
											 int p_iIndex,
											 CONST char* p_pszParents,
											 BOOL p_fErrorIfNotExists,
											 PLTypeTestFn p_pTestFn,
											 void* p_pLogServerData)
{
  proplist_t propList=NULL;
  if (GSWPropList_TestArray(p_propListArray,TRUE,NULL,p_pszParents,p_pLogServerData))
	{
	  propList=PLGetArrayElement(p_propListArray,p_iIndex);
	  if (p_pTestFn)
		{
		  char szKey[120]="";
		  sprintf(szKey,"index: %d",p_iIndex);
		  if (!(*p_pTestFn)(propList,p_fErrorIfNotExists,szKey,p_pszParents,p_pLogServerData))
			propList=NULL;
		};
	};
  return propList;
};

//--------------------------------------------------------------------
//You have to free the returned proplist !
proplist_t GSWPropList_GetAllDictionaryKeys(proplist_t p_propListDictionary,
												  CONST char* p_pszParents,
												  BOOL p_fErrorIfNotExists,
												  PLTypeTestFn p_pTestFn,
												  void* p_pLogServerData)
{
  proplist_t propList=NULL;
  if (GSWPropList_TestDictionary(p_propListDictionary,TRUE,NULL,p_pszParents,p_pLogServerData))
	{
	  propList=PLGetAllDictionaryKeys(p_propListDictionary);
	  if (p_pTestFn)
		{
		  if (!(*p_pTestFn)(propList,p_fErrorIfNotExists,NULL,p_pszParents,p_pLogServerData))
			propList=NULL;
		};
	};
  return propList;
};
