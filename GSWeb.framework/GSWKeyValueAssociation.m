/* GSWKeyValueAssociation.m - GSWeb: Class GSWKeyValueAssociation
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWKeyValueAssociation

//--------------------------------------------------------------------
-(id)initWithKeyPath:(NSString*)keyPath_
{
  //OK
  if ((self=[super init]))
	{
	  ASSIGNCOPY(keyPath,keyPath_);
	};
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(keyPath);
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone;
{
  GSWKeyValueAssociation* clone = [super copyWithZone:zone];
  ASSIGN(clone->keyPath,keyPath);
  return clone;
};

//--------------------------------------------------------------------
-(id)valueInObject:(id)object_
{
  id retValue=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"associations",@"keyPath=%@ object_=%p",keyPath,(void*)object_);
  retValue=[GSWAssociation valueInObject:object_
                           forKeyPath:keyPath];
  NSDebugMLLog(@"associations",@"retValue=%@ (%p) (class=%@)",
               retValue,
               retValue,
               [retValue class]);
  [self logTakeValue:retValue];
  LOGObjectFnStop();
  return retValue;
};

//--------------------------------------------------------------------
-(void)setValue:(id)value_
	   inObject:(id)object_
{
  LOGObjectFnStart();
  NSDebugMLLog(@"associations",@"GSWAssociation: setValue:%@ (self=%@)",value_,self);
  NSDebugMLLog(@"associations",@"value_ class:%@",[value_ class]);
  NSDebugMLLog(@"associations",@"value_ String class:%@",NSStringFromClass([value_ class]));
  //TODO (return something!)
  [object_ validateValue:&value_
			  forKey:self];
  [GSWAssociation setValue:value_
				  inObject:object_
				  forKeyPath:keyPath];
  [self logSetValue:value_];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(BOOL)isValueConstant
{
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)isValueSettable
{
  return YES;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  GSWLogAssertGood(self);
  return [NSString stringWithFormat:@"<%s %p - keyPath=%@>",
				   object_get_class_name(self),
				   (void*)self,
				   keyPath];
};

@end

//====================================================================
@implementation GSWKeyValueAssociation (GSWAssociationB)

//--------------------------------------------------------------------
-(NSString*)keyPath
{
  return keyPath;
};

//--------------------------------------------------------------------
-(NSString*)debugDescription
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

@end




