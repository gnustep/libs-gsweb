/** GSWBindingNameAssociation.m - <title>GSWeb: Class GSWBindingNameAssociation</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Apr 1999
   
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
@implementation GSWBindingNameAssociation

//--------------------------------------------------------------------
-(id)initWithKeyPath:(NSString*)aKeyPath
{
  if ((self=[super init]))
    {
      NSArray* keys=nil;
      int      keyCount = 0;
      
      if ([aKeyPath hasPrefix:@"^"]) {
        aKeyPath = [aKeyPath substringFromIndex:1];
      }

      keys=[aKeyPath componentsSeparatedByString:@"."];
      ASSIGN(_parentBindingName,[[keys objectAtIndex:0] stringByDeletingPrefix:@"^"]);
      keyCount = [keys count];
      if (keyCount > 1) {
        ASSIGN(_keyPath,[[keys subarrayWithRange:NSMakeRange(1,keyCount-1)] componentsJoinedByString:@"."]);
      }
    }

  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_parentBindingName);
  DESTROY(_keyPath);
  [super dealloc];
}

- (BOOL) _hasBindingInParent:(GSWComponent *) component
{
 return [component hasBinding:_parentBindingName];
}

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone;
{
  GSWBindingNameAssociation* clone = [super copyWithZone:zone];
  ASSIGN(clone->_parentBindingName,_parentBindingName);
  ASSIGN(clone->_keyPath,_keyPath);
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - parentBindingName=%@ negate:%d keyPath=%@>",
                   object_get_class_name(self),
                   (void*)self,
                   _parentBindingName,
                   _negate,
                   _keyPath];
};

//--------------------------------------------------------------------
-(BOOL)isImplementedForComponent:(GSWComponent*)component
{
  BOOL isImplemented=NO;
  isImplemented=(BOOL)[component hasBinding:_parentBindingName];

  return isImplemented;
};

//--------------------------------------------------------------------
-(id)valueInComponent:(GSWComponent*)component
{
  id value = [component valueForBinding:_parentBindingName];
  
  if ((_keyPath != nil) && (value != nil)) {
      value = [value valueForKeyPath:_keyPath];
  }
  return value;
}

//--------------------------------------------------------------------
-(void)setValue:(id)newValue
    inComponent:(GSWComponent*)component
{
  if (_keyPath != nil) {
    NSException * ex = nil;
    id value = [component valueForBinding:_parentBindingName];
    
    if (value != nil) {
      NS_DURING {
        [component validateTakeValue:newValue
                          forKeyPath:_keyPath];
      } NS_HANDLER {
        ex = localException;
      } NS_ENDHANDLER;
    }
    
    if ((ex != nil) && ([value isKindOfClass:[GSWComponent class]])) {
      [(GSWComponent*)value validationFailedWithException:ex
                                                    value:newValue
                                                  keyPath:_keyPath];
    }
  } else {
    [component setValue:newValue
             forBinding:_parentBindingName];
  }
}

- (void) _setValueNoValidation:(id) aValue inComponent:(GSWComponent*) component
{    
  if (_keyPath != nil) {
    id value = [component valueForBinding:_parentBindingName];

    if (value != nil) {
        [component takeValue:aValue
                          forKeyPath:_keyPath];
    }

  } else {
    GSWAssociation * association = [component _associationWithName:_parentBindingName];
    GSWComponent*    parent = nil;

    if (association == nil) {
      return;
    }

    parent = [component parent];
    if ([association isValueSettableInComponent:parent]) {
      [association _setValueNoValidation:aValue inComponent:parent];
    } else {
      [NSException raise:NSInvalidArgumentException 
                  format:@"%@: Cannot set value for binding '%@' -- corresponding association %@ is not settable.",
			 [parent name], _parentBindingName, association];
    }
  }
}    

//--------------------------------------------------------------------
-(BOOL)isValueConstant
{
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)isValueSettable
{
  return YES;
}

- (BOOL) isValueSettableInComponent:(GSWComponent*) component
{
  GSWAssociation * association = [component _associationWithName:_parentBindingName];
  BOOL yn = NO;

  if (association != nil) {
    yn = [association isValueSettableInComponent:[component parent]];
  }
  return yn;
}

- (BOOL) isValueConstantInComponent:(GSWComponent*) component
{
  GSWAssociation * association = [component _associationWithName:_parentBindingName];
  BOOL yn = NO;

  if (association != nil) {
    yn = [association isValueConstantInComponent:[component parent]];
  }
  return yn;
}

- (BOOL) _isImplementedForComponent:(GSWComponent*) component
{
  return ([component _associationWithName:_parentBindingName] != nil);
}

- (NSString*) keyPath
{
  return @"<none>";
}

- (NSString*) bindingInComponent:(GSWComponent*) component
{
  GSWComponent * parentcomp = [component parent];
  GSWAssociation * association = [component _associationWithName:_parentBindingName];
  
  if (association != nil) {
    return [association bindingInComponent:parentcomp];
  }
  return nil;
}

@end


