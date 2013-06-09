/* GSWPropList.h - GSWeb: PropList
   Copyright (C) 2000, 2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 	March 2000
   
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

#ifndef _GSWPropList_h__
#define _GSWPropList_h__

#include <proplist.h>
#include <time.h>
#include "GSWList.h"

typedef BOOL (*PLTypeTestFn)(proplist_t  pl,
			     BOOL        p_fErrorIfNotExists,
			     CONST char *p_pszKey,
			     CONST char *p_pszParents,
			     void       *p_pLogServerData);

CONST char *PLGetType(proplist_t pl);
BOOL GSWPropList_TestDictionary(proplist_t  pl,
				BOOL        p_fErrorIfNotExists,
				CONST char *p_pszKey,
				CONST char *p_pszParents,
				void       *p_pLogServerData);
BOOL GSWPropList_TestArray(proplist_t  pl,
			   BOOL        p_fErrorIfNotExists,
			   CONST char *p_pszKey,
			   CONST char *p_pszParents,
			   void       *p_pLogServerData);
BOOL GSWPropList_TestString(proplist_t  pl,
			    BOOL        p_fErrorIfNotExists,
			    CONST char *p_pszKey,
			    CONST char *p_pszParents,
			    void       *p_pLogServerData);

//Do not destroy the returned proplist !
proplist_t GSWPropList_GetDictionaryEntry(proplist_t   p_propListDictionary,
					  CONST char  *p_pszKey,
					  CONST char  *p_pszParents,
					  BOOL         p_fErrorIfNotExists,
					  PLTypeTestFn p_pTestFn,
					  void        *p_pLogServerData);
//Do not destroy the returned proplist !
proplist_t GSWPropList_GetArrayElement(proplist_t   p_propListArray,
				       int          p_iIndex,
				       CONST char  *p_pszParents,
				       BOOL         p_fErrorIfNotExists,
				       PLTypeTestFn p_pTestFn,
				       void        *p_pLogServerData);
//You have to free the returned proplist !
proplist_t GSWPropList_GetAllDictionaryKeys(proplist_t  p_propListDictionary,
					    CONST char  *p_pszParents,
					    BOOL         p_fErrorIfNotExists,
					    PLTypeTestFn p_pTestFn,
					    void        *p_pLogServerData);

#endif //_GSWPropList_h__
