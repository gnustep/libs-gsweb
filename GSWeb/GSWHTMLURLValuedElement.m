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

#include "GSWeb.h"

//====================================================================
@implementation GSWHTMLURLValuedElement

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  if ((self=[super initWithName: aName
		   associations:associations
		   template:template]))
    {  
      NSString* urlAttributeName = [self urlAttributeName];
      NSString* valueAttributeName = [self valueAttributeName];

      GSWAssignAndRemoveAssociation(&_src,_associations,urlAttributeName);
      GSWAssignAndRemoveAssociation(&_value,_associations,valueAttributeName);
      GSWAssignAndRemoveAssociation(&_pageName,_associations,pageName__Key);
      GSWAssignAndRemoveAssociation(&_filename,_associations,filename__Key);
      GSWAssignAndRemoveAssociation(&_framework,_associations,framework__Key);
      GSWAssignAndRemoveAssociation(&_data,_associations,data__Key);
      GSWAssignAndRemoveAssociation(&_mimeType,_associations,mimeType__Key);
      GSWAssignAndRemoveAssociation(&_key,_associations,key__Key);
      GSWAssignAndRemoveAssociation(&_queryDictionary,_associations,queryDictionary__Key);
      GSWAssignAndRemoveAssociation(&_actionClass,_associations,actionClass__Key);
      GSWAssignAndRemoveAssociation(&_directActionName,_associations,directActionName__Key);


      _otherQueryAssociations = RETAIN([_associations extractObjectsForKeysWithPrefix:@"?" 
						      removePrefix: YES]);

      if (_filename != nil)
	{
	  if (_src != nil
	      || _pageName != nil
	      || _value != nil
	      || _data != nil)
	    {	      
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: Can't have 'filename' and '%@', 'pageName', 'data', or '%@'.",
			   __PRETTY_FUNCTION__, [self urlAttributeName], [self valueAttributeName]];
	    }
	}
      else  if (_data != nil)
	{
	  if (_src != nil
	      || _pageName != nil
	      || _value != nil)
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: Can't have 'data' and '%@', 'pageName', 'pageName', or '%@'.",
			   __PRETTY_FUNCTION__, [self urlAttributeName], [self valueAttributeName]];      
	    }
	  if (_mimeType == nil)
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: Missing 'mimeType' when 'data' is specified.",
			   __PRETTY_FUNCTION__];            
	    }
	}
      else
	{
	  if ((_pageName != nil && _src != nil)
	      || (_pageName != nil && _value != nil)
	      || (_src != nil && _value != nil))
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: dynamic element can not have two conflicting bindings: 'pageName' and '%@', or  'pageName' and '%@', or 'pageName', or '%@' and '%@'.",
			   __PRETTY_FUNCTION__, 
			   [self urlAttributeName], 
			   [self valueAttributeName],
			   [self urlAttributeName], 
			   [self valueAttributeName]];            
	    }
	  if (_pageName == nil
	      && _value == nil 
	      && _src == nil 
	      && _directActionName == nil 
	      && _actionClass == nil
	      && ![self isKindOfClass:[GSWBody class]])
	    {
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
-(NSString*) valueAttributeName
{
    return @"src";
}

//--------------------------------------------------------------------
-(NSString*) urlAttributeName
{
  return @"value";
}

//--------------------------------------------------------------------
-(id <GSWActionResults>)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)context
{
  id <GSWActionResults> element = nil;

  NSString* elementID = GSWContext_elementID(context);
  NSString* senderID = GSWContext_senderID(context);
  
  if (elementID != nil
      && senderID != nil
      && [elementID isEqual:senderID])
    {
      GSWComponent* component = GSWContext_component(context);
      if (_value != nil)
	element = [_value valueInComponent:component];
      else if (_pageName != nil)
	{
	  NSString* pageName = NSStringWithObject([_pageName valueInComponent:component]);
	  if (pageName != nil)
	    {
	      element = [GSWApp pageWithName:pageName
				inContext:context];
	    }
	}
    }
  else
    {
      element = [super invokeActionForRequest: aRequest 
		       inContext: context];
    }
  return element;
};

//--------------------------------------------------------------------
- (NSString*) _imageURL:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);
  NSString * fname = [_filename valueInComponent: component];
  NSString * fwname =  [[self class] _frameworkNameForAssociation: _framework 
                                                      inComponent: component];
  NSString * url = [context _urlForResourceNamed: fname
                                    inFramework: fwname];
  
  if (url == nil)
    {
      url = [[GSWApp resourceManager] errorMessageUrlForResourceNamed:fname
				      inFramework:fwname];
    }
  return url;
}

//--------------------------------------------------------------------
- (void) _appendFilenameToResponse:(GSWResponse *) response
                         inContext:(GSWContext*) context
{
  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
								[self urlAttributeName],
								[self _imageURL:context],
								NO);
}

//--------------------------------------------------------------------
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


//--------------------------------------------------------------------
- (void) appendAttributesToResponse:(GSWResponse*) response
                          inContext:(GSWContext*) context
{
  [super appendAttributesToResponse:response
                          inContext:context];
  
  if (_directActionName != nil || _actionClass != nil)
    {
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
								    [self urlAttributeName],
								    [self CGIActionURL:context],
								    NO);
    }
  else if (_filename != nil)
    {
      [self _appendFilenameToResponse:response
	    inContext:context];
    }
  else if (_value != nil || _pageName != nil)
    {
      GSWComponent* component = GSWContext_component(context);
      BOOL secure = (_secure != nil ? [_secure boolValueInComponent:component] : NO);
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
								    [self urlAttributeName],
								    [context _componentActionURLIsSecure:secure],
								    NO);
    }
  else
    {
      GSWComponent* component = GSWContext_component(context);
      NSString* src=NSStringWithObject([_src valueInComponent:component]);
      if (src != nil)
	{
          if ([src isRelativeURL] 
	      && ![src isFragmentURL])
	    {
	      NSString* url = [context _urlForResourceNamed: src 
				       inFramework: nil];
	      if (url != nil)
		{
		  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
										[self urlAttributeName],
										url,
										NO);
		}
	      else 
		{
		  GSWResponse_appendContentCharacter(response,' ');
		  GSWResponse_appendContentAsciiString(response, [self urlAttributeName]);
		  GSWResponse_appendContentCharacter(response,'=');
		  GSWResponse_appendContentCharacter(response,'"');
		  GSWResponse_appendContentAsciiString(response, [component baseURL]);
		  GSWResponse_appendContentCharacter(response,'/');
		  GSWResponse_appendContentString(response,src);
		  GSWResponse_appendContentCharacter(response,'"');
		}
	    }
	  else
	    {
              GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
                                                                            [self urlAttributeName],
                                                                            src,
                                                                            NO);
	    }
        }
      else if (_data != nil && _mimeType != nil)
        {
	  [GSWURLValuedElementData _appendDataURLAttributeToResponse:response
				   inContext:context
				   key:_key
				   data:_data
				   mimeType:_mimeType
				   urlAttributeName:[self urlAttributeName]
				   inComponent:component];
        }
    }
}

@end

