#	Makefile for Netscape (NSAPI) GNUstepWeb module
#   Copyright (C) 1999 Free Software Foundation, Inc.
#   
#   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
#   Date: 		Jully 1999
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

#	The result of this is a libgsweb.so

PLATFORM_OS=solaris
SRCROOT = ..
DSTROOT = .
SERVERAPI = netscape
OBJROOT = ../$(SERVERAPI)


#include $(MAKEFILEPATH)/pb_makefiles/platform.make

ADAPTOR = $(DSTROOT)/libgsweb.so

#Not Used yet
LOADBALANCING = roundrobin
ADAPTORLIB = $(OBJROOT)/libAdaptor.a
COMMON = $(SRCROOT)/common


#NS Root directory
#NS_ROOT = /netscape/suitespot
NS_ROOT=/netscape/enterprise/ns-home/nsapi
NETSCAPELIB = $(NS_ROOT)/lib
NETSCAPE_VERSION = Netscape_3

#
#	any additional macros for this Server API
#
INCLUDE = -I$(COMMON) -I$(NS_ROOT)/include -I/usr/local/include/

#-DDEBUG_NETSCAPE_GUTS
APIDEFINES =  -DNetscape -D$(NETSCAPE_VERSION) -DREENTRANT -DNET_SSL -DSW_THREADS -DXP_UNIX

ifeq "solaris" "$(PLATFORM_OS)"
CFLAGS = -O2 $(RC_CFLAGS) $(INCLUDE) -D$(SERVERAPI) $(APIDEFINES) -DSOLARIS
else
CFLAGS = -O2 $(RC_CFLAGS) $(INCLUDE) -D$(SERVERAPI) $(APIDEFINES)
endif

TRANSPORT = nssocket

all:: $(ADAPTOR)

include $(COMMON)/common.make

OFILES = $(OBJROOT)/gsweb.o


ifeq "solaris" "$(PLATFORM_OS)"
$(ADAPTOR):: $(OFILES) $(ADAPTORLIB)
	ld -G $(OFILES) $(ADAPTORLIB) $(OTHER_LDFLAGS) -lnsl -lsocket -L/usr/local/lib -lPropList -o $(ADAPTOR)    
else
$(ADAPTOR):: $(OFILES) $(ADAPTORLIB)
	$(CC) -dll $(LDFLAGS) $(OTHER_LDFLAGS) -L$(NETSCAPELIB) -lns-httpd35 -L/usr/local/lib -lPropList -o $(ADAPTOR) \
	$(OFILES) $(ADAPTORLIB)  -Xlinker /DEF:$(DEFFILE)
endif

install:	$(ADAPTOR)
	mv $(ADAPTOR) $(DSTROOT)


clean:
	rm -f $(COMMONOBJS) $(ADAPTORLIB) $(OFILES) $(ADAPTOR) \
	libgsweb.lib core


$(OBJROOT)/gsweb.o:	$(SRCROOT)/$(SERVERAPI)/gsweb.c
	$(CC) $(CFLAGS) -c -o $*.o $<

