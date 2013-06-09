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

CFLAGS = -O2 $(RC_CFLAGS) $(INCLUDE) -DCGI 

all:: $(ADAPTORLIB)

include $(COMMON)/common.make

install:	$(ADAPTORLIB)
	mv $(ADAPTORLIB) $(DSTROOT)

clean:
	rm -f $(COMMONOBJS) $(ADAPTORLIB) core


