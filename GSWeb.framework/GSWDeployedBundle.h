/* GSWDeployedBundle.h - GSWeb: Class GSWDeployedBundle
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Mar 1999
   
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

#ifndef _GSWDeployedBundle_h__
	#define _GSWDeployedBundle_h__


//====================================================================
@interface GSWDeployedBundle : NSObject
{
  NSString* bundlePath;
  GSWMultiKeyDictionary* relativePathsCache;
  NSRecursiveLock* selfLock;
#ifndef NDEBUG
  int selfLockn;
  objc_thread_t selfLock_thread_id;
  objc_thread_t creation_thread_id;
#endif
};

-(void)dealloc;
-(NSString*)description;
-(id)initWithPath:(NSString*)path_;
-(GSWProjectBundle*)projectBundle;
-(BOOL)isFramework;
-(NSString*)wrapperName;
-(NSString*)projectName;
-(NSString*)bundlePath;
-(NSArray*)pathsForResourcesOfType:(NSString*)type_;
-(NSArray*)lockedPathsForResourcesOfType:(NSString*)type_;
-(NSString*)relativePathForResourceNamed:(NSString*)name_
							 forLanguage:(NSString*)language_;
-(NSString*)relativePathForResourceNamed:(NSString*)name_
							forLanguages:(NSArray*)languages_;
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)name_
								   forLanguage:(NSString*)language_;
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)name_
								  forLanguages:(NSArray*)languages_;
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)name_
								   inDirectory:(NSString*)directory_
								  forLanguages:(NSArray*)languages_;
-(NSString*)lockedCachedRelativePathForResourceNamed:(NSString*)name_
										 inDirectory:(NSString*)directory_
										 forLanguage:(NSString*)language_;
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)name_
								   inDirectory:(NSString*)directory_
								   forLanguage:(NSString*)language_;
-(void)lock;
-(void)unlock;

@end

@interface GSWDeployedBundle (GSWDeployedBundleA)
+(GSWDeployedBundle*)bundleWithPath:(NSString*)path_;
@end

#endif //_GSWDeployedBundle_h__
