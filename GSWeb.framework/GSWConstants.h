/** GSWConstants.h - <title>constants</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$
   $Id$
   
   <abstract></abstract>

   This file is part of the GNUstep Web Library.

   <license>
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
   </license>
**/

// $Id$

#ifndef _GSWebConstants_h__
#define _GSWebConstants_h__

//====================================================================
// -
/*
typedef  NSBoolNumber* BOOLNB;
GSWEB_EXPORT NSBoolNumber* BNYES;
GSWEB_EXPORT NSBoolNumber* BNNO;
*/

GSWEB_EXPORT NSString* NSTYES;
GSWEB_EXPORT NSString* NSTNO;


//====================================================================
// Suffixes
#define GSWNAMES_INDEX	0
#define WONAMES_INDEX	1
GSWEB_EXPORT NSString* GSWApplicationSuffix[2];
GSWEB_EXPORT NSString* GSWApplicationPSuffix[2];
GSWEB_EXPORT NSString* GSWPageSuffix[2];
GSWEB_EXPORT NSString* GSWPagePSuffix[2];
GSWEB_EXPORT NSString* GSWScriptSuffix[2];
GSWEB_EXPORT NSString* GSWScriptPSuffix[2];
GSWEB_EXPORT NSString* GSWResourceRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWComponentRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWDirectActionRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWPingActionRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWStaticResourceRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWComponentTemplateSuffix;
GSWEB_EXPORT NSString* GSWComponentTemplatePSuffix;
GSWEB_EXPORT NSString* GSWComponentDeclarationsSuffix[2];
GSWEB_EXPORT NSString* GSWComponentDeclarationsPSuffix[2];
GSWEB_EXPORT NSString* GSWLibrarySuffix[2];
GSWEB_EXPORT NSString* GSWLibraryPSuffix[2];
GSWEB_EXPORT NSString* GSWArchiveSuffix[2];
GSWEB_EXPORT NSString* GSWArchivePSuffix[2];
GSWEB_EXPORT NSString* GSWURLPrefix[2];

GSWEB_EXPORT NSString* GSFrameworkSuffix;
GSWEB_EXPORT NSString* GSFrameworkPSuffix;
GSWEB_EXPORT NSString* GSLanguageSuffix;
GSWEB_EXPORT NSString* GSLanguagePSuffix;
GSWEB_EXPORT NSString* GSWStringTableSuffix;
GSWEB_EXPORT NSString* GSWStringTablePSuffix;
GSWEB_EXPORT NSString* GSWStringTableArraySuffix;
GSWEB_EXPORT NSString* GSWStringTableArrayPSuffix;
GSWEB_EXPORT NSString* GSWMainPageName;
GSWEB_EXPORT NSString* GSWMonitorServiceName;
GSWEB_EXPORT NSString* GSWAPISuffix;
GSWEB_EXPORT NSString* GSWAPIPSuffix;


//====================================================================
// User Class Names

GSWEB_EXPORT NSString* GSWClassName_Session;
GSWEB_EXPORT NSString* GSWClassName_Application;
GSWEB_EXPORT NSString* GSWClassName_ResourceManager[2];
GSWEB_EXPORT NSString* GSWClassName_StatisticsStore[2];
GSWEB_EXPORT NSString* GSWClassName_ServerSessionStore[2];
GSWEB_EXPORT NSString* GSWClassName_DefaultAdaptor[2];
GSWEB_EXPORT NSString* GSWClassName_DefaultContext[2];
GSWEB_EXPORT NSString* GSWClassName_DefaultResponse[2];
GSWEB_EXPORT NSString* GSWClassName_DefaultRequest[2];
GSWEB_EXPORT NSString* GSWClassName_DefaultRecording[2];

//====================================================================
// Keys

GSWEB_EXPORT NSString* GSWKey_InstanceID[2];
GSWEB_EXPORT NSString* GSWKey_SessionID[2];
GSWEB_EXPORT NSString* GSWKey_PageName[2];
GSWEB_EXPORT NSString* GSWKey_ContextID[2];
GSWEB_EXPORT NSString* GSWKey_ElementID[2];
GSWEB_EXPORT NSString* GSWKey_Data[2];
GSWEB_EXPORT NSString* GSWKey_SubmitAction[2];
GSWEB_EXPORT NSString* GSWKey_IsmapCoords[2];

//====================================================================
// HTTP Headers
GSWEB_EXPORT NSString* GSWHTTPHeader_Cookie;
GSWEB_EXPORT NSString* GSWHTTPHeader_CookieStupidIIS;
GSWEB_EXPORT NSString* GSWHTTPHeader_SetCookie;
GSWEB_EXPORT NSString* GSWHTTPHeader_AdaptorVersion[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_RequestMethod[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_Recording[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_QueryString[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_RemoteAddress[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_RemoteHost[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_RemoteIdent[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_RemoteUser[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_ServerName[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_ServerPort[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_ServerSoftware[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_AnnotationServer[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_AuthPass[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_AuthType[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_DocumentRoot[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_GatewayInterface[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_Protocol[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_ProtocolNum[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_RequestScheme[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_ApplicationName[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_RecordingSessionID[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_RecordingIDsURL[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_RecordingIDsCookie[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_RecordingApplicationNumber[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_LoadAverage[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_RefuseSessions[2];

// Header key to return statistics to Adaptor
GSWEB_EXPORT NSString* GSWHTTPHeader_AdaptorStats[2];

GSWEB_EXPORT NSString* GSWHTTPHeader_Method[2];
GSWEB_EXPORT NSString* GSWHTTPHeader_MethodPost;
GSWEB_EXPORT NSString* GSWHTTPHeader_MethodGet;
GSWEB_EXPORT NSString* GSWHTTPHeader_AcceptLanguage;
GSWEB_EXPORT NSString* GSWHTTPHeader_AcceptEncoding;
GSWEB_EXPORT NSString* GSWHTTPHeader_ContentType;
GSWEB_EXPORT NSString* GSWHTTPHeader_FormURLEncoded;
GSWEB_EXPORT NSString* GSWHTTPHeader_MultipartFormData;
GSWEB_EXPORT NSString* GSWHTTPHeader_ContentLength;
GSWEB_EXPORT NSString* GSWHTTPHeader_MimeType_TextPlain;
GSWEB_EXPORT NSString* GSWHTTPHeader_UserAgent;
GSWEB_EXPORT NSString* GSWHTTPHeader_Referer;

GSWEB_EXPORT NSString* GSWHTTPHeader_Response_OK;
GSWEB_EXPORT NSString* GSWHTTPHeader_Response_HeaderLineEnd[2];

GSWEB_EXPORT NSString* GSWFormValue_RemoteInvocationPost[2];

//====================================================================
// Notifications
GSWEB_EXPORT NSString* GSWNotification__SessionDidTimeOutNotification[2];

//====================================================================
// Frameworks

#if !GSWEB_STRICT
	GSWEB_EXPORT NSString* GSWFramework_all;
#endif
GSWEB_EXPORT NSString* GSWFramework_app;
GSWEB_EXPORT NSString* GSWFramework_extensions[2];

//====================================================================
// Protocols

GSWEB_EXPORT NSString* GSWProtocol_HTTP;
GSWEB_EXPORT NSString* GSWProtocol_HTTPS;

//====================================================================
// Option Names

GSWEB_EXPORT NSString* GSWOPT_Adaptor[2];
GSWEB_EXPORT NSString* GSWOPT_Context[2];
GSWEB_EXPORT NSString* GSWOPT_Response[2];
GSWEB_EXPORT NSString* GSWOPT_Request[2];
GSWEB_EXPORT NSString* GSWOPT_AdditionalAdaptors[2];
GSWEB_EXPORT NSString* GSWOPT_ApplicationBaseURL[2];
GSWEB_EXPORT NSString* GSWOPT_AutoOpenInBrowser[2];
GSWEB_EXPORT NSString* GSWOPT_CGIAdaptorURL[2];
GSWEB_EXPORT NSString* GSWOPT_CachingEnabled[2];
GSWEB_EXPORT NSString* GSWOPT_ComponentRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWOPT_DebuggingEnabled[2];
GSWEB_EXPORT NSString* GSWOPT_StatusDebuggingEnabled[2];
GSWEB_EXPORT NSString* GSWOPT_StatusLoggingEnabled[2];
GSWEB_EXPORT NSString* GSWOPT_DirectActionRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWOPT_DirectConnectEnabled[2];
GSWEB_EXPORT NSString* GSWOPT_FrameworksBaseURL[2];
GSWEB_EXPORT NSString* GSWOPT_OutputPath[2];
GSWEB_EXPORT NSString* GSWOPT_IncludeCommentsInResponse[2];
GSWEB_EXPORT NSString* GSWOPT_ListenQueueSize[2];
GSWEB_EXPORT NSString* GSWOPT_LoadFrameworks[2];
GSWEB_EXPORT NSString* GSWOPT_LifebeatEnabled[2];
GSWEB_EXPORT NSString* GSWOPT_LifebeatDestinationHost[2];
GSWEB_EXPORT NSString* GSWOPT_LifebeatDestinationPort[2];
GSWEB_EXPORT NSString* GSWOPT_LifebeatInterval[2];
GSWEB_EXPORT NSString* GSWOPT_MonitorEnabled[2];
GSWEB_EXPORT NSString* GSWOPT_MonitorHost[2];
GSWEB_EXPORT NSString* GSWOPT_Port[2];
GSWEB_EXPORT NSString* GSWOPT_Host[2];
GSWEB_EXPORT NSString* GSWOPT_ResourceRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWOPT_StreamActionRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWOPT_PingActionRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWOPT_StaticResourceRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWOPT_SMTPHost[2];
GSWEB_EXPORT NSString* GSWOPT_SessionTimeOut[2];
GSWEB_EXPORT NSString* GSWOPT_DefaultUndoStackLimit[2];
GSWEB_EXPORT NSString* GSWOPT_LockDefaultEditingContext[2];
GSWEB_EXPORT NSString* GSWOPT_WorkerThreadCount[2];
GSWEB_EXPORT NSString* GSWOPT_WorkerThreadCountMin[2];
GSWEB_EXPORT NSString* GSWOPT_WorkerThreadCountMax[2];
GSWEB_EXPORT NSString* GSWOPT_ProjectSearchPath;
GSWEB_EXPORT NSString* GSWOPT_MultiThreadEnabled;
GSWEB_EXPORT NSString* GSWOPT_DebugSetConfigFilePath;
GSWEB_EXPORT NSString* GSWOPT_AdaptorHost[2];
GSWEB_EXPORT NSString* GSWOPT_RecordingPath[2];
GSWEB_EXPORT NSString* GSWOPT_DefaultTemplateParser[2];
GSWEB_EXPORT NSString* GSWOPT_AcceptedContentEncoding[2];
GSWEB_EXPORT NSString* GSWOPT_SessionStoreClassName[2];
GSWEB_EXPORT NSString* GSWOPT_ResourceManagerClassName[2];
GSWEB_EXPORT NSString* GSWOPT_StatisticsStoreClassName[2];
GSWEB_EXPORT NSString* GSWOPT_RecordingClassName[2];
GSWEB_EXPORT NSString* GSWOPT_DisplayExceptionPages[2];
GSWEB_EXPORT NSString* GSWOPT_AllowsCacheControlHeader[2];



//====================================================================
// Option Values

GSWEB_EXPORT NSString* GSWOPTValue_DefaultTemplateParser_XMLHTML;
GSWEB_EXPORT NSString* GSWOPTValue_DefaultTemplateParser_XMLHTMLNoOmittedTags;
GSWEB_EXPORT NSString* GSWOPTValue_DefaultTemplateParser_XML;
GSWEB_EXPORT NSString* GSWOPTValue_DefaultTemplateParser_ANTLR;
GSWEB_EXPORT NSString* GSWOPTValue_DefaultTemplateParser_RawHTML;
GSWEB_EXPORT NSString* GSWOPTValue_ComponentRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWOPTValue_ResourceRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWOPTValue_DirectActionRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWOPTValue_StreamActionRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWOPTValue_PingActionRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWOPTValue_StaticResourceRequestHandlerKey[2];
GSWEB_EXPORT NSString* GSWOPTValue_SessionStoreClassName[2];

//====================================================================
// Cache Marker

GSWEB_EXPORT NSString* GSNotFoundMarker;
GSWEB_EXPORT NSString* GSFoundMarker;

//====================================================================
// GSWAssociation special keys

GSWEB_EXPORT NSString* GSASK_Field;
GSWEB_EXPORT NSString* GSASK_FieldValidate;
GSWEB_EXPORT NSString* GSASK_FieldTitle;
GSWEB_EXPORT NSString* GSASK_Class;
GSWEB_EXPORT NSString* GSASK_Language;

//====================================================================
// Page names

GSWEB_EXPORT NSString* GSWSessionRestorationErrorPageName[2];
GSWEB_EXPORT NSString* GSWSessionCreationErrorPageName[2];
GSWEB_EXPORT NSString* GSWExceptionPageName[2];
GSWEB_EXPORT NSString* GSWPageRestorationErrorPageName[2];

//====================================================================
// Thread Keys

GSWEB_EXPORT NSString* GSWThreadKey_ComponentDefinition;
GSWEB_EXPORT NSString* GSWThreadKey_DefaultAdaptorThread;
GSWEB_EXPORT NSString* GSWThreadKey_Context;

//====================================================================
// Tag Name

GSWEB_EXPORT NSString* GSWTag_Name[2];

//====================================================================
// Components Keys

GSWEB_EXPORT id value__Key;
GSWEB_EXPORT id action__Key;
GSWEB_EXPORT id name__Key;
GSWEB_EXPORT id disabled__Key;
GSWEB_EXPORT id dateFormat__Key;
GSWEB_EXPORT id dateFormat__AltKey;
GSWEB_EXPORT id numberFormat__Key;
GSWEB_EXPORT id numberFormat__AltKey;
GSWEB_EXPORT id href__Key;
GSWEB_EXPORT id queryDictionary__Key;
GSWEB_EXPORT id multipleSubmit__Key;
GSWEB_EXPORT id src__Key;
GSWEB_EXPORT id filename__Key;
GSWEB_EXPORT id framework__Key;
GSWEB_EXPORT id imageMapFileName__Key;
GSWEB_EXPORT id x__Key;
GSWEB_EXPORT id y__Key;
GSWEB_EXPORT id target__Key;
GSWEB_EXPORT id code__Key;
GSWEB_EXPORT id width__Key;
GSWEB_EXPORT id height__Key;
GSWEB_EXPORT id associationClass__Key;
GSWEB_EXPORT id codeBase__Key;
GSWEB_EXPORT id archive__Key;
GSWEB_EXPORT id archiveNames__Key;
GSWEB_EXPORT id object__Key;
GSWEB_EXPORT id hspace__Key;
GSWEB_EXPORT id vspace__Key;
GSWEB_EXPORT id align__Key;
GSWEB_EXPORT id list__Key;
GSWEB_EXPORT id sublist__Key;
GSWEB_EXPORT id item__Key;
GSWEB_EXPORT id selections__Key;
GSWEB_EXPORT id multiple__Key;
GSWEB_EXPORT id size__Key;
GSWEB_EXPORT id selection__Key;
GSWEB_EXPORT id checked__Key;
GSWEB_EXPORT id condition__Key;
GSWEB_EXPORT id conditionValue__Key;
GSWEB_EXPORT id negate__Key;
GSWEB_EXPORT id pageName__Key;
GSWEB_EXPORT id elementName__Key;
GSWEB_EXPORT id fragmentIdentifier__Key;
GSWEB_EXPORT id secure__Key;
GSWEB_EXPORT id string__Key;
GSWEB_EXPORT id scriptFile__Key;
GSWEB_EXPORT id scriptString__Key;
GSWEB_EXPORT id scriptSource__Key;
GSWEB_EXPORT id hideInComment__Key;
GSWEB_EXPORT id index__Key;
GSWEB_EXPORT id identifier__Key;
GSWEB_EXPORT id count__Key;
GSWEB_EXPORT id escapeHTML__Key;
GSWEB_EXPORT id GSWComponentName__Key[2];
GSWEB_EXPORT id componentName__Key;
GSWEB_EXPORT id prefix__Key;
GSWEB_EXPORT id suffix__Key;
GSWEB_EXPORT id level__Key;
GSWEB_EXPORT id isOrdered__Key;
GSWEB_EXPORT id useDecimalNumber__Key;
GSWEB_EXPORT id formatter__Key;
GSWEB_EXPORT id actionClass__Key;
GSWEB_EXPORT id directActionName__Key;
GSWEB_EXPORT id file__Key;
GSWEB_EXPORT id data__Key;
GSWEB_EXPORT id mimeType__Key;
GSWEB_EXPORT id key__Key;
GSWEB_EXPORT id selectedValue__Key;
GSWEB_EXPORT id noSelectionString__Key;
GSWEB_EXPORT id displayString__Key;
GSWEB_EXPORT id filePath__Key;
GSWEB_EXPORT id language__Key;
GSWEB_EXPORT id omitTags__Key;
GSWEB_EXPORT id formValue__Key;
GSWEB_EXPORT id formValues__Key;
GSWEB_EXPORT id invokeAction__Key;
GSWEB_EXPORT id elementID__Key;
GSWEB_EXPORT id otherTagString__Key;

//GSWeb Additions
GSWEB_EXPORT id redirectURL__Key;
GSWEB_EXPORT id displayDisabled__Key;
GSWEB_EXPORT id actionYes__Key;
GSWEB_EXPORT id actionNo__Key;
GSWEB_EXPORT id pageSetVar__Prefix__Key;
GSWEB_EXPORT id pageSetVars__Key;
GSWEB_EXPORT id selectionValue__Key;
GSWEB_EXPORT id selectionValues__Key;
GSWEB_EXPORT id enabled__Key;
GSWEB_EXPORT id convertHTML__Key;
GSWEB_EXPORT id convertHTMLEntities__Key;
GSWEB_EXPORT id componentDesign__Key;
GSWEB_EXPORT id pageDesign__Key;
GSWEB_EXPORT id imageMapString__Key;
GSWEB_EXPORT id imageMapRegions__Key;
GSWEB_EXPORT id handleValidationException__Key;
GSWEB_EXPORT id selectedValues__Key;
GSWEB_EXPORT id startIndex__Key;
GSWEB_EXPORT id stopIndex__Key;
GSWEB_EXPORT id cidStore__Key;
GSWEB_EXPORT id cidKey__Key;
GSWEB_EXPORT id isDisplayStringBefore__Key;
GSWEB_EXPORT id urlPrefix__Key;
GSWEB_EXPORT id pathQueryDictionary__Key;
GSWEB_EXPORT id omitElement__Key;

#endif // _GSWebConstants_h__

