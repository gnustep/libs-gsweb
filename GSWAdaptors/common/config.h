/* config.h - GSWeb: Adaptors: Config
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

#ifndef _GSWebConfig_h__
#define _GSWebConfig_h__

#include <sys/param.h>

#ifdef __cplusplus
extern "C" {
#endif //_cplusplus

#define CONST const
#define DEBUG 1

#define	GSWEB_SERVER_ADAPTOR_VERSION_MAJOR	1
#define	GSWEB_SERVER_ADAPTOR_VERSION_MAJOR_STRING	"1"
#define	GSWEB_SERVER_ADAPTOR_VERSION_MINOR	0
#define	GSWEB_SERVER_ADAPTOR_VERSION_MINOR_STRING	"0"

#define	GSWEB_VERSION_MAJOR	1
#define GSWEB_VERSION_MINOR	0

#define	GSWEB_PREFIX	"/GSWeb"
#define	GSWEB_HANDLER	"GSWeb"

#define GSWAPP_EXTENSION ".gswa"

// Time Outs ...
#define	APP_CONNECT_TIMEOUT			300
#define	RESPONSE__LINE_MAX_SIZE		8192
#define	APP_CONNECT_RETRY_DELAY		3
#define	APP_CONNECT_RETRIES_NB		10


#define	HITS_PER_SECOND				80
#define	LOG_FILE_STAT_COUNTER		(HITS_PER_SECOND*20)
#define	DUMP_FILE_STAT_COUNTER		(1)
#define	CONFIG_FILE_STAT_INTERVAL 	10


// Configuration Strings
#define	GSWEB__MIME_TYPE		"application/x-httpd-gsweb"


// Config File Keywords

// All
#define GSWEB_CONF__DOC_ROOT			"GSWeb_DocumentRoot"
#define GSWEB_CONF__CONFIG_FILE_PATH   		"GSWeb_ConfigFilePath"
#define GSWEB_CONF__LOG_FILE_PATH   		"GSWeb_LogFilePath"
#define GSWEB_CONF__LOG_FLAG_FILE_PATH   	"GSWeb_LogFlagFilePath"
#define GSWEB_CONF__DUMP_FLAG_FILE_PATH   	"GSWeb_DumpFlagFilePath"


// Aapche
#define GSWEB_CONF__ALIAS				"GSWeb_Alias"

// Netscape
#define	GSWEB_CONF__PATH_TRANS	"from"			// NameTrans
#define	GSWEB_CONF__APP_ROOT	"dir"			// NameTrans
#define	GSWEB_CONF__NAME		"name"			// NameTrans, Object 


#define DEFAULT_CONFIG_FILE_PATH 	"/etc/httpd/conf/gsweb.conf"
#define DEFAULT_LOG_FILE_PATH 		"/var/log/httpd/gsweb.log"
#define DEFAULT_LOG_FLAG_PATH 		"/etc/httpd/conf/gsweb-log"
#define DEFAULT_DUMP_FLAG_PATH 		"/etc/httpd/conf/gsweb-dump"

#define	DEFAULT_GSWEXTENSIONS_FRAMEWORK_WEB_SERVER_RESOURCES "/GSWeb/Frameworks/WOExtensions.framework/WebServerResources"


#define	GSWEB_INSTANCE_COOKIE	"gswinst="


/*
 *	operating specific things regarding gethostbyname()
 */
#if	defined(SOLARIS)
#define	HAS_REENTRANT_GETHOSTENT
#if defined(NSAPI) || defined(Apache)
#define	NEEDS_HSTRERR
#endif
#endif

#if defined(Apache)
#pragma message(Apache)
#define	SERVER	"Apache"
#elif defined(Netscape)
#if	defined(WAI)
#pragma message(WAI)
#define	SERVER	"WAI"
#else
#pragma message(NSAPI)
#define	SERVER	"NSAPI"
#endif
#elif defined(CGI)
#pragma message(CGI)
#define	SERVER	"CGI"
#else
#pragma message(Unknwon)
#define	SERVER	"Unknown"
#endif 


#ifndef	MAXHOSTNAMELEN
#define	MAXHOSTNAMELEN	256	/* reasonable default */
#endif


#ifdef __cplusplus
} // end of C header
#endif //_cplusplus

#endif
