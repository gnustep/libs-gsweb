/** GSWWOCompatibility.h - <title>GSWeb: GSWWOCompatibility</title>

   Copyright (C) 2000-2002 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Dec 2000
   
   $Revision$
   $Date$

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

#ifndef _GSWWOCompatibility_h__
	#define _GSWWOCompatibility_h__

#if GSWEB_WONAMES
#else
@interface WOApplication : GSWApplication
@end

@interface WOAdaptor : GSWAdaptor
@end

@interface WODefaultAdaptor: GSWDefaultAdaptor
@end

@interface WOAssociation : GSWAssociation
@end

@interface WOComponent : GSWComponent
@end

@interface WOContext : GSWContext
@end

@interface WODisplayGroup : GSWDisplayGroup
@end

@interface WOElement : GSWElement
@end

@interface WODynamicElement : GSWDynamicElement
@end

@interface WORequest : GSWRequest
@end

@interface WOResourceManager : GSWResourceManager
@end

@interface WOResponse : GSWResponse
@end

@interface WOSession : GSWSession
@end

@interface WOSessionStore : GSWSessionStore
@end

@interface WOStatisticsStore : GSWStatisticsStore
@end

@interface WORequestHandler : GSWRequestHandler
@end

@interface WOComponentDefinition : GSWComponentDefinition
@end

@interface WOBundle : GSWBundle
@end

@interface WOMultiKeyDictionary : GSWMultiKeyDictionary
@end

@interface WOCookie : GSWCookie
@end

@interface WOElementIDString : GSWElementIDString
@end

@interface WODirectAction : GSWDirectAction
@end

@interface WOMailDelivery : GSWMailDelivery
@end

@interface WOComponentRequestHandler : GSWComponentRequestHandler
@end

@interface WOResourceRequestHandler : GSWResourceRequestHandler
@end

@interface WODirectActionRequestHandler : GSWDirectActionRequestHandler
@end

@interface WODefaultAdaptorThread : GSWDefaultAdaptorThread
@end

@interface WOKeyValueAssociation : GSWKeyValueAssociation
@end

@interface WOConstantValueAssociation : GSWConstantValueAssociation
@end

@interface WOHTMLStaticElement : GSWHTMLStaticElement
@end

@interface WOHTMLStaticGroup : GSWHTMLStaticGroup
@end

@interface WOInput : GSWInput
@end

@interface WOComponentReference : GSWComponentReference
@end

@interface WOPageDefElement : GSWPageDefElement
@end

@interface WOSessionTimeOutManager : GSWSessionTimeOutManager
@end

@interface WOServerSessionStore : GSWServerSessionStore
@end

@interface WODeployedBundle : GSWDeployedBundle
@end

@interface WOProjectBundle : GSWProjectBundle
@end

@interface WOSessionTimeOut : GSWSessionTimeOut
@end

@interface WOTemplateParser : GSWTemplateParser
@end

@interface WODynamicURLString : GSWDynamicURLString
@end

@interface WOBindingNameAssociation : GSWBindingNameAssociation
@end

@interface WOURLValuedElementData : GSWURLValuedElementData
@end

@interface WOHTMLURLValuedElement : GSWHTMLURLValuedElement
@end

@interface WOStats : GSWStats
@end

@interface WOTransactionRecord : GSWTransactionRecord
@end

@interface WOComponentContent : GSWComponentContent
@end

@interface WOFileUpload : GSWFileUpload
@end

@interface WOResourceURL : GSWResourceURL
@end

@interface WOString : GSWString
@end

@interface WORepetition : GSWRepetition
@end

@interface WOActiveImage : GSWActiveImage
@end

@interface WOApplet : GSWApplet
@end

@interface WOBrowser : GSWBrowser
@end


@interface WOCheckBox : GSWCheckBox
@end

@interface WOCheckBoxList : GSWCheckBoxList
@end

@interface WOParam : GSWParam
@end

@interface WOForm : GSWForm
@end

@interface WOPopUpButton : GSWPopUpButton
@end

@interface WOTextField : GSWTextField
@end

@interface WOSubmitButton : GSWSubmitButton
@end

@interface WOConditional : GSWConditional
@end

@interface WOText : GSWText
@end

@interface WOHiddenField : GSWHiddenField
@end

@interface WOPasswordField : GSWPasswordField
@end

@interface WOResetButton : GSWResetButton
@end

@interface WOFrame : GSWFrame 
@end

@interface WOGenericContainer : GSWGenericContainer
@end

@interface WOGenericElement : GSWGenericElement
@end

@interface WOImage : GSWImage
@end

@interface WOImageButton : GSWImageButton
@end

@interface WORadioButton : GSWRadioButton
@end

@interface WORadioButtonList : GSWRadioButtonList
@end

@interface WOHyperlink : GSWHyperlink
@end

extern WOApplication *WOApp;

#endif

#endif // _GSWWOCompatibility_h__
