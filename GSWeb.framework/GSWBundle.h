/** GSWBundle.h - <title>GSWeb: Class GSWBundle</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Mar 1999
   
   $Revision$
   $Date$

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

#ifndef _GSWBundle_h__
	#define _GSWBundle_h__


//====================================================================
@interface GSWBundle : NSObject <NSLocking>
{
  NSString* _path;
  NSString* _baseURL;
  NSString* _frameworkName;
  NSMutableDictionary* _archiveCache;
  NSMutableDictionary* _apiCache;//NDFN
  NSMutableDictionary* _encodingCache;
  NSMutableDictionary* _pathCache;
  NSMutableDictionary* _urlCache;
  NSMutableDictionary* _stringsTableCache;
  NSMutableDictionary* _stringsTableArrayCache; //NDFN
  NSMutableDictionary* _templateCache;
  NSMutableDictionary* _classCache;
  NSRecursiveLock* _selfLock;
#ifndef NDEBUG
  int _selfLockn;
#endif
};

-(NSString*)baseURL;
-(NSString*)path;
-(NSString*)frameworkName;
-(NSString*)description;
-(void)dealloc;
-(id)initWithPath:(NSString*)aPath
          baseURL:(NSString*)aBaseURL
 inFrameworkNamed:(NSString*)aFrameworkName;
-(id)initWithPath:(NSString*)aPath
          baseURL:(NSString*)aBaseURL;
-(void)unlock;
-(void)lock;

@end

@interface GSWBundle (GSWBundleCache)
-(void)clearCache;
-(void)loadCache;
@end

@interface GSWBundle (GSWBundleA)
-(id)lockedResourceNamed:(NSString*)aName
                  ofType:(NSString*)aType
           withLanguages:(NSArray*)languages
              usingCache:(NSMutableDictionary*)cache
            relativePath:(NSString**)relativePath
            absolutePath:(NSString**)absolutePath;
@end


@interface GSWBundle (GSWResourceManagement)
-(void)initializeObject:(id)anObject
       fromArchiveNamed:(NSString*)aName;

-(void)initializeObject:(id)anObject
            fromArchive:(NSDictionary*)archive;

-(Class)scriptedClassWithName:(NSString*)aName
               superclassName:(NSString*)superclassName;

-(Class)lockedScriptedClassWithName:(NSString*)aName
                           pathName:(NSString*)pathName
                     superclassName:(NSString*)superclassName;

-(NSString*)lockedScriptedClassPathWithName:(NSString*)aName;

-(Class)compiledClassWithName:(NSString*)aName
               superclassName:(NSString*)superclassName;

-(GSWElement*)templateNamed:(NSString*)aName
                  languages:(NSArray*)languages;

-(GSWElement*)lockedTemplateNamed:(NSString*)aName
                        languages:(NSArray*)languages;

-(NSString*)stringForKey:(NSString*)key_
            inTableNamed:(NSString*)aName
        withDefaultValue:(NSString*)defaultValue
               languages:(NSArray*)languages;

//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aName
                    withLanguages:(NSArray*)languages;

//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aName
                    withLanguages:(NSArray*)languages;

-(NSString*)urlForResourceNamed:(NSString*)aName
                         ofType:(NSString*)aType
                      languages:(NSArray*)languages
                        request:(GSWRequest*)aRequest;

-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)aType
                       languages:(NSArray*)languages;

-(NSStringEncoding)encodingForResourcesNamed:(NSString*)aName;

-(NSDictionary*)archiveNamed:(NSString*)aName;
-(NSDictionary*)apiNamed:(NSString*)aName;//NDFN

-(NSDictionary*)lockedArchiveNamed:(NSString*)aName;
-(NSDictionary*)lockedApiNamed:(NSString*)aName;//NDFN

@end

@interface GSWBundle (GSWBundleC)
-(id)scriptedClassNameFromClassName:(NSString*)aName;
-(id)scriptPathNameFromScriptedClassName:(NSString*)aName;
@end

#endif //_GSWBundle_h__
