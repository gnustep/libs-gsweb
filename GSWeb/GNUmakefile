# GNUmakefile - GSWeb: GNUmakefile
#
#   Copyright (C) 1999-2004 Free Software Foundation, Inc.
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

GNUSTEP_LOCAL_ADDITIONAL_MAKEFILES=../gsweb.make
include $(GNUSTEP_MAKEFILES)/common.make
ifeq ($(GDL2),yes)
include $(GNUSTEP_MAKEFILES)/Auxiliary/gdl2.make
endif

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
# Hmmm.
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
GSWDictionary.m \
GSWDebug.m \
GSWConstants.m \
GSWTemporaryElement.m \
GSWBaseParser.m \
GSWHTMLRawParser.m \
GSWHTTPIO.m \
GSWDeclaration.m \
GSWDeclarationParser.m \
GSWTemplateParser.m \
GSWHTMLTemplateParser.m \
GSWSessionTimeOutManager.m \
GSWServerSessionStore.m \
GSWDeployedBundle.m \
GSWProjectBundle.m \
GSWSessionTimeOut.m \
GSWStats.m \
NSNonBlockingFileHandle.m \
NSDictionary+HTML.m \
GSWTransactionRecord.m \
GSWBundle.m \
NSString+Trimming.m \
NSString+HTML.m \
GSWApplication.m \
GSWApplication+Defaults.m \
GSWAssociation.m \
GSWComponent.m \
GSWContext.m \
GSWDynamicElement.m \
GSWDynamicGroup.m \
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
GSWClientSideScript.m \
GSWActiveImage.m \
GSWAjaxRequestHandler.m \
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
GSWImageInfo.m \
GSWPngImageInfo.m \
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
GSWKeyValueAssociation.m \
GSWHTMLStaticElement.m \
GSWHTMLStaticGroup.m \
GSWInput.m \
GSWConstantValueAssociation.m \
GSWComponentReference.m \
GSWElementID.m \
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
GSWWorkerThread.m \
NSObject+XML.m \
WOKeyValueUnarchiver.m

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
GSWDictionary.h \
GSWeb.h \
GSWActiveImage.h \
GSWAdaptor.h \
GSWAjaxRequestHandler.h \
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
GSWDeployedBundle.h \
GSWAction.h \
GSWDirectAction.h \
GSWActionRequestHandler.h \
GSWDirectActionRequestHandler.h \
GSWDynamicElement.h \
GSWDynamicGroup.h \
GSWDynamicURLString.h \
GSWElement.h \
GSWElementID.h \
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
GSWImageInfo.h \
GSWPngImageInfo.h \
GSWInput.h \
GSWJavaScript.h \
GSWKeyValueAssociation.h \
GSWMailDelivery.h \
GSWNestedList.h \
GSWTemporaryElement.h \
GSWBaseParser.h \
GSWHTMLRawParser.h \
GSWDeclaration.h \
GSWDeclarationParser.h \
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
GSWHTMLTemplateParser.h \
GSWText.h \
GSWTextField.h \
GSWToggle.h \
GSWTransactionRecord.h \
GSWURLValuedElementData.h \
GSWVBScript.h \
NSNonBlockingFileHandle.h \
NSString+HTML.h \
NSString+Trimming.h \
NSDictionary+HTML.h \
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
GSWDefines.h \
GSWHTTPIO.h \
GSWPrivate.h \
NSObject+XML.h \
WOKeyValueUnarchiver.h

#For next Version:
#GSWAdminAction.h \
#GSWStack.h \
#GSWXMLCoder.h \
#GSWXMLMappingCoder.h \
#GSWXMLDecoder.h \
#GSWMonitorXMLCoder.h \
#GSWMonitorXMLDecoder.h \

WO_HEADER_FILES = \
	WOAdaptor.h \
	WOApplication.h \
	WOAssociation.h \
	WOComponent.h \
	WOContext.h \
	WOCookie.h \
	WODirectAction.h \
	WODynamicElement.h \
	WOElement.h \
	WOMailDelivery.h \
	WORequest.h \
	WORequestHandler.h \
    WOAjaxRequestHandler.h \
	WOResourceManager.h \
	WOResponse.h \
	WOSession.h \
	WOSessionStore.h \
	WOStatisitcsStore.h 

# WebObjects.h not needed as it gets copied explicitly

# The framework installed WO header files
WebObjects_HEADER_FILES = $(GSWeb_HEADER_FILES) WebObjects.h $(WO_HEADER_FILES)

GSWeb_HEADER_FILES_DIR = $(HEADER_DIR)
WebObjects_HEADER_FILES_DIR = $(HEADER_DIR)

SRCS = $(LIBRARY_NAME:=.m)
HDRS = $(LIBRARY_NAME:=.h)

# Documentation
DOCUMENT_NAME = GSWeb

GSWeb_AUTOGSDOC_HEADERS = $(GSWeb_HEADER_FILES)
GSWeb_AUTOGSDOC_SOURCE = $(GSWeb_OBJC_FILES)
GSWeb_AGSDOC_FILES = gsweb.gsdoc $(GSWeb_AUTOGSDOC_HEADERS) 
GSWeb_ADSDOC_INSTALL_BUNDLE = GNUstepWeb

GSWeb_AGSDOC_FLAGS = \
        -Declared WebObjects \
	-Standards YES \
	-Project gsweb \
	-WordMap '{\
	FOUNDATION_EXPORT=extern;\
	FOUNDATION_STATIC_INLINE="";\
	GS_DECLARE="";\
	GS_EXPORT=extern;\
	GS_GEOM_ATTR="";\
	GS_GEOM_SCOPE=extern;\
	GS_RANGE_ATTR="";\
	GS_RANGE_SCOPE=extern;\
	GS_ZONE_ATTR="";\
	GS_ZONE_SCOPE=extern;\
	GSWEB_EXPORT="";\
	}' -Up gsweb

-include Makefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/framework.make
# Only build the doc if doc=yes was passed on the command line
ifeq ($(doc),yes)
include $(GNUSTEP_MAKEFILES)/documentation.make
endif

ADDITIONAL_OBJCFLAGS = -Werror-implicit-function-declaration

-include Makefile.postamble
