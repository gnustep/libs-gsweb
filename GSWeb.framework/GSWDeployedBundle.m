/** GSWDeployedBundle.m - <title>GSWeb: Class GSWDeployedBundle</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

//====================================================================
@implementation GSWDeployedBundle

//--------------------------------------------------------------------
-(id)initWithPath:(NSString*)aPath
{
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      NSDebugMLLog(@"bundles",@"aPath=%@",aPath);
      ASSIGN(_bundlePath,[aPath stringGoodPath]);
      NSDebugMLLog(@"bundles",@"_bundlePath=%@",_bundlePath);
      _relativePathsCache=[GSWMultiKeyDictionary new];
#ifndef NDEBUG
      _creation_thread_id=objc_thread_id();
#endif
      _selfLock=[NSRecursiveLock new];
/*
  NSDebugMLog(@"selfLock->mutex=%p",(void*)selfLock->mutex);
  NSDebugMLog(@"selfLock->mutex backend=%p",(void*)((pthread_mutex_t*)(selfLock->mutex->backend)));
  NSDebugMLog(@"selfLock->mutex backend m_owner=%p",
  (void*)(((pthread_mutex_t*)(selfLock->mutex->backend))->m_owner));
  NSDebugMLog(@"selfLock->mutex backend m_count=%p",(void*)(((pthread_mutex_t*)(selfLock->mutex->backend))->m_count));
  NSDebugMLog(@"selfLock->mutex backend m_kind=%p",(void*)(((pthread_mutex_t*)(selfLock->mutex->backend))->m_kind));
  NSDebugMLog(@"selfLock->mutex backend m_spinlock=%p",(void*)(((pthread_mutex_t*)(selfLock->mutex->backend))->m_spinlock));
*/
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  NSDebugFLog(@"Dealloc GSWDeployedBundle %p",(void*)self);
  DESTROY(_bundlePath);
  DESTROY(_relativePathsCache);
  GSWLogC("Dealloc GSWDeployedBundle: selfLock");
  NSDebugFLog(@"selfLock=%p selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p creation_thread_id=%p",
              (void*)_selfLock,
              _selfLockn,
              (void*)_selfLock_thread_id,
              (void*)objc_thread_id(),
              (void*)_creation_thread_id);
  fflush(stderr);
  DESTROY(_selfLock);
  GSWLogC("Dealloc GSWDeployedBundle Super");
  [super dealloc];
  NSDebugFLog(@"End Dealloc GSWDeployedBundle %p",(void*)self);
};

//--------------------------------------------------------------------
-(NSString*)description
{
  NSString* descr=nil;
//  GSWLogC("GSWDeployedBundle description A");
  descr=[NSString stringWithFormat:@"<%s %p - ",
                  object_get_class_name(self),
                  (void*)self];
//  GSWLogC("GSWDeployedBundle description B");
  descr=[descr stringByAppendingFormat:@"bundlePath:%@ ",
               _bundlePath];
//  GSWLogC("GSWDeployedBundle description C");
  descr=[descr stringByAppendingFormat:@"relativePathsCache=%p>",
               (void*)_relativePathsCache];
//  GSWLogC("GSWDeployedBundle description D");
  return descr;
};

//--------------------------------------------------------------------
-(GSWProjectBundle*)projectBundle
{
  //OK
  NSString* projectName=nil;
  BOOL isFramework=NO;
  GSWDeployedBundle* projectBundle=nil;
  LOGObjectFnStart();
  projectName=[self projectName];
  NSDebugMLLog(@"bundles",@"projectName=%@",projectName);
  isFramework=[self isFramework];
  NSDebugMLLog(@"bundles",@"isFramework=%s",(isFramework ? "YES" : "NO"));
  projectBundle=[GSWProjectBundle projectBundleForProjectNamed:projectName
                                  isFramework:isFramework];
  NSDebugMLLog(@"bundles",@"projectBundle=%@",projectBundle);
  LOGObjectFnStop();
  return (GSWProjectBundle*)projectBundle;
};

//--------------------------------------------------------------------
-(BOOL)isFramework
{
  //OK ??
  return [_bundlePath hasSuffix:GSFrameworkSuffix];
};

//--------------------------------------------------------------------
-(NSString*)wrapperName
{
  //OK ?
  NSString* projectName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"_bundlePath=%@",_bundlePath);
  projectName=[_bundlePath lastPathComponent];
  NSDebugMLLog(@"bundles",@"projectName=%@",projectName);
  projectName=[projectName stringByDeletingPathExtension];
  NSDebugMLLog(@"bundles",@"projectName=%@",projectName);
  LOGObjectFnStop();
  return projectName;
};

//--------------------------------------------------------------------
-(NSString*)projectName
{
  // H:\Wotests\ObjCTest3\ObjCTest3.gswa ==> ObjCTest3
  //OK ?
  NSString* projectName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"_gnustep_target_cpu=%@",[NSBundle _gnustep_target_cpu]);
  NSDebugMLLog(@"bundles",@"_gnustep_target_dir=%@",[NSBundle _gnustep_target_dir]);
  NSDebugMLLog(@"bundles",@"_gnustep_target_os=%@",[NSBundle _gnustep_target_os]);
  NSDebugMLLog(@"bundles",@"_library_combo=%@",[NSBundle _library_combo]);
  NSDebugMLLog(@"bundles",@"_bundlePath=%@",_bundlePath);
  projectName=[_bundlePath lastPathComponent];
  NSDebugMLLog(@"bundles",@"projectName=%@",projectName);
  projectName=[projectName stringByDeletingPathExtension];
  NSDebugMLLog(@"bundles",@"projectName=%@",projectName);
  LOGObjectFnStop();
  return projectName;
};

//--------------------------------------------------------------------
-(NSString*)bundlePath
{
  return _bundlePath;
};

//--------------------------------------------------------------------
-(NSArray*)pathsForResourcesOfType:(NSString*)aType
{
  //OK
  NSArray* paths=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aType=%@",aType);
  [self lock];
  NS_DURING
    {
      paths=[self lockedPathsForResourcesOfType:aType];
      NSDebugMLLog(@"bundles",@"paths=%@",paths);
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@)",
                   localException,[localException reason]);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  return paths;
};

//--------------------------------------------------------------------
-(NSArray*)lockedPathsForResourcesOfType:(NSString*)aType
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)relativePathForResourceNamed:(NSString*)aName
                             forLanguage:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;
  LOGObjectFnStart();
  [self lock];
  NSDebugMLLog(@"bundles",@"aName=%@ aLanguage=%@",aName,aLanguage);
  NS_DURING
    {
      path=[self lockedRelativePathForResourceNamed:aName
                 forLanguage:aLanguage];
      NSDebugMLLog(@"bundles",@"path=%@",path);
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@)",
                   localException,[localException reason]);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  return path;
};

//--------------------------------------------------------------------
-(NSString*)relativePathForResourceNamed:(NSString*)aName
                            forLanguages:(NSArray*)someLanguages
{
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@ someLanguages=%@",aName,someLanguages);
  [self lock];
  NS_DURING
    {
      path=[self lockedRelativePathForResourceNamed:aName
                 forLanguages:someLanguages];
      //NSDebugMLLog(@"bundles",@"path=%@",path);
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@)",
                   localException,[localException reason]);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                   forLanguage:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@ aLanguage=%@",aName,aLanguage);
  NSDebugMLLog(@"bundles",@"bundlePath=%@ Trying Resources/WebServer",_bundlePath);
  path=[self lockedRelativePathForResourceNamed:aName
             inDirectory:@"Resources/WebServer"
             forLanguage:aLanguage];
  NSDebugMLLog(@"bundles",@"path=%@",path);
  if (!path)
    {
      NSDebugMLLog(@"bundles",@"bundlePath=%@ Trying Resources",_bundlePath);
      path=[self lockedRelativePathForResourceNamed:aName
                 inDirectory:@"Resources"
                 forLanguage:aLanguage];
      NSDebugMLLog(@"bundles",@"path=%@",path);
      if (!path)
        {
          NSDebugMLLog(@"bundles",@"bundlePath=%@ Trying .",_bundlePath);
          path=[self lockedRelativePathForResourceNamed:aName
                     inDirectory:@"."
                     forLanguage:aLanguage];
          NSDebugMLLog(@"bundles",@"path=%@",path);
        };
    };
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                  forLanguages:(NSArray*)someLanguages
{
  //OK
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@ someLanguages=%@",aName,someLanguages);
  NSDebugMLLog(@"bundles",@"bundlePath=%@ Trying Resources/WebServer",_bundlePath);
  path=[self lockedRelativePathForResourceNamed:aName
             inDirectory:@"Resources/WebServer"
             forLanguages:someLanguages];
  NSDebugMLLog(@"bundles",@"path=%@",path);
  if (!path)
    {
      NSDebugMLLog(@"bundles",@"bundlePath=%@ Trying Resources",_bundlePath);
      path=[self lockedRelativePathForResourceNamed:aName
                 inDirectory:@"Resources"
                 forLanguages:someLanguages];
      NSDebugMLLog(@"bundles",@"path=%@",path);
      if (!path)
        {
          NSDebugMLLog(@"bundles",@"bundlePath=%@ Trying .",_bundlePath);
          path=[self lockedRelativePathForResourceNamed:aName
                     inDirectory:@"."
                     forLanguages:someLanguages];
          NSDebugMLLog(@"bundles",@"path=%@",path);
        };
    };
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                   inDirectory:(id)aDirectory
                                  forLanguages:(NSArray*)someLanguages
{
  //OK
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@ aDirectory=%@ someLanguages=%@",aName,aDirectory,someLanguages);
  if (someLanguages)
    {
      int i=0;
      for(i=0;!path && i<[someLanguages count];i++)
        {
          path=[self lockedCachedRelativePathForResourceNamed:aName
                     inDirectory:aDirectory
                     forLanguage:[someLanguages objectAtIndex:i]];
          NSDebugMLLog(@"bundles",@"path=%@",path);
        };
    };
  if (!path)
    path=[self lockedCachedRelativePathForResourceNamed:aName
               inDirectory:aDirectory
               forLanguage:nil];
  NSDebugMLLog(@"bundles",@"path=%@",path);
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedCachedRelativePathForResourceNamed:(NSString*)aName
                                         inDirectory:(NSString*)aDirectory
                                         forLanguage:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@ aDirectory=%@ aLanguage=%@",aName,aDirectory,aLanguage);
  if (aName)
    {
      NSAutoreleasePool* arp = [NSAutoreleasePool new];
      NS_DURING
        {
          NSString* emptyString=[NSString string];
          NSString* bundlePath=[self bundlePath];
          NSArray* keys;
          if ([aDirectory isEqualToString:@"."])
            aDirectory=nil;
          if (aLanguage)
            keys=[NSArray arrayWithObjects:aName,
                          bundlePath ? bundlePath : emptyString,
                          aDirectory ? aDirectory : emptyString,
                          aLanguage ? aLanguage : emptyString,
                          nil];
          else
            keys=[NSArray arrayWithObjects:aName,
                          bundlePath ? bundlePath : emptyString,
                          aDirectory ? aDirectory : emptyString,
                          nil];
          //NSDebugMLLog(@"bundles",@"_keys=%@",_keys);
          path=[_relativePathsCache objectForKeysArray:keys];
          //NSDebugMLLog(@"bundles",@"_path=%@",_path);
          if (path==GSNotFoundMarker)
            path=nil;
          else if (!path)
            {
              //call again _relativePathForResourceNamed:inDirectory:forLanguage:
              NSString* completePathTest=nil;
              BOOL exists=NO;
              NSFileManager* fileManager=nil;
              NSString* pathTest=[NSString string];
              if (aDirectory)
                pathTest=[pathTest stringByAppendingPathComponent:aDirectory];
              //NSDebugMLLog(@"bundles",@"_pathTest=%@",_pathTest);
              if (aLanguage)
                pathTest=[pathTest stringByAppendingPathComponent:
                                     [aLanguage stringByAppendingString:GSLanguagePSuffix]];
              //NSDebugMLLog(@"bundles",@"pathTest=%@",pathTest);
              pathTest=[pathTest stringByAppendingPathComponent:aName];
              NSDebugMLLog(@"bundles",@"pathTest=%@",pathTest);
              completePathTest=[bundlePath stringByAppendingPathComponent:pathTest];
              NSDebugMLLog(@"bundles",@"completePathTest=%@",completePathTest);
              fileManager=[NSFileManager defaultManager];
              exists=[fileManager fileExistsAtPath:completePathTest];
              NSDebugMLLog(@"bundles",@"exists=%s",(exists ? "YES" : "NO"));
              if (exists)
                {
                  path=pathTest;
                  [_relativePathsCache setObject:path
                                       forKeysArray:keys];
                }
              else
                [_relativePathsCache setObject:GSNotFoundMarker
                                     forKeysArray:keys];
            }
        }
      NS_HANDLER
        {
          localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                   @"lockedCachedRelativePathForResourceNamed:inDirectory:forLanguage:");
          LOGException(@"%@ (%@)",localException,[localException reason]);
          RETAIN(localException);
          DESTROY(arp);
          AUTORELEASE(localException);
          [localException raise];
        }
      NS_ENDHANDLER;
      RETAIN(path);
      DESTROY(arp);
      AUTORELEASE(path);      
    };
  NSDebugMLLog(@"bundles",@"path=%@",path);
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                   inDirectory:(NSString*)aDirectory
                                   forLanguage:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@ aDirectory=%@ aLanguage=%@",
               aName,aDirectory,aLanguage);
  path=[self lockedCachedRelativePathForResourceNamed:aName
             inDirectory:aDirectory
             forLanguage:aLanguage];
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
//	lock
-(void)lock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"selfLock=%p selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
			   (void*)_selfLock,
			   _selfLockn,
			   (void*)_selfLock_thread_id,
			   (void*)objc_thread_id());
  if (_selfLockn>0)
    {
      if (_selfLock_thread_id!=objc_thread_id())
        {
          NSDebugMLog0(@"PROBLEM: owner!=thread id");
        };
    };
  TmpLockBeforeDate(_selfLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
  _selfLockn++;
  _selfLock_thread_id=objc_thread_id();
#endif
  NSDebugMLLog(@"bundles",@"selfLock=%p selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
               _selfLock,
               _selfLockn,
               (void*)_selfLock_thread_id,
               (void*)objc_thread_id());
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	unlock
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"selfLock=%p selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
               (void*)_selfLock,
               _selfLockn,
               (void*)_selfLock_thread_id,
               (void*)objc_thread_id());
  if (_selfLockn>0)
    {
      if (_selfLock_thread_id!=objc_thread_id())
        {
          NSDebugMLog0(@"PROBLEM: owner!=thread id");
        };
    };
  TmpUnlock(_selfLock);
#ifndef NDEBUG
  _selfLockn--;
  if (_selfLockn==0)
    _selfLock_thread_id=NULL;
#endif
  NSDebugMLLog(@"bundles",@"selfLock=%p selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
               (void*)_selfLock,
               _selfLockn,
               (void*)_selfLock_thread_id,
               (void*)objc_thread_id());
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWDeployedBundle (GSWDeployedBundleA)

//--------------------------------------------------------------------
+(id)bundleWithPath:(NSString*)aPath
{
  id bundle=nil;
  NSDebugMLLog(@"bundles",@"aPath=%@",aPath);
  bundle=[[[GSWDeployedBundle alloc]initWithPath:aPath]autorelease];
  return bundle;
};

@end
