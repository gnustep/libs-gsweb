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

-(id)initWithPath:(NSString*)path_
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"path_=%@",path_);
  if ((self=[super initWithPath:path_]))
    {
      //TODO
    };
  LOGObjectFnStop();
  return nil;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(projectName);
  DESTROY(subprojects);
  DESTROY(pbProjectDictionary);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - bundlePath:[%@] relativePaths:[%@] projectName:[%@] subprojects:[%@] pbProjectDictionary:[%@]>",
				   object_get_class_name(self),
				   (void*)self,
				   bundlePath,
				   relativePathsCache,
				   projectName,
				   subprojects,
				   pbProjectDictionary];
};

//--------------------------------------------------------------------
-(NSArray*)lockedPathsForResourcesOfType:(id)type_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return [super lockedPathsForResourcesOfType:type_];
};

//--------------------------------------------------------------------
-(NSArray*)lockedPathsForResourcesInSubprojectsOfType:(id)type_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)name_
								   forLanguage:(NSString*)language_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return [super lockedRelativePathForResourceNamed:name_
				forLanguage:language_];
};

//--------------------------------------------------------------------
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)name_
								  forLanguages:(NSArray*)languages_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return [super lockedRelativePathForResourceNamed:name_
					  forLanguages:languages_];
};

//--------------------------------------------------------------------
-(NSDictionary*)subprojects
{
  return subprojects;
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
  return projectName;
};

//--------------------------------------------------------------------
-(NSDictionary*)_pbProjectDictionary
{
  return pbProjectDictionary;
};

@end

//====================================================================
@implementation GSWProjectBundle (GSWProjectBundle)
+(GSWDeployedBundle*)projectBundleForProjectNamed:(NSString*)name_
									  isFramework:(BOOL)isFramework_
{
  //OK
  //name:ObjCTest3
  GSWDeployedBundle* _projectBundle=nil;
  GSWDeployedBundle* _aBundle=nil;
  NSArray* _projectSearchPath=nil;
  NSMutableArray* _projectsBundles=nil;
  NSEnumerator* _projectEnum = nil;
  NSEnumerator* _projectSearchPathEnum=nil;
  NSString* _path=nil;
  LOGClassFnStart();
  NSDebugMLLog(@"bundles",@"name_:%@",name_);
  NSDebugMLLog(@"bundles",@"isFramework_=%s",(isFramework_ ? "YES" : "NO"));
    
  _projectSearchPath=[GSWApplication projectSearchPath];	 // ("H:\\Wotests")
  NSDebugMLLog(@"bundles",@"_projectSearchPath:%@",_projectSearchPath);
  _projectsBundles=[NSMutableArray array];

  _projectSearchPathEnum = [_projectSearchPath objectEnumerator];
  while ((_path = [_projectSearchPathEnum nextObject]))
	{
	  NSDirectoryEnumerator* dirEnum=nil;
	  NSString* filePath=nil;
	  NSFileManager* fileManager=[NSFileManager defaultManager];
	  dirEnum = [fileManager enumeratorAtPath:_path];
	  while ((filePath = [dirEnum nextObject]))
		{
		  NSDictionary* attributes = [dirEnum fileAttributes];
		  NSString* fileType = [attributes objectForKey:NSFileType];
		  filePath=[_path stringByAppendingFormat:@"/%@",filePath];
		  NSDebugMLLog(@"bundles",@"filePath:%@",filePath);
//		  NSDebugMLLog(@"bundles",@"attributes:%@",attributes);
//		  NSDebugMLLog(@"bundles",@"fileType:%@",fileType);
		  if ([fileType isEqual:NSFileTypeDirectory])
			{
			  BOOL _tmpBundleIsFramework=NO;
			  NSString* _tmpBundleProjectName=nil;
			  GSWDeployedBundle* _tmpBundle=[GSWProjectBundle bundleWithPath:filePath];
			  NSDebugMLLog(@"bundles",@"_tmpBundle:%@",_tmpBundle);
			  _tmpBundleProjectName=[_tmpBundle projectName];
			  NSDebugMLLog(@"bundles",@"_tmpBundleProjectName:%@",_tmpBundleProjectName);
			  _tmpBundleIsFramework=[_tmpBundle isFramework];
			  NSDebugMLLog(@"bundles",@"_tmpBundleIsFramework=%s",(_tmpBundleIsFramework ? "YES" : "NO"));
//Why projectName...
			  if ((isFramework_ && _tmpBundleIsFramework)
				  ||(!isFramework_ && !_tmpBundleIsFramework))
				{
				  NSDebugMLLog(@"bundles",@"adding _tmpBundle:%@",_tmpBundleProjectName);
				  [_projectsBundles addObject:_tmpBundle];
				};
			};
		};
	};
  _projectEnum =[_projectsBundles objectEnumerator];
  while(!_projectBundle && (_aBundle = [_projectEnum nextObject]))
	{
          NSString* suffix1=isFramework_ ? GSFrameworkPSuffix : GSWApplicationPSuffix[GSWebNamingConv];
          NSString* suffix2=isFramework_ ? GSFrameworkPSuffix : GSWApplicationPSuffix[GSWebNamingConvInversed];
          NSDebugMLLog(@"bundles",@"suffix1:%@ suffix2",suffix1,suffix2);
	  NSDebugMLLog(@"bundles",@"_aBundle:%@",_aBundle);

	  if ([[_aBundle bundlePath]hasSuffix:suffix1] 
              || [[_aBundle bundlePath]hasSuffix:suffix2] 
              || [[_aBundle bundlePath]hasSuffix:@".debug"])
		{
		  NSString* _tmpName=[_aBundle projectName];
		  NSDebugMLLog(@"bundles",@"_tmpName:%@",_tmpName);
		  if ([_tmpName isEqual:name_])
			{
			  _projectBundle=_aBundle;
			  NSDebugMLLog(@"bundles",@"_projectBundle:%@",_projectBundle);
			};
		};
	};
  NSDebugMLLog(@"bundles",@"_projectBundle:%@",_projectBundle);
  LOGClassFnStop();
  return _projectBundle;
};

@end
