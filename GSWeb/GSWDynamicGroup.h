/** GSWHyperlink.h - <title>GSWeb: Class GSWHyperlink</title>

   Copyright (C) 2005-2006 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de>
   Date: Dec 2005
   
   $Revision: 1.17 $
   $Date: 2004/12/31 14:33:16 $

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

// $Id: GSWHyperlink.h,v 1.9 2005/04/24 11:56:45 mguesdon Exp $

#ifndef _GSWDynamicGroup_h__
	#define _GSWDynamicGroup_h__

#include "GSWDynamicElement.h"

@interface GSWDynamicGroup: GSWDynamicElement
{
  NSMutableArray * _children;
}


-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)template;
         

-(id)initWithName:(NSString*) name
     associations:(NSDictionary*) associations
  contentElements:(NSMutableArray*) children;

-(NSMutableArray*) childrenElements;

- (BOOL) hasChildrenElements;

-(void) takeChildrenValuesFromRequest:(GSWRequest*)request
			    inContext:(GSWContext*)aContext;

-(id <GSWActionResults>) invokeChildrenActionForRequest:(GSWRequest*)request
					      inContext:(GSWContext*)aContext;

-(void) appendChildrenToResponse:(GSWResponse*) response
                       inContext:(GSWContext*)aContext;

@end

#endif //_GSWDynamicGroup_h__

