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


/*  
 * Private declarations of private methods in GSWeb.
 *
 * If you use them outside the GSW Framework you should keep in mind that they may
 * change any time. This is no public API and may be incompatible with any WebObjects
 * Version.
 *
 * Actually this is bad. We should have separate CLASSNAME_Private.h files
 */

#ifndef _GSWPrivate_h__
	#define _GSWPrivate_h__

#include "GSWDictionary.h"
#include "GSWComponentDefinition.h"
#include "GSWComponent.h"
#include "GSWApplication.h"
#include "GSWAssociation.h"
#include "GSWInput.h"
#include "GSWHyperlink.h"
#include "GSWImage.h"
#include "GSWContext.h"
#include "GSWSession.h"
#include "GSWMessage.h"
#include "GSWDefaultAdaptor.h"

GSWEB_EXPORT SEL gswAppendStringSEL;
GSWEB_EXPORT SEL gswObjectAtIndexSEL;

/** append string to object using appendString: impPtr.
If *impPtr is NULL, the method assign it **/
static inline void GSWeb_appendStringWithImpPtr(NSMutableString* object,IMP* impPtr,NSString* string)
{
  if (object && string)
    {
      if (!*impPtr)
	{
	  if (gswAppendStringSEL==NULL)
	    GSWInitializeAllMisc();
	  *impPtr=[object methodForSelector:gswAppendStringSEL];
	}
      (**impPtr)(object,gswAppendStringSEL,string);
    };
};

/** get object at index 
If *impPtr is NULL, the method assign it **/
static inline id GSWeb_objectAtIndexWithImpPtr(NSArray* array,IMP* impPtr,NSUInteger index)
{
  if (array)
    {
      if (!*impPtr)
	{
	  if (gswObjectAtIndexSEL==NULL)
	    GSWInitializeAllMisc();
	  *impPtr=[array methodForSelector:gswObjectAtIndexSEL];
	}
      return (**impPtr)(array,gswObjectAtIndexSEL,index);
    }
  else
    return nil;
};

@interface GSWComponentDefinition (PrivateDeclarations)

- (void) _checkInComponentInstance:(GSWComponent*) component;

- (void) finishInitializingComponent:(GSWComponent*)component;

- (void) _clearCache;

@end

@interface GSWComponent (PrivateDeclarations)

-(GSWComponent*) _subcomponentForElementWithID:(NSString*) str;

@end

@interface GSWApplication (PrivateDeclarations)

-(GSWComponentDefinition*) _componentDefinitionWithName:(NSString*)aName
                                              languages:(NSArray*)languages;

/* defaults */

+(void)_setLifebeatDestinationPort:(int)port;

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

@interface GSWHyperlink (PrivateDeclarations)

-(void) _appendQueryStringToResponse:(GSWResponse*) response
                           inContext:(GSWContext*) context
                  requestHandlerPath:(NSString*) aRequestHandlerPath
                       htmlEscapeURL:(BOOL) htmlEscapeURL;

@end

@interface GSWMessage (PrivateDeclarations)

-(void)_finalizeCookiesInContext:(GSWContext*)aContext;

@end

@interface GSWImage (PrivateDeclarations)

+ (void) _appendImageSizetoResponse:(GSWResponse *) response
                          inContext:(GSWContext *) context
                              width:(GSWAssociation *) width
                             height:(GSWAssociation *) height;

@end

@interface GSWContext (PrivateDeclarations)

- (GSWDynamicURLString*) _urlWithRequestHandlerKey:(NSString*) requestHandlerKey
                                requestHandlerPath:(NSString*) aRequestHandlerPath
                                       queryString:(NSString*) aQueryString
                                          isSecure:(BOOL) isSecure
                                              port:(int) somePort;


-(GSWDynamicURLString*) _directActionURLForActionNamed:(NSString*) anActionName
                                       queryDictionary:(NSDictionary*)queryDictionary
                                              isSecure:(BOOL)isSecure
                                                  port:(int)port
                                 escapeQueryDictionary:(BOOL)escapeQueryDict;

@end

@interface GSWSession (PrivateDeclarations)

-(void) _clearCookieFromResponse:(GSWResponse*) aResponse;

@end

@interface GSWDefaultAdaptor (PrivateDeclarations)

+(GSWResponse*) _lastDitchErrorResponse; 

@end

#endif // _GSWPrivate_h__
