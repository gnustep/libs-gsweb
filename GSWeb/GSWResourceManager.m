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

static NSString * emptyStr=@"";

//====================================================================
@implementation GSWResourceManager

GSWBundle* globalAppGSWBundle=nil;
GSWProjectBundle* globalAppProjectBundle=nil;
NSDictionary* globalMime=nil;
NSString* globalMimePListPathName=nil;
NSDictionary* localGS2ISOLanguages=nil;
NSDictionary* localISO2GSLanguages=nil;
NSString* globalLanguagesPListPathName=nil;
NSString* localNotFoundMarker=@"NOTFOUND";
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

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
    {
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
      [self  _initFrameworkProjectBundles];
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
-(void)_initFrameworkProjectBundles
{
  //OK
  NSArray* allFrameworks=nil;
  int i=0;
  int allFrameworksCount=0;
  NSBundle* bundle=nil;
  NSString* frameworkName=nil;

  allFrameworks=[NSBundle allFrameworks];

  allFrameworksCount=[allFrameworks count];

  for(i=0;i<allFrameworksCount;i++)
    {
      bundle=[allFrameworks objectAtIndex:i];
      frameworkName=[bundle bundleName];
      [self lockedCachedBundleForFrameworkNamed:frameworkName];
    };
};
/*
//--------------------------------------------------------------------
-(NSString*)frameworkNameForPath:(NSString*)aPath
{
  NSString* _name=nil;
  NSDebugMLLog(@"resmanager",@"aPath=%@",aPath);
  [self lock];
  NS_DURING
	{
	  NSDebugMLLog(@"resmanager",@"_frameworkPathsToFrameworksNames=%@",_frameworkPathsToFrameworksNames);
	  _name=[_frameworkPathsToFrameworksNames objectForKey:aPath];	  
	  NSDebugMLLog(@"resmanager",@"_name=%@",_name);
	  if (!_name)
		{
		  NSArray* allFrameworks=[NSBundle allFrameworks];
		  NSString* bundlePath=nil;
		  NSBundle* bundle=nil;
		  int i=0;
		  for(i=0;i<[allFrameworks count];i++)
			{
			  bundle=[allFrameworks objectAtIndex:i];
			  bundlePath=[bundle bundlePath];
			  if (![_frameworkPathsToFrameworksNames objectForKey:bundlePath])
				{
				  NSDebugMLLog(@"resmanager",@"****bundlePath=%@",bundlePath);
				  NSDebugMLLog(@"resmanager",@"****[bundle bundleName]=%@",[bundle bundleName]);
				  if ([bundle bundleName])
					[_frameworkPathsToFrameworksNames setObject:[bundle bundleName]
													 forKey:bundlePath];				  
				  else
					{
					  NSDebugMLLog(@"resmanager",@"no name for bundle %@",bundle);
					};
				};
			};
		  NSDebugMLLog(@"resmanager",@"_frameworkPathsToFrameworksNames=%@",_frameworkPathsToFrameworksNames);
		  _name=[_frameworkPathsToFrameworksNames objectForKey:aPath];	  
		  NSDebugMLLog(@"resmanager",@"_name=%@",_name);
		};
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	}
  NS_ENDHANDLER;
  [self unlock];
  return _name;
  
};
*/
//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)resourceName
                     inFramework:(NSString*)aFrameworkName
                       languages:(NSArray*)languages
{
  //OK
  NSString* path=nil;
  [self lock];
  NS_DURING
    {
      path=[self lockedPathForResourceNamed:resourceName
                 inFramework:aFrameworkName
                 languages:languages];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  return path;
};

//--------------------------------------------------------------------
-(NSString*)urlForResourceNamed:(NSString*)name
                    inFramework:(NSString*)aFrameworkName
                      languages:(NSArray*)languages
                        request:(GSWRequest*)request
{
  //OK
  NSString* url=nil;

  [self lock];
  NS_DURING
    {
      url=[self lockedUrlForResourceNamed:name
                inFramework:aFrameworkName
                languages:languages
                request:request];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  return url;
};

//--------------------------------------------------------------------
-(NSString*)stringForKey:(NSString*)key
            inTableNamed:(NSString*)tableName
        withDefaultValue:(NSString*)defaultValue
             inFramework:(NSString*)framework
               languages:(NSArray*)languages
{
  NSString* string=nil;
  [self lock];
  NS_DURING
    {
      string=[self lockedStringForKey:key
                   inTableNamed:tableName
                   inFramework:framework
                   languages:languages];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  if (!string)
    string=defaultValue;
  return string;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)tableName
                      inFramework:(NSString*)aFrameworkName
                        languages:(NSArray*)languages
                    foundLanguage:(NSString**)foundLanguagePtr
{
  NSDictionary* stringsTable=nil;
  [self lock];
  NS_DURING
    {
      stringsTable=[self lockedStringsTableNamed:tableName
                         inFramework:aFrameworkName
                         languages:languages
                         foundLanguage:foundLanguagePtr];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  return stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)tableName
                      inFramework:(NSString*)aFrameworkName
                        languages:(NSArray*)languages;
{
  return [self stringsTableNamed:tableName
               inFramework:aFrameworkName
               languages:languages
               foundLanguage:NULL];
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)tableName
                      inFramework:(NSString*)aFrameworkName
                        languages:(NSArray*)languages
{
  NSArray* stringsTableArray=nil;

  [self lock];
  NS_DURING
    {
      stringsTableArray=[self lockedStringsTableArrayNamed:tableName
                              inFramework:aFrameworkName
                              languages:languages];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  return stringsTableArray;
};

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

//--------------------------------------------------------------------
-(NSString*)lockedStringForKey:(NSString*)aKey
                  inTableNamed:(NSString*)aTableName
                   inFramework:(NSString*)aFrameworkName
                     languages:(NSArray*)languages
                 foundLanguage:(NSString**)foundLanguagePtr
{
  //OK
  NSString* string=nil;
  NSString* language=nil;
  int i=0;
  int count=0;
  int iFramework=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  int frameworksCount=0;


  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:emptyStr];
    }
  count=[languages count];
  frameworksCount=[frameworks count];

  for(i=0;!string && i<=count;i++)
    {
      if (i<count)
        language=[languages objectAtIndex:i];
      else
        language=nil;
      for(iFramework=0;!string && iFramework<frameworksCount;iFramework++)
        {
          frameworkName=[frameworks objectAtIndex:iFramework];
          if ([frameworkName length]==0)
            frameworkName=nil;
          string=[self lockedCachedStringForKey:aKey
                       inTableNamed:aTableName
                       inFramework:frameworkName
                       language:language];
          if (string && foundLanguagePtr)
            *foundLanguagePtr=language;
        };
    };


  return string;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)lockedStringsTableNamed:(NSString*)aTableName
                            inFramework:(NSString*)aFrameworkName
                              languages:(NSArray*)languages
                          foundLanguage:(NSString**)foundLanguagePtr
{
  //OK
  NSDictionary* stringsTable=nil;
  NSString* language=nil;
  int i=0;
  int count=0;
  int iFramework=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  int frameworksCount=0;


  count=[languages count];
  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:emptyStr];
    }
  else
    frameworks = [NSArray arrayWithObject:aFrameworkName ? aFrameworkName : emptyStr];

  frameworksCount=[frameworks count];

  for(i=0;!stringsTable && i<count;i++)
    {
      language=[languages objectAtIndex:i];
      for(iFramework=0;!stringsTable && iFramework<frameworksCount;iFramework++)
        {
          frameworkName=[frameworks objectAtIndex:iFramework];
          if ([frameworkName length]==0)
            frameworkName=nil;
          stringsTable=[self lockedCachedStringsTableWithName:aTableName
                             inFramework:frameworkName
                             language:language];
          if (stringsTable && foundLanguagePtr)
            *foundLanguagePtr=language;
        };
    };

  return stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)lockedStringForKey:(NSString*)aKey
                  inTableNamed:(NSString*)aTableName
                   inFramework:(NSString*)aFrameworkName
                     languages:(NSArray*)languages
{
  return [self lockedStringForKey:aKey
               inTableNamed:aTableName
               inFramework:aFrameworkName
               languages:languages
               foundLanguage:NULL];
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)lockedStringsTableNamed:(NSString*)aTableName
                            inFramework:(NSString*)aFrameworkName
                              languages:(NSArray*)languages
{
  return [self lockedStringsTableNamed:aTableName
               inFramework:aFrameworkName
               languages:languages
               foundLanguage:NULL];
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)lockedStringsTableArrayNamed:(NSString*)aTableName
                            inFramework:(NSString*)aFrameworkName
                              languages:(NSArray*)languages
                          foundLanguage:(NSString**)foundLanguagePtr
{
  //OK
  NSArray* stringsTableArray=nil;
  NSString* language=nil;
  int i=0;
  int count=0;
  int iFramework=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  int frameworksCount=0;


  count=[languages count];

  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:emptyStr];
    }
  else
    frameworks=[NSArray arrayWithObject:aFrameworkName ? aFrameworkName : emptyStr];

  frameworksCount=[frameworks count];

  for(i=0;!stringsTableArray && i<count;i++)
    {
      language=[languages objectAtIndex:i];
      for(iFramework=0;!stringsTableArray && iFramework<frameworksCount;iFramework++)
        {
          frameworkName=[frameworks objectAtIndex:iFramework];
          if ([frameworkName length]==0)
            frameworkName=nil;
          stringsTableArray=[self lockedCachedStringsTableArrayWithName:aTableName
                                  inFramework:frameworkName
                                  language:language];
          if (stringsTableArray && foundLanguagePtr)
            *foundLanguagePtr=language;
        };
    };
  return stringsTableArray;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)lockedStringsTableArrayNamed:(NSString*)aTableName
                            inFramework:(NSString*)aFrameworkName
                              languages:(NSArray*)languages
{
  return [self lockedStringsTableArrayNamed:aTableName
               inFramework:aFrameworkName
               languages:languages
               foundLanguage:NULL];
};

//--------------------------------------------------------------------
-(NSString*)lockedCachedStringForKey:(NSString*)aKey
                        inTableNamed:(NSString*)aTableName 
                         inFramework:(NSString*)aFrameworkName
                            language:(NSString*)aLanguage
{
  //OK
  NSString* string=nil;
  NSDictionary* stringsTable=nil;
  stringsTable=[self lockedCachedStringsTableWithName:aTableName
					  inFramework:aFrameworkName
					  language:aLanguage];
  if (stringsTable)
	string=[stringsTable objectForKey:aKey];
  return string;
};

//--------------------------------------------------------------------
-(NSDictionary*)lockedCachedStringsTableWithName:(NSString*)aTableName 
                                     inFramework:(NSString*)aFrameworkName
                                        language:(NSString*)aLanguage
{
  NSDictionary* stringsTable=nil;
  NSDictionary* stringsTablesForFramework=nil;
  NSDictionary* stringsTablesForFrameworkAndLanguage=nil;

  stringsTablesForFramework=[_stringsTablesByFrameworkByLanguageByName 
                              objectForKey:aFrameworkName];
  stringsTablesForFrameworkAndLanguage=[stringsTablesForFramework
                                         objectForKey:aLanguage];
  stringsTable=[stringsTablesForFrameworkAndLanguage 
                 objectForKey:aTableName];

  if (!stringsTable)
    stringsTable=[self  lockedStringsTableWithName:aTableName 
                         inFramework:aFrameworkName
                         language:aLanguage];
  else if ((id)stringsTable==(id)localNotFoundMarker)
    stringsTable=nil;

  return stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)lockedCachedStringsTableArrayWithName:(NSString*)aTableName 
                                     inFramework:(NSString*)aFrameworkName
                                        language:(NSString*)aLanguage
{
  NSArray* stringsTableArray=nil;
  NSDictionary* stringsTableArraysForFramework=nil;
  NSDictionary* stringsTableArraysForFrameworkAndLanguage=nil;

  stringsTableArraysForFramework=
    [_stringsTableArraysByFrameworkByLanguageByName 
      objectForKey:aFrameworkName];

  stringsTableArraysForFrameworkAndLanguage=
    [stringsTableArraysForFramework objectForKey:aLanguage];

  stringsTableArray=[stringsTableArraysForFrameworkAndLanguage
                      objectForKey:aTableName];

  if (!stringsTableArray)
    stringsTableArray=[self  lockedStringsTableArrayWithName:aTableName 
                              inFramework:aFrameworkName
                              language:aLanguage];
  else if ((id)stringsTableArray==(id)localNotFoundMarker)
    stringsTableArray=nil;
  return stringsTableArray;
};

//--------------------------------------------------------------------
-(NSDictionary*)lockedStringsTableWithName:(NSString*)aTableName 
                               inFramework:(NSString*)aFrameworkName
                                  language:(NSString*)aLanguage
{
  //OK
  NSDictionary* stringsTable=nil;
  NSString* relativePath=nil;
  NSString* path=nil;
  GSWDeployedBundle* bundle=nil;
  NSString* resourceName=nil;
  int i=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  int frameworksCount=0;

  resourceName=[aTableName stringByAppendingString:GSWStringTablePSuffix];
  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:emptyStr];
    }
  else
    frameworks=[NSArray arrayWithObject:aFrameworkName ? aFrameworkName : emptyStr];

  frameworksCount=[frameworks count];

  for(i=0;!path && i<frameworksCount;i++)
    {
      frameworkName=[frameworks objectAtIndex:i];
      if ([frameworkName length]==0)
        frameworkName=nil;
      if (frameworkName)
        {
          bundle=[self lockedCachedBundleForFrameworkNamed:frameworkName];
          if (bundle)
            {
              relativePath=[bundle relativePathForResourceNamed:resourceName
                                   language:aLanguage];
              if (relativePath)
                {
                  path=[[bundle bundlePath] stringByAppendingPathComponent:relativePath];
                };
            };
        }
      else
        {
          relativePath=[globalAppProjectBundle relativePathForResourceNamed:resourceName
                                               language:aLanguage];
          if (relativePath)
            {
              NSString* applicationPath=[GSWApp path];
              path=[applicationPath stringByAppendingPathComponent:relativePath];
            };
        };
    };
  if (path)
    {
      //TODO use encoding ??
      NSString* stringsTableContent = [NSString stringWithContentsOfFile:path];
      NS_DURING
        {
          stringsTable = [stringsTableContent propertyListFromStringsFileFormat]; 
        }
      NS_HANDLER
        {
          stringsTable = nil;
        }
      NS_ENDHANDLER
    };
  {
    NSMutableDictionary* frameworkDict=[_stringsTablesByFrameworkByLanguageByName objectForKey:aFrameworkName];
    NSMutableDictionary* languageDict=nil;
    if (!frameworkDict)
      {
        frameworkDict=(NSMutableDictionary*)[NSMutableDictionary dictionary];
        if (!aFrameworkName)
          aFrameworkName=emptyStr;//Global
        [_stringsTablesByFrameworkByLanguageByName setObject:frameworkDict
                                                   forKey:aFrameworkName];
      };
    languageDict=[frameworkDict objectForKey:aLanguage];
    if (!languageDict)
      {
        languageDict=(NSMutableDictionary*)[NSMutableDictionary dictionary];
        if (!aLanguage)
          aLanguage=emptyStr;
        [frameworkDict setObject:languageDict
                       forKey:aLanguage];
      };
    NSAssert(aTableName,@"No tableName");
    if (stringsTable)
      [languageDict setObject:stringsTable
                    forKey:aTableName];
    else
      [languageDict setObject:localNotFoundMarker
                    forKey:aTableName];
  }
  return stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)lockedStringsTableArrayWithName:(NSString*)aTableName 
                               inFramework:(NSString*)aFrameworkName
                                  language:(NSString*)aLanguage
{
  //OK
  NSArray* stringsTableArray=nil;
  NSString* relativePath=nil;
  NSString* path=nil;
  GSWDeployedBundle* bundle=nil;
  NSString* resourceName=nil;
  int i=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  int frameworksCount=0;

  resourceName=[aTableName stringByAppendingString:GSWStringTableArrayPSuffix];
  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:emptyStr];
    }
  else
    frameworks=[NSArray arrayWithObject:aFrameworkName ? aFrameworkName : emptyStr];

  frameworksCount=[frameworks count];
  
  for(i=0;!path && i<frameworksCount;i++)
    {
      frameworkName=[frameworks objectAtIndex:i];
      if ([frameworkName length]==0)
        frameworkName=nil;
      
      if (frameworkName)
        {
          bundle=[self lockedCachedBundleForFrameworkNamed:frameworkName];
          if (bundle)
            {
              relativePath=[bundle relativePathForResourceNamed:resourceName
                                   language:aLanguage];
              if (relativePath)
                {
                  path=[[bundle bundlePath] stringByAppendingPathComponent:relativePath];
                };
            };
        }
      else
        {
          relativePath=[globalAppProjectBundle relativePathForResourceNamed:resourceName
                                               language:aLanguage];
          if (relativePath)
            {
              NSString* applicationPath=[GSWApp path];
              path=[applicationPath stringByAppendingPathComponent:relativePath];
            };
        };
    };
  if (path)
    {
      //TODO use encoding ??
      stringsTableArray=[NSArray arrayWithContentsOfFile:path];
      if (!stringsTableArray)
        {
//          LOGSeriousError(@"Bad stringTableArray \n%@\n from file %@",
//                          [NSString stringWithContentsOfFile:path],
//                          path);
        };
    };
  {
    NSMutableDictionary* frameworkDict=[_stringsTableArraysByFrameworkByLanguageByName objectForKey:aFrameworkName];
    NSMutableDictionary* languageDict=nil;
    if (!frameworkDict)
      {
        frameworkDict=(NSMutableDictionary*)[NSMutableDictionary dictionary];
        if (!aFrameworkName)
          aFrameworkName=emptyStr;//Global
        [_stringsTableArraysByFrameworkByLanguageByName setObject:frameworkDict
                                                        forKey:aFrameworkName];
      };
    languageDict=[frameworkDict objectForKey:aLanguage];
    if (!languageDict)
      {
        languageDict=(NSMutableDictionary*)[NSMutableDictionary dictionary];
        if (!aLanguage)
          aLanguage=emptyStr;
        [frameworkDict setObject:languageDict
                       forKey:aLanguage];
      };
    NSAssert(aTableName,@"No tableName");
    if (stringsTableArray)
      [languageDict setObject:stringsTableArray
                    forKey:aTableName];
    else
      [languageDict setObject:localNotFoundMarker
                    forKey:aTableName];
  }
  return stringsTableArray;
};

//--------------------------------------------------------------------
-(NSString*)lockedUrlForResourceNamed:(NSString*)resourceName
                          inFramework:(NSString*)aFrameworkName
                            languages:(NSArray*)languages
                              request:(GSWRequest*)request
{
  //OK	TODOV
  NSString* url=nil;
  BOOL isUsingWebServer=NO;

  isUsingWebServer=!request || [request _isUsingWebServer];

  if (isUsingWebServer)
    {
      url=[self lockedCachedURLForResourceNamed:resourceName
                inFramework:aFrameworkName
                languages:languages];
    }
  else
    {
      NSString* path=[self pathForResourceNamed:resourceName
                           inFramework:aFrameworkName
                           languages:languages];
      if (path)
        {
          GSWURLValuedElementData* cachedData=[self _cachedDataForKey:path];
          if (!cachedData)
            {
              NSString* type=[self contentTypeForResourcePath:url];
              [self setData:nil
                    forKey:path
                    mimeType:type
                    session:nil];
            };
        }
      else
        path=[NSString stringWithFormat:@"ERROR_NOT_FOUND_framework_*%@*_filename_%@",
                       aFrameworkName,
                       resourceName];
      url=(NSString*)[request _urlWithRequestHandlerKey:GSWResourceRequestHandlerKey[GSWebNamingConv]
                              path:nil
                              queryString:[NSString stringWithFormat:
                                                      @"%@=%@",
                                                    GSWKey_Data[GSWebNamingConv],
                                                    path]];//TODO Escape
    };

  return url;
};

//--------------------------------------------------------------------
-(NSString*)lockedCachedURLForResourceNamed:(NSString*)resourceName
                                inFramework:(NSString*)aFrameworkName
                                  languages:(NSArray*)languages
{
  //OK
  NSString* url=nil;
  int i=0;
  NSArray* frameworks=nil;
  int frameworksCount=0;


  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:emptyStr];
    }
  else
    frameworks=[NSArray arrayWithObject:aFrameworkName ? aFrameworkName : emptyStr];
  
  frameworksCount=[frameworks count];

  for(i=0;!url && i<frameworksCount;i++)
    {
      GSWDeployedBundle* bundle=nil;
      NSString* frameworkName=[frameworks objectAtIndex:i];
      if ([frameworkName length]==0)
        frameworkName=nil;
      if (frameworkName)
        bundle=[self lockedCachedBundleForFrameworkNamed:frameworkName];
      else
        bundle=globalAppProjectBundle;
      if (bundle)
        url=[bundle urlForResourceNamed:resourceName
                    languages:languages];
    };
  if (!url)
    {
      NSLog(@"No URL for resource named: %@ in framework named: %@ for languages: %@",
                      resourceName,
                      aFrameworkName,
                      languages);
    };

  return url;
};

//--------------------------------------------------------------------
-(NSString*)lockedPathForResourceNamed:(NSString*)resourceName
                           inFramework:(NSString*)aFrameworkName
                             languages:(NSArray*)languages
{ 
  NSString* path=nil;
  int i=0;
  NSArray* frameworks=nil;
  int frameworksCount=0;

  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:emptyStr];
    }
  else
    frameworks=[NSArray arrayWithObject:aFrameworkName ? aFrameworkName : emptyStr];

  frameworksCount=[frameworks count];

  for(i=0;!path && i<frameworksCount;i++)
    {
      GSWDeployedBundle* bundle=nil;
      NSString* frameworkName=[frameworks objectAtIndex:i];
      if ([frameworkName length]==0)
        frameworkName=nil;
      if (frameworkName)
        bundle=[self lockedCachedBundleForFrameworkNamed:frameworkName];
      else
        bundle=globalAppProjectBundle;
      path=[bundle absolutePathForResourceNamed:resourceName
                   languages:languages];
    };

  return path;
};


//--------------------------------------------------------------------
/** GSWeb specific
Returns the bundle for framework named aFrameworkName or application 
bundle if none is found
**/
-(GSWDeployedBundle*)cachedBundleForFrameworkNamed:(NSString*)aFrameworkName
{
  GSWDeployedBundle* bundle=nil;
  [self lock];
  NS_DURING
    {
      bundle=[self lockedCachedBundleForFrameworkNamed:aFrameworkName];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  return bundle;
};

//--------------------------------------------------------------------
/**
Returns the bundle for framework named aFrameworkName or application 
bundle if none is found
**/
-(GSWDeployedBundle*)lockedCachedBundleForFrameworkNamed:(NSString*)resourceName
{
  //OK
  GSWDeployedBundle* bundle=nil;

  NSAssert(resourceName,@"No name");
  if (resourceName==GSWFramework_app
      || [resourceName isEqualToString:GSWFramework_app])
    {
      resourceName=[globalAppProjectBundle projectName];
      bundle=globalAppProjectBundle;
    }
  else
    bundle=[_frameworkProjectBundlesCache objectForKey:resourceName];
  if (!bundle)
    {
      NSMutableArray* allFrameworks=AUTORELEASE([[NSBundle allFrameworks] mutableCopy]);
      int i=0;
      int frameworksCount=[allFrameworks count];
      NSString* bundlePath=nil;
      NSBundle* tmpBundle=nil;
      NSString* frameworkName=nil;
      
      [allFrameworks addObjectsFromArray:[NSBundle allBundles]];
      
      for(i=0;!bundle && i<frameworksCount;i++)
        {
          tmpBundle=[allFrameworks objectAtIndex:i];
          //TODO: use bundleName ?
          bundlePath=[tmpBundle bundlePath];
          frameworkName=[bundlePath lastPathComponent];
          frameworkName=[frameworkName stringByDeletingPathExtension];
          if ([frameworkName isEqualToString:resourceName])
            {
              bundle=(GSWDeployedBundle*)[GSWDeployedBundle bundleWithPath:bundlePath];
              NSDebugMLLog(@"resmanager",@"bundle=%@",bundle);
              /*projectBundle=[GSWProjectBundle projectBundleForProjectNamed:resourceName
                isFramework:YES];
                NSDebugMLLog(@"resmanager",@"projectBundle=%@",projectBundle);
                if (projectBundle)
                {
                //TODO
                };
              */
            };
        };
      if (!bundle)
        bundle=globalAppProjectBundle;
      NSAssert(bundle,@"No bundle");
      [_frameworkProjectBundlesCache setObject:bundle
                                     forKey:resourceName];
    };

  return bundle;
};


//--------------------------------------------------------------------
-(void)flushDataCache
{
  [self lock];
  NS_DURING
    {
      [_urlValuedElementsData removeAllObjects];
    }
  NS_HANDLER
    {
	  //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
};

//--------------------------------------------------------------------
-(void)setURLValuedElementData:(GSWURLValuedElementData*)aData
{
  if ([aData data])
    {
      [self lock];

      NS_DURING
	{
	  [self lockedCacheData:aData];
	}
      NS_HANDLER
	{
	  //TODO
	  [self unlock];
	  [localException raise];
	}
      NS_ENDHANDLER
      [self unlock];
    }
};

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
  [self setURLValuedElementData:dataValue];
};

//--------------------------------------------------------------------
-(void)removeDataForKey:(NSString*)aKey
                session:(GSWSession*)session //unused
{
  [self lock];
  NS_DURING
    {
      [self lockedRemoveDataForKey:aKey];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
};


//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)resourceName
                     inFramework:(NSString*)aFrameworkName
                        language:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;
  [self lock];
  NS_DURING
    {
      path=[self lockedPathForResourceNamed:resourceName
                 inFramework:aFrameworkName
                 language:aLanguage];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedPathForResourceNamed:(NSString*)resourceName
                           inFramework:(NSString*)aFrameworkName
                              language:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;
  NSString* relativePath=nil;
  GSWDeployedBundle* bundle=nil;
  int i=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  int frameworksCount=0;


  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:emptyStr];
    }
  else
    frameworks=[NSArray arrayWithObject:aFrameworkName ? aFrameworkName : emptyStr];

  frameworksCount=[frameworks count];

  for(i=0;!path && i<frameworksCount;i++)
    {
      frameworkName=[frameworks objectAtIndex:i];
      if ([frameworkName length]==0)
        frameworkName=nil;
      
      if (frameworkName)
        {
          bundle=[self lockedCachedBundleForFrameworkNamed:frameworkName];
          if (bundle)
            {
              relativePath=[bundle relativePathForResourceNamed:resourceName
                                   language:aLanguage];
              if (relativePath)
                {
                  path=[[bundle bundlePath] stringByAppendingPathComponent:relativePath];
                };
            };
        }
      else
        {
          relativePath=[globalAppProjectBundle relativePathForResourceNamed:resourceName
                                               language:aLanguage];
          if (relativePath)
            {
              NSString* applicationPath=[GSWApp path];
              path=[applicationPath stringByAppendingPathComponent:relativePath];
            };
        };
    };

  return path;
};

//--------------------------------------------------------------------
-(GSWDeployedBundle*)_appProjectBundle
{
  return globalAppProjectBundle;
};

//--------------------------------------------------------------------
-(NSArray*)_allFrameworkProjectBundles
{
  //OK
  NSArray* array=nil;
  array=[_frameworkProjectBundlesCache allValues];
  return array;
};

//--------------------------------------------------------------------
-(void)lockedRemoveDataForKey:(NSString*)key
{
  [_urlValuedElementsData removeObjectForKey:key];
};

//--------------------------------------------------------------------
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
-(void)lockedCacheData:(GSWURLValuedElementData*)aData
{
  //OK
  NSData* data=nil;
  BOOL isTemporary=NO;
  NSString* key=nil;
  NSString* type=nil;
  data=[aData data];
  NSAssert(data,@"Data");
  isTemporary=[aData isTemporary];
  key=[aData key];
  NSAssert(key,@"No key");
  type=[aData type];
  [self lock];
  NS_DURING
    {
      if (!_urlValuedElementsData)
        _urlValuedElementsData=[NSMutableDictionary new];
      [_urlValuedElementsData setObject:aData
                              forKey:key];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
};

//--------------------------------------------------------------------
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
-(NSArray*)_frameworkClassPaths
{
  return _frameworkClassPaths;
};


//--------------------------------------------------------------------
-(NSString*)urlForResourceNamed:(NSString*)resourceName
                    inFramework:(NSString*)aFrameworkName
{
  NSString* url=nil;

  url=[self urlForResourceNamed:resourceName
			 inFramework:aFrameworkName
			 languages:nil
			 request:nil];

  return url;
};

//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)resourceName
                     inFramework:(NSString*)aFrameworkName
{
  NSString* path=nil;

  path=[self pathForResourceNamed:resourceName
             inFramework:aFrameworkName
             language:nil];
  
  return path;
};

//--------------------------------------------------------------------
//NDFN
+(NSString*)GSLanguageFromISOLanguage:(NSString*)ISOLanguage
{
  return [localISO2GSLanguages objectForKey:[[ISOLanguage stringByTrimmingSpaces] lowercaseString]];
};

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
//--------------------------------------------------------------------
+(GSWBundle*)_applicationGSWBundle
{
  if (!globalAppGSWBundle)
    {
      NSString* applicationBaseURL=nil;
      NSString* baseURL=nil;
      NSString* wrapperName=nil;
      
      applicationBaseURL=[GSWApplication applicationBaseURL]; //(retourne /GSWeb)
      wrapperName=[globalAppProjectBundle wrapperName];
      baseURL=[applicationBaseURL stringByAppendingFormat:@"/%@",wrapperName];
      globalAppGSWBundle=[[GSWBundle alloc]initWithPath:[globalAppProjectBundle bundlePath]
                                           baseURL:baseURL];
      //???
      {
        NSBundle* resourceManagerBundle = [NSBundle bundleForClass: self];

        globalMimePListPathName=[resourceManagerBundle pathForResource:@"MIME"
                                                       ofType:@"plist"]; //TODO should return /usr/GNUstep/Libraries/GNUstepWeb/GSWeb.framework/Resources/MIME.plist

        if (!globalMimePListPathName)
          globalMimePListPathName = [[NSBundle bundleForClass: self]
                                      pathForResource:@"MIME"
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
        };
        globalLanguagesPListPathName=[resourceManagerBundle pathForResource:@"languages"
                                                            ofType:@"plist"];
        if (!globalLanguagesPListPathName)
          globalLanguagesPListPathName=[[NSBundle bundleForClass: self]
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
        };
      };
	  
      [globalAppGSWBundle clearCache];
    };
  return globalAppGSWBundle;
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
  NSString *path = [self pathForResourceNamed:filename
			 inFramework:(NSString*)frameworkName
			 languages:(NSArray*)languages];
  
  return [GSWImageInfo imageInfoWithFile: path];
}

@end
