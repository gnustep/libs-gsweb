/* GSWTemplates.c - GSWeb: GSWTemplates
   Copyright (C) 2000 Free Software Foundation, Inc.
   
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
#include "config.h"
#include "GSWConfig.h"
#include "GSWUtil.h"
#include "GSWTemplates.h"

//--------------------------------------------------------------------
const char* g_szErrorResponseTextTemplate[2]={
"##TEXT##",
"<HTML><BODY BGCOLOR=\"#FFFFFF\">\n"
"<CENTER><H1>##TEXT##</H1></CENTER>\n"
"<BR>\n"
"<CENTER><A HREF=\"http://www.gnustepweb.org\"><IMG SRC=\"##GSWEXTFWKWSR##/PoweredByGNUstepWeb.gif\" ALT=\"Powered By GNUstepWeb\" BORDER=0></A></CENTER>\n"
"</BODY></HTML>\n"};

//--------------------------------------------------------------------
const char* g_szErrorNoResponseMessageTemplate[2]={
"##APP_NAME##:##APP_INSTANCE## (##APP_HOST##:##APP_PORT##) doesn't repond",
"##APP_NAME##:##APP_INSTANCE## (##APP_HOST##:##APP_PORT##) doesn't repond"};

//--------------------------------------------------------------------
const char* g_szStatusResponseAllowedTemplate[2]={
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
  "<CENTER><A HREF=\"http://www.gnustepweb.org\"><IMG SRC=\"##GSWEXTFWKWSR##/PoweredByGNUstepWeb.gif\" ALT=\"Powered By GNUstepWeb\" BORDER=0></A></CENTER>\n"
  "</BODY></HTML>\n"};

//--------------------------------------------------------------------
const char* g_szStatusResponseDeniedTemplate[2]={
  "Don't play with me ##REMOTE_ADDR## ##REMOTE_HOST##, I'll win!\n",

  "<HTML><HEAD><TITLE>Server Status</TITLE></HEAD>\n"
  "<BODY BGCOLOR=\"#FFFFFF\">\n"
  "<CENTER><H1>Don't play with me ##REMOTE_ADDR## ##REMOTE_HOST##, I'll win!</H1></CENTER>"
  "<BR>\n"
  "<CENTER><A HREF=\"http://www.gnustepweb.org\"><IMG SRC=\"##GSWEXTFWKWSR##/PoweredByGNUstepWeb.gif\" ALT=\"Powered By GNUstepWeb\" BORDER=0></A></CENTER>\n"
  "</BODY></HTML>\n"};

//--------------------------------------------------------------------
const char* g_szDump_HeadTemplate[2]={
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
const char* g_szDump_FootTemplate[2]={
"",
"</table></CENTER>\n"
"<BR>\n"
"<CENTER><A HREF=\"http://www.gnustepweb.org\"><IMG SRC=\"##GSWEXTFWKWSR##/PoweredByGNUstepWeb.gif\" ALT=\"Powered By GNUstepWeb\" BORDER=0></A></CENTER>\n"
"</BODY></HTML>"};

//--------------------------------------------------------------------
char* g_szDump_AppTemplate[2]={
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
char* g_szDump_AppInstanceTemplate[2]={
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
CONST char* GSWTemplate_ErrorResponseText(BOOL p_fHTML)
{
  return g_szErrorResponseTextTemplate[p_fHTML ? 1 : 0];
};

//--------------------------------------------------------------------
CONST char* GSWTemplate_ErrorNoResponseMessage(BOOL p_fHTML)
{
  return g_szErrorNoResponseMessageTemplate[p_fHTML ? 1 : 0];
};

//--------------------------------------------------------------------
CONST char* GSWTemplate_StatusAllowedResponse(BOOL p_fHTML)
{
  return g_szStatusResponseAllowedTemplate[p_fHTML ? 1 : 0];
};

//--------------------------------------------------------------------
CONST char* GSWTemplate_StatusDeniedResponse(BOOL p_fHTML)
{
  return g_szStatusResponseDeniedTemplate[p_fHTML ? 1 : 0];
};

//--------------------------------------------------------------------
CONST char* GSWTemplate_GetDumpHead(BOOL p_fHTML)
{
  return g_szDump_HeadTemplate[p_fHTML ? 1 : 0];
};

//--------------------------------------------------------------------
CONST char* GSWTemplate_GetDumpFoot(BOOL p_fHTML)
{
  return g_szDump_FootTemplate[p_fHTML ? 1 : 0];
};

//--------------------------------------------------------------------
CONST char* GSWTemplate_GetDumpApp(BOOL p_fHTML)
{
  return g_szDump_AppTemplate[p_fHTML ? 1 : 0];
};

//--------------------------------------------------------------------
CONST char* GSWTemplate_GetDumpAppInstance(BOOL p_fHTML)
{
  return g_szDump_AppInstanceTemplate[p_fHTML ? 1 : 0];
};

//--------------------------------------------------------------------
void GSWTemplate_ReplaceStd(GSWString* p_pString,GSWApp* p_pApp)
{
  GSWString_SearchReplace(p_pString,"##CONF_FILE##",GSWConfig_GetConfigFilePath());
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
