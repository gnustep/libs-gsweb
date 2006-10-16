/** GSWInput.h - <title>GSWeb: Class GSWInput</title>

   Copyright (C) 1999-2006 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
   Written by:	David Wetzel <dave@turbocat.de> http://www.turbocat.de/
   Date: Jan 2006
      
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

#ifndef _GSWInput_h__
	#define _GSWInput_h__


//====================================================================
@interface GSWInput: GSWHTMLDynamicElement
{
  GSWAssociation * _disabled;
  GSWAssociation * _name;
  GSWAssociation * _value;
  GSWAssociation * _escapeHTML;
}

+ (void) _appendImageSizetoResponse:(GSWResponse *) response
                          inContext:(GSWContext *) context
                              width:(GSWAssociation *) width
                             height:(GSWAssociation *) height;

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSMutableArray*) elements;

-(void)dealloc;

- (BOOL) disabledInComponent:(GSWComponent*) component;


/** Return the name for html output. 
If no name is binded, it return the context id **/
-(NSString*)nameInContext:(GSWContext*)context;


/** Return YES if element is disabled, NO otherwise, 
depending on disabled/enabled binding
**/
-(BOOL)disabledInContext:(GSWContext*)context;

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context; 


- (void) _appendNameAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*)context;


@end

#endif //GSWInput

