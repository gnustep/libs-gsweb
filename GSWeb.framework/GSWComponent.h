/** GSWComponent.h - <title>GSWeb: Class GSWComponent</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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
    NSMutableDictionary* _keyAssociations;
    //NSArray* _associationsKeys;  replaced by _keyAssociations
    //NSArray* _associations;
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
    BOOL _isSynchronized;

};

- (id)initWithContext:(GSWContext *) aContext;

-(NSString*)description;
#if !GSWEB_STRICT
-(NSDictionary*)userDictionary;
-(void)setUserDictionary:(NSDictionary*)userDictionary;
-(NSDictionary*)userAssociations;
-(void)setUserAssociations:(NSDictionary*)userAssociations;
-(GSWAssociation*)userAssociationForKey:(NSString*)key;
-(NSDictionary*)defaultAssociations;
-(void)setDefaultAssociations:(NSDictionary*)defaultAssociations;
-(GSWAssociation*)defaultAssociationForKey:(NSString*)key;
#endif
-(NSString*)frameworkName;
-(NSString*)baseURL;
-(NSString*)name;
-(NSString*)path;


-(BOOL)isCachingEnabled;
-(void)setCachingEnabled:(BOOL)flag;

-(void) _setParent:(GSWComponent*) parent
      associations:(NSMutableDictionary *) assocdict
          template:(GSWElement*) template;

-(void)synchronizeComponentToParent;
-(void)synchronizeParentToComponent;
-(GSWElement*)_childTemplate;
-(GSWElement*) template;
-(GSWComponentDefinition*)_componentDefinition;
-(NSString*)_templateName;
-(NSString*)declarationName;
-(BOOL)_isPage;
-(void)_setIsPage:(BOOL)isPage;
-(void)_setContext:(GSWContext*)aContext;

-(GSWElement*)templateWithName:(NSString*)aName;

-(GSWComponent*)subComponentForElementID:(NSString*)elementId;
// PRIVATE
-(void)_setSubcomponent:(GSWComponent*)component
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

-(GSWAssociation*)_associationWithName:(NSString*)parentBindingName;

-(BOOL)hasBinding:(NSString*)parentBindingName;
-(void)setValue:(id)value
     forBinding:(NSString*)parentBindingName;
-(id)valueForBinding:(NSString*)parentBindingName;
-(BOOL)synchronizesVariablesWithBindings;
-(BOOL)synchronizesParentToComponentVariablesWithBindings;
//-(BOOL)synchronizesComponentToParentVariablesWithBindings;
-(BOOL) isStateless;
-(void) reset;

-(NSDictionary*)bindingAssociations;

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

/*
Makes sure that the receiver is awake in aContext. 
Call this method before using a component which was cached in a variable.
*/

-(void)ensureAwakeInContext:(GSWContext*)aContext;
-(void)awake;

// PRIVATE
-(void)_awakeInContext:(GSWContext*)aContext;

-(id)performParentAction:(NSString*)attribute;
-(GSWComponent*)parent;
-(GSWComponent*)topParent;//NDFN
-(NSArray*)parents;//NDFN
-(NSArray*)parentsClasses;//NDFN

-(GSWComponent*)pageWithName:(NSString*)aName;
-(GSWSession*)session;
-(BOOL)hasSession;
-(GSWContext*)context;
-(NSArray*)languages;//NDFN
-(GSWApplication*)application;

-(void)validationFailedWithException:(NSException*)exception
                               value:(id)_value
                             keyPath:(id)_keyPath;
-(void)_debugWithString:(NSString*)string;
-(void)debugWithFormat:(NSString*)format,...;
-(void)logString:(NSString*)aString;
-(void)logWithFormat:(NSString*)format,...;
-(void)logWithFormat:(NSString*)format
           arguments:(va_list)argList;
+(void)logWithFormat:(NSString*)format,...;

-(NSString*)_uniqueID;

-(GSWResponse*)_generateResponseInContext:(GSWContext*)aContext;
-(id)validateValue:(id*)valuePtr
            forKey:(id)key;

//+(id)validateValue:(id*)valuePtr
//            forKey:(id)key;

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


+(GSWElement*)templateWithHTMLString:(NSString*)htmlString
                   declarationString:(NSString*)declarationString
                           languages:(NSArray*)languages;


+(GSWElement*)templateWithHTMLString:(NSString *)htmlString
                   declarationString:(NSString*)declarationString;//old


- (GSWResponse*)generateResponse;

-(NSString*)descriptionForResponse:(GSWResponse*)response
                         inContext:(GSWContext*)aContext;

+(void)_registerObserver:(id)observer;

-(void)validateAPIAssociations;
@end
#endif //_GSWComponent_h__
