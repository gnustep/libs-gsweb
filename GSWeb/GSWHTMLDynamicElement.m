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

#include "GSWeb.h"
#include "GSWPrivate.h"


//static Class standardClass = Nil;
static Class NSStringClass = Nil;
static Class NSNumberClass = Nil;
static Class NSMutableDictionaryClass = Nil;
static Class GSCachedIntClass = Nil;
static NSMutableDictionary *  _urlAttributesTable = nil;

static inline BOOL _needQuote(NSString* str_needQuote)
{
  unsigned int mystrlen = [str_needQuote length];
  return (mystrlen == 0
	  || [str_needQuote hasPrefix:@"\""] == NO
	  || [str_needQuote hasSuffix:@"\""] == NO);
}

//====================================================================
@implementation GSWHTMLDynamicElement

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWHTMLDynamicElement class])
    {
      if (!_urlAttributesTable)
	{
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

//--------------------------------------------------------------------
// returns string or array or nil.
+ (id) _urlAttributesForElementNamed:(NSString*) str
{
  id result = nil;
  if (str != nil)
    {
      result = [_urlAttributesTable objectForKey:[str lowercaseString]];
      if (!result)
	{
	  NSLog(@"%s:%@ %@ ", __PRETTY_FUNCTION__ , str, self);
	}
    }
  return result;
}

//--------------------------------------------------------------------
-(void) dealloc
{
  DESTROY(_dynElementName);
  DESTROY(_nonURLAttributeAssociations);
  DESTROY(_urlAttributeAssociations);
  DESTROY(_constantAttributesRepresentation);
  DESTROY(_associations);
  DESTROY(_secure);

  [super dealloc];
}


//--------------------------------------------------------------------
-(BOOL) escapeHTML
{
  return NO;
}

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  if ((self = [super initWithName:nil
		     associations:nil   
		     template: template]))
    {
      ASSIGN(_dynElementName, name);
      if (associations == nil)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: No associations",
		       __PRETTY_FUNCTION__];
	}
      DESTROY(_associations);
      _associations = [associations mutableCopyWithZone:[self zone]];
      _finishedInitialization = NO;
    }
  return self;
}

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSMutableArray*) children
{
  // I am not sure if this mehod should exist here at all. dave@turbocat.de
  [NSException raise:NSInvalidArgumentException
	       format:@"%s: sure you want this?",
	       __PRETTY_FUNCTION__];
  return self;
}


//--------------------------------------------------------------------
- (void) _finishInitialization
{
  if (!_finishedInitialization)
    {
      NSMutableString * buffer = nil;
      DESTROY(_nonURLAttributeAssociations);
      DESTROY(_urlAttributeAssociations);
      
      if (_dynElementName != nil
	  && [_associations count] > 0)
	{
	  IMP asIMP=NULL;
	  BOOL escapeHTML=[self escapeHTML];
	  NSEnumerator * enumer = [[NSArray arrayWithArray:[_associations allKeys]] objectEnumerator];
	  NSString* key = nil;
	  while ((key = [enumer nextObject]))
	    {
	      GSWAssociation* association = [_associations objectForKey: key];
	      if ([association isKindOfClass:[GSWConstantValueAssociation class]]
		  && !escapeHTML)
		{
		  NSString* aValue = [association valueInComponent:nil];
		  if (aValue == nil)
		    aValue = @"";
		  else
		    aValue = NSStringWithObject(aValue);
        
		  if (buffer==nil)
		    buffer=[NSMutableString stringWithCapacity:256];

		  if ([key isEqual:@"otherTagString"])
		    {
		      GSWeb_appendStringWithImpPtr(buffer,&asIMP,@" ");
		      GSWeb_appendStringWithImpPtr(buffer,&asIMP,aValue);
		    }
		  else
		    {
		      GSWeb_appendStringWithImpPtr(buffer,&asIMP,@" ");
		      GSWeb_appendStringWithImpPtr(buffer,&asIMP,key);
		      GSWeb_appendStringWithImpPtr(buffer,&asIMP,@"=");
		      if (_needQuote(aValue)
			  || [aValue length] == 0)
			{
			  GSWeb_appendStringWithImpPtr(buffer,&asIMP,@"\"");
			  GSWeb_appendStringWithImpPtr(buffer,&asIMP,aValue);
			  GSWeb_appendStringWithImpPtr(buffer,&asIMP,@"\"");
			}
		      else
			GSWeb_appendStringWithImpPtr(buffer,&asIMP,aValue);
		    }
		  [_associations removeObjectForKey:key];
		}
	      else
		{
		  id knowAttrKeys = [[self class] _urlAttributesForElementNamed:_dynElementName];
		  BOOL isKnowURLAttr = NO;
		  NSString * lcKey = [key lowercaseString];
		  if (knowAttrKeys != nil)
		    {
		      if ([knowAttrKeys isKindOfClass:NSStringClass])
			{
			  isKnowURLAttr = [lcKey isEqual: knowAttrKeys];
			}
		      else
			{  // an array
			  int c = [knowAttrKeys count];
			  int i = 0;
			  IMP oaiIMP=NULL;
			  for (i = 0;i<c && !isKnowURLAttr; i++)
			    {
			      isKnowURLAttr = [lcKey isEqual: GSWeb_objectAtIndexWithImpPtr(knowAttrKeys,&oaiIMP,i)];
			    }
			}
		    }
		  if (isKnowURLAttr)
		    {
		      if (_urlAttributeAssociations == nil)
			_urlAttributeAssociations = [NSMutableDictionary new];
		      [_urlAttributeAssociations setObject:association
						 forKey:lcKey];
		      [_associations removeObjectForKey:lcKey];
		    }
		}
	    } // while 
	  
	  if ([_associations count] > 0)
	    ASSIGN(_nonURLAttributeAssociations, _associations);
	}
      ASSIGN(_constantAttributesRepresentation,buffer);
      DESTROY(_associations);    
      _finishedInitialization = YES;
    }
}

//--------------------------------------------------------------------
-(NSString*)description
{
  NSString * desStr = [NSString stringWithFormat:@"<%@ %p elementName:%@ ",
				[self class],
				(void*)self, _dynElementName];

  if (_constantAttributesRepresentation != nil)
    desStr = [desStr stringByAppendingFormat:@" Constant Attributes: %@", _constantAttributesRepresentation];
  
  if (_urlAttributeAssociations != nil)
    desStr = [desStr stringByAppendingFormat:@" URL Dynamic Attributes: %@", _urlAttributeAssociations];
  
  if (_nonURLAttributeAssociations != nil)
    desStr = [desStr stringByAppendingFormat:@" non-URL Dynamic Attributes: %@", _nonURLAttributeAssociations];
  
  if ([self hasChildrenElements])
    desStr = [desStr stringByAppendingFormat:@" Children: %@", [self childrenElements]];
  
  desStr = [desStr stringByAppendingString:@" >"];

  return desStr;
}

//--------------------------------------------------------------------
- (NSString*) elementName
{
  return _dynElementName;
}

//--------------------------------------------------------------------
- (NSMutableDictionary*) urlAttributeAssociations
{
  if (!_finishedInitialization)
    [self _finishInitialization];
  return _urlAttributeAssociations;
}

//--------------------------------------------------------------------
- (NSMutableDictionary*) nonUrlAttributeAssociations
{
  if (!_finishedInitialization)
    [self _finishInitialization];
  return _nonURLAttributeAssociations;
}

//--------------------------------------------------------------------
- (NSString*) constantAttributesRepresentation
{
  if (!_finishedInitialization)
    [self _finishInitialization];
  
  return _constantAttributesRepresentation;
}

//--------------------------------------------------------------------
// _frameworkNameInComponent
+ (NSString*) _frameworkNameForAssociation: (GSWAssociation*)association 
                               inComponent: (GSWComponent *) component
{
  NSString *name = nil;

  if (association != nil)
    {
      name = [association valueInComponent:component];
      if (name)
	{
	  if ([@"app" caseInsensitiveCompare: name] == NSOrderedSame)
	    name = nil;
	}
      else
	{
	  if (component != nil)
	    name = [component frameworkName];

	  [GSWApp debugWithFormat:@"%s evaluated to nil. Defaulting to %@",
		  __PRETTY_FUNCTION__,
		  (name ? name : (NSString*) @"app")];
	}
    }
  else
    {
      if (component != nil)
	name = [component frameworkName];
    }
   return name;
}

// computeActionStringInContext in wo5
//--------------------------------------------------------------------
-(NSString*)computeActionStringWithActionClassAssociation:(GSWAssociation*)actionClass
                             directActionNameAssociation:(GSWAssociation*)directActionName
                                               inContext:(GSWContext*)context

{
  GSWComponent * component = GSWContext_component(context);
  NSString* actionClassValue = nil;
  NSString* directActionValue = nil;
  NSString* resultString = nil;
  
  if (actionClass != nil)
    {
      actionClassValue = [actionClass valueInComponent: component];
      if ([actionClassValue isKindOfClass: NSStringClass] == NO)
	{	  
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Value for attribute named '%@' must be a string.  Received '%@'.",
		       __PRETTY_FUNCTION__, actionClass, actionClassValue];
	}
    }
  if (directActionName != nil)
    {
      directActionValue = [directActionName valueInComponent:component];
      if ([directActionValue isKindOfClass: NSStringClass] == NO)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Value for attribute named '%@' must be a string.  Received '%@'.",
		       __PRETTY_FUNCTION__, directActionName, directActionValue];
	  
	}
    }
  
  if (actionClassValue != nil
      && directActionValue != nil)
    {
      if ([actionClassValue isEqual:@"DirectAction"])
	resultString = directActionValue;
      else
	{
	  resultString = [actionClassValue stringByAppendingString:@"/"];
	  resultString = [resultString stringByAppendingString:directActionValue];
	}
    }
  else if (actionClassValue != nil)
    resultString = actionClassValue;
  else if (directActionValue != nil)
    resultString = directActionValue;
  else
    {
      [NSException raise:NSInternalInconsistencyException
		   format:@"%s: Both 'actionClass' and 'directActionName' are either absent or evaluated to nil. Cannot generate dynamic url without an actionClass or directActionName.",
		   __PRETTY_FUNCTION__];
    }
  
  return resultString;
}


//--------------------------------------------------------------------
- (NSDictionary*) __queryDictionary:(GSWAssociation*) queryDictionary
                          inContext:(GSWContext*) context
{
  NSDictionary* aQueryDict = nil;

  if (queryDictionary != nil)
    aQueryDict = [queryDictionary valueInComponent:[context component]];
  
  if(aQueryDict != nil)
    return aQueryDict;
  else    
    return [NSDictionary dictionary]; // or a nil? -- dw
}

//--------------------------------------------------------------------
- (NSDictionary*) __otherQueryDictionary:(NSDictionary*) otherQueryAssociations
                               inContext:(GSWContext*) context
{
  NSMutableDictionary * queryDict = nil;
  
  if (otherQueryAssociations != nil)
    {
      NSEnumerator *keyEnumerator = [otherQueryAssociations keyEnumerator];
      NSString     *key = nil;
      
      while ((key = [keyEnumerator nextObject]))
	{
	  GSWAssociation * association = [otherQueryAssociations objectForKey:key];
	  id value = [association valueInComponent:[context component]];

	  if (value)
	    {
	      if (!queryDict)
		queryDict=[NSMutableDictionary dictionary];
	      [queryDict setObject:value
			 forKey:key];
	    }
	}
  }
  // is it really faster/better to copy this here? -- dw
  return (queryDict==nil ? [NSDictionary dictionary] : [NSDictionary dictionaryWithDictionary:queryDict]);
}


//--------------------------------------------------------------------
- (NSDictionary*) computeQueryDictionaryWithRequestHandlerPath: (NSString*) aRequestHandlerPath 
                                    queryDictionaryAssociation: (GSWAssociation*) queryDictionary
                                        otherQueryAssociations: (NSDictionary*) otherQueryAssociations 
                                                     inContext: (GSWContext*) context
{
  NSDictionary * aQueryDict = [self __queryDictionary:queryDictionary
                                            inContext: context];

  NSDictionary * anotherQueryDict = [self __otherQueryDictionary:otherQueryAssociations
                                                       inContext: context];

  return [context computeQueryDictionaryWithPath:aRequestHandlerPath
                                 queryDictionary:aQueryDict
                            otherQueryDictionary:anotherQueryDict];
}




//--------------------------------------------------------------------
- (NSDictionary*) computeQueryDictionaryWithActionClassAssociation: (GSWAssociation*)actionClass
                                       directActionNameAssociation: (GSWAssociation*)directActionName
                                        queryDictionaryAssociation: (GSWAssociation*)queryDictionary
                                            otherQueryAssociations: (NSDictionary*)otherQueryAssociations 
                                                         inContext: (GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  GSWSession   * session = [context _session];
  NSString * sessionID = nil;
  NSMutableDictionary *newQueryDictionary = nil;
  
  if (queryDictionary != nil)
    {
      NSDictionary * nsdictionary1 = [queryDictionary valueInComponent:component];
      if ([nsdictionary1 isKindOfClass:NSMutableDictionaryClass])
	newQueryDictionary = (NSMutableDictionary*) nsdictionary1;
      else
	newQueryDictionary = (NSMutableDictionary*) AUTORELEASE([nsdictionary1 mutableCopyWithZone:[self zone]]);
    }

  if (newQueryDictionary == nil)
    newQueryDictionary = [NSMutableDictionary dictionary];

  if (session != nil)
    sessionID = [session sessionID];
  else 
    {
      if ([context request] != nil)
	sessionID = [[context request] stringFormValueForKey:GSWKey_SessionID[GSWebNamingConv]];   
    }

  if (sessionID != nil
      && (directActionName != nil || actionClass != nil)
      && (session == nil || ![session storesIDsInCookies] || [session storesIDsInURLs])) 
    {
      [newQueryDictionary setObject:sessionID
			  forKey:GSWKey_SessionID[GSWebNamingConv]];
    }

  if (otherQueryAssociations != nil) 
    {
      NSString * key = nil;
      NSEnumerator* keyEnumerator = [otherQueryAssociations keyEnumerator];
    
      while ((key = [keyEnumerator nextObject]))
	{
	  GSWAssociation* otherAssociations = [otherQueryAssociations objectForKey:key];
	  id otherValue = [otherAssociations valueInComponent:component];
	  if (otherValue != nil)
	    {
	      if ([key isEqual:GSWKey_SessionID[GSWebNamingConv]]
		  || [key isEqual:[GSWApp sessionIdKey]])
		{
		  if (GSWIsBoolNumberNo(otherValue))
		    [newQueryDictionary removeObjectForKey:key];
		}
	      else
		{
		  [newQueryDictionary setObject: otherValue
				      forKey:key];
		}
	    } 
	  else 
	    {
	      [newQueryDictionary removeObjectForKey:key];
	    }
	}      
    }
  return newQueryDictionary;
}

//--------------------------------------------------------------------
//Used by childs like GSW(CheckBox|RadioButton)List to avoid calling 
//multiple time appendConstantAttributesToResponse: if there's nothing
//to do
-(BOOL)hasConstantAttributes
{
  return ([[self constantAttributesRepresentation] length]>0 ? YES : NO);
}

//--------------------------------------------------------------------
-(void) appendConstantAttributesToResponse:(GSWResponse*) response
                                 inContext:(GSWContext*)aContext
{
  NSString * str = [self constantAttributesRepresentation];
  if (str != nil)
    GSWResponse_appendContentString(response,str);
}

//--------------------------------------------------------------------
-(void) _appendAttributesFromAssociationsToResponse:(GSWResponse*) response 
                                          inContext:(GSWContext*)context
                                       associations:(NSDictionary*) associations

{
  if (associations != nil
      && [associations count] > 0)
    {
      NSEnumerator * enumer = [associations keyEnumerator];
      GSWComponent * component = GSWContext_component(context);
      NSString     * key = nil;
    
      while ((key = [enumer nextObject]))
	{
	  GSWAssociation* currentAssociation = [associations objectForKey:key];
	  NSString* value = [currentAssociation valueInComponent:component];
	  if (value != nil)
	    {
	      value=NSStringWithObject(value);
	      if ([key isEqual:@"otherTagString"])
		{
		  GSWResponse_appendContentCharacter(response,' ');
		  GSWResponse_appendContentString(response, value);
		}
	      else
		{ 
		  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,key,value,NO);
		}
	    }
	}
    }
}

//--------------------------------------------------------------------
//Used by childs like GSW(CheckBox|RadioButton)List to avoid calling 
//multiple time appendNonURLAttributesToResponse: if there's nothing
//to do
-(BOOL)hasNonURLAttributes
{
  return ([[self nonUrlAttributeAssociations] count]>0 ? YES : NO);
}

//--------------------------------------------------------------------
-(void) appendNonURLAttributesToResponse:(GSWResponse*) response
                               inContext:(GSWContext*) context
  
{
  [self _appendAttributesFromAssociationsToResponse: response 
                                          inContext: context
                                       associations: [self nonUrlAttributeAssociations]];

}

//--------------------------------------------------------------------
//Used by childs like GSW(CheckBox|RadioButton)List to avoid calling 
//multiple time appendURLAttributesToResponse: if there's nothing
//to do
-(BOOL)hasURLAttributes
{
  return ([[self urlAttributeAssociations] count]>0 ? YES : NO);
}

//--------------------------------------------------------------------
-(void) appendURLAttributesToResponse:(GSWResponse*) response
                            inContext:(GSWContext*) context
{
  NSMutableDictionary * attributeDict = [self urlAttributeAssociations];
  
  if ([attributeDict count] > 0)
    {
      GSWComponent* component = GSWContext_component(context);
      NSEnumerator* enumer = [attributeDict keyEnumerator];
      NSString * key = nil;

      while ((key = [enumer nextObject]))
	{
	  GSWAssociation* association = [attributeDict objectForKey:key];
	  NSString* value = NSStringWithObject([association valueInComponent:component]);
	  NSString* urlValue=nil;
	  if (value != nil)
	    {
	      urlValue = [context _urlForResourceNamed: value
				  inFramework: nil];
	    }
	  else
	    {
	      [GSWApp debugWithFormat:@"%s evaluated to nil in component %@. Inserted nil resource in html tag.",
		      __PRETTY_FUNCTION__, component];
	    }
	  if (urlValue != nil)
	    {
	      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,key,urlValue,NO);
	    }
	  else
	    {
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

//--------------------------------------------------------------------
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

//--------------------------------------------------------------------
-(void) _appendOpenTagToResponse:(GSWResponse *) response
                       inContext:(GSWContext*) context

{
  GSWResponse_appendContentCharacter(response,'<');
  GSWResponse_appendContentAsciiString(response, [self elementName]);
  [self appendAttributesToResponse:response
	inContext: context];
  GSWResponse_appendContentCharacter(response,'>');
}

//--------------------------------------------------------------------
-(void) _appendCloseTagToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
  GSWResponse_appendContentAsciiString(response, @"</");
  GSWResponse_appendContentAsciiString(response, [self elementName]);
  GSWResponse_appendContentCharacter(response,'>');
}

//--------------------------------------------------------------------
-(void) appendToResponse:(GSWResponse *) response
               inContext:(GSWContext*) context
{
  if (context != nil 
      && response != nil)
    {
      NSString * myElementName = [self elementName];
      if (myElementName != nil)
	{
	  [self _appendOpenTagToResponse:response
		inContext: context];
	}
      
      [self appendChildrenToResponse: response
	    inContext: context];

      if (myElementName != nil)
	{
	  [self _appendCloseTagToResponse:response
		inContext: context];    
	}
    }
}

//--------------------------------------------------------------------
- (BOOL) secureInContext:(GSWContext*) context
{
  if (_secure != nil)
    return [_secure boolValueInComponent:[context component]];
  else
    return [context secureMode];
}

@end
