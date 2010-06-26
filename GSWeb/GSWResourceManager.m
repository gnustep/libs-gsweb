/** GSWResourceManager.m - <title>GSWeb: Class GSWResourceManager</title>

   Copyright (C) 1999-2005 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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
#include <GNUstepBase/NSObject+GNUstepBase.h>
#include <GNUstepBase/NSString+GNUstepBase.h>

static NSString            * NONESTR = @"NONE";
static NSString            * localNotFoundMarker=@"NOTFOUND";
static NSMutableDictionary * TheStringsTableDictionary = nil;
static NSLock              * TheStringsTableLock = nil;
//====================================================================
@implementation GSWResourceManager

GSWProjectBundle* globalAppProjectBundle=nil;
NSDictionary* globalMime=nil;
NSString* globalMimePListPathName=nil;
NSDictionary* localGS2ISOLanguages=nil;
NSDictionary* localISO2GSLanguages=nil;
NSString* globalLanguagesPListPathName=nil;
NSMutableDictionary   *globalPathCache = nil;
//--------------------------------------------------------------------
+(void)initialize
{
  if (self==[GSWResourceManager class])
    {
      NSBundle* mainBundle=nil;
      GSWDeployedBundle* deployedBundle=nil;
      //if ((self=[[super superclass] initialize]))
        {
          NSString* bundlePath=nil;
          mainBundle=[GSWApplication mainBundle];
          bundlePath=[mainBundle  bundlePath];
          deployedBundle=(GSWDeployedBundle*)[GSWDeployedBundle bundleWithPath:bundlePath];
	  
          globalAppProjectBundle=[[deployedBundle projectBundle] retain];
          NSAssert(globalAppProjectBundle,@"no globalAppProjectBundle");
          //call  deployedBundle bundlePath
          //call  globalAppProjectBundle bundlePath
          //call isDebuggingEnabled
        };
    };
};

-(void) _loadMimeTypes
{
  NSBundle* resourceManagerBundle = [NSBundle bundleForClass: [self class]];
  
  globalMimePListPathName=[resourceManagerBundle pathForResource:@"MIME"
                                                          ofType:@"plist"]; 
  
  NSAssert(globalMimePListPathName,@"No resource MIME.plist");
  {
    NSDictionary* tmpMimeTypes=nil;
    NSMutableDictionary* mimeTypes=(NSMutableDictionary*)[NSMutableDictionary dictionary];
    tmpMimeTypes=[NSDictionary  dictionaryWithContentsOfFile:globalMimePListPathName];
    
    if (tmpMimeTypes)
    {
      NSEnumerator* enumerator = [tmpMimeTypes keyEnumerator];
      id key=nil;
      id value=nil;
      while ((key = [enumerator nextObject]))
      {
        value=[tmpMimeTypes objectForKey:key];
        NSAssert(value,@"No value");
        value=[value lowercaseString];
        key=[key lowercaseString];
        NSAssert(key,@"No key");
        [mimeTypes setObject:value
                      forKey:key];
      };
      // NSDebugMLLog(@"resmanager",@"mimeTypes=%@",mimeTypes);
    };
    ASSIGN(globalMime,[NSDictionary dictionaryWithDictionary:mimeTypes]);
  }
}

- (void) _loadLanguages
{
  NSBundle* resourceManagerBundle = [NSBundle bundleForClass: [self class]];
  globalLanguagesPListPathName=[resourceManagerBundle pathForResource:@"languages"
                                                               ofType:@"plist"];
  if (!globalLanguagesPListPathName)
    globalLanguagesPListPathName=[[NSBundle bundleForClass: [self class]]
                                  pathForResource:@"languages"
                                  ofType:@"plist"];
  
  NSAssert(globalLanguagesPListPathName,@"No resource languages.plist");
  {
    NSDictionary* tmpLanguages=nil;
    NSMutableDictionary* ISO2GS=(NSMutableDictionary*)[NSMutableDictionary dictionary];
    NSMutableDictionary* GS2ISO=(NSMutableDictionary*)[NSMutableDictionary dictionary];
    tmpLanguages=[NSDictionary  dictionaryWithContentsOfFile:globalLanguagesPListPathName];
    if (tmpLanguages)
    {
      NSEnumerator* enumerator = [tmpLanguages keyEnumerator];
      id iso=nil;
      id gs=nil;
      while ((iso = [enumerator nextObject]))
      {
        gs=[tmpLanguages objectForKey:iso];
        NSAssert(gs,@"No gs");
        [ISO2GS setObject:gs
                   forKey:[iso lowercaseString]];
        if ([iso length]==2)//No xx-xx
        {
          [GS2ISO setObject:iso
                     forKey:[gs lowercaseString]];
        };
      };
    };
    ASSIGN(localISO2GSLanguages,[NSDictionary dictionaryWithDictionary:ISO2GS]);
    ASSIGN(localGS2ISOLanguages,[NSDictionary dictionaryWithDictionary:GS2ISO]);
  }
}

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
    {
      if (!globalMime) {
        [self _loadMimeTypes];
        [self _loadLanguages];
      }
      if (!globalPathCache) {
        globalPathCache = [NSMutableDictionary new];
      }
      if (!TheStringsTableDictionary) {
        TheStringsTableDictionary = [NSMutableDictionary new];
        TheStringsTableLock = [NSLock new];
      }
      //TODO NSBundle* mainBundle=[NSBundle mainBundle];
      NSArray* allFrameworks=[NSBundle allFrameworks];
      int i=0;
      int allFrameworksCount=[allFrameworks count];
      NSString* bundlePath=nil;
      NSBundle* bundle=nil;
      NSDictionary* infoDictionary=nil;
      for(i=0;i<allFrameworksCount;i++)
        {
          bundle=[allFrameworks objectAtIndex:i];
          bundlePath=[bundle bundlePath];
          //So what ?
        };
      
      _selfLock=[NSRecursiveLock new];
      
      _frameworkProjectBundlesCache=[NSMutableDictionary new];
      _appURLs=[NSMutableDictionary new];
      _frameworkURLs=[NSMutableDictionary new];
      _appPaths=[NSMutableDictionary new];
      _frameworkPaths=[GSWMultiKeyDictionary new];
      _urlValuedElementsData=[NSMutableDictionary new];
      _stringsTablesByFrameworkByLanguageByName=[NSMutableDictionary new];
      _stringsTableArraysByFrameworkByLanguageByName=[NSMutableDictionary new];
//      [self  _initFrameworkProjectBundles];
      //	  _frameworkPathsToFrameworksNames=[NSMutableDictionary new];

      allFrameworks=[NSBundle allFrameworks];
      allFrameworksCount=[allFrameworks count];

      for(i=0;i<allFrameworksCount;i++)
        {
          bundle=[allFrameworks objectAtIndex:i];
          infoDictionary=[bundle infoDictionary];
          //So what ?
          /*
            NSDebugMLLog(@"resmanager",@"****bundlePath=%@",bundlePath);
            NSDebugMLLog(@"resmanager",@"****[bundle bundleName]=%@",[bundle bundleName]);
            bundlePath=[bundle bundlePath];
            if ([bundle bundleName])
            [_frameworkPathsToFrameworksNames setObject:[bundle bundleName]
            forKey:bundlePath];					  
          */
        };
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_frameworkProjectBundlesCache);
  DESTROY(_appURLs);
  DESTROY(_frameworkURLs);
  DESTROY(_appPaths);
  DESTROY(_frameworkPaths);
  DESTROY(_urlValuedElementsData);
  DESTROY(_stringsTablesByFrameworkByLanguageByName);
  DESTROY(_stringsTableArraysByFrameworkByLanguageByName);
  DESTROY(_frameworkClassPaths);
//  DESTROY(_frameworkPathsToFrameworksNames);
  DESTROY(_selfLock);

  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  NSString* dscr=nil;
  [self lock];
  NS_DURING
    {
      dscr=[NSString stringWithFormat:@"<%s %p - _frameworkProjectBundlesCache:%p _appURLs:%@ _frameworkURLs:%@ _appPaths:%@ _frameworkPaths:%@ _urlValuedElementsData:%@ _frameworkClassPaths:%@>",
                     object_getClassName(self),
                     (void*)self,
                     (void*)_frameworkProjectBundlesCache,
                     _appURLs,
                     _frameworkURLs,
                     _appPaths,
                     _frameworkPaths,
                     _urlValuedElementsData,
                     _frameworkClassPaths];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  return dscr;
};

//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)name
                     inFramework:(NSString*)aFrameworkName
                       languages:(NSArray*)languages
{
  NSString * path = nil;
  
  if ((languages) && ([languages count])) {
    NSEnumerator * langEnumer = [languages objectEnumerator];
    NSString     * currentLang;
    
    while (((currentLang = [langEnumer nextObject])) && (!path)) {
      path = [self pathForResourceNamed:name
                            inFramework:aFrameworkName
                               language:currentLang];
      
    }
  } else {
    // no languages
    
    path = [self pathForResourceNamed:name
                          inFramework:aFrameworkName
                             language:nil];
    
  }

  return path;
}

//--------------------------------------------------------------------

- (NSString*) _cleanPath:(NSString*) oldPath frameworkName:(NSString*) frameworkName
{
  // /Library/Frameworks/WOExtensions.framework/Versions/1/Resources/WebServer/back.png
  // ->> /WOExtensions/wr/back.png
  // /Users/dave/dev/gsweb/trunk/Testing/DynamicElements/DynamicElements.gswa/Contents/Resources/WebServer/testpic.jpg
  // ->> /wr/testpic.jpg
  
  NSString * newPath = nil;
    
  NSRange range = [oldPath rangeOfString:@"Resources/WebServer"
                                 options:NSBackwardsSearch];
  
  if ((range.location == NSNotFound)) {
    if (([oldPath hasSuffix:@".wo"] == NO)) {
      return nil;
    }
  } else {
    newPath = [oldPath substringFromIndex: range.location+range.length];
  }

  if (!frameworkName) {
    return newPath;
  }  
  
  return [NSString stringWithFormat:@"/%@/wr%@",frameworkName, newPath];
  
}

/*
 Returns the URL for a resource name.
 The URL returned is of the following form: 
 /WebObjects/MyApp.woa/0/wr/English.lproj/name
 /WebObjects/MyApp.woa/0/wr/testpic.jpg
 /WebObjects/MyApp.woa/0/wr/MyFramework/wr/English.lproj/name

 TODO: test with true dynamic data in URLs
 */

-(NSString*)urlForResourceNamed:(NSString*)name
                    inFramework:(NSString*)aFrameworkName
                      languages:(NSArray*)languages
                        request:(GSWRequest*)request
{
  NSString   * url=nil;
  NSString   * path=nil;
  //GSWContext * context = nil;
  
  if ((languages) && ([languages count])) {
    NSEnumerator * langEnumer = [languages objectEnumerator];
    NSString     * currentLang;
    
    while (((currentLang = [langEnumer nextObject])) && (!path)) {
      path = [self pathForResourceNamed:name
                            inFramework:aFrameworkName
                               language:currentLang];
      
    }
  } else {
    // no languages
    
    path = [self pathForResourceNamed:name
                          inFramework:aFrameworkName
                             language:nil];
    
  }
  
  if (!path) {
    return nil;
  }
  
  path = [self _cleanPath:path frameworkName:aFrameworkName];
  
  //context = [request _context];
  
  url = [NSString stringWithFormat:@"%@%@%@", [request _applicationURLPrefix],
         [[GSWApp class] resourceRequestHandlerKey], 
         path];
  
  return url;
}


static NSDictionary * _cachedStringsTable(GSWResourceManager * resmanager, NSString * tableName, NSString * framework, NSString * lang)
{
  NSDictionary * stringTableDict = nil;

  if (tableName)
  {
    NSString * languageKey = (!lang) ? NONESTR : lang;
    NSString * frameworkNameKey = (!framework) ? NONESTR : framework;
    NSString * tableKey = [NSString stringWithFormat:@"%@_%@_%@", tableName, frameworkNameKey, languageKey];
    
    SYNCHRONIZED(TheStringsTableLock) {
      stringTableDict = [TheStringsTableDictionary objectForKey:tableKey];
    } END_SYNCHRONIZED;
    
    if (!stringTableDict)
    {
      // load from file
      if (tableName)
      {
        NSString * path;
        
        path = [resmanager pathForResourceNamed:[tableName stringByAppendingString:@".strings"]
                                    inFramework:framework
                                       language:lang];
        
        if (path) {
          NSString         * fileString = nil;
          NSStringEncoding   encoding = 0;
          NSError          * error = nil;
          
          fileString = [NSString stringWithContentsOfFile:path 
                                             usedEncoding:&encoding 
                                                    error:&error];
          
          if (error) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
          } else {
            stringTableDict = [fileString propertyListFromStringsFileFormat];
          }
        }        
      }
      if (!stringTableDict)
      {
        stringTableDict = (NSDictionary*) [NSNull null];
      }
      SYNCHRONIZED(TheStringsTableLock) {
        [TheStringsTableDictionary setObject:stringTableDict
                                      forKey:tableKey];
      } END_SYNCHRONIZED;
    }
    // we are using a static object so the == is ok here.
    if ((stringTableDict == (NSDictionary*) [NSNull null]))
    {
      stringTableDict = nil;
    }
  }
  return stringTableDict;
}


static NSString * _cachedStringForKey(GSWResourceManager * resmanager, NSString * key, NSString * tableName, NSString * framework, NSString * lang)
{
  NSDictionary * stringTableDict = _cachedStringsTable(resmanager, tableName, framework, lang);
  NSString     * string = nil;

  if ((stringTableDict) && (key)) 
  {
    string = [stringTableDict objectForKey:key];
  }
  return string;
}

/*
 * Return value: string from tableName using key to look it up.
 * first searches the tableName.strings file in the locale
 * subdirectories. languages specifies the search order.
 */
-(NSString*)stringForKey:(NSString*)key
            inTableNamed:(NSString*)aTableName
        withDefaultValue:(NSString*)defaultValue
             inFramework:(NSString*)framework
               languages:(NSArray*)languages
{
  NSString * string=nil;
  NSString * tableName; 
  
  if (!aTableName) {
    tableName = @"Localizable";
  } else {
    tableName = aTableName;
  }

  if (languages)
  {
    NSUInteger count = [languages count];
    NSUInteger idx;

    for(idx = 0; idx < count; idx++)
    {
      NSString * lang = [languages objectAtIndex:idx];
      string = _cachedStringForKey(self, key, tableName, framework, lang);
      if (string) 
      {
        return string;
      }
    }
    
  }
  string = _cachedStringForKey(self, key, tableName, framework, nil);
  
  if (!string)
    string=defaultValue;
  return string;
}

//--------------------------------------------------------------------
-(void)unlock
{
  LoggedUnlock(_selfLock);
#ifndef NDEBUG
	_selfLockn--;
#endif
};

//--------------------------------------------------------------------
-(void)lock
{
  LoggedLockBeforeDate(_selfLock,GSW_LOCK_LIMIT);
#ifndef NDEBUG
  _selfLockn++;
#endif
};


-(void)flushDataCache
{
  SYNCHRONIZED(self)
  {
    [_urlValuedElementsData removeAllObjects];
  } 
  END_SYNCHRONIZED;
}

-(void)_lockedCacheData:(GSWURLValuedElementData*)aData
{
  NSData* data=nil;
  NSString* key=nil;
  data=[aData data];
  NSAssert(data,@"Data");
  key=[aData key];
  NSAssert(key,@"No key");
  
  if (!_urlValuedElementsData)
    _urlValuedElementsData=[NSMutableDictionary new];
  
  [_urlValuedElementsData setObject:aData
                             forKey:key];
}

//--------------------------------------------------------------------
-(void)setData:(NSData*)aData
        forKey:(NSString*)aKey
      mimeType:(NSString*)aType
       session:(GSWSession*)session_ //unused
{
  GSWURLValuedElementData* dataValue=nil;
  
  dataValue=[[[GSWURLValuedElementData alloc] initWithData:aData
                                                  mimeType:aType
                                                       key:aKey] autorelease];
  if ((dataValue) && ([dataValue data]))
  {
    SYNCHRONIZED(self)
    {
      [self _lockedCacheData:dataValue];
    } 
    END_SYNCHRONIZED;
  }
}

//--------------------------------------------------------------------
-(void)removeDataForKey:(NSString*)aKey
                session:(GSWSession*)session //unused
{
  SYNCHRONIZED(self)
  {
    [_urlValuedElementsData removeObjectForKey:aKey];
  } 
  END_SYNCHRONIZED;
}


/*
 must be used locked.
 returns localNotFoundMarker on negative cache result.
 */
-(NSString*)_cachedPathForResourceNamed:(NSString*)resourceName
                            inFramework:(NSString*)frameworkName
                               language:(NSString*)language
{
  NSString * cachedPath = nil;
  
  NSString * key = [NSString stringWithFormat:@"%@:%@:%@",
                    resourceName,
                    (frameworkName) ? frameworkName : @"APP",
                    (language) ? language : NONESTR];
    
  cachedPath = [globalPathCache objectForKey:key];
    
  return cachedPath;
}

/*
 must be used locked.
 saves localNotFoundMarker into cache if path is nil.
 */
-(void)_cachePath:(NSString*)path 
 forResourceNamed:(NSString*)resourceName
      inFramework:(NSString*)frameworkName
         language:(NSString*)language
{  
  NSString * key = [NSString stringWithFormat:@"%@:%@:%@",
                    resourceName,
                    (frameworkName) ? frameworkName : @"APP",
                    (language) ? language : NONESTR];
  
  if (!path) {
    path = localNotFoundMarker;
  }
  
  [globalPathCache setObject:path
                      forKey:key];
  
}


/*
 Returns the absolute path for the resource resourceName. 
 resourceName must include the extension.
 If the file is in the application, specify nil for the frameworkName argument.
 */
-(NSString*)pathForResourceNamed:(NSString*)resourceName
                     inFramework:(NSString*)frameworkName
                        language:(NSString*)language
{
  NSBundle * bundleToUse = nil;
  NSString * path        = nil;
  
  SYNCHRONIZED(self) 
  {    
    path = [self _cachedPathForResourceNamed:resourceName
                                 inFramework:frameworkName
                                    language:language];
    if (!path) {
      
      if (!frameworkName)
      {
        bundleToUse = [NSBundle mainBundle];
      } else {
        NSEnumerator * bundleEnumer = [[NSBundle allFrameworks] objectEnumerator];
        NSBundle     * currentBundle;
        
        while (((currentBundle = [bundleEnumer nextObject])) && (!bundleToUse))
        {
          if (([[[currentBundle infoDictionary] objectForKey:@"CFBundleExecutable"] 
                isEqualToString:frameworkName]) || 
              ([[[currentBundle infoDictionary] objectForKey:@"NSExecutable"] 
                isEqualToString:frameworkName]))
          {
            
            bundleToUse = currentBundle;
            
          }
        }    
      }
      
      if (!bundleToUse) {
        //        NSLog(@"%s: could not find bundle for resource '%@' inFramework '%@'",
        //              __PRETTY_FUNCTION__, resourceName, frameworkName);
      } else {
        
        NSString  * nameWithoutExtension = [resourceName stringByDeletingPathExtension];
        NSString  * pathExtension = [resourceName pathExtension];
        
        path = [bundleToUse pathForResource:nameWithoutExtension 
                                     ofType:pathExtension
                                inDirectory:nil 
                            forLocalization:language];
        
        if (!path) {
          path = [bundleToUse pathForResource:nameWithoutExtension 
                                       ofType:pathExtension
                                  inDirectory:@"WebServer"
                              forLocalization:language];
        }
        [self _cachePath:path 
        forResourceNamed:resourceName
             inFramework:frameworkName
                language:language];
      }
      
    }
  } 
  END_SYNCHRONIZED;
  
  /*
   NSLog(@"%s resourceName:'%@' language:'%@' frameworkName:'%@' path '%@'", __PRETTY_FUNCTION__, 
   resourceName, language, frameworkName,
   path);
   */
  if ([localNotFoundMarker isEqualToString:path]) {
    return nil;
  }
  
  return path;
}


//--------------------------------------------------------------------
-(GSWDeployedBundle*)_appProjectBundle
{
  return globalAppProjectBundle;
};


-(BOOL)_doesRequireJavaVirualMachine
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(NSString *) _absolutePathForJavaClassPath:(NSString*)path
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
}

//--------------------------------------------------------------------
// used by GSWResourceRequestHandler
-(GSWURLValuedElementData*)_cachedDataForKey:(NSString*)key
{
  //OK
  GSWURLValuedElementData* data=nil;
  [self lock];
  NS_DURING
    {
      data=[_urlValuedElementsData objectForKey:key];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  return data;
};

//--------------------------------------------------------------------

// TODO: find out what the real name for this is.
//- (NSString*) contentTypeForResourceNamed:(NSString*) aName

-(NSString*)contentTypeForResourcePath:(NSString*)path
{
  //OK
  NSString* type=nil;
  NSString* extension=nil;
  extension=[path pathExtension];
  if (extension)
    {
      extension=[extension lowercaseString];
      type=[globalMime objectForKey:extension];
    };
  if (!type)
    type=[NSString stringWithString:@"application/octet-stream"];
  return type;
};


//--------------------------------------------------------------------
// TODO: Check if we really need this
-(NSArray*)_frameworkClassPaths
{
  return _frameworkClassPaths;
};


//--------------------------------------------------------------------
/* Deprecated in WO 4.0. 
 * Use urlForResourceNamed:inFramework:languages:request: instead.
 */
-(NSString*)urlForResourceNamed:(NSString*)resourceName
                    inFramework:(NSString*)aFrameworkName
{
  NSString* url=nil;
  
  url=[self urlForResourceNamed:resourceName
                    inFramework:aFrameworkName
                      languages:nil
                        request:nil];
  
  return url;
}

//--------------------------------------------------------------------
/* Deprecated in WO 4.0. 
 * Use pathForResourceNamed:inFramework:languages: instead.
 */

-(NSString*)pathForResourceNamed:(NSString*)resourceName
                     inFramework:(NSString*)aFrameworkName
{
  NSString* path=nil;
  
  path=[self pathForResourceNamed:resourceName
                      inFramework:aFrameworkName
                         language:nil];
  
  return path;
}

//--------------------------------------------------------------------

/*
 * more specific names like 'ja-jp' have priority over 'ja'
 * that way, de-at could return a different language than 'de'
 * As they have some different words...
 */

+(NSString*)GSLanguageFromISOLanguage:(NSString*)ISOLanguage
{
  NSString * searchStr = [[ISOLanguage stringByTrimmingSpaces] lowercaseString];
  NSString * langName  = nil;
  
  langName = [localISO2GSLanguages objectForKey:searchStr];
  
  if (!langName) {
    // try to get only the prefix of 'ja-jp'
    NSRange  minusRange = [searchStr rangeOfString:@"-"];
    if (minusRange.location != NSNotFound) {
      searchStr = [searchStr substringToIndex:minusRange.location];

      langName = [localISO2GSLanguages objectForKey:searchStr];
    }

  }
  return langName;
}

//--------------------------------------------------------------------
//NDFN
+(NSArray*)GSLanguagesFromISOLanguages:(NSArray*)ISOLanguages
{
  NSArray* GSLanguages=nil;
  if (ISOLanguages)
    {
      NSMutableArray* array=[NSMutableArray array];
      NSString* ISOLanguage=nil;
      NSString* GSLanguage=nil;
      int i=0;
      int ISOLanguagesCount=[ISOLanguages count];

      for(i=0;i<ISOLanguagesCount;i++)
        {
          ISOLanguage=[ISOLanguages objectAtIndex:i];
          GSLanguage=[self GSLanguageFromISOLanguage:ISOLanguage];
          if (GSLanguage)
            [array addObject:GSLanguage];
          else
            {
              NSLog(@"Unknown language: %@\nKnown languages are : %@",ISOLanguage,localISO2GSLanguages);
            };
        };
      GSLanguages=[NSArray arrayWithArray:array];
    }
  return GSLanguages;
};

//--------------------------------------------------------------------
//NDFN
+(NSString*)ISOLanguageFromGSLanguage:(NSString*)GSLanguage
{
  return [localGS2ISOLanguages objectForKey:[[GSLanguage stringByTrimmingSpaces] lowercaseString]];
};

//--------------------------------------------------------------------
//NDFN
+(NSArray*)ISOLanguagesFromGSLanguages:(NSArray*)GSLanguages
{
  NSArray* ISOLanguages=nil;
  if (GSLanguages)
    {
      NSMutableArray* array=[NSMutableArray array];
      NSString* ISOLanguage=nil;
      NSString* GSLanguage=nil;
      int i=0;
      int GSLanguagesCount=[GSLanguages count];

      for(i=0;i<GSLanguagesCount;i++)
        {
          GSLanguage=[GSLanguages objectAtIndex:i];
          ISOLanguage=[self ISOLanguageFromGSLanguage:GSLanguage];
          NSDebugMLog(@"ISOLanguage=%@",ISOLanguage);
          if (ISOLanguage)
            [array addObject:ISOLanguage];
          else
            {
              NSLog(@"Unknown language: %@\nKnown languages are : %@",GSLanguage,localGS2ISOLanguages);
            };
        };
      ISOLanguages=[NSArray arrayWithArray:array];
    }
  return ISOLanguages;
};

// wo
- (NSString *) errorMessageUrlForResourceNamed:(NSString *) resourceName
                                   inFramework:(NSString *) frameworkName
{
  NSString * url = nil;
  if( resourceName == nil)
    {
      resourceName = @"nil";
    }
  if (frameworkName != nil)
    {
      url = [NSString stringWithFormat:@"/ERROR/NOT_FOUND/framework=%@/filename=%@", frameworkName, resourceName];
    }
  else
    {
      NSString * s3 = [GSWApp name];
      url = [NSString stringWithFormat:@"/ERROR/NOT_FOUND/app=%@/filename=%@", s3, resourceName];
    }
  return url;
}

// checkme: locking?? davew
- (void) _cacheData:(GSWURLValuedElementData *) aData
{
  if (aData != nil) 
    {
      [_urlValuedElementsData setObject: aData  
			      forKey: [aData key]];
    }
}

- (GSWImageInfo *) _imageInfoForUrl:(NSString *)resourceURL
                           fileName:(NSString *)filename
                          framework:(NSString *)frameworkName
                          languages:(NSArray *)languages
{
  NSString *path = nil;
  
  path = [self pathForResourceNamed:filename                    
                        inFramework:frameworkName
                          languages:languages];
  
  return [GSWImageInfo imageInfoWithFile: path];
}

@end
