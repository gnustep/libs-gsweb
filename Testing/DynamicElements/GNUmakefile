#
#  Dynamic Elements Testing makefile for the GNUstepWeb
#
#  Copyright (C) 2002 Free Software Foundation, Inc.
#
#  Written by:	Manuel Guesdon <mguedon@orange-concept.com>
#
#  This file is part of GNUstepWeb
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

# Install into the system root by default
GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)

GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles

include $(GNUSTEP_MAKEFILES)/common.make
include config.mak


GSWAPP_NAME=DynamicElements
DynamicElements_HAS_GSWCOMPONENTS=YES
DynamicElements_PRINCIPAL_CLASS=DynamicElements
DynamicElements_GSWAPP_INFO_PLIST=Resources/Info-DynamicElements.plist

# The bundle resource files and directories
DynamicElements_RESOURCE_FILES = \
Resources/Info-DynamicElements.plist \
Resources/Base.gswd \

# The Objective-C source files to be compiled
DynamicElements_OBJC_FILES = \
BasePage.m \
DynamicElements.m \
DynamicElements_main.m \
Main.m \
RadioButtonList1Page.m \
RadioButtonList2Page.m \
CheckBoxList1Page.m \
CheckBoxList2Page.m \
Browser1Page.m \
Browser2Page.m \
PopUpButton1Page.m \
PopUpButton2Page.m \
TextField1Page.m \
CheckBox1Page.m \
CheckBox2Page.m \
RadioButton1Page.m \
RadioButton2Page.m \

DynamicElements_COMPONENTS = \
Main.gswc \
RadioButtonList1Page.gswc \
RadioButtonList2Page.gswc \
CheckBoxList1Page.gswc \
CheckBoxList2Page.gswc \
Browser1Page.gswc \
Browser2Page.gswc \
PopUpButton1Page.gswc \
PopUpButton2Page.gswc \
TextField1Page.gswc \
CheckBox1Page.gswc \
CheckBox2Page.gswc \
RadioButton1Page.gswc \
RadioButton2Page.gswc \


SRCS = $(GSWAPP_NAME:=.m)

HDRS =

DIST_FILES = $(SRCS) $(HDRS) GNUmakefile Makefile.postamble Makefile.preamble

-include Makefile.preamble

include $(GNUSTEP_MAKEFILES)/gswapp.make

-include Makefile.postamble
