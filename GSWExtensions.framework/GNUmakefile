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

# Options
ifeq ($(gswnames), gsw)
FRAMEWORK_NAME = GSWExtensions
endif
ifeq ($(gswnames), wo)
FRAMEWORK_NAME = GSWExtensions_wo
endif
ifeq ($(gswnames), all)
FRAMEWORK_NAME = GSWExtensions GSWExtensions_wo
endif

# Ensure that each framework uses its own GNUSTEP_OBJ_DIR & DERIVED_SRC
ifneq ($(GNUSTEP_INSTANCE),)
GNUSTEP_OBJ_DIR := $(GNUSTEP_OBJ_DIR)/$(GNUSTEP_INSTANCE)
DERIVED_SRC := $(DERIVED_SRC)/$(GNUSTEP_INSTANCE)
endif

GSWExtensions_wo_CPPFLAGS = -DGSWEB_WONAMES

# The framework resource files and directories
GSWExtensions_RESOURCE_FILES = \
Resources/Info-gnustep.plist \
GSWSessionRestorationErrorPage.gswd
GSWExtensions_wo_RESOURCE_FILES = $(GSWExtensions_RESOURCE_FILES)

GSWExtensions_COMPONENTS = \
GSWSessionCreationErrorPage.gswc \
GSWSessionRestorationErrorPage.gswc \
GSWCollapsibleComponentContent.gswc \
GSWStatsPage.gswc \
GSWDictionaryRepetition.gswc \
GSWTable.gswc \
GSWExceptionPage.gswc \
GSWTableString.gswc \
GSWIFrame.gswc \
GSWMetaRefresh.gswc \
GSWRedirect.gswc

#GSWCompletionBar.gswc 
#GSWAnyField.gswc 
#GSWSimpleArrayDisplay.gswc 
#GSWAppleScript.gswc 
#GSWSimpleArrayDisplay2.gswc 
#GSWBatchNavigationBar.gswc 
#GSWSortOrder.gswc 
#GSWSortOrderManyKey.gswc 
#GSWThresholdColoredNumber.gswc 
#GSWToManyRelationship.gswc 
#GSWPageRestorationErrorPage.gswc 
#GSWToOneRelationship.gswc 
GSWExtensions_wo_COMPONENTS = $(GSWExtensions_COMPONENTS)

GSWExtensions_LANGUAGES = \
French
GSWExtensions_wo_LANGUAGES = $(GSWExtensions_LANGUAGES)

GSWExtensions_RESOURCE_DIRS = 
GSWExtensions_wo_RESOURCE_DIRS = $(GSWExtensions_RESOURCE_DIRS)

GSWExtensions_WEBSERVER_RESOURCE_FILES = \
Ascending.png \
Descending.png \
DownTriangle.png \
PoweredByGNUstep.png \
PoweredByGNUstepWeb.png \
RightTriangle.png \
Unsorted.png \
appOff.png \
appOn.png \
back.png \
dir.png \
exclamation.mng \
eye.png \
lft-OSarw.png \
rt-OSarw.png \
text.png \
gswapp.png \
gswappsrv.png \
warning.mng \
error.mng
GSWExtensions_wo_WEBSERVER_RESOURCE_FILES = $(GSWExtensions_WEBSERVER_RESOURCE_FILES)

# The Objective-C source files to be compiled
GSWExtensions_OBJC_FILES = \
GSWStatsPage.m \
GSWCollapsibleComponentContent.m \
GSWSessionCreationErrorPage.m \
GSWSessionRestorationErrorPage.m \
GSWExceptionPage.m \
GSWDictionaryRepetition.m \
GSWRedirect.m \
GSWIFrame.m \
GSWMetaRefresh.m \
GSWLongResponsePage.m \

#GSWCompletionBar.m
GSWExtensions_wo_OBJC_FILES = $(GSWExtensions_OBJC_FILES)

# The header files to be installed
GSWExtensions_HEADER_FILES = \
GSWExtWOCompatibility.h \
GSWExtensions.h \
GSWCollapsibleComponentContent.h \
GSWDictionaryRepetition.h \
GSWExceptionPage.h \
GSWIFrame.h \
GSWMetaRefresh.h \
GSWPageRestorationErrorPage.h \
GSWRedirect.h \
GSWSessionCreationErrorPage.h \
GSWSessionRestorationErrorPage.h \
GSWStatsPage.h \
GSWLongResponsePage.h

#GSWCompletionBar.h
#GSWThresholdColoredNumber.h
#GSWSortOrder.h
#GSWSortOrderManyKey.h
#GSWSimpleArrayDisplay.h
#GSWSimpleArrayDisplay2.h
#GSWBatchNavigationBar.h
GSWExtensions_wo_HEADER_FILES = $(GSWExtensions_HEADER_FILES)

WO_HEADER_FILES = \
	WOLongResponsePage.h \
	WORedirect.h

# WOExtensions.h not needed as it gets copied explicitly

GSWExtensions_HEADER_FILES_DIR = $(HEADER_DIR)
GSWExtensions_wo_HEADER_FILES_DIR = $(HEADER_DIR)
GSWExtensions_wo_HEADER_FILES_INSTALL_DIR = WOExtensions

SRCS = $(LIBRARY_NAME:=.m)
HDRS = $(LIBRARY_NAME:=.h)

GSWExtensions_AUTOGSDOC_HEADERS = $(GSWExtensions_HEADER_FILES)
GSWExtensions_AUTOGSDOC_SOURCE = $(GSWExtensions_OBJC_FILES)
DOCUMENT_NAME = GSWExtensions
GSWExtensions_AGSDOC_FILES = gswextensions.gsdoc $(GSWExtensions_AUTOGSDOC_HEADERS) 
#$(GSWExtensions_AUTOGSDOC_SOURCE)
GSWExtensions_AGSDOC_FLAGS = \
	-Declared Foundation \
	-Standards YES \
	-Project gswextensions \
	-WordMap '{\
	FOUNDATION_EXPORT=extern;FOUNDATION_STATIC_INLINE="";\
	GS_GEOM_SCOPE=extern;GS_GEOM_ATTR="";\
	GS_EXPORT=extern;GS_DECLARE="";\
	GS_RANGE_SCOPE=extern;GS_RANGE_ATTR="";\
	GS_ZONE_SCOPE=extern;GS_ZONE_ATTR="";\
	}' -Up gswextensions

#	-SystemProjects System \

#DIST_FILES = $(SRCS) $(HDRS) GNUmakefile Makefile.postamble Makefile.preamble


-include Makefile.preamble

-include GNUmakefile.local

include ../gsweb.make

include $(GNUSTEP_MAKEFILES)/framework.make
ifeq ($(doc),yes)
include $(GNUSTEP_MAKEFILES)/documentation.make
endif

-include Makefile.postamble

