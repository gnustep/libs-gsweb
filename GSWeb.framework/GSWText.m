/** GSWText.m - <title>GSWeb: Class GSWText</title>

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

RCS_ID("$Id$")

#include "GSWeb.h"

//====================================================================
@implementation GSWText

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  if ((self=[super initWithName:name
                   associations:associations
                   contentElements:nil]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_get_class_name(self),
                   (void*)self];
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return @"TEXTAREA";
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  //OK
  //GSWRequest* request=[aContext request];
  NSString* valueValue=nil;
  NSString* valueValueFiltered=nil;
  //not used BOOL isFromClientComponent=[request isFromClientComponent];
  GSWComponent* component=GSWContext_component(aContext);
  [super appendToResponse:aResponse
		 inContext:aContext];
  valueValue=[_value valueInComponent:component];
  valueValueFiltered=[self _filterSoftReturnsFromString:valueValue];
  GSWResponse_appendContentHTMLString(aResponse,valueValueFiltered);
  GSWResponse_appendContentAsciiString(aResponse,@"</TEXTAREA>");
};

//--------------------------------------------------------------------
// Replace \r\n by \n
-(NSString*)_filterSoftReturnsFromString:(NSString*)string
{
  NSRange range=[string rangeOfString:@"\r\n"];
  if (range.length>0)
    string=[string stringByReplacingString:@"\r\n"
                   withString:@"\n"];
  return string;
};

@end

//====================================================================
@implementation GSWText (GSWTextA)
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

@end
