/* GSWLoadBalancing.c - GSWeb: Adaptors: Load Balancing
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jully 1999
   
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
#include "GSWDict.h"
#include "GSWList.h"
#include "GSWURLUtil.h"
#include "GSWConfig.h"
#include "GSWAppRequestStruct.h"
#include "GSWAppConnect.h"
#include "GSWHTTPRequest.h"
#include "GSWHTTPResponse.h"
#include "GSWAppRequest.h"
#include "GSWHTTPHeaders.h"
#include "GSWLoadBalancing.h"
#include "GSWLock.h"

static GSWLock g_lockAppList;
static GSWList* g_pAppList = NULL;



static time_t config_mtime = (time_t)0;

// Callback Functions
static int compareApps(CONST void *p1, CONST void *p2)
{
  GSWApp* pApp1=*(GSWApp**)p1;
  GSWApp* pApp2=*(GSWApp**)p2;
  return strcmp(pApp1->pszName,pApp2->pszName);
}

static int compareInstances(CONST void *p1, CONST void *p2)
{
  GSWAppInstance* pAppInstance1=*(GSWAppInstance**)p1;
  GSWAppInstance* pAppInstance2=*(GSWAppInstance**)p2;
  return (pAppInstance1->iInstance-pAppInstance2->iInstance);
}

static int compareAppNames(CONST void *p1, CONST void *p2)
{
  GSWApp* pApp=*(GSWApp**)p2;
  return strcmp((char*)p1,pApp->pszName);
}


void GSWLoadBalancing_Init(GSWDict* p_pDict)
{
  if (p_pDict)
	{
	  CONST char* pszPath=GSWDict_ValueForKey(p_pDict,g_szGSWeb_Conf_ConfigFilePath);
	  GSWConfig_SetConfigFilePath(pszPath);
	};

  GSWLock_Init(g_lockAppList);
};

static GSWLoadBalancing_ClearInstances()
{
  int iAppIndex=0;
  int iInstanceIndex=0;
  GSWApp *pApp = NULL;
  GSWAppInstance *pAppInstance = NULL;
  for (iAppIndex=0;iAppIndex<g_pAppList->uCount;iAppIndex++) 
	{
	  pApp = GSWList_ElementAtIndex(g_pAppList,iAppIndex);
	  for (iInstanceIndex=0;iInstanceIndex<pApp->stInstances.uCount;iInstanceIndex++)
		{
		  pAppInstance = GSWList_ElementAtIndex(&pApp->stInstances,iInstanceIndex);
		  pAppInstance->fValid=FALSE;
		};
	};
};
static EGSWConfigResult GSWLoadBalancing_NewInstance(STGSWConfigEntry* p_pConfigEntry,
													 void* p_pLogServerData)
{
  EGSWConfigResult eResult=EGSWConfigResult__Ok;
  int iAppIndex=0;
  int iInstanceIndex=0;
  GSWApp *pApp = NULL;
  GSWAppInstance *pAppInstance = NULL;
	
	
  if (p_pConfigEntry)
	{
	  BOOL fFound=FALSE;
	  for (iAppIndex=0;! fFound && iAppIndex<g_pAppList->uCount;iAppIndex++)
		{
		  pApp = GSWList_ElementAtIndex(g_pAppList,iAppIndex);
		  fFound=(strcmp(p_pConfigEntry->pszAppName,pApp->pszName)==0);
		};
	  if (!fFound)
		{
		  time_t now;
		  time(&now);
		  srand(now);		  
		  pApp=(GSWApp*)calloc(1,sizeof(GSWApp));
		  pApp->pszName=strdup(p_pConfigEntry->pszAppName);
		  pApp->iIndex = rand();
		  GSWList_Add(g_pAppList,pApp);
		};
	  fFound = 0;
	  for (iInstanceIndex=0;!fFound && iInstanceIndex<pApp->stInstances.uCount;iInstanceIndex++)
		{
		  pAppInstance = GSWList_ElementAtIndex(&(pApp->stInstances),iInstanceIndex);
		  if (pAppInstance->iInstance==p_pConfigEntry->iInstance)
			{
			  fFound=TRUE;
			  free(pAppInstance->pszHost);
			  pAppInstance->pszHost=NULL;
			  pAppInstance->pszHost=strdup(p_pConfigEntry->pszHostName);
			};
		};
	  if (!fFound)
		{
		  pAppInstance = (GSWAppInstance *)calloc(1,sizeof(GSWAppInstance));
		  pAppInstance->iInstance = p_pConfigEntry->iInstance;
		  pAppInstance->pszHost = strdup(p_pConfigEntry->pszHostName);
		  GSWList_Add(&pApp->stInstances,pAppInstance);
		};
	
	  pAppInstance->iPort = p_pConfigEntry->iPort;
	  pAppInstance->timeNextRetryTime=0;
	  pAppInstance->fValid=TRUE;
	  GSWLog(GSW_INFO,p_pLogServerData,
			 "Config: %s instance %d host %s port %d Valid:%s timeNextRetryTime? %d",
			 pApp->pszName,
			 pAppInstance->iInstance,
			 pAppInstance->pszHost,
			 pAppInstance->iPort,
			 (pAppInstance->fValid ? "YES" : "NO"),
			 pAppInstance->timeNextRetryTime);
	};
  return eResult;	
};


static void GSWLoadBalancing_VerifyConfiguration(void* p_pLogServerData)
{
  proplist_t propListConfig=NULL;
  if (!g_pAppList) 
	g_pAppList = GSWList_New(16);
  
  if (GSWConfig_ReadIFND(GSWConfig_GetConfigFilePath(),
						 &config_mtime,
						 &propListConfig,
						 p_pLogServerData)==EGSWConfigResult__Ok)
	{
	  proplist_t propListApps=NULL;
	  GSWLoadBalancing_ClearInstances();
	  propListApps=GSWConfig_GetApplicationsFromConfig(propListConfig);
	  if (propListApps)
		{
		  int iAppIndex=0;
		  int iInstanceIndex=0;
		  GSWApp* pApp=NULL;
		  GSWAppInstance* pAppInstance=NULL;
		  proplist_t propListAppsNames=GSWConfig_ApplicationsKeysFromApplications(propListApps);		  
		  unsigned int uAppNb=PLGetNumberOfElements(propListAppsNames);
		  for(iAppIndex=0;iAppIndex<uAppNb;iAppIndex++)
			{
			  proplist_t propListAppKey=GSWConfig_ApplicationKeyFromApplicationsKey(propListAppsNames,iAppIndex);
			  if (!propListAppKey)
				{
				  //TODO
				}
			  else
				{
				  CONST char* pszAppName=PLGetString(propListAppKey);
				  proplist_t propListApp=GSWConfig_ApplicationFromApplications(propListApps,
																							   propListAppKey);
				  if (!propListApp)
					{
					  GSWLog(GSW_ERROR,p_pLogServerData,"no ppropListApp");
					  //TODO
					}
				  else
					{
					  proplist_t propListInstances=GSWConfig_InstancesFromApplication(propListApp);
					  if (!propListInstances)
						{
						  GSWLog(GSW_ERROR,p_pLogServerData,"no propListInstances");
						  //TODO
						}
					  else
						{
						  unsigned int uInstancesNb=PLGetNumberOfElements(propListInstances);
					  
						  for(iInstanceIndex=0;iInstanceIndex<uInstancesNb;iInstanceIndex++)
							{
							  proplist_t propListInstance=PLGetArrayElement(propListInstances,iInstanceIndex);
							  if (!propListInstance)
								{
								  GSWLog(GSW_ERROR,p_pLogServerData,"no propListInstance");
								  //TODO
								}
							  else if (!PLIsDictionary(propListInstance))
								{
								  GSWLog(GSW_ERROR,p_pLogServerData,"propListInstance is not a dictionary");
								}
							  else
								{
								  STGSWConfigEntry stEntry;
								  GSWConfig_PropListInstanceToInstanceEntry(&stEntry,
																			propListInstance,
																			pszAppName);
								  GSWLoadBalancing_NewInstance(&stEntry,p_pLogServerData);
								};
							};
						};
					};
				};
			};
		  // Changed !
		  for (iAppIndex=g_pAppList->uCount-1;iAppIndex>=0;iAppIndex--)
			{
			  pApp=GSWList_ElementAtIndex(g_pAppList,iAppIndex);
			  for (iInstanceIndex=pApp->stInstances.uCount-1;iInstanceIndex>=0;iInstanceIndex--)
				{
				  pAppInstance = GSWList_ElementAtIndex(&pApp->stInstances,iInstanceIndex);
				  if (!pAppInstance->fValid)
					{
					  GSWLog(GSW_INFO,p_pLogServerData,"Removing %s instance %d %s",
							 pApp->pszName,
							 pAppInstance->iInstance,
							 pAppInstance->pszHost);
					  GSWList_RemoveAtIndex(&pApp->stInstances,iInstanceIndex);
					  if (pAppInstance->uOpenedRequestsNb==0)
						{
						  free(pAppInstance->pszHost);
						  pAppInstance->pszHost=NULL;
						  free(pAppInstance);
						  pAppInstance=NULL;
						};
					};
				};
			  if (pApp->stInstances.uCount==0)
				{
				  GSWList_RemoveAtIndex(g_pAppList,iAppIndex);
				  GSWLog(GSW_INFO,p_pLogServerData,"Removing application %s as there is no instance left.",
						 pApp->pszName);
				}
			  else
				{
				  GSWList_Sort(&pApp->stInstances,compareInstances);
				  for (iInstanceIndex=0;iInstanceIndex<pApp->stInstances.uCount-1;iInstanceIndex++)
					{
					  GSWAppInstance* pAppInstance0=GSWList_ElementAtIndex(&pApp->stInstances,iInstanceIndex);
					  GSWAppInstance* pAppInstance1=GSWList_ElementAtIndex(&pApp->stInstances,iInstanceIndex+1);
					  if (pAppInstance0->iInstance == pAppInstance1->iInstance)
						{
						  GSWLog(GSW_ERROR,
								 p_pLogServerData,
								 "Configuration error: instance numbers must be unique:\n\t(%s:%d@%s) == (%s:%d@%s)",
								 pApp->pszName,pAppInstance0->iInstance,
								 pAppInstance0->pszHost,
								 pApp->pszName,pAppInstance1->iInstance,
								 pAppInstance1->pszHost);
						};
					};
				};
			};
		  GSWList_Sort(g_pAppList,compareApps);
		};
	};
};

BOOL GSWLoadBalancing_FindApp(void* p_pLogServerData,GSWAppRequest *p_pAppRequest)
{
  BOOL fFound=FALSE;
  GSWApp* pApp=NULL;
  
  GSWLock_Lock(g_lockAppList);
  GSWLoadBalancing_VerifyConfiguration(p_pLogServerData);  
  pApp = GSWList_BSearch(g_pAppList,
						 p_pAppRequest->pszName,
						 compareAppNames);
  if (pApp)
	{
	  int iTries=pApp->stInstances.uCount;
	  GSWAppInstance* pAppInstance=NULL;
	  time_t curTime = (time_t)0;
	  
	  while (!fFound && iTries-->0)
		{
		  pApp->iIndex = (pApp->iIndex+1) % pApp->stInstances.uCount;
		  pAppInstance=GSWList_ElementAtIndex((&pApp->stInstances),pApp->iIndex);
		  if (pAppInstance->timeNextRetryTime!=0)
			{
			  if (!curTime)
				time(&curTime);
			  if (pAppInstance->timeNextRetryTime<curTime)
				{
				  GSWLog(GSW_INFO,
						 p_pLogServerData,
						 "LoadBalance: Instance %s:%d was marked dead for %d secs. Now resurecting !",
						 p_pAppRequest->pszName, 
						 pAppInstance->iInstance,
						 APP_CONNECT_RETRY_DELAY);
				  pAppInstance->timeNextRetryTime=0;
				};
			};
		  if (pAppInstance->timeNextRetryTime==0 && pAppInstance->fValid)
			{
			  fFound = TRUE;
			  strcpy(p_pAppRequest->pszName,pApp->pszName);
			  p_pAppRequest->iInstance = pAppInstance->iInstance;
			  p_pAppRequest->pszHost = pAppInstance->pszHost;
			  p_pAppRequest->iPort = pAppInstance->iPort;
			  p_pAppRequest->eType = EAppType_LoadBalanced;
			  p_pAppRequest->pLoadBalancingData = pAppInstance;
			  pAppInstance->uOpenedRequestsNb++;
			};
		};
	};
  GSWLock_Unlock(g_lockAppList);
  
  if (fFound)
	GSWLog(GSW_INFO,p_pLogServerData,"LoadBalance: looking for %s, fFound instance %d on %s:%d",
		   p_pAppRequest->pszName,
		   p_pAppRequest->iInstance,
		   p_pAppRequest->pszHost,
		  p_pAppRequest->iPort);
  else
	GSWLog(GSW_INFO,p_pLogServerData,"LoadBalance: looking for %s, Not Found",
		   p_pAppRequest->pszName);
  return fFound;
};

BOOL GSWLoadBalancing_FindInstance(void* p_pLogServerData,GSWAppRequest *p_pAppRequest)
{
  BOOL fFound=FALSE;
  GSWApp* pApp=NULL;
  int i=0;
  GSWLock_Lock(g_lockAppList);
  GSWLoadBalancing_VerifyConfiguration(p_pLogServerData);
	
  pApp=GSWList_BSearch(g_pAppList,p_pAppRequest->pszName,compareAppNames);
  if (pApp)
	{
	  GSWAppInstance* pAppInstance=NULL;
	  for (i=0;i<pApp->stInstances.uCount && !fFound;i++)
		{
		  pAppInstance = GSWList_ElementAtIndex((&pApp->stInstances),i);
		  if (pAppInstance->iInstance
			  && pAppInstance->iInstance==p_pAppRequest->iInstance
			  && pAppInstance->fValid)
			{
			  fFound=TRUE;
			  p_pAppRequest->iInstance = pAppInstance->iInstance;
			  p_pAppRequest->pszHost = pAppInstance->pszHost;
			  p_pAppRequest->iPort = pAppInstance->iPort;
			  p_pAppRequest->eType = EAppType_LoadBalanced;
			  p_pAppRequest->pLoadBalancingData = pAppInstance;
			  pAppInstance->uOpenedRequestsNb++;		
			};
		};
	};
  GSWLock_Unlock(g_lockAppList);
  return fFound;
};

void GSWLoadBalancing_MarkNotRespondingApp(void* p_pLogServerData,GSWAppRequest *p_pAppRequest)
{
  GSWAppInstance* pAppInstance;
  time_t now;
  time(&now);
  pAppInstance = (GSWAppInstance *)p_pAppRequest->pLoadBalancingData;
  pAppInstance->uOpenedRequestsNb--;
  pAppInstance->timeNextRetryTime=now+APP_CONNECT_RETRY_DELAY;
  GSWLog(GSW_WARNING,p_pLogServerData,"Marking %s unresponsive",p_pAppRequest->pszName);
}

void GSWLoadBalancing_StartAppRequest(void* p_pLogServerData,GSWAppRequest *p_pAppRequest)
{
  GSWAppInstance* pAppInstance=(GSWAppInstance*)p_pAppRequest->pLoadBalancingData;
  if (pAppInstance->timeNextRetryTime!=0)
	{
	  pAppInstance->timeNextRetryTime=0;
	  GSWLog(GSW_WARNING,p_pLogServerData,"Marking %s as alive",p_pAppRequest->pszName);
	};
}

void GSWLoadBalancing_StopAppRequest(void* p_pLogServerData,GSWAppRequest *p_pAppRequest)
{
  GSWAppInstance* pAppInstance=(GSWAppInstance*)p_pAppRequest->pLoadBalancingData;
  GSWLock_Lock(g_lockAppList);
  pAppInstance->uOpenedRequestsNb--;
  if (!pAppInstance->fValid && pAppInstance->uOpenedRequestsNb==0)
	{
	  GSWLog(GSW_ERROR,p_pLogServerData,"Not deleted (not implemented) %s (%d)",
			 p_pAppRequest->pszName,
			 p_pAppRequest->iInstance);
	};
  GSWLock_Unlock(g_lockAppList);
  p_pAppRequest->pLoadBalancingData = NULL;
};

