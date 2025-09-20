/** GSWActionURL.h - <title>GSWeb: Class GSWActionURL</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.

   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Sept 1999

   $Revision$
   $Date$

   This file is part of the GNUstep Web Library.

   <license>
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
   </license>
**/

// $Id$

#ifndef _GSWActionURL_h__
	#define _GSWActionURL_h__

/**
 * GSWActionURL is a specialized hyperlink component designed for creating
 * URLs that invoke direct actions in GSWeb applications. It extends
 * GSWHyperlink to provide specific functionality for generating links
 * that bypass the typical component-based request handling and instead
 * call action methods directly. This makes it ideal for creating
 * bookmarkable URLs and RESTful interfaces where stateless operations
 * are preferred.
 */
@interface GSWActionURL: GSWHyperlink
@end

#endif // _GSWActionURL_h__
