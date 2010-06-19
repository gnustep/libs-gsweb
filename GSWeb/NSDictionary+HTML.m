/** NSDictionary+HTML.m - <title>GSWeb: NSDictionary+HTML</title>

   Copyright (C) 2005-2006 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de>
   Date: Jan 2006
   
   $Revision: 1.17 $
   $Date: 2004/12/31 14:33:16 $

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


#include "config.h"

RCS_ID("$Id: GSWDynamicGroup.m,v 1.17 2004/12/31 14:33:16 mguesdon Exp $")

#include "GSWeb.h"
#include <GNUstepBase/GSMime.h>


//====================================================================

//static Class NSDictionaryClass = Nil;
//static Class NSArrayClass = Nil;

@implementation NSDictionary (GSWHTML)

/* mybe we need that later.
static inline void initClasses(void)
{
  if (NSDictionaryClass == Nil) {
    NSDictionaryClass = [NSDictionary class];
    NSArrayClass = [NSArray class];
  }
}
*/
static NSString* _encodeObjectAndKeyUsingEncoding(id obj, id key, NSStringEncoding encoding)
{
  NSString       * codeStr = nil;
  NSString       * strVal = nil;

  if (obj != nil) {  
    strVal = obj;                   // stringValue??
    codeStr = [strVal encodeURL];       // give encoding to method?
    codeStr = [key stringByAppendingFormat:@"=%@", codeStr];
  }

  return codeStr;
}

static NSMutableArray* _encodeAsCGIFormValuesInDictionaryUsingEncoding(NSDictionary* dict, NSStringEncoding encoding)
{
  NSMutableArray * array = [NSMutableArray arrayWithCapacity:[dict count]];
  NSEnumerator   * enumer = [dict keyEnumerator];
  NSString       * key = nil;
  NSString       * subCodeStr = nil;
  NSString       * codeStr = nil;
  id               obj = nil;

  while ((key = [enumer nextObject])) {
    obj = [dict objectForKey:key];
    codeStr = [key encodeURL];       // give encoding to method?
    if ((subCodeStr = _encodeObjectAndKeyUsingEncoding(obj, codeStr, encoding))) {      
      [array addObject: subCodeStr];
    }
  }

  return array;
}

// encodeAsCGIFormValues
- (NSString*) encodeAsCGIFormValuesEscapeAmpersand:(BOOL) doEscapeAmpersand
{
  NSMutableArray      * stringArray = nil;
  NSString            * encodingStr = [self objectForKey:@"WOURLEncoding"];
  NSStringEncoding      encoding = NSUTF8StringEncoding;

  if (encodingStr) {
    
    encoding = [GSMimeDocument encodingFromCharset:encodingStr];
  }

  stringArray = _encodeAsCGIFormValuesInDictionaryUsingEncoding(self, encoding);

  if (doEscapeAmpersand) {
    return [stringArray componentsJoinedByString:@"&amp;"];
  }
  
  return [stringArray componentsJoinedByString:@"&"];
}


// encodeAsCGIFormValues
- (NSString*) encodeAsCGIFormValues
{
 // todo set urlEncoding from the WOURLEncoding key in the dict?
  NSStringEncoding urlEncoding = NSUTF8StringEncoding;
  NSMutableArray * array = _encodeAsCGIFormValuesInDictionaryUsingEncoding(self, urlEncoding);
  return [array componentsJoinedByString:@"&"];
}

@end
