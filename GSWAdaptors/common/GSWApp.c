/* GSWApp.c - GSWeb: Adaptors: GSWApp & GSWAppInstance
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
#include "GSWApp.h"

void GSWApp_InternFreeNotValidInstances(GSWDictElem* p_pElem,void* p_pData);
void GSWApp_InternClearInstances(GSWDictElem* p_pElem,void* p_pData);
void GSWAppInstance_InternClear(GSWDictElem* p_pElem,void* p_pData);

//====================================================================
//--------------------------------------------------------------------
GSWApp* GSWApp_New()
{
  GSWApp* pApp=(GSWApp*)calloc(1,sizeof(GSWApp));
  memset(pApp,0,sizeof(GSWApp));
  pApp->iUsageCounter++;
  return pApp;
};

//--------------------------------------------------------------------
void GSWApp_Free(GSWApp* p_pApp)
{
  if (!p_pApp)
	GSWLog(GSW_CRITICAL,NULL,"No App to free");
  else
	{
	  p_pApp->iUsageCounter--;
	  if (p_pApp->iUsageCounter<0)
		GSWLog(GSW_CRITICAL,NULL,"App  seems to have been freed too much times");
	  if (p_pApp->iUsageCounter<=0)
		{
		  if (p_pApp->pszName)
			free(p_pApp->pszName);
		  if (p_pApp->pszGSWExtensionsFrameworkWebServerResources)
			free(p_pApp->pszGSWExtensionsFrameworkWebServerResources);
                  if (p_pApp->pszAdaptorTemplatesPath)
                    free(p_pApp->pszAdaptorTemplatesPath);
		  GSWDict_FreeElements(&p_pApp->stInstancesDict);
		  GSWDict_FreeElements(&p_pApp->stHeadersDict);
		  free(p_pApp);
		};
	};
};

//--------------------------------------------------------------------
void GSWApp_AddInstance(GSWApp* p_pApp,CONST char* p_pszInstanceNum,GSWAppInstance* p_pInstance)
{
  if (!p_pApp)
	{
	  GSWLog(GSW_CRITICAL,NULL,"No App to add instance");
	}
  else if (!p_pInstance)
	{
	  GSWLog(GSW_CRITICAL,NULL,"No instance to add");
	}
  else
	{
	  if (p_pInstance->pApp!=p_pApp)
		{
		  GSWLog(GSW_CRITICAL,NULL,"Trying to add instance to another app");
		  if (p_pInstance->pApp)
			p_pInstance->pApp->iUsageCounter--;
		  p_pInstance->pApp=p_pApp;
		  p_pInstance->pApp->iUsageCounter++;
		};
	  GSWDict_Add(&p_pApp->stInstancesDict,p_pszInstanceNum,p_pInstance,FALSE);//NotOwner
	};
};

//--------------------------------------------------------------------
void GSWApp_InternFreeNotValidInstances(GSWDictElem* p_pElem,void* p_pData)
{
  GSWDict* pInstancesDict=(GSWDict*)p_pData;
  GSWAppInstance* pInstance=(GSWAppInstance*)p_pElem->pValue;
  if (!pInstance->fValid)
	{
	  GSWDict_RemoveKey(pInstancesDict,p_pElem->pszKey);
	  if (GSWAppInstance_FreeIFND(pInstance))
		pInstance=NULL;
	};
};

//--------------------------------------------------------------------
void GSWApp_FreeNotValidInstances(GSWApp* p_pApp)
{
  GSWDict_PerformForAllElem(&p_pApp->stInstancesDict,
							GSWApp_InternFreeNotValidInstances,
							&p_pApp->stInstancesDict);
};

//--------------------------------------------------------------------
void GSWApp_InternClearInstances(GSWDictElem* p_pElem,void* p_pData)
{
  GSWApp* pApp=(GSWApp*)(p_pElem->pValue);
  GSWDict_PerformForAllElem(&pApp->stInstancesDict,
							GSWAppInstance_InternClear,
							NULL);
};

//--------------------------------------------------------------------
void GSWApp_AppsClearInstances(GSWDict* p_pAppsDict)
{
  GSWDict_PerformForAllElem(p_pAppsDict,
							GSWApp_InternClearInstances,
							NULL);
};

//====================================================================
//--------------------------------------------------------------------
GSWAppInstance* GSWAppInstance_New(GSWApp* p_pApp)
{
  GSWAppInstance* pInstance=(GSWAppInstance*)calloc(1,sizeof(GSWAppInstance));
  memset(pInstance,0,sizeof(GSWAppInstance));
  if (!p_pApp)
	GSWLog(GSW_CRITICAL,NULL,"Intance %p created without App",
		   pInstance);
  pInstance->pApp=p_pApp;
  return pInstance;
};



//--------------------------------------------------------------------
void GSWAppInstance_Free(GSWAppInstance* p_pInstance)
{
  if (p_pInstance)
	{
	  if (p_pInstance->pszHostName)
		free(p_pInstance->pszHostName);
	  if (p_pInstance->pApp)
		{
		  char szBuffer[128]="";
		  sprintf(szBuffer,"%d",p_pInstance->iInstance);
		  if (GSWDict_ValueForKey(&p_pInstance->pApp->stInstancesDict,szBuffer)==p_pInstance)
			GSWDict_RemoveKey(&p_pInstance->pApp->stInstancesDict,szBuffer);
		  p_pInstance->pApp->iUsageCounter--;
		};
	  free(p_pInstance);
	};  
};

//--------------------------------------------------------------------
BOOL GSWAppInstance_FreeIFND(GSWAppInstance* p_pInstance)
{
  if (p_pInstance->uOpenedRequestsNb==0)
	{
	  GSWAppInstance_Free(p_pInstance);
	  return TRUE;
	}
  else
	return FALSE;
};

//--------------------------------------------------------------------
void GSWAppInstance_InternClear(GSWDictElem* p_pElem,void* p_pData)
{
  GSWAppInstance* pInstance=(GSWAppInstance*)(p_pElem->pValue);
  pInstance->fValid=FALSE;
};

//--------------------------------------------------------------------
//--------------------------------------------------------------------

void GSWAppInfo_Init()
{
	if (_gswAppInfoDict == NULL) {
		_gswAppInfoDict = GSWDict_New(50);		// allows 50 different instances of apps
	}
}

//--------------------------------------------------------------------
char* GSWAppInfo_MakeDictKeyName(char* pszName, int iInstance)
{
	char	*name = NULL;

    if (name = calloc(1,50)) {
		if (pszName) {
			strncpy(name, pszName,45);
                        name[45]=0;
		}
		sprintf(name + strlen(name), "%d", iInstance);

	}
    return name;
}

//--------------------------------------------------------------------
GSWAppInfo* GSWAppInfo_Find(char* pszName, int iInstance)
{
	char	*name;
	GSWAppInfo* newInfo = NULL;

	if (_gswAppInfoDict == NULL) {
		GSWAppInfo_Init();
		return NULL;
	}

	name = GSWAppInfo_MakeDictKeyName(pszName, iInstance);
	if (name) {
		newInfo = GSWDict_ValueForKey(_gswAppInfoDict, name);
		free(name); name = NULL;
	}

	return newInfo;
}

//--------------------------------------------------------------------
void GSWAppInfo_Add(GSWAppInfo* appInfoDict, CONST char* keyName)
{
    if (appInfoDict) {
		GSWDict_Add(_gswAppInfoDict, keyName, appInfoDict, TRUE);
	}
}

//--------------------------------------------------------------------
void GSWAppInfo_Set(char* pszName, int iInstance, BOOL isRefused)
{
	char	*name;
	GSWAppInfo* newInfo = GSWAppInfo_Find(pszName, iInstance);
	time_t curTime = (time_t)0;
	BOOL	addDict = FALSE;

	if (newInfo == NULL) {
		newInfo=(GSWAppInfo*)calloc(1,sizeof(GSWAppInfo));
		addDict = TRUE;
	}

    if (newInfo && (name = GSWAppInfo_MakeDictKeyName(pszName, iInstance) )) {
		newInfo->isRefused = isRefused;
		time(&curTime);
		newInfo->timeNextRetryTime = curTime + 10;	// + 10 sec

		if (addDict == TRUE) {
			GSWAppInfo_Add(newInfo, name);
		}
		free(name); name = NULL;
	} else {
		if (newInfo) {
			free(newInfo); newInfo = NULL;
		}
	}
}

//--------------------------------------------------------------------
void GSWAppInfo_Remove(GSWAppInfo* _appInfo)
{
}


