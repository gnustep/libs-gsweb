/** GSWBindingNameAssociation.m - <title>GSWeb: Class GSWBindingNameAssociation</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWBindingNameAssociation

//--------------------------------------------------------------------
-(id)initWithKeyPath:(NSString*)aKeyPath
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      NSArray* keys=nil;
      NSDebugMLLog(@"associations",@"aKeyPath=%@",aKeyPath);
      keys=[aKeyPath componentsSeparatedByString:@"."];
      if ([keys count]>0)
        {
          if (!WOStrictFlag && [aKeyPath hasPrefix:@"^"])
            {
              ASSIGNCOPY(_parentBindingName,[[keys objectAtIndex:0] stringWithoutPrefix:@"^"]);
            }
          else if (!WOStrictFlag && [aKeyPath hasPrefix:@"~"])
            {
              ASSIGNCOPY(_parentBindingName,[[keys objectAtIndex:0] stringWithoutPrefix:@"~"]);
              _isNonMandatory=YES; 
            };
          if ([keys count]>1)
            {
              ASSIGN(_keyPath,[[keys subarrayWithRange:NSMakeRange(1,[keys count]-1)]componentsJoinedByString:@"."]);
            };
        };
      NSDebugMLLog(@"associations",@"parentBindingName=%@",_parentBindingName);
      NSDebugMLLog(@"associations",@"keyPath=%@",_keyPath);
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_parentBindingName);
  DESTROY(_keyPath);
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone;
{
  GSWBindingNameAssociation* clone = [super copyWithZone:zone];
  ASSIGN(clone->_parentBindingName,_parentBindingName);
  ASSIGN(clone->_keyPath,_keyPath);
  _isNonMandatory=_isNonMandatory;
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - parentBindingName=%@ keyPath=%@>",
                   object_get_class_name(self),
                   (void*)self,
                   _parentBindingName,
                   _keyPath];
};

//--------------------------------------------------------------------
-(BOOL)isImplementedForComponent:(NSObject*)object
{
  BOOL isImplemented=NO;
  LOGObjectFnStart();
  isImplemented=(BOOL)[object hasBinding:_parentBindingName];
  LOGObjectFnStop();
  return isImplemented;
};

//--------------------------------------------------------------------
-(id)valueInObject:(id)object
{
  id value=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"associations",@"parentBindingName=%@",_parentBindingName);
  NSDebugMLLog(@"associations",@"keyPath=%@",_keyPath);
  NSDebugMLLog(@"associations",@"object=%@",object);
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
      NSDebugMLLog(@"associations",@"value=%@",value);
      if (value && _keyPath)
        {
          value=[GSWAssociation valueInObject:value
                                forKeyPath:_keyPath];
          NSDebugMLLog(@"associations",@"value=%@",value);
        };
    };
  NSDebugMLLog(@"associations",@"value=%@",value);
  [self logTakeValue:value];
  LOGObjectFnStop();
  return value;
};

//--------------------------------------------------------------------
-(void)setValue:(id)value
       inObject:(id)object
{
  LOGObjectFnStart();
  NSDebugMLLog(@"associations",@"parentBindingName=%@",_parentBindingName);
  NSDebugMLLog(@"associations",@"keyPath=%@",_keyPath);
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
                          inObject:tmpValue
                          forKeyPath:_keyPath];
        }
      else
        [object setValue:value
                forBinding:_parentBindingName];
    };
  [self logSetValue:value];
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

@end


