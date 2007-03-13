# configure.ac for GNUstepWeb library
# Process this file with autoconf to produce a configure script.
#
# Copyright (C) 2005 Free Software Foundation, Inc.
#
# Author:  David Ayers <d.ayers@inode.at>
# Author:  David Wetzel <dave@turbocat.de> 
#
#
# This file is part of the GNUstepWeb library
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any
# later version.
#
# This library is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with program; see the file COPYING. If not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA. 
#
AC_INIT
AC_CONFIG_SRCDIR([mod_gsweb.c])
AC_CANONICAL_TARGET([])

BIN_PATH=$PATH:/usr/local/sbin:/usr/apache/sbin:/usr/sbin:/usr/pkg/sbin

case "$target_os" in
  freebsd* | openbsd* )
              CPPFLAGS="$CPPFLAGS -I/usr/local/include"
              LDFLAGS="$LDFLAGS -L/usr/local/lib";;
  netbsd*)    CPPFLAGS="$CPPFLAGS -I/usr/pkg/include"
              LDFLAGS="$LDFLAGS -Wl,-R/usr/pkg/lib -L/usr/pkg/lib";;
esac

AC_ARG_WITH(apxs,
	[[  --with-apxs=[FILE|PATH] Path to apxs tool. Default is apxs.]],
	APXS_OPT="$withval", APXS_OPT=default)

AC_ARG_WITH(apr-config,
	[[  --with-apr-config=[FILE|PATH] Path to apr-config tool. Default is apr-config.]],
	APRCONFIG_NAME="$withval", APRCONFIG_NAME=apr-config)

# Set APXS_NAME
# Default to apxs but remeber in APXS_OPT that no option was given.
if test x$APXS_OPT = xdefault ; then
  APXS_NAME=apxs
else
  APXS_NAME="$APXS_OPT"
fi

# If the user specified an executable, use it.  Otherwise search
# for a usable apxs executable.
if test -x "$APXS_NAME"; then
  APXS=APXS_NAME
else
  AC_PATH_PROG(APXS, "$APXS_NAME", "no", $BIN_PATH)
  if test x${APXS_OPT} = xdefault ; then
    if test x${APXS} = xno -o x${APXS} = x ; then
     AC_PATH_PROG(APXS2, apxs2, "no", $BIN_PATH)
     APXS="$APXS2"
    fi
  fi
fi

if test x${APXS} = xno -o x${APXS} = x ; then
   AC_MSG_ERROR([ apxs tool not found.  Check path or use --with-apxs and specify a full path to the apxs tool.  ])
fi

# This is currently testing for SERVERAPI which
# currently should be Apache for 1.3 and Apache2 for 2
# In the future it would be better to test for
# the actual features which we are using and
# generate a config.h with the correct defines.

AC_ARG_WITH(server-api,
	[[  --with-server-api=[Apache|Apache2] Specify SERVERAPI explicitly.]],
	server_api="$withval", server_api="no")
if test x${server_api} != xno ; then
   SERVERAPI="${server_api}"
else
   APXS_TARGET=`$APXS -q TARGET`
   AC_PATH_PROG(APACHE, "$APXS_TARGET", "no", $BIN_PATH)
   if ( $APACHE -v | grep "Apache@<:@^@<:@:space:@:>@@:>@*/1." > /dev/null 2>&1) ; then
     SERVERAPI=Apache
   elif ( $APACHE -v | grep "Apache@<:@^@<:@:space:@:>@@:>@*/2." > /dev/null 2>&1) ; then
     SERVERAPI=Apache2
   else
     SERVERAPI=unknown
   fi
fi
AC_MSG_CHECKING(server API)
AC_MSG_RESULT($SERVERAPI)

if test x${SERVERAPI} = xunknown ; then
   AC_MSG_ERROR([ Could not determine Apache API version.  Use --with-server-api and specify either Apache or Apache2.  ])
fi

if test x${SERVERAPI} == xApache2 ; then
   AC_PATH_PROG(APRCONFIG, "$APRCONFIG_NAME", "no", $BIN_PATH)
fi

CONFIG_CPPFLAGS="$CPPFLAGS"
CONFIG_LDFLAGS="$LDFLAGS"

AC_SUBST(APXS)
AC_SUBST(APRCONFIG)
AC_SUBST(SERVERAPI)
AC_SUBST(CONFIG_CPPFLAGS)
AC_SUBST(CONFIG_LDFLAGS)

AC_CONFIG_FILES([GNUmakefile])
AC_OUTPUT
