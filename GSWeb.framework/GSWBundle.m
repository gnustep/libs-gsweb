/* GSWBundle.m - GSWeb: Class GSWBundle
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

#ifdef GDL2
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
#endif // GDL2
//====================================================================
@implementation GSWBundle

//--------------------------------------------------------------------
-(id)initWithPath:(NSString*)path_
		  baseURL:(NSString*)baseURL_
{
  return [self initWithPath:path_
			   baseURL:baseURL_
			   inFrameworkNamed:nil];
};

//--------------------------------------------------------------------
-(id)initWithPath:(NSString*)path_
		  baseURL:(NSString*)baseURL_
 inFrameworkNamed:(NSString*)frameworkName_
{
  if ((self=[super init]))
	{
	  LOGObjectFnStart();
	  NSDebugMLLog(@"bundles",@"path_=%@",path_);
	  NSDebugMLLog(@"bundles",@"baseURL_=%@",baseURL_);
	  ASSIGN(path,[path_ stringGoodPath]);
	  NSDebugMLLog(@"bundles",@"path=%@",path);
	  ASSIGN(baseURL,baseURL_);
	  ASSIGN(frameworkName,frameworkName_);
	  archiveCache=[NSMutableDictionary new];
	  apiCache=[NSMutableDictionary new];
	  encodingCache=[NSMutableDictionary new];
	  pathCache=[NSMutableDictionary new];
	  urlCache=[NSMutableDictionary new];
	  stringsTableCache=[NSMutableDictionary new];
	  stringsTableArrayCache=[NSMutableDictionary new];
	  templateCache=[NSMutableDictionary new];
	  classCache=[NSMutableDictionary new];
	  selfLock=[NSRecursiveLock new];
	  LOGObjectFnStop();
	};
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWBundle");
  GSWLogC("Dealloc GSWBundle: path");
  DESTROY(path);
  GSWLogC("Dealloc GSWBundle: baseURL");
  DESTROY(baseURL);
  GSWLogC("Dealloc GSWBundle: archiveCache");
  DESTROY(archiveCache);
  GSWLogC("Dealloc GSWBundle: apiCache");
  DESTROY(apiCache);
  GSWLogC("Dealloc GSWBundle: encodingCache");
  DESTROY(encodingCache);
  GSWLogC("Dealloc GSWBundle: pathCache");
  DESTROY(pathCache);
  GSWLogC("Dealloc GSWBundle: urlCache");
  DESTROY(urlCache);
  GSWLogC("Dealloc GSWBundle: stringsTableCache");
  DESTROY(stringsTableCache);
  GSWLogC("Dealloc GSWBundle: stringsTableArrayCache");
  DESTROY(stringsTableArrayCache);
  GSWLogC("Dealloc GSWBundle: templateCache");
  DESTROY(templateCache);
  GSWLogC("Dealloc GSWBundle: classCache");
  DESTROY(classCache);
  GSWLogC("Dealloc GSWBundle: selfLock");
  DESTROY(selfLock);
  GSWLogC("Dealloc GSWBundle Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWBundle");
};

//--------------------------------------------------------------------
-(NSString*)baseURL
{
  return baseURL;
};

//--------------------------------------------------------------------
-(NSString*)path
{
  return path;
};

//--------------------------------------------------------------------
-(NSString*)frameworkName
{
  return frameworkName;
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
			   path];
//  GSWLogC("GSWBundle description C");
  descr=[descr stringByAppendingFormat:@"baseURL:[%@] frameworkName:[%@]>",
			   baseURL,
			   frameworkName];
//  GSWLogC("GSWBundle description D");
  return descr;
};

//--------------------------------------------------------------------
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"selfLockn=%d",selfLockn);
  TmpUnlock(selfLock);
#ifndef NDEBUG
	selfLockn--;
#endif
  NSDebugMLLog(@"bundles",@"selfLockn=%d",selfLockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)lock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"selfLockn=%d",selfLockn);
  TmpLockBeforeDate(selfLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
  selfLockn++;
#endif
  NSDebugMLLog(@"bundles",@"selfLockn=%d",selfLockn);
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
	  NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
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
-(id)lockedResourceNamed:(NSString*)name_
				  ofType:(NSString*)type_
		   withLanguages:(NSArray*)languages_
			  usingCache:(NSMutableDictionary*)cache_
			relativePath:(NSString**)relativePath_
			absolutePath:(NSString**)absolutePath_
{
  int _languageIndex=0;
  NSString* _relativePath=nil;
  NSString* _absolutePath=nil;
  NSString* _fileName=nil;
  NSString* _language=nil;
  id _resource=nil;
  NSString* _path=nil;
  NSFileManager* _fileManager=nil;
  int _languagesNb=nil;
  BOOL _exists=NO;
  LOGObjectFnStart();
  NSDebugMLog(@"type=%@",type_);
  _languagesNb=[languages_ count];

  _fileManager=[NSFileManager defaultManager];

  _fileName=[NSString stringWithFormat:@"%@.%@",name_,type_];
  NSDebugMLog(@"fileName=%@",_fileName);
  for(_languageIndex=0;!_resource && !_path && _languageIndex<=_languagesNb;_languageIndex++)
	{
	  _language=nil;
	  if (_languageIndex==_languagesNb)
		_relativePath=[NSString stringWithFormat:@"/%@",
							 _fileName];
	  else
		{
		  _language=[languages_ objectAtIndex:_languageIndex];
		  _relativePath=[NSString stringWithFormat:@"/%@.%@/%@",
							   _language,
							   GSLanguageSuffix,
							   _fileName];
		};
	  _absolutePath=[path stringByAppendingString:_relativePath];
	  if ([[GSWApplication application] isCachingEnabled])
		_resource=[cache_ objectForKey:_relativePath];
	  if (_resource==GSNotFoundMarker)
            {
		_resource=nil;
                _absolutePath=nil;
                _relativePath=nil;
            }
	  else if (!_resource)
		{
		  _exists=[_fileManager fileExistsAtPath:_absolutePath];
		  NSDebugMLLog(@"bundles",@"%@ _exists=%s",_absolutePath,(_exists ? "YES" : "NO"));
		  if (!_exists)
			{
			  if ([[GSWApplication application] isCachingEnabled])
				[cache_ setObject:GSNotFoundMarker
						forKey:_relativePath];
			  _relativePath=nil;
			  _absolutePath=nil;
			};
		};
	};
  if (relativePath_)
	*relativePath_=_relativePath;
  if (absolutePath_)
	*absolutePath_=_absolutePath;
  LOGObjectFnStop();
  return _resource;
};
@end

//====================================================================
@implementation GSWBundle (GSWResourceManagement)

//--------------------------------------------------------------------
-(void)initializeObject:(id)object_
       fromArchiveNamed:(NSString*)name_
{
  //OK
  NSDictionary* _archive=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"object_:%@",object_);
  NSDebugMLLog(@"bundles",@"name_:%@",name_);
  //call application _isDynamicLoadingEnabled
  //call -- isTerminating
  //call -- isCachingEnabled
  //call -- isPageRefreshOnBacktrackEnabled//0
  _archive=[self archiveNamed:name_];
  //Verify
  NSDebugMLLog(@"bundles",@"_archive:%@",_archive);
  if (_archive)
    [self initializeObject:object_
          fromArchive:_archive];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)initializeObject:(id)object_
            fromArchive:(NSDictionary*)archive_
{
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"object_:%@",object_);
  NSDebugMLLog(@"bundles",@"archive_:%@",archive_);
  [self lock];
  NS_DURING
    {
      if (!WOStrictFlag)
        {
          NSDictionary* _userDictionary=[archive_ objectForKey:@"userDictionary"];
          NSDictionary* _userAssociations=[archive_ objectForKey:@"userAssociations"];		
          NSDictionary* _defaultAssociations=[archive_ objectForKey:@"defaultAssociations"];
          NSDebugMLLog(@"bundles",@"_userDictionary:%@",_userDictionary);
          NSDebugMLLog(@"bundles",@"_userAssociations:%@",_userAssociations);
          NSDebugMLLog(@"bundles",@"_defaultAssociations:%@",_defaultAssociations);
          _userAssociations=[_userAssociations dictionaryByReplacingStringsWithAssociations];
          NSDebugMLLog(@"bundles",@"_userAssociations:%@",_userAssociations);
          _defaultAssociations=[_defaultAssociations dictionaryByReplacingStringsWithAssociations];
          NSDebugMLLog(@"bundles",@"_defaultAssociations:%@",_defaultAssociations);
          if (_userDictionary && [object_ respondsToSelector:@selector(setUserDictionary:)])
            [object_ setUserDictionary:_userDictionary];
          if (_userAssociations && [object_ respondsToSelector:@selector(setUserAssociations:)])
            [object_ setUserAssociations:_userAssociations];
          if (_defaultAssociations && [object_ respondsToSelector:@selector(setDefaultAssociations:)])
            [object_ setDefaultAssociations:_defaultAssociations];
        };
#if GDL2 // GDL2 implementation
      {
        EOKeyValueUnarchiver* unarchiver=nil;
        GSWBundleUnarchiverDelegate* bundleDelegate=nil;
        NSDictionary* variables=nil;
        NSEnumerator* variablesEnum=nil;
        id variableName=nil;
        NSDebugMLLog(@"bundles",@"archive_ %p:%@",archive_,archive_);
        unarchiver=[[[EOKeyValueUnarchiver alloc] initWithDictionary:archive_]
                     autorelease];
        NSDebugMLLog(@"bundles",@"unarchiver %p:%@",unarchiver,unarchiver);
        bundleDelegate=[[[GSWBundleUnarchiverDelegate alloc] initWithObject:object_]
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
                         [object_ class],
                         variableName,
                         variableName,
                         variableValue,
                         variableValue);
            NSDebugMLLog(@"bundles",@"BEF variableValue %p:%@ [RC=%d]",
                         variableValue,
                         variableValue,
                         [variableValue retainCount]);
            [object_ takeValue:variableValue
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
      NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,
                   [localException reason],
                   __FILE__,
                   __LINE__);
      //TODO
      [self unlock];
      [localException raise];
    };
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(Class)scriptedClassWithName:(NSString*)name_
			   superclassName:(NSString*)superclassName_
{
  //OK
  Class _class=nil;
  NSString* _pathName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"Name=%@",name_);
  NSDebugMLLog(@"bundles",@"superclassName_=%@",superclassName_);
  [self lock];
  NS_DURING
	{
	  _pathName=[self lockedScriptedClassPathWithName:name_];
	  //Verify
	  if (_pathName)
		{
		  _class=[self lockedScriptedClassWithName:name_
					   pathName:_pathName
					   superclassName:superclassName_];
		};
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return _class;
};

//--------------------------------------------------------------------
-(Class)lockedScriptedClassWithName:(NSString*)name_
						   pathName:(NSString*)pathName_
					 superclassName:(NSString*)superclassName_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)lockedScriptedClassPathWithName:(NSString*)name_
{
  NSString* _path=nil;
  id _script=nil;
  _script=[self lockedResourceNamed:name_
				ofType:GSWScriptSuffix[GSWebNamingConv]
				withLanguages:nil
				usingCache:classCache
				relativePath:NULL
				absolutePath:&_path];
  if (!_script && !_path)
    _script=[self lockedResourceNamed:name_
                  ofType:GSWScriptSuffix[GSWebNamingConvInversed]
                  withLanguages:nil
                  usingCache:classCache
                  relativePath:NULL
                  absolutePath:&_path];
  return _path;
};

//--------------------------------------------------------------------
-(Class)compiledClassWithName:(NSString*)name_
			   superclassName:(NSString*)superclassName_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(GSWElement*)templateNamed:(NSString*)name_
				  languages:(NSArray*)languages_
{
  GSWElement* _template=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"Name=%@",name_);
  //OK
  [self lock];
  NS_DURING
	{
	  _template=[self lockedTemplateNamed:name_
					  languages:languages_];
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In lockedTemplateNamed");
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  NSDebugMLLog(@"bundles",@"_template=%@",_template);
  LOGObjectFnStop();
  return _template;
};

//--------------------------------------------------------------------
-(GSWElement*)lockedTemplateNamed:(NSString*)name_
						languages:(NSArray*)languages_
{
  //OK
  GSWElement* _template=nil;
  NSString* _relativeTemplatePath=nil;
  NSString* _absoluteTemplatePath=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"Name_=%@",name_);
  NSDebugMLLog(@"bundles",@"Languages_=%@",languages_);
  NSDebugMLLog(@"bundles",@"Path=%@",path);
  NSDebugMLLog(@"bundles",@"baseURL=%@",baseURL);
  NSDebugMLLog(@"bundles",@"frameworkName=%@",frameworkName);
  _template=[self lockedResourceNamed:name_
				  ofType:GSWComponentTemplateSuffix
				  withLanguages:languages_
				  usingCache:templateCache
				  relativePath:&_relativeTemplatePath
				  absolutePath:&_absoluteTemplatePath];
  if (!_template)
	{
	  if (!_relativeTemplatePath)
		{
		  NSDebugMLLog(@"errors",@"No template named:%@ for languages:%@",
					   name_,
					   languages_);
		}
	  else
		{
		  NSStringEncoding encoding=[self encodingForResourcesNamed:name_];
		  NSString* _pageDefString=nil;
		  //TODO use encoding !
		  NSString* _htmlString=[NSString stringWithContentsOfFile:_absoluteTemplatePath];
		  NSDebugMLLog(@"bundles",@"htmlPath=%@",_absoluteTemplatePath);
		  if (!_htmlString)
			{
			  NSDebugMLLog(@"errors",@"No html file for template named:%@ for languages:%@",
						   name_,
						   languages_);
			}
		  else
			{
			  NSString* _absoluteDefinitionPath=nil;
			  _pageDefString=[self lockedResourceNamed:name_
								   ofType:GSWComponentDefinitionSuffix[GSWebNamingConv]
								   withLanguages:languages_
								   usingCache:nil
								   relativePath:NULL
								   absolutePath:&_absoluteDefinitionPath];
                          NSDebugMLLog(@"bundles",@"_absoluteDefinitionPath=%@",
                                       _absoluteDefinitionPath);
			  if (!_pageDefString && !_absoluteDefinitionPath)
                            {
                              _pageDefString=[self lockedResourceNamed:name_
                                                   ofType:GSWComponentDefinitionSuffix[GSWebNamingConvInversed]
                                                   withLanguages:languages_
                                                   usingCache:nil
                                                   relativePath:NULL
                                                   absolutePath:&_absoluteDefinitionPath];
                              NSDebugMLLog(@"bundles",@"_absoluteDefinitionPath=%@",
                                           _absoluteDefinitionPath);
                            };
                            
			  if (_absoluteDefinitionPath)
				{
				  //TODO use encoding !
				  NSDebugMLLog(@"bundles",@"_absoluteDefinitionPath=%@",
                                               _absoluteDefinitionPath);
				  _pageDefString=[NSString stringWithContentsOfFile:_absoluteDefinitionPath];
				};
#ifndef NDEBUG
			  NS_DURING
#endif
				{
				  NSDebugMLLog(@"bundles",@"GSWTemplateParser on template named %@",
                                               name_);
				  _template=[GSWTemplateParserXML templateNamed:name_
                                                                  inFrameworkNamed:[self frameworkName]
                                                                  withParserClassName:nil
                                                                  withString:_htmlString
                                                                  encoding:encoding
                                                                  fromPath:_absoluteTemplatePath
                                                                  definitionsString:_pageDefString
                                                                  languages:languages_
                                                                  definitionPath:_absoluteDefinitionPath];
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
			  GSWLogC("TemplateParsed\n");
			  NSDebugMLLog(@"bundles",@"_template=%@",_template);
			};
		  if ([[GSWApplication application] isCachingEnabled])
			{
			  if (_template)
				[templateCache setObject:_template
							   forKey:_relativeTemplatePath];
			  else
				[templateCache setObject:GSNotFoundMarker
							   forKey:_relativeTemplatePath];
			};
		};
	};
  NSDebugMLLog(@"bundles",@"_template=%@",_template);
  LOGObjectFnStop();
  return _template;
};

//--------------------------------------------------------------------
-(NSString*)stringForKey:(NSString*)key_
			inTableNamed:(NSString*)name_
		withDefaultValue:(NSString*)defaultValue_
			   languages:(NSArray*)languages_
{
  NSDictionary* _stringsTable=nil;
  NSString* _string=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"Key_=%@",key_);
  NSDebugMLLog(@"bundles",@"Name_=%@",name_);
  NSDebugMLLog(@"bundles",@"Languages_=%@",languages_);
  NSDebugMLLog(@"bundles",@"defaultValue_=%@",defaultValue_);
  _stringsTable=[self stringsTableNamed:name_
					  withLanguages:languages_];
  if (_stringsTable)
	_string=[_stringsTable objectForKey:key_];
  if (!_string)
	_string=defaultValue_;
  LOGObjectFnStop();
  return _string;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)name_
					withLanguages:(NSArray*)languages_
{
  NSDictionary* _stringsTable=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"Name_=%@",name_);
  NSDebugMLLog(@"bundles",@"Languages_=%@",languages_);
  [self lock];
  NS_DURING
	{
	  NSString* _relativePath=nil;
	  NSString* _absolutePath=nil;
	  LOGObjectFnStart();
	  _stringsTable=[self lockedResourceNamed:name_
						  ofType:GSWStringTableSuffix
						  withLanguages:languages_
						  usingCache:stringsTableCache
						  relativePath:&_relativePath
						  absolutePath:&_absolutePath];
	  if (!_stringsTable)
		{
		  if (_absolutePath)
			{
			  //TODO use encoding ??
			  _stringsTable=[NSDictionary dictionaryWithContentsOfFile:_absolutePath];
			  if (!_stringsTable)
				{
				  NSString* _tmpString=[NSString stringWithContentsOfFile:_absolutePath];
				  LOGSeriousError(@"Bad stringTable \n%@\n from file %@",
								  _tmpString,
								  _absolutePath);
				};
			  if ([[GSWApplication application] isCachingEnabled])
				{
				  if (_stringsTable)
					[stringsTableCache setObject:_stringsTable
									  forKey:_relativePath];
				  else
					[stringsTableCache setObject:GSNotFoundMarker
									  forKey:_relativePath];
				};
			};
		};
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return _stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)name_
					withLanguages:(NSArray*)languages_
{
  NSArray* _stringsTableArray=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"Name_=%@",name_);
  NSDebugMLLog(@"bundles",@"Languages_=%@",languages_);
  [self lock];
  NS_DURING
	{
	  NSString* _relativePath=nil;
	  NSString* _absolutePath=nil;
	  LOGObjectFnStart();
	  _stringsTableArray=[self lockedResourceNamed:name_
							   ofType:GSWStringTableArraySuffix
							   withLanguages:languages_
							   usingCache:stringsTableArrayCache
							   relativePath:&_relativePath
							   absolutePath:&_absolutePath];
	  if (!_stringsTableArray)
		{
		  if (_absolutePath)
			{
			  //TODO use encoding ??
			  _stringsTableArray=[NSArray arrayWithContentsOfFile:_absolutePath];
			  if (!_stringsTableArray)
				{
				  NSString* _tmpString=[NSString stringWithContentsOfFile:_absolutePath];
				  LOGSeriousError(@"Bad stringTableArray \n%@\n from file %@",
								  _tmpString,
								  _absolutePath);
				};
			  if ([[GSWApplication application] isCachingEnabled])
				{
				  if (_stringsTableArray)
					[stringsTableArrayCache setObject:_stringsTableArray
											forKey:_relativePath];
				  else
					[stringsTableArrayCache setObject:GSNotFoundMarker
											forKey:_relativePath];
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
  return _stringsTableArray;
};

//--------------------------------------------------------------------
-(NSString*)urlForResourceNamed:(NSString*)name_
						 ofType:(NSString*)type_
					  languages:(NSArray*)languages_
						request:(GSWRequest*)request_
{
  BOOL _isUsingWebServer=NO;
  NSString* _url=nil;
  LOGObjectFnStart();
  _isUsingWebServer=[request_ _isUsingWebServer];
  [self lock];
  NS_DURING
	{
	  NSString* _relativePath=nil;
	  NSString* _absolutePath=nil;
	  NSString* _baseURL=nil;
	  LOGObjectFnStart();
	  _baseURL=[self lockedResourceNamed:name_
					 ofType:type_
					 withLanguages:languages_
					 usingCache:urlCache
					 relativePath:&_relativePath
					 absolutePath:&_absolutePath];
	  if (!_baseURL)
		{
		  if (_relativePath)
			{
			  _baseURL=_relativePath;
			  if ([[GSWApplication application] isCachingEnabled])
				{
				  [pathCache setObject:_baseURL
							 forKey:_relativePath];
				};
			};
		};
	  if (_baseURL)
		{
		  if (_isUsingWebServer)
			{
			  _url=[baseURL stringByAppendingString:_baseURL];
			}
		  else
			{
			  NSString* _completePath=[path stringByAppendingString:_baseURL];
			  _url=(NSString*)[request_ _urlWithRequestHandlerKey:GSWResourceRequestHandlerKey[GSWebNamingConv]
                                                    path:nil
                                                    queryString:[NSString stringWithFormat:@"%@=%@",
                                                                          GSWKey_Data[GSWebNamingConv],
                                                                          _completePath]];//TODO Escape
			};
		};
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return _url;
};

//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)name_
						  ofType:(NSString*)type_
					   languages:(NSArray*)languages_
{
  NSString* _absolutePath=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"Name_=%@",name_);
  NSDebugMLLog(@"bundles",@"type_=%@",type_);
  NSDebugMLLog(@"bundles",@"languages_=%@",languages_);
  [self lock];
  NS_DURING
	{
	  NSString* _path=nil;
	  NSString* _relativePath=nil;
	  LOGObjectFnStart();
	  _path=[self lockedResourceNamed:name_
				  ofType:type_
				  withLanguages:languages_
				  usingCache:stringsTableCache
				  relativePath:&_relativePath
				  absolutePath:&_absolutePath];
	  if (_path)
		_absolutePath=_path;
	  else if (_absolutePath
			   &&[[GSWApplication application] isCachingEnabled])
		{
		  [pathCache setObject:_absolutePath
					 forKey:_relativePath];
		};
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return _absolutePath;
};

//--------------------------------------------------------------------
-(NSStringEncoding)encodingForResourcesNamed:(NSString*)name_
{
  NSDictionary* _archive=nil;
  NSStringEncoding _encoding=GSUndefinedEncoding;
  id _encodingObject=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  NSDebugMLLog(@"bundles",@"Name_=%@",name_);
	  NSDebugMLLog(@"bundles",@"encodingCache=%@",encodingCache);
	  NSDebugMLLog(@"bundles",@"archiveCache=%@",archiveCache);
	  _encodingObject=[encodingCache objectForKey:name_];
	  if (!_encodingObject)
		{
		  _archive=[self archiveNamed:name_];
		  if (_archive)
			{
			  _encodingObject=[_archive objectForKey:@"encoding"];
			  if (_encodingObject)
				{
				  _encodingObject=[NSNumber valueFromString:_encodingObject];
				  [encodingCache setObject:_encodingObject
								 forKey:name_];
				};
			};
		};
	  if (_encodingObject)
		_encoding=[_encodingObject unsignedIntValue];
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return _encoding;
};

//--------------------------------------------------------------------
-(NSDictionary*)archiveNamed:(NSString*)name_
{
  //OK
  NSDictionary* _archive=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"name_=%@",name_);
  [self lock];
  NS_DURING
	{
	  _archive=[self lockedArchiveNamed:name_];
	  NSDebugMLLog(@"bundles",@"_archive=%@",_archive);
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  NSDebugMLLog(@"bundles",@"_archive=%@",_archive);
  LOGObjectFnStop();
  return _archive;
};

//--------------------------------------------------------------------
-(NSDictionary*)lockedArchiveNamed:(NSString*)name_
{
  //OK
  NSDictionary* _archive=nil;
  NSString* _relativePath=nil;
  NSString* _absolutePath=nil;
  BOOL _isCachingEnabled=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"search=%@.%@",name_,GSWArchiveSuffix[GSWebNamingConv]);
  _archive=[self lockedResourceNamed:name_
				 ofType:GSWArchiveSuffix[GSWebNamingConv]
				 withLanguages:nil
				 usingCache:archiveCache
				 relativePath:&_relativePath
				 absolutePath:&_absolutePath];
  NSDebugMLLog(@"bundles",@"_archive=%p _absolutePath=%@",_archive,_absolutePath);
  if (!_archive && !_absolutePath)
    {
      NSDebugMLLog(@"bundles",@"search=%@.%@",name_,GSWArchiveSuffix[GSWebNamingConvInversed]);
      _archive=[self lockedResourceNamed:name_
                     ofType:GSWArchiveSuffix[GSWebNamingConvInversed]
                     withLanguages:nil
                     usingCache:archiveCache
                     relativePath:&_relativePath
                     absolutePath:&_absolutePath];
      NSDebugMLLog(@"bundles",@"_archive=%p _absolutePath=%@",_archive,_absolutePath);
    };
  if (!_archive)
	{
	  if (_absolutePath)
		{
		  _archive=[NSDictionary dictionaryWithContentsOfFile:_absolutePath];
		  if ([[GSWApplication application] isCachingEnabled])
			{
			  if (_archive)
				[pathCache setObject:_archive
						   forKey:_relativePath];
			  else
				[archiveCache setObject:GSNotFoundMarker
							  forKey:_relativePath];
			};
		};
	};
  NSDebugMLLog(@"bundles",@"_archive=%@",_archive);
  LOGObjectFnStop();
  return _archive;
};

//--------------------------------------------------------------------
-(NSDictionary*)apiNamed:(NSString*)name_
{
  //OK
  NSDictionary* _api=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"bundles",@"name_=%@",name_);
  [self lock];
  NS_DURING
	{
	  _api=[self lockedApiNamed:name_];
	  NSDebugMLLog(@"bundles",@"_api=%@",_api);
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"bundles",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [self unlock];
  NSDebugMLLog(@"bundles",@"_api=%@",_api);
  LOGObjectFnStop();
  return _api;
};

//--------------------------------------------------------------------
-(NSDictionary*)lockedApiNamed:(NSString*)name_
{
  //OK
  NSDictionary* _api=nil;
  NSString* _relativePath=nil;
  NSString* _absolutePath=nil;
  BOOL _isCachingEnabled=NO;
  LOGObjectFnStart();
  _api=[self lockedResourceNamed:name_
				 ofType:GSWAPISuffix
				 withLanguages:nil
				 usingCache:apiCache
				 relativePath:&_relativePath
				 absolutePath:&_absolutePath];
  if (!_api)
	{
	  if (_absolutePath)
		{
		  _api=[NSDictionary dictionaryWithContentsOfFile:_absolutePath];
		  if ([[GSWApplication application] isCachingEnabled])
			{
			  if (_api)
				[apiCache setObject:_api
						  forKey:_relativePath];
			  else
				[apiCache setObject:GSNotFoundMarker
						  forKey:_relativePath];
			};
		};
	};
  NSDebugMLLog(@"bundles",@"_api=%@",_api);
  LOGObjectFnStop();
  return _api;
};

@end

//====================================================================
@implementation GSWBundle (GSWBundleC)

//--------------------------------------------------------------------
-(id)scriptedClassNameFromClassName:(NSString*)name_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)scriptPathNameFromScriptedClassName:(NSString*)name_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

@end


