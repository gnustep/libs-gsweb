/** GSWForm.h - <title>GSWeb: Class GSWForm</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

#ifndef _GSWForm_h__
	#define _GSWForm_h__

//OK
@interface GSWForm: GSWHTMLDynamicElement
{
  GSWAssociation* _action;
  GSWAssociation* _href;
  GSWAssociation* _multipleSubmit;
  GSWAssociation* _actionClass;
  GSWAssociation* _directActionName;
  GSWAssociation* _queryDictionary;
//GSWeb Additions {
  GSWAssociation* _disabled;
  GSWAssociation* _enabled;
// }
  NSDictionary* _otherQueryAssociations;
};

-(id)description;
-(id)elementName;
-(void)dealloc;

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements;
@end


@interface GSWForm (GSWFormA)
#if !GSWEB_STRICT
-(BOOL)disabledInContext:(GSWContext*)context;
#endif
-(BOOL)compactHTMLTags;
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context;

-(void)_appendHiddenFieldsToResponse:(GSWResponse*)response
                           inContext:(GSWContext*)context;

-(NSDictionary*)computeQueryDictionaryInContext:(GSWContext*)context;
-(NSString*)computeActionStringInContext:(GSWContext*)context;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context;

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context; 
@end

@interface GSWForm (GSWFormB)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response
                                      inContext:(GSWContext*)context;

-(void)_appendCGIActionToResponse:(GSWResponse*)response
                        inContext:(GSWContext*)context;
@end

@interface GSWForm (GSWFormC)
+(BOOL)hasGSWebObjectsAssociations;
@end

#endif //_GSWForm_h__
