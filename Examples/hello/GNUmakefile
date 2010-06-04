#
#  examples makefile for the GNUstep Base Library
#
#  Copyright (C) 1997 Free Software Foundation, Inc.
#
#  Written by:	Scott Christley <scottc@net-community.com>
#
#  This file is part of the GNUstep Base Library.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
#  Library General Public License for more details.
#
#  You should have received a copy of the GNU Library General Public
#  License along with this library; if not, write to the Free
#  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

include $(GNUSTEP_MAKEFILES)/common.make
include $(GNUSTEP_MAKEFILES)/Auxiliary/gsweb_wo.make


GSWAPP_NAME=Hello
Hello_HAS_GSWCOMPONENTS=YES
Hello_PRINCIPAL_CLASS=Hello
Hello_GSWAPP_INFO_PLIST=Resources/Info-Hello.plist

# The Objective-C source files to be compiled
Hello_OBJC_FILES = Hello_main.m Hello.m HelloPage.m Main.m 

Hello_COMPONENTS = Main.wo HelloPage.wo

SRCS = $(GSWAPP_NAME:=.m)

HDRS =

DIST_FILES = $(SRCS) $(HDRS) GNUmakefile Makefile.postamble Makefile.preamble

ifneq ($(FOUNDATION_LIB),gnu)
AUXILIARY_GSW_LIBS = -framework WebObjects -framework WOExtensions
else
AUXILIARY_GSW_LIBS += -lWebObjects -lWOExtensions
endif


-include Makefile.preamble

include $(GNUSTEP_MAKEFILES)/gswapp.make

-include Makefile.postamble

# enable this for TCSimpleDB
#ADDITIONAL_TOOL_LIBS += -lTCSimpleDB 
#ADDITIONAL_OBJCFLAGS += -DTCSDB

