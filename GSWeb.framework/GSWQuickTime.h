/** GSWQuickTime.h -  <title>GSWeb: Class GSWQuickTime</title>

   Copyright (C) 2000-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 200
   
   $Revision$
   $Date$
   
   <abstract></abstract>

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

// $Id$

#ifndef _GSWQuickTime_h__
	#define _GSWQuickTime_h__

//OK
//====================================================================
@interface GSWNestedList: GSWDynamicElement
{
  NSMutableDictionary* _associations;
  GSWAssociation* _src;
  GSWAssociation* _filename;
  GSWAssociation* _hotspotList;
  GSWAssociation* _framework;
  GSWAssociation* _width;
  GSWAssociation* _height;
  GSWAssociation* _action;
  GSWAssociation* _selection;
  GSWAssociation* _loop;
  GSWAssociation* _volume;
  GSWAssociation* _scale;
  GSWAssociation* _pluginsPage;
  GSWAssociation* _pluginsPageName;
  GSWAssociation* _href;
  GSWAssociation* _pageName;
  GSWAssociation* _bgcolor;
  GSWAssociation* _target;
  GSWAssociation* _pan;
  GSWAssociation* _tilt;
  GSWAssociation* _fov;
  GSWAssociation* _node;
  GSWAssociation* _correction;
  GSWAssociation* _cache;
  GSWAssociation* _autoplay;
  GSWAssociation* _autostart;
  GSWAssociation* _hidden;
  GSWAssociation* _playEveryFrame;
  GSWAssociation* _controller;
  GSWAssociation* _prefixHost;
};

-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext;
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext;
-(void)addHRefToResponse:(GSWResponse*)aResponse
               inContext:(GSWContext*)aContext;
-(id)_generateURL:(id)u;
-(id)_prefixedURL:(id)u
        inContext:(GSWContext*)aContext;
-(void)addToResponse:(GSWResponse*)aResponse
                 tag:(id)tag
               value:(id)value;
-(void)dealloc;
-(id)init;
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement;
-(BOOL)booleanValueOfBinding:(id)binding
                 inComponent:(id)component;
@end

#endif //_GSWQuickTime_h__
