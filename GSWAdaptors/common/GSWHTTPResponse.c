/* GSWHTTPResponse.c - GSWeb: Adaptors: HTTP Response
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
#include "GSWString.h"
#include "GSWURLUtil.h"
#include "GSWConfig.h"
#include "GSWHTTPHeaders.h"
#include "GSWAppRequestStruct.h"
#include "GSWAppConnect.h"
#include "GSWHTTPRequest.h"
#include "GSWHTTPResponse.h"
#include "GSWAppRequest.h"


static char* g_pszLocalHostName = NULL;

#define	STATUS	"Status"
#define	HTTP_SLASH	"HTTP/"


GSWHTTPResponse* GSWHTTPResponse_New(void* p_pLogServerData,CONST char* p_pszStatus)
{
  GSWHTTPResponse* pHTTPResponse=NULL;
  BOOL fOk=FALSE;
  // Accept "HTTP/1.0 200 OK GSWeb..." and "HTTP/1.0 200 OK GNUstep GSWeb..."
  if (strncmp(p_pszStatus,HTTP_SLASH,strlen(HTTP_SLASH))==0)
	{
	  // Status Code
	  CONST char* pszSpace=strchr(p_pszStatus,' ');
	  if (pszSpace)
		{
		  unsigned int uStatus=0;
		  fOk=TRUE;
		  pszSpace++;
		  uStatus=atoi(pszSpace);
		  for(;fOk && *pszSpace && !isspace(*pszSpace);pszSpace++)
			fOk=isdigit(*pszSpace);
		  if (fOk)
			{
			  pHTTPResponse = calloc(1,sizeof(GSWHTTPResponse));
			  memset(pHTTPResponse,0,sizeof(GSWHTTPResponse));
			  pHTTPResponse->uStatus=uStatus;
			  pHTTPResponse->pHeaders = GSWDict_New(16);
			  if (*pszSpace)
				{
				  pszSpace=strchr(pszSpace,' ');
				  if (pszSpace)
					  pHTTPResponse->pszStatusMessage=strdup(pszSpace);
				};
			};
		};
	};
  if (!fOk)
	GSWLog(GSW_ERROR,p_pLogServerData,"Invalid response");
  return pHTTPResponse;
};

	
GSWHTTPResponse* GSWHTTPResponse_BuildErrorResponse(CONST char* p_pszMessage)
{
  GSWHTTPResponse* pHTTPResponse=calloc(1,sizeof(GSWHTTPResponse));
  char szBuffer[RESPONSE__LINE_MAX_SIZE]="";	
  pHTTPResponse->uStatus = 200;
  pHTTPResponse->pszStatusMessage = strdup(g_szOKGSWeb);
  pHTTPResponse->pHeaders = GSWDict_New(2);
  GSWDict_Add(pHTTPResponse->pHeaders,
			  g_szHeader_ContentType,
			  g_szContentType_TextHtml,
			  FALSE);
  sprintf(szBuffer,g_szErrorResponseHTMLTextTpl,p_pszMessage);
  pHTTPResponse->uContentLength = strlen(szBuffer);
  pHTTPResponse->pContent = malloc(pHTTPResponse->uContentLength);
  strcpy(pHTTPResponse->pContent,szBuffer);
  sprintf(szBuffer,"%d",pHTTPResponse->uContentLength);
  GSWDict_AddStringDup(pHTTPResponse->pHeaders,g_szHeader_ContentLength,szBuffer);
  return pHTTPResponse;
};

GSWHTTPResponse* GSWHTTPResponse_BuildRedirectedResponse(CONST char* p_pszRedirectPath)
{
  GSWHTTPResponse* pHTTPResponse=calloc(1,sizeof(GSWHTTPResponse));
  pHTTPResponse->uStatus = 302;
  pHTTPResponse->pszStatusMessage = strdup(g_szOKGSWeb);
  pHTTPResponse->pHeaders=GSWDict_New(2);
  GSWDict_Add(pHTTPResponse->pHeaders, g_szHeader_ContentType, g_szContentType_TextHtml,FALSE);
  GSWDict_AddStringDup(pHTTPResponse->pHeaders,"location",p_pszRedirectPath);
  return pHTTPResponse;
};

void GSWHTTPResponse_Free(GSWHTTPResponse* p_pHTTPResponse)
{
  if (p_pHTTPResponse)
	{
	  if (p_pHTTPResponse->pHeaders)
		{
		  GSWDict_Free(p_pHTTPResponse->pHeaders);
		  p_pHTTPResponse->pHeaders=NULL;
		};
	  if (p_pHTTPResponse->pszStatusMessage)
		{
		  free(p_pHTTPResponse->pszStatusMessage);
		  p_pHTTPResponse->pszStatusMessage=NULL;
		};
	  if (p_pHTTPResponse->pContent)
		{
		  free(p_pHTTPResponse->pContent);
		  p_pHTTPResponse->pContent=NULL;
		};
	  free(p_pHTTPResponse);
	  p_pHTTPResponse=NULL;
	};
};


void GSWHTTPResponse_AddHeader(GSWHTTPResponse* p_pHTTPResponse,char* p_pszHeader)
{
  char* pszKey=NULL;
  char* pszValue=NULL;
	
  for (pszKey=p_pszHeader,pszValue=pszKey;*pszValue!=':';pszValue++)
	{
	  if (isupper(*pszValue))
		*pszValue = tolower(*pszValue);
	};
  if (*pszValue==':')
	{
	  *pszValue++='\0';
	  while (*pszValue && isspace(*pszValue))
		pszValue++;
	  GSWDict_AddStringDup(p_pHTTPResponse->pHeaders,pszKey,pszValue);
	
	  if (p_pHTTPResponse->uContentLength==0 && strcmp(g_szHeader_ContentLength,pszKey)==0)
		p_pHTTPResponse->uContentLength = atoi(pszValue);
	}
  /*
  else
	Pb
  */
};

GSWHTTPResponse* GSWHTTPResponse_GetResponse(void* p_pLogServerData,AppConnectHandle p_socket)
{
  GSWHTTPResponse* pHTTPResponse=NULL;
  char szResponseBuffer[RESPONSE__LINE_MAX_SIZE];
	
  // Get the 1st Line
  GSWApp_ReceiveLine(p_pLogServerData,p_socket,szResponseBuffer, RESPONSE__LINE_MAX_SIZE);
  pHTTPResponse = GSWHTTPResponse_New(p_pLogServerData,szResponseBuffer);
#ifdef	DEBUG
  GSWLog(GSW_INFO,p_pLogServerData,"Response receive first line:\t\t[%s]",szResponseBuffer);
#endif
	
  if (!pHTTPResponse) //Error
	  pHTTPResponse=GSWHTTPResponse_BuildErrorResponse("Invalid Response");
  else
	{
	  int iHeader=0;
	  // Headers
	  while (GSWApp_ReceiveLine(p_pLogServerData,p_socket,szResponseBuffer,RESPONSE__LINE_MAX_SIZE)>0
			 && szResponseBuffer[0]
			 )
		{
#ifdef	DEBUG
		  GSWLog(GSW_INFO,p_pLogServerData,"Header %d=\t\t[%s]",iHeader,szResponseBuffer);
#endif
		  GSWHTTPResponse_AddHeader(pHTTPResponse,szResponseBuffer);
		};

	  // Content
	  if (pHTTPResponse->uContentLength)
		{
		  char* pszBuffer= malloc(pHTTPResponse->uContentLength);
		  int iReceivedCount=GSWApp_ReceiveBlock(p_pLogServerData,p_socket,pszBuffer,pHTTPResponse->uContentLength);
#ifdef	DEBUG
		  GSWLog(GSW_INFO,p_pLogServerData,"iReceivedCount=%d",iReceivedCount);
#endif
		  if (iReceivedCount!= pHTTPResponse->uContentLength)
			{
			  GSWLog(GSW_ERROR,p_pLogServerData,
					 "Content received doesn't equal to ContentLength. Too bad, same player must shoot again !");
			  free(pszBuffer);
			  pszBuffer=NULL;
			  GSWHTTPResponse_Free(pHTTPResponse);
			  pHTTPResponse=NULL;
			  pHTTPResponse = GSWHTTPResponse_BuildErrorResponse("Invalid Response");
			}
		  else
			pHTTPResponse->pContent = pszBuffer;
		}
#ifdef	DEBUG
	  if (pHTTPResponse->pContent)
		{
		  char szTraceBuffer[pHTTPResponse->uContentLength+1];
		  GSWLog(GSW_INFO,p_pLogServerData,"\ncontent (%d Bytes)=\n",pHTTPResponse->uContentLength);
		  memcpy(szTraceBuffer,pHTTPResponse->pContent,pHTTPResponse->uContentLength);
		  szTraceBuffer[pHTTPResponse->uContentLength] = 0;
		  GSWLogSized(GSW_INFO,p_pLogServerData,
					  pHTTPResponse->uContentLength+1,
					  "%.*s",
					  (int)pHTTPResponse->uContentLength,
					  szTraceBuffer);
//		  GSWLog(GSW_INFO,p_pLogServerData,"\nEND\n");
		};
#endif
	};
  return pHTTPResponse;
};


static void GetHeaderLength(GSWDictElem* p_pElem,
							void* p_piAddTo)
{
  int* piAddTo=(int*)p_piAddTo;
  // +2=": "
  // +1="\r"
  // +1="\n"
  (*piAddTo)+=strlen(p_pElem->pszKey)+strlen((char*)p_pElem->pValue)+2+1+2;
};

static void FormatHeader(GSWDictElem* p_pElem,
						 void* p_ppszBuffer)
{
  char** ppszBuffer=(char**)p_ppszBuffer;
  strcpy(*ppszBuffer,p_pElem->pszKey);
  strcat(*ppszBuffer, ": ");
  strcat(*ppszBuffer,(char*)p_pElem->pValue);
  (*ppszBuffer)+= strlen(*ppszBuffer);
  **ppszBuffer = '\r';
  (*ppszBuffer)++;
  **ppszBuffer = '\n';
  (*ppszBuffer)++;
};

char *GSWHTTPResponse_PackageHeaders(GSWHTTPResponse* p_pHTTPResponse,
									 char* p_pszBuffer,
									 int p_iBufferSize)
{
  int iHeaderLength=0;
  char* pszBuffer=NULL;
  char* pszTmp=NULL;
	
  GSWDict_PerformForAllElem(p_pHTTPResponse->pHeaders,
							GetHeaderLength,
							(void*)&iHeaderLength);
  pszBuffer = ((p_iBufferSize > (iHeaderLength)) ? p_pszBuffer : malloc(p_iBufferSize+1));
  pszTmp = pszBuffer;
	
  GSWDict_PerformForAllElem(p_pHTTPResponse->pHeaders,FormatHeader,&pszTmp);
  *pszTmp = '\0';
  if (pszTmp-pszBuffer>1)
	{
	  // Remove last \r\n
	  *(pszTmp-1) = 0;
	  *(pszTmp-2) = 0; 
	};
  return pszBuffer;
};

void GSWHTTPResponse_AddHeaderToString(GSWDictElem* p_pElem,void* p_pData)
{
  GSWString* pString=(GSWString*)p_pData;
  GSWString_Append(pString,p_pElem->pszKey);
  GSWString_Append(pString,": ");
  GSWString_Append(pString,(char*)p_pElem->pValue);
  GSWString_Append(pString,"<br>");
};

GSWHTTPResponse* GSWHTTPResponse_BuildTestResponse(void* p_pLogServerData,GSWHTTPRequest* p_pHTTPRequest)
{
  GSWHTTPResponse* pHTTPResponse=GSWHTTPResponse_New(p_pLogServerData,g_szOKStatus);
  GSWDict* pRequestHeaders=NULL;
  GSWString* pContent=GSWString_New();

  GSWDict_AddString(pHTTPResponse->pHeaders,
					g_szHeader_ContentType,
					g_szContentType_TextHtml,
					FALSE);
  
  GSWString_Append(pContent, "<HTML><BODY>");
  GSWString_Append(pContent, "<br><strong>Server Adaptor:</strong><br>");
  GSWString_Append(pContent, "<p>Server = ");
  GSWString_Append(pContent, g_szGSWeb_Server);
  GSWString_Append(pContent, " <br>");
  GSWString_Append(pContent, "GNUstepWeb Web Server Adaptor version = ");
  GSWString_Append(pContent, g_szGSWeb_AdaptorVersion);
  GSWString_Append(pContent, "</p>");
  
  GSWString_Append(pContent, "<br><strong>Headers:</strong><br>");
  pRequestHeaders = (GSWDict*)(p_pHTTPRequest->pHeaders);
  GSWDict_PerformForAllElem(pRequestHeaders,GSWHTTPResponse_AddHeaderToString,pContent);
  
  GSWString_Append(pContent, "</BODY></HTML>");
  
  pHTTPResponse->uContentLength = pContent->iLen;
  pHTTPResponse->pContent = pContent->pszData;
  GSWString_Detach(pContent);
  GSWString_Free(pContent);
  return pHTTPResponse;
};


GSWHTTPResponse* GSWDumpConfigFile(void* p_pLogServerData,GSWURLComponents* p_pURLComponents)
{
  GSWHTTPResponse* pHTTPResponse=NULL;  
  if (GSWDumpConfigFile_CanDump())
	{
	  proplist_t propListConfig=NULL;
	  char szBuffer[4096]="";
	  GSWString* pContent=GSWString_New();
	  time_t nullTime=(time_t)0;
	  char pszPrefix[MAXPATHLEN]="";
	  char szReqAppName[MAXPATHLEN]="Unknown";
	  GSWLog(GSW_INFO,p_pLogServerData,"Creating Applications Page.");
	
	  if (!g_pszLocalHostName)
		{
		  char szHostName[MAXHOSTNAMELEN+1];
		  gethostname(szHostName, MAXHOSTNAMELEN);
		  g_pszLocalHostName= strdup(szHostName);
		};
	  
	  pHTTPResponse = GSWHTTPResponse_New(p_pLogServerData,g_szOKStatus);
	  GSWDict_AddString(pHTTPResponse->pHeaders,
						g_szHeader_ContentType,
						g_szContentType_TextHtml,
						FALSE);

	  if (p_pURLComponents->stAppName.iLength>0 && p_pURLComponents->stAppName.pszStart)
		{
		  strncpy(szReqAppName,p_pURLComponents->stAppName.pszStart,p_pURLComponents->stAppName.iLength);
		  szReqAppName[p_pURLComponents->stAppName.iLength]=0;
		};
	  sprintf(szBuffer,
			  g_szDumpConfFile_Head,
			  szReqAppName,
			  GSWConfig_GetConfigFilePath());
	  GSWString_Append(pContent,szBuffer);

	  strncpy(pszPrefix, p_pURLComponents->stPrefix.pszStart,p_pURLComponents->stPrefix.iLength);
	  pszPrefix[p_pURLComponents->stPrefix.iLength] = '\0';

	  if (GSWConfig_ReadIFND(GSWConfig_GetConfigFilePath(),
							 &nullTime,
							 &propListConfig,
							 p_pLogServerData)==EGSWConfigResult__Ok)
		{
		  proplist_t propListApps=NULL;
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
				  proplist_t propListAppKey=GSWConfig_ApplicationKeyFromApplicationsKey(propListAppsNames,
																						iAppIndex);
				  if (!propListAppKey)
					{
					  //TODO
					}
				  else
					{
					  char url[MAXPATHLEN+256];
					  CONST char* pszAppName=PLGetString(propListAppKey);
					  proplist_t propListApp;

					  sprintf(url,"%s/%s",pszPrefix,pszAppName);
					  sprintf(szBuffer,"<TR>\n<TD>%s</TD>\n<TD><A HREF=\"%s\">%s</A></TD>",
							  pszAppName,
							  url, 
							  url);
					  GSWString_Append(pContent,szBuffer);
					  propListApp=GSWConfig_ApplicationFromApplications(propListApps,
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
							  GSWLog(GSW_INFO,p_pLogServerData,"uInstancesNb=%u",uInstancesNb);
							  if (uInstancesNb>0)
								{
								  sprintf(szBuffer,"<TD colspan=3><TABLE border=1>\n");
								  GSWString_Append(pContent,szBuffer);
								};
					  
							  for(iInstanceIndex=0;iInstanceIndex<uInstancesNb;iInstanceIndex++)
								{
								  proplist_t propListInstance=PLGetArrayElement(propListInstances,iInstanceIndex);
								  GSWLog(GSW_INFO,p_pLogServerData,"propListInstance=%p",propListInstance);
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
									  sprintf(url,
											  "http://%s:%d%s/%s",
											  stEntry.pszHostName,
											  stEntry.iPort,
											  pszPrefix,
											  pszAppName);
									  sprintf(szBuffer,
											  "<TR>\n<TD><A HREF=\"%s\">%d</A></TD>\n<TD>%s</TD>\n<TD>%d</TD>\n</TR>\n",
											  url,
											  stEntry.iInstance,
											  stEntry.pszHostName,
											  stEntry.iPort);
									  GSWString_Append(pContent,szBuffer);
									};
								};
							  if (uInstancesNb>0)
								{
								  sprintf(szBuffer,"</TABLE></TD>");
								  GSWString_Append(pContent,szBuffer);
								};
							};
						};
					};
				};
			};
		  sprintf(szBuffer,
				  g_szDumpConfFile_Foot,
				  g_szGSWeb_DefaultGSWExtensionsFrameworkWebServerResources);
		  GSWString_Append(pContent,szBuffer);
		  
		  pHTTPResponse->uContentLength = pContent->iLen;
		  pHTTPResponse->pContent = pContent->pszData;
		  GSWString_Detach(pContent);
		  GSWString_Free(pContent);
		};
	};
  return pHTTPResponse;	
};



