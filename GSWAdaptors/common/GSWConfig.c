/* GSWConfig.c - GSWeb: Adaptors: Config
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

static char rcsId[] = "$Id$";

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
#include "GSWURLUtil.h"
#include "GSWUtil.h"
#include "GSWConfig.h"
#include "GSWPropList.h"
#include "GSWTemplates.h"

#if defined(__DATE__) && defined(__TIME__)
static const char g_szAdaptorBuilt[] = __DATE__ " " __TIME__;
#else
static const char g_szAdaptorBuilt[] = "unknown";
#endif

 
const char* g_szGSWeb_AdaptorVersion=GSWEB_SERVER_ADAPTOR_VERSION_MAJOR_STRING "." GSWEB_SERVER_ADAPTOR_VERSION_MINOR_STRING;

const char* g_szGSWeb_Prefix=GSWEB_PREFIX;
const char* g_szGSWeb_Handler=GSWEB_HANDLER;
const char* g_szGSWeb_StatusResponseAppName=GSWEB_STATUS_RESPONSE_APP_NAME;
const char* g_szGSWeb_AppExtention=GSWAPP_EXTENSION;

const char* g_szGSWeb_MimeType=GSWEB__MIME_TYPE;
//const char* g_szGSWeb_Conf_DocRoot=GSWEB_CONF__DOC_ROOT;
const char* g_szGSWeb_Conf_ConfigFilePath=GSWEB_CONF__CONFIG_FILE_PATH;


// Apache
#if defined(Apache)
const char* g_szGSWeb_Conf_Alias=GSWEB_CONF__ALIAS;
#endif

// Netscape
#if	defined(Netscape)
const char* g_szGSWeb_Conf_PathTrans=GSWEB_CONF__PATH_TRANS;
const char* g_szGSWeb_Conf_AppRoot=GSWEB_CONF__APP_ROOT;
const char* g_szGSWeb_Conf_Name=GSWEB_CONF__NAME;
#endif

const char* g_szGSWeb_InstanceCookie=GSWEB_INSTANCE_COOKIE;

const char* g_szGSWeb_Server=SERVER;
const char* g_szGSWeb_ServerAndAdaptorVersion=SERVER "/" GSWEB_SERVER_ADAPTOR_VERSION_MAJOR_STRING "." GSWEB_SERVER_ADAPTOR_VERSION_MINOR_STRING;


const char* const g_szGNUstep = "GNUstep";

#if GSWEB_WONAMES
const char* const g_szOKGSWeb = "OK Apple";
const char* const g_szOKStatus = "HTTP/1.0 200 OK Apple GSWeb";
#else
const char* const g_szOKGSWeb = "OK GSWeb";
const char* const g_szOKStatus = "HTTP/1.0 200 OK GNUstep GSWeb";
#endif

#if	defined(Apache)
#define GSWServerVersion		ap_get_server_version()
#define GSWServerBuilt			ap_get_server_built()
#define GSWServerURL			"http://www.apache.org"
#else
#define GSWServerVersion		"Unknown"
#define GSWServerBuilt			"Unknown"
#define GSWServerURL			"http://www.gnustepweb.org"
#endif

//====================================================================
GSWLock g_lockAppList=NULL;
static GSWDict* g_pAppDict = NULL;
static time_t config_mtime = (time_t)0;
static GSWConfig g_gswConfig;
static char g_szServerStringInfo[1024]="";
static char g_szAdaptorStringInfo[1024]="";
//--------------------------------------------------------------------
void GSWConfig_Init(GSWDict* p_pDict)
{
  memset(&g_gswConfig,0,sizeof(g_gswConfig));
  sprintf(g_szServerStringInfo,"%s v %s built %s",
		  g_szGSWeb_Server,
		  GSWServerVersion,		  
		  GSWServerBuilt);
  sprintf(g_szAdaptorStringInfo,"GNUstepWeb v %s built %s",
		  g_szGSWeb_AdaptorVersion,
		  g_szAdaptorBuilt);
  if (p_pDict)
	{
	  CONST char* pszPath=GSWDict_ValueForKey(p_pDict,g_szGSWeb_Conf_ConfigFilePath);
	  GSWConfig_SetConfigFilePath(pszPath);
	};
  GSWLock_Init(g_lockAppList);
};

//--------------------------------------------------------------------
GSWConfig* GSWConfig_GetConfig()
{
  return &g_gswConfig;
};

//--------------------------------------------------------------------
BOOL GSWConfig_CanDumpStatus()
{
  return g_gswConfig.fCanDumpStatus;
};

//--------------------------------------------------------------------
void GSWConfig_SetConfigFilePath(CONST char* p_pszConfigFilePath)
{
  if (g_gswConfig.pszConfigFilePath)
	{
	  free(g_gswConfig.pszConfigFilePath);
	  g_gswConfig.pszConfigFilePath=NULL;
	};
  if (p_pszConfigFilePath)
	g_gswConfig.pszConfigFilePath=strdup(p_pszConfigFilePath);
  else
	{
	  GSWLog(GSW_CRITICAL,NULL,
			 "GSWeb: No path for config file. Add a %s directive in your web server configuration",
			 g_szGSWeb_Conf_ConfigFilePath);
	};
};

//--------------------------------------------------------------------
CONST char* GSWConfig_GetConfigFilePath()
{
  return g_gswConfig.pszConfigFilePath;
};


/*{
    canDumpStatus=NO;
    GSWExtensionsFrameworkWebServerResources="/GSW/GSWExtensions/WebServerResources"
	applications=	{
				MyApp1 = {
				        GSWExtensionsFrameworkWebServerResources="/GSW/GSWExtensions/WebServerResources"
						instances = 	{
									1 = {
										host=12.13.14.15;
										port=9001;
										parameters=	{ 
													transport=socket;
												};			
									};
									2 = {
										host=12.13.14.21;
										port=9001;
										parameters=	{ 
													transport=socket;
												};			
									}
								};
					};
				MyApp2 = {
						instances = 	{
									1 = {
										host=12.13.14.15;
										port=9001;
										parameters=	{ 
													transport=socket;
												};			
									};
								};
					};
				MyApp3 = {
						canDump = YES;
						instances = 	{
									1 = {
										host=12.13.14.15;
										port=9002;
										parameters=	{ 
													transport=socket;
												};
									};
								};
					};
	};
};
*/

//--------------------------------------------------------------------
//Read configuration from p_pszConfigPath if the file changed since p_pLastReadTime 
//	and return the config into p_ppPropList
EGSWConfigResult GSWConfig_ReadIFND(CONST char* p_pszConfigPath,
									time_t* p_pLastReadTime,
									proplist_t* p_ppPropList,//Please, PLRelease it after used !
									void* p_pLogServerData)
{
  EGSWConfigResult eResult=EGSWConfigResult__Ok;
  p_pLogServerData=NULL;//General Log
  if (!p_pszConfigPath)
	{
	  GSWLog(GSW_CRITICAL,p_pLogServerData,"GSWeb: No path for config file.");
	  eResult=EGSWConfigResult__Error;
	}
  else
	{
	  time_t timeNow=(time_t)0;
	  time_t timePrevious=*p_pLastReadTime;	  
	  time(&timeNow);

	  if (timeNow-timePrevious<CONFIG_FILE_STAT_INTERVAL)
		{
		  GSWLog(GSW_INFO,p_pLogServerData,
				 "GSWeb: GSWConfig_ReadIFND: Not Reading : Less than %d sec since last read config file.",
				 (int)CONFIG_FILE_STAT_INTERVAL);
		  eResult=EGSWConfigResult__NotChanged;
        }
	  else
		{
		  struct stat stStat;
		  memset(&stStat,0,sizeof(stStat));
		  if (stat(p_pszConfigPath, &stStat) == 0)
			{
			  *p_pLastReadTime = timeNow;
			  if (stStat.st_mtime>timePrevious) 
				{
				  GSWLog(GSW_INFO,p_pLogServerData,
						 "GSWeb: GSWConfig_ReadIFND: Reading new configuration from %s",
						 p_pszConfigPath);

				  *p_ppPropList=PLGetProplistWithPath(p_pszConfigPath);
				  if (*p_ppPropList)
					{
					  GSWLog(GSW_WARNING,p_pLogServerData,
							 "GSWeb: GSWConfig_ReadIFND: New configuration from %s readen",
							 p_pszConfigPath);
					}
				  else
				    {
				      GSWLog(GSW_CRITICAL,p_pLogServerData,
					     "Can't read configuration file %s (PLGetProplistWithPath).",
					     p_pszConfigPath);
				    };
				}
			  else
				{
				  GSWLog(GSW_INFO,p_pLogServerData,
						 "GSWeb: GSWConfig_ReadIFND: Not Reading : config file not modified since last read.");
				  eResult=EGSWConfigResult__NotChanged;
				}
			}
		  else
			{
			  GSWLog(GSW_CRITICAL,p_pLogServerData,
					 "GSWeb: GSWConfig_ReadIFND: config file %s does not exist.",
					 p_pszConfigPath);
			  eResult=EGSWConfigResult__Error;
			};
		};
	};
  GSWLog(GSW_INFO,p_pLogServerData,"GSWeb: GSWConfig_ReadIFND: result= %d",(int)eResult);
  return eResult;
};

//--------------------------------------------------------------------
BOOL GSWConfig_PropListHeadersToHeaders(GSWDict* p_pHeaders,
										proplist_t p_propListHeaders,
										CONST char* p_pszParents,
										void* p_pLogServerData)
{
  BOOL fOk=TRUE;
  char pszParents[4096]="";
  //Headers
  //	{
  //		header1=1234;
  //		header2=4567;
  //	};
  if (p_propListHeaders)
	{
	  int iHeaderIndex=0;
	  proplist_t propListHeadersNames=NULL;
	  unsigned int uHeaderNb=0;
	  sprintf(pszParents,"%s",p_pszParents);
	  //Next get Array Of Headers Names
	  //header1,header2
	  //We'll have to destroy propListHeadersNames
	  propListHeadersNames=GSWPropList_GetAllDictionaryKeys(p_propListHeaders,
																  pszParents,
																  TRUE,
																  GSWPropList_TestArray,
																  p_pLogServerData);
	  //Nb Of Headers
	  uHeaderNb=PLGetNumberOfElements(propListHeadersNames);
	  //For Each Header
	  for(iHeaderIndex=0;iHeaderIndex<uHeaderNb;iHeaderIndex++)
		{
		  //Get Header Name Key
		  proplist_t propListHeaderKey=GSWPropList_GetArrayElement(propListHeadersNames,
																		 iHeaderIndex,
																		 pszParents,
																		 TRUE,
																		 GSWPropList_TestString,
																		 p_pLogServerData);
		  if (!propListHeaderKey)
			{
			  //TODO
			}
		  else
			{
			  //Get Headerlication Name (MyHeader1)
			  CONST char* pszHeaderName=PLGetString(propListHeaderKey);//Do Not Free It
			  proplist_t propListHeader=GSWPropList_GetDictionaryEntry(p_propListHeaders,
																			 pszHeaderName,
																			 pszParents,
																			 TRUE,//Error If Not Exists
																			 GSWPropList_TestString,
																			 p_pLogServerData);
			  if (propListHeader)
				{
				  //Get Header Value (1234)
				  CONST char* pszHeaderValue=PLGetString(propListHeader);//Do Not Free It
				  GSWDict_AddStringDup(p_pHeaders,pszHeaderName,pszHeaderValue);
				};
			};
		};
	  PLRelease(propListHeadersNames);//Because it's a newly created proplist
	};
  return fOk;
};

//--------------------------------------------------------------------
BOOL GSWConfig_PropListInstanceToInstance(GSWAppInstance* p_pInstance,
										  proplist_t p_propListInstance,
										  GSWApp* p_pApp,
										  int p_iInstanceNum,
										  CONST char* p_pszParents,
										  void* p_pLogServerData)
{
  BOOL fOk=TRUE;
  proplist_t pValue=NULL;
  char pszParents[4096]="";
  p_pInstance->fValid=TRUE;
  p_pInstance->timeNextRetryTime=0;

  // Instance Num
  sprintf(pszParents,"%s",p_pszParents);
  p_pInstance->iInstance=p_iInstanceNum;
						  
  // Host Name
  sprintf(pszParents,"%s",p_pszParents);
  pValue=GSWPropList_GetDictionaryEntry(p_propListInstance,
										"host",
										pszParents,
										TRUE,//Error If Not Exists
										GSWPropList_TestString,
										p_pLogServerData);
  if (pValue)
	{
	  if (p_pInstance->pszHostName)
		free(p_pInstance->pszHostName);
	  p_pInstance->pszHostName=SafeStrdup(PLGetString(pValue));//Do Not Free It PLGetStringValue, so strdup it
	};

  // Port
  sprintf(pszParents,"%s",p_pszParents);
  pValue=GSWPropList_GetDictionaryEntry(p_propListInstance,
											  "port",
											  pszParents,
											  TRUE,//Error If Not Exists
											  GSWPropList_TestString,
											  p_pLogServerData);
  if (pValue)
	{
	  char* pszPort=PLGetString(pValue);//Do Not Free It
	  if (pszPort)
		{
		  p_pInstance->iPort=atoi(pszPort);
		};
	};
  GSWLog(GSW_INFO,p_pLogServerData,
		 "Config: App=%p %s instance %d host %s port %d Valid:%s timeNextRetryTime %d",
		 p_pApp,
		 p_pApp->pszName,
		 p_pInstance->iInstance,
		 p_pInstance->pszHostName,
		 p_pInstance->iPort,
		 (p_pInstance->fValid ? "YES" : "NO"),
		 (int)p_pInstance->timeNextRetryTime);

  return fOk;
};

//--------------------------------------------------------------------
BOOL GSWConfig_PropListApplicationToApplication(GSWApp* p_pApp,
												proplist_t p_propListApp,
												CONST char* p_pszAppName,
												CONST char* p_pszParents,
												void* p_pLogServerData)
{
  BOOL fOk=TRUE;
  char pszParents[4096]="";
  proplist_t pValueCanDump=NULL;
  if (p_pApp->pszName)
	free(p_pApp->pszName);
  p_pApp->pszName=SafeStrdup(p_pszAppName);//We'll own the AppName
  // CanDump
  sprintf(pszParents,"%s/%s",p_pszParents,p_pszAppName);
  pValueCanDump=GSWPropList_GetDictionaryEntry(p_propListApp,
													 "canDump",
													 pszParents,
													 FALSE,//No Error If Not Exists
													 GSWPropList_TestString,
													 p_pLogServerData);
  p_pApp->fCanDump=NO;
  if (pValueCanDump)
	{
	  CONST char* pszCanDump=PLGetString(pValueCanDump);//Do Not Free It
	  p_pApp->fCanDump=(strcasecmp(pszCanDump,"YES")==0);
	};
  //GSWExtensionsFrameworkWebServerResources
  {
	proplist_t pValuePath=NULL;
	if (p_pApp->pszGSWExtensionsFrameworkWebServerResources)
	  {
		free(p_pApp->pszGSWExtensionsFrameworkWebServerResources);
		p_pApp->pszGSWExtensionsFrameworkWebServerResources=NULL;
	  };
	pValuePath=GSWPropList_GetDictionaryEntry(p_propListApp,
											  "GSWExtensionsFrameworkWebServerResources",
											  NULL,
											  FALSE,//No Error If Not Exists
											  GSWPropList_TestString,
											  p_pLogServerData);
	if (pValuePath)
	  {
		CONST char* pszPath=PLGetString(pValuePath);//Do Not Free It
		p_pApp->pszGSWExtensionsFrameworkWebServerResources=SafeStrdup(pszPath);
	  };
  };
/*  // LogFilePath
  sprintf(pszParents,"%s/%s",p_pszParents,p_pszAppName);
  pValueLogFilePath=GSWPropList_GetDictionaryEntry(p_propListApp,
														 "logFilePath",
														 pszParents,
														 FALSE,//No Error If Not Exists
														 GSWPropList_TestString,
														 p_pLogServerData);
  if (pValueLogFilePath)
	{
	  p_pApp->pszLogFilePath=PLGetString(pValueLogFilePath);//Do Not Free It
	};
*/
  //Headers
  //	{
  //		header1=1234;
  //		header2=4567;
  //	};
  
  {
	proplist_t propListHeaders=NULL;
	sprintf(pszParents,"%s/%s",p_pszParents,p_pszAppName);
	propListHeaders=GSWPropList_GetDictionaryEntry(p_propListApp,
														 "headers",
														 pszParents,
														 FALSE,//No Error If Not Exists
														 GSWPropList_TestDictionary,
														 p_pLogServerData);
	sprintf(pszParents,"%s/%s",p_pszParents,p_pszAppName);
	fOk=GSWConfig_PropListHeadersToHeaders(&p_pApp->stHeadersDict,
										   propListHeaders,
										   pszParents,
										   p_pLogServerData);
  };

  //Instances
  //	{
  //		1 = {
  //			host=12.13.14.15;
  //			port=9001;
  //			parameters=	{ 
  //							transport=socket;
  //						};			
  //		};
  //		2 = {
  //			host=12.13.14.21;
  //			port=9001;
  //			parameters=	{ 
  //							transport=socket;
  //						};			
  //		}
  //	};

  {
	proplist_t propListInstances=NULL;
	sprintf(pszParents,"%s/%s",p_pszParents,p_pszAppName);
	propListInstances=GSWPropList_GetDictionaryEntry(p_propListApp,
														   "instances",
														   pszParents,
														   TRUE,//Error If Not Exists
														   GSWPropList_TestDictionary,
														   p_pLogServerData);
	if (propListInstances)
	  {
		int iInstanceIndex=0;
		//Next get Array Of Instances Names
		//1,3,5
		//We'll have to destroy propListInstancesNums
		proplist_t propListInstancesNums=GSWPropList_GetAllDictionaryKeys(propListInstances,
																				pszParents,//Parents
																				TRUE,//Error If Not Exists
																				GSWPropList_TestArray,//TestFn
																				p_pLogServerData);
		if (propListInstancesNums)
		  {
			//Nb Of Instances
			unsigned int uInstancesNb=PLGetNumberOfElements(propListInstancesNums);
			//For Each Instance
			for(iInstanceIndex=0;iInstanceIndex<uInstancesNb;iInstanceIndex++)
			  {
				//Get Instance Num Key
				proplist_t propListInstanceNumKey=GSWPropList_GetArrayElement(propListInstancesNums,
																					iInstanceIndex,
																					pszParents,
																					TRUE,
																					GSWPropList_TestString,//TestFn
																					p_pLogServerData);
				if (propListInstanceNumKey)
				  {
					//Get Instance Num (1)
					CONST char* pszInstanceNum=PLGetString(propListInstanceNumKey);//Do Not Free It
					proplist_t propListInstance=NULL;
					
					//Get Instance PropList
					//							{
					//								host=12.13.14.15;
					//								port=9001;
					//								parameters=	{ 
					//												transport=socket;
					//											};			
					//							};
					propListInstance=GSWPropList_GetDictionaryEntry(propListInstances,
																	pszInstanceNum,
																	pszParents,
																	TRUE,
																	GSWPropList_TestDictionary,
																	p_pLogServerData);
					
					if (propListInstance)
					  {
						BOOL fNew=NO;
						GSWAppInstance* pInstance=(GSWAppInstance*)GSWDict_ValueForKey(&p_pApp->stInstancesDict,
																					   pszInstanceNum);
						if (!pInstance)
							{
							  fNew=YES;
							  pInstance=GSWAppInstance_New(p_pApp);
							};
						GSWConfig_PropListInstanceToInstance(pInstance,
															 propListInstance,
															 p_pApp,
															 atoi(pszInstanceNum),
															 pszParents,
															 p_pLogServerData);
						if (fNew)
						  GSWApp_AddInstance(p_pApp,pszInstanceNum,pInstance);
					  };
				  };
			  };
			PLRelease(propListInstancesNums);//Because it's a newly created proplist
		  };
	  };
  };
  //Remove Not Valid Instances
  GSWApp_FreeNotValidInstances(p_pApp);
  return fOk;
};

//--------------------------------------------------------------------
BOOL GSWConfig_LoadConfiguration(void* p_pLogServerData)
{
  BOOL fOk=TRUE;
  proplist_t propListConfig=NULL;
  p_pLogServerData=NULL;
  GSWLock_Lock(g_lockAppList);
  if (!g_pAppDict) 
	g_pAppDict = GSWDict_New(16);
  
  if (GSWConfig_ReadIFND(GSWConfig_GetConfigFilePath(),
						 &config_mtime,
						 &propListConfig,//We'll have to PLRelease it
						 p_pLogServerData)==EGSWConfigResult__Ok)
	{
	  proplist_t propListApps=NULL;
	  GSWApp_AppsClearInstances(g_pAppDict);
	  
	  //CanDumpStatus
	  {
		proplist_t pValueCanDumpStatus=NULL;
		g_gswConfig.fCanDumpStatus=NO;
		pValueCanDumpStatus=GSWPropList_GetDictionaryEntry(propListConfig,
														   "canDumpStatus",
														   NULL,
														   FALSE,//No Error If Not Exists
														   GSWPropList_TestString,
														   p_pLogServerData);
		if (pValueCanDumpStatus)
		  {
			CONST char* pszCanDumpStatus=PLGetString(pValueCanDumpStatus);//Do Not Free It
			g_gswConfig.fCanDumpStatus=(strcasecmp(pszCanDumpStatus,"YES")==0);
		  };
	  };

	  //GSWExtensionsFrameworkWebServerResources
	  {
		proplist_t pValuePath=NULL;
		if (g_gswConfig.pszGSWExtensionsFrameworkWebServerResources)
		  {
			free(g_gswConfig.pszGSWExtensionsFrameworkWebServerResources);
			g_gswConfig.pszGSWExtensionsFrameworkWebServerResources=NULL;
		  };
		pValuePath=GSWPropList_GetDictionaryEntry(propListConfig,
												  "GSWExtensionsFrameworkWebServerResources",
												  NULL,
												  FALSE,//No Error If Not Exists
												  GSWPropList_TestString,
												  p_pLogServerData);
		if (pValuePath)
		  {
			CONST char* pszPath=PLGetString(pValuePath);//Do Not Free It
			g_gswConfig.pszGSWExtensionsFrameworkWebServerResources=SafeStrdup(pszPath);
		  };
	  };


	  //Get Dictionary Of Applications
	  //           {
	  //				MyApp1 = {
	  //						instances = 	(
	  //									{
	  //										instanceNum=1;
	  //										host=12.13.14.15;
	  //										port=9001;
	  //										parameters=	{ 
	  //													transport=socket;
	  //												};			
	  //									},
	  //									{
	  //										instanceNum=2;
	  //										host=12.13.14.21;
	  //										port=9001;
	  //										parameters=	{ 
	  //													transport=socket;
	  //												};			
	  //									}
	  //								);
	  //					};
	  //				MyApp2 = {
	  //						instances = 	(
	  //									{
	  //										instanceNum=1;
	  //										host=12.13.14.15;
	  //										port=9001;
	  //										parameters=	{ 
	  //													transport=socket;
	  //												};			
	  //									}
	  //								);
	  //					};
	  //				MyApp3 = {
	  //						canDump = YES;
	  //						instances = 	(
	  //									{
	  //										instanceNum=1;
	  //										host=12.13.14.15;
	  //										port=9002;
	  //										parameters=	{ 
	  //													transport=socket;
	  //												};
	  //									}
	  //								);
	  //			};
	  propListApps=GSWPropList_GetDictionaryEntry(propListConfig,//Dictionary
														"applications",//Key
														NULL,//No Parents
														TRUE,//Error If Not Exists
														GSWPropList_TestDictionary, // Test Fn
														p_pLogServerData);
	  if (propListApps)
		{
		  int iAppIndex=0;
		  //Next get Array Of App Names
		  //MyApp1,MyApp2,MyApp3
		  //We'll have to destroy propListAppsNames
		  proplist_t propListAppsNames=GSWPropList_GetAllDictionaryKeys(propListApps,
																			  "applications",//Parents
																			  TRUE,//Error If Not Exists
																			  GSWPropList_TestArray,//TestFn
																			  p_pLogServerData);
		  if (propListAppsNames)
			{
			  //Nb Of App
			  unsigned int uAppNb=PLGetNumberOfElements(propListAppsNames);
			  //For Each Application
			  for(iAppIndex=0;iAppIndex<uAppNb;iAppIndex++)
				{
				  //Get Application Name Key
				  proplist_t propListAppKey=GSWPropList_GetArrayElement(propListAppsNames,
																			  iAppIndex,
																			  "applications",
																			  TRUE,
																			  GSWPropList_TestString,//TestFn
																			  p_pLogServerData);
				  if (propListAppKey)
					{
					  //Get Application Name (MyApp1)
					  CONST char* pszAppName=PLGetString(propListAppKey);//Do Not Free It
					  proplist_t propListApp=NULL;

					  //Get Application PropList
					  //	{
					  //		instances = 	(
					  //							{
					  //								instanceNum=1;
					  //								host=12.13.14.15;
					  //								port=9001;
					  //								parameters=	{ 
					  //												transport=socket;
					  //											};			
					  //							},
					  //							{
					  //								instanceNum=2;
					  //								host=12.13.14.21;
					  //								port=9001;
					  //								parameters=	{ 
					  //												transport=socket;
					  //											};			
					  //							}
					  //						);
					  //	};				  
					  propListApp=GSWPropList_GetDictionaryEntry(propListApps,
																	   pszAppName,
																	   "applications",
																	   TRUE,
																	   GSWPropList_TestDictionary,
																	   p_pLogServerData);
					  if (propListApp)
						{
						  BOOL fNew=NO;
						  GSWApp* pApp=(GSWApp*)GSWDict_ValueForKey(g_pAppDict,pszAppName);
						  if (!pApp)
							{
							  fNew=YES;
							  pApp=GSWApp_New();
							};
						  GSWConfig_PropListApplicationToApplication(pApp,
																	 propListApp,
																	 pszAppName,
																	 "applications",
																	 p_pLogServerData);
						  if (GSWDict_Count(&pApp->stInstancesDict)==0)
							{
							  if (!fNew)
								GSWDict_RemoveKey(g_pAppDict,pApp->pszName);
							  GSWApp_Free(pApp);
							  pApp=NULL;
							}
						  else 
							{
							  if (fNew)
								GSWDict_Add(g_pAppDict,pApp->pszName,pApp,FALSE);//NotOwner
							};
						};
					};
				};
			  PLRelease(propListAppsNames);//Because it's a newly created proplist			  
			};
		};
	};
  if (propListConfig)
	PLRelease(propListConfig);
  {
	GSWString* pString=GSWConfig_DumpGSWApps(NULL,g_szGSWeb_Prefix,TRUE,FALSE,p_pLogServerData);
	GSWLogSized(GSW_INFO,p_pLogServerData,SafeStrlen(pString->pszData),"Config: %s",pString->pszData);
	GSWString_Free(pString);
  };
  GSWLock_Unlock(g_lockAppList);
  return fOk;
};

//--------------------------------------------------------------------
typedef struct _GSWDumpParams
{
  GSWString* pBuffer;
  GSWApp* pApp;
  CONST char* pszPrefix;
  BOOL fForceDump;
  BOOL fHTML;
  void* pLogServerData;
} GSWDumpParams;


//--------------------------------------------------------------------
void GSWConfig_DumpGSWAppInstanceIntern(GSWDictElem* p_pElem,void* p_pData)
{  
  GSWString* pBuffer=GSWString_New();
  char szBuffer[4096]="";
  GSWAppInstance* pAppInstance=(GSWAppInstance*)p_pElem->pValue;
  GSWDumpParams* pParams=(GSWDumpParams*)p_pData;
  //Template
  GSWString_Append(pBuffer,GSWTemplate_GetDumpAppInstance(pParams->fHTML));
  
  //NUM
  sprintf(szBuffer,"%d",
		  pAppInstance->iInstance);
  GSWString_SearchReplace(pBuffer,"##NUM##",szBuffer);
  
  //URL
  sprintf(szBuffer,"%s/%s/%d",
		  pParams->pszPrefix,
		  pParams->pApp->pszName,
		  pAppInstance->iInstance);
  GSWString_SearchReplace(pBuffer,"##URL##",szBuffer);

  //Host
  GSWString_SearchReplace(pBuffer,"##HOST##",pAppInstance->pszHostName);

  //Host
  sprintf(szBuffer,"%d",pAppInstance->iPort);
  GSWString_SearchReplace(pBuffer,"##PORT##",szBuffer);

  //InstanceHeader
  //TODO
  
  GSWTemplate_ReplaceStd(pBuffer,pAppInstance->pApp);
  //Append !
  GSWString_Append(pParams->pBuffer,pBuffer->pszData);
  GSWString_Free(pBuffer);  
  pBuffer=NULL;
};

//--------------------------------------------------------------------
void GSWConfig_DumpGSWAppIntern(GSWDictElem* p_pElem,void* p_pData)
{
  GSWApp* pApp=(GSWApp*)(p_pElem->pValue);
  GSWDumpParams* pParams=(GSWDumpParams*)p_pData;
  if (pParams->fForceDump || pApp->fCanDump)
	{
	  GSWString* pBuffer=GSWString_New();
	  char szBuffer[4096]="";
	  	  
	  //Template
	  GSWString_Append(pBuffer,GSWTemplate_GetDumpApp(pParams->fHTML));
	  
	  //AppName
	  GSWString_SearchReplace(pBuffer,"##NAME##",pApp->pszName);
	  
	  //AppURL
	  sprintf(szBuffer,"%s/%s",pParams->pszPrefix,pApp->pszName);
	  GSWString_SearchReplace(pBuffer,"##URL##",szBuffer);
	  	  
	  //AppHeader
	  //TODO
	  
	  //AppInstances
	  {
		GSWString* pInstancesBuffer=GSWString_New();
		GSWString* pParamsBuffer=pParams->pBuffer;
		pParams->pBuffer=pInstancesBuffer;
		pParams->pApp=pApp;  
		GSWDict_PerformForAllElem(&pApp->stInstancesDict,
								  GSWConfig_DumpGSWAppInstanceIntern,
								  pParams);
		GSWString_SearchReplace(pBuffer,"##INSTANCES##",pInstancesBuffer->pszData);
		pParams->pBuffer=pParamsBuffer;
		GSWString_Free(pInstancesBuffer);
		pInstancesBuffer=NULL;
		pParams->pApp=NULL;
	  };
	  
	  GSWTemplate_ReplaceStd(pBuffer,pApp);
	  
	  //Append !
	  GSWString_Append(pParams->pBuffer,pBuffer->pszData);
	  GSWString_Free(pBuffer);  
	  pBuffer=NULL;
	};
};

//--------------------------------------------------------------------
GSWString* GSWConfig_DumpGSWApps(const char* p_pszReqApp,
								 const char* p_pszPrefix,
								 BOOL p_fForceDump,
								 BOOL p_fHTML,
								 void* p_pLogServerData)
{
  GSWString* pBuffer=GSWString_New();
  GSWDumpParams stParams;
  GSWLock_Lock(g_lockAppList);

  stParams.pBuffer=GSWString_New();
  stParams.pApp=NULL;
  stParams.pszPrefix=p_pszPrefix;
  stParams.fForceDump=p_fForceDump;
  stParams.fHTML=p_fHTML;
  stParams.pLogServerData=p_pLogServerData;

  //Template Head
  GSWString_Append(pBuffer,GSWTemplate_GetDumpHead(p_fHTML));
  GSWString_SearchReplace(pBuffer,"##APP_NAME##",p_pszReqApp);

  GSWTemplate_ReplaceStd(pBuffer,NULL);
  
  GSWString_Append(stParams.pBuffer,pBuffer->pszData);
  GSWString_Free(pBuffer);  
  pBuffer=NULL;

  GSWDict_PerformForAllElem(g_pAppDict,
							GSWConfig_DumpGSWAppIntern,
							&stParams);
  //Template Foot
  pBuffer=GSWString_New();
  GSWString_Append(pBuffer,GSWTemplate_GetDumpFoot(p_fHTML));
  GSWTemplate_ReplaceStd(pBuffer,NULL);
  GSWString_Append(stParams.pBuffer,pBuffer->pszData);
  GSWString_Free(pBuffer);  
  pBuffer=NULL;
  GSWLock_Unlock(g_lockAppList);
  return stParams.pBuffer;
};

//--------------------------------------------------------------------
GSWApp* GSWConfig_GetApp(CONST char* p_pszAppName)
{
  return (GSWApp*)GSWDict_ValueForKey(g_pAppDict,p_pszAppName);
};

//--------------------------------------------------------------------
CONST char* GSWConfig_AdaptorBuilt()
{
  return g_szAdaptorBuilt;
};

//--------------------------------------------------------------------
CONST char* GSWConfig_ServerStringInfo()
{
  return g_szServerStringInfo;
};

//--------------------------------------------------------------------
CONST char* g_szGSWeb_AdaptorStringInfo()
{
  return g_szAdaptorStringInfo;
};

//--------------------------------------------------------------------
CONST char* GSWConfig_ServerURL()
{
  return GSWServerURL;
};

//--------------------------------------------------------------------
CONST char* g_szGSWeb_AdaptorURL()
{
  return "http://www.gnustepweb.org";
};
