/** GSWResourceManager.h - <title>GSWeb: Class GSWResourceManager</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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

GSWEB_EXPORT NSDictionary* globalMime;

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

//-(NSString*)frameworkNameForPath:(NSString*)path_;
-(NSString*)pathForResourceNamed:(NSString*)name
                     inFramework:(NSString*)frameworkName
                       languages:(NSArray*)languages;

-(NSString*)urlForResourceNamed:(NSString*)name
                    inFramework:(NSString*)frameworkName
                      languages:(NSArray*)languages
                        request:(GSWRequest*)request;

/*
 * Return value: string from tableName using key to look it up.
 * first searches the tableName.strings file in the locale
 * subdirectories. languages specifies the search order.
 */

-(NSString*)stringForKey:(NSString*)key
            inTableNamed:(NSString*)tableName
        withDefaultValue:(NSString*)defaultValue
             inFramework:(NSString*)frameworkName
               languages:(NSArray*)languages;

-(void)lock;

-(void)unlock;

-(void)flushDataCache;

-(void)setData:(NSData*)data
        forKey:(NSString*)key
      mimeType:(NSString*)type
       session:(GSWSession*)session;

-(void)removeDataForKey:(NSString*)key
                session:(GSWSession*)session;

-(NSString*)pathForResourceNamed:(NSString*)name
                     inFramework:(NSString*)frameworkName
                        language:(NSString*)language;

-(GSWDeployedBundle*)_appProjectBundle;
-(BOOL)_doesRequireJavaVirualMachine;
-(NSString*)_absolutePathForJavaClassPath:(NSString*)path;
-(GSWURLValuedElementData*)_cachedDataForKey:(NSString*)key;
-(NSString*)contentTypeForResourcePath:(NSString*)path;
-(NSArray*)_frameworkClassPaths;

/* Deprecated in WO 4.0. 
 * Use urlForResourceNamed:inFramework:languages:request: instead.
 */

-(NSString*)urlForResourceNamed:(NSString*)name
                    inFramework:(NSString*)frameworkName GS_ATTRIB_DEPRECATED;

/* Deprecated in WO 4.0. 
 * Use pathForResourceNamed:inFramework:languages: instead.
 */

-(NSString*)pathForResourceNamed:(NSString*)name
                     inFramework:(NSString*)frameworkName GS_ATTRIB_DEPRECATED;

+(NSString*)GSLanguageFromISOLanguage:(NSString*)ISOLanguage;		//NDFN
+(NSArray*)GSLanguagesFromISOLanguages:(NSArray*)ISOlanguages;		//NDFN
+(NSString*)ISOLanguageFromGSLanguage:(NSString*)GSLanguage;		//NDFN
+(NSArray*)ISOLanguagesFromGSLanguages:(NSArray*)GSlanguages;		//NDFN

- (NSString*) errorMessageUrlForResourceNamed:(NSString *) resourceName
                                  inFramework:(NSString *) frameworkName;

- (void) _cacheData:(GSWURLValuedElementData *) aData;
- (GSWImageInfo *) _imageInfoForUrl:(NSString *)resourceURL
			   fileName:(NSString *)filename
			  framework:(NSString *)frameworkName
			  languages:(NSArray *)languages;

@end

#endif //_GSWResourceManager_h__
