/** GSWHyperlink.m - <title>GSWeb: Class GSWHyperlink</title>

   Copyright (C) 2005-2006 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de> http://www.turbocat.de/
   Date: Jan 2006
   
   $Revision$
   $Date$
   
   $Revision$
   $Date$
   $Id$

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

// todo disabledInContext ??

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;
static Class NSStringClass = Nil;

//====================================================================
@implementation GSWHyperlink

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWHyperlink class])
    {
      standardClass=[GSWHyperlink class];
      NSStringClass = [NSString class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

-(void) dealloc
{
  DESTROY(_action);
  DESTROY(_string);
  DESTROY(_pageName);
  DESTROY(_href);
  DESTROY(_disabled);
  DESTROY(_fragmentIdentifier);
  DESTROY(_secure);
  DESTROY(_queryDictionary);
  DESTROY(_actionClass);
  DESTROY(_directActionName);
  DESTROY(_otherQueryAssociations);

  [super dealloc];
}

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  self = [super initWithName:@"a" associations:associations template:template];
  if (!self) {
    return nil;
  }

  DESTROY(_otherQueryAssociations);
  _otherQueryAssociations = RETAIN([_associations extractObjectsForKeysWithPrefix:@"?" removePrefix: YES]);

  _otherQueryAssociations = _otherQueryAssociations == nil || 
                               ([_otherQueryAssociations count] <= 0) ? nil : _otherQueryAssociations;

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
  ASSIGN(_string, [_associations objectForKey: string__Key]);
  if (_string != nil) {
    [_associations removeObjectForKey: string__Key];
  }  
  ASSIGN(_disabled, [_associations objectForKey: disabled__Key]);
  if (_disabled != nil) {
    [_associations removeObjectForKey: disabled__Key];
  }  
  ASSIGN(_queryDictionary, [_associations objectForKey: queryDictionary__Key]);
  if (_queryDictionary != nil) {
    [_associations removeObjectForKey: queryDictionary__Key];
  }  
  ASSIGN(_actionClass, [_associations objectForKey: actionClass__Key]);
  if (_actionClass != nil) {
    [_associations removeObjectForKey: actionClass__Key];
  }  
  ASSIGN(_directActionName, [_associations objectForKey: directActionName__Key]);
  if (_directActionName != nil) {
    [_associations removeObjectForKey: directActionName__Key];
  }  
  ASSIGN(_pageName, [_associations objectForKey: pageName__Key]);
  if (_pageName != nil) {
    [_associations removeObjectForKey: pageName__Key];
  }  
  ASSIGN(_secure, [_associations objectForKey: secure__Key]);
  if (_secure != nil) {
    [_associations removeObjectForKey: secure__Key];
  }  
  ASSIGN(_fragmentIdentifier, [_associations objectForKey: fragmentIdentifier__Key]);
  if (_fragmentIdentifier != nil) {
    [_associations removeObjectForKey: fragmentIdentifier__Key];
  }  

  if ((_action == nil) && (_href == nil) && (_pageName == nil) && 
      (_directActionName == nil) && (_actionClass == nil)) {
     
      [NSException raise:NSInvalidArgumentException
                  format:@"%s: Missing required attribute: 'action' or 'href' or 'pageName' or 'directActionName' or 'actionClass'",
                              __PRETTY_FUNCTION__];
  }
  if ((_action != nil) && (_href != nil) || (_action != nil) && (_pageName != nil) || 
      (_href != nil) && (_pageName != nil) || (_action != nil) && 
      (_directActionName != nil) || (_href != nil) && (_directActionName != nil) || (_pageName != nil) &&
      (_directActionName != nil) || (_action != nil) && (_actionClass != nil)) {

      [NSException raise:NSInvalidArgumentException
                  format:@"%s: At least two of these conflicting attributes are present: 'action', 'href', 'pageName', 'directActionName', 'actionClass'.",
                              __PRETTY_FUNCTION__];      
  }
  if ((_action != nil) && ([_action isValueConstant])) {
     [NSException raise:NSInvalidArgumentException
             format:@"%s: 'action' is a constant.",
                                  __PRETTY_FUNCTION__];
    
  }
  return self;
}

-(id) description
{
  return [NSString stringWithFormat:@"<%s %p action: %@ actionClass: %@ directActionName: %@ href:%@ string:%@   queryDictionary: %@ otherQueryAssociations: %@ pageName: %@ fragmentIdentifier:%@ disabled:%@ secure:%@ >",
                   object_get_class_name(self),
                   (void*)self, _action, _actionClass, _directActionName, _href,
                   _string,
                   _queryDictionary, _otherQueryAssociations, _pageName,
                   _fragmentIdentifier, _disabled, _secure];
};

// isDisabled in wo5
- (BOOL) isDisabledInContext:(GSWContext *) context
{
  return ((_disabled != nil) && ([_disabled boolValueInComponent: GSWContext_component(context)]));
}

-(GSWElement*)invokeActionForRequest:(GSWRequest*) request
                           inContext:(GSWContext*) context
{
  NSString * str = nil;
  id obj = nil;
  id value = nil;
  GSWComponent * component = GSWContext_component(context);
  
  if ([[context elementID] isEqual:[context senderID]]) {
    if ((_disabled == nil) || (![_disabled boolValueInComponent:component])) {
      if (_pageName != nil) {
        value = [_pageName valueInComponent:component];
        if (value != nil) {
          str = value; //stringValue;
        }
      }
      if (_action != nil) {
        obj = [_action valueInComponent:component];
      } else {
        if (_pageName == nil) {
         [NSException raise:NSInternalInconsistencyException
                 format:@"%s: Missing page name.", __PRETTY_FUNCTION__];
        }
        if (str != nil) {
          obj = [GSWApp pageWithName:str inContext:context];
        } else {
         // CHECKME: log page name? dave@turbocat.de
         [NSException raise:NSInternalInconsistencyException
                 format:@"%s: cannot find page.", __PRETTY_FUNCTION__];
          
        }
      }
    } else {
      #warning TODO GSWNoContentElement
      obj = nil;
    }
    if (obj == nil) {
      obj = [context page];
    }
  }
  return obj;
}

-(void) _appendOpenTagToResponse:(GSWResponse *) response
                       inContext:(GSWContext*) context
{
   if (! [self isDisabledInContext:context]) {
    [super _appendOpenTagToResponse:response
                          inContext:context];
  }
}

-(void) _appendCloseTagToResponse:(GSWResponse *) response
                        inContext:(GSWContext*) context
{
  if (! [self isDisabledInContext:context]) {
    [super _appendCloseTagToResponse:response
                           inContext:context];
  }
}

-(void) _appendQueryStringToResponse:(GSWResponse*) response
                           inContext:(GSWContext*) context
{
  NSString     * str = nil;
  NSDictionary * queryDict = [self computeQueryDictionaryWithActionClassAssociation: _actionClass
                                                        directActionNameAssociation: _directActionName
                                                         queryDictionaryAssociation: _queryDictionary
                                                             otherQueryAssociations: _otherQueryAssociations 
                                                                          inContext: context];
  
  if ((queryDict != nil) && ([queryDict count] > 0)) {
    str = [queryDict encodeAsCGIFormValues];
    GSWResponse_appendContentCharacter(response,'?');
    GSWResponse_appendContentHTMLAttributeValue(response, str);
  }
}

-(void) _appendFragmentToResponse:(GSWResponse*) response
                        inContext:(GSWContext*) context

{
  if (_fragmentIdentifier != nil) {
    id obj = [_fragmentIdentifier valueInComponent:GSWContext_component(context)];
    if (obj != nil) {
      GSWResponse_appendContentCharacter(response,'#');
      GSWResponse_appendContentString(response, obj);  // [obj stringValue] ??
    }
  }
}

-(void)_appendCGIActionURLToResponse:(GSWResponse*) response
                           inContext:(GSWContext*) context
{
  NSString * actionStr = [self computeActionStringWithActionClassAssociation: _actionClass
                                                 directActionNameAssociation: _directActionName
                                                                   inContext: context];
  
  NSDictionary * queryDict = [self computeQueryDictionaryWithActionClassAssociation: _actionClass
                                                        directActionNameAssociation: _directActionName
                                                         queryDictionaryAssociation: _queryDictionary
                                                             otherQueryAssociations: _otherQueryAssociations 
                                                                          inContext: context];
  NSString * urlString = nil;
  if (_secure != nil) {
    [context _generateCompleteURLs];
  }
  urlString = [context directActionURLForActionNamed: actionStr
                                     queryDictionary: queryDict];

  if (_secure != nil) {
    [context _generateRelativeURLs];
  }
  GSWResponse_appendContentString(response,urlString);

  [self _appendFragmentToResponse: response inContext:context];
}

-(void) appendAttributesToResponse:(GSWResponse *) response
                            inContext:(GSWContext*) context
{
  id obj = nil;
  id obj1 = nil;
  id obj3 = nil;
  id obj4 = nil;
  GSWComponent * component = GSWContext_component(context);
  BOOL securestuff = ((_secure != nil) && [_secure boolValueInComponent:component]);

  [super appendAttributesToResponse: response
                          inContext: context];
                            
  if (_href != nil) {
    obj = [_href valueInComponent:component];
  }
  if (_actionClass != nil || _directActionName != nil) {
    GSWResponse_appendContentCharacter(response,' ');
    GSWResponse_appendContentAsciiString(response, href__Key);
    GSWResponse_appendContentCharacter(response,'=');
    GSWResponse_appendContentCharacter(response,'"');

    [self _appendCGIActionURLToResponse:response
                              inContext:context];
    
    GSWResponse_appendContentCharacter(response,'"');
  } else {
    if (_action != nil || _pageName != nil) {
      GSWResponse_appendContentCharacter(response,' ');
      GSWResponse_appendContentAsciiString(response, href__Key);
      GSWResponse_appendContentCharacter(response,'=');
      GSWResponse_appendContentCharacter(response,'"');
      if (securestuff) {
        [context _generateCompleteURLs];
      }
      GSWResponse_appendContentString(response, 
                          [context _componentActionURL]);
  
      if (securestuff) {
        [context _generateRelativeURLs];
      }
      [self _appendQueryStringToResponse:response inContext: context];
      [self _appendFragmentToResponse: response inContext:context];
      GSWResponse_appendContentCharacter(response,'"');
    } else {
      if (obj != nil) {
        NSString * s1 = obj; //stringValue?
        GSWResponse_appendContentCharacter(response,' ');
        GSWResponse_appendContentAsciiString(response,href__Key);
        GSWResponse_appendContentCharacter(response,'=');
        GSWResponse_appendContentCharacter(response,'"');
        if ([s1 isRelativeURL] && (![s1 isFragmentURL])) {
          NSString * s = [context _urlForResourceNamed:s1 inFramework:nil];
          if (s != nil) {
            GSWResponse_appendContentString(response,s);
          } else {
            GSWResponse_appendContentAsciiString(response,[component baseURL]);
            GSWResponse_appendContentCharacter(response,'/');
            GSWResponse_appendContentString(response,s1);
          }
        } else {
          GSWResponse_appendContentString(response,s1);
        }
        [self _appendQueryStringToResponse:response inContext: context];
        [self _appendFragmentToResponse: response inContext:context];
        GSWResponse_appendContentCharacter(response,'"');
      } else {
        if (_fragmentIdentifier != nil) {
          id obj2 = [_fragmentIdentifier valueInComponent:component];
          if (obj2 != nil) {
            GSWResponse_appendContentCharacter(response,' ');
            GSWResponse_appendContentAsciiString(response,href__Key);
            GSWResponse_appendContentCharacter(response,'=');
            GSWResponse_appendContentCharacter(response,'"');
            [self _appendQueryStringToResponse:response inContext: context];
            GSWResponse_appendContentCharacter(response,'#');
            GSWResponse_appendContentString(response,obj2);    // stringValue?
            GSWResponse_appendContentCharacter(response,'"');
          }
        }
      }
    }
  }
}

-(void) appendContentStringToResponse:(GSWResponse *) response
                            inContext:(GSWContext*) context
{
  if (_string != nil) {
    id value = [_string valueInComponent:GSWContext_component(context)];
    if (value != nil) {
      if ([value isKindOfClass:NSStringClass]) {
        GSWResponse_appendContentString(response, value);  
      } else {      
        GSWResponse_appendContentString(response, [value description]);        
      }
    }
  }
}

-(void) appendChildrenToResponse:(GSWResponse *) response
                       inContext:(GSWContext*) context
{
  [super appendChildrenToResponse:response
                        inContext:context];

  [self appendContentStringToResponse:response
                            inContext:context];
}


@end
