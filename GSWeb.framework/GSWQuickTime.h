/* GSWQuickTime.h - GSWeb: Class GSWQuickTime
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 2000
   
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

// $Id$

#ifndef _GSWQuickTime_h__
	#define _GSWQuickTime_h__

//OK
//====================================================================
@interface GSWNestedList: GSWDynamicElement
{
  NSMutableDictionary* associations;
  GSWAssociation* src;
  GSWAssociation* filename;
  GSWAssociation* hotspotList;
  GSWAssociation* framework;
  GSWAssociation* width;
  GSWAssociation* height;
  GSWAssociation* action;
  GSWAssociation* selection;
  GSWAssociation* loop;
  GSWAssociation* volume;
  GSWAssociation* scale;
  GSWAssociation* pluginsPage;
  GSWAssociation* pluginsPageName;
  GSWAssociation* href;
  GSWAssociation* pageName;
  GSWAssociation* bgcolor;
  GSWAssociation* target;
  GSWAssociation* pan;
  GSWAssociation* tilt;
  GSWAssociation* fov;
  GSWAssociation* node;
  GSWAssociation* correction;
  GSWAssociation* cache;
  GSWAssociation* autoplay;
  GSWAssociation* autostart;
  GSWAssociation* hidden;
  GSWAssociation* playEveryFrame;
  GSWAssociation* controller;
  GSWAssociation* prefixHost;
};

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						   inContext:(GSWContext*)context_;
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;
-(void)addHRefToResponse:(GSWResponse*)response_
			   inContext:(GSWContext*)context_;
-(id)_generateURL:(id)u;
-(id)_prefixedURL:(id)u
		inContext:(GSWContext*)context_;
-(void)addToResponse:(GSWResponse*)response_
				 tag:(id)tag_
			   value:(id)value_;
-(void)dealloc;
-(id)init;
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
		 template:(GSWElement*)templateElement_;
-(BOOL)booleanValueOfBinding:(id)binding_
				 inComponent:(id)component_;
@end

#endif //_GSWQuickTime_h__
