/** GSWLifebeatThread.m - <title>GSWeb: Class GSWLifebeatThread</title>

   Copyright (C) 2003 Free Software Foundation, Inc.
   
   Written by:  Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jul 2003

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

#ifndef _GSWLifebeatThread_h__
	#define _GSWLifebeatThread_h__


//==============================================================================
@interface GSWLifebeatThread: NSObject
{
  NSAutoreleasePool* _pool;
  NSDate* _creationDate;
  GSWApplication* _application;
  NSString* _applicationName;
  int _applicationPort;
  NSString* _applicationHost;
  NSString* _lifebeatHost;
  int _lifebeatPort;
  NSTimeInterval _interval;
  NSString* _baseURL;
  NSDictionary* _messages;
  int _requestNamingConv;//GSWNAMES_INDEX or WONAMES_INDEX
}

+(GSWLifebeatThread*)lifebeatThreadWithApplication:(GSWApplication*)application
                                              name:(NSString*)name
                                              host:(NSString*)host
                                              port:(int)port
                                      lifebeatHost:(NSString*)lifebeatHost
                                      lifebeatPort:(int)lifebeatPort
                                          interval:(NSTimeInterval)interval;
-(id)initWithApplication:(GSWApplication*)application
                    name:(NSString*)name
                    host:(NSString*)host
                    port:(int)port
            lifebeatHost:(NSString*)lifebeatHost
            lifebeatPort:(int)lifebeatPort
                interval:(NSTimeInterval)interval;
  

-(void)run:(id)nothing;

-(NSAutoreleasePool*)pool;
-(void)setPool:(NSAutoreleasePool*)pool
   destroyLast:(BOOL)destroy;

-(void)threadExited;
+(id)threadExited:(NSNotification*)notif;

@end

#endif
