/* GSWBundle.h - GSWeb: Class GSWBundle
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

#ifndef _GSWBundle_h__
	#define _GSWBundle_h__


//====================================================================
@interface GSWBundle : NSObject <NSLocking>
{
  NSString* path;
  NSString* baseURL;
  NSString* frameworkName;
  NSMutableDictionary* archiveCache;
  NSMutableDictionary* apiCache;//NDFN
  NSMutableDictionary* encodingCache;
  NSMutableDictionary* pathCache;
  NSMutableDictionary* urlCache;
  NSMutableDictionary* stringsTableCache;
  NSMutableDictionary* stringsTableArrayCache; //NDFN
  NSMutableDictionary* templateCache;
  NSMutableDictionary* classCache;
  NSRecursiveLock* selfLock;
#ifndef NDEBUG
  int selfLockn;
#endif
};

-(NSString*)baseURL;
-(NSString*)path;
-(NSString*)frameworkName;
-(NSString*)description;
-(void)dealloc;
-(id)initWithPath:(NSString*)path_
		  baseURL:(NSString*)baseURL_
 inFrameworkNamed:(NSString*)frameworkName_;
-(id)initWithPath:(NSString*)path_
		  baseURL:(NSString*)baseURL_;
-(void)unlock;
-(void)lock;

@end

@interface GSWBundle (GSWBundleCache)
-(void)clearCache;
-(void)loadCache;
@end

@interface GSWBundle (GSWBundleA)
-(id)lockedResourceNamed:(NSString*)name_
				  ofType:(NSString*)type_
		   withLanguages:(NSArray*)languages_
			  usingCache:(NSMutableDictionary*)cache_
			relativePath:(NSString**)relativePath_
			absolutePath:(NSString**)absolutePath_;
@end


@interface GSWBundle (GSWResourceManagement)
-(void)initializeObject:(id)object_
	   fromArchiveNamed:(NSString*)name_;

-(void)initializeObject:(id)object_
			fromArchive:(NSDictionary*)archive;

-(Class)scriptedClassWithName:(NSString*)name_
			   superclassName:(NSString*)superclassName_;

-(Class)lockedScriptedClassWithName:(NSString*)name_
					  pathName:(NSString*)pathName_
				superclassName:(NSString*)superclassName_;

-(NSString*)lockedScriptedClassPathWithName:(NSString*)name_;

-(Class)compiledClassWithName:(NSString*)name_
			   superclassName:(NSString*)superclassName_;

-(GSWElement*)templateNamed:(NSString*)name_
				 languages:(NSArray*)languages_;

-(GSWElement*)lockedTemplateNamed:(NSString*)name_
					   languages:(NSArray*)languages_;

-(NSString*)stringForKey:(NSString*)key_
			inTableNamed:(NSString*)name_
		withDefaultValue:(NSString*)defaultValue_
			   languages:(NSArray*)languages_;

//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)name_
					withLanguages:(NSArray*)languages_;

//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)name_
					withLanguages:(NSArray*)languages_;

-(NSString*)urlForResourceNamed:(NSString*)name_
						 ofType:(NSString*)type_
					  languages:(NSArray*)languages_
						request:(GSWRequest*)request_;

-(NSString*)pathForResourceNamed:(NSString*)name_
						  ofType:(NSString*)type_
					   languages:(NSArray*)languages_;

-(NSStringEncoding)encodingForResourcesNamed:(NSString*)name_;

-(NSDictionary*)archiveNamed:(NSString*)name_;
-(NSDictionary*)apiNamed:(NSString*)name_;//NDFN

-(NSDictionary*)lockedArchiveNamed:(NSString*)name_;
-(NSDictionary*)lockedApiNamed:(NSString*)name_;//NDFN

@end
 
@interface GSWBundle (GSWBundleC)
-(id)scriptedClassNameFromClassName:(NSString*)name_;
-(id)scriptPathNameFromScriptedClassName:(NSString*)name_;
@end

#endif //_GSWBundle_h__
