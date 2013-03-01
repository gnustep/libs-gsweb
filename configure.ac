# configure.in for GSWeb library
# Process this file with autoconf to produce a configure script.
#
#   Copyright (C) 1993,1994, 1995, 1996, 1997 Free Software Foundation, Inc.
#
#   Written by: Mirko Viviani <mirko.viviani@rccr.cremona.it>
#
#   This file is part of the GSWeb library.
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
#   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA
builtin(include, config/pathxml.m4)dnl

AC_INIT

if test -z "$GNUSTEP_MAKEFILES"; then
  AC_MSG_ERROR([You must run set GNUSTEP_MAKEFILES or run the GNUstep initialization script first!])
fi

AC_CONFIG_HEADER(config.h)

#--------------------------------------------------------------------
# Define default gswnames
#--------------------------------------------------------------------
AC_ARG_WITH(gswnames,
 [  --with-gswnames=NAMESPC Set the default namespace (gsw,wo,all=def)])
AC_MSG_CHECKING(default gswnames)
if test "x$with_gswnames" = "x"; then
  GSWNAMES=all
else
  GSWNAMES=${with_gswnames}
fi
AC_MSG_RESULT($GSWNAMES)
AC_SUBST(GSWNAMES)

#--------------------------------------------------------------------
# Check for GDL2
#--------------------------------------------------------------------
AC_CHECK_FILE($GNUSTEP_MAKEFILES/Auxiliary/gdl2.make, GDL2=yes, GDL2=no)
if test "$GDL2" = yes; then
  AC_DEFINE(HAVE_GDL2)
else
  AC_MSG_WARN(Could not find GNUstep Database Library 2. Will assume a compatible library exists anyway.)
fi
AC_SUBST(GDL2)

#--------------------------------------------------------------------
# Check for zlib
# AC_CHECL_LIB sets HAVE_LIBZ instead of HAVE_ZLIB
#--------------------------------------------------------------------
AC_CHECK_HEADERS(zlib.h)
if test $ac_cv_header_zlib_h = yes; then
  AC_CHECK_LIB(z, gzseek)
fi

#--------------------------------------------------------------------
# Check for libwrap
#--------------------------------------------------------------------
saved_LIBS="$LIBS"
WRAP_LIBS=""
AC_CHECK_LIB(wrap, main, wrap_ok=yes, wrap_ok=no)
if test "$wrap_ok" = yes; then
  LIBS="-lwrap"
  echo -n "checking whether libnsl is needed... "
  AC_TRY_LINK([#include <tcpd.h>
	       int allow_severity, deny_severity;],
	      [struct request_info *request; hosts_access(request);],
	need_nsl=no, need_nsl=yes)
  echo $need_nsl
  if test "$need_nsl" = yes; then
    LIBS="$LIBS -lnsl";
    echo -n "checking whether -lwrap and -lnsl work... "
    AC_TRY_LINK([#include <tcpd.h>
	         int allow_severity, deny_severity;],
	        [struct request_info *request; hosts_access(request);],
	need_nsl=yes,need_nsl=error)
    if test "$need_nsl" = error; then
      echo -n " libwrap seems unusable even with libnsl! :"
      wrap_ok=no
    fi
    echo $need_nsl
  fi

  if test "$wrap_ok" = yes; then
    WRAP_LIBS="$LIBS"
    HAVE_LIBWRAP=1
    AC_DEFINE(HAVE_LIBWRAP)
  fi
fi
AC_SUBST(LIBWRAP,$wrap_ok)
LIBS="$saved_LIBS $WRAP_LIBS"

#--------------------------------------------------------------------
# Check recent libxml for XML parser
#--------------------------------------------------------------------

# Save CFLAGS and LIBS as AM_PATH_XML clobbers these variables regardless
# of the success of the macro.
saved_LIBS="$LIBS"
saved_CFLAGS="$CFLAGS"

AM_PATH_XML(2.3.0, enable_libxml=yes, enable_libxml=no)
if test $enable_libxml = yes; then
  CPPFLAGS="$CPPFLAGS $XML_CFLAGS"
  AUX_INCS="$AUX_INCS $XML_CFLAGS"
  LIBS="$LIBS $XML_LIBS"
  HAVE_LIBXML=1
  AC_DEFINE(HAVE_LIBXML,1,
           [Define if libxml available])
else
  HAVE_LIBXML=0
  # Restore the CFLAGS and LIBS because AM_PATH_XML messes them
  LIBS="$saved_LIBS"
  CFLAGS="$saved_CFLAGS"
fi

#--------------------------------------------------------------------
# Find additional image libs
#--------------------------------------------------------------------
AC_ARG_ENABLE(png,
  [  --disable-png           Disable PNG support],,
  enable_png=yes)

if test $enable_png = yes; then

  PNG_CPPFLAGS="`pkg-config --cflags libpng`"
  CPPFLAGS="$CPPFLAGS $PNG_CPPFLAGS"
  AUX_INCS="$AUX_INCS $PNG_CPPFLAGS"
  AC_CHECK_HEADER(png.h, [], [], [])

  AC_CHECK_LIB(png, png_sig_cmp)
fi

#--------------------------------------------------------------------
# Record the version
#--------------------------------------------------------------------
AC_MSG_CHECKING(for the version of GSWeb we are compiling)
if test -f "Version"; then
  . ./Version
fi
AC_MSG_RESULT($VERSION)
AC_SUBST(VERSION)
AC_SUBST(MAJOR_VERSION)
AC_SUBST(MINOR_VERSION)
AC_SUBST(SUBMINOR_VERSION)
AC_SUBST(GCC_VERSION)

AUX_LIBS="$LIBS"
AC_SUBST(AUX_INCS)
AC_SUBST(AUX_LIBS)

#--------------------------------------------------------------------
# Write the Makefiles
#--------------------------------------------------------------------
AC_CONFIG_FILES([config.mak gsweb.make GSWeb/Makefile.preamble])
AC_OUTPUT
