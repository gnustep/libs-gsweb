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

#ifdef GSWEB_WONAMES

/* public */
#define GSWAdaptor			WOAdaptor
#define GSWApplication			WOApplication
#define GSWAssociation			WOAssociation
#define GSWComponent			WOComponent
#define GSWContext			WOContext
#define GSWCookie			WOCookie
#define GSWDirectAction			WODirectAction
#define GSWDisplayGroup			WODisplayGroup
#define GSWDynamicElement		WODynamicElement
#define GSWElement			WOElement
#define GSWEvent                        WOEvent
#define GSWHTTPConnection               WOHTTPConnection
#define GSWMailDelivery			WOMailDelivery
#define GSWMessage                      WOMesssage
#define GSWRequest			WORequest
#define GSWRequestHandler		WORequestHandler
#define GSWResourceManager		WOResourceManager
#define GSWResponse			WOResponse
#define GSWSession			WOSession
#define GSWSessionStore			WOSessionStore
#define GSWStatisticsStore		WOStatisticsStore

/* protocols */
#define GSWActionResults                WOActionResults
//#define GSWDisplayGroup                 WODisplayGroup

/* private */
#define GSWComponentDefinition		WOComponentDefinition
#define GSWBundle			WOBundle
#define GSWMultiKeyDictionary		WOMultiKeyDictionary
#define GSWElementIDString		WOElementIDString
#define GSWComponentRequestHandler	WOComponentRequestHandler
#define GSWResourceRequestHandler	WOResourceRequestHandler
#define GSWDirectActionRequestHandler	WODirectActionRequestHandler
#define GSWDefaultAdaptorThread		WODefaultAdaptorThread
#define GSWKeyValueAssociation		WOKeyValueAssociation
#define GSWConstantValueAssociation	WOConstantValueAssociation
#define GSWHTMLStaticElement		WOHTMLStaticElement
#define GSWHTMLStaticGroup		WOHTMLStaticGroup
#define GSWInput			WOInput
#define GSWComponentReference		WOComponentReference
#define GSWPageDefElement		WOPageDefElement
#define GSWBundle			WOBundle
#define GSWSessionTimeOutManager	WOSessionTimeOutManager
#define GSWServerSessionStore		WOServerSessionStore
#define GSWDeployedBundle		WODeployedBundle
#define GSWProjectBundle		WOProjectBundle
#define GSWSessionTimeOut		WOSessionTimeOut
#define GSWMultiKeyDictionary		WOMultiKeyDictionary
#define GSWTemplateParser		WOTemplateParser
#define GSWDynamicURLString		WODynamicURLString
#define GSWBindingNameAssociation	WOBindingNameAssociation
#define GSWURLValuedElementData		WOURLValuedElementData
#define GSWHTMLURLValuedElement		WOHTMLURLValuedElement
#define GSWStats			WOStats
#define GSWTransactionRecord		WOTransactionRecord
#define GSWDefaultAdaptor		WODefaultAdaptor


/* Dynamic Elements */
#define GSWActionURL                    WOActionURL
#define GSWActiveImage                  WOActiveImage
#define GSWApplet                       WOApplet
#define GSWBody                         WOBody
#define GSWBrowser                      WOBrowser
#define GSWCheckBox                     WOCheckBox
#define GSWCheckBoxList                 WOCheckBoxList
#define GSWComponentContent             WOComponentContent
#define GSWConditional                  WOConditional
#define GSWEmbeddedObject               WOEmbeddedObject
#define GSWFileUpload                   WOFileUpload
#define GSWForm                         WOForm
#define GSWFrame                        WOFrame
#define GSWGenericContainer             WOGenericContainer
#define GSWGenericElement               WOGenericElement
#define GSWHiddenField                  WOHiddenField
#define GSWHyperlink                    WOHyperlink
#define GSWImage                        WOImage
#define GSWImageButton                  WOImageButton
#define GSWJavaScript                   WOJaveScript
#define GSWNestedList                   WONestedList
#define GSWParam                        WOParam
#define GSWPasswordField                WOPasswordField
#define GSWPopUpButton                  WOPopUpButton
#define GSWQuickTime                    WOQuickTime
#define GSWRadioButton                  WORadioButton
#define GSWRadioButtonList              WORadioButtonList
#define GSWRepetition                   WORepetition
#define GSWResetButton                  WOResetButton
#define GSWResourceURL                  WOResourceURL
#define GSWString                       WOString
#define GSWSubmitButton                 WOSubmitButton
#define GSWSwitchComponent              WOSwitchComponent
#define GSWText                         WOText
#define GSWTextField                    WOTextField
#define GSWVBScript                     WOVBScript

/* Extensions */
#define GSWAnyField                     WOAnyField
#define GSWBatchNavigatorBar            WOBatchNavigatorBar
#define GSWCheckboxMatrix               WOCheckboxMatrix
#define GSWCollapsibleComponentContent  WOCollapsibleComponentContent
#define GSWCompletionBar                WOCompletionBar
#define GSWDictionaryRepetition         WODictionaryRepetition
#define GSWEventDisplayPage             WOEventDisplayPage
#define GSWEventSetupPage               WOEventSetupPage
#define GSWIFrame                       WOIFrame
#define GSWKeyValueConditional          WOKeyValueConditional
#define GSWLongResponsePage             WOLongResponsePage
#define GSWMeteRefresh                  WOMetaRefresh
#define GSWPageRestorationErrorPage     WOPageRestorationErrorPage
#define GSWRadioButtonMatrix            WORadioButtonMatrix
#define GSWRedirect                     WORedirect
#define GSWSessionCreationErrorPage     WOSessionCreationErrorPage
#define GSWSessionRestorationErrorPage  WOSessionRestorationErrorPage
#define GSWSimpleArrayDisplay           WOSimpleArrayDisplay
#define GSWSimpleArrayDisplay2          WOSimpleArrayDisplay2
#define GSWSortOrder                    WOSortOrder
#define GSWSortOrderManyKey             WOSortOrderManyKey
#define GSWStatsPage                    WOStatsPage
#define GSWTabPanel                     WOTabPanel
#define GSWTable                        WOTable
#define GSWThresholdColoredNumber       WOThresholdColoredNumber
#define GSWToManyRelationship           WOToManyRelationship
#define GSWToOneRelationship            WOToOneRelationship

/* Constants */
#define GSWApp				WOApp

#endif // GSWEB_WONAMES

#endif // _GSWWOCompatibility_h__
