/** GSWDeployedBundle.h -  <title>GSWeb: Class GSWDeployedBundle</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 1999
   
   $Revision$
   $Date$
   
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

// $Id$

#ifndef _GSWDeployedBundle_h__
	#define _GSWDeployedBundle_h__


//====================================================================
@interface GSWDeployedBundle : NSObject
{
  NSString* _bundlePath;
  NSString* _wrapperName;
  NSString* _projectName;
  BOOL _isFramework;
  GSWMultiKeyDictionary* _relativePathsCache;
  NSMutableDictionary* _absolutePathsCache;
  NSMutableDictionary* _urlsCache;
  NSRecursiveLock* _selfLock;
#ifndef NDEBUG
  int _selfLockn;
  NSThread *_selfLock_thread_id;
  NSThread *_creation_thread_id;
#endif
};

-(id)initWithPath:(NSString*)aPath;
-(GSWProjectBundle*)projectBundle;
-(BOOL)isFramework;
-(NSString*)wrapperName;
-(NSString*)projectName;
-(NSString*)bundlePath;
-(NSString*)bundleURLPrefix;
-(NSArray*)pathsForResourcesOfType:(NSString*)aType;
-(NSArray*)lockedPathsForResourcesOfType:(NSString*)aType;
-(NSString*)relativePathForResourceNamed:(NSString*)aName
                                language:(NSString*)aLanguage;
-(NSString*)relativePathForResourceNamed:(NSString*)aName
                               languages:(NSArray*)someLanguages;
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                      language:(NSString*)aLanguage;
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                     languages:(NSArray*)someLanguages;
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                   inDirectory:(NSString*)aDirectory
                                     languages:(NSArray*)someLanguages;
-(NSString*)lockedCachedRelativePathForResourceNamed:(NSString*)aName
                                         inDirectory:(NSString*)aDirectory
                                            language:(NSString*)aLanguage;
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                   inDirectory:(NSString*)aDirectory
                                      language:(NSString*)aLanguage;

/** Returns url for resource named aName for languages someLanguages **/
-(NSString*)urlForResourceNamed:(NSString*)aName
                      languages:(NSArray*)someLanguages;

/** Returns the url (cached or not) for relativePath. Put it in the cache 
if it was not cached **/
-(NSString*)lockedCachedURLForRelativePath:(NSString*)relativePath;

/** Returns the absolute path (cached or not) for relativePath. Put it in the cache 
if it was not cached **/
-(NSString*)lockedCachedAbsolutePathForRelativePath:(NSString*)relativePath;

-(NSString*)absolutePathForRelativePath:(NSString*)relativePath;

-(NSString*)absolutePathForResourceNamed:(NSString*)aName
                               languages:(NSArray*)someLanguages;

-(void)lock;
-(void)unlock;

@end

@interface GSWDeployedBundle (GSWDeployedBundleA)
+(id)bundleWithPath:(NSString*)aPath;
@end

#endif //_GSWDeployedBundle_h__
