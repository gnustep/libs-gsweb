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

//--------------------------------------------------------------------
-(void) dealloc
{
  DESTROY(_action);
  DESTROY(_string);
  DESTROY(_pageName);
  DESTROY(_href);
  DESTROY(_disabled);
  DESTROY(_fragmentIdentifier);
//  DESTROY(_secure);
  DESTROY(_queryDictionary);
  DESTROY(_actionClass);
  DESTROY(_directActionName);
  DESTROY(_otherQueryAssociations);

  [super dealloc];
}

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  if ((self = [super initWithName:@"a"
		     associations:associations
		     template:template]))
    {
      DESTROY(_otherQueryAssociations);
      _otherQueryAssociations = RETAIN([_associations extractObjectsForKeysWithPrefix:@"?" removePrefix: YES]);

      if ([_otherQueryAssociations count] == 0)
	DESTROY(_otherQueryAssociations);

      GSWAssignAndRemoveAssociation(&_action,_associations,action__Key);
      GSWAssignAndRemoveAssociation(&_string,_associations,string__Key);
      GSWAssignAndRemoveAssociation(&_href,_associations,href__Key);
      GSWAssignAndRemoveAssociation(&_disabled,_associations,disabled__Key);
      GSWAssignAndRemoveAssociation(&_queryDictionary,_associations,queryDictionary__Key);
      GSWAssignAndRemoveAssociation(&_actionClass,_associations,actionClass__Key);
      GSWAssignAndRemoveAssociation(&_directActionName,_associations,directActionName__Key);
      GSWAssignAndRemoveAssociation(&_pageName,_associations,pageName__Key);
      GSWAssignAndRemoveAssociation(&_fragmentIdentifier,_associations,fragmentIdentifier__Key);
      GSWAssignAndRemoveAssociation(&_secure,_associations,secure__Key);

      if (_action == nil
	  && _href == nil
	  && _pageName == nil
	  && _directActionName == nil
	  && _actionClass == nil)
	{     
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Missing required attribute: 'action' or 'href' or 'pageName' or 'directActionName' or 'actionClass'",
		       __PRETTY_FUNCTION__];
	}
      if ((_action != nil && _href != nil)
	  || (_action != nil && _pageName != nil)
	  || (_href != nil && _pageName != nil)
	  || (_action != nil && _directActionName != nil)
	  || (_href != nil && _directActionName != nil)
	  || (_pageName != nil && _directActionName != nil)
	  || (_action != nil && _actionClass != nil))
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: At least two of these conflicting attributes are present: 'action', 'href', 'pageName', 'directActionName', 'actionClass'.",
		       __PRETTY_FUNCTION__];      
	}
      if (_action != nil
	  && [_action isValueConstant])
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: 'action' is a constant.",
		       __PRETTY_FUNCTION__];
	}
    }
  return self;
}

//--------------------------------------------------------------------
-(id) description
{
  return [NSString stringWithFormat:@"<%s %p action: %@ actionClass: %@ directActionName: %@ href:%@ string:%@   queryDictionary: %@ otherQueryAssociations: %@ pageName: %@ fragmentIdentifier:%@ disabled:%@ secure:%@ >",
                   object_getClassName(self),
                   (void*)self, _action, _actionClass, _directActionName, _href,
                   _string,
                   _queryDictionary, _otherQueryAssociations, _pageName,
                   _fragmentIdentifier, _disabled, _secure];
};

//--------------------------------------------------------------------
// isDisabled in wo5
- (BOOL) isDisabledInContext:(GSWContext *) context
{
  return ((_disabled != nil) && ([_disabled boolValueInComponent: GSWContext_component(context)]));
}

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*) request
                           inContext:(GSWContext*) context
{
  GSWElement* result = nil;
  
  if ([[context elementID] isEqual:[context senderID]])
    {
      GSWComponent* component = GSWContext_component(context);
      if (_disabled == nil
	  || ![_disabled boolValueInComponent:component])
	{
	  NSString* pageName = nil;
	  if (_pageName != nil)
	    {
	      pageName = NSStringWithObject([_pageName valueInComponent:component]);
	    }
	  if (_action != nil)
	    {
	      result = [_action valueInComponent:component];
	    }
	  else
	    {
	      if (_pageName == nil)
		{
		  [NSException raise:NSInternalInconsistencyException
			       format:@"%s: Missing page name.", __PRETTY_FUNCTION__];
		}
	      if (pageName != nil)
		{
		  result = [GSWApp pageWithName:pageName
				   inContext:context];
		}
	      else
		{
		  // CHECKME: log page name? dave@turbocat.de
		  [NSException raise:NSInternalInconsistencyException
			       format:@"%s: cannot find page.", __PRETTY_FUNCTION__];
		  
		}
	    }
	}
      else
	{
	  //TODO GSWNoContentElement
	  result = nil;
	}
      if (result == nil)
	{
	  result = [context page];
	}
    }
  return result;
}

//--------------------------------------------------------------------
-(void) _appendOpenTagToResponse:(GSWResponse *) response
                       inContext:(GSWContext*) context
{
   if (![self isDisabledInContext:context])
     {
       [super _appendOpenTagToResponse:response
	      inContext:context];
     }
}

//--------------------------------------------------------------------
-(void) _appendCloseTagToResponse:(GSWResponse *) response
                        inContext:(GSWContext*) context
{
  if (![self isDisabledInContext:context])
    {
      [super _appendCloseTagToResponse:response
	     inContext:context];
    }
}

//--------------------------------------------------------------------
-(void) _appendQueryStringToResponse:(GSWResponse*) response
                           inContext:(GSWContext*) context
{
  GSOnceMLog(@"%s is deprecated, use _appendQueryStringToResponse: inContext: requestHandlerPath: htmlEscapeURL:", __PRETTY_FUNCTION__);
  
  NSDictionary * queryDict = [self computeQueryDictionaryWithActionClassAssociation: _actionClass
                                                        directActionNameAssociation: _directActionName
                                                         queryDictionaryAssociation: _queryDictionary
                                                             otherQueryAssociations: _otherQueryAssociations 
                                                                          inContext: context];
  
  if (queryDict != nil 
      && [queryDict count] > 0)
    {
      NSString* queryString = [queryDict encodeAsCGIFormValues];
      GSWResponse_appendContentCharacter(response,'?');
      GSWResponse_appendContentHTMLAttributeValue(response, queryString);
    }
}

//--------------------------------------------------------------------
-(void) _appendQueryStringToResponse:(GSWResponse*) response
                           inContext:(GSWContext*) context
                  requestHandlerPath: (NSString*) aRequestHandlerPath
                       htmlEscapeURL: (BOOL) htmlEscapeURL
{
  NSString     * path = (aRequestHandlerPath == nil ? @"" : aRequestHandlerPath);
  
  NSDictionary * queryDict = [self computeQueryDictionaryWithRequestHandlerPath: path
                                                     queryDictionaryAssociation: _queryDictionary
                                                         otherQueryAssociations: _otherQueryAssociations 
                                                                      inContext: context];
    
  if ([queryDict count] > 0) 
    {
      NSString* queryString = [queryDict encodeAsCGIFormValuesEscapeAmpersand:htmlEscapeURL];
      GSWResponse_appendContentCharacter(response,'?');
      GSWResponse_appendContentHTMLAttributeValue(response, queryString);
    }
}


//--------------------------------------------------------------------
-(void) _appendFragmentToResponse:(GSWResponse*) response
                        inContext:(GSWContext*) context

{
  if (_fragmentIdentifier != nil)
    {
      NSString* fragment = [_fragmentIdentifier valueInComponent:GSWContext_component(context)];
      if (fragment != nil)
	{
	  GSWResponse_appendContentCharacter(response,'#');
	  GSWResponse_appendContentString(response, NSStringWithObject(fragment));
	}
    }
}

//--------------------------------------------------------------------
-(void)_appendCGIActionURLToResponse:(GSWResponse*) response
                           inContext:(GSWContext*) context
{
  BOOL completeURLsOriginalState=NO;
  GSWComponent * component = GSWContext_component(context);
  BOOL securestuff = (_secure != nil ? [_secure boolValueInComponent:component] : NO);

  NSString * actionStr = [self computeActionStringWithActionClassAssociation: _actionClass
                                                 directActionNameAssociation: _directActionName
                                                                   inContext: context];
  
  NSDictionary * queryDict = [self computeQueryDictionaryWithActionClassAssociation: _actionClass
                                                        directActionNameAssociation: _directActionName
                                                         queryDictionaryAssociation: _queryDictionary
                                                             otherQueryAssociations: _otherQueryAssociations 
                                                                          inContext: context];
  NSString * urlString = nil;

  if (securestuff)
    completeURLsOriginalState=[context _generateCompleteURLs];

  urlString = [context directActionURLForActionNamed: actionStr
                                     queryDictionary: queryDict];

  if (securestuff
      && !completeURLsOriginalState)
    [context _generateRelativeURLs];

  GSWResponse_appendContentString(response,urlString);

  [self _appendFragmentToResponse: response
	inContext:context];
}

//--------------------------------------------------------------------
-(void) appendAttributesToResponse:(GSWResponse *) response
                            inContext:(GSWContext*) context
{
  [super appendAttributesToResponse: response
                          inContext: context];
                            
  if (_actionClass != nil || _directActionName != nil)
    {
      GSWResponse_appendContentCharacter(response,' ');
      GSWResponse_appendContentAsciiString(response, href__Key);
      GSWResponse_appendContentCharacter(response,'=');
      GSWResponse_appendContentCharacter(response,'"');

      [self _appendCGIActionURLToResponse:response
	    inContext:context];
      
      GSWResponse_appendContentCharacter(response,'"');
    }
  else if (_action != nil || _pageName != nil)
    {
      GSWComponent * component = GSWContext_component(context);
      BOOL secure = (_secure != nil ? [_secure boolValueInComponent:component] : NO);

      GSWResponse_appendContentCharacter(response,' ');
      GSWResponse_appendContentAsciiString(response, href__Key);
      GSWResponse_appendContentCharacter(response,'=');
      GSWResponse_appendContentCharacter(response,'"');

      GSWResponse_appendContentString(response, 
				      [context _componentActionURLIsSecure:secure]);
  
      [self _appendQueryStringToResponse:response 
                               inContext:context 
                      requestHandlerPath:nil
                           htmlEscapeURL:YES];
      
      [self _appendFragmentToResponse: response
	    inContext:context];

      GSWResponse_appendContentCharacter(response,'"');
    } 
  else if (_href != nil)
    {
      GSWComponent * component = GSWContext_component(context);
      NSString* hrefValue = [_href valueInComponent:component];

      if (hrefValue==nil)
	hrefValue=@"";
      else 
	hrefValue=NSStringWithObject(hrefValue);
	
      GSWResponse_appendContentCharacter(response,' ');
      GSWResponse_appendContentAsciiString(response,href__Key);
      GSWResponse_appendContentCharacter(response,'=');
      GSWResponse_appendContentCharacter(response,'"');

      if ([hrefValue isRelativeURL]
	  && ![hrefValue isFragmentURL])
	{
	  NSString * url = [context _urlForResourceNamed:hrefValue
				    inFramework:nil];
          if (url != nil)
            GSWResponse_appendContentString(response,url);
          else 
	    {
	      GSWResponse_appendContentAsciiString(response,[component baseURL]);
	      GSWResponse_appendContentCharacter(response,'/');
	      GSWResponse_appendContentString(response,hrefValue);
	    }
        } 
      else
	{
          GSWResponse_appendContentString(response,hrefValue);
        }

      [self _appendQueryStringToResponse:response 
	    inContext:context
	    requestHandlerPath:nil
	    htmlEscapeURL:YES];
      
      [self _appendFragmentToResponse: response
	    inContext:context];

      GSWResponse_appendContentCharacter(response,'"');
    }
  else if (_fragmentIdentifier != nil)
    {
      GSWComponent * component = GSWContext_component(context);
      id fragmentIdentifierValue = [_fragmentIdentifier valueInComponent:component];
      if (fragmentIdentifierValue != nil)
	{
	  GSWResponse_appendContentCharacter(response,' ');
	  GSWResponse_appendContentAsciiString(response,href__Key);
	  GSWResponse_appendContentCharacter(response,'=');
	  GSWResponse_appendContentCharacter(response,'"');
	  
	  [self _appendQueryStringToResponse:response 
		inContext:context
		requestHandlerPath:nil
		htmlEscapeURL:YES];
	  
	  GSWResponse_appendContentCharacter(response,'#');
	  GSWResponse_appendContentString(response,NSStringWithObject(fragmentIdentifierValue));
	  GSWResponse_appendContentCharacter(response,'"');
	}
    }
}

//--------------------------------------------------------------------
-(void) appendContentStringToResponse:(GSWResponse *) response
                            inContext:(GSWContext*) context
{
  if (_string != nil)
    {
      NSString* string = [_string valueInComponent:GSWContext_component(context)];
      if (string != nil)
        GSWResponse_appendContentString(response,NSStringWithObject(string));
    }
}

//--------------------------------------------------------------------
-(void) appendChildrenToResponse:(GSWResponse *) response
                       inContext:(GSWContext*) context
{
  [super appendChildrenToResponse:response
                        inContext:context];

  [self appendContentStringToResponse:response
                            inContext:context];
}


@end
