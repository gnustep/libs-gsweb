/* GSWHTMLParserExt.m - GSWeb: Class GSWHTMLParser: Categories

   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Mar 1999
   
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

#include <gsweb/GSWeb.framework/GSWeb.h>

//====================================================================
@implementation GSWHTMLParser (GSWHTMLParserExt)

//--------------------------------------------------------------------
-(void)dealloc
{
//  GSWLogC("Dealloc GSWHTMLParser");
//  GSWLogC("Dealloc GSWHTMLParser: errors");
  DESTROY(errors);
//  GSWLogC("Dealloc GSWHTMLParser: warnings");
  DESTROY(warnings);
  [super dealloc];
//  GSWLogC("End Dealloc GSWHTMLParser");
};

//--------------------------------------------------------------------
-(void)reportErrorWithException:(NSException*)_exception
{
  NSString* _error=nil;
  if (!errors)
	errors=[NSMutableArray new];
  _error=[NSString stringWithFormat:@"Parsing Exception: %@ (Reason:%@)",
				   [_exception description],
				   [_exception reason]];
  [errors addObject:_error];
};

//--------------------------------------------------------------------
-(void)reportError:(NSString*)_text
{
  NSString* _error=nil;
  if (!errors)
	errors=[NSMutableArray new];
  _error=[NSString stringWithFormat:@"Parsing Error: %@",
				   _text];
  [errors addObject:_error];
};

//--------------------------------------------------------------------
-(void)reportWarning:(NSString*)_text
{
  NSString* _warning=nil;
  if (!warnings)
	warnings=[NSMutableArray new];
  _warning=[NSString stringWithFormat:@"Parsing Warning: %@",
				   _text];
  [warnings addObject:_warning];
};

//--------------------------------------------------------------------
-(BOOL)isError
{
  return ([errors count]>0);
};

//--------------------------------------------------------------------
-(BOOL)isWarning
{
  return ([warnings count]>0);
};

//--------------------------------------------------------------------
-(NSArray*)errors
{
  return errors;
};

//--------------------------------------------------------------------
-(NSArray*)warnings
{
  return warnings;
};

@end


