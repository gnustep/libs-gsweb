/* GSWProcFS - /proc management
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Oct 1999
   
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

#ifndef _GSWProcFS_h__
#define _GSWProcFS_h__

//extern NSTimeInterval NSTimeIntervalFromTimeVal(struct timeval* tv);

typedef enum _GSWProcState
{
  GSWProcState__Unknown =0,
  GSWProcState__Sleeping,
  GSWProcState__Running,
  GSWProcState__Zombie,
  GSWProcState__Stopped,
  GSWProcState__SleepWait

} GSWProcState;
@interface GSWProcFSProcInfo : NSObject <NSCoding,NSCopying>
{
  NSString* user;		// user name corresponding to owner of process [/proc/#/stat]
  NSString* cmd;		// basename of executable file in call to exec(2) [/proc/#/stat]
  GSWProcState state;	// single-char code for process state (S=sleeping) [/proc/#/stat]
  NSString* ttyc;		// string representation of controlling tty device [/proc/#/stat]
  NSArray* environ;		// environment string vector (/proc/#/environ) 
  NSArray* cmdline;		// command line string vector (/proc/#/cmdline) 
  uid_t uid;            // user id 
  pid_t pid;            // process id [/proc/#/stat]
  pid_t ppid;           // pid of parent process [/proc/#/stat]
  pid_t pgrp;           // process group id [/proc/#/stat]
  int session;        // session id [/proc/#/stat]
  int tty;            // full device number of controlling terminal [/proc/#/stat]
  pid_t tpgid;          // terminal process group id [/proc/#/stat]
  int priority;       // kernel scheduling priority [/proc/#/stat]
  int nice;           // standard unix nice level of process [/proc/#/stat]
  long long signal;         // mask of pending signals [/proc/#/stat]
  long long blocked;        // mask of blocked signals [/proc/#/stat]
  long long sigIgnore;      // mask of ignored signals [/proc/#/stat]
  long long sigCatch;       // mask of caught  signals [/proc/#/stat]
  NSTimeInterval startTime;     // start time of process (Absolute)[/proc/#/stat]
  NSTimeInterval userTime; // user-mode CPU time accumulated by process [/proc/#/stat]
  NSTimeInterval systemTime;          // kernel-mode CPU time accumulated by process [/proc/#/stat]
  NSTimeInterval cumulativeUserTime;         // cumulative utime of process and reaped children [/proc/#/stat]
  NSTimeInterval cumulativeSystemTime;         // cumulative stime of process and reaped children [/proc/#/stat]
  long pagesNb;           // total # of pages of memory [/proc/#/statm]
  long residentPagesNb;       // number of resident set (non-swapped) pages (4k) [/proc/#/statm]
  long sharedPagesNb;          // number of pages of shared (mmap'd) memory [/proc/#/statm]
  long textResidentSize;            // text resident set size [/proc/#/statm]
  long sharedLibResidentSize;            // shared-lib resident set size [/proc/#/statm]
  long dataResidentSize;            // data resident set size [/proc/#/statm]
  long dirtyPagesNb;             // dirty pages [/proc/#/statm]
  unsigned cpuUsagePC; // %CPU usage (is not filled in by readproc!!!)   
  unsigned long virtualPagesNb;          // number of pages of virtual memory ... [/proc/#/stat]
  unsigned long residentMemorySize;            // resident set size from /proc/#/stat 
  unsigned long residentMemorySizeLimit;       // resident set size ... ?
  unsigned long timeout;        // ? [/proc/#/stat]
  unsigned long it_real_value;  // ? [/proc/#/stat]
  unsigned long flags;          // kernel flags for the process [/proc/#/stat]
  unsigned long minorPageFaultNb;        // number of minor page faults since process start [/proc/#/stat]
  unsigned long majorPageFaultNb;        // number of major page faults since process start [/proc/#/stat]
  unsigned long cumulativeMinorPageFaultNb;       // cumulative min_flt of process and child processes [/proc/#/stat]
  unsigned long cumulativeMajorPageFaultNb;       // cumulative maj_flt of process and child processes [/proc/#/stat]
  unsigned long startCodeAddress;     // address of beginning of code segment [/proc/#/stat]
  unsigned long endCodeAddress;       // address of end of code segment [/proc/#/stat]
  unsigned long startStackAddress;    // address of the bottom of stack for the process [/proc/#/stat]
  unsigned long kernelStackPointerESP;       // kernel stack pointer [/proc/#/stat]
  unsigned long kernelStackPointerEIP;       // kernel stack pointer [/proc/#/stat]
  unsigned long kernelWaitChannelProc;          // address of kernel wait channel proc is sleeping in [/proc/#/stat]
};

+(GSWProcFSProcInfo*)filledProcInfo;
+(GSWProcFSProcInfo*)filledProcInfoWithPID:(pid_t)pid_;
-(id)initFilledWithPID:(pid_t)pid_;
-(void)dealloc;
-(BOOL)fill;
+(NSString*)contentOfProcFile:(NSString*)procFile;
-(NSString*)contentOfPIDFile:(NSString*)pidFile;
-(BOOL)fillStatm;
-(BOOL)fillStat;

@end

#endif // _GSWProcFS_h__
