/* GSWDefaultAdaptor.m - GSWeb: Class GSWDefaultAdaptor
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

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWDefaultAdaptor

-(id)initWithName:(NSString*)name_
		arguments:(NSDictionary*)arguments_
{
  if ((self=[super initWithName:name_
				   arguments:arguments_]))
	{
	  fileHandle=nil;
	  threads=[NSMutableArray new];
	  waitingThreads=[NSMutableArray new];
	  selfLock=[NSLock new];
	  port=[[arguments_ objectForKey:GSWOPT_Port] intValue];
	  NSDebugMLLog(@"info",@"port=%d",port);
	  ASSIGN(host,[arguments_ objectForKey:GSWOPT_Host]);
	  //  [self setInstance:_instance];
	  queueSize=[[arguments_ objectForKey:GSWOPT_ListenQueueSize] intValue];
	  workerThreadCount=[[arguments_ objectForKey:GSWOPT_WorkerThreadCount] intValue];
	  isMultiThreadEnabled=[[arguments_ objectForKey:GSWOPT_MultiThreadEnabled] boolValue];
	};
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWDefaultAdaptor");
  //TODO? DESTROY(listenPortObject);
  GSWLogC("Dealloc GSWDefaultAdaptor: host");
  DESTROY(host);
  GSWLogC("Dealloc GSWDefaultAdaptor: fileHandle");
  DESTROY(fileHandle);
  GSWLogC("Dealloc GSWDefaultAdaptor: threads");
  DESTROY(threads);
  GSWLogC("Dealloc GSWDefaultAdaptor: waitingThreads");
  DESTROY(waitingThreads);
  GSWLogC("Dealloc GSWDefaultAdaptor: selfLock");
  DESTROY(selfLock);
  GSWLogC("Dealloc GSWDefaultAdaptor Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWDefaultAdaptor");
};

//--------------------------------------------------------------------
-(void)registerForEvents
{
  NSAssert(!fileHandle,@"fileHandle already exists");
  NSDebugMLLog(@"info",@"registerForEvents port=%d",port);
  NSDebugMLLog(@"info",@"registerForEvents host=%@",host);
  if (!host)
    {
      ASSIGN(host,[[NSHost currentHost] name]);
    };
  fileHandle=[[NSFileHandle fileHandleAsServerAtAddress:host
			    service:[NSString stringWithFormat:@"%d",port]
			    protocol:@"tcp"] retain];
  NSDebugMLLog(@"info",@"fileHandle=%p\n",(void*)fileHandle);
  [[NSNotificationCenter defaultCenter] addObserver:self
					selector: @selector(announceNewConnection:)
					name: NSFileHandleConnectionAcceptedNotification
					object:fileHandle];
/*  [NotificationDispatcher addObserver:self
    selector: @selector(announceNewConnection:)
    name: NSFileHandleConnectionAcceptedNotification
    object:fileHandle];
*/
  [fileHandle acceptConnectionInBackgroundAndNotify];
  [GSWApplication statusLogWithFormat:@"Waiting for connections."];
};

//--------------------------------------------------------------------
-(void)unregisterForEvents
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
										name: NSFileHandleConnectionAcceptedNotification
										object:fileHandle];
/*  [NotificationDispatcher removeObserver:self
						  name: NSFileHandleConnectionAcceptedNotification
						  object:fileHandle];
*/
  DESTROY(fileHandle);
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)_format,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(void)logWithFormat:(NSString*)_format,...
{
  LOGClassFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)runOnce
{
  //call doesBusyRunOnce
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(BOOL)doesBusyRunOnce
{
  //call _runOnce
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)dispatchesRequestsConcurrently
{
  return YES;
};

//--------------------------------------------------------------------
-(int)port
{
  return port;
};

//--------------------------------------------------------------------
-(NSString*)host
{
  return host;
};


//--------------------------------------------------------------------
-(void)setWorkerThreadCount:(id)workerThreadCount_
{
  if ([self tryLock])
	{
	  NS_DURING
		{
		  workerThreadCount=[workerThreadCount_ intValue];
		  if (workerThreadCount<1)
			workerThreadCount=1;
		}
	  NS_HANDLER
		{
		  LOGException(@"%@ (%@)",
					   localException,
					   [localException reason]);
		}
	  NS_ENDHANDLER;
	  [self unlock];
	}
  else
	{
	  //TODO
	};
};

//--------------------------------------------------------------------
-(id)workerThreadCount
{
  return [NSNumber numberWithInt:workerThreadCount];
};

//--------------------------------------------------------------------
-(BOOL)isMultiThreadEnabled
{
  return isMultiThreadEnabled;
};
//--------------------------------------------------------------------
-(void)setListenQueueSize:(id)listenQueueSize_
{
  if ([self tryLock])
	{
	  NS_DURING
		{
		  queueSize=[listenQueueSize_ intValue];
		  if (queueSize<1)
			queueSize=1;
		}
	  NS_HANDLER
		{
		  LOGException(@"%@ (%@)",
					   localException,
					   [localException reason]);
		}
	  NS_ENDHANDLER;
	  [self unlock];
	}
  else
	{
	  //TODO
	};
};

//--------------------------------------------------------------------
//NDFN
-(id)announceNewConnection:(id)notification
{
  GSWDefaultAdaptorThread* _newThread=nil;
  NSFileHandle* _listenHandle=nil;
  NSFileHandle* inStream = nil;
  NSCalendarDate* requestDate=nil;
  NSString* requestDateString=nil;
  LOGObjectFnStart();
  _listenHandle=[notification object];
  requestDate=[NSCalendarDate calendarDate];
  requestDateString=[NSString stringWithFormat:@"New Request %@",requestDate];
  [GSWApplication statusLogWithFormat:@"%@",requestDateString];
  NSDebugMLLog(@"info",@"_listenHandle=%p",(void*)_listenHandle);
  inStream = [[notification userInfo]objectForKey:@"NSFileHandleNotificationFileHandleItem"];
  NSDebugMLLog(@"info",@"announceNewConnection notification=%@\n",notification);
  NSDebugMLLog(@"info",@"notification userInfo=%@\n",[notification userInfo]);

  if ([waitingThreads count]>=queueSize)
	{
	  DESTROY(_newThread);
	}
  else
	{
	  //release done after lock !
	  _newThread=[[GSWDefaultAdaptorThread alloc] initWithApp:[GSWApplication application]
												  withAdaptor:self
												  withStream:inStream];
	  if (_newThread)
		{
		  NSDebugMLog0(@"_newThread !");
		  if ([self tryLock])
			{
			  NSDebugMLog0(@"locked !");
			  NS_DURING
				{
				  NSDebugMLLog(@"low",
							   @"[waitingThreads count]=%d [threads count]=%d",
							   [waitingThreads count],
							   [threads count]);
				  if ([threads count]<workerThreadCount)
					{
					  [threads addObject:_newThread];
					  if (isMultiThreadEnabled)
						{
						  requestDate=[NSCalendarDate calendarDate];
						  requestDateString=[NSString stringWithFormat:@"Lauch Thread (Multi) %@",requestDate];
						  [GSWApplication statusLogWithFormat:@"%@",requestDateString];
						  NSDebugMLLog(@"info",
									   @"Lauch Thread (Multi) %p",
									   (void*)_newThread);
						  [NSThread detachNewThreadSelector:@selector(run:)
									toTarget:_newThread
									withObject:nil];
						  DESTROY(_newThread);
						}
					  else
						{
						  //Runit after
/*
						  [GSWApplication statusLogWithFormat:@"Lauch Thread (Mono)"];
						  NSDebugMLLog(@"info",
									   @"Lauch Thread (Mono) %p",
									   (void*)_newThread);
						  [_newThread run:nil];
*/
						};
					}
				  else
					{
					  [GSWApplication statusLogWithFormat:@"Set Thread to wait"];
					  NSDebugMLLog(@"info",
								   @"Set Thread to wait %p",
								   (void*)_newThread);
					  [waitingThreads addObject:_newThread];
					  DESTROY(_newThread);
					};
				}
			  NS_HANDLER
				{
				  LOGException(@"%@ (%@)",
							   localException,[localException reason]);
				  //TODO
				  [self unlock];
				  [localException raise];
				}
			  NS_ENDHANDLER;
			  [self unlock];
			}
		  else
			{
			  DESTROY(_newThread);
			};
		};
	  if (!isMultiThreadEnabled && _newThread)
		{
		  requestDate=[NSCalendarDate calendarDate];
		  requestDateString=[NSString stringWithFormat:@"Lauch Thread (Mono) %@",requestDate];
		  [GSWApplication statusLogWithFormat:@"%@",requestDateString];
		  NSDebugMLLog(@"info",
					   @"%@ %p",
					   requestDateString,
					   (void*)_newThread);
		  [_newThread run:nil];
		  DESTROY(_newThread);
		  requestDate=[NSCalendarDate calendarDate];
		  requestDateString=[NSString stringWithFormat:@"Stop Thread (Mono) %@",requestDate];
		  [GSWApplication statusLogWithFormat:@"%@",requestDateString];
		  NSDebugMLLog0(@"info",
						requestDateString);
		};
	  if ([self tryLock])
		{
		  BOOL accept=[waitingThreads count]<queueSize;
		  NS_DURING
			{
			  if (accept)
				[_listenHandle acceptConnectionInBackgroundAndNotify];
			}
		  NS_HANDLER
			{
			  LOGException(@"%@ (%@)",
						   localException,[localException reason]);
			  //TODO
			  blocked=!accept;
			  [self unlock];
			  [localException raise];
			}
		  NS_ENDHANDLER;
		  blocked=!accept;		  
		  [self unlock];
		};
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)adaptorThreadExited:(GSWDefaultAdaptorThread*)adaptorThread_
{
  LOGObjectFnStart();
  if ([self tryLock])
	{
	  NSAutoreleasePool* pool=nil;
#ifndef NDEBUG
	  pool=[NSAutoreleasePool new];
	  NSDebugMLLog(@"low",
				   @"remove thread %p",
				   (void*)adaptorThread_);
	  DESTROY(pool);
#endif
	  NS_DURING
		{
		  [threads removeObject:adaptorThread_];
		}
	  NS_HANDLER
		{
		  pool=[NSAutoreleasePool new];
		  LOGException(@"%@ (%@)",
					   localException,
					   [localException reason]);
		  DESTROY(pool);
		  //TODO
//		  [self unlock];
//		  [localException raise];
		}
	  NS_ENDHANDLER;
#ifndef NDEBUG
	  pool=[NSAutoreleasePool new];
	  NSDebugMLLog(@"low",
				   @"[waitingThreads count]=%d [threads count]=%d",
				   [waitingThreads count],
				   [threads count]);
	  DESTROY(pool);
#endif
	  if ([threads count]==0)
		{
		  BOOL _isApplicationRequestHandlingLocked=[[GSWApplication application] isRequestHandlingLocked];
		  if (_isApplicationRequestHandlingLocked)
			{
			  pool=[NSAutoreleasePool new];
			  LOGSeriousError0(@"Application RequestHandling is LOCKED !!!");
			  [[GSWApplication application] terminate];
			  DESTROY(pool);
			};
		};
	  if ([waitingThreads count]>0 && [threads count]<workerThreadCount)
		{
		  NS_DURING
			{
			  GSWDefaultAdaptorThread* _thread=[waitingThreads objectAtIndex:0];
			  [threads addObject:_thread];
			  [waitingThreads removeObjectAtIndex:0];
#ifndef NDEBUG
			  pool=[NSAutoreleasePool new];
			  [GSWApplication statusLogWithFormat:@"Lauch waiting Thread"];
			  NSDebugMLLog(@"info",
						   @"Lauch waiting Thread %p",
						   (void*)_thread);
			  DESTROY(pool);
#endif
			  if (isMultiThreadEnabled)
				[NSThread detachNewThreadSelector:@selector(run:)
						  toTarget:_thread
						  withObject:nil];
			  else
				[_thread run:nil];
			}
		  NS_HANDLER
			{
			  pool=[NSAutoreleasePool new];
			  LOGException(@"%@ (%@)",
						   localException,
						   [localException reason]);
			  DESTROY(pool);
			  //TODO
//			  [self unlock];
//			  [localException raise];
			}
		  NS_ENDHANDLER;
		};

	  NS_DURING
		{
		  BOOL accept=[waitingThreads count]<queueSize;
		  if (blocked && accept)
			{
			  [fileHandle acceptConnectionInBackgroundAndNotify];
			  blocked=NO;
			};
		}
	  NS_HANDLER
		{
		  pool=[NSAutoreleasePool new];
		  LOGException(@"%@ (%@)",
					   localException,
					   [localException reason]);
		  DESTROY(pool);
		  //TODO
//		  [self unlock];
//		  [localException raise];
		}
	  NS_ENDHANDLER;

	  [self unlock];
	};
  LOGObjectFnStop();
};
//--------------------------------------------------------------------
//NDFN
-(id)announceBrokenConnection:(id)notification
{
  LOGObjectFnNotImplemented();	//TODOFN
//  [self shutDownConnectionWithSocket:[in_port _port_socket]];
  return self;
};

//--------------------------------------------------------------------
//	lock
-(BOOL)tryLock
{
  BOOL _locked=NO;
  LOGObjectFnStart();
  _locked=[selfLock tmptryLockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:90]];
  LOGObjectFnStop();
  return _locked;
};

//--------------------------------------------------------------------
//	unlock
-(void)unlock
{
  LOGObjectFnStart();
  [selfLock tmpunlock];
  LOGObjectFnStop();
};

@end


//====================================================================
@implementation GSWDefaultAdaptor (GSWDefaultAdaptorA)
-(void)stop
{
  LOGObjectFnNotImplemented();	//TODOFN
};

-(void)run
{
  LOGObjectFnNotImplemented();	//TODOFN
};

-(void)_runOnce
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

