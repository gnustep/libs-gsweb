/* GSWString.h - GSWeb: String
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

#ifndef _GSWString_h__
#define _GSWString_h__

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

typedef struct _GSWString
{
  int   iSize;
  int   iLen;
  char *pszData;
} GSWString;

GSWString *GSWString_New(void);
int GSWString_Len(GSWString *p_pString);
void GSWString_Free(GSWString *p_pString);
void GSWString_Detach(GSWString *p_pString);
void GSWString_Append(GSWString  *p_pString,
		      CONST char *p_pszString);
void GSWString_SearchReplace(GSWString  *p_pString,
			     CONST char *p_pszSearch,
			     CONST char *p_pszReplace);
#ifdef __cplusplus
} // end of C header
#endif //_cplusplus

#endif // _GSWString_h__

