/** GSWUtils.m - <title>GSWeb: Utilities</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
  
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

#include <sys/time.h>
#include <time.h>
#include <unistd.h>
#ifndef GNUSTEP
#include <GNUstepBase/GSObjCRuntime.h>
#endif
#include <GNUstepBase/NSObject+GNUstepBase.h>
#include <GNUstepBase/NSString+GNUstepBase.h>
#include <GNUstepBase/GSMime.h>
#include "stacktrace.h"
#include "attach.h"

static NSNumber* cachedGSWNumber_Yes=nil;
static NSNumber* cachedGSWNumber_No=nil;

#define INT_NUMBER_CACHE_SIZE 128
static NSNumber* GSWIntNumber_cache[INT_NUMBER_CACHE_SIZE];
static SEL numberWithIntSEL = NULL;
static IMP numberWithIntIMP = NULL;

static SEL stringWithStringSEL = NULL;
static IMP nsString_stringWithStringIMP = NULL;

static SEL stringWithFormatSEL = NULL;
static IMP nsString_stringWithFormatIMP = NULL;

static SEL stringWithCString_lengthSEL = NULL;
static IMP nsString_stringWithCString_lengthIMP = NULL;

static Class nsNumberClass=Nil;
static Class nsStringClass=Nil;
static Class nsMutableStringClass=Nil;
static Class eoNullClass=Nil;

//--------------------------------------------------------------------
void GSWInitializeAllMisc()
{
  static BOOL initialized=NO;
  if (!initialized)
    {
      initialized=YES;

      // Yes & No
      ASSIGN(cachedGSWNumber_Yes,([NSNumber numberWithBool:YES]));
      ASSIGN(cachedGSWNumber_No,([NSNumber numberWithBool:NO]));

      // GSWInt Number
      int i=0;
      nsNumberClass=[NSNumber class];
      numberWithIntSEL=@selector(numberWithInt:);
      NSCAssert(numberWithIntSEL,@"No SEL for numberWithIntSEL:");
      numberWithIntIMP=[nsNumberClass methodForSelector:numberWithIntSEL];
      for(i=0;i<INT_NUMBER_CACHE_SIZE;i++)
        ASSIGN(GSWIntNumber_cache[i],((*numberWithIntIMP)(nsNumberClass,numberWithIntSEL,i)));

      // Strings things
      ASSIGN(nsStringClass,[NSString class]);
      ASSIGN(nsMutableStringClass,[NSMutableString class]);
      ASSIGN(eoNullClass,[NSNull class]);

      stringWithStringSEL = @selector(stringWithString:);
      NSCAssert(stringWithStringSEL,@"No SEL for stringWithString:");
      nsString_stringWithStringIMP = [nsStringClass methodForSelector:stringWithStringSEL];
      NSCAssert(nsString_stringWithStringIMP,@"No IMP for stringWithString:");

      stringWithFormatSEL = @selector(stringWithFormat:);
      NSCAssert(stringWithFormatSEL,@"No SEL for stringWithFormat:");
      nsString_stringWithFormatIMP = [nsStringClass methodForSelector:stringWithFormatSEL];
      NSCAssert(nsString_stringWithFormatIMP,@"No IMP for stringWithFormat:");

      stringWithCString_lengthSEL = @selector(stringWithCString:length:);
      NSCAssert(stringWithCString_lengthSEL,@"No SEL for stringWithCString:length::");
      nsString_stringWithCString_lengthIMP = [nsStringClass methodForSelector:stringWithCString_lengthSEL];
      NSCAssert(nsString_stringWithCString_lengthIMP,@"No IMP for stringWithCString:length:");

      // NSString+HTML
      NSStringHTML_Initialize();
    };
};

//--------------------------------------------------------------------
NSNumber* GSWNumber_Yes()
{
  NSCAssert(cachedGSWNumber_Yes,@"cachedGSWNumber_Yes not initialized");
  return cachedGSWNumber_Yes;
};

//--------------------------------------------------------------------
NSNumber* GSWNumber_No()
{
  NSCAssert(cachedGSWNumber_No,@"cachedGSWNumber_No not initialized");
  return cachedGSWNumber_No;
};

//--------------------------------------------------------------------
char* GSWIntToString(char* buffer,NSUInteger bufferSize,int value,NSUInteger* resultLength)
{
  int origValue=value;
  int i=bufferSize-1;
  int j=0;
  if (value<0)
    value=-value;
  do
    {
      NSCAssert2(i>0,@"Buffer not large (%"PRIuPTR") enough for %d",bufferSize,origValue);//>0 for null term
      buffer[i--]='0'+(value%10);
      value=value/10;
    }
  while(value);
  i++;

  j=0;
  if (origValue<0)
    {
      NSCAssert2(i>0,@"Buffer not large (%"PRIuPTR") enough for %d",bufferSize,origValue);
      buffer[j++]='-';
    };
  do
    {
      buffer[j++]=buffer[i++];
    }
  while(i<bufferSize);
  if (resultLength)
    *resultLength=j;
  buffer[j++]='\0';

  return buffer;
};

//--------------------------------------------------------------------
NSString* cachedStringForInt(int value)
{
  static NSString* cachedString[] = {
    @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
    @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", 
    @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", 
    @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", 
    @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", 
    @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", 
    @"60", @"61", @"62", @"63", @"64", @"65", @"66", @"67", @"68", @"69",
    @"70", @"71", @"72", @"73", @"74", @"75", @"76", @"77", @"78", @"79",
    @"80", @"81", @"82", @"83", @"84", @"85", @"86", @"87", @"88", @"89",
    @"90", @"91", @"92", @"93", @"94", @"95", @"96", @"97", @"98", @"99" };
  if (value>=0 && value <100)
    return cachedString[value];
  else
    return nil;
}

//--------------------------------------------------------------------
NSString* GSWIntToNSString(int value)
{
  NSString* s=nil;
  char buffer[20];
  NSUInteger resultLength=0;
  
  NSCAssert(nsStringClass,@"GSWUtils not initialized");

  s=cachedStringForInt(value);
  if (!s)
    {
      GSWIntToString(buffer,20,value,&resultLength);
      s=(*nsString_stringWithCString_lengthIMP)(nsStringClass,stringWithCString_lengthSEL,
                                                buffer,resultLength);
    }
  return s;
};

//--------------------------------------------------------------------
NSNumber* GSWIntNumber(int value)
{
  NSCAssert(numberWithIntIMP,@"GSWIntNumber not initialized");
  if (value>=0 && value<INT_NUMBER_CACHE_SIZE)
    return GSWIntNumber_cache[value];
  else
    return (*numberWithIntIMP)(nsNumberClass,numberWithIntSEL,value);
};

//--------------------------------------------------------------------
GSWTime GSWTime_now()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return GSWTime_makeTimeFromSecAndUSec(tv.tv_sec,tv.tv_usec);
}

//--------------------------------------------------------------------
time_t GSWTime_secPart(GSWTime t)
{
  return (time_t)(t/USEC_PER_SEC);
};

//--------------------------------------------------------------------
long GSWTime_usecPart(GSWTime t)
{
  return (time_t)(t%USEC_PER_SEC);
};

//--------------------------------------------------------------------
long GSWTime_msecPart(GSWTime t)
{
  return ((time_t)(t%USEC_PER_SEC))/1000;
};

//--------------------------------------------------------------------
// 2003/12/24 22:12:25.123
NSString* GSWTime_format(GSWTime t)
{
  char sDate[24];
  struct tm stTM;
  time_t timeSecPart=GSWTime_secPart(t);
  long timeMSecPart=GSWTime_msecPart(t);
  int real_year;

  localtime_r(&timeSecPart,&stTM);
  real_year = 1900 + stTM.tm_year;
  
  sDate[0] = real_year / 1000 + '0';
  sDate[1] = (real_year % 1000) / 100 + '0';
  sDate[2] = (real_year % 100) / 10 + '0';
  sDate[3] = real_year % 10 + '0';

  sDate[4] = '/';

  sDate[5] = (stTM.tm_mon+1) / 10 + '0';
  sDate[6] = (stTM.tm_mon+1) % 10 + '0';

  sDate[7] = '/';

  sDate[8] = stTM.tm_mday / 10 + '0';
  sDate[9] = stTM.tm_mday % 10 + '0';
  
  sDate[10] = ' ';
  sDate[11] = stTM.tm_hour / 10 + '0';
  sDate[12] = stTM.tm_hour % 10 + '0';
  sDate[13] = ':';
  sDate[14] = stTM.tm_min / 10 + '0';
  sDate[15] = stTM.tm_min % 10 + '0';
  sDate[16] = ':';
  sDate[17] = stTM.tm_sec / 10 + '0';
  sDate[18] = stTM.tm_sec % 10 + '0';
  sDate[19] = '.';
  sDate[20] = timeMSecPart / 100 + '0';
  sDate[21] = (timeMSecPart % 100) / 10 + '0';
  sDate[22] = timeMSecPart % 10 + '0';

  sDate[23] = 0;
  return (*nsString_stringWithCString_lengthIMP)(nsStringClass,stringWithCString_lengthSEL,
                                                 sDate,23);
}

//--------------------------------------------------------------------
BOOL boolValueFor(id anObject)
{
  if (anObject)
    {
      if (/*anObject==BNYES ||*/ anObject==NSTYES || anObject==GSWNumberYes)
        return YES;
      else if (/*anObject==BNNO ||*/ anObject==NSTNO || anObject==GSWNumberNo)
        return NO;
      else if ([anObject respondsToSelector:@selector(boolValue)] && [anObject boolValue])
        return YES;
      else if ([anObject respondsToSelector:@selector(intValue)] && [anObject intValue])
        return YES;
      //BOOL is unisgned char
      else if ([anObject respondsToSelector:@selector(unsignedCharValue)] && [anObject unsignedCharValue])
        return YES;
      else
        return NO;
    }
  else
    return NO;
};

//--------------------------------------------------------------------
BOOL boolValueWithDefaultFor(id anObject,BOOL defaultValue)
{
  if (anObject)
    {
      if (/*anObject==BNYES ||*/ anObject==NSTYES)
        return YES;
      else if (/*anObject==BNNO ||*/ anObject==NSTNO)
        return NO;
      else if ([anObject respondsToSelector:@selector(boolValue)])
        return ([anObject boolValue]!=NO);
      else if ([anObject respondsToSelector:@selector(intValue)])
        return ([anObject intValue]!=0);
      /* BOOL is unsigned char.  */
      else if ([anObject respondsToSelector:@selector(unsignedCharValue)])
        return ([anObject unsignedCharValue]!=0);
      else
        return defaultValue;
    }
  else
    return NO;
};

/*
//--------------------------------------------------------------------
BOOLNB boolNbFor(BOOL value)
{
  return (value ? BNYES : BNNO);
};
*/

//--------------------------------------------------------------------
BOOL isHeaderKeysEqual(NSString* headerKey,NSString* testKey)
{
  return [[headerKey lowercaseString]isEqualToString:[testKey lowercaseString]];
};


//--------------------------------------------------------------------
BOOL SBIsEqual(id id1,id id2)
{
  BOOL equal=NO;
  if (id1==id2)
    equal=YES;
  else if (id1)
    {
      if (id2)
        equal=[id1 isEqual:id2];
    }
  else if (!id2)
    {
      equal=YES;
    };
  return equal;
};

//--------------------------------------------------------------------
BOOL SBIsValueEqual(id id1,id id2)
{
  BOOL equal=SBIsEqual(id1,id2);
  if (!equal
      && [id1 class]!=[id2 class])
    {
      if ([id1 isKindOfClass:nsStringClass])
        {
          NSString* id2String=NSStringWithObject(id2);
          equal=[id1 isEqualToString:id2String];
        }
      else if ([id2 isKindOfClass:nsStringClass])
        {
          NSString* id1String=NSStringWithObject(id1);
          equal=[id2 isEqualToString:id1String];
        };
    };
  return equal;
};

//--------------------------------------------------------------------
BOOL SBIsValueIsIn(id id1,id id2)
{
  int i=0;
  int count=[id2 count];
  for(i=0;i<count;i++)
    {
      if (SBIsValueEqual(id1,[id2 objectAtIndex:i]))
        return YES;
    };
  return NO;
};

/* The number of seconds between 1/1/2001 and 1/1/1970 = -978307200. */
/* This number comes from:
-(((31 years * 365 days) + 8 days for leap years) =total number of days
  * 24 hours
  * 60 minutes
  * 60 seconds)
  This ignores leap-seconds. */
#define UNIX_REFERENCE_INTERVAL -978307200.0
//--------------------------------------------------------------------
NSTimeInterval NSTimeIntervalFromTimeVal(struct timeval* tv)
{
  NSTimeInterval interval;
  interval = UNIX_REFERENCE_INTERVAL;
  interval += tv->tv_sec;
  interval += (double)tv->tv_usec/1000000.0;
  /* There seems to be a problem with bad double arithmetic... */
  NSCAssert(interval < 0, NSInternalInconsistencyException);
  return interval;
};

//--------------------------------------------------------------------
void NSTimeIntervalSleep(NSTimeInterval ti)
{
  struct timespec ts;  
  struct timespec remaining;
  ts.tv_sec=(time_t)ti;
  ts.tv_nsec=(long)((ti-ts.tv_sec)*100000000.0);
  remaining.tv_sec=0;
  remaining.tv_nsec=0;
  if (nanosleep(&ts,&remaining)==-1)
    {
//      NSDebugFLog(@"remaining tv_sec=%ld tv_nsec=%ld",(long)remaining.tv_sec,remaining.tv_nsec);
    };
};

//--------------------------------------------------------------------
void StackTraceIFND()
{
  NSString* stackTraceString=[nsStringClass stringWithContentsOfFile:
                                              (*nsString_stringWithFormatIMP)(nsStringClass,stringWithFormatSEL,@"/tmp/%@.stacktrace",
                                                             globalApplicationClassName)];
  if ([stackTraceString intValue])
    {
      StackTrace();
    };
};

//--------------------------------------------------------------------
void DebugBreakpointIFND()
{
  NSString* breakString=[nsStringClass stringWithContentsOfFile:
                                         (*nsString_stringWithFormatIMP)(nsStringClass,stringWithFormatSEL,@"/tmp/%@.break",
                                                                         globalApplicationClassName)];
  if ([breakString intValue])
    {
      DebugBreakpoint();
    };
};

//--------------------------------------------------------------------
void ExceptionRaiseFn(const char *func, 
                      const char *file,
                      int line,
                      NSString* name,
                      NSString* format,
                      ...)
{
  NSString* fmt =  (*nsString_stringWithFormatIMP)
    (nsStringClass,stringWithFormatSEL,@"File %s: %d. In %s EXCEPTION %@: %@",
     func,line,file,name,format);
  NSString* string= nil;
  va_list args;
  va_start(args,format);
  string=[nsStringClass stringWithFormat:fmt
                        arguments:args];
  va_end(args);
  NSLog(@"%@",string);
  StackTraceIFND();
  DebugBreakpointIFND();
  [NSException raise:name
               format:@"%@",string];
};

//--------------------------------------------------------------------
void ExceptionRaiseFn0(const char *func, 
                       const char *file,
                       int line,
                       NSString* name,
                       NSString* format)
{
  NSString* string =  (*nsString_stringWithFormatIMP)
    (nsStringClass,stringWithFormatSEL,@"File %s: %d. In %s EXCEPTION %@: %@",
     func,line,file,name,format);
  NSLog(@"%@",string);
  StackTraceIFND();
  DebugBreakpointIFND();
  [NSException raise:name
               format:@"%@",string];
};

//====================================================================
@implementation NSException (NSBuild)

//--------------------------------------------------------------------
+(NSException*)exceptionWithName:(NSString*)excptName
                          format:(NSString*)format,...
{
  NSException* exception=nil;
  NSString* excptReason=nil;
  va_list args;
  va_start(args,format);
  excptReason=[nsStringClass stringWithFormat:format
                             arguments:args];
  va_end(args);
  exception=[self exceptionWithName:excptName
                  reason:excptReason
                  userInfo: nil];
  return exception;
};
@end

//====================================================================
@implementation NSException (NSExceptionUserInfoAdd)

//--------------------------------------------------------------------
-(NSException*)exceptionByAddingUserInfo:(NSDictionary*)aUserInfo
{
  NSMutableDictionary* excptUserInfo
    = [NSMutableDictionary dictionaryWithDictionary:[self userInfo]];
  [excptUserInfo addEntriesFromDictionary:aUserInfo];
  return [[self class]exceptionWithName:[self name]
                      reason:[self reason]
                      userInfo: excptUserInfo];
};

//--------------------------------------------------------------------
-(NSException*)exceptionByAddingToUserInfoKey:(id)key
                                       format:(NSString*)format,...
{
  NSException* exception=nil;
  NSString* userInfoString=nil;
  NSMutableDictionary* excptUserInfo=nil;
  va_list args;

  excptUserInfo=[NSMutableDictionary dictionaryWithDictionary:[self userInfo]];
  va_start(args,format);
  userInfoString = [nsStringClass stringWithFormat:format
                                  arguments:args];
  va_end(args);
  {
    id curArray = [excptUserInfo objectForKey:key];
    id newArray=[NSMutableArray arrayWithObject:userInfoString];
    if (!curArray)
      {
        curArray = [NSMutableArray array];
      }
    if (![curArray isKindOfClass:[NSMutableArray class]])
      {
        id tempObject = curArray;
        curArray = [NSMutableArray array];
        [curArray addObject:tempObject];
      }
    [newArray addObjectsFromArray:curArray];
    [excptUserInfo setObject:newArray forKey:key];
  }
  exception=[[self class]exceptionWithName:[self name]
                         reason:[self reason]
                         userInfo:excptUserInfo];

  return exception;
};


//--------------------------------------------------------------------
-(NSException*)exceptionByAddingUserInfoKey:(id)key
                                     format:(NSString*)format,...
{
  NSException* exception=nil;
  NSString* userInfoString=nil;
  NSMutableDictionary* excptUserInfo=nil;
  va_list args;

  excptUserInfo=[NSMutableDictionary dictionaryWithDictionary:[self userInfo]];
  va_start(args,format);
  userInfoString = [nsStringClass stringWithFormat:format
                                  arguments:args];
  va_end(args);
  [excptUserInfo setObject:userInfoString
		 forKey:key];
  exception=[[self class]exceptionWithName:[self name]
                         reason:[self reason]
                         userInfo:excptUserInfo];

  return exception;
};

//--------------------------------------------------------------------
-(NSException*)exceptionByAddingUserInfoFrameInfo:(NSString*)frameInfo
{
  NSException* exception=nil;
  NSMutableDictionary* excptUserInfo=nil;
  NSArray* frameInfoArray=nil;

  NSAssert(frameInfo,@"No frameInfo");
  excptUserInfo=[NSMutableDictionary dictionaryWithDictionary:[self userInfo]];
  frameInfoArray=[excptUserInfo objectForKey:@"FrameInfo"];
  if (frameInfoArray)
    frameInfoArray=[frameInfoArray arrayByAddingObject:frameInfo];
  else
    frameInfoArray=[NSArray arrayWithObject:frameInfo];
  [excptUserInfo setObject:frameInfoArray
		 forKey:@"FrameInfo"];
  exception=[[self class]exceptionWithName:[self name]
                         reason:[self reason]
                         userInfo:excptUserInfo];

  return exception;
};

//--------------------------------------------------------------------
-(NSException*)exceptionByAddingUserInfoFrameInfoFormat:(NSString*)format,...
{
  NSException* exception=nil;
  NSString* frameInfo=nil;
  va_list args;

  va_start(args,format);
  frameInfo = [nsStringClass stringWithFormat:format
                             arguments:args];
  va_end(args);
  exception=[self exceptionByAddingUserInfoFrameInfo:frameInfo];

  return exception;
};

//--------------------------------------------------------------------
-(NSException*)exceptionByAddingUserInfoFrameInfoObject:(id)obj
                                                    sel:(SEL)sel
                                                   file:(const char*)file
                                                   line:(int)line
                                                 format:(NSString*)format,...
{
  NSException* exception=nil;
  Class         cls = (Class)obj;
  char          c = '+';
  NSString* fmt=nil;
  NSString* string= nil;
  va_list args;

  if (class_isMetaClass([self class]) == NO)
    {
      c = '-';
      cls = [obj class];
    };
  fmt = (*nsString_stringWithFormatIMP)(nsStringClass,stringWithFormatSEL, @"%s: %d. In [%@ %c%@] %@",
                                        file,
                                        line,
                                        NSStringFromClass(cls),
                                        c,
                                        NSStringFromSelector(sel),
                                        format);
  va_start(args,format);
  string=[nsStringClass stringWithFormat:fmt
                        arguments:args];
  va_end(args);
  exception=[self exceptionByAddingUserInfoFrameInfo:string];

  return exception;
};

//--------------------------------------------------------------------
-(NSException*)exceptionByAddingUserInfoFrameInfoFunction:(const char*)fn
                                                     file:(const char*)file
                                                     line:(int)line
                                                   format:(NSString*)format,...
{
  NSException* exception=nil;
  NSString* fmt =nil;
  NSString* string= nil;
  va_list args;

  va_start(args,format);
  fmt =  (*nsString_stringWithFormatIMP)(nsStringClass,stringWithFormatSEL,@"%s: %d. In %s %@: %@",
                                         file,line,fn,format);
  string=[nsStringClass stringWithFormat:fmt
                        arguments:args];
  va_end(args);
  exception=[self exceptionByAddingUserInfoFrameInfo:string];

  return exception;
};

//--------------------------------------------------------------------
-(BOOL)isValidationException
{
  BOOL isValidationException=boolValueWithDefaultFor([[self userInfo] objectForKey:@"isValidationException"],NO);
  return isValidationException;
};

@end

//====================================================================
@implementation NSDate (NSDateHTMLDescription)
//------------------------------------------------------------------------------
-(NSString*)htmlDescription
{
  NSTimeZone* gmtTZ=[NSTimeZone timeZoneWithName:@"GMT"];
  if (!gmtTZ)
    NSWarnLog(@"no time zone for GMT");
  return [self descriptionWithCalendarFormat:@"%a, %d %b %Y %H:%M:%S GMT"
			   timeZone:gmtTZ
			   locale:nil];
};
@end

//====================================================================
@implementation NSMutableOrderedArray: NSMutableArray

//--------------------------------------------------------------------
- (id)initWithCompareSelector:(SEL)compareSelector
{
  if ((self=[super init]))
    {
      _array = [NSMutableArray new];
      _compareSelector=compareSelector;
    }

  return self;
};

//--------------------------------------------------------------------
- (id)initWithCapacity:(NSUInteger)cap
{
  if ((self=[super init]))
    {
      _array = [NSMutableArray new];
      _compareSelector=NULL;
    };
  return self;
}

//--------------------------------------------------------------------
- (NSUInteger)count
{
  return [_array count];
}

//--------------------------------------------------------------------
- (id)objectAtIndex:(NSUInteger)i
{
  return [_array objectAtIndex:i];
}

//--------------------------------------------------------------------
- (void)removeObjectAtIndex:(NSUInteger)i
{
  [_array removeObjectAtIndex:i];
}

//--------------------------------------------------------------------
- (oneway void)release
{
  DESTROY(_array);
  _compareSelector=NULL;
  [super dealloc];
}

//--------------------------------------------------------------------
-(void)addObject:(id)object
{
  //TODO better method
  int i=0;
  int count=[_array count];
  NSComparisonResult result=NSOrderedSame;

  for(i=0;result!=NSOrderedDescending && i<count;i++)
    {
      result=(NSComparisonResult)[object performSelector:_compareSelector
                                         withObject:[_array objectAtIndex:i]];

      if (result==NSOrderedDescending)
	[_array insertObject:object
                atIndex:i];
    };

  if (result!=NSOrderedDescending)
    [_array addObject:object];
};

//--------------------------------------------------------------------
-(void)addObjectsFromArray:(NSArray*)array
{
  int i;
  int count=[array count];

  for(i=0;i<count;i++)
    {
      [_array addObject:[array objectAtIndex:i]];
    };
};

//--------------------------------------------------------------------
-(void)insertObject:(id)object
            atIndex:(NSUInteger)index
{
  [NSException raise:@"NSMutableOrderedArray"
	       format:@"NSMutableOrderedArray doesn't support %s",sel_getName(_cmd)];
};

//--------------------------------------------------------------------
-(void)replaceObjectAtIndex:(NSUInteger)index
                 withObject:(id)object
{
  [NSException raise:@"NSMutableOrderedArray"
	       format:@"NSMutableOrderedArray doesn't support %s",sel_getName(_cmd)];
};

//--------------------------------------------------------------------
-(void)replaceObjectsInRange:(NSRange)range
        withObjectsFromArray:(NSArray*)array
{

  [NSException raise:@"NSMutableOrderedArray"
	       format:@"NSMutableOrderedArray doesn't support %s",sel_getName(_cmd)];
};

//--------------------------------------------------------------------
-(void)replaceObjectsInRange:(NSRange)range
        withObjectsFromArray:(NSArray*)array
                       range:(NSRange)arrayRange
{
  [NSException raise:@"NSMutableOrderedArray"
	       format:@"NSMutableOrderedArray doesn't support %s",sel_getName(_cmd)];
};

//--------------------------------------------------------------------
-(void)setArray:(NSArray*)array
{
  [_array setArray:[array sortedArrayUsingSelector:_compareSelector]];
};

@end

//====================================================================
@implementation NSBundle (NSBundleAllFrameworks)
//--------------------------------------------------------------------
-(NSString*)bundleName
{
  //TODO: Cache it !
  NSString* bundlePath=nil;
  NSString* name=nil;

  bundlePath=[self bundlePath];
  bundlePath=[bundlePath stringGoodPath];
  name=[bundlePath lastPathComponent];
  name=[name stringByDeletingPathExtension];

  return name;
};

@end

//====================================================================
@implementation NSObject (NSObjectVoid)
//--------------------------------------------------------------------
-(id)nilMethod
{
  return nil;
};

//--------------------------------------------------------------------
+(id)nilMethod
{
  return nil;
};

#ifndef GNUSTEP_BASE_LIBRARY
// defined in gnustep-base NSObject
//--------------------------------------------------------------------
-(NSString*)className
{
  return NSStringFromClass([self class]);
};
#endif

//--------------------------------------------------------------------
+(NSString*)className
{
  return NSStringFromClass([self class]);
};

//--------------------------------------------------------------------
-(id)performSelectorIfPossible:(SEL)aSelector
{
  if ([self respondsToSelector:aSelector])
    return [self performSelector:aSelector];
  else
    return nil;
};

//--------------------------------------------------------------------
-(id)performSelectorIfPossible:(SEL)aSelector
                    withObject:(id)anObject
{
  if ([self respondsToSelector:aSelector])
    return [self performSelector:aSelector
                 withObject:anObject];
  else
    return nil;
};

//--------------------------------------------------------------------
-(id)performSelectorIfPossible:(SEL)aSelector
                    withObject:(id)object1
                    withObject:(id)object2
{
  if ([self respondsToSelector:aSelector])
    return [self performSelector:aSelector
                 withObject:object1
                 withObject:object2];
  else
    return nil;
};


@end

//====================================================================

#ifdef GNUSTEP
@implementation NSThread (Debugging)

//--------------------------------------------------------------------
- (NSString *)description
{
  /* This guards us from associating the wrong objc_thread_id()
     when other threads invoke description on us.  */
  if (self == [NSThread currentThread])
    {
        return (*nsString_stringWithFormatIMP)(nsStringClass,stringWithFormatSEL, @"<%s: %p>",
                                               GSClassNameFromObject(self),
                                               self);
    }
  return [super description];
}
@end
#endif

//--------------------------------------------------------------------
static NSString *
volatileInternalDescription(NSLock *self)
{
  return [self description];
}

//--------------------------------------------------------------------
BOOL
loggedLockBeforeDateFromFunctionInFileInLine(id self,
					     BOOL try,
					     NSDate *limit, 
					     const char *file,
					     const char *function,
					     long line)
{
  BOOL isLocked = YES;
  NSThread *thread;

  thread = [NSThread currentThread];

  if (limit == nil)
    {
      if (try == YES)
	{
	  isLocked = [self tryLock];
	}
      else
	{
	  NS_DURING
	    [self lock];
	  NS_HANDLER
	    {
	      [localException raise];
	    }
	  NS_ENDHANDLER
	}
    }
  else
    {
      isLocked = [self lockBeforeDate: limit];

      if (try == NO && isLocked == NO)
	{
	  NSString *name;

	  NSDebugFLLog(@"locking",
		       @"tried lock FAILED thread %@ "
		       @"date:%@ file:%s function:%s line:%li "
		       @"lock:%@ ",
		       thread, 
		       limit, file, function, line, 
		       volatileInternalDescription(self));

	  name = NSStringFromClass([self class]);
	  name = [name stringByAppendingString:@"Exception"];

	  [NSException raise: name 
		       format: @"lockBeforeDate (%@) failed", limit];
	}
    }

  NSDebugFLLog(@"locking",
	       @"%@ %@ thread %@ "
	       @"date:%@ file:%s function:%s line:%li "
	       @"result:%d lock:%@",
	       (try ? @"tried lock" : @"lock"),
	       (isLocked ? @"SUCCEEDED" : @"FAILED"),
	       thread,
	       limit, file, function, line,
	       isLocked, volatileInternalDescription(self));

  return isLocked;
}

//--------------------------------------------------------------------
void
loggedUnlockFromFunctionInFileInLine(id self,
				     const char *file,
				     const char *function,
				     long line)
{
    NSThread *thread;
    
    thread = [NSThread currentThread];
    
    NSDebugFLLog(@"locking",
                 @"unlock thread %@ "
                 @"file:%s function:%s line:%li "
                 @"lock:%@",
                 thread,
                 file, function, line,
                 volatileInternalDescription(self));
    [self unlock];
    NSDebugFLLog(@"locking",
                 @"unlock SUCCEEDED thread %@ "
                 @"file:%s function:%s line:%li "
                 @"lock:%@",
                 thread,
                 file, function, line, 
                 volatileInternalDescription(self));
    
}

//====================================================================
@implementation NSArray (NSPerformSelectorWith2Objects)

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector
                       withObject:(id)object1
                       withObject:(id)object2
{
  NSUInteger i = [self count];
  while (i-- > 0)
    [[self objectAtIndex:i]performSelector:selector
                           withObject:object1
                           withObject:object2];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
{
  NSUInteger i = [self count];
  while (i-->0)
    [[self objectAtIndex: i] performSelectorIfPossible:aSelector];
}

//--------------------------------------------------------------------
-(void)makeObjectsPerformIfPossible:(SEL)aSelector
{
   [self makeObjectsPerformSelectorIfPossible:aSelector];
}

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)argument
{
  NSUInteger i = [self count];
  while (i-->0)
    [[self objectAtIndex: i] performSelectorIfPossible:aSelector
                             withObject:argument];
}

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)argument1
                                 withObject:(id)argument2
{
  NSUInteger i = [self count];
  while (i-->0)
    [[self objectAtIndex: i] performSelectorIfPossible:aSelector
                             withObject:argument1
                             withObject:argument2];
}

//--------------------------------------------------------------------
-(void)makeObjectsPerformIfPossible:(SEL)aSelector
                         withObject:(id)argument
{
  [self makeObjectsPerformSelectorIfPossible:aSelector
        withObject: argument];
}


@end

//====================================================================
@implementation NSDictionary (NSPerformSelector)

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector
{
  NSArray* array=[self allValues];
  [array makeObjectsPerformSelector:selector];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector
                       withObject:(id)object
{
  NSArray* array=[self allValues];
  [array makeObjectsPerformSelector:selector
         withObject:object];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector
                       withObject:(id)object1
                       withObject:(id)object2
{
  NSArray* array=[self allValues];
  [array makeObjectsPerformSelector:selector
         withObject:object1
         withObject:object2];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
{
  NSArray* array=[self allValues];
  [array makeObjectsPerformSelectorIfPossible:aSelector];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformIfPossible:(SEL)aSelector
{
  NSArray* array=[self allValues];
  [array makeObjectsPerformSelectorIfPossible:aSelector];
};


//--------------------------------------------------------------------
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)object
{
  NSArray* array=[self allValues];
  [array makeObjectsPerformSelectorIfPossible:aSelector
         withObject:object];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformIfPossible:(SEL)aSelector
                         withObject:(id)argument
{
  NSArray* array=[self allValues];
  [array makeObjectsPerformSelectorIfPossible:aSelector
         withObject:argument];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)object1
                                 withObject:(id)object2
{
  NSArray* array=[self allValues];
  [array makeObjectsPerformSelectorIfPossible:aSelector
         withObject:object1
         withObject:object2];
};


@end

//--------------------------------------------------------------------
NSString* GSWGetDefaultDocRoot()
{
  NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
  NSDictionary* gsweb=[userDefaults objectForKey:@"GSWeb"];
  NSString* rootDoc=[gsweb objectForKey:@"rootDoc"];
  if (!rootDoc)
    rootDoc=[nsStringClass stringWithString:@"/home/httpd/gsweb"];
  return rootDoc;
};

//===================================================================================
@implementation NSDictionary (SBDictionary)

//--------------------------------------------------------------------
-(id)		objectForKey:(id)key
	   withDefaultObject:(id)defaultObject
{
  id object=[self objectForKey:key];
  if (object)
    return object;
  else
    return defaultObject;
};

//--------------------------------------------------------------------
+(NSDictionary*)dictionaryWithDictionary:(NSDictionary*)dictionary
         andDefaultEntriesFromDictionary:(NSDictionary*)dictionaryDefaults
{
  NSMutableDictionary* dict=nil;
  if (dictionary)
    {
      dict=[[dictionary mutableCopy]autorelease];
      [dict addDefaultEntriesFromDictionary:dictionaryDefaults];
      dict=[NSDictionary dictionaryWithDictionary:dict];
    }
  else
    dict=[NSDictionary dictionaryWithDictionary:dictionaryDefaults];
  return dict;
};

//--------------------------------------------------------------------
-(NSDictionary*)dictionaryBySettingObject:(id)object
                                   forKey:(id)key
{
  NSMutableDictionary* dict=[[self mutableCopy]autorelease];
  [dict setObject:object
        forKey:key];
  dict=[NSDictionary dictionaryWithDictionary:dict];
  return dict;
};

//--------------------------------------------------------------------
-(NSDictionary*)dictionaryByAddingEntriesFromDictionary:(NSDictionary*)dictionary
{
  NSMutableDictionary* dict=[[self mutableCopy]autorelease];
  [dict addEntriesFromDictionary:dictionary];
  dict=[NSDictionary dictionaryWithDictionary:dict];
  return dict;
};

@end

//====================================================================
@implementation NSMutableDictionary (SBMutableDictionary)

//--------------------------------------------------------------------
-(void)setDefaultObject:(id)object
                 forKey:(id)key
{
  if (![self objectForKey:key])
	[self setObject:object
              forKey:key];
};

//--------------------------------------------------------------------
-(void)addDefaultEntriesFromDictionary:(NSDictionary*)dictionary
{
  id key=nil;
  NSEnumerator* anEnum = [dictionary keyEnumerator];
  while ((key=[anEnum nextObject]))
    [self setDefaultObject:[dictionary objectForKey:key]
          forKey:key];
};

//--------------------------------------------------------------------
-(NSDictionary*)extractObjectsForKeysWithPrefix:(NSString*)prefix
                                   removePrefix:(BOOL)removePrefix
{
  NSMutableDictionary* newDictionary=nil;
  NSEnumerator *enumerator = nil;
  NSString* key=nil;
  NSString* newKey=nil;
  id value=nil;
  newDictionary=(NSMutableDictionary*)[NSMutableDictionary dictionary];
  enumerator = [self keyEnumerator];
  while ((key = [enumerator nextObject]))
    {
      NSDebugMLLog(@"associations",@"key=%@",key);
      if ([key hasPrefix:prefix])
        {
          value=[self objectForKey:key];
          NSDebugMLLog(@"associations",@"value=%@",value);
          if (removePrefix)
            newKey=[key stringByDeletingPrefix:prefix];
          else
            newKey=key;
          [newDictionary setObject:value
                          forKey:newKey];
          [self removeObjectForKey:key];
        };
    };
  newDictionary=[NSDictionary dictionaryWithDictionary:newDictionary];
  return newDictionary;
};


@end


//===================================================================================
@implementation NSString (SBGoodPath)

//--------------------------------------------------------------------
-(NSString*)stringGoodPath
{
  NSString* good=[self stringByStandardizingPath];
  while([good hasSuffix:@"/."])
    {
      if ([good length]>2)
        good=[good stringByDeletingSuffix:@"/."];
      else
        good=[nsStringClass stringWithString:@"/"];
    };
  return good;
};
@end

//====================================================================
//TODO
#ifdef GNUSTEP
@implementation NSUserDefaults (Description)

//--------------------------------------------------------------------
-(NSString*)description
{
  return (*nsString_stringWithFormatIMP)(nsStringClass,stringWithFormatSEL,@"<%s %p - searchList:\n%@\n persDomains:\n%@\n tempDomains:\n%@\n changedDomains:\n%@\n dictionaryRep:\n%@\n defaultsDatabase:\n%@\n>",
                   object_getClassName(self),
                   (void*)self,
                   _searchList,
                   _persDomains,
                   _tempDomains,
                   _changedDomains,
                   _dictionaryRep,
                   _defaultsDatabase);
};

@end
#endif

//====================================================================
@implementation NSDictionary (FromNSArray)

//--------------------------------------------------------------------
+(id)dictionaryWithArray:(NSArray*)array
              onSelector:(SEL)sel
{
  NSMutableDictionary* dict=[NSMutableDictionary dictionary];
  int count=[array count];
  int i=0;
  id object=nil;
  id key=nil;
  for(i=0;i<count;i++)
    {
      //TODO optimiser
      object=[array objectAtIndex:i];
      key=[object performSelector:sel];
      NSAssert1(key,@"NSDictionary dictionaryWithArray: no key for object:%@",object);
      [dict setObject:object
            forKey:key];
    };
  return [self dictionaryWithDictionary:dict];
};

//--------------------------------------------------------------------
+(id)dictionaryWithArray:(NSArray*)array
              onSelector:(SEL)sel
              withObject:(id)anObject
{
  NSMutableDictionary* dict=[NSMutableDictionary dictionary];
  int count=[array count];
  int i=0;
  id object=nil;
  id key=nil;
  for(i=0;i<count;i++)
    {
      //TODO optimiser
      object=[array objectAtIndex:i];
      key=[object performSelector:sel
                  withObject:anObject];
      NSAssert1(key,@"NSDictionary dictionaryWithArray: no key for object:%@",object);
      [dict setObject:object
            forKey:key];
    };
  return [self dictionaryWithDictionary:dict];
};
@end

//====================================================================
@implementation NSNumber (SBNumber)

//--------------------------------------------------------------------
+(NSNumber*)maxValueOf:(NSNumber*)val0
                   and:(NSNumber*)val1
{
  NSComparisonResult compare=NSOrderedSame;
  NSAssert(val0,@"val0 can't be nil");
  NSAssert(val1,@"val1 can't be nil");
  NSAssert([val0 isKindOfClass:nsNumberClass],@"val0 must't be a NSNumber");
  NSAssert([val1 isKindOfClass:nsNumberClass],@"val1 must't be a NSNumber");
  compare=[val0 compare:val1];
  if (compare==NSOrderedAscending)
    return val1;
  else
    return val0;
};

//--------------------------------------------------------------------
+(NSNumber*)minValueOf:(NSNumber*)val0
                   and:(NSNumber*)val1
{
  NSComparisonResult compare=NSOrderedSame;
  NSAssert(val0,@"val0 can't be nil");
  NSAssert(val1,@"val1 can't be nil");
  NSAssert([val0 isKindOfClass:nsNumberClass],@"val0 must't be a NSNumber");
  NSAssert([val1 isKindOfClass:nsNumberClass],@"val1 must't be a NSNumber");
  compare=[val0 compare:val1];
  if (compare==NSOrderedDescending)
    return val1;
  else
    return val0;
};

@end

//====================================================================
@implementation NSData (SBNSData)

//--------------------------------------------------------------------
-(NSRange)rangeOfData:(NSData*)data
{
  NSRange all =NSMakeRange(0,[self length]);
  return [self rangeOfData:data
               options:0
               range:all];
}

//--------------------------------------------------------------------
-(NSRange)rangeOfData:(NSData*)data
              options:(NSUInteger)mask
{
  NSRange all = NSMakeRange(0,[self length]);
  return [self rangeOfData:data
               options:mask
               range:all];
}

//--------------------------------------------------------------------
-(NSRange)rangeOfData:(NSData *)aData
              options:(NSUInteger)mask
                range:(NSRange)aRange
{
  NSRange range=NSMakeRange(NSNotFound,0);
  NSDebugFLog(@"self=%@",self);
  NSDebugFLog(@"aData=%@",aData);
  NSDebugFLog(@"mask=%"PRIuPTR,mask);
  NSDebugFLog(@"aRange=(%"PRIuPTR",%"PRIuPTR")",aRange.location,aRange.length);
  if (aData)
    {
      int aDataLength=[aData length];
      int selfLength=[self length];
      NSDebugFLog(@"aDataLength=%d",aDataLength);
      NSDebugFLog(@"selfLength=%d",selfLength);
      if (aRange.location+aRange.length>selfLength)
        [NSException raise:NSInvalidArgumentException format:@"Bad Range (%"PRIuPTR",%"PRIuPTR") for self length %d",
                     aRange.location,
                     aRange.length,
                     selfLength];
      else if (aDataLength>0)		
        {
          BOOL reverse=((mask&NSBackwardsSearch)==NSBackwardsSearch);
          BOOL anchored=((mask&NSAnchoredSearch)==NSAnchoredSearch);
          const void* selfBytes=[self bytes];
          const void* aDataBytes=[aData bytes];
          NSDebugFLog(@"reverse=%d",(int)reverse);
          NSDebugFLog(@"anchored=%d",(int)anchored);
          if (anchored)
            {
              // Can be found ?
              if (aDataLength<=aRange.length)
                {
                  if (reverse)
                    {
                      if (memcmp(selfBytes+aRange.location-aDataLength,
                                 aDataBytes,
                                 aDataLength)==0)
                        {
                          range=NSMakeRange(selfLength-aDataLength,aDataLength);
                        };
                    }
                  else
                    {
                      if (memcmp(selfBytes+aRange.location,
                                 aDataBytes,
                                 aDataLength))
                        {
                          range=NSMakeRange(0,aDataLength);
                        };
                    };
                };
            }
          else
            {
              if (reverse)
                {
                  int i=0;
                  int first=(aRange.location+aDataLength);
                  for(i=aRange.location+aRange.length-1;i>=first && range.length==0;i--)
                    {
                      if (((unsigned char*)selfBytes)[i]==((unsigned char*)aDataBytes)[aDataLength-1])
                        {
                          if (memcmp(selfBytes+i-aDataLength,aDataBytes,aDataLength)==0)
                            {
                              range=NSMakeRange(i-aDataLength,aDataLength);
                            };
                        };
                    };
                }
              else
                {
                  int i=0;
                  int last=aRange.location+aRange.length-aDataLength;

                  for(i=aRange.location;i<=last && range.length==0;i++)
                    {
                      if (((unsigned char*)selfBytes)[i]==((unsigned char*)aDataBytes)[0])
                        {
                          if (memcmp(selfBytes+i,aDataBytes,aDataLength)==0)
                            {
                              range=NSMakeRange(i,aDataLength);
                            };
                        };
                    };
                };
            };
        };
    }
  else
    [NSException raise:NSInvalidArgumentException 
                 format: @"range of nil"];  
  return range;
}

//--------------------------------------------------------------------
-(NSArray*)componentsSeparatedByData:(NSData*)aSeparator
{
  NSRange search, complete;
  NSRange found;
  NSData* tmpData=nil;
  NSMutableArray *array = [NSMutableArray array];

  search=NSMakeRange(0, [self length]);
  complete=search;
  found=[self rangeOfData:aSeparator];

  while (found.length)
    {
      NSRange current;
      current = NSMakeRange (search.location,
                             found.location-search.location);

      tmpData=[self subdataWithRange:current];
      [array addObject:tmpData];
      search = NSMakeRange (found.location + found.length,
                            complete.length - found.location - found.length);
      found = [self rangeOfData:aSeparator
                    options: 0
                    range:search];
    }
  // Add the last search data range
  tmpData=[self subdataWithRange:search];
  [array addObject:tmpData];

  return [NSArray arrayWithArray:array];
};

//--------------------------------------------------------------------
-(NSData*)dataByDeletingFirstBytesCount:(NSUInteger)bytesCount
{
  NSMutableData* tmpdata=[self mutableCopy];
  [tmpdata deleteFirstBytesCount:bytesCount];
  return [NSData dataWithData:tmpdata];
};

//--------------------------------------------------------------------
-(NSData*)dataByDeletingLastBytesCount:(NSUInteger)bytesCount
{
  NSMutableData* tmpdata=[self mutableCopy];
  [tmpdata deleteLastBytesCount:bytesCount];
  return [NSData dataWithData:tmpdata];
};

@end

//====================================================================
@implementation NSMutableData (SBNSData)

//--------------------------------------------------------------------
-(void)deleteFirstBytesCount:(NSUInteger)bytesCount
{
  void* mutableBytes=NULL;
  NSUInteger length=[self length];
  NSAssert2(length>=bytesCount,
            @"Can't delete %"PRIuPTR" first bytes from a data of length %"PRIuPTR,
            bytesCount,length);
  mutableBytes=[self mutableBytes];
  memmove(mutableBytes,mutableBytes+bytesCount,bytesCount);
  [self setLength:length-bytesCount];
};

//--------------------------------------------------------------------
-(void)deleteLastBytesCount:(NSUInteger)bytesCount;
{
  NSUInteger length=[self length];
  NSAssert2(length>=bytesCount,
            @"Can't delete %"PRIuPTR" last bytes from a data of length %"PRIuPTR,
            bytesCount,length);
  [self setLength:length-bytesCount];
};
@end


//====================================================================
@implementation NSFooNumberFormatter

//--------------------------------------------------------------------
-(id)initType:(NSNumFmtType)type
{
  if ((self=[super init]))
    {
      _type=type;
    };
  return self;
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  NSFooNumberFormatter* clone = [[isa allocWithZone:zone] init];
  if (clone)
    {
      clone->_type=_type;
    };
  return clone;
};

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder
{
  [super encodeWithCoder:coder];
  [coder encodeValueOfObjCType: @encode(int) at: &_type];
}

//--------------------------------------------------------------------
-(id)initWithCoder: (NSCoder*)coder
{
  if (([super initWithCoder:coder]))
    {
      [coder decodeValueOfObjCType: @encode(int) at: &_type];
    };
  return self;
}

//--------------------------------------------------------------------
-(NSString*)stringForObjectValue:(id)anObject
{
  NSString* string=nil;
  if ([anObject isKindOfClass:nsStringClass])
    string=anObject;
  else if (anObject)
    {
      switch(_type)
        {
        case NSNumFmtType__Int:
          if ([anObject isKindOfClass:nsNumberClass])
            {
              int value=[anObject intValue];
              string=GSWIntToNSString(value);
            }
          else if ([anObject respondsToSelector:@selector(intValue)])
            {
              int value=[anObject intValue];
              string=GSWIntToNSString(value);
            }
          else if ([anObject respondsToSelector:@selector(floatValue)])
            {
              int value=(int)[anObject floatValue];
              string=GSWIntToNSString(value);
            }
          else if ([anObject respondsToSelector:@selector(doubleValue)])
            {
              int value=(int)[anObject doubleValue];
              string=GSWIntToNSString(value);
            }
          else
            {
//              LOGSeriousError(@"Can't convert %@ of class %@ to string",
//                              anObject,
//                              [anObject class]);
              string=@"***";
            };
          break;
        case NSNumFmtType__Float:
          if ([anObject isKindOfClass:nsNumberClass])
            {
              double value=[anObject doubleValue];
              string=(*nsString_stringWithFormatIMP)(nsStringClass,stringWithFormatSEL,@"%.2f",value);
            }
          else if ([anObject respondsToSelector:@selector(intValue)])
            {
              int value=[anObject intValue];
              string=[GSWIntToNSString(value) stringByAppendingString:@".00"];
            }
          else if ([anObject respondsToSelector:@selector(floatValue)])
            {
              double value=(double)[anObject floatValue];
              string=(*nsString_stringWithFormatIMP)(nsStringClass,stringWithFormatSEL,@"%.2f",value);
            }
          else if ([anObject respondsToSelector:@selector(doubleValue)])
            {
              double value=[anObject doubleValue];
              string=(*nsString_stringWithFormatIMP)(nsStringClass,stringWithFormatSEL,@"%.2f",value);
            }
          else
            {
//              LOGSeriousError(@"Can't convert %@ of class %@ to string",
//                              anObject,
//                              [anObject class]);
              string=@"***";
            };
          break;
        case NSNumFmtType__Unknown:
        default:
//          LOGSeriousError(@"Unknown type %d to convert %@ to string",
//                          (int)_type,
//                          anObject);
          string=@"***";
          break;
        };
    };
  return string;
};

//--------------------------------------------------------------------
-(BOOL)getObjectValue:(id*)anObject
            forString:(NSString*)string
     errorDescription:(NSString**)error
{
  BOOL ok=NO;
  NSAssert(anObject,@"No value* to return");
  NSAssert(error,@"No error* to return");
  *anObject=nil;
  *error=nil;
  switch(_type)
    {
    case NSNumFmtType__Int:
      *anObject=GSWIntNumber([string intValue]);
      ok=YES;
      break;
    case NSNumFmtType__Float:
      *anObject=[nsNumberClass numberWithFloat:[string floatValue]];
      ok=YES;
      break;
    case NSNumFmtType__Unknown:
    default:	  
//      LOGSeriousError(@"Unknown type %d to convert from string %@",
//                      (int)_type,
//                      string);
      *error = @"Unknown type";
      break;
    };
  return ok;
};

@end


//====================================================================
@implementation NSData (Base64)

//--------------------------------------------------------------------
- (NSString*) base64Representation
{
  return [[[nsStringClass alloc]initWithData:[GSMimeDocument encodeBase64:self]
                                encoding:NSASCIIStringEncoding] autorelease];
};

//--------------------------------------------------------------------
- (id) initWithBase64Representation: (NSString*)string
{
  return [self initWithData:[GSMimeDocument decodeBase64:[string dataUsingEncoding: NSASCIIStringEncoding]]];
};

@end

//====================================================================
@implementation NSData (Search)

//--------------------------------------------------------------------
- (NSRange) rangeOfData: (NSData *)data
                  range: (NSRange)aRange
{
  NSRange range=NSMakeRange(0,0);
  if (data == nil)
    [NSException raise: NSInvalidArgumentException format: @"range of nil"];
  else
    {
      NSUInteger selfLength=[self length];
      NSUInteger searchedLength=[data length];
      if (aRange.location+aRange.length>selfLength)
        {
        }
      else if (selfLength>0 && searchedLength>0)
        {
          const unsigned char* bytes=(const unsigned char*)[self bytes];
          const unsigned char* searchedBytes=(const unsigned char*)[data bytes];

          NSUInteger searchIndex=0;
          for(searchIndex=aRange.location;
              searchIndex<(selfLength-searchedLength) && range.length==0;
              searchIndex++)
            {
              NSUInteger i=0;
              if (bytes[searchIndex]==searchedBytes[0])
                {
                  for(i=1;i<searchedLength && bytes[searchIndex+i]==searchedBytes[i];i++);
                  if (i==searchedLength)
                    range=NSMakeRange(searchIndex,searchedLength);
                };
            };
        };
    };
  return range;
}
@end

//====================================================================
@implementation NSMutableData (Replace)

//--------------------------------------------------------------------
- (NSUInteger) replaceOccurrencesOfData: (NSData*)replace
                                 withData: (NSData*)by
                                    range: (NSRange)searchRange
{
  NSRange       range;
  NSUInteger  count = 0;

  if (replace == nil)
    {
      [NSException raise: NSInvalidArgumentException
                  format: @"%@ nil search string", NSStringFromSelector(_cmd)];
    }
  if (by == nil)
    {
      [NSException raise: NSInvalidArgumentException
                  format: @"%@ nil replace string", NSStringFromSelector(_cmd)];
    }
  range = [self rangeOfData: replace 
                range: searchRange];

  if (range.length > 0)
    {
      NSUInteger  byLen = [by length];
      const void* byBytes=[by bytes];

      do
        {
          NSUInteger      newEnd;
          count++;
          [self replaceBytesInRange:range
                withBytes:byBytes
                length:byLen];

          newEnd = NSMaxRange(searchRange) + byLen - range.length;
          searchRange.location = range.location + byLen;
          searchRange.length = newEnd - searchRange.location;

          range = [self rangeOfData: replace 
                        range: searchRange];
        }
      while (range.length > 0);
    }
  return count;
}
@end

//====================================================================
// this should be in Gnustep base / extensions

@implementation NSString (EncodingDataExt)

//--------------------------------------------------------------------
+ (id)stringWithContentsOfFile:(NSString *)path
                      encoding:(NSStringEncoding)encoding
{
  NSData   * tmpData = nil;
  NSString * tmpString = nil;
  
  if ((tmpData = [NSData dataWithContentsOfFile: path]))
    {
      tmpString = [nsStringClass alloc];
      tmpString = [tmpString initWithData:tmpData 
                             encoding:encoding];
      if (!tmpString) {
        NSLog(@"%s NO STRING for path '%@' encoding:%"PRIuPTR, __PRETTY_FUNCTION__, path, (NSUInteger)encoding);
        
        [NSException raise:NSInvalidArgumentException 
                     format:@"%s: could not open convert file contents '%@' non-lossy to encoding %"PRIuPTR,
                     __PRETTY_FUNCTION__, path, (NSUInteger)encoding];  
        
      }                               
      AUTORELEASE(tmpString);
    }
  
  return tmpString;
}

@end

//====================================================================
NSString* NSStringWithObject(id object)
{
  NSString* string=nil;
  NSCAssert(nsMutableStringClass,@"GSWUtils not initialized");
  if (object)
    {
      if ([object isKindOfClass:nsMutableStringClass])
        // why wasting memory? -- dw
        // string=AUTORELEASE([object copy]);
        string=(NSString*)object;
      else if ([object isKindOfClass:nsStringClass])
        string=(NSString*)object;
      else if ([object isKindOfClass:eoNullClass])
        string=@"";
      else if ([object respondsToSelector:@selector(stringValue)])
        string=[object stringValue];
      else if ([object respondsToSelector:@selector(description)])
        string=[object description];
      else
        string=object;
    };
  return string;
};
