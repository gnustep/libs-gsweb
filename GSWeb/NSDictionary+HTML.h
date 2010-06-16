/** NSDictionary+HTML.h - <title>GSWeb: NSString / HTML</title>

   Copyright (C) 2005-2006 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de> http://www.turbocat.de/
   Date: Jan 2006
   
   $Revision: 1.5 $
   $Date: 2005/03/10 16:10:03 $

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

// $Id: NSString+HTML.h,v 1.5 2005/03/10 16:10:03 dwetzel Exp $

#ifndef _NSDictionary_HTML_h__
#define _NSDictionary_HTML_h__


@interface NSDictionary (HTML)
- (NSString*) encodeAsCGIFormValues;
- (NSString*) encodeAsCGIFormValuesEscapeAmpersand:(BOOL) doEscapeAmpersand;

@end

#endif //_NSDictionary_HTML_h__
