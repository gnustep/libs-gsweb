/** GSWElementIDString.m - <title>GSWeb: Class GSWElementIDString</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>


//====================================================================
@implementation GSWElementIDString

+ (id) allocWithZone: (NSZone*)z
{
  if (self == [GSWElementIDString class])
    {
      return NSAllocateObject ([GSWElementIDString class], 0, z);
    }
  else
    {
      return NSAllocateObject (self, 0, z);
    }
}

- (id) initWithCharactersNoCopy: (unichar*)chars
			 length: (unsigned)length
		   freeWhenDone: (BOOL)flag
{
  LOGObjectFnStart();
  if (!_string)
    _string=[[NSMutableString alloc] initWithCharactersNoCopy:chars
                                     length:length
                                     freeWhenDone:flag];
  LOGObjectFnStop();
  return self;
};

- (id) initWithCStringNoCopy: (char*)byteString
		      length: (unsigned)length
		freeWhenDone: (BOOL)flag
{
  LOGObjectFnStart();
  if (!_string)
    _string=[[NSMutableString alloc] initWithCStringNoCopy:byteString
                                     length:length
                                     freeWhenDone:flag];
  LOGObjectFnStop();
  return self;
};

- (id) initWithCapacity: (unsigned)capacity
{
  LOGObjectFnStart();
  if (!_string)
    _string=[[NSMutableString alloc] initWithCapacity:capacity];
  LOGObjectFnStop();
  return self;
};

- (unsigned) length
{
  return [_string length];
};

- (unichar) characterAtIndex: (unsigned)index
{
  NSAssert(_string,@"No String");
  return [_string characterAtIndex:index];
};

- (void) replaceCharactersInRange: (NSRange)range 
		       withString: (NSString*)aString
{
  LOGObjectFnStart();
  NSAssert(_string,@"No String");
  [_string replaceCharactersInRange:range
           withString:aString];
  LOGObjectFnStop();
};

-(BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding
{
  return [_string canBeConvertedToEncoding:encoding];
};

-(void)dealloc
{
  LOGObjectFnStart();
  GSWLogAssertGood(self);
  GSWLogAssertGood(_string);
  GSWLogMemC("_string deallocate");
  DESTROY(_string);
  GSWLogMemC("_string deallocated");
  [super dealloc];
  GSWLogMemC("GSWElementIDString end of dealloc");
};

-(void)getCString:(char*)buffer
        maxLength:(unsigned int)maxLength
            range:(NSRange)aRange
   remainingRange:(NSRange *)leftoverRange
{
  NSAssert(_string,@"No String");
  return [_string getCString:buffer
                  maxLength:maxLength
                  range:aRange
                  remainingRange:leftoverRange];
};

-(void)getCString:(char*)buffer
        maxLength:(unsigned int)maxLength;
{
  NSAssert(_string,@"No String");
  return [_string getCString:buffer
                  maxLength:maxLength];
};

-(void)getCString:(char *)buffer;
{
  NSAssert(_string,@"No String");
  return [_string getCString:buffer];
};

-(id)initWithCoder:(NSCoder*)decoder
{
  DESTROY(_string);
  [decoder decodeValueOfObjCType:@encode(id)
          at:&_string];
  return self;
};

-(void)encodeWithCoder:(NSCoder*)encoder
{
  NSAssert(_string,@"No String");
  [encoder encodeValueOfObjCType:@encode(id)
          at:&_string];
};

-(const char*)cString
{
  return [_string cString];
};

-(unsigned int)cStringLength
{
  return  [_string cStringLength];
};


//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  return [self mutableCopyWithZone:zone];
};

//--------------------------------------------------------------------
-(id)mutableCopyWithZone:(NSZone*)zone
{
  GSWElementIDString* obj = [[[self class] alloc] initWithString:_string];
  return obj;
};

-(BOOL)isSearchOverForSenderID:(NSString*)senderID
{
  BOOL over=NO;
  if (senderID == nil)
    [NSException raise:NSInvalidArgumentException
                 format:@"compare with nil"];
  else
    {
      BOOL finished=NO;
      NSCharacterSet* nonNumericSet=[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
      NSArray* selfElements=[self componentsSeparatedByString:@"."];
      NSArray* senderIDElements=[senderID componentsSeparatedByString:@"."];
      int i=0;
      int selfElementsCount=[selfElements count];
      int senderIDElementsCount=[senderIDElements count];
      int count=min(selfElementsCount,senderIDElementsCount);
      for(i=0;i<count && !over && !finished;i++)
        {
          NSString* selfElement=[selfElements objectAtIndex:i];
          NSString* senderIDElement=[senderIDElements objectAtIndex:i];
          BOOL selfElementIsNumeric=[selfElement rangeOfCharacterFromSet:nonNumericSet].length==0;
          BOOL selfAStringIsNumeric=[senderIDElement rangeOfCharacterFromSet:nonNumericSet].length==0;
          if (selfElementIsNumeric && selfAStringIsNumeric) //Numeric comparison
            {
              int selfIntValue=[selfElement intValue];
              int senderIDIntValue=[senderIDElement intValue];
              if (selfIntValue>senderIDIntValue)
                over=YES;
            }
          else if (!selfElementIsNumeric && !selfAStringIsNumeric)//string comparison
            {
              if ([selfElement compare:senderIDElement]==NSOrderedDescending)
                over=YES;
            }
          else
            finished=YES;
        };
/*      if (!over && !finished)
        {
          if (selfElementsCount>senderIDElementsCount)
            over=YES;
        };
*/
    };
  return over;
}
/*
{  
  NSComparisonResult result=NSOrderedSame;
  if (aString == nil)
    [NSException raise:NSInvalidArgumentException
                 format:@"compare with nil"];
  else if (mask!=0) //TODO
    [NSException raise:NSInvalidArgumentException
                 format:@"no options are allowed in GSWElementIDString compare"];
  else if (aRange.location!=0)
    [NSException raise:NSInvalidArgumentException
                 format:@"GSWElementIDString compare only on full string (range.location=%d instead of 0)",
                 aRange.location];
  else if (aRange.length!=[self length])
    [NSException raise:NSInvalidArgumentException
                 format:@"GSWElementIDString compare only on full string (range.length=%d instead of %d)",
                 aRange.length,
                 [self length]];
  else
    {
      NSCharacterSet* nonNumericSet=[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
      NSArray* selfElements=[self componentsSeparatedByString:@"."];
      NSArray* aStringElements=[aString componentsSeparatedByString:@"."];
      int i=0;
      int selfElementsCount=[selfElements count];
      int aStringElementsCount=[aStringElements count];
      int count=min(selfElementsCount,aStringElementsCount);
      for(i=0;i<count && result==NSOrderedSame;i++)
        {
          NSString* selfElement=[selfElements objectAtIndex:i];
          NSString* aStringElement=[aStringElements objectAtIndex:i];
          BOOL selfElementIsNumeric=[selfElement rangeOfCharacterFromSet:nonNumericSet].length==0;
          BOOL selfAStringIsNumeric=[aStringElement rangeOfCharacterFromSet:nonNumericSet].length==0;
          if (selfElementIsNumeric && selfAStringIsNumeric) //Numeric comparison
            {
              int selfIntValue=[selfElement intValue];
              int aStringIntValue=[aStringElement intValue];
              result=(selfIntValue==aStringIntValue ? 0 : (selfIntValue>aStringIntValue ? NSOrderedDescending : NSOrderedAscending));
            }
          else if (selfElementIsNumeric) //we consider strictly num < string
            result=NSOrderedAscending;
          else if (selfAStringIsNumeric) //we consider strictly num < string
            result=NSOrderedDescending;
          else //string comparison
            result=[selfElement compare:aStringElement];
        };
      if (result==NSOrderedSame)
        {
          if (selfElementsCount<aStringElementsCount)
            result=NSOrderedAscending;
          else if (selfElementsCount>aStringElementsCount)
            result=NSOrderedDescending;
        };
    };
  return result;
}

*/

@end

//====================================================================
@implementation GSWElementIDString  (GSWElementIDStringGSW)

//--------------------------------------------------------------------
-(void)deleteAllElementIDComponents
{
  [self setString:nil];
};

//--------------------------------------------------------------------
-(void)deleteLastElementIDComponent
{
  NSArray* ids=nil;
  LOGObjectFnStart();
  if ([self length]>0)
    {
      ids=[self componentsSeparatedByString:@"."];
      NSAssert([ids count]>0,@"PROBLEM");
      if ([ids count]==1)
        [self setString:@""];
      else
        {
          [self setString:[[ids subarrayWithRange:NSMakeRange(0,[ids count]-1)]
                            componentsJoinedByString:@"."]];
        };
    }
  else
    {
      ExceptionRaise0(@"GSWElementIDString",@"Can't deleteLastElementIDComponent of an empty ElementID String");
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)incrementLastElementIDComponent
{
  NSArray* ids=nil;
  LOGObjectFnStart();
  ids=[self componentsSeparatedByString:@"."];
  if (ids && [ids count]>0)
    {
      NSString* _last=[ids lastObject];
      NSString* _new=nil;
      _last=[NSString  stringWithFormat:@"%d",([_last intValue]+1)];	  
      if ([ids count]>1)
        _new=[[[ids subarrayWithRange:NSMakeRange(0,[ids count]-1)]
                componentsJoinedByString:@"."]
               stringByAppendingFormat:@".%@",_last];
      else
        _new=_last;
      [self setString:_new];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendZeroElementIDComponent
{
  LOGObjectFnStart();
  if ([self length]>0)
    [self appendString:@".0"];
  else
    [self setString:@"0"];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendElementIDComponent:(id)_element
{
  LOGObjectFnStart();
  if (self && [self length]>0)
    [self appendFormat:@".%@",_element];
  else
    [self setString:_element];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)parentElementIDString
{
  GSWElementIDString* _id=[[self copy] autorelease];
  if ([self length]>0)
    [_id deleteLastElementIDComponent];
  return _id;
};
//--------------------------------------------------------------------
#ifndef NDEBBUG
-(int)elementsNb
{
  if ([self length]==0)
    return 0;
  else
    return [[self componentsSeparatedByString:@"."] count];
};
#endif

@end
