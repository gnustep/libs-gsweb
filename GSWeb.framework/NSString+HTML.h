/** NSString+HTML.h - <title>GSWeb: NSString / HTML</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

#ifndef _NSString_HTML_h__
#define _NSString_HTML_h__

//====================================================================
@interface NSString (HTMLString)
-(NSString*)htmlPlus2Space;
-(NSString*)decodeURL;
-(NSString*)encodeURL;
-(NSString*)encodeURLWithValid:(NSString*)valid;
-(NSDictionary*)dictionaryQueryString;
-(NSDictionary*)dictionaryWithSep1:(NSString*)sep1
                          withSep2:(NSString*)sep2
                withOptionUnescape:(BOOL)unescape;
-(NSDictionary*)dictionaryWithSep1:(NSString*)sep1
                          withSep2:(NSString*)sep2
                withOptionUnescape:(BOOL)unescape
                        forceArray:(BOOL)forceArray;
-(BOOL)ismapCoordx:(int*)x
                 y:(int*)y;
-(NSString*)stringByEscapingHTMLString;
-(NSString*)stringByEscapingHTMLAttributeValue;
-(NSString*)stringByConvertingToHTMLEntities;
-(NSString*)stringByConvertingFromHTMLEntities;
-(NSString*)stringByConvertingToHTML;
-(NSString*)stringByConvertingFromHTML;
@end

#endif //_NSString_HTML_h__
