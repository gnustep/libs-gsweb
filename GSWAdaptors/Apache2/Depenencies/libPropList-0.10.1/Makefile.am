
AUTOMAKE_OPTIONS = no-dependencies

lib_LTLIBRARIES = libPropList.la

#SUBDIRS= . gsdd defaults

include_HEADERS = proplist.h

EXTRA_DIST = proplist_y.h types.c

DISTCLEANFILES = proplist.c proplist_y.c

INCLUDES = -DDAEMON_PATH=\"${bindir}/gsdd\"

libPropList_la_SOURCES = 	\
	comparing.c		\
	plconf.h		\
	daemon.c		\
	filehandling.c		\
	getting.c		\
	modifying.c		\
	proplist.h		\
	proplistP.h		\
	memhandling.c		\
	util.c			\
	proplist_y.y		\
	proplist.l		\
	util.h


libPropList_la_LDFLAGS = -version-info 2:2:2

YACC = @YACC@ -d

BUILT_SOURCES = proplist_y.c proplist_y.h proplist.c

