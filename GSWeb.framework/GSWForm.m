/** GSWForm.m - <title>GSWeb: Class GSWForm</title>

   Copyright (C) 1999-2005 Free Software Foundation, Inc.
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWForm

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWForm class])
    {
      standardClass=[GSWForm class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  GSWConstantValueAssociation * methodAssoc = nil;
  
  self = [super initWithName:@"form" associations:associations template:template];
  if (!self) {
    return nil;
  }
  
  DESTROY(_otherQueryAssociations);
  _otherQueryAssociations = RETAIN([_associations extractObjectsForKeysWithPrefix:@"?" removePrefix: YES]);

  if ((_otherQueryAssociations != nil) && ([_otherQueryAssociations count] == 0)) {
    DESTROY(_otherQueryAssociations);
  }
  ASSIGN(_action, [_associations objectForKey: action__Key]);
  if (_action != nil) {
    [_associations removeObjectForKey: action__Key];
  }
  ASSIGN(_href, [_associations objectForKey: href__Key]);
  if (_href != nil) {
    [_associations removeObjectForKey: href__Key];
  }  
  ASSIGN(_multipleSubmit, [_associations objectForKey: multipleSubmit__Key]);
  if (_multipleSubmit != nil) {
    [_associations removeObjectForKey: multipleSubmit__Key];
  }
  ASSIGN(_actionClass, [_associations objectForKey: actionClass__Key]);
  if (_actionClass != nil) {
    [_associations removeObjectForKey: actionClass__Key];
  }
  ASSIGN(_queryDictionary, [_associations objectForKey: queryDictionary__Key]);
  if (_queryDictionary != nil) {
    [_associations removeObjectForKey: queryDictionary__Key];
  }
  ASSIGN(_directActionName, [_associations objectForKey: directActionName__Key]);
  if (_directActionName != nil) {
    [_associations removeObjectForKey: directActionName__Key];
  }
  
  if ((([_associations objectForKey:method__Key] == nil) && 
      ([_associations objectForKey:@"Method"] == nil)) && 
      ([_associations objectForKey:@"METHOD"] == nil)) {

      methodAssoc = [[GSWConstantValueAssociation alloc] initWithValue:post__Key];
      [_associations setObject: methodAssoc
                      forKey:method__Key];
      DESTROY(methodAssoc);
  }
  if (((_action != nil) && (_href != nil)) || 
      ((_action != nil) && (_directActionName != nil)) || 
      ((_href != nil) && (_directActionName != nil)) || 
      ((_action != nil) && (_actionClass != nil)) || 
      ((_href != nil) && (_actionClass != nil))) {

     [NSException raise:NSInvalidArgumentException
             format:@"%s: At least two of these conflicting attributes are present: 'action', 'href', 'directActionName', 'actionClass'",
                                  __PRETTY_FUNCTION__];
   }
  if ((_action != nil) && ([_action isValueConstant])) {
     [NSException raise:NSInvalidArgumentException
             format:@"%s: 'action' is a constant.",
                                  __PRETTY_FUNCTION__];
    
  }
  return self;
}

-(void) dealloc
{
  DESTROY(_action);
  DESTROY(_href);
  DESTROY(_multipleSubmit);
  DESTROY(_actionClass);
  DESTROY(_queryDictionary);
  DESTROY(_otherQueryAssociations);
  DESTROY(_directActionName);

  [super dealloc];
}

-(id) description
{
  return [NSString stringWithFormat:@"<%s %p action: %@ actionClass: %@ directActionName: %@ href:%@ multipleSubmit: %@ queryDictionary: %@ otherQueryAssociations: %@ >",
                   object_get_class_name(self),
                   (void*)self, _action, _actionClass, _directActionName, _href, _multipleSubmit,
                   _queryDictionary, _otherQueryAssociations];
};


- (void) _enterFormInContext:(GSWContext *) context
{
  [context setInForm:YES];
  if ([[context elementID] isEqual:[context senderID]]) {
    [context _setFormSubmitted:YES];
  }
}

- (void) _exitFormInContext:(GSWContext *) context
{
  [context setInForm:NO];
  [context _setFormSubmitted:NO];
}

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context; 
{
  [self _enterFormInContext:context];
  [super takeValuesFromRequest:request
                     inContext:context];
  [self _exitFormInContext:context];  
}

-(GSWElement*)invokeActionForRequest:(GSWRequest*) request
                           inContext:(GSWContext*) context

{
  id  supervalue = nil;
  
  [self _enterFormInContext:context];
  [context _setActionInvoked:NO];
  [context _setIsMultipleSubmitForm:(_multipleSubmit == nil ? NO : [_multipleSubmit boolValueInComponent:[context component]])];
  
  supervalue = [super invokeActionForRequest:request inContext:context];
  if ((![context _wasActionInvoked]) && ([context _wasFormSubmitted])) {
    if (_action != nil) {
      supervalue = [_action valueInComponent:[context component]];
    }
    if (supervalue == nil) {
      supervalue = [context page];
    }
  }
  [context _setIsMultipleSubmitForm:NO];
  [self _exitFormInContext:context];
  
  return supervalue;
}

-(void) _appendHiddenFieldsToResponse:(GSWResponse*) response
                       inContext:(GSWContext*) context
{
  NSEnumerator * myEnumer = nil;
  NSString     * key = nil;
  NSString     * value = nil;
  NSDictionary * queryDict = [self computeQueryDictionaryWithActionClassAssociation: _actionClass
                                                        directActionNameAssociation: _directActionName
                                                         queryDictionaryAssociation: _queryDictionary
                                                             otherQueryAssociations: _otherQueryAssociations 
                                                                          inContext: context];
  if ([queryDict count] > 0) {
    myEnumer = [queryDict keyEnumerator];
    
    while ((key = [myEnumer nextObject])) {
      value = [queryDict objectForKey:key];
      GSWResponse_appendContentAsciiString(response,@"<input type=hidden");
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, name__Key, key, NO);  
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, value__Key, value, NO);
      GSWResponse_appendContentAsciiString(response,@">\n");
    }

  }
}

-(void) appendToResponse:(GSWResponse *) response
               inContext:(GSWContext*) context
{
  [context setInForm:YES];
  [super appendToResponse: response inContext: context];
  [context setInForm:NO];
}

-(void) appendChildrenToResponse:(GSWResponse *) response
                       inContext:(GSWContext*) context
{
  [super appendChildrenToResponse:response
                        inContext:context];

  [self _appendHiddenFieldsToResponse:response
                            inContext:context];
}

-(void) _appendCGIActionToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
  NSString *str = [self computeActionStringWithActionClassAssociation: _actionClass
                                          directActionNameAssociation: _directActionName
                                                            inContext: context];

  NSString * myActionURL = [context directActionURLForActionNamed: str
                                                  queryDictionary: nil];
                                                       
  
  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, action__Key, myActionURL, NO);
}

-(void) appendAttributesToResponse:(GSWResponse *) response 
                         inContext:(GSWContext*) context
{
  NSString     * value = nil;
  GSWComponent * component = [context component];

  [super appendAttributesToResponse:response inContext:context];
  if (_href != nil) {
    value = [_href valueInComponent:component];
  }
  if (_directActionName != nil || _actionClass != nil) {
    [self _appendCGIActionToResponse:response inContext: context];
  } else {
    if (value != nil) {
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, action__Key, value, NO);
    } else {
      if (_href == nil) {
        GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, 
                        action__Key, [context componentActionURL], NO);
      } else {
        NSLog(@"%s: action attribute evaluates to null. %@", __PRETTY_FUNCTION__, self);
      }
    }
  }
}

+(BOOL)hasGSWebObjectsAssociations
{
  return NO;
};

@end

