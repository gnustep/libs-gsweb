/* GSWCollapsibleComponentContent.h - GSWeb: Class GSWCollapsibleComponentContent

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        Apr 1999
   
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

#ifndef _GSWCollapsibleComponentContent_h__
	#define _GSWCollapsibleComponentContent_h__


//==============================================================================
@interface GSWCollapsibleComponentContent: GSWComponent
{
  NSString* _tmpAnchorName;
  BOOL _isVisibleConditionPassed;
  BOOL _isVisible;
  NSString* _openedImageFileName;
  NSString* _closedImageFileName;
  NSString* _openedHelpString;
  NSString* _closedHelpString;
};

-(BOOL)isVisible;
-(GSWComponent*)toggleVisibilityAction;
-(NSString*)imageFileName;
-(id)label;
-(NSString*)helpString;
-(BOOL)isDisabled;
-(BOOL)shouldDisplay;

@end

#endif //_GSWCollapsibleComponentContent_h__
