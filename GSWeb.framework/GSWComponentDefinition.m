/* GSWComponentDefinition.m - GSWeb: Class GSWComponentDefinition
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
@implementation GSWComponentDefinition

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
			 path:(NSString*)path_
		  baseURL:(NSString*)baseURL_
	frameworkName:(NSString*)frameworkName_
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  NSDebugMLLog(@"gswcomponents",@"name_=%@ frameworkName_=%@",name_,frameworkName_);
	  ASSIGN(name,name_);
	  bundle=[[GSWBundle alloc] initWithPath:path_
								baseURL:baseURL_
								inFrameworkNamed:frameworkName_];
	  observers=nil;
	  ASSIGN(frameworkName,frameworkName_);
	  NSDebugMLLog(@"gswcomponents",@"frameworkName=%@",frameworkName);
	  ASSIGN(templateName,name_);//TODOV
	  NSDebugMLLog(@"gswcomponents",@"templateName=%@",templateName);
	  componentClass=Nil;
	  isScriptedClass=NO;
	  isCachingEnabled=NO;
	  isAwake=NO;
	  [self setCachingEnabled:[GSWApplication isCachingEnabled]];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWComponentDefinition");
  GSWLogC("Dealloc GSWComponentDefinition: name");
  DESTROY(name);
  GSWLogC("Dealloc GSWComponentDefinition: bundle");
  DESTROY(bundle);
  GSWLogC("Dealloc GSWComponentDefinition: observers");
  DESTROY(observers);
  GSWLogC("Dealloc GSWComponentDefinition: frameworkName");
  DESTROY(frameworkName);
  GSWLogC("Dealloc GSWComponentDefinition: templateName");
  DESTROY(templateName);
  GSWLogC("Dealloc GSWComponentDefinition: componentClass");
  DESTROY(componentClass);
  GSWLogC("Dealloc GSWComponentDefinition Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWComponentDefinition");
};

//--------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*)coder_
{
  if ((self = [super init]))
	{
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&name];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&bundle];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&observers]; //TODOV
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&frameworkName];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&templateName];
	  [coder_ decodeValueOfObjCType:@encode(Class)
			  at:&componentClass];
	  [coder_ decodeValueOfObjCType:@encode(BOOL)
			  at:&isScriptedClass];
	  [coder_ decodeValueOfObjCType:@encode(BOOL)
			  at:&isCachingEnabled];
	  [coder_ decodeValueOfObjCType:@encode(BOOL)
			  at:&isAwake];
	};
  return self;
};

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder_
{
  [coder_ encodeObject:name];
  [coder_ encodeObject:bundle];
  [coder_ encodeObject:observers]; //TODOV
  [coder_ encodeObject:frameworkName];
  [coder_ encodeObject:templateName];
  [coder_ encodeValueOfObjCType:@encode(Class)
		  at:&componentClass];
  [coder_ encodeValueOfObjCType:@encode(BOOL)
		  at:&isScriptedClass];
  [coder_ encodeValueOfObjCType:@encode(BOOL)
		  at:&isCachingEnabled];
  [coder_ encodeValueOfObjCType:@encode(BOOL)
		  at:&isAwake];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone_
{
  GSWComponentDefinition* clone = [[isa allocWithZone:zone_] init];
  if (clone)
	{
	  ASSIGNCOPY(clone->name,name);
	  ASSIGNCOPY(clone->bundle,bundle);
	  ASSIGNCOPY(clone->observers,observers);
	  ASSIGNCOPY(clone->frameworkName,frameworkName);
	  ASSIGNCOPY(clone->templateName,templateName);
	  clone->componentClass=componentClass;
	  clone->isScriptedClass=isScriptedClass;
	  clone->isCachingEnabled=isCachingEnabled;
	  clone->isAwake=isAwake;
	};
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)frameworkName
{
  return frameworkName;
};

//--------------------------------------------------------------------
-(NSString*)baseURL
{
  return [bundle baseURL];
};

//--------------------------------------------------------------------
-(NSString*)path
{
  return [bundle path];
};

//--------------------------------------------------------------------
-(NSString*)name
{
  return name;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  //TODO
  return [NSString stringWithFormat:@"<%s %p - name:[%@] bundle:[%@] observers=[%@] frameworkName=[%@] templateName=[%@] componentClass=[%@] isScriptedClass=[%s] isCachingEnabled=[%s] isAwake=[%s]>",
				   object_get_class_name(self),
				   (void*)self,
				   name,
				   bundle,
				   observers,
				   frameworkName,
				   templateName,
				   componentClass,
				   isScriptedClass ? "YES" : "NO",
				   isCachingEnabled ? "YES" : "NO",
				   isAwake ? "YES" : "NO"];
};

//--------------------------------------------------------------------
-(void)sleep
{
  //OK
  LOGObjectFnStart();
  isAwake=NO;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)awake
{
  //OK
  BOOL _isCachingEnabled=NO;
  LOGObjectFnStart();
  isAwake=YES;
  _isCachingEnabled=[self isCachingEnabled];
  if (!_isCachingEnabled) //??
	[self _clearCache];
  //call self componentClass
  LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWComponentDefinition (GSWCacheManagement)

//--------------------------------------------------------------------
-(BOOL)isCachingEnabled
{
  return isCachingEnabled;
};

//--------------------------------------------------------------------
-(void)setCachingEnabled:(BOOL)flag_
{
  isCachingEnabled=flag_;
};

@end

//====================================================================
@implementation GSWComponentDefinition (GSWComponentDefinitionA)

//--------------------------------------------------------------------
-(void)_clearCache
{
  //OK
  LOGObjectFnStart();
  [bundle clearCache];
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWComponentDefinition (GSWComponentDefinitionB)

//--------------------------------------------------------------------
-(GSWElement*)templateWithName:(NSString*)name_
					 languages:(NSArray*)languages_
{
  GSWElement* _element=nil;
  LOGObjectFnStart();
  _element=[bundle templateNamed:name_
				   languages:languages_];
  NSDebugMLLog(@"gswcomponents",@"_element=%@",_element);
  LOGObjectFnStop();
  return _element;
};
/*
//--------------------------------------------------------------------
-(NSString*)stringForKey:(NSString*)key_
			inTableNamed:(NSString*)name_
		withDefaultValue:(NSString*)defaultValue_
			   languages:(NSArray*)languages_
{
  NSString* _string=nil;
  LOGObjectFnStart();
  _string=[bundle stringForKey:key_
				  inTableNamed:name_
				  withDefaultValue:defaultValue_
				  languages:languages_];
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
  _stringsTable=[bundle stringsTableNamed:name_
				  withLanguages:languages_];
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
  _stringsTableArray=[bundle stringsTableArrayNamed:name_
						withLanguages:languages_];
  LOGObjectFnStop();
  return _stringsTableArray;
};

//--------------------------------------------------------------------
-(NSString*)urlForResourceNamed:(NSString*)name_
						 ofType:(NSString*)type_
					  languages:(NSArray*)languages_
						request:(GSWRequest*)request_
{
  NSString* _url=nil;
  LOGObjectFnStart();
  _url=[bundle urlForResourceNamed:name_
				  ofType:type_
				  languages:languages_
				  request:request_];
  LOGObjectFnStop();
  return _url;
};
*/
//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)name_
						  ofType:(NSString*)type_
					   languages:(NSArray*)languages_
{
  NSString* _path=nil;
  LOGObjectFnStart();
  _path=[bundle pathForResourceNamed:name_
				ofType:type_
				languages:languages_];
  LOGObjectFnStop();
  return _path;
};

@end

//====================================================================
@implementation GSWComponentDefinition (GSWComponentDefinitionC)

//--------------------------------------------------------------------
-(GSWComponent*)componentInstanceInContext:(GSWContext*)_context
{
  //OK
  GSWComponent* _component=nil;
  Class _componentClass=nil;
  NSMutableDictionary* _threadDictionary=nil;
  LOGObjectFnStart();
  NSAssert(_context,@"No Context");
  NSDebugMLLog(@"gswcomponents",@"_context=%@",_context);
  _componentClass=[self componentClass];
  NSDebugMLLog(@"gswcomponents",@"_componentClass=%p",(void*)_componentClass);
  _threadDictionary=GSCurrentThreadDictionary();
  [_threadDictionary setObject:self
					 forKey:GSWThreadKey_ComponentDefinition];
  NS_DURING
	{
	  _component=[[_componentClass new] autorelease];
	}
  NS_HANDLER
	{
	  LOGException(@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  [_threadDictionary removeObjectForKey:GSWThreadKey_ComponentDefinition];
	  [localException raise];
	};
  NS_ENDHANDLER;
  [_threadDictionary removeObjectForKey:GSWThreadKey_ComponentDefinition];
  //  [_component context];//so what ?
  LOGObjectFnStop();
  return _component;
};

//--------------------------------------------------------------------
-(Class)componentClass
{
  //OK
  return [self _componentClass];
};

//--------------------------------------------------------------------
-(Class)_componentClass
{
  //OK To Verify
  Class _componentClass=componentClass;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"_componentClass=%@",_componentClass);
  NSDebugMLLog(@"gswcomponents",@"name=%@",name);
  if (!_componentClass)
	_componentClass=NSClassFromString(name);//???
  NSDebugMLLog(@"gswcomponents",@"_componentClass=%@",_componentClass);
  NSDebugMLLog(@"gswcomponents",@"_componentClass superclass=%@",[_componentClass superclass]);
  if (!_componentClass)
	{
	  BOOL _createClassesOk=NO;
	  NSString* _superClassName=nil;
          if (!WOStrictFlag)
            {
              NSDictionary* _archive=[bundle archiveNamed:name];
              NSDebugMLLog(@"gswcomponents",@"_archive=%@",_archive);
              _superClassName=[_archive objectForKey:@"superClassName"];
              NSDebugMLLog(@"gswcomponents",@"_superClassName=%@",_superClassName);
              if (_superClassName)
		{
		  if (!NSClassFromString(_superClassName))
                    {
                      ExceptionRaise(NSGenericException,@"Superclass %@ of component %@ doesn't exist",
                                     _superClassName,
                                     name);
                    };
		};
            };
          if (!_superClassName)
            _superClassName=@"GSWComponent";
	  NSDebugMLLog(@"gswcomponents",@"_superClassName=%@",_superClassName);
	  _createClassesOk=[GSWApplication createUnknownComponentClasses:[NSArray arrayWithObject:name]
									   superClassName:_superClassName];
	  _componentClass=NSClassFromString(name);
	  NSDebugMLLog(@"gswcomponents",@"_componentClass=%p",(void*)_componentClass);
	};
//call GSWApp isCaching
  NSDebugMLLog(@"gswcomponents",@"componentClass=%@",componentClass);
  LOGObjectFnStop();
  return _componentClass;
};

//--------------------------------------------------------------------
-(GSWComponentReference*)componentReferenceWithAssociations:(NSDictionary*)_associations
												  template:(GSWElement*)_template
{
  //OK
  GSWComponentReference* _componentReference=nil;
  LOGObjectFnStart();
  _componentReference=[[[GSWComponentReference alloc]initWithName:name
													associations:_associations
													template:_template] autorelease];
  LOGObjectFnStop();
  return _componentReference;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)componentAPI
{
  NSDictionary* _componentAPI=nil;
  LOGObjectFnStart();
  _componentAPI=[bundle apiNamed:name];
  LOGObjectFnStop();
  return _componentAPI;
};

@end

//====================================================================
@implementation GSWComponentDefinition (GSWComponentDefinitionD)

//--------------------------------------------------------------------
-(void)_finishInitializingComponent:(GSWComponent*)_component
{
  //OK
  NSDictionary* _archive=nil;
  LOGObjectFnStart();
  _archive=[bundle archiveNamed:name];
  [bundle initializeObject:_component
		  fromArchive:_archive];
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWComponentDefinition (GSWComponentDefinitionE)

//--------------------------------------------------------------------
-(void)_notifyObserversForDyingComponent:(GSWComponent*)_component
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_awakeObserversForComponent:(GSWComponent*)_component
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_deallocForComponent:(GSWComponent*)_component
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_awakeForComponent:(GSWComponent*)_component
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_registerObserver:(id)_observer
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(void)_registerObserver:(id)_observer
{
  LOGClassFnNotImplemented();	//TODOFN
};

@end
