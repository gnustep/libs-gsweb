

#Defaults

#Directories
SRCROOT = ..
DSTROOT = .
OBJROOT = .

#Load Balancing (Not used yet)
LOADBALANCING = random

#Library Name
ADAPTORLIB = $(OBJROOT)/libAdaptor.a


# Common Source Files
COMMON = $(SRCROOT)/common
INCLUDE = -I$(COMMON)

ifeq "solaris" "$(PLATFORM_OS)"
CFLAGS = -O2 $(RC_CFLAGS) $(INCLUDE) -DCGI -DSOLARIS -DNEEDS_HSTRERR
else
CFLAGS = -O2 $(RC_CFLAGS) $(INCLUDE) -DCGI 
endif


all:: $(ADAPTORLIB)

include $(COMMON)/common.make

install:	$(ADAPTORLIB)
	mv $(ADAPTORLIB) $(DSTROOT)

clean:
	rm -f $(COMMONOBJS) $(ADAPTORLIB) core


