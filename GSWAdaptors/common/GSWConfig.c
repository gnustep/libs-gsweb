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
#include "GSWURLUtil.h"
#include "GSWUtil.h"
#include "GSWConfig.h"

#define MAX_LENGTH_CONF_LINE 1024

static const int timeIntervalBetweenStats = CONFIG_FILE_STAT_INTERVAL;

const char* g_szGSWeb_AdaptorVersion=GSWEB_SERVER_ADAPTOR_VERSION_MAJOR_STRING "." GSWEB_SERVER_ADAPTOR_VERSION_MINOR_STRING;

const char* g_szGSWeb_Prefix=GSWEB_PREFIX;
const char* g_szGSWeb_Handler=GSWEB_HANDLER;
const char* g_szGSWeb_AppExtention=GSWAPP_EXTENSION;

const char* g_szGSWeb_MimeType=GSWEB__MIME_TYPE;
const char* g_szGSWeb_Conf_DocRoot=GSWEB_CONF__DOC_ROOT;
const char* g_szGSWeb_Conf_ConfigFilePath=GSWEB_CONF__CONFIG_FILE_PATH;


// Apache
const char* g_szGSWeb_Conf_Alias=GSWEB_CONF__ALIAS;

// Netscape
const char* g_szGSWeb_Conf_PathTrans=GSWEB_CONF__PATH_TRANS;
const char* g_szGSWeb_Conf_AppRoot=GSWEB_CONF__APP_ROOT;
const char* g_szGSWeb_Conf_Name=GSWEB_CONF__NAME;




const char* g_szGSWeb_DefaultConfigFilePath=DEFAULT_CONFIG_FILE_PATH;
const char* g_szGSWeb_DefaultLogFilePath=DEFAULT_LOG_FILE_PATH;
const char* g_szGSWeb_DefaultLogFlagPath=DEFAULT_LOG_FLAG_PATH;
const char* g_szGSWeb_DefaultDumpFlagPath=DEFAULT_DUMP_FLAG_PATH;

const char* g_szGSWeb_DefaultGSWExtensionsFrameworkWebServerResources=DEFAULT_GSWEXTENSIONS_FRAMEWORK_WEB_SERVER_RESOURCES;


const char* g_szGSWeb_InstanceCookie=GSWEB_INSTANCE_COOKIE;

const char* g_szGSWeb_Server=SERVER;
const char* g_szGSWeb_ServerAndAdaptorVersion=SERVER "/" GSWEB_SERVER_ADAPTOR_VERSION_MAJOR_STRING "." GSWEB_SERVER_ADAPTOR_VERSION_MINOR_STRING;

const char* g_szDumpConfFile_Head="<HTML><HEAD><TITLE>Index of GNUstepWeb Applications</TITLE></HEAD>\n"
"<BODY BGCOLOR=\"#FFFFFF\">"
"<CENTER><H3>Could not find the application specified in the URL (%s).</H3>\n"
"<H4>Index of GNUstepWeb Applications in %s (some applications may be down)</H4>\n"
"<table border=1>"
"<tr>\n"
"<td align=center rowspan=2>Name</td>"
"<td align=center rowspan=2>Application Access</td>"
"<td align=center colspan=3>Instances</td>"
"</tr>\n"
"<tr>\n"
"<td align=center>#</td>"
"<td align=center>Host</td>"
"<td align=center>Port</td>"
"</tr>\n";

const char* g_szDumpConfFile_Foot="</table></CENTER>\n"
"<BR>\n"
"<CENTER><A HREF=\"http://www.gnustep.org\"><IMG SRC=\"%s/PoweredByGNUstepWeb.gif\" ALT=\"Powered By GNUstepWeb\" BORDER=0></A></CENTER>\n"
"</BODY></HTML>";


const char* const g_szGNUstep = "GNUstep";
const char* const g_szOKGSWeb = "OK GSWeb";
const char* const g_szOKStatus = "HTTP/1.0 200 OK GNUstep GSWeb";


const char* g_szErrorResponseHTMLTextTpl = "<HTML><BODY BGCOLOR=\"#FFFFFF\"><CENTER><H1>%s</H1></CENTER></BODY></HTML>\n";

static char *g_pszConfigFilePath = NULL;

proplist_t configKey__Applications=NULL;
proplist_t configKey__Instances=NULL;
proplist_t configKey__InstanceNum=NULL;
proplist_t configKey__Host=NULL;
proplist_t configKey__Port=NULL;
proplist_t configKey__Parameters=NULL;


void GSWConfig_Init()
{
  if (!configKey__Applications)
	{
	  configKey__Applications=PLMakeString("applications");
	  configKey__Instances=PLMakeString("instances");
	  configKey__InstanceNum=PLMakeString("instanceNum");
	  configKey__Host=PLMakeString("host");
	  configKey__Port=PLMakeString("port");
	  configKey__Parameters=PLMakeString("parameters");  
	};
};

/*
 *	parse: <appname>=[-]<instance_number>@<hostname>:<port> [<key>=<Value>]*
 */
static EGSWConfigResult GSWConfig_GetEntryComponentsFromLine(char* p_pszLine,char** p_ppszComponents)
{
  EGSWConfigResult eResult=EGSWConfigResult__Ok;

  // Skip Spaces
  while (*p_pszLine && isspace(*p_pszLine))
	p_pszLine++;

  if (!*p_pszLine)
	eResult=EGSWConfigResult__Error;
  else
	{
	  // AppName
	  p_ppszComponents[0] = p_pszLine;
	  while (*p_pszLine && *p_pszLine!='=')
		p_pszLine++;
	  // Found End of AppName ?
	  if (*p_pszLine!='=')
		eResult=EGSWConfigResult__Error;
	  else
		{
		  *p_pszLine++=0;
		  DeleteTrailingSpaces(p_ppszComponents[0]);

		  // Skip Spaces
		  while (*p_pszLine && isspace(*p_pszLine))
			p_pszLine++;
		  if (!*p_pszLine)
			eResult=EGSWConfigResult__Error;
		  else
			{
			  p_ppszComponents[1]=p_pszLine;
			  if (*p_pszLine=='-')
				p_pszLine++;
			  while (*p_pszLine && isdigit(*p_pszLine))
				p_pszLine++;

			  if (!*p_pszLine)
				eResult=EGSWConfigResult__Error;
			  else
				{
				  // End of Instance
				  *p_pszLine++ = '\0';
				  while (*p_pszLine && isspace(*p_pszLine))
					p_pszLine++;
				  
				  if (*p_pszLine!='@')
					eResult=EGSWConfigResult__Error;
				  else
					{
					  // Host
					  p_ppszComponents[2]=p_pszLine;
					  while (*p_pszLine && !isspace(*p_pszLine) && *p_pszLine!=':')
						p_pszLine++;
					  if (!*p_pszLine)
						eResult=EGSWConfigResult__Error;
					  else
						{
						  // End of host
						  *p_pszLine++ = '\0';
						};
					  // Skip Spaces
					  while (*p_pszLine && isspace(*p_pszLine))
						p_pszLine++;

					  if (*p_pszLine!=':')
						eResult=EGSWConfigResult__Error;
					  else
						{
						  p_pszLine++; // Skip :

						  // Port Number
						  if (*p_pszLine && isdigit(*p_pszLine))
							{
							  p_ppszComponents[3]=p_pszLine;
							  while (*p_pszLine && isdigit(*p_pszLine))
								p_pszLine++;
							  if (*p_pszLine)
								{
								  *p_pszLine=0;
								  p_pszLine++;

								  // Skip Spaces
								  while (*p_pszLine && isspace(*p_pszLine))
									p_pszLine++;

								  if (*p_pszLine)
									p_ppszComponents[4] = p_pszLine;
								  else
									p_ppszComponents[4] = NULL;
								};
							};
						};
					};
				};
			};
		};
	};
  return eResult;
};

static int GSWConfig_ReadLine(FILE* p_pFile,char* p_pszBuffer,int p_iBufferSize)
{
  int iReaden=0;
  if (fgets(p_pszBuffer,p_iBufferSize,p_pFile))
	{
	  iReaden = strlen(p_pszBuffer);
	  while (iReaden && isspace(p_pszBuffer[iReaden]))
		iReaden--;
	  if (p_pszBuffer[iReaden] == '\\') // Continued ?
		iReaden+=GSWConfig_ReadLine(p_pFile,p_pszBuffer+iReaden,p_iBufferSize-iReaden);
	};
  return iReaden;
};

static EGSWConfigResult GSWConfig_ReadEntries(CONST char* p_pszConfigPath,
											  EGSWConfigResult (*p_pFNConfigEntry)(EGSWConfigCallType p_eCallType,
																				   STGSWConfigEntry* p_pConfigEntry,
																				   void* p_pLogServerData),
											  void* p_pLogServerData)
{
  EGSWConfigResult eResult=EGSWConfigResult__Ok;
  if (!p_pszConfigPath)
	{
	  eResult=EGSWConfigResult__Error;
	}
  else
	{
	  FILE* pFile=fopen(p_pszConfigPath,"r");
	  if (!pFile)
		{
		  GSWLog(GSW_ERROR,p_pLogServerData,
				 "Can't open configuration file %s. Error=%d (%s)",
				 p_pszConfigPath,
				 errno,
				 strerror(errno));
		  eResult=EGSWConfigResult__Error;
		}
	  else
		{
		  eResult=p_pFNConfigEntry(EGSWConfigResult__Clear,NULL,p_pLogServerData);
		  if (eResult==EGSWConfigResult__Ok)
			{
			  STGSWConfigEntry stEntry;
			  char* szComponents[5]={ "","","","",""};
			  char szLine[MAX_LENGTH_CONF_LINE+1]="";
			  int iLine = 0;
			  while (GSWConfig_ReadLine(pFile,szLine,MAX_LENGTH_CONF_LINE)>0 && eResult==EGSWConfigResult__Ok)
				{
				  memset(&stEntry,0,sizeof(stEntry));
				  memset(szComponents,0,sizeof(szComponents)); //??
				  memset(szLine,0,sizeof(szLine)); //??
				  iLine++;
				  if (szLine[0]!='#' && szLine[0] != '\n')
					{
					  if (GSWConfig_GetEntryComponentsFromLine(szLine,szComponents)!=EGSWConfigResult__Ok)
						{
						  GSWLog(GSW_ERROR,p_pLogServerData,
								 "Invalid entry in configuration at line %d: (%s)",
								 iLine,
								 szLine);
						}
					  else
						{
						  stEntry.pszAppName = szComponents[0];
						  stEntry.iInstance = atoi(szComponents[1]);
						  stEntry.pszHostName = szComponents[2];
						  stEntry.iPort = atoi(szComponents[3]);
						  if (szComponents[4])
							{
							  // TODO
							  GSWLog(GSW_WARNING,p_pLogServerData,
									 "Parameter at line %d ignored. (%s)",
									 iLine,
									 szComponents[4]);
							};
						  eResult=p_pFNConfigEntry(EGSWConfigResult__Add,
												   &stEntry,
												   p_pLogServerData);
						};
					};
				};
			};
		};
	  fclose(pFile);
	};
	return eResult;
}

EGSWConfigResult GSWConfig_ReadIFND(CONST char* p_pszConfigPath,
									time_t* p_pLastReadTime,
									proplist_t* p_ppPropList,
									void* p_pLogServerData)
{
  EGSWConfigResult eResult=EGSWConfigResult__Ok;
  if (!p_pszConfigPath)
	{
	  GSWLog(GSW_ERROR,p_pLogServerData,"GSWeb: No path for config file.");
	  eResult=EGSWConfigResult__Error;
	}
  else
	{
	  time_t timeNow=(time_t)0;
	  time_t timePrevious=*p_pLastReadTime;	  
	  time(&timeNow);
	  GSWLog(GSW_ERROR,p_pLogServerData,"config file");

	  if (timeNow-timePrevious<timeIntervalBetweenStats)
		{
		  GSWLog(GSW_INFO,p_pLogServerData,
				 "GSWeb: GSWConfig_ReadIFND: Not Reading : Less than %d sec since last read config file.",
				 timeIntervalBetweenStats);
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
				  if (!*p_ppPropList)
				    {
				      GSWLog(GSW_ERROR,p_pLogServerData,
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
			  GSWLog(GSW_INFO,p_pLogServerData,
					 "GSWeb: GSWConfig_ReadIFND: config file %s does not exist.",
					 p_pszConfigPath);
			  eResult=EGSWConfigResult__Error;
			};
		};
	};
  return eResult;
};

proplist_t GSWConfig_GetApplicationsFromConfig(proplist_t p_propListConfig)
{
  proplist_t propListApps=PLGetDictionaryEntry(p_propListConfig,configKey__Applications);
  if (!propListApps)
	{
	  GSWLog(GSW_ERROR,NULL,"No propListApps");
	  //TODO
	}
  else if (!PLIsDictionary(propListApps))
	{
	  GSWLog(GSW_ERROR,NULL,"propListApps is not a dictionary");
	  propListApps=NULL;
	  //TODO
	};
  return propListApps;  
};

proplist_t GSWConfig_ApplicationKeyFromApplicationsKey(proplist_t p_propListApplicationsKeys,int p_iIndex)
{
  proplist_t propListAppKey=PLGetArrayElement(p_propListApplicationsKeys,p_iIndex);
  if (!propListAppKey)
	{
	  //TODO
	}
  else if (!PLIsString(propListAppKey))
	{
	  //TODO
	  propListAppKey=NULL;
	};
  return propListAppKey;
};

proplist_t GSWConfig_InstancesFromApplication(proplist_t p_propListApplication)
{
  proplist_t propListInstances=PLGetDictionaryEntry(p_propListApplication,configKey__Instances);
  if (!propListInstances)
	{
	  GSWLog(GSW_ERROR,NULL,"no propListInstances");
	  //TODO
	}
  else if (!PLIsArray(propListInstances))
	{
	  GSWLog(GSW_ERROR,NULL,"propListInstances is not an array");
	  propListInstances=NULL;
	};
  return propListInstances;
};

proplist_t GSWConfig_ApplicationFromApplications(proplist_t p_propListApplications,proplist_t p_propListApplicationKey)
{
  proplist_t propListApp=PLGetDictionaryEntry(p_propListApplications,p_propListApplicationKey);
  if (!propListApp)
	{
	  //TODO
	}
  else if (!PLIsDictionary(propListApp))
	{
	  //TODO
	  propListApp=NULL;
	};
  return propListApp;
};

proplist_t GSWConfig_ApplicationsKeysFromApplications(proplist_t p_propListApplications)
{
  proplist_t propListAppsNames=NULL;
  if (p_propListApplications)
	{
	  propListAppsNames=PLGetAllDictionaryKeys(p_propListApplications);		  
	};
  return propListAppsNames;
};
proplist_t GSWConfig_ApplicationsKeysFromConfig(proplist_t p_propListConfig)
{
  proplist_t propListApps=GSWConfig_GetApplicationsFromConfig(p_propListConfig);
  proplist_t propListAppsNames=NULL;
  GSWLog(GSW_INFO,NULL,"propListApps=%p",(void*)propListApps);
  if (!propListApps)
	{
	  GSWLog(GSW_ERROR,NULL,"No propListApps");
	  //TODO
	}
  else
	{
	  propListAppsNames=GSWConfig_ApplicationsKeysFromApplications(propListApps);
	};
  return propListAppsNames;  
};

BOOL GSWConfig_PropListInstanceToInstanceEntry(STGSWConfigEntry* p_pInstanceEntry,
											   proplist_t p_propListInstance,
											   CONST char* p_pszAppName)
{
  BOOL fOk=TRUE;
  proplist_t pValue=NULL;
  memset(p_pInstanceEntry,0,sizeof(STGSWConfigEntry));
  p_pInstanceEntry->pszAppName=p_pszAppName;
  GSWLog(GSW_INFO,NULL,"AppName=%s",p_pszAppName);

  // Instance Num
  pValue=PLGetDictionaryEntry(p_propListInstance,configKey__InstanceNum);
  p_pInstanceEntry->iInstance=-1;
  if (!pValue)
	{
	  fOk=FALSE;
	  //TODO
	}
  else if (!PLIsString(pValue))
	{
	  fOk=FALSE;
	  //TODO
	}
  else
	{
	  char* pszInstanceNum=PLGetString(pValue);
	  if (pszInstanceNum)
		{
		  p_pInstanceEntry->iInstance=atoi(pszInstanceNum);
		};
	};
  GSWLog(GSW_INFO,NULL,"instance=%d",p_pInstanceEntry->iInstance);
						  
						  // Host Name
  pValue=PLGetDictionaryEntry(p_propListInstance,configKey__Host);						  
  if (!pValue)
	{
	  fOk=FALSE;
	  //TODO
	}
  else if (!PLIsString(pValue))
	{
	  fOk=FALSE;
	  //TODO
	}
  else
	p_pInstanceEntry->pszHostName=PLGetString(pValue);
  GSWLog(GSW_INFO,NULL,"HostName=%s",
		 p_pInstanceEntry->pszHostName);

  // Port
  pValue=PLGetDictionaryEntry(p_propListInstance,configKey__Port);
  if (!pValue)
	{
	  fOk=FALSE;
	  //TODO
	}
  else if (!PLIsString(pValue))
	{
	  fOk=FALSE;
	  //TODO
	}
  else
	{
	  char* pszPort=PLGetString(pValue);
	  if (pszPort)
		{
		  p_pInstanceEntry->iPort=atoi(pszPort);
		};
	};
  GSWLog(GSW_INFO,NULL,"Port=%d",p_pInstanceEntry->iPort);
  return fOk;
};

void GSWConfig_SetConfigFilePath(CONST char* p_pszConfigFilePath)
{
  if (g_pszConfigFilePath)
	{
	  free(g_pszConfigFilePath);
	  g_pszConfigFilePath=NULL;
	};
  if (!p_pszConfigFilePath)
	p_pszConfigFilePath=g_szGSWeb_DefaultConfigFilePath;
  g_pszConfigFilePath=strdup(p_pszConfigFilePath);
}

CONST char* GSWConfig_GetConfigFilePath()
{
  return g_pszConfigFilePath;
};

