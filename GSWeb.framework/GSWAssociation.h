/* GSWAssociation.h - GSWeb: Class GSWAssociation
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

#ifndef _GSWAssociation_h__
	#define _GSWAssociation_h__

//====================================================================
@interface GSWAssociation : NSObject <NSCopying>
{
  BOOL debugEnabled;
  NSString* bindingName;
  NSString* declarationName;
  NSString* declarationType;
};

-(id)init;
-(id)copyWithZone:(NSZone *)zone;

-(id)valueInComponent:(GSWComponent*)component_;
-(id)valueInObject:(id)object_;//NDFN
-(void)setValue:(id)value_
	inComponent:(GSWComponent*)component_;
-(void)setValue:(id)value_
	inObject:(id)object_;//NDFN
-(BOOL)isValueConstant;
-(BOOL)isValueSettable;
-(NSString*)description;
-(NSString*)bindingName;
-(NSString*)declarationName;
-(NSString*)declarationType;
@end

//====================================================================
@interface GSWAssociation (GSWAssociationHandlers)
+(void)setClasse:(Class)class_
	  forHandler:(NSString*)handler_;
+(void)addLogHandlerClasse:(Class)class_;
+(void)removeLogHandlerClasse:(Class)class_;
@end
//====================================================================
@interface GSWAssociation (GSWAssociationCreation)
+(GSWAssociation*)associationWithValue:(id)value_;
+(GSWAssociation*)associationWithKeyPath:(NSString*)keyPath_;
//NDFN
+(GSWAssociation*)associationFromString:(NSString*)string_;

@end
/*
//====================================================================
@interface GSWAssociation (GSWAssociationOldFn)

-(void)setValue:(id)value_;
-(id)value;

@end
*/
//====================================================================
@interface GSWAssociation (GSWAssociationA)

-(BOOL)isImplementedForComponent:(NSObject*)component_;

@end

//====================================================================
@interface GSWAssociation (GSWAssociationB)

-(NSString*)keyPath;
-(void)logSynchronizeComponentToParentForValue:(id)value_
								   inComponent:(NSObject*)component_;
-(void)logSynchronizeParentToComponentForValue:(id)value_
								   inComponent:(NSObject*)component_;
-(void)logTakeValue:(id)value_;
-(void)logSetValue:(id)value_;

-(NSString*)debugDescription;
-(void)setDebugEnabledForBinding:(NSString*)_bindingName
				 declarationName:(NSString*)_declarationName
				 declarationType:(NSString*)_declarationType;

+(id)valueInObject:(id)object_
		forKeyPath:(NSString*)keyPath_;

+(void)setValue:(id)value_
	   inObject:(id)object_
	 forKeyPath:(NSString*)keyPath_;

@end

//===================================================================================
@interface NSDictionary (GSWAssociation)
-(BOOL)isAssociationDebugEnabledInComponent:(NSObject*)component_;
-(void)associationsSetDebugEnabled;
-(void)associationsSetValuesFromObject:(id)from_
							  inObject:(id)to_;
-(NSDictionary*)associationsWithoutPrefix:(NSString*)prefix_
							   removeFrom:(NSMutableDictionary*)removeFrom_;
-(NSDictionary*)dictionaryByReplacingStringsWithAssociations;
@end

//===================================================================================
@interface NSArray (GSWAssociation)
-(NSArray*)arrayByReplacingStringsWithAssociations;
@end
#endif //_GSWAssociation_h__



