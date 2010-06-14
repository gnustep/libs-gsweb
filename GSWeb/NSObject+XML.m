/** NSObject+XML.m - <title>GSWeb: NSObject+XML</title>

   Copyright (C) 2010 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de>
   Date: Feb 2010
   
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

#include "NSObject+XML.h"
#include <Foundation/NSString.h>
#include <Foundation/NSException.h>
#include <Foundation/NSEnumerator.h>


@implementation NSObject (GSWXML)


/*
 <element type="NSString">atlantis.local: wotaskd may not be accessed through a Web server - Access Denied</element>
 
 */

- (NSString*) encodeXMLPrefix
{
  return [NSString stringWithFormat:@"<element type=\"%@\">\n", [self className]];
}

- (NSString*) encodeXMLSuffix
{
  return @"</element>\n";
}


- (NSString*) encodeXML
{
  NSMutableString * contentStr = [NSMutableString string];
  
  [contentStr appendString:[self encodeXMLPrefix]];
  
  [contentStr appendString:[NSString stringWithFormat:@"%@", self]];

  [contentStr appendString:[self encodeXMLSuffix]];

  return contentStr;
}

@end

@implementation NSArray (GSWXML)


/*
 <errorResponse type="NSArray">
 <element type="NSString">atlantis.local: wotaskd may not be accessed through a Web server - Access Denied</element>
 </errorResponse>
 
 */


- (NSString*) encodeXMLRootObjectForKey:(NSString*) key
{
  NSString        * prefixStr = nil;
  NSString        * suffixStr = nil;
  NSEnumerator    * myEnumer = [self objectEnumerator];
  NSMutableString * contentStr = [NSMutableString string];
  id               currentObj = nil;
  
  
  if (!key) {
    [NSException raise: NSInvalidArgumentException
                format: @"key is missing"];
  }
  
  prefixStr = [NSString stringWithFormat:@"<%@ type=\"%@\">\n", key, [self className]];
  [contentStr appendString:prefixStr];
  
  suffixStr = [NSString stringWithFormat:@"</%@>\n", key];
  
  
  while ((currentObj = [myEnumer nextObject])) {
    [contentStr appendString:[currentObj encodeXML]];
  }
  
  [contentStr appendString:suffixStr];
  
  return contentStr;
}

@end

@implementation NSDictionary (GSWXML)


/*
 <monitorResponse type="NSDictionary">
 <errorResponse type="NSArray">
 <element type="NSString">atlantis.local: wotaskd may not be accessed through a Web server - Access Denied</element>
 </errorResponse>
 </monitorResponse>
 
 */


- (NSString*) encodeXMLRootObjectForKey:(NSString*) key
{
  NSString        * prefixStr = nil;
  NSString        * suffixStr = nil;
  NSEnumerator    * keyEnumer = [self keyEnumerator];
  NSMutableString * contentStr = [NSMutableString string];
  NSString        * currentKey = nil;
  
  
  if (!key) {
    [NSException raise: NSInvalidArgumentException
                format: @"key is missing"];
  }
  
  prefixStr = [NSString stringWithFormat:@"<%@ type=\"%@\">\n", key, [self className]];
  [contentStr appendString:prefixStr];
  
  suffixStr = [NSString stringWithFormat:@"</%@>\n", key];
  
  
  while ((currentKey = [keyEnumer nextObject])) {
    [contentStr appendString:[[self objectForKey:currentKey] encodeXMLRootObjectForKey:currentKey]];
  }
  
  [contentStr appendString:suffixStr];
  
  return contentStr;
}

@end

