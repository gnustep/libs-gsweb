/* GSWComponentDefinition.h - GSWeb: Class GSWComponentDefinition
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

#ifndef _GSWComponentDefinition_h__
	#define _GSWComponentDefinition_h__


//====================================================================
@interface GSWComponentDefinition : NSObject <NSCoding,NSCopying>
{
  NSString* name;
  GSWBundle* bundle;
  NSMutableArray* observers;
  NSString* frameworkName;
  NSString* templateName;
  Class componentClass;
  BOOL isScriptedClass;
  BOOL isCachingEnabled;
  BOOL isAwake;
};

-(id)initWithName:(NSString*)name_
			 path:(NSString*)_path
		  baseURL:(NSString*)_baseURL
	frameworkName:(NSString*)_frameworkName;
-(void)dealloc;
-(id)initWithCoder:(NSCoder*)coder_;
-(void)encodeWithCoder:(NSCoder*)coder_;
-(id)copyWithZone:(NSZone*)zone_;

-(NSString*)frameworkName;
-(NSString*)baseURL;
-(NSString*)path;
-(NSString*)name;
-(NSString*)description;
-(void)sleep;
-(void)awake;
@end

//====================================================================
@interface GSWComponentDefinition (GSWCacheManagement)
-(BOOL)isCachingEnabled;
-(void)setCachingEnabled:(BOOL)flag_;
@end

//====================================================================
@interface GSWComponentDefinition (GSWComponentDefinitionA)
-(void)_clearCache;
@end

//====================================================================
@interface GSWComponentDefinition (GSWComponentDefinitionB)
-(GSWElement*)templateWithName:(NSString*)name_
					languages:(NSArray*)languages_;
/*
-(NSString*)stringForKey:(NSString*)key_
			inTableNamed:(NSString*)name_
		withDefaultValue:(NSString*)defaultValue_
			   languages:(NSArray*)languages_;
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)name_
					withLanguages:(NSArray*)languages_;

//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)name_
						 withLanguages:(NSArray*)languages_;

-(NSString*)urlForResourceNamed:(NSString*)name_
						 ofType:(NSString*)type_
					  languages:(NSArray*)languages_
						request:(GSWRequest*)request_;
*/
-(NSString*)pathForResourceNamed:(NSString*)name_
						  ofType:(NSString*)type_
					   languages:(NSArray*)languages_;
@end

//====================================================================
@interface GSWComponentDefinition (GSWComponentDefinitionC)
-(GSWComponent*)componentInstanceInContext:(GSWContext*)context_;
-(Class)componentClass;
-(Class)_componentClass;
-(GSWComponentReference*)componentReferenceWithAssociations:(NSDictionary*)associations_
												  template:(GSWElement*)_template;

-(NSDictionary*)componentAPI;//NDFN
@end

//====================================================================
@interface GSWComponentDefinition (GSWComponentDefinitionD)
-(void)_finishInitializingComponent:(GSWComponent*)_component;
@end

//====================================================================
@interface GSWComponentDefinition (GSWComponentDefinitionE)
-(void)_notifyObserversForDyingComponent:(GSWComponent*)_component;
-(void)_awakeObserversForComponent:(GSWComponent*)_component;
-(void)_deallocForComponent:(GSWComponent*)_component;
-(void)_awakeForComponent:(GSWComponent*)_component;
-(void)_registerObserver:(id)_observer;
+(void)_registerObserver:(id)_observer;
@end



#endif //GSWComponentDefinition
