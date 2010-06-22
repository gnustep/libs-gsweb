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

include $(GNUSTEP_MAKEFILES)/common.make
include $(GNUSTEP_MAKEFILES)/Auxiliary/gsweb.make

GSWAPP_NAME=DynamicElements
DynamicElements_HAS_GSWCOMPONENTS=YES
DynamicElements_PRINCIPAL_CLASS=DynamicElements
DynamicElements_GSWAPP_INFO_PLIST=Resources/Info-DynamicElements.plist

# The bundle resource files and directories
DynamicElements_RESOURCE_FILES = \
Resources/Info-DynamicElements.plist \

DynamicElements_WEBSERVER_RESOURCE_FILES = testpic.jpg

# The Objective-C source files to be compiled
DynamicElements_OBJC_FILES = \
BasePage.m \
DynamicElements.m \
DynamicElements_main.m \
Main.m \
FileUpload1Page.m \
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
ImagePage.m

DynamicElements_COMPONENTS = \
Main.wo \
FileUpload1Page.wo \
RadioButtonList1Page.wo \
RadioButtonList2Page.wo \
CheckBoxList1Page.wo \
CheckBoxList2Page.wo \
Browser1Page.wo \
Browser2Page.wo \
PopUpButton1Page.wo \
PopUpButton2Page.wo \
TextField1Page.wo \
CheckBox1Page.wo \
CheckBox2Page.wo \
RadioButton1Page.wo \
ImagePage.wo


-include Makefile.preamble

include $(GNUSTEP_MAKEFILES)/gswapp.make

ifneq ($(FOUNDATION_LIB),gnu)
AUXILIARY_GSW_LIBS = -framework WebObjects -framework WOExtensions
else
AUXILIARY_GSW_LIBS += -lWebObjects -lWOExtensions
endif

-include Makefile.postamble
