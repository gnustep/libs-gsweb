/* constants.h - constants
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
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

// $Id$

#ifndef _GSWebConstants_h__
#define _GSWebConstants_h__

//====================================================================
// -
/*
typedef  NSBoolNumber* BOOLNB;
extern NSBoolNumber* BNYES;
extern NSBoolNumber* BNNO;
*/

extern NSString* NSTYES;
extern NSString* NSTNO;


//====================================================================
// Suffixes
extern NSString* GSWApplicationSuffix;
extern NSString* GSWApplicationPSuffix;
extern NSString* GSWPageSuffix;
extern NSString* GSWPagePSuffix;
extern NSString* GSWScriptSuffix;
extern NSString* GSWScriptPSuffix;
extern NSString* GSWResourceRequestHandlerKey;
extern NSString* GSWComponentRequestHandlerKey;
extern NSString* GSWDirectActionRequestHandlerKey;
extern NSString* GSWComponentTemplateSuffix;
extern NSString* GSWComponentTemplatePSuffix;
extern NSString* GSWComponentDefinitionSuffix;
extern NSString* GSWComponentDefinitionPSuffix;
extern NSString* GSWLibrarySuffix;
extern NSString* GSWLibraryPSuffix;
extern NSString* GSWArchiveSuffix;
extern NSString* GSWArchivePSuffix;
extern NSString* GSWURLPrefix;
extern NSString* GSFrameworkSuffix;
extern NSString* GSFrameworkPSuffix;
extern NSString* GSLanguageSuffix;
extern NSString* GSLanguagePSuffix;
extern NSString* GSWStringTableSuffix;
extern NSString* GSWStringTablePSuffix;
extern NSString* GSWStringTableArraySuffix;
extern NSString* GSWStringTableArrayPSuffix;
extern NSString* GSWMainPageName;
extern NSString* GSWMonitorServiceName;
extern NSString* GSWAPISuffix;
extern NSString* GSWAPIPSuffix;


//====================================================================
// User Class Names

extern NSString* GSWClassName_Session;
extern NSString* GSWClassName_Application;
extern NSString* GSWClassName_DefaultAdaptor;

//====================================================================
// Keys

extern NSString* GSWKey_InstanceID;
extern NSString* GSWKey_SessionID;
extern NSString* GSWKey_PageName;
extern NSString* GSWKey_ContextID;
extern NSString* GSWKey_ElementID;
extern NSString* GSWKey_Data;
extern NSString* GSWKey_SubmitAction;
extern NSString* GSWKey_IsmapCoords;

//====================================================================
// HTTP Headers
extern NSString* GSWHTTPHeader_Cookie;
extern NSString* GSWHTTPHeader_SetCookie;
extern NSString* GSWHTTPHeader_AdaptorVersion;
extern NSString* GSWHTTPHeader_RequestMethod;
extern NSString* GSWHTTPHeader_Recording;
extern NSString* GSWHTTPHeader_QueryString;
extern NSString* GSWHTTPHeader_RemoteAddress;
extern NSString* GSWHTTPHeader_RemoteHost;
extern NSString* GSWHTTPHeader_RemoteIdent;
extern NSString* GSWHTTPHeader_RemoteUser;
extern NSString* GSWHTTPHeader_ServerName;
extern NSString* GSWHTTPHeader_ServerPort;
extern NSString* GSWHTTPHeader_ServerSoftware;
extern NSString* GSWHTTPHeader_AnnotationServer;
extern NSString* GSWHTTPHeader_AuthPass;
extern NSString* GSWHTTPHeader_AuthType;
extern NSString* GSWHTTPHeader_DocumentRoot;
extern NSString* GSWHTTPHeader_GatewayInterface;
extern NSString* GSWHTTPHeader_Method;
extern NSString* GSWHTTPHeader_MethodPost;
extern NSString* GSWHTTPHeader_MethodGet;
extern NSString* GSWHTTPHeader_AcceptLanguage;
extern NSString* GSWHTTPHeader_ContentType;
extern NSString* GSWHTTPHeader_FormURLEncoded;
extern NSString* GSWHTTPHeader_MultipartFormData;
extern NSString* GSWHTTPHeader_ContentLength;
extern NSString* GSWHTTPHeader_MimeType_TextPlain;

extern NSString* GSWHTTPHeader_Response_OK;
extern NSString* GSWHTTPHeader_Response_HeaderLineEnd;

extern NSString* GSWFormValue_RemoteInvocationPost;

//====================================================================
// Notifications
extern NSString* GSWNotification__SessionDidTimeOutNotification;

//====================================================================
// Frameworks

#if !GSWEB_STRICT
	extern NSString* GSWFramework_all;
#endif
extern NSString* GSWFramework_app;
extern NSString* GSWFramework_extensions;

//====================================================================
// Protocols

extern NSString* GSWProtocol_HTTP;
extern NSString* GSWProtocol_HTTPS;

//====================================================================
// Option Names

extern NSString* GSWOPT_Adaptor;
extern NSString* GSWOPT_AdditionalAdaptors;
extern NSString* GSWOPT_ApplicationBaseURL;
extern NSString* GSWOPT_AutoOpenInBrowser;
extern NSString* GSWOPT_CGIAdaptorURL;
extern NSString* GSWOPT_CachingEnabled;
extern NSString* GSWOPT_ComponentRequestHandlerKey;
extern NSString* GSWOPT_DebuggingEnabled;
extern NSString* GSWOPT_DirectActionRequestHandlerKey;
extern NSString* GSWOPT_DirectConnectEnabled;
extern NSString* GSWOPT_FrameworksBaseURL;
extern NSString* GSWOPT_IncludeCommentsInResponse;
extern NSString* GSWOPT_ListenQueueSize;
extern NSString* GSWOPT_LoadFrameworks;
extern NSString* GSWOPT_MonitorEnabled;
extern NSString* GSWOPT_MonitorHost;
extern NSString* GSWOPT_Port;
extern NSString* GSWOPT_Host;
extern NSString* GSWOPT_ResourceRequestHandlerKey;
extern NSString* GSWOPT_SMTPHost;
extern NSString* GSWOPT_SessionTimeOut;
extern NSString* GSWOPT_WorkerThreadCount;
extern NSString* GSWOPT_ProjectSearchPath;
extern NSString* GSWOPT_MultiThreadEnabled;


//====================================================================
// Cache Marker

extern NSString* GSNotFoundMarker;
extern NSString* GSFoundMarker;

//====================================================================
// GSWAssociation special keys

#if !GSWEB_STRICT
	extern NSString* GSASK_Field;
	extern NSString* GSASK_FieldValidate;
	extern NSString* GSASK_FieldTitle;
	extern NSString* GSASK_Class;
#endif

//====================================================================
// Page names

extern NSString* GSWSessionRestorationErrorPageName;
extern NSString* GSWExceptionPageName;
extern NSString* GSWPageRestorationErrorPageName;

//====================================================================
// Thread Keys

extern NSString* GSWThreadKey_ComponentDefinition;
extern NSString* GSWThreadKey_DefaultAdaptorThread;
extern NSString* GSWThreadKey_Context;

//====================================================================
// Components Keys

extern id value__Key;
extern id action__Key;
extern id name__Key;
extern id disabled__Key;
extern id dateFormat__Key;
extern id numberFormat__Key;
extern id href__Key;
extern id queryDictionary__Key;
extern id multipleSubmit__Key;
extern id src__Key;
extern id filename__Key;
extern id framework__Key;
extern id imageMapFileName__Key;
extern id x__Key;
extern id y__Key;
extern id target__Key;
extern id code__Key;
extern id width__Key;
extern id height__Key;
extern id associationClass__Key;
extern id codeBase__Key;
extern id archive__Key;
extern id archiveNames__Key;
extern id object__Key;
extern id hspace__Key;
extern id vspace__Key;
extern id align__Key;
extern id list__Key;
extern id sublist__Key;
extern id item__Key;
extern id selections__Key;
extern id multiple__Key;
extern id size__Key;
extern id selection__Key;
extern id checked__Key;
extern id condition__Key;
extern id negate__Key;
extern id pageName__Key;
extern id elementName__Key;
extern id fragmentIdentifier__Key;
extern id string__Key;
extern id scriptFile__Key;
extern id scriptString__Key;
extern id scriptSource__Key;
extern id hideInComment__Key;
extern id index__Key;
extern id identifier__Key;
extern id count__Key;
extern id escapeHTML__Key;
extern id GSWComponentName__Key;
extern id prefix__Key;
extern id suffix__Key;
extern id level__Key;
extern id isOrdered__Key;
extern id useDecimalNumber__Key;
extern id formatter__Key;
extern id actionClass__Key;
extern id directActionName__Key;
extern id file__Key;
extern id data__Key;
extern id mimeType__Key;
extern id key__Key;
extern id selectedValue__Key;
extern id noSelectionString__Key;
extern id displayString__Key;
extern id filePath__Key;

#if !GSWEB_STRICT
	extern id redirectURL__Key;
	extern id displayDisabled__Key;
	extern id actionYes__Key;
	extern id actionNo__Key;
	extern id pageSetVar__Prefix__Key;
	extern id pageSetVars__Key;
	extern id selectionValue__Key;
	extern id enabled__Key;
	extern id convertHTML__Key;
	extern id convertHTMLEntities__Key;
	extern id componentDesign__Key;
	extern id pageDesign__Key;
	extern id imageMapString__Key;
	extern id imageMapRegions__Key;
	extern id handleValidationException__Key;
#endif


#endif // _GSWebConstants_h__

