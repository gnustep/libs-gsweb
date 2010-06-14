/** GSWHTMLURLValuedElement.m - <title>GSWeb: Class GSWHTMLURLValuedElement</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Apr 1999
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

//====================================================================
@implementation GSWHTMLURLValuedElement

-(NSString*) valueAttributeName
{
    return @"src";
}

-(NSString*) urlAttributeName
{
  return @"value";
}

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  NSString* urlAttributeName=nil;
  NSString* valueAttributeName=nil;

  self=[super initWithName: aName
        associations:associations
            template:template];
  if (!self) {
    return nil;
  }              
  
  urlAttributeName = [self urlAttributeName];
  valueAttributeName = [self valueAttributeName];

  ASSIGN(_src, [_associations objectForKey: urlAttributeName]);
  if (_src != nil) {
    [_associations removeObjectForKey: urlAttributeName];
  }
  ASSIGN(_value, [_associations objectForKey: valueAttributeName]);
  if (_value != nil) {
    [_associations removeObjectForKey: valueAttributeName];
  }
  ASSIGN(_pageName, [_associations objectForKey: pageName__Key]);
  if (_pageName != nil) {
    [_associations removeObjectForKey: pageName__Key];
  }
  ASSIGN(_filename, [_associations objectForKey: filename__Key]);
  if (_filename != nil) {
    [_associations removeObjectForKey: filename__Key];
  }
  ASSIGN(_framework, [_associations objectForKey: framework__Key]);
  if (_framework != nil) {
    [_associations removeObjectForKey: framework__Key];
  }
  ASSIGN(_data, [_associations objectForKey: data__Key]);
  if (_data != nil) {
    [_associations removeObjectForKey: data__Key];
  }
  ASSIGN(_mimeType, [_associations objectForKey: mimeType__Key]);
  if (_mimeType != nil) {
    [_associations removeObjectForKey: mimeType__Key];
  }
  ASSIGN(_key, [_associations objectForKey: key__Key]);
  if (_key != nil) {
    [_associations removeObjectForKey: key__Key];
  }
  ASSIGN(_actionClass, [_associations objectForKey: actionClass__Key]);
  if (_actionClass != nil) {
    [_associations removeObjectForKey: actionClass__Key];
  }
  ASSIGN(_directActionName, [_associations objectForKey: directActionName__Key]);
  if (_directActionName != nil) {
    [_associations removeObjectForKey: directActionName__Key];
  }
  ASSIGN(_queryDictionary, [_associations objectForKey: queryDictionary__Key]);
  if (_queryDictionary != nil) {
    [_associations removeObjectForKey: queryDictionary__Key];
  }

  _otherQueryAssociations = RETAIN([_associations extractObjectsForKeysWithPrefix:@"?" 
                                                                     removePrefix: YES]);

  if (_filename != nil) {
    if ((_src != nil) || (_pageName != nil) || (_value != nil) || (_data != nil)) {
    
     [NSException raise:NSInvalidArgumentException
             format:@"%s: Can't have 'filename' and '%@', 'pageName', 'data', or '%@'.",
                                  __PRETTY_FUNCTION__, [self urlAttributeName], [self valueAttributeName]];
     }
  } else {
    if (_data != nil) {
      if (_src != nil || _pageName != nil || _value != nil) {
         [NSException raise:NSInvalidArgumentException
                 format:@"%s: Can't have 'data' and '%@', 'pageName', 'pageName', or '%@'.",
                                      __PRETTY_FUNCTION__, [self urlAttributeName], [self valueAttributeName]];      
      }
      if (_mimeType == nil) {
         [NSException raise:NSInvalidArgumentException
                 format:@"%s: Missing 'mimeType' when 'data' is specified.",
                                      __PRETTY_FUNCTION__];            
      }
    } else {
      if (((_pageName != nil) && (_src != nil)) || ((_pageName != nil) && (_value != nil)) || ((_src != nil) && (_value != nil))) {
         [NSException raise:NSInvalidArgumentException
                 format:@"%s: dynamic element can not have two conflicting bindings: 'pageName' and '%@', or  'pageName' and '%@', or 'pageName', or '%@' and '%@'.",
                                      __PRETTY_FUNCTION__, 
                                      [self urlAttributeName], 
                                      [self valueAttributeName],
                                      [self urlAttributeName], 
                                      [self valueAttributeName]];            
      
      }
      if (((_pageName == nil) && (_value == nil) && (_src == nil) && (_directActionName == nil)) && 
           ((_actionClass == nil) && (! [self isKindOfClass:[GSWBody class]]))) {

         [NSException raise:NSInvalidArgumentException
                 format:@"%s: At least one of the following bindings is required for this dynamic element: 'directActionName', 'actionClass', 'filename', 'pageName', 'data', '%@' or '%@'.",
                                      __PRETTY_FUNCTION__,[self urlAttributeName], 
                                      [self valueAttributeName]];            
      }
    }
  }

  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_src);
  DESTROY(_value);
  DESTROY(_pageName);
  DESTROY(_filename);
  DESTROY(_framework);
  DESTROY(_data);
  DESTROY(_mimeType);
  DESTROY(_key);
  DESTROY(_queryDictionary);
  DESTROY(_actionClass);
  DESTROY(_directActionName);
  DESTROY(_otherQueryAssociations);

  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_getClassName(self),
                   (void*)self];
};


//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)context
{
  GSWElement* element = nil;
  NSString* senderID = nil;
  NSString* elementID = nil;
  GSWComponent * component = nil;
  
  elementID = GSWContext_elementID(context);
  senderID = GSWContext_senderID(context);
  if (elementID != nil && senderID != nil && [elementID isEqual:senderID]) {
    component = GSWContext_component(context);
    if (_value != nil) {
      element = [_value valueInComponent:component];
    } else {
      if (_pageName != nil) {
        GSWElement* element1 = [_pageName valueInComponent:component];
        if (element1 != nil) {
          NSString * pageName = (NSString *) element1;    // stringValue?
          if (pageName != nil) {
             element = [GSWApp pageWithName:pageName inContext:context];
          }
        }
      }
    }
  } else {
    element = [super invokeActionForRequest: aRequest inContext: context];
  }
  return element;
};

- (NSString*) _imageURL:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);
  NSString * fname = [_filename valueInComponent: component];
  NSString * fwname =  [[self class] _frameworkNameForAssociation: _framework 
                                                      inComponent: component];
  NSString * url = [context _urlForResourceNamed: fname
                                    inFramework: fwname];
  
  if (url == nil) {
    url = [[GSWApp resourceManager] errorMessageUrlForResourceNamed:fname inFramework:fwname];
  }
  return url;
}

- (void) _appendFilenameToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
  NSString * myurl = [self _imageURL:context];

  [response _appendTagAttribute: [self urlAttributeName]
                          value: myurl
     escapingHTMLAttributeValue: NO];
  
}

- (NSString*) CGIActionURL:(GSWContext*) context
{

  NSString * actionString = [self computeActionStringWithActionClassAssociation: _actionClass
                                                    directActionNameAssociation: _directActionName
                                                                      inContext: context];

  NSDictionary * queryDict =  [self computeQueryDictionaryWithActionClassAssociation: _actionClass
                                                         directActionNameAssociation: _directActionName
                                                          queryDictionaryAssociation: _queryDictionary
                                                              otherQueryAssociations: _otherQueryAssociations 
                                                                           inContext: context];

  return [context directActionURLForActionNamed: actionString
                                     queryDictionary: queryDict];

}


- (void) appendAttributesToResponse:(GSWResponse*) response
                          inContext:(GSWContext*) context
{
  NSString           * src = nil;
  GSWComponent       * component = GSWContext_component(context);

  [super appendAttributesToResponse:response
                          inContext:context];

  if (_src != nil) {
    src = [_src valueInComponent:component];
  }
  if (_directActionName != nil || _actionClass != nil) {
    [response _appendTagAttribute:[self urlAttributeName]
                            value:[self CGIActionURL:context] 
       escapingHTMLAttributeValue:NO];
  } else {
    if (_filename != nil) {
      [self _appendFilenameToResponse:response inContext:context];
    } else {
      if (_value != nil || _pageName != nil) {      
        GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
                                                                      [self urlAttributeName],
                                                                      [context componentActionURL],
                                                                      NO);
      } else {
        if (src != nil) {
          if ([src isRelativeURL] && (![src isFragmentURL])) {
            NSString * s1 = [context _urlForResourceNamed: src 
                                              inFramework: nil];
            if (s1 != nil) {
              [response _appendTagAttribute: [self urlAttributeName]
                                      value: s1
                 escapingHTMLAttributeValue: NO];      
            } else {
              GSWResponse_appendContentCharacter(response,' ');
              GSWResponse_appendContentAsciiString(response, [self urlAttributeName]);
              GSWResponse_appendContentCharacter(response,'=');
              GSWResponse_appendContentCharacter(response,'"');
              GSWResponse_appendContentAsciiString(response, [component baseURL]);
              GSWResponse_appendContentCharacter(response,'/');
              GSWResponse_appendContentString(response,src);
              GSWResponse_appendContentCharacter(response,'"');
            }
          } else {
              GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
                                                                            [self urlAttributeName],
                                                                            src,
                                                                            NO);
          }
        } else
        if (_data != nil && _mimeType != nil)
        {
          // TODO call _appendDataURLAttributeToResponse
          [NSException raise:NSInvalidArgumentException
                  format:@"%s: you need to add a call to _appendDataURLAttributeToResponse in file '%s'",
                                       __PRETTY_FUNCTION__,__FILE__];
          
        }
      }
    }
  }
}

@end

