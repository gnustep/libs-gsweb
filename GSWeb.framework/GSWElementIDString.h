/** GSWElementIDString.h - <title>GSWeb: Class GSWElementIDString</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
      
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

#ifndef _GSWElementIDString_h__
	#define _GSWElementIDString_h__


//====================================================================
@interface GSWElementIDString : NSMutableString
{
  NSMutableString* _string;
};

-(id)init;
-(id)initWithCharactersNoCopy:(unichar*)chars
                       length:(unsigned)length
                 freeWhenDone:(BOOL)flag;

-(id)initWithCStringNoCopy:(char*)byteString
                    length:(unsigned)length
              freeWhenDone:(BOOL)flag;
-(id)initWithCapacity:(unsigned)capacity;
-(unsigned)length;
-(unichar)characterAtIndex:(unsigned)index;
-(void)replaceCharactersInRange:(NSRange)range 
		       withString:(NSString*)aString;
-(BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding;
-(void)dealloc;
-(void)getCString:(char*)buffer
        maxLength:(unsigned int)maxLength
            range:(NSRange)aRange
   remainingRange:(NSRange *)leftoverRange;
-(void)getCString:(char*)buffer
        maxLength:(unsigned int)maxLength;
-(void)getCString:(char *)buffer; 
-(id)initWithCoder:(NSCoder*)decoder;
-(void)encodeWithCoder:(NSCoder*)encoder;
-(id)copyWithZone:(NSZone *)zone; 
-(const char*)cString;
-(unsigned int)cStringLength;
-(BOOL)isSearchOverForSenderID:(NSString*)senderID;
@end

//====================================================================

@interface GSWElementIDString (GSWElementIDStringGSW)
-(void)deleteAllElementIDComponents;
-(void)deleteLastElementIDComponent;
-(void)incrementLastElementIDComponent;
-(void)appendZeroElementIDComponent;
-(void)appendElementIDComponent:(id)_element;
-(NSString*)parentElementIDString;//NDFN
#ifndef NDEBBUG
-(int)elementsNb;
#endif
@end

#endif //_GSWElementIDString_h__


