/* debug.h - debug
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

// $Id$

#ifndef _GSWebDebug_h__
#define _GSWebDebug_h__

//extern void logObjectFnNotImplemented(CONST char* file,int line,id obj,SEL cmd);
//extern void logClassFnNotImplemented(CONST char* file,int line,Class class,SEL cmd);
//extern void logObjectFnStart(CONST char* file,int line,id obj,SEL cmd,CONST char* comment,BOOL dumpClass);
//extern void logObjectFnStop(CONST char* file,int line,id obj,SEL cmd,CONST char* comment);
//extern void logClassFnStart(CONST char* file,int line,Class class,SEL cmd,CONST char* comment);
//extern void logClassFnStop(CONST char* file,int line,Class class,SEL cmd,CONST char* comment);
extern void DumpObject(CONST char* file,int line,id object,int level);
extern void GSWLog(NSString* string);
extern void GSWLogStdOut(NSString* string);
extern void GSWLogCStdOut(CONST char* string);
extern void GSWLog(NSString* string);
extern void GSWLogC(CONST char* string);
extern void GSWLogF(NSString* format,...);
//extern void GSWLogFStdOut(NSString* format,...);
//extern void GSWLogFCond(BOOL cond,NSString* format,...);
//extern void GSWLogError(CONST char* file,int line);
//extern void GSWLogException(CONST char* comment,CONST char* file,int line);
//extern void GSWLogExceptionF(CONST char* file,int line,NSString* format,...);
//extern void GSWLogErrorF(CONST char* file,int line,NSString* format,...);
extern void GSWAssertGood(NSObject* object,CONST char* file,int line);

#define LOGDumpObject(object,level)	DumpObject(__FILE__,__LINE__,object,level)
//#define LOGError();					GSWLogError(__FILE__,__LINE__);
//#define LOGException(comment);	    GSWLogException(comment,__FILE__,__LINE__);
#define LOGAssertGood(object);		GSWAssertGood(object,__FILE__,__LINE__);

#ifdef DEBUG
#define LOGClassFnStart()  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTART"); \
    NSLog(fmt); }} while (0)

#define LOGClassFnStop()  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__,__FILE__, __LINE__,@"FNSTOP"); \
    NSLog(fmt); }} while (0)

#define LOGClassFnStartC(comment)  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTART %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGClassFnStopC(comment)  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTOP %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGClassFnStartCond(cond)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTART"); \
    NSLog(fmt); }} while (0)

#define LOGClassFnStopCond(cond)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTOP"); \
    NSLog(fmt); }} while (0)

#define LOGClassFnStartCondC(cond,comment)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTART %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGClassFnStopCondC(cond,comment)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTOP %s"); \
    NSLog(fmt,comment); }} while (0)


#define LOGObjectFnStart()  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTART"); \
    NSLog(fmt); }} while (0)

#define LOGObjectFnStop()  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTOP"); \
    NSLog(fmt); }} while (0)

#define LOGObjectFnStartC(comment)  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTART %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGObjectFnStopC(comment)  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTOP %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGObjectFnStartCond(cond)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTART"); \
    NSLog(fmt); }} while (0)

#define LOGObjectFnStopCond(cond)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTOP"); \
    NSLog(fmt); }} while (0)

#define LOGObjectFnStartCondC(cond,comment)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTART %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGObjectFnStopCondC(cond,comment)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTOP %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGObjectFnNotImplemented()	  \
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"NOT IMPLEMENTED"); \
    NSLog(fmt); }} while (0)

#define LOGClassFnNotImplemented() 	\
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"NOT IMPLEMENTED"); \
    NSLog(fmt); }} while (0)

#define LOGClassFnNotImplemented() 	\
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"NOT IMPLEMENTED"); \
    NSLog(fmt); }} while (0)

#define LOGSeriousError(format, args...) 	\
  do { if (GSDebugSet(@"seriousError") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*SERIOUS ERROR*: %@",fmt]; \
    /*NSLog(fmt2,## args);*/ \
    [GSWApp logErrorWithFormat:fmt2, ## args];}} while (0)

#define LOGSeriousError0(format) 	\
  do { if (GSDebugSet(@"seriousError") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*SERIOUS ERROR*: %@",fmt]; \
    /*NSLog(fmt2);*/ \
    [GSWApp logErrorWithFormat:@"%@",fmt2]; }} while (0)

#define LOGException(format, args...) 	\
  do { if (GSDebugSet(@"exception") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*EXCEPTION*: %@",fmt]; \
    /*NSLog(fmt2,## args);*/ \
    [GSWApp logErrorWithFormat:fmt2, ## args]; }} while (0)

#define LOGException0(format) 	\
  do { if (GSDebugSet(@"exception") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*EXCEPTION*: %@",fmt]; \
    /*NSLog(fmt2);*/ \
	[GSWApp logErrorWithFormat:@"%@",fmt2]; }} while (0)

#define LOGError(format, args...) 	\
  do { if (GSDebugSet(@"error") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*ERROR*: %@",fmt]; \
    /*NSLog(fmt2,## args);*/ \
    [GSWApp logErrorWithFormat:fmt2, ## args];}} while (0)

#define LOGError0(format) 	\
  do { if (GSDebugSet(@"error") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*ERROR*: %@",fmt]; \
    /*NSLog(fmt2);*/ \
    [GSWApp logErrorWithFormat:@"%@",fmt2]; }} while (0)

#define NSDebugMLLogCond(cond, level, format, args...) \
  do { if (cond && GSDebugSet(level) == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt, ## args); }} while (0)

#define NSDebugMLogCond(cond, format, args...) \
  do { if (cond && GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt, ## args); }} while (0)

#define NSDebugMLog0(format) \
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt); }} while (0)

#define NSDebugMLLog0(level,format) \
  do { if (GSDebugSet(level) == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt); }} while (0)

#define NSDebugFLog0(format) \
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugFunctionMsg( \
        __PRETTY_FUNCTION__, __FILE__, __LINE__, format); \
    NSLog(fmt); }} while (0)

#define NSDebugFLLog0(level,format) \
  do { if (GSDebugSet(level) == YES) { \
    NSString *fmt = GSDebugFunctionMsg( \
        __PRETTY_FUNCTION__, __FILE__, __LINE__, format); \
    NSLog(fmt); }} while (0)

#else
#define LOGClassFnStart()  	{}
#define LOGClassFnStop()	{}
#define LOGClassFnStartC(comment)  {}
#define LOGClassFnStopC(comment)	{}
#define LOGClassFnStartCond(cond)  {}
#define LOGClassFnStopCond(cond)  	{}
#define LOGClassFnStartCondC(cond,comment)  {} 
#define LOGClassFnStopCondC(cond,comment)  	{}
#define LOGClassFnNotImplemented() 	{}
#define LOGObjectFnStart()  	{}
#define LOGObjectFnStop()	{}
#define LOGObjectFnStartC(comment)  {}
#define LOGObjectFnStopC(comment)	{}
#define LOGObjectFnStartCond(cond)  {}
#define LOGObjectFnStopCond(cond)  	{}
#define LOGObjectFnStartCondC(cond,comment)  {}
#define LOGObjectFnStopCondC(cond,comment)  	{}
#define LOGObjectFnNotImplemented()	  {}
#define LOGSeriousError(format, args...) 	{}
#define LOGSeriousError0(format) 	{}
#define LOGError(format, args...) 	{}
#define LOGError0(format) 	{}
#define LOGException(format, args...) 		{}
#define LOGException0(format) 	{}
#define NSDebugMLog0(format) {}
#define NSDebugMLLog0(level,format) {}
#define NSDebugFLog0(format) {}
#define NSDebugFLLog0(level,format) {}
#define NSDebugMLLogCond(cond, level, format, args...)  {} 
#define NSDebugMLogCond(cond, format, args...) {}
#endif
#endif // _GSWebDebug_h__
