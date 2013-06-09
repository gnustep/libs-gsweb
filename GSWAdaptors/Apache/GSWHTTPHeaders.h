/* GSWHTTPHeaders.h - GSWeb: GSWeb HTTP Headers
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

#ifndef _GSWHTTPHeaders_h__
#define _GSWHTTPHeaders_h__

extern const char *g_szHeader_GSWeb_ServerAdaptor;
extern const char *g_szHeader_GSWeb_RequestMethod;
extern const char *g_szHeader_GSWeb_Recording;
extern const char *g_szHeader_GSWeb_QueryString;
extern const char *g_szHeader_GSWeb_RemoteAddress;
extern const char *g_szHeader_GSWeb_RemoteHost;
extern const char *g_szHeader_GSWeb_RemoteIdent;
extern const char *g_szHeader_GSWeb_RemoteUser;
extern const char *g_szHeader_GSWeb_ServerName;
extern const char *g_szHeader_GSWeb_ServerPort;
extern const char *g_szHeader_GSWeb_ServerSoftware;
extern const char *g_szHeader_GSWeb_AnnotationServer;
extern const char *g_szHeader_GSWeb_AuthPass;
extern const char *g_szHeader_GSWeb_AuthType;
extern const char *g_szHeader_GSWeb_DocumentRoot;
extern const char *g_szHeader_GSWeb_GatewayInterface;
extern const char *g_szHeader_GSWeb_Protocol;
extern const char *g_szHeader_GSWeb_ProtocolNum;
extern const char *g_szHeader_GSWeb_HTTPMethod;
extern const char *g_szHeader_GSWeb_ApplicationName;

extern const char *g_szHeader_Accept;
extern const char *g_szHeader_AcceptEncoding;
extern const char *g_szHeader_AcceptLanguage;
extern const char *g_szHeader_Allow;
extern const char *g_szHeader_Authorization;
extern const char *g_szHeader_AuthUser;
extern const char *g_szHeader_Cookie;
extern const char *g_szHeader_ContentLength;
extern const char *g_szHeader_ContentType;
extern const char *g_szHeader_IfModifiedSince;
extern const char *g_szHeader_LastModified;
extern const char *g_szHeader_Method;
extern const char *g_szHeader_PathInfo;
extern const char *g_szHeader_Pragma;
extern const char *g_szHeader_Protocol;
extern const char *g_szHeader_Referer;
extern const char *g_szHeader_UserAgent;
extern const char *g_szHeader_Date;
extern const char *g_szHeader_Expires;
extern const char *g_szHeader_From;
extern const char *g_szHeader_MimeVersion;
extern const char *g_szHeader_ContentEncoding;

extern const char *g_szServerInfo_DocumentRoot;
extern const char *g_szServerInfo_HTTPAccept;
extern const char *g_szServerInfo_HTTPAcceptEncoding;
extern const char *g_szServerInfo_HTTPAllow;
extern const char *g_szServerInfo_HTTPDate;
extern const char *g_szServerInfo_HTTPExpires;
extern const char *g_szServerInfo_HTTPFrom;
extern const char *g_szServerInfo_HTTPIfModifiedSince;
extern const char *g_szServerInfo_HTTPLastModified;
extern const char *g_szServerInfo_HTTPMimeVersion;
extern const char *g_szServerInfo_HTTPPragma;
extern const char *g_szServerInfo_HTTPReferer;
extern const char *g_szServerInfo_RemoteIdent;
extern const char *g_szServerInfo_RequestScheme;

extern const char *g_szServerInfo_AnnotationServer;
extern const char *g_szServerInfo_AuthPass;
extern const char *g_szServerInfo_AuthType;
extern const char *g_szServerInfo_AuthUser;
extern const char *g_szServerInfo_ClientCert;
extern const char *g_szServerInfo_ContentEncoding;
extern const char *g_szServerInfo_ContentLength;
extern const char *g_szServerInfo_ContentType;
extern const char *g_szServerInfo_GatewayInterface;
extern const char *g_szServerInfo_Host;
extern const char *g_szServerInfo_HTTPAcceptLanguage;
extern const char *g_szServerInfo_HTTPAuthorization;
extern const char *g_szServerInfo_HTTPCookie;
extern const char *g_szServerInfo_HTTPUserAgent;
extern const char *g_szServerInfo_HTTPS;
extern const char *g_szServerInfo_HTTPSKeySize;
extern const char *g_szServerInfo_HTTPSSecretKeySize;
extern const char *g_szServerInfo_PathInfo;
extern const char *g_szServerInfo_PathTranslated;
extern const char *g_szServerInfo_Query;
extern const char *g_szServerInfo_QueryString;
extern const char *g_szServerInfo_RemoteAddress;
extern const char *g_szServerInfo_RemoteHost;
extern const char *g_szServerInfo_RemoteUser;
extern const char *g_szServerInfo_ScriptName;
extern const char *g_szServerInfo_ServerID;
extern const char *g_szServerInfo_ServerName;
extern const char *g_szServerInfo_ServerPort;
extern const char *g_szServerInfo_ServerProtocol;
extern const char *g_szServerInfo_ServerSoftware;
extern const char *g_szServerInfo_HTTPGSWebRecording;
extern const char *g_szServerInfo_ServerAdmin;
extern const char *g_szServerInfo_ScriptFileName;
extern const char *g_szServerInfo_RemotePort;
extern const char *g_szServerInfo_Protocol;
extern const char *g_szServerInfo_ProtocolNum;
extern const char *g_szServerInfo_RequestScheme;

extern const char *g_szMethod_Get;
extern const char *g_szMethod_Post;
extern const char *g_szMethod_Head;
extern const char *g_szMethod_Put;

extern const char *g_szContentType_TextHtml;

typedef	struct _GSWHeaderTranslationItem {
	const char /*const*/ *pszHTTP;
	const char /*const*/ *pszGSWeb;
} GSWHeaderTranslationItem;

extern /*const*/ GSWHeaderTranslationItem GSWHeaderTranslationTable[];
extern int GSWHeaderTranslationTableItemsNb;
CONST char* GSWebHeaderForHTTPHeader(CONST char *p_pszHTTPHeader);
/*
static const GSWHeaderTranslationItem GSWHeaderTranslationTable[] =
{
  {  g_szServerInfo_AnnotationServer,   g_szHeader_GSWeb_AnnotationServer},
  {  g_szServerInfo_AuthPass,           g_szHeader_GSWeb_AuthPass        },
  {  g_szServerInfo_AuthType,           g_szHeader_GSWeb_AuthType        },
  {  g_szServerInfo_ContentEncoding,    g_szHeader_ContentEncoding       },
  {  g_szServerInfo_ContentLength,      g_szHeader_ContentLength         },
  {  g_szServerInfo_ContentType,        g_szHeader_ContentType           },
  {  g_szServerInfo_DocumentRoot,       g_szHeader_GSWeb_DocumentRoot    },
  {  g_szServerInfo_GatewayInterface,   g_szHeader_GSWeb_GatewayInterface},
  {  g_szServerInfo_HTTPAccept,         g_szHeader_Accept                },
  {  g_szServerInfo_HTTPAcceptEncoding, g_szHeader_AcceptEncoding        },
  {  g_szServerInfo_HTTPAcceptLanguage, g_szHeader_AcceptLanguage        },
  {  g_szServerInfo_HTTPAllow,          g_szHeader_Allow                 },
  {  g_szServerInfo_HTTPAuthorization,  g_szHeader_Authorization         },
  {  g_szServerInfo_HTTPCookie,         g_szHeader_Cookie                },
  {  g_szServerInfo_HTTPDate,  	        g_szHeader_Date                  },
  {  g_szServerInfo_HTTPExpires,        g_szHeader_Expires               },
  {  g_szServerInfo_HTTPFrom,           g_szHeader_From                  },
  {  g_szServerInfo_HTTPIfModifiedSince,g_szHeader_IfModifiedSince       },
  {  g_szServerInfo_HTTPLastModified,   g_szHeader_LastModified          },
  {  g_szServerInfo_HTTPMimeVersion,    g_szHeader_MimeVersion           },
  {  g_szServerInfo_HTTPPragma,	        g_szHeader_Pragma                },
  {  g_szServerInfo_HTTPReferer,	g_szHeader_Referer               },
  {  g_szServerInfo_HTTPUserAgent,	g_szHeader_UserAgent             },
  {  g_szServerInfo_HTTPGSWebRecording, g_szHeader_GSWeb_Recording       },
  {  g_szServerInfo_QueryString,        g_szHeader_GSWeb_QueryString     },
  {  g_szServerInfo_RemoteAddress,      g_szHeader_GSWeb_RemoteAddress   },
  {  g_szServerInfo_RemoteHost,         g_szHeader_GSWeb_RemoteHost      },
  {  g_szServerInfo_RemoteIdent,        g_szHeader_GSWeb_RemoteIdent     },
  {  g_szServerInfo_RemoteUser,         g_szHeader_GSWeb_RemoteUser      },
  {  g_szServerInfo_RequestMethod,      g_szHeader_GSWebRequestMethod    },
  {  g_szServerInfo_ServerName,         g_szHeader_GSWeb_ServerName      },
  {  g_szServerInfo_ServerPort,         g_szHeader_GSWeb_ServerPort      },
  {  g_szServerInfo_ServerSoftware,     g_szHeader_GSWeb_ServerSoftware  },
  {  NULL,                              NULL                             }
};

#define	GSWHeaderTranslationTable_HeaderNb	(sizeof(GSWHeaderTranslationTable)/sizeof(GSWHeaderTranslationTable[0]))
*/
#endif	// _GSWHTTPHeaders_h__


