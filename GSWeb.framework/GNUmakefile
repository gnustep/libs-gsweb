# GNUmakefile - GSWeb: GNUmakefile
#
#   Copyright (C) 1999-2003 Free Software Foundation, Inc.
#   
#   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
#   Date: 	Jan 1999
#   
#   This file is part of the GNUstep Web Library.
#   
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU Library General Public
#   License as published by the Free Software Foundation; either
#   version 2 of the License, or (at your option) any later version.
#   
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   Library General Public License for more details.
#   
#   You should have received a copy of the GNU Library General Public
#   License along with this library; if not, write to the Free
#   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# Install into the system root by default
GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)

GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles

GNUSTEP_LOCAL_ADDITIONAL_MAKEFILES=../gsweb.make
include $(GNUSTEP_MAKEFILES)/common.make

include ../Version
include ../config.mak

# The framework to be compiled

# Options
ifeq ($(gswnames), gsw)
FRAMEWORK_NAME = GSWeb
endif
ifeq ($(gswnames), wo)
FRAMEWORK_NAME = WebObjects
endif
ifeq ($(gswnames), all)
FRAMEWORK_NAME = GSWeb WebObjects
endif

# Ensure that each framework uses its own GNUSTEP_OBJ_DIR_NAME & DERIVED_SRC
ifneq ($(GNUSTEP_INSTANCE),)
GNUSTEP_OBJ_DIR_NAME := $(GNUSTEP_OBJ_DIR_NAME)/$(GNUSTEP_INSTANCE)
DERIVED_SRC := $(DERIVED_SRC)/$(GNUSTEP_INSTANCE)
endif

WebObjects_CPPFLAGS = -DGSWEB_WONAMES

# DTDs to install
srcDTDDir = DTDs
dstDTDDir = $(GNUSTEP_RESOURCES)/DTDs
DTD_FILES = \
xhtml-lat1.ent \
xhtml-symbol.ent \
xhtml-special.ent \
xhtml1-strict.dtd \
xhtml1-frameset.dtd \
xhtml1-transitional.dtd


# The framework resource files and directories
GSWeb_RESOURCE_FILES = \
Resources/MIME.plist \
Resources/languages.plist \
DTDs
WebObjects_RESOURCE_FILES = $(GSWeb_RESOURCE_FILES)

GSWeb_RESOURCE_DIRS = DTDs
WebObjects_RESOURCE_DIRS = $(GSWeb_RESOURCE_DIRS)

# The framework libraries to link against
#GSWeb_GSWBUNDLE_LIBS = 

# The Bundle Objective-C source files to be compiled
GSWeb_OBJC_FILES = \
GSWDebug.m \
GSWConstants.m \
GSWPageDefParser.m \
GSWPageDefParserExt.m \
GSWPageDefLexer.m \
GSWPageDefElement.m \
GSWSessionTimeOutManager.m \
GSWServerSessionStore.m \
GSWDeployedBundle.m \
GSWProjectBundle.m \
GSWSessionTimeOut.m \
GSWStats.m \
NSNonBlockingFileHandle.m \
GSWTransactionRecord.m \
GSWBundle.m \
NSString+Trimming.m \
NSString+HTML.m \
GSWTemplateParser.m \
GSWTemplateParserANTLR.m \
GSWTemplateParserXML.m \
GSWHTMLParser.m \
GSWHTMLParserExt.m \
GSWHTMLLexer.m \
GSWHTMLAttrLexer.m \
GSWHTMLAttrParser.m \
GSWHTMLAttrParserExt.m \
GSWApplication.m \
GSWAssociation.m \
GSWComponent.m \
GSWContext.m \
GSWMultiKeyDictionary.m \
GSWDisplayGroup.m \
GSWDynamicElement.m \
GSWElement.m \
GSWMessage.m \
GSWRequest.m \
GSWResourceManager.m \
GSWResponse.m \
GSWSession.m \
GSWSessionStore.m \
GSWStatisticsStore.m \
GSWAdaptor.m \
GSWDefaultAdaptor.m \
GSWUtils.m \
GSCache.m \
GSWClientSideScript.m \
GSWActiveImage.m \
GSWBody.m \
GSWTextField.m \
GSWForm.m \
GSWSubmitButton.m \
GSWHTMLBareString.m \
GSWHTMLComment.m \
GSWApplet.m \
GSWBrowser.m \
GSWCheckBox.m \
GSWCheckBoxList.m \
GSWConditional.m \
GSWEmbeddedObject.m \
GSWFrame.m \
GSWGenericContainer.m \
GSWGenericElement.m \
GSWHiddenField.m \
GSWHyperlink.m \
GSWImage.m \
GSWImageButton.m \
GSWJavaScript.m \
GSWNestedList.m \
GSWParam.m \
GSWPasswordField.m \
GSWPopUpButton.m \
GSWRadioButton.m \
GSWRadioButtonList.m \
GSWRepetition.m \
GSWResetButton.m \
GSWSwitchComponent.m \
GSWVBScript.m \
GSWString.m \
GSWText.m \
GSWCookie.m \
GSWRequestHandler.m \
GSWComponentDefinition.m \
GSWAction.m \
GSWDirectAction.m \
GSWMailDelivery.m \
GSWComponentRequestHandler.m \
GSWResourceRequestHandler.m \
GSWActionRequestHandler.m \
GSWDirectActionRequestHandler.m \
GSWDefaultAdaptorThread.m \
GSWKeyValueAssociation.m \
GSWHTMLStaticElement.m \
GSWHTMLStaticGroup.m \
GSWInput.m \
GSWConstantValueAssociation.m \
GSWComponentReference.m \
GSWElementIDString.m \
GSWHTMLDynamicElement.m \
GSWDynamicURLString.m \
GSWBindingNameAssociation.m \
GSWURLValuedElementData.m \
GSWHTMLURLValuedElement.m \
GSWToggle.m \
GSWComponentContent.m \
GSWGeometricRegion.m \
GSWFileUpload.m \
GSWResourceURL.m \
GSWProcFS.m \
NSData+Compress.m \
stacktrace.m \
attach.m \
GSWLifebeatThread.m \
GSWStaticResourceRequestHandler.m \
GSWRecording.m \
GSWInputStreamData.m \
GSWActionURL.m \

#For next Version:
#GSWAdminAction.m \
#GSWStack.m \
#GSWXMLCoder.m \
#GSWXMLMappingCoder.m \
#GSWXMLDecoder.m \
#GSWMonitorXMLCoder.m \
#GSWMonitorXMLDecoder.m \

WebObjects_OBJC_FILES = $(GSWeb_OBJC_FILES)


# The framework installed header files
GSWeb_HEADER_FILES = \
GSCache.h  \
GSWeb.h \
GSWActiveImage.h \
GSWAdaptor.h \
GSWApplet.h \
GSWApplication.h \
GSWAssociation.h \
GSWBindingNameAssociation.h \
GSWBody.h \
GSWBrowser.h \
GSWBundle.h \
GSWCheckBox.h \
GSWCheckBoxList.h \
GSWClientSideScript.h \
GSWComponent.h \
GSWComponentContent.h \
GSWComponentDefinition.h \
GSWComponentReference.h \
GSWComponentRequestHandler.h \
GSWConditional.h \
GSWConstantValueAssociation.h \
GSWContext.h \
GSWCookie.h \
GSWDefaultAdaptor.h \
GSWDefaultAdaptorThread.h \
GSWDeployedBundle.h \
GSWAction.h \
GSWDirectAction.h \
GSWActionRequestHandler.h \
GSWDirectActionRequestHandler.h \
GSWDisplayGroup.h \
GSWDynamicElement.h \
GSWDynamicURLString.h \
GSWElement.h \
GSWElementIDString.h \
GSWEmbeddedObject.h \
GSWForm.h \
GSWFrame.h \
GSWGenericContainer.h \
GSWGenericElement.h \
GSWHTMLBareString.h \
GSWHTMLComment.h \
GSWHTMLDynamicElement.h \
GSWHTMLStaticElement.h \
GSWHTMLStaticGroup.h \
GSWHTMLURLValuedElement.h \
GSWHiddenField.h \
GSWHyperlink.h \
GSWImage.h \
GSWImageButton.h \
GSWInput.h \
GSWJavaScript.h \
GSWKeyValueAssociation.h \
GSWMailDelivery.h \
GSWMultiKeyDictionary.h \
GSWNestedList.h \
GSWPageDefElement.h \
GSWPageDefLexer.h \
GSWPageDefParser.h \
GSWPageDefParserExt.h \
GSWPageDefTokenTypes.h \
GSWParam.h \
GSWPasswordField.h \
GSWPopUpButton.h \
GSWProjectBundle.h \
GSWRadioButton.h \
GSWRadioButtonList.h \
GSWRepetition.h \
GSWMessage.h \
GSWRequest.h \
GSWRequestHandler.h \
GSWResetButton.h \
GSWResourceManager.h \
GSWResourceRequestHandler.h \
GSWResponse.h \
GSWServerSessionStore.h \
GSWSession.h \
GSWSessionStore.h \
GSWSessionTimeOut.h \
GSWSessionTimeOutManager.h \
GSWStatisticsStore.h \
GSWStats.h \
GSWString.h \
GSWSubmitButton.h \
GSWSwitchComponent.h \
GSWTemplateParser.h \
GSWTemplateParserANTLR.h \
GSWTemplateParserXML.h \
GSWHTMLAttrLexer.h \
GSWHTMLAttrParser.h \
GSWHTMLAttrParserExt.h \
GSWHTMLAttrTokenTypes.h \
GSWHTMLLexer.h \
GSWHTMLParser.h \
GSWHTMLParserExt.h \
GSWHTMLTokenTypes.h \
GSWText.h \
GSWTextField.h \
GSWToggle.h \
GSWTransactionRecord.h \
GSWURLValuedElementData.h \
GSWVBScript.h \
NSNonBlockingFileHandle.h \
NSString+HTML.h \
NSString+Trimming.h \
GSWConfig.h \
GSWConstants.h \
GSWDebug.h \
GSWUtils.h \
GSWGeometricRegion.h \
GSWFileUpload.h \
GSWResourceURL.h \
GSWProcFS.h \
NSData+Compress.h \
GSWWOCompatibility.h \
GSWLifebeatThread.h \
GSWStaticResourceRequestHandler.h \
GSWRecording.h \
GSWInputStreamData.h \
GSWActionURL.h \

#For next Version:
#GSWAdminAction.h \
#GSWStack.h \
#GSWXMLCoder.h \
#GSWXMLMappingCoder.h \
#GSWXMLDecoder.h \
#GSWMonitorXMLCoder.h \
#GSWMonitorXMLDecoder.h \

# The framework installed WO header files
WebObjects_HEADER_FILES = $(GSWeb_HEADER_FILES)

WO_HEADER_FILES = \
	WOAdaptor.h \
	WOApplication.h \
	WOAssociation.h \
	WOComponent.h \
	WOContext.h \
	WOCookie.h \
	WODirectAction.h \
	WODisplayGroup.h \
	WODynamicElement.h \
	WOElement.h \
	WOMailDelivery.h \
	WORequest.h \
	WORequestHandler.h \
	WOResourceManager.h \
	WOResponse.h \
	WOSession.h \
	WOSessionStore.h \
	WOStatisitcsStore.h 

# WebObjects.h not needed as it gets copied explicitly


GSWeb_HEADER_FILES_DIR = $(HEADER_DIR)
WebObjects_HEADER_FILES_DIR = $(HEADER_DIR)

SRCS = $(LIBRARY_NAME:=.m)
HDRS = $(LIBRARY_NAME:=.h)

# Documentation
DOCUMENT_NAME = GSWeb

GSWeb_AUTOGSDOC_HEADERS = $(GSWeb_HEADER_FILES)
GSWeb_AUTOGSDOC_SOURCE = $(GSWeb_OBJC_FILES)
GSWeb_AGSDOC_FILES = gsweb.gsdoc $(GSWeb_AUTOGSDOC_HEADERS) 

GSWeb_AGSDOC_FLAGS = \
	-Declared Foundation \
	-Standards YES \
	-SystemProjects System \
	-Project gsweb \
	-WordMap '{\
	FOUNDATION_EXPORT=extern;FOUNDATION_STATIC_INLINE="";\
	GS_GEOM_SCOPE=extern;GS_GEOM_ATTR="";\
	GS_EXPORT=extern;GS_DECLARE="";\
	GS_RANGE_SCOPE=extern;GS_RANGE_ATTR="";\
	GS_ZONE_SCOPE=extern;GS_ZONE_ATTR="";\
	}' -Up gsweb

GSWeb_AGSDOC_FLAGS = $(GSWeb_AGSDOC_FLAGS)

-include Makefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/framework.make
# Only build the doc if doc=yes was passed on the command line
ifeq ($(doc),yes)
include $(GNUSTEP_MAKEFILES)/documentation.make
endif

-include Makefile.postamble
