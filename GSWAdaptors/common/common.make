#
#   common.make
#
#   Set all of the common environment variables.
#
#   Copyright (C) 1999, 2000 Free Software Foundation, Inc.
#
#   Author:  Manuel Guesdon <mguesdon@sbuilders.com>
#
#   This file is part of the GNUstepWeb Adaptors Makefile Package.
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

COMMONFILES = $(COMMON)/GSWHTTPHeaders.c \
	$(COMMON)/config.c $(COMMON)/GSWConfig.c $(COMMON)/GSWPropList.c \
	$(COMMON)/GSWTemplates.c $(COMMON)/GSWApp.c \
	$(COMMON)/GSWURLUtil.c $(COMMON)/GSWDict.c \
	$(COMMON)/GSWHTTPRequest.c $(COMMON)/GSWHTTPResponse.c \
	$(COMMON)/GSWAppConnectSocket.c $(COMMON)/GSWUtil.c \
	$(COMMON)/GSWAppRequest.c \
	$(COMMON)/GSWLoadBalancing.c $(COMMON)/GSWList.c  \
	$(COMMON)/GSWString.c $(COMMON)/GSWStats.c


COMMONOBJS = $(OBJROOT)/GSWHTTPHeaders.o \
	$(OBJROOT)/config.o $(OBJROOT)/GSWConfig.o $(OBJROOT)/GSWPropList.o \
	$(OBJROOT)/GSWTemplates.o $(OBJROOT)/GSWApp.o \
	$(OBJROOT)/GSWURLUtil.o $(OBJROOT)/GSWDict.o \
	$(OBJROOT)/GSWHTTPRequest.o $(OBJROOT)/GSWHTTPResponse.o \
	$(OBJROOT)/GSWAppConnectSocket.o $(OBJROOT)/GSWUtil.o \
	$(OBJROOT)/GSWAppRequest.o \
	$(OBJROOT)/GSWLoadBalancing.o $(OBJROOT)/GSWList.o \
	$(OBJROOT)/GSWString.o $(COMMON)/GSWStats.o

$(ADAPTORLIB):: $(COMMONOBJS)
#	libtool -static $(ARCH) -o $(ADAPTORLIB) $(COMMONOBJS)
	ar -rc $(ADAPTORLIB) $(COMMONOBJS)
	ranlib $(ADAPTORLIB)


$(OBJROOT)/GSWHTTPHeaders.o: $(COMMON)/GSWHTTPHeaders.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWPropList.o: $(COMMON)/GSWPropList.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWTemplates.o: $(COMMON)/GSWTemplates.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWApp.o: $(COMMON)/GSWApp.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWConfig.o: $(COMMON)/GSWConfig.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWList.o: $(COMMON)/GSWList.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWString.o: $(COMMON)/GSWString.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWLoadBalancing.o: $(COMMON)/GSWLoadBalancing.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWAppRequest.o: $(COMMON)/GSWAppRequest.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWURLUtil.o: $(COMMON)/GSWURLUtil.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWDict.o: $(COMMON)/GSWDict.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWUtil.o: $(COMMON)/GSWUtil.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/config.o: $(COMMON)/config.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWHTTPRequest.o: $(COMMON)/GSWHTTPRequest.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWHTTPResponse.o: $(COMMON)/GSWHTTPResponse.c
	$(CC) $(CFLAGS) -c -o $*.o $<

$(OBJROOT)/GSWAppConnectSocket.o: $(COMMON)/GSWAppConnectSocket.c
	$(CC) $(CFLAGS) -c -o $*.o $<

