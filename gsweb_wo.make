#
#   gsweb_wo.make
#
#   Makefile flags and configs to build with the gsweb library
#   using WO-Names
#
#   Copyright (C) 2002 Free Software Foundation, Inc.
#
#   Author: David Ayers <d.ayers@inode.at>
#   Based on code originally in the gnustep make package
#
#   This file is part of the GNUstep Base Library.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

ifeq ($(GSWEB_WO_MAKE_LOADED),)
GSWEB_WO_MAKE_LOADED=yes

GSW_NAMES=wo
include $(GNUSTEP_MAKEFILES)/Auxiliary/gsweb.make

endif # GSWEB_WO_MAKE_LOADED

