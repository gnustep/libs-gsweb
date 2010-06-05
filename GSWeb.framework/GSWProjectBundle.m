/** GSWProjectBundle.m - <title>GSWeb: Class GSWProjectBundle</title>

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
#include <Foundation/NSFileManager.h>
#include <GNUstepBase/NSObject+GNUstepBase.h>

//====================================================================
@implementation GSWProjectBundle

-(id)initWithPath:(NSString*)aPath
{
  if ((self=[super initWithPath:aPath]))
    {
      //TODO
    };
  return nil;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_subprojects);
  DESTROY(_pbProjectDictionary);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - bundlePath:[%@] relativePaths:[%@] projectName:[%@] subprojects:[%@] pbProjectDictionary:[%@]>",
                   object_getClassName(self),
                   (void*)self,
                   _bundlePath,
                   _relativePathsCache,
                   _projectName,
                   _subprojects,
                   _pbProjectDictionary];
};

//--------------------------------------------------------------------
-(NSArray*)lockedPathsForResourcesOfType:(id)aType
{
  [self notImplemented: _cmd];	//TODOFN
  return [super lockedPathsForResourcesOfType:aType];
};

//--------------------------------------------------------------------
-(NSArray*)lockedPathsForResourcesInSubprojectsOfType:(id)aType
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                      language:(NSString*)aLanguage
{
  [self notImplemented: _cmd];	//TODOFN
  return [super lockedRelativePathForResourceNamed:aName
                language:aLanguage];
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                     languages:(NSArray*)someLanguages
{
  [self notImplemented: _cmd];	//TODOFN
  return [super lockedRelativePathForResourceNamed:aName
                languages:someLanguages];
};

//--------------------------------------------------------------------
-(NSDictionary*)subprojects
{
  return _subprojects;
};

//--------------------------------------------------------------------
-(BOOL)isFramework
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(GSWDeployedBundle*)projectBundle
{
  [self notImplemented: _cmd];	//TODOFN
  return [super projectBundle];
};

//--------------------------------------------------------------------
-(NSString*)projectPath
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSDictionary*)_pbProjectDictionary
{
  return _pbProjectDictionary;
};

@end

//====================================================================
@implementation GSWProjectBundle (GSWProjectBundle)
+(GSWDeployedBundle*)projectBundleForProjectNamed:(NSString*)aName
                                      isFramework:(BOOL)isFramework
{
  //OK
  //name:ObjCTest3
  GSWDeployedBundle* projectBundle=nil;
  GSWDeployedBundle* aBundle=nil;
  NSArray* projectSearchPath=nil;
  NSMutableArray* projectsBundles=nil;
  NSEnumerator* projectEnum = nil;
  NSEnumerator* projectSearchPathEnum=nil;
  NSString* path=nil;
    
  projectSearchPath=[GSWApplication projectSearchPath];	 // ("H:\\Wotests")
  projectsBundles=[NSMutableArray array];

  projectSearchPathEnum = [projectSearchPath objectEnumerator];
  while ((path = [projectSearchPathEnum nextObject]))
    {
      NSDirectoryEnumerator* dirEnum=nil;
      NSString* filePath=nil;
      NSFileManager* fileManager=[NSFileManager defaultManager];
      dirEnum = [fileManager enumeratorAtPath:path];
      while ((filePath = [dirEnum nextObject]))
        {
          NSDictionary* attributes = [dirEnum fileAttributes];
          NSString* fileType = [attributes objectForKey:NSFileType];
          filePath=[path stringByAppendingFormat:@"/%@",filePath];
          if ([fileType isEqual:NSFileTypeDirectory])
            {
              BOOL tmpBundleIsFramework=NO;
              NSString* tmpBundleProjectName=nil;
              GSWDeployedBundle* tmpBundle=(GSWDeployedBundle*)[GSWProjectBundle bundleWithPath:filePath];
              tmpBundleProjectName=[tmpBundle projectName];
              tmpBundleIsFramework=[tmpBundle isFramework];
//Why projectName...
              if ((isFramework && tmpBundleIsFramework)
                  ||(!isFramework && !tmpBundleIsFramework))
                {
                  [projectsBundles addObject:tmpBundle];
                };
            };
        };
    };
  projectEnum =[projectsBundles objectEnumerator];
  while(!projectBundle && (aBundle = [projectEnum nextObject]))
    {
      NSString* suffix1=isFramework ? GSFrameworkPSuffix : GSWApplicationPSuffix[GSWebNamingConv];
      NSString* suffix2=isFramework ? GSFrameworkPSuffix : GSWApplicationPSuffix[GSWebNamingConvInversed];

      if ([[aBundle bundlePath]hasSuffix:suffix1] 
          || [[aBundle bundlePath]hasSuffix:suffix2] 
          || [[aBundle bundlePath]hasSuffix:@".debug"])
        {
          NSString* tmpName=[aBundle projectName];
          if ([tmpName isEqual:aName])
            {
              projectBundle=aBundle;
            };
        };
    };
  return projectBundle;
};

@end
