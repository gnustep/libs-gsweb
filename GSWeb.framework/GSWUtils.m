/** GSWUtils.m - <title>GSWeb: Utilities</title>

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

#include <sys/time.h>
#include <unistd.h>
#include "stacktrace.h"
#include "attach.h"
//--------------------------------------------------------------------
BOOL ClassIsKindOfClass(Class classA,Class classB)
{
  Class class;
  for (class = classA; 
       class != Nil;
       class = class_get_super_class (class))
    {
      if (class == classB)
        return YES;
    }
  return NO;
};

//--------------------------------------------------------------------
BOOL boolValueFor(id anObject)
{
  if (anObject)
    {
      if (/*anObject==BNYES ||*/ anObject==NSTYES)
        return YES;
      else if (/*anObject==BNNO ||*/ anObject==NSTNO)
        return NO;
      else if (/*[anObject conformsTo:@protocol(NSString)]*/ [anObject isKindOfClass:[NSString class]] && [anObject length]>0)
        return ([anObject caseInsensitiveCompare: @"NO"]!=NSOrderedSame);
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
      //@protocol NSString
      else if (/*[anObject conformsTo:@protocol(NSString)]*/ [anObject isKindOfClass:[NSString class]] && [anObject length]>0)
        return ([anObject caseInsensitiveCompare: @"NO"]!=NSOrderedSame);
      else if ([anObject respondsToSelector:@selector(boolValue)])
        return ([anObject boolValue]!=NO);
      else if ([anObject respondsToSelector:@selector(intValue)])
        return ([anObject intValue]!=0);
      else if ([anObject respondsToSelector:@selector(unsignedCharValue)]) //BOOL is unsigned char
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
      if ([id1 isKindOfClass:[NSString class]])
        {
          NSString* id2String=[NSString stringWithObject:id2];
          equal=[id1 isEqualToString:id2String];
        }
      else if ([id2 isKindOfClass:[NSString class]])
        {
          NSString* id1String=[NSString stringWithObject:id1];
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

//--------------------------------------------------------------------
id GetTmpName(NSString* dir,NSString* prefix)
{
  id result=nil;
  char *pszTmpFile=tempnam([dir cString],[prefix cString]);
  if (!pszTmpFile)
    {
      //TODO
      //result=NewError(1,@"Can't get TmpFile",0,0,0);
    }
  else
    {
      result=[NSString stringWithCString:pszTmpFile];
      free(pszTmpFile);
    };
  return result;
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

NSString* pidproccontent(NSString* path)
{
  NSString* content=nil;
  char thePath[BUFSIZ*2];
  FILE* theFile = 0;
  if ([path getFileSystemRepresentation:thePath
            maxLength:sizeof(thePath)-1] == NO)
    {
      LOGSeriousError(@"Open (%@) attempt failed - bad path",
                      path);
    }
  else
    {
#if     defined(__WIN32__)
      theFile = fopen(thePath, "rb");
#else
      theFile = fopen(thePath, "r");
#endif
      if (theFile == NULL)          /* We failed to open the file. */
        {
          LOGSeriousError(@"Open (%s) attempt failed - %s",
                          thePath, strerror(errno));
        }
      else
        {
          char buff[1024]="";
          if (!fgets(buff,1024,theFile))
            {
              LOGSeriousError(@"Read (%s) attempt failed",thePath);
            }
          else
            {
              content=[NSString stringWithCString:buff];
            };
          fclose(theFile);
        };
    };
  return content;
};
void pidstat(pid_t pid, proc_t* P)
{
  NSString* filename=[NSString stringWithFormat:@"/proc/%d/stat",(int)pid];
  NSString* pidstat=pidproccontent(filename);
  NSDebugFLog(@"pidstat=%@",pidstat);
  NSDebugFLog(@"filename=%@",filename);
  NSDebugFLog(@"pid=%d",(int)pid);
  if (pidstat)
    {
      NSRange cmdEnd=[pidstat rangeOfString:@") "];
      if (cmdEnd.length>0)
        {
          NSString* pid_cmd=[pidstat substringToIndex:cmdEnd.location];
          NSDebugFLog(@"pid_cmd=%@",pid_cmd);
          if (cmdEnd.location+cmdEnd.length<[pidstat length])
            {
              NSString* stats=[pidstat substringFromIndex:cmdEnd.location+cmdEnd.length];
              /*
                char* tmp = strrchr(S, ')');        // split into "PID (cmd" and "<rest>" 
                *tmp = '\0';                        // replace trailing ')' with NUL 
                // parse these two strings separately, skipping the leading "(". 
                memset(P->cmd, 0, sizeof P->cmd);   // clear even though *P xcalloc'd ?! 
                sscanf(S, "%d (%39c", &P->pid, P->cmd);
              */
              const char* statsChars=[stats cString];
              NSDebugFLog(@"stats=%@",stats);
              sscanf(statsChars,
                     "%c %d %d %d %d %d %lu %lu %lu %lu %lu %ld %ld %ld %ld %d "
                     "%d %lu %lu %ld %lu %lu %lu %lu %lu %lu %lu %lu %LX %LX %LX %LX %lu",
                     &P->state, &P->ppid, &P->pgrp, &P->session, &P->tty, &P->tpgid,
                     &P->flags, &P->min_flt, &P->cmin_flt, &P->maj_flt, &P->cmaj_flt,
                     &P->utime, &P->stime, &P->cutime, &P->cstime, &P->priority, &P->nice,
                     &P->timeout, &P->it_real_value, &P->start_time, &P->vsize, &P->rss,
                     &P->rss_rlim, &P->start_code, &P->end_code, &P->start_stack,
                     &P->kstk_esp, &P->kstk_eip, &P->signal, &P->blocked, &P->sigignore,
                     &P->sigcatch, &P->wchan);
              if (P->tty == 0)
                P->tty = -1;  // the old notty val, update elsewhere bef. moving to 0 
              /*			  if (linux_version_code < LINUX_VERSION(1,3,39))
                                          {
                                          P->priority = 2*15 - P->priority;       // map old meanings to new 
                                          P->nice = 15 - P->nice;
                                          }
                                          if (linux_version_code < LINUX_VERSION(1,1,30) && P->tty != -1)
                                          P->tty = 4*0x100 + P->tty;              // when tty wasn't full devno 
              */
              NSDebugFLog(@"P->vsize=%lu",P->vsize);
              NSDebugFLog(@"P->rss=%lu",P->rss);
            };
        };
    };
};

void pidstatm(pid_t pid, proc_t* P)
{
  NSString* filename=[NSString stringWithFormat:@"/proc/%d/statm",(int)pid];
  NSString* pidstat=pidproccontent(filename);
  NSDebugFLog(@"pidstat=%@",pidstat);
  NSDebugFLog(@"filename=%@",filename);
  NSDebugFLog(@"pid=%d",(int)pid);
  if (pidstat)
    {
      const char* statsChars=[pidstat cString];
      NSDebugFLog(@"pidstat=%@",pidstat);
      sscanf(statsChars, "%ld %ld %ld %ld %ld %ld %ld",
             &P->size, &P->resident, &P->share,
             &P->trs, &P->lrs, &P->drs, &P->dt);
      NSDebugFLog(@"P->size=%ld",P->size);
      NSDebugFLog(@"P->resident=%ld",P->resident);
      NSDebugFLog(@"P->share=%ld",P->share);
      NSDebugFLog(@"P->trs=%ld",P->trs);
      NSDebugFLog(@"P->lrs=%ld",P->lrs);
      NSDebugFLog(@"P->drs=%ld",P->drs);
      NSDebugFLog(@"P->dt=%ld",P->dt);	  
    };
};

//--------------------------------------------------------------------
void StackTraceIFND()
{
  NSString* stackTraceString=[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"/tmp/%@.stacktrace",
                                                                          globalApplicationClassName]];
  if ([stackTraceString intValue])
    {
      StackTrace();
    };
};

//--------------------------------------------------------------------
void DebugBreakpointIFND()
{
  NSString* breakString=[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"/tmp/%@.break",
                                                                     globalApplicationClassName]];
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
  NSString* fmt =  [NSString stringWithFormat:@"File %s: %d. In %s EXCEPTION %@: %@",
                             func,line,file,name,format];
  NSString* string= nil;
  va_list args;
  va_start(args,format);
  string=[NSString stringWithFormat:fmt
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
  NSString* string =  [NSString stringWithFormat:@"File %s: %d. In %s EXCEPTION %@: %@",
                                func,line,file,name,format];
  NSLog(@"%@",string);
  StackTraceIFND();
  DebugBreakpointIFND();
  [NSException raise:name
               format:@"%@",string];
};

//--------------------------------------------------------------------
void ValidationExceptionRaiseFn(const char *func, 
                                const char *file,
                                int line,
                                NSString* name,
                                NSString* message,
                                NSString* format,
                                ...)
{
  NSException* exception=nil;
  NSString* fmt=[NSString stringWithFormat:@"File %s: %d. In %s EXCEPTION %@: %@",
                          func,line,file,name,format];
  NSString* string=nil;
  va_list args;
  va_start(args,format);
  string=[NSString stringWithFormat:fmt
                   arguments:args];
  va_end(args);
  NSLog(@"%@",string);
  exception=[NSException exceptionWithName:name
                         reason:string
                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithBool:YES],@"isValidationException",
                                                message,@"message",
                                                nil,nil]];
  StackTraceIFND();
  DebugBreakpointIFND();
  [exception raise];
};

//--------------------------------------------------------------------
void ValidationExceptionRaiseFn0(const char *func, 
                                 const char *file,
                                 int line,
                                 NSString* name,
                                 NSString* message,
                                 NSString* format)
{
  NSException* exception=nil;
  NSString* string=[NSString stringWithFormat:@"File %s: %d. In %s EXCEPTION %@: %@",
                             func,line,file,name,format];
  NSLog(@"%@",string);
  exception=[NSException exceptionWithName:name
                         reason:format
                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithBool:YES],@"isValidationException",
                                                message,@"message",
                                                nil,nil]];
  StackTraceIFND();
  DebugBreakpointIFND();
  [exception raise];
};

//====================================================================
@implementation NSException (NSBuild)
+(NSException*)exceptionWithName:(NSString*)name
                          format:(NSString*)format,...
{
  NSException* exception=nil;
  NSString* reason=nil;
  va_list args;
  va_start(args,format);
  reason=[NSString stringWithFormat:format
                   arguments:args];
  va_end(args);
  exception=[self exceptionWithName:name
                  reason:reason
                  userInfo: nil];
  return exception;
};
@end

//====================================================================
@implementation NSException (NSExceptionUserInfoAdd)

-(NSException*)exceptionByAddingUserInfo:(NSDictionary*)aUserInfo
{
  NSMutableDictionary* userInfo=[NSMutableDictionary dictionaryWithDictionary:[self userInfo]];
  [userInfo addEntriesFromDictionary:aUserInfo];
  return [[self class]exceptionWithName:[self name]
                      reason:[self reason]
                      userInfo:userInfo];
};

-(NSException*)exceptionByAddingToUserInfoKey:(id)key
                                       format:(NSString*)format,...
{
  NSException* exception=nil;
  NSString* userInfoString=nil;
  NSMutableDictionary* userInfo=nil;
  va_list args;
  LOGObjectFnStart();
  userInfo=[NSMutableDictionary dictionaryWithDictionary:[self userInfo]];
  va_start(args,format);
  userInfoString = [NSString stringWithFormat:format
                             arguments:args];
  va_end(args);
  {
    id curArray = [userInfo objectForKey:key];
    id newArray=[NSMutableArray arrayWithObject:userInfoString];
    if (!curArray)
      {
        curArray = [NSMutableArray array];
      }
    if (![curArray isKindOf:[NSMutableArray class]])
      {
        id tempObject = curArray;
        curArray = [NSMutableArray array];
        [curArray addObject:tempObject];
      }
    [newArray addObjectsFromArray:curArray];
    [userInfo setObject:newArray forKey:key];
  }
  exception=[[self class]exceptionWithName:[self name]
                         reason:[self reason]
                         userInfo:userInfo];
  LOGObjectFnStop();
  return exception;
};


-(NSException*)exceptionByAddingUserInfoKey:(id)key
                                     format:(NSString*)format,...
{
  NSException* exception=nil;
  NSString* userInfoString=nil;
  NSMutableDictionary* userInfo=nil;
  va_list args;
  LOGObjectFnStart();
  userInfo=[NSMutableDictionary dictionaryWithDictionary:[self userInfo]];
  va_start(args,format);
  userInfoString = [NSString stringWithFormat:format
                             arguments:args];
  va_end(args);
  [userInfo setObject:userInfoString
            forKey:key];
  exception=[[self class]exceptionWithName:[self name]
                         reason:[self reason]
                         userInfo:userInfo];
  LOGObjectFnStop();
  return exception;
};

-(NSException*)exceptionByAddingUserInfoFrameInfo:(NSString*)frameInfo
{
  NSException* exception=nil;
  NSMutableDictionary* userInfo=nil;
  NSArray* frameInfoArray=nil;
  LOGObjectFnStart();
  NSAssert(frameInfo,@"No frameInfo");
  userInfo=[NSMutableDictionary dictionaryWithDictionary:[self userInfo]];
  frameInfoArray=[userInfo objectForKey:@"FrameInfo"];
  if (frameInfoArray)
    frameInfoArray=[frameInfoArray arrayByAddingObject:frameInfo];
  else
    frameInfoArray=[NSArray arrayWithObject:frameInfo];
  [userInfo setObject:frameInfoArray
            forKey:@"FrameInfo"];
  exception=[[self class]exceptionWithName:[self name]
                         reason:[self reason]
                         userInfo:userInfo];
  LOGObjectFnStop();
  return exception;
};

-(NSException*)exceptionByAddingUserInfoFrameInfoFormat:(NSString*)format,...
{
  NSException* exception=nil;
  NSString* frameInfo=nil;
  va_list args;
  LOGObjectFnStart();
  va_start(args,format);
  frameInfo = [NSString stringWithFormat:format
                        arguments:args];
  va_end(args);
  exception=[self exceptionByAddingUserInfoFrameInfo:frameInfo];
  LOGObjectFnStop();
  return exception;
};

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
  LOGObjectFnStart();
  if ([obj isInstance] == YES)
    {
      c = '-';
      cls = [obj class];
    };
  fmt = [NSString stringWithFormat: @"%s: %d. In [%@ %c%@] %@",
                  file,
                  line,
                  NSStringFromClass(cls),
                  c,
                  NSStringFromSelector(sel),
                  format];
  va_start(args,format);
  string=[NSString stringWithFormat:fmt
                   arguments:args];
  va_end(args);
  exception=[self exceptionByAddingUserInfoFrameInfo:string];
  LOGObjectFnStop();
  return exception;
};

-(NSException*)exceptionByAddingUserInfoFrameInfoFunction:(const char*)fn
                                                     file:(const char*)file
                                                     line:(int)line
                                                   format:(NSString*)format,...
{
  NSException* exception=nil;
  NSString* fmt =nil;
  NSString* string= nil;
  va_list args;
  LOGObjectFnStart();
  va_start(args,format);
  fmt =  [NSString stringWithFormat:@"%s: %d. In %s %@: %@",
                   file,line,fn,format];
  string=[NSString stringWithFormat:fmt
                   arguments:args];
  va_end(args);
  exception=[self exceptionByAddingUserInfoFrameInfo:string];
  LOGObjectFnStop();
  return exception;
};

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
  LOGObjectFnNotImplemented();	//TODOFN
  if (!gmtTZ)
    NSWarnLog(@"no time zone for GMT");
  //TODO English day...
  return [self descriptionWithCalendarFormat:@"%A, %d-%b-%Y %H:%M:%S GMT"
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

- (id)initWithCapacity:(unsigned)cap
{
  if ((self=[super init]))
    {
      _array = [NSMutableArray new];
      _compareSelector=NULL;
    };
  return self;
}

- (unsigned)count
{
  return [_array count];
}

- (id)objectAtIndex:(unsigned)i
{
  return [_array objectAtIndex:i];
}

- (void)removeObjectAtIndex:(unsigned)i
{
  [_array removeObjectAtIndex:i];
}

- (void)release
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
  NSComparisonResult result=NSOrderedSame;

  for(i=0;result!=NSOrderedDescending && i<[_array count];i++)
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

  for(i=0;i<[array count];i++)
    {
      [_array addObject:[array objectAtIndex:i]];
    };
};

//--------------------------------------------------------------------
-(void)insertObject:(id)object
            atIndex:(unsigned int)index
{
  LOGException0(@"NSMutableOrderedArray doesn't support this fn");

  [NSException raise:@"NSMutableOrderedArray"
	       format:@"NSMutableOrderedArray doesn't support %s",sel_get_name(_cmd)];
};

//--------------------------------------------------------------------
-(void)replaceObjectAtIndex:(unsigned int)index
                 withObject:(id)object
{
  LOGException0(@"NSMutableOrderedArray doesn't support this fn");

  [NSException raise:@"NSMutableOrderedArray"
	       format:@"NSMutableOrderedArray doesn't support %s",sel_get_name(_cmd)];
};

//--------------------------------------------------------------------
-(void)replaceObjectsInRange:(NSRange)range
        withObjectsFromArray:(NSArray*)array
{
  LOGException0(@"NSMutableOrderedArray doesn't support this fn");

  [NSException raise:@"NSMutableOrderedArray"
	       format:@"NSMutableOrderedArray doesn't support %s",sel_get_name(_cmd)];
};

//--------------------------------------------------------------------
-(void)replaceObjectsInRange:(NSRange)range
        withObjectsFromArray:(NSArray*)array
                       range:(NSRange)arrayRange
{
  LOGException0(@"NSMutableOrderedArray doesn't support this fn");

  [NSException raise:@"NSMutableOrderedArray"
	       format:@"NSMutableOrderedArray doesn't support %s",sel_get_name(_cmd)];
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
  NSString* bundlePath=nil;
  NSString* name=nil;
  LOGObjectFnStart();
  bundlePath=[self bundlePath];
  NSDebugMLLog(@"low",@"bundlePath=%@",bundlePath);
  bundlePath=[bundlePath stringGoodPath];
  NSDebugMLLog(@"low",@"bundlePath=%@",bundlePath);
  name=[bundlePath lastPathComponent];
  NSDebugMLLog(@"low",@"name=%@",name);
  name=[name stringByDeletingPathExtension];
  NSDebugMLLog(@"low",@"name=%@",name);
  LOGObjectFnStop();
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

//--------------------------------------------------------------------
-(NSString*)className
{
  return NSStringFromClass([self class]);
};

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

extern struct PTHREAD_HANDLE* nub_get_active_thread(void);

NSString *NSLockException = @"NSLockException";

//====================================================================
@implementation NSLock (NSLockBD)

-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - ",
                   object_get_class_name(self),
                   (void*)self];
};

//--------------------------------------------------------------------
-(BOOL)isLocked
{
  BOOL isLocked=YES;
  if ([self tmptryLock])
    {
      isLocked=NO;
      [self tmpunlock];
    }
  else
    {
      NSDebugMLog(@"Locked by _mutex->owner=%p (our ThreadID=%p)",
                  (void*)_mutex->owner,
                  (void*)objc_thread_id());
    };
  return isLocked;
};

//--------------------------------------------------------------------
-(BOOL)tmplock
{
  return [self tmplockFromFunction:NULL
               file:NULL
               line:-1];
};


//--------------------------------------------------------------------
-(BOOL)tmplockFromFunction:(const char*)fn
                      file:(const char*)file
                      line:(int)line
{
  BOOL locked=NO;
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  result=objc_mutex_trylock(_mutex);
//  NSDebugMLLog(@"low",@"result=%d",result);
  if (result != 0 && result!=1)
    locked=NO;
  else
    locked=YES;

//  NSDebugMLLog(@"low",@"locked=%d",(int)locked);
  if (locked)
    {
      //NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
    }
  else
    {
      LOGException(@"NSLockException lock: failed to lock mutex. Called from %s in %s %d",
                   fn ? fn : "Unknown",
                   file ? file : "Unknown",
                   line);
      [NSException raise:NSLockException
                   format:@"lock: failed to lock mutex. Called from %s in %s %d",
                   fn ? fn : "Unknown",
                   file ? file : "Unknown",
                   line];
    };
//  LOGObjectFnStop();
  return locked;
};

//--------------------------------------------------------------------
-(BOOL)tmptryLock
{
  return [self tmptryLockFromFunction:NULL
			   file:NULL
			   line:-1];
};

//--------------------------------------------------------------------
-(BOOL)tmptryLockFromFunction:(const char*)fn
                         file:(const char*)file
                         line:(int)line
{
  BOOL locked=NO;
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  result=objc_mutex_trylock(_mutex);
//  NSDebugMLLog(@"low",@"result=%d",result);
  if (result != 0 && result!=1)
    locked=NO;
  else
    locked=YES;
//  LOGObjectFnStop();
  return locked;
};

//--------------------------------------------------------------------
-(BOOL)tmptryLockBeforeDate:(NSDate*)limit
{
  return [self tmptryLockBeforeDate:limit
               fromFunction:NULL
               file:NULL
               line:-1];
};

//--------------------------------------------------------------------
-(BOOL)tmptryLockBeforeDate:(NSDate*)limit
               fromFunction:(const char*)fn
                       file:(const char*)file
                       line:(int)line
{
  BOOL locked=NO;
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  result=objc_mutex_trylock(_mutex);
//  NSDebugMLLog(@"low",@"result=%d",result);
  if (result != 0 && result!=1)
    locked=NO;
  else
    locked=YES;
  
  //  NSDebugMLLog(@"low",@"[NSDate date]=%@ limit=%@",[NSDate date],limit);
  while (!locked && [[NSDate date]compare:limit]==NSOrderedAscending)
    {
      //NSDebugMLLog(@"low",@"tmplockBeforeDate wait");
      usleep(100);
      //NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
      result=objc_mutex_trylock(_mutex);
      //NSDebugMLLog(@"low",@"result=%d",result);
      if (result != 0 && result!=1)
        locked=NO;
      else
        locked=YES;
    }; 
  //  NSDebugMLLog(@"low",@"locked=%d",(int)locked);
  if (locked)
    {
      //NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
    }
  else
    {
      NSDebugMLog(@"NSLock tmptryLockBeforeDate lock: failed to lock mutex before %@. Called from %s in %s %d",
                  limit,
                  fn ? fn : "Unknown",
                  file ? file : "Unknown",
                  line);
    };
  //  LOGObjectFnStop();
  return locked;
};

//--------------------------------------------------------------------
-(BOOL)tmplockBeforeDate:(NSDate*)limit
{
  return [self tmplockBeforeDate:limit
			   fromFunction:NULL
			   file:NULL
			   line:-1];
};

//--------------------------------------------------------------------
-(BOOL)tmplockBeforeDate:(NSDate*)limit
            fromFunction:(const char*)fn
                    file:(const char*)file
                    line:(int)line
{
  BOOL locked=NO;
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  result=objc_mutex_trylock(_mutex);
//  NSDebugMLLog(@"low",@"result=%d",result);
  if (result != 0 && result!=1)
    locked=NO;
  else
    locked=YES;

//  NSDebugMLLog(@"low",@"[NSDate date]=%@ limit=%@",[NSDate date],limit);
  while (!locked && [[NSDate date]compare:limit]==NSOrderedAscending)
    {
      //NSDebugMLLog(@"low",@"tmplockBeforeDate wait");
      usleep(100);
      //NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
      result=objc_mutex_trylock(_mutex);
      //NSDebugMLLog(@"low",@"result=%d",result);
      if (result != 0 && result!=1)
        locked=NO;
      else
        locked=YES;
    }; 
  //  NSDebugMLLog(@"low",@"locked=%d",(int)locked);
  if (locked)
    {
      //NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
    }
  else
    {
      LOGException(@"NSLockException lock: failed to lock mutex before date %@. Called from %s in %s %d",
                   limit,
                   fn ? fn : "Unknown",
                   file ? file : "Unknown",
                   line);
      [NSException raise:NSLockException
                   format:@"lock: failed to lock mutex before date %@. Called from %s in %s %d",
                   limit,
                   fn ? fn : "Unknown",
                   file ? file : "Unknown",
                   line];
    };
//  LOGObjectFnStop();
  return locked;
};

//--------------------------------------------------------------------
-(void)tmpunlock
{
  [self tmpunlockFromFunction:NULL
        file:NULL
        line:-1];
};

//--------------------------------------------------------------------
-(void)tmpunlockFromFunction:(const char*)fn
                        file:(const char*)file
                        line:(int)line;
{
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  if (_mutex->owner!=objc_thread_id())
    {
      LOGException(@"NSLockException unlock: failed to unlock mutex (not owner). Called from %s in %s %d",
                   fn ? fn : "Unknown",
                   file ? file : "Unknown",
                   line);
      [NSException raise:NSLockException
                   format:@"unlock: failed to lock mutex (not owner). Called from %s in %s %d",
                   fn ? fn : "Unknown",
                   file ? file : "Unknown",
                   line];
    }
  else
    {
      result=objc_mutex_unlock(_mutex);
      //NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
      //NSDebugMLLog(@"low",@"result=%d",result);
      if (result != 0)
        {
          //NSDebugMLLog(@"low",@"UNLOCK PROBLEM");
          LOGException(@"NSLockException unlock: failed to unlock mutex (result!=0). Called from %s in %s %d",
                       fn ? fn : "Unknown",
                       file ? file : "Unknown",
					   line);
          [NSException raise:NSLockException
                       format:@"unlock: failed to lock mutex (result!=0). Called from %s in %s %d",
                       fn ? fn : "Unknown",
                       file ? file : "Unknown",
                       line];
        };
    };
  //  LOGObjectFnStop();
};
@end

NSString *NSRecursiveLockException = @"NSRecursiveLockException";

//====================================================================
@implementation NSRecursiveLock (NSLockBD)

-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - ",
                   object_get_class_name(self),
                   (void*)self];
};

//--------------------------------------------------------------------
-(BOOL)isLocked
{
  BOOL isLocked=YES;
  if ([self tmptryLock])
    {
      isLocked=NO;
      [self unlock];
    };
  return isLocked;
};

//--------------------------------------------------------------------
-(BOOL)tmplock
{
  return [self tmplockFromFunction:NULL
               file:NULL
               line:-1];
};


//--------------------------------------------------------------------
-(BOOL)tmplockFromFunction:(const char*)fn
                      file:(const char*)file
                      line:(int)line
{
  BOOL locked=NO;
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  if (!_mutex->owner || _mutex->owner==objc_thread_id())
    {
      result=objc_mutex_trylock(_mutex);
      //NSDebugMLLog(@"low",@"result=%d",result);
      if (result == -1)
        {
          locked=NO;
          LOGException(@"NSLockException lock: failed to lock mutex (result==-1). Called from %s in %s %d",
                       fn ? fn : "Unknown",
                       file ? file : "Unknown",
                       line);
          [NSException raise:NSLockException
                       format:@"lock: failed to lock mutex (result==-1). Called from %s in %s %d",
                       fn ? fn : "Unknown",
                       file ? file : "Unknown",
                       line];
        }
      else
        {
          locked=YES;
          //NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
        };
    }
  else
    {
      LOGException(@"NSLockException lock: failed to lock mutex (not owner). Called from %s in %s %d",
                   fn ? fn : "Unknown",
                   file ? file : "Unknown",
                   line);
      [NSException raise:NSLockException
                   format:@"lock: failed to lock mutex (not owner). Called from %s in %s %d",
                   fn ? fn : "Unknown",
                   file ? file : "Unknown",
                   line];
    };
  //  NSDebugMLLog(@"low",@"locked=%d",(int)locked);
  //  LOGObjectFnStop();
  return locked;
};

//--------------------------------------------------------------------
-(BOOL)tmptryLock
{
  return [self tmptryLockFromFunction:NULL
               file:NULL
               line:-1];
};


//--------------------------------------------------------------------
-(BOOL)tmptryLockFromFunction:(const char*)fn
                         file:(const char*)file
                         line:(int)line
{
  BOOL locked=NO;
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  if (!_mutex->owner || _mutex->owner==objc_thread_id())
    {
      result=objc_mutex_trylock(_mutex);
      //NSDebugMLLog(@"low",@"result=%d",result);
      if (result == -1)
        {
          locked=NO;
        }
      else
        {
          locked=YES;
        };
    };
  //  NSDebugMLLog(@"low",@"locked=%d",(int)locked);
  //  LOGObjectFnStop();
  return locked;
};

//--------------------------------------------------------------------
-(BOOL)tmptryLockBeforeDate:(NSDate*)limit
{
  return [self tmptryLockBeforeDate:limit
               fromFunction:NULL
               file:NULL
               line:-1];
};

//--------------------------------------------------------------------
-(BOOL)tmptryLockBeforeDate:(NSDate*)limit
               fromFunction:(const char*)fn
                       file:(const char*)file
                       line:(int)line
{
  BOOL locked=NO;
  BOOL notOwner=NO;
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  if (!_mutex->owner || _mutex->owner==objc_thread_id())
    {
      notOwner=NO;
      result=objc_mutex_trylock(_mutex);
      //NSDebugMLLog(@"low",@"result=%d",result);
      if (result == -1)
        locked=NO;
      else
        locked=YES;
    }
  else
    notOwner=YES;
  while (!locked && [[NSDate date]compare:limit]==NSOrderedAscending)
    {
      //NSDebugMLLog(@"low",@"tmplockBeforeDate wait");
      usleep(100);
      //NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
      if (!_mutex->owner || _mutex->owner==objc_thread_id())
        {
          notOwner=NO;
          result=objc_mutex_trylock(_mutex);
          //NSDebugMLLog(@"low",@"result=%d",result);
          if (result == -1)
            locked=NO;
          else
            locked=YES;
        }
      else
        notOwner=YES;
    }; 
  //  NSDebugMLLog(@"low",@"locked=%d",(int)locked);
  if (locked)
    {
      //NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
    }
  else
    {
      NSDebugMLog(@"NSLock tmptryLockBeforeDate lock: failed to lock mutex before %@ (%s). Called from %s in %s %d",
                  limit,
                  notOwner ? "Not Owner" : "result==-1",
                  fn ? fn : "Unknown",
                  file ? file : "Unknown",
                  line);
    };
  //  LOGObjectFnStop();
  return locked;
};

//--------------------------------------------------------------------
-(BOOL)tmplockBeforeDate:(NSDate*)limit
{
  return [self tmplockBeforeDate:limit
               fromFunction:NULL
               file:NULL
               line:-1];
};

//--------------------------------------------------------------------
-(BOOL)tmplockBeforeDate:(NSDate*)limit
            fromFunction:(const char*)fn
                    file:(const char*)file
                    line:(int)line
{
  BOOL locked=NO;
  BOOL notOwner=NO;
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  if (!_mutex->owner || _mutex->owner==objc_thread_id())
    {
      notOwner=NO;
      result=objc_mutex_trylock(_mutex);
      //NSDebugMLLog(@"low",@"result=%d",result);
      if (result == -1)
        locked=NO;
      else
        locked=YES;
    }
  else
    notOwner=YES;
  
  while (!locked && [[NSDate date]compare:limit]==NSOrderedAscending)
    {
      //NSDebugMLLog(@"low",@"tmplockBeforeDate wait");
      usleep(100);
      //NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
      if (!_mutex->owner || _mutex->owner==objc_thread_id())
        {
          notOwner=NO;
          result=objc_mutex_trylock(_mutex);
          //NSDebugMLLog(@"low",@"result=%d",result);
          if (result == -1)
            locked=NO;
          else
            locked=YES;
        }
      else
        notOwner=YES;
    }; 
  //  NSDebugMLLog(@"low",@"locked=%d",(int)locked);
  if (locked)
    {
      //NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
    }
  else
    {
      LOGException(@"NSLockException lock: failed to lock mutex before date %@ (%s). Called from %s in %s %d",
                   limit,
                   notOwner ? "Not Owner" : "result==-1",
                   fn ? fn : "Unknown",
                   file ? file : "Unknown",
                   line);
      [NSException raise:NSLockException
                   format:@"lock: failed to lock mutex before date %@ (%s). Called from %s in %s %d",
                   limit,
                   notOwner ? "Not Owner" : "result==-1",
                   fn ? fn : "Unknown",
                   file ? file : "Unknown",
                   line];
    };
//  LOGObjectFnStop();
  return locked;
};

//--------------------------------------------------------------------
-(void)tmpunlock
{
  [self tmpunlockFromFunction:NULL
        file:NULL
        line:-1];
};

//--------------------------------------------------------------------
-(void)tmpunlockFromFunction:(const char*)fn
                        file:(const char*)file
                        line:(int)line;
{
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  if (_mutex->owner!=objc_thread_id())
    {
      LOGException(@"NSLockException unlock: failed to unlock mutex (not owner). Called from %s in %s %d",
                   fn ? fn : "Unknown",
                   file ? file : "Unknown",
                   line);
      [NSException raise:NSLockException
                   format:@"unlock: failed to lock mutex (not owner). Called from %s in %s %d",
                   fn ? fn : "Unknown",
                   file ? file : "Unknown",
                   line];
    }
  else
    {
      result=objc_mutex_unlock(_mutex);
      //NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
      //NSDebugMLLog(@"low",@"result=%d",result);
      if (result == -1)
        {
          LOGException(@"NSLockException unlock: failed to unlock mutex (result==-1). Called from %s in %s %d",
                       fn ? fn : "Unknown",
                       file ? file : "Unknown",
                       line);
          [NSException raise:NSLockException
                       format:@"unlock: failed to lock mutex (result==-1). Called from %s in %s %d",
                       fn ? fn : "Unknown",
                       file ? file : "Unknown",
                       line];
        };
    };
  //  LOGObjectFnStop();
};
@end

//====================================================================
@implementation NSArray (NSPerformSelectorWith2Objects)
//--------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector
                       withObject:(id)object1
                       withObject:(id)object2
{
  unsigned i = [self count];
  while (i-- > 0)
    [[self objectAtIndex:i]performSelector:selector
                           withObject:object1
                           withObject:object2];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
{
  unsigned i = [self count];
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
  unsigned i = [self count];
  while (i-->0)
    [[self objectAtIndex: i] performSelectorIfPossible:aSelector
                             withObject:argument];
}

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)argument1
                                 withObject:(id)argument2
{
  unsigned i = [self count];
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
    rootDoc=[NSString stringWithString:@"/home/httpd/gsweb"];
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
      //NSDebugFLog(@"_dict=%@",_dict);
      [dict addDefaultEntriesFromDictionary:dictionaryDefaults];
      //NSDebugFLog(@"_dict=%@",_dict);
      dict=[NSDictionary dictionaryWithDictionary:dict];
      //NSDebugFLog(@"_dict=%@",_dict);
    }
  else
    dict=[NSDictionary dictionaryWithDictionary:dictionaryDefaults];
  //  NSDebugFLog(@"dict=%@",dict);
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
  LOGObjectFnStart();
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
  LOGObjectFnStop();
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
        good=[NSString stringWithString:@"/"];
    };
  return good;
};
@end

//====================================================================
@implementation NSUserDefaults (Description)

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - searchList:\n%@\n persDomains:\n%@\n tempDomains:\n%@\n changedDomains:\n%@\n dictionaryRep:\n%@\n defaultsDatabase:\n%@\n tickingTimer:\n%@\n>",
                   object_get_class_name(self),
                   (void*)self,
                   _searchList,
                   _persDomains,
                   _tempDomains,
                   _changedDomains,
                   _dictionaryRep,
                   _defaultsDatabase,
                   _tickingTimer];
};

@end

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
  NSAssert([val0 isKindOfClass:[NSNumber class]],@"val0 must't be a NSNumber");
  NSAssert([val1 isKindOfClass:[NSNumber class]],@"val1 must't be a NSNumber");
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
  NSAssert([val0 isKindOfClass:[NSNumber class]],@"val0 must't be a NSNumber");
  NSAssert([val1 isKindOfClass:[NSNumber class]],@"val1 must't be a NSNumber");
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
              options:(unsigned)mask
{
  NSRange all = NSMakeRange(0,[self length]);
  return [self rangeOfData:data
               options:mask
               range:all];
}

//--------------------------------------------------------------------
-(NSRange)rangeOfData:(NSData *)aData
              options:(unsigned)mask
                range:(NSRange)aRange
{
  NSRange range=NSMakeRange(NSNotFound,0);
  NSDebugFLog(@"self=%@",self);
  NSDebugFLog(@"aData=%@",aData);
  NSDebugFLog(@"mask=%u",mask);
  NSDebugFLog(@"aRange=(%u,%u)",aRange.location,aRange.length);
  if (aData)
    {
      int aDataLength=[aData length];
      int selfLength=[self length];
      NSDebugFLog(@"aDataLength=%d",aDataLength);
      NSDebugFLog(@"selfLength=%d",selfLength);
      if (aRange.location+aRange.length>selfLength)
        [NSException raise:NSInvalidArgumentException format:@"Bad Range (%d,%d) for self length %d",
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
                      NSDebugFLog(@"cmp at %d length %d",
                                  aRange.location-aDataLength,
                                  aDataLength);
                      if (memcmp(selfBytes+aRange.location-aDataLength,
                                 aDataBytes,
                                 aDataLength)==0)
                        {
                          NSDebugFLog0(@"FOUND");
                          range=NSMakeRange(selfLength-aDataLength,aDataLength);
                        };
                    }
                  else
                    {
                      NSDebugFLog(@"cmp at %d length %d",
                                  aRange.location,
                                  aDataLength);
                      if (memcmp(selfBytes+aRange.location,
                                 aDataBytes,
                                 aDataLength))
                        {
                          NSDebugFLog0(@"FOUND");
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
                  NSDebugFLog(@"cmp at %d downto index: %d",
                              aRange.location+aRange.length-1,
                              first);
                  for(i=aRange.location+aRange.length-1;i>=first && range.length==0;i--)
                    {
                      if (((unsigned char*)selfBytes)[i]==((unsigned char*)aDataBytes)[aDataLength-1])
                        {
                          NSDebugFLog(@"FOUND Last Char at %d",i);
                          if (memcmp(selfBytes+i-aDataLength,aDataBytes,aDataLength)==0)
                            {
                              range=NSMakeRange(i-aDataLength,aDataLength);
                              NSDebugFLog(@"FOUND at %d",i-aDataLength);
                            };
                        };
                    };
                }
              else
                {
                  int i=0;
                  int last=aRange.location+aRange.length-aDataLength;
                  NSDebugFLog(@"cmp at %d upto index: %d",
                              aRange.location,
                              last);
                  for(i=aRange.location;i<=last && range.length==0;i++)
                    {
                      if (((unsigned char*)selfBytes)[i]==((unsigned char*)aDataBytes)[0])
                        {
                          NSDebugFLog(@"FOUND First Char at %d",i);
                          if (memcmp(selfBytes+i,aDataBytes,aDataLength)==0)
                            {
                              range=NSMakeRange(i,aDataLength);
                              NSDebugFLog(@"FOUND at %d",i);
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
  NSDebugFLog(@"aSeparator %@ length=%d",aSeparator,[aSeparator length]);
  NSDebugFLog(@"self length=%d",[self length]);
  search=NSMakeRange(0, [self length]);
  complete=search;
  found=[self rangeOfData:aSeparator];
  NSDebugFLog(@"found=(%u,%u)",found.location,found.length);
  while (found.length)
    {
      NSRange current;
      current = NSMakeRange (search.location,
                             found.location-search.location);
      NSDebugFLog(@"current=(%u,%u)",current.location,current.length);
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
  NSDebugFLog(@"array=%@",array);
  return [NSArray arrayWithArray:array];
};

//--------------------------------------------------------------------
-(NSData*)dataByDeletingFirstBytesCount:(unsigned int)bytesCount
{
  NSMutableData* tmpdata=[self mutableCopy];
  [tmpdata deleteFirstBytesCount:bytesCount];
  return [NSData dataWithData:tmpdata];
};

//--------------------------------------------------------------------
-(NSData*)dataByDeletingLastBytesCount:(unsigned int)bytesCount
{
  NSMutableData* tmpdata=[self mutableCopy];
  [tmpdata deleteLastBytesCount:bytesCount];
  return [NSData dataWithData:tmpdata];
};

@end

//====================================================================
@implementation NSMutableData (SBNSData)

//--------------------------------------------------------------------
-(void)deleteFirstBytesCount:(unsigned int)bytesCount
{
  void* mutableBytes=NULL;
  unsigned int length=[self length];
  NSAssert2(length>=bytesCount,
            @"Can't delete %d first bytes from a data of length %d",
            bytesCount,length);
  mutableBytes=[self mutableBytes];
  memmove(mutableBytes,mutableBytes+bytesCount,bytesCount);
  [self setLength:length-bytesCount];
};

//--------------------------------------------------------------------
-(void)deleteLastBytesCount:(unsigned int)bytesCount;
{
  unsigned int length=[self length];
  NSAssert2(length>=bytesCount,
            @"Can't delete %d last bytes from a data of length %d",
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
-(NSString*)stringForObjectValue:(id)anObject
{
  NSString* string=nil;
  if ([anObject isKindOfClass:[NSString class]])
    string=anObject;
  else if (anObject)
    {
      switch(_type)
        {
        case NSNumFmtType__Int:
          if ([anObject isKindOfClass:[NSNumber class]])
            {
              int value=[anObject intValue];
              string=[NSString stringWithFormat:@"%d",value];
            }
          else if ([anObject respondsToSelector:@selector(intValue)])
            {
              int value=[anObject intValue];
              string=[NSString stringWithFormat:@"%d",value];
            }
          else if ([anObject respondsToSelector:@selector(floatValue)])
            {
              int value=(int)[anObject floatValue];
              string=[NSString stringWithFormat:@"%d",value];
            }
          else if ([anObject respondsToSelector:@selector(doubleValue)])
            {
              int value=(int)[anObject doubleValue];
              string=[NSString stringWithFormat:@"%d",value];
            }
          else
            {
              LOGSeriousError(@"Can't convert %@ of class %@ to string",
                              anObject,
                              [anObject class]);
              string=@"***";
            };
          break;
        case NSNumFmtType__Float:
          if ([anObject isKindOfClass:[NSNumber class]])
            {
              double value=[anObject doubleValue];
              string=[NSString stringWithFormat:@"%.2f",value];
            }
          else if ([anObject respondsToSelector:@selector(intValue)])
            {
              int value=[anObject intValue];
              string=[NSString stringWithFormat:@"%d.00",value];
            }
          else if ([anObject respondsToSelector:@selector(floatValue)])
            {
              double value=(double)[anObject floatValue];
              string=[NSString stringWithFormat:@"%.2f",value];
            }
          else if ([anObject respondsToSelector:@selector(doubleValue)])
            {
              double value=[anObject doubleValue];
              string=[NSString stringWithFormat:@"%.2f",value];
            }
          else
            {
              LOGSeriousError(@"Can't convert %@ of class %@ to string",
                              anObject,
                              [anObject class]);
              string=@"***";
            };
          break;
        case NSNumFmtType__Unknown:
        default:
          LOGSeriousError(@"Unknown type %d to convert %@ to string",
                          (int)type,
                          anObject);
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
      *anObject=[NSNumber numberWithInt:[string intValue]];
      ok=YES;
      break;
    case NSNumFmtType__Float:
      *anObject=[NSNumber numberWithFloat:[string floatValue]];
      ok=YES;
      break;
    case NSNumFmtType__Unknown:
    default:	  
      LOGSeriousError(@"Unknown type %d to convert from string %@",
                      (int)_type,
                      string);
      *error = @"Unknown type";
      break;
    };
  return ok;
};

@end

