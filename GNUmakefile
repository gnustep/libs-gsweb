#  Main Makefile for GNUstep Web
#  
#  Copyright (C) 1999-2000 Free Software Foundation, Inc.
#
#  Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
#
#  This file is part of GNUstep Web
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

ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
  ifeq ($(GNUSTEP_MAKEFILES),)
    $(warning )
    $(warning Unable to obtain GNUSTEP_MAKEFILES setting from gnustep-config!)
    $(warning Perhaps gnustep-make is not properly installed,)
    $(warning so gnustep-config is not in your PATH.)
    $(warning )
    $(warning Your PATH is currently $(PATH))
    $(warning )
  endif
endif

ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

include ./Version
include ./config.mak

#
# The list of subproject directories
#
SUBPROJECTS = GSWeb \
	GSWExtensions \
	GSWDatabase

#	GSWExtensionsGSW \
#GSWAdaptors

-include Makefile.preamble

include $(GNUSTEP_MAKEFILES)/aggregate.make

-include Makefile.postamble

