/** GSWHTMLBareString.m - <title>GSWeb: Class GSWHTMLBareString</title>

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

#include "GSWeb.h"

//====================================================================
@implementation GSWHTMLBareString


// we should ONLY support initWithString: ! dw
-(id)init
{
  [NSException raise:NSInvalidArgumentException
              format:@"%s: use initWithString: to init",
                          __PRETTY_FUNCTION__];

  return nil;                              
}

-(id)initWithString:(NSString*)aString
{
  if ((self=[super init]))
    {
      ASSIGN(_string,aString);
    };
  return self;
}

-(void)dealloc
{
  DESTROY(_string);
  [super dealloc];
}

-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - String:[%@]>",
                   object_getClassName(self),
                   (void*)self,
                   _string];
}

-(NSString*)string
{
  return _string;
}

-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  GSWResponse_appendContentString(aResponse,_string);  
}


+(id)elementWithString:(NSString*)aString
{
  return [[[GSWHTMLBareString alloc]initWithString:aString] autorelease];
}

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
}

-(id <GSWActionResults>)invokeActionForRequest:(GSWRequest*)request
                                    inContext:(GSWContext*)context
{

      [NSException raise:NSInvalidArgumentException
                  format:@"%s: A BareString does not have any brain to think about actions. You should avoid calling this method to save CPU cycles.",
                              __PRETTY_FUNCTION__];

  //Does Nothing
  return nil;
}

@end
