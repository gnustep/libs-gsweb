/* GSWApp.h - GSWeb: Adaptors: GSWApp & GSWAppInstance
   Copyright (C) 2000, 2001, 2003 Free Software Foundation, Inc.
   
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

#ifndef _GSWApp_h__
#define _GSWApp_h__

typedef struct _GSWApp
{
  int     iUsageCounter;
  char   *pszName;
  GSWDict stInstancesDict;
  GSWDict stHeadersDict;
  char   *pszGSWExtensionsFrameworkWebServerResources;
  BOOL    fCanDump;
  char   *pszAdaptorTemplatesPath;
  int     iLastInstanceIndex;//Last Instance Index
} GSWApp;

typedef struct _GSWAppInstance
{
  GSWApp      *pApp;
  int          iInstance;
  char        *pszHostName;
  int          iPort;
  time_t       timeNextRetryTime;	// Timer
  unsigned int uOpenedRequestsNb;
  unsigned int uHandledRequestsNb;
  unsigned int uNotRespondingRequestsNb;
  BOOL         fValid;
} GSWAppInstance;

//--------------------------------------------------------------------
GSWApp *GSWApp_New();
void    GSWApp_Free(GSWApp *p_pApp);
void    GSWApp_FreeNotValidInstances(GSWApp *p_pApp);
void    GSWApp_AppsClearInstances(GSWDict *p_pAppsDict);
void    GSWApp_AddInstance(GSWApp         *p_pApp,
			   CONST char     *p_pszInstanceNum,
			   GSWAppInstance *p_pInstance);

//--------------------------------------------------------------------
GSWAppInstance *GSWAppInstance_New(GSWApp *p_pApp);
void            GSWAppInstance_Free(GSWAppInstance *p_pInstance);
BOOL            GSWAppInstance_FreeIFND(GSWAppInstance *p_pInstance);

//---------------------------------------------------------------------
typedef struct _GSWAppInfo
{
  BOOL isRefused;
  time_t timeNextRetryTime;			// next try to look, if it is not refused
} GSWAppInfo;

static GSWDict *_gswAppInfoDict = NULL;

void 		GSWAppInfo_Init();
GSWAppInfo     *GSWAppInfo_Find(char *pszName,int iInstance);
void 		GSWAppInfo_Add(GSWAppInfo *appInfoDict, CONST char *keyName);
void 		GSWAppInfo_Set(char *pszName, int iInstance, BOOL isRefused);
void 		GSWAppInfo_Remove(GSWAppInfo *_appInfo);


#endif // _GSWApp_h__

