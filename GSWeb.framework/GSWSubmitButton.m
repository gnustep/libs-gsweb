/** GSWSubmitButton.m - <title>GSWeb: Class GSWSubmitButton</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

//====================================================================
@implementation GSWSubmitButton

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  self = [super initWithName:@"input" associations:associations template: nil];
  if (!self) {
    return nil;
  }  
  if (_value == nil) {
    ASSIGN(_value, [[[GSWConstantValueAssociation alloc]initWithValue:@"Submit"] autorelease]);
  }
  ASSIGN(_action, [_associations objectForKey: action__Key]);
  if (_action != nil) {
    [_associations removeObjectForKey: action__Key];
  }
  ASSIGN(_actionClass, [_associations objectForKey: actionClass__Key]);
  if (_actionClass != nil) {
    [_associations removeObjectForKey: actionClass__Key];
  }
  ASSIGN(_directActionName, [_associations objectForKey: directActionName__Key]);
  if (_directActionName != nil) {
    [_associations removeObjectForKey: directActionName__Key];
  }
  
  if ((_action != nil) && ([_action isValueConstant])) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: 'action' attribute is a constant",
                            __PRETTY_FUNCTION__];  
  }
  if (((_action != nil) && (_directActionName != nil)) || ((_action != nil) && (_actionClass != nil))) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: Either 'action' and 'directActionName' both exist, or 'action' and 'actionClass' both exist",
                            __PRETTY_FUNCTION__];    
  }

  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_action);
  DESTROY(_actionClass);
  DESTROY(_directActionName);
  [super dealloc];
};

- (NSString*) type
{
  return @"submit";
}

-(id) description
{
  return [NSString stringWithFormat:@"<%s %p action: %@ actionClass: %@ directActionName:%@ disabled:%@ >",
                   object_getClassName(self),
                   (void*)self, _action, _actionClass, _directActionName,
                   _disabled];
};


//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext
{
  //Does Nothing!
}

-(GSWElement*)invokeActionForRequest:(GSWRequest*) request
                           inContext:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);
  id actionValue=nil;

  NS_DURING
  if ((! [self disabledInComponent: component]) && ([context _wasFormSubmitted])) {
    if ([context _isMultipleSubmitForm]) {    
      if ([request formValueForKey:[self nameInContext:context]] != nil) {
        [context _setActionInvoked:YES];
        if (_action != nil) {
          actionValue = [_action valueInComponent:component];
        }
        if (actionValue == nil) {
          actionValue = [context page];
        }
      }
    } else {
      [context _setActionInvoked:YES];
      if (_action != nil) {
         actionValue = [_action valueInComponent:component];
      }
      if (actionValue == nil) {
        actionValue = [context page];
      }
    }
  }
  NS_HANDLER
   localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"In GSWSubmitButton invokeActionForRequest:inContext");
   LOGException(@"exception=%@",localException);
   [localException raise];
  NS_ENDHANDLER

  return actionValue;
}

// PRIVATE used within dynamic elements
- (NSString*) _actionClassAndNameInContext:(GSWContext*) context
{
  NSString * s = [self computeActionStringWithActionClassAssociation: _actionClass
                              directActionNameAssociation: _directActionName
                                                inContext: context];
  
  return s; 
}

- (void) _appendNameAttributeToResponse:(GSWResponse*)response
                              inContext:(GSWContext*)context
{
  if ((_directActionName != nil) || (_actionClass != nil)) {
    [response _appendTagAttribute: name__Key
                            value: [self _actionClassAndNameInContext:context]
       escapingHTMLAttributeValue: NO];  
  } else {
    [super _appendNameAttributeToResponse:response
                              inContext: context];
  }
}

- (void) appendToResponse:(GSWResponse*)response
                inContext:(GSWContext*)context
{
  [super appendToResponse:response inContext:context];

  if ((_directActionName != nil) || (_actionClass != nil)) {
    GSWResponse_appendContentAsciiString(response,@"<input type=\"hidden\" name=\"WOSubmitAction\"");
    [response _appendTagAttribute: value__Key
                            value: [self _actionClassAndNameInContext:context]
       escapingHTMLAttributeValue: NO];  
    GSWResponse_appendContentCharacter(response,'>');
  }
}

-(void) _appendCloseTagToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
}

@end


