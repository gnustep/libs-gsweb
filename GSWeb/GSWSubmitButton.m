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

#include "GSWeb.h"

//====================================================================
@implementation GSWSubmitButton

static GSWAssociation* static_defaultValueAssociation = nil;

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWSubmitButton class])
    {
      if (!static_defaultValueAssociation)
	{
	  ASSIGN(static_defaultValueAssociation,([GSWAssociation associationWithValue:@"Submit"]));
	}
    }
}

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  if ((self = [super initWithName:@"input"
		     associations:associations
		     template: nil]))
    {
      if (_value == nil)
	ASSIGN(_value,static_defaultValueAssociation);
  
      GSWAssignAndRemoveAssociation(&_action,_associations,action__Key);
      GSWAssignAndRemoveAssociation(&_actionClass,_associations,actionClass__Key);
      GSWAssignAndRemoveAssociation(&_directActionName,_associations,directActionName__Key);
  
      if (_action != nil
	  && [_action isValueConstant])
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: 'action' attribute is a constant",
		       __PRETTY_FUNCTION__];  
	}
      if ((_action != nil && _directActionName != nil) 
	  || (_action != nil && _actionClass != nil))
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Either 'action' and 'directActionName' both exist, or 'action' and 'actionClass' both exist",
		       __PRETTY_FUNCTION__];    
	}
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

//--------------------------------------------------------------------
- (NSString*) type
{
  return @"submit";
}

//--------------------------------------------------------------------
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

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*) request
                           inContext:(GSWContext*) context
{
  id actionValue=nil;

  NS_DURING
    {
      GSWComponent * component = GSWContext_component(context);
      if (! [self disabledInComponent: component]
	  && [context _wasFormSubmitted])
	{
	  if ([context _isMultipleSubmitForm])
	    {
	      if ([request formValueForKey:[self nameInContext:context]] != nil)
		{
		  [context _setActionInvoked:YES];
		  if (_action != nil)
		    actionValue = [_action valueInComponent:component];
		  
		  if (actionValue == nil)
		    actionValue = [context page];
		}
	    }
	  else
	    {
	      [context _setActionInvoked:YES];
	      if (_action != nil)
		actionValue = [_action valueInComponent:component];
	      
	      if (actionValue == nil)
		actionValue = [context page];
	    }
	}
    }
  NS_HANDLER
    {
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
							      @"In GSWSubmitButton invokeActionForRequest:inContext");
      [localException raise];
    }
  NS_ENDHANDLER
  return actionValue;
}

//--------------------------------------------------------------------
// PRIVATE used within dynamic elements
- (NSString*) _actionClassAndNameInContext:(GSWContext*) context
{
  return [self computeActionStringWithActionClassAssociation: _actionClass
	       directActionNameAssociation: _directActionName
	       inContext: context];
}

//--------------------------------------------------------------------
- (void) _appendNameAttributeToResponse:(GSWResponse*)response
                              inContext:(GSWContext*)context
{
  if (_directActionName != nil
      || _actionClass != nil)
    {
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
								    name__Key,
								    [self _actionClassAndNameInContext:context],
								    NO);
    }
  else
    {
      [super _appendNameAttributeToResponse:response
	     inContext: context];
    }
}

//--------------------------------------------------------------------
- (void) appendToResponse:(GSWResponse*)response
                inContext:(GSWContext*)context
{
  [super appendToResponse:response inContext:context];

  if (_directActionName != nil
      || _actionClass != nil)
    {
      GSWResponse_appendContentAsciiString(response,@"<input type=\"hidden\" name=\"WOSubmitAction\"");
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
								    value__Key,
								    [self _actionClassAndNameInContext:context],
								    NO);
      GSWResponse_appendContentCharacter(response,'>');
    }
}

-(void) _appendCloseTagToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
}

@end


