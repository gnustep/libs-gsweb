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
FRAMEWORK_NAME = GSWExtensionsGSW
endif
ifeq ($(gswnames), wo)
FRAMEWORK_NAME = GSWExtensionsGSW_wo
endif
ifeq ($(gswnames), all)
FRAMEWORK_NAME = GSWExtensionsGSW GSWExtensionsGSW_wo
endif

# Ensure that each framework uses its own GNUSTEP_OBJ_DIR_NAME & DERIVED_SRC
ifneq ($(GNUSTEP_INSTANCE),)
GNUSTEP_OBJ_DIR_NAME := $(GNUSTEP_OBJ_DIR_NAME)/$(GNUSTEP_INSTANCE)
DERIVED_SRC := $(DERIVED_SRC)/$(GNUSTEP_INSTANCE)
endif

GSWExtensionsGSW_wo_CPPFLAGS = -DGSWEB_WONAMES

# The framework resource files and directories
GSWExtensionsGSW_RESOURCE_FILES = \
Resources/Info-gnustep.plist
GSWExtensionsGSW_wo_RESOURCE_FILES = $(GSWExtensionsGSW_RESOURCE_FILES)

GSWExtensionsGSW_COMPONENTS= \
GSWTabComponent.gswc \
GSWValidationFailureComponent.gswc \
GSWLogin.gswc \
GSWSimpleFormComponent.gswc \
GSWFileUploadFormComponent.gswc \
GSWFileUploadComponent.gswc
GSWExtensionsGSW_wo_COMPONENTS = $(GSWExtensionsGSW_COMPONENTS)

GSWExtensionsGSW_LANGUAGES= \
French
GSWExtensionsGSW_wo_LANGUAGES = $(GSWExtensionsGSW_LANGUAGES)

GSWExtensionsGSW_RESOURCE_DIRS = 
GSWExtensionsGSW_wo_RESOURCE_DIRS = $(GSWExtensionsGSW_RESOURCE_DIRS)

GSWExtensionsGSW_WEBSERVER_RESOURCE_FILES = 
GSWExtensionsGSW_wo_WEBSERVER_RESOURCE_FILES = $(GSWExtensionsGSW_WEBSERVER_RESOURCE_FILES)

# The Objective-C source files to be compiled
GSWExtensionsGSW_OBJC_FILES = \
GSWLogin.m \
GSWTabComponent.m \
GSWValidationFailureComponent.m \
GSWSimpleFormComponent.m \
GSWFileUploadFormComponent.m \
GSWFileUploadComponent.m 
GSWExtensionsGSW_wo_OBJC_FILES = $(GSWExtensionsGSW_OBJC_FILES)

# The header files to be installed
GSWExtensionsGSW_HEADER_FILES = \
GSWExtGSWWOCompatibility.h \
GSWLogin.h \
GSWTabComponent.h \
GSWValidationFailureComponent.h \
GSWFileUploadFormComponent.h \
GSWFileUploadComponent.h
GSWExtensionsGSW_wo_HEADER_FILES = $(GSWExtensionsGSW_HEADER_FILES)

GSWExtensionsGSW_HEADER_FILES_DIR = $(HEADER_DIR)
GSWExtensionsGSW_wo_HEADER_FILES_DIR = $(GSWExtensionsGSW_HEADER_FILES_DIR)

SRCS = $(LIBRARY_NAME:=.m)
HDRS = $(LIBRARY_NAME:=.h)

GSWExtensionsGSW_AUTOGSDOC_HEADERS = $(GSWExtensionsGSW_HEADER_FILES)
GSWExtensionsGSW_AUTOGSDOC_SOURCE = $(GSWExtensionsGSW_OBJC_FILES)
DOCUMENT_NAME = GSWExtensionsGSW

GSWExtensionsGSW_AGSDOC_FILES = gswextensionsgsw.gsdoc $(GSWExtensionsGSW_AUTOGSDOC_HEADERS) 
#$(GSWExtensionsGSW_AUTOGSDOC_SOURCE)
GSWExtensionsGSW_AGSDOC_FLAGS = \
	-Declared Foundation \
	-Standards YES \
	-Project gswextensionsgsw \
	-WordMap '{\
	FOUNDATION_EXPORT=extern;FOUNDATION_STATIC_INLINE="";\
	GS_GEOM_SCOPE=extern;GS_GEOM_ATTR="";\
	GS_EXPORT=extern;GS_DECLARE="";\
	GS_RANGE_SCOPE=extern;GS_RANGE_ATTR="";\
	GS_ZONE_SCOPE=extern;GS_ZONE_ATTR="";\
	}' -Up gswextensionsgsw

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

