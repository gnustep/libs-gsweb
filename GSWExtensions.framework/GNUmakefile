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
FRAMEWORK_NAME = GSWExtensions

# The framework resource files and directories
GSWExtensions_RESOURCE_FILES = \
Resources/Info-gnustep.plist \
GSWSessionRestorationErrorPage.gswd

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

GSWExtensions_LANGUAGES = \
French

GSWExtensions_RESOURCE_DIRS = 

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
exclamation.gif \
eye.png \
lft-OSarw.png \
rt-OSarw.png \
text.png \
gswapp.png \
gswappsrv.png \
warning.gif \
error.gif


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

# The header files to be installed
GSWExtensions_HEADER_FILES = \
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

include $(GNUSTEP_MAKEFILES)/framework.make

-include Makefile.postamble

