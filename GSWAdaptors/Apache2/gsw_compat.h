/*
   Copyright (C) 2007-2008 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de>
   Based on Apache2 Sample Module
   
   This file is part of the GNUstep Web Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#ifndef GSW_COMPAT_H
#define GSW_COMPAT_H

/* Compatibility shims for older APR / Apache releases.  Include this AFTER
 * gsw_private.h (it relies on the Apache and APR headers being in scope);
 * including it here keeps the order correct for every caller.
 *
 * Only include this from a source file that actually needs one of the
 * shims: the apr_parse_int64() fallback has internal linkage, so an
 * unnecessary inclusion would produce an unused-function warning under
 * -Wall.
 */
#include "gsw_private.h"

#if !defined(OS2) && !defined(WIN32) && !defined(BEOS) && !defined(NETWARE)
#include "unixd.h"
#define MOD_EXIPC_SET_MUTEX_PERMS /* XXX Apache should define something */
#endif

/*
 * apr_parse_int64() was added in APR 1.3.  On older APR installations
 * (e.g. some FreeBSD ports) it is not declared, which produces an
 * implicit-declaration warning.  Provide a portable fallback that
 * matches the same calling convention:
 *
 *   apr_status_t apr_parse_int64(apr_int64_t *val, const char *str,
 *                                int base, char **end);
 *
 * The fallback uses strtoll() and sets *end to point past the last
 * consumed digit, or to the first non-digit if the string is empty.
 *
 * APR_VERSION_MAJOR/MINOR arrive via the APR headers that gsw_private.h
 * already includes, exactly as they did in the original single-file module.
 */
#if (APR_VERSION_MAJOR < 1) || \
    ((APR_VERSION_MAJOR == 1) && (APR_VERSION_MINOR < 3))
static apr_status_t apr_parse_int64(apr_int64_t *val, const char *str,
                                    int base, char **end)
{
  char *s = (char *) str;
  char *e;
  long long v;

  if (s == NULL || *s == '\0') {
    if (end) *end = s;
    return APR_ENOENT;
  }

  v = strtoll(s, &e, base);
  if (e == s) {
    /* no digits consumed */
    if (end) *end = s;
    return APR_ENOENT;
  }

  if (v < INT64_MIN || v > INT64_MAX) {
    if (end) *end = e;
    return APR_ENOENT;
  }

  *val = (apr_int64_t) v;
  if (end) *end = e;
  return APR_SUCCESS;
}
#endif

/* unixd_set_global_mutex_perms changed name to ap_unixd_set_global_mutex_perms
 * in Apache 2.4. This function provides a wrapper with the new name for old
 * versions.
 */
#ifdef AP_NEED_SET_MUTEX_PERMS
#if (AP_SERVER_MAJORVERSION_NUMBER == 2) && (AP_SERVER_MINORVERSION_NUMBER < 4)
static inline apr_status_t ap_unixd_set_global_mutex_perms(apr_global_mutex_t *gmutex) {
    return unixd_set_global_mutex_perms(gmutex);
}
#endif
#endif

#endif /* GSW_COMPAT_H */
