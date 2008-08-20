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

typedef enum _GSWProcState
{
  GSWProcState__Unknown =0,
  GSWProcState__Sleeping,
  GSWProcState__Running,
  GSWProcState__Zombie,
  GSWProcState__Stopped,
  GSWProcState__SleepWait

} GSWProcState;
@interface GSWProcFSProcInfo : NSObject //<NSCoding,NSCopying>
{
  NSString* _user;		// user name corresponding to owner of process [/proc/#/stat]
  NSString* _command;		// basename of executable file in call to exec(2) [/proc/#/stat]
  GSWProcState _state;	// single-char code for process state (S=sleeping) [/proc/#/stat]
  NSString* _ttyc;		// string representation of controlling tty device [/proc/#/stat]
  NSArray* _environ;		// environment string vector (/proc/#/environ) 
  NSArray* _commandLine;		// command line string vector (/proc/#/cmdline) 
  int _uid;            // user id 
  int _pid;            // process id [/proc/#/stat]
  int _ppid;           // pid of parent process [/proc/#/stat]
  int _pgrp;           // process group id [/proc/#/stat]
  int _session;        // session id [/proc/#/stat]
  int _tty;            // full device number of controlling terminal [/proc/#/stat]
  int _tpgid;          // terminal process group id [/proc/#/stat]
  int _priority;       // kernel scheduling priority [/proc/#/stat]
  int _nice;           // standard unix nice level of process [/proc/#/stat]
  long long _signal;         // mask of pending signals [/proc/#/stat]
  long long _blocked;        // mask of blocked signals [/proc/#/stat]
  long long _sigIgnore;      // mask of ignored signals [/proc/#/stat]
  long long _sigCatch;       // mask of caught  signals [/proc/#/stat]
  NSTimeInterval _startTime;     // start time of process (Absolute)[/proc/#/stat]
  NSTimeInterval _userTime; // user-mode CPU time accumulated by process [/proc/#/stat]
  NSTimeInterval _systemTime;          // kernel-mode CPU time accumulated by process [/proc/#/stat]
  NSTimeInterval _cumulativeUserTime;         // cumulative utime of process and reaped children [/proc/#/stat]
  NSTimeInterval _cumulativeSystemTime;         // cumulative stime of process and reaped children [/proc/#/stat]
  long _pagesNb;           // total # of pages of memory [/proc/#/statm]
  long _residentPagesNb;       // number of resident set (non-swapped) pages (4k) [/proc/#/statm]
  long _sharedPagesNb;          // number of pages of shared (mmap'd) memory [/proc/#/statm]
  long _textResidentSize;            // text resident set size [/proc/#/statm]
  long _sharedLibResidentSize;            // shared-lib resident set size [/proc/#/statm]
  long _dataResidentSize;            // data resident set size [/proc/#/statm]
  long _dirtyPagesNb;             // dirty pages [/proc/#/statm]
  unsigned _cpuUsagePC; // %CPU usage (is not filled in by readproc!!!)   
  unsigned long _virtualMemorySize;          // Virtual memory size in bytes ... [/proc/#/stat]
  unsigned long _residentMemorySize;            // resident set size from /proc/#/stat 
  unsigned long _residentMemorySizeLimit;       // resident set size ... ?
  unsigned long _timeout;        // ? [/proc/#/stat]
  unsigned long _it_real_value;  // ? [/proc/#/stat]
  unsigned long _flags;          // kernel flags for the process [/proc/#/stat]
  unsigned long _minorPageFaultNb;        // number of minor page faults since process start [/proc/#/stat]
  unsigned long _majorPageFaultNb;        // number of major page faults since process start [/proc/#/stat]
  unsigned long _cumulativeMinorPageFaultNb;       // cumulative min_flt of process and child processes [/proc/#/stat]
  unsigned long _cumulativeMajorPageFaultNb;       // cumulative maj_flt of process and child processes [/proc/#/stat]
  unsigned long _startCodeAddress;     // address of beginning of code segment [/proc/#/stat]
  unsigned long _endCodeAddress;       // address of end of code segment [/proc/#/stat]
  unsigned long _startStackAddress;    // address of the bottom of stack for the process [/proc/#/stat]
  unsigned long _kernelStackPointerESP;       // kernel stack pointer [/proc/#/stat]
  unsigned long _kernelStackPointerEIP;       // kernel stack pointer [/proc/#/stat]
  unsigned long _kernelWaitChannelProc;          // address of kernel wait channel proc is sleeping in [/proc/#/stat]
};

+(GSWProcFSProcInfo*)filledProcInfo;
+(GSWProcFSProcInfo*)filledProcInfoWithPID: (int)processID;
-(id)initFilledWithPID: (int)processID;
-(void)dealloc;
-(BOOL)fill;
+(NSString*)contentOfProcFile:(NSString*)procFile;
-(NSString*)contentOfPIDFile:(NSString*)pidFile;
-(BOOL)fillStatm;
-(BOOL)fillStat;
-(unsigned int)residentMemory;
-(unsigned int)sharedMemory;
-(unsigned int)virtualMemory;
-(unsigned int)swapMemory;
-(unsigned int)usedMemory;
-(NSString*)formattedResidentMemory;
-(NSString*)formattedSharedMemory;
-(NSString*)formattedVirtualMemory;
-(NSString*)formattedSwapMemory;
-(NSString*)formattedUsedMemory;

@end

#endif // _GSWProcFS_h__
