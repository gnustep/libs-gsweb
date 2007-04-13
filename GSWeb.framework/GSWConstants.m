/** GSWConstants.m - <title>constants</title>

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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

//====================================================================
// -
/*
NSBoolNumber* BNYES=[NSBoolNumber numberWithBool:YES];
NSBoolNumber* BNNO=[NSBoolNumber numberWithBool:NO];
*/

NSString* NSTYES=@"YES";
NSString* NSTNO=@"NO";

NSString* GSWMonitorServiceName=@"gsweb-monitor";

//====================================================================
// Suffixes
NSString* GSWApplicationSuffix[2]={ @"gswa", @"woa" };
NSString* GSWApplicationPSuffix[2]={ @".gswa", @".woa" };
NSString* GSWPageSuffix[2]={ @"gswc", @"wo" };
NSString* GSWPagePSuffix[2]={ @".gswc", @".wo" };
NSString* GSWScriptSuffix[2]={ @"gsws", @"wos" };
NSString* GSWScriptPSuffix[2]={ @".gsws", @".wos" };
NSString* GSWResourceRequestHandlerKey[2]={ @"rr", @"wr" };
NSString* GSWComponentRequestHandlerKey[2]={ @"cr", @"wo" };
NSString* GSWDirectActionRequestHandlerKey[2]={ @"dr", @"wa" };
NSString* GSWPingActionRequestHandlerKey[2]={ @"lb", @"wlb" };
NSString* GSWComponentDeclarationsSuffix[2]={ @"gswd", @"wod" };
NSString* GSWComponentDeclarationsPSuffix[2]={ @".gswd", @".wod" };
NSString* GSWArchiveSuffix[2]={ @"gswi", @"woo" };
NSString* GSWArchivePSuffix[2]={ @".gswi", @".woo" };
NSString* GSWURLPrefix[2]={ @"GSWeb", @"WebObjects" };
NSString* GSWLibrarySuffix[2]={ @"gswso", @"woso" };
NSString* GSWLibraryPSuffix[2]={ @".gswso", @".woso" };

NSString* GSFrameworkSuffix=@"framework";
NSString* GSFrameworkPSuffix=@".framework";
NSString* GSLanguageSuffix=@"lproj";
NSString* GSLanguagePSuffix=@".lproj";
NSString* GSWComponentTemplateSuffix=@"html";
NSString* GSWComponentTemplatePSuffix=@".html";
NSString* GSWStringTableSuffix=@"strings";
NSString* GSWStringTablePSuffix=@".strings";
NSString* GSWStringTableArraySuffix=@"astrings";
NSString* GSWStringTableArrayPSuffix=@".astrings";
NSString* GSWAPISuffix=@"api";
NSString* GSWAPIPSuffix=@".api";
NSString* GSWMainPageName=@"Main";

//====================================================================
// User Class Names

NSString* GSWClassName_Session=@"Session";
NSString* GSWClassName_Application=@"Application";
NSString* GSWClassName_ResourceManager[2]={ @"GSWResourceManager", @"WOResourceManager" };
NSString* GSWClassName_StatisticsStore[2]={ @"GSWStatisticsStore", @"WOStatisticsStore" };
NSString* GSWClassName_ServerSessionStore[2]={ @"GSWServerSessionStore", @"WOServerSessionStore" };
NSString* GSWClassName_DefaultAdaptor[2]={ @"GSWDefaultAdaptor", @"WODefaultAdaptor" };
NSString* GSWClassName_DefaultContext[2]={ @"GSWContext", @"WOContext" };
NSString* GSWClassName_DefaultResponse[2]={ @"GSWResponse", @"WOResponse" };
NSString* GSWClassName_DefaultRequest[2]={ @"GSWRequest", @"WORequest" };
NSString* GSWClassName_DefaultRecording[2]={ @"GSWRecording", @"WORecording" };

//====================================================================
// Keys

NSString* GSWKey_InstanceID[2]={ @"gswinst", @"woinst" };
NSString* GSWKey_SessionID[2]={ @"gswsid", @"wosid" };
NSString* GSWKey_PageName[2]={ @"gswpage", @"wopage" };
NSString* GSWKey_ContextID[2]={ @"gswcid", @"wocid" };
NSString* GSWKey_ElementID[2]={ @"gsweid", @"woeid" };
NSString* GSWKey_Data[2]={ @"gswdata", @"wodata" };
NSString* GSWKey_SubmitAction[2]={ @"GSWSubmitAction", @"WOSubmitAction" };
NSString* GSWKey_IsmapCoords[2]={ @"GSWIsmapCoords", @"WOIsmapCoords" };

//====================================================================
// HTTP Headers
NSString* GSWHTTPHeader_Cookie=@"cookie";
NSString* GSWHTTPHeader_CookieStupidIIS=@"http_cookie";
NSString* GSWHTTPHeader_SetCookie=@"set-cookie";

NSString* GSWHTTPHeader_AdaptorVersion[2]={ @"x-gsweb-adaptor-version", @"x-webobjects-adaptor-version" };
NSString* GSWHTTPHeader_Method[2]={ @"x-gsweb-request-method", @"x-webobjects-request-method" };
NSString* GSWHTTPHeader_Response_HeaderLineEnd[2]={ @"GNUstep GSWeb", @"NeXT WebObjects" };
NSString* GSWHTTPHeader_RequestMethod[2]={ @"x-gsweb-request-method", @"x-webobjects-request-method" };
NSString* GSWHTTPHeader_Recording[2]={ @"x-gsweb-recording", @"x-webobjects-recording" };
NSString* GSWHTTPHeader_QueryString[2]={ @"x-gsweb-query-string", @"x-webobjects-query-string" };
NSString* GSWHTTPHeader_RemoteAddress[2]={ @"x-gsweb-remote-addr", @"x-webobjects-remote-addr" };
NSString* GSWHTTPHeader_RemoteHost[2]={ @"x-gsweb-remote-host", @"x-webobjects-remote-host" };
NSString* GSWHTTPHeader_RemoteIdent[2]={ @"x-gsweb-remote-ident", @"x-webobjects-remote-ident" };
NSString* GSWHTTPHeader_RemoteUser[2]={ @"x-gsweb-remote-user", @"x-webobjects-remote-user" };
NSString* GSWHTTPHeader_ServerName[2]={ @"x-gsweb-server-name", @"x-webobjects-server-name" };
NSString* GSWHTTPHeader_ServerPort[2]={ @"x-gsweb-server-port", @"x-webobjects-server-port" };
NSString* GSWHTTPHeader_ServerSoftware[2]={ @"x-gsweb-server-software", @"x-webobjects-server-software" };
NSString* GSWHTTPHeader_AnnotationServer[2]={ @"x-gsweb-annotation-server", @"x-webobjects-annotation-server" };
NSString* GSWHTTPHeader_AuthPass[2]={ @"x-gsweb-auth-pass", @"x-webobjects-auth-pass" };
NSString* GSWHTTPHeader_AuthType[2]={ @"x-gsweb-auth-type", @"x-webobjects-auth-type" };
NSString* GSWHTTPHeader_DocumentRoot[2]={ @"x-gsweb-documentroot", @"x-webobjects-documentroot" };
NSString* GSWHTTPHeader_GatewayInterface[2]={ @"x-gsweb-gateway-interface", @"x-webobjects-gateway-interface" };
NSString* GSWHTTPHeader_Protocol[2]={ @"x-gsweb-server-protocol", @"x-webobjects-server-protocol" };
NSString* GSWHTTPHeader_ProtocolNum[2]={ @"x-gsweb-server-protocol-num", @"x-webobjects-server-protocol-num" };
NSString* GSWHTTPHeader_RequestScheme[2]={ @"x-gsweb-request-scheme", @"x-webobjects-request-scheme" };
NSString* GSWHTTPHeader_ApplicationName[2]={ @"x-gsweb-application-name", @"x-webobjects-application-name" };
NSString* GSWHTTPHeader_RecordingSessionID[2]={ @"x-gsweb-session-id", @"x-webobjects-session-id" };
NSString* GSWHTTPHeader_RecordingIDsURL[2]={ @"x-gsweb-ids-url", @"x-webobjects-ids-url" };
NSString* GSWHTTPHeader_RecordingIDsCookie[2]={ @"x-gsweb-ids-url", @"x-webobjects-ids-cookie" };
NSString* GSWHTTPHeader_RecordingApplicationNumber[2]={ @"x-gsweb-application-number", @"x-webobjects-application-number" };
NSString* GSWHTTPHeader_LoadAverage[2] = { @"x-gsweb-loadaverage", @"x-webobjects-loadaverage" };
NSString* GSWHTTPHeader_RefuseSessions[2] = { @"x-gsweb-refusenewsessions", @"x-webobjects-refusenewsessions" };
NSString* GSWHTTPHeader_AdaptorStats[2] = { @"x-gsweb-adaptorstats", @"x-webobjects-adaptorstats" };

NSString* GSWHTTPHeader_MethodPost=@"POST";
NSString* GSWHTTPHeader_MethodGet=@"GET";
NSString* GSWHTTPHeader_AcceptLanguage=@"accept-language";
NSString* GSWHTTPHeader_AcceptEncoding=@"accept-encoding";
NSString* GSWHTTPHeader_ContentType=@"content-type";
NSString* GSWHTTPHeader_FormURLEncoded=@"application/x-www-form-urlencoded";
NSString* GSWHTTPHeader_MultipartFormData=@"multipart/form-data";
NSString* GSWHTTPHeader_MimeType_TextPlain=@"text/plain";
NSString* GSWHTTPHeader_UserAgent=@"user-agent";
NSString* GSWHTTPHeader_Referer=@"referer";

NSString* GSWHTTPHeader_ContentLength=@"content-length";

NSString* GSWHTTPHeader_Response_OK=@"OK";

NSString* GSWFormValue_RemoteInvocationPost[2]={ @"GSWRemoteInvocationPost", @"WORemoteInvocationPost" };

//====================================================================
// Notifications

NSString* GSWNotification__SessionDidTimeOutNotification[2]={ @"GSWSessionDidTimeOutNotification", @"WOSessionDidTimeOutNotification" };
//====================================================================
// Frameworks

#if !GSWEB_STRICT
	NSString* GSWFramework_all=@"ALL";
#endif
NSString* GSWFramework_app=@"app";

NSString* GSWFramework_extensions[2]={ @"GSWExtensions", @"WOExtensions" };

//====================================================================
// Protocols

NSString* GSWProtocol_HTTP=@"http";
NSString* GSWProtocol_HTTPS=@"https";

//====================================================================
// Option Names

NSString* GSWOPT_Adaptor[2]={ @"GSWAdaptor", @"WOAdaptor" };
NSString* GSWOPT_Context[2]={ @"GSWContext", @"WOContext" };
NSString* GSWOPT_Response[2]={ @"GSWResponse", @"WOResponse" };
NSString* GSWOPT_Request[2]={ @"GSWRequest", @"WORequest" };
NSString* GSWOPT_AdditionalAdaptors[2]={ @"GSWAdditionalAdaptors", @"WOAdditionalAdaptors" };
NSString* GSWOPT_ApplicationBaseURL[2]={ @"GSWApplicationBaseURL", @"WOApplicationBaseURL" };
NSString* GSWOPT_AutoOpenInBrowser[2]={ @"GSWAutoOpenInBrowser", @"WOAutoOpenInBrowser" };
NSString* GSWOPT_CGIAdaptorURL[2]={ @"GSWCGIAdaptorURL", @"WOCGIAdaptorURL" };
NSString* GSWOPT_CachingEnabled[2]={ @"GSWCachingEnabled", @"WOCachingEnabled" };
NSString* GSWOPT_ComponentRequestHandlerKey[2]={ @"GSWComponentRequestHandlerKey", @"WOComponentRequestHandlerKey" };
NSString* GSWOPT_DebuggingEnabled[2]={ @"GSWDebuggingEnabled", @"WODebuggingEnabled" };
NSString* GSWOPT_StatusDebuggingEnabled[2]={ @"GSWStatusDebuggingEnabled", @"WOStatusDebuggingEnabled" };//NDFN
NSString* GSWOPT_StatusLoggingEnabled[2]={ @"GSWStatusLoggingEnabled", @"WOStatusLoggingEnabled" };//NDFN
NSString* GSWOPT_DirectActionRequestHandlerKey[2]={ @"GSWDirectActionRequestHandlerKey", @"WODirectActionRequestHandlerKey" };
NSString* GSWOPT_PingActionRequestHandlerKey[2]={ @"GSWPingActionRequestHandlerKey", @"WOPingActionRequestHandlerKey" };
NSString* GSWOPT_StaticResourceRequestHandlerKey[2]={ @"GSWStaticResourceRequestHandlerKey", @"WOStaticResourceRequestHandlerKey" };
NSString* GSWOPT_DirectConnectEnabled[2]={ @"GSWDirectConnectEnabled", @"WODirectConnectEnabled" };
NSString* GSWOPT_FrameworksBaseURL[2]={ @"GSWFrameworksBaseURL", @"WOFrameworksBaseURL" };
NSString* GSWOPT_OutputPath[2]={ @"GSWOutputPath", @"WOOutputPath" };
NSString* GSWOPT_IncludeCommentsInResponse[2]={ @"GSWIncludeCommentsInResponse", @"WOIncludeCommentsInResponse" };
NSString* GSWOPT_ListenQueueSize[2]={ @"GSWListenQueueSize", @"WOListenQueueSize" };
NSString* GSWOPT_LoadFrameworks[2]={ @"GSWLoadFrameworks", @"WOLoadFrameworks" };
NSString* GSWOPT_LifebeatEnabled[2]={ @"GSWLifebeatEnabled", @"WOLifebeatEnabled" };
NSString* GSWOPT_LifebeatDestinationHost[2]={ @"GSWLifebeatDestinationHost", @"WOLifebeatDestinationHost" };
NSString* GSWOPT_LifebeatDestinationPort[2]={ @"GSWLifebeatDestinationPort", @"WOLifebeatDestinationPort" };
NSString* GSWOPT_LifebeatInterval[2]={ @"GSWLifebeatInterval", @"WOLifebeatInterval" };
NSString* GSWOPT_MonitorEnabled[2]={ @"GSWMonitorEnabled", @"WOMonitorEnabled" };
NSString* GSWOPT_MonitorHost[2]={ @"GSWMonitorHost", @"WOMonitorHost" };
NSString* GSWOPT_Port[2]={ @"GSWPort", @"WOPort" };
NSString* GSWOPT_Host[2]={ @"GSWHost", @"WOHost" };
NSString* GSWOPT_ResourceRequestHandlerKey[2]={ @"GSWResourceRequestHandlerKey", @"WOResourceRequestHandlerKey" };
NSString* GSWOPT_StreamActionRequestHandlerKey[2]={ @"GSWStreamActionRequestHandlerKey", @"WOStreamActionRequestHandlerKey" };
NSString* GSWOPT_SMTPHost[2]={ @"GSWSMTPHost", @"WOSMTPHost" };
NSString* GSWOPT_SessionTimeOut[2]={ @"GSWSessionTimeOut", @"WOSessionTimeOut" };
NSString* GSWOPT_DefaultUndoStackLimit[2]={ @"GSWDefaultUndoStackLimit", @"WODefaultUndoStackLimit" };
NSString* GSWOPT_LockDefaultEditingContext[2]={ @"GSWLockDefaultEditingContext", @"WOLockDefaultEditingContext" };
NSString* GSWOPT_WorkerThreadCount[2]={ @"GSWWorkerThreadCount", @"WOWorkerThreadCount" };
NSString* GSWOPT_WorkerThreadCountMin[2]={ @"GSWWorkerThreadCountMin", @"WOWorkerThreadCountMin" };
NSString* GSWOPT_WorkerThreadCountMax[2]={ @"GSWWorkerThreadCountMax", @"WOWorkerThreadCountMax" };
NSString* GSWOPT_ProjectSearchPath=@"NSProjectSearchPath";
NSString* GSWOPT_MultiThreadEnabled=@"GSWMTEnabled";
NSString* GSWOPT_DebugSetConfigFilePath=@"GSWDebugSetConfigFilePath";
NSString* GSWOPT_AdaptorHost[2]={ @"GSWAdaptorHost", @"WOAdaptorHost" };
NSString* GSWOPT_RecordingPath[2]={ @"GSWRecordingPath", @"WORecordingPath" };
NSString* GSWOPT_DefaultTemplateParser[2]= { @"GSWDefaultTemplateParser", @"WODefaultTemplateParser" };
NSString* GSWOPT_AcceptedContentEncoding[2]= { @"GSWAcceptedContentEncoding", @"WOAcceptedContentEncoding" };
NSString* GSWOPT_SessionStoreClassName[2]= { @"GSWSessionStoreClassName", @"WOSessionStoreClassName" };
NSString* GSWOPT_ResourceManagerClassName[2]= { @"GSWResourceManagerClassName", @"WOResourceManagerClassName" };
NSString* GSWOPT_StatisticsStoreClassName[2]= { @"GSWStatisticsStoreClassName", @"WOStatisticsStoreClassName" };
NSString* GSWOPT_RecordingClassName[2]= { @"GSWRecordingClassName", @"WORecordingClassName" };
NSString* GSWOPT_DisplayExceptionPages[2]= { @"GSWDisplayExceptionPages", @"WODisplayExceptionPages" };
NSString* GSWOPT_AllowsCacheControlHeader[2]= { @"GSWAllowsCacheControlHeader", @"WOAllowsCacheControlHeader" };



//====================================================================
// Option Values

NSString* GSWOPTValue_DefaultTemplateParser_XMLHTML = @"XMLHTML";
NSString* GSWOPTValue_DefaultTemplateParser_XMLHTMLNoOmittedTags  = @"XMLHTMLNoOmittedTags";
NSString* GSWOPTValue_DefaultTemplateParser_XML = @"XML";
NSString* GSWOPTValue_DefaultTemplateParser_ANTLR = @"ANTLR";
NSString* GSWOPTValue_DefaultTemplateParser_RawHTML = @"RawHTML";
NSString* GSWOPTValue_ComponentRequestHandlerKey[2]={ @"cr", @"wo" };
NSString* GSWOPTValue_ResourceRequestHandlerKey[2]={ @"rr", @"wr" };
NSString* GSWOPTValue_DirectActionRequestHandlerKey[2]={ @"dr", @"wa" };
NSString* GSWOPTValue_StreamActionRequestHandlerKey[2]={ @"sr", @"wis" };
NSString* GSWOPTValue_PingActionRequestHandlerKey[2]={ @"lb", @"wlb" };
NSString* GSWOPTValue_StaticResourceRequestHandlerKey[2]={ @"_rr_", @"_wr_" };
NSString* GSWOPTValue_SessionStoreClassName[2]={ @"GSWServerSessionStore", @"WOServerSessionStore" };

//====================================================================
// Cache Marker
NSString* GSNotFoundMarker=@"NotFoundMarker";
NSString* GSFoundMarker=@"FoundMarker";

//====================================================================
// GSWAssociation special keys

NSString* GSASK_Field=@"GSField";
NSString* GSASK_FieldValidate=@"GSFieldValidate";
NSString* GSASK_FieldTitle=@"GSFieldTitle";
NSString* GSASK_Class = @"GSClass";
NSString* GSASK_Language = @"GSLanguage";

//====================================================================
// Page names

NSString* GSWSessionRestorationErrorPageName[2]={ @"GSWSessionRestorationErrorPage", @"WOSessionRestorationErrorPage" };
NSString* GSWSessionCreationErrorPageName[2]={ @"GSWSessionCreationErrorPage", @"WOSessionCreationError" };
NSString* GSWExceptionPageName[2]={ @"GSWExceptionPage", @"WOExceptionPage" };
NSString* GSWPageRestorationErrorPageName[2]={ @"GSWPageRestorationErrorPage", @"WOPageRestorationErrorPage" };


//====================================================================
// Thread Keys

NSString* GSWThreadKey_ComponentDefinition=@"ComponentDefinition";
NSString* GSWThreadKey_DefaultAdaptorThread=@"DefaultAdaptorThread";
NSString* GSWThreadKey_Context=@"Context";

//====================================================================
// Tag Name

NSString* GSWTag_Name[2]={ @"gsweb", @"webobject" };

//====================================================================
// Components Keys

id post__Key = @"post";
id method__Key = @"method";
id value__Key = @"value";
id valueWhenEmpty__Key = @"valueWhenEmpty";
id action__Key = @"action";
id name__Key = @"name";
id disabled__Key = @"disabled";
id dateFormat__Key = @"dateformat";
id dateFormat__AltKey = @"dateFormat";
id numberFormat__Key = @"numberformat";
id numberFormat__AltKey = @"numberFormat";
id href__Key = @"href";
id queryDictionary__Key = @"queryDictionary";
id multipleSubmit__Key = @"multipleSubmit";
id src__Key = @"src";
id filename__Key = @"filename";
id framework__Key = @"framework";
id imageMapFileName__Key = @"imageMapFile";
id x__Key = @"x";
id y__Key = @"y";
id target__Key = @"target";
id code__Key = @"code";
id width__Key = @"width";
id height__Key = @"height";
id associationClass__Key = @"associationClass";
id codeBase__Key = @"codeBase";
id archive__Key = @"archive";
id archiveNames__Key = @"archiveNames";
id object__Key = @"object";
id hspace__Key = @"hspace";
id vspace__Key = @"vspace";
id align__Key = @"align";
id list__Key = @"list";
id sublist__Key = @"sublist";
id item__Key = @"item";
id selections__Key = @"selections";
id multiple__Key = @"multiple";
id size__Key = @"size";
id selection__Key = @"selection";
id checked__Key = @"checked";
id condition__Key = @"condition";
id conditionValue__Key = @"conditionValue";
id negate__Key = @"negate";
id pageName__Key = @"pageName";
id elementName__Key = @"elementName";
id fragmentIdentifier__Key = @"fragmentIdentifier";
id secure__Key = @"secure";
id string__Key = @"string";
id scriptFile__Key = @"scriptFile";
id scriptString__Key = @"scriptString";
id scriptSource__Key = @"scriptSource";
id hideInComment__Key = @"hideInComment";
id index__Key = @"index";
id identifier__Key = @"identifier";
id count__Key = @"count";
id escapeHTML__Key = @"escapeHTML";
id GSWComponentName__Key[2] = { @"GSWComponentName", @"WOComponentName"};
id componentName__Key = @"componentName";
id prefix__Key = @"prefix";
id suffix__Key = @"suffix";
id level__Key = @"level";
id isOrdered__Key = @"isOrdered";
id useDecimalNumber__Key = @"useDecimalNumber";
id formatter__Key = @"formatter";
id actionClass__Key = @"actionClass";
id directActionName__Key = @"directActionName";
id file__Key = @"file";
id data__Key = @"data";
id mimeType__Key = @"mimeType";
id type__Key = @"type";
id key__Key = @"key";
id selectedValue__Key = @"selectedValue";
id noSelectionString__Key = @"noSelectionString";
id displayString__Key = @"displayString";
id filePath__Key = @"filePath";
id language__Key= @"language";
id omitTags__Key = @"omitTag";
id formValue__Key = @"formValue";
id formValues__Key = @"formValues";
id invokeAction__Key = @"invokeAction";
id elementID__Key = @"elementID";
id otherTagString__Key = @"otherTagString";

//GSWeb additions
id redirectURL__Key = @"redirectURL";
id displayDisabled__Key = @"displayDisabled";
id actionYes__Key = @"actionYes";
id actionNo__Key = @"actionNo";
id pageSetVar__Prefix__Key=@"pageSetVar_";
id pageSetVars__Key=@"pageSetVars";
id selectionValue__Key=@"selectionValue";
id selectionValues__Key=@"selectionValues";
id enabled__Key=@"enabled";
id convertHTML__Key=@"convertHTML";
id convertHTMLEntities__Key=@"convertHTMLEntities";
id imageMapString__Key = @"imageMapString";
id imageMapRegions__Key = @"imageMapRegions";
id handleValidationException__Key = @"handleValidationException";
id selectedValues__Key = @"selectedValues";
id startIndex__Key = @"startIndex";
id stopIndex__Key = @"stopIndex";
id cidStore__Key = @"cidStore";
id cidKey__Key = @"cidKey";
id isDisplayStringBefore__Key = @"isDisplayStringBefore";
id urlPrefix__Key = @"urlPrefix";
id pathQueryDictionary__Key = @"pathQueryDictionary";
id omitElement__Key = @"omitElement";
