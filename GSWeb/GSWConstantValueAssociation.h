/** GSWConstantValueAssociation.h - <title>GSWeb: Class GSWConstantValueAssociation</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 1999
   
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

#ifndef _GSWConstantValueAssociation_h__
	#define _GSWConstantValueAssociation_h__

//====================================================================
@interface GSWConstantValueAssociation:GSWAssociation
{
  id _value;
};

-(id)initWithValue:(id)aValue;
-(NSString*)debugDescription;
-(BOOL)isValueConstant;
-(BOOL)isValueSettable;
-(id)valueInComponent:(GSWComponent*)component;
-(void)setValue:(id)aValue
       inComponent:(GSWComponent*)component;

@end
#endif //GSWConstantValueAssociation
