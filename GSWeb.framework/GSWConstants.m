/* constants.m - constants
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

static char rcsId[] = "$Id$";

#include <gsweb/GSWeb.framework/GSWeb.h>

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
#if GSWEB_WONAMES
	NSString* GSWApplicationSuffix=@"woa";
	NSString* GSWApplicationPSuffix=@".woa";
	NSString* GSWPageSuffix=@"wo";
	NSString* GSWPagePSuffix=@".wo";
	NSString* GSWScriptSuffix=@"wos";
	NSString* GSWScriptPSuffix=@".wos";
	NSString* GSWResourceRequestHandlerKey=@"wr";
	NSString* GSWComponentRequestHandlerKey=@"wo";
	NSString* GSWDirectActionRequestHandlerKey=@"wa";
	NSString* GSWComponentDefinitionSuffix=@"wod";
	NSString* GSWComponentDefinitionPSuffix=@".wod";
	NSString* GSWArchiveSuffix=@"woo";
	NSString* GSWArchivePSuffix=@".woo";
	NSString* GSWURLPrefix=@"WebObjects";
	NSString* GSWLibrarySuffix=@"woso";
	NSString* GSWLibraryPSuffix=@".woso";
#else
	NSString* GSWApplicationSuffix=@"gswa";
	NSString* GSWApplicationPSuffix=@".gswa";
	NSString* GSWPageSuffix=@"gswc";
	NSString* GSWPagePSuffix=@".gswc";
	NSString* GSWScriptSuffix=@"gsws";
	NSString* GSWScriptPSuffix=@".gsws";
	NSString* GSWResourceRequestHandlerKey=@"rr";
	NSString* GSWComponentRequestHandlerKey=@"cr";
	NSString* GSWDirectActionRequestHandlerKey=@"dr";
	NSString* GSWComponentDefinitionSuffix=@"gswd";
	NSString* GSWComponentDefinitionPSuffix=@".gswd";
	NSString* GSWArchiveSuffix=@"gswi";
	NSString* GSWArchivePSuffix=@".gswi";
	NSString* GSWURLPrefix=@"GSWeb";
	NSString* GSWLibrarySuffix=@"gswso";
	NSString* GSWLibraryPSuffix=@".gswso";
#endif

#ifdef DEBUG
NSString* GSFrameworkSuffix=@"frameworkd";
NSString* GSFrameworkPSuffix=@".frameworkd";
#else
NSString* GSFrameworkSuffix=@"framework";
NSString* GSFrameworkPSuffix=@".framework";
#endif
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
#if GSWEB_WONAMES
NSString* GSWClassName_DefaultAdaptor=@"WODefaultAdaptor";
#else
NSString* GSWClassName_DefaultAdaptor=@"GSWDefaultAdaptor";
#endif
//====================================================================
// Keys

#if GSWEB_WONAMES
	NSString* GSWKey_InstanceID=@"woinst";
	NSString* GSWKey_SessionID=@"wosid";
	NSString* GSWKey_PageName=@"wopage";
	NSString* GSWKey_ContextID=@"wocid";
	NSString* GSWKey_ElementID=@"woeid";
	NSString* GSWKey_Data=@"wodata";
	NSString* GSWKey_SubmitAction=@"WOSubmitAction";
	NSString* GSWKey_IsmapCoords=@"WOIsmapCoords";
#else
	NSString* GSWKey_InstanceID=@"gswinst";
	NSString* GSWKey_SessionID=@"gswsid";
	NSString* GSWKey_PageName=@"gswpage";
	NSString* GSWKey_ContextID=@"gswcid";
	NSString* GSWKey_ElementID=@"gsweid";
	NSString* GSWKey_Data=@"gswdata";
	NSString* GSWKey_SubmitAction=@"GSWSubmitAction";
	NSString* GSWKey_IsmapCoords=@"GSWIsmapCoords";
#endif

//====================================================================
// HTTP Headers
NSString* GSWHTTPHeader_Cookie=@"cookie";
NSString* GSWHTTPHeader_SetCookie=@"set-cookie";

#if GSWEB_WONAMES
NSString* GSWHTTPHeader_AdaptorVersion=@"x-webobjects-adaptor-version";
NSString* GSWHTTPHeader_Method=@"x-webobjects-request-method";
NSString* GSWHTTPHeader_Response_HeaderLineEnd=@" NeXT WebObjects";
NSString* GSWHTTPHeader_RequestMethod=@"x-webobjects-request-method";
NSString* GSWHTTPHeader_Recording=@"x-webobjects-recording";
NSString* GSWHTTPHeader_QueryString=@"x-webobjects-query-string";
NSString* GSWHTTPHeader_RemoteAddress=@"x-webobjects-remote-addr";
NSString* GSWHTTPHeader_RemoteHost=@"x-webobjects-remote-host";
NSString* GSWHTTPHeader_RemoteIdent=@"x-webobjects-remote-ident";
NSString* GSWHTTPHeader_RemoteUser=@"x-webobjects-remote-user";
NSString* GSWHTTPHeader_ServerName=@"x-webobjects-server-name";
NSString* GSWHTTPHeader_ServerPort=@"x-webobjects-server-port";
NSString* GSWHTTPHeader_ServerSoftware=@"x-webobjects-server-software";
NSString* GSWHTTPHeader_AnnotationServer=@"x-webobjects-annotation-server";
NSString* GSWHTTPHeader_AuthPass=@"x-webobjects-auth-pass";
NSString* GSWHTTPHeader_AuthType=@"x-webobjects-auth-type";
NSString* GSWHTTPHeader_DocumentRoot=@"x-webobjects-documentroot";
NSString* GSWHTTPHeader_GatewayInterface=@"x-webobjects-gateway-interface";

#else
NSString* GSWHTTPHeader_AdaptorVersion=@"x-gsweb-adaptor-version";
NSString* GSWHTTPHeader_Method=@"x-gsweb-request-method";
NSString* GSWHTTPHeader_Response_HeaderLineEnd=@" GNUstep GSWeb";
NSString* GSWHTTPHeader_RequestMethod=@"x-gsweb-request-method";
NSString* GSWHTTPHeader_Recording=@"x-gsweb-recording";
NSString* GSWHTTPHeader_QueryString=@"x-gsweb-query-string";
NSString* GSWHTTPHeader_RemoteAddress=@"x-gsweb-remote-addr";
NSString* GSWHTTPHeader_RemoteHost=@"x-gsweb-remote-host";
NSString* GSWHTTPHeader_RemoteIdent=@"x-gsweb-remote-ident";
NSString* GSWHTTPHeader_RemoteUser=@"x-gsweb-remote-user";
NSString* GSWHTTPHeader_ServerName=@"x-gsweb-server-name";
NSString* GSWHTTPHeader_ServerPort=@"x-gsweb-server-port";
NSString* GSWHTTPHeader_ServerSoftware=@"x-gsweb-server-software";
NSString* GSWHTTPHeader_AnnotationServer=@"x-gsweb-annotation-server";
NSString* GSWHTTPHeader_AuthPass=@"x-gsweb-auth-pass";
NSString* GSWHTTPHeader_AuthType=@"x-gsweb-auth-type";
NSString* GSWHTTPHeader_DocumentRoot=@"x-gsweb-documentroot";
NSString* GSWHTTPHeader_GatewayInterface=@"x-gsweb-gateway-interface";
#endif
NSString* GSWHTTPHeader_MethodPost=@"POST";
NSString* GSWHTTPHeader_MethodGet=@"GET";
NSString* GSWHTTPHeader_AcceptLanguage=@"accept-language";
NSString* GSWHTTPHeader_ContentType=@"content-type";
NSString* GSWHTTPHeader_FormURLEncoded=@"application/x-www-form-urlencoded";
NSString* GSWHTTPHeader_MultipartFormData=@"multipart/form-data";
NSString* GSWHTTPHeader_MimeType_TextPlain=@"text/plain";

NSString* GSWHTTPHeader_ContentLength=@"content-length";

NSString* GSWHTTPHeader_Response_OK=@"OK";

#if GSWEB_WONAMES
NSString* GSWFormValue_RemoteInvocationPost=@"WORemoteInvocationPost";
#else
NSString* GSWFormValue_RemoteInvocationPost=@"GSWRemoteInvocationPost";
#endif

//====================================================================
// Notifications

#if GSWEB_WONAMES
NSString* GSWNotification__SessionDidTimeOutNotification=@"WOSessionDidTimeOutNotification";
#else
NSString* GSWNotification__SessionDidTimeOutNotification=@"GSWSessionDidTimeOutNotification";
#endif
//====================================================================
// Frameworks

#if !GSWEB_STRICT
	NSString* GSWFramework_all=@"ALL";
#endif
NSString* GSWFramework_app=@"app";

#if GSWEB_WONAMES
NSString* GSWFramework_extensions=@"WOExtensions";
#else
NSString* GSWFramework_extensions=@"GSWExtensions";
#endif

//====================================================================
// Protocols

NSString* GSWProtocol_HTTP=@"http";
NSString* GSWProtocol_HTTPS=@"https";

//====================================================================
// Option Names

#if GSWEB_WONAMES
NSString* GSWOPT_Adaptor=@"WOAdaptor";
NSString* GSWOPT_AdditionalAdaptors=@"WOAdditionalAdaptors";
NSString* GSWOPT_ApplicationBaseURL=@"WOApplicationBaseURL";
NSString* GSWOPT_AutoOpenInBrowser=@"WOAutoOpenInBrowser";
NSString* GSWOPT_CGIAdaptorURL=@"WOCGIAdaptorURL";
NSString* GSWOPT_CachingEnabled=@"WOCachingEnabled";
NSString* GSWOPT_ComponentRequestHandlerKey=@"WOComponentRequestHandlerKey";
NSString* GSWOPT_DebuggingEnabled=@"WODebuggingEnabled";
NSString* GSWOPT_StatusDebuggingEnabled=@"WOStatusDebuggingEnabled";//NDFN
NSString* GSWOPT_DirectActionRequestHandlerKey=@"WODirectActionRequestHandlerKey";
NSString* GSWOPT_DirectConnectEnabled=@"WODirectConnectEnabled";
NSString* GSWOPT_FrameworksBaseURL=@"WOFrameworksBaseURL";
NSString* GSWOPT_IncludeCommentsInResponse=@"WOIncludeCommentsInResponse";
NSString* GSWOPT_ListenQueueSize=@"WOListenQueueSize";
NSString* GSWOPT_LoadFrameworks=@"WOLoadFrameworks";
NSString* GSWOPT_MonitorEnabled=@"WOMonitorEnabled";
NSString* GSWOPT_MonitorHost=@"WOMonitorHost";
NSString* GSWOPT_Port=@"WOPort";
NSString* GSWOPT_Host=@"WOHost";
NSString* GSWOPT_ResourceRequestHandlerKey=@"WOResourceRequestHandlerKey";
NSString* GSWOPT_SMTPHost=@"WOSMTPHost";
NSString* GSWOPT_SessionTimeOut=@"WOSessionTimeOut";
NSString* GSWOPT_WorkerThreadCount=@"WOWorkerThreadCount";
NSString* GSWOPT_ProjectSearchPath=@"NSProjectSearchPath";
#else
NSString* GSWOPT_Adaptor=@"GSWAdaptor";
NSString* GSWOPT_AdditionalAdaptors=@"GSWAdditionalAdaptors";
NSString* GSWOPT_ApplicationBaseURL=@"GSWApplicationBaseURL";
NSString* GSWOPT_AutoOpenInBrowser=@"GSWAutoOpenInBrowser";
NSString* GSWOPT_CGIAdaptorURL=@"GSWCGIAdaptorURL";
NSString* GSWOPT_CachingEnabled=@"GSWCachingEnabled";
NSString* GSWOPT_ComponentRequestHandlerKey=@"GSWComponentRequestHandlerKey";
NSString* GSWOPT_DebuggingEnabled=@"GSWDebuggingEnabled";
NSString* GSWOPT_StatusDebuggingEnabled=@"GSWStatusDebuggingEnabled";//NDFN
NSString* GSWOPT_DirectActionRequestHandlerKey=@"GSWDirectActionRequestHandlerKey";
NSString* GSWOPT_DirectConnectEnabled=@"GSWDirectConnectEnabled";
NSString* GSWOPT_FrameworksBaseURL=@"GSWFrameworksBaseURL";
NSString* GSWOPT_IncludeCommentsInResponse=@"GSWIncludeCommentsInResponse";
NSString* GSWOPT_ListenQueueSize=@"GSWListenQueueSize";
NSString* GSWOPT_LoadFrameworks=@"GSWLoadFrameworks";
NSString* GSWOPT_MonitorEnabled=@"GSWMonitorEnabled";
NSString* GSWOPT_MonitorHost=@"GSWMonitorHost";
NSString* GSWOPT_Port=@"GSWPort";
NSString* GSWOPT_Host=@"GSWHost";
NSString* GSWOPT_ResourceRequestHandlerKey=@"GSWResourceRequestHandlerKey";
NSString* GSWOPT_SMTPHost=@"GSWSMTPHost";
NSString* GSWOPT_SessionTimeOut=@"GSWSessionTimeOut";
NSString* GSWOPT_WorkerThreadCount=@"GSWWorkerThreadCount";
NSString* GSWOPT_ProjectSearchPath=@"NSProjectSearchPath";
#endif
NSString* GSWOPT_MultiThreadEnabled=@"GSWMTEnabled";
NSString* GSWOPT_DebugSetConfigFilePath=@"GSWDebugSetConfigFilePath";

//====================================================================
// Cache Marker
NSString* GSNotFoundMarker=@"NotFoundMarker";
NSString* GSFoundMarker=@"FoundMarker";

//====================================================================
// GSWAssociation special keys

#if !GSWEB_STRICT
NSString* GSASK_Field=@"GSField";
NSString* GSASK_FieldValidate=@"GSFieldValidate";
NSString* GSASK_FieldTitle=@"GSFieldTitle";
NSString* GSASK_Class = @"GSClass";
#endif

//====================================================================
// Page names

#if GSWEB_WONAMES
NSString* GSWSessionRestorationErrorPageName=@"WOSessionRestorationErrorPage";
NSString* GSWExceptionPageName=@"WOExceptionPage";
NSString* GSWPageRestorationErrorPageName=@"WOPageRestorationErrorPage";
#else
NSString* GSWSessionRestorationErrorPageName=@"GSWSessionRestorationErrorPage";
NSString* GSWExceptionPageName=@"GSWExceptionPage";
NSString* GSWPageRestorationErrorPageName=@"GSWPageRestorationErrorPage";
#endif


//====================================================================
// Thread Keys

NSString* GSWThreadKey_ComponentDefinition=@"ComponentDefinition";
NSString* GSWThreadKey_DefaultAdaptorThread=@"DefaultAdaptorThread";
NSString* GSWThreadKey_Context=@"Context";
//====================================================================
// Components Keys

id value__Key = @"value";
id action__Key = @"action";
id name__Key = @"name";
id disabled__Key = @"disabled";
id dateFormat__Key = @"dateformat";
id numberFormat__Key = @"numberformat";
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
id negate__Key = @"negate";
id pageName__Key = @"pageName";
id elementName__Key = @"elementName";
id fragmentIdentifier__Key = @"fragmentIdentifier";
id string__Key = @"string";
id scriptFile__Key = @"scriptFile";
id scriptString__Key = @"scriptString";
id scriptSource__Key = @"scriptSource";
id hideInComment__Key = @"hideInComment";
id index__Key = @"index";
id identifier__Key = @"identifier";
id count__Key = @"count";
id escapeHTML__Key = @"escapeHTML";
#if GSWEB_WONAMES
	id GSWComponentName__Key = @"WOComponentName";
#else
	id GSWComponentName__Key = @"GSWComponentName";
#endif
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
id key__Key = @"key";
id selectedValue__Key = @"selectedValue";
id noSelectionString__Key = @"noSelectionString";
id displayString__Key = @"displayString";
id filePath__Key = @"filePath";
#if !GSWEB_STRICT
	id redirectURL__Key = @"redirectURL";
	id displayDisabled__Key = @"displayDisabled";
	id actionYes__Key = @"actionYes";
	id actionNo__Key = @"actionNo";
	id pageSetVar__Prefix__Key=@"pageSetVar_";
	id pageSetVars__Key=@"pageSetVars";
	id selectionValue__Key=@"selectionValue";
	id enabled__Key=@"enabled";
	id convertHTML__Key=@"convertHTML";
	id convertHTMLEntities__Key=@"convertHTMLEntities";
	id imageMapString__Key = @"imageMapString";
	id imageMapRegions__Key = @"imageMapRegions";
	id handleValidationException__Key = @"handleValidationException";
#endif
