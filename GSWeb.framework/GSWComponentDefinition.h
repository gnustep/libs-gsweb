/** GSWComponentDefinition.h - <title>GSWeb: Class GSWComponentDefinition</title>

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

// $Id$

#ifndef _GSWComponentDefinition_h__
	#define _GSWComponentDefinition_h__

//====================================================================
@interface GSWComponentDefinition : NSObject <NSCoding,NSCopying>
{
  NSString* _name;
  GSWBundle* _bundle;
  NSMutableArray* _observers;
  NSString* _frameworkName;
  NSString* _templateName;
  Class _componentClass;
  BOOL _isScriptedClass;
  BOOL _isCachingEnabled;
  BOOL _isAwake;
};

-(id)initWithName:(NSString*)aName
             path:(NSString*)aPath
          baseURL:(NSString*)baseURL
    frameworkName:(NSString*)aFrameworkName;
-(void)dealloc;
-(id)initWithCoder:(NSCoder*)coder;
-(void)encodeWithCoder:(NSCoder*)coder;
-(id)copyWithZone:(NSZone*)zone;

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
-(void)setCachingEnabled:(BOOL)flag;
@end

//====================================================================
@interface GSWComponentDefinition (GSWComponentDefinitionA)
-(void)_clearCache;
@end

//====================================================================
@interface GSWComponentDefinition (GSWComponentDefinitionB)
-(GSWElement*)templateWithName:(NSString*)aName
                     languages:(NSArray*)languages;
/*
-(NSString*)stringForKey:(NSString*)key_
	    inTableNamed:(NSString*)aName
	withDefaultValue:(NSString*)defaultValue_
       	       languages:(NSArray*)languages;
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)aName
	            withLanguages:(NSArray*)languages;

//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)aName
		    withLanguages:(NSArray*)languages;

-(NSString*)urlForResourceNamed:(NSString*)aName
		         ofType:(NSString*)aType
		      languages:(NSArray*)languages
	      		request:(GSWRequest*)aRequest;
*/
-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)aType
                       languages:(NSArray*)languages;
@end

//====================================================================
@interface GSWComponentDefinition (GSWComponentDefinitionC)
-(GSWComponent*)componentInstanceInContext:(GSWContext*)aContext;
-(Class)componentClass;
-(Class)_componentClass;
-(GSWComponentReference*)componentReferenceWithAssociations:(NSDictionary*)associations
                                                   template:(GSWElement*)template;

-(NSDictionary*)componentAPI;//NDFN
@end

//====================================================================
@interface GSWComponentDefinition (GSWComponentDefinitionD)
-(void)_finishInitializingComponent:(GSWComponent*)aComponent;
@end

//====================================================================
@interface GSWComponentDefinition (GSWComponentDefinitionE)
-(void)_notifyObserversForDyingComponent:(GSWComponent*)aComponent;
-(void)_awakeObserversForComponent:(GSWComponent*)aComponent;
-(void)_deallocForComponent:(GSWComponent*)aComponent;
-(void)_awakeForComponent:(GSWComponent*)aComponent;
-(void)_registerObserver:(id)observer;
+(void)_registerObserver:(id)observer;
@end



#endif //GSWComponentDefinition
