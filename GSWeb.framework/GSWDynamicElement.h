/** GSWDynamicElement.h - <title>GSWeb: Class GSWDynamicElement</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

#ifndef _GSWDynamicElement_h__
	#define _GSWDynamicElement_h__

GSWEB_EXPORT SEL evaluateConditionInContextSEL;

//====================================================================
@interface GSWDynamicElement : GSWElement
{
};

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)template;

-(BOOL)		evaluateCondition:(id)condition
                        inContext:(GSWContext*)context
    noConditionAssociationDefault:(BOOL)noConditionAssociationDefault
               noConditionDefault:(BOOL)noConditionDefault;

-(BOOL)evaluateCondition:(id)condition
               inContext:(GSWContext*)context;
@end

static inline
BOOL GSWDynamicElement_evaluateValueInContext(GSWDynamicElement* element,Class standardClass,
                                              GSWIMP_BOOL imp,GSWAssociation* condition,GSWContext* context)
{
  if (imp && object_get_class(element)==standardClass)
    {
      return (*imp)(element,evaluateConditionInContextSEL,
                    condition,context);
    }
  else
    return [element evaluateCondition:condition
            inContext:context];
};


#endif //_GSWDynamicElement_h__
