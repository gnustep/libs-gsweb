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
  GSWLogMemC("GSWKeyValueAssociation start of dealloc");
  GSWLogAssertGood(self);
  DESTROY(keyPath);
  GSWLogMemC("keyPath deallocated");
  [super dealloc];
  GSWLogMemC("GSWKeyValueAssociation end of dealloc");
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
  NSDebugMLLog(@"associations",@"self=%@ ",self);
  NSDebugMLLog(@"associations",@"keyPath=%@ ",keyPath);
  NSDebugMLLog(@"associations",@"object_=%@ ", object_);
  retValue=[GSWAssociation valueInObject:object_
                           forKeyPath:keyPath];
  NSDebugMLLog(@"associations",@"self=%@ retValue=%@ (%p) (class=%@)",
               self,
               retValue,
               retValue,
               NSStringFromClass([retValue class]));
  [self logTakeValue:retValue];
  LOGObjectFnStop();
  return retValue;
};

//--------------------------------------------------------------------
-(void)setValue:(id)value_
	   inObject:(id)object_
{
  LOGObjectFnStart();
  NSDebugMLLog(@"associations",@"keyPath=%@ ",keyPath);
  NSDebugMLLog(@"associations",@"GSWAssociation: setValue:%@ (self=%@)",value_,self);
  if (value_) {
    NSDebugMLLog(@"associations",@"value_ class:%@",NSStringFromClass([value_ class]));
  }
  /*Not Here because self is not a string key !
  //TODO (return something!)
  [object_ validateValue:&value_
			  forKey:self];
  */
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
  NSString* dscr=nil;
  GSWLogAssertGood(self);
  dscr=[NSString stringWithFormat:@"<%s %p -",
                 object_get_class_name(self),
                 (void*)self];
  dscr=[dscr stringByAppendingFormat:@" keyPath=%@>",
             keyPath];
  return dscr;
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




