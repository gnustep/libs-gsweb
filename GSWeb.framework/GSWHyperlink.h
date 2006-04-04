/** GSWHyperlink.h - <title>GSWeb: Class GSWHyperlink</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        Jan 1999
   
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

// $Id$

#ifndef _GSWHyperlink_h__
	#define _GSWHyperlink_h__


@interface GSWHyperlink: GSWHTMLDynamicElement
{
  GSWAssociation * _action;
  GSWAssociation * _string;
  GSWAssociation * _pageName;
  GSWAssociation * _href;
  GSWAssociation * _disabled;
  GSWAssociation * _fragmentIdentifier;
  GSWAssociation * _secure;
  GSWAssociation * _queryDictionary;
  GSWAssociation * _actionClass;
  GSWAssociation * _directActionName;
  NSDictionary  * _otherQueryAssociations;
};

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement;

-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext;

-(void)_appendCGIActionURLToResponse:(GSWResponse*)aResponse
                           inContext:(GSWContext*)aContext;

-(NSString*)computeActionStringInContext:(GSWContext*)aContext;

-(void)_appendQueryStringToResponse:(GSWResponse*)aResponse
                          inContext:(GSWContext*)aContext;

-(NSDictionary*)computeQueryDictionaryInContext:(GSWContext*)aContext;

-(void)_appendFragmentToResponse:(GSWResponse*)aResponse
                       inContext:(GSWContext*)aContext;

-(void)_appendContentStringToResponse:(GSWResponse*)aResponse
                            inContext:(GSWContext*)aContext;

-(void)_appendChildrenToResponse:(GSWResponse*)aResponse
                       inContext:(GSWContext*)aContext;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext;
@end

#endif //_GSWHyperlink_h__
