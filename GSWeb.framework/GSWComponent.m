/** GSWComponent.m - <title>GSWeb: Class GSWComponent</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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
#endif
//====================================================================
@implementation GSWComponent

//--------------------------------------------------------------------
//	init

-(id)init
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      NSMutableDictionary* currentThreadDictionary=GSCurrentThreadDictionary();
      GSWContext* aContext=[currentThreadDictionary objectForKey:GSWThreadKey_Context];
      // This was set by GSWComponentDefintion -componentInstanceInContext:
      GSWComponentDefinition* aComponentDefinition=[currentThreadDictionary objectForKey:GSWThreadKey_ComponentDefinition];
      NSAssert(aContext,@"No Context in GSWComponent Init");
      NSAssert(aComponentDefinition,@"No ComponentDefinition in GSWComponent Init");
      ASSIGN(_componentDefinition,aComponentDefinition);
      _name=[[NSString stringWithCString:object_get_class_name(self)]retain];
      NSDebugMLLog(@"GSWComponent",@"_name=%@",_name);
      _isCachingEnabled=YES;
      [self _setContext:aContext];
      NSDebugMLLog(@"GSWComponent",@"_context=%@",_context);
      _templateName=[[self _templateNameFromClass:[self class]] retain];
      NSDebugMLLog(@"GSWComponent",@"_templateName=%@",_templateName);
      [self setCachingEnabled:[GSWApp isCachingEnabled]];
      [_componentDefinition _finishInitializingComponent:self];
      _isParentToComponentSynchronized=[self synchronizesParentToComponentVariablesWithBindings];
      _isComponentToParentSynchronized=[self synchronizesComponentToParentVariablesWithBindings];
      NSDebugMLLog(@"GSWComponent",@"_isParentToComponentSynchronized=%s",(_isParentToComponentSynchronized ? "YES" : "NO"));
      NSDebugMLLog(@"GSWComponent",@"_isComponentToParentSynchronized=%s",(_isComponentToParentSynchronized ? "YES" : "NO"));
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogAssertGood(self);
  GSWLogC("Dealloc GSWComponent");
  GSWLogC("Dealloc GSWComponent: name");
  DESTROY(_name);
  GSWLogC("Dealloc GSWComponent: subComponents");
  DESTROY(_subComponents);
  GSWLogC("Dealloc GSWComponent: templateName");
  DESTROY(_templateName);
  GSWLogC("Dealloc GSWComponent: template");
  DESTROY(_template);
  GSWLogC("Dealloc GSWComponent: componentDefinition");
  DESTROY(_componentDefinition);
  _parent=nil;
  GSWLogC("Dealloc GSWComponent: associationsKeys");
  DESTROY(_associationsKeys);
  GSWLogC("Dealloc GSWComponent: associations");
  DESTROY(_associations);
  GSWLogC("Dealloc GSWComponent: childTemplate");
  DESTROY(_childTemplate);
  GSWLogC("Dealloc GSWComponent: userDictionary");
  DESTROY(_userDictionary);
  GSWLogC("Dealloc GSWComponent: userAssociations");
  DESTROY(_userAssociations);
  GSWLogC("Dealloc GSWComponent: defaultAssociations");
  DESTROY(_defaultAssociations);
  GSWLogC("Dealloc GSWComponent: validationFailureMessages");
  DESTROY(_validationFailureMessages);
  GSWLogC("Dealloc GSWComponent: context (set to nil)");
  _context=nil;
  GSWLogC("Dealloc GSWComponent: session (set to nil)");
  _session=nil;
  GSWLogC("Dealloc GSWComponent Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWComponent");
}

//--------------------------------------------------------------------
-(id)copyWithZone: (NSZone*)zone
{
  GSWComponent* clone = [[isa allocWithZone: zone] init];
  ASSIGNCOPY(clone->_name,_name);
  ASSIGNCOPY(clone->_subComponents,_subComponents);
  ASSIGNCOPY(clone->_templateName,_templateName);
  ASSIGN(clone->_template,_template);
  ASSIGN(clone->_componentDefinition,_componentDefinition);
  ASSIGN(clone->_parent,_parent);
  ASSIGNCOPY(clone->_associationsKeys,_associationsKeys);
  ASSIGNCOPY(clone->_associations,_associations);
  ASSIGNCOPY(clone->_childTemplate,_childTemplate);
  ASSIGNCOPY(clone->_context,_context);
  ASSIGNCOPY(clone->_session,_session);
  clone->_isPage=_isPage;
  clone->_isCachingEnabled=_isCachingEnabled;
  clone->_isParentToComponentSynchronized=_isParentToComponentSynchronized;
  clone->_isComponentToParentSynchronized=_isComponentToParentSynchronized;
  return clone;
};

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)aCoder
{
  //TODOV
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:_name];
  [aCoder encodeObject:_subComponents];
  [aCoder encodeObject:_templateName];
  [aCoder encodeObject:_template];
  [aCoder encodeObject:_componentDefinition];
  [aCoder encodeObject:_parent];
  [aCoder encodeObject:_associationsKeys];
  [aCoder encodeObject:_associations];
  [aCoder encodeObject:_childTemplate];
  [aCoder encodeObject:_context];
  [aCoder encodeObject:_session];
  [aCoder encodeValueOfObjCType:@encode(BOOL)
          at:&_isPage];
  [aCoder encodeValueOfObjCType:@encode(BOOL)
          at:&_isCachingEnabled];
  [aCoder encodeValueOfObjCType:@encode(BOOL)
          at:&_isParentToComponentSynchronized];
  [aCoder encodeValueOfObjCType:@encode(BOOL)
          at:&_isComponentToParentSynchronized];
}

//--------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*)aCoder
{
  //TODOV
  if ((self = [super initWithCoder:aCoder]))
    {
      [aCoder decodeValueOfObjCType:@encode(id)
              at:&_name];
      [aCoder decodeValueOfObjCType:@encode(id)
              at:&_subComponents];
      [aCoder decodeValueOfObjCType:@encode(id)
              at:&_templateName];
      [aCoder decodeValueOfObjCType:@encode(id)
              at:&_template];
      [aCoder decodeValueOfObjCType:@encode(id)
              at:&_componentDefinition];
      [aCoder decodeValueOfObjCType:@encode(id)
              at:&_parent];
      [aCoder decodeValueOfObjCType:@encode(id)
              at:&_associationsKeys];
      [aCoder decodeValueOfObjCType:@encode(id)
              at:&_associations];
      [aCoder decodeValueOfObjCType:@encode(id)
              at:&_childTemplate];
      [aCoder decodeValueOfObjCType:@encode(id)
              at:&_context];
      [aCoder decodeValueOfObjCType:@encode(id)
              at:&_session];
      [aCoder decodeValueOfObjCType:@encode(BOOL)
              at:&_isPage];
      [aCoder decodeValueOfObjCType:@encode(BOOL)
              at:&_isCachingEnabled];
      [aCoder decodeValueOfObjCType:@encode(BOOL)
              at:&_isParentToComponentSynchronized];
      [aCoder decodeValueOfObjCType:@encode(BOOL)
              at:&_isComponentToParentSynchronized];
	};
  return self;
}

//--------------------------------------------------------------------
//	frameworkName

-(NSString*)frameworkName 
{
  //OK
  NSString* aFrameworkName=nil;
  GSWComponentDefinition* aComponentDefinition=nil;
  LOGObjectFnStart();
  aComponentDefinition=[self _componentDefinition];
  NSAssert(aComponentDefinition,@"No componentDefinition");
  aFrameworkName=[aComponentDefinition frameworkName];
  NSDebugMLLog(@"GSWComponent",@"aFrameworkName=%@",aFrameworkName);
  LOGObjectFnStop();
  return aFrameworkName;
};

//--------------------------------------------------------------------
//	logWithFormat:

-(void)logWithFormat:(NSString*)format,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	logWithFormat:arguments:

-(void)logWithFormat:(NSString*)format
           arguments:(va_list)arguments
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	name

-(NSString*)name 
{
  return _name;
};

//--------------------------------------------------------------------
//	path

-(NSString*)path 
{
  //TODOV
  NSBundle* bundle=[NSBundle mainBundle];
  return [bundle pathForResource:_name
                 ofType:GSWPageSuffix[GSWebNamingConv]];
};

//--------------------------------------------------------------------
//	baseURL

-(NSString*)baseURL 
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)_templateNameFromClass:(Class)aClass
{
  //OK
  NSString* aTemplateName=nil;
  LOGObjectFnStart();
  aTemplateName=[NSString stringWithCString:class_get_class_name(aClass)];
  LOGObjectFnStop();
  return aTemplateName;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  //TODO
  NSString* dscr=nil;
  GSWLogAssertGood(self);
  NSDebugMLLog(@"GSWComponent",@"GSWComponent description self=%p",self);
  dscr=[NSString stringWithFormat:@"<%s %p>",
				  object_get_class_name(self),
				  (void*)self];
  return dscr;
};

// GSWeb Additions {
//--------------------------------------------------------------------
-(NSDictionary*)userDictionary
{
  return _userDictionary;
};

//--------------------------------------------------------------------
-(void)setUserDictionary:(NSDictionary*)aUserDictionary
{
  ASSIGN(_userDictionary,aUserDictionary);
  NSDebugMLLog(@"GSWComponent",@"userDictionary:%@",_userDictionary);
};

//--------------------------------------------------------------------
-(NSDictionary*)userAssociations
{
  return _userAssociations;
};

//--------------------------------------------------------------------
-(void)setUserAssociations:(NSDictionary*)userAssociations
{
  ASSIGN(_userAssociations,userAssociations);
  NSDebugMLLog(@"GSWComponent",@"userAssociations:%@",_userAssociations);
};

//--------------------------------------------------------------------
-(GSWAssociation*)userAssociationForKey:(NSString*)key
{
  return [[self userAssociations]objectForKey:key];
};

//--------------------------------------------------------------------
-(NSDictionary*)defaultAssociations
{
  return _defaultAssociations;
};

//--------------------------------------------------------------------
-(void)setDefaultAssociations:(NSDictionary*)defaultAssociations
{
  ASSIGN(_defaultAssociations,defaultAssociations);
  NSDebugMLLog(@"GSWComponent",@"defaultAssociations:%@",_defaultAssociations);
};

//--------------------------------------------------------------------
-(GSWAssociation*)defaultAssociationForKey:(NSString*)key
{
  return [[self defaultAssociations]objectForKey:key];
};

// }

@end

//====================================================================
@implementation GSWComponent (GSWCachingPolicy)

//--------------------------------------------------------------------
//setCachingEnabled:

-(void)setCachingEnabled:(BOOL)caching
{
  //OK
  _isCachingEnabled=caching;
};

//--------------------------------------------------------------------
//isCachingEnabled

-(BOOL)isCachingEnabled 
{
  //OK
  return _isCachingEnabled;
};

@end

//====================================================================
@implementation GSWComponent (GSWComponentA)

//--------------------------------------------------------------------
-(void)setParent:(GSWComponent*)parent
associationsKeys:(NSArray*)associationsKeys
    associations:(NSArray*)associations
        template:(GSWElement*)template
{
  //OK
  LOGObjectFnStart();
  _parent=parent;
  NSDebugMLLog(@"GSWComponent",@"name=%@ parent=%p (%@)",
               [self declarationName],
               (void*)parent,[parent class]);
  NSDebugMLLog(@"GSWComponent",@"associations=%@",_associations);
  ASSIGN(_associations,associations);
  ASSIGN(_associationsKeys,associationsKeys);
  NSDebugMLLog(@"GSWComponent",@"associationsKeys=%@",_associationsKeys);
  ASSIGN(_childTemplate,template);
  NSDebugMLLog(@"GSWComponent",@"template=%@",_childTemplate);
  [self validateAPIAssociations];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)synchronizeComponentToParent
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"Name=%@ - isComponentToParentSynchronized=%s",
              [self declarationName],(_isComponentToParentSynchronized ? "YES" : "NO"));
  if (_isComponentToParentSynchronized)
    {
      int i=0;
      id aKey=nil;
      GSWAssociation* anAssociation=nil;
      id aValue=nil;
      id logValue=[self valueForBinding:@"GSWDebug"];
      BOOL doLog=boolValueWithDefaultFor(logValue,NO);
      NSDebugMLLog(@"GSWComponent",@"declarationName=%@ - Synchro SubComponent->Component",               
                  [self declarationName]);
      for(i=0;i<[_associationsKeys count];i++)
        {
          aKey=[_associationsKeys objectAtIndex:i];
          anAssociation=[_associations objectAtIndex:i];
          NSDebugMLLog(@"GSWComponent",@"aKey=%@ anAssociation=%@",aKey,anAssociation);
          if ([anAssociation isValueSettable]
              && ![anAssociation isKindOfClass:[GSWBindingNameAssociation class]]) //TODOV
            {
              aValue=[self valueForKey:aKey];
              NSDebugMLLog(@"GSWComponent",@"aKey=%@ aValue=%@ (%@)",
                           aKey,aValue,NSStringFromClass([aValue class]));
              if (doLog)
                [anAssociation logSynchronizeComponentToParentForValue:aValue
                               inComponent:_parent];
              [anAssociation setValue:aValue
                             inComponent:_parent];
            };
        };
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)synchronizeParentToComponent
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"Name=%@ - isParentToComponentSynchronized=%s",
              [self declarationName],(_isParentToComponentSynchronized ? "YES" : "NO"));
  if (_isParentToComponentSynchronized)
    {
      //Synchro Component->SubComponent
      int i=0;
      id aKey=nil;
      GSWAssociation* anAssociation=nil;
      id aValue=nil;
      id logValue=[self valueForBinding:@"GSWDebug"];
      BOOL doLog=boolValueWithDefaultFor(logValue,NO);
      NSDebugMLLog(@"GSWComponent",@"Name=%@ - Synchro Component->SubComponent",
                  [self declarationName]);
      for(i=0;i<[_associationsKeys count];i++)
        {
          aKey=[_associationsKeys  objectAtIndex:i];
          anAssociation=[_associations objectAtIndex:i];
          NSDebugMLLog(@"GSWComponent",@"aKey=%@ anAssociation=%@",aKey,anAssociation);
          if (![anAssociation isKindOfClass:[GSWBindingNameAssociation class]]) //TODOV
            {
              aValue=[anAssociation valueInComponent:_parent];
              NSDebugMLLog(@"GSWComponent",@"aKey=%@ aValue=%@ (%@)",
                           aKey,aValue,NSStringFromClass([aValue class]));
              if (doLog)
                [anAssociation logSynchronizeParentToComponentForValue:aValue
                               inComponent:self];
#if HAVE_GDL2 // GDL2 implementation
              [self smartTakeValue:aValue
                    forKey:aKey];
#else
              [self takeValue:aValue
                    forKey:aKey];
#endif
            };
        };
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)_childTemplate
{
  //OK
  return _childTemplate;
};

//--------------------------------------------------------------------
-(GSWElement*)_template
{
  //OK
  GSWElement* template=_template;
  LOGObjectFnStart();
  if (!template)
    {
      NSDebugMLLog(@"GSWComponent",@"templateName=%@",[self _templateName]);
      template=[self templateWithName:[self _templateName]];
      NSDebugMLLog(@"GSWComponent",@"template=%p",template);
      if ([self isCachingEnabled])
        {
          ASSIGN(_template,template);
        };
    };
  LOGObjectFnStop();
  return template;
};

//--------------------------------------------------------------------
-(GSWComponentDefinition*)_componentDefinition
{
  //OK
  GSWComponentDefinition* aComponentDefinition=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"_componentDefinition=%@",_componentDefinition);
  if (_componentDefinition)
    aComponentDefinition=_componentDefinition;
  else
    {
      NSArray* languages=[self languages];
      NSDebugMLLog(@"GSWComponent",@"languages=%@",languages);
      NSDebugMLLog(@"GSWComponent",@"_name=%@",_name);
      aComponentDefinition=[GSWApp componentDefinitionWithName:_name
                                   languages:languages];
      NSDebugMLLog(@"GSWComponent",@"aComponentDefinition=%@",aComponentDefinition);
      if ([self isCachingEnabled])
        {
          ASSIGN(_componentDefinition,aComponentDefinition);
        };
    };
  LOGObjectFnStop();
  return aComponentDefinition;
};

//--------------------------------------------------------------------
-(NSString*)_templateName
{
  return _templateName;
};

//--------------------------------------------------------------------
-(NSString*)declarationName
{
  return [self _templateName];
};

//--------------------------------------------------------------------
-(BOOL)_isPage
{
  //OK
  return _isPage;
};

//--------------------------------------------------------------------
-(void)_setIsPage:(BOOL)isPage
{
  //OK
  _isPage=isPage;
};

//--------------------------------------------------------------------
-(void)_setContext:(GSWContext*)aContext
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"aContext=%p",(void*)aContext);
  _context=aContext;//NO retain !
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWComponent (GSWResourceManagement)

//--------------------------------------------------------------------
//	templateWithName:

-(GSWElement*)templateWithName:(NSString*)aName
{
  //OK
  GSWElement* template=nil;
  NSArray* languages=nil;
  GSWComponentDefinition* aComponentDefinition=nil;
  LOGObjectFnStart();
  languages=[self languages];
  aComponentDefinition=[self _componentDefinition];
  NSAssert(aComponentDefinition,@"No componentDefinition");
  template=[aComponentDefinition templateWithName:aName
                                 languages:languages];
  NSDebugMLLog(@"GSWComponent",@"aName=%@ template=%@",aName,template);
  LOGObjectFnStop();
  return template;
};

@end

//====================================================================
@implementation GSWComponent (GSWComponentC)

-(GSWComponent*)subComponentForElementID:(NSString*)elementId
{
  //OK
  GSWComponent* subc=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"_elementId=%@",elementId);
  NSDebugMLLog(@"GSWComponent",@"subComponents=%@",_subComponents);
  subc=[_subComponents objectForKey:elementId];
  NSDebugMLLog(@"GSWComponent",@"subc=%@",subc);
  NSDebugMLLog(@"GSWComponent",@"subComponent %@ for _elementId=%@",[subc class],elementId);  
  LOGObjectFnStop();
  return subc;
};

//--------------------------------------------------------------------
-(void)setSubComponent:(GSWComponent*)component
          forElementID:(NSString*)elementId
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"setSubComponent %@ for _elementId=%@",[component class],elementId);  
  NSDebugMLLog(@"GSWComponent",@"elementId=%@",elementId);
  NSDebugMLLog(@"GSWComponent",@"component=%@",component);
  NSDebugMLLog(@"GSWComponent",@"_subComponents=%@",_subComponents);
  if (!_subComponents)
    _subComponents=[NSMutableDictionary new];
  [_subComponents setObject:component
                  forKey:elementId];
  NSDebugMLLog(@"GSWComponent",@"_subComponents=%@",_subComponents);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector
{
  NSArray* parents=nil;
  LOGObjectFnStart();
  parents=[self parents];
  NSDebugMLLog(@"GSWComponent",@"parents=%@",parents);
  [parents makeObjectsPerformSelectorIfPossible:aSelector];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)object
{
  NSArray* parents=nil;
  LOGObjectFnStart();
  parents=[self parents];
  NSDebugMLLog(@"GSWComponent",@"parents=%@",parents);
  [parents makeObjectsPerformSelectorIfPossible:aSelector
           withObject:object];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)object1
                                 withObject:(id)object2
{
  NSArray* parents=nil;
  LOGObjectFnStart();
  parents=[self parents];
  NSDebugMLLog(@"GSWComponent",@"parents=%@",parents);
  [parents makeObjectsPerformSelectorIfPossible:aSelector
           withObject:object1
           withObject:object2];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector
{
  id retValue=nil;
  GSWComponent* obj=[self parent];
  LOGObjectFnStart();
  while(obj)
    {
      if ([obj respondsToSelector:aSelector])
	{
	  retValue=[obj performSelector:aSelector];
	  obj=nil;
	}
      else
	obj=[obj parent];
    };
  LOGObjectFnStop();
  return retValue;
};

//--------------------------------------------------------------------
//NDFN
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector
                               withObject:(id)object
{
  id retValue=nil;
  GSWComponent* obj=[self parent];
  LOGObjectFnStart();
  while(obj)
    {
      if ([obj respondsToSelector:aSelector])
	{
	  retValue=[obj performSelector:aSelector
                        withObject:object];
	  obj=nil;
	}
      else
	obj=[obj parent];
    };
  LOGObjectFnStop();
  return retValue;
};

//--------------------------------------------------------------------
//NDFN
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector
                               withObject:(id)object1
                               withObject:(id)object2
{
  id retValue=nil;
  GSWComponent* obj=[self parent];
  LOGObjectFnStart();
  while(obj)
    {
      if ([obj respondsToSelector:aSelector])
	{
	  retValue=[obj performSelector:aSelector
			 withObject:object1
			 withObject:object2];
	  obj=nil;
	}
      else
	obj=[obj parent];
    };
  LOGObjectFnStop();
  return retValue;
};

//--------------------------------------------------------------------
//NDFN
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector
{
  NSEnumerator* enumerator=nil;
  GSWComponent* component=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"_subComponents=%@",_subComponents);
  enumerator= [_subComponents objectEnumerator];    
  while ((component=[enumerator nextObject]))
    {
      [component performSelectorIfPossible:aSelector];
      [component makeSubComponentsPerformSelectorIfPossible:aSelector];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector
                                       withObject:(id)object
{
  NSEnumerator* enumerator=nil;
  GSWComponent* component=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"_subComponents=%@",_subComponents);
  enumerator= [_subComponents objectEnumerator];    
  while ((component=[enumerator nextObject]))
    {
      [component performSelectorIfPossible:aSelector
                 withObject:object];
      [component makeSubComponentsPerformSelectorIfPossible:aSelector
                 withObject:object];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector
                                       withObject:(id)object1
                                       withObject:(id)object2
{
  NSEnumerator* enumerator=nil;
  GSWComponent* component=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"_subComponents=%@",_subComponents);
  enumerator= [_subComponents objectEnumerator];    
  while ((component=[enumerator nextObject]))
	{
	  [component performSelectorIfPossible:aSelector
                     withObject:object1
                     withObject:object2];
	  [component makeSubComponentsPerformSelectorIfPossible:aSelector
                     withObject:object1
                     withObject:object2];
	};
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWComponent (GSWComponentD)

-(GSWAssociation*)_associationWithName:(NSString*)aName
{
  //OK
  GSWAssociation* assoc=nil;
  unsigned int index=NSNotFound;
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"In %@ Search %@ _associationsKeys=%@",
               NSStringFromClass([self class]),
               aName,_associationsKeys);
  //NSDebugMLLog(@"GSWComponent",@"_associations=%@",[_associations description]);
  if (_associationsKeys)
    {
      index=[_associationsKeys indexOfObject:aName];
      NSDebugMLLog(@"GSWComponent",@"index=%u",index);
      if (index!=NSNotFound)
        assoc=[_associations objectAtIndex:index];
    };
  if (!WOStrictFlag && index==NSNotFound)
    {	  
      assoc=[_defaultAssociations objectForKey:aName];
    };
  NSDebugMLLog(@"GSWComponent",@"In %@ Association for %@=%@",
               NSStringFromClass([self class]),
               aName,assoc);
  LOGObjectFnStop();
  return assoc;
};

@end

//====================================================================
@implementation GSWComponent (GSWSynchronizing)

//--------------------------------------------------------------------
-(BOOL)hasBinding:(NSString*)parentBindingName
{
  //OK
  BOOL hasBinding=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"declarationName=%@ - parentBindingName_=%@",
               [self declarationName],
               parentBindingName);
  if (_associationsKeys)
    {
      int index=[_associationsKeys indexOfObject:parentBindingName];
      NSDebugMLLog(@"GSWComponent",@"index=%u",index);
      hasBinding=(index!=NSNotFound);
    };
  NSDebugMLLog(@"GSWComponent",@"declarationName=%@ - hasBinding=%s",
               [self declarationName],
               (hasBinding ? "YES" : "NO"));
  if (!WOStrictFlag && !hasBinding)
    {	  
      hasBinding=([_defaultAssociations objectForKey:parentBindingName]!=nil);
    };
  LOGObjectFnStop();
  return hasBinding;
};

//--------------------------------------------------------------------
-(void)setValue:(id)value
     forBinding:(NSString*)parentBindingName
{
  //OK
  GSWAssociation* assoc=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"self=%@ declarationName=%@ - parentBindingName_=%@",
               NSStringFromClass([self class]),
               [self declarationName],
               parentBindingName);
  NSDebugMLLog(@"GSWComponent",@"value_=%@",value);
  NSDebugMLLog(@"GSWComponent",@"_parent=%p of class %@",
               (void*)_parent,
               NSStringFromClass([_parent class]));
  if (_parent)
    {
      assoc=[self _associationWithName:parentBindingName];
      NSDebugMLLog(@"GSWComponent",@"assoc for %@=%@",parentBindingName,assoc);
      if(assoc)
        [assoc setValue:value
               inComponent:_parent];
      /* // Why doing this ? Be carefull: it may make a loop !
#if HAVE_GDL2
	  else
          {
          NS_DURING
              {
		[self smartTakeValue:value_ 
                  forKey:parentBindingName_];
               }
	      NS_HANDLER;
               {
                  //TODO
               }
	      NS_ENDHANDLER;
	    }
#endif
*/
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(id)valueForBinding:(NSString*)parentBindingName
{
  //OK
  id aValue=nil;
  GSWAssociation* assoc=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"declarationName=%@",
               [self declarationName]);
  NSDebugMLLog(@"GSWComponent",@"parentBindingName=%@",
               parentBindingName);
  NSDebugMLLog(@"GSWComponent",@"parent=%p of class %@",(void*)_parent,[_parent class]);
  if (_parent)
    {
      assoc=[self _associationWithName:parentBindingName];
      NSDebugMLLog(@"GSWComponent",@"assoc=%@",assoc);
      if(assoc)
        aValue=[assoc valueInComponent:_parent];
/* // Why doing this ? Be carefull: it may make a loop !
#if HAVE_GDL2
	  else
	    {
	      NS_DURING
                {
                  aValue = [self valueForKey:parentBindingName_];
                }
	      NS_HANDLER
                {
                  //TODO
                }
	      NS_ENDHANDLER;
	    }
#endif
*/
	  NSDebugMLLog(@"GSWComponent",@"parentBindingName=%@ aValue=%@ (%@)",
                       parentBindingName,aValue,NSStringFromClass([aValue class]));
	};
  LOGObjectFnStop();
  return aValue; 
};

//--------------------------------------------------------------------
//NDFN
/** Do we need to synchronize parent to component **/
-(BOOL)synchronizesParentToComponentVariablesWithBindings
{
  //OK
  NSDictionary* userDictionary=nil;
  id synchronizesParentToComponentVariablesWithBindingsValue=nil;
  BOOL synchronizesParentToComponentVariablesWithBindings=YES;
  LOGObjectFnStart();
  userDictionary=[self userDictionary];
  synchronizesParentToComponentVariablesWithBindingsValue=[userDictionary objectForKey:@"synchronizesParentToComponentVariablesWithBindings"];
  NSDebugMLLog(@"GSWComponent",@"declarationName=%@ - userDictionary _synchronizesVariablesWithBindingsValue=%@",
               [self declarationName],
               synchronizesParentToComponentVariablesWithBindingsValue);
  //NDFN
  if (synchronizesParentToComponentVariablesWithBindingsValue)
    {
      synchronizesParentToComponentVariablesWithBindings=[synchronizesParentToComponentVariablesWithBindingsValue boolValue];
      NSDebugMLLog(@"GSWComponent",@"userDictionary synchronizesParentToComponentVariablesWithBindings=%s",
                       (synchronizesParentToComponentVariablesWithBindings ? "YES" : "NO"));
    }
  else
    synchronizesParentToComponentVariablesWithBindings=[self synchronizesVariablesWithBindings];
  LOGObjectFnStop();
  return synchronizesParentToComponentVariablesWithBindings;
};

//--------------------------------------------------------------------
//NDFN
/** Do we need to synchronize component to parent **/
-(BOOL)synchronizesComponentToParentVariablesWithBindings
{
  //OK
  NSDictionary* userDictionary=nil;
  id synchronizesComponentToParentVariablesWithBindingsValue=nil;
  BOOL synchronizesComponentToParentVariablesWithBindings=YES;
  LOGObjectFnStart();
  userDictionary=[self userDictionary];
  synchronizesComponentToParentVariablesWithBindingsValue=[userDictionary objectForKey:@"synchronizesComponentToParentVariablesWithBindings"];
  NSDebugMLLog(@"GSWComponent",@"declarationName=%@ - userDictionary _synchronizesVariablesWithBindingsValue=%@",
               [self declarationName],
               synchronizesComponentToParentVariablesWithBindingsValue);
  //NDFN
  if (synchronizesComponentToParentVariablesWithBindingsValue)
    {
      synchronizesComponentToParentVariablesWithBindings=[synchronizesComponentToParentVariablesWithBindingsValue boolValue];
      NSDebugMLLog(@"GSWComponent",@"userDictionary synchronizesComponentToParentVariablesWithBindings=%s",
                       (synchronizesComponentToParentVariablesWithBindings ? "YES" : "NO"));
    }
  else
    synchronizesComponentToParentVariablesWithBindings=[self synchronizesVariablesWithBindings];
  LOGObjectFnStop();
  return synchronizesComponentToParentVariablesWithBindings;
};

//--------------------------------------------------------------------
-(BOOL)synchronizesVariablesWithBindings
{
  //OK
  NSDictionary* userDictionary=nil;
  id synchronizesVariablesWithBindingsValue=nil;
  BOOL synchronizesVariablesWithBindings=YES;
  LOGObjectFnStart();
  userDictionary=[self userDictionary];
  synchronizesVariablesWithBindingsValue=[userDictionary objectForKey:@"synchronizesVariablesWithBindings"];
  NSDebugMLLog(@"GSWComponent",@"declarationName=%@ - userDictionary _synchronizesVariablesWithBindingsValue=%@",
               [self declarationName],
               synchronizesVariablesWithBindingsValue);
  //NDFN
  if (synchronizesVariablesWithBindingsValue)
    {
      synchronizesVariablesWithBindings=[synchronizesVariablesWithBindingsValue boolValue];
      NSDebugMLLog(@"GSWComponent",@"userDictionary synchronizesVariablesWithBindings=%s",
                       (synchronizesVariablesWithBindings ? "YES" : "NO"));
    };
  LOGObjectFnStop();
  return synchronizesVariablesWithBindings;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)bindingAssociations
{
  return [NSDictionary dictionaryWithObjects:_associations
                       forKeys:_associationsKeys];
};

@end

//====================================================================
@implementation GSWComponent (GSWRequestHandling)

//--------------------------------------------------------------------
//	sleep

-(void)sleep 
{
  LOGObjectFnStart();
  //Does Nothing
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)sleepInContext:(GSWContext*)aContext
{
  //OK
  GSWComponentDefinition* aComponentDefinition=nil;
  LOGObjectFnStart();
  NS_DURING
    {      
      aComponentDefinition=[self _componentDefinition];
      [aComponentDefinition sleep];
      [self sleep];
      [self _setContext:nil];
      NSDebugMLLog(@"GSWComponent",@"declarationName=%@ - subComponents=%@",
                   [self declarationName],
                   _subComponents);
      [_subComponents makeObjectsPerformSelector:@selector(sleepInContext:)
                     withObject:aContext];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In sleepInContext:");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    }
  NS_ENDHANDLER;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendToResponse:inContext:

-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext 
{
  //OK
  GSWElement* template=nil;
  GSWRequest* request=nil;
  BOOL isFromClientComponent=NO;
  GSWComponent* component=nil;
#ifndef NDEBUG
  GSWElementIDString* debugElementID=[aContext elementID];
#endif
  LOGObjectFnStart();
  NSAssert(aContext,@"No Context");
  NSAssert(aResponse,@"No Response");
  GSWStartElement(aContext);
  GSWSaveAppendToResponseElementID(aContext);

  template=[self _template];
  NSAssert(template,@"No template");
#ifndef NDEBUG
  if(GSDebugSet(@"gswcomponents"))
    [aResponse appendDebugCommentContentString:[NSString stringWithFormat:@"Start %@ [%@]",[self _templateName],[aContext elementID]]];
#endif

  request=[aContext request];
  NSAssert(request,@"No request");
  isFromClientComponent=[request isFromClientComponent];
  component=[aContext component];
  [aContext appendZeroElementIDComponent];
  NS_DURING
    {
      [aResponse appendDebugCommentContentString:[NSString stringWithFormat:@"declarationName=%@ ID=%@",[self declarationName],[aContext elementID]]];
      NSDebugMLLog(@"GSWComponent",@"COMPONENT START %p declarationName=%@ [aContext elementID]=%@",
                   self,[self declarationName],[aContext elementID]);
      [template appendToResponse:aResponse
                 inContext:aContext];
    }
  NS_HANDLER
    {
      LOGException(@"exception in %@ appendToResponse:inContext",
                   [self class]);
      LOGException(@"exception=%@",localException);
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"In %@ appendToResponse:inContext",
                                                              [self class]);
      LOGException(@"exception=%@",localException);
      [localException raise];
    }
  NS_ENDHANDLER;

  NSDebugMLLog(@"GSWComponent",@"COMPONENT STOP %p declarationName=%@ [aContext elementID]=%@",
               self,[self declarationName],[aContext elementID]);

  [aContext deleteLastElementIDComponent];

  GSWStopElement(aContext);
#ifndef NDEBUG
  if (![debugElementID isEqualToString:[aContext elementID]])
    {
      NSDebugMLLog(@"GSWComponent",@"WARNING: class=%@ debugElementID=%@ [aContext elementID]=%@",
                   [self class],debugElementID,[aContext elementID]);	  
    };
#endif

#ifndef NDEBUG
  if(GSDebugSet(@"gswcomponents") == YES)
    [aResponse appendDebugCommentContentString:
		 [NSString stringWithFormat:@"\n<!-- Stop %@ [%@]-->\n",
			   [self _templateName],
			   [aContext elementID]]];//TODO enlever
#endif
  GSWAssertIsElementID(aContext);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	invokeActionForRequest:inContext:

-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext 
{
  //OK
  GSWElement* element=nil;
  GSWElement* template=nil;
#ifndef NDEBUG
  GSWElementIDString* debugElementID=[aContext elementID];
#endif
  LOGObjectFnStart();
  GSWStartElement(aContext);
  NS_DURING
    {
      GSWAssertCorrectElementID(aContext);
      template=[self _template];
      [aContext appendZeroElementIDComponent];
      element=[[self _template] invokeActionForRequest:aRequest
                                inContext:aContext];
      [aContext deleteLastElementIDComponent];
    }
  NS_HANDLER
    {
      LOGException(@"exception in %@ invokeActionForRequest:inContext",
                   [self class]);
      LOGException(@"exception=%@",localException);
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"In %@ invokeActionForRequest:inContext",
                                                              [self class]);
      LOGException(@"exception=%@",localException);
      [localException raise];
    }
  NS_ENDHANDLER;
  GSWStopElement(aContext);
#ifndef NDEBUG
  if (![debugElementID isEqualToString:[aContext elementID]])
    {
      NSDebugMLLog(@"GSWComponent",@"class=%@ debugElementID=%@ [aContext elementID]=%@",
                   [self class],debugElementID,[aContext elementID]);
      
    };
#endif
//  if (![aContext _wasActionInvoked] && [[[aContext elementID] parentElementIDString] compare:[aContext senderID]]==NSOrderedDescending)
  if (![aContext _wasActionInvoked]
      && [(GSWElementIDString*)[[aContext elementID] parentElementIDString] isSearchOverForSenderID:[aContext senderID]])
    {
      LOGError(@"Action not invoked at the end of %@ (id=%@) senderId=%@",
               [self class],
               [aContext elementID],
               [aContext senderID]);
    };
  GSWAssertIsElementID(aContext);
  LOGObjectFnStop();
  return element;
};

//--------------------------------------------------------------------
//	takeValuesFromRequest:inContext:

-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext 
{
  //OK
  BOOL oldValidateFlag=NO;
  GSWElement* template=nil;
#ifndef NDEBUG
  GSWElementIDString* debugElementID=[aContext elementID];
#endif
  LOGObjectFnStart();
  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);

  [_validationFailureMessages removeAllObjects];
  oldValidateFlag=[aContext isValidate];
  [aContext setValidate:YES];
  template=[self _template];
  [aContext appendZeroElementIDComponent];
  NSDebugMLLog(@"GSWComponent",@"COMPONENT START %p declarationName=%@ [aContext elementID]=%@",
               self,[self declarationName],[aContext elementID]);
  [template takeValuesFromRequest:aRequest
			 inContext:aContext];
  NSDebugMLLog(@"GSWComponent",@"COMPONENT STOP %p declarationName=%@ [aContext elementID]=%@",
               self,[self declarationName],[aContext elementID]);
  [aContext deleteLastElementIDComponent];
  GSWStopElement(aContext);
#ifndef NDEBUG
  if (![debugElementID isEqualToString:[aContext elementID]])
    {
      NSDebugMLLog(@"GSWComponent",@"WARNING class=%@ debugElementID=%@ [aContext elementID]=%@",
                   [self class],debugElementID,[aContext elementID]);
      
    };
#endif
  [aContext setValidate:oldValidateFlag];
  GSWAssertIsElementID(aContext);
  LOGObjectFnStop();
};


//GSWeb Additions {
//--------------------------------------------------------------------
-(void)setValidationFailureMessage:(NSString*)message
                        forElement:(GSWDynamicElement*)element
{
  if (!_validationFailureMessages)
    _validationFailureMessages=[NSMutableDictionary new];
  [_validationFailureMessages setObject:message
                              forKey:[NSValue valueWithNonretainedObject:element]];
};

//--------------------------------------------------------------------
-(NSString*)validationFailureMessageForElement:(GSWDynamicElement*)element
{
  return [_validationFailureMessages objectForKey:[NSValue valueWithNonretainedObject:element]];
};

//--------------------------------------------------------------------
-(NSString*)handleValidationExceptionDefault
{
  return nil; //Raise !
};

//--------------------------------------------------------------------
-(BOOL)isValidationFailure
{
  //TODO ameliorate
  return [[self allValidationFailureMessages] count]>0;
};

//--------------------------------------------------------------------
-(NSDictionary*)validationFailureMessages
{
  LOGObjectFnStart();
  LOGObjectFnStop();
  return _validationFailureMessages;
};

//--------------------------------------------------------------------
-(NSArray*)allValidationFailureMessages
{
  NSMutableArray* msgs=[NSMutableArray array];
  NSEnumerator* subComponentsEnum=nil;
  GSWComponent* component=nil;
  LOGObjectFnStart();
//  NSDebugMLLog(@"GSWComponent",@"validationFailureMessages=%@",validationFailureMessages);
  [msgs addObjectsFromArray:[[self validationFailureMessages] allValues]];
//  NSDebugMLLog(@"GSWComponent",@"_msgs=%@",_msgs);
  subComponentsEnum=[_subComponents objectEnumerator];
  while((component=[subComponentsEnum nextObject]))
    {
      //	  NSDebugMLLog(@"GSWComponent",@"_component=%@",_component);
      [msgs addObjectsFromArray:[component allValidationFailureMessages]];
      //	  NSDebugMLLog(@"GSWComponent",@"_msgs=%@",_msgs);
    };
  msgs=[NSArray arrayWithArray:msgs];
  //  NSDebugMLLog(@"GSWComponent",@"_msgs=%@",_msgs);
  LOGObjectFnStop();
  return msgs;
};

// } 

//--------------------------------------------------------------------
-(void)ensureAwakeInContext:(GSWContext*)aContext
{
  //LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStart();
  if (![self context]) 
    {
      NSDebugMLLog(@"GSWComponent",@"component sleeps, we awake it = %@",self);
      [self awakeInContext:aContext];
    } 
  else 
    {
      if ([self context] != aContext) 
        { 
          NSDebugMLLog(@"GSWComponent",
                       @"component is already awaken, but has not the current context, we awake it twice with current context = %@",
                       self);
          [self awakeInContext:aContext];
	}
    }
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	awake

-(void)awake 
{
  LOGObjectFnStart();
  //Does Nothing
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)awakeInContext:(GSWContext*)aContext
{
  //OK
  GSWComponentDefinition* aComponentDefinition=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent",@"aContext=%@",aContext);
  NSDebugMLLog(@"GSWComponent",@"declarationName=%@",[self declarationName]);
  NSAssert(aContext,@"No Context");
  [self _setContext:aContext];
  aComponentDefinition=[self _componentDefinition];
  [aComponentDefinition setCachingEnabled:[self isCachingEnabled]];
  [aComponentDefinition awake];
  [_subComponents makeObjectsPerformSelector:@selector(awakeInContext:)
                  withObject:aContext];
  [aComponentDefinition _awakeObserversForComponent:self];
  [self awake];
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWComponent (GSWActionInvocation)

//--------------------------------------------------------------------
//	performParentAction:

- (id)performParentAction:(NSString *)attribute
{
  GSWAssociation *assoc=nil;
  id ret=nil;

  LOGObjectFnStart();
  NSDebugMLLog(@"GSWComponent", @"name=%@ - parent=%p",
               [self declarationName],
               (void*)_parent);
  if (_parent)
    {
      assoc = [self _associationWithName:attribute];
      NSDebugMLLog(@"GSWComponent", @"assoc=%@", assoc);

      if(assoc && [assoc isValueConstant] == YES)
	{
	  NSString *aValue = [assoc valueInComponent:self];

	  if(aValue)
	    ret = [_parent performSelector:NSSelectorFromString(aValue)];
	}
    }

  LOGObjectFnStop();

  return ret;
};

//--------------------------------------------------------------------
-(GSWComponent*)parent
{
  //OK
  return _parent;
};

//--------------------------------------------------------------------
//NDFN
-(GSWComponent*)topParent
{
  GSWComponent* parent=[self parent];
  GSWComponent* topParent=parent;
  while (parent)
    {
      topParent=parent;
      parent=[parent parent];
    };
  return topParent;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)parents
{
  NSMutableArray* parents=[NSMutableArray array];
  GSWComponent* parent=[self parent];
  while (parent)
    {
      [parents addObject:parent];
      parent=[parent parent];
    };
  return [NSArray arrayWithArray:parents];
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)parentsClasses
{
  NSMutableArray* parents=[NSMutableArray array];
  GSWComponent* parent=[self parent];
  while (parent)
    {
      [parents addObject:[parent class]];
      parent=[parent parent];
    };
  return [NSArray arrayWithArray:parents];
};

@end

//====================================================================
@implementation GSWComponent (GSWConveniences)
-(GSWComponent*)pageWithName:(NSString*)aName
{
  //OK
  GSWComponent* page=nil;
  GSWContext* aContext=nil;
  LOGObjectFnStart();
  aContext=[self context];
  page=[GSWApp pageWithName:aName
               inContext:aContext];
  LOGObjectFnStop();
  return page;
};

//--------------------------------------------------------------------
//	session

-(GSWSession*)session 
{
  GSWSession* session=nil;
  if (_session)
    session=_session;
  else if (_context)
    session=[_context session];
  return session;
};

//--------------------------------------------------------------------
-(BOOL)hasSession
{
  return (_session!=nil);
};

//--------------------------------------------------------------------
//	application

-(GSWApplication*)application 
{
  return [GSWApplication application];
};

//--------------------------------------------------------------------
//	context

-(GSWContext*)context 
{
  return _context;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)languages
{
  NSArray* languages=nil;
  LOGObjectFnStart();
  languages=[[self context] languages];
  LOGObjectFnStop();
  return languages;
};

@end

//====================================================================
@implementation GSWComponent (GSWLogging)
//--------------------------------------------------------------------
//Called when an Enterprise Object or formatter failed validation during an
//assignment. 
//The default implementation ignores the error. Subclassers can override to
// record the error and possibly return a different page for the current action.
-(void)validationFailedWithException:(NSException*)exception
                               value:(id)aValue
                             keyPath:(id)keyPath
{
  // Does nothing
  LOGObjectFnStart();
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_debugWithString:(NSString*)string
{
  LOGObjectFnNotImplemented();	//TODOFN
/* Seems there's a problem with patches... Why this code is here ?
   LOGObjectFnStart();
   if (![self context])
     {
       NSDebugMLLog(@"GSWComponent",@"component sleeps, we awake it = %@",self);
       [self awakeInContext:aContext];
     }
   else
     {
       if ([self context] != aContext)
         { 
           NSDebugMLLog(@"GSWComponent",@"component is already awaken, but has not the current context, we awake it twice with current context = %@",self);
           [self awakeInContext:aContext];
         };
     };
   LOGObjectFnStop();
*/
};

//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)format,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)format,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)format
           arguments:(va_list)argList
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(void)logWithFormat:(NSString*)format,...
{
  LOGClassFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWComponent (GSWComponentJ)

-(NSString*)_uniqueID
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWComponent (GSWComponentK)

//--------------------------------------------------------------------
-(void)_appendPageToResponse:(GSWResponse*)response
                   inContext:(GSWContext*)aContext
{
  //OK
  GSWSession* session=nil;
  GSWRequest* request=nil;
  NSString* httpVersion=nil;
  GSWElement* pageElement=nil;
  BOOL pageChanged=NO;
  LOGObjectFnStart();
  NSAssert(aContext,@"No context");
  NS_DURING
    {
      [aContext deleteAllElementIDComponents];
      request=[aContext request];
      NSDebugMLLog(@"GSWComponent",@"request=%@",request);
      httpVersion=(request ? [request httpVersion] : @"HTTP/1.0");
      [response setHTTPVersion:httpVersion];
      if (request)
        [response setAcceptedEncodings:[request browserAcceptedEncodings]];
      [response setHeader:@"text/html"
                forKey:@"content-type"];
      NSDebugMLLog(@"GSWComponent",@"response=%@",response);
      [aContext _setResponse:response];

      pageElement=[aContext _pageElement];
      NSDebugMLLog(@"GSWComponent",@"pageElement=%@",pageElement);

      pageChanged=(self!=(GSWComponent*)pageElement);
      NSDebugMLLog(@"GSWComponent",@"pageChanged=%d",pageChanged);
      [aContext _setPageChanged:pageChanged];

      if (pageChanged)
        [aContext _setPageElement:self];

      [aContext _setCurrentComponent:self];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"in GSWComponent -_generateResponseInContext:");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    };
  NS_ENDHANDLER;
  
  NS_DURING
    {
      [self appendToResponse:response
            inContext:aContext];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"in GSWComponent -_generateResponseInContext:");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    };
  NS_ENDHANDLER;
  
  NS_DURING
    {
      session=[aContext _session];
      NSDebugMLLog(@"GSWComponent",@"session=%@",session);
      if (session)
        {
          NSDebugMLLog(@"GSWComponent",@"sessionID=%@",[session sessionID]);
          [session appendCookieToResponse:response];
          NSDebugMLLog(@"GSWComponent",@"sessionID=%@",[session sessionID]);
          [session _saveCurrentPage];
        };
      [aContext _incrementContextID];
      [aContext deleteAllElementIDComponents];
      [aContext _setPageChanged:YES];
      //[aContext _setPageReplaced:NO];
      NSDebugMLLog(@"GSWComponent",@"sessionID=%@",[session sessionID]);
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"in GSWComponent -_generateResponseInContext:");
      LOGException(@"%@ (%@)",localException,[localException reason]);
      [localException raise];
    };
  NS_ENDHANDLER;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWResponse*)_generateResponseInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;
  LOGObjectFnStart();
  NSAssert(aContext,@"No context");
  response=[GSWApp createResponseInContext:aContext];
  [self _appendPageToResponse:response
        inContext:aContext];
  return response;
};

//--------------------------------------------------------------------
-(NSException*)validateValue:(id*)valuePtr
                      forKey:(NSString*)key
{
  NSException* exception=nil;
  LOGObjectFnStart();
/*
  // Should all default implementation (i.e. the one which call validateXX:
  exception=[super validateValue:valuePtr
                   forKey:key];
*/
  LOGObjectFnStop();
  return exception;
};

@end

//====================================================================
@implementation GSWComponent (GSWComponentL)

//--------------------------------------------------------------------
//	stringForKey:inTableNamed:withDefaultValue:

-(NSString*)stringForKey:(NSString*)key
            inTableNamed:(NSString*)tableName
        withDefaultValue:(NSString*)defaultValue
{
  //OK
  NSString* string=nil;
/*
  NSArray* languages=nil;
  GSWComponentDefinition* aComponentDefinition=nil;
  LOGObjectFnStart();
  languages=[self languages];
  aComponentDefinition=[self _componentDefinition];
  if (aComponentDefinition)
	string=[aComponentDefinition stringForKey:key
        inTableNamed:tableName
        withDefaultValue:defaultValue
        languages:languages];
        else
	string=defaultValue;
*/
  LOGObjectFnStart();
  string=[GSWApp stringForKey:key
                 inTableNamed:tableName
                 withDefaultValue:defaultValue
                 inFramework:[self frameworkName]
                 languages:[self languages]];
  LOGObjectFnStop();
  return string;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aName
{
  //OK
  NSDictionary* stringsTable=nil;
/*  NSArray* languages=nil;
  GSWComponentDefinition* aComponentDefinition=nil;
  LOGObjectFnStart();
  languages=[self languages];
  aComponentDefinition=[self _componentDefinition];
  if (aComponentDefinition)
	stringsTable=[aComponentDefinition stringsTableNamed:aName
        withLanguages:languages];
*/
  LOGObjectFnStart();
  stringsTable=[GSWApp stringsTableNamed:aName
                       inFramework:[self frameworkName]
                       languages:[self languages]];
  LOGObjectFnStop();
  return stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aName
{
  //OK
  NSArray* stringsTableArray=nil;
/*
  NSArray* languages=nil;
  GSWComponentDefinition* aComponentDefinition=nil;
  LOGObjectFnStart();
  languages=[self languages];
  aComponentDefinition=[self _componentDefinition];
  if (aComponentDefinition)
	stringsTableArray=[aComponentDefinition stringsTableArrayNamed:aName
        withLanguages:languages];
*/
  LOGObjectFnStart();
  stringsTableArray=[GSWApp stringsTableArrayNamed:aName
                            inFramework:[self frameworkName]
                            languages:[self languages]];
  LOGObjectFnStop();
  return stringsTableArray;
};


//--------------------------------------------------------------------
//	urlForResourceNamed:ofType:

-(NSString*)urlForResourceNamed:(NSString*)aName
                         ofType:(NSString*)type
{
  //TODO
  NSString* url=nil;
/*  NSArray* languages=nil;
  GSWComponentDefinition* aComponentDefinition=nil;
  LOGObjectFnStart();
  languages=[self languages];
  aComponentDefinition=[self _componentDefinition];
  if (aComponentDefinition)
	url=[aComponentDefinition urlForResourceNamed:aName
        ofType:type
        languages:languages
        request:nil];//TODO
*/
  LOGObjectFnStart();
  url=[GSWApp urlForResourceNamed:(type ? [NSString stringWithFormat:@"%@.%@",aName,type] : aName)
              inFramework:[self frameworkName]
              languages:[self languages]
              request:nil];//TODO
  LOGObjectFnStop();
  return url;
};

//--------------------------------------------------------------------
-(NSString*)_urlForResourceNamed:(NSString*)aName
                          ofType:(NSString*)type
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
//	pathForResourceNamed:ofType:
// Normally: local search. Here we do a resourceManager serahc.
-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)type
{
  NSString* path=nil;
/*  NSArray* languages=nil;
  GSWComponentDefinition* aComponentDefinition=nil;
  LOGObjectFnStart();
  languages=[self languages];
  aComponentDefinition=[self _componentDefinition];
  if (aComponentDefinition)
	path=[aComponentDefinition pathForResourceNamed:aName
        ofType:type
        languages:languages];
*/
  LOGObjectFnStart();
  path=[GSWApp pathForResourceNamed:aName
				ofType:type
               inFramework:[self frameworkName]
               languages:[self languages]];
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)pathForComponentResourceNamed:(NSString*)aName
                                   ofType:(NSString*)type_ 
{
  NSString* path=nil;
  NSArray* languages=nil;
  GSWComponentDefinition* aComponentDefinition=nil;
  LOGObjectFnStart();
  languages=[self languages];
  aComponentDefinition=[self _componentDefinition];
  if (aComponentDefinition)
    path=[aComponentDefinition pathForResourceNamed:aName
                               ofType:type_
                               languages:languages];
  return path;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)stringForKey:(id)key
            inTableNamed:(NSString*)aName
        withDefaultValue:(NSString*)defaultValue
             inFramework:(NSString*)aFrameworkName
{
  return [GSWApp stringForKey:key
                 inTableNamed:aName
                 withDefaultValue:defaultValue
                 inFramework:aFrameworkName
                 languages:[self languages]];
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aName
                      inFramework:(NSString*)aFrameworkName
{
  return [GSWApp stringsTableNamed:aName
                 inFramework:aFrameworkName
                 languages:[self languages]];
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aName
                      inFramework:(NSString*)aFrameworkName
{
  return [GSWApp stringsTableArrayNamed:aName
                 inFramework:aFrameworkName
                 languages:[self languages]];
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlForResourceNamed:(NSString*)aName
                         ofType:(NSString*)extension
                    inFramework:(NSString*)aFrameworkName;
{
  return [GSWApp urlForResourceNamed:(extension ? [NSString stringWithFormat:@"%@.%@",aName,extension] : aName)
                 inFramework:aFrameworkName
                 languages:[self languages]
                 request:nil];//TODO
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)extension
                     inFramework:(NSString*)aFrameworkName
{
  return [GSWApp pathForResourceNamed:aName
                 ofType:(NSString*)extension
                 inFramework:aFrameworkName
                 languages:[self languages]];
};

@end

//====================================================================
@implementation GSWComponent (GSWTemplateParsing)

//--------------------------------------------------------------------
//	templateWithHTMLString:declarationString:languages

//--------------------------------------------------------------------
+(GSWElement*)templateWithHTMLString:(NSString*)htmlString
                   declarationString:(NSString*)pageDefString
                           languages:(NSArray*)languages
{
  GSWElement* rootElement=nil;
  NSDebugMLog0(@"Begin GSWComponent:templateWithHTMLString...");
  rootElement=[GSWTemplateParser templateWithHTMLString:htmlString
                                 declarationString:pageDefString
                                 languages:languages];
  return rootElement;
};

@end

//====================================================================
@implementation GSWComponent (GSWTemplateParsingOldFn)
//--------------------------------------------------------------------
//	templateWithHTMLString:declarationString:
//old
+(GSWElement*)templateWithHTMLString:(NSString*)htmlString
                   declarationString:(NSString*)pageDefString
{
  return [self templateWithHTMLString:htmlString
               declarationString:pageDefString
               languages:nil];
};


@end
//====================================================================
@implementation GSWComponent (GSWActionResults)

//--------------------------------------------------------------------
-(GSWResponse*)generateResponse
{
  //OK
  GSWResponse* response=nil;
  GSWContext* aContext=nil;
  LOGObjectFnStart();
  aContext=[self context];
  response=[self _generateResponseInContext:aContext];
  LOGObjectFnStop();
  return response;
};

@end


//====================================================================
@implementation GSWComponent (GSWStatistics)

//--------------------------------------------------------------------
//	descriptionForResponse:inContext:

-(NSString*)descriptionForResponse:(GSWResponse*)aResponse
                         inContext:(GSWContext*)aContext 
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWComponent (GSWComponentClassA)
+(void)_registerObserver:(id)observer
{
  LOGClassFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWComponent (GSWVerifyAPI)
-(void)validateAPIAssociations
{
  NSDictionary* api=[[self _componentDefinition] componentAPI];
  if (api)
    {
      NSArray* required=[api objectForKey:@"Required"];
      //TODO useit NSArray* optional=[api objectForKey:@"Optional"];
      int i=0;
      int count=[required count];
      id aName=nil;
      for(i=0;i<count;i++)
        {
          aName=[required objectAtIndex:i];
          if (![self hasBinding:aName])
            {
              [NSException raise:NSGenericException
                           format:@"There is no binding for '%@' in parent '%@' for component '%@' [parents : %@]",
                           aName,
                           [_parent class],
                           [self class],
                           [self parentsClasses]];
            };
        };
    };
};
@end

