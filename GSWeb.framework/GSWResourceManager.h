/** GSWResourceManager.h - <title>GSWeb: Class GSWResourceManager</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$
   $Id$

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

#ifndef _GSWResourceManager_h__
	#define _GSWResourceManager_h__

extern NSDictionary* globalMime;

//====================================================================
@interface GSWResourceManager : NSObject <NSLocking>
{
@private
  NSMutableDictionary* _frameworkProjectBundlesCache;
  NSMutableDictionary* _appURLs;
  NSMutableDictionary* _frameworkURLs;
  NSMutableDictionary* _appPaths;
  GSWMultiKeyDictionary* _frameworkPaths;
  NSMutableDictionary* _urlValuedElementsData;
  NSMutableDictionary* _stringsTablesByFrameworkByLanguageByName;//NDFN
  NSMutableDictionary* _stringsTableArraysByFrameworkByLanguageByName;//NDFN
//  NSMutableDictionary* _frameworkPathsToFrameworksNames;
  NSArray* _frameworkClassPaths;
  NSRecursiveLock* _selfLock;
#ifndef NDEBUG
  int _selfLockn;
#endif
  BOOL _applicationRequiresJavaVirtualMachine;
};

-(NSString*)description;
-(void)_initFrameworkProjectBundles;

//-(NSString*)frameworkNameForPath:(NSString*)path_;
-(NSString*)pathForResourceNamed:(NSString*)name
                     inFramework:(NSString*)frameworkName
                       languages:(NSArray*)languages;
-(NSString*)urlForResourceNamed:(NSString*)name
                    inFramework:(NSString*)frameworkName
                      languages:(NSArray*)languages
                        request:(GSWRequest*)request;
-(NSString*)stringForKey:(NSString*)key_
            inTableNamed:(NSString*)tableName
        withDefaultValue:(NSString*)defaultValue_
             inFramework:(NSString*)frameworkName
               languages:(NSArray*)languages;

//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)tableName
                      inFramework:(NSString*)frameworkName
                        languages:(NSArray*)languages;

//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)tableName
                      inFramework:(NSString*)frameworkName
                        languages:(NSArray*)languages;

-(void)lock;

-(void)unlock;

-(NSString*)lockedStringForKey:(NSString*)key
                  inTableNamed:(NSString*)tableName
                   inFramework:(NSString*)framework
                     languages:(NSArray*)languages;
//NDFN
-(NSDictionary*)lockedStringsTableNamed:(NSString*)tableName
                            inFramework:(NSString*)framework
                              languages:(NSArray*)languages;

//NDFN
-(NSArray*)lockedStringsTableArrayNamed:(NSString*)tableName
                            inFramework:(NSString*)framework
                              languages:(NSArray*)languages;

-(NSString*)lockedCachedStringForKey:(NSString*)key
                        inTableNamed:(NSString*)tableName
                         inFramework:(NSString*)frameworkName
                            language:(NSString*)language;

-(NSDictionary*)lockedCachedStringsTableWithName:(NSString*)tableName
                                     inFramework:(NSString*)frameworkName
                                        language:(NSString*)language;

//NDFN
-(NSArray*)lockedCachedStringsTableArrayWithName:(NSString*)tableName
                                     inFramework:(NSString*)frameworkName
                                        language:(NSString*)language;

-(NSDictionary*)lockedStringsTableWithName:(NSString*)tableName
                               inFramework:(NSString*)frameworkName
                                  language:(NSString*)language;

//NDFN
-(NSArray*)lockedStringsTableArrayWithName:(NSString*)tableName
                               inFramework:(NSString*)frameworkName
                                  language:(NSString*)language;

-(NSString*)lockedUrlForResourceNamed:(NSString*)name
                          inFramework:(NSString*)frameworkName
                            languages:(NSArray*)languages_
                              request:(GSWRequest*)request;

-(NSString*)lockedCachedURLForResourceNamed:(NSString*)name
                                inFramework:(NSString*)frameworkName
                                  languages:(NSArray*)languages;

-(NSString*)lockedPathForResourceNamed:(NSString*)name
                           inFramework:(NSString*)frameworkName
                             languages:(NSArray*)languages;

/** GSWeb specific
Returns the bundle for framework named aFrameworkName or application 
bundle if none is found
**/
-(GSWDeployedBundle*)cachedBundleForFrameworkNamed:(NSString*)aFrameworkName;

/** Returns the bundle for framework named aFrameworkName or application 
bundle if none is found
**/
-(GSWDeployedBundle*)lockedCachedBundleForFrameworkNamed:(NSString*)name;
@end

//====================================================================
@interface GSWResourceManager (GSWURLValuedElementsDataCaching)

-(void)flushDataCache;

-(void)setURLValuedElementData:(GSWURLValuedElementData*)data;

-(void)setData:(NSData*)data
        forKey:(NSString*)key
      mimeType:(NSString*)type
       session:(GSWSession*)session;

-(void)removeDataForKey:(NSString*)key
                session:(GSWSession*)session;

@end


//====================================================================
@interface GSWResourceManager (GSWResourceManagerA)
-(NSString*)pathForResourceNamed:(NSString*)name
                     inFramework:(NSString*)frameworkName
                        language:(NSString*)language;
-(NSString*)lockedPathForResourceNamed:(NSString*)name
                           inFramework:(NSString*)frameworkName
                              language:(NSString*)language;
-(GSWDeployedBundle*)_appProjectBundle;
-(NSArray*)_allFrameworkProjectBundles;
-(void)lockedRemoveDataForKey:(NSString*)key;
-(BOOL)_doesRequireJavaVirualMachine;
-(NSString*)_absolutePathForJavaClassPath:(NSString*)path;
-(GSWURLValuedElementData*)_cachedDataForKey:(NSString*)key;
-(void)lockedCacheData:(GSWURLValuedElementData*)data;
-(NSString*)contentTypeForResourcePath:(NSString*)path;
-(NSArray*)_frameworkClassPaths;

@end


//====================================================================
@interface GSWResourceManager (GSWResourceManagerOldFn)
-(NSString*)urlForResourceNamed:(NSString*)name
                    inFramework:(NSString*)frameworkName;
-(NSString*)pathForResourceNamed:(NSString*)name
                     inFramework:(NSString*)frameworkName;
@end


//====================================================================
@interface GSWResourceManager (GSWResourceManagerB)
-(void)_validateAPI;
@end

//====================================================================
@interface GSWResourceManager (GSWResourceManagerClassA)
+(NSString*)GSLanguageFromISOLanguage:(NSString*)ISOLanguage;		//NDFN
+(NSArray*)GSLanguagesFromISOLanguages:(NSArray*)ISOlanguages;		//NDFN
+(NSString*)ISOLanguageFromGSLanguage:(NSString*)GSLanguage;		//NDFN
+(NSArray*)ISOLanguagesFromGSLanguages:(NSArray*)GSlanguages;		//NDFN
+(GSWBundle*)_applicationGSWBundle;
@end

#endif //_GSWResourceManager_h__
