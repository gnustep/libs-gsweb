/** GSWeb.h -  <title>GSWeb</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
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

#ifndef GNUSTEP
#include <GNUstepBase/GNUstep.h>
#endif

#if GDL2
#define HAVE_GDL2 1
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
#include <Foundation/NSFormatter.h>
#include <GNUstepBase/GSXML.h>
#include <GNUstepBase/GSCategories.h>
#include "GSWConfig.h"

@class EOEditingContext;

@class GSWAdaptor;
@class GSWApplication;
@class GSWAssociation;
@class GSWComponent;
@class GSWContext;
@class GSWDisplayGroup;
@class GSWElement;
@class GSWDynamicElement;
@class GSWMessage;
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
@class GSWAction;
@class GSWDirectAction;
@class GSWMailDelivery;
@class GSWComponentRequestHandler;
@class GSWResourceRequestHandler;
@class GSWStaticResourceRequestHandler;
@class GSWActionRequestHandler;
@class GSWDirectActionRequestHandler;
@class GSWDefaultAdaptorThread;
@class GSWKeyValueAssociation;
@class GSWConstantValueAssociation;
@class GSWHTMLStaticElement;
@class GSWHTMLStaticGroup;
@class GSWInput;
@class GSWComponentReference;
@class GSWTemporaryElement;
@class GSWBaseParser;
@class GSWDeclaration;
@class GSWGSWDeclarationParser;
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
@class GSWLifebeatThread;
@class GSWAdminAction;
@class GSWStack;
@class GSWXMLCoder;
@class GSWXMLDecoder;
@class GSWMonitorXMLCoder;
@class GSWMonitorXMLDecoder;
@class GSWRecording;
@class GSWInputStreamData;

#include "GSWConstants.h"
#include "GSWUtils.h"
#include "GSWProcFS.h"
#include "GSWDebug.h"
#include "NSString+Trimming.h"
#include "NSString+HTML.h"
#include "GSWElementIDString.h"
#include "GSWMessage.h"
#include "GSWResponse.h"
#include "GSWHTMLLexer.h"
#include "GSWHTMLParser.h"
#include "GSWHTMLParserExt.h"
#include "GSWBaseParser.h"
#include "GSWDeclaration.h"
#include "GSWDeclarationParser.h"
#include "GSWAdaptor.h"
#include "GSWApplication.h"
#include "GSWAssociation.h"
#include "GSWContext.h"
#include "GSWDisplayGroup.h"
#include "GSWElement.h"
#include "GSWComponent.h"
#include "GSWHTMLStaticElement.h"
#include "GSWHTMLStaticGroup.h"
#include "GSWDynamicElement.h"
#include "GSWRequest.h"
#include "GSWResourceManager.h"
#include "GSWSession.h"
#include "GSWSessionStore.h"
#include "GSWSessionTimeOut.h"
#include "GSWStatisticsStore.h"
#include "GSWAdaptor.h"
#include "GSWDefaultAdaptor.h"
#include "GSWHTMLDynamicElement.h"
#include "GSWHTMLURLValuedElement.h"
#include "GSWClientSideScript.h"
#include "GSWComponentReference.h"
#include "GSWInput.h"
#include "GSWTextField.h"
#include "GSWForm.h"
#include "GSWSubmitButton.h"
#include "GSWActiveImage.h"
#include "GSWHTMLBareString.h"
#include "GSWHTMLComment.h"
#include "GSWBody.h"
#include "GSWApplet.h"
#include "GSWBrowser.h"
#include "GSWCheckBox.h"
#include "GSWCheckBoxList.h"
#include "GSWConditional.h"
#include "GSWEmbeddedObject.h"
#include "GSWFrame.h"
#include "GSWGenericContainer.h"
#include "GSWGenericElement.h"
#include "GSWHiddenField.h"
#include "GSWHyperlink.h"
#include "GSWImage.h"
#include "GSWImageButton.h"
#include "GSWJavaScript.h"
#include "GSWNestedList.h"
#include "GSWParam.h"
#include "GSWPasswordField.h"
#include "GSWPopUpButton.h"
#include "GSWRadioButton.h"
#include "GSWRadioButtonList.h"
#include "GSWRepetition.h"
#include "GSWResetButton.h"
#include "GSWResetButton.h"
#include "GSWSwitchComponent.h"
#include "GSWVBScript.h"
#include "GSWString.h"
#include "GSWActionURL.h"
#include "GSWText.h"
#include "GSWCookie.h"
#include "GSWRequestHandler.h"
#include "GSWComponentDefinition.h"
#include "GSWAction.h"
#include "GSWDirectAction.h"
#include "GSWMailDelivery.h"
#include "GSWComponentRequestHandler.h"
#include "GSWResourceRequestHandler.h"
#include "GSWStaticResourceRequestHandler.h"
#include "GSWActionRequestHandler.h"
#include "GSWDirectActionRequestHandler.h"
#include "GSWDefaultAdaptorThread.h"
#include "GSWKeyValueAssociation.h"
#include "GSWConstantValueAssociation.h"
#include "GSWTemplateParser.h"
#include "GSWHTMLTemplateParser.h"
#include "GSWTemporaryElement.h"
#include "GSWBundle.h"
#include "GSWSessionTimeOutManager.h"
#include "GSWServerSessionStore.h"
#include "GSWDeployedBundle.h"
#include "GSWProjectBundle.h"
#include "GSWMultiKeyDictionary.h"
#include "GSWDynamicURLString.h"
#include "GSWBindingNameAssociation.h"
#include "GSWURLValuedElementData.h"
#include "GSWStats.h"
#include "GSWTransactionRecord.h"
#include "GSWToggle.h"
#include "GSWComponentContent.h"
#include "GSWGeometricRegion.h"
#include "GSWFileUpload.h"
#include "GSWResourceURL.h"

#endif //_GSWeb_h__




