/** NSString+Trimming.h - <title>GSWeb: Class NSString with Trimming </title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        Jan 1999
   
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

#ifndef _NSString_Trimming_h__
#define _NSString_Trimming_h__

//====================================================================
@interface NSString (SBString)
-(BOOL)isANumber;
-(BOOL)isAFloatNumber;
-(BOOL)isAnIntegerNumber;
#ifdef LONG_LONG_MAX
-(BOOL)isAnIntegerNumberWithMin:(long long)min
                            max:(long long)max;
#else
-(BOOL)isAnIntegerNumberWithMin:(long)min
                            max:(long)max;
#endif
-(BOOL)isAnUnsignedIntegerNumber;
#ifdef LONG_LONG_MAX
-(BOOL)isAnUnsignedIntegerNumberWithMax:(unsigned long long)max;
#else
-(BOOL)isAnUnsignedIntegerNumberWithMax:(unsigned long)max;
#endif
-(BOOL)isStartingWithNumber;
-(long)longValue;
-(unsigned long)ulongValue;
-(long long)longLongValue;

@end

//====================================================================
@interface NSString (UniqueIdString)
+(NSString*)stringUniqueIdWithLength:(int)length;
@end

//====================================================================
@interface NSString (stringWithObject)
+(NSString*)stringWithObject:(id)object;
@end


//====================================================================
@interface NSString (uniqueFileName)
+(NSString*)stringForUniqueFilenameInDirectory:(NSString*)directory
                                    withPrefix:(NSString*)prefix
                                    withSuffix:(NSString*)suffix;
@end

//====================================================================
@interface NSString (Qutotes)
-(BOOL)hasPrefix:(NSString*)prefix
       andSuffix:(NSString*)suffix;
-(NSString*)stringWithoutPrefix:(NSString*)prefix
                      andSuffix:(NSString*)suffix;
-(BOOL)isQuotedWith:(NSString*)quote;
-(NSString*)stringWithoutQuote:(NSString*)quote;
@end

//====================================================================
@interface NSMutableString (Qutotes)
-(void)removePrefix:(NSString*)prefix
          andSuffix:(NSString*)suffix;
-(void)removeQuote:(NSString*)quote;
@end

#endif //_NSString_Trimming_h__
