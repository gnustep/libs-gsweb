/** GSWLifebeatThread.m - <title>GSWeb: Class GSWLifebeatThread</title>

   Copyright (C) 2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        Jul 2003

   $Revision$
   $Date$
   $Id$
   
   <abstract></abstract>

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

#include <unistd.h>
#include "GSWeb.h"
#include "GSWLifebeatThread.h"
#include <GNUstepBase/GSCategories.h>

//====================================================================
@implementation GSWLifebeatThread

+(GSWLifebeatThread*)lifebeatThreadWithApplication:(GSWApplication*)application
                                              name:(NSString*)name
                                              host:(NSString*)host
                                              port:(int)port
                                      lifebeatHost:(NSString*)lifebeatHost
                                      lifebeatPort:(int)lifebeatPort
                                          interval:(NSTimeInterval)interval
{
  return [[[self alloc]initWithApplication:application
                       name:name
                       host:host
                       port:port
                       lifebeatHost:lifebeatHost
                       lifebeatPort:lifebeatPort
                       interval:interval]autorelease];
};

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
    {
      ASSIGN(_creationDate,[NSDate date]);
      _requestNamingConv=GSWebNamingConv;//GSWNAMES_INDEX or WONAMES_INDEX
    };
  return self;
};

//--------------------------------------------------------------------
-(id)initWithApplication:(GSWApplication*)application
                    name:(NSString*)name
                    host:(NSString*)host
                    port:(int)port
            lifebeatHost:(NSString*)lifebeatHost
            lifebeatPort:(int)lifebeatPort
                interval:(NSTimeInterval)interval
{
  if ((self=[self init]))
    {
      _application=application; //don't retain
      ASSIGN(_applicationName,name);
      ASSIGN(_applicationHost,host);
      _applicationPort=port;
      ASSIGN(_lifebeatHost,lifebeatHost);
      _lifebeatPort=lifebeatPort;
      _interval=interval;

      ASSIGN(_baseURL,([NSString stringWithFormat:@"http://%@:%d/GSWeb/gswtaskd.gswa/lb/applicationName=%@&applicationHost=%@&applicationPort=%d&",
                                _lifebeatHost,
                                lifebeatPort,
                                _applicationName,
                                _applicationHost,
                                _applicationPort]));
      ASSIGN(_messages,([NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%@message=hasStarted",_baseURL],
                                     @"hasStarted",

                                       [NSString stringWithFormat:@"%@message=lifebeat",_baseURL],
                                     @"lifebeat",

                                       [NSString stringWithFormat:@"%@message=willStop",_baseURL],
                                     @"willStop",

                                       [NSString stringWithFormat:@"%@message=willCrash",_baseURL],
                                     @"willCrash",

                                     nil]));
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogMemC("dealloc GSWLifebeatThread");
  DESTROY(_creationDate);
  DESTROY(_applicationName);
  DESTROY(_applicationHost);
  DESTROY(_lifebeatHost);
  DESTROY(_baseURL);
  DESTROY(_messages);
  GSWLogMemC("release pool");
//  DESTROY(_pool);
  GSWLogMemC("super dealloc");
  [super dealloc];
  GSWLogMemC("dealloc GSWLifebeatThread end");
};

//--------------------------------------------------------------------
-(NSAutoreleasePool*)pool
{
  return _pool;
};

//--------------------------------------------------------------------
-(void)setPool:(NSAutoreleasePool*)pool
   destroyLast:(BOOL)destroy
{
  if (destroy)
    {
      GSWLogMemC("dealloc pool");
      GSWLogMemCF("Destroy NSAutoreleasePool: %p. %@",
		  _pool, GSCurrentThread());
      DESTROY(_pool);
      GSWLogMemC("end dealloc pool");
    };
  _pool=pool;
};

//--------------------------------------------------------------------
-(void)sendMessage:(NSString*)message
{
  NSURL* url=[NSURL URLWithString:message];
  NSData* data=[url resourceDataUsingCache:NO];
  NSDebugMLog(@"MESSAGE data=%@",data);//TODO handle it !
};

//--------------------------------------------------------------------
-(void)run:(id)nothing
{
  _pool=[NSAutoreleasePool new];

  [self sendMessage:[_messages objectForKey:@"hasStarted"]];
  NSTimeIntervalSleep(_interval);
  while(YES)
    {
      //TODO

//        [self sendMessage:[_messages objectForKey:@"lifebeat"]];
      NSTimeIntervalSleep(_interval);
    };
  

/*
  LOGObjectFnStop();
#ifdef DEBUG
  [GSWApplication statusLogWithFormat:@"threadWillExit START"];
#endif
  [_application threadWillExit];
#ifdef DEBUG
  [GSWApplication statusLogWithFormat:@"threadWillExit STOP"];
#endif
  if (_isMultiThread)
    {
      NSAssert([NSThread isMultiThreaded],@"No MultiThread !");
      [NSThread exit]; //???
    }
  else
    [self threadExited];
#ifdef DEBUG
  [GSWApplication statusLogWithFormat:@"run STOP"];
#endif
*/
};

//--------------------------------------------------------------------
-(void)threadExited
{
//  LOGObjectFnStart();
//  NSDebugMLLog0(@"trace",@"GSWLifebeatThread: threadExited method");
//  NSDebugMLLog(@"low",@"[_defaultAdaptorThread retainCount=%d",
//			   (int)[self retainCount]);
  GSWLogMemCF("Will Destroy NSAutoreleasePool: %p",_pool);
  [self setPool:nil
        destroyLast:YES];
//  LOGObjectFnStop();
  GSWLogDeepC("threadExited");
};
/*
//TODO
//--------------------------------------------------------------------
+(id)threadExited:(NSNotification*)notif
{
  NSThread* thread=nil;
  NSMutableDictionary* threadDict=nil;
  GSWLifebeatThread* adaptorThread=nil;
  GSWLogDeepC("Start threadExited:");
  NSAssert([NSThread isMultiThreaded],@"No MultiThread !");
  NSDebugMLLog(@"low",@"notif=%@",notif);
  thread=[notif object];
  NSDebugMLLog(@"low",@"thread=%@",thread);
  threadDict = [thread threadDictionary];
  NSDebugMLLog(@"low",@"threadDict=%@",threadDict);
  adaptorThread=[threadDict objectForKey:GSWThreadKey_LifebeatThread];
  NSDebugMLLog(@"low",@"adaptorThread=%@",adaptorThread);
  [threadDict removeObjectForKey:GSWThreadKey_LifebeatThread];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                        name:NSThreadExiting//NSThreadWillExitNotification
                                        object:thread];
  [adaptorThread threadExited];
  GSWLogDeepC("Stop threadExited:");
  GSWLogDeepC("threadExited really exit");
  return nil; //??
};
*/

@end
