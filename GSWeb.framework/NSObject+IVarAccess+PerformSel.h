/* NSObject+IVarAccess+PerformSel.h
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

#ifndef _NSObject_IVarAccess_PerformSel_h__
#define _NSObject_IVarAccess_PerformSel_h__

//===================================================================================
@interface NSObject (IVarsAccess)

// A class can return YES to disable IVar access Caching
+(BOOL)isIVarAccessCachingDisabled;

// return function name with template _tpl for an IVar
+(NSString*)getFunctionNameWithTemplate:(NSString*)tpl
							forVariable:(NSString*)iVarName
				   uppercaseFirstLetter:(BOOL)uppercaseFirstLetter;

-(SEL)getSelectorWithFunctionTemplate:(NSString*)tpl
						   forVariable:(NSString*)iVarName
				 uppercaseFirstLetter:(BOOL)uppercaseFirstLetter;

-(id)getIVarNamed:(NSString*)iVarName;

-(void)setIVarNamed:(NSString*)iVarName
		  withValue:(id)value;

-(id)performSelector:(SEL)aSelector
		withIntValue:(int)value;

-(id)performSelector:(SEL)aSelector
	  withFloatValue:(float)value;

-(id)performSelector:(SEL)aSelector
	 withDoubleValue:(double)value;

-(id)performSelector:(SEL)aSelector
	  withShortValue:(short)value;

-(id)performSelector:(SEL)aSelector
	 withUShortValue:(ushort)value;

@end

#endif //_NSObject_IVarAccess_PerformSel_h__
