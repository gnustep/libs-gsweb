/** GSWComponent.m - <title>GSWeb: Class GSWComponent</title>
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

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
	  NSMutableDictionary* _threadDictionary=GSCurrentThreadDictionary();
	  GSWContext* _context=[_threadDictionary objectForKey:GSWThreadKey_Context];
	  GSWComponentDefinition* _componentDefinition=[_threadDictionary objectForKey:GSWThreadKey_ComponentDefinition];
	  NSAssert(_context,@"No Context in GSWComponent Init");
	  NSAssert(_componentDefinition,@"No ComponentDefinition in GSWComponent Init");
	  ASSIGN(componentDefinition,_componentDefinition);
	  name=[[NSString stringWithCString:object_get_class_name(self)]retain];
	  NSDebugMLLog(@"gswcomponents",@"name=%@",name);
	  isCachingEnabled=YES;
	  [self _setContext:_context];
	  NSDebugMLLog(@"gswcomponents",@"context=%@",context);
	  templateName=[[self _templateNameFromClass:[self class]] retain];
	  NSDebugMLLog(@"gswcomponents",@"templateName=%@",templateName);
	  [self setCachingEnabled:[GSWApp isCachingEnabled]];
	  [componentDefinition _finishInitializingComponent:self];
	  isSynchronized=[self synchronizesVariablesWithBindings];
	  NSDebugMLLog(@"gswcomponents",@"isSynchronized=%s",(isSynchronized ? "YES" : "NO"));
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
  DESTROY(name);
  GSWLogC("Dealloc GSWComponent: subComponents");
  DESTROY(subComponents);
  GSWLogC("Dealloc GSWComponent: templateName");
  DESTROY(templateName);
  GSWLogC("Dealloc GSWComponent: template");
  DESTROY(template);
  GSWLogC("Dealloc GSWComponent: componentDefinition");
  DESTROY(componentDefinition);
  parent=nil;
  GSWLogC("Dealloc GSWComponent: associationsKeys");
  DESTROY(associationsKeys);
  GSWLogC("Dealloc GSWComponent: associations");
  DESTROY(associations);
  GSWLogC("Dealloc GSWComponent: childTemplate");
  DESTROY(childTemplate);
  GSWLogC("Dealloc GSWComponent: userDictionary");
  DESTROY(userDictionary);
  GSWLogC("Dealloc GSWComponent: userAssociations");
  DESTROY(userAssociations);
  GSWLogC("Dealloc GSWComponent: defaultAssociations");
  DESTROY(defaultAssociations);
  GSWLogC("Dealloc GSWComponent: validationFailureMessages");
  DESTROY(validationFailureMessages);
  GSWLogC("Dealloc GSWComponent: context (set to nil)");
  context=nil;
  GSWLogC("Dealloc GSWComponent: session (set to nil)");
  session=nil;
  GSWLogC("Dealloc GSWComponent Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWComponent");
}

//--------------------------------------------------------------------
-(id)copyWithZone: (NSZone*)zone
{
  GSWComponent* clone = [[isa allocWithZone: zone] init];
  ASSIGNCOPY(clone->name,name);
  ASSIGNCOPY(clone->subComponents,subComponents);
  ASSIGNCOPY(clone->templateName,templateName);
  ASSIGN(clone->template,template);
  ASSIGN(clone->componentDefinition,componentDefinition);
  ASSIGN(clone->parent,parent);
  ASSIGNCOPY(clone->associationsKeys,associationsKeys);
  ASSIGNCOPY(clone->associations,associations);
  ASSIGNCOPY(clone->childTemplate,childTemplate);
  ASSIGNCOPY(clone->context,context);
  ASSIGNCOPY(clone->session,session);
  clone->isPage=isPage;
  clone->isCachingEnabled=isCachingEnabled;
  clone->isSynchronized=isSynchronized;
  return clone;
};

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder_
{
  //TODOV
  [super encodeWithCoder:coder_];
  [coder_ encodeObject:name];
  [coder_ encodeObject:subComponents];
  [coder_ encodeObject:templateName];
  [coder_ encodeObject:template];
  [coder_ encodeObject:componentDefinition];
  [coder_ encodeObject:parent];
  [coder_ encodeObject:associationsKeys];
  [coder_ encodeObject:associations];
  [coder_ encodeObject:childTemplate];
  [coder_ encodeObject:context];
  [coder_ encodeObject:session];
  [coder_ encodeValueOfObjCType:@encode(BOOL)
		  at:&isPage];
  [coder_ encodeValueOfObjCType:@encode(BOOL)
		  at:&isCachingEnabled];
  [coder_ encodeValueOfObjCType:@encode(BOOL)
		  at:&isSynchronized];
}

//--------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*)coder_
{
  //TODOV
  if ((self = [super initWithCoder:coder_]))
	{
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&name];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&subComponents];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&templateName];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&template];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&componentDefinition];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&parent];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&associationsKeys];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&associations];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&childTemplate];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&context];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&session];
	  [coder_ decodeValueOfObjCType:@encode(BOOL)
			at:&isPage];
	  [coder_ decodeValueOfObjCType:@encode(BOOL)
			  at:&isCachingEnabled];
	  [coder_ decodeValueOfObjCType:@encode(BOOL)
			  at:&isSynchronized];
	};
  return self;
}

//--------------------------------------------------------------------
//	frameworkName

-(NSString*)frameworkName 
{
  //OK
  NSString* _frameworkName=nil;
  GSWComponentDefinition* _componentDefinition=nil;
  LOGObjectFnStart();
  _componentDefinition=[self _componentDefinition];
  _frameworkName=[_componentDefinition frameworkName];
  NSDebugMLLog(@"gswcomponents",@"_frameworkName=%@",_frameworkName);
  LOGObjectFnStop();
  return _frameworkName;
};

//--------------------------------------------------------------------
//	logWithFormat:

-(void)logWithFormat:(NSString*)format_,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	logWithFormat:arguments:

-(void)logWithFormat:(NSString*)format_
		   arguments:(va_list)arguments_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//	name

-(NSString*)name 
{
  return name;
};

//--------------------------------------------------------------------
//	path

-(NSString*)path 
{
  //TODOV
  NSBundle* bundle=[NSBundle mainBundle];
  return [bundle pathForResource:name
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
-(NSString*)_templateNameFromClass:(Class)_class
{
  //OK
  NSString* _templateName=nil;
  LOGObjectFnStart();
  _templateName=[NSString stringWithCString:[_class name]];
  LOGObjectFnStop();
  return _templateName;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  //TODO
  NSString* _dscr=nil;
  GSWLogAssertGood(self);
  NSDebugMLLog(@"gswcomponents",@"GSWComponent description self=%p",self);
  _dscr=[NSString stringWithFormat:@"<%s %p>",
				  object_get_class_name(self),
				  (void*)self];
  return _dscr;
};

// GSWeb Additions {
-(NSDictionary*)userDictionary
{
  return userDictionary;
};

-(void)setUserDictionary:(NSDictionary*)userDictionary_
{
  ASSIGN(userDictionary,userDictionary_);
  NSDebugMLLog(@"gswcomponents",@"userDictionary:%@",userDictionary);
};

-(NSDictionary*)userAssociations
{
  return userAssociations;
};

-(void)setUserAssociations:(NSDictionary*)userAssociations_
{
  ASSIGN(userAssociations,userAssociations_);
  NSDebugMLLog(@"gswcomponents",@"userAssociations:%@",userAssociations);
};

-(NSDictionary*)defaultAssociations
{
  return defaultAssociations;
};

-(void)setDefaultAssociations:(NSDictionary*)defaultAssociations_
{
  ASSIGN(defaultAssociations,defaultAssociations_);
  NSDebugMLLog(@"gswcomponents",@"defaultAssociations:%@",defaultAssociations);
};
// }

@end

//====================================================================
@implementation GSWComponent (GSWCachingPolicy)

//--------------------------------------------------------------------
//setCachingEnabled:

-(void)setCachingEnabled:(BOOL)caching_
{
  //OK
  isCachingEnabled=caching_;
};

//--------------------------------------------------------------------
//isCachingEnabled

-(BOOL)isCachingEnabled 
{
  //OK
  return isCachingEnabled;
};

@end

//====================================================================
@implementation GSWComponent (GSWComponentA)

//--------------------------------------------------------------------
-(void)setParent:(GSWComponent*)_parent
associationsKeys:(NSArray*)_associationsKeys
	associations:(NSArray*)_associations
		template:(GSWElement*)_template
{
  //OK
  LOGObjectFnStart();
  parent=_parent;
  NSDebugMLLog(@"gswcomponents",@"name=%@ parent=%p (%@)",
               [self definitionName],
               (void*)parent,[parent class]);
  NSDebugMLLog(@"gswcomponents",@"associations=%@",associations);
  ASSIGN(associations,_associations);
  ASSIGN(associationsKeys,_associationsKeys);
  NSDebugMLLog(@"gswcomponents",@"associationsKeys=%@",associationsKeys);
  ASSIGN(childTemplate,_template);
  NSDebugMLLog(@"gswcomponents",@"template=%@",childTemplate);
  [self validateAPIAssociations];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)synchronizeComponentToParent
{
  //OK
  LOGObjectFnStart();
  NSDebugMLog(@"Name=%@ - isSynchronized=%s",
              [self definitionName],(isSynchronized ? "YES" : "NO"));
  if (isSynchronized)
	{
	  int i=0;
	  id _key=nil;
	  GSWAssociation* _assoc=nil;
	  id _value=nil;
	  id _logValue=[self valueForBinding:@"GSWDebug"];
	  BOOL _log=boolValueWithDefaultFor(_logValue,NO);
	  NSDebugMLog(@"defName=%@ - Synchro SubComponent->Component",               
                      [self definitionName]);
	  for(i=0;i<[associationsKeys count];i++)
		{
		  _key=[associationsKeys objectAtIndex:i];
		  _assoc=[associations objectAtIndex:i];
		  NSDebugMLLog(@"gswcomponents",@"_key=%@ _assoc=%@",_key,_assoc);
		  if ([_assoc isValueSettable]
			  && ![_assoc isKindOfClass:[GSWBindingNameAssociation class]]) //TODOV
			{
			  //MGNEW _value=[self getIVarNamed:_key];
                          _value=[self valueForKey:_key];//MGNEW 
			  NSDebugMLLog(@"gswcomponents",@"_value=%@",_value);
			  if (_log)
				[_assoc logSynchronizeComponentToParentForValue:_value
						inComponent:parent];
			  [_assoc setValue:_value
					  inComponent:parent];
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
  NSDebugMLog(@"Name=%@ - isSynchronized=%s",
              [self definitionName],(isSynchronized ? "YES" : "NO"));
  if (isSynchronized)
	{
	  //Synchro Component->SubComponent
	  int i=0;
	  id _key=nil;
	  GSWAssociation* _assoc=nil;
	  id _value=nil;
	  id _logValue=[self valueForBinding:@"GSWDebug"];
	  BOOL _log=boolValueWithDefaultFor(_logValue,NO);
	  NSDebugMLog(@"Name=%@ - Synchro Component->SubComponent",
                      [self definitionName]);
	  for(i=0;i<[associationsKeys count];i++)
		{
		  _key=[associationsKeys  objectAtIndex:i];
		  _assoc=[associations objectAtIndex:i];
		  NSDebugMLLog(@"gswcomponents",@"_key=%@ _assoc=%@",_key,_assoc);
		  if (![_assoc isKindOfClass:[GSWBindingNameAssociation class]]) //TODOV
			{
			  _value=[_assoc valueInComponent:parent];
			  NSDebugMLLog(@"gswcomponents",@"_value=%@",_value);
			  if (_log)
				[_assoc logSynchronizeParentToComponentForValue:_value
						inComponent:self];
			  /*//MGNEW [self setIVarNamed:_key
					withValue:_value];*/
                  [self takeValue:_value
                        forKey:_key];
			};
		};
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)_childTemplate
{
  //OK
  return childTemplate;
};

//--------------------------------------------------------------------
-(GSWElement*)_template
{
  //OK
  GSWElement* _template=template;
  LOGObjectFnStart();
  if (!_template)
	{
	  _template=[self templateWithName:[self _templateName]];
	  if ([self isCachingEnabled])
		{
		  ASSIGN(template,_template);
		};
	};
  LOGObjectFnStop();
  return _template;
};

//--------------------------------------------------------------------
-(GSWComponentDefinition*)_componentDefinition
{
  //OK
  GSWComponentDefinition* _componentDefinition=nil;
  LOGObjectFnStart();
  if (componentDefinition)
	_componentDefinition=componentDefinition;
  else
	{
	  NSArray* _languages=[self languages];
	  _componentDefinition=[GSWApp componentDefinitionWithName:name
								   languages:_languages];
	  if ([self isCachingEnabled])
		{
		  ASSIGN(componentDefinition,_componentDefinition);
		};
	};
  LOGObjectFnStop();
  return _componentDefinition;
};

//--------------------------------------------------------------------
-(NSString*)_templateName
{
  return templateName;
};

//--------------------------------------------------------------------
-(BOOL)_isPage
{
  //OK
  return isPage;
};

//--------------------------------------------------------------------
-(void)_setIsPage:(BOOL)_isPage
{
  //OK
  isPage=_isPage;
};

//--------------------------------------------------------------------
-(void)_setContext:(GSWContext*)_context
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"_context=%p",(void*)_context);
  context=_context;//NO retain !
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWComponent (GSWResourceManagement)

//--------------------------------------------------------------------
//	templateWithName:

-(GSWElement*)templateWithName:(NSString*)name_ 
{
  //OK
  GSWElement* _template=nil;
  NSArray* _languages=nil;
  GSWComponentDefinition* _componentDefinition=nil;
  LOGObjectFnStart();
  _languages=[self languages];
  _componentDefinition=[self _componentDefinition];
  _template=[_componentDefinition templateWithName:name_
								  languages:_languages];
  NSDebugMLLog(@"gswcomponents",@"_template=%@",_template);
  LOGObjectFnStop();
  return _template;
};

@end

//====================================================================
@implementation GSWComponent (GSWComponentC)

-(GSWComponent*)subComponentForElementID:(NSString*)_elementId
{
  //OK
  GSWComponent* _subc=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"_elementId=%@",_elementId);
  NSDebugMLLog(@"gswcomponents",@"subComponents=%@",subComponents);
  _subc=[subComponents objectForKey:_elementId];
  NSDebugMLLog(@"gswcomponents",@"_subc=%@",_subc);
  LOGObjectFnStop();
  return _subc;
};

//--------------------------------------------------------------------
-(void)setSubComponent:(GSWComponent*)_component
		  forElementID:(NSString*)_elementId
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"_elementId=%@",_elementId);
  NSDebugMLLog(@"gswcomponents",@"_component=%@",_component);
  NSDebugMLLog(@"gswcomponents",@"subComponents=%@",subComponents);
  if (!subComponents)
	subComponents=[NSMutableDictionary new];
  [subComponents setObject:_component
				 forKey:_elementId];
  NSDebugMLLog(@"gswcomponents",@"subComponents=%@",subComponents);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector
{
  NSArray* _parents=nil;
  LOGObjectFnStart();
  _parents=[self parents];
  NSDebugMLLog(@"gswcomponents",@"parents=%@",_parents);
  [_parents makeObjectsPerformSelectorIfPossible:aSelector];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector
							 withObject:(id)object_
{
  NSArray* _parents=nil;
  LOGObjectFnStart();
  _parents=[self parents];
  NSDebugMLLog(@"gswcomponents",@"parents=%@",_parents);
  [_parents makeObjectsPerformSelectorIfPossible:aSelector
			withObject:object_];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector
								 withObject:(id)object1_
								 withObject:(id)object2_
{
  NSArray* _parents=nil;
  LOGObjectFnStart();
  _parents=[self parents];
  NSDebugMLLog(@"gswcomponents",@"parents=%@",_parents);
  [_parents makeObjectsPerformSelectorIfPossible:aSelector
			withObject:object1_
			withObject:object2_];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector
{
  id _retValue=nil;
  id obj=[self parent];
  LOGObjectFnStart();
  while(obj)
    {
      if ([obj respondsToSelector:aSelector])
	{
	  _retValue=[obj performSelector:aSelector];
	  obj=nil;
	}
      else
	obj=[obj parent];
    };
  LOGObjectFnStop();
  return _retValue;
};

//--------------------------------------------------------------------
//NDFN
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector
							 withObject:(id)object_
{
  id _retValue=nil;
  id obj=[self parent];
  LOGObjectFnStart();
  while(obj)
    {
      if ([obj respondsToSelector:aSelector])
	{
	  _retValue=[obj performSelector:aSelector
			 withObject:object_];
	  obj=nil;
	}
      else
	obj=[obj parent];
    };
  LOGObjectFnStop();
  return _retValue;
};

//--------------------------------------------------------------------
//NDFN
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector
								 withObject:(id)object1_
								 withObject:(id)object2_
{
  id _retValue=nil;
  id obj=[self parent];
  LOGObjectFnStart();
  while(obj)
    {
      if ([obj respondsToSelector:aSelector])
	{
	  _retValue=[obj performSelector:aSelector
			 withObject:object1_
			 withObject:object2_];
	  obj=nil;
	}
      else
	obj=[obj parent];
    };
  LOGObjectFnStop();
  return _retValue;
};

//--------------------------------------------------------------------
//NDFN
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector
{
  NSEnumerator* _enum=nil;
  id _component=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"subComponents=%@",subComponents);
  _enum= [subComponents objectEnumerator];    
  while ((_component=[_enum nextObject]))
	{
	  [_component performSelectorIfPossible:aSelector];
	  [_component makeSubComponentsPerformSelectorIfPossible:aSelector];
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector
									   withObject:(id)object_
{
  NSEnumerator* _enum=nil;
  id _component=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"subComponents=%@",subComponents);
  _enum= [subComponents objectEnumerator];    
  while ((_component=[_enum nextObject]))
	{
	  [_component performSelectorIfPossible:aSelector
				  withObject:object_];
	  [_component makeSubComponentsPerformSelectorIfPossible:aSelector
				  withObject:object_];
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector
									   withObject:(id)object1_
									   withObject:(id)object2_
{
  NSEnumerator* _enum=nil;
  id _component=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"subComponents=%@",subComponents);
  _enum= [subComponents objectEnumerator];    
  while ((_component=[_enum nextObject]))
	{
	  [_component performSelectorIfPossible:aSelector
				  withObject:object1_
				  withObject:object2_];
	  [_component makeSubComponentsPerformSelectorIfPossible:aSelector
				  withObject:object1_
				  withObject:object2_];
	};
  LOGObjectFnStop();
};

@end

//====================================================================
@implementation GSWComponent (GSWComponentD)

-(GSWAssociation*)_associationWithName:(NSString*)_name
{
  //OK
  GSWAssociation* _assoc=nil;
  unsigned int _index=NSNotFound;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"associationsKeys=%@",associationsKeys);
  //NSDebugMLLog(@"gswcomponents",@"associations=%@",[associations description]);
  if (associationsKeys)
	{
	  _index=[associationsKeys indexOfObject:_name];
	  NSDebugMLLog(@"gswcomponents",@"_index=%u",_index);
	  if (_index!=NSNotFound)
		_assoc=[associations objectAtIndex:_index];
	};
  if (!WOStrictFlag && _index==NSNotFound)
	{	  
	  _assoc=[defaultAssociations objectForKey:_name];
	};
  NSDebugMLLog(@"gswcomponents",@"_assoc=%@",_assoc);
  LOGObjectFnStop();
  return _assoc;
};

@end

//====================================================================
@implementation GSWComponent (GSWSynchronizing)

//--------------------------------------------------------------------
-(BOOL)hasBinding:(NSString*)parentBindingName_
{
  //OK
  BOOL _hasBinding=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"defName=%@ - parentBindingName_=%@",
               [self definitionName],
               parentBindingName_);
  if (associationsKeys)
	{
	  int _index=[associationsKeys indexOfObject:parentBindingName_];
	  NSDebugMLLog(@"gswcomponents",@"_index=%u",_index);
	  _hasBinding=(_index!=NSNotFound);
	};
  NSDebugMLLog(@"gswcomponents",@"defName=%@ - hasBinding=%s",
               [self definitionName],
               (_hasBinding ? "YES" : "NO"));
  if (!WOStrictFlag && !_hasBinding)
	{	  
	  _hasBinding=([defaultAssociations objectForKey:parentBindingName_]!=nil);
	};
  LOGObjectFnStop();
  return _hasBinding;
};

//--------------------------------------------------------------------
-(void)setValue:(id)value_
	 forBinding:(NSString*)parentBindingName_
{
  //OK
  GSWAssociation* _assoc=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"defName=%@ - parentBindingName_=%@",
               [self definitionName],
               parentBindingName_);
  NSDebugMLLog(@"gswcomponents",@"value_=%@",value_);
  NSDebugMLLog(@"gswcomponents",@"parent=%p",(void*)parent);
  if (parent)
	{
	  _assoc=[self _associationWithName:parentBindingName_];
	  NSDebugMLLog(@"gswcomponents",@"_assoc=%@",_assoc);
	  if(_assoc)
	    [_assoc setValue:value_
		    inComponent:parent];
/* // Why doing this ? Be carefull: it may make a loop !
#if GDL2
	  else
	    {
	      NS_DURING
              {
		[self takeValue:value_ 
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
-(id)valueForBinding:(NSString*)parentBindingName_
{
  //OK
  id _value=nil;
  GSWAssociation* _assoc=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"defName=%@",
               [self definitionName]);
  NSDebugMLLog(@"gswcomponents",@"parentBindingName_=%@",
               parentBindingName_);
  NSDebugMLLog(@"gswcomponents",@"parent=%p of class %@",(void*)parent,[parent class]);
  if (parent)
	{
	  _assoc=[self _associationWithName:parentBindingName_];
	  NSDebugMLLog(@"gswcomponents",@"_assoc=%@",_assoc);
	  if(_assoc)
	    _value=[_assoc valueInComponent:parent];
/* // Why doing this ? Be carefull: it may make a loop !
#if GDL2
	  else
	    {
	      NS_DURING
                {
                  _value = [self valueForKey:parentBindingName_];
                }
	      NS_HANDLER
                {
                  //TODO
                }
	      NS_ENDHANDLER;
	    }
#endif
*/
	  NSDebugMLLog(@"gswcomponents",@"_value=%@",_value);
	};
  LOGObjectFnStop();
  return _value; 
};

//--------------------------------------------------------------------
-(BOOL)synchronizesVariablesWithBindings
{
  //OK
  NSDictionary* _userDictionary=nil;
  id _synchronizesVariablesWithBindingsValue=nil;
  BOOL _synchronizesVariablesWithBindings=YES;
  LOGObjectFnStart();
  _userDictionary=[self userDictionary];
  _synchronizesVariablesWithBindingsValue=[_userDictionary objectForKey:@"synchronizesVariablesWithBindings"];
  NSDebugMLLog(@"gswcomponents",@"defName=%@ - userDictionary _synchronizesVariablesWithBindingsValue=%@",
               [self definitionName],
               _synchronizesVariablesWithBindingsValue);
  //NDFN
  if (_synchronizesVariablesWithBindingsValue)
	{
	  _synchronizesVariablesWithBindings=[_synchronizesVariablesWithBindingsValue boolValue];
          NSDebugMLLog(@"gswcomponents",@"userDictionary _synchronizesVariablesWithBindings=%s",
                       (_synchronizesVariablesWithBindings ? "YES" : "NO"));
	};
  LOGObjectFnStop();
  return _synchronizesVariablesWithBindings ;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)bindingAssociations
{
  return [NSDictionary dictionaryWithObjects:associations
					   forKeys:associationsKeys];
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
-(void)sleepInContext:(GSWContext*)context_
{
  //OK
  GSWComponentDefinition* _componentDefinition=nil;
  LOGObjectFnStart();
  _componentDefinition=[self _componentDefinition];
  [_componentDefinition sleep];
  [self sleep];
  [self _setContext:nil];
  NSDebugMLLog(@"gswcomponents",@"defName=%@ - subComponents=%@",
               [self definitionName],
               subComponents);
  [subComponents makeObjectsPerformSelector:@selector(sleepInContext:)
				 withObject:context_];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendToResponse:inContext:

-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_ 
{
  //OK
  GSWElement* _template=nil;
  GSWRequest* _request=nil;
  BOOL _isFromClientComponent=NO;
  GSWComponent* _component=nil;
#ifndef NDEBUG
  GSWElementIDString* debugElementID=[context_ elementID];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"ET=%@ id=%@",[self class],[context_ elementID]);
  NSDebugMLLog(@"gswcomponents",@"defName=%@",[self definitionName]);
  GSWSaveAppendToResponseElementID(context_);//Debug Only

  _template=[self _template];
  if(GSDebugSet(@"gswcomponents") == YES)
    [response_ appendContentString:[NSString stringWithFormat:@"\n<!-- Start %@ -->\n",[self _templateName]]];//TODO enlever

  _request=[context_ request];
  _isFromClientComponent=[_request isFromClientComponent];
  _component=[context_ component];
  [context_ appendZeroElementIDComponent];
  [_template appendToResponse:response_
			 inContext:context_];
  [context_ deleteLastElementIDComponent];

  NSDebugMLLog(@"gswcomponents",@"ET=%@ id=%@",[self class],[context_ elementID]);
  NSDebugMLLog(@"gswcomponents",@"defName=%@",[self definitionName]);
#ifndef NDEBUG
  if (![debugElementID isEqualToString:[context_ elementID]])
	{
	  NSDebugMLLog(@"gswcomponents",@"class=%@ debugElementID=%@ [context_ elementID]=%@",[self class],debugElementID,[context_ elementID]);
	  
	};
#endif
  if(GSDebugSet(@"gswcomponents") == YES)
    [response_ appendContentString:[NSString stringWithFormat:@"\n<!-- Stop %@ -->\n",[self _templateName]]];//TODO enlever

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	invokeActionForRequest:inContext:

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_ 
{
  //OK
  GSWElement* element=nil;
  GSWElement* _template=nil;
#ifndef NDEBUG
  GSWElementIDString* debugElementID=[context_ elementID];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"ET=%@ id=%@",[self class],[context_ elementID]);
  NSDebugMLLog(@"gswcomponents",@"defName=%@",[self definitionName]);
  NS_DURING
	{
	  GSWAssertCorrectElementID(context_);// Debug Only
	  _template=[self _template];
	  [context_ appendZeroElementIDComponent];
	  element=[[self _template] invokeActionForRequest:request_
								inContext:context_];
	  [context_ deleteLastElementIDComponent];
	}
  NS_HANDLER
	{
	  LOGException0(@"exception in GSWComponent invokeActionForRequest:inContext");
	  LOGException(@"exception=%@",localException);
	  localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
															  @"In GSWComponent invokeActionForRequest:inContext");
	  LOGException(@"exception=%@",localException);
	  [localException raise];
	}
  NS_ENDHANDLER;
  NSDebugMLLog(@"gswcomponents",@"ET=%@ id=%@",[self class],[context_ elementID]);
  NSDebugMLLog(@"gswcomponents",@"defName=%@",[self definitionName]);
#ifndef NDEBUG
  if (![debugElementID isEqualToString:[context_ elementID]])
	{
	  NSDebugMLLog(@"gswcomponents",@"class=%@ debugElementID=%@ [context_ elementID]=%@",[self class],debugElementID,[context_ elementID]);
	  
	};
#endif
//  if (![context_ _wasActionInvoked] && [[[context_ elementID] parentElementIDString] compare:[context_ senderID]]==NSOrderedDescending)
  if (![context_ _wasActionInvoked] && [[[context_ elementID] parentElementIDString] isSearchOverForSenderID:[context_ senderID]])
	{
	  LOGError(@"Action not invoked at the end of %@ (id=%@) senderId=%@",
			   [self class],
			   [context_ elementID],
			   [context_ senderID]);
	};
  LOGObjectFnStop();
  return element;
};

//--------------------------------------------------------------------
//	takeValuesFromRequest:inContext:

-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_ 
{
  //OK
  BOOL _oldValidateFlag=NO;
  GSWElement* _template=nil;
#ifndef NDEBUG
  GSWElementIDString* debugElementID=[context_ elementID];
#endif
  LOGObjectFnStart();
  GSWAssertCorrectElementID(context_);// Debug Only

  [validationFailureMessages removeAllObjects];
  _oldValidateFlag=[context_ isValidate];
  [context_ setValidate:YES];
  NSDebugMLLog(@"gswcomponents",@"ET=%@ id=%@",[self class],[context_ elementID]);
  NSDebugMLLog(@"gswcomponents",@"defName=%@",[self definitionName]);
  _template=[self _template];
  [context_ appendZeroElementIDComponent];
  [_template takeValuesFromRequest:request_
			 inContext:context_];
  [context_ deleteLastElementIDComponent];
  NSDebugMLLog(@"gswcomponents",@"ET=%@ id=%@",[self class],[context_ elementID]);
  NSDebugMLLog(@"gswcomponents",@"defName=%@",[self definitionName]);
#ifndef NDEBUG
  if (![debugElementID isEqualToString:[context_ elementID]])
	{
	  NSDebugMLLog(@"gswcomponents",@"class=%@ debugElementID=%@ [context_ elementID]=%@",[self class],debugElementID,[context_ elementID]);
	  
	};
#endif
  [context_ setValidate:_oldValidateFlag];
  LOGObjectFnStop();
};


//GSWeb Additions {
//--------------------------------------------------------------------
-(void)setValidationFailureMessage:(NSString*)message
						forElement:(GSWDynamicElement*)element_
{
  if (!validationFailureMessages)
	validationFailureMessages=[NSMutableDictionary new];
  [validationFailureMessages setObject:message
							 forKey:[NSValue valueWithNonretainedObject:element_]];
};

//--------------------------------------------------------------------
-(NSString*)validationFailureMessageForElement:(GSWDynamicElement*)element_
{
  return [validationFailureMessages objectForKey:[NSValue valueWithNonretainedObject:element_]];
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
  return validationFailureMessages;
};

//--------------------------------------------------------------------
-(NSArray*)allValidationFailureMessages
{
  NSMutableArray* _msgs=[NSMutableArray array];
  NSEnumerator* _subComponentsEnum=nil;
  GSWComponent* _component=nil;
  LOGObjectFnStart();
//  NSDebugMLLog(@"gswcomponents",@"validationFailureMessages=%@",validationFailureMessages);
  [_msgs addObjectsFromArray:[[self validationFailureMessages] allValues]];
//  NSDebugMLLog(@"gswcomponents",@"_msgs=%@",_msgs);
  _subComponentsEnum=[subComponents objectEnumerator];
  while((_component=[_subComponentsEnum nextObject]))
	{
//	  NSDebugMLLog(@"gswcomponents",@"_component=%@",_component);
	  [_msgs addObjectsFromArray:[_component allValidationFailureMessages]];
//	  NSDebugMLLog(@"gswcomponents",@"_msgs=%@",_msgs);
	};
  _msgs=[NSArray arrayWithArray:_msgs];
//  NSDebugMLLog(@"gswcomponents",@"_msgs=%@",_msgs);
  LOGObjectFnStop();
  return _msgs;
};

// } 

//--------------------------------------------------------------------
-(void)ensureAwakeInContext:(GSWContext*)context_
{
  //LOGObjectFnNotImplemented();	//TODOFN
  LOGObjectFnStart();
  if (![self context]) {
	NSDebugMLLog(@"gswcomponents",@"component sleeps, we awake it = %@",self);
	[self awakeInContext:context_];
  } else {
	if ([self context] != context_) { 
		NSDebugMLLog(@"gswcomponents",@"component is already awaken, but has not the current context, we awake it twice with current context = %@",self);
		[self awakeInContext:context_];
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
-(void)awakeInContext:(GSWContext*)context_
{
  //OK
  GSWComponentDefinition* _componentDefinition=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"context_=%@",context_);
  NSDebugMLLog(@"gswcomponents",@"defName=%@",[self definitionName]);
  NSAssert(context_,@"No Context");
  [self _setContext:context_];
  _componentDefinition=[self _componentDefinition];
  [_componentDefinition setCachingEnabled:[self isCachingEnabled]];
  [_componentDefinition awake];
  [subComponents makeObjectsPerformSelector:@selector(awakeInContext:)
				 withObject:context_];
  [_componentDefinition _awakeObserversForComponent:self];
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
  GSWAssociation *_assoc=nil;
  id _ret=nil;

  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents", @"name=%@ - parent=%p",
               [self definitionName],
               (void*)parent);
  if (parent)
    {
      _assoc = [self _associationWithName:attribute];
      NSDebugMLLog(@"gswcomponents", @"_assoc=%@", _assoc);

      if(_assoc && [_assoc isValueConstant] == YES)
	{
	  NSString *_value = [_assoc valueInComponent:self];

	  if(_value)
	    _ret = [parent performSelector:NSSelectorFromString(_value)];
	}
    }

  LOGObjectFnStop();

  return _ret;
};

//--------------------------------------------------------------------
-(GSWComponent*)parent
{
  //OK
  return parent;
};

//--------------------------------------------------------------------
//NDFN
-(GSWComponent*)topParent
{
  GSWComponent* _parent=[self parent];
  GSWComponent* _topParent=_parent;
  while (_parent)
	{
	  _topParent=_parent;
	  _parent=[_parent parent];
	};
  return _topParent;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)parents
{
  NSMutableArray* _parents=[NSMutableArray array];
  GSWComponent* _parent=[self parent];
  while (_parent)
	{
	  [_parents addObject:_parent];
	  _parent=[_parent parent];
	};
  return [NSArray arrayWithArray:_parents];
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)parentsClasses
{
  NSMutableArray* _parents=[NSMutableArray array];
  GSWComponent* _parent=[self parent];
  while (_parent)
	{
	  [_parents addObject:[_parent class]];
	  _parent=[_parent parent];
	};
  return [NSArray arrayWithArray:_parents];
};

@end

//====================================================================
@implementation GSWComponent (GSWConveniences)
-(GSWComponent*)pageWithName:(NSString*)_name;
{
  //OK
  GSWComponent* _page=nil;
  GSWContext* _context=nil;
  LOGObjectFnStart();
  _context=[self context];
  _page=[GSWApp pageWithName:_name
			   inContext:_context];
  LOGObjectFnStop();
  return _page;
};

//--------------------------------------------------------------------
//	session

-(GSWSession*)session 
{
  GSWSession* _session=nil;
  if (session)
	_session=session;
  else if (context)
	_session=[context session];
  return _session;
};

//--------------------------------------------------------------------
-(BOOL)hasSession
{
  return (session!=nil);
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
  return context;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)languages
{
  NSArray* _languages=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswcomponents",@"[self context]=%p",(void*)[self context]);
  NSDebugMLLog(@"gswcomponents",@"[self context]=%@",[self context]);
  _languages=[[self context] languages];
  LOGObjectFnStop();
  return _languages;
};

@end

//====================================================================
@implementation GSWComponent (GSWLogging)
//--------------------------------------------------------------------
//Called when an Enterprise Object or formatter failed validation during an
//assignment. 
//The default implementation ignores the error. Subclassers can override to
// record the error and possibly return a different page for the current action.
-(void)validationFailedWithException:(NSException*)_exception
							   value:(id)_value
							 keyPath:(id)_keyPath
{
  // Does nothing
  LOGObjectFnStart();
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_debugWithString:(NSString*)_string
{
  LOGObjectFnNotImplemented();	//TODOFN
/* Seems there's a problem with patches... Why this code is here ?
   LOGObjectFnStart();
   if (![self context])
     {
       NSDebugMLLog(@"gswcomponents",@"component sleeps, we awake it = %@",self);
       [self awakeInContext:context_];
     }
   else
     {
       if ([self context] != context_)
         { 
           NSDebugMLLog(@"gswcomponents",@"component is already awaken, but has not the current context, we awake it twice with current context = %@",self);
           [self awakeInContext:context_];
         };
     };
   LOGObjectFnStop();
*/
};

//--------------------------------------------------------------------
-(void)debugWithFormat:(NSString*)_format,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)_format,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)_format
		   arguments:(va_list)argList
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(void)logWithFormat:(NSString*)_format,...
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
-(GSWResponse*)_generateResponseInContext:(GSWContext*)_context
{
  //OK
  GSWResponse* _response=nil;
  GSWSession* _session=nil;
  GSWRequest* _request=nil;
  NSString* _httpVersion=nil;
  GSWElement* _pageElement=nil;
  BOOL _pageChanged=NO;
  LOGObjectFnStart();
  _response=[[GSWResponse new]autorelease];
  _session=[_context existingSession];
  NSDebugMLog(@"_session=%@",_session);
  if (_session)
	{
	  //TODO
	};
  [_context deleteAllElementIDComponents];
  _request=[_context request];
  _httpVersion=[_request httpVersion];
  [_response setHTTPVersion:_httpVersion];
  [_response setHeader:@"text/html"
			 forKey:@"content-type"];
  [_context _setResponse:_response];
//====>
  _pageElement=[_context _pageElement];
  _pageChanged=(self!=(GSWComponent*)_pageElement);
  [_context _setPageChanged:_pageChanged];
//====>
  if (_pageChanged)
	[_context _setPageElement:self];
  [_context _setCurrentComponent:self];
//====>

  [self appendToResponse:_response
		inContext:_context];

//----------------
//==>10
  _session=[_context session];
  NSDebugMLog(@"_session=%@",_session);
  NSDebugMLog(@"_sessionID=%@",[_session sessionID]);
  [_session appendCookieToResponse:_response];
//==>11
  [_session _saveCurrentPage];
  [_context _incrementContextID];
  [_context deleteAllElementIDComponents];
  [_context _setPageChanged:_pageChanged];
  [_context _setPageReplaced:NO];

//<==========
  LOGObjectFnStop();
  return _response;
};

//--------------------------------------------------------------------
-(id)validateValue:(id*)valuePtr_
			forKey:(id)key_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
+(id)validateValue:(id*)valuePtr_
			forKey:(id)key_
{
  LOGClassFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWComponent (GSWComponentL)

//--------------------------------------------------------------------
//	stringForKey:inTableNamed:withDefaultValue:

-(NSString*)stringForKey:(NSString*)key_
			inTableNamed:(NSString*)tableName_
		withDefaultValue:(NSString*)defaultValue_
{
  //OK
  NSString* _string=nil;
/*
  NSArray* _languages=nil;
  GSWComponentDefinition* _componentDefinition=nil;
  LOGObjectFnStart();
  _languages=[self languages];
  _componentDefinition=[self _componentDefinition];
  if (_componentDefinition)
	_string=[_componentDefinition stringForKey:key_
								  inTableNamed:tableName_
								  withDefaultValue:defaultValue_
								  languages:_languages];
  else
	_string=defaultValue_;
*/
  LOGObjectFnStart();
  _string=[GSWApp stringForKey:key_
				  inTableNamed:tableName_
				  withDefaultValue:defaultValue_
				  inFramework:[self frameworkName]
				  languages:[self languages]];
  LOGObjectFnStop();
  return _string;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)name_
{
  //OK
  NSDictionary* _stringsTable=nil;
/*  NSArray* _languages=nil;
  GSWComponentDefinition* _componentDefinition=nil;
  LOGObjectFnStart();
  _languages=[self languages];
  _componentDefinition=[self _componentDefinition];
  if (_componentDefinition)
	_stringsTable=[_componentDefinition stringsTableNamed:name_
										withLanguages:_languages];
*/
  LOGObjectFnStart();
  _stringsTable=[GSWApp stringsTableNamed:name_
                        inFramework:[self frameworkName]
                        languages:[self languages]];
  LOGObjectFnStop();
  return _stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)name_
{
  //OK
  NSArray* _stringsTableArray=nil;
/*
  NSArray* _languages=nil;
  GSWComponentDefinition* _componentDefinition=nil;
  LOGObjectFnStart();
  _languages=[self languages];
  _componentDefinition=[self _componentDefinition];
  if (_componentDefinition)
	_stringsTableArray=[_componentDefinition stringsTableArrayNamed:name_
											 withLanguages:_languages];
*/
  LOGObjectFnStart();
  _stringsTableArray=[GSWApp stringsTableArrayNamed:name_
							 inFramework:[self frameworkName]
							 languages:[self languages]];
  LOGObjectFnStop();
  return _stringsTableArray;
};


//--------------------------------------------------------------------
//	urlForResourceNamed:ofType:

-(NSString*)urlForResourceNamed:(NSString*)name_
						 ofType:(NSString*)type_ 
{
  //TODO
  NSString* _url=nil;
/*  NSArray* _languages=nil;
  GSWComponentDefinition* _componentDefinition=nil;
  LOGObjectFnStart();
  _languages=[self languages];
  _componentDefinition=[self _componentDefinition];
  if (_componentDefinition)
	_url=[_componentDefinition urlForResourceNamed:name_
							   ofType:type_
							   languages:_languages
							   request:nil];//TODO
*/
  LOGObjectFnStart();
  _url=[GSWApp urlForResourceNamed:(type_ ? [NSString stringWithFormat:@"%@.%@",name_,type_] : name_)
			   inFramework:[self frameworkName]
			   languages:[self languages]
			   request:nil];//TODO
  LOGObjectFnStop();
  return _url;
};

//--------------------------------------------------------------------
-(NSString*)_urlForResourceNamed:(NSString*)name_
						  ofType:(NSString*)type_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
//	pathForResourceNamed:ofType:
// Normally: local search. Here we do a resourceManager serahc.
-(NSString*)pathForResourceNamed:(NSString*)name_
						  ofType:(NSString*)type_ 
{
  NSString* _path=nil;
/*  NSArray* _languages=nil;
  GSWComponentDefinition* _componentDefinition=nil;
  LOGObjectFnStart();
  _languages=[self languages];
  _componentDefinition=[self _componentDefinition];
  if (_componentDefinition)
	_path=[_componentDefinition pathForResourceNamed:name_
								ofType:type_
								languages:_languages];
*/
  LOGObjectFnStart();
  _path=[GSWApp pathForResourceNamed:name_
				ofType:type_
				inFramework:[self frameworkName]
				languages:[self languages]];
  LOGObjectFnStop();
  return _path;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)pathForComponentResourceNamed:(NSString*)name_
								   ofType:(NSString*)type_ 
{
  NSString* _path=nil;
  NSArray* _languages=nil;
  GSWComponentDefinition* _componentDefinition=nil;
  LOGObjectFnStart();
  _languages=[self languages];
  _componentDefinition=[self _componentDefinition];
  if (_componentDefinition)
	_path=[_componentDefinition pathForResourceNamed:name_
								ofType:type_
								languages:_languages];
  return _path;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)stringForKey:(id)key_
			inTableNamed:(NSString*)name_
		withDefaultValue:(NSString*)defaultValue_
			 inFramework:(NSString*)frameworkName_
{
  return [GSWApp stringForKey:key_
				 inTableNamed:name_
				 withDefaultValue:defaultValue_
				 inFramework:frameworkName_
				 languages:[self languages]];
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)name_
					  inFramework:(NSString*)frameworkName_;
{
  return [GSWApp stringsTableNamed:name_
				 inFramework:frameworkName_
				 languages:[self languages]];
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)name_
					  inFramework:(NSString*)frameworkName_;
{
  return [GSWApp stringsTableArrayNamed:name_
				 inFramework:frameworkName_
				 languages:[self languages]];
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlForResourceNamed:(NSString*)name_
						 ofType:(NSString*)extension_
					inFramework:(NSString*)frameworkName_;
{
  return [GSWApp urlForResourceNamed:(extension_ ? [NSString stringWithFormat:@"%@.%@",name_,extension_] : name_)
				 inFramework:frameworkName_
				 languages:[self languages]
				 request:nil];//TODO
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)pathForResourceNamed:(NSString*)name_
						  ofType:(NSString*)extension_
					 inFramework:(NSString*)frameworkName_
{
  return [GSWApp pathForResourceNamed:name_
				 ofType:(NSString*)extension_
				 inFramework:frameworkName_
				 languages:[self languages]];
};

@end

//====================================================================
@implementation GSWComponent (GSWTemplateParsing)

//--------------------------------------------------------------------
//	templateWithHTMLString:declarationString:languages

//--------------------------------------------------------------------
+(GSWElement*)templateWithHTMLString:(NSString*)htmlString_
				   declarationString:(NSString*)pageDefString_
						   languages:(NSArray*)languages_
{
  GSWElement* rootElement=nil;
  NSDebugMLog0(@"Begin GSWComponent:templateWithHTMLString...\n");
  rootElement=[GSWTemplateParser templateWithHTMLString:htmlString_
								declarationString:pageDefString_
								languages:languages_];
  return rootElement;
};

@end

//====================================================================
@implementation GSWComponent (GSWTemplateParsingOldFn)
//--------------------------------------------------------------------
//	templateWithHTMLString:declarationString:
//old
+(GSWElement*)templateWithHTMLString:(NSString*)htmlString_
				  declarationString:(NSString*)pageDefString_ 
{
  return [self templateWithHTMLString:htmlString_
			   declarationString:pageDefString_
			   languages:nil];
};


@end
//====================================================================
@implementation GSWComponent (GSWActionResults)

//--------------------------------------------------------------------
-(GSWResponse*)generateResponse
{
  //OK
  GSWResponse* _response=nil;
  GSWContext* _context=nil;
  LOGObjectFnStart();
  _context=[self context];
  _response=[self _generateResponseInContext:_context];
  LOGObjectFnStop();
  return _response;
};

@end


//====================================================================
@implementation GSWComponent (GSWStatistics)

//--------------------------------------------------------------------
//	descriptionForResponse:inContext:

-(NSString*)descriptionForResponse:(GSWResponse*)response_
						 inContext:(GSWContext*)context_ 
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

@end

//====================================================================
@implementation GSWComponent (GSWComponentClassA)
+(void)_registerObserver:(id)_observer
{
  LOGClassFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWComponent (GSWVerifyAPI)
-(void)validateAPIAssociations
{
  NSDictionary* _api=[[self _componentDefinition] componentAPI];
  if (_api)
	{
	  NSArray* _required=[_api objectForKey:@"Required"];
	  NSArray* _optional=[_api objectForKey:@"Optional"];
	  int i=0;
	  int _count=[_required count];
	  id _name=nil;
	  for(i=0;i<_count;i++)
		{
		  _name=[_required objectAtIndex:i];
		  if (![self hasBinding:_name])
			{
			  [NSException raise:NSGenericException
						   format:@"There is no binding for '%@' in parent '%@' for component '%@' [parents : %@]",
						   _name,
						   [parent class],
						   [self class],
						   [self parentsClasses]];
			};
		};
	};
};
@end
