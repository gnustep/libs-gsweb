/* GSWProjectBundle.h - GSWeb: Class GSWProjectBundle
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

#ifndef _GSWProjectBundle_h__
	#define _GSWProjectBundle_h__


//====================================================================
@interface GSWProjectBundle : GSWDeployedBundle
{
  NSString* projectName;
  NSDictionary* subprojects;
  NSDictionary* pbProjectDictionary;
};

-(id)initWithPath:(NSString*)path_;
-(void)dealloc;
-(NSString*)description;
-(NSArray*)lockedPathsForResourcesOfType:(id)type_;
-(NSArray*)lockedPathsForResourcesInSubprojectsOfType:(id)type_;
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)name_
								   forLanguage:(NSString*)language_;
-(NSString*)lockedRelativePathForResourceNamed:(NSString*)name_
								  forLanguages:(NSArray*)languages_;
-(NSDictionary*)subprojects;
-(BOOL)isFramework;
-(GSWDeployedBundle*)projectBundle;
-(NSString*)projectPath;
-(NSString*)projectName;
-(NSDictionary*)_pbProjectDictionary;
@end


@interface GSWProjectBundle (GSWProjectBundle)
+(GSWDeployedBundle*)projectBundleForProjectNamed:(NSString*)name_
									 isFramework:(BOOL)isFramework_;
@end


#endif //_GSWProjectBundle_h__
