/* NSString+Trimming.m
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

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
#ifdef LONG_LONG_MAX
-(BOOL)isAnIntegerNumberWithMin:(long long)min_
									max:(long long)max_
#else
-(BOOL)isAnIntegerNumberWithMin:(long)min_
									max:(long)max_
#endif
{
  if ([self isAnIntegerNumber])
	{
	  //TODO
	  long _v=[self longValue];
	  if (_v>=min_ && _v<=max_)
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
#ifdef LONG_LONG_MAX
-(BOOL)isAnUnsignedIntegerNumberWithMax:(unsigned long long)max_
#else
-(BOOL)isAnUnsignedIntegerNumberWithMax:(unsigned long)max_
#endif
{
  if ([self isAnUnsignedIntegerNumber])
	{
	  //TODO
	  unsigned long _v=[self ulongValue];
	  if (_v<=max_)
		return YES;
	  else
		return NO;
	}
  else
	return NO;
};

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

//--------------------------------------------------------------------
-(long)longValue
{
  return atol([self cString]);
}

//--------------------------------------------------------------------
-(unsigned long)ulongValue
{
  return strtoul([self cString],NULL,10);
}

//--------------------------------------------------------------------
-(long long)longLongValue
{
  long long _v=0;
  NSScanner* _scanner = [NSScanner scannerWithString:self];
  [_scanner scanLongLong:&_v];
  return _v;
}

@end

//====================================================================
@implementation NSString (UniqueIdString)
//--------------------------------------------------------------------
+(NSString*)stringUniqueIdWithLength:(int)_lentgh
{
  int i=0;
  NSTimeInterval ti=[[NSDate date]timeIntervalSinceReferenceDate];
  int size=0;
  NSMutableData* data=nil;
  void* pData=NULL;
  NSString* dataHex=nil;
  int intLength=(_lentgh/sizeof(int))-sizeof(ti);
  if (intLength<0)
	intLength=0;
  size=sizeof(ti)+intLength*sizeof(int);
  data=[NSMutableData dataWithLength:size];
  pData=[data mutableBytes];
  dataHex=nil;
  *((NSTimeInterval*)pData)=ti;//TODO: NSSwapHostLongToBig(ti);
  pData+=sizeof(ti);
  for(i=0;i<intLength;i++)
	{
	  *((int*)pData)=rand(); //TODO: NSSwapHostIntToBig(rand());
	  pData+=sizeof(int);
	};
  dataHex=DataToHexString(data);
  return dataHex;
};

//====================================================================
@implementation NSString (stringWithObject)

//--------------------------------------------------------------------
+(NSString*)stringWithObject:(id)object_
{
  NSString* _string=nil;
  if (object_)
	{
	  if ([object_ isKindOfClass:[NSString class]])
		_string=[[object_ copy] autorelease];
#ifdef GDL2
	  else if ([object_ isKindOfClass:[EONull class]])
		_string=@"";
#else
	  else if ([object_ isKindOfClass:[NSNull class]])
		_string=@"";
#endif
	  else if ([object_ respondsToSelector:@selector(stringValue)])
		_string=[object_ stringValue];
	  else if ([object_ respondsToSelector:@selector(description)])
		_string=[object_ description];
	  else
		_string=object_;
	};
  return _string;
};
@end

//====================================================================
@implementation NSString (uniqueFileName)

//--------------------------------------------------------------------
+(NSString*)stringForUniqueFilenameInDirectory:(NSString*)directory_
									withPrefix:(NSString*)prefix_
									withSuffix:(NSString*)suffix_
{
  NSString* _filename=nil;
  NSFileManager* _fileManager=nil;
  NSArray* _directoryContents=nil;
  LOGObjectFnStart();
  _fileManager=[NSFileManager defaultManager];
  _directoryContents=[_fileManager directoryContentsAtPath:directory_];
  if (!_directoryContents)
	{
	  //ERROR
	}
  else
	{
	  int _attempts=16;
	  while(_attempts-->0 && !_filename)
		{
		  NSString* _unique=[NSString stringUniqueIdWithLength:16];
		  _filename=[NSString stringWithFormat:@"%@_%@_%@",prefix_,_unique,suffix_];
		  if ([_directoryContents containsObject:_filename])
			_filename=nil;
		};
	};
  if (_filename)
	_filename=[directory_ stringByAppendingPathComponent:_filename];
  LOGObjectFnStop();
  return _filename;
};
@end

//====================================================================
@implementation NSString (Qutotes)

//--------------------------------------------------------------------
-(BOOL)hasPrefix:(NSString*)prefix_
	   andSuffix:(NSString*)suffix_
{
  return [self hasPrefix:prefix_] && [self hasSuffix:suffix_];
};

//--------------------------------------------------------------------
-(NSString*)stringWithoutPrefix:(NSString*)prefix_
					  andSuffix:(NSString*)suffix_
{
  return [[self stringWithoutPrefix:prefix_]stringWithoutSuffix:suffix_];
};

//--------------------------------------------------------------------
-(BOOL)isQuotedWith:(NSString*)quote_
{
  return [self hasPrefix:quote_
			   andSuffix:quote_];
};
//--------------------------------------------------------------------
-(NSString*)stringWithoutQuote:(NSString*)quote_
{
  return [self stringWithoutPrefix:quote_
			   andSuffix:quote_];
};
@end

//====================================================================
@implementation NSMutableString (Qutotes)

//--------------------------------------------------------------------
-(void)removePrefix:(NSString*)prefix_
		  andSuffix:(NSString*)suffix_
{
  [self removePrefix:prefix_];
  [self removeSuffix:suffix_];
};

//--------------------------------------------------------------------
-(void)removeQuote:(NSString*)quote_
{
  [self removePrefix:quote_
		andSuffix:quote_];
};
@end

