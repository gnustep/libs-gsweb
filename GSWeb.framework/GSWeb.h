/** GSWeb.h -  <title>GSWeb</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$
   
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

#ifndef _GSWeb_h__
#define _GSWeb_h__

#ifdef SOLARIS
#include <limits.h> 
#endif
#ifdef __FreeBSD__
#include <float.h>
#endif
#include <Foundation/Foundation.h>
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
#include <Foundation/NSFormatter.h>
#include <Foundation/GSXML.h>
#include "GSCache.h"


#include <GSWeb/GSWConfig.h>

#if GSWEB_WONAMES
#define GSWAdaptor						WOAdaptor
#define GSWDefaultAdaptor				WODefaultAdaptor
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
#define GSWApp						WOApp
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

#include <GSWeb/GSWConstants.h>
#include <GSWeb/GSWUtils.h>
#include <GSWeb/GSWProcFS.h>
#include <GSWeb/GSWDebug.h>
#include <GSWeb/NSString+Trimming.h>
#include <GSWeb/NSString+HTML.h>
#include <GSWeb/NSObject+IVarAccess+PerformSel.h>
#include <GSWeb/GSWElementIDString.h>
#include <GSWeb/GSWResponse.h>
#include <GSWeb/GSWHTMLLexer.h>
#include <GSWeb/GSWHTMLParser.h>
#include <GSWeb/GSWHTMLParserExt.h>
#include <GSWeb/GSWPageDefParser.h>
#include <GSWeb/GSWPageDefParserExt.h>
#include <GSWeb/GSWAdaptor.h>
#include <GSWeb/GSWApplication.h>
#include <GSWeb/GSWAssociation.h>
#include <GSWeb/GSWContext.h>
#include <GSWeb/GSWDisplayGroup.h>
#include <GSWeb/GSWElement.h>
#include <GSWeb/GSWComponent.h>
#include <GSWeb/GSWHTMLStaticElement.h>
#include <GSWeb/GSWHTMLStaticGroup.h>
#include <GSWeb/GSWDynamicElement.h>
#include <GSWeb/GSWRequest.h>
#include <GSWeb/GSWResourceManager.h>
#include <GSWeb/GSWSession.h>
#include <GSWeb/GSWSessionStore.h>
#include <GSWeb/GSWSessionTimeOut.h>
#include <GSWeb/GSWStatisticsStore.h>
#include <GSWeb/GSWAdaptor.h>
#include <GSWeb/GSWDefaultAdaptor.h>
#include <GSWeb/GSWHTMLDynamicElement.h>
#include <GSWeb/GSWHTMLURLValuedElement.h>
#include <GSWeb/GSWClientSideScript.h>
#include <GSWeb/GSWComponentReference.h>
#include <GSWeb/GSWInput.h>
#include <GSWeb/GSWTextField.h>
#include <GSWeb/GSWForm.h>
#include <GSWeb/GSWSubmitButton.h>
#include <GSWeb/GSWActiveImage.h>
#include <GSWeb/GSWHTMLBareString.h>
#include <GSWeb/GSWHTMLComment.h>
#include <GSWeb/GSWBody.h>
#include <GSWeb/GSWApplet.h>
#include <GSWeb/GSWBrowser.h>
#include <GSWeb/GSWCheckBox.h>
#include <GSWeb/GSWCheckBoxList.h>
#include <GSWeb/GSWConditional.h>
#include <GSWeb/GSWEmbeddedObject.h>
#include <GSWeb/GSWFrame.h>
#include <GSWeb/GSWGenericContainer.h>
#include <GSWeb/GSWGenericElement.h>
#include <GSWeb/GSWHiddenField.h>
#include <GSWeb/GSWHyperlink.h>
#include <GSWeb/GSWImage.h>
#include <GSWeb/GSWImageButton.h>
#include <GSWeb/GSWJavaScript.h>
#include <GSWeb/GSWNestedList.h>
#include <GSWeb/GSWParam.h>
#include <GSWeb/GSWPasswordField.h>
#include <GSWeb/GSWPopUpButton.h>
#include <GSWeb/GSWRadioButton.h>
#include <GSWeb/GSWRadioButtonList.h>
#include <GSWeb/GSWRepetition.h>
#include <GSWeb/GSWResetButton.h>
#include <GSWeb/GSWResetButton.h>
#include <GSWeb/GSWSwitchComponent.h>
#include <GSWeb/GSWVBScript.h>
#include <GSWeb/GSWString.h>
#include <GSWeb/GSWText.h>
#include <GSWeb/GSWCookie.h>
#include <GSWeb/GSWRequestHandler.h>
#include <GSWeb/GSWComponentDefinition.h>
#include <GSWeb/GSWDirectAction.h>
#include <GSWeb/GSWMailDelivery.h>
#include <GSWeb/GSWComponentRequestHandler.h>
#include <GSWeb/GSWResourceRequestHandler.h>
#include <GSWeb/GSWDirectActionRequestHandler.h>
#include <GSWeb/GSWDefaultAdaptorThread.h>
#include <GSWeb/GSWKeyValueAssociation.h>
#include <GSWeb/GSWConstantValueAssociation.h>
#include <GSWeb/GSWPageDefElement.h>
#include <GSWeb/GSWTemplateParser.h>
#include <GSWeb/GSWBundle.h>
#include <GSWeb/GSWSessionTimeOutManager.h>
#include <GSWeb/GSWServerSessionStore.h>
#include <GSWeb/GSWDeployedBundle.h>
#include <GSWeb/GSWProjectBundle.h>
#include <GSWeb/GSWMultiKeyDictionary.h>
#include <GSWeb/GSWDynamicURLString.h>
#include <GSWeb/GSWBindingNameAssociation.h>
#include <GSWeb/GSWURLValuedElementData.h>
#include <GSWeb/GSWStats.h>
#include <GSWeb/GSWTransactionRecord.h>
#include <GSWeb/GSWToggle.h>
#include <GSWeb/GSWComponentContent.h>
#include <GSWeb/GSWGeometricRegion.h>
#include <GSWeb/GSWFileUpload.h>
#include <GSWeb/GSWResourceURL.h>
#include <GSWeb/GSWWOCompatibility.h>

#endif //_GSWeb_h__
