/* GSWResourceManager.m - GSWeb: Class GSWResourceManager
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>


//====================================================================
@implementation GSWResourceManager

GSWBundle* globalAppGSWBundle=nil;
GSWProjectBundle* globalAppProjectBundle=nil;
NSDictionary* globalMime=nil;
NSString* globalMimePListPathName=nil;
NSDictionary* localGS2ISOLanguages=nil;
NSDictionary* localISO2GSLanguages=nil;
NSString* globalLanguagesPListPathName=nil;

//--------------------------------------------------------------------
+(void)initialize
{
  if (self==[GSWResourceManager class])
	{
	  NSBundle* _mainBundle=nil;
	  GSWDeployedBundle* _deployedBundle=nil;
	  GSWLogC("Start GSWResourceManager +initialize");
	  if ((self=[[super superclass] initialize]))
		{
		  NSString* _bundlePath=nil;
		  _mainBundle=[GSWApplication mainBundle];
//		  NSDebugFLog(@"_mainBundle:%@",_mainBundle);
		  _bundlePath=[_mainBundle  bundlePath];
		  _deployedBundle=[GSWDeployedBundle bundleWithPath:_bundlePath];
//		  NSDebugFLog(@"_deployedBundle:%@",_deployedBundle);
	  
		  globalAppProjectBundle=[[_deployedBundle projectBundle] retain];
//		  NSDebugFLog(@"globalAppProjectBundle=%@",globalAppProjectBundle);
		  NSAssert(globalAppProjectBundle,@"no globalAppProjectBundle");
//		  LOGDumpObject(globalAppProjectBundle,2);
		  //call  _deployedBundle bundlePath
		  //call  globalAppProjectBundle bundlePath
		  //call isDebuggingEnabled
		};
	  GSWLogC("Stop GSWResourceManager +init");
	};
};

//--------------------------------------------------------------------
+(void)dealloc
{
  GSWLogC("Dealloc GSWResourceManager Class");
  DESTROY(globalAppGSWBundle);
  DESTROY(globalAppProjectBundle);
  DESTROY(globalMime);
  DESTROY(globalMimePListPathName);
  DESTROY(localGS2ISOLanguages);
  DESTROY(localISO2GSLanguages);
  DESTROY(globalLanguagesPListPathName);
  GSWLogC("End Dealloc GSWResourceManager Class");
};

//--------------------------------------------------------------------
-(id)init
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  //TODO
	  NSBundle* _mainBundle=[NSBundle mainBundle];
	  NSArray* _allFrameworks=[NSBundle allFrameworks];
	  int i=0;
	  NSString* _bundlePath=nil;
	  NSBundle* _bundle=nil;
	  NSDictionary* _infoDictionary=nil;
	  for(i=0;i<[_allFrameworks count];i++)
		{
		  _bundle=[_allFrameworks objectAtIndex:i];
		  _bundlePath=[_bundle bundlePath];
		  NSDebugMLLog(@"resmanager",@"_bundlePath=%@",_bundlePath);
		  //So what ?
		};

	  selfLock=[NSRecursiveLock new];

	  [self _validateAPI];
	  frameworkProjectBundlesCache=[NSMutableDictionary new];
	  appURLs=[NSMutableDictionary new];
	  frameworkURLs=[NSMutableDictionary new];
	  appPaths=[NSMutableDictionary new];
	  frameworkPaths=[GSWMultiKeyDictionary new];
	  urlValuedElementsData=[NSMutableDictionary new];
	  [self  _initFrameworkProjectBundles];
//	  frameworkPathsToFrameworksNames=[NSMutableDictionary new];

	  _allFrameworks=[NSBundle allFrameworks];
	  for(i=0;i<[_allFrameworks count];i++)
		{
		  _bundle=[_allFrameworks objectAtIndex:i];
		  _infoDictionary=[_bundle infoDictionary];
		  //So what ?
/*
		  NSDebugMLLog(@"resmanager",@"****_bundlePath=%@",_bundlePath);
		  NSDebugMLLog(@"resmanager",@"****[_bundle bundleName]=%@",[_bundle bundleName]);
		  _bundlePath=[_bundle bundlePath];
		  if ([_bundle bundleName])
			[frameworkPathsToFrameworksNames setObject:[_bundle bundleName]
											 forKey:_bundlePath];					  
*/
		};
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWResourceManager");
  GSWLogC("Dealloc GSWResourceManager: frameworkProjectBundlesCache");
  DESTROY(frameworkProjectBundlesCache);
  GSWLogC("Dealloc GSWResourceManager: appURLs");
  DESTROY(appURLs);
  DESTROY(frameworkURLs);
  DESTROY(appPaths);
  DESTROY(frameworkPaths);
  DESTROY(urlValuedElementsData);
  DESTROY(frameworkClassPaths);
//  DESTROY(frameworkPathsToFrameworksNames);
  GSWLogC("Dealloc GSWResourceManager: selfLock");
  DESTROY(selfLock);
  GSWLogC("Dealloc GSWResourceManager Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWResourceManager");
};

//--------------------------------------------------------------------
-(NSString*)description
{
  NSString* _dscr=nil;
  [self lock];
  NS_DURING
	{
	  _dscr=[NSString stringWithFormat:@"<%s %p - frameworkProjectBundlesCache:%p appURLs:%@ frameworkURLs:%@ appPaths:%@ frameworkPaths:%@ urlValuedElementsData:%@ frameworkClassPaths:%@>",
					   object_get_class_name(self),
					   (void*)self,
					   (void*)frameworkProjectBundlesCache,
					   appURLs,
					   frameworkURLs,
					   appPaths,
					   frameworkPaths,
					   urlValuedElementsData,
					   frameworkClassPaths];
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
  return _dscr;
};

//--------------------------------------------------------------------
-(void)_initFrameworkProjectBundles
{
  //OK
  NSArray* _allFrameworks=nil;
  int i=0;
  NSBundle* _bundle=nil;
  NSString* _frameworkName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"globalAppProjectBundle=%@",globalAppProjectBundle);
  _allFrameworks=[NSBundle allFrameworks];
  NSDebugMLLog(@"resmanager",@"allBundles=%@",[NSBundle allBundles]);
  NSDebugMLLog(@"resmanager",@"_allFrameworks=%@",_allFrameworks);
  for(i=0;i<[_allFrameworks count];i++)
	{
	  _bundle=[_allFrameworks objectAtIndex:i];
	  NSDebugMLLog(@"resmanager",@"_bundle=%@",_bundle);
	  _frameworkName=[_bundle bundleName];
	  NSDebugMLLog(@"resmanager",@"_frameworkName=%@",_frameworkName);
	  [self lockedCachedBundleForFrameworkNamed:_frameworkName];
	};
  LOGObjectFnStop();
};
/*
//--------------------------------------------------------------------
-(NSString*)frameworkNameForPath:(NSString*)path_
{
  NSString* _name=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"path_=%@",path_);
  [self lock];
  NS_DURING
	{
	  NSDebugMLLog(@"resmanager",@"frameworkPathsToFrameworksNames=%@",frameworkPathsToFrameworksNames);
	  _name=[frameworkPathsToFrameworksNames objectForKey:path_];	  
	  NSDebugMLLog(@"resmanager",@"_name=%@",_name);
	  if (!_name)
		{
		  NSArray* _allFrameworks=[NSBundle allFrameworks];
		  NSString* _bundlePath=nil;
		  NSBundle* _bundle=nil;
		  int i=0;
		  for(i=0;i<[_allFrameworks count];i++)
			{
			  _bundle=[_allFrameworks objectAtIndex:i];
			  _bundlePath=[_bundle bundlePath];
			  if (![frameworkPathsToFrameworksNames objectForKey:_bundlePath])
				{
				  NSDebugMLLog(@"resmanager",@"****_bundlePath=%@",_bundlePath);
				  NSDebugMLLog(@"resmanager",@"****[_bundle bundleName]=%@",[_bundle bundleName]);
				  if ([_bundle bundleName])
					[frameworkPathsToFrameworksNames setObject:[_bundle bundleName]
													 forKey:_bundlePath];				  
				  else
					{
					  NSDebugMLLog(@"resmanager",@"no name for bundle %@",_bundle);
					};
				};
			};
		  NSDebugMLLog(@"resmanager",@"frameworkPathsToFrameworksNames=%@",frameworkPathsToFrameworksNames);
		  _name=[frameworkPathsToFrameworksNames objectForKey:path_];	  
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
  LOGObjectFnStop();
  return _name;
  
};
*/
//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)name_
					 inFramework:(NSString*)frameworkName_
					   languages:(NSArray*)languages_
{
  //OK
  NSString* _path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"name_=%@ frameworkName_=%@ languages_=%@",name_,frameworkName_,languages_);
  [self lock];
  NS_DURING
	{
	  _path=[self lockedPathForResourceNamed:name_
				  inFramework:frameworkName_
				  languages:languages_];
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
  LOGObjectFnStop();
  return _path;
};

//--------------------------------------------------------------------
-(NSString*)urlForResourceNamed:(NSString*)name_
					inFramework:(NSString*)frameworkName_
					   languages:(NSArray*)languages_
						request:(GSWRequest*)request_
{
  //OK
  NSString* _url=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"name_=%@ frameworkName_=%@ languages_=%@ request_=%@",name_,frameworkName_,languages_,request_);
//  NSDebugMLLog(@"resmanager",@"[frameworkProjectBundlesCache count]=%d",[frameworkProjectBundlesCache count]);
//  NSDebugMLLog(@"resmanager",@"frameworkProjectBundlesCache=%@",frameworkProjectBundlesCache);
  [self lock];
  NS_DURING
	{
	  _url=[self lockedUrlForResourceNamed:name_
				 inFramework:frameworkName_
				 languages:languages_
				 request:request_];
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
//  NSDebugMLLog(@"resmanager",@"[frameworkProjectBundlesCache count]=%d",[frameworkProjectBundlesCache count]);
//  NSDebugMLLog(@"resmanager",@"frameworkProjectBundlesCache=%@",frameworkProjectBundlesCache);
  LOGObjectFnStop();
  return _url;
};

//--------------------------------------------------------------------
-(NSString*)stringForKey:(NSString*)key_
			inTableNamed:(NSString*)tableName_
		withDefaultValue:(NSString*)defaultValue_
			 inFramework:(NSString*)framework_
			   languages:(NSArray*)languages_
{
  NSString* _string=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  _string=[self lockedStringForKey:key_
					inTableNamed:tableName_
					inFramework:framework_
					languages:languages_];
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
  if (!_string)
	_string=defaultValue_;
  LOGObjectFnStop();
  return _string;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)tableName_
					  inFramework:(NSString*)frameworkName_
						languages:(NSArray*)languages_;
{
  NSDictionary* _stringsTable=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"tableName=%@ frameworkName=%@",tableName_,frameworkName_);
  [self lock];
  NS_DURING
	{
	  _stringsTable=[self lockedStringsTableNamed:tableName_
						  inFramework:frameworkName_
						  languages:languages_];
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
  LOGObjectFnStop();
  return _stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)tableName_
				 inFramework:(NSString*)frameworkName_
				   languages:(NSArray*)languages_;
{
  NSArray* _stringsTableArray=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"tableName=%@ frameworkName=%@",tableName_,frameworkName_);
  [self lock];
  NS_DURING
	{
	  _stringsTableArray=[self lockedStringsTableArrayNamed:tableName_
							   inFramework:frameworkName_
							   languages:languages_];
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
  LOGObjectFnStop();
  return _stringsTableArray;
};

//--------------------------------------------------------------------
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"selfLockn=%d",selfLockn);
  TmpUnlock(selfLock);
#ifndef NDEBUG
	selfLockn--;
#endif
  NSDebugMLLog(@"resmanager",@"selfLockn=%d",selfLockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)lock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"selfLockn=%d",selfLockn);
  TmpLockBeforeDate(selfLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
  selfLockn++;
#endif
  NSDebugMLLog(@"resmanager",@"selfLockn=%d",selfLockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSString*)lockedStringForKey:(NSString*)key_
				  inTableNamed:(NSString*)tableName_
				   inFramework:(NSString*)frameworkName_
					 languages:(NSArray*)languages_
{
  //OK
  NSString* _string=nil;
  NSString* _language=nil;
  int i=0;
  int _count=0;
#if !GSWEB_STRICT
  int iFramework=0;
  NSArray* _frameworks=nil;
#endif
  NSString* _frameworkName=nil;
  LOGObjectFnStart();
#if !GSWEB_STRICT
  if ([frameworkName_ isEqualToString:GSWFramework_all])
	{
	  _frameworks=[frameworkProjectBundlesCache allKeys];
	  _frameworks=[_frameworks arrayByAddingObject:@""];
	}
  else
	  _frameworks=[NSArray arrayWithObject:frameworkName_ ? frameworkName_ : @""];
#else
  _frameworkName=frameworkName_;
#endif
  _count=[languages_ count];
  NSDebugMLLog(@"resmanager",@"languages_=%@",languages_);
  NSDebugMLLog(@"resmanager",@"_frameworks=%@",_frameworks);
  for(i=0;!_string && i<=_count;i++)
	{
	  if (i<_count)
		_language=[languages_ objectAtIndex:i];
	  else
		_language=nil;
#if !GSWEB_STRICT
	  for(iFramework=0;!_string && iFramework<[_frameworks count];iFramework++)
		{
		  _frameworkName=[_frameworks objectAtIndex:iFramework];
		  if ([_frameworkName length]==0)
			_frameworkName=nil;
#endif
		  _string=[self lockedCachedStringForKey:key_
						inTableNamed:tableName_
						inFramework:_frameworkName
						language:_language];
#if !GSWEB_STRICT
		};
#endif
	};
  LOGObjectFnStop();
  return _string;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)lockedStringsTableNamed:(NSString*)tableName_
							inFramework:(NSString*)frameworkName_
							  languages:(NSArray*)languages_
{
  //OK
  NSDictionary* _stringsTable=nil;
  NSString* _language=nil;
  int i=0;
  int _count=0;
#if !GSWEB_STRICT
  int iFramework=0;
  NSArray* _frameworks=nil;
#endif
  NSString* _frameworkName=nil;
  LOGObjectFnStart();
  _count=[languages_ count];
#if !GSWEB_STRICT
  if ([frameworkName_ isEqualToString:GSWFramework_all])
	{
	  _frameworks=[frameworkProjectBundlesCache allKeys];
	  _frameworks=[_frameworks arrayByAddingObject:@""];
	}
  else
	  _frameworks=[NSArray arrayWithObject:frameworkName_ ? frameworkName_ : @""];
#else
  _frameworkName=frameworkName_;
#endif
  for(i=0;!_stringsTable && i<_count;i++)
	{
	  _language=[languages_ objectAtIndex:i];
#if !GSWEB_STRICT
	  for(iFramework=0;!_stringsTable && iFramework<[_frameworks count];iFramework++)
		{
		  _frameworkName=[_frameworks objectAtIndex:iFramework];
		  if ([_frameworkName length]==0)
			_frameworkName=nil;
#endif
		  _stringsTable=[self lockedCachedStringsTableWithName:tableName_
							  inFramework:_frameworkName
							  language:_language];
#if !GSWEB_STRICT
		};
#endif
	};
  LOGObjectFnStop();
  return _stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)lockedStringsTableArrayNamed:(NSString*)tableName_
							inFramework:(NSString*)frameworkName_
							  languages:(NSArray*)languages_
{
  //OK
  NSArray* _stringsTableArray=nil;
  NSString* _language=nil;
  int i=0;
  int _count=0;
#if !GSWEB_STRICT
  int iFramework=0;
  NSArray* _frameworks=nil;
#endif
  NSString* _frameworkName=nil;
  LOGObjectFnStart();
  _count=[languages_ count];
#if !GSWEB_STRICT
  if ([frameworkName_ isEqualToString:GSWFramework_all])
	{
	  _frameworks=[frameworkProjectBundlesCache allKeys];
	  _frameworks=[_frameworks arrayByAddingObject:@""];
	}
  else
	  _frameworks=[NSArray arrayWithObject:frameworkName_ ? frameworkName_ : @""];
#else
  _frameworkName=frameworkName_;
#endif
  for(i=0;!_stringsTableArray && i<_count;i++)
	{
	  _language=[languages_ objectAtIndex:i];
#if !GSWEB_STRICT
	  for(iFramework=0;!_stringsTableArray && iFramework<[_frameworks count];iFramework++)
		{
		  _frameworkName=[_frameworks objectAtIndex:iFramework];
		  if ([_frameworkName length]==0)
			_frameworkName=nil;
#endif
		  _stringsTableArray=[self lockedCachedStringsTableArrayWithName:tableName_
								   inFramework:_frameworkName
								   language:_language];
#if !GSWEB_STRICT
		};
#endif
	};
  LOGObjectFnStop();
  return _stringsTableArray;
};

//--------------------------------------------------------------------
-(NSString*)lockedCachedStringForKey:(NSString*)key_
						inTableNamed:(NSString*)tableName_ 
						 inFramework:(NSString*)frameworkName_
							language:(NSString*)language_
{
  //OK
  NSString* _string=nil;
  NSDictionary* _stringsTable=nil;
  LOGObjectFnStart();
  _stringsTable=[self lockedCachedStringsTableWithName:tableName_
					  inFramework:frameworkName_
					  language:language_];
  if (_stringsTable)
	_string=[_stringsTable objectForKey:key_];
  LOGObjectFnStop();
  return _string;
};

//--------------------------------------------------------------------
-(NSDictionary*)lockedCachedStringsTableWithName:(NSString*)tableName_ 
									 inFramework:(NSString*)frameworkName_
										language:(NSString*)language_
{
  //OK
  NSDictionary* _stringsTable=nil;
  LOGObjectFnStart();
  _stringsTable=[self  lockedStringsTableWithName:tableName_ 
					   inFramework:frameworkName_
					   language:language_];
  LOGObjectFnStop();
  return _stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)lockedCachedStringsTableArrayWithName:(NSString*)tableName_ 
									 inFramework:(NSString*)frameworkName_
										language:(NSString*)language_
{
  //OK
  NSArray* _stringsTableArray=nil;
  LOGObjectFnStart();
  _stringsTableArray=[self  lockedStringsTableArrayWithName:tableName_ 
							inFramework:frameworkName_
							language:language_];
  LOGObjectFnStop();
  return _stringsTableArray;
};

//--------------------------------------------------------------------
-(NSDictionary*)lockedStringsTableWithName:(NSString*)tableName_ 
							   inFramework:(NSString*)frameworkName_
								  language:(NSString*)language_
{
  //OK
  NSDictionary* _stringsTable=nil;
  NSString* _relativePath=nil;
  NSString* _path=nil;
  GSWDeployedBundle* _bundle=nil;
  NSString* _resourceName=nil;
#if !GSWEB_STRICT
  int i=0;
  NSArray* _frameworks=nil;
#endif
  NSString* _frameworkName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"tableName_=%@ frameworkName_=%@ language_=%@",tableName_,frameworkName_,language_);
  _resourceName=[tableName_ stringByAppendingString:GSWStringTablePSuffix];
#if !GSWEB_STRICT
  if ([frameworkName_ isEqualToString:GSWFramework_all])
	{
	  _frameworks=[frameworkProjectBundlesCache allKeys];
	  _frameworks=[_frameworks arrayByAddingObject:@""];
	}
  else
	  _frameworks=[NSArray arrayWithObject:frameworkName_ ? frameworkName_ : @""];
#else
  _frameworkName=frameworkName_;
#endif

#if !GSWEB_STRICT
  for(i=0;!_path && i<[_frameworks count];i++)
	{
	  _frameworkName=[_frameworks objectAtIndex:i];
	  if ([_frameworkName length]==0)
		_frameworkName=nil;
#endif		
	  if (_frameworkName)
		{
//		  NSDebugMLLog(@"resmanager",@"frameworkName=%@",frameworkName_);
		  _bundle=[self lockedCachedBundleForFrameworkNamed:_frameworkName];
		  if (_bundle)
			{
//			  NSDebugMLLog(@"resmanager",@"found cached bundle=%@",_bundle);
			  _relativePath=[_bundle relativePathForResourceNamed:_resourceName
									 forLanguage:language_];
//			  NSDebugMLLog(@"resmanager",@"_relativePath=%@",_relativePath);
			  if (_relativePath)
				{
				  _path=[[_bundle bundlePath] stringByAppendingPathComponent:_relativePath];
				};
			};
		}
	  else
		{
//		  NSDebugMLLog(@"resmanager",@"globalAppProjectBundle=%@",globalAppProjectBundle);
		  _relativePath=[globalAppProjectBundle relativePathForResourceNamed:_resourceName
												forLanguage:language_];
//		  NSDebugMLLog(@"resmanager",@"_relativePath=%@",_relativePath);
		  if (_relativePath)
			{
			  NSString* _applicationPath=[GSWApp path];
			  _path=[_applicationPath stringByAppendingPathComponent:_relativePath];
			};
		};
#if !GSWEB_STRICT
	};
#endif
//  NSDebugMLLog(@"resmanager",@"_path=%@",_path);
  if (_path)
	{
	  //TODO use encoding ??
	  _stringsTable=[NSDictionary dictionaryWithContentsOfFile:_path];
	  if (!_stringsTable)
		{
		  NSString* _tmpString=[NSString stringWithContentsOfFile:_path];
		  LOGSeriousError(@"Bad stringTable \n%@\n from file %@",
						  _tmpString,
						  _path);
		};
	};
//  NSDebugMLLog(@"resmanager",@"_stringsTable=%@",_stringsTable);
  LOGObjectFnStop();
  return _stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)lockedStringsTableArrayWithName:(NSString*)tableName_ 
							   inFramework:(NSString*)frameworkName_
								  language:(NSString*)language_
{
  //OK
  NSArray* _stringsTableArray=nil;
  NSString* _relativePath=nil;
  NSString* _path=nil;
  GSWDeployedBundle* _bundle=nil;
  NSString* _resourceName=nil;
#if !GSWEB_STRICT
  int i=0;
  NSArray* _frameworks=nil;
#endif
  NSString* _frameworkName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"tableName_=%@ frameworkName_=%@ language_=%@",tableName_,frameworkName_,language_);
  _resourceName=[tableName_ stringByAppendingString:GSWStringTableArrayPSuffix];
#if !GSWEB_STRICT
  if ([frameworkName_ isEqualToString:GSWFramework_all])
	{
	  _frameworks=[frameworkProjectBundlesCache allKeys];
	  _frameworks=[_frameworks arrayByAddingObject:@""];
	}
  else
	  _frameworks=[NSArray arrayWithObject:frameworkName_ ? frameworkName_ : @""];
#else
  _frameworkName=frameworkName_;
#endif

#if !GSWEB_STRICT
  for(i=0;!_path && i<[_frameworks count];i++)
	{
	  _frameworkName=[_frameworks objectAtIndex:i];
	  if ([_frameworkName length]==0)
		_frameworkName=nil;
#endif		
	  if (_frameworkName)
		{
//		  NSDebugMLLog(@"resmanager",@"frameworkName=%@",frameworkName_);
		  _bundle=[self lockedCachedBundleForFrameworkNamed:_frameworkName];
		  if (_bundle)
			{
//			  NSDebugMLLog(@"resmanager",@"found cached bundle=%@",_bundle);
			  _relativePath=[_bundle relativePathForResourceNamed:_resourceName
									 forLanguage:language_];
//			  NSDebugMLLog(@"resmanager",@"_relativePath=%@",_relativePath);
			  if (_relativePath)
				{
				  _path=[[_bundle bundlePath] stringByAppendingPathComponent:_relativePath];
				};
			};
		}
	  else
		{
//		  NSDebugMLLog(@"resmanager",@"globalAppProjectBundle=%@",globalAppProjectBundle);
		  _relativePath=[globalAppProjectBundle relativePathForResourceNamed:_resourceName
												forLanguage:language_];
//		  NSDebugMLLog(@"resmanager",@"_relativePath=%@",_relativePath);
		  if (_relativePath)
			{
			  NSString* _applicationPath=[GSWApp path];
			  _path=[_applicationPath stringByAppendingPathComponent:_relativePath];
			};
		};
#if !GSWEB_STRICT
	};
#endif
//  NSDebugMLLog(@"resmanager",@"_path=%@",_path);
  if (_path)
	{
	  //TODO use encoding ??
	  _stringsTableArray=[NSArray arrayWithContentsOfFile:_path];
	  if (!_stringsTableArray)
		{
		  NSString* _tmpString=[NSString stringWithContentsOfFile:_path];
		  LOGSeriousError(@"Bad stringTableArray \n%@\n from file %@",
						  _tmpString,
						  _path);
		};
	};
  LOGObjectFnStop();
  return _stringsTableArray;
};

//--------------------------------------------------------------------
-(NSString*)lockedUrlForResourceNamed:(NSString*)name_
						  inFramework:(NSString*)frameworkName_
							languages:(NSArray*)languages_
							  request:(GSWRequest*)_request
{
  //OK	TODOV
  NSString* _url=nil;
  BOOL _isUsingWebServer=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"name_=%@ frameworkName_=%@ languages_=%@ _request=%@",name_,frameworkName_,languages_,_request);
//  NSDebugMLLog(@"resmanager",@"[frameworkProjectBundlesCache count]=%d",[frameworkProjectBundlesCache count]);
//  NSDebugMLLog(@"resmanager",@"frameworkProjectBundlesCache=%@",frameworkProjectBundlesCache);
  _isUsingWebServer=!_request || [_request _isUsingWebServer];
  NSDebugMLLog(@"resmanager",@"_isUsingWebServer=%s",(_isUsingWebServer ? "YES" : "NO"));
  if (_isUsingWebServer)
	{
	  _url=[self lockedCachedURLForResourceNamed:name_
				 inFramework:frameworkName_
				 languages:languages_];
	}
  else
	{
	  NSString* _path=[self pathForResourceNamed:name_
							inFramework:frameworkName_
							languages:languages_];
	  if (_path)
		{
		  GSWURLValuedElementData* _cachedData=[self _cachedDataForKey:_path];
		  if (!_cachedData)
			{
			  NSString* _type=[self contentTypeForResourcePath:_url];
			  [self setData:nil
					forKey:_path
					mimeType:_type
					session:nil];
			};
		}
	  else
		_path=[NSString stringWithFormat:@"ERROR_NOT_FOUND_framework_*%@*_filename_%@",
						frameworkName_,
						name_];
	  _url=[_request _urlWithRequestHandlerKey:GSWResourceRequestHandlerKey
					 path:nil
					 queryString:[NSString stringWithFormat:
											 @"%@=%@",
										   GSWKey_Data,
										   _path]];//TODO Escape
	};
//  NSDebugMLLog(@"resmanager",@"[frameworkProjectBundlesCache count]=%d",[frameworkProjectBundlesCache count]);
//  NSDebugMLLog(@"resmanager",@"frameworkProjectBundlesCache=%@",frameworkProjectBundlesCache);
  LOGObjectFnStop();
  return _url;
};

//--------------------------------------------------------------------
-(NSString*)lockedCachedURLForResourceNamed:(NSString*)name_
								inFramework:(NSString*)frameworkName_
								  languages:(NSArray*)languages_
{
  //OK
  NSString* _url=nil;
  NSString* _relativePath=nil;
  GSWDeployedBundle* _bundle=nil;
#if !GSWEB_STRICT
  int i=0;
  NSArray* _frameworks=nil;
#endif
  NSString* _frameworkName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"name_=%@ frameworkName_=%@ languages_=%@",name_,frameworkName_,languages_);
#if !GSWEB_STRICT
  if ([frameworkName_ isEqualToString:GSWFramework_all])
	{
	  _frameworks=[frameworkProjectBundlesCache allKeys];
	  _frameworks=[_frameworks arrayByAddingObject:@""];
	}
  else
	  _frameworks=[NSArray arrayWithObject:frameworkName_ ? frameworkName_ : @""];
#else
  _frameworkName=frameworkName_;
#endif

#if !GSWEB_STRICT
  for(i=0;!_url && i<[_frameworks count];i++)
	{
	  _frameworkName=[_frameworks objectAtIndex:i];
	  if ([_frameworkName length]==0)
		_frameworkName=nil;
#endif
	  if (_frameworkName)
		{
//		  NSDebugMLLog(@"resmanager",@"frameworkName=%@",_frameworkName);
		  _bundle=[self lockedCachedBundleForFrameworkNamed:_frameworkName];
		  if (_bundle)
			{
//			  NSDebugMLLog(@"resmanager",@"found cached bundle=%@",_bundle);
			  _relativePath=[_bundle relativePathForResourceNamed:name_
									 forLanguages:languages_];
//			  NSDebugMLLog(@"resmanager",@"_relativePath=%@",_relativePath);
			  if (_relativePath)
				{
				  //TODOV
				  NSString* _applicationBaseURL=[GSWApplication applicationBaseURL];
				  NSString* _wrapperName=[_bundle wrapperName];
				  NSDebugMLLog(@"resmanager",@"_applicationBaseURL=%@",_applicationBaseURL);
				  NSDebugMLLog(@"resmanager",@"_wrapperName=%@",_wrapperName);
				  _url=[_applicationBaseURL stringByAppendingPathComponent:_wrapperName];
				  NSDebugMLLog(@"resmanager",@"_url=%@",_url);
				  _url=[_url stringByAppendingPathComponent:_relativePath];
				  NSDebugMLLog(@"resmanager",@"_url=%@",_url);
				};
			};
		}
	  else
		{
		  NSDebugMLLog(@"resmanager",@"globalAppProjectBundle=%@",globalAppProjectBundle);
		  _relativePath=[globalAppProjectBundle relativePathForResourceNamed:name_
												forLanguages:languages_];
		  NSDebugMLLog(@"resmanager",@"_relativePath=%@",_relativePath);
		  if (_relativePath)
			{
			  NSString* _applicationBaseURL=[GSWApplication applicationBaseURL];
			  NSString* _wrapperName=[globalAppProjectBundle wrapperName];
			  NSDebugMLLog(@"resmanager",@"_applicationBaseURL=%@",_applicationBaseURL);
			  NSDebugMLLog(@"resmanager",@"_wrapperName=%@",_wrapperName);
			  _url=[_applicationBaseURL stringByAppendingPathComponent:_wrapperName];
			  _url=[_url stringByAppendingPathComponent:_relativePath];
			};
		};
#if !GSWEB_STRICT
	};
#endif
  if (!_url)
	{
	  LOGSeriousError(@"No URL for resource named: %@ in framework named: %@ for languages: %@",
					  name_,
					  frameworkName_,
					  languages_);
	};
//  NSDebugMLLog(@"resmanager",@"[frameworkProjectBundlesCache count]=%d",[frameworkProjectBundlesCache count]);
//  NSDebugMLLog(@"resmanager",@"frameworkProjectBundlesCache=%@",frameworkProjectBundlesCache);
//  NSDebugMLLog(@"resmanager",@"_url=%@",_url);
  LOGObjectFnStop();
  return _url;
};

//--------------------------------------------------------------------
-(NSString*)lockedPathForResourceNamed:(NSString*)name_
						   inFramework:(NSString*)frameworkName_
							 languages:(NSArray*)languages_
{ 
  NSString* _path=nil;
  NSString* _relativePath=nil;
  GSWDeployedBundle* _bundle=nil;
#if !GSWEB_STRICT
  int i=0;
  NSArray* _frameworks=nil;
  NSString* _frameworkName=nil;
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"name_=%@ frameworkName_=%@ languages_=%@",name_,frameworkName_,languages_);
#if !GSWEB_STRICT
  if ([frameworkName_ isEqualToString:GSWFramework_all])
	{
	  _frameworks=[frameworkProjectBundlesCache allKeys];
	  _frameworks=[_frameworks arrayByAddingObject:@""];
	}
  else
	  _frameworks=[NSArray arrayWithObject:frameworkName_ ? frameworkName_ : @""];
#else
  _frameworkName=frameworkName_;
#endif


#if !GSWEB_STRICT
  for(i=0;!_path && i<[_frameworks count];i++)
	{
	  _frameworkName=[_frameworks objectAtIndex:i];
	  if ([_frameworkName length]==0)
		_frameworkName=nil;
#endif
	  if (_frameworkName)
		{
//		  NSDebugMLLog(@"resmanager",@"frameworkName=%@",_frameworkName);
		  _bundle=[self lockedCachedBundleForFrameworkNamed:_frameworkName];
		  if (_bundle)
			{
//			  NSDebugMLLog(@"resmanager",@"found cached bundle=%@",_bundle);
			  _relativePath=[_bundle relativePathForResourceNamed:name_
									 forLanguages:languages_];
//			  NSDebugMLLog(@"resmanager",@"_relativePath=%@",_relativePath);
			  if (_relativePath)
				{
				  _path=[[_bundle bundlePath] stringByAppendingPathComponent:_relativePath];
				};
			};
		}
	  else
		{
		  NSDebugMLLog(@"resmanager",@"globalAppProjectBundle=%@",globalAppProjectBundle);
		  _relativePath=[globalAppProjectBundle relativePathForResourceNamed:name_
												forLanguages:languages_];
		  NSDebugMLLog(@"resmanager",@"_relativePath=%@",_relativePath);
		  if (_relativePath)
			{
			  NSString* _applicationPath=[GSWApp path];
			  _path=[_applicationPath stringByAppendingPathComponent:_relativePath];
			};
		};
#if !GSWEB_STRICT
	};
#endif
//  NSDebugMLLog(@"resmanager",@"_path=%@",_path);
  LOGObjectFnStop();
  return _path;
};

//--------------------------------------------------------------------
-(GSWDeployedBundle*)lockedCachedBundleForFrameworkNamed:(NSString*)name_
{
  //OK
  GSWDeployedBundle* _bundle=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"name_=%@",name_);
//  NSDebugMLLog(@"resmanager",@"frameworkProjectBundlesCache=%@",frameworkProjectBundlesCache);
  if ([name_ isEqualToString:GSWFramework_app])
	{
	  name_=[globalAppProjectBundle projectName];
	  _bundle=globalAppProjectBundle;
	}
  else
	_bundle=[frameworkProjectBundlesCache objectForKey:name_];
//  NSDebugMLLog(@"resmanager",@"bundle %@ %s cached",name_,(_bundle ? "" : "NOT"));
  if (!_bundle)
	{
	  NSArray* _allFrameworks=[NSBundle allFrameworks];
	  int i=0;
	  NSString* _bundlePath=nil;
	  NSBundle* _tmpBundle=nil;
	  NSDictionary* _infoDict=nil;
	  NSString* _frameworkName=nil;
	  GSWDeployedBundle* _projectBundle=nil;
	  for(i=0;!_bundle && i<[_allFrameworks count];i++)
		{
		  _tmpBundle=[_allFrameworks objectAtIndex:i];
//		  NSDebugMLLog(@"resmanager",@"_tmpBundle=%@",_tmpBundle);
		  _bundlePath=[_tmpBundle bundlePath];
//		  NSDebugMLLog(@"resmanager",@"_bundlePath=%@",_bundlePath);
		  _frameworkName=[_bundlePath lastPathComponent];
//		  NSDebugMLLog(@"resmanager",@"_frameworkName=%@",_frameworkName);
		  _frameworkName=[_frameworkName stringByDeletingPathExtension];
//		  NSDebugMLLog(@"resmanager",@"_frameworkName=%@",_frameworkName);
		  if ([_frameworkName isEqualToString:name_])
			{
			  _bundle=[GSWDeployedBundle bundleWithPath:_bundlePath];
			  NSDebugMLLog(@"resmanager",@"_bundle=%@",_bundle);
/*			  _projectBundle=[GSWProjectBundle projectBundleForProjectNamed:name_
											  isFramework:YES];
			  NSDebugMLLog(@"resmanager",@"_projectBundle=%@",_projectBundle);
			  if (_projectBundle)
				{
				  //TODO
				};
*/
			  [frameworkProjectBundlesCache setObject:_bundle
											forKey:name_];
//			  NSDebugMLLog(@"resmanager",@"frameworkProjectBundlesCache=%@",frameworkProjectBundlesCache);
			};
		};
	};
//  NSDebugMLLog(@"resmanager",@"frameworkProjectBundlesCache=%@",frameworkProjectBundlesCache);
//  NSDebugMLLog(@"resmanager",@"_bundle=%@",_bundle);
  LOGObjectFnStop();
  return _bundle;
};

@end

//====================================================================
@implementation GSWResourceManager (GSWURLValuedElementsDataCaching)

//--------------------------------------------------------------------
-(void)flushDataCache
{
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  [urlValuedElementsData removeAllObjects];
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
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)setURLValuedElementData:(GSWURLValuedElementData*)data_
{
  LOGObjectFnStart();
  [self lock];
  NSDebugMLLog(@"resmanager",@"data_=%@",data_);
  NS_DURING
	{
	  [self lockedCacheData:data_];
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
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)setData:(NSData*)data_
		forKey:(NSString*)key_
	  mimeType:(NSString*)type_
	   session:(GSWSession*)session_ //unused
{
  GSWURLValuedElementData* _dataValue=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"data_=%@",data_);
  NSDebugMLLog(@"resmanager",@"key_=%@",key_);
  NSDebugMLLog(@"resmanager",@"type_=%@",type_);
  _dataValue=[[[GSWURLValuedElementData alloc] initWithData:data_
											   mimeType:type_
											   key:key_] autorelease];
  NSDebugMLLog(@"resmanager",@"_dataValue=%@",_dataValue);
  [self setURLValuedElementData:_dataValue];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)removeDataForKey:(NSString*)key_
				session:(GSWSession*)session_ //unused
{
  LOGObjectFnStart();
  [self lock];
  NS_DURING
	{
	  [self lockedRemoveDataForKey:key_];
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
  LOGObjectFnStop();
};

@end


//====================================================================
@implementation GSWResourceManager (GSWResourceManagerA)

//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)name_
					 inFramework:(NSString*)frameworkName_
						language:(NSString*)language_
{
  //OK
  NSString* _path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"name_=%@ frameworkName_=%@ language_=%@",name_,frameworkName_,language_);
//  NSDebugMLLog(@"resmanager",@"[frameworkProjectBundlesCache count]=%d",[frameworkProjectBundlesCache count]);
//  NSDebugMLLog(@"resmanager",@"frameworkProjectBundlesCache=%@",frameworkProjectBundlesCache);
  [self lock];
  NS_DURING
	{
	  _path=[self lockedPathForResourceNamed:name_
				  inFramework:frameworkName_
				  language:language_];
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
  LOGObjectFnStop();
  return _path;
};

//--------------------------------------------------------------------
-(NSString*)lockedPathForResourceNamed:(NSString*)name_
					  inFramework:(NSString*)frameworkName_
						 language:(NSString*)language_
{
  //OK
  NSString* _path=nil;
  NSString* _relativePath=nil;
  GSWDeployedBundle* _bundle=nil;
#if !GSWEB_STRICT
  int i=0;
  NSArray* _frameworks=nil;
#endif
  NSString* _frameworkName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"name_=%@ frameworkName_=%@ language_=%@",name_,frameworkName_,language_);
//  NSDebugMLLog(@"resmanager",@"frameworkProjectBundlesCache=%@",frameworkProjectBundlesCache);
#if !GSWEB_STRICT
  if ([frameworkName_ isEqualToString:GSWFramework_all])
	{
	  _frameworks=[frameworkProjectBundlesCache allKeys];
	  _frameworks=[_frameworks arrayByAddingObject:@""];
	}
  else
	  _frameworks=[NSArray arrayWithObject:frameworkName_ ? frameworkName_ : @""];
#else
  _frameworkName=frameworkName_;
#endif

#if !GSWEB_STRICT
  for(i=0;!_path && i<[_frameworks count];i++)
	{
	  _frameworkName=[_frameworks objectAtIndex:i];
	  if ([_frameworkName length]==0)
		_frameworkName=nil;
#endif
	  if (_frameworkName)
		{
//		  NSDebugMLLog(@"resmanager",@"frameworkName=%@",_frameworkName);
		  _bundle=[self lockedCachedBundleForFrameworkNamed:_frameworkName];
		  if (_bundle)
			{
//			  NSDebugMLLog(@"resmanager",@"found cached bundle=%@",_bundle);
			  _relativePath=[_bundle relativePathForResourceNamed:name_
									 forLanguage:language_];
//			  NSDebugMLLog(@"resmanager",@"_relativePath=%@",_relativePath);
			  if (_relativePath)
				{
				  _path=[[_bundle bundlePath] stringByAppendingPathComponent:_relativePath];
				};
			};
		}
	  else
		{
		  NSDebugMLLog(@"resmanager",@"globalAppProjectBundle=%@",globalAppProjectBundle);
		  _relativePath=[globalAppProjectBundle relativePathForResourceNamed:name_
												forLanguage:language_];
		  NSDebugMLLog(@"resmanager",@"_relativePath=%@",_relativePath);
		  if (_relativePath)
			{
			  NSString* _applicationPath=[GSWApp path];
			  _path=[_applicationPath stringByAppendingPathComponent:_relativePath];
			};
		};
#if !GSWEB_STRICT
	};
#endif
//  NSDebugMLLog(@"resmanager",@"_path=%@",_path);
  LOGObjectFnStop();
  return _path;
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
  NSArray* _array=nil;
  LOGObjectFnStart();
  _array=[frameworkProjectBundlesCache allValues];
  LOGObjectFnStop();
  return _array;
};

//--------------------------------------------------------------------
-(void)lockedRemoveDataForKey:(NSString*)key
{
  LOGObjectFnStart();
  [urlValuedElementsData removeObjectForKey:key];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(BOOL)_doesRequireJavaVirualMachine
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(id)_absolutePathForJavaClassPath:(NSString*)_path
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(GSWURLValuedElementData*)_cachedDataForKey:(NSString*)key
{
  //OK
  GSWURLValuedElementData* _data=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"key=%@",key);
  [self lock];
  NS_DURING
	{
	  _data=[urlValuedElementsData objectForKey:key];
	  NSDebugMLLog(@"resmanager",@"_data=%@",_data);
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
  LOGObjectFnStop();
  return _data;
};

//--------------------------------------------------------------------
-(void)lockedCacheData:(GSWURLValuedElementData*)data_
{
  //OK
  NSData* _data=nil;
  BOOL _isTemporary=NO;
  NSString* _key=nil;
  NSString* _type=nil;
  LOGObjectFnStart();
  _data=[data_ data];
  _isTemporary=[data_ isTemporary];
  _key=[data_ key];
  _type=[data_ type];
  [self lock];
  NS_DURING
	{
	  if (!urlValuedElementsData)
		urlValuedElementsData=[NSMutableDictionary new];
	  [urlValuedElementsData setObject:data_
							 forKey:_key];
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
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSString*)contentTypeForResourcePath:(NSString*)_path
{
  //OK
  NSString* _type=nil;
  NSString* _extension=nil;
  NSDictionary* _tmpMimeTypes=nil;
  NSMutableDictionary* _mimeTypes=[NSMutableDictionary dictionary];
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"_path=%@",_path);
  _extension=[_path pathExtension];
  NSDebugMLLog(@"resmanager",@"_extension=%@",_extension);
  if (_extension)
	{
	  _extension=[_extension lowercaseString];
	  NSDebugMLLog(@"resmanager",@"_extension=%@",_extension);
	  _type=[globalMime objectForKey:_extension];
	  NSDebugMLLog(@"resmanager",@"_type=%@",_type);
	};
  if (!_type)
	_type=[NSString stringWithString:@"application/octet-stream"];
  NSDebugMLLog(@"resmanager",@"_type=%@",_type);
  LOGObjectFnStop();
  return _type;
};

//--------------------------------------------------------------------
-(NSArray*)_frameworkClassPaths
{
  return frameworkClassPaths;
};

@end


//====================================================================
@implementation GSWResourceManager (GSWResourceManagerOldFn)

//--------------------------------------------------------------------
-(NSString*)urlForResourceNamed:(NSString*)name_
					inFramework:(NSString*)frameworkName_
{
  NSString* _url=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"name_=%@ frameworkName_=%@",name_,frameworkName_);
  _url=[self urlForResourceNamed:name_
			 inFramework:frameworkName_
			 languages:nil
			 request:nil];
  LOGObjectFnStop();
  return _url;
};

//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)name_
					 inFramework:(NSString*)frameworkName_
{
  NSString* _path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"name_=%@ frameworkName_=%@",name_,frameworkName_);
  _path=[self pathForResourceNamed:name_
			   inFramework:frameworkName_
			   language:nil];
  LOGObjectFnStop();
  return _path;
};

@end


//====================================================================
@implementation GSWResourceManager (GSWResourceManagerB)

//--------------------------------------------------------------------
-(void)_validateAPI
{
  //Verifier que self ne répond pas aux OldFN
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWResourceManager (GSWResourceManagerClassA)

//--------------------------------------------------------------------
//NDFN
+(NSString*)GSLanguageFromISOLanguage:(NSString*)ISOLanguage_
{
  return [localISO2GSLanguages objectForKey:ISOLanguage_];
};

//--------------------------------------------------------------------
//NDFN
+(NSArray*)GSLanguagesFromISOLanguages:(NSArray*)ISOLanguages_
{
  NSArray* _languages=nil;
  if (ISOLanguages_)
	{
	  NSMutableArray* _array=[NSMutableArray array];
	  NSString* _ISOLanguage=nil;
	  NSString* _GSLanguage=nil;
	  int i=0;
	  for(i=0;i<[ISOLanguages_ count];i++)
		{
		  _ISOLanguage=[[[ISOLanguages_ objectAtIndex:i] stringByTrimmingSpaces] lowercaseString];
		  _GSLanguage=[self GSLanguageFromISOLanguage:_ISOLanguage];
		  if (_GSLanguage)
			[_array addObject:_GSLanguage];
		  else
			{
			  LOGError(@"Unknown language: %@\nKnown languages are : %@",_ISOLanguage,localISO2GSLanguages);
			};
		};
	  _languages=[NSArray arrayWithArray:_array];
	}
  return _languages;
};

//--------------------------------------------------------------------
//NDFN
+(NSString*)ISOLanguageFromGSLanguage:(NSString*)GSLanguage_
{
  return [localGS2ISOLanguages objectForKey:GSLanguage_];
};

//--------------------------------------------------------------------
//NDFN
+(NSArray*)ISOLanguagesFromGSLanguages:(NSArray*)GSLanguages_
{
  NSArray* _languages=nil;
  if (GSLanguages_)
	{
	  NSMutableArray* _array=[NSMutableArray array];
	  NSString* _ISOLanguage=nil;
	  NSString* _GSLanguage=nil;
	  int i=0;
	  for(i=0;i<[GSLanguages_ count];i++)
		{
		  _GSLanguage=[[[GSLanguages_ objectAtIndex:i] stringByTrimmingSpaces] lowercaseString];
		  _ISOLanguage=[self ISOLanguageFromGSLanguage:_GSLanguage];
		  [_array addObject:_ISOLanguage];
		};
	  _languages=[NSArray arrayWithArray:_array];
	}
  return _languages;
};
//--------------------------------------------------------------------
+(GSWBundle*)_applicationGSWBundle
{
  LOGClassFnStart();
  if (!globalAppGSWBundle)
	{
	  NSString* _applicationBaseURL=nil;
	  NSString* _baseURL=nil;
	  NSString* _wrapperName=nil;
	  _applicationBaseURL=[GSWApplication applicationBaseURL]; //(retourne /GSWeb)
	  NSDebugMLLog(@"resmanager",@"_applicationBaseURL=%@",_applicationBaseURL);
	  _wrapperName=[globalAppProjectBundle wrapperName];
	  NSDebugMLLog(@"resmanager",@"_wrapperName=%@",_wrapperName);
	  _baseURL=[_applicationBaseURL stringByAppendingFormat:@"/%@",_wrapperName];
	  NSDebugMLLog(@"resmanager",@"_baseURL=%@",_baseURL);
	  globalAppGSWBundle=[[GSWBundle alloc]initWithPath:[globalAppProjectBundle bundlePath]
										   baseURL:_baseURL];
	  NSDebugMLLog(@"resmanager",@"globalAppGSWBundle=%@",globalAppGSWBundle);
	  //???
	  {
		NSBundle* _resourceManagerBundle=[NSBundle bundleForClass:
													 NSClassFromString(@"GSWResourceManager")];
		NSDebugMLLog(@"resmanager",@"_resourceManagerBundle bundlePath=%@",[_resourceManagerBundle bundlePath]);
		globalMimePListPathName=[_resourceManagerBundle pathForResource:@"MIME"
														ofType:@"plist"]; //TODO should return /usr/GNUstep/Libraries/GNUstepWeb/GSWeb.framework/Resources/MIME.plist
		NSDebugMLLog(@"resmanager",@"globalMimePListPathName=%@",globalMimePListPathName);
		if (!globalMimePListPathName)
		  globalMimePListPathName=[NSBundle pathForGNUstepResource:@"MIME"
											ofType:@"plist"
											inDirectory:@"gsweb/GSWeb.framework/Resources"];
		NSDebugMLLog(@"resmanager",@"globalMimePListPathName=%@",globalMimePListPathName);
#ifdef DEBUG
		if (!globalMimePListPathName)
		  {
			NSDictionary* env=[[NSProcessInfo processInfo] environment];

			NSDebugMLLog(@"error",@"GNUSTEP_USER_ROOT=%@",[env objectForKey: @"GNUSTEP_USER_ROOT"]);
			NSDebugMLLog(@"error",@"GNUSTEP_LOCAL_ROOT=%@",[env objectForKey: @"GNUSTEP_LOCAL_ROOT"]);
			NSDebugMLLog(@"error",@"gnustepBundle resourcePath=%@",[[NSBundle gnustepBundle]resourcePath]);
		  };
#endif
		NSAssert(globalMimePListPathName,@"No resource MIME.plist");
		{
		  NSDictionary* _tmpMimeTypes=nil;
		  NSMutableDictionary* _mimeTypes=[NSMutableDictionary dictionary];
		  LOGObjectFnStart();
		  _tmpMimeTypes=[NSDictionary  dictionaryWithContentsOfFile:globalMimePListPathName];
//		  NSDebugMLLog(@"resmanager",@"_tmpMimeTypes=%@",_tmpMimeTypes);
		  if (_tmpMimeTypes)
			{
			  NSEnumerator* enumerator = [_tmpMimeTypes keyEnumerator];
			  id _key;
			  id _value;
			  while ((_key = [enumerator nextObject]))
				{
				  _value=[_tmpMimeTypes objectForKey:_key];
				  _value=[_value lowercaseString];
				  _key=[_key lowercaseString];
				  [_mimeTypes setObject:_value
							  forKey:_key];
				};
//			  NSDebugMLLog(@"resmanager",@"_mimeTypes=%@",_mimeTypes);
			};
		  ASSIGN(globalMime,[NSDictionary dictionaryWithDictionary:_mimeTypes]);
		};
		globalLanguagesPListPathName=[_resourceManagerBundle pathForResource:@"languages"
															 ofType:@"plist"];
		NSDebugMLLog(@"resmanager",@"globalLanguagesPListPathName=%@",globalLanguagesPListPathName);
		if (!globalLanguagesPListPathName)
		  globalLanguagesPListPathName=[NSBundle pathForGNUstepResource:@"languages"
												 ofType:@"plist"
												 inDirectory:@"gsweb/GSWeb.framework/Resources"];
		NSDebugMLLog(@"resmanager",@"globalLanguagesPListPathName=%@",globalLanguagesPListPathName);
		NSAssert(globalLanguagesPListPathName,@"No resource languages.plist");
		{
		  NSDictionary* _tmpLanguages=nil;
		  NSMutableDictionary* _ISO2GS=[NSMutableDictionary dictionary];
		  NSMutableDictionary* _GS2ISO=[NSMutableDictionary dictionary];
		  LOGObjectFnStart();
		  _tmpLanguages=[NSDictionary  dictionaryWithContentsOfFile:globalLanguagesPListPathName];
//		  NSDebugMLLog(@"resmanager",@"_tmpLanguages=%@",_tmpLanguages);
		  if (_tmpLanguages)
			{
			  NSEnumerator* enumerator = [_tmpLanguages keyEnumerator];
			  id _iso=nil;
			  id _gs=nil;
			  while ((_iso = [enumerator nextObject]))
				{
				  _gs=[_tmpLanguages objectForKey:_iso];
				  [_ISO2GS setObject:_gs
							  forKey:[_iso lowercaseString]];
				  if ([_iso length]==2)//No xx-xx
					{
					  [_GS2ISO setObject:_iso
							   forKey:[_gs lowercaseString]];
					};
				};
//			  NSDebugMLLog(@"resmanager",@"_ISO2GS=%@",_ISO2GS);
//			  NSDebugMLLog(@"resmanager",@"_GS2ISO=%@",_ISO2GS);
			};
		  ASSIGN(localISO2GSLanguages,[NSDictionary dictionaryWithDictionary:_ISO2GS]);
		  ASSIGN(localGS2ISOLanguages,[NSDictionary dictionaryWithDictionary:_GS2ISO]);
		};
	  };
	  
	  [globalAppGSWBundle clearCache];
	};
  LOGClassFnStop();
  return globalAppGSWBundle;
};

@end
