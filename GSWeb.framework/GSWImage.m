/** GSWImage.m - <title>GSWeb: Class GSWImage</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
   $Revision$
   $Date$
   $Id$

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

static const char rcsId[]="$Id$";

#include "GSWeb.h"

//====================================================================
@implementation GSWImage

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)inAssociations
  contentElements:(NSArray*)elements
{
  NSMutableDictionary* associations=nil;
  LOGObjectFnStartC("GSWImage");

  associations=[NSMutableDictionary dictionaryWithDictionary:inAssociations];

  _width = [[inAssociations objectForKey:width__Key
                          withDefaultObject:[_width autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"width=%@",_width);

  _height = [[inAssociations objectForKey:height__Key
                          withDefaultObject:[_height autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"height=%@",_height);

  [associations removeObjectForKey:width__Key];
  [associations removeObjectForKey:height__Key];

  if ((self=[super initWithName:name
                   associations:associations
                   contentElements:elements]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_width);
  DESTROY(_height);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)valueAttributeName
{
  return @"value";
};

//--------------------------------------------------------------------
-(NSString*)urlAttributeName
{
  return @"src";
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return @"IMG";
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_get_class_name(self),
                   (void*)self];
};


//--------------------------------------------------------------------
+(BOOL)hasGSWebObjectsAssociations
{
  return YES;
};

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response
                                      inContext:(GSWContext*)context
{
  //OK
  GSWComponent* component=nil;
  LOGObjectFnStartC("GSWImage");
  [super appendGSWebObjectsAssociationsToResponse:response
         inContext:context];
  if (_width || _height)
    {
      if (_width)
        {
          id width=[_width valueInComponent:component];
          [response _appendContentAsciiString:@" width=\""];
          [response appendContentHTMLString:width];
          [response appendContentCharacter:'"'];
        };
      if (_height)
        {
          id height=[_height valueInComponent:component];
          [response _appendContentAsciiString:@" height=\""];
          [response appendContentHTMLString:height];
          [response appendContentCharacter:'"'];
        };
    };
  LOGObjectFnStopC("GSWImage");
};

@end
