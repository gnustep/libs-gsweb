/* GSWeb.h - GSWeb
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

#ifndef _GSWeb_h__
#define _GSWeb_h__

#ifdef SOLARIS
#include <limits.h> 
#endif
#ifdef __FreeBSD__
#include <float.h>
#endif
#include <Foundation/NSObject.h>
#include <Foundation/NSValue.h>
#include <Foundation/NSString.h>
#include <Foundation/NSArchiver.h>
#include <Foundation/NSException.h>
#include <Foundation/NSProcessInfo.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSUserDefaults.h>
#include <Foundation/NSBundle.h>
#include <Foundation/NSLock.h>
#include <Foundation/NSData.h>
#include <Foundation/NSHost.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSConnection.h>
#include <Foundation/NSDistantObject.h>
#include <Foundation/NSNotification.h>
#include <Foundation/NSRunLoop.h>
#include <Foundation/NSPortNameServer.h>
#include <Foundation/NSCharacterSet.h>
#include <Foundation/NSFileHandle.h>
#include <Foundation/NSInvocation.h>
#include <Foundation/NSMethodSignature.h>
#include <Foundation/NSURLHandle.h>
#include <Foundation/NSURL.h>
#include <Foundation/NSThread.h>
#include <Foundation/NSConcreteNumber.h>
#include <Foundation/NSGArray.h>
#include <Foundation/NSFormatter.h>
#include <Foundation/GSXML.h>
#include "GSCache.h"


#include <gsweb/GSWeb.framework/GSWConfig.h>

#if GSWEB_WONAMES
#define GSWAdaptor						WOAdaptor
#define GSWApplication					WOApplication
#define GSWAssociation					WOAssociation
#define GSWComponent					WOComponent
#define GSWContext						WOContext
#define GSWDisplayGroup					WODisplayGroup
#define GSWElement						WOElement
#define GSWDynamicElement				WODynamicElement
#define GSWRequest						WORequest
#define GSWResourceManager				WOResourceManager
#define GSWResponse						WOResponse
#define GSWSession						WOSession
#define GSWSessionStore					WOSessionStore
#define GSWStatisticsStore				WOStatisticsStore
#define GSWRequestHandler				WORequestHandler
#define GSWComponentDefinition			WOComponentDefinition
#define GSWBundle						WOBundle
#define GSWMultiKeyDictionary			WOMultiKeyDictionary
#define GSWCookie						WOCookie
#define GSWElementIDString				WOElementIDString
#define GSWDirectAction					WODirectAction
#define GSWMailDelivery					WOMailDelivery
#define GSWComponentRequestHandler		WOComponentRequestHandler
#define GSWResourceRequestHandler		WOResourceRequestHandler
#define GSWDirectActionRequestHandler	WODirectActionRequestHandler
#define GSWDefaultAdaptorThread			WODefaultAdaptorThread
#define GSWKeyValueAssociation			WOKeyValueAssociation
#define GSWConstantValueAssociation		WOConstantValueAssociation
#define GSWHTMLStaticElement			WOHTMLStaticElement
#define GSWHTMLStaticGroup				WOHTMLStaticGroup
#define GSWInput						WOInput
#define GSWComponentReference			WOComponentReference
#define GSWPageDefElement				WOPageDefElement
#define GSWBundle						WOBundle
#define GSWSessionTimeOutManager		WOSessionTimeOutManager
#define GSWServerSessionStore			WOServerSessionStore
#define GSWDeployedBundle				WODeployedBundle
#define GSWProjectBundle				WOProjectBundle
#define GSWSessionTimeOut				WOSessionTimeOut
#define GSWMultiKeyDictionary			WOMultiKeyDictionary
#define GSWTemplateParser				WOTemplateParser
#define GSWDynamicURLString				WODynamicURLString
#define GSWBindingNameAssociation		WOBindingNameAssociation
#define GSWURLValuedElementData			WOURLValuedElementData
#define GSWHTMLURLValuedElement			WOHTMLURLValuedElement
#define GSWStats						WOStats
#define GSWTransactionRecord			WOTransactionRecord
#define GSWComponentContent				WOComponentContent
#define GSWFileUpload					WOFileUpload
#define GSWResourceURL					WOResourceURL
#endif
@class EOEditingContext;

@class GSWAdaptor;
@class GSWApplication;
@class GSWAssociation;
@class GSWComponent;
@class GSWContext;
@class GSWDisplayGroup;
@class GSWElement;
@class GSWDynamicElement;
@class GSWRequest;
@class GSWResourceManager;
@class GSWResponse;
@class GSWSession;
@class GSWSessionStore;
@class GSWStatisticsStore;
@class GSWRequestHandler;
@class GSWComponentDefinition;
@class GSWBundle;
@class GSWMultiKeyDictionary;
@class GSWCookie;
@class GSWElementIDString;
@class GSWDirectAction;
@class GSWMailDelivery;
@class GSWComponentRequestHandler;
@class GSWResourceRequestHandler;
@class GSWDirectActionRequestHandler;
@class GSWDefaultAdaptorThread;
@class GSWKeyValueAssociation;
@class GSWConstantValueAssociation;
@class GSWHTMLStaticElement;
@class GSWHTMLStaticGroup;
@class GSWInput;
@class GSWComponentReference;
@class GSWPageDefElement;
@class GSWBundle;
@class GSWSessionTimeOutManager;
@class GSWServerSessionStore;
@class GSWDeployedBundle;
@class GSWProjectBundle;
@class GSWSessionTimeOut;
@class GSWMultiKeyDictionary;
@class GSWTemplateParser;
@class GSWDynamicURLString;
@class GSWBindingNameAssociation;
@class GSWURLValuedElementData;
@class GSWHTMLURLValuedElement;
@class GSWStats;
@class GSWTransactionRecord;
@class GSWComponentContent;
@class GSWFileUpload;
@class GSWResourceURL;
@class GSWProcFSProcInfo;

#include <gsweb/GSWeb.framework/GSWConstants.h>
#include <gsweb/GSWeb.framework/GSWUtils.h>
#include <gsweb/GSWeb.framework/GSWProcFS.h>
#include <gsweb/GSWeb.framework/GSWDebug.h>
#include <gsweb/GSWeb.framework/NSString+Trimming.h>
#include <gsweb/GSWeb.framework/NSString+HTML.h>
#include <gsweb/GSWeb.framework/NSObject+IVarAccess+PerformSel.h>
#include <gsweb/GSWeb.framework/GSWElementIDString.h>
#include <gsweb/GSWeb.framework/GSWResponse.h>
#include <gsweb/GSWeb.framework/GSWHTMLLexer.h>
#include <gsweb/GSWeb.framework/GSWHTMLParser.h>
#include <gsweb/GSWeb.framework/GSWHTMLParserExt.h>
#include <gsweb/GSWeb.framework/GSWPageDefParser.h>
#include <gsweb/GSWeb.framework/GSWPageDefParserExt.h>
#include <gsweb/GSWeb.framework/GSWAdaptor.h>
#include <gsweb/GSWeb.framework/GSWApplication.h>
#include <gsweb/GSWeb.framework/GSWAssociation.h>
#include <gsweb/GSWeb.framework/GSWContext.h>
#include <gsweb/GSWeb.framework/GSWDisplayGroup.h>
#include <gsweb/GSWeb.framework/GSWElement.h>
#include <gsweb/GSWeb.framework/GSWComponent.h>
#include <gsweb/GSWeb.framework/GSWHTMLStaticElement.h>
#include <gsweb/GSWeb.framework/GSWHTMLStaticGroup.h>
#include <gsweb/GSWeb.framework/GSWDynamicElement.h>
#include <gsweb/GSWeb.framework/GSWRequest.h>
#include <gsweb/GSWeb.framework/GSWResourceManager.h>
#include <gsweb/GSWeb.framework/GSWSession.h>
#include <gsweb/GSWeb.framework/GSWSessionStore.h>
#include <gsweb/GSWeb.framework/GSWStatisticsStore.h>
#include <gsweb/GSWeb.framework/GSWAdaptor.h>
#include <gsweb/GSWeb.framework/GSWDefaultAdaptor.h>
#include <gsweb/GSWeb.framework/GSWHTMLDynamicElement.h>
#include <gsweb/GSWeb.framework/GSWHTMLURLValuedElement.h>
#include <gsweb/GSWeb.framework/GSWClientSideScript.h>
#include <gsweb/GSWeb.framework/GSWComponentReference.h>
#include <gsweb/GSWeb.framework/GSWInput.h>
#include <gsweb/GSWeb.framework/GSWTextField.h>
#include <gsweb/GSWeb.framework/GSWForm.h>
#include <gsweb/GSWeb.framework/GSWSubmitButton.h>
#include <gsweb/GSWeb.framework/GSWActiveImage.h>
#include <gsweb/GSWeb.framework/GSWHTMLBareString.h>
#include <gsweb/GSWeb.framework/GSWHTMLComment.h>
#include <gsweb/GSWeb.framework/GSWBody.h>
#include <gsweb/GSWeb.framework/GSWApplet.h>
#include <gsweb/GSWeb.framework/GSWBrowser.h>
#include <gsweb/GSWeb.framework/GSWCheckBox.h>
#include <gsweb/GSWeb.framework/GSWCheckBoxList.h>
#include <gsweb/GSWeb.framework/GSWConditional.h>
#include <gsweb/GSWeb.framework/GSWEmbeddedObject.h>
#include <gsweb/GSWeb.framework/GSWFrame.h>
#include <gsweb/GSWeb.framework/GSWGenericContainer.h>
#include <gsweb/GSWeb.framework/GSWGenericElement.h>
#include <gsweb/GSWeb.framework/GSWHiddenField.h>
#include <gsweb/GSWeb.framework/GSWHyperlink.h>
#include <gsweb/GSWeb.framework/GSWImage.h>
#include <gsweb/GSWeb.framework/GSWImageButton.h>
#include <gsweb/GSWeb.framework/GSWJavaScript.h>
#include <gsweb/GSWeb.framework/GSWNestedList.h>
#include <gsweb/GSWeb.framework/GSWParam.h>
#include <gsweb/GSWeb.framework/GSWPasswordField.h>
#include <gsweb/GSWeb.framework/GSWPopUpButton.h>
#include <gsweb/GSWeb.framework/GSWRadioButton.h>
#include <gsweb/GSWeb.framework/GSWRadioButtonList.h>
#include <gsweb/GSWeb.framework/GSWRepetition.h>
#include <gsweb/GSWeb.framework/GSWResetButton.h>
#include <gsweb/GSWeb.framework/GSWResetButton.h>
#include <gsweb/GSWeb.framework/GSWSwitchComponent.h>
#include <gsweb/GSWeb.framework/GSWVBScript.h>
#include <gsweb/GSWeb.framework/GSWString.h>
#include <gsweb/GSWeb.framework/GSWText.h>
#include <gsweb/GSWeb.framework/GSWCookie.h>
#include <gsweb/GSWeb.framework/GSWRequestHandler.h>
#include <gsweb/GSWeb.framework/GSWComponentDefinition.h>
#include <gsweb/GSWeb.framework/GSWDirectAction.h>
#include <gsweb/GSWeb.framework/GSWMailDelivery.h>
#include <gsweb/GSWeb.framework/GSWComponentRequestHandler.h>
#include <gsweb/GSWeb.framework/GSWResourceRequestHandler.h>
#include <gsweb/GSWeb.framework/GSWDirectActionRequestHandler.h>
#include <gsweb/GSWeb.framework/GSWDefaultAdaptorThread.h>
#include <gsweb/GSWeb.framework/GSWKeyValueAssociation.h>
#include <gsweb/GSWeb.framework/GSWConstantValueAssociation.h>
#include <gsweb/GSWeb.framework/GSWPageDefElement.h>
#include <gsweb/GSWeb.framework/GSWBundle.h>
#include <gsweb/GSWeb.framework/GSWSessionTimeOutManager.h>
#include <gsweb/GSWeb.framework/GSWServerSessionStore.h>
#include <gsweb/GSWeb.framework/GSWDeployedBundle.h>
#include <gsweb/GSWeb.framework/GSWProjectBundle.h>
#include <gsweb/GSWeb.framework/GSWMultiKeyDictionary.h>
#include <gsweb/GSWeb.framework/GSWTemplateParser.h>
#include <gsweb/GSWeb.framework/GSWTemplateParserXML.h>
#include <gsweb/GSWeb.framework/GSWTemplateParserANTLR.h>
#include <gsweb/GSWeb.framework/GSWDynamicURLString.h>
#include <gsweb/GSWeb.framework/GSWBindingNameAssociation.h>
#include <gsweb/GSWeb.framework/GSWURLValuedElementData.h>
#include <gsweb/GSWeb.framework/GSWStats.h>
#include <gsweb/GSWeb.framework/GSWTransactionRecord.h>
#include <gsweb/GSWeb.framework/GSWToggle.h>
#include <gsweb/GSWeb.framework/GSWComponentContent.h>
#include <gsweb/GSWeb.framework/GSWGeometricRegion.h>
#include <gsweb/GSWeb.framework/GSWFileUpload.h>
#include <gsweb/GSWeb.framework/GSWResourceURL.h>

#endif //_GSWeb_h__
