/** GSWParam.h - <title>GSWeb: Class GSWParam</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
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

#ifndef _GSWParam_h__
	#define _GSWParam_h__

//OK
//====================================================================
@interface GSWParam: GSWHTMLDynamicElement
{
  GSWAssociation* _action;
  GSWAssociation* _value;
  BOOL _treatNilValueAsGSWNull;
  id _target;
  NSString* _targetKey;
};

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
           target:(id)target
              key:(NSString*)key
treatNilValueAsGSWNull:(BOOL)treatNilValueAsGSWNull;

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements;

-(void)dealloc;

-(NSString*)description;
-(NSString*)elementName;

@end

//====================================================================
@interface GSWParam (GSWParamA)
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext;
@end

//====================================================================
@interface GSWParam (GSWParamB)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext;

-(id)valueInComponent:(id)component;
@end

//====================================================================
@interface GSWParam (GSWParamC)
+(BOOL)escapeHTML;
+(BOOL)hasGSWebObjectsAssociations;
@end


#endif //_GSWParam_h__
