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

include $(GNUSTEP_MAKEFILES)/common.make

include ./Version
include ./config.mak

#
# The list of subproject directories
#
SUBPROJECTS = GSWeb.framework \
	GSWExtensions.framework \
	GSWExtensionsGSW.framework \
	GSWDatabase

#GSWAdaptors

-include Makefile.preamble

include $(GNUSTEP_MAKEFILES)/aggregate.make

-include Makefile.postamble

