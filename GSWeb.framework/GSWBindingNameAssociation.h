/** GSWBindingNameAssociation.h - <title>GSWeb: Class GSWBindingNameAssociation</title>

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

// $Id$

#ifndef _GSWBindingNameAssociation_h__
	#define _GSWBindingNameAssociation_h__

//====================================================================
@interface GSWBindingNameAssociation : GSWAssociation
{
  NSString* _parentBindingName;
  NSString* _keyPath;
};

-(id)initWithKeyPath:(NSString*)keyPath;

-(BOOL)isImplementedForComponent:(GSWComponent*)object;
-(BOOL)isValueConstant;
-(BOOL)isValueSettable;
-(id)valueInComponent:(GSWComponent*)component;
-(void)setValue:(id)value
    inComponent:(GSWComponent*)component;
@end

#endif //_GSWBindingNameAssociation_h__



