# GNUmakefile - GSWeb documentation: GNUmakefile
#
#   Copyright (C) 2004 Free Software Foundation, Inc.
#   
#   Written by:	David Ayers <d.ayers@inode.at
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

include $(GNUSTEP_MAKEFILES)/common.make

include ../Version
include ../config.mak

# Documentation
DOCUMENT_NAME = GNUstepWeb

GNUstepWeb_AGSDOC_FILES = gsweb.gsdoc

GNUstepWeb_AGSDOC_FLAGS = \
	-Declared WebObjects \
	-Standards YES \
	-Project GNUstepWeb \
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
	}' -Up GNUstepWeb

-include Makefile.preamble

-include GNUmakefile.local

# Only build the doc if doc=yes was passed on the command line
ifeq ($(doc),yes)
include $(GNUSTEP_MAKEFILES)/documentation.make
endif

-include Makefile.postamble
