#	Makefile for Apache GNUstepWeb module
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

#	The result of this is mod_gsweb.so.
#       Newt, run
#	       apxs -i -a -n gsweb mod_gsweb.so
#

#Solaris, Linux, FreeBSD

OSNAME := "$(shell uname)"
APXS := "$(shell which apxs)"

ifeq ("",$(strip $(APXS)))
	ifeq ("FreeBSD",$(strip $(OSNAME)))
		APXS = /usr/local/sbin/apxs
	else
		APXS = /usr/apache/sbin/apxs
	endif
else
	ifneq (,$(findstring no apxs,$(APXS)))
		APXS = "/usr/apache/sbin/apxs"
	endif
endif

APACHEHEADERS := -I/usr/apache/include -I/usr/include/apache -I/usr/local/include/apache -I/usr/lib/apache/include -I/usr/local/include

APXS := $(APXS) -l PropList -L/usr/local/lib

SRCROOT = ..
DSTROOT = .
OBJROOT = .

# Directory
SERVERAPI = Apache

ADAPTOR = $(DSTROOT)/mod_gsweb.so

LOADBALANCING = roundrobin
ADAPTORLIB = $(OBJROOT)/libAdaptor.a
COMMON = $(SRCROOT)/common

INCLUDE = -I$(COMMON) $(APACHEHEADERS)

CFLAGS = -O2 $(RC_CFLAGS) $(INCLUDE) -D$(SERVERAPI) -DREENTRANT -DEAPI

all:: $(ADAPTOR)

include $(COMMON)/common.make

OFILES = $(COMMONOBJS) $(OBJROOT)/mod_gsweb.o

install: $(ADAPTOR)
	-cp -f $(ADAPTOR) $(DSTROOT)

$(ADAPTOR):: $(OFILES)
	$(APXS) -c $(OTHER_LDFLAGS) -o $@ $(OFILES)

$(OBJROOT)/mod_gsweb.o: $(SRCROOT)/$(SERVERAPI)/mod_gsweb.c
	$(CC) $(CFLAGS) -c -o $*.o $<

clean:
	rm -f $(COMMONOBJS) $(OFILES) $(ADAPTOR) $(ADAPTORLIB) core
