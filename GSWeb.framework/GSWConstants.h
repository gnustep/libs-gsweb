/* GSWConstants.h - constants

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
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
#define GSWNAMES_INDEX	0
#define WONAMES_INDEX	1
extern NSString* GSWApplicationSuffix[2];
extern NSString* GSWApplicationPSuffix[2];
extern NSString* GSWPageSuffix[2];
extern NSString* GSWPagePSuffix[2];
extern NSString* GSWScriptSuffix[2];
extern NSString* GSWScriptPSuffix[2];
extern NSString* GSWResourceRequestHandlerKey[2];
extern NSString* GSWComponentRequestHandlerKey[2];
extern NSString* GSWDirectActionRequestHandlerKey[2];
extern NSString* GSWComponentTemplateSuffix;
extern NSString* GSWComponentTemplatePSuffix;
extern NSString* GSWComponentDefinitionSuffix[2];
extern NSString* GSWComponentDefinitionPSuffix[2];
extern NSString* GSWLibrarySuffix[2];
extern NSString* GSWLibraryPSuffix[2];
extern NSString* GSWArchiveSuffix[2];
extern NSString* GSWArchivePSuffix[2];
extern NSString* GSWURLPrefix[2];

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
extern NSString* GSWClassName_DefaultAdaptor[2];
extern NSString* GSWClassName_DefaultContext[2];

//====================================================================
// Keys

extern NSString* GSWKey_InstanceID[2];
extern NSString* GSWKey_SessionID[2];
extern NSString* GSWKey_PageName[2];
extern NSString* GSWKey_ContextID[2];
extern NSString* GSWKey_ElementID[2];
extern NSString* GSWKey_Data[2];
extern NSString* GSWKey_SubmitAction[2];
extern NSString* GSWKey_IsmapCoords[2];

//====================================================================
// HTTP Headers
extern NSString* GSWHTTPHeader_Cookie;
extern NSString* GSWHTTPHeader_SetCookie;
extern NSString* GSWHTTPHeader_AdaptorVersion[2];
extern NSString* GSWHTTPHeader_RequestMethod[2];
extern NSString* GSWHTTPHeader_Recording[2];
extern NSString* GSWHTTPHeader_QueryString[2];
extern NSString* GSWHTTPHeader_RemoteAddress[2];
extern NSString* GSWHTTPHeader_RemoteHost[2];
extern NSString* GSWHTTPHeader_RemoteIdent[2];
extern NSString* GSWHTTPHeader_RemoteUser[2];
extern NSString* GSWHTTPHeader_ServerName[2];
extern NSString* GSWHTTPHeader_ServerPort[2];
extern NSString* GSWHTTPHeader_ServerSoftware[2];
extern NSString* GSWHTTPHeader_AnnotationServer[2];
extern NSString* GSWHTTPHeader_AuthPass[2];
extern NSString* GSWHTTPHeader_AuthType[2];
extern NSString* GSWHTTPHeader_DocumentRoot[2];
extern NSString* GSWHTTPHeader_GatewayInterface[2];
extern NSString* GSWHTTPHeader_Protocol[2];
extern NSString* GSWHTTPHeader_ProtocolNum[2];
extern NSString* GSWHTTPHeader_RequestScheme[2];
extern NSString* GSWHTTPHeader_ApplicationName[2];

extern NSString* GSWHTTPHeader_Method[2];
extern NSString* GSWHTTPHeader_MethodPost;
extern NSString* GSWHTTPHeader_MethodGet;
extern NSString* GSWHTTPHeader_AcceptLanguage;
extern NSString* GSWHTTPHeader_AcceptEncoding;
extern NSString* GSWHTTPHeader_ContentType;
extern NSString* GSWHTTPHeader_FormURLEncoded;
extern NSString* GSWHTTPHeader_MultipartFormData;
extern NSString* GSWHTTPHeader_ContentLength;
extern NSString* GSWHTTPHeader_MimeType_TextPlain;
extern NSString* GSWHTTPHeader_UserAgent;

extern NSString* GSWHTTPHeader_Response_OK;
extern NSString* GSWHTTPHeader_Response_HeaderLineEnd[2];

extern NSString* GSWFormValue_RemoteInvocationPost[2];

//====================================================================
// Notifications
extern NSString* GSWNotification__SessionDidTimeOutNotification[2];

//====================================================================
// Frameworks

#if !GSWEB_STRICT
	extern NSString* GSWFramework_all;
#endif
extern NSString* GSWFramework_app;
extern NSString* GSWFramework_extensions[2];

//====================================================================
// Protocols

extern NSString* GSWProtocol_HTTP;
extern NSString* GSWProtocol_HTTPS;

//====================================================================
// Option Names

extern NSString* GSWOPT_Adaptor[2];
extern NSString* GSWOPT_Context[2];
extern NSString* GSWOPT_AdditionalAdaptors[2];
extern NSString* GSWOPT_ApplicationBaseURL[2];
extern NSString* GSWOPT_AutoOpenInBrowser[2];
extern NSString* GSWOPT_CGIAdaptorURL[2];
extern NSString* GSWOPT_CachingEnabled[2];
extern NSString* GSWOPT_ComponentRequestHandlerKey[2];
extern NSString* GSWOPT_DebuggingEnabled[2];
extern NSString* GSWOPT_StatusDebuggingEnabled[2];
extern NSString* GSWOPT_DirectActionRequestHandlerKey[2];
extern NSString* GSWOPT_DirectConnectEnabled[2];
extern NSString* GSWOPT_FrameworksBaseURL[2];
extern NSString* GSWOPT_IncludeCommentsInResponse[2];
extern NSString* GSWOPT_ListenQueueSize[2];
extern NSString* GSWOPT_LoadFrameworks[2];
extern NSString* GSWOPT_MonitorEnabled[2];
extern NSString* GSWOPT_MonitorHost[2];
extern NSString* GSWOPT_Port[2];
extern NSString* GSWOPT_Host[2];
extern NSString* GSWOPT_ResourceRequestHandlerKey[2];
extern NSString* GSWOPT_SMTPHost[2];
extern NSString* GSWOPT_SessionTimeOut[2];
extern NSString* GSWOPT_WorkerThreadCount[2];
extern NSString* GSWOPT_ProjectSearchPath;
extern NSString* GSWOPT_MultiThreadEnabled;
extern NSString* GSWOPT_DebugSetConfigFilePath;
extern NSString* GSWOPT_AdaptorHost[2];
extern NSString* GSWOPT_SaveResponsesPath[2];
extern NSString* GSWOPT_DefaultTemplateParser[2];

//====================================================================
// Option Values

extern NSString* GSWOPTValue_DefaultTemplateParser_XMLHTML;
extern NSString* GSWOPTValue_DefaultTemplateParser_XMLHTMLNoOmittedTags;
extern NSString* GSWOPTValue_DefaultTemplateParser_XML;
extern NSString* GSWOPTValue_DefaultTemplateParser_ANTLR;

//====================================================================
// Cache Marker

extern NSString* GSNotFoundMarker;
extern NSString* GSFoundMarker;

//====================================================================
// GSWAssociation special keys

extern NSString* GSASK_Field;
extern NSString* GSASK_FieldValidate;
extern NSString* GSASK_FieldTitle;
extern NSString* GSASK_Class;
extern NSString* GSASK_Language;

//====================================================================
// Page names

extern NSString* GSWSessionRestorationErrorPageName[2];
extern NSString* GSWExceptionPageName[2];
extern NSString* GSWPageRestorationErrorPageName[2];

//====================================================================
// Thread Keys

extern NSString* GSWThreadKey_ComponentDefinition;
extern NSString* GSWThreadKey_DefaultAdaptorThread;
extern NSString* GSWThreadKey_Context;

//====================================================================
// Tag Name

extern NSString* GSWTag_Name[2];

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
extern id conditionValue__Key;
extern id negate__Key;
extern id pageName__Key;
extern id elementName__Key;
extern id fragmentIdentifier__Key;
extern id secure__Key;
extern id string__Key;
extern id scriptFile__Key;
extern id scriptString__Key;
extern id scriptSource__Key;
extern id hideInComment__Key;
extern id index__Key;
extern id identifier__Key;
extern id count__Key;
extern id escapeHTML__Key;
extern id GSWComponentName__Key[2];
extern id componentName__Key;
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
extern id language__Key;

//GSWeb Additions
extern id redirectURL__Key;
extern id displayDisabled__Key;
extern id actionYes__Key;
extern id actionNo__Key;
extern id pageSetVar__Prefix__Key;
extern id pageSetVars__Key;
extern id selectionValue__Key;
extern id selectionValues__Key;
extern id enabled__Key;
extern id convertHTML__Key;
extern id convertHTMLEntities__Key;
extern id componentDesign__Key;
extern id pageDesign__Key;
extern id imageMapString__Key;
extern id imageMapRegions__Key;
extern id handleValidationException__Key;
extern id selectedValues__Key;
extern id startIndex__Key;
extern id stopIndex__Key;
extern id cidStore__Key;
extern id cidKey__Key;

#endif // _GSWebConstants_h__

