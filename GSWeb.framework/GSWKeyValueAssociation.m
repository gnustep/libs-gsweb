/** GSWKeyValueAssociation.m - <title>GSWeb: Class GSWKeyValueAssociation</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

//====================================================================
@implementation GSWKeyValueAssociation

//--------------------------------------------------------------------
-(id)initWithKeyPath:(NSString*)aKeyPath
{
  //OK
  if ((self=[super init]))
    {
      ASSIGNCOPY(_keyPath,aKeyPath);
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogMemC("GSWKeyValueAssociation start of dealloc");
  GSWLogAssertGood(self);
  DESTROY(_keyPath);
  GSWLogMemC("keyPath deallocated");
  [super dealloc];
  GSWLogMemC("GSWKeyValueAssociation end of dealloc");
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWKeyValueAssociation* clone = [super copyWithZone:zone];
  ASSIGN(clone->_keyPath,_keyPath);
  return clone;
};

//--------------------------------------------------------------------
-(id)valueInComponent:(GSWComponent*)object
{
  id retValue=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"associations",@"self=%@ ",self);
  NSDebugMLLog(@"associations",@"keyPath=%@ ",_keyPath);
  NSDebugMLLog(@"associations",@"object=%@ ", object);
  retValue=[GSWAssociation valueInComponent:object
                           forKeyPath:_keyPath];
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
-(void)setValue:(id)aValue
    inComponent:(GSWComponent*)object
{
  LOGObjectFnStart();
  NSDebugMLLog(@"associations",@"keyPath=%@ ",_keyPath);
  NSDebugMLLog(@"associations",@"GSWAssociation: setValue:%@ (self=%@)",aValue,self);
  if (aValue) 
    {
      NSDebugMLLog(@"associations",@"value_ class:%@",NSStringFromClass([aValue class]));
    }
  if ([_keyPath length]==0)
    {
      [NSException raise:NSInvalidArgumentException 
                   format:@"No key path when setting value %@ in object of class %@ for association %@",
                   aValue,NSStringFromClass([object class]),self];
    }
  /*Not Here because self is not a string key !
  //TODO (return something!)
  [object validateValue:&aValue
  forKey:self];
  */
  [GSWAssociation setValue:aValue
                  inComponent:object
                  forKeyPath:_keyPath];
  [self logSetValue:aValue];
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
             _keyPath];
  return dscr;
};

@end

//====================================================================
@implementation GSWKeyValueAssociation (GSWAssociationB)

//--------------------------------------------------------------------
-(NSString*)keyPath
{
  return _keyPath;
};

//--------------------------------------------------------------------
-(NSString*)debugDescription
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

@end




