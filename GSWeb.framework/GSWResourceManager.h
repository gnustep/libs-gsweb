/* GSWResourceManager.h - GSWeb: Class GSWResourceManager
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
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

#ifndef _GSWResourceManager_h__
	#define _GSWResourceManager_h__

extern NSDictionary* globalMime;

//====================================================================
@interface GSWResourceManager : NSObject <NSLocking>
{
@private
  NSMutableDictionary* frameworkProjectBundlesCache;
  NSMutableDictionary* appURLs;
  NSMutableDictionary* frameworkURLs;
  NSMutableDictionary* appPaths;
  GSWMultiKeyDictionary* frameworkPaths;
  NSMutableDictionary* urlValuedElementsData;
  NSMutableDictionary* _stringsTablesByFrameworkByLanguageByName;//NDFN
  NSMutableDictionary* _stringsTableArraysByFrameworkByLanguageByName;//NDFN
//  NSMutableDictionary* frameworkPathsToFrameworksNames;
  NSArray* frameworkClassPaths;
  NSRecursiveLock* selfLock;
#ifndef NDEBUG
  int selfLockn;
#endif
  BOOL applicationRequiresJavaVirtualMachine;
};

-(void)dealloc;
-(id)init;
-(NSString*)description;
-(void)_initFrameworkProjectBundles;

//-(NSString*)frameworkNameForPath:(NSString*)path_;
-(NSString*)pathForResourceNamed:(NSString*)name_
					 inFramework:(NSString*)frameworkName_
					   languages:(NSArray*)languages_;
-(NSString*)urlForResourceNamed:(NSString*)name_
					inFramework:(NSString*)frameworkName_
					  languages:(NSArray*)languages_
						request:(GSWRequest*)request_;
-(NSString*)stringForKey:(NSString*)key_
			inTableNamed:(NSString*)tableName_
		withDefaultValue:(NSString*)defaultValue_
			 inFramework:(NSString*)frameworkName_
			   languages:(NSArray*)languages_;

//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)tableName_
					  inFramework:(NSString*)frameworkName_
						languages:(NSArray*)languages_;

//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)tableName_
					  inFramework:(NSString*)frameworkName_
						languages:(NSArray*)languages_;
   
-(void)lock;

-(void)unlock;

-(NSString*)lockedStringForKey:(NSString*)_key
				  inTableNamed:(NSString*)_tableName
				   inFramework:(NSString*)_framework
					 languages:(NSArray*)languages_;
//NDFN
-(NSDictionary*)lockedStringsTableNamed:(NSString*)_tableName
					   inFramework:(NSString*)_framework
						 languages:(NSArray*)languages_;

//NDFN
-(NSArray*)lockedStringsTableArrayNamed:(NSString*)_tableName
							inFramework:(NSString*)_framework
							  languages:(NSArray*)languages_;

-(NSString*)lockedCachedStringForKey:(NSString*)key_
				   inTableNamed:(NSString*)tableName_
					inFramework:(NSString*)frameworkName_
					   language:(NSString*)language_;

-(NSDictionary*)lockedCachedStringsTableWithName:(NSString*)tableName_
									 inFramework:(NSString*)frameworkName_
										language:(NSString*)language_;

//NDFN
-(NSArray*)lockedCachedStringsTableArrayWithName:(NSString*)tableName_
									 inFramework:(NSString*)frameworkName_
										language:(NSString*)language_;

-(NSDictionary*)lockedStringsTableWithName:(NSString*)tableName_
							   inFramework:(NSString*)frameworkName_
								  language:(NSString*)language_;

//NDFN
-(NSArray*)lockedStringsTableArrayWithName:(NSString*)tableName_
							   inFramework:(NSString*)frameworkName_
								  language:(NSString*)language_;

-(NSString*)lockedUrlForResourceNamed:(NSString*)name_
						  inFramework:(NSString*)frameworkName_
							languages:(NSArray*)languages_
							  request:(GSWRequest*)_request;

-(NSString*)lockedCachedURLForResourceNamed:(NSString*)name_
								inFramework:(NSString*)frameworkName_
								  languages:(NSArray*)languages_;

-(NSString*)lockedPathForResourceNamed:(NSString*)name_
						   inFramework:(NSString*)frameworkName_
							 languages:(NSArray*)languages_;

-(GSWDeployedBundle*)lockedCachedBundleForFrameworkNamed:(NSString*)name_;
@end

//====================================================================
@interface GSWResourceManager (GSWURLValuedElementsDataCaching)

-(void)flushDataCache;

-(void)setURLValuedElementData:(GSWURLValuedElementData*)data_;

-(void)setData:(NSData*)data_
		forKey:(NSString*)key_
	  mimeType:(NSString*)type_
	   session:(GSWSession*)session_;

-(void)removeDataForKey:(NSString*)key_
				session:(GSWSession*)session_;

@end


//====================================================================
@interface GSWResourceManager (GSWResourceManagerA)
-(NSString*)pathForResourceNamed:(NSString*)name_
					 inFramework:(NSString*)frameworkName_
						language:(NSString*)language_;
-(NSString*)lockedPathForResourceNamed:(NSString*)name_
						   inFramework:(NSString*)frameworkName_
							  language:(NSString*)language_;
-(GSWDeployedBundle*)_appProjectBundle;
-(NSArray*)_allFrameworkProjectBundles;
-(void)lockedRemoveDataForKey:(NSString*)key_;
-(BOOL)_doesRequireJavaVirualMachine;
-(NSString*)_absolutePathForJavaClassPath:(NSString*)path_;
-(GSWURLValuedElementData*)_cachedDataForKey:(NSString*)key_;
-(void)lockedCacheData:(GSWURLValuedElementData*)data_;
-(NSString*)contentTypeForResourcePath:(NSString*)path_;
-(NSArray*)_frameworkClassPaths;

@end


//====================================================================
@interface GSWResourceManager (GSWResourceManagerOldFn)
-(NSString*)urlForResourceNamed:(NSString*)name_
					inFramework:(NSString*)frameworkName_;
-(NSString*)pathForResourceNamed:(NSString*)name_
					 inFramework:(NSString*)frameworkName_;
@end


//====================================================================
@interface GSWResourceManager (GSWResourceManagerB)
-(void)_validateAPI;
@end

//====================================================================
@interface GSWResourceManager (GSWResourceManagerClassA)
+(NSString*)GSLanguageFromISOLanguage:(NSString*)ISOLanguage_;		//NDFN
+(NSArray*)GSLanguagesFromISOLanguages:(NSArray*)ISOLanguages_;		//NDFN
+(NSString*)ISOLanguageFromGSLanguage:(NSString*)GSLanguage_;		//NDFN
+(NSArray*)ISOLanguagesFromGSLanguages:(NSArray*)GSLanguages_;		//NDFN
+(GSWBundle*)_applicationGSWBundle;
@end

#endif //_GSWResourceManager_h__
