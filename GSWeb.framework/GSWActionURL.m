/** GSWActionURL.m - <title>GSWeb: Class GSWActionURL</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Sep 1999
   
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
@implementation GSWActionURL

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  IM_StartC("ActionURL");
  MDumpInputObject(name);
  MDumpInputObject(associations);
  MDumpInputObject(template);
  if ((self=[super initWithName:name
                   associations:associations
                   template:template]))
    {
    };
  IM_StopC("ActionURL");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  id retValue=nil;
  IM_StartC("ActionURL");
  retValue=[super elementName];
  MDumpReturnObject(retValue);
  IM_StopC("ActionURL");
  return retValue;
};

@end

//====================================================================
@implementation GSWActionURL (GSWActionURLA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  IM_StartC("ActionURL");
  [super appendToResponse:response
		 inContext:context];
  IM_StopC("ActionURL");
};

//--------------------------------------------------------------------
+(BOOL)hasGSWebObjectsAssociations
{
  BOOL retValue=NO;
  CM_StartC("ActionURL");
  retValue=[[self superclass] hasWebObjectsAssociations];
  MDumpReturnUInt(retValue);
  CM_StopC("ActionURL");
  return retValue;
};

@end

