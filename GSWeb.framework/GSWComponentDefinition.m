/** GSWComponentDefinition.m - <title>GSWeb: Class GSWComponentDefinition</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$

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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWComponentDefinition

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
             path:(NSString*)aPath
          baseURL:(NSString*)baseURL
    frameworkName:(NSString*)aFrameworkName
{
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      NSDebugMLLog(@"gswcomponents",@"aName=%@ aFrameworkName=%@",aName,aFrameworkName);
      ASSIGN(_name,aName);
      _bundle=[[GSWBundle alloc] initWithPath:aPath
                                 baseURL:baseURL
                                 inFrameworkNamed:aFrameworkName];
      _observers=nil;
      ASSIGN(_frameworkName,aFrameworkName);
      NSDebugMLLog(@"gswcomponents",@"frameworkName=%@",_frameworkName);
      ASSIGN(_templateName,aName);//TODOV
      NSDebugMLLog(@"gswcomponents",@"templateName=%@",_templateName);
      _componentClass=Nil;
      _isScriptedClass=NO;
      _isCachingEnabled=NO;
      _isAwake=NO;
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
  DESTROY(_name);
  GSWLogC("Dealloc GSWComponentDefinition: bundle");
  DESTROY(_bundle);
  GSWLogC("Dealloc GSWComponentDefinition: observers");
  DESTROY(_observers);
  GSWLogC("Dealloc GSWComponentDefinition: frameworkName");
  DESTROY(_frameworkName);
  GSWLogC("Dealloc GSWComponentDefinition: templateName");
  DESTROY(_templateName);
  GSWLogC("Dealloc GSWComponentDefinition: componentClass");
  DESTROY(_componentClass);
  GSWLogC("Dealloc GSWComponentDefinition Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWComponentDefinition");
};

//--------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*)coder
{
  if ((self = [super init]))
    {
      [coder decodeValueOfObjCType:@encode(id)
             at:&_name];
      [coder decodeValueOfObjCType:@encode(id)
             at:&_bundle];
      [coder decodeValueOfObjCType:@encode(id)
             at:&_observers]; //TODOV
      [coder decodeValueOfObjCType:@encode(id)
             at:&_frameworkName];
      [coder decodeValueOfObjCType:@encode(id)
             at:&_templateName];
      [coder decodeValueOfObjCType:@encode(Class)
             at:&_componentClass];
      [coder decodeValueOfObjCType:@encode(BOOL)
             at:&_isScriptedClass];
      [coder decodeValueOfObjCType:@encode(BOOL)
             at:&_isCachingEnabled];
      [coder decodeValueOfObjCType:@encode(BOOL)
             at:&_isAwake];
	};
  return self;
};

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder
{
  [coder encodeObject:_name];
  [coder encodeObject:_bundle];
  [coder encodeObject:_observers]; //TODOV
  [coder encodeObject:_frameworkName];
  [coder encodeObject:_templateName];
  [coder encodeValueOfObjCType:@encode(Class)
         at:&_componentClass];
  [coder encodeValueOfObjCType:@encode(BOOL)
         at:&_isScriptedClass];
  [coder encodeValueOfObjCType:@encode(BOOL)
         at:&_isCachingEnabled];
  [coder encodeValueOfObjCType:@encode(BOOL)
         at:&_isAwake];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWComponentDefinition* clone = [[isa allocWithZone:zone] init];
  if (clone)
    {
      ASSIGNCOPY(clone->_name,_name);
      ASSIGNCOPY(clone->_bundle,_bundle);
      ASSIGNCOPY(clone->_observers,_observers);
      ASSIGNCOPY(clone->_frameworkName,_frameworkName);
      ASSIGNCOPY(clone->_templateName,_templateName);
      clone->_componentClass=_componentClass;
      clone->_isScriptedClass=_isScriptedClass;
      clone->_isCachingEnabled=_isCachingEnabled;
      clone->_isAwake=_isAwake;
    };
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)frameworkName
{
  return _frameworkName;
};

//--------------------------------------------------------------------
-(NSString*)baseURL
{
  return [_bundle baseURL];
};

//--------------------------------------------------------------------
-(NSString*)path
{
  return [_bundle path];
};

//--------------------------------------------------------------------
-(NSString*)name
{
  return _name;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  //TODO
  return [NSString stringWithFormat:@"<%s %p - name:[%@] bundle:[%@] observers=[%@] frameworkName=[%@] templateName=[%@] componentClass=[%@] isScriptedClass=[%s] isCachingEnabled=[%s] isAwake=[%s]>",
				   object_get_class_name(self),
				   (void*)self,
				   _name,
				   _bundle,
				   _observers,
				   _frameworkName,
				   _templateName,
				   _componentClass,
				   _isScriptedClass ? "YES" : "NO",
				   _isCachingEnabled ? "YES" : "NO",
				   _isAwake ? "YES" : "NO"];
};

//--------------------------------------------------------------------
-(void)sleep
{
  //OK
  LOGObjectFnStart();
  _isAwake=NO;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)awake
{
  //OK
  BOOL isCachingEnabled=NO;
  LOGObjectFnStart();
  _isAwake=YES;
  isCachingEnabled=[self isCachingEnabled];
  if (!isCachingEnabled) //??
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
  return _isCachingEnabled;
};

//--------------------------------------------------------------------
-(void)setCachingEnabled:(BOOL)flag
{
  _isCachingEnabled=flag;
};

@end

//====================================================================
@implementation GSWComponentDefinition (GSWComponentDefinitionA)

//--------------------------------------------------------------------
-(void)_clearCache
{
  //OK
  LOGObjectFnStart();
  [_bundle clearCache];
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWComponentDefinition (GSWComponentDefinitionB)

//--------------------------------------------------------------------
-(GSWElement*)templateWithName:(NSString*)aName
                     languages:(NSArray*)languages
{
  GSWElement* element=nil;
  LOGObjectFnStart();
  element=[_bundle templateNamed:aName
                   languages:languages];
  NSDebugMLLog(@"gswcomponents",@"aName=%@ languages=%@ element=%@",aName,languages,element);
  LOGObjectFnStop();
  return element;
};
/*
//--------------------------------------------------------------------
-(NSString*)stringForKey:(NSString*)key
inTableNamed:(NSString*)aName
withDefaultValue:(NSString*)defaultValue
languages:(NSArray*)languages
{
  NSString* string=nil;
  LOGObjectFnStart();
  string=[_bundle stringForKey:key
  inTableNamed:aName
  withDefaultValue:defaultValue
  languages:languages];
  LOGObjectFnStop();
  return string;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aName
                    withLanguages:(NSArray*)languages
{
  NSDictionary* stringsTable=nil;
  LOGObjectFnStart();
  stringsTable=[bundle stringsTableNamed:aName
				  withLanguages:languages];
  LOGObjectFnStop();
  return stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aName
                    withLanguages:(NSArray*)languages
{
  NSArray* stringsTableArray=nil;
  LOGObjectFnStart();
  stringsTableArray=[bundle stringsTableArrayNamed:aName
						withLanguages:languages];
  LOGObjectFnStop();
  return stringsTableArray;
};

//--------------------------------------------------------------------
-(NSString*)urlForResourceNamed:(NSString*)aName
						 ofType:(NSString*)type
					  languages:(NSArray*)languages
						request:(GSWRequest*)request
{
  NSString* url=nil;
  LOGObjectFnStart();
  url=[bundle urlForResourceNamed:aName
				  ofType:type
				  languages:languages
				  request:request];
  LOGObjectFnStop();
  return url;
};
*/
//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)aType
                       languages:(NSArray*)languages
{
  NSString* path=nil;
  LOGObjectFnStart();
  path=[_bundle pathForResourceNamed:aName
                ofType:aType
                languages:languages];
  LOGObjectFnStop();
  return path;
};

@end

//====================================================================
@implementation GSWComponentDefinition (GSWComponentDefinitionC)

//--------------------------------------------------------------------
-(GSWComponent*)componentInstanceInContext:(GSWContext*)aContext
{
  //OK
  GSWComponent* component=nil;
  Class componentClass=nil;
  NSMutableDictionary* threadDictionary=nil;
  LOGObjectFnStart();
  NSAssert(aContext,@"No Context");
  NSDebugMLLog(@"gswcomponents",@"aContext=%@",aContext);
  componentClass=[self componentClass];
  NSAssert(componentClass,@"No componentClass");
  NSDebugMLLog(@"gswcomponents",@"componentClass=%p",(void*)componentClass);
  threadDictionary=GSCurrentThreadDictionary();
  [threadDictionary setObject:self
                    forKey:GSWThreadKey_ComponentDefinition];
  NS_DURING
    {
      component=[[componentClass new] autorelease];
    }
  NS_HANDLER
    {
      LOGException(@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      [threadDictionary removeObjectForKey:GSWThreadKey_ComponentDefinition];
      [localException raise];
    };
  NS_ENDHANDLER;
  [threadDictionary removeObjectForKey:GSWThreadKey_ComponentDefinition];
  //  [_component context];//so what ?
  LOGObjectFnStop();
  return component;
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
  Class componentClass=_componentClass;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"componentClass=%@",componentClass);
  NSDebugMLLog(@"gswcomponents",@"name=%@",_name);
  if (!componentClass)
    componentClass=NSClassFromString(_name);//???
  NSDebugMLLog(@"gswcomponents",@"componentClass=%@",componentClass);
  NSDebugMLLog(@"gswcomponents",@"componentClass superclass=%@",[componentClass superclass]);
  if (!componentClass)
    {
      BOOL createClassesOk=NO;
      NSString* superClassName=nil;
      if (!WOStrictFlag)
        {
          NSDictionary* archive=[_bundle archiveNamed:_name];
          NSDebugMLLog(@"gswcomponents",@"archive=%@",archive);
          superClassName=[archive objectForKey:@"superClassName"];
          NSDebugMLLog(@"gswcomponents",@"superClassName=%@",superClassName);
          if (superClassName)
            {
              if (!NSClassFromString(superClassName))
                {
                  ExceptionRaise(NSGenericException,@"Superclass %@ of component %@ doesn't exist",
                                 superClassName,
                                 _name);
                };
            };
        };
      if (!superClassName)
        superClassName=@"GSWComponent";
      NSDebugMLLog(@"gswcomponents",@"superClassName=%@",superClassName);
      createClassesOk=[GSWApplication createUnknownComponentClasses:[NSArray arrayWithObject:_name]
                                      superClassName:superClassName];
      componentClass=NSClassFromString(_name);
      NSDebugMLLog(@"gswcomponents",@"componentClass=%p",(void*)componentClass);
    };
//call GSWApp isCaching
  NSDebugMLLog(@"gswcomponents",@"componentClass=%@",componentClass);
  LOGObjectFnStop();
  return componentClass;
};

//--------------------------------------------------------------------
-(GSWComponentReference*)componentReferenceWithAssociations:(NSDictionary*)associations
                                                   template:(GSWElement*)template
{
  //OK
  GSWComponentReference* componentReference=nil;
  LOGObjectFnStart();
  componentReference=[[[GSWComponentReference alloc]initWithName:_name
                                                    associations:associations
                                                    template:template] autorelease];
  LOGObjectFnStop();
  return componentReference;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)componentAPI
{
  NSDictionary* componentAPI=nil;
  LOGObjectFnStart();
  componentAPI=[_bundle apiNamed:_name];
  LOGObjectFnStop();
  return componentAPI;
};

@end

//====================================================================
@implementation GSWComponentDefinition (GSWComponentDefinitionD)

//--------------------------------------------------------------------
-(void)_finishInitializingComponent:(GSWComponent*)component
{
  //OK
  NSDictionary* archive=nil;
  LOGObjectFnStart();
  archive=[_bundle archiveNamed:_name];
  [_bundle initializeObject:component
           fromArchive:archive];
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWComponentDefinition (GSWComponentDefinitionE)

//--------------------------------------------------------------------
-(void)_notifyObserversForDyingComponent:(GSWComponent*)aComponent
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_awakeObserversForComponent:(GSWComponent*)aComponent
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_deallocForComponent:(GSWComponent*)aComponent
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_awakeForComponent:(GSWComponent*)aComponent
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_registerObserver:(id)observer
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(void)_registerObserver:(id)observer
{
  LOGClassFnNotImplemented();	//TODOFN
};

@end
