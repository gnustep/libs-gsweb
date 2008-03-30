/** GSWPrivate.h - <title>GSWeb: Class GSWPrivate</title>

   Copyright (C) 2005 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Apr 2005
   
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

#ifndef _GSWPrivate_h__
	#define _GSWPrivate_h__


/** append string to object using appendString: impPtr.
If *impPtr is NULL, the method assign it **/
static inline void GSWeb_appendStringWithImpPtr(NSMutableString* object,IMP* impPtr,NSString* string)
{
  if (object && string)
    {
      if (!*impPtr)
        *impPtr=[object methodForSelector:@selector(appendString:)];
      (**impPtr)(object,@selector(appendString:),string);
    };
};

@interface GSWComponentDefinition (PrivateDeclarations)

- (void) _checkInComponentInstance:(GSWComponent*) component;

- (void) finishInitializingComponent:(GSWComponent*)component;

- (void) _clearCache;

@end

@interface GSWApplication (PrivateDeclarations)

-(GSWComponentDefinition*) _componentDefinitionWithName:(NSString*)aName
                                              languages:(NSArray*)languages;

@end

@interface GSWAssociation (PrivateDeclarations)

- (BOOL)_hasBindingInParent:(GSWComponent*) parent;

- (void) _setValueNoValidation:(id) aValue
                   inComponent:(GSWComponent*) component;

@end

@interface GSWInput (PrivateDeclarations)

- (void) _appendNameAttributeToResponse:(GSWResponse *) response
                              inContext:(GSWContext*)context;
@end

@interface GSWResponse (PrivateDeclarations)

- (void) _redirectResponse:(NSString *) location contentString:(NSString *) content;

@end


#endif // _GSWPrivate_h__
