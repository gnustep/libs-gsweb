/** GSWElementIDString.m - <title>GSWeb: Class GSWElementIDString</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

static NSCharacterSet* nonNumericSet=nil;

//====================================================================
@implementation GSWElementIDString

//--------------------------------------------------------------------
+(void)initialize
{
  if (self==[GSWElementIDString class])
    {
      ASSIGN(nonNumericSet,([[NSCharacterSet decimalDigitCharacterSet] invertedSet]));
    };
};

//--------------------------------------------------------------------
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

//--------------------------------------------------------------------
- (id) initWithCharactersNoCopy: (unichar*)chars
			 length: (unsigned)length
		   freeWhenDone: (BOOL)flag
{
  LOGObjectFnStart();
  if (_string)
    _string=[_string initWithCharactersNoCopy:chars
                     length:length
                     freeWhenDone:flag];
  else
    _string=[[NSMutableString alloc] initWithCharactersNoCopy:chars
                                     length:length
                                     freeWhenDone:flag];
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
- (id) initWithCStringNoCopy: (char*)byteString
		      length: (unsigned)length
		freeWhenDone: (BOOL)flag
{
  LOGObjectFnStart();
  if (_string)
    _string=[_string  initWithCStringNoCopy:byteString
                      length:length
                      freeWhenDone:flag];
  else
    _string=[[NSMutableString alloc] initWithCStringNoCopy:byteString
                                     length:length
                                     freeWhenDone:flag];
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
- (id) initWithCapacity: (unsigned)capacity
{
  LOGObjectFnStart();
  if (_string)
    _string=[_string initWithCapacity:capacity];
  else
    _string=[[NSMutableString alloc] initWithCapacity:capacity];
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
- (unsigned) length
{
  return [_string length];
};

//--------------------------------------------------------------------
- (unichar) characterAtIndex: (unsigned)index
{
  NSAssert(_string,@"No String");
  return [_string characterAtIndex:index];
};

//--------------------------------------------------------------------
- (void) replaceCharactersInRange: (NSRange)range 
		       withString: (NSString*)aString
{
  LOGObjectFnStart();
  NSAssert(_string,@"No String");
  [_string replaceCharactersInRange:range
           withString:aString];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding
{
  return [_string canBeConvertedToEncoding:encoding];
};

//--------------------------------------------------------------------
-(void)dealloc
{
  LOGObjectFnStart();
  GSWLogAssertGood(self);
  GSWLogAssertGood(_string);
  GSWLogMemCF("_string deallocate %p",self);
  DESTROY(_string);
  GSWLogMemCF("_string deallocated %p",self);
  [super dealloc];
  GSWLogMemC("GSWElementIDString end of dealloc");
};

//--------------------------------------------------------------------
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

//--------------------------------------------------------------------
-(void)getCString:(char*)buffer
        maxLength:(unsigned int)maxLength;
{
  NSAssert(_string,@"No String");
  return [_string getCString:buffer
                  maxLength:maxLength];
};

//--------------------------------------------------------------------
-(void)getCString:(char *)buffer;
{
  NSAssert(_string,@"No String");
  return [_string getCString:buffer];
};

//--------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*)decoder
{
  DESTROY(_string);
  [decoder decodeValueOfObjCType:@encode(id)
          at:&_string];
  RETAIN(_string);
  return self;
};

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)encoder
{
  NSAssert(_string,@"No String");
  [encoder encodeValueOfObjCType:@encode(id)
          at:&_string];
};

//--------------------------------------------------------------------
-(const char*)cString
{
  return [_string cString];
};

//--------------------------------------------------------------------
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

//--------------------------------------------------------------------
-(BOOL)isSearchOverForSenderID:(NSString*)senderID
{
  BOOL over=NO;

  LOGObjectFnStart();

  if (senderID == nil)
    [NSException raise:NSInvalidArgumentException
                 format:@"compare with nil"];
  else
    {
      NSArray* selfElements=[self componentsSeparatedByString:@"."];
      NSArray* senderIDElements=[senderID componentsSeparatedByString:@"."];
      int i=0;
      int selfElementsCount=[selfElements count];
      int senderIDElementsCount=[senderIDElements count];
      int count=min(selfElementsCount,senderIDElementsCount);

      NSDebugMLLog(@"gswdync",@"selfElements=%@",selfElements);
      NSDebugMLLog(@"gswdync",@"senderIDElements=%@",senderIDElements);

      //NSLog(@"%s %i: selfElements=%@",__FILE__,__LINE__,selfElements);
      //NSLog(@"%s %i: senderIDElements=%@",__FILE__,__LINE__,senderIDElements);

      for(i=0;i<count && !over;i++)
        {
          NSString* selfElement=[selfElements objectAtIndex:i];
          NSString* senderIDElement=[senderIDElements objectAtIndex:i];
          NSRange selfRange=[selfElement rangeOfCharacterFromSet:nonNumericSet
                                         options:NSBackwardsSearch];
          NSRange senderRange=[senderIDElement rangeOfCharacterFromSet:nonNumericSet
                                               options:NSBackwardsSearch];

          BOOL selfElementIsNumeric=(selfRange.length==0);
          BOOL senderIDElementIsNumeric=(senderRange.length==0);

          //NSLog(@"%s %i: selfElement=%@",__FILE__,__LINE__,selfElement);
          //NSLog(@"%s %i: senderIDElement=%@",__FILE__,__LINE__,senderIDElement);

          //NSLog(@"%s %i: selfElementIsNumeric=%d",__FILE__,__LINE__,selfElementIsNumeric);
          //NSLog(@"%s %i: senderIDElementIsNumeric=%d",__FILE__,__LINE__,senderIDElementIsNumeric);

          if (selfElementIsNumeric && senderIDElementIsNumeric)
            {
              //Numeric comparison like 2 and 24
              int selfIntValue=[selfElement intValue];
              int senderIDIntValue=[senderIDElement intValue];
              if (selfIntValue>senderIDIntValue)
                over=YES;
            }
          else
            {
              NSComparisonResult cResult=NSOrderedSame;
              NSString* selfNumberString=nil;
              NSString* selfNonNumberString=nil;
              
              NSString* senderIDNumberString=nil;
              NSString* senderIDNonNumberString=nil;

              if (selfElementIsNumeric)
                {
                  selfNumberString=selfElement;
                  selfNonNumberString=@"";
                }
              else
                {
                  int selfElementLength=[selfElement length];
                  if (selfRange.location+selfRange.length<selfElementLength)
                    {
                      selfNonNumberString=[selfElement substringToIndex:
                                                         selfRange.location+selfRange.length];
                      selfNumberString=[selfElement substringFromIndex:
                                                      selfRange.location+selfRange.length];
                    }
                  else
                    {
                      selfNumberString=@"";
                      selfNonNumberString=selfElement;
                    };
                };

              //NSLog(@"%s %i: selfElement range=%@",__FILE__,__LINE__,NSStringFromRange(selfRange));
              //NSLog(@"%s %i: selfNonNumberString=%@",__FILE__,__LINE__,selfNonNumberString);
              //NSLog(@"%s %i: selfNumberString=%@",__FILE__,__LINE__,selfNumberString);

              if (senderIDElementIsNumeric)
                {
                  senderIDNumberString=senderIDElement;
                  senderIDNonNumberString=@"";
                }
              else
                {
                  int senderElementLength=[senderIDElement length];
                  if (senderRange.location+senderRange.length<senderElementLength)
                    {
                      senderIDNonNumberString=[senderIDElement substringToIndex:
                                                                 senderRange.location+senderRange.length];
                      senderIDNumberString=[senderIDElement substringFromIndex:
                                                              senderRange.location+senderRange.length];
                    }
                  else
                    {
                      senderIDNumberString=@"";
                      senderIDNonNumberString=senderIDElement;
                    };
                };


              //NSLog(@"%s %i: senderIDElement range=%@",__FILE__,__LINE__,NSStringFromRange(senderRange));
              //NSLog(@"%s %i: senderIDNumberString=%@",__FILE__,__LINE__,senderIDNumberString);
              //NSLog(@"%s %i: senderIDNonNumberString=%@",__FILE__,__LINE__,senderIDNonNumberString);

              // First compare on string
              cResult=[selfNonNumberString compare:senderIDNonNumberString];
              if (cResult==NSOrderedDescending)
                over=YES;
              else if (cResult==NSOrderedSame
                       && [selfNumberString intValue]>[senderIDNumberString intValue])
                over=YES;
            };
          NSDebugMLLog(@"gswdync",@"i=%d selfElement='%@' senderIDElement='%@' => over=%d",
                       i,selfElement,senderIDElement,over);
        };
      NSDebugMLLog(@"gswdync",@"selfElements=%@ senderIDElements=%@ => over=%d",
                   selfElements,senderIDElements,over);
    };

  LOGObjectFnStop();

  return over;
}

@end

//====================================================================
@implementation GSWElementIDString  (GSWElementIDStringGSW)

- (void)setString: (NSString *)aString 
{
  if (!aString)
    {
      aString = @"";
    }

  if (!_string) 
    {
      _string = [[NSMutableString alloc] initWithString: aString];
    } 
  else
    {
      [_string setString: aString];
    }
}
//--------------------------------------------------------------------
-(void)deleteAllElementIDComponents
{
  [self setString:nil];
};

//--------------------------------------------------------------------
-(void)deleteLastElementIDComponent
{
  //  NSArray* ids=nil;
  int length=0;
  LOGObjectFnStart();

  length=[self length];
  if (length>0)
    {
/*
      ids=[self componentsSeparatedByString:@"."];
      NSAssert([ids count]>0,@"PROBLEM");
      if ([ids count]==1)
        [self setString:@""];
      else
        {
          [self setString:[[ids subarrayWithRange:NSMakeRange(0,[ids count]-1)]
                            componentsJoinedByString:@"."]];
        };
*/
      NSRange dotRange=[self rangeOfString:@"."
                             options:NSBackwardsSearch];
      if (dotRange.length>0)
        {
          [self deleteCharactersInRange:
                  NSMakeRange(dotRange.location,length-dotRange.location)];
        }
      else
        [self setString:@""];        
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
/*
  NSArray* ids=nil;
  int idsCount=0;
  LOGObjectFnStart();
  ids=[self componentsSeparatedByString:@"."];
  idsCount=[ids count];
  if (ids && idsCount>0)
    {
      NSString* lastPart=[ids lastObject];
      if ([lastPart length]==0) // not possible ?
        {
          // ads a '1' at the end
          [self appendString:@"1"];
        }
      else
        {
          // find last 'number'         
          // search for last non '0'-'9' char
          NSRange range=[lastPart rangeOfCharacterFromSet:nonNumericSet
                                  options:NSBackwardsSearch];
          if (range.length>0) // a string and (may be) a number
            {
              if ((range.location+range.length)==[lastPart length]) // no number
                {
                  lastPart=[lastPart stringByAppendingString:@"1"]; // add '1' at the end
                }
              else
                {
                  NSString* numberString=[lastPart substringFromIndex:range.location+range.length];
                  NSString* nonNumberString=[lastPart substringToIndex:range.location+range.length];
                  lastPart=[NSString  stringWithFormat:@"%@%d",
                                   nonNumberString,
                                   [numberString intValue]+1];
                };
            }
          else
            {
              // it's a number 
              lastPart=GSWIntToNSString([lastPart intValue]+1);
            };
          if (idsCount>1)
            [self setString:[[[ids subarrayWithRange:NSMakeRange(0,idsCount-1)]
                               componentsJoinedByString:@"."]
                              stringByAppendingFormat:@".%@",lastPart]];
          else
            [self setString:lastPart];
        };
    };
  LOGObjectFnStop();
*/
  int length=0;
  LOGObjectFnStart();
  length=[self length];
  if (length>0)
    {
      NSString* lastPart=nil;
      NSRange dotRange=[self rangeOfString:@"."
                             options:NSBackwardsSearch];
      if (dotRange.length>0)
        {
          if (dotRange.location+1<length)
            lastPart=[self substringFromIndex:dotRange.location+1];
          else
            lastPart=@"";
        }
      else
        lastPart=self;
      if ([lastPart length]==0) // not possible ?
        {
          // add a '1' at the end
          [self appendString:@"1"];
        }
      else
        {
          // find last 'number'         
          // search for last non '0'-'9' char
          NSRange range=[lastPart rangeOfCharacterFromSet:nonNumericSet
                                  options:NSBackwardsSearch];
          if (range.length>0) // a string and (may be) a number
            {
              if ((range.location+range.length)==[lastPart length]) // no number
                {
                  lastPart=[lastPart stringByAppendingString:@"1"]; // add '1' at the end
                }
              else
                {
                  NSString* numberString=[lastPart substringFromIndex:range.location+range.length];
                  NSString* nonNumberString=[lastPart substringToIndex:range.location+range.length];
                  lastPart=[NSString  stringWithFormat:@"%@%d",
                                      nonNumberString,
                                      [numberString intValue]+1];
                };
            }
          else
            {
              // it's a number 
              lastPart=GSWIntToNSString([lastPart intValue]+1);
            };
          if (dotRange.length>0)
            {
              //Remove after last dot
              [self deleteCharactersInRange:
                      NSMakeRange(dotRange.location+1,length-(dotRange.location+1))];
              //Append lastPart
              [self appendString:lastPart];
            }
          else
            {
              // Set last Part
              [self setString:lastPart];
            };
        };
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
-(void)appendElementIDComponent:(id)element
{
  NSRange range;
  LOGObjectFnStart();
  if (self && [self length]>0)
    {
      [self appendString:@"."];
      [self appendString:element];
    }
  else
    [self setString:element];
  range=[self rangeOfCharacterFromSet:nonNumericSet
              options:NSBackwardsSearch];
  if (range.location+range.length<[self length])
    {
      NSWarnLog(@"You'll may get problems if you use anElementID which ends with decimal character like you do: '%@'",
                element);
    };
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
  int length=[self length];
  if (length==0)
    return 0;
  else
    {
      int count=1;
      NSRange dotRange=[self rangeOfString:@"."];
      while(dotRange.length>0)
        {
          count++;
          dotRange.location++;
          dotRange.length=length-dotRange.location;
          if (dotRange.location>=length)
            break;
          dotRange=[self rangeOfString:@"."
                         options:0
                         range:dotRange];
        };
      return count;
    }
};
#endif

@end
