#
#  WebBookStore1 Example
#
#  Copyright (C) 2004 Free Software Foundation, Inc.
#
#  Written by:	David Ayers  <d.ayers@inode.at>
#
#  This file is part of the GNUstepWeb Library.
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

GSWAPP_NAME=WebBookStore1
WebBookStore1_HAS_GSWCOMPONENTS=YES
WebBookStore1_PRINCIPAL_CLASS=WebBookStore1
WebBookStore1_GSWAPP_INFO_PLIST=Resources/Info-WebBookStore1.plist

# The Objective-C source files to be compiled
WebBookStore1_OBJC_FILES = Application.m Session.m DirectAction.m Main.m \
	WebBookStore1_main.m

WebBookStore1_RESOURCE_FILES = BookStore.eomodeld
WebBookStore1_WEBSERVER_RESOURCE_FILES = Insert.png Delete.png Save.png \
	CreateTables.png DropTables.png

WebBookStore1_COMPONENTS = Main.gswc

-include Makefile.preamble

include $(GNUSTEP_MAKEFILES)/gswapp.make

-include Makefile.postamble
