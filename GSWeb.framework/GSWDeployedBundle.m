/** GSWDeployedBundle.m - <title>GSWeb: Class GSWDeployedBundle</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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

      ASSIGN(_wrapperName,([_bundlePath lastPathComponent]));
      NSDebugMLLog(@"bundles",@"_wrapperName=%@",_wrapperName);
      
      ASSIGN(_projectName,([_wrapperName stringByDeletingPathExtension]));
      NSDebugMLLog(@"bundles",@"_projectName=%@",_projectName);

      _isFramework=[_bundlePath hasSuffix:GSFrameworkSuffix];//Ok ?

      _relativePathsCache=[GSWMultiKeyDictionary new];
      _absolutePathsCache=[NSMutableDictionary new];
      _urlsCache=[NSMutableDictionary new];
#ifndef NDEBUG
      _creation_thread_id=GSCurrentThread();
#endif
      _selfLock=[NSRecursiveLock new];
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  NSDebugFLog(@"Dealloc GSWDeployedBundle %p",(void*)self);
  DESTROY(_bundlePath);
  DESTROY(_wrapperName);
  DESTROY(_projectName);
  DESTROY(_relativePathsCache);
  DESTROY(_absolutePathsCache);
  DESTROY(_urlsCache);
  GSWLogC("Dealloc GSWDeployedBundle: selfLock");
  NSDebugFLog(@"selfLock=%p selfLockn=%d selfLock_thread_id=%@ "
	      @"GSCurrentThread()=%@ creation_thread_id=%@",
              (void*)_selfLock,
              _selfLockn,
              _selfLock_thread_id,
              GSCurrentThread(),
              _creation_thread_id);
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
                  object_getClassName(self),
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
  return _isFramework;
};

//--------------------------------------------------------------------
-(NSString*)wrapperName
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _wrapperName;
};

//--------------------------------------------------------------------
-(NSString*)projectName
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _projectName;
};

//--------------------------------------------------------------------
-(NSString*)bundlePath
{
  return _bundlePath;
};

//--------------------------------------------------------------------
-(NSString*)bundleURLPrefix
{  
  NSString* urlPrefix=nil;
  NSString* wrapperName=nil;

  if ([self isFramework]) // get framework prefix ?
    urlPrefix = [GSWApplication frameworksBaseURL];
  else
    urlPrefix = [GSWApplication applicationBaseURL];

  NSDebugMLLog(@"bundles",@"urlPrefix=%@",urlPrefix);
  NSAssert([urlPrefix length]>0,@"No urlPrefix");
  
  wrapperName=[self wrapperName];
  NSDebugMLLog(@"bundles",@"wrapperName=%@",wrapperName);
  NSAssert([wrapperName length]>0,@"No wrapperName");
  
  if (urlPrefix && wrapperName)
    {
      urlPrefix=[urlPrefix stringByAppendingPathComponent:wrapperName];
      NSDebugMLLog(@"bundles",@"urlPrefix=%@",urlPrefix);
    };
  return urlPrefix;
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
                             language:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;
  LOGObjectFnStart();
  [self lock];
  NSDebugMLLog(@"bundles",@"aName=%@ aLanguage=%@",aName,aLanguage);
  NS_DURING
    {
      path=[self lockedRelativePathForResourceNamed:aName
                 language:aLanguage];
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
                            languages:(NSArray*)someLanguages
{
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@ someLanguages=%@",aName,someLanguages);
  [self lock];
  NS_DURING
    {
      path=[self lockedRelativePathForResourceNamed:aName
                 languages:someLanguages];
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
                                   language:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@ aLanguage=%@",aName,aLanguage);
  NSDebugMLLog(@"bundles",@"bundlePath=%@ Trying Resources/WebServer",_bundlePath);
  path=[self lockedRelativePathForResourceNamed:aName
             inDirectory:@"Resources/WebServer"
             language:aLanguage];
  NSDebugMLLog(@"bundles",@"path=%@",path);
  if (!path)
    {
      NSDebugMLLog(@"bundles",@"bundlePath=%@ Trying Resources",_bundlePath);
      path=[self lockedRelativePathForResourceNamed:aName
                 inDirectory:@"Resources"
                 language:aLanguage];
      NSDebugMLLog(@"bundles",@"path=%@",path);
      if (!path)
        {
          NSDebugMLLog(@"bundles",@"bundlePath=%@ Trying .",_bundlePath);
          path=[self lockedRelativePathForResourceNamed:aName
                     inDirectory:@"."
                     language:aLanguage];
          NSDebugMLLog(@"bundles",@"path=%@",path);
        };
    };
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                  languages:(NSArray*)someLanguages
{
  //OK
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@ someLanguages=%@",aName,someLanguages);
  NSDebugMLLog(@"bundles",@"bundlePath=%@ Trying Resources/WebServer",_bundlePath);
  path=[self lockedRelativePathForResourceNamed:aName
             inDirectory:@"Resources/WebServer"
             languages:someLanguages];
  NSDebugMLLog(@"bundles",@"path=%@",path);
  if (!path)
    {
      NSDebugMLLog(@"bundles",@"bundlePath=%@ Trying Resources",_bundlePath);
      path=[self lockedRelativePathForResourceNamed:aName
                 inDirectory:@"Resources"
                 languages:someLanguages];
      NSDebugMLLog(@"bundles",@"path=%@",path);
      if (!path)
        {
          NSDebugMLLog(@"bundles",@"bundlePath=%@ Trying .",_bundlePath);
          path=[self lockedRelativePathForResourceNamed:aName
                     inDirectory:@"."
                     languages:someLanguages];
          NSDebugMLLog(@"bundles",@"path=%@",path);
        };
    };
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                   inDirectory:(NSString*)aDirectory
                                     languages:(NSArray*)someLanguages
{
  //OK
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@ aDirectory=%@ someLanguages=%@",aName,aDirectory,someLanguages);
  if (someLanguages)
    {
      int i=0;
      int someLanguagesCount=[someLanguages count];
      for(i=0;!path && i<someLanguagesCount;i++)
        {
          path=[self lockedCachedRelativePathForResourceNamed:aName
                     inDirectory:aDirectory
                     language:[someLanguages objectAtIndex:i]];
          NSDebugMLLog(@"bundles",@"path=%@",path);
        };
    };
  if (!path)
    path=[self lockedCachedRelativePathForResourceNamed:aName
               inDirectory:aDirectory
               language:nil];
  NSDebugMLLog(@"bundles",@"path=%@",path);
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedCachedRelativePathForResourceNamed:(NSString*)aName
                                         inDirectory:(NSString*)aDirectory
                                            language:(NSString*)aLanguage
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
          NSString* emptyString=@"";
          NSString* bundlePath=[self bundlePath];
          NSDebugMLLog(@"bundles",@"aName=%@ bundlePath=%@ aDirectory=%@ aLanguage=%@",
                       aName,bundlePath,aDirectory,aLanguage);
          if ([aDirectory isEqualToString:@"."])
            aDirectory=nil;
          if (aLanguage)
            path=[_relativePathsCache objectForKeys:aName,
                                      (bundlePath ? bundlePath : emptyString),
                                      (aDirectory ? aDirectory : emptyString),
                                      (aLanguage ? aLanguage : emptyString),
                                      nil];
          else
            path=[_relativePathsCache objectForKeys:aName,
                                      (bundlePath ? bundlePath : emptyString),
                                      (aDirectory ? aDirectory : emptyString),
                                      nil];
          NSDebugMLLog(@"bundles",@"path=%@",path);
          if (path==GSNotFoundMarker)
            path=nil;
          else if (!path)
            {
              //TODO: use a mutable string for path ?
              //call again _relativePathForResourceNamed:inDirectory:language:
              NSString* completePathTest=nil;
              BOOL exists=NO;
              NSFileManager* fileManager=nil;
              NSString* pathTest=@"";
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
              #ifdef __APPLE__
              if(!exists)
                {
                  NSString  *aCompletePath = [[[NSBundle bundleWithPath:bundlePath] 
                                                pathForResource:[aName stringByDeletingPathExtension] 
                                                ofType:[aName pathExtension] 
                                                inDirectory:aDirectory
                                                forLocalization:aLanguage]
                                              stringByResolvingSymlinksInPath];
                
                if([aCompletePath length] >= ([bundlePath length] + 1))
                  {
                    exists = YES;
                    pathTest = [aCompletePath substringFromIndex:[bundlePath length] + 1];
                  }
                }
              #endif //__APPLE__
              if (exists)
                {
                  path=pathTest;
                  if (aLanguage)
                    [_relativePathsCache setObject:path
                                         forKeys:aName,
                                         (bundlePath ? bundlePath : emptyString),
                                         (aDirectory ? aDirectory : emptyString),
                                         (aLanguage ? aLanguage : emptyString),
                                         nil];
                  else
                    [_relativePathsCache setObject:path
                                         forKeys:aName,
                                         (bundlePath ? bundlePath : emptyString),
                                         (aDirectory ? aDirectory : emptyString),
                                         nil];
                }
              else
                {
                  if (aLanguage)
                    [_relativePathsCache setObject:GSNotFoundMarker
                                         forKeys:aName,
                                         (bundlePath ? bundlePath : emptyString),
                                         (aDirectory ? aDirectory : emptyString),
                                         (aLanguage ? aLanguage : emptyString),
                                         nil];
                  else
                    [_relativePathsCache setObject:GSNotFoundMarker
                                         forKeys:aName,
                                         (bundlePath ? bundlePath : emptyString),
                                         (aDirectory ? aDirectory : emptyString),
                                         nil];
                }
            }
        }
      NS_HANDLER
        {
          localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                   @"lockedCachedRelativePathForResourceNamed:inDirectory:language:");
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
                                   language:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@ aDirectory=%@ aLanguage=%@",
               aName,aDirectory,aLanguage);
  path=[self lockedCachedRelativePathForResourceNamed:aName
             inDirectory:aDirectory
             language:aLanguage];
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
/** Returns url for resource anmed aName for languages someLanguages **/
-(NSString*)urlForResourceNamed:(NSString*)aName
                   languages:(NSArray*)someLanguages
{
  NSString* url=nil;

  LOGObjectFnStart();

  NSDebugMLLog(@"bundles",@"aName=%@ someLanguages=%@",aName,someLanguages);

  [self lock];
  NS_DURING
    {
      NSString* relativePath=[self lockedRelativePathForResourceNamed:aName
                                   languages:someLanguages];
      NSDebugMLLog(@"bundles",@"relativePath=%@",relativePath);
      url=[self lockedCachedURLForRelativePath:relativePath];
      NSDebugMLLog(@"bundles",@"url=%@",url);
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

  return url;
};

/** Returns the absolute path (cached or not) for relativePath. Put it in the cache 
if it was not cached **/
-(NSString*)lockedCachedAbsolutePathForRelativePath:(NSString*)relativePath
{
  NSString* path=nil;

  LOGObjectFnStart();

  if (relativePath)
    {
      // Test if already cached
      path = [_absolutePathsCache objectForKey:relativePath];

      // If not, build it
      if (!path)
        {
          path=[[self bundlePath] stringByAppendingPathComponent:relativePath];
          [_absolutePathsCache setObject:path
                               forKey:relativePath];
        }
    }

  LOGObjectFnStop();

  return path;
};

//--------------------------------------------------------------------
-(NSString*)absolutePathForRelativePath:(NSString*)relativePath
{
  NSString* path=nil;

  LOGObjectFnStart();

  [self lock];
  NS_DURING
    {
      path=[self lockedCachedAbsolutePathForRelativePath:relativePath];
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

  LOGObjectFnStop();

  return path;
}

//--------------------------------------------------------------------
-(NSString*)absolutePathForResourceNamed:(NSString*)aName
                            languages:(NSArray*)someLanguages
{
  NSString* absolutePath=nil;
  NSString* relativePath=nil;

  LOGObjectFnStart();

  relativePath = [self relativePathForResourceNamed:aName
                       languages:someLanguages];
  NSDebugMLLog(@"bundles",@"relativePath=%@",relativePath);

  absolutePath=[self absolutePathForRelativePath:relativePath];
  NSDebugMLLog(@"bundles",@"absolutePath=%@",absolutePath);

  LOGObjectFnStop();
  return absolutePath;
}

//--------------------------------------------------------------------
/** Returns the url (cached or not) for relativePath. Put it in the cache 
if it was not cached **/
-(NSString*)lockedCachedURLForRelativePath:(NSString*)relativePath
{
  NSString* url=nil;

  LOGObjectFnStart();

  if (relativePath)
    {
      // Test if already cached
      url = [_urlsCache objectForKey:relativePath];

      // If not, build it
      if (!url)
        {
          NSString* urlPrefix=[self bundleURLPrefix];
          NSDebugMLLog(@"bundles",@"urlPrefix=%@",urlPrefix);

          url=[urlPrefix stringByAppendingPathComponent:relativePath];
          NSDebugMLLog(@"bundles",@"url=%@",url);

          [_urlsCache setObject:url
                      forKey:relativePath];
        };
    }
  LOGObjectFnStop();
  return url;
};

//--------------------------------------------------------------------
//	lock
-(void)lock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",
	       @"selfLock=%p selfLockn=%d selfLock_thread_id=%@ "
	       @"GSCurrentThread()=%@",
	       (void*)_selfLock,
	       _selfLockn,
	       _selfLock_thread_id,
	       GSCurrentThread());
  if (_selfLockn>0)
    {
      if (_selfLock_thread_id!=GSCurrentThread())
        {
          NSDebugMLog0(@"PROBLEM: owner!=thread id");
        };
    };
  LoggedLockBeforeDate(_selfLock,GSW_LOCK_LIMIT);
#ifndef NDEBUG
  _selfLockn++;
  _selfLock_thread_id=GSCurrentThread();
#endif
  NSDebugMLLog(@"bundles",
	       @"selfLock=%p selfLockn=%d selfLock_thread_id=%@ "
	       @"GSCurrentThread()=%@",
               _selfLock,
               _selfLockn,
               _selfLock_thread_id,
               GSCurrentThread());
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	unlock
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",
	       @"selfLock=%p selfLockn=%d selfLock_thread_id=%@ "
	       @"GSCurrentThread()=%@",
               (void*)_selfLock,
               _selfLockn,
               _selfLock_thread_id,
               GSCurrentThread());
  if (_selfLockn>0)
    {
      if (_selfLock_thread_id!=GSCurrentThread())
        {
          NSDebugMLog0(@"PROBLEM: owner!=thread id");
        };
    };
  LoggedUnlock(_selfLock);
#ifndef NDEBUG
  _selfLockn--;
  if (_selfLockn==0)
    _selfLock_thread_id=NULL;
#endif
  NSDebugMLLog(@"bundles",
	       @"selfLock=%p selfLockn=%d selfLock_thread_id=%@ "
	       @"GSCurrentThread()=%@",
               (void*)_selfLock,
               _selfLockn,
               _selfLock_thread_id,
               GSCurrentThread());
  LOGObjectFnStop();
};


//--------------------------------------------------------------------
+(id)bundleWithPath:(NSString*)aPath
{
  id bundle=nil;
  NSDebugMLLog(@"bundles",@"aPath=%@",aPath);
  bundle=[[[GSWDeployedBundle alloc]initWithPath:aPath]autorelease];
  return bundle;
};

@end
