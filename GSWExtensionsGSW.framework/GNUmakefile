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
GSWBUNDLE_NAME=GSWExtensionsGSW
GSWExtensionsGSW_HAS_GSWCOMPONENTS=YES

# The bundle resource files and directories
GSWExtensionsGSW_RESOURCE_FILES = \
Resources/Info-gnustep.plist \

GSWExtensionsGSW_COMPONENTS= \
GSWTabComponent.gswc \
GSWValidationFailureComponent.gswc \
GSWLogin.gswc \
GSWSimpleFormComponent.gswc \
GSWFileUploadFormComponent.gswc

GSWExtensionsGSW_LANGUAGES= \
French

GSWExtensionsGSW_RESOURCE_DIRS = 

GSWExtensionsGSW_WEBSERVER_RESOURCE_FILES = 

# The bundles libraries to link against
#GNUstepWeb_BUNDLE_LIBS = 

# The bundles to be installed
GSWBUNDLE_INSTALL = $(BUNDLE_NAME)
GSWBUNDLE_INSTALL_DIR = $(GNUSTEP_LIBRARIES_ROOT)/gsweb

# Determine the bundle directory extension
ifeq ($(profile), yes)
  GSWBUNDLE_EXTENSION = .frameworkp
else
  ifeq ($(debug), yes)
    GSWBUNDLE_EXTENSION = .frameworkd
  else
    GSWBUNDLE_EXTENSION = .framework
  endif
endif

# The Objective-C source files to be compiled
GSWExtensionsGSW_OBJC_FILES = \
GSWLogin.m \
GSWTabComponent.m \
GSWValidationFailureComponent.m \
GSWSimpleFormComponent.m \
GSWFileUploadFormComponent.m 

# The library to be compiled
LIBRARY_NAME=libGSWExtensionsGSW

# The bundle Objective-C source files to be compiled
libGSWExtensionsGSW_OBJC_FILES = $(GSWExtensionsGSW_OBJC_FILES)

libGSWExtensionsGSW_HEADER_FILES_DIR = .
libGSWExtensionsGSW_HEADER_FILES_INSTALL_DIR = /gsweb/GSWExtensionsGSW.framework

libGSWExtensionsGSW_HEADER_FILES = \
GSWLogin.h \
GSWTabComponent.h \
GSWValidationFailureComponent.h \
GSWFileUploadFormComponent.h

SRCS = $(LIBRARY_NAME:=.m)

HDRS = $(LIBRARY_NAME:=.h)

#DIST_FILES = $(SRCS) $(HDRS) GNUmakefile Makefile.postamble Makefile.preamble

-include Makefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/gswbundle.make
include $(GNUSTEP_MAKEFILES)/library.make

-include Makefile.postamble
