# GNUmakefile - GSWeb: GNUmakefile
#   Copyright (C) 2010 Free Software Foundation, Inc.
#   
#   Written by:	David Wetzel <dave@turbocat.de>
#   Date: 		Apr 2010
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

include $(GNUSTEP_MAKEFILES)/common.make

FRAMEWORK_NAME = GSWDatabase

GSWDatabase_CPPFLAGS = -DGSWEB_WONAMES

# The framework resource files and directories
GSWDatabase_RESOURCE_FILES = \
Resources/Info-gnustep.plist \

GSWDatabase_COMPONENTS = 
GSWDatabase_LOCALIZED_RESOURCE_FILES = 

WOExtensions_COMPONENTS =  $(addprefix WO, \
			     $(addsuffix .wo, $(Extensions_COMPONENTS)))

GSWDatabase_LANGUAGES = \
French

GSWDatabase_LOCALIZED_RESOURCE_FILES = $(addprefix GSW, \
		$(addsuffix .gswc, $(Extensions_LOCALIZED_RESOURCE_FILES)))

WOExtensions_LOCALIZED_RESOURCE_FILES = $(addprefix WO, \
		$(addsuffix .wo, $(Extensions_LOCALIZED_RESOURCE_FILES)))

WOExtensions_LANGUAGES = $(GSWDatabase_LANGUAGES)

GSWDatabase_RESOURCE_DIRS = 

# The Objective-C source files to be compiled
GSWDatabase_OBJC_FILES = \
WODisplayGroup.m 

# The header files to be installed
GSWDatabase_HEADER_FILES = \
WODisplayGroup.h 

WOExtensions_HEADER_FILES = $(GSWDatabase_HEADER_FILES) \
				WOExtensions.h $(WO_HEADER_FILES)

GSWDatabase_HEADER_FILES_DIR = $(HEADER_DIR)

SRCS = $(LIBRARY_NAME:=.m)
HDRS = $(LIBRARY_NAME:=.h)

GSWDatabase_AUTOGSDOC_HEADERS = $(GSWDatabase_HEADER_FILES)
GSWDatabase_AUTOGSDOC_SOURCE = $(GSWDatabase_OBJC_FILES)
DOCUMENT_NAME = GSWDatabase


-include Makefile.preamble

-include GNUmakefile.local

include ../gsweb.make

include $(GNUSTEP_MAKEFILES)/framework.make
                
-include Makefile.postamble

