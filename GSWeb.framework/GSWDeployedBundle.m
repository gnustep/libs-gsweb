/* GSWDeployedBundle.m - GSWeb: Class GSWDeployedBundle
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>
#include <pthread.h>

//====================================================================
@implementation GSWDeployedBundle

//--------------------------------------------------------------------
-(id)initWithPath:(NSString*)path_
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  NSDebugMLLog(@"bundles",@"path_=%@",path_);
	  ASSIGN(bundlePath,[path_ stringGoodPath]);
	  NSDebugMLLog(@"bundles",@"bundlePath=%@",bundlePath);
	  relativePathsCache=[GSWMultiKeyDictionary new];
#ifndef NDEBUG
	  creation_thread_id=objc_thread_id();
#endif
	  selfLock=[NSRecursiveLock new];
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
  DESTROY(bundlePath);
  DESTROY(relativePathsCache);
  GSWLogC("Dealloc GSWDeployedBundle: selfLock");
  NSDebugFLog(@"selfLock=%p selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p creation_thread_id=%p",
			  (void*)selfLock,
			  selfLockn,
			  (void*)selfLock_thread_id,
			  (void*)objc_thread_id(),
			  (void*)creation_thread_id);
  fflush(stderr);
  DESTROY(selfLock);
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
			   bundlePath];
//  GSWLogC("GSWDeployedBundle description C");
  descr=[descr stringByAppendingFormat:@"relativePathsCache=%p>",
			   (void*)relativePathsCache];
//  GSWLogC("GSWDeployedBundle description D");
  return descr;
};

//--------------------------------------------------------------------
-(GSWProjectBundle*)projectBundle
{
  //OK
  NSString* _projectName=nil;
  BOOL _isFramework=NO;
  GSWDeployedBundle* _projectBundle=nil;
  LOGObjectFnStart();
  _projectName=[self projectName];
  NSDebugMLLog(@"bundles",@"_projectName=%@",_projectName);
  _isFramework=[self isFramework];
  NSDebugMLLog(@"bundles",@"_isFramework=%s",(_isFramework ? "YES" : "NO"));
  _projectBundle=[GSWProjectBundle projectBundleForProjectNamed:_projectName
												   isFramework:_isFramework];
  NSDebugMLLog(@"bundles",@"_projectBundle=%@",_projectBundle);
  LOGObjectFnStop();
  return _projectBundle;
};

//--------------------------------------------------------------------
-(BOOL)isFramework
{
  //OK ??
  return [bundlePath hasSuffix:GSFrameworkSuffix];
};

//--------------------------------------------------------------------
-(NSString*)wrapperName
{
  //OK ?
  NSString* _projectName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"bundlePath=%@",bundlePath);
  _projectName=[bundlePath lastPathComponent];
  NSDebugMLLog(@"bundles",@"_projectName=%@",_projectName);
  _projectName=[_projectName stringByDeletingPathExtension];
  NSDebugMLLog(@"bundles",@"_projectName=%@",_projectName);
  LOGObjectFnStop();
  return _projectName;
};

//--------------------------------------------------------------------
-(NSString*)projectName
{
  // H:\Wotests\ObjCTest3\ObjCTest3.gswa ==> ObjCTest3
  //OK ?
  NSString* _projectName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"bundlePath=%@",bundlePath);
  _projectName=[bundlePath lastPathComponent];
  NSDebugMLLog(@"bundles",@"_projectName=%@",_projectName);
  _projectName=[_projectName stringByDeletingPathExtension];
  NSDebugMLLog(@"bundles",@"_projectName=%@",_projectName);
  LOGObjectFnStop();
  return _projectName;
};

//--------------------------------------------------------------------
-(NSString*)bundlePath
{
  return bundlePath;
};

//--------------------------------------------------------------------
-(NSArray*)pathsForResourcesOfType:(NSString*)type_
{
  //OK
  NSString* _paths=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"type_=%@ language_=%@",type_);
  [self lock];
  NS_DURING
	{
	  _paths=[self lockedPathsForResourcesOfType:type_];
	  NSDebugMLLog(@"bundles",@"_paths=%@",_paths);
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@)",localException,[localException reason]);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  return _paths;
};

//--------------------------------------------------------------------
-(NSArray*)lockedPathsForResourcesOfType:(NSString*)type_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)relativePathForResourceNamed:(NSString*)name_
							 forLanguage:(NSString*)language_
{
  //OK
  NSString* _path=nil;
  LOGObjectFnStart();
  [self lock];
  NSDebugMLLog(@"bundles",@"name_=%@ language_=%@",name_,language_);
  NS_DURING
	{
	  _path=[self lockedRelativePathForResourceNamed:name_
				  forLanguage:language_];
	  NSDebugMLLog(@"bundles",@"_path=%@",_path);
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@)",localException,[localException reason]);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  return _path;
};

//--------------------------------------------------------------------
-(NSString*)relativePathForResourceNamed:(NSString*)name_
							forLanguages:(NSArray*)languages_
{
  NSString* _path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"name_=%@ languages_=%@",name_,languages_);
  [self lock];
  NS_DURING
	{
	  _path=[self lockedRelativePathForResourceNamed:name_
				  forLanguages:languages_];
	  //NSDebugMLLog(@"bundles",@"_path=%@",_path);
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@)",localException,[localException reason]);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return _path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)name_
								   forLanguage:(NSString*)language_
{
  //OK
  NSString* _path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"name_=%@ language_=%@",name_,language_);
  _path=[self lockedRelativePathForResourceNamed:name_
			  inDirectory:@"WebServerResources"
			  forLanguage:language_];
  //NSDebugMLLog(@"bundles",@"_path=%@",_path);
  if (!_path)
	{
	  _path=[self lockedRelativePathForResourceNamed:name_
				  inDirectory:@"Resources"
				  forLanguage:language_];
	  //NSDebugMLLog(@"bundles",@"_path=%@",_path);
	  if (!_path)
		{
		  _path=[self lockedRelativePathForResourceNamed:name_
					  inDirectory:@"."
					  forLanguage:language_];
		  //NSDebugMLLog(@"bundles",@"_path=%@",_path);
		};
	};
  LOGObjectFnStop();
  return _path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)name_
								  forLanguages:(NSArray*)languages_
{
  //OK
  NSString* _path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"name_=%@ languages_=%@",name_,languages_);
  _path=[self lockedRelativePathForResourceNamed:name_
			  inDirectory:@"WebServerResources"
			  forLanguages:languages_];
  //NSDebugMLLog(@"bundles",@"_path=%@",_path);
  if (!_path)
	{
	  _path=[self lockedRelativePathForResourceNamed:name_
				  inDirectory:@"Resources"
				  forLanguages:languages_];
	  //NSDebugMLLog(@"bundles",@"_path=%@",_path);
	  if (!_path)
		{
		  _path=[self lockedRelativePathForResourceNamed:name_
					  inDirectory:@"."
					  forLanguages:languages_];
		  //NSDebugMLLog(@"bundles",@"_path=%@",_path);
		};
	};
  LOGObjectFnStop();
  return _path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)name_
								   inDirectory:(id)directory_
								  forLanguages:(NSArray*)languages_
{
  //OK
  NSString* _path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"name_=%@ directory_=%@ languages_=%@",name_,directory_,languages_);
  if (languages_)
	{
	  int i=0;
	  for(i=0;!_path && i<[languages_ count];i++)
		{
		  _path=[self lockedCachedRelativePathForResourceNamed:name_
					  inDirectory:directory_
					  forLanguage:[languages_ objectAtIndex:i]];
		  NSDebugMLLog(@"bundles",@"_path=%@",_path);
		};
	};
  if (!_path)
	_path=[self lockedCachedRelativePathForResourceNamed:name_
				inDirectory:directory_
				forLanguage:nil];
  NSDebugMLLog(@"bundles",@"_path=%@",_path);
  LOGObjectFnStop();
  return _path;
};

//--------------------------------------------------------------------
-(NSString*)lockedCachedRelativePathForResourceNamed:(NSString*)name_
										 inDirectory:(NSString*)directory_
										 forLanguage:(NSString*)language_
{
  //OK
  NSString* _path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"name_=%@ directory_=%@ language_=%@",name_,directory_,language_);
  if (name_)
	{
	  NSString* _emptyString=[NSString string];
	  NSString* _bundlePath=[self bundlePath];
	  NSArray* _keys;
	  if ([directory_ isEqualToString:@"."])
		directory_=nil;
	  if (language_)
		_keys=[NSArray arrayWithObjects:name_,
					   _bundlePath ? _bundlePath : _emptyString,
					   directory_ ? directory_ : _emptyString,
					   language_ ? language_ : _emptyString,
					   nil];
	  else
		_keys=[NSArray arrayWithObjects:name_,
					   _bundlePath ? _bundlePath : _emptyString,
					   directory_ ? directory_ : _emptyString,
					   nil];
	  //NSDebugMLLog(@"bundles",@"_keys=%@",_keys);
	  _path=[relativePathsCache objectForKeysArray:_keys];
	  //NSDebugMLLog(@"bundles",@"_path=%@",_path);
	  if (_path==GSNotFoundMarker)
		_path=nil;
	  if (!_path)
		{
		  //call again _relativePathForResourceNamed:inDirectory:forLanguage:
		  NSString* _completePathTest=nil;
		  BOOL _exists=NO;
		  NSFileManager* _fileManager=nil;
		  NSString* _pathTest=[NSString string];
		  if (directory_)
			_pathTest=[_pathTest stringByAppendingPathComponent:directory_];
		  //NSDebugMLLog(@"bundles",@"_pathTest=%@",_pathTest);
		  if (language_)
			  _pathTest=[_pathTest stringByAppendingPathComponent:
									 [language_ stringByAppendingString:GSLanguagePSuffix]];
		  //NSDebugMLLog(@"bundles",@"_pathTest=%@",_pathTest);
		  _pathTest=[_pathTest stringByAppendingPathComponent:name_];
		  //NSDebugMLLog(@"bundles",@"_pathTest=%@",_pathTest);
		  _completePathTest=[_bundlePath stringByAppendingPathComponent:_pathTest];
		  //NSDebugMLLog(@"bundles",@"_completePathTest=%@",_completePathTest);
		  _fileManager=[NSFileManager defaultManager];
		  _exists=[_fileManager fileExistsAtPath:_completePathTest];
		  //NSDebugMLLog(@"bundles",@"_exists=%s",(_exists ? "YES" : "NO"));
		  if (_exists)
			{
			  _path=_pathTest;
			  [relativePathsCache setObject:_path
							 forKeysArray:_keys];
			}
		  else
			[relativePathsCache setObject:GSNotFoundMarker
						   forKeysArray:_keys];
		};
	};
  NSDebugMLLog(@"bundles",@"_path=%@",_path);
  LOGObjectFnStop();
  return _path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)name_
								   inDirectory:(NSString*)directory_
								   forLanguage:(NSString*)language_
{
  //OK
  NSString* _path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"name_=%@ directory_=%@ language_=%@",name_,directory_,language_);
  _path=[self lockedCachedRelativePathForResourceNamed:name_
			  inDirectory:directory_
			  forLanguage:language_];
  LOGObjectFnStop();
  return _path;
};

//--------------------------------------------------------------------
//	lock
-(void)lock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"selfLock=%p selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
			   (void*)selfLock,
			   selfLockn,
			   (void*)selfLock_thread_id,
			   (void*)objc_thread_id());
  if (selfLockn>0)
	{
	  if (selfLock_thread_id!=objc_thread_id())
		{
		  NSDebugMLog0(@"PROBLEM: owner!=thread id");
		};
	};
  TmpLockBeforeDate(selfLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
  selfLockn++;
  selfLock_thread_id=objc_thread_id();
#endif
  NSDebugMLLog(@"bundles",@"selfLock=%p selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
			   selfLock,
			   selfLockn,
			   (void*)selfLock_thread_id,
			   (void*)objc_thread_id());
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	unlock
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"selfLock=%p selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
			   (void*)selfLock,
			   selfLockn,
			   (void*)selfLock_thread_id,
			   (void*)objc_thread_id());
  if (selfLockn>0)
	{
	  if (selfLock_thread_id!=objc_thread_id())
		{
		  NSDebugMLog0(@"PROBLEM: owner!=thread id");
		};
	};
  TmpUnlock(selfLock);
#ifndef NDEBUG
	selfLockn--;
	if (selfLockn==0)
	  selfLock_thread_id=NULL;
#endif
  NSDebugMLLog(@"bundles",@"selfLock=%p selfLockn=%d selfLock_thread_id=%p objc_thread_id()=%p",
			   (void*)selfLock,
			   selfLockn,
			   (void*)selfLock_thread_id,
			   (void*)objc_thread_id());
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWDeployedBundle (GSWDeployedBundleA)

//--------------------------------------------------------------------
+(id)bundleWithPath:(NSString*)path_
{
  id _bundle=[[[GSWDeployedBundle alloc]initWithPath:path_]autorelease];
  return _bundle;
};

@end
