/** GSWProjectBundle.m - <title>GSWeb: Class GSWProjectBundle</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Mar 1999
   
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>
#include <Foundation/NSFileManager.h>

//====================================================================
@implementation GSWProjectBundle

-(id)initWithPath:(NSString*)aPath
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aPath=%@",aPath);
  if ((self=[super initWithPath:aPath]))
    {
      //TODO
    };
  LOGObjectFnStop();
  return nil;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_projectName);
  DESTROY(_subprojects);
  DESTROY(_pbProjectDictionary);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - bundlePath:[%@] relativePaths:[%@] projectName:[%@] subprojects:[%@] pbProjectDictionary:[%@]>",
                   object_get_class_name(self),
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
  LOGObjectFnNotImplemented();	//TODOFN
  return [super lockedPathsForResourcesOfType:aType];
};

//--------------------------------------------------------------------
-(NSArray*)lockedPathsForResourcesInSubprojectsOfType:(id)aType
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                   forLanguage:(NSString*)aLanguage
{
  LOGObjectFnNotImplemented();	//TODOFN
  return [super lockedRelativePathForResourceNamed:aName
                forLanguage:aLanguage];
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)aName
                                  forLanguages:(NSArray*)someLanguages
{
  LOGObjectFnNotImplemented();	//TODOFN
  return [super lockedRelativePathForResourceNamed:aName
                forLanguages:someLanguages];
};

//--------------------------------------------------------------------
-(NSDictionary*)subprojects
{
  return _subprojects;
};

//--------------------------------------------------------------------
-(BOOL)isFramework
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(GSWDeployedBundle*)projectBundle
{
  LOGObjectFnNotImplemented();	//TODOFN
  return [super projectBundle];
};

//--------------------------------------------------------------------
-(NSString*)projectPath
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)projectName
{
  return _projectName;
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
  LOGClassFnStart();
  NSDebugMLLog(@"bundles",@"aName:%@",aName);
  NSDebugMLLog(@"bundles",@"isFramework=%s",(isFramework ? "YES" : "NO"));
    
  projectSearchPath=[GSWApplication projectSearchPath];	 // ("H:\\Wotests")
  NSDebugMLLog(@"bundles",@"projectSearchPath:%@",projectSearchPath);
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
          NSDebugMLLog(@"bundles",@"filePath:%@",filePath);
          //		  NSDebugMLLog(@"bundles",@"attributes:%@",attributes);
          //		  NSDebugMLLog(@"bundles",@"fileType:%@",fileType);
          if ([fileType isEqual:NSFileTypeDirectory])
            {
              BOOL tmpBundleIsFramework=NO;
              NSString* tmpBundleProjectName=nil;
              GSWDeployedBundle* tmpBundle=(GSWDeployedBundle*)[GSWProjectBundle bundleWithPath:filePath];
              NSDebugMLLog(@"bundles",@"tmpBundle:%@",tmpBundle);
              tmpBundleProjectName=[tmpBundle projectName];
              NSDebugMLLog(@"bundles",@"tmpBundleProjectName:%@",tmpBundleProjectName);
              tmpBundleIsFramework=[tmpBundle isFramework];
              NSDebugMLLog(@"bundles",@"tmpBundleIsFramework=%s",
                           (tmpBundleIsFramework ? "YES" : "NO"));
//Why projectName...
              if ((isFramework && tmpBundleIsFramework)
                  ||(!isFramework && !tmpBundleIsFramework))
                {
                  NSDebugMLLog(@"bundles",@"adding tmpBundle:%@",tmpBundleProjectName);
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
      NSDebugMLLog(@"bundles",@"suffix1:%@ suffix2",suffix1,suffix2);
      NSDebugMLLog(@"bundles",@"aBundle:%@",aBundle);

      if ([[aBundle bundlePath]hasSuffix:suffix1] 
          || [[aBundle bundlePath]hasSuffix:suffix2] 
          || [[aBundle bundlePath]hasSuffix:@".debug"])
        {
          NSString* tmpName=[aBundle projectName];
          NSDebugMLLog(@"bundles",@"tmpName:%@",tmpName);
          if ([tmpName isEqual:aName])
            {
              projectBundle=aBundle;
              NSDebugMLLog(@"bundles",@"projectBundle:%@",projectBundle);
            };
        };
    };
  NSDebugMLLog(@"bundles",@"projectBundle:%@",projectBundle);
  LOGClassFnStop();
  return projectBundle;
};

@end
