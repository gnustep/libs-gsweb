/* GSWConfig.h - GSWeb: GSWeb Configuration Management
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

#ifndef _GSWConfig_h__
#define _GSWConfig_h__

#include <proplist.h>
#include <time.h>
#include "GSWList.h"

// AppName=Instance@Hostname:Port[ Key=Value]*

extern const char* g_szGSWeb_AdaptorVersion;

extern const char* g_szGSWeb_Prefix;
extern const char* g_szGSWeb_Handler;
extern const char* g_szGSWeb_AppExtention;

extern const char* g_szGSWeb_MimeType;
extern const char* g_szGSWeb_Conf_DocRoot;
extern const char* g_szGSWeb_Conf_ConfigFilePath;


// Apache
extern const char* g_szGSWeb_Conf_Alias;

// Netscape
extern const char* g_szGSWeb_Conf_PathTrans;
extern const char* g_szGSWeb_Conf_AppRoot;
extern const char* g_szGSWeb_Conf_Name;


extern const char* g_szGSWeb_DefaultConfigFilePath;
extern const char* g_szGSWeb_DefaultLogFilePath;
extern const char* g_szGSWeb_DefaultLogFlagPath;
extern const char* g_szGSWeb_DefaultDumpFlagPath;


extern const char* g_szGSWeb_DefaultGSWExtensionsFrameworkWebServerResources;

extern const char* g_szGSWeb_InstanceCookie;

extern const char* g_szGSWeb_Server;
extern const char* g_szGSWeb_ServerAndAdaptorVersion;

extern const char* g_szDumpConfFile_Head;
extern const char* g_szDumpConfFile_Foot;

extern const char* const g_szGNUstep;
extern const char* const g_szOKGSWeb;
extern const char* const g_szOKStatus;

extern const char* g_szErrorResponseHTMLTextTpl;

typedef struct _STGSWConfigEntry
{
  const char* pszAppName;
  int iInstance;
  const char* pszHostName;
  int iPort;
  GSWDict* pParams;
} STGSWConfigEntry;

typedef enum
{
  EGSWConfigResult__Error = -1,
  EGSWConfigResult__Ok = 0,
  EGSWConfigResult__NotChanged = 1
} EGSWConfigResult;

typedef enum
{
  EGSWConfigResult__Clear = 0,
  EGSWConfigResult__Add = 1
} EGSWConfigCallType;

typedef struct _GSWApp
{
  char* pszName;
  int iIndex;
  GSWList stInstances;
} GSWApp;

typedef struct _GSWAppInstance
{
  int iInstance;
  char* pszHost;
  int iPort;
  time_t timeNextRetryTime;			// Timer
  unsigned int uOpenedRequestsNb;
  BOOL fValid;
} GSWAppInstance;

extern proplist_t configKey__Applications;
extern proplist_t configKey__InstanceNum;
extern proplist_t configKey__Host;
extern proplist_t configKey__Port;
extern proplist_t configKey__Parameters;

EGSWConfigResult GSWConfig_ReadIFND(CONST char* p_pszConfigPath,
									time_t* p_pLastReadTime,
									proplist_t* p_ppPropList,
									void* p_pLogServerData);

proplist_t GSWConfig_GetApplicationsFromConfig(proplist_t p_propListConfig);
proplist_t GSWConfig_ApplicationKeyFromApplicationsKey(proplist_t p_propListApplicationsKeys,
													   int p_iIndex);
proplist_t GSWConfig_InstancesFromApplication(proplist_t p_propListApplication);
proplist_t GSWConfig_ApplicationFromApplications(proplist_t p_propListApplications,
												 proplist_t p_propListApplicationKey);
proplist_t GSWConfig_ApplicationsKeysFromApplications(proplist_t p_propListApplications);
proplist_t GSWConfig_ApplicationsKeysFromConfig(proplist_t p_propListConfig);
BOOL GSWConfig_PropListInstanceToInstanceEntry(STGSWConfigEntry* p_pInstanceEntry,
											   proplist_t p_propListInstance,
											   CONST char* p_pszAppName);

CONST char* GSWConfig_GetConfigFilePath();
void GSWConfig_SetConfigFilePath(CONST char* p_pszConfigFilePath);


#endif // _GSWConfig_h__

