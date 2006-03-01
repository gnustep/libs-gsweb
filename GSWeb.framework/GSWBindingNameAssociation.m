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
  //OK
  if ((self=[super init]))
    {
      NSArray* keys=nil;

      keys=[aKeyPath componentsSeparatedByString:@"."];
      if ([keys count]>0)
        {
          if (!WOStrictFlag && [aKeyPath hasPrefix:@"^"])
            {
              ASSIGNCOPY(_parentBindingName,[[keys objectAtIndex:0] stringByDeletingPrefix:@"^"]);
            }
          else if (!WOStrictFlag && [aKeyPath hasPrefix:@"~"])
            {
              ASSIGNCOPY(_parentBindingName,[[keys objectAtIndex:0] stringByDeletingPrefix:@"~"]);
            };
          if ([keys count]>1)
            {
              ASSIGN(_keyPath,[[keys subarrayWithRange:NSMakeRange(1,[keys count]-1)]componentsJoinedByString:@"."]);
            };
        };
    };

  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_parentBindingName);
  DESTROY(_keyPath);
  [super dealloc];
};

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
-(BOOL)isImplementedForComponent:(GSWComponent*)object
{
  BOOL isImplemented=NO;
  isImplemented=(BOOL)[object hasBinding:_parentBindingName];

  return isImplemented;
};

//--------------------------------------------------------------------
-(id)valueInComponent:(GSWComponent*)object
{
  id value=nil;

  if (object)
    {
      /*
        #if !GSWEB_STRICT
        if (!isNonMandatory)
        #endif
        {
        if (![self isImplementedForComponent:object_])
        {
        ExceptionRaise(NSGenericException,@"%@ is not implemented for object of class %@",
        self,
        [object_ class]);			  
        };
        };
      */
      value=[object valueForBinding:_parentBindingName];

      if (value && _keyPath)
        {
          value=[GSWAssociation valueInComponent:value
                                forKeyPath:_keyPath];
        };
    };
  [self logTakeValue:value];

  return value;
};

//--------------------------------------------------------------------
-(void)setValue:(id)value
       inComponent:(GSWComponent*)object
{
  if (object)
    {
      [object validateValue:&value
              forKey:self];
      /*
        #if !GSWEB_STRICT
        if (!isNonMandatory)
        #endif
        {
        if (![self isImplementedForComponent:object_])
        {
        ExceptionRaise(NSGenericException,@"%@ is not implemented for object of class %@",
        self,
        [object_ class]);			  
        };
        };
      */
      if (_keyPath)
        {
          id tmpValue=[object valueForBinding:_parentBindingName];
          [GSWAssociation setValue:value
                          inComponent:tmpValue
                          forKeyPath:_keyPath];
        }
      else
        [object setValue:value
                forBinding:_parentBindingName];
    };
  [self logSetValue:value];
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

@end


