/* GSWHTTPHeaders.c - GSWeb: GSWeb HTTP Headers
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
#include "GSWHTTPHeaders.h"

const char *g_szHeader_GSWeb_ServerAdaptor="x-gsweb-adaptor-version";
const char *g_szHeader_GSWeb_RequestMethod="x-gsweb-request-method";
const char *g_szHeader_GSWeb_Recording="x-gsweb-recording";
const char *g_szHeader_GSWeb_QueryString="x-gsweb-query-string";
const char *g_szHeader_GSWeb_RemoteAddress="x-gsweb-remote-addr";
const char *g_szHeader_GSWeb_RemoteHost="x-gsweb-remote-host";
const char *g_szHeader_GSWeb_RemoteIdent="x-gsweb-remote-ident";
const char *g_szHeader_GSWeb_RemoteUser="x-gsweb-remote-user";
const char *g_szHeader_GSWeb_ServerName="x-gsweb-server-name";
const char *g_szHeader_GSWeb_ServerPort="x-gsweb-server-port";
const char *g_szHeader_GSWeb_ServerSoftware="x-gsweb-server-software";
const char *g_szHeader_GSWeb_AnnotationServer="x-gsweb-annotation-server";
const char *g_szHeader_GSWeb_AuthPass="x-gsweb-auth-pass";
const char *g_szHeader_GSWeb_AuthType="x-gsweb-auth-type";
const char *g_szHeader_GSWeb_DocumentRoot="x-gsweb-documentroot";
const char *g_szHeader_GSWeb_GatewayInterface="x-gsweb-gateway-interface";
const char *g_szHeader_GSWeb_Protocol="x-gsweb-server-protocol";
const char *g_szHeader_GSWeb_ProtocolNum="x-gsweb-server-protocol-num";
const char *g_szHeader_GSWeb_RequestScheme="x-gsweb-request-scheme";

const char *g_szHeader_Accept="accept";
const char *g_szHeader_AcceptEncoding="accept-encoding";
const char *g_szHeader_AcceptLanguage="accept-language";
const char *g_szHeader_Allow="allow";
const char *g_szHeader_Authorization="authorization";
const char *g_szHeader_AuthUser="auth-user";
const char *g_szHeader_Cookie="cookie";
const char *g_szHeader_ContentLength="content-length";
const char *g_szHeader_ContentType="content-type";
const char *g_szHeader_IfModifiedSince="if-modified-since";
const char *g_szHeader_LastModified="last-modified";
const char *g_szHeader_Method="method";
const char *g_szHeader_PathInfo="path-info";
const char *g_szHeader_Pragma="pragma";
const char *g_szHeader_Protocol="protocol";
const char *g_szHeader_Referer="referer";
const char *g_szHeader_UserAgent="user-agent";
const char *g_szHeader_Date="date";
const char *g_szHeader_Expires="expires";
const char *g_szHeader_From="from";
const char *g_szHeader_MimeVersion="mime-version";
const char *g_szHeader_ContentEncoding="content-encoding";



const char *g_szServerInfo_DocumentRoot="DOCUMENT_ROOT";
const char *g_szServerInfo_HTTPAccept="HTTP_ACCEPT";
const char *g_szServerInfo_HTTPAcceptEncoding="HTTP_ACCEPT_ENCODING";
const char *g_szServerInfo_HTTPAllow="HTTP_ALLOW";
const char *g_szServerInfo_HTTPDate="HTTP_DATE";
const char *g_szServerInfo_HTTPExpires="HTTP_EXPIRES";
const char *g_szServerInfo_HTTPFrom="HTTP_FROM";
const char *g_szServerInfo_HTTPIfModifiedSince="HTTP_IF_MODIFIED_SINCE";
const char *g_szServerInfo_HTTPLastModified="HTTP_LAST_MODIFIED";
const char *g_szServerInfo_HTTPMimeVersion="HTTP_MIME_VERSION";
const char *g_szServerInfo_HTTPPragma="HTTP_PRAGMA";
const char *g_szServerInfo_HTTPReferer="HTTP_REFERER";
const char *g_szServerInfo_RemoteIdent="REMOTE_IDENT";
const char *g_szServerInfo_RequestMethod="REQUEST_METHOD";

const char *g_szServerInfo_AnnotationServer="ANNOTATION_SERVER";
const char *g_szServerInfo_AuthPass="AUTH_PASS";
const char *g_szServerInfo_AuthType="AUTH_TYPE";
const char *g_szServerInfo_AuthUser="AUTH_USER";
const char *g_szServerInfo_ClientCert="CLIENT_CERT";
const char *g_szServerInfo_ContentEncoding="CONTENT_ENCODING";
const char *g_szServerInfo_ContentLength="CONTENT_LENGTH";
const char *g_szServerInfo_ContentType="CONTENT_TYPE";
const char *g_szServerInfo_GatewayInterface="GATEWAY_INTERFACE";
const char *g_szServerInfo_Host="HOST";
const char *g_szServerInfo_HTTPAcceptLanguage="HTTP_ACCEPT_LANGUAGE";
const char *g_szServerInfo_HTTPAuthorization="HTTP_AUTHORIZATION";
const char *g_szServerInfo_HTTPCookie="HTTP_COOKIE";
const char *g_szServerInfo_HTTPUserAgent="HTTP_USER_AGENT";
const char *g_szServerInfo_HTTPS="HTTPS";
const char *g_szServerInfo_HTTPSKeySize="HTTPS_KEYSIZE";
const char *g_szServerInfo_HTTPSSecretKeySize="HTTPS_SECRETKEYSIZE";
const char *g_szServerInfo_PathInfo="PATH_INFO";
const char *g_szServerInfo_PathTranslated="PATH_TRANSLATED";
const char *g_szServerInfo_Query="QUERY";
const char *g_szServerInfo_QueryString="QUERY_STRING";
const char *g_szServerInfo_RemoteAddress="REMOTE_ADDR";
const char *g_szServerInfo_RemoteHost="REMOTE_HOST";
const char *g_szServerInfo_RemoteUser="REMOTE_USER";
const char *g_szServerInfo_ScriptName="SCRIPT_NAME";
const char *g_szServerInfo_ServerID="SERVER_ID";
const char *g_szServerInfo_ServerName="SERVER_NAME";
const char *g_szServerInfo_ServerPort="SERVER_PORT";
const char *g_szServerInfo_ServerProtocol="SERVER_PROTOCOL";
const char *g_szServerInfo_ServerSoftware="SERVER_SOFTWARE";
const char *g_szServerInfo_HTTPGSWebRecording="HTTP_X_GSWEB_RECORDING";
const char *g_szServerInfo_ServerAdmin="SERVER_ADMIN";
const char *g_szServerInfo_ScriptFileName="SCRIPT_FILENAME";
const char *g_szServerInfo_RemotePort="REMOTE_PORT";
const char *g_szServerInfo_Protocol="PROTOCOL";
const char *g_szServerInfo_ProtocolNum="PROTOCOL_NUM";
const char *g_szServerInfo_RequestScheme="REQUEST_SCHEME";

const char *g_szMethod_Get="GET";
const char *g_szMethod_Post="POST";
const char *g_szMethod_Head="HEAD";
const char *g_szMethod_Put="PUT";

const char *g_szContentType_TextHtml="text/html";


GSWHeaderTranslationItem GSWHeaderTranslationTable[50];
int GSWHeaderTranslationTableItemsNb=0;

//--------------------------------------------------------------------
// p_pKey0 is a header key
// p_pKey1 is a dictionary element
static int
compareHeader(CONST void *p_pKey0,
	      CONST void *p_pKey1)
{
  CONST char *pKey1=((GSWHeaderTranslationItem *)p_pKey1)->pszHTTP;
  if (pKey1)
    return strcmp((CONST char *)p_pKey0,pKey1);
  else if (!p_pKey0)
    return 0;
  else
    return 1;
};

//--------------------------------------------------------------------
// p_pKey0 and p_pKey1 are dictionary elements
static int
compareHeaderItems(CONST void *p_pKey0,
                   CONST void *p_pKey1)
{
  CONST char *pKey0=((GSWHeaderTranslationItem *)p_pKey0)->pszHTTP;
  CONST char *pKey1=((GSWHeaderTranslationItem *)p_pKey1)->pszHTTP;
  if (pKey1)
    return strcmp((CONST char *)pKey0,pKey1);
  else if (!pKey0)
    return 0;
  else
    return 1;
};

//--------------------------------------------------------------------
void
GSWHeaderTranslationTable_Init()
{
  int i=0;
  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_AnnotationServer;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_AnnotationServer;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_AuthPass;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_AuthPass;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_AuthType;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_AuthType;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_ContentEncoding;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_ContentEncoding;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_ContentLength;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_ContentLength;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_ContentType;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_ContentType;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_DocumentRoot;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_DocumentRoot;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_GatewayInterface;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_GatewayInterface;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPAccept;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_Accept;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPAcceptEncoding;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_AcceptEncoding;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPAcceptLanguage;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_AcceptLanguage;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPAllow;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_Allow;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPAuthorization;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_Authorization;	

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPCookie;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_Cookie;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPDate;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_Date;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPExpires;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_Expires;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPFrom;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_From;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPIfModifiedSince;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_IfModifiedSince;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPLastModified;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_LastModified;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPMimeVersion;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_MimeVersion;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPPragma;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_Pragma;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPReferer;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_Referer;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPUserAgent;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_UserAgent;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_HTTPGSWebRecording;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_Recording;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_QueryString;
  GSWHeaderTranslationTable[i++].pszGSWeb=	g_szHeader_GSWeb_QueryString;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_RemoteAddress;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_RemoteAddress;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_RemoteHost;
  GSWHeaderTranslationTable[i++].pszGSWeb=	g_szHeader_GSWeb_RemoteHost;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_RemoteIdent;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_RemoteIdent;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_RemoteUser;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_RemoteUser;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_RequestMethod;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_RequestMethod;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_ServerName;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_ServerName;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_ServerPort;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_ServerPort;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_ServerSoftware;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_ServerSoftware;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_Protocol;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_Protocol;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_ProtocolNum;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_ProtocolNum;

  GSWHeaderTranslationTable[i].pszHTTP=g_szServerInfo_RequestScheme;
  GSWHeaderTranslationTable[i++].pszGSWeb=g_szHeader_GSWeb_RequestScheme;

  GSWHeaderTranslationTable[i].pszHTTP=NULL;
  GSWHeaderTranslationTable[i++].pszGSWeb=NULL;

  GSWHeaderTranslationTableItemsNb=i;

  // Because bsearch require sorted array
  qsort(GSWHeaderTranslationTable,GSWHeaderTranslationTableItemsNb,sizeof(GSWHeaderTranslationItem),
        compareHeaderItems);

/*  
  GSWLog(GSW_ERROR,LOGSD,"GSWHeaderTranslationTableItemsNb=%d",
	 GSWHeaderTranslationTableItemsNb);
  for(i=0;i<GSWHeaderTranslationTableItemsNb-1;i++)
    {
      GSWLog(GSW_ERROR,LOGSD,"GSWHeaderTranslationTable[%d].pszHTTP=%s",
	     i,GSWHeaderTranslationTable[i].pszHTTP);
      GSWLog(GSW_ERROR,LOGSD,"GSWHeaderTranslationTable[%d].pszGSWeb=%s",
	     i,GSWHeaderTranslationTable[i].pszGSWeb);
    };
*/
};

//--------------------------------------------------------------------
CONST char* GSWebHeaderForHTTPHeader(CONST char *p_pszHTTPHeader)
{
  GSWHeaderTranslationItem *pItem=NULL;
  if (GSWHeaderTranslationTableItemsNb==0)
    GSWHeaderTranslationTable_Init();

  pItem=bsearch(p_pszHTTPHeader,
		GSWHeaderTranslationTable,
		GSWHeaderTranslationTableItemsNb,
		sizeof(GSWHeaderTranslationItem),
		compareHeader);

  return (pItem ? pItem->pszGSWeb : NULL);
};


