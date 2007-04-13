/** GSWBundle.m -  <title>GSWeb: Class GSWBundle</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 1999
   
   $Revision$
   $Date$
   $Id$
   
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

#ifdef HAVE_GDL2
#include <EOControl/EOKeyValueCoding.h>

//====================================================================
@interface GSWBundleUnarchiverDelegate : NSObject
{
  id _object;
}
- (id) unarchiver:(EOKeyValueUnarchiver*)unarchiver
objectForReference:(NSString*)keyPath;
- (id) initWithObject:(id)object;
@end

//====================================================================
@implementation GSWBundleUnarchiverDelegate

//--------------------------------------------------------------------
- (void) dealloc
{
  [super dealloc];
};

//--------------------------------------------------------------------
- (id) unarchiver:(EOKeyValueUnarchiver*)unarchiver
objectForReference:(NSString*)keyPath
{
  return [_object valueForKeyPath:keyPath];
};

//--------------------------------------------------------------------
- (id) initWithObject:(id)object
{
  if ((self=[super init]))
    {
      _object=object;
    };
  return self;
};

@end
#endif // HAVE_GDL2

@implementation GSWBundle

//--------------------------------------------------------------------
-(id)initWithPath:(NSString*)aPath
		  baseURL:(NSString*)aBaseURL
{
  return [self initWithPath:aPath
               baseURL:aBaseURL
               inFrameworkNamed:nil];
};

//--------------------------------------------------------------------
-(id)initWithPath:(NSString*)aPath
          baseURL:(NSString*)aBaseURL
 inFrameworkNamed:(NSString*)aFrameworkName
{
  if ((self=[super init]))
    {
      LOGObjectFnStart();
      NSDebugMLLog(@"bundles",@"aPath=%@",aPath);
      NSDebugMLLog(@"bundles",@"aBaseURL=%@",aBaseURL);
      ASSIGN(_path,[aPath stringGoodPath]);
      NSDebugMLLog(@"bundles",@"path=%@",_path);
      ASSIGN(_baseURL,aBaseURL);
      ASSIGN(_frameworkName,aFrameworkName);
      _archiveCache=[NSMutableDictionary new];
      _apiCache=[NSMutableDictionary new];
      _encodingCache=[NSMutableDictionary new];
      _templateParserTypeCache=[NSMutableDictionary new];
      _pathCache=[NSMutableDictionary new];
      _urlCache=[NSMutableDictionary new];
      _stringsTableCache=[NSMutableDictionary new];
      _stringsTableArrayCache=[NSMutableDictionary new];
      _templateCache=[NSMutableDictionary new];
      _classCache=[NSMutableDictionary new];
      _selfLock=[NSRecursiveLock new];
      LOGObjectFnStop();
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWBundle");
  GSWLogC("Dealloc GSWBundle: path");
  DESTROY(_path);
  GSWLogC("Dealloc GSWBundle: baseURL");
  DESTROY(_baseURL);
  GSWLogC("Dealloc GSWBundle: archiveCache");
  DESTROY(_archiveCache);
  GSWLogC("Dealloc GSWBundle: apiCache");
  DESTROY(_apiCache);
  GSWLogC("Dealloc GSWBundle: encodingCache");
  DESTROY(_encodingCache);
  GSWLogC("Dealloc GSWBundle: templateParserTypeCache");
  DESTROY(_templateParserTypeCache);
  GSWLogC("Dealloc GSWBundle: pathCache");
  DESTROY(_pathCache);
  GSWLogC("Dealloc GSWBundle: urlCache");
  DESTROY(_urlCache);
  GSWLogC("Dealloc GSWBundle: stringsTableCache");
  DESTROY(_stringsTableCache);
  GSWLogC("Dealloc GSWBundle: stringsTableArrayCache");
  DESTROY(_stringsTableArrayCache);
  GSWLogC("Dealloc GSWBundle: templateCache");
  DESTROY(_templateCache);
  GSWLogC("Dealloc GSWBundle: classCache");
  DESTROY(_classCache);
  GSWLogC("Dealloc GSWBundle: selfLock");
  DESTROY(_selfLock);
  GSWLogC("Dealloc GSWBundle Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWBundle");
};

//--------------------------------------------------------------------
-(NSString*)baseURL
{
  return _baseURL;
};

//--------------------------------------------------------------------
-(NSString*)path
{
  return _path;
};

//--------------------------------------------------------------------
-(NSString*)frameworkName
{
  return _frameworkName;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  NSString* descr=nil;
//  GSWLogC("GSWBundle description A");
//  NSDebugMLLog(@"bundles",@"GSWBundle description Self=%p",self);
  descr=[NSString stringWithFormat:@"<%s %p - ",
                  object_get_class_name(self),
                  (void*)self];
  //  GSWLogC("GSWBundle description B");
  descr=[descr stringByAppendingFormat:@"path:[%@] ",
               _path];
  //  GSWLogC("GSWBundle description C");
  descr=[descr stringByAppendingFormat:@"baseURL:[%@] frameworkName:[%@]>",
               _baseURL,
               _frameworkName];
//  GSWLogC("GSWBundle description D");
  return descr;
};

//--------------------------------------------------------------------
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"selfLockn=%d",_selfLockn);
  LoggedUnlock(_selfLock);
#ifndef NDEBUG
  _selfLockn--;
#endif
  NSDebugMLLog(@"bundles",@"selfLockn=%d",_selfLockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)lock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"selfLockn=%d",_selfLockn);
  LoggedLockBeforeDate(_selfLock,GSW_LOCK_LIMIT);
#ifndef NDEBUG
  _selfLockn++;
#endif
  NSDebugMLLog(@"bundles",@"selfLockn=%d",_selfLockn);
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWBundle (GSWBundleCache)

//--------------------------------------------------------------------
-(void)clearCache
{
  //OK
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      //TemplateCache clearr ?
      LOGObjectFnNotImplemented();	//TODOFN
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)loadCache
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWBundle (GSWBundleA)

// returned relativePath won't have "/" prefix

-(id)lockedResourceNamed:(NSString*)aName
                  ofType:(NSString*)aType
           withLanguages:(NSArray*)someLanguages
              usingCache:(NSMutableDictionary*)aCache
            relativePath:(NSString**)aRelativePath
            absolutePath:(NSString**)anAbsolutePath
{
  int languageIndex=0;
  NSString* relativePath=nil;
  NSString* absolutePath=nil;
  NSString* fileName=nil;
  NSString* language=nil;
  id resource=nil;
  NSString* path=nil;
  NSFileManager* fileManager=nil;
  int languagesNb=0;
  BOOL exists=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"type=%@",aType);
  languagesNb=[someLanguages count];

  fileManager=[NSFileManager defaultManager];
  NSAssert(fileManager,@"No fileManager");

  fileName=[aName stringByAppendingPathExtension:aType];
  NSDebugMLLog(@"bundles",@"fileName=%@",fileName);

  for(languageIndex=0;!resource && !path && languageIndex<=languagesNb;languageIndex++)
    {
      language=nil;
      if (languageIndex==languagesNb)
        relativePath=fileName;
      else
        {
          language=[someLanguages objectAtIndex:languageIndex];
          // format like: language.languageSuffix/fileName
          relativePath=[language stringByAppendingPathExtension:GSLanguageSuffix];
          relativePath=[relativePath stringByAppendingPathComponent:fileName];
        };
      NSDebugMLLog(@"bundles",@"language=%@",language);
      NSDebugMLLog(@"bundles",@"relativePath=%@",relativePath);
      absolutePath=[_path stringByAppendingPathComponent:relativePath];
      NSDebugMLLog(@"bundles",@"absolutePath=%@",absolutePath);
      if ([[GSWApplication application] isCachingEnabled])
        resource=[aCache objectForKey:relativePath];
      NSDebugMLLog(@"bundles",@"resource=%@",resource);
      if (resource==GSNotFoundMarker)
        {
          resource=nil;
          absolutePath=nil;
          relativePath=nil;
        }
      else if (!resource)
        {
          exists=[fileManager fileExistsAtPath:absolutePath];
          NSDebugMLLog(@"bundles",@"%@ exists=%s",absolutePath,(exists ? "YES" : "NO"));
          if (!exists)
            {
              if ([[GSWApplication application] isCachingEnabled])
                [aCache setObject:GSNotFoundMarker
                        forKey:relativePath];
              relativePath=nil;
              absolutePath=nil;
            };
        };
    };

  if (aRelativePath)
    *aRelativePath=(([relativePath length]>0) ? relativePath : nil);
  if (anAbsolutePath)
    *anAbsolutePath=(([absolutePath length]>0) ? absolutePath : nil);

  LOGObjectFnStop();

  return resource;
};
@end

//====================================================================
@implementation GSWBundle (GSWResourceManagement)

//--------------------------------------------------------------------
-(void)initializeObject:(id)anObject
       fromArchiveNamed:(NSString*)aName
{
  //OK
  NSDictionary* archive=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"anObject:%@",anObject);
  NSDebugMLLog(@"bundles",@"aName:%@",aName);
  //call application _isDynamicLoadingEnabled
  //call -- isTerminating
  //call -- isCachingEnabled
  //call -- isPageRefreshOnBacktrackEnabled//0
  archive=[self archiveNamed:aName];
  //Verify
  NSDebugMLLog(@"bundles",@"archive:%@",archive);
  if (archive)
    [self initializeObject:anObject
          fromArchive:archive];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)initializeObject:(id)anObject
            fromArchive:(NSDictionary*)anArchive
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"anObject:%@",anObject);
  NSDebugMLLog(@"bundles",@"anArchive:%@",anArchive);
  [self lock];
  NS_DURING
    {
      if (!WOStrictFlag)
        {
          NSDictionary* userDictionary=[anArchive objectForKey:@"userDictionary"];
          NSDictionary* userAssociations=[anArchive objectForKey:@"userAssociations"];		
          NSDictionary* defaultAssociations=[anArchive objectForKey:@"defaultAssociations"];
          NSDebugMLLog(@"bundles",@"userDictionary:%@",userDictionary);
          NSDebugMLLog(@"bundles",@"userAssociations:%@",userAssociations);
          NSDebugMLLog(@"bundles",@"defaultAssociations:%@",defaultAssociations);
          userAssociations=[userAssociations dictionaryByReplacingStringsWithAssociations];
          NSDebugMLLog(@"bundles",@"userAssociations:%@",userAssociations);
          defaultAssociations=[defaultAssociations dictionaryByReplacingStringsWithAssociations];
          NSDebugMLLog(@"bundles",@"defaultAssociations:%@",defaultAssociations);
          if (userDictionary && [anObject respondsToSelector:@selector(setUserDictionary:)])
            [anObject setUserDictionary:userDictionary];
          if (userAssociations && [anObject respondsToSelector:@selector(setUserAssociations:)])
            [anObject setUserAssociations:userAssociations];
          if (defaultAssociations && [anObject respondsToSelector:@selector(setDefaultAssociations:)])
            [anObject setDefaultAssociations:defaultAssociations];
        };
#if HAVE_GDL2 // GDL2 implementation
      {
        EOKeyValueUnarchiver* unarchiver=nil;
        GSWBundleUnarchiverDelegate* bundleDelegate=nil;
        NSDictionary* variables=nil;
        NSEnumerator* variablesEnum=nil;
        id variableName=nil;
        NSDebugMLLog(@"bundles",@"anArchive %p:%@",anArchive,anArchive);
        unarchiver=[[[EOKeyValueUnarchiver alloc] initWithDictionary:anArchive]
                     autorelease];
        NSDebugMLLog(@"bundles",@"unarchiver %p:%@",unarchiver,unarchiver);
        bundleDelegate=[[[GSWBundleUnarchiverDelegate alloc] initWithObject:anObject]
                         autorelease];
        NSDebugMLLog(@"bundles",@"bundleDelegate %p:%@",bundleDelegate,bundleDelegate);
        [unarchiver setDelegate:bundleDelegate];
        NSDebugMLLog(@"bundles",@"decodevar here=%p",[NSString string]);
        variables=[unarchiver decodeObjectForKey:@"variables"];
        NSDebugMLLog(@"bundles",@"variables %p:%@",variables,variables);
        [unarchiver finishInitializationOfObjects];
        NSDebugMLLog(@"bundles",@"here=%p",[NSString string]);
        [unarchiver awakeObjects];
        variablesEnum=[variables keyEnumerator];
        NSDebugMLLog(@"bundles",@"here=%p",[NSString string]);
        NSDebugMLLog0(@"bundles",@"Will set variables");
        while ((variableName = [variablesEnum nextObject]))
          {
            id variableValue=[variables objectForKey:variableName];
            NSDebugMLLog(@"bundles",@"ObjectClas=%@ variableName %p:%@ variableValue %p:%@",
                         [anObject class],
                         variableName,
                         variableName,
                         variableValue,
                         variableValue);
            NSDebugMLLog(@"bundles",@"BEF variableValue %p:%@ [RC=%d]",
                         variableValue,
                         variableValue,
                         [variableValue retainCount]);
            [anObject smartTakeValue:variableValue
                     forKey:variableName];
            NSDebugMLLog(@"bundles",@"AFT variableValue %p:%@ [RC=%d]",
                         variableValue,
                         variableValue,
                         [variableValue retainCount]);
          };
      };
#else
      LOGObjectFnNotImplemented();
#endif
    }
  NS_HANDLER
    {
      NSDebugMLog(@"EXCEPTION:%@ (%@) [%s %d] anObject=%p class=%@ superClass=%@ ",
                   localException,
                   [localException reason],
                   __FILE__,
                   __LINE__,
                  anObject,
                  [anObject class],
                  [anObject superclass]);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(Class)scriptedClassWithName:(NSString*)aName
               superclassName:(NSString*)aSuperclassName
{
  //OK
  Class aClass=nil;
  NSString* pathName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"Name=%@",aName);
  NSDebugMLLog(@"bundles",@"aSuperclassName=%@",aSuperclassName);
  [self lock];
  NS_DURING
    {
      pathName=[self lockedScriptedClassPathWithName:aName];
      //Verify
      if (pathName)
        {
          aClass=[self lockedScriptedClassWithName:aName
                       pathName:pathName
                       superclassName:aSuperclassName];
        };
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return aClass;
};

//--------------------------------------------------------------------
-(Class)lockedScriptedClassWithName:(NSString*)aName
                           pathName:(NSString*)aPathName
                     superclassName:(NSString*)aSuperclassName
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)lockedScriptedClassPathWithName:(NSString*)aName
{
  NSString* path=nil;
  id script=nil;
  script=[self lockedResourceNamed:aName
               ofType:GSWScriptSuffix[GSWebNamingConv]
               withLanguages:nil
               usingCache:_classCache
               relativePath:NULL
               absolutePath:&path];
  if (!script && !path)
    script=[self lockedResourceNamed:aName
                 ofType:GSWScriptSuffix[GSWebNamingConvInversed]
                 withLanguages:nil
                 usingCache:_classCache
                 relativePath:NULL
                 absolutePath:&path];
  return path;
};

//--------------------------------------------------------------------
-(Class)compiledClassWithName:(NSString*)aName
               superclassName:(NSString*)aSuperclassName
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(GSWElement*)templateNamed:(NSString*)aName
                  languages:(NSArray*)someLanguages
{
  GSWElement* template=nil;

  [self lock];
  NS_DURING
    {
      template=[self lockedTemplateNamed:aName
                     languages:someLanguages];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In lockedTemplateNamed");
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];

  return template;
};

//--------------------------------------------------------------------
-(GSWElement*)lockedTemplateNamed:(NSString*)aName
                        languages:(NSArray*)someLanguages
{
  //OK
  GSWElement* template=nil;
  NSString* relativeTemplatePath=nil;
  NSString* absoluteTemplatePath=nil;

  template=[self lockedResourceNamed:aName
                 ofType:GSWComponentTemplateSuffix
                 withLanguages:someLanguages
                 usingCache:_templateCache
                 relativePath:&relativeTemplatePath
                 absolutePath:&absoluteTemplatePath];

  if (!template)
    {
      if (!relativeTemplatePath)
        {
          NSDebugMLLog(@"errors",@"No template named:%@ for languages:%@",
                       aName,
                       someLanguages);
        }
      else
        {
          GSWTemplateParserType templateParserType=[self templateParserTypeForResourcesNamed:aName];
          NSStringEncoding encoding=[self encodingForResourcesNamed:aName];
          NSString* pageDefString=nil;
          NSString* htmlString=[NSString stringWithContentsOfFile:absoluteTemplatePath 
                                                         encoding:encoding];
          //NSString* htmlString=[NSString stringWithContentsOfFile:absoluteTemplatePath];
          NSDebugMLLog(@"bundles",@"htmlPath=%@",absoluteTemplatePath);
          if (!htmlString)
            {
              NSDebugMLLog(@"errors",@"No html file for template named:%@ for languages:%@",
                           aName,
                           someLanguages);
            }
          else
            {
              NSString* absoluteDefinitionPath=nil;
              pageDefString=[self lockedResourceNamed:aName
                                  ofType:GSWComponentDeclarationsSuffix[GSWebNamingConv]
                                  withLanguages:someLanguages
                                  usingCache:nil
                                  relativePath:NULL
                                  absolutePath:&absoluteDefinitionPath];
              NSDebugMLLog(@"bundles",@"absoluteDefinitionPath=%@",
                           absoluteDefinitionPath);
              if (!pageDefString && !absoluteDefinitionPath)
                {
                  pageDefString=[self lockedResourceNamed:aName
                                      ofType:GSWComponentDeclarationsSuffix[GSWebNamingConvInversed]
                                      withLanguages:someLanguages
                                      usingCache:nil
                                      relativePath:NULL
                                      absolutePath:&absoluteDefinitionPath];
                  NSDebugMLLog(@"bundles",@"absoluteDefinitionPath=%@",
                               absoluteDefinitionPath);
                };
              
              if (absoluteDefinitionPath)
                {
                  //TODO use encoding !
                  NSDebugMLLog(@"bundles",@"absoluteDefinitionPath=%@",
                               absoluteDefinitionPath);
                  //pageDefString=[NSString stringWithContentsOfFile:absoluteDefinitionPath];
                  pageDefString = [NSString stringWithContentsOfFile:absoluteDefinitionPath 
                                                            encoding:encoding];

                };
#ifndef NDEBUG
              NS_DURING
#endif
                {
                  NSDebugMLLog(@"bundles",@"GSWTemplateParser on template named %@",
                               aName);
                  template=[GSWTemplateParser templateNamed:aName
                                              inFrameworkNamed:[self frameworkName]
                                              withParserType:templateParserType
                                              parserClassName:nil
                                              withString:htmlString
                                              encoding:encoding
                                              fromPath:absoluteTemplatePath
                                              declarationsString:pageDefString
                                              languages:someLanguages
                                              declarationsPath:absoluteDefinitionPath];
                }
#ifndef NDEBUG
              NS_HANDLER
                {
                  NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",
                               localException,
                               [localException reason],
                               __FILE__,
                               __LINE__);
                  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                           @"In template Parsing");
                  [localException raise];
                };
              NS_ENDHANDLER;
#endif
            };
          if ([[GSWApplication application] isCachingEnabled])
            {
              if (template)
		{
		  [_templateCache setObject:template
				  forKey:relativeTemplatePath];
		}
              else
		{
		  [_templateCache setObject:GSNotFoundMarker
				  forKey:relativeTemplatePath];
		}
            };
        };
    };

  return template;
};

//--------------------------------------------------------------------
-(NSString*)stringForKey:(NSString*)aKey
            inTableNamed:(NSString*)aName
        withDefaultValue:(NSString*)defaultValue
               languages:(NSArray*)someLanguages
{
  NSDictionary* stringsTable=nil;
  NSString* string=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"AKey=%@",aKey);
  NSDebugMLLog(@"bundles",@"aName=%@",aName);
  NSDebugMLLog(@"bundles",@"SomeLanguages=%@",someLanguages);
  NSDebugMLLog(@"bundles",@"defaultValue_=%@",defaultValue);
  stringsTable=[self stringsTableNamed:aName
                     withLanguages:someLanguages];
  if (stringsTable)
    string=[stringsTable objectForKey:aKey];
  if (!string)
    string=defaultValue;
  LOGObjectFnStop();
  return string;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aName
                    withLanguages:(NSArray*)someLanguages
{
  NSDictionary* stringsTable=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@",aName);
  NSDebugMLLog(@"bundles",@"SomeLanguages=%@",someLanguages);
  [self lock];
  NS_DURING
    {
      NSString* relativePath=nil;
      NSString* absolutePath=nil;
      LOGObjectFnStart();
      stringsTable=[self lockedResourceNamed:aName
                         ofType:GSWStringTableSuffix
                         withLanguages:someLanguages
                         usingCache:_stringsTableCache
                         relativePath:&relativePath
                         absolutePath:&absolutePath];
      if (!stringsTable)
        {
          if (absolutePath)
            {
              //TODO use encoding ??
              NSString* stringsTableContent = [NSString stringWithContentsOfFile:absolutePath];
              NS_DURING
                {
                  stringsTable = [stringsTableContent propertyListFromStringsFileFormat]; 
                }
              NS_HANDLER
                {
                  LOGSeriousError(@"Failed to parse strings file %@ - %@",
                                  absolutePath, localException);
                  stringsTable = nil;
                }
              NS_ENDHANDLER
              if ([[GSWApplication application] isCachingEnabled])
                {
                  if (stringsTable)
                    [_stringsTableCache setObject:stringsTable
                                        forKey:relativePath];
                  else
                    [_stringsTableCache setObject:GSNotFoundMarker
                                        forKey:relativePath];
                };
            };
        };
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aName
                    withLanguages:(NSArray*)someLanguages
{
  NSArray* stringsTableArray=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@",aName);
  NSDebugMLLog(@"bundles",@"SomeLanguages=%@",someLanguages);
  [self lock];
  NS_DURING
    {
      NSString* relativePath=nil;
      NSString* absolutePath=nil;
      LOGObjectFnStart();
      stringsTableArray=[self lockedResourceNamed:aName
                              ofType:GSWStringTableArraySuffix
                              withLanguages:someLanguages
                              usingCache:_stringsTableArrayCache
                              relativePath:&relativePath
                              absolutePath:&absolutePath];
      if (!stringsTableArray)
        {
          if (absolutePath)
            {
              //TODO use encoding ??
              stringsTableArray=[NSArray arrayWithContentsOfFile:absolutePath];
              if (!stringsTableArray)
                {
                  LOGSeriousError(@"Bad stringTableArray \n%@\n from file %@",
                                  [NSString stringWithContentsOfFile:absolutePath],
                                  absolutePath);
                };
              if ([[GSWApplication application] isCachingEnabled])
                {
                  if (stringsTableArray)
                    [_stringsTableArrayCache setObject:stringsTableArray
                                             forKey:relativePath];
                  else
                    [_stringsTableArrayCache setObject:GSNotFoundMarker
                                             forKey:relativePath];
                };
            };
        };
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"During stringsTableArrayNamed:withLanguages:");
      LOGException(@"exception=%@",localException);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return stringsTableArray;
};

//--------------------------------------------------------------------
-(NSString*)urlForResourceNamed:(NSString*)aName
                         ofType:(NSString*)aType
                      languages:(NSArray*)someLanguages
                        request:(GSWRequest*)aRequest
{
  BOOL isUsingWebServer=NO;
  NSString* url=nil;
  LOGObjectFnStart();
  isUsingWebServer=[aRequest _isUsingWebServer];
  [self lock];
  NS_DURING
    {
      NSString* relativePath=nil;
      NSString* absolutePath=nil;
      NSString* baseURL=nil;

      LOGObjectFnStart();

      // baseURL have / prefix, relativePath don't
      baseURL=[self lockedResourceNamed:aName
                    ofType:aType
                    withLanguages:someLanguages
                    usingCache:_urlCache
                    relativePath:&relativePath
                    absolutePath:&absolutePath];
      if (!baseURL)
        {
          if (relativePath)
            {
              baseURL=[relativePath stringByAppendingString:@"/"];
              if ([[GSWApplication application] isCachingEnabled])
                {
                  [_pathCache setObject:baseURL
                              forKey:relativePath];
                };
            };
        };
      if (baseURL)
        {
          if (isUsingWebServer)
            {
              url=[_baseURL stringByAppendingString:baseURL];
            }
          else
            {
              NSString* completePath=[_path stringByAppendingString:baseURL];
              url=(NSString*)[aRequest _urlWithRequestHandlerKey:GSWResourceRequestHandlerKey[GSWebNamingConv]
                                       path:nil
                                       queryString:[NSString stringWithFormat:@"%@=%@",
                                                             GSWKey_Data[GSWebNamingConv],
                                                             completePath]];//TODO Escape
            };
        };
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return url;
};

//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)aType
                       languages:(NSArray*)someLanguages
{
  NSString* absolutePath=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@",aName);
  NSDebugMLLog(@"bundles",@"aType=%@",aType);
  NSDebugMLLog(@"bundles",@"someLanguages=%@",someLanguages);
  [self lock];
  NS_DURING
    {
      NSString* path=nil;
      NSString* relativePath=nil;
      LOGObjectFnStart();
      path=[self lockedResourceNamed:aName
                 ofType:aType
                 withLanguages:someLanguages
                 usingCache:_stringsTableCache
                 relativePath:&relativePath
                 absolutePath:&absolutePath];
      if (path)
        absolutePath=path;
      else if (absolutePath
               &&[[GSWApplication application] isCachingEnabled])
        {
          [_pathCache setObject:absolutePath
                      forKey:relativePath];
        };
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return absolutePath;
};

//--------------------------------------------------------------------
-(NSStringEncoding)encodingForResourcesNamed:(NSString*)aName
{
  NSDictionary* archive=nil;
  NSStringEncoding encoding=[GSWMessage defaultEncoding]; // safer, because we may not have a .woo file
  id encodingObject=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      NSDebugMLLog(@"bundles",@"aName=%@",aName);
      NSDebugMLLog(@"bundles",@"encodingCache=%@",_encodingCache);
      NSDebugMLLog(@"bundles",@"archiveCache=%@",_archiveCache);
      encodingObject=[_encodingCache objectForKey:aName];
      if (!encodingObject)
        {
          archive=[self archiveNamed:aName];
          if (archive)
            {
            //NSLog(@"archive is '%@'", archive);
              encodingObject=[archive objectForKey:@"encoding"];
              if (encodingObject)
                {
                  //NSLog(@"encodingObject is '%@'", encodingObject);
                  //encodingObject is 'NSISOLatin1StringEncoding'
                  //not very cool to make a int into a string and some time later a string..
                  encodingObject=GSWIntToNSString([NSString encodingNamed: encodingObject]);
                  [_encodingCache setObject:encodingObject
                                  forKey:aName];
                };
            };
        };
      if (encodingObject)
        encoding=[encodingObject intValue];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return encoding;
};

//--------------------------------------------------------------------
-(GSWTemplateParserType)templateParserTypeForResourcesNamed:(NSString*)aName
{
  NSDictionary* archive=nil;
  GSWTemplateParserType templateParserType=GSWTemplateParserType_Default;
  id templateParserTypeObject=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      NSDebugMLLog(@"bundles",@"aName=%@",aName);
      NSDebugMLLog(@"bundles",@"templateParserTypeCache=%@",_templateParserTypeCache);
      NSDebugMLLog(@"bundles",@"archiveCache=%@",_archiveCache);
      templateParserTypeObject=[_templateParserTypeCache objectForKey:aName];
      if (!templateParserTypeObject)
        {
          archive=[self archiveNamed:aName];
          if (archive)
            {
              templateParserTypeObject=[archive objectForKey:@"templateParserType"];
              if (templateParserTypeObject)
                {
                  templateParserTypeObject=GSWIntNumber([GSWTemplateParser templateParserTypeFromString:templateParserTypeObject]);
                  [_templateParserTypeCache setObject:templateParserTypeObject
                                  forKey:aName];
                };
            };
        };
      if (templateParserTypeObject)
        templateParserType=[templateParserTypeObject intValue];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return templateParserType;
};

//--------------------------------------------------------------------
-(NSDictionary*)archiveNamed:(NSString*)aName
{
  //OK
  NSDictionary* archive=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@",aName);
  [self lock];
  NS_DURING
    {
      archive=[self lockedArchiveNamed:aName];
      NSDebugMLLog(@"bundles",@"archive=%@",archive);
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  NSDebugMLLog(@"bundles",@"archive=%@",archive);
  LOGObjectFnStop();
  return archive;
};

//--------------------------------------------------------------------
-(NSDictionary*)lockedArchiveNamed:(NSString*)aName
{
  //OK
  NSDictionary* archive=nil;
  NSString* relativePath=nil;
  NSString* absolutePath=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"search=%@.%@",aName,GSWArchiveSuffix[GSWebNamingConv]);
  archive=[self lockedResourceNamed:aName
                ofType:GSWArchiveSuffix[GSWebNamingConv]
                withLanguages:nil
                usingCache:_archiveCache
                relativePath:&relativePath
                absolutePath:&absolutePath];
  NSDebugMLLog(@"bundles",@"archive=%p absolutePath=%@",archive,absolutePath);
  if (!archive && !absolutePath)
    {
      NSDebugMLLog(@"bundles",@"search=%@.%@",aName,GSWArchiveSuffix[GSWebNamingConvInversed]);
      archive=[self lockedResourceNamed:aName
                    ofType:GSWArchiveSuffix[GSWebNamingConvInversed]
                    withLanguages:nil
                    usingCache:_archiveCache
                    relativePath:&relativePath
                    absolutePath:&absolutePath];
      NSDebugMLLog(@"bundles",@"archive=%p absolutePath=%@",archive,absolutePath);
    };
  if (!archive)
    {
      if (absolutePath)
        {
          archive=[NSDictionary dictionaryWithContentsOfFile:absolutePath];
          if ([[GSWApplication application] isCachingEnabled])
            {
              if (archive)
                [_archiveCache setObject:archive
                               forKey:relativePath];
              else
                [_archiveCache setObject:GSNotFoundMarker
                               forKey:relativePath];
            };
        };
    };
  NSDebugMLLog(@"bundles",@"archive=%@",archive);
  LOGObjectFnStop();
  return archive;
};

//--------------------------------------------------------------------
-(NSDictionary*)apiNamed:(NSString*)aName
{
  //OK
  NSDictionary* api=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"aName=%@",aName);
  [self lock];
  NS_DURING
    {
      api=[self lockedApiNamed:aName];
      NSDebugMLLog(@"bundles",@"api=%@",api);
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  NSDebugMLLog(@"bundles",@"api=%@",api);
  LOGObjectFnStop();
  return api;
};

//--------------------------------------------------------------------
-(NSDictionary*)lockedApiNamed:(NSString*)aName
{
  //OK
  NSDictionary* api=nil;
  NSString* relativePath=nil;
  NSString* absolutePath=nil;
  LOGObjectFnStart();
  api=[self lockedResourceNamed:aName
            ofType:GSWAPISuffix
            withLanguages:nil
            usingCache:_apiCache
            relativePath:&relativePath
            absolutePath:&absolutePath];
  if (!api)
    {
      if (absolutePath)
        {
          api=[NSDictionary dictionaryWithContentsOfFile:absolutePath];
          if ([[GSWApplication application] isCachingEnabled])
            {
              if (api)
                [_apiCache setObject:api
                           forKey:relativePath];
              else
                [_apiCache setObject:GSNotFoundMarker
                           forKey:relativePath];
            };
        };
    };
  NSDebugMLLog(@"bundles",@"api=%@",api);
  LOGObjectFnStop();
  return api;
};

@end

//====================================================================
@implementation GSWBundle (GSWBundleC)

//--------------------------------------------------------------------
-(id)scriptedClassNameFromClassName:(NSString*)aName
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)scriptPathNameFromScriptedClassName:(NSString*)aName
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

@end


