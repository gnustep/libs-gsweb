/** GSWComponent.h - <title>GSWeb: Class GSWComponent</title>
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

// $Id$

#ifndef _GSWComponent_h__
	#define _GSWComponent_h__


@interface GSWComponent : GSWElement <NSCoding,NSCopying>
{
//TODO ==> private @private
    NSString* _name;
    NSMutableDictionary* _subComponents;
    NSString* _templateName;
    GSWElement* _template;
    GSWComponentDefinition* _componentDefinition;
    GSWComponent* _parent;
    NSArray* _associationsKeys;
    NSArray* _associations;
    GSWElement* _childTemplate;
    GSWContext* _context;
    GSWSession* _session;
//GSWeb Additions {
	NSDictionary* _userDictionary;
	NSDictionary* _userAssociations;
	NSDictionary* _defaultAssociations;
	NSMutableDictionary* _validationFailureMessages;
// }
    BOOL _isPage;
    BOOL _isCachingEnabled;
    BOOL _isParentToComponentSynchronized;
    BOOL _isComponentToParentSynchronized;

};

-(NSString*)description;
#if !GSWEB_STRICT
-(NSDictionary*)userDictionary;
-(void)setUserDictionary:(NSDictionary*)userDictionary;
-(NSDictionary*)userAssociations;
-(void)setUserAssociations:(NSDictionary*)userAssociations;
-(NSDictionary*)defaultAssociations;
-(void)setDefaultAssociations:(NSDictionary*)defaultAssociations;
#endif
-(NSString*)frameworkName;
-(NSString*)baseURL;
-(NSString*)name;
-(NSString*)path;

-(NSString*)_templateNameFromClass:(Class)_class;

@end

//====================================================================
@interface GSWComponent (GSWCachingPolicy)

-(BOOL)isCachingEnabled;
-(void)setCachingEnabled:(BOOL)flag;

@end

//====================================================================
@interface GSWComponent (GSWComponentA)

-(void)setParent:(GSWComponent*)parent
associationsKeys:(NSArray*)associationsKeys
    associations:(NSArray*)associations
        template:(GSWElement*)template;

-(void)synchronizeComponentToParent;
-(void)synchronizeParentToComponent;
-(GSWElement*)_childTemplate;
-(GSWElement*)_template;
-(GSWComponentDefinition*)_componentDefinition;
-(NSString*)_templateName;
-(NSString*)definitionName;
-(BOOL)_isPage;
-(void)_setIsPage:(BOOL)isPage;
-(void)_setContext:(GSWContext*)aContext;

@end

//====================================================================
@interface GSWComponent (GSWResourceManagement)

-(GSWElement*)templateWithName:(NSString*)aName;

@end

//====================================================================
@interface GSWComponent (GSWComponentC)
-(GSWComponent*)subComponentForElementID:(NSString*)elementId;
-(void)setSubComponent:(GSWComponent*)component
          forElementID:(NSString*)elementId;

//NDFN
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector;
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)object;
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector
                                 withObject:(id)object1
                                 withObject:(id)object2;
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector;
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector
                               withObject:(id)object;
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector
                               withObject:(id)object1
                               withObject:(id)object2;
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector;
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector
                                       withObject:(id)object;
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector
                                       withObject:(id)object1
                                       withObject:(id)object2;

@end

//====================================================================
@interface GSWComponent (GSWComponentD)
-(GSWAssociation*)_associationWithName:(NSString*)parentBindingName;
@end

//====================================================================
@interface GSWComponent (GSWSynchronizing)
-(BOOL)hasBinding:(NSString*)parentBindingName;
-(void)setValue:(id)value
     forBinding:(NSString*)parentBindingName;
-(id)valueForBinding:(NSString*)parentBindingName;
-(BOOL)synchronizesVariablesWithBindings;
-(BOOL)synchronizesParentToComponentVariablesWithBindings;
-(BOOL)synchronizesComponentToParentVariablesWithBindings;
-(NSDictionary*)bindingAssociations;
@end

//====================================================================
@interface GSWComponent (GSWRequestHandling)
-(void)sleep;
-(void)sleepInContext:(GSWContext*)aContext;
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext;
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext;
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext;
#if !GSWEB_STRICT
-(void)setValidationFailureMessage:(NSString*)message
                        forElement:(GSWDynamicElement*)element;
-(NSString*)validationFailureMessageForElement:(GSWDynamicElement*)element;
-(NSString*)handleValidationExceptionDefault;
-(BOOL)isValidationFailure;
-(NSDictionary*)validationFailureMessages;
-(NSArray*)allValidationFailureMessages;
#endif
-(void)ensureAwakeInContext:(GSWContext*)aContext;
-(void)awake;
-(void)awakeInContext:(GSWContext*)aContext;

@end

//====================================================================
@interface GSWComponent (GSWActionInvocation)
-(id)performParentAction:(NSString*)attribute;
-(GSWComponent*)parent;
-(GSWComponent*)topParent;//NDFN
-(NSArray*)parents;//NDFN
-(NSArray*)parentsClasses;//NDFN
@end

//====================================================================
@interface GSWComponent (GSWConveniences)
-(GSWComponent*)pageWithName:(NSString*)aName;
-(GSWSession*)session;
-(BOOL)hasSession;
-(GSWContext*)context;
-(NSArray*)languages;//NDFN
-(GSWApplication*)application;
@end

//====================================================================
@interface GSWComponent (GSWLogging)
-(void)validationFailedWithException:(NSException*)exception
                               value:(id)_value
                             keyPath:(id)_keyPath;
-(void)_debugWithString:(NSString*)string;
-(void)debugWithFormat:(NSString*)format,...;
-(void)logWithFormat:(NSString*)format,...;
-(void)logWithFormat:(NSString*)format
           arguments:(va_list)argList;
+(void)logWithFormat:(NSString*)format,...;

@end

//====================================================================
@interface GSWComponent (GSWComponentJ)
-(NSString*)_uniqueID;
@end

//====================================================================
@interface GSWComponent (GSWComponentK)
-(GSWResponse*)_generateResponseInContext:(GSWContext*)aContext;
-(id)validateValue:(id*)valuePtr
            forKey:(id)key;
+(id)validateValue:(id*)valuePtr
            forKey:(id)key;
@end

//====================================================================
@interface GSWComponent (GSWComponentL)
-(NSString*)stringForKey:(id)key
            inTableNamed:(NSString*)aName
        withDefaultValue:(NSString*)defaultValue;
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aName;

//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aName;

-(NSString*)urlForResourceNamed:(NSString*)aName
                         ofType:(NSString*)extension;
-(NSString*)_urlForResourceNamed:(NSString*)aName
                          ofType:(NSString*)extension;
-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)extension;
//NDFN
-(NSString*)pathForComponentResourceNamed:(NSString*)aName
                                   ofType:(NSString*)type;


//NDFN
-(NSString*)stringForKey:(id)key
            inTableNamed:(NSString*)aName
        withDefaultValue:(NSString*)defaultValue
             inFramework:(NSString*)frameworkName;

//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aName
                      inFramework:(NSString*)frameworkName;

//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aName
                      inFramework:(NSString*)frameworkName;

//NDFN
-(NSString*)urlForResourceNamed:(NSString*)aName
                         ofType:(NSString*)extension
                    inFramework:(NSString*)frameworkName;

//NDFN
-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)extension
                     inFramework:(NSString*)frameworkName;
@end

//====================================================================
@interface GSWComponent (GSWTemplateParsing)

+(GSWElement*)templateWithHTMLString:(NSString*)htmlString
                   declarationString:(NSString*)declarationString
                           languages:(NSArray*)languages;

@end
//====================================================================
@interface GSWComponent (GSWTemplateParsingOldFn)
+(GSWElement*)templateWithHTMLString:(NSString *)htmlString
                   declarationString:(NSString*)declarationString;//old

@end

//====================================================================
@interface GSWComponent (GSWActionResults) <GSWActionResults>

- (GSWResponse*)generateResponse;

@end

//====================================================================
@interface GSWComponent (GSWStatistics)
-(NSString*)descriptionForResponse:(GSWResponse*)response
                         inContext:(GSWContext*)aContext;
@end

//====================================================================
@interface GSWComponent (GSWComponentClassA)
+(void)_registerObserver:(id)observer;
@end

//====================================================================
@interface GSWComponent (GSWVerifyAPI)
-(void)validateAPIAssociations;
@end
#endif //_GSWComponent_h__
