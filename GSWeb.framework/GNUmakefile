# GNUmakefile - GSWeb: GNUmakefile
#   Copyright (C) 1999 Free Software Foundation, Inc.
#   
#   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
#   Date: 		Jan 1999
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

include $(GNUSTEP_MAKEFILES)/common.make

include ../Version
include ../config.mak

srcdir = .

# The framework to be compiled
FRAMEWORK_NAME = GSWeb

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

GSWeb_RESOURCE_DIRS = DTDs

# The framework libraries to link against
GSWeb_GSWBUNDLE_LIBS = 

# Determine the bundle directory extension
#ifeq ($(profile), yes)
#  GSWBUNDLE_EXTENSION = .frameworkp
#else
#  ifeq ($(debug), yes)
#    GSWBUNDLE_EXTENSION = .frameworkd
#  else
#    GSWBUNDLE_EXTENSION = .framework
#  endif
#endif

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
GSWeb.m \
GSWBundle.m \
NSObject+IVarAccess+PerformSel.m \
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
GSWDirectAction.m \
GSWMailDelivery.m \
GSWComponentRequestHandler.m \
GSWResourceRequestHandler.m \
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
GSWWOCompatibility.m \
stacktrace.m \
attach.m


# The framework installed header files
GSWeb_HEADER_FILES = \
GSCache.h  \
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
GSWDirectAction.h \
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
GSWeb.h \
NSNonBlockingFileHandle.h \
NSObject+IVarAccess+PerformSel.h \
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
GSWWOCompatibility.h


SRCS = $(LIBRARY_NAME:=.m)
HDRS = $(LIBRARY_NAME:=.h)


-include Makefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/framework.make

-include Makefile.postamble
