/** GSWHTMLParserExt.m - <title>GSWeb: Class GSWHTMLParser: Categories</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 1999
   
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
-(void)reportErrorWithException:(NSException*)exception
{
  NSString* error=nil;
  if (!errors)
    errors=[NSMutableArray new];
  error=[NSString stringWithFormat:@"Parsing Exception: %@ (Reason:%@)",
                  [exception description],
                  [exception reason]];
  [errors addObject:error];
};

//--------------------------------------------------------------------
-(void)reportError:(NSString*)text
{
  NSString* error=nil;
  if (!errors)
    errors=[NSMutableArray new];
  error=[NSString stringWithFormat:@"Parsing Error: %@",
                  text];
  [errors addObject:error];
};

//--------------------------------------------------------------------
-(void)reportWarning:(NSString*)text
{
  NSString* warning=nil;
  if (!warnings)
    warnings=[NSMutableArray new];
  warning=[NSString stringWithFormat:@"Parsing Warning: %@",
                    text];
  [warnings addObject:warning];
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


