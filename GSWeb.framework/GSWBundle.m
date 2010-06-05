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
#include <GNUstepBase/NSObject+GNUstepBase.h>

//#ifdef HAVE_GDL2
//#include <EOControl/EOKeyValueCoding.h>

//====================================================================
@interface GSWBundleUnarchiverDelegate : NSObject
{
  id _object;
}
- (id) unarchiver:(NSKeyedUnarchiver*)unarchiver objectForReference:(NSString*)keyPath;
- (id) initWithObject:(id)object;
@end

//====================================================================
@implementation GSWBundleUnarchiverDelegate

//--------------------------------------------------------------------
- (void) dealloc
{
  [super dealloc];
}

//--------------------------------------------------------------------
- (id) unarchiver:(NSKeyedUnarchiver*)unarchiver objectForReference:(NSString*)keyPath
{
  return [_object valueForKeyPath:keyPath];
}

//--------------------------------------------------------------------
- (id) initWithObject:(id)object
{
  if ((self=[super init]))
    {
      _object=object;
    }
  return self;
}

@end
//#endif // HAVE_GDL2

@implementation GSWBundle

//--------------------------------------------------------------------
-(id)initWithPath:(NSString*)aPath
          baseURL:(NSString*)aBaseURL
{
  return [self initWithPath:aPath
               baseURL:aBaseURL
               inFrameworkNamed:nil];
}

//--------------------------------------------------------------------
-(id)initWithPath:(NSString*)aPath
          baseURL:(NSString*)aBaseURL
 inFrameworkNamed:(NSString*)aFrameworkName
{
  if ((self=[super init]))
    {
      ASSIGN(_path,[aPath stringGoodPath]);
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
    }
  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_path);
  DESTROY(_baseURL);
  DESTROY(_archiveCache);
  DESTROY(_apiCache);
  DESTROY(_encodingCache);
  DESTROY(_templateParserTypeCache);
  DESTROY(_pathCache);
  DESTROY(_urlCache);
  DESTROY(_stringsTableCache);
  DESTROY(_stringsTableArrayCache);
  DESTROY(_templateCache);
  DESTROY(_classCache);
  DESTROY(_selfLock);
  
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)baseURL
{
  return _baseURL;
}

//--------------------------------------------------------------------
-(NSString*)path
{
  return _path;
}

//--------------------------------------------------------------------
-(NSString*)frameworkName
{
  return _frameworkName;
}

//--------------------------------------------------------------------
-(NSString*)description
{
  NSString* descr=nil;

  descr=[NSString stringWithFormat:@"<%s %p - ",
                  object_getClassName(self),
                  (void*)self];

  descr=[descr stringByAppendingFormat:@"path:[%@] ",
               _path];

  descr=[descr stringByAppendingFormat:@"baseURL:[%@] frameworkName:[%@]>",
               _baseURL,
               _frameworkName];

  return descr;
}

//--------------------------------------------------------------------
-(void)unlock
{
  LoggedUnlock(_selfLock);
#ifndef NDEBUG
  _selfLockn--;
#endif
}

//--------------------------------------------------------------------
-(void)lock
{
  LoggedLockBeforeDate(_selfLock,GSW_LOCK_LIMIT);
#ifndef NDEBUG
  _selfLockn++;
#endif
}


//--------------------------------------------------------------------
-(void)clearCache
{
  [self lock];
  NS_DURING
    {
      DESTROY(_archiveCache);
      DESTROY(_apiCache);
      DESTROY(_encodingCache);
      DESTROY(_templateParserTypeCache);
      DESTROY(_pathCache);
      DESTROY(_urlCache);
      DESTROY(_stringsTableCache);
      DESTROY(_stringsTableArrayCache);
      DESTROY(_templateCache);
      DESTROY(_classCache);
      
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
      
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
}

//--------------------------------------------------------------------
-(void)loadCache
{
  [self notImplemented: _cmd];	//TODOFN
}


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

  languagesNb=[someLanguages count];

  fileManager=[NSFileManager defaultManager];
  NSAssert(fileManager,@"No fileManager");

  fileName=[aName stringByAppendingPathExtension:aType];

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
        }
      
      absolutePath=[_path stringByAppendingPathComponent:relativePath];

      if ([[GSWApplication application] isCachingEnabled])
        resource=[aCache objectForKey:relativePath];

      if (resource==GSNotFoundMarker)
        {
          resource=nil;
          absolutePath=nil;
          relativePath=nil;
        }
      else if (!resource)
        {
          exists=[fileManager fileExistsAtPath:absolutePath];

          if (!exists)
            {
              if ([[GSWApplication application] isCachingEnabled])
                [aCache setObject:GSNotFoundMarker
                        forKey:relativePath];
              relativePath=nil;
              absolutePath=nil;
            }
        }
    }

  if (aRelativePath) {
    if ([relativePath length]>0) {
      *aRelativePath = relativePath;
    } else {
      *aRelativePath = nil;
    }
  }
  if (anAbsolutePath) {
    if ([absolutePath length]>0) {
      *anAbsolutePath = absolutePath;
    } else {
      *anAbsolutePath = nil;
    }
  }

  return resource;
}

//--------------------------------------------------------------------
-(void)initializeObject:(id)anObject
       fromArchiveNamed:(NSString*)aName
{
  //OK
  NSDictionary* archive=nil;

  //call application _isDynamicLoadingEnabled
  //call -- isTerminating
  //call -- isCachingEnabled
  //call -- isPageRefreshOnBacktrackEnabled//0
  archive=[self archiveNamed:aName];
  //Verify

  if (archive)
    [self initializeObject:anObject
          fromArchive:archive];
}

//--------------------------------------------------------------------
-(void)initializeObject:(id)anObject
            fromArchive:(NSDictionary*)anArchive
{
  [self lock];
  NS_DURING
    {
      /*
      if (!WOStrictFlag)
        {
          NSDictionary* userDictionary=[anArchive objectForKey:@"userDictionary"];
          NSDictionary* userAssociations=[anArchive objectForKey:@"userAssociations"];		
          NSDictionary* defaultAssociations=[anArchive objectForKey:@"defaultAssociations"];

          userAssociations=[userAssociations dictionaryByReplacingStringsWithAssociations];
          defaultAssociations=[defaultAssociations dictionaryByReplacingStringsWithAssociations];
          if (userDictionary && [anObject respondsToSelector:@selector(setUserDictionary:)])
            [anObject setUserDictionary:userDictionary];
          if (userAssociations && [anObject respondsToSelector:@selector(setUserAssociations:)])
            [anObject setUserAssociations:userAssociations];
          if (defaultAssociations && [anObject respondsToSelector:@selector(setDefaultAssociations:)])
            [anObject setDefaultAssociations:defaultAssociations];
        }
      [self notImplemented: _cmd];
       */
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
    }
  NS_ENDHANDLER;
  [self unlock];
}

//--------------------------------------------------------------------
-(Class)scriptedClassWithName:(NSString*)aName
               superclassName:(NSString*)aSuperclassName
{
  //OK
  Class aClass=nil;
  NSString* pathName=nil;

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
        }
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];

  return aClass;
}

//--------------------------------------------------------------------
-(Class)lockedScriptedClassWithName:(NSString*)aName
                           pathName:(NSString*)aPathName
                     superclassName:(NSString*)aSuperclassName
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
}

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
}

//--------------------------------------------------------------------
-(Class)compiledClassWithName:(NSString*)aName
               superclassName:(NSString*)aSuperclassName
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
}

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
      //TODO
      [self unlock];
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"In lockedTemplateNamed");
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];

  return template;
}

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
//          NSDebugMLLog(@"errors",@"No template named:%@ for languages:%@",
//                       aName,
//                       someLanguages);
        }
      else
        {
          GSWTemplateParserType templateParserType=[self templateParserTypeForResourcesNamed:aName];
          NSStringEncoding encoding=[self encodingForResourcesNamed:aName];
          NSString* pageDefString=nil;
          NSString* htmlString=[NSString stringWithContentsOfFile:absoluteTemplatePath 
                                                         encoding:encoding];
          //NSString* htmlString=[NSString stringWithContentsOfFile:absoluteTemplatePath];

          if (!htmlString)
            {
//              NSDebugMLLog(@"errors",@"No html file for template named:%@ for languages:%@",
//                           aName,
//                           someLanguages);
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

              if (!pageDefString && !absoluteDefinitionPath)
                {
                  pageDefString=[self lockedResourceNamed:aName
                                      ofType:GSWComponentDeclarationsSuffix[GSWebNamingConvInversed]
                                      withLanguages:someLanguages
                                      usingCache:nil
                                      relativePath:NULL
                                      absolutePath:&absoluteDefinitionPath];
                }
              
              if (absoluteDefinitionPath)
                {
                  //TODO use encoding !
                  //pageDefString=[NSString stringWithContentsOfFile:absoluteDefinitionPath];
                  pageDefString = [NSString stringWithContentsOfFile:absoluteDefinitionPath 
                                                            encoding:encoding];

                }
#ifndef NDEBUG
              NS_DURING
#endif
                {
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
                  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                           @"In template Parsing");
                  [localException raise];
                }
              NS_ENDHANDLER;
#endif
            }
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
            }
        }
    }

  return template;
}

//--------------------------------------------------------------------
-(NSString*)stringForKey:(NSString*)aKey
            inTableNamed:(NSString*)aName
        withDefaultValue:(NSString*)defaultValue
               languages:(NSArray*)someLanguages
{
  NSDictionary* stringsTable=nil;
  NSString* string=nil;

  stringsTable=[self stringsTableNamed:aName
                     withLanguages:someLanguages];
  if (stringsTable)
    string=[stringsTable objectForKey:aKey];
  if (!string)
    string=defaultValue;

  return string;
}

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aName
                    withLanguages:(NSArray*)someLanguages
{
  NSDictionary* stringsTable=nil;

  [self lock];
  NS_DURING
    {
      NSString* relativePath=nil;
      NSString* absolutePath=nil;
    
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
//                  LOGSeriousError(@"Failed to parse strings file %@ - %@",
//                                  absolutePath, localException);
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
                }
            }
        }
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
}

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aName
                    withLanguages:(NSArray*)someLanguages
{
  NSArray* stringsTableArray=nil;

  [self lock];
  NS_DURING
    {
      NSString* relativePath=nil;
      NSString* absolutePath=nil;
    
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
//                  LOGSeriousError(@"Bad stringTableArray \n%@\n from file %@",
//                                  [NSString stringWithContentsOfFile:absolutePath],
//                                  absolutePath);
                }
              if ([[GSWApplication application] isCachingEnabled])
                {
                  if (stringsTableArray)
                    [_stringsTableArrayCache setObject:stringsTableArray
                                             forKey:relativePath];
                  else
                    [_stringsTableArrayCache setObject:GSNotFoundMarker
                                             forKey:relativePath];
                }
            }
        }
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"During stringsTableArrayNamed:withLanguages:");
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];

  return stringsTableArray;
}

//--------------------------------------------------------------------
-(NSString*)urlForResourceNamed:(NSString*)aName
                         ofType:(NSString*)aType
                      languages:(NSArray*)someLanguages
                        request:(GSWRequest*)aRequest
{
  BOOL isUsingWebServer=NO;
  NSString* url=nil;

  isUsingWebServer=[aRequest _isUsingWebServer];
  [self lock];
  NS_DURING
    {
      NSString* relativePath=nil;
      NSString* absolutePath=nil;
      NSString* baseURL=nil;

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
                }
            }
        }
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
            }
        }
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
}

//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)aType
                       languages:(NSArray*)someLanguages
{
  NSString* absolutePath=nil;

  [self lock];
  NS_DURING
    {
      NSString* path=nil;
      NSString* relativePath=nil;

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
        }
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];

  return absolutePath;
}

//--------------------------------------------------------------------
-(NSStringEncoding)encodingForResourcesNamed:(NSString*)aName
{
  NSDictionary* archive=nil;
  NSStringEncoding encoding=[GSWMessage defaultEncoding]; // safer, because we may not have a .woo file
  id encodingObject=nil;

  [self lock];
  NS_DURING
    {
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
                }
            }
        }
      if (encodingObject)
        encoding=[encodingObject intValue];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];

  return encoding;
}

//--------------------------------------------------------------------
-(GSWTemplateParserType)templateParserTypeForResourcesNamed:(NSString*)aName
{
  NSDictionary* archive=nil;
  GSWTemplateParserType templateParserType=GSWTemplateParserType_Default;
  id templateParserTypeObject=nil;

  [self lock];
  NS_DURING
    {
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
                }
            }
        }
      if (templateParserTypeObject)
        templateParserType=[templateParserTypeObject intValue];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];

  return templateParserType;
}

//--------------------------------------------------------------------
-(NSDictionary*)archiveNamed:(NSString*)aName
{
  //OK
  NSDictionary* archive=nil;

  [self lock];
  NS_DURING
    {
      archive=[self lockedArchiveNamed:aName];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];

  return archive;
}

//--------------------------------------------------------------------
-(NSDictionary*)lockedArchiveNamed:(NSString*)aName
{
  //OK
  NSDictionary* archive=nil;
  NSString* relativePath=nil;
  NSString* absolutePath=nil;

  archive=[self lockedResourceNamed:aName
                ofType:GSWArchiveSuffix[GSWebNamingConv]
                withLanguages:nil
                usingCache:_archiveCache
                relativePath:&relativePath
                absolutePath:&absolutePath];

  if (!archive && !absolutePath)
    {
      archive=[self lockedResourceNamed:aName
                    ofType:GSWArchiveSuffix[GSWebNamingConvInversed]
                    withLanguages:nil
                    usingCache:_archiveCache
                    relativePath:&relativePath
                    absolutePath:&absolutePath];
    }
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
            }
        }
    }

  return archive;
}

//--------------------------------------------------------------------
-(NSDictionary*)apiNamed:(NSString*)aName
{
  //OK
  NSDictionary* api=nil;

  [self lock];
  NS_DURING
    {
      api=[self lockedApiNamed:aName];
    }
  NS_HANDLER
    {
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];

  return api;
}

//--------------------------------------------------------------------
-(NSDictionary*)lockedApiNamed:(NSString*)aName
{
  //OK
  NSDictionary* api=nil;
  NSString* relativePath=nil;
  NSString* absolutePath=nil;

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
            }
        }
    }

  return api;
}


//--------------------------------------------------------------------
-(id)scriptedClassNameFromClassName:(NSString*)aName
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
}

//--------------------------------------------------------------------
-(id)scriptPathNameFromScriptedClassName:(NSString*)aName
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
}

@end


