/** GSWAssociation.h - <title>GSWeb: Class GSWAssociation</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

/**
The WOAssociation class is a class for objects which represents values of GNUstepWeb attributes specified in declaration files (.gswd).

WOAssociation object get or set value according to values key. For exemple:

MyString1: GSWString 
{
value = "aLabel";
};

MyString2: GSWString
{
  value = label;
};

MyString3: GSWString 
{
  value = myMember.label;
};


At runtime, the GNUstepWeb parser scans an HTML template (.html) and it's declarations (.gswd) and creates 3 dynamic element objects of type GSWString. 
In the case value= "label", the string value will be a constant string "aLabel". 
In the case value = label, the value came from method "label" or member "label" of the component (by valueForKey: mechanism). 
In the case value = myMember.label, value came from method "label" or member "label" of the object returned by calling valueForKey:@"myMember" on the component.

NEW FEATURE: negate. add a "!" in front of your key path and the result will be negated.

**/

#ifndef _GSWAssociation_h__
	#define _GSWAssociation_h__

//====================================================================
@interface GSWAssociation : NSObject <NSCopying>
{
  BOOL _debugEnabled;
  BOOL _negate;                // GSW addon.
  NSString* _bindingName;
  NSString* _declarationName;
  NSString* _declarationType;
};

-(id)valueInComponent:(GSWComponent*)component;

- (BOOL) boolValueInComponent:(GSWComponent*)component;

-(void)setValue:(id)value
    inComponent:(GSWComponent*)component;
-(BOOL)isValueConstant;
-(BOOL)isValueSettable;
-(BOOL)isValueSettableInComponent:(GSWComponent*) comp;
-(BOOL)isValueConstantInComponent:(GSWComponent*) comp;

// YES if we negate the result before returnig it.
-(BOOL)negate;
-(void) setNegate:(BOOL) yn;


-(NSString*)description;
-(NSString*)bindingName;
-(NSString*)declarationName;
-(NSString*)declarationType;

+(void)setClasse:(Class)class
      forHandler:(NSString*)handler;
+(void)addLogHandlerClasse:(Class)class;
+(void)removeLogHandlerClasse:(Class)class;

+(GSWAssociation*)associationWithValue:(id)value;
+(GSWAssociation*)associationWithKeyPath:(NSString*)keyPath;
//NDFN
+(GSWAssociation*)associationFromString:(NSString*)string;


// returns the binding String as in the wod.
- (NSString*) bindingInComponent:(GSWComponent*) component;

-(BOOL)isImplementedForComponent:(NSObject*)component;


-(NSString*)keyPath;
-(void)logSynchronizeComponentToParentForValue:(id)value
                                   inComponent:(GSWComponent*)component;
-(void)logSynchronizeParentToComponentForValue:(id)value
                                   inComponent:(GSWComponent*)component;

-(void)_logPullValue:(id)value
	 inComponent:(GSWComponent*) component;
-(void)_logPushValue:(id)value
	 inComponent:(GSWComponent*) component;

-(NSString*)debugDescription;
-(void)setDebugEnabledForBinding:(NSString*)bindingName
                 declarationName:(NSString*)declarationName
                 declarationType:(NSString*)declarationType;

+(id)valueInComponent:(GSWComponent*)component
           forKeyPath:(NSString*)keyPath;

+(void)setValue:(id)value
    inComponent:(GSWComponent*)component
     forKeyPath:(NSString*)keyPath;

@end

//===================================================================================
@interface NSDictionary (GSWAssociation)
-(BOOL)isAssociationDebugEnabledInComponent:(GSWComponent*)component;
-(void)associationsSetDebugEnabled;
-(void)associationsSetValuesFromObject:(id)from
                              inObject:(id)to;
-(NSDictionary*)associationsWithoutPrefix:(NSString*)prefix
                               removeFrom:(NSMutableDictionary*)removeFrom;
-(NSDictionary*)dictionaryByReplacingStringsWithAssociations;
@end

//===================================================================================
@interface NSArray (GSWAssociation)
-(NSArray*)arrayByReplacingStringsWithAssociations;
@end
#endif //_GSWAssociation_h__



