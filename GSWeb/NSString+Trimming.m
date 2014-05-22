/** NSString+Trimming.m - <title>GSWeb: Class NSString with Trimming </title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$
   $Id$

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
#include "GSWPrivate.h"
#include <time.h>

//====================================================================
@implementation NSString (SBString)

//--------------------------------------------------------------------
-(BOOL)isANumber
{
  return [self isAFloatNumber];
};

//--------------------------------------------------------------------
-(BOOL)isAFloatNumber
{
  //TODOV
  NSRange nonNumberRange;
  NSMutableCharacterSet* nonNumberCS=[[NSCharacterSet decimalDigitCharacterSet] 
                                       mutableCopy];
  [nonNumberCS addCharactersInString:@".Ee-+"];
  [nonNumberCS invert];
  nonNumberRange  = [self rangeOfCharacterFromSet:nonNumberCS];
  return (nonNumberRange.length<=0);
};

//--------------------------------------------------------------------
-(BOOL)isAnIntegerNumber
{
  //TODOV
  NSRange nonNumberRange;
  NSMutableCharacterSet* nonNumberCS=[[NSCharacterSet decimalDigitCharacterSet] 
                                       mutableCopy];
  [nonNumberCS addCharactersInString:@".-+"];
  [nonNumberCS invert];
  nonNumberRange  = [self rangeOfCharacterFromSet:nonNumberCS];
  return (nonNumberRange.length<=0);
};

//--------------------------------------------------------------------
-(BOOL)isAnIntegerNumberWithMin:(NSInteger) min
                            max:(NSInteger) max
{
  if ([self isAnIntegerNumber])
    {
      NSInteger v=[self integerValue];
      if (v>=min && v<=max)
        return YES;
      else
        return NO;
    }
  else
    return NO;
};

//--------------------------------------------------------------------
-(BOOL)isAnUnsignedIntegerNumber
{
  //TODOV
  NSRange nonNumberRange;
  NSMutableCharacterSet* nonNumberCS=[[NSCharacterSet decimalDigitCharacterSet] 
                                       mutableCopy];
  [nonNumberCS addCharactersInString:@".+"];
  [nonNumberCS invert];
  nonNumberRange  = [self rangeOfCharacterFromSet:nonNumberCS];
  return (nonNumberRange.length<=0);
};

//--------------------------------------------------------------------
-(BOOL)isAnUnsignedIntegerNumberWithMax:(NSUInteger) max
{
    unsigned int v;
    
    if ([self isAnUnsignedIntegerNumber])
    {
        //TODO
        sscanf([self UTF8String], "%u", &v);
        //      v=[self unsignedIntegerValue];
        if (v<=max)
            return YES;
        else
            return NO;
    }
    else
        return NO;
}

//--------------------------------------------------------------------
-(BOOL)isStartingWithNumber
{
  //TODOV
  NSRange numberRange;
  NSMutableCharacterSet* numberCS=[[NSCharacterSet decimalDigitCharacterSet]
                                    mutableCopy];
  [numberCS addCharactersInString:@".-+"];
  numberRange  = [self rangeOfCharacterFromSet:numberCS];
  return (numberRange.location==0 && numberRange.length>0);
};


@end

//====================================================================
@implementation NSString (UniqueIdString)
//--------------------------------------------------------------------
+(NSString*)stringUniqueIdWithLength:(int)length
{
  int i=0;
  NSTimeInterval ti = [[NSDate date] timeIntervalSinceReferenceDate];
  NSMutableData* data=nil;
  void* pData=NULL;
  NSString* dataHex=nil;  
  
  NSAssert1(length>=sizeof(ti),@"Too short length: %d",length);

  data=[NSMutableData dataWithLength:length];
  NSAssert(data,@"no data");

  pData=[data mutableBytes];
  NSAssert(pData,@"no pData");
  //NSDebugMLog(@"pData=%p",pData);

  *((NSTimeInterval*)pData)=ti;
  pData+=sizeof(ti);
  length-=sizeof(ti);

  srand(time(NULL));
  for(i=0;i<length;i++)
    {
      int c=rand();
      *((unsigned char*)pData)=(unsigned char)(256.0*c/(RAND_MAX+1.0));
      //NSDebugMLog(@"i=%d c=%i max=%d c=%u",i,c,(int)RAND_MAX,(unsigned int)(*((unsigned char*)pData)));
      pData++;
    };
  //NSDebugMLog(@"pData=%p",pData);
  //NSDebugMLog(@"pData length=%d",(int)(pData-[data mutableBytes]));

  dataHex=[data hexadecimalRepresentation];
  //NSDebugMLog(@"dataHex %p=%@",dataHex,dataHex);
  return dataHex;
};
@end

//====================================================================


@implementation NSString (stringWithObject)

//--------------------------------------------------------------------
+(NSString*)stringWithObject:(id)object
{
  return NSStringWithObject(object);
};
@end

//====================================================================
@implementation NSString (uniqueFileName)

//--------------------------------------------------------------------
+(NSString*)stringForUniqueFilenameInDirectory:(NSString*)directory
                                    withPrefix:(NSString*)prefix
                                    withSuffix:(NSString*)suffix
{
    NSString      * filename = nil;
    NSFileManager * fileManager = nil;
    NSArray       * directoryContents = nil;
    NSError       * error = nil;
    
    fileManager = [NSFileManager defaultManager];
    
    directoryContents = [fileManager contentsOfDirectoryAtPath:directory
                                                         error:&error];
    if (!directoryContents)
    {
        //ERROR
        NSDebugMLog(@"error %s %@",__PRETTY_FUNCTION__, error);
    }
    else
    {
        int attempts=16;
        while(attempts-->0 && !filename)
        {
            NSString* unique=[NSString stringUniqueIdWithLength:16];
            filename=[NSString stringWithFormat:@"%@_%@_%@",prefix,unique,suffix];
            if ([directoryContents containsObject:filename])
                filename=nil;
        };
    };
    if (filename)
        filename=[directory stringByAppendingPathComponent:filename];
    return filename;
}

@end

//====================================================================
@implementation NSString (Qutotes)

//--------------------------------------------------------------------
-(BOOL)hasPrefix:(NSString*)prefix
       andSuffix:(NSString*)suffix
{
  return [self hasPrefix:prefix] && [self hasSuffix:suffix];
};

//--------------------------------------------------------------------
-(NSString*)stringWithoutPrefix:(NSString*)prefix
                      andSuffix:(NSString*)suffix
{
  return [[self stringByDeletingPrefix:prefix] stringByDeletingSuffix:suffix];
};

//--------------------------------------------------------------------
-(BOOL)isQuotedWith:(NSString*)quote
{
  return [self hasPrefix:quote
               andSuffix:quote];
};
//--------------------------------------------------------------------
-(NSString*)stringWithoutQuote:(NSString*)quote
{
  return [self stringWithoutPrefix:quote
               andSuffix:quote];
};
@end

//====================================================================
@implementation NSMutableString (Qutotes)

//--------------------------------------------------------------------
-(void)removePrefix:(NSString*)prefix
          andSuffix:(NSString*)suffix
{
  [self deletePrefix:prefix];
  [self deleteSuffix:suffix];
};

//--------------------------------------------------------------------
-(void)removeQuote:(NSString*)quote
{
  [self removePrefix:quote
        andSuffix:quote];
};
@end

//--------------------------------------------------------------------
NSString* GSWJoinedStrings(int stringsCount,NSString* s1,...)
{
  NSString* result=nil;
  if (stringsCount>0)
    {
      NSMutableString* tmp=nil;
      //GSODFLog(@"s1=%@",result);
      if (stringsCount==1)
	tmp=(NSMutableString*)s1;
      else
	{
	  IMP asIMP=NULL;
	  va_list ap;
	  va_start(ap,s1);
	  int i=0;
	  for(i=0;i<stringsCount;i++)
	    {
	      NSString* s=(i==0 ? s1 : va_arg(ap,NSString*));
	      if (s)
		{
		  if (!tmp)
		    tmp=[NSMutableString string];
		  GSWeb_appendStringWithImpPtr(tmp,&asIMP,s);
		}
	    }
	  va_end(ap);
	}
      if (tmp!=nil)
	result=[NSString stringWithString:tmp];
    }
  return result;
}
