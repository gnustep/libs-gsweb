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

static char rcsId[] = "$Id$";

#include "GSWeb.h"
#include <unistd.h>
#include <sys/time.h>

@implementation GSWProcFSProcInfo

+(GSWProcFSProcInfo*)filledProcInfo
{
  return [self filledProcInfoWithPID:getpid()];
};

+(GSWProcFSProcInfo*)filledProcInfoWithPID:(pid_t)pid_
{
  GSWProcFSProcInfo* obj=[[[self alloc] initFilledWithPID:pid_]autorelease];
  return obj;
};

-(id)initFilledWithPID:(pid_t)pid_
{
  if ((self=[super init]))
	{
	  pid=pid_;
	  [self fill];
	};
  return self;
};

-(void)dealloc
{
  DESTROY(user);
  DESTROY(cmd);
  DESTROY(ttyc);
  DESTROY(environ);
  DESTROY(cmdline);
  [super dealloc];
};

-(NSString*)description
{
  NSString* dscr=nil;
  size_t _pageSize=getpagesize();
  char* _state=NULL;
  switch(state)
	{
	case GSWProcState__Sleeping:
	  _state="Sleeping";
	  break;
	case GSWProcState__Running:
	  _state="Running";
	  break;
	case GSWProcState__Zombie:
	  _state="Zombie";
	  break;
	case GSWProcState__Stopped:
	  _state="Stopped";
	  break;
	case GSWProcState__SleepWait:
	  _state="Waiting-Sleeping";
	  break;
	case GSWProcState__Unknown:
	default:
	  _state="Unknown";
	  break;
	};
  dscr=[NSString stringWithFormat:@"user: %@\ncmd: %@\nState: %s\nttyc: %@\nenviron: %@\ncommand line:%@\n",
				 user,
				 cmd,
				 _state,
				 ttyc,
				 environ,
				 cmdline];
  dscr=[dscr stringByAppendingFormat:@"uid: %d\npid: %d\nppid: %d\npgrp: %d\nsession: %d\ntty: %d\ntpgid: %d\npriority: %d\nnice: %d\nsignal: %LX\nblocked: %LX\nsigIgnore: %LX\nsigCache: %LX\n",
			 (int)uid,
			 (int)pid,
			 (int)ppid,
			 (int)pgrp,
			 session,
			 tty,
			 (int)tpgid,
			 priority,
			 nice,
			 signal,
			 blocked,
			 sigIgnore,
			 sigCatch];
  dscr=[dscr stringByAppendingFormat:@"startTime: %@\nuserTime: %f\nsystemTime: %f\ncumulativeUserTime: %f\ncumulativeSystemTime: %f\n",
			 [NSDate dateWithTimeIntervalSinceReferenceDate:startTime],
			 userTime,
			 systemTime,
			 cumulativeUserTime,
			 cumulativeSystemTime];
  dscr=[dscr stringByAppendingFormat:@"pagesNb=%ld (size: %ld)\nresidentPagesNb: %ld (size: %ld)\nsharedPagesNb: %ld (size: %ld)\ntextResidentSize: %ld\nsharedLibResidentSize: %ld\ndataResidentSize: %ld\ndirtyPagesNb: %ld\n",
			 pagesNb,
			 (long)(pagesNb*_pageSize),
			 residentPagesNb,
			 (long)(residentPagesNb*_pageSize),
			 sharedPagesNb,
			 (long)(sharedPagesNb*_pageSize),
			 textResidentSize,
			 sharedLibResidentSize,
			 dataResidentSize,
			 dirtyPagesNb];
  dscr=[dscr stringByAppendingFormat:@"cpuUsage: %u%%\nvirtualPagesNb: %lu (size: %lu)\nresidentMemorySize: %lu\nresidentMemorySizeLimit: %lu\ntimeout: %lu\nit_real_value: %lu\n",
			 cpuUsagePC,
			 virtualPagesNb,
			 (long)(virtualPagesNb*_pageSize),
			 residentMemorySize,
			 residentMemorySizeLimit,
			 timeout,
			 it_real_value];
/*  unsigned long flags,
  unsigned long minorPageFaultNb,
  unsigned long majorPageFaultNb,
  unsigned long cumulativeMinorPageFaultNb,
  unsigned long cumulativeMajorPageFaultNb,
  unsigned long startCodeAddress,
  unsigned long endCodeAddress,
  unsigned long startStackAddress,
  unsigned long kernelStackPointerESP,
  unsigned long kernelStackPointerEIP,
  unsigned long kernelWaitChannelProc,
*/
  return dscr;
};
-(BOOL)fill
{
  //TODO
  [self fillStat];
  [self fillStatm];
  return YES;
};

+(NSString*)contentOfProcFile:(NSString*)procFile
{
  NSString* _content=nil;
  char          thePath[BUFSIZ*2];
  FILE          *theFile = 0;
  NSString* _path=[NSString stringWithFormat:@"/proc/%@",procFile];
  if ([_path getFileSystemRepresentation:thePath
                              maxLength:sizeof(thePath)-1] == NO)
    {
	  LOGSeriousError(@"Open (%@) attempt failed - bad path",
					  _path);
    }
  else
	{
	  theFile = fopen(thePath, "r");
	  if (theFile == NULL)          // We failed to open the file.
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

-(NSString*)contentOfPIDFile:(NSString*)pidFile
{
  NSString* _content=nil;
  NSString* _path=[NSString stringWithFormat:@"%d/%@",(int)(pid ? pid : getpid()),pidFile];
  _content=[[self class] contentOfProcFile:_path];
  return _content;
};

-(BOOL)fillStatm
{
  BOOL ok=NO;
  NSString* pidstat=[self contentOfPIDFile:@"statm"];
  NSDebugFLog(@"pidstat=%@",pidstat);
  if (pidstat)
	{
	  char* _statsChars=[pidstat cString];
	  NSDebugFLog(@"pidstat=%@",pidstat);
	  if (sscanf(_statsChars, "%ld %ld %ld %ld %ld %ld %ld",
				 &pagesNb,//size
				 &residentPagesNb,//resident
				 &sharedPagesNb,//share
				 &textResidentSize, //trs
				 &sharedLibResidentSize,//lrs
				 &dataResidentSize,//drs
				 &dirtyPagesNb//dt
				 )==7)
		ok=YES;
	};
  return ok;
};

-(BOOL)fillStat
{
  BOOL ok=NO;
  NSString* pidstat=[self contentOfPIDFile:@"stat"];
  NSDebugFLog(@"pidstat=%@",pidstat);
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
			  char* _statsChars=[_stats cString];
			  char cState;
			  long _utime;
			  long _stime;
			  long _cutime;
			  long _cstime;
			  long _startTime;

			  NSDebugFLog(@"_stats=%@",_stats);
			  if (sscanf(_statsChars,
						 "%c %d %d %d %d %d %lu %lu %lu %lu %lu %ld %ld %ld %ld %d "
						 "%d %lu %lu %ld %lu %lu %lu %lu %lu %lu %lu %lu %LX %LX %LX %LX %lu",
						 &cState, //state
						 &ppid,//ppid
						 &pgrp,//pgrp
						 &session,//session
						 &tty,//tty
						 &tpgid,//tpgid,
						 &flags,//flags
						 &minorPageFaultNb,//min_flt
						 &cumulativeMinorPageFaultNb,//cmin_flt
						 &majorPageFaultNb,//maj_flt
						 &cumulativeMajorPageFaultNb,//cmaj_flt,
						 &_utime,//utime
						 &_stime,//stime
						 &_cutime,//cutime
						 &_cstime,//cstime
						 &priority,//priority
						 &nice,//nice,
						 &timeout,//timeout
						 &it_real_value,//it_real_value
						 &_startTime,//start_time
						 &virtualPagesNb,//vsize
						 &residentMemorySize,//rss,
						 &residentMemorySizeLimit,//rss_rlim
						 &startCodeAddress,//start_code
						 &endCodeAddress,//end_code
						 &startStackAddress,//start_stack,
						 &kernelStackPointerESP,//kstk_esp
						 &kernelStackPointerEIP,//kstk_eip
						 &signal,//signal
						 &blocked,//blocked
						 &sigIgnore,//sigignore,
						 &sigCatch,//sigcatch
						 &kernelWaitChannelProc//wchan
						 )==33)
				{
				  ok=YES;
				  switch(cState)
					{
					case 'S':
					  state=GSWProcState__Sleeping;
					  break;
					case 'R':
					  state=GSWProcState__Running;
					  break;
					case 'Z':
					  state=GSWProcState__Zombie;
					  break;
					case 'T':
					  state=GSWProcState__Stopped;
					  break;
					case 'D':
					  state=GSWProcState__SleepWait;
					  break;
					default:
					  state=GSWProcState__Unknown;
					  break;
					};
				  userTime=_utime;
				  systemTime=_stime;
				  cumulativeUserTime=_cutime;
				  cumulativeSystemTime=_cstime;
				  startTime=[[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)_startTime]timeIntervalSinceReferenceDate];
				  
				  if (tty == 0)
					tty = -1;  // the old notty val, update elsewhere bef. moving to 0 
				  /*			  if (linux_version_code < LINUX_VERSION(1,3,39))
								  {
								  P->priority = 2*15 - P->priority;       // map old meanings to new 
								  P->nice = 15 - P->nice;
								  }
								  if (linux_version_code < LINUX_VERSION(1,1,30) && P->tty != -1)
								  P->tty = 4*0x100 + P->tty;              // when tty wasn't full devno 
				  */
				  NSDebugFLog(@"residentMemorySize=%lu",residentMemorySize);
				};
			};
		};
	};
  return ok;
};

@end
