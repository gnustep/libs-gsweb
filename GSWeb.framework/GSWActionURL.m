/* GSWActionURL.h - GSWeb: Class GSWActionURL
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Sep 1999
   
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

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWActionURL

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
		 template:(GSWElement*)template_
{
  IM_StartC("ActionURL");
  MDumpInputObject(name_);
  MDumpInputObject(associations_);
  MDumpInputObject(template_);
  self=[super initWithName:name_
			  associations:associations_
			  template:template_];
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
-(void)appendToResponse:(GSWResponse*)response_
				   inContext:(GSWContext*)context_
{
  IM_StartC("ActionURL");
  MDumpInputObject(response_);
  MDumpInputObject(context_);
  [super appendToResponse:response_
		 inContext:context_];
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

