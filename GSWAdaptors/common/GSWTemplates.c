/* GSWTemplates.c - GSWeb: GSWTemplates
   Copyright (C) 2000, 2001, 2002, 2003-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
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

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>
#include "config.h"
#include "GSWConfig.h"
#include "GSWUtil.h"
#include "GSWTemplates.h"

//--------------------------------------------------------------------
const char *g_szErrorResponseTemplate[2]={
"##TEXT##",
"<HTML><BODY BGCOLOR=\"#FFFFFF\">\n"
"<CENTER><H1>##TEXT##</H1></CENTER>\n"
"<BR>\n"
"<CENTER><A HREF=\"http://www.gnustepweb.org\"><IMG SRC=\"##GSWEXTFWKWSR##/PoweredByGNUstepWeb.png\" ALT=\"Powered By GNUstepWeb\" BORDER=0></A></CENTER>\n"
"</BODY></HTML>\n"};

//--------------------------------------------------------------------
const char *g_szErrorNoResponseTemplate[2]={
"##TEXT##",
"<HTML><BODY BGCOLOR=\"#FFFFFF\">\n"
"<CENTER><H1>##TEXT##</H1></CENTER>\n"
"<BR>\n"
"<CENTER><A HREF=\"http://www.gnustepweb.org\"><IMG SRC=\"##GSWEXTFWKWSR##/PoweredByGNUstepWeb.png\" ALT=\"Powered By GNUstepWeb\" BORDER=0></A></CENTER>\n"
"</BODY></HTML>\n"};

//--------------------------------------------------------------------
const char *g_szErrorNoResponseIncludedMessageTemplate[2]={
"##APP_NAME##:##APP_INSTANCE## (##APP_HOST##:##APP_PORT##) doesn't respond",
"##APP_NAME##:##APP_INSTANCE## (##APP_HOST##:##APP_PORT##) doesn't respond"};

//--------------------------------------------------------------------
const char *g_szStatusResponseAllowedTemplate[2]={
  "Server Status\n"
  "##SERVER_INFO## ##SERVER_URL##\n"
  "##ADAPTOR_INFO## ##ADAPTOR_URL##\n"
  "##HEADERS##\n",
  
  "<HTML><HEAD><TITLE>Server Status</TITLE></HEAD>\n"
  "<BODY BGCOLOR=\"#FFFFFF\">\n"
  "<br><strong>Server Adaptor:</strong><br>"
  "<p>Server = <A HREF=\"##SERVER_URL##\">##SERVER_INFO##</A><BR>\n"
  "Adaptor = <A HREF=\"##ADAPTOR_URL##\">##ADAPTOR_INFO##</A></p>\n"
  "<p><strong>Headers:</strong><br>\n"
  "##HEADERS##\n"
  "<BR>\n"
  "<CENTER><A HREF=\"http://www.gnustepweb.org\"><IMG SRC=\"##GSWEXTFWKWSR##/PoweredByGNUstepWeb.png\" ALT=\"Powered By GNUstepWeb\" BORDER=0></A></CENTER>\n"
  "</BODY></HTML>\n"};

//--------------------------------------------------------------------
const char *g_szStatusResponseDeniedTemplate[2]={
  "Don't play with me ##REMOTE_ADDR## ##REMOTE_HOST##, I'll win!\n",

  "<HTML><HEAD><TITLE>Server Status</TITLE></HEAD>\n"
  "<BODY BGCOLOR=\"#FFFFFF\">\n"
  "<CENTER><H1>Don't play with me ##REMOTE_ADDR## ##REMOTE_HOST##, I'll win!</H1></CENTER>"
  "<BR>\n"
  "<CENTER><A HREF=\"http://www.gnustepweb.org\"><IMG SRC=\"##GSWEXTFWKWSR##/PoweredByGNUstepWeb.png\" ALT=\"Powered By GNUstepWeb\" BORDER=0></A></CENTER>\n"
  "</BODY></HTML>\n"};

//--------------------------------------------------------------------
const char *g_szDump_HeadTemplate[2]={
"GNUstepWeb Application\n",
"<HTML><HEAD><TITLE>Index of GNUstepWeb Applications</TITLE></HEAD>\n"
"<BODY BGCOLOR=\"#FFFFFF\">"
"<CENTER><H3>Could not find the application specified in the URL (##APP_NAME##).</H3>\n"
"<H4>Index of GNUstepWeb Applications in ##CONF_FILE## (some applications may be down)</H4>\n"
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
"</tr>\n"};

//--------------------------------------------------------------------
const char *g_szDump_FootTemplate[2]={
"",
"</table></CENTER>\n"
"<BR>\n"
"<CENTER><A HREF=\"http://www.gnustepweb.org\"><IMG SRC=\"##GSWEXTFWKWSR##/PoweredByGNUstepWeb.png\" ALT=\"Powered By GNUstepWeb\" BORDER=0></A></CENTER>\n"
"</BODY></HTML>"};

//--------------------------------------------------------------------
char *g_szDump_AppTemplate[2]={
  "AppName: ##NAME##\n"
  "URL: ##URL##\n"
  "Instances:\n"
  "##INSTANCES##\n",

  "<TR>\n"
  "<TD>##NAME##</TD>\n"
  "<TD><A HREF=\"##URL##\">##URL##</A></TD>\n"
  "<TD colspan=3><TABLE border=1>\n"
  "##INSTANCES##\n"
  "</TABLE></TD>\n"
  "</TR>\n"};

//--------------------------------------------------------------------
char *g_szDump_AppInstanceTemplate[2]={
  "Instance ##NUM##\n"
  "URL: ##URL##\n"
  "HOST: ##HOST##\n"
  "PORT: ##PORT##\n",

  "<TR>\n"
  "<TD><A HREF=\"##URL##\">##NUM##</A></TD>\n"
  "<TD>##HOST##</TD>\n"
  "<TD>##PORT##</TD>\n"
  "</TR>"};

//--------------------------------------------------------------------
char *g_szServiceUnavailableResponseTemplate[2]={
  "Application ##APP_NAME## is unavailable until ##UNAVAILABLE_UNTIL##.\n",

  "<HTML><HEAD><TITLE>Application ##APP_NAME## is unavailable until ##UNAVAILABLE_UNTIL##</TITLE></HEAD>\n"
  "<BODY BGCOLOR=\"#FFFFFF\">\n"
  "<CENTER><H1>Application ##APP_NAME##</H1><H3>is unavailable until ##UNAVAILABLE_UNTIL##</H3></CENTER>"
  "<BR>\n"
  "<CENTER><A HREF=\"http://www.gnustepweb.org\"><IMG SRC=\"##GSWEXTFWKWSR##/PoweredByGNUstepWeb.png\" ALT=\"Powered By GNUstepWeb\" BORDER=0></A></CENTER>\n"
  "</BODY></HTML>\n"};

//--------------------------------------------------------------------
char *
GSWTemplate_GetTemplate(BOOL        p_fHTML,
			GSWApp     *pApp,
			CONST char *p_pszTemplateName)
{
  char *pszTemplate=NULL;
  GSWConfig *gswConfig=GSWConfig_GetConfig();

  if (p_pszTemplateName
      && ((pApp && pApp->pszAdaptorTemplatesPath)
          || gswConfig->pszAdaptorTemplatesPath))
    {
      FILE *fd=NULL;
      int applen = 0;
      int globallen = 0;
      int maxlen = 0;

      applen = strlen(pApp->pszAdaptorTemplatesPath) 
	+ strlen(p_pszTemplateName);

      if (gswConfig->pszAdaptorTemplatesPath)
	globallen = strlen(gswConfig->pszAdaptorTemplatesPath) 
	  + strlen(p_pszTemplateName);

      maxlen = (applen > globallen ? applen : globallen) + 20;
      {
        char *pathName=malloc(maxlen);
        memset(pathName,0,maxlen);
        if (p_fHTML)
          sprintf(pathName,"%s/%s.html",pApp->pszAdaptorTemplatesPath,
		  p_pszTemplateName);
        else
          sprintf(pathName,"%s/%s.txt",pApp->pszAdaptorTemplatesPath,
		  p_pszTemplateName);

        fd=fopen(pathName,"r");
        if (!fd)
          {
            if (p_fHTML)
              sprintf(pathName,"%s/%s.html",
		      gswConfig->pszAdaptorTemplatesPath,p_pszTemplateName);
            else
              sprintf(pathName,"%s/%s.txt",
		      gswConfig->pszAdaptorTemplatesPath,p_pszTemplateName);

            fd=fopen(pathName,"r");
          };

        if (fd)
          {
            char buff[4096]="";
            GSWString *pBuffer=GSWString_New();
            while(fgets(buff,4096,fd))
              {
                GSWString_Append(pBuffer,buff);
              };          
            fclose(fd);
            pszTemplate=pBuffer->pszData;
            GSWString_Detach(pBuffer);
            GSWString_Free(pBuffer);
          };
        free(pathName);
        pathName=NULL;
      };
    };

  return pszTemplate;
};


//--------------------------------------------------------------------
char *
GSWTemplate_ErrorResponse(BOOL    p_fHTML,
                          GSWApp *pApp)
{
  char *pszString=NULL;
  pszString=GSWTemplate_GetTemplate(p_fHTML,pApp,"ErrorResponse");
  if (!pszString)
    pszString=strdup(g_szErrorResponseTemplate[p_fHTML ? 1 : 0]);
  return pszString;
};

//--------------------------------------------------------------------
char *
GSWTemplate_ErrorNoResponse(BOOL    p_fHTML,
                            GSWApp *pApp)
{
  char *pszString=NULL;
  pszString=GSWTemplate_GetTemplate(p_fHTML,pApp,"ErrorNoResponse");
  if (!pszString)
    pszString=strdup(g_szErrorNoResponseTemplate[p_fHTML ? 1 : 0]);
  return pszString;
};

//--------------------------------------------------------------------
char *
GSWTemplate_ErrorNoResponseIncludedMessage(BOOL    p_fHTML,
                                           GSWApp *pApp)
{
  char *pszString=NULL;
  pszString=GSWTemplate_GetTemplate(p_fHTML,pApp,"ErrorNoResponseIncludedMessage");
  if (!pszString)
    pszString=strdup(g_szErrorNoResponseIncludedMessageTemplate[p_fHTML ? 1 : 0]);
  return pszString;
};

//--------------------------------------------------------------------
char *
GSWTemplate_StatusAllowedResponse(BOOL    p_fHTML,
				  GSWApp *pApp)
{
  char *pszString=NULL;
  pszString=GSWTemplate_GetTemplate(p_fHTML,pApp,"StatusAllowedResponse");
  if (!pszString)
    pszString=strdup(g_szStatusResponseAllowedTemplate[p_fHTML ? 1 : 0]);
  return pszString;
};

//--------------------------------------------------------------------
char *
GSWTemplate_StatusDeniedResponse(BOOL    p_fHTML,
				 GSWApp *pApp)
{
  char *pszString=NULL;
  pszString=GSWTemplate_GetTemplate(p_fHTML,pApp,"StatusDeniedResponse");
  if (!pszString)
    pszString=strdup(g_szStatusResponseDeniedTemplate[p_fHTML ? 1 : 0]);
  return pszString;
};

//--------------------------------------------------------------------
char *
GSWTemplate_ServiceUnavailableResponse(BOOL    p_fHTML,
                                       GSWApp *pApp)
{
  char *pszString=NULL;
  pszString=GSWTemplate_GetTemplate(p_fHTML,pApp,"ServiceUnavailableResponse");
  if (!pszString)
    pszString=strdup(g_szServiceUnavailableResponseTemplate[p_fHTML ? 1 : 0]);
  return pszString;
};

//--------------------------------------------------------------------
char *
GSWTemplate_GetDumpHead(BOOL p_fHTML)
{
  char *pszString=NULL;
/*  pszString=GSWTemplate_GetTemplate(p_fHTML,pApp,"DumpHead");
  if (!pszString)*/
    pszString=strdup(g_szDump_HeadTemplate[p_fHTML ? 1 : 0]);
  return pszString;
};

//--------------------------------------------------------------------
char *
GSWTemplate_GetDumpFoot(BOOL p_fHTML)
{
  char *pszString=NULL;
/*  pszString=GSWTemplate_GetTemplate(p_fHTML,pApp,"DumpFoot");
  if (!pszString)*/
    pszString=strdup(g_szDump_FootTemplate[p_fHTML ? 1 : 0]);
  return pszString;
};

//--------------------------------------------------------------------
char *
GSWTemplate_GetDumpApp(BOOL p_fHTML)
{
  char *pszString=NULL;
/*  pszString=GSWTemplate_GetTemplate(p_fHTML,pApp,"DumpApp");
  if (!pszString)*/
    pszString=strdup(g_szDump_AppTemplate[p_fHTML ? 1 : 0]);
  return pszString;
};

//--------------------------------------------------------------------
char *
GSWTemplate_GetDumpAppInstance(BOOL p_fHTML)
{
  char *pszString=NULL;
/*  pszString=GSWTemplate_GetTemplate(p_fHTML,pApp,"DumpAppInstance");
  if (!pszString)*/
    pszString=strdup(g_szDump_AppInstanceTemplate[p_fHTML ? 1 : 0]);
  return pszString;
};

//--------------------------------------------------------------------
void
GSWTemplate_ReplaceStd(GSWString *p_pString,
		       GSWApp    *p_pApp)
{
  GSWString_SearchReplace(p_pString,"##CONF_FILE##",
			  GSWConfig_GetConfigFilePath());
  if (p_pApp)
    {
      GSWString_SearchReplace(p_pString,"##APP_NAME##",p_pApp->pszName);
    };
  if (p_pApp && p_pApp->pszGSWExtensionsFrameworkWebServerResources)
    GSWString_SearchReplace(p_pString,"##GSWEXTFWKWSR##",
	   p_pApp->pszGSWExtensionsFrameworkWebServerResources);
  else
    GSWString_SearchReplace(p_pString,"##GSWEXTFWKWSR##",
	   GSWConfig_GetConfig()->pszGSWExtensionsFrameworkWebServerResources);
};
