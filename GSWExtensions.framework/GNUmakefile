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
FRAMEWORK_NAME = WOExtensions
endif
ifeq ($(gswnames), all)
FRAMEWORK_NAME = GSWExtensions WOExtensions
endif

# Ensure that each framework uses its own GNUSTEP_OBJ_DIR_NAME & DERIVED_SRC
ifneq ($(GNUSTEP_INSTANCE),)
GNUSTEP_OBJ_DIR_NAME := $(GNUSTEP_OBJ_DIR_NAME)/$(GNUSTEP_INSTANCE)
DERIVED_SRC := $(DERIVED_SRC)/$(GNUSTEP_INSTANCE)
endif

WOExtensions_CPPFLAGS = -DGSWEB_WONAMES

# The framework resource files and directories
GSWExtensions_RESOURCE_FILES = \
Resources/Info-gnustep.plist \

WOExtensions_RESOURCE_FILES = $(GSWExtensions_RESOURCE_FILES)

Extensions_COMPONENTS = \
SessionCreationErrorPage \
SessionRestorationErrorPage \
CollapsibleComponentContent \
PageRestorationErrorPage \
StatsPage \
DictionaryRepetition \
Table \
ExceptionPage \
TableString \
IFrame \
MetaRefresh \
Redirect \
KeyValueConditional \

#CompletionBar 
#AnyField 
#SimpleArrayDisplay 
#AppleScript 
#SimpleArrayDisplay2 
#BatchNavigationBar 
#SortOrder 
#SortOrderManyKey 
#ThresholdColoredNumber 
#ToManyRelationship 
#PageRestorationErrorPage 
#ToOneRelationship 

Extensions_LOCALIZED_RESOURCE_FILES = \
ExceptionPage \
PageRestorationErrorPage \
SessionCreationErrorPage \
SessionRestorationErrorPage

GSWExtensions_COMPONENTS = $(addprefix GSW, \
			     $(addsuffix .gswc, $(Extensions_COMPONENTS)))
GSWExtensions_COMPONENTS += GSWRedirect.gswc

WOExtensions_COMPONENTS =  $(addprefix WO, \
			     $(addsuffix .wo, $(Extensions_COMPONENTS)))

GSWExtensions_LANGUAGES = \
French

GSWExtensions_LOCALIZED_RESOURCE_FILES = $(addprefix GSW, \
		$(addsuffix .gswc, $(Extensions_LOCALIZED_RESOURCE_FILES)))

WOExtensions_LOCALIZED_RESOURCE_FILES = $(addprefix WO, \
		$(addsuffix .wo, $(Extensions_LOCALIZED_RESOURCE_FILES)))

WOExtensions_LANGUAGES = $(GSWExtensions_LANGUAGES)

WO_LOCALIZED_COMPONENTS = \
	$(addprefix French.lproj/, $(WOExtensions_LOCALIZED_RESOURCE_FILES))

GSWExtensions_RESOURCE_DIRS = 
WOExtensions_RESOURCE_DIRS = $(GSWExtensions_RESOURCE_DIRS)

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
WOExtensions_WEBSERVER_RESOURCE_FILES = \
	$(GSWExtensions_WEBSERVER_RESOURCE_FILES)

# The Objective-C source files to be compiled
GSWExtensions_OBJC_FILES = \
GSWStatsPage.m \
GSWCollapsibleComponentContent.m \
GSWSessionCreationErrorPage.m \
GSWSessionRestorationErrorPage.m \
GSWPageRestorationErrorPage.m \
GSWExceptionPage.m \
GSWDictionaryRepetition.m \
GSWRedirect.m \
GSWIFrame.m \
GSWMetaRefresh.m \
GSWLongResponsePage.m \
GSWKeyValueConditional.m \

#GSWCompletionBar.m
WOExtensions_OBJC_FILES = $(GSWExtensions_OBJC_FILES)

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
GSWLongResponsePage.h \
GSWKeyValueConditional.h \

#GSWCompletionBar.h
#GSWThresholdColoredNumber.h
#GSWSortOrder.h
#GSWSortOrderManyKey.h
#GSWSimpleArrayDisplay.h
#GSWSimpleArrayDisplay2.h
#GSWBatchNavigationBar.h

WO_HEADER_FILES = \
	WOLongResponsePage.h \
	WORedirect.h

# WOExtensions.h not needed as it gets copied explicitly

WOExtensions_HEADER_FILES = $(GSWExtensions_HEADER_FILES) \
				WOExtensions.h $(WO_HEADER_FILES)

GSWExtensions_HEADER_FILES_DIR = $(HEADER_DIR)
WOExtensions_HEADER_FILES_DIR = $(HEADER_DIR)

SRCS = $(LIBRARY_NAME:=.m)
HDRS = $(LIBRARY_NAME:=.h)

GSWExtensions_AUTOGSDOC_HEADERS = $(GSWExtensions_HEADER_FILES)
GSWExtensions_AUTOGSDOC_SOURCE = $(GSWExtensions_OBJC_FILES)
DOCUMENT_NAME = GSWExtensions
GSWExtensions_AGSDOC_FILES = gswextensions.gsdoc \
	$(GSWExtensions_AUTOGSDOC_HEADERS) 
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

