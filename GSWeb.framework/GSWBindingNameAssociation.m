/* GSWBindingNameAssociation.m - GSWeb: Class GSWBindingNameAssociation
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Apr 1999
   
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
@implementation GSWBindingNameAssociation

//--------------------------------------------------------------------
-(id)initWithKeyPath:(NSString*)keyPath_
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  NSArray* keys=nil;
	  NSDebugMLLog(@"associations",@"keyPath_=%@",keyPath_);
	  keys=[keyPath_ componentsSeparatedByString:@"."];
	  if ([keys count]>0)
		{
		  if (!WOStrictFlag && [keyPath_ hasPrefix:@"^"])
                    {
                      ASSIGNCOPY(parentBindingName,[[keys objectAtIndex:0] stringWithoutPrefix:@"^"]);
                    }
		  else if (!WOStrictFlag && [keyPath_ hasPrefix:@"~"])
                    {
                      ASSIGNCOPY(parentBindingName,[[keys objectAtIndex:0] stringWithoutPrefix:@"~"]);
                      isNonMandatory=YES; 
                    };
		  if ([keys count]>1)
			{
			  ASSIGN(keyPath,[[keys subarrayWithRange:NSMakeRange(1,[keys count]-1)]componentsJoinedByString:@"."]);
			};
		};
	  NSDebugMLLog(@"associations",@"parentBindingName=%@",parentBindingName);
	  NSDebugMLLog(@"associations",@"keyPath=%@",keyPath);
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(parentBindingName);
  DESTROY(keyPath);
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone;
{
  GSWBindingNameAssociation* clone = [super copyWithZone:zone];
  ASSIGN(clone->parentBindingName,parentBindingName);
  ASSIGN(clone->keyPath,keyPath);
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - parentBindingName=%@ keyPath=%@>",
				   object_get_class_name(self),
				   (void*)self,
				   parentBindingName,
				   keyPath];
};

//--------------------------------------------------------------------
-(BOOL)isImplementedForComponent:(NSObject*)object_
{
  BOOL _isImplemented=NO;
  LOGObjectFnStart();
  _isImplemented=[object_ hasBinding:parentBindingName];
  LOGObjectFnStop();
  return _isImplemented;
};

//--------------------------------------------------------------------
-(id)valueInObject:(id)object_
{
  id _value=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"associations",@"parentBindingName=%@",parentBindingName);
  NSDebugMLLog(@"associations",@"keyPath=%@",keyPath);
  NSDebugMLLog(@"associations",@"object_=%@",object_);
  if (object_)
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
	  _value=[object_ valueForBinding:parentBindingName];
	  NSDebugMLLog(@"associations",@"_value=%@",_value);
	  if (_value && keyPath)
		{
		  _value=[GSWAssociation valueInObject:_value
								 forKeyPath:keyPath];
		  NSDebugMLLog(@"associations",@"_value=%@",_value);
		};
	};
  NSDebugMLLog(@"associations",@"_value=%@",_value);
  [self logTakeValue:_value];
  LOGObjectFnStop();
  return _value;
};

//--------------------------------------------------------------------
-(void)setValue:(id)value_
	   inObject:(id)object_
{
  LOGObjectFnStart();
  NSDebugMLLog(@"associations",@"parentBindingName=%@",parentBindingName);
  NSDebugMLLog(@"associations",@"keyPath=%@",keyPath);
  if (object_)
	{
	  [object_ validateValue:&value_
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
	  if (keyPath)
		{
		  id tmpValue=[object_ valueForBinding:parentBindingName];
		  [GSWAssociation setValue:value_
						  inObject:tmpValue
						  forKeyPath:keyPath];
		}
	  else
		[object_ setValue:value_
				 forBinding:parentBindingName];
	};
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

@end


