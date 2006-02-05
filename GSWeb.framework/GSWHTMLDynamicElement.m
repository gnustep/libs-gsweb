/** GSWHTMLDynamicElement.m - <title>GSWeb: Class GSWHTMLDynamicElement</title>

   Copyright (C) 1999-2005 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
   
   $Revision$
   $Date$
   $Id$
   
   <abstract></abstract>

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
#include "GSWPrivate.h"


static Class standardClass = Nil;
static Class NSStringClass = Nil;
static Class NSNumberClass = Nil;
static Class NSMutableDictionaryClass = Nil;
static Class GSCachedIntClass = Nil;
static NSMutableDictionary *  _urlAttributesTable = nil;

static inline BOOL _needQuote(NSString* str_needQuote)
{
 if ([str_needQuote isKindOfClass:NSStringClass] == NO) {
   return NO;
 } else {
  unsigned int mystrlen = [str_needQuote length];
  return (((mystrlen < 1) || ([str_needQuote hasPrefix:@"\""] == NO)) || ([str_needQuote hasSuffix:@"\""] == NO));
 }
}

//====================================================================
@implementation GSWHTMLDynamicElement

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWHTMLDynamicElement class])
    {
    if (!_urlAttributesTable) {
      _urlAttributesTable = [NSMutableDictionary new];
      [_urlAttributesTable setObject:@"href" forKey:@"a"];
      [_urlAttributesTable setObject:@"codebase" forKey:@"applet"];
      [_urlAttributesTable setObject:@"href" forKey:@"area"];
      [_urlAttributesTable setObject:@"src" forKey:@"bgsound"];
      [_urlAttributesTable setObject:@"href" forKey:@"base"];
      [_urlAttributesTable setObject:@"background" forKey:@"body"];
      [_urlAttributesTable setObject:@"src" forKey:@"embed"];
      [_urlAttributesTable setObject:@"action" forKey:@"form"];
      [_urlAttributesTable setObject:@"src" forKey:@"frame"];
      [_urlAttributesTable setObject:[NSArray arrayWithObjects:@"src",@"dynsrc",@"usemap",nil] 
                              forKey:@"img"];
      [_urlAttributesTable setObject:@"src" forKey:@"input"];
      [_urlAttributesTable setObject:@"href" forKey:@"link"];
      [_urlAttributesTable setObject:@"src" forKey:@"script"];
      
      NSStringClass = [NSString class];
      NSNumberClass = [NSNumber class];
      NSMutableDictionaryClass = [NSMutableDictionary class];
      GSCachedIntClass = NSClassFromString(@"GSCachedInt");
    }
    };
};

// returns string or array or nil.
+ (id) _urlAttributesForElementNamed:(NSString*) str
{
  id result = nil;
  if (str == nil) {
    return nil;
  } else {
    result = [_urlAttributesTable objectForKey:[str lowercaseString]];
    if (!result) {
      NSLog(@"%s:%@ %@ ", __PRETTY_FUNCTION__ , str, self);
    }
  }
  return result;
}


-(void) dealloc
{
  DESTROY(_elementName);
  DESTROY(_nonURLAttributeAssociations);
  DESTROY(_urlAttributeAssociations);
  DESTROY(_constantAttributesRepresentation);
  DESTROY(_associations);

  [super dealloc];
}


-(BOOL) escapeHTML
{
  return NO;
}

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  self = [super initWithName:nil
                associations:nil   
                   template: template];

  ASSIGN(_elementName, name);
  if (associations == nil) {
     [NSException raise:NSInvalidArgumentException
             format:@"%s: No associations",
                                  __PRETTY_FUNCTION__];
  }
  DESTROY(_associations);    
  _associations = [associations mutableCopyWithZone:nil];
  _finishedInitialization = NO;
                            
  return self;
}

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSMutableArray*) children
{

// I am not sure if this mehod should exist here at all. dave@turbocat.de

     [NSException raise:NSInvalidArgumentException
             format:@"%s: sure you want this?",
                                  __PRETTY_FUNCTION__];
//
//  self = [super initWithName:nil
//                associations:nil   
//             contentElements:children];
//
//  ASSIGN(_elementName, name);
//  if (associations == nil) {
//     [NSException raise:NSInvalidArgumentException
//             format:@"%s: No associations",
//                                  __PRETTY_FUNCTION__];
//  }
//  DESTROY(_associations);    
//  _associations = [associations mutableCopyWithZone:nil];
//  _finishedInitialization = NO;
//                           
  return self;
}


- (void) _finishInitialization
{
//lock for _finishedInitialization ?

  _nonURLAttributeAssociations = nil;
  _urlAttributeAssociations = nil;
  NSMutableString * buffer = [NSMutableString stringWithCapacity:256];
  NSString * str = nil;
  NSString * s1 = nil;
  GSWAssociation  * association = nil;
  id                aValue = nil;
  int i = 0;
  
  if ((_elementName != nil) && ((_associations != nil) && ([_associations count] > 0))) {
    NSEnumerator * enumer = [[NSArray arrayWithArray:[_associations allKeys]] objectEnumerator];

    while (str = [enumer nextObject]) {
      association = [_associations objectForKey: str];
      if (([association isKindOfClass:[GSWConstantValueAssociation class]]) && ([self escapeHTML] == NO)) {
        aValue = [association valueInComponent:nil];
        s1 = (aValue == nil) ? @"" : aValue;    // stringValue??
        if ([s1 isKindOfClass:NSStringClass] == NO) {
          s1 = [(NSNumber*)s1 stringValue];
        }
        if ([aValue isEqual:@"otherTagString"]) {
          [buffer appendString:@" "];
          [buffer appendString: s1];
        } else {
            [buffer appendString:@" "];
            [buffer appendString: str];
            [buffer appendString:@"="];
          if (_needQuote(s1) || ([s1 length] == 0)) {
            [buffer appendString:@"\""];
            [buffer appendString: s1];
            [buffer appendString:@"\""];
          } else {
            [buffer appendString: s1];
          }
        }
        [_associations removeObjectForKey:str];
      } else {
        id resultattribute = [[self class] _urlAttributesForElementNamed:_elementName];
        BOOL flag = NO;
        NSString * lowercaseString = [str lowercaseString];
        if (resultattribute != nil)
        {
        NSLog(@"resultattribute is %@ - %@", resultattribute, NSStringFromClass([resultattribute class]));
          if ([resultattribute isKindOfClass:NSStringClass] == NO) {
            int j = [resultattribute count];
            for (i = 0; ((i < j) && (!flag)); i++) {
              flag = [lowercaseString isEqual: [resultattribute objectAtIndex:i]];
            }
          } else {  // is a string
              flag = [lowercaseString isEqual: resultattribute];          
          }
        }
        if (flag) {
          if (_urlAttributeAssociations == nil)
          {
            _urlAttributeAssociations = [NSMutableDictionary new];
          }
          [_urlAttributeAssociations setObject:association forKey:str];
          [_associations removeObjectForKey:str];
        }
      }
    } // while 
    
    if ([_associations count] > 0) {
      ASSIGN(_nonURLAttributeAssociations, _associations);
    }
  }
  if ([buffer length] > 0) {
    ASSIGN(_constantAttributesRepresentation,buffer);
  } else {
    DESTROY(_constantAttributesRepresentation);
  }
  DESTROY(_associations);    
  _finishedInitialization = YES;
}

-(NSString*)description
{
  NSString * desStr = [NSString stringWithFormat:@"<%@ %p elementName:%@ ",
				   [self class],
				   (void*)self, _elementName];

  if (_constantAttributesRepresentation != nil) {
    desStr = [desStr stringByAppendingFormat:@" Constant Attributes: %@", _constantAttributesRepresentation];
  }
  if (_urlAttributeAssociations != nil) {
    desStr = [desStr stringByAppendingFormat:@" URL Dynamic Attributes: %@", _urlAttributeAssociations];
  }
  if (_nonURLAttributeAssociations != nil) {
    desStr = [desStr stringByAppendingFormat:@" non-URL Dynamic Attributes: %@", _nonURLAttributeAssociations];
  }
  if ([self hasChildrenElements]) {
    desStr = [desStr stringByAppendingFormat:@" Children: %@", [self childrenElements]];
  }
  desStr = [desStr stringByAppendingString:@" >"];

  return desStr;
}

- (NSString*) elementName
{
  return _elementName;
}

- (NSMutableDictionary*) urlAttributeAssociations
{
  if (!_finishedInitialization) {
    [self _finishInitialization];
  }
  return _urlAttributeAssociations;
}

- (NSMutableDictionary*) nonUrlAttributeAssociations
{
  if (!_finishedInitialization) {
    [self _finishInitialization];
  }
  return _nonURLAttributeAssociations;
}

- (NSString*) constantAttributesRepresentation
{
  if (!_finishedInitialization) {
    [self _finishInitialization];
  }
    return _constantAttributesRepresentation;
}

// _frameworkNameInComponent
- (NSString*) _frameworkNameForAssociation: (GSWAssociation*)association 
                               inComponent: (GSWComponent *) component
{
  NSString * s = nil;

  if (association != nil) {
    s = [association valueInComponent:component];
    if (s != nil) {
      if ([[s lowercaseString] isEqual:@"app"]) {
        s = nil;
      }
    } else {
      if (component != nil)
      {
        s = [component frameworkName];
      }
      [GSWApp debugWithFormat:@"%s evaluated to nil. Defaulting to %@",
                                __PRETTY_FUNCTION__,
                                (s != nil ? s : @"app")];
    }
  } else {
    if (component != nil) {
        s = [component frameworkName];
    }
  }
  return s;
}

// computeActionStringInContext in wo5
-(NSString*)computeActionStringWithActionClassAssociation:(GSWAssociation*)actionClass
                             directActionNameAssociation:(GSWAssociation*)directActionName
                                               inContext:(GSWContext*)context

{
  GSWComponent * component = GSWContext_component(context);
  id componentValue = nil;
  id directActionValue = nil;
  id resultString = nil;
  
  if (actionClass != nil) {
    componentValue = [actionClass valueInComponent: component];
    if ([componentValue isKindOfClass: NSStringClass] == NO) {

     [NSException raise:NSInvalidArgumentException
             format:@"%s: Value for attribute named '%@' must be a string.  Received '%@'.",
                                  __PRETTY_FUNCTION__, actionClass, componentValue];
    }
  }
  if (directActionName != nil)
  {
    directActionValue = [directActionName valueInComponent:component];
    if ([directActionValue isKindOfClass: NSStringClass] == NO) {

     [NSException raise:NSInvalidArgumentException
             format:@"%s: Value for attribute named '%@' must be a string.  Received '%@'.",
                                  __PRETTY_FUNCTION__, directActionName, directActionValue];
      
    }
  }
  
  if ((componentValue != nil) && (directActionValue != nil)) {
    if ([componentValue isEqual:@"DirectAction"]) {
      resultString = directActionValue;
    } else {
      resultString = [componentValue stringByAppendingString:@"/"];
      resultString = [resultString stringByAppendingString:directActionValue];
    }
  } else {
    if (componentValue != nil) {
      resultString = componentValue;
    } else {
      if (directActionValue != nil) {
        resultString = directActionValue;
      } else {
        [NSException raise:NSInternalInconsistencyException
          format:@"%s: Both 'actionClass' and 'directActionName' are either absent or evaluated to nil. Cannot generate dynamic url without an actionClass or directActionName.",
                               __PRETTY_FUNCTION__];
      }
    }
  }
  
  return resultString;
}


// computeQueryDictionaryInContext

- (NSDictionary*) computeQueryDictionaryWithActionClassAssociation: (GSWAssociation*)actionClass
                                       directActionNameAssociation: (GSWAssociation*)directActionName
                                        queryDictionaryAssociation: (GSWAssociation*)queryDictionary
                                            otherQueryAssociations: (NSDictionary*)otherQueryAssociations 
                                                         inContext: (GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  GSWSession   * session = [context _session];
  NSString * s = nil;
  NSMutableDictionary *nsmutabledictionary = nil;
  NSEnumerator  * keyEnumerator = nil;
  NSString * key = nil;
  GSWAssociation *otherAssociations = nil;
  id otherValue = nil;
  
  if (queryDictionary != nil) {
    NSDictionary * nsdictionary1 = [queryDictionary valueInComponent:component];
    if ([nsdictionary1 isKindOfClass:NSMutableDictionaryClass]) {
      nsmutabledictionary = nsdictionary1;
    } else {
      nsmutabledictionary = AUTORELEASE([nsdictionary1 mutableCopyWithZone:nil]);
    }
  }
  if (nsmutabledictionary == nil) {
    nsmutabledictionary = [NSMutableDictionary dictionary];
  }
  if (session != nil) {
    s = [session sessionID];
  } else {
    if ([context request] != nil) {
      s = [[context request] stringFormValueForKey:@"wosid"];
    }
  }
  if ((s != nil) && ((directActionName != nil) || (actionClass != nil)) && ((session == nil) || (![session storesIDsInCookies]) || ([session storesIDsInURLs]))) {
    [nsmutabledictionary setObject:s forKey:@"wosid"];
  }
  if (otherQueryAssociations != nil) {
    keyEnumerator = [otherQueryAssociations keyEnumerator];
    
    while (key = [keyEnumerator nextObject]) {
      otherAssociations = [otherQueryAssociations objectForKey:key];
      otherValue = [otherAssociations valueInComponent:component];
      if (otherValue != nil && ([key isEqual:@"wosid"] || ([otherValue boolValue] == YES))) {
        [nsmutabledictionary setObject: otherValue forKey:key];
      } else {
        [nsmutabledictionary removeObjectForKey:key];
      }
    }

  }
  return nsmutabledictionary;
}

-(void) appendConstantAttributesToResponse:(GSWResponse*) response
                                 inContext:(GSWContext*)aContext
{
  NSString * str = [self constantAttributesRepresentation];
  if (str != nil) {
    GSWResponse_appendContentString(response,str);
  }
}

-(void) _appendAttributesFromAssociationsToResponse:(GSWResponse*) response 
                                          inContext:(GSWContext*)context
                                       associations:(NSDictionary*) associations

{
  if ((associations != nil) && ([associations count] > 0)) {
    NSString * s1 = nil;
    NSEnumerator * enumer = [associations keyEnumerator];
    GSWComponent * component = GSWContext_component(context);
    NSString     * key = nil;
    GSWAssociation * currentAssociation = nil;
    id            obj = nil;
    
    while (key = [enumer nextObject]) {
      currentAssociation = [associations objectForKey:key];
      obj = [currentAssociation valueInComponent:component];
      if (obj != nil) {
//        s1 = [(NSNumber*) obj description];
// mr. ayers says that is not good..        
        if ([obj isKindOfClass:NSNumberClass] == YES) {
          s1 = [(NSNumber*) obj stringValue];
        }
        NSLog(@"%s:class %@ '%@'", __PRETTY_FUNCTION__, [obj class] , obj);
        if ([key isEqual:@"otherTagString"]) {
          GSWResponse_appendContentCharacter(response,' ');
          GSWResponse_appendContentString(response, s1);
        } else {        
          [response _appendTagAttribute: key
                                  value: s1
             escapingHTMLAttributeValue: NO];
        }
      }
    } // while
  }
}

-(void) appendNonURLAttributesToResponse:(GSWResponse*) response
                               inContext:(GSWContext*) context
  
{
  [self _appendAttributesFromAssociationsToResponse: response 
                                          inContext: context
                                       associations: [self nonUrlAttributeAssociations]];

}

-(void) appendURLAttributesToResponse:(GSWResponse*) response
                            inContext:(GSWContext*) context
{
  GSWComponent        * component = nil;
  NSMutableDictionary * attributeDict = [self urlAttributeAssociations];
  GSWAssociation      * association = nil;
  id                  value = nil;
  
  if ((attributeDict != nil) && ([attributeDict count] > 0)) {
    component = GSWContext_component(context);
    NSEnumerator * enumer = [attributeDict keyEnumerator];

    NSString * key = nil;

    NSString * s = nil;
    NSString * s1 = nil;
    
    while (key = [enumer nextObject]) {
      association = [attributeDict objectForKey:key];
      value = [association valueInComponent:component];
      if (value != nil) {
        // value to string??
        s1 = [context _urlForResourceNamed: value 
                       inFramework: nil];
      } else {
        [GSWApp debugWithFormat:@"%s evaluated to nil in component %@. Inserted nil resource in html tag.",
                                  __PRETTY_FUNCTION__, component];
      }
      if (s1 != nil) {
          [response _appendTagAttribute: key
                                  value: s1
             escapingHTMLAttributeValue: NO];
      } else {
        GSWResponse_appendContentCharacter(response,' ');
        GSWResponse_appendContentString(response, key);
        GSWResponse_appendContentAsciiString(response,@"=\"");
        GSWResponse_appendContentAsciiString(response, [component baseURL]);
        GSWResponse_appendContentCharacter(response,'/');
        GSWResponse_appendContentAsciiString(response, value);
        GSWResponse_appendContentCharacter(response,'"');
      }
    }
  }
}

-(void) appendAttributesToResponse:(GSWResponse *) response
                            inContext:(GSWContext*) context
{
  [self appendConstantAttributesToResponse: response 
                                 inContext: context];
                                 
  [self appendNonURLAttributesToResponse: response
                               inContext: context];

  [self appendURLAttributesToResponse: response
                            inContext: context];
}

-(void) _appendOpenTagToResponse:(GSWResponse *) response
                       inContext:(GSWContext*) context

{
  GSWResponse_appendContentCharacter(response,'<');
  GSWResponse_appendContentAsciiString(response, [self elementName]);
  [self appendAttributesToResponse:response inContext: context];
  GSWResponse_appendContentCharacter(response,'>');
}

-(void) _appendCloseTagToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
  GSWResponse_appendContentAsciiString(response, @"</");
  GSWResponse_appendContentAsciiString(response, [self elementName]);
  GSWResponse_appendContentCharacter(response,'>');
}

-(void) appendToResponse:(GSWResponse *) response
               inContext:(GSWContext*) context
{
  NSString * myElementName = nil;
  
  if (context == nil || response == nil) {
    return;
  }
  myElementName = [self elementName];
  if (myElementName != nil) {
    [self _appendOpenTagToResponse:response
               inContext: context];
  }

  [self appendChildrenToResponse: response
                       inContext: context];

  if (myElementName != nil) {
    [self _appendCloseTagToResponse:response
               inContext: context];    
  }
}


@end
