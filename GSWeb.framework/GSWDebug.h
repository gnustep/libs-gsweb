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


#ifdef DEBUG
extern void GSWLogC_(CONST char* file,int line,CONST char* string);
extern void GSWLogDumpObject_(CONST char* file,int line,id object,int deep);
extern void GSWLogAssertGood_(CONST char* file,int line,NSObject* object);

#define GSWLogC(cString);				GSWLogC_(__FILE__,__LINE__,cString);
#define GSWLogDumpObject(object,deep); 	GSWLogDumpObject_(__FILE__,__LINE__,object,deep);
#define GSWLogAssertGood(object); 		GSWLogAssertGood_(__FILE__,__LINE__,object);
#else
#define GSWLogC(cString);				
#define GSWLogDumpObject(object,deep);
#define GSWLogAssertGood(object);
#endif


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
