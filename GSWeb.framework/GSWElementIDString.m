/* GSWElementIDString.m - GSWeb: Class GSWElementIDString
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

#undef GSWElementIDString

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
  GSWLogC("_string deallocate");
  DESTROY(_string);
  GSWLogC("_string deallocated");
  [super dealloc];
  GSWLogC("GSWElementIDString end of dealloc");
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
//  NSDebugMLLog(@"low",@"self:%@",self);  
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
  NSDebugMLLog(@"low",@"self:%@",self);  
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)incrementLastElementIDComponent
{
  NSArray* ids=nil;
  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"self:%@",self);  
  ids=[self componentsSeparatedByString:@"."];
  if (ids && [ids count]>0)
	{
	  NSString* _last=[ids lastObject];
	  NSString* _new=nil;
	  NSDebugMLLog(@"low",@"_last:%@",_last);  
	  _last=[NSString  stringWithFormat:@"%d",([_last intValue]+1)];	  
	  NSDebugMLLog(@"low",@"_last:%@",_last);  
	  NSDebugMLLog(@"low",@"ids count:%d",[ids count]);  
	  if ([ids count]>1)
		_new=[[[ids subarrayWithRange:NSMakeRange(0,[ids count]-1)]
				componentsJoinedByString:@"."]
			   stringByAppendingFormat:@".%@",_last];
	  else
		_new=_last;
	  [self setString:_new];
	};
  NSDebugMLLog(@"low",@"self:%@",self);  
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendZeroElementIDComponent
{
  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"self:%@",self);  
  if ([self length]>0)
	  [self appendString:@".0"];
  else
	  [self setString:@"0"];
  NSDebugMLLog(@"low",@"self:%@",self);  
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendElementIDComponent:(id)_element
{
  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"self:%@",self);  
//  NSDebugMLLog(@"low",@"_element:%@",_element);  
  if (self && [self length]>0)
	  [self appendFormat:@".%@",_element];
  else
	  [self setString:_element];
  NSDebugMLLog(@"low",@"self:%@",self);  
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
