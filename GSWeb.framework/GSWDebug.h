/** debug.h - debug
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
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
**/

// $Id$

#ifndef _GSWebDebug_h__
#define _GSWebDebug_h__

#ifdef DEBUG
extern void GSWLogC_(CONST char* file,int line,CONST char* string);
extern void GSWLogDumpObjectFn(CONST char* file,int line,id object,int deep);
extern void GSWLogAssertGoodFn(CONST char* file,int line,NSObject* object);
#endif
#ifdef GSWDEBUG

#define GSWLogC(cString);				GSWLogC_(__FILE__,__LINE__,cString);
#define GSWLogDumpObject(object,deep); 	GSWLogDumpObjectFn(__FILE__,__LINE__,object,deep);
#define GSWLogAssertGood(object); 		GSWLogAssertGoodFn(__FILE__,__LINE__,object);

//Log Memory Alloc/Dealloc
#ifdef GSWDEBUG_MEM
#define GSWLogMemC(cString);				GSWLogC_(__FILE__,__LINE__,cString);
#else
#define GSWLogMemC(cString);				
#endif

//Log Locks
#ifdef GSWDEBUG_LOCK
#define GSWLogLockC(cString);				GSWLogC_(__FILE__,__LINE__,cString);
#else
#define GSWLogLockC(cString);				
#endif

//Log Locks
#ifdef GSWDEBUG_DEEP
#define GSWLogDeepC(cString);				GSWLogC_(__FILE__,__LINE__,cString);
#else
#define GSWLogDeepC(cString);				
#endif

#else // no GSWDEBUG
#define GSWLogC(cString);			{}	
#define GSWLogDumpObject(object,deep);		{}
#define GSWLogAssertGood(object);		{}
#define GSWLogMemC(cString);			{}	
#define GSWLogLockC(cString);			{}	
#define GSWLogDeepC(cString);			{}	
#endif

// Normal Debug
#ifdef GSWDEBUG
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
    NSLog(fmt2, ## args); }} while (0)

#define LOGSeriousError0(format) 	\
  do { if (GSDebugSet(@"seriousError") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*SERIOUS ERROR*: %@",fmt]; \
	NSLog(@"%@",fmt2); }} while (0)

#define LOGException(format, args...) 	\
  do { if (GSDebugSet(@"exception") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*EXCEPTION*: %@",fmt]; \
    NSLog(fmt2, ## args); }} while (0)

#define LOGException0(format) 	\
  do { if (GSDebugSet(@"exception") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*EXCEPTION*: %@",fmt]; \
	NSLog(@"%@",fmt2); }} while (0)

#define LOGError(format, args...) 	\
  do { if (GSDebugSet(@"error") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*ERROR*: %@",fmt]; \
    NSLog(fmt2, ## args);}} while (0)

#define LOGError0(format) 	\
  do { if (GSDebugSet(@"error") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*ERROR*: %@",fmt]; \
    NSLog(@"%@",fmt2); }} while (0)

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

#else // no GSWDEBUG
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

//Deep Debug
#if defined(DEBUG) && defined(GSWDEBUG_DEEP)
#define LOGDEEPClassFnStart()  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTART"); \
    NSLog(fmt); }} while (0)

#define LOGDEEPClassFnStop()  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__,__FILE__, __LINE__,@"FNSTOP"); \
    NSLog(fmt); }} while (0)

#define LOGDEEPClassFnStartC(comment)  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTART %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGDEEPClassFnStopC(comment)  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTOP %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGDEEPClassFnStartCond(cond)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTART"); \
    NSLog(fmt); }} while (0)

#define LOGDEEPClassFnStopCond(cond)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTOP"); \
    NSLog(fmt); }} while (0)

#define LOGDEEPClassFnStartCondC(cond,comment)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTART %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGDEEPClassFnStopCondC(cond,comment)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTOP %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGDEEPObjectFnStart()  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTART"); \
    NSLog(fmt); }} while (0)

#define LOGDEEPObjectFnStop()  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTOP"); \
    NSLog(fmt); }} while (0)

#define LOGDEEPObjectFnStartC(comment)  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTART %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGDEEPObjectFnStopC(comment)  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTOP %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGDEEPObjectFnStartCond(cond)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTART"); \
    NSLog(fmt); }} while (0)

#define LOGDEEPObjectFnStopCond(cond)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTOP"); \
    NSLog(fmt); }} while (0)

#define LOGDEEPObjectFnStartCondC(cond,comment)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTART %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGDEEPObjectFnStopCondC(cond,comment)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTOP %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGDEEPObjectFnNotImplemented()	  \
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"NOT IMPLEMENTED"); \
    NSLog(fmt); }} while (0)

#define LOGDEEPClassFnNotImplemented() 	\
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"NOT IMPLEMENTED"); \
    NSLog(fmt); }} while (0)

#define LOGDEEPClassFnNotImplemented() 	\
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"NOT IMPLEMENTED"); \
    NSLog(fmt); }} while (0)

#define LOGDEEPSeriousError(format, args...) 	\
  do { if (GSDebugSet(@"seriousError") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*SERIOUS ERROR*: %@",fmt]; \
    NSLog(fmt2, ## args); }} while (0)

#define LOGDEEPSeriousError0(format) 	\
  do { if (GSDebugSet(@"seriousError") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*SERIOUS ERROR*: %@",fmt]; \
	NSLog(@"%@",fmt2); }} while (0)

#define LOGDEEPException(format, args...) 	\
  do { if (GSDebugSet(@"exception") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*EXCEPTION*: %@",fmt]; \
    NSLog(fmt2, ## args); }} while (0)

#define LOGDEEPException0(format) 	\
  do { if (GSDebugSet(@"exception") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*EXCEPTION*: %@",fmt]; \
	NSLog(@"%@",fmt2); }} while (0)

#define LOGDEEPError(format, args...) 	\
  do { if (GSDebugSet(@"error") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*ERROR*: %@",fmt]; \
    NSLog(fmt2, ## args);}} while (0)

#define LOGDEEPError0(format) 	\
  do { if (GSDebugSet(@"error") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*ERROR*: %@",fmt]; \
    NSLog(@"%@",fmt2); }} while (0)

#define NSDebugDeepMLLogCond(cond, level, format, args...) \
  do { if (cond && GSDebugSet(level) == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt, ## args); }} while (0)

#define NSDebugDeepMLog(format, args...) \
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt, ## args); }} while (0)

#define NSDebugDeepMLLog(level, format, args...) \
  do { if (GSDebugSet(level) == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt, ## args); }} while (0)

#define NSDebugDeepMLogCond(cond, format, args...) \
  do { if (cond && GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt, ## args); }} while (0)

#define NSDebugDeepMLog0(format) \
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt); }} while (0)

#define NSDebugDeepMLLog0(level,format) \
  do { if (GSDebugSet(level) == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt); }} while (0)

#define NSDebugDeepFLog0(format) \
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugFunctionMsg( \
        __PRETTY_FUNCTION__, __FILE__, __LINE__, format); \
    NSLog(fmt); }} while (0)

#define NSDebugDeepFLLog0(level,format) \
  do { if (GSDebugSet(level) == YES) { \
    NSString *fmt = GSDebugFunctionMsg( \
        __PRETTY_FUNCTION__, __FILE__, __LINE__, format); \
    NSLog(fmt); }} while (0)

#else
#define LOGDEEPClassFnStart()  	{}
#define LOGDEEPClassFnStop()	{}
#define LOGDEEPClassFnStartC(comment)  {}
#define LOGDEEPClassFnStopC(comment)	{}
#define LOGDEEPClassFnStartCond(cond)  {}
#define LOGDEEPClassFnStopCond(cond)  	{}
#define LOGDEEPClassFnStartCondC(cond,comment)  {} 
#define LOGDEEPClassFnStopCondC(cond,comment)  	{}
#define LOGDEEPClassFnNotImplemented() 	{}
#define LOGDEEPObjectFnStart()  	{}
#define LOGDEEPObjectFnStop()	{}
#define LOGDEEPObjectFnStartC(comment)  {}
#define LOGDEEPObjectFnStopC(comment)	{}
#define LOGDEEPObjectFnStartCond(cond)  {}
#define LOGDEEPObjectFnStopCond(cond)  	{}
#define LOGDEEPObjectFnStartCondC(cond,comment)  {}
#define LOGDEEPObjectFnStopCondC(cond,comment)  	{}
#define LOGDEEPObjectFnNotImplemented()	  {}
#define LOGDEEPSeriousError(format, args...) 	{}
#define LOGDEEPSeriousError0(format) 	{}
#define LOGDEEPError(format, args...) 	{}
#define LOGDEEPError0(format) 	{}
#define LOGDEEPException(format, args...) 		{}
#define LOGDEEPException0(format) 	{}
#define NSDebugDeepMLLog(format, args...) {}
#define NSDebugDeepMLog(format, args...) {}
#define NSDebugDeepMLog0(format) {}
#define NSDebugDeepMLLog0(level,format) {}
#define NSDebugDeepFLog0(format) {}
#define NSDebugDeepFLLog0(level,format) {}
#define NSDebugDeepMLLogCond(cond, level, format, args...)  {} 
#define NSDebugDeepMLogCond(cond, format, args...) {}
#endif

//Lock Debug
#if defined(DEBUG) && (defined(GSWDEBUG_DEEP) || defined (GSWDEBUG_LOCK))
#define LOGLOCKClassFnStart()  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTART"); \
    NSLog(fmt); }} while (0)

#define LOGLOCKClassFnStop()  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__,__FILE__, __LINE__,@"FNSTOP"); \
    NSLog(fmt); }} while (0)

#define LOGLOCKClassFnStartC(comment)  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTART %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGLOCKClassFnStopC(comment)  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTOP %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGLOCKClassFnStartCond(cond)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTART"); \
    NSLog(fmt); }} while (0)

#define LOGLOCKClassFnStopCond(cond)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTOP"); \
    NSLog(fmt); }} while (0)

#define LOGLOCKClassFnStartCondC(cond,comment)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTART %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGLOCKClassFnStopCondC(cond,comment)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"FNSTOP %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGLOCKObjectFnStart()  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTART"); \
    NSLog(fmt); }} while (0)

#define LOGLOCKObjectFnStop()  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTOP"); \
    NSLog(fmt); }} while (0)

#define LOGLOCKObjectFnStartC(comment)  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTART %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGLOCKObjectFnStopC(comment)  \
  do { if (GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTOP %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGLOCKObjectFnStartCond(cond)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTART"); \
    NSLog(fmt); }} while (0)

#define LOGLOCKObjectFnStopCond(cond)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTOP"); \
    NSLog(fmt); }} while (0)

#define LOGLOCKObjectFnStartCondC(cond,comment)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTART %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGLOCKObjectFnStopCondC(cond,comment)  \
  do { if (cond && GSDebugSet(@"GSWebFn") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"FNSTOP %s"); \
    NSLog(fmt,comment); }} while (0)

#define LOGLOCKObjectFnNotImplemented()	  \
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugMethodMsg(self, _cmd, __FILE__, __LINE__,@"NOT IMPLEMENTED"); \
    NSLog(fmt); }} while (0)

#define LOGLOCKClassFnNotImplemented() 	\
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"NOT IMPLEMENTED"); \
    NSLog(fmt); }} while (0)

#define LOGLOCKClassFnNotImplemented() 	\
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,@"NOT IMPLEMENTED"); \
    NSLog(fmt); }} while (0)

#define LOGLOCKSeriousError(format, args...) 	\
  do { if (GSDebugSet(@"seriousError") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*SERIOUS ERROR*: %@",fmt]; \
    NSLog(fmt2, ## args); }} while (0)

#define LOGLOCKSeriousError0(format) 	\
  do { if (GSDebugSet(@"seriousError") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*SERIOUS ERROR*: %@",fmt]; \
	NSLog(@"%@",fmt2); }} while (0)

#define LOGLOCKException(format, args...) 	\
  do { if (GSDebugSet(@"exception") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*EXCEPTION*: %@",fmt]; \
    NSLog(fmt2, ## args); }} while (0)

#define LOGLOCKException0(format) 	\
  do { if (GSDebugSet(@"exception") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*EXCEPTION*: %@",fmt]; \
	NSLog(@"%@",fmt2); }} while (0)

#define LOGLOCKError(format, args...) 	\
  do { if (GSDebugSet(@"error") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*ERROR*: %@",fmt]; \
    NSLog(fmt2, ## args);}} while (0)

#define LOGLOCKError0(format) 	\
  do { if (GSDebugSet(@"error") == YES) { \
    NSString *fmt = GSDebugFunctionMsg(__PRETTY_FUNCTION__, __FILE__, __LINE__,format); \
    NSString *fmt2 = [NSString stringWithFormat:@"*ERROR*: %@",fmt]; \
    NSLog(@"%@",fmt2); }} while (0)

#define NSDebugLockMLLogCond(cond, level, format, args...) \
  do { if (cond && GSDebugSet(level) == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt, ## args); }} while (0)

#define NSDebugLockMLLog(level, format, args...) \
  do { if (GSDebugSet(level) == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt, ## args); }} while (0)

#define NSDebugLockMLogCond(cond, format, args...) \
  do { if (cond && GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt, ## args); }} while (0)

#define NSDebugLockMLog(format, args...) \
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt, ## args); }} while (0)

#define NSDebugLockMLog0(format) \
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt); }} while (0)

#define NSDebugLockMLLog0(level,format) \
  do { if (GSDebugSet(level) == YES) { \
    NSString *fmt = GSDebugMethodMsg( \
        self, _cmd, __FILE__, __LINE__, format); \
    NSLog(fmt); }} while (0)

#define NSDebugLockFLog0(format) \
  do { if (GSDebugSet(@"dflt") == YES) { \
    NSString *fmt = GSDebugFunctionMsg( \
        __PRETTY_FUNCTION__, __FILE__, __LINE__, format); \
    NSLog(fmt); }} while (0)

#define NSDebugLockFLLog0(level,format) \
  do { if (GSDebugSet(level) == YES) { \
    NSString *fmt = GSDebugFunctionMsg( \
        __PRETTY_FUNCTION__, __FILE__, __LINE__, format); \
    NSLog(fmt); }} while (0)

#else
#define LOGLOCKClassFnStart()  	{}
#define LOGLOCKClassFnStop()	{}
#define LOGLOCKClassFnStartC(comment)  {}
#define LOGLOCKClassFnStopC(comment)	{}
#define LOGLOCKClassFnStartCond(cond)  {}
#define LOGLOCKClassFnStopCond(cond)  	{}
#define LOGLOCKClassFnStartCondC(cond,comment)  {} 
#define LOGLOCKClassFnStopCondC(cond,comment)  	{}
#define LOGLOCKClassFnNotImplemented() 	{}
#define LOGLOCKObjectFnStart()  	{}
#define LOGLOCKObjectFnStop()	{}
#define LOGLOCKObjectFnStartC(comment)  {}
#define LOGLOCKObjectFnStopC(comment)	{}
#define LOGLOCKObjectFnStartCond(cond)  {}
#define LOGLOCKObjectFnStopCond(cond)  	{}
#define LOGLOCKObjectFnStartCondC(cond,comment)  {}
#define LOGLOCKObjectFnStopCondC(cond,comment)  	{}
#define LOGLOCKObjectFnNotImplemented()	  {}
#define LOGLOCKSeriousError(format, args...) 	{}
#define LOGLOCKSeriousError0(format) 	{}
#define LOGLOCKError(format, args...) 	{}
#define LOGLOCKError0(format) 	{}
#define LOGLOCKException(format, args...) 		{}
#define LOGLOCKException0(format) 	{}
#define NSDebugLockMLLog(format, args...) {}
#define NSDebugLockMLog(format, args...) {}
#define NSDebugLockMLog0(format) {}
#define NSDebugLockMLLog0(level,format) {}
#define NSDebugLockFLog0(format) {}
#define NSDebugLockFLLog0(level,format) {}
#define NSDebugLockMLLogCond(cond, level, format, args...)  {} 
#define NSDebugLockMLogCond(cond, format, args...) {}
#endif

#endif // _GSWebDebug_h__
