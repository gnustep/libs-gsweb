/** GSWHTMLStaticGroup.m - <title>GSWeb: Class GSWHTMLStaticGroup</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
   
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

#include "GSWeb.h"

//====================================================================
@implementation GSWHTMLStaticGroup
-(id)initWithContentElements:(NSArray*)elements
{
  //OK
  LOGObjectFnStart();  
  NSDebugMLLog(@"gswdync",@"elements:%@",elements);
  if ([elements count]==1 && [[elements objectAtIndex:0] class]==[GSWHTMLStaticGroup class])
    self=[super initWithName:nil
                attributeDictionary:nil
                contentElements:[[elements objectAtIndex:0]dynamicChildren]];
  else
    self=[super initWithName:nil
                attributeDictionary:nil
                contentElements:elements];
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_documentTypeString);
  [super dealloc];
}

//--------------------------------------------------------------------
-(void)setDocumentTypeString:(NSString *)documentType
{
  ASSIGN(_documentTypeString,documentType);
}

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  LOGObjectFnStart();  
  GSWStartElement(context);
  if (_documentTypeString)
    {
      NSStringEncoding encoding=[response contentEncoding];      
      NSDebugMLLog(@"gswdync",@"added documentTypeString = %@",_documentTypeString);
      [response appendContentData:[_documentTypeString dataUsingEncoding:encoding]];
    };
  
  [super appendToResponse:response
         inContext:context];
  GSWStopElement(context);
  LOGObjectFnStop();  
};

@end
