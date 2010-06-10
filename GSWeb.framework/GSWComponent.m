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

#include "GSWPrivate.h"
#include "WOKeyValueUnarchiver.h"
#include <GNUstepBase/NSObject+GNUstepBase.h>
#include <GNUstepBase/NSString+GNUstepBase.h>

//====================================================================
@implementation GSWComponent

/* Static variables */

static NSMutableDictionary * TheTemplateNameDictionary;
static NSLock * TheTemplateNameDictionaryLock;
static Class GSWHTMLBareStringClass = Nil;

+ (void) initialize
{
  if (self == [GSWComponent class]) {
    TheTemplateNameDictionary = [NSMutableDictionary new];
    TheTemplateNameDictionaryLock = [[NSLock alloc] init];
    GSWHTMLBareStringClass = [GSWHTMLBareString class];
  }
}

// deprecated. use initWithContext:

-(id)init
{
//  NSLog(@"%s init: deprecated. use initWithContext", class_getName([self class]));
  return [self initWithContext:[GSWComponentDefinition TheTemporaryContext]];
}


- (id)initWithContext:(GSWContext *) aContext
{
  Class myClass = Nil;
  GSWComponentDefinition* aComponentDefinition = nil;
  
  if ((self=[super init])) {
    if (aContext == nil) {
      [NSException raise:NSInvalidArgumentException
                  format:@"Attempt to init component without a context. In %s",
                         __PRETTY_FUNCTION__];
    }

    [self _setContext:aContext];
    myClass = [self class];
    if (myClass == ([GSWComponent class])) {
      ASSIGN(_name, [aContext _componentName]);
    } else {
      ASSIGN(_name, [NSString stringWithCString:object_getClassName(self)]);
    }
    ASSIGN(_templateName,[NSString stringWithCString:class_getName(myClass)]);
    _isPage = NO;
    _subComponents = nil;
    [self setCachingEnabled:[GSWApp isCachingEnabled]];
    ASSIGN(_componentDefinition, [aContext _tempComponentDefinition]);
    aComponentDefinition = [self _componentDefinition];
    if (aComponentDefinition != nil) {
      [aComponentDefinition finishInitializingComponent:self];
    }
    _isSynchronized = [self synchronizesVariablesWithBindings];
  }

  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{

  DESTROY(_keyAssociations);
  DESTROY(_childTemplate);
  DESTROY(_componentDefinition);
  DESTROY(_defaultAssociations);
  DESTROY(_name);
  DESTROY(_subComponents);
  DESTROY(_template);
  DESTROY(_templateName);
  DESTROY(_userAssociations);
  DESTROY(_userDictionary);
  DESTROY(_validationFailureMessages);

  DESTROY(_context); //_context=nil;
  _parent = nil;
  _session = nil;
  
  [super dealloc];
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
  ASSIGNCOPY(clone->_keyAssociations, _keyAssociations);
  ASSIGNCOPY(clone->_childTemplate,_childTemplate);
  ASSIGNCOPY(clone->_context,_context);
  ASSIGNCOPY(clone->_session,_session);
  clone->_isPage=_isPage;
  clone->_isCachingEnabled=_isCachingEnabled;
//  clone->_isParentToComponentSynchronized=_isParentToComponentSynchronized;
//  clone->_isComponentToParentSynchronized=_isComponentToParentSynchronized;
  return clone;
}

//--------------------------------------------------------------------
//-(void)encodeWithCoder:(NSCoder*)aCoder
//{
//  //TODOV
//  [super encodeWithCoder:aCoder];
//  [aCoder encodeObject:_name];
//  [aCoder encodeObject:_subComponents];
//  [aCoder encodeObject:_templateName];
//  [aCoder encodeObject:_template];
//  [aCoder encodeObject:_componentDefinition];
//  [aCoder encodeObject:_parent];
//  [aCoder encodeObject:_keyAssociations];
//  [aCoder encodeObject:_childTemplate];
//  [aCoder encodeObject:_context];
//  [aCoder encodeObject:_session];
//  [aCoder encodeValueOfObjCType:@encode(BOOL)
//          at:&_isPage];
//  [aCoder encodeValueOfObjCType:@encode(BOOL)
//          at:&_isCachingEnabled];
////  [aCoder encodeValueOfObjCType:@encode(BOOL)
////          at:&_isParentToComponentSynchronized];
////  [aCoder encodeValueOfObjCType:@encode(BOOL)
////          at:&_isComponentToParentSynchronized];
//}
//
////--------------------------------------------------------------------
//-(id)initWithCoder:(NSCoder*)aCoder
//{
//  //TODOV
//  if ((self = [super initWithCoder:aCoder]))
//    {
//      [aCoder decodeValueOfObjCType:@encode(id)
//              at:&_name];
//      [aCoder decodeValueOfObjCType:@encode(id)
//              at:&_subComponents];
//      [aCoder decodeValueOfObjCType:@encode(id)
//              at:&_templateName];
//      [aCoder decodeValueOfObjCType:@encode(id)
//              at:&_template];
//      [aCoder decodeValueOfObjCType:@encode(id)
//              at:&_componentDefinition];
//      [aCoder decodeValueOfObjCType:@encode(id)
//              at:&_parent];
//      [aCoder decodeValueOfObjCType:@encode(id)
//              at:&_keyAssociations];
//      [aCoder decodeValueOfObjCType:@encode(id)
//              at:&_childTemplate];
//      [aCoder decodeValueOfObjCType:@encode(id)
//              at:&_context];
//      [aCoder decodeValueOfObjCType:@encode(id)
//              at:&_session];
//      [aCoder decodeValueOfObjCType:@encode(BOOL)
//              at:&_isPage];
//      [aCoder decodeValueOfObjCType:@encode(BOOL)
//              at:&_isCachingEnabled];
////      [aCoder decodeValueOfObjCType:@encode(BOOL)
////              at:&_isParentToComponentSynchronized];
////      [aCoder decodeValueOfObjCType:@encode(BOOL)
////              at:&_isComponentToParentSynchronized];
//	}
//  return self;
//}
//
//--------------------------------------------------------------------
//	frameworkName

-(NSString*)frameworkName 
{
  //OK
  NSString* aFrameworkName=nil;
  GSWComponentDefinition* aComponentDefinition=nil;

  aComponentDefinition=[self _componentDefinition];
  NSAssert(aComponentDefinition,@"No componentDefinition");
  aFrameworkName=[aComponentDefinition frameworkName];

  return aFrameworkName;
}

//--------------------------------------------------------------------
//	logString:

-(void)logString:(NSString*)aString
{
  [GSWApp logString:aString];
}

//--------------------------------------------------------------------
//	logWithFormat:

-(void)logWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [self logWithFormat:aFormat
        arguments:ap];
  va_end(ap);
}

//--------------------------------------------------------------------
//	logWithFormat:arguments:

-(void)logWithFormat:(NSString*)aFormat
           arguments:(va_list)arguments
{
  NSString* string=[NSString stringWithFormat:aFormat
                             arguments:arguments];
  [self logString:string];
}

//--------------------------------------------------------------------
//	name

-(NSString*)name 
{
  return _name;
}

//--------------------------------------------------------------------
//	path

-(NSString*)path 
{
  //TODOV
  NSBundle* bundle=[NSBundle mainBundle];
  return [bundle pathForResource:_name
                 ofType:GSWPageSuffix[GSWebNamingConv]];
}

//--------------------------------------------------------------------
//	baseURL

-(NSString*)baseURL 
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
}


//--------------------------------------------------------------------
-(NSString*)description
{
  //TODO
  NSString* dscr=nil;

  dscr=[NSString stringWithFormat:@"<%s %p>",
				  object_getClassName(self),
				  (void*)self];

  return dscr;
}

// GSWeb Additions {
//--------------------------------------------------------------------
-(NSDictionary*)userDictionary
{
  return _userDictionary;
}

//--------------------------------------------------------------------
-(void)setUserDictionary:(NSDictionary*)aUserDictionary
{
  ASSIGN(_userDictionary,aUserDictionary);
}

//--------------------------------------------------------------------
-(NSDictionary*)userAssociations
{
  return _userAssociations;
}

//--------------------------------------------------------------------
-(void)setUserAssociations:(NSDictionary*)userAssociations
{
  ASSIGN(_userAssociations,userAssociations);
}

//--------------------------------------------------------------------
-(GSWAssociation*)userAssociationForKey:(NSString*)key
{
  return [[self userAssociations]objectForKey:key];
}

//--------------------------------------------------------------------
-(NSDictionary*)defaultAssociations
{
  NSLog(@"WARNING: %s is not WebObjects API",__PRETTY_FUNCTION__);
  return _defaultAssociations;
}

//--------------------------------------------------------------------
-(void)setDefaultAssociations:(NSDictionary*)defaultAssociations
{
  NSLog(@"WARNING: %s is not WebObjects API",__PRETTY_FUNCTION__);
  ASSIGN(_defaultAssociations,defaultAssociations);
}

//--------------------------------------------------------------------
-(GSWAssociation*)defaultAssociationForKey:(NSString*)key
{
  NSLog(@"WARNING: %s is not WebObjects API",__PRETTY_FUNCTION__);

  return [[self defaultAssociations]objectForKey:key];
}

// }


//--------------------------------------------------------------------
//setCachingEnabled:

-(void)setCachingEnabled:(BOOL)caching
{
  //OK
  _isCachingEnabled=caching;
}

//--------------------------------------------------------------------
//isCachingEnabled

-(BOOL)isCachingEnabled 
{
  //OK
  return _isCachingEnabled;
}

-(void) _setParent:(GSWComponent*) parent
      associations:(NSMutableDictionary *) assocdict
          template:(GSWElement*) template
{
  if (parent != _parent) {
    _parent = parent;
  }
  if (assocdict != _keyAssociations) {
    ASSIGN(_keyAssociations, assocdict);    
  }
  if (template != _childTemplate) {
    ASSIGN(_childTemplate,template);
  }
  //  not WO!
  //  [self validateAPIAssociations];
}

//--------------------------------------------------------------------

-(void) _doPushValuesUp
{
  NSEnumerator       * enumer = nil;
  NSString           * aKey = nil; 
  GSWAssociation     * assoc = nil;

  if (_isSynchronized && (_keyAssociations != nil)) {
    enumer = [_keyAssociations keyEnumerator];
    while ((aKey = [enumer nextObject])) {
      assoc = [_keyAssociations objectForKey: aKey];
      if ([assoc isValueSettableInComponent:self]) {
        [assoc setValue:[self valueForKey: aKey]
                    inComponent:_parent];
      }
    }
  }
}

-(void) pushValuesToParent
{
  GSWComponentDefinition * componentdefinition = nil;
  
  if (_isSynchronized) {
    [self _doPushValuesUp];
  }
  componentdefinition = [self _componentDefinition];
  if ([componentdefinition isStateless]) {
    [self reset];
    _parent = nil;  // no retain? dw
    _session = nil;
    DESTROY(_context);
    [componentdefinition _checkInComponentInstance:self];
  }
}

-(void)synchronizeComponentToParent
{
  NSLog(@"WARNING: %s is deprecated. Use pushValuesToParent instead.", __PRETTY_FUNCTION__);
  [self pushValuesToParent];
}

//--------------------------------------------------------------------


-(void) pullValuesFromParent
{
  NSEnumerator       * enumer = nil;
  NSString           * myKey = nil;
  id                 obj; 
  GSWAssociation     * assoc = nil;
  
  if (_isSynchronized && (_keyAssociations != nil)) {
    enumer = [_keyAssociations keyEnumerator];
    
    while ((myKey = [enumer nextObject])) {
      assoc = [_keyAssociations objectForKey: myKey];
      obj = [assoc valueInComponent:_parent];        
      [self setValue: obj
              forKey: myKey];
    }
    
  }
}

-(void) synchronizeParentToComponent
{
//  NSLog(@"WARNING: %s is deprecated. Use pullValuesFromParent instead.", __PRETTY_FUNCTION__);
  [self pullValuesFromParent];
}

//--------------------------------------------------------------------
-(GSWElement*)_childTemplate
{
  //OK
  return _childTemplate;
}

//--------------------------------------------------------------------
-(GSWElement*) template
{
  GSWElement* element = nil;
  if (_template != element) {
    element = _template;
  } else {
    element = [self templateWithName:nil];
    if ([self isCachingEnabled]) {
        ASSIGN(_template, element);
    }
  }
  return element;
}

-(GSWElement*)_template
{
  NSLog(@"WARNING: %s is deprecated. Use template instead.", __PRETTY_FUNCTION__);

  return [self template];
}

//--------------------------------------------------------------------
-(GSWComponentDefinition*)_componentDefinition
{
  GSWComponentDefinition* aComponentDefinition=nil;

  if (_componentDefinition) {
    aComponentDefinition=_componentDefinition;
  } else {
    NSArray* languages=[self languages];
    aComponentDefinition=[GSWApp _componentDefinitionWithName:_name
                                 languages:languages];
    if ([self isCachingEnabled]) {
        ASSIGN(_componentDefinition,aComponentDefinition);
    }
  }

  return aComponentDefinition;
}

//--------------------------------------------------------------------
-(NSString*)_templateName
{
  return _templateName;
}

//--------------------------------------------------------------------
-(NSString*)declarationName
{
  return _templateName;
}

//--------------------------------------------------------------------
-(BOOL)_isPage
{
  //OK
  return _isPage;
}

//--------------------------------------------------------------------
-(void)_setIsPage:(BOOL)isPage
{
  //OK
  _isPage=isPage;
}

//--------------------------------------------------------------------
-(void)_setContext:(GSWContext*)aContext
{
  // Verified with WO 4.5. We DO retain!
  ASSIGN(_context, aContext);
}


//--------------------------------------------------------------------
//	templateWithName:

// templateWithName is deprecated but I do not know in which version of WO

-(GSWElement*)templateWithName:(NSString*)aName
{
    return [[self _componentDefinition] template];
}


-(GSWComponent*)subComponentForElementID:(NSString*)elementId
{
  //OK
  GSWComponent* subc=nil;

  subc=[_subComponents objectForKey:elementId];

  return subc;
}

//--------------------------------------------------------------------
-(void)_setSubcomponent:(GSWComponent*)component
           forElementID:(NSString*)elementId
{
  if (!_subComponents)
    _subComponents=[NSMutableDictionary new];
  [_subComponents setObject:component
                  forKey:elementId];
}

//--------------------------------------------------------------------
//NDFN
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector
{
  NSArray* parents=nil;

  parents=[self parents];
  [parents makeObjectsPerformSelectorIfPossible:aSelector];
}

//--------------------------------------------------------------------
//NDFN
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)object
{
  NSArray* parents=nil;
  parents = [self parents];

  [parents makeObjectsPerformSelectorIfPossible:aSelector
           withObject:object];
}

//--------------------------------------------------------------------
//NDFN
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)object1
                                 withObject:(id)object2
{
  NSArray* parents=nil;

  parents=[self parents];

  [parents makeObjectsPerformSelectorIfPossible:aSelector
           withObject:object1
           withObject:object2];

}

//--------------------------------------------------------------------
//NDFN
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector
{
  id retValue=nil;
  GSWComponent* obj=[self parent];

  while(obj)
    {
      if ([obj respondsToSelector:aSelector])
	{
	  retValue=[obj performSelector:aSelector];
	  obj=nil;
	}
      else
	obj=[obj parent];
    }

  return retValue;
}

//--------------------------------------------------------------------
//NDFN
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector
                               withObject:(id)object
{
  id retValue=nil;
  GSWComponent* obj=[self parent];

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
    }

  return retValue;
}

//--------------------------------------------------------------------
//NDFN
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector
                               withObject:(id)object1
                               withObject:(id)object2
{
  id retValue=nil;
  GSWComponent* obj=[self parent];

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
    }

  return retValue;
}

//--------------------------------------------------------------------
//NDFN
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector
{
  NSEnumerator* enumerator=nil;
  GSWComponent* component=nil;

  enumerator= [_subComponents objectEnumerator];    
  while ((component=[enumerator nextObject]))
    {
      [component performSelectorIfPossible:aSelector];
      [component makeSubComponentsPerformSelectorIfPossible:aSelector];
    }
}

//--------------------------------------------------------------------
//NDFN
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector
                                       withObject:(id)object
{
  NSEnumerator* enumerator=nil;
  GSWComponent* component=nil;

  enumerator= [_subComponents objectEnumerator];    
  while ((component=[enumerator nextObject]))
    {
      [component performSelectorIfPossible:aSelector
                 withObject:object];
      [component makeSubComponentsPerformSelectorIfPossible:aSelector
                 withObject:object];
    }
}

//--------------------------------------------------------------------
//NDFN
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector
                                       withObject:(id)object1
                                       withObject:(id)object2
{
  NSEnumerator* enumerator=nil;
  GSWComponent* component=nil;

  enumerator= [_subComponents objectEnumerator];    
  while ((component=[enumerator nextObject]))
	{
	  [component performSelectorIfPossible:aSelector
                     withObject:object1
                     withObject:object2];
	  [component makeSubComponentsPerformSelectorIfPossible:aSelector
                     withObject:object1
                     withObject:object2];
	}
}


//PRIVATE
-(GSWComponent*) _subcomponentForElementWithID:(NSString*) str
{
  if ((_subComponents != nil) && (str != nil)) {
    return [_subComponents objectForKey:str];
  }
  return nil;
}

-(GSWAssociation*)_associationWithName:(NSString*)aName
{
  GSWAssociation* assoc=nil;

  if (_keyAssociations != nil) {
    assoc = [_keyAssociations objectForKey: aName];
  }

  return assoc;
}


-(BOOL)hasBinding:(NSString*)parentBindingName
{
  BOOL hasBinding = NO;
  GSWAssociation * association = [self _associationWithName: parentBindingName];

  hasBinding = (association != nil);
  if (hasBinding) {
    hasBinding = [association _hasBindingInParent:_parent];
  }
  return hasBinding;
}

//--------------------------------------------------------------------
-(void)setValue:(id)value
     forBinding:(NSString*)parentBindingName
{
  GSWAssociation* assoc=nil;
  
  if (_parent)
  {
    assoc=[self _associationWithName:parentBindingName];
    if(assoc)
      [assoc setValue:value
          inComponent:_parent];
	}
}

//--------------------------------------------------------------------
-(id)valueForBinding:(NSString*)parentBindingName
{
  id aValue=nil;
  GSWAssociation* assoc=nil;
  
  if (_parent)
  {
    assoc=[self _associationWithName:parentBindingName];
    if(assoc)
      aValue=[assoc valueInComponent:_parent];
	}
  
  return aValue; 
}

//--------------------------------------------------------------------
//NDFN
/** Do we need to synchronize parent to component **/
-(BOOL)synchronizesParentToComponentVariablesWithBindings
{
  //OK
  NSDictionary* userDictionary=nil;
  id synchronizesParentToComponentVariablesWithBindingsValue=nil;
  BOOL synchronizesParentToComponentVariablesWithBindings=YES;

  userDictionary=[self userDictionary];
  synchronizesParentToComponentVariablesWithBindingsValue=[userDictionary objectForKey:@"synchronizesParentToComponentVariablesWithBindings"];

  //NDFN
  if (synchronizesParentToComponentVariablesWithBindingsValue)
    {
      synchronizesParentToComponentVariablesWithBindings=[synchronizesParentToComponentVariablesWithBindingsValue boolValue];
    }
  else
    synchronizesParentToComponentVariablesWithBindings=[self synchronizesVariablesWithBindings];

  return synchronizesParentToComponentVariablesWithBindings;
}

//--------------------------------------------------------------------
-(BOOL)synchronizesVariablesWithBindings
{
   return (![self isStateless]);
}

-(BOOL) isStateless
{
  return NO;
}


//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)bindingAssociations
{
  return _keyAssociations;
}


//--------------------------------------------------------------------
//	sleep

-(void)sleep 
{
  //Does Nothing
}

//--------------------------------------------------------------------
-(void)sleepInContext:(GSWContext*)aContext
{
  //OK
  GSWComponentDefinition* aComponentDefinition=nil;
  NS_DURING
    {      
      aComponentDefinition=[self _componentDefinition];
      [aComponentDefinition sleep];
      [self sleep];
      [self _setContext:nil];
      [_subComponents makeObjectsPerformSelector:@selector(sleepInContext:)
                     withObject:aContext];
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In sleepInContext:");
      [localException raise];
    }
  NS_ENDHANDLER;
}

//--------------------------------------------------------------------
//	appendToResponse:inContext:

-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext 
{
  GSWComponent * component = nil;
  GSWElement * element    = nil;
  
  [aContext _setResponse: aResponse];
  element = [self template];
    
  if (element != nil) {
    if (([self parent] == nil) && ([aContext page] != self)) {
      component = [aContext component];
      [aContext _setCurrentComponent:self];
    }
    [element appendToResponse: aResponse 
                     inContext: aContext];
    if (component != nil)
    {
      [aContext _setCurrentComponent: component];
    }
  }
}


-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext 
{
  GSWElement* template=nil;
  GSWElement* element=nil;

  NS_DURING

  template = [self template];
  if (template != nil) {
    if ([template class] != GSWHTMLBareStringClass) {
      element=[template invokeActionForRequest:aRequest
                                inContext:aContext];
    }
  }
  NS_HANDLER
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"In %s", __PRETTY_FUNCTION__);
      [localException raise];
  NS_ENDHANDLER
  
  return element;
}


//--------------------------------------------------------------------
//	takeValuesFromRequest:inContext:

-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext 
{
  //OK
  BOOL oldValidateFlag=NO;
  GSWElement* template=nil;
  GSWDeclareDebugElementIDsCount(aContext);
  GSWDeclareDebugElementID(aContext);

  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);

  [_validationFailureMessages removeAllObjects];
  oldValidateFlag=[aContext isValidate];
  [aContext setValidate:YES];
  template=[self template];

  [template takeValuesFromRequest:aRequest
			 inContext:aContext];

  GSWStopElement(aContext);
  GSWAssertDebugElementID(aContext);

  [aContext setValidate:oldValidateFlag];

  GSWAssertIsElementID(aContext);
  GSWAssertDebugElementIDsCount(aContext);

}


//GSWeb Additions {
//--------------------------------------------------------------------
-(void)setValidationFailureMessage:(NSString*)message
                        forElement:(GSWDynamicElement*)element
{
  if (!_validationFailureMessages)
    _validationFailureMessages=[NSMutableDictionary new];
  [_validationFailureMessages setObject:message
                              forKey:[NSValue valueWithNonretainedObject:element]];
}

//--------------------------------------------------------------------
-(NSString*)validationFailureMessageForElement:(GSWDynamicElement*)element
{
  return [_validationFailureMessages objectForKey:[NSValue valueWithNonretainedObject:element]];
}

//--------------------------------------------------------------------
-(NSString*)handleValidationExceptionDefault
{
  return nil; //Raise !
}

//--------------------------------------------------------------------
-(BOOL)isValidationFailure
{
  //TODO ameliorate
  return [[self allValidationFailureMessages] count]>0;
}

//--------------------------------------------------------------------
-(NSDictionary*)validationFailureMessages
{
  return _validationFailureMessages;
}

//--------------------------------------------------------------------
-(NSArray*)allValidationFailureMessages
{
  NSMutableArray* msgs=[NSMutableArray array];
  NSEnumerator* subComponentsEnum=nil;
  GSWComponent* component=nil;

  [msgs addObjectsFromArray:[[self validationFailureMessages] allValues]];
  subComponentsEnum=[_subComponents objectEnumerator];
  while((component=[subComponentsEnum nextObject]))
    {
      [msgs addObjectsFromArray:[component allValidationFailureMessages]];
    }
  msgs=[NSArray arrayWithArray:msgs];

  return msgs;
}

// } 

//--------------------------------------------------------------------

-(void) _awakeInContext:(GSWContext*)aContext
{
  GSWComponentDefinition* componentdefinition =nil;
  
  [self _setContext:aContext];

  componentdefinition = [self _componentDefinition];
  [componentdefinition setCachingEnabled:[self isCachingEnabled]];
  [componentdefinition awake];

  if (_subComponents) {

  [_subComponents makeObjectsPerformSelector:@selector(_awakeInContext:)
                  withObject:aContext];

  }

  _session = nil;
  [self awake];
}

/*
Makes sure that the receiver is awake in aContext. 
Call this method before using a component which was cached in a variable.
*/

-(void)ensureAwakeInContext:(GSWContext*)aContext
{
  if ([self context] != aContext)  { 
    [self _awakeInContext:aContext];
  }
}

//--------------------------------------------------------------------
-(void) reset
{
  //Does Nothing
}

-(void)awake 
{
  //Does Nothing
}

-(void)awakeInContext:(GSWContext*)aContext
{
  NSLog(@"WARNING: %s is deprecated. Use _awakeInContext: instead.", __PRETTY_FUNCTION__);
  [self _awakeInContext:aContext];
}


- (id<GSWActionResults>)performParentAction:(NSString *)attribute
{
  GSWContext       *context = nil;
  GSWComponent     *component = _parent;
  id<GSWActionResults> actionresults = nil;
  
  if (!_parent) {
    return nil;
  }
  [context _setCurrentComponent:_parent];  
  [self pushValuesToParent];
  _parent = component;            // get the _parent back.

  context = [self context];  // we do NOT use the iVar to enable fancy subclass magic.
  NS_DURING
    actionresults = [_parent valueForKey: attribute];
  NS_HANDLER
    localException=[localException exceptionByAddingUserInfoFrameInfoFormat:@"In %s",
                                                                          __PRETTY_FUNCTION__];
    [localException raise];    
  NS_ENDHANDLER
  [self pullValuesFromParent];
  [context _setCurrentComponent:self];  

  return actionresults;
}

//--------------------------------------------------------------------
-(GSWComponent*)parent
{
  //OK
  return _parent;
}

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
    }
  return topParent;
}

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
    }
  return [NSArray arrayWithArray:parents];
}

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
    }
  return [NSArray arrayWithArray:parents];
}

-(GSWComponent*)pageWithName:(NSString*)aName
{
  //OK
  GSWComponent* page=nil;
  GSWContext* aContext=nil;

  aContext=[self context];
  page=[GSWApp pageWithName:aName
               inContext:aContext];

  return page;
}

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
}

//--------------------------------------------------------------------
-(BOOL)hasSession
{
  return (_session!=nil);
}

//--------------------------------------------------------------------
//	application

-(GSWApplication*)application 
{
  return [GSWApplication application];
}

//--------------------------------------------------------------------
//	context

-(GSWContext*)context 
{
  GSWContext * ctx = nil;

  if ((_context == nil) && (_session != nil)) {
    if ((ctx = [_session context])) {
      [self _awakeInContext: ctx];
      [_context _takeAwakeComponent:self];
    }
  }
  return _context;
}

//--------------------------------------------------------------------
//NDFN
-(NSArray*)languages
{
  NSArray* languages=nil;
  languages=[[self context] languages];

  return languages;
}

//--------------------------------------------------------------------
//Called when an Enterprise Object or formatter failed validation during an
//assignment. 
//The default implementation ignores the error. Subclassers can override to
// record the error and possibly return a different page for the current action.

- (void) validationFailedWithException:(NSException *)exception
                                 value:(id)value
                               keyPath:(NSString *)keyPath
{
  // FIXME: check if that code is in WO4.x
  /*
  if ([self hasSession]) {
    [[self session] validationFailedWithException:exception
                                            value:value
                                          keyPath:keyPath
                                        component:self];
  } else {
   [GSWApp validationFailedWithException:exception
                                   value:value
                                 keyPath:keyPath
                               component:self
                                 session:null];
  }
  */
}

//--------------------------------------------------------------------
-(void)_debugWithString:(NSString*)string
{
  [self notImplemented: _cmd];	//TODOFN
/* Seems there's a problem with patches... Why this code is here ?
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
         }
     }
*/
}

//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)aFormat,...
{
  [self notImplemented: _cmd];	//TODOFN
}

//--------------------------------------------------------------------
+(void)logWithFormat:(NSString*)aFormat,...
{
  va_list ap;
  va_start(ap,aFormat);
  [[GSWApplication application] logWithFormat:aFormat
                                arguments:ap];
  va_end(ap);
}


-(NSString*)_uniqueID
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
}


//--------------------------------------------------------------------
-(void)_appendPageToResponse:(GSWResponse*)response
                   inContext:(GSWContext*)aContext
{
  //OK
  GSWSession* session=nil;
  GSWRequest* request=nil;
  NSString* httpVersion=@"HTTP/1.0";
  GSWElement* pageElement=nil;
  BOOL pageChanged=NO;  

  NSAssert(aContext,@"No context");
  NS_DURING
    {    
      request=[aContext request];
      GSWContext_deleteAllElementIDComponents(aContext);

      if (request != nil) {
        httpVersion = [request httpVersion];
        [response setAcceptedEncodings:[request browserAcceptedEncodings]];
      }

      [response setHTTPVersion:httpVersion];
      [response setHeader:@"text/html"
                forKey:@"content-type"];
      [aContext _setResponse:response];

      pageElement=[aContext _pageElement];

      pageChanged=(self!=(GSWComponent*)pageElement);
      [aContext _setPageChanged:pageChanged];

      if (pageChanged)
        [aContext _setPageElement:self];

      [aContext _setCurrentComponent:self];

      [self appendToResponse:response
            inContext:aContext];

      session=[aContext _session];

      if (session) {
          [session appendCookieToResponse:response];
          [session _saveCurrentPage];
      }

      [aContext _incrementContextID];
      GSWContext_deleteAllElementIDComponents(aContext);
      [aContext _setPageChanged:YES];
    }
  NS_HANDLER
    {
    NSLog(@"localException is %@", localException);                    

      localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                               @"in GSWComponent -_generateResponseInContext:");      
      [localException raise];
    }
  NS_ENDHANDLER;
  
}

//--------------------------------------------------------------------
-(GSWResponse*)_generateResponseInContext:(GSWContext*)aContext
{
  GSWResponse* response=nil;

  NSAssert(aContext,@"No context");
  
  response=[GSWApp createResponseInContext:aContext];
  
  [self _appendPageToResponse:response
                    inContext:aContext];
        
  return response;
}

//--------------------------------------------------------------------

// actually this is wrong. it should call the validateValue:forKey: of the default implementation
// as such it should call the validateXXX stuff like EOs do. dave@turbocat.de

-(NSException*)validateValue:(id*)valuePtr
                      forKey:(NSString*)key
{
  NSException* exception=nil;
/*
  // Should all default implementation (i.e. the one which call validateXX:
  exception=[super validateValue:valuePtr
                   forKey:key];
*/
  return exception;
}

/**
 * This method is called to validate and potentially coerce
 * VALUE for the receivers key path.  This method also assigns
 * the value if it is different from the current value.
 * This method will raise an EOValidationException
 * if validateValue:forKeyPath:error: returns an error.
 * This method returns new value.
 **/
- (id)validateTakeValue:(id)value forKeyPath:(NSString *)path
{
  NSError   * outError = nil;
  BOOL        ok       = NO;
  NSRange     dotRange;
  NSString  * errorStr = @"unknown reason";
  NSString  * validatePath = path;
  
  if (!path) {
    errorStr = @"keyPath must not be nil";
  } else {
    
    id targetObject = self;
    
    dotRange = [path rangeOfString:@"."
                           options:NSBackwardsSearch];
    
    if (dotRange.location != NSNotFound) {
      NSString * newPath = [path substringToIndex:dotRange.location];
      
      targetObject = [self valueForKeyPath:newPath];
      
      if (!targetObject) {
        // If there is no object to set a value, we cannot do any validation.
        // There is nothing to set on a non-existing object, so just go.
        return nil;
      }
      
      // 1 is the length of the "."
      validatePath = [path substringFromIndex: dotRange.location+1];
    } 
    
    ok = [targetObject validateValue:&value 
                          forKeyPath:validatePath 
                               error:&outError];
  }
  
  if (ok) { // value is ok
    [self setValue:value
        forKeyPath:path];
    
    return value;
  } else {
    NSException  * exception=nil;
    NSDictionary * uInfo;
    
    uInfo = [NSDictionary dictionaryWithObjectsAndKeys:
             (value ? value : (id)@"nil"), @"EOValidatedObjectUserInfoKey",
             path, @"EOValidatedPropertyUserInfoKey",
             nil];
    
    if ((outError) && ([outError userInfo])) {
      errorStr = [[outError userInfo] valueForKey:NSLocalizedDescriptionKey];
    }
    
    exception=[NSException exceptionWithName:@"EOValidationException"
                                      reason:errorStr
                                    userInfo:uInfo];
    
    if (exception) {
      [exception raise];
    }
    
  }
  
  return value;
}

//--------------------------------------------------------------------
//	stringForKey:inTableNamed:withDefaultValue:

-(NSString*)stringForKey:(NSString*)key
            inTableNamed:(NSString*)tableName
        withDefaultValue:(NSString*)defaultValue
{
  //OK
  NSString* string=nil;

  string=[GSWApp stringForKey:key
                 inTableNamed:tableName
                 withDefaultValue:defaultValue
                 inFramework:[self frameworkName]
                 languages:[self languages]];
  return string;
}

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aName
{
  //OK
  NSDictionary* stringsTable=nil;

  stringsTable=[GSWApp stringsTableNamed:aName
                       inFramework:[self frameworkName]
                       languages:[self languages]];
  return stringsTable;
}

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aName
{
  //OK
  NSArray* stringsTableArray=nil;

  stringsTableArray=[GSWApp stringsTableArrayNamed:aName
                            inFramework:[self frameworkName]
                            languages:[self languages]];

  return stringsTableArray;
}


//--------------------------------------------------------------------
//	urlForResourceNamed:ofType:

-(NSString*)urlForResourceNamed:(NSString*)aName
                         ofType:(NSString*)type
{
  //TODO
  NSString* url=nil;
  NSString* name;
  
  if ((type != nil)) {
    name = [NSString stringWithFormat:@"%@.%@",aName,type];
  } else {
    name = aName;
  }
  
  url=[GSWApp urlForResourceNamed:name
                      inFramework:[self frameworkName]
                        languages:[self languages]
                          request:nil];//TODO
  
  return url;
}

//--------------------------------------------------------------------
-(NSString*)_urlForResourceNamed:(NSString*)aName
                          ofType:(NSString*)type
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
}

//--------------------------------------------------------------------
//	pathForResourceNamed:ofType:
// Normally: local search. Here we do a resourceManager serahc.
-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)type
{
  NSString* path=nil;

  path=[GSWApp pathForResourceNamed:aName
				ofType:type
               inFramework:[self frameworkName]
               languages:[self languages]];

  return path;
}

//--------------------------------------------------------------------
//NDFN
-(NSString*)pathForComponentResourceNamed:(NSString*)aName
                                   ofType:(NSString*)type_ 
{
  NSString* path=nil;
  NSArray* languages=nil;
  GSWComponentDefinition* aComponentDefinition=nil;

  languages=[self languages];
  aComponentDefinition=[self _componentDefinition];
  if (aComponentDefinition)
    path=[aComponentDefinition pathForResourceNamed:aName
                               ofType:type_
                               languages:languages];
  return path;
}

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
}

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aName
                      inFramework:(NSString*)aFrameworkName
{
  return [GSWApp stringsTableNamed:aName
                 inFramework:aFrameworkName
                 languages:[self languages]];
}

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aName
                      inFramework:(NSString*)aFrameworkName
{
  return [GSWApp stringsTableArrayNamed:aName
                 inFramework:aFrameworkName
                 languages:[self languages]];
}

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlForResourceNamed:(NSString*)aName
                         ofType:(NSString*)extension
                    inFramework:(NSString*)aFrameworkName;
{
  
  NSString * name;
  
  if ((extension != nil)) {
    name = [NSString stringWithFormat:@"%@.%@",aName,extension];
  } else {
    name = aName;
  }
  
  return [GSWApp urlForResourceNamed:name
                         inFramework:aFrameworkName
                           languages:[self languages]
                             request:nil];//TODO
}

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
}


//--------------------------------------------------------------------
//	templateWithHTMLString:declarationString:languages

//--------------------------------------------------------------------
+(GSWElement*)templateWithHTMLString:(NSString*)htmlString
                   declarationString:(NSString*)pageDefString
                           languages:(NSArray*)languages
{
  GSWElement* rootElement=nil;

  rootElement=[GSWTemplateParser templateWithHTMLString:htmlString
                                 declarationString:pageDefString
                                 languages:languages];
  return rootElement;
}

//--------------------------------------------------------------------
//	templateWithHTMLString:declarationString:
//old
+(GSWElement*)templateWithHTMLString:(NSString*)htmlString
                   declarationString:(NSString*)pageDefString
{
  return [self templateWithHTMLString:htmlString
               declarationString:pageDefString
               languages:nil];
}



//--------------------------------------------------------------------
-(GSWResponse*)generateResponse
{
  return [self _generateResponseInContext: [self context]];
}


//--------------------------------------------------------------------
//	descriptionForResponse:inContext:

-(NSString*)descriptionForResponse:(GSWResponse*)aResponse
                         inContext:(GSWContext*)aContext 
{
  return _name;
}

+(void)_registerObserver:(id)observer
{
  [self notImplemented: _cmd];	//TODOFN
}

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
            }
        }
    }
}

- (id)unarchiver: (WOKeyValueUnarchiver*)archiver objectForReference: (id)keyPath
{  
  if ([keyPath isKindOfClass:[NSString class]])
  {
    return [self valueForKeyPath:keyPath];
  }
  return nil;
}

@end

