/* utils.m - utils
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

#include <gsweb/GSWeb.framework/GSWeb.h>

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
BOOL boolValueFor(id id_)
{
  if (id_)
	{
	  if (/*id_==BNYES ||*/ id_==NSTYES)
		return YES;
	  else if (/*id_==BNNO ||*/ id_==NSTNO)
		return NO;
	  else if ([id_ conformsTo:@protocol(NSString)] && [id_ length]>0)
		return ([id_ caseInsensitiveCompare: @"NO"]!=NSOrderedSame);
	  else if ([id_ respondsToSelector:@selector(boolValue)] && [id_ boolValue])
		return YES;
	  else if ([id_ respondsToSelector:@selector(intValue)] && [id_ intValue])
		return YES;
	  //BOOL is unisgned char
	  else if ([id_ respondsToSelector:@selector(unsignedCharValue)] && [id_ unsignedCharValue])
		return YES;
	  else
		return NO;
	}
  else
	return NO;
};

//--------------------------------------------------------------------
BOOL boolValueWithDefaultFor(id id_,BOOL default_)
{
  if (id_)
	{
	  if (/*id_==BNYES ||*/ id_==NSTYES)
		return YES;
	  else if (/*id_==BNNO ||*/ id_==NSTNO)
		return NO;
//@protocol NSString
	  else if ([id_ conformsTo:@protocol(NSString)] && [id_ length]>0)
		return ([id_ caseInsensitiveCompare: @"NO"]!=NSOrderedSame);
	  else if ([id_ respondsToSelector:@selector(boolValue)])
		return ([id_ boolValue]!=NO);
	  else if ([id_ respondsToSelector:@selector(intValue)])
		return ([id_ intValue]!=0);
	  else if ([id_ respondsToSelector:@selector(unsignedCharValue)]) //BOOL is unsigned char
		return ([id_ unsignedCharValue]!=0);
	  else
		return default_;
	}
  else
	return NO;
};

/*
//--------------------------------------------------------------------
BOOLNB boolNbFor(BOOL value_)
{
  return (value_ ? BNYES : BNNO);
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
  BOOL _equal=NO;
  if (id1==id2)
	_equal=YES;
  else if (id1)
	{
	  if (id2)
		  _equal=[id1 isEqual:id2];
	};
  return _equal;
};

//--------------------------------------------------------------------
BOOL SBIsValueEqual(id id1,id id2)
{
  BOOL _equal=SBIsEqual(id1,id2);
  if (!_equal
	  && [id1 class]!=[id2 class])
	{
	  if ([id1 isKindOfClass:[NSString class]])
		{
		  NSString* _id2String=[NSString stringWithObject:id2];
		  _equal=[id1 isEqualToString:_id2String];
		}
	  else if ([id2 isKindOfClass:[NSString class]])
		{
		  NSString* _id1String=[NSString stringWithObject:id1];
		  _equal=[id2 isEqualToString:_id1String];
		};
	};
  return _equal;
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

NSString* pidproccontent(NSString* _path)
{
  NSString* _content=nil;
  char          thePath[BUFSIZ*2];
  FILE          *theFile = 0;
  if ([_path getFileSystemRepresentation:thePath
                              maxLength:sizeof(thePath)-1] == NO)
    {
	  LOGSeriousError(@"Open (%@) attempt failed - bad path",
					  _path);
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
		  LOGSeriousError(@"Open (%s) attempt failed - %s", thePath, strerror(errno));
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
			  _content=[NSString stringWithCString:buff];
			};
		  fclose(theFile);
		};
	};
  return _content;
};
void pidstat(pid_t pid, proc_t* P)
{
  NSString* _filename=[NSString stringWithFormat:@"/proc/%d/stat",(int)pid];
  NSString* pidstat=pidproccontent(_filename);
  NSDebugFLog(@"pidstat=%@",pidstat);
  NSDebugFLog(@"_filename=%@",_filename);
  NSDebugFLog(@"pid=%d",(int)pid);
  if (pidstat)
	{
	  NSRange _cmdEnd=[pidstat rangeOfString:@") "];
	  if (_cmdEnd.length>0)
		{
		  NSString* _pid_cmd=[pidstat substringToIndex:_cmdEnd.location];
		  NSDebugFLog(@"_pid_cmd=%@",_pid_cmd);
		  if (_cmdEnd.location+_cmdEnd.length<[pidstat length])
			{
			  NSString* _stats=[pidstat substringFromIndex:_cmdEnd.location+_cmdEnd.length];
			  /*
				char* tmp = strrchr(S, ')');        // split into "PID (cmd" and "<rest>" 
				*tmp = '\0';                        // replace trailing ')' with NUL 
				// parse these two strings separately, skipping the leading "(". 
				memset(P->cmd, 0, sizeof P->cmd);   // clear even though *P xcalloc'd ?! 
				sscanf(S, "%d (%39c", &P->pid, P->cmd);
			  */
			  const char* _statsChars=[_stats cString];
			  NSDebugFLog(@"_stats=%@",_stats);
			  sscanf(_statsChars,
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
  NSString* _filename=[NSString stringWithFormat:@"/proc/%d/statm",(int)pid];
  NSString* pidstat=pidproccontent(_filename);
  NSDebugFLog(@"pidstat=%@",pidstat);
  NSDebugFLog(@"_filename=%@",_filename);
  NSDebugFLog(@"pid=%d",(int)pid);
  if (pidstat)
	{
	  const char* _statsChars=[pidstat cString];
	  NSDebugFLog(@"pidstat=%@",pidstat);
	  sscanf(_statsChars, "%ld %ld %ld %ld %ld %ld %ld",
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
  NSString* _stackTraceString=[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"/tmp/%@.stacktrace",
																		 globalApplicationClassName]];
  if ([_stackTraceString intValue])
	{
	  StackTrace();
	};
};

//--------------------------------------------------------------------
void DebugBreakpointIFND()
{
  NSString* _breakString=[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"/tmp/%@.break",
																		 globalApplicationClassName]];
  if ([_breakString intValue])
	{
	  DebugBreakpoint();
	};
};

//--------------------------------------------------------------------
void ExceptionRaiseFn(const char *func, 
					  const char *file,
					  int line,
					  NSString* name_,
					  NSString* format_,
					  ...)
{
  NSString* fmt =  [NSString stringWithFormat:@"File %s: %d. In %s EXCEPTION %@: %@",
							 func,line,file,name_,format_];
  NSString* string= nil;
  va_list args;
  va_start(args,format_);
  string=[NSString stringWithFormat:fmt
				   arguments:args];
  va_end(args);
  NSLog(@"%@",string);
  StackTraceIFND();
  DebugBreakpointIFND();
  [NSException raise:name_ format:@"%@",string];
};

//--------------------------------------------------------------------
void ExceptionRaiseFn0(const char *func, 
					   const char *file,
					   int line,
					   NSString* name_,
					   NSString* format_)
{
  NSString* string =  [NSString stringWithFormat:@"File %s: %d. In %s EXCEPTION %@: %@",
								func,line,file,name_,format_];
  NSLog(@"%@",string);
  StackTraceIFND();
  DebugBreakpointIFND();
  [NSException raise:name_ format:@"%@",string];
};

//--------------------------------------------------------------------
void ValidationExceptionRaiseFn(const char *func, 
								const char *file,
								int line,
								NSString* name_,
								NSString* message_,
								NSString* format_,
								...)
{
  NSException* _exception=nil;
  NSString* fmt =  [NSString stringWithFormat:@"File %s: %d. In %s EXCEPTION %@: %@",
							 func,line,file,name_,format_];
  NSString* string= nil;
  va_list args;
  va_start(args,format_);
  string=[NSString stringWithFormat:fmt
				   arguments:args];
  va_end(args);
  NSLog(@"%@",string);
  _exception=[NSException exceptionWithName:name_
						  reason:string
						  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												   [NSNumber numberWithBool:YES],@"isValidationException",
												 message_,@"message",
												 nil,nil]];
  StackTraceIFND();
  DebugBreakpointIFND();
  [_exception raise];
};

//--------------------------------------------------------------------
void ValidationExceptionRaiseFn0(const char *func, 
								 const char *file,
								 int line,
								 NSString* name_,
								 NSString* message_,
								 NSString* format_)
{
  NSException* _exception=nil;
  NSString* string =  [NSString stringWithFormat:@"File %s: %d. In %s EXCEPTION %@: %@",
								func,line,file,name_,format_];
  NSLog(@"%@",string);
  _exception=[NSException exceptionWithName:name_
						  reason:format_
						  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												   [NSNumber numberWithBool:YES],@"isValidationException",
												 message_,@"message",
												 nil,nil]];
  StackTraceIFND();
  DebugBreakpointIFND();
  [_exception raise];
};

//====================================================================
@implementation NSException (NSBuild)
+(NSException*)exceptionWithName:(NSString *)name
						  format:(NSString *)format,...
{
  NSException* _exception=nil;
  NSString* reason=nil;
  va_list args;
  va_start(args,format);
  reason = [NSString stringWithFormat:format
					 arguments:args];
  va_end(args);
  _exception=[self exceptionWithName:name
				   reason:reason
				   userInfo: nil];
  return _exception;
};
@end

//====================================================================
@implementation NSException (NSExceptionUserInfoAdd)

-(NSException*)exceptionByAddingUserInfo:(NSDictionary*)userInfo_
{
  NSMutableDictionary* _userInfo=[NSMutableDictionary dictionaryWithDictionary:[self userInfo]];
  [_userInfo addEntriesFromDictionary:userInfo_];
  return [[self class]exceptionWithName:[self name]
					  reason:[self reason]
					  userInfo:_userInfo];
};

-(NSException*)exceptionByAddingUserInfoKey:(id)key_
									 format:(NSString*)format_,...
{
  NSString* _userInfoString=nil;
  NSMutableDictionary* _userInfo=[NSMutableDictionary dictionaryWithDictionary:[self userInfo]];
  va_list args;
  va_start(args,format_);
  _userInfoString = [NSString stringWithFormat:format_
							  arguments:args];
  va_end(args);
  [_userInfo setObject:_userInfoString
			 forKey:key_];
  return [[self class]exceptionWithName:[self name]
					  reason:[self reason]
					  userInfo:_userInfo];
};

-(NSException*)exceptionByAddingUserInfoFrameInfo:(NSString*)frameInfo_
{
  NSMutableDictionary* _userInfo=[NSMutableDictionary dictionaryWithDictionary:[self userInfo]];
  NSArray* _frameInfoArray=[_userInfo objectForKey:@"FrameInfo"];
  if (_frameInfoArray)
	_frameInfoArray=[_frameInfoArray arrayByAddingObject:frameInfo_];
  else
	_frameInfoArray=[NSArray arrayWithObject:frameInfo_];
  [_userInfo setObject:_frameInfoArray
			 forKey:@"FrameInfo"];
  return [[self class]exceptionWithName:[self name]
					  reason:[self reason]
					  userInfo:_userInfo];
};

-(NSException*)exceptionByAddingUserInfoFrameInfoFormat:(NSString*)format_,...
{
  NSString* _frameInfo=nil;
  va_list args;
  va_start(args,format_);
  _frameInfo = [NSString stringWithFormat:format_
						 arguments:args];
  va_end(args);
  return [self exceptionByAddingUserInfoFrameInfo:_frameInfo];
};

-(NSException*)exceptionByAddingUserInfoFrameInfoObject:(id)obj_
													sel:(SEL)sel_
												   file:(const char*)file_
												   line:(int)line_
												 format:(NSString*)format_,...
{
  Class         cls = (Class)obj_;
  char          c = '+';
  NSString* fmt=nil;
  NSString* string= nil;
  va_list args;
  if ([obj_ isInstance] == YES)
    {
      c = '-';
      cls = [obj_ class];
    };
  fmt = [NSString stringWithFormat: @"%s: %d. In [%@ %c%@] %@",
				  file_,
				  line_,
				  NSStringFromClass(cls),
				  c,
				  NSStringFromSelector(sel_),
				  format_];
  va_start(args,format_);
  string=[NSString stringWithFormat:fmt
				   arguments:args];
  va_end(args);
  return [self exceptionByAddingUserInfoFrameInfo:string];

};

-(NSException*)exceptionByAddingUserInfoFrameInfoFunction:(const char*)fn_
													 file:(const char*)file_
													 line:(int)line_
												   format:(NSString*)format_,...
{
  NSString* fmt =  [NSString stringWithFormat:@"%s: %d. In %s %@: %@",
							 file_,line_,fn_,format_];
  NSString* string= nil;
  va_list args;
  va_start(args,format_);
  string=[NSString stringWithFormat:fmt
				   arguments:args];
  va_end(args);
  return [self exceptionByAddingUserInfoFrameInfo:string];
};

-(BOOL)isValidationException
{
  BOOL _isValidationException=boolValueWithDefaultFor([[self userInfo] objectForKey:@"isValidationException"],NO);
  return _isValidationException;
};

@end

//====================================================================
@implementation NSDate (NSDateHTMLDescription)
//------------------------------------------------------------------------------
-(NSString*)htmlDescription
{
  LOGObjectFnNotImplemented();	//TODOFN
  //TODO English day...
  return [self descriptionWithCalendarFormat:@"%A, %d-%b-%Y %H:%M:%S GMT"
			   timeZone:[NSTimeZone timeZoneWithName:@"GMT"]
			   locale:nil];
};
@end

//====================================================================
@implementation NSMutableOrderedArray: NSGMutableArray

//--------------------------------------------------------------------
-(id)initWithCompareSelector:(SEL)compareSelector_
{
  if ((self=[super init]))
	{
	  compareSelector=compareSelector_;
	};
  return self;
};

//--------------------------------------------------------------------
-(void)addObject:(id)object_
{
  //TODO better method
  int i=0;
  NSComparisonResult _result=NSOrderedSame;
  for(i=0;_result!=NSOrderedDescending && i<[self count];i++)
	{
	  _result=(NSComparisonResult)[object_ performSelector:compareSelector
										   withObject:[self objectAtIndex:i]];
	  if (_result==NSOrderedDescending)
		[super insertObject:object_
			   atIndex:i];
	};
  if (_result!=NSOrderedDescending)
		[super addObject:object_];
};

//--------------------------------------------------------------------
-(void)addObjectsFromArray:(NSArray*)array_
{
  int i;
  for(i=0;i<[array_ count];i++)
	{
	  [self addObject:[array_ objectAtIndex:i]];
	};
};

//--------------------------------------------------------------------
-(void)insertObject:(id)object_
			atIndex:(unsigned int)index_
{
   LOGException0(@"NSMutableOrderedArray doesn't support this fn");
   [NSException raise:@"NSMutableOrderedArray"
				format:@"NSMutableOrderedArray doesn't support %s",sel_get_name(_cmd)];
};

//--------------------------------------------------------------------
-(void)replaceObjectAtIndex:(unsigned int)index_
				 withObject:(id)object_
{
   LOGException0(@"NSMutableOrderedArray doesn't support this fn");
   [NSException raise:@"NSMutableOrderedArray"
				format:@"NSMutableOrderedArray doesn't support %s",sel_get_name(_cmd)];
};

//--------------------------------------------------------------------
-(void)replaceObjectsInRange:(NSRange)range_
		withObjectsFromArray:(NSArray*)array_
{
   LOGException0(@"NSMutableOrderedArray doesn't support this fn");
   [NSException raise:@"NSMutableOrderedArray"
				format:@"NSMutableOrderedArray doesn't support %s",sel_get_name(_cmd)];
};

//--------------------------------------------------------------------
-(void)replaceObjectsInRange:(NSRange)range_
		withObjectsFromArray:(NSArray*)array_
					   range:(NSRange)arrayRange_
{
   LOGException0(@"NSMutableOrderedArray doesn't support this fn");
   [NSException raise:@"NSMutableOrderedArray"
				format:@"NSMutableOrderedArray doesn't support %s",sel_get_name(_cmd)];
};

//--------------------------------------------------------------------
-(void)setArray:(NSArray*)array_
{
  [super setArray:[array_ sortedArrayUsingSelector:compareSelector]];
};

@end

//====================================================================
@implementation NSBundle (NSBundleAllFrameworks)
//--------------------------------------------------------------------
+(NSArray*)tmpAllFrameworks
{
  NSMutableArray* _allFrameworks=nil;
  NSArray* _allBundles=nil;
  int i=0;
  NSString* _bundlePath=nil;
  NSBundle* _bundle=nil;
  LOGObjectFnStart();
  _allFrameworks=[NSMutableArray array];
  _allBundles=[[self class] allBundles];
  for(i=0;i<[_allBundles count];i++)
	{
	  _bundle=[_allBundles objectAtIndex:i];
	  _bundlePath=[_bundle bundlePath];
	  NSDebugMLLog(@"low",@"_bundlePath=%@",_bundlePath);
	  _bundlePath=[_bundlePath stringGoodPath];
	  NSDebugMLLog(@"low",@"_bundlePath=%@",_bundlePath);
	  if ([_bundlePath hasSuffix:GSFrameworkSuffix])
		[_allFrameworks addObject:_bundle];
	};
  LOGObjectFnStop();
  return _allFrameworks;
};

//--------------------------------------------------------------------
-(NSString*)bundleName
{
  NSString* _bundlePath=nil;
  NSString* _name=nil;
  LOGObjectFnStart();
  _bundlePath=[self bundlePath];
  NSDebugMLLog(@"low",@"_bundlePath=%@",_bundlePath);
  _bundlePath=[_bundlePath stringGoodPath];
  NSDebugMLLog(@"low",@"_bundlePath=%@",_bundlePath);
  _name=[_bundlePath lastPathComponent];
  NSDebugMLLog(@"low",@"_name=%@",_name);
  _name=[_name stringByDeletingPathExtension];
  NSDebugMLLog(@"low",@"_name=%@",_name);
  LOGObjectFnStop();
  return _name;
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

extern struct PTHREAD_HANDLE * nub_get_active_thread( void );

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
  BOOL _isLocked=YES;
  if ([self tmptryLock])
	{
	  _isLocked=NO;
	  [self tmpunlock];
	};
  return _isLocked;
};

//--------------------------------------------------------------------
-(BOOL)tmplock
{
  return [self tmplockFromFunction:NULL
			   file:NULL
			   line:-1];
};


//--------------------------------------------------------------------
-(BOOL)tmplockFromFunction:(const char*)fn_
					  file:(const char*)file_
					  line:(int)line_
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
//	  NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
	}
  else
	{
	  LOGException(@"NSLockException lock: failed to lock mutex. Called from %s in %s %d",
				   fn_ ? fn_ : "Unknown",
				   file_ ? file_ : "Unknown",
				   line_);
	  [NSException raise:NSLockException
				   format:@"lock: failed to lock mutex. Called from %s in %s %d",
				   fn_ ? fn_ : "Unknown",
				   file_ ? file_ : "Unknown",
				   line_];
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
-(BOOL)tmptryLockFromFunction:(const char*)fn_
						 file:(const char*)file_
						 line:(int)line_
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
			   fromFunction:(const char*)fn_
					   file:(const char*)file_
					   line:(int)line_
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
//	  NSDebugMLLog(@"low",@"tmplockBeforeDate wait");
	  usleep(100);
//	  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
	  result=objc_mutex_trylock(_mutex);
//	  NSDebugMLLog(@"low",@"result=%d",result);
	  if (result != 0 && result!=1)
		locked=NO;
	  else
		locked=YES;
	}; 
//  NSDebugMLLog(@"low",@"locked=%d",(int)locked);
  if (locked)
	{
//	  NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
	}
  else
	{
	  NSDebugMLog(@"NSLock tmptryLockBeforeDate lock: failed to lock mutex before %@. Called from %s in %s %d",
				  limit,
				  fn_ ? fn_ : "Unknown",
				  file_ ? file_ : "Unknown",
				  line_);
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
			fromFunction:(const char*)fn_
					file:(const char*)file_
					line:(int)line_
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
//	  NSDebugMLLog(@"low",@"tmplockBeforeDate wait");
	  usleep(100);
//	  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
	  result=objc_mutex_trylock(_mutex);
//	  NSDebugMLLog(@"low",@"result=%d",result);
	  if (result != 0 && result!=1)
		locked=NO;
	  else
		locked=YES;
	}; 
//  NSDebugMLLog(@"low",@"locked=%d",(int)locked);
  if (locked)
	{
//	  NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
	}
  else
	{
	  LOGException(@"NSLockException lock: failed to lock mutex before date %@. Called from %s in %s %d",
				   limit,
				   fn_ ? fn_ : "Unknown",
				   file_ ? file_ : "Unknown",
				   line_);
	  [NSException raise:NSLockException
				   format:@"lock: failed to lock mutex before date %@. Called from %s in %s %d",
				   limit,
				   fn_ ? fn_ : "Unknown",
				   file_ ? file_ : "Unknown",
				   line_];
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
-(void)tmpunlockFromFunction:(const char*)fn_
						file:(const char*)file_
						line:(int)line_;
{
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  if (_mutex->owner!=objc_thread_id())
	{
	  LOGException(@"NSLockException unlock: failed to unlock mutex (not owner). Called from %s in %s %d",
				   fn_ ? fn_ : "Unknown",
				   file_ ? file_ : "Unknown",
				   line_);
	  [NSException raise:NSLockException
				   format:@"unlock: failed to lock mutex (not owner). Called from %s in %s %d",
				   fn_ ? fn_ : "Unknown",
				   file_ ? file_ : "Unknown",
				   line_];
	}
  else
	{
	  result=objc_mutex_unlock(_mutex);
//	  NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
//	  NSDebugMLLog(@"low",@"result=%d",result);
	  if (result != 0)
		{
//		  NSDebugMLLog(@"low",@"UNLOCK PROBLEM");
		  LOGException(@"NSLockException unlock: failed to unlock mutex (result!=0). Called from %s in %s %d",
					   fn_ ? fn_ : "Unknown",
					   file_ ? file_ : "Unknown",
					   line_);
		  [NSException raise:NSLockException
					   format:@"unlock: failed to lock mutex (result!=0). Called from %s in %s %d",
					   fn_ ? fn_ : "Unknown",
					   file_ ? file_ : "Unknown",
					   line_];
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
  BOOL _isLocked=YES;
  if ([self tmptryLock])
	{
	  _isLocked=NO;
	  [self unlock];
	};
  return _isLocked;
};

//--------------------------------------------------------------------
-(BOOL)tmplock
{
  return [self tmplockFromFunction:NULL
			   file:NULL
			   line:-1];
};


//--------------------------------------------------------------------
-(BOOL)tmplockFromFunction:(const char*)fn_
					  file:(const char*)file_
					  line:(int)line_
{
  BOOL locked=NO;
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  if (!_mutex->owner || _mutex->owner==objc_thread_id())
	{
	  result=objc_mutex_trylock(_mutex);
//	  NSDebugMLLog(@"low",@"result=%d",result);
	  if (result == -1)
		{
		  locked=NO;
		  LOGException(@"NSLockException lock: failed to lock mutex (result==-1). Called from %s in %s %d",
					   fn_ ? fn_ : "Unknown",
					   file_ ? file_ : "Unknown",
					   line_);
		  [NSException raise:NSLockException
					   format:@"lock: failed to lock mutex (result==-1). Called from %s in %s %d",
					   fn_ ? fn_ : "Unknown",
					   file_ ? file_ : "Unknown",
					   line_];
		}
	  else
		{
		  locked=YES;
		  //	  NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
		};
	}
  else
	{
	  LOGException(@"NSLockException lock: failed to lock mutex (not owner). Called from %s in %s %d",
				   fn_ ? fn_ : "Unknown",
				   file_ ? file_ : "Unknown",
				   line_);
	  [NSException raise:NSLockException
				   format:@"lock: failed to lock mutex (not owner). Called from %s in %s %d",
				   fn_ ? fn_ : "Unknown",
				   file_ ? file_ : "Unknown",
				   line_];
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
-(BOOL)tmptryLockFromFunction:(const char*)fn_
						 file:(const char*)file_
						 line:(int)line_
{
  BOOL locked=NO;
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  if (!_mutex->owner || _mutex->owner==objc_thread_id())
	{
	  result=objc_mutex_trylock(_mutex);
//	  NSDebugMLLog(@"low",@"result=%d",result);
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
			   fromFunction:(const char*)fn_
					   file:(const char*)file_
					   line:(int)line_
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
//	  NSDebugMLLog(@"low",@"result=%d",result);
	  if (result == -1)
		locked=NO;
	  else
		locked=YES;
	}
  else
	notOwner=YES;
  while (!locked && [[NSDate date]compare:limit]==NSOrderedAscending)
	{
//	  NSDebugMLLog(@"low",@"tmplockBeforeDate wait");
	  usleep(100);
//	  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
	  if (!_mutex->owner || _mutex->owner==objc_thread_id())
		{
		  notOwner=NO;
		  result=objc_mutex_trylock(_mutex);
//		  NSDebugMLLog(@"low",@"result=%d",result);
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
//	  NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
	}
  else
	{
	  NSDebugMLog(@"NSLock tmptryLockBeforeDate lock: failed to lock mutex before %@ (%s). Called from %s in %s %d",
				  limit,
				  notOwner ? "Not Owner" : "result==-1",
				  fn_ ? fn_ : "Unknown",
				  file_ ? file_ : "Unknown",
				  line_);
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
			fromFunction:(const char*)fn_
					file:(const char*)file_
					line:(int)line_
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
//	  NSDebugMLLog(@"low",@"result=%d",result);
	  if (result == -1)
		locked=NO;
	  else
		locked=YES;
	}
  else
	notOwner=YES;

  while (!locked && [[NSDate date]compare:limit]==NSOrderedAscending)
	{
//	  NSDebugMLLog(@"low",@"tmplockBeforeDate wait");
	  usleep(100);
//	  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
	  if (!_mutex->owner || _mutex->owner==objc_thread_id())
		{
		  notOwner=NO;
		  result=objc_mutex_trylock(_mutex);
//		  NSDebugMLLog(@"low",@"result=%d",result);
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
//	  NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
	}
  else
	{
	  LOGException(@"NSLockException lock: failed to lock mutex before date %@ (%s). Called from %s in %s %d",
				   limit,
				   notOwner ? "Not Owner" : "result==-1",
				   fn_ ? fn_ : "Unknown",
				   file_ ? file_ : "Unknown",
				   line_);
	  [NSException raise:NSLockException
				   format:@"lock: failed to lock mutex before date %@ (%s). Called from %s in %s %d",
				   limit,
				   notOwner ? "Not Owner" : "result==-1",
				   fn_ ? fn_ : "Unknown",
				   file_ ? file_ : "Unknown",
				   line_];
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
-(void)tmpunlockFromFunction:(const char*)fn_
						file:(const char*)file_
						line:(int)line_;
{
  int result=0;
//  LOGObjectFnStart();
//  NSDebugMLLog(@"low",@"BEF _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
  if (_mutex->owner!=objc_thread_id())
	{
	  LOGException(@"NSLockException unlock: failed to unlock mutex (not owner). Called from %s in %s %d",
				   fn_ ? fn_ : "Unknown",
				   file_ ? file_ : "Unknown",
				   line_);
	  [NSException raise:NSLockException
				   format:@"unlock: failed to lock mutex (not owner). Called from %s in %s %d",
				   fn_ ? fn_ : "Unknown",
				   file_ ? file_ : "Unknown",
				   line_];
	}
  else
	{
	  result=objc_mutex_unlock(_mutex);
//	  NSDebugMLLog(@"low",@"AFT _mutex->owner=%p objc_thread_id()=%p",(void*)_mutex->owner,(void*)objc_thread_id());
//	  NSDebugMLLog(@"low",@"result=%d",result);
	  if (result == -1)
		{
		  LOGException(@"NSLockException unlock: failed to unlock mutex (result==-1). Called from %s in %s %d",
					   fn_ ? fn_ : "Unknown",
					   file_ ? file_ : "Unknown",
					   line_);
		  [NSException raise:NSLockException
					   format:@"unlock: failed to lock mutex (result==-1). Called from %s in %s %d",
					   fn_ ? fn_ : "Unknown",
					   file_ ? file_ : "Unknown",
					   line_];
		};
	};
//  LOGObjectFnStop();
};
@end

//====================================================================
@implementation NSArray (NSPerformSelectorWith2Objects)
//--------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector_
					   withObject:(id)object1_
					   withObject:(id)object2_
{
  unsigned i = [self count];
  while (i-- > 0)
    [[self objectAtIndex:i]performSelector:selector_
						   withObject:object1_
						   withObject:object2_];
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
-(void)makeObjectsPerformSelector:(SEL)selector_
{
  NSArray* _array=[self allValues];
  [_array makeObjectsPerformSelector:selector_];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector_
					   withObject:(id)object_
{
  NSArray* _array=[self allValues];
  [_array makeObjectsPerformSelector:selector_
		  withObject:object_];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelector:(SEL)selector_
					   withObject:(id)object1_
					   withObject:(id)object2_
{
  NSArray* _array=[self allValues];
  [_array makeObjectsPerformSelector:selector_
		  withObject:object1_
		  withObject:object2_];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
{
  NSArray* _array=[self allValues];
  [_array makeObjectsPerformSelectorIfPossible:aSelector];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformIfPossible:(SEL)aSelector
{
  NSArray* _array=[self allValues];
  [_array makeObjectsPerformSelectorIfPossible:aSelector];
};


//--------------------------------------------------------------------
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
								 withObject:(id)object_
{
  NSArray* _array=[self allValues];
  [_array makeObjectsPerformSelectorIfPossible:aSelector
		  withObject:object_];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformIfPossible:(SEL)aSelector
						 withObject:(id)argument
{
  NSArray* _array=[self allValues];
  [_array makeObjectsPerformSelectorIfPossible:aSelector
		  withObject:argument];
};

//--------------------------------------------------------------------
-(void)makeObjectsPerformSelectorIfPossible:(SEL)aSelector
								 withObject:(id)object1_
								 withObject:(id)object2_
{
  NSArray* _array=[self allValues];
  [_array makeObjectsPerformSelectorIfPossible:aSelector
		  withObject:object1_
		  withObject:object2_];
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
  
//--------------------------------------------------------------------
//To Move

//--------------------------------------------------------------------
NSString* DataToHexString(NSData* data)
{
  unsigned int size=[data length];
  if (size)
	{
	  const unsigned char* pData=(const unsigned char*)[data bytes];
	  if (pData)
		{
		  NSMutableString* string=[[NSMutableString new] autorelease];
		  int i=0;
		  for(i=0;i<size;i++)
			{
			  [string appendFormat:@"%02x",(unsigned int)pData[i]];
			};
		  return string;
		};
	};
  return nil;
};

//--------------------------------------------------------------------
NSData* HexStringToData(NSString* _string)
{
  int size=[_string length];
  if (size>0)
	{
	  const char* pString=(const char*)[[_string uppercaseString]cString];
	  if (pString)
		{
		  NSMutableData* data=[NSMutableData dataWithLength:size/2];
		  unsigned char* pData=(unsigned char*)[data bytes];
		  int i=0;
		  for(i=0;i<size/2;i++)
			{
			  if (pString[i*2]>='0' && pString[i*2]<='9')
				pData[i]=(pString[i*2]-'0') << 4;
			  else if (pString[i*2]>='A' && pString[i*2]<='F')
				pData[i]=(pString[i*2]-'A') << 4;
			  else
				{
				  NSCAssert(NO,@"Bad hex String");
				};
			  if (pString[i*2+1]>='0' && pString[i*2+1]<='9')
				pData[i]=pData[i]|(pString[i*2+1]-'0');
			  else if (pString[i*2+1]>='A' && pString[i*2+1]<='F')
				pData[i]=pData[i]|(pString[i*2+1]-'A');
			  else
				{
				  NSCAssert(NO,@"Bad hex String");
				};
			};
		  return data;
		};
	};
  return nil;
};

//===================================================================================
@implementation NSDictionary (SBDictionary)

//--------------------------------------------------------------------
-(id)		objectForKey:(id)_key
	   withDefaultObject:(id)_default
{
  id object=[self objectForKey:_key];
  if (object)
	return object;
  else
	return _default;
};

//--------------------------------------------------------------------
+(id)	dictionaryWithDictionary:(NSDictionary*)dictionary_
 andDefaultEntriesFromDictionary:(NSDictionary*)dictionaryDefaults_
{
  NSMutableDictionary* _dict=nil;
  if (dictionary_)
	{
	  _dict=[[dictionary_ mutableCopy]autorelease];
//	  NSDebugFLog(@"_dict=%@",_dict);
	  [_dict addDefaultEntriesFromDictionary:dictionaryDefaults_];
//	  NSDebugFLog(@"_dict=%@",_dict);
	  _dict=[NSDictionary dictionaryWithDictionary:_dict];
//	  NSDebugFLog(@"_dict=%@",_dict);
	}
  else
	_dict=[NSDictionary dictionaryWithDictionary:dictionaryDefaults_];
//  NSDebugFLog(@"_dict=%@",_dict);
  return _dict;
};

//--------------------------------------------------------------------
-(id)dictionaryBySettingObject:(id)object_
						forKey:(id)key_
{
  NSMutableDictionary* _dict=[[self mutableCopy]autorelease];
  [_dict setObject:object_
		 forKey:key_];
  _dict=[NSDictionary dictionaryWithDictionary:_dict];
  return _dict;
};

//--------------------------------------------------------------------
-(id)dictionaryByAddingEntriesFromDictionary:(NSDictionary*)dictionary_
{
  NSMutableDictionary* _dict=[[self mutableCopy]autorelease];
  [_dict addEntriesFromDictionary:dictionary_];
  _dict=[NSDictionary dictionaryWithDictionary:_dict];
  return _dict;
};

@end

//====================================================================
@implementation NSMutableDictionary (SBMutableDictionary)

//--------------------------------------------------------------------
-(void)setDefaultObject:(id)object_
				 forKey:(id)key_
{
  if (![self objectForKey:key_])
	[self setObject:object_
		  forKey:key_];
};

//--------------------------------------------------------------------
-(void)addDefaultEntriesFromDictionary:(NSDictionary*)dictionary_
{
  id _key=nil;
  NSEnumerator* _enum = [dictionary_ keyEnumerator];
  while ((_key = [_enum nextObject]))
    [self setDefaultObject:[dictionary_ objectForKey:_key]
		  forKey:_key];
};

@end


//===================================================================================
@implementation NSString (SBGoodPath)

//--------------------------------------------------------------------
-(NSString*)stringGoodPath
{
  NSString* _good=[self stringByStandardizingPath];
  while([_good hasSuffix:@"/."])
	{
	  if ([_good length]>2)
		_good=[_good stringWithoutSuffix:@"/."];
	  else
		_good=[NSString stringWithString:@"/"];
	};
  return _good;
};
@end

//====================================================================
@implementation NSUserDefaults (Description)

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - searchList:\n%@\n persDomains:\n%@\n tempDomains:\n%@\n changedDomains:\n%@\n dictionaryRep:\n%@\n defaultsDatabase:\n%@\n defaultsDatabaseLockName:\n%@\n defaultsDatabaseLock:\n%@\n tickingTimer:\n%@\n>",
				   object_get_class_name(self),
				   (void*)self,
				   _searchList,
				   _persDomains,
				   _tempDomains,
				   _changedDomains,
				   _dictionaryRep,
				   _defaultsDatabase,
				   _defaultsDatabaseLockName,
				   _defaultsDatabaseLock,
				   _tickingTimer];
};

@end

//====================================================================
@implementation NSDictionary (FromNSArray)

//--------------------------------------------------------------------
+(id)dictionaryWithArray:(NSArray*)array_
			  onSelector:(SEL)sel_
{
  NSMutableDictionary* _dict=[NSMutableDictionary dictionary];
  int _count=[array_ count];
  int i=0;
  id _object=nil;
  id _key=nil;
  for(i=0;i<_count;i++)
	{
	  //TODO optimiser
	  _object=[array_ objectAtIndex:i];
	  _key=[_object performSelector:sel_];
	  NSAssert1(_key,@"NSDictionary dictionaryWithArray: no key for object:%@",_object);
	  [_dict setObject:_object
			 forKey:_key];
	};
  return [self dictionaryWithDictionary:_dict];
};

//--------------------------------------------------------------------
+(id)dictionaryWithArray:(NSArray*)array_
			  onSelector:(SEL)sel_
			  withObject:(id)object
{
  NSMutableDictionary* _dict=[NSMutableDictionary dictionary];
  int _count=[array_ count];
  int i=0;
  id _object=nil;
  id _key=nil;
  for(i=0;i<_count;i++)
	{
	  //TODO optimiser
	  _object=[array_ objectAtIndex:i];
	  _key=[_object performSelector:sel_
					withObject:object];
	  NSAssert1(_key,@"NSDictionary dictionaryWithArray: no key for object:%@",_object);
	  [_dict setObject:_object
			 forKey:_key];
	};
  return [self dictionaryWithDictionary:_dict];
};
@end

//====================================================================
@implementation NSNumber (SBNumber)

//--------------------------------------------------------------------
+(NSNumber*)maxValueOf:(NSNumber*)_val0
				   and:(NSNumber*)_val1
{
  NSComparisonResult _compare=NSOrderedSame;
  NSAssert(_val0,@"_val0 can't be nil");
  NSAssert(_val1,@"_val1 can't be nil");
  NSAssert([_val0 isKindOfClass:[NSNumber class]],@"_val0 must't be a NSNumber");
  NSAssert([_val1 isKindOfClass:[NSNumber class]],@"_val1 must't be a NSNumber");
  _compare=[_val0 compare:_val1];
  if (_compare==NSOrderedAscending)
	return _val1;
  else
	return _val0;
};

//--------------------------------------------------------------------
+(NSNumber*)minValueOf:(NSNumber*)_val0
				   and:(NSNumber*)_val1
{
  NSComparisonResult _compare=NSOrderedSame;
  NSAssert(_val0,@"_val0 can't be nil");
  NSAssert(_val1,@"_val1 can't be nil");
  NSAssert([_val0 isKindOfClass:[NSNumber class]],@"_val0 must't be a NSNumber");
  NSAssert([_val1 isKindOfClass:[NSNumber class]],@"_val1 must't be a NSNumber");
  _compare=[_val0 compare:_val1];
  if (_compare==NSOrderedDescending)
	return _val1;
  else
	return _val0;
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
  NSRange _range=NSMakeRange(NSNotFound,0);
  NSDebugFLog(@"self=%@",self);
  NSDebugFLog(@"aData=%@",aData);
  NSDebugFLog(@"mask=%u",mask);
  NSDebugFLog(@"aRange=(%u,%u)",aRange.location,aRange.length);
  if (aData)
	{
	  int _aDataLength=[aData length];
	  int _selfLength=[self length];
	  NSDebugFLog(@"_aDataLength=%d",_aDataLength);
	  NSDebugFLog(@"_selfLength=%d",_selfLength);
	  if (aRange.location+aRange.length>_selfLength)
		[NSException raise:NSInvalidArgumentException format:@"Bad Range (%d,%d) for self length %d",
					 aRange.location,
					 aRange.length,
					 _selfLength];
	  else if (_aDataLength>0)		
		{
		  BOOL _reverse=((mask&NSBackwardsSearch)==NSBackwardsSearch);
		  BOOL _anchored=((mask&NSAnchoredSearch)==NSAnchoredSearch);
		  const void* _bytes=[self bytes];
		  const void* _aDataBytes=[aData bytes];
		  NSDebugFLog(@"_reverse=%d",(int)_reverse);
		  NSDebugFLog(@"_anchored=%d",(int)_anchored);
		  if (_anchored)
			{
			  // Can be found ?
			  if (_aDataLength<=aRange.length)
				{
				  if (_reverse)
					{
					  NSDebugFLog(@"cmp at %d length %d",
								  aRange.location-_aDataLength,
								  _aDataLength);
					  if (memcmp(_bytes+aRange.location-_aDataLength,
								 _aDataBytes,
								 _aDataLength)==0)
						{
						  NSDebugFLog0(@"FOUND");
						  _range=NSMakeRange(_selfLength-_aDataLength,_aDataLength);
						};
					}
				  else
					{
					  NSDebugFLog(@"cmp at %d length %d",
								  aRange.location,
								  _aDataLength);
					  if (memcmp(_bytes+aRange.location,
								 _aDataBytes,
								 _aDataLength))
						{
						  NSDebugFLog0(@"FOUND");
						  _range=NSMakeRange(0,_aDataLength);
						};
					};
				};
			}
		  else
			{
			  if (_reverse)
				{
				  int i=0;
				  int _first=(aRange.location+_aDataLength);
				  NSDebugFLog(@"cmp at %d downto index: %d",
							  aRange.location+aRange.length-1,
							  _first);
				  for(i=aRange.location+aRange.length-1;i>=_first && _range.length==0;i--)
					{
					  if (((unsigned char*)_bytes)[i]==((unsigned char*)_aDataBytes)[_aDataLength-1])
						{
						  NSDebugFLog(@"FOUND Last Char at %d",i);
						  if (memcmp(_bytes+i-_aDataLength,_aDataBytes,_aDataLength)==0)
							{
							  _range=NSMakeRange(i-_aDataLength,_aDataLength);
							  NSDebugFLog(@"FOUND at %d",i-_aDataLength);
							};
						};
					};
				}
			  else
				{
				  int i=0;
				  int _last=aRange.location+aRange.length-_aDataLength;
				  NSDebugFLog(@"cmp at %d upto index: %d",
							  aRange.location,
							  _last);
				  for(i=aRange.location;i<=_last && _range.length==0;i++)
					{
					  if (((unsigned char*)_bytes)[i]==((unsigned char*)_aDataBytes)[0])
						{
						  NSDebugFLog(@"FOUND First Char at %d",i);
						  if (memcmp(_bytes+i,_aDataBytes,_aDataLength)==0)
							{
							  _range=NSMakeRange(i,_aDataLength);
							  NSDebugFLog(@"FOUND at %d",i);
							};
						};
					};
				};
			};
		};
	}
  else
    [NSException raise:NSInvalidArgumentException format: @"range of nil"];  
  return _range;
}

//--------------------------------------------------------------------
-(NSArray*)componentsSeparatedByData:(NSData*)separator_
{
  NSRange search, complete;
  NSRange found;
  NSData* tmpData=nil;
  NSMutableArray *array = [NSMutableArray array];
  NSDebugFLog(@"separator_ %@ length=%d",separator_,[separator_ length]);
  NSDebugFLog(@"self length=%d",[self length]);
  search=NSMakeRange(0, [self length]);
  complete=search;
  found=[self rangeOfData:separator_];
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
      found = [self rangeOfData:separator_
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
-(NSData*)dataByDeletingFirstBytesCount:(unsigned int)bytesCount_
{
  NSMutableData* tmpdata=[self mutableCopy];
  [tmpdata deleteFirstBytesCount:bytesCount_];
  return [NSData dataWithData:tmpdata];
};

//--------------------------------------------------------------------
-(NSData*)dataByDeletingLastBytesCount:(unsigned int)bytesCount_
{
  NSMutableData* tmpdata=[self mutableCopy];
  [tmpdata deleteLastBytesCount:bytesCount_];
  return [NSData dataWithData:tmpdata];
};

@end

//====================================================================
@implementation NSMutableData (SBNSData)

//--------------------------------------------------------------------
-(void)deleteFirstBytesCount:(unsigned int)bytesCount_
{
  void* _mutableBytes=NULL;
  unsigned int _length=[self length];
  NSAssert2(_length>=bytesCount_,@"Can't delete %d first bytes from a data of length %d",bytesCount_,_length);
  _mutableBytes=[self mutableBytes];
  memmove(_mutableBytes,_mutableBytes+bytesCount_,bytesCount_);
  [self setLength:_length-bytesCount_];
};

//--------------------------------------------------------------------
-(void)deleteLastBytesCount:(unsigned int)bytesCount_;
{
  unsigned int _length=[self length];
  NSAssert2(_length>=bytesCount_,@"Can't delete %d last bytes from a data of length %d",bytesCount_,_length);
  [self setLength:_length-bytesCount_];
};
@end


//====================================================================
@implementation NSNumberFormatter

//--------------------------------------------------------------------
-(id)initType:(NSNumFmtType)type_
{
  if ((self=[super init]))
	{
	  type=type_;
	};
  return self;
};

//--------------------------------------------------------------------
-(NSString*)stringForObjectValue:(id)anObject
{
  NSString* _string=nil;
  if ([anObject isKindOfClass:[NSString class]])
	_string=anObject;
  else if (anObject)
	{
	  switch(type)
		{
		case NSNumFmtType__Int:
		  if ([anObject isKindOfClass:[NSNumber class]])
			{
			  int _value=[anObject intValue];
			  _string=[NSString stringWithFormat:@"%d",_value];
			}
		  else if ([anObject respondsToSelector:@selector(intValue)])
			{
			  int _value=[anObject intValue];
			  _string=[NSString stringWithFormat:@"%d",_value];			  
			}
		  else if ([anObject respondsToSelector:@selector(floatValue)])
			{
			  int _value=(int)[anObject floatValue];
			  _string=[NSString stringWithFormat:@"%d",_value];			  
			}
		  else if ([anObject respondsToSelector:@selector(doubleValue)])
			{
			  int _value=(int)[anObject doubleValue];
			  _string=[NSString stringWithFormat:@"%d",_value];			  
			}
		  else
			{
			  LOGSeriousError(@"Can't convert %@ of class %@ to string",
							  anObject,
							  [anObject class]);
			  _string=@"***";
			};
		  break;
		case NSNumFmtType__Float:
		  if ([anObject isKindOfClass:[NSNumber class]])
			{
			  double _value=[anObject doubleValue];
			  _string=[NSString stringWithFormat:@"%.2f",_value];
			}
		  else if ([anObject respondsToSelector:@selector(intValue)])
			{
			  int _value=[anObject intValue];
			  _string=[NSString stringWithFormat:@"%d.00",_value];			  
			}
		  else if ([anObject respondsToSelector:@selector(floatValue)])
			{
			  double _value=(double)[anObject floatValue];
			  _string=[NSString stringWithFormat:@"%.2f",_value];			  
			}
		  else if ([anObject respondsToSelector:@selector(doubleValue)])
			{
			  double _value=[anObject doubleValue];
			  _string=[NSString stringWithFormat:@"%.2f",_value];			  
			}
		  else
			{
			  LOGSeriousError(@"Can't convert %@ of class %@ to string",
							  anObject,
							  [anObject class]);
			  _string=@"***";
			};
		  break;
		case NSNumFmtType__Unknown:
		default:
		  LOGSeriousError(@"Unknown type %d to convert %@ to string",
						  (int)type,
						  anObject);
		  _string=@"***";
		  break;
		};
	};
  return _string;
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
  switch(type)
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
					  (int)type,
					  string);
	   *error = @"Unknown type";
	  break;
	};
  return ok;
};

@end
