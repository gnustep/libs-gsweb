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

# The library to be compiled
GSWBUNDLE_NAME=GSWExtensions
GSWExtensions_HAS_GSWCOMPONENTS=YES

# The bundle resource files and directories
GSWExtensions_RESOURCE_FILES = \
Resources/Info-gnustep.plist

GSWExtensions_COMPONENTS= \
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

GSWExtensions_LANGUAGES= \
French

GSWExtensions_RESOURCE_DIRS = 

GSWExtensions_WEBSERVER_RESOURCE_FILES = \
Ascending.gif \
Descending.gif \
DownTriangle.gif \
PoweredByGNUstep.gif \
PoweredByGNUstepWeb.gif \
RightTriangle.gif \
Unsorted.gif \
appOff.gif \
appOn.gif \
back.gif \
dir.gif \
exclamation.gif \
eye.gif \
lft-OSarw.gif \
rt-OSarw.gif \
text.gif \
gswapp.gif \
gswappsrv.gif


# The bundles libraries to link against
#GSWExtensions_BUNDLE_LIBS = 

# The bundles to be installed
GSWBUNDLE_INSTALL = $(BUNDLE_NAME)
GSWBUNDLE_INSTALL_DIR = $(GNUSTEP_LIBRARIES_ROOT)/gsweb

# Use .gdladaptor as the bundle extension
GSWBUNDLE_EXTENSION = .framework

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
GSWMetaRefresh.m

#GSWCompletionBar.m

# The library to be compiled
LIBRARY_NAME=libGSWExtensions

# The bundle Objective-C source files to be compiled
libGSWExtensions_OBJC_FILES = $(GSWExtensions_OBJC_FILES)

libGSWExtensions_HEADER_FILES_DIR = .
libGSWExtensions_HEADER_FILES_INSTALL_DIR = /gsweb/GSWExtensions.framework

libGSWExtensions_HEADER_FILES = \
GSWCollapsibleComponentContent.h \
GSWDictionaryRepetition.h \
GSWExceptionPage.h \
GSWIFrame.h \
GSWMetaRefresh.h \
GSWPageRestorationErrorPage.h \
GSWRedirect.h \
GSWSessionCreationErrorPage.h \
GSWSessionRestorationErrorPage.h \
GSWStatsPage.h

#GSWCompletionBar.h
#GSWThresholdColoredNumber.h
#GSWSortOrder.h
#GSWSortOrderManyKey.h
#GSWSimpleArrayDisplay.h
#GSWSimpleArrayDisplay2.h
#GSWBatchNavigationBar.h

SRCS = $(LIBRARY_NAME:=.m)

HDRS = $(LIBRARY_NAME:=.h)

#DIST_FILES = $(SRCS) $(HDRS) GNUmakefile Makefile.postamble Makefile.preamble


-include Makefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/gswbundle.make
include $(GNUSTEP_MAKEFILES)/library.make

-include Makefile.postamble

