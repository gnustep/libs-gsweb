/* NSString+Trimming.h
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
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

// $Id$

#ifndef _NSString_Trimming_h__
#define _NSString_Trimming_h__

//====================================================================
@interface NSString (SBString)
-(BOOL)isANumber;
-(BOOL)isAFloatNumber;
-(BOOL)isAnIntegerNumber;
#ifdef LONG_LONG_MAX
-(BOOL)isAnIntegerNumberWithMin:(long long)min_
							max:(long long)max_;
#else
-(BOOL)isAnIntegerNumberWithMin:(long)min_
							max:(long)max_;
#endif
-(BOOL)isAnUnsignedIntegerNumber;
#ifdef LONG_LONG_MAX
-(BOOL)isAnUnsignedIntegerNumberWithMax:(unsigned long long)max_;
#else
-(BOOL)isAnUnsignedIntegerNumberWithMax:(unsigned long)max_;
#endif
-(BOOL)isStartingWithNumber;
-(long)longValue;
-(unsigned long)ulongValue;
-(long long)longLongValue;

@end

//====================================================================
@interface NSString (UniqueIdString)
+(NSString*)stringUniqueIdWithLength:(int)_lentgh;
@end

//====================================================================
@interface NSString (stringWithObject)
+(NSString*)stringWithObject:(id)object_;
@end


//====================================================================
@interface NSString (uniqueFileName)
+(NSString*)stringForUniqueFilenameInDirectory:(NSString*)directory_
								  withPrefix:(NSString*)prefix_
									withSuffix:(NSString*)suffix_;
@end

//====================================================================
@interface NSString (Qutotes)
-(BOOL)hasPrefix:(NSString*)prefix_
	   andSuffix:(NSString*)suffix_;
-(NSString*)stringWithoutPrefix:(NSString*)prefix_
					  andSuffix:(NSString*)suffix_;
-(BOOL)isQuotedWith:(NSString*)quote_;
-(NSString*)stringWithoutQuote:(NSString*)quote_;
@end

//====================================================================
@interface NSMutableString (Qutotes)
-(void)removePrefix:(NSString*)prefix_
		  andSuffix:(NSString*)suffix_;
-(void)removeQuote:(NSString*)quote_;
@end

#endif //_NSString_Trimming_h__
