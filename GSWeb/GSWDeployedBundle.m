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

#include "GSWeb.h"
#include <GNUstepBase/NSThread+GNUstepBase.h>
#include <GNUstepBase/NSObject+GNUstepBase.h>


//====================================================================
@implementation GSWDeployedBundle

//--------------------------------------------------------------------
-(id)initWithPath:(NSString*)aPath
{
  if ((self=[super init]))
    {
      ASSIGN(_bundlePath,[aPath stringGoodPath]);
      ASSIGN(_wrapperName,([_bundlePath lastPathComponent]));
      ASSIGN(_projectName,([_wrapperName stringByDeletingPathExtension]));

      _isFramework=[_bundlePath hasSuffix:GSFrameworkSuffix];//Ok ?

      _relativePathsCache=[GSWMultiKeyDictionary new];
      _absolutePathsCache=[NSMutableDictionary new];
      _urlsCache=[NSMutableDictionary new];
#ifndef NDEBUG
      _creation_thread_id=GSCurrentThread();
#endif
      _selfLock=[NSRecursiveLock new];
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_bundlePath);
  DESTROY(_wrapperName);
  DESTROY(_projectName);
  DESTROY(_relativePathsCache);
  DESTROY(_absolutePathsCache);
  DESTROY(_urlsCache);
  DESTROY(_selfLock);

  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  NSString* descr=nil;
  descr=[NSString stringWithFormat:@"<%s %p - ",
                  object_getClassName(self),
                  (void*)self];
  descr=[descr stringByAppendingFormat:@"bundlePath:%@ ",
               _bundlePath];
  descr=[descr stringByAppendingFormat:@"relativePathsCache=%p>",
               (void*)_relativePathsCache];
  return descr;
};

//--------------------------------------------------------------------
-(GSWProjectBundle*)projectBundle
{
  //OK
  NSString* projectName=nil;
  BOOL isFramework=NO;
  GSWDeployedBundle* projectBundle=nil;
  projectName=[self projectName];
  isFramework=[self isFramework];
  
  projectBundle=[GSWProjectBundle projectBundleForProjectNamed:projectName
                                  isFramework:isFramework];

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
  return _wrapperName;
};

//--------------------------------------------------------------------
-(NSString*)projectName
{
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

  NSAssert([urlPrefix length]>0,@"No urlPrefix");
  
  wrapperName=[self wrapperName];
  NSAssert([wrapperName length]>0,@"No wrapperName");
  
  if (urlPrefix && wrapperName)
    {
      urlPrefix=[urlPrefix stringByAppendingPathComponent:wrapperName];
    };
  return urlPrefix;
};

//--------------------------------------------------------------------
-(NSArray*)pathsForResourcesOfType:(NSString*)aType
{
  //OK
  NSArray* paths=nil;
  [self lock];
  NS_DURING
    {
      paths=[self lockedPathsForResourcesOfType:aType];
    }
  NS_HANDLER
    {
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
  [self notImplemented: _cmd];
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)relativePathForResourceNamed:(NSString*)aName
                             language:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;
  [self lock];

  NS_DURING
    {
      path=[self lockedRelativePathForResourceNamed:aName
                 language:aLanguage];
    }
  NS_HANDLER
    {
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

  [self lock];
  NS_DURING
    {
      path=[self lockedRelativePathForResourceNamed:aName
                 languages:someLanguages];
      //NSDebugMLLog(@"bundles",@"path=%@",path);
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                   language:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;

  path=[self lockedRelativePathForResourceNamed:aName
             inDirectory:@"Resources/WebServer"
             language:aLanguage];

  if (!path)
    {
      path=[self lockedRelativePathForResourceNamed:aName
                 inDirectory:@"Resources"
                 language:aLanguage];
      if (!path)
        {
          path=[self lockedRelativePathForResourceNamed:aName
                     inDirectory:@"."
                     language:aLanguage];
        };
    };
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                  languages:(NSArray*)someLanguages
{
  //OK
  NSString* path=nil;

  path=[self lockedRelativePathForResourceNamed:aName
             inDirectory:@"Resources/WebServer"
             languages:someLanguages];

  if (!path)
    {
      path=[self lockedRelativePathForResourceNamed:aName
                 inDirectory:@"Resources"
                 languages:someLanguages];
      if (!path)
        {
          path=[self lockedRelativePathForResourceNamed:aName
                     inDirectory:@"."
                     languages:someLanguages];
        };
    };
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                   inDirectory:(NSString*)aDirectory
                                     languages:(NSArray*)someLanguages
{
  //OK
  NSString* path=nil;

  if (someLanguages)
    {
      int i=0;
      int someLanguagesCount=[someLanguages count];
      for(i=0;!path && i<someLanguagesCount;i++)
        {
          path=[self lockedCachedRelativePathForResourceNamed:aName
                     inDirectory:aDirectory
                     language:[someLanguages objectAtIndex:i]];
        };
    };
  if (!path)
    path=[self lockedCachedRelativePathForResourceNamed:aName
               inDirectory:aDirectory
               language:nil];
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedCachedRelativePathForResourceNamed:(NSString*)aName
                                         inDirectory:(NSString*)aDirectory
                                            language:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;
  if (aName)
    {
      NS_DURING
        {
          NSString* emptyString=@"";
          NSString* bundlePath=[self bundlePath];

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
              completePathTest=[bundlePath stringByAppendingPathComponent:pathTest];
              fileManager=[NSFileManager defaultManager];
              exists=[fileManager fileExistsAtPath:completePathTest];
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
          RETAIN(localException);
          AUTORELEASE(localException);
          [localException raise];
        }
      NS_ENDHANDLER;
      RETAIN(path);
      AUTORELEASE(path);      
    };
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                   inDirectory:(NSString*)aDirectory
                                   language:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;

  path=[self lockedCachedRelativePathForResourceNamed:aName
             inDirectory:aDirectory
             language:aLanguage];
  return path;
};

//--------------------------------------------------------------------
/** Returns url for resource anmed aName for languages someLanguages **/
-(NSString*)urlForResourceNamed:(NSString*)aName
                   languages:(NSArray*)someLanguages
{
  NSString* url=nil;

  [self lock];
  NS_DURING
    {
      NSString* relativePath=[self lockedRelativePathForResourceNamed:aName
                                   languages:someLanguages];

      url=[self lockedCachedURLForRelativePath:relativePath];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];


  return url;
};

/** Returns the absolute path (cached or not) for relativePath. Put it in the cache 
if it was not cached **/
-(NSString*)lockedCachedAbsolutePathForRelativePath:(NSString*)relativePath
{
  NSString* path=nil;


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


  return path;
};

//--------------------------------------------------------------------
-(NSString*)absolutePathForRelativePath:(NSString*)relativePath
{
  NSString* path=nil;


  [self lock];
  NS_DURING
    {
      path=[self lockedCachedAbsolutePathForRelativePath:relativePath];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];


  return path;
}

//--------------------------------------------------------------------
-(NSString*)absolutePathForResourceNamed:(NSString*)aName
                            languages:(NSArray*)someLanguages
{
  NSString* absolutePath=nil;
  NSString* relativePath=nil;


  relativePath = [self relativePathForResourceNamed:aName
                       languages:someLanguages];

  absolutePath=[self absolutePathForRelativePath:relativePath];

  return absolutePath;
}

//--------------------------------------------------------------------
/** Returns the url (cached or not) for relativePath. Put it in the cache 
if it was not cached **/
-(NSString*)lockedCachedURLForRelativePath:(NSString*)relativePath
{
  NSString* url=nil;


  if (relativePath)
    {
      // Test if already cached
      url = [_urlsCache objectForKey:relativePath];

      // If not, build it
      if (!url)
        {
          NSString* urlPrefix=[self bundleURLPrefix];

          url=[urlPrefix stringByAppendingPathComponent:relativePath];

          [_urlsCache setObject:url
                      forKey:relativePath];
        };
    }
  return url;
};

//--------------------------------------------------------------------
//	lock
-(void)lock
{
  if (_selfLockn>0)
    {
      if (_selfLock_thread_id!=GSCurrentThread())
        {
          NSLog(@"PROBLEM: owner!=thread id");
        };
    };
  LoggedLockBeforeDate(_selfLock,GSW_LOCK_LIMIT);
#ifndef NDEBUG
  _selfLockn++;
  _selfLock_thread_id=GSCurrentThread();
#endif
};

//--------------------------------------------------------------------
//	unlock
-(void)unlock
{
  if (_selfLockn>0)
    {
      if (_selfLock_thread_id!=GSCurrentThread())
        {
          NSLog(@"PROBLEM: owner!=thread id");
        };
    };
  LoggedUnlock(_selfLock);
#ifndef NDEBUG
  _selfLockn--;
  if (_selfLockn==0)
    _selfLock_thread_id=NULL;
#endif
};


//--------------------------------------------------------------------
+(id)bundleWithPath:(NSString*)aPath
{
  id bundle=nil;
  bundle=[[[GSWDeployedBundle alloc]initWithPath:aPath]autorelease];
  return bundle;
};

@end
