/* GSWComponent.h - GSWeb: Class GSWComponent
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

// $Id$

#ifndef _GSWComponent_h__
	#define _GSWComponent_h__


@interface GSWComponent : GSWElement <NSCoding,NSCopying>
{
//TODO ==> private @private
    NSString* name;
    NSMutableDictionary* subComponents;
    NSString* templateName;
    GSWElement* template;
    GSWComponentDefinition* componentDefinition;
    GSWComponent* parent;
    NSArray* associationsKeys;
    NSArray* associations;
    GSWElement* childTemplate;
    GSWContext* context;
    GSWSession* session;
//GSWeb Additions {
	NSDictionary* userDictionary;
	NSDictionary* userAssociations;
	NSDictionary* defaultAssociations;
	NSMutableDictionary* validationFailureMessages;
// }
    BOOL isPage;
    BOOL isCachingEnabled;
    BOOL isSynchronized;
};

-(id)init;
-(void)dealloc;

-(id)initWithCoder:(NSCoder*)coder_;
-(void)encodeWithCoder:(NSCoder*)coder_;
-(id)copyWithZone:(NSZone*)zone;

-(NSString*)description;
#if !GSWEB_STRICT
-(NSDictionary*)userDictionary;
-(void)setUserDictionary:(NSDictionary*)userDictionary_;
-(NSDictionary*)userAssociations;
-(void)setUserAssociations:(NSDictionary*)userAssociations_;
-(NSDictionary*)defaultAssociations;
-(void)setDefaultAssociations:(NSDictionary*)defaultAssociations_;
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
-(void)setCachingEnabled:(BOOL)flag_;

@end

//====================================================================
@interface GSWComponent (GSWComponentA)

-(void)setParent:(GSWComponent*)_parent
associationsKeys:(NSArray*)_associationsKeys
	associations:(NSArray*)_associations
		template:(GSWElement*)_template;

-(void)synchronizeComponentToParent;
-(void)synchronizeParentToComponent;
-(GSWElement*)_childTemplate;
-(GSWElement*)_template;
-(GSWComponentDefinition*)_componentDefinition;
-(NSString*)_templateName;
-(BOOL)_isPage;
-(void)_setIsPage:(BOOL)_isPage;
-(void)_setContext:(GSWContext*)context_;

@end

//====================================================================
@interface GSWComponent (GSWResourceManagement)

-(GSWElement*)templateWithName:(NSString*)name_;

@end

//====================================================================
@interface GSWComponent (GSWComponentC)
-(GSWComponent*)subComponentForElementID:(NSString*)_elementId;
-(void)setSubComponent:(GSWComponent*)_component
		  forElementID:(NSString*)_elementId;

//NDFN
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector;
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector
								 withObject:(id)object_;
-(void)makeParentsPerformSelectorIfPossible:(SEL)aSelector
								 withObject:(id)object1_
								 withObject:(id)object2_;
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector;
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector
							   withObject:(id)object_;
-(id)makeAParentPerformSelectorIfPossible:(SEL)aSelector
							   withObject:(id)object1_
							   withObject:(id)object2_;
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector;
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector
									   withObject:(id)object_;
-(void)makeSubComponentsPerformSelectorIfPossible:(SEL)aSelector
									   withObject:(id)object1_
									   withObject:(id)object2_;

@end

//====================================================================
@interface GSWComponent (GSWComponentD)
-(GSWAssociation*)_associationWithName:(NSString*)parentBindingName_;
@end

//====================================================================
@interface GSWComponent (GSWSynchronizing)
-(BOOL)hasBinding:(NSString*)parentBindingName_;
-(void)setValue:(id)_value
	 forBinding:(NSString*)parentBindingName_;
-(id)valueForBinding:(NSString*)parentBindingName_;
-(BOOL)synchronizesVariablesWithBindings;
-(NSDictionary*)bindingAssociations;
@end

//====================================================================
@interface GSWComponent (GSWRequestHandling)
-(void)sleep;
-(void)sleepInContext:(GSWContext*)context_;
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_;
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_;
#if !GSWEB_STRICT
-(void)setValidationFailureMessage:(NSString*)message
						forElement:(GSWDynamicElement*)element_;
-(NSString*)validationFailureMessageForElement:(GSWDynamicElement*)element_;
-(NSString*)handleValidationExceptionDefault;
-(BOOL)isValidationFailure;
-(NSDictionary*)validationFailureMessages;
-(NSArray*)allValidationFailureMessages;
#endif
-(void)ensureAwakeInContext:(GSWContext*)context_;
-(void)awake;
-(void)awakeInContext:(GSWContext*)context_;

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
-(GSWComponent*)pageWithName:(NSString*)_name;
-(GSWSession*)session;
-(BOOL)hasSession;
-(GSWContext*)context;
-(NSArray*)languages;//NDFN
-(GSWApplication*)application;
@end

//====================================================================
@interface GSWComponent (GSWLogging)
-(void)validationFailedWithException:(NSException*)_exception
							   value:(id)_value
							 keyPath:(id)_keyPath;
-(void)_debugWithString:(NSString*)_string;
-(void)debugWithFormat:(NSString*)_format,...;
-(void)logWithFormat:(NSString*)_format,...;
-(void)logWithFormat:(NSString*)_format
		   arguments:(va_list)argList;
+(void)logWithFormat:(NSString*)_format,...;

@end

//====================================================================
@interface GSWComponent (GSWComponentJ)
-(NSString*)_uniqueID;
@end

//====================================================================
@interface GSWComponent (GSWComponentK)
-(GSWResponse*)_generateResponseInContext:(GSWContext*)context_;
-(id)validateValue:(id*)valuePtr_
			forKey:(id)key_;
+(id)validateValue:(id*)valuePtr_
			forKey:(id)key_;
@end

//====================================================================
@interface GSWComponent (GSWComponentL)
-(NSString*)stringForKey:(id)key_
			inTableNamed:(NSString*)name_
		withDefaultValue:(NSString*)defaultValue_;
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)name_;

//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)name_;

-(NSString*)urlForResourceNamed:(NSString*)name_
						 ofType:(NSString*)extension_;
-(NSString*)_urlForResourceNamed:(NSString*)name_
						 ofType:(NSString*)extension_;
-(NSString*)pathForResourceNamed:(NSString*)name_
						  ofType:(NSString*)extension_;
//NDFN
-(NSString*)pathForComponentResourceNamed:(NSString*)name_
								   ofType:(NSString*)type_;


//NDFN
-(NSString*)stringForKey:(id)key_
			inTableNamed:(NSString*)name_
		withDefaultValue:(NSString*)defaultValue_
			 inFramework:(NSString*)frameworkName_;

//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)name_
					  inFramework:(NSString*)frameworkName_;

//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)name_
					  inFramework:(NSString*)frameworkName_;

//NDFN
-(NSString*)urlForResourceNamed:(NSString*)name_
						 ofType:(NSString*)extension_
					inFramework:(NSString*)frameworkName_;

//NDFN
-(NSString*)pathForResourceNamed:(NSString*)name_
						  ofType:(NSString*)extension_
					 inFramework:(NSString*)frameworkName_;
@end

//====================================================================
@interface GSWComponent (GSWTemplateParsing)

+(GSWElement*)templateWithHTMLString:(NSString *)htmlString_
				  declarationString:(NSString *)declarationString_
						  languages:(NSArray*)languages_;

@end
//====================================================================
@interface GSWComponent (GSWTemplateParsingOldFn)
+(GSWElement*)templateWithHTMLString:(NSString *)htmlString_
				  declarationString:(NSString*)declarationString_;//old

@end

//====================================================================
@interface GSWComponent (GSWActionResults) <GSWActionResults>

- (GSWResponse*)generateResponse;

@end

//====================================================================
@interface GSWComponent (GSWStatistics)
-(NSString*)descriptionForResponse:(GSWResponse*)response_
						 inContext:(GSWContext*)context_;
@end

//====================================================================
@interface GSWComponent (GSWComponentClassA)
+(void)_registerObserver:(id)_observer;
@end

//====================================================================
@interface GSWComponent (GSWVerifyAPI)
-(void)validateAPIAssociations;
@end
#endif //_GSWComponent_h__
