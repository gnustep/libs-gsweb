/* config.h - GSWeb: Adaptors: Config
   Copyright (C) 1999, 2000, 2001, 2002, 2003 Free Software Foundation, Inc.
   
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

#ifndef _GSWebConfig_h__
#define _GSWebConfig_h__

#include <sys/param.h>

#ifdef __cplusplus
extern "C" {
#endif //_cplusplus

#if defined(Apache2)
#define Apache
#endif

#define CONST const
#define DEBUG

#define	GSWEB_SERVER_ADAPTOR_VERSION_MAJOR         1
#define	GSWEB_SERVER_ADAPTOR_VERSION_MAJOR_STRING "1"
#define	GSWEB_SERVER_ADAPTOR_VERSION_MINOR         1
#define	GSWEB_SERVER_ADAPTOR_VERSION_MINOR_STRING "1"

#define	GSWEB_VERSION_MAJOR	1
#define GSWEB_VERSION_MINOR	0

#if GSWEB_WONAMES
#define	GSWEB_PREFIX	"/WebObjects"
#define	GSWEB_HANDLER	"WebObjects"
#else
#define	GSWEB_PREFIX	"/GSWeb"
#define	GSWEB_HANDLER	"GSWeb"
#endif
#define	GSWEB_STATUS_RESPONSE_APP_NAME	"status"

#define GSWAPP_EXTENSION_WO ".woa"
#define GSWAPP_EXTENSION_GSW ".gswa"

// Time Outs ...
#define	APP_CONNECT_TIMEOUT		300
#define	RESPONSE__LINE_MAX_SIZE		8192
#define	APP_CONNECT_RETRY_DELAY		3
#define	APP_CONNECT_RETRIES_NB		10


#define	HITS_PER_SECOND			80
#define	CONFIG_FILE_STAT_INTERVAL 	10


// Configuration Strings
#if GSWEB_WONAMES
#define	GSWEB__MIME_TYPE		"application/x-httpd-webobjects"
#else
#define	GSWEB__MIME_TYPE		"application/x-httpd-gsweb"
#endif
// Config File Keywords

// All
//#define GSWEB_CONF__DOC_ROOT		"GSWeb_DocumentRoot"
#define GSWEB_CONF__CONFIG_FILE_PATH	"GSWeb_ConfigFilePath"

// Aapche
#if defined(Apache)
#define GSWEB_CONF__ALIAS	"GSWeb_Alias"
#endif

// Netscape
#if	defined(Netscape)
#define	GSWEB_CONF__PATH_TRANS	"from"			// NameTrans
#define	GSWEB_CONF__APP_ROOT	"dir"			// NameTrans
#define	GSWEB_CONF__NAME	"name"			// NameTrans, Object 
#endif


#define	GSWEB_INSTANCE_COOKIE_WO	"woinst="
#define	GSWEB_INSTANCE_COOKIE_GSW	"gswinst="

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
#define	SERVER	"Apache"
#elif defined(Netscape)
#define	SERVER	"NSAPI"
#endif

#ifndef	MAXHOSTNAMELEN
#define	MAXHOSTNAMELEN	256
#endif


#ifdef __cplusplus
} // end of C header
#endif //_cplusplus

#endif
