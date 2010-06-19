/** GSWUtils.h - <title>GSWeb: Utilities</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

#ifndef _GSWebUtils_h__
#define _GSWebUtils_h__

#include <sys/time.h>

#define CONST
#ifndef max
#define max(a,b) ((a) > (b) ? (a) : (b))
#endif
#ifndef min
#define min(a,b) ((a) < (b) ? (a) : (b))
#endif

#define IsStyle(__value,__style) \
  ((((__value)&(__style))==(__style)) ? YES : NO)
#define IsNumberStyle(__value,__style) \
  (((([__value unsignedIntValue])&(__style))==(__style)) ? YES : NO)

#define VOID_RCSID	\
static void VoidUseRCSId() { rcsId[0]=0; };

#ifndef BYTE_DEFINED
typedef unsigned char BYTE;
#define BYTE_DEFINED
#endif
#ifndef UINTs_DEFINED
typedef NSUInteger UINT;
typedef unsigned char UINT8;
typedef unsigned short UINT16;
typedef NSUInteger UINT32;
#define UINTs_DEFINED
#endif

// Function which call various initialization functions
GSWEB_EXPORT void GSWInitializeAllMisc();

// Various IMP types declaration
typedef short (*GSWIMP_SHORT)(id, SEL, ...);
typedef int (*GSWIMP_INT)(id, SEL, ...);
typedef long (*GSWIMP_LONG)(id, SEL, ...);
typedef BOOL (*GSWIMP_BOOL)(id, SEL, ...);
typedef float (*GSWIMP_FLOAT)(id, SEL, ...);
typedef double (*GSWIMP_DOUBLE)(id, SEL, ...);

GSWEB_EXPORT NSNumber* GSWNumber_Yes();
GSWEB_EXPORT NSNumber* GSWNumber_No();
#define GSWNumberYes 	(GSWNumber_Yes())
#define GSWNumberNo 	(GSWNumber_No())

#define GSW_LOCK_LIMIT [NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]

GSWEB_EXPORT char* GSWIntToString(char* buffer,NSUInteger bufferSize,int value,NSUInteger* resultLength);
GSWEB_EXPORT NSString* GSWIntToNSString(int value);
GSWEB_EXPORT NSNumber* GSWIntNumber(int value);

#define ClassIsKindOfClass(classA,classB) GSObjCIsKindOf(classA,classB)

typedef long long GSWTime; // usec since Epoch

#ifndef USEC_PER_SEC
#define USEC_PER_SEC	((GSWTime)1000000)
#endif

#define GSWTime_makeTimeFromSecAndUSec(sec,usec)	((GSWTime)(sec)*USEC_PER_SEC+(GSWTime)(usec))

GSWEB_EXPORT GSWTime GSWTime_now();
#define GSWTime_zero()	((GSWTime)0)
GSWEB_EXPORT NSString* GSWTime_format(GSWTime t); // 2003/12/24 22:12:25.123
GSWEB_EXPORT time_t GSWTime_secPart(GSWTime t);
GSWEB_EXPORT long GSWTime_usecPart(GSWTime t);
GSWEB_EXPORT long GSWTime_msecPart(GSWTime t);

#define GSWTime_floatSec(t) ((double)(((double)GSWTime_secPart(t))+((double)GSWTime_usecPart(t))/USEC_PER_SEC))


GSWEB_EXPORT void
ExceptionRaiseFn(const char *func, 
		 const char *file,
		 int line,
		 NSString* name_,
		 NSString* format_,
		 ...);
GSWEB_EXPORT void
ExceptionRaiseFn0(const char *func, 
		  const char *file,
		  int line,
		  NSString* name_,
		  NSString* format_);

GSWEB_EXPORT void
ValidationExceptionRaiseFn(const char *func, 
			   const char *file,
			   int line,
			   NSString* name_,
			   NSString* message_,
			   NSString* format_,
			   ...);
GSWEB_EXPORT void
ValidationExceptionRaiseFn0(const char *func, 
			    const char *file,
			    int line,
			    NSString* name_,
			    NSString* message_,
			    NSString* format_);

#define ExceptionRaise(name_, format_, args...) \
  { ExceptionRaiseFn(__PRETTY_FUNCTION__, __FILE__, __LINE__, \
                     name_,format_, ## args); }

#define ExceptionRaise0(name_, format_) \
  { ExceptionRaiseFn0(__PRETTY_FUNCTION__, __FILE__, __LINE__, \
                      name_,format_); }

#define ValidationExceptionRaise(name_,message_, format_, args...) \
  { ValidationExceptionRaiseFn(__PRETTY_FUNCTION__, __FILE__, __LINE__,\
                               name_,message_,format_, ## args); }

#define ValidationExceptionRaise0(name_,message_, format_) \
  { ValidationExceptionRaiseFn0(__PRETTY_FUNCTION__, __FILE__, __LINE__,\
                                name_,message_,format_); }

GSWEB_EXPORT BOOL boolValueFor(id id_);
GSWEB_EXPORT BOOL boolValueWithDefaultFor(id id_,BOOL defaultValue);
//GSWEB_EXPORT BOOLNB boolNbFor(BOOL value_);
GSWEB_EXPORT BOOL isHeaderKeysEqual(NSString* headerKey,NSString* testKey);
GSWEB_EXPORT BOOL SBIsEqual(id id1,id id2);
GSWEB_EXPORT BOOL SBIsValueEqual(id id1,id id2);
GSWEB_EXPORT BOOL SBIsValueIsIn(id id1,id id2);

GSWEB_EXPORT NSTimeInterval NSTimeIntervalFromTimeVal(struct timeval* tv);
GSWEB_EXPORT void NSTimeIntervalSleep(NSTimeInterval ti);

GSWEB_EXPORT NSString* GSWGetDefaultDocRoot();

//====================================================================
@interface NSException (NSBuild)
+(NSException*)exceptionWithName:(NSString *)name
                          format:(NSString *)format,...;
@end


#define ExceptionByAddingUserInfoObjectFrameInfo(_exception,format_, args...) \
[(_exception) exceptionByAddingUserInfoFrameInfoObject:self sel:_cmd \
              file:__FILE__ line:__LINE__ format:format_, ## args]

#define ExceptionByAddingUserInfoObjectFrameInfo0(_exception,format_) \
[(_exception) exceptionByAddingUserInfoFrameInfoObject:self sel:_cmd \
              file:__FILE__ line:__LINE__ format:format_]

#define ExceptionByAddingUserInfoFunctionFrameInfo(format_, args...) \
[(_exception) exceptionByAddingUserInfoFrameInfoFunction:__PRETTY_FUNCTION__ \
              file:__FILE__ line:__LINE__ format:format_, ## args]

#define ExceptionByAddingUserInfoFunctionFrameInfo0(format_) \
[(_exception) exceptionByAddingUserInfoFrameInfoFunction:__PRETTY_FUNCTION__ \
              file:__FILE__ line:__LINE__ format:format_]

//====================================================================
@interface NSException (NSExceptionUserInfoAdd)

-(NSException*)exceptionByAddingUserInfo:(NSDictionary*)userInfo;
-(NSException*)exceptionByAddingUserInfoKey:(id)key
                                     format:(NSString*)format,...;
-(NSException*)exceptionByAddingToUserInfoKey:(id)key
                                       format:(NSString*)format,...;
-(NSException*)exceptionByAddingUserInfoFrameInfo:(NSString*)frameInfo;
-(NSException*)exceptionByAddingUserInfoFrameInfoFormat:(NSString*)format,...;
-(NSException*)exceptionByAddingUserInfoFrameInfoObject:(id)obj
                                                    sel:(SEL)sel
                                                   file:(const char*)file
                                                   line:(int)line
                                                 format:(NSString*)format,...;
-(NSException*)exceptionByAddingUserInfoFrameInfoFunction:(const char*)fn
                                                     file:(const char*)file
                                                     line:(int)line
                                                   format:(NSString*)format,...;
-(BOOL)isValidationException;
@end

//====================================================================
@interface NSDate (NSDateHTMLDescription)
-(NSString*)htmlDescription;
@end

//====================================================================
@interface NSDictionary (SBDictionary)
-(id)		objectForKey:(id)key
	   withDefaultObject:(id)defaultObject;
+(NSDictionary*)dictionaryWithDictionary:(NSDictionary*)dictionary
         andDefaultEntriesFromDictionary:(NSDictionary*)dictionaryDefaults;
-(NSDictionary*)dictionaryBySettingObject:(id)object
                                   forKey:(id)key;
-(NSDictionary*)dictionaryByAddingEntriesFromDictionary:(NSDictionary*)dictionary;
@end

//====================================================================
@interface NSMutableDictionary (SBMutableDictionary)
-(void)setDefaultObject:(id)object
                 forKey:(id)key;
-(void)addDefaultEntriesFromDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)extractObjectsForKeysWithPrefix:(NSString*)prefix
                                   removePrefix:(BOOL)removePrefix;
@end

//====================================================================
@interface NSMutableOrderedArray: NSMutableArray
{
  NSMutableArray* _array;
  SEL _compareSelector;
};
-(id)initWithCompareSelector:(SEL)compareSelector;
-(void)addObject:(id)object;
-(void)addObjectsFromArray:(NSArray*)array;
-(void)insertObject:(id)object
            atIndex:(NSUInteger)index;
-(void)replaceObjectAtIndex:(NSUInteger)index
                 withObject:(id)object;
-(void)replaceObjectsInRange:(NSRange)range
        withObjectsFromArray:(NSArray*)array;
-(void)replaceObjectsInRange:(NSRange)range
        withObjectsFromArray:(NSArray*)array
                       range:(NSRange)arrayRange;
-(void)setArray:(NSArray*)array;
@end

//====================================================================
@interface NSString (SBGoodPath)
-(NSString*)stringGoodPath;
@end

//====================================================================
@interface NSObject (NSObjectVoid)
-(id)nilMethod;
+(id)nilMethod;
-(NSString*)className;
+(NSString*)className;
-(id)performSelectorIfPossible:(SEL)aSelector;
-(id)performSelectorIfPossible:(SEL)aSelector
                    withObject:(id)anObject;
-(id)performSelectorIfPossible:(SEL)aSelector
                    withObject:(id)object1
                    withObject:(id)object2;
@end

//====================================================================
@interface NSBundle (NSBundleAllFrameworks)
-(NSString*)bundleName;
@end

//====================================================================
#define LoggedLock(__lock) \
  (loggedLockBeforeDateFromFunctionInFileInLine((__lock), NO, nil, \
     __FILE__, __PRETTY_FUNCTION__, __LINE__))
#define LoggedLockBeforeDate(__lock,__limit) \
  (loggedLockBeforeDateFromFunctionInFileInLine((__lock), NO, (__limit), \
     __FILE__, __PRETTY_FUNCTION__,  __LINE__))
#define LoggedTryLock(__lock) \
  (loggedLockBeforeDateFromFunctionInFileInLine((__lock), YES, nil, \
     __FILE__, __PRETTY_FUNCTION__, __LINE__))
#define LoggedTryLockBeforeDate(__lock,__limit) \
  (loggedLockBeforeDateFromFunctionInFileInLine((__lock), YES, (__limit), \
     __FILE__, __PRETTY_FUNCTION__, __LINE__))
#define LoggedUnlock(__lock) \
  (loggedUnlockFromFunctionInFileInLine(__lock, \
     __FILE__, __PRETTY_FUNCTION__, __LINE__))

GSWEB_EXPORT BOOL
loggedLockBeforeDateFromFunctionInFileInLine(id self,
					     BOOL try,
					     NSDate *limit, 
					     const char *file,
					     const char *function,
					     long line);
GSWEB_EXPORT void
loggedUnlockFromFunctionInFileInLine(id self,
				     const char *file,
				     const char *function,
				     long line);


//====================================================================
@interface NSArray (NSPerformSelectorWith2Objects)
-(void)makeObjectsPerformSelector:(SEL)selector
                       withObject:(id)object1
                       withObject:(id)object2;

-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector;
-(void)makeObjectsPerformIfPossible:(SEL)aSelector;
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)argument;
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)argument1
                                 withObject:(id)argument2;
-(void)makeObjectsPerformIfPossible:(SEL)aSelector
                         withObject:(id)argument;

@end

//====================================================================
@interface NSDictionary (NSPerformSelector)
-(void)makeObjectsPerformSelector:(SEL)selector;
-(void)makeObjectsPerformSelector:(SEL)selector
                       withObject:(id)object;
-(void)makeObjectsPerformSelector:(SEL)selector
                       withObject:(id)object_
                       withObject:(id)object2;
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector;
-(void)makeObjectsPerformIfPossible:(SEL)aSelector;
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)argument;
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)argument1
                                 withObject:(id)argument2;
-(void)makeObjectsPerformIfPossible:(SEL)aSelector
                         withObject:(id)argument;
@end

//====================================================================
@interface NSDictionary (FromNSArray)
+(id)dictionaryWithArray:(NSArray*)array
              onSelector:(SEL)sel;
+(id)dictionaryWithArray:(NSArray*)array
              onSelector:(SEL)sel
              withObject:(id)object;
@end

//====================================================================
@interface NSNumber (SBNumber)
+(NSNumber*)maxValueOf:(NSNumber*)val0
                   and:(NSNumber*)val1;
+(NSNumber*)minValueOf:(NSNumber*)val0
                   and:(NSNumber*)val1;
@end

//====================================================================
@interface NSData (SBNSData)
-(NSRange)rangeOfData:(NSData*)data;
-(NSRange)rangeOfData:(NSData*)data
              options:(NSUInteger)mask;
-(NSRange)rangeOfData:(NSData *)aData
              options:(NSUInteger)mask
                range:(NSRange)aRange;
-(NSArray*)componentsSeparatedByData:(NSData*)separator;
-(NSData*)dataByDeletingFirstBytesCount:(NSUInteger)bytesCount;
-(NSData*)dataByDeletingLastBytesCount:(NSUInteger)bytesCount;
@end

//====================================================================
@interface NSMutableData (SBNSData)
-(void)deleteFirstBytesCount:(NSUInteger)bytesCount;
-(void)deleteLastBytesCount:(NSUInteger)bytesCount;
@end

//====================================================================
typedef enum _NSNumFmtType
{
  NSNumFmtType__Unknown	=	0,
  NSNumFmtType__Int	=	1,
  NSNumFmtType__Float	=	2,
} NSNumFmtType;

@interface NSFooNumberFormatter : NSFormatter <NSCoding, NSCopying>
{
  NSNumFmtType _type;
};

-(id)initType:(NSNumFmtType)type;
-(NSString*)stringForObjectValue:(id)anObject;
-(BOOL)getObjectValue:(id*)anObject
            forString:(NSString*)string
     errorDescription:(NSString**)error;
@end

//====================================================================
@interface NSData (Base64)
/**
 * Returns an NSString object containing an ASCII base64 representation
 * of the receiver. <br />
 * If you need the hexadecimal representation as raw byte data, use code
 * like -
 * <example>
 *   hexData = [[sourceData base64Representation]
 *     dataUsingEncoding: NSASCIIStringEncoding];
 * </example>
 */
- (NSString*) base64Representation;

/**
 * Initialises the receiver with the supplied string data which contains
 * a base64 coding of the bytes.  The parsing of the string is
 * fairly tolerant, ignoring whitespace.<br />
 * If the string does not contain one or more valid base64 characters
 * then an exception is raised. 
 */
- (id) initWithBase64Representation: (NSString*)string;

@end

//====================================================================
@interface NSData (Search)
- (NSRange) rangeOfData: (NSData *)data
                  range: (NSRange)aRange;
@end

//====================================================================
@interface NSMutableData (Replace)
- (NSUInteger) replaceOccurrencesOfData: (NSData*)replace
                                 withData: (NSData*)by
                                    range: (NSRange)searchRange;
@end

//====================================================================
// this should be in Gnustep base / extensions

@interface NSString (EncodingDataExt)

+ (id)stringWithContentsOfFile:(NSString *)path
                      encoding:(NSStringEncoding)encoding;
@end

//====================================================================
GSWEB_EXPORT NSString* NSStringWithObject(id object);

#endif // _GSWebUtils_h__
