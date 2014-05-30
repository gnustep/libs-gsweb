/** GSWActiveImage.m - <title>GSWeb: Class GSWActiveImage</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$
   
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


static NSString * static_sessionIDKey = nil;
static NSString * static_tempQueryKey = nil; 
static GSWAssociation * static_defaultBorderAssociation = nil;

@implementation GSWActiveImage

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWActiveImage class])
    {
      if (!static_sessionIDKey)
	{
	  ASSIGN(static_sessionIDKey,([GSWApp sessionIdKey]));
	  ASSIGN(static_tempQueryKey,([@"?" stringByAppendingString:static_sessionIDKey]));
	  ASSIGN(static_defaultBorderAssociation,([GSWAssociation associationWithValue:@"0"]));
	}
    }
}


//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  NSMutableDictionary * tempQueryAssociations = [NSMutableDictionary dictionary];
  GSWAssociation      * tempAssociation = nil;

  if ((self = [super initWithName:@"input"
		    associations:associations
		    template: nil]))
    {
      tempAssociation = [_associations objectForKey:static_tempQueryKey];
      if (tempAssociation != nil)
	{
	  [tempQueryAssociations setObject:tempAssociation
				 forKey:static_sessionIDKey];
	  [_associations removeObjectForKey: static_tempQueryKey];
	}
      
      if ([static_sessionIDKey isEqualToString:GSWKey_SessionID[GSWebNamingConv]] == NO)
	{
	  tempAssociation = [_associations objectForKey:GSWKey_QuestionMarkSessionID[GSWebNamingConv]];
	  if (tempAssociation != nil)
	    {
	      [tempQueryAssociations setObject:tempAssociation
				     forKey:GSWKey_SessionID[GSWebNamingConv]];
	      [_associations removeObjectForKey:GSWKey_QuestionMarkSessionID[GSWebNamingConv]];
	    }
	}
      
      if ([tempQueryAssociations count] > 0)
	{
	  _sessionIDQueryAssociations = [tempQueryAssociations retain];
	}
      else
	{
	  DESTROY(_sessionIDQueryAssociations);
	}
      
      GSWAssignAndRemoveAssociation(&_file,_associations,imageMapFileName__Key);
      
      if (!WOStrictFlag)
	{
	  GSWAssignAndRemoveAssociation(&_imageMapString,_associations,imageMapString__Key);
	  GSWAssignAndRemoveAssociation(&_imageMapRegions,_associations,imageMapRegions__Key);
	};
      
      GSWAssignAndRemoveAssociation(&_action,_associations,action__Key);
      GSWAssignAndRemoveAssociation(&_href,_associations,href__Key);
      GSWAssignAndRemoveAssociation(&_src,_associations,src__Key);
      GSWAssignAndRemoveAssociation(&_xAssoc,_associations,x__Key);
      GSWAssignAndRemoveAssociation(&_yAssoc,_associations,y__Key);
      GSWAssignAndRemoveAssociation(&_target,_associations,target__Key);
      GSWAssignAndRemoveAssociation(&_filename,_associations,filename__Key);
      GSWAssignAndRemoveAssociation(&_framework,_associations,framework__Key);
      GSWAssignAndRemoveAssociation(&_data,_associations,data__Key);
      GSWAssignAndRemoveAssociation(&_mimeType,_associations,mimeType__Key);
      GSWAssignAndRemoveAssociation(&_key,_associations,key__Key);
      GSWAssignAndRemoveAssociation(&_border,_associations,border__Key);
      if (_border==nil)
	ASSIGN(_border,static_defaultBorderAssociation);

      if (_file != nil
	  && _imageMapString != nil
	  && _imageMapRegions != nil)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: you can't specify %@, %@ and %@",
		       __PRETTY_FUNCTION__,
		       imageMapFileName__Key,
		       imageMapString__Key,
		       imageMapRegions__Key];
	};
      
      if (_action != nil)
	{
	  if (_actionClass != nil
	      || _directActionName != nil
	      || _href != nil) 
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: If 'action' is specified, 'directActionName', 'actionClass', and 'href' must be nil.",
			   __PRETTY_FUNCTION__];
	    }
	  if ([_action isValueConstant]) 
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: 'action' must not be a constant.",
			   __PRETTY_FUNCTION__];
	    }
	} 
      else if (_href != nil)
	{
	  if (_actionClass != nil
	      || _directActionName != nil)
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: If 'directActionName' or 'actionClass' is specified, 'action' and 'href' must be nil.",
			   __PRETTY_FUNCTION__];
	    }
	}
      else if (_actionClass == nil
	       && _directActionName == nil) 
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Either a component action or a direct action or 'href' must be specified.",
		       __PRETTY_FUNCTION__];
	}
      
      if (_filename != nil) 
	{
	  if (_src != nil
	      || _data != nil
	      || _value != nil) 
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: If 'filename' is specified, 'src', 'data', and 'value' must be nil.",
			   __PRETTY_FUNCTION__];
	    }
	} 
      else 
	{
	  if (_framework != nil) 
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: 'framework' should not be specified if 'filename' is nil.",
			   __PRETTY_FUNCTION__];
	    }                           
	  if (_data != nil)
	    {
	      if (_mimeType == nil)
		{
		  [NSException raise:NSInvalidArgumentException
			       format:@"%s: 'mimeType' must be specified if 'data' is specified.",
			       __PRETTY_FUNCTION__];
		}
	      if (_src != nil
		  || _value != nil) 
		{
		  [NSException raise:NSInvalidArgumentException
			       format:@"%s: If 'data' is specified, 'src', 'filename', and 'value' must be nil.",
			       __PRETTY_FUNCTION__];
		}
	    }
	  else if (_value != nil)
	    {
	      if ([_value isValueConstant])
		{
		  [NSException raise:NSInvalidArgumentException
			       format:@"%s: 'value' must not be constant.",
			       __PRETTY_FUNCTION__];
		}
	      if (_src != nil)
		{
		  [NSException raise:NSInvalidArgumentException
			       format:@"%s: If 'value' is specified, 'data', 'filename', and 'src' must be nil.",
			       __PRETTY_FUNCTION__];    
		}
	    } 
	  else if (_src == nil) 
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: One of 'filename', 'src', 'data', or 'value' must be specified.",
			   __PRETTY_FUNCTION__];        
	    }
	}
      
      if (_xAssoc != nil
	  && _yAssoc != nil) 
	{
	  if (![_xAssoc isValueSettable]
	      || ![_yAssoc isValueSettable])
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: 'x' and 'y' can not be constants.",
			   __PRETTY_FUNCTION__];        
	    }
	}
      else if (_xAssoc != nil
	       || _yAssoc != nil)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: 'x' and 'y' must both be specified or both be nil.",
		       __PRETTY_FUNCTION__];            
	}
    }
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_imageMapString);
  DESTROY(_imageMapRegions);
  DESTROY(_file);
  DESTROY(_action);
  DESTROY(_href);
  DESTROY(_src);
  DESTROY(_xAssoc);
  DESTROY(_yAssoc);
  DESTROY(_target);
  DESTROY(_filename);
  DESTROY(_framework);
  DESTROY(_data);
  DESTROY(_mimeType);
  DESTROY(_key);
  DESTROY(_width);
  DESTROY(_height);
//  DESTROY(_secure);
  DESTROY(_actionClass);
  DESTROY(_directActionName);
  DESTROY(_sessionIDQueryAssociations);
  DESTROY(_border);

  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return nil;//@"ELEMENTCHOSENBYCONTEXT";
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_getClassName(self),
                   (void*)self];
};

//--------------------------------------------------------------------
-(GSWAssociation*)hitTestX:(int)x
                         y:(int)y
                 inRegions:(NSArray*)regions
{
  GSWAssociation* assoc=nil;
  GSWGeometricRegion* region=[GSWGeometricRegion hitTestX:x
                                                 y:y
                                                 inRegions:regions];
  if (region)
    assoc=[GSWAssociation associationWithKeyPath:[region userDefinedString]];
  else
    assoc=_action;
  return assoc;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext
{
  //Does nothing
}

//--------------------------------------------------------------------
-(id <GSWActionResults>)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)aContext
{
  NSObject <GSWActionResults> * results = nil;
  GSWComponent* component=GSWContext_component(aContext);
  NSString* senderID=nil;
  NSString* elementID=nil;
  BOOL disabledInContext=NO;
  BOOL isInForm=NO;
  BOOL XYValues=NO;
  BOOL thisOne=NO;
  NSInteger x=0;
  NSInteger y=0;


  GSWContext_appendZeroElementIDComponent(aContext);

  senderID=GSWContext_senderID(aContext);

  elementID=GSWContext_elementID(aContext);

  if ([elementID isEqualToString:senderID])
    {
      //TODO
    };
  GSWContext_deleteLastElementIDComponent(aContext);
  disabledInContext=[self disabledInComponent:component];
  if (!disabledInContext)
    {
      isInForm=[aContext isInForm];
      if (isInForm)
        {
          BOOL wasFormSubmitted=[aContext _wasFormSubmitted];
          if (wasFormSubmitted)
            {
              NSString* nameInContext=[self nameInContext:aContext];
              NSString* formValueX=[request formValueForKey:[nameInContext stringByAppendingString:@".x"]];
              NSString* formValueY=[request formValueForKey:[nameInContext stringByAppendingString:@".y"]];

              if (formValueX && formValueY)
                {
                  x=[formValueX intValue];
                  y=[formValueY intValue];
                  XYValues=YES;
                  thisOne=YES;
                }
              else
                {
                  //TODO
                };
            };
        }
      else
        {
          elementID=GSWContext_elementID(aContext);

          if ([elementID isEqualToString:senderID])
            {
              id param=[request formValueForKey:GSWKey_IsmapCoords[GSWebNamingConv]];

              if (param)
                {
                  if ([param ismapCoordx:&x
                             y:&y])
                    XYValues=YES;
                  else
                    {
                      //TODO
                    };
                };
              thisOne=YES;
            };
        };
      if (thisOne)
        {
          GSWAssociation* actionAssociation=nil;
          NSArray* regions=nil;
          if (_file)
	    {
	      id imageMapFileNameValue=[_file valueInComponent:component];
	      NSString* imageMapFilePath;
	      GSWResourceManager* resourceManager=[[GSWApplication application]resourceManager];
	      NSArray* languages=[aContext languages];
	      imageMapFilePath=[resourceManager pathForResourceNamed:imageMapFileNameValue
						inFramework:nil
						languages:languages];
	      
	      if (imageMapFilePath)
		regions=[GSWGeometricRegion geometricRegionsWithFile:imageMapFilePath];
	      else
		{
		  //NSDebugMLLog0(@"gswdync",@"GSWActiveImage No image Map.");
		};
	    }
          else if (!WOStrictFlag && _imageMapString)
            {
              id imageMapValue=[_imageMapString valueInComponent:component];
              regions=[GSWGeometricRegion geometricRegionsWithString:imageMapValue];
            }
          else if (!WOStrictFlag && _imageMapRegions)
            {
              regions=[_imageMapRegions valueInComponent:component];
            };
          if (_xAssoc)
            [_xAssoc setValue:GSWIntNumber(x)
                     inComponent:component];
          if (_yAssoc)
            [_yAssoc setValue:GSWIntNumber(y)
                     inComponent:component];
	  
          actionAssociation=[self hitTestX:x
                                  y:y
                                  inRegions:regions];
          if (actionAssociation)
            {
              [aContext _setActionInvoked:YES];
              results = (NSObject <GSWActionResults> *) [actionAssociation valueInComponent:component];
              NSAssert4(!results || [results isKindOfClass:[GSWElement class]],
                        @"actionAssociation=%@, component=%@ Element is a %@ not a GSWElement: %@",
                        actionAssociation,
                        component,
                        [results class],
                        results);
            }
          else
            {
              if (_href)
                {
                  [aContext _setActionInvoked:YES];
                  //TODO redirect to href
                }
              else if (_action)
                {
                  [aContext _setActionInvoked:YES];
                  results = (NSObject <GSWActionResults> *)[_action valueInComponent:component];
                  NSAssert4(!results || [results isKindOfClass:[GSWElement class]],
                            @"_action=%@, component=%@ Element is a %@ not a GSWElement: %@",
                            _action,
                            component,
                            [results class],
                            results);
                }
              else
                {				
                  //NSDebugMLLog0(@"gswdync",@"GSWActiveImage Couldn't trigger action.");
                };
            };
          if (!results)
            {
              results=[aContext page];
              NSAssert2(!results || [results isKindOfClass:[GSWElement class]],
                        @"Element is a %@ not a GSWElement: %@",
                        [results class],
                        results);
            };
        }
      else
      {
          results = (NSObject <GSWActionResults> *) [super invokeActionForRequest:request
                                                                       inContext:aContext];
          NSAssert2(!results || [results isKindOfClass:[GSWElement class]],
                    @"Element is a %@ not a GSWElement: %@",
                    [results class],
                    results);
      }
    }
  else
    {
        results = (NSObject <GSWActionResults> *) [super invokeActionForRequest:request
                                                                     inContext:aContext];
      NSAssert2(!results || [results isKindOfClass:[GSWElement class]],
                @"Element is a %@ not a GSWElement: %@",
                [results class],
                results);
    };
  return results;
};

//--------------------------------------------------------------------
-(void)appendAttributesToResponse:(GSWResponse*) response
                        inContext:(GSWContext*) context
{
  NSString           * srcValue = nil;
  id                   borderValue = nil;
  GSWComponent       * component = GSWContext_component(context);

  borderValue=[_border valueInComponent:component];
  if (borderValue != nil)
    GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, @"border", NSStringWithObject(borderValue), NO);

  [self appendURLAttributesToResponse:response
                            inContext:context];
                            
  if (![self disabledInComponent:component])
    {
      if ([context isInForm])
	GSWResponse_appendContentAsciiString(response, @" type=image");
      else
	{
	  GSWResponse_appendContentAsciiString(response,@" ismap");
	}
  }

  if (_src != nil)
    srcValue = [_src valueInComponent:component];

  if (_filename == nil)
    {
      [GSWImage _appendImageSizetoResponse: response
		inContext: context
		width: _width
		height: _height];
    }

  if (_filename != nil)
    {
      [GSWImage _appendFilenameToResponse: response
		inContext: context
		framework: _framework
		filename: _filename
		width: _width 
		height: _height];
    }
  else if (_value != nil)
    {
      BOOL secure = (_secure != nil ? [_secure boolValueInComponent:component] : NO);
      GSWContext_appendZeroElementIDComponent(context);
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, 
								    @"src", 
								    [context _componentActionURLIsSecure:secure], 
								    NO);
      GSWContext_deleteLastElementIDComponent(context);
    }
  else if (srcValue != nil)
    {
      if ([srcValue isRelativeURL]
	  && ![srcValue isFragmentURL])
	{
	  NSString * url = [context _urlForResourceNamed: srcValue 
				    inFramework: nil];
	  if (url != nil)
	    GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, @"src", url, NO);      
	  else
	    {
	      GSWResponse_appendContentAsciiString(response, @" src=\"");
	      GSWResponse_appendContentAsciiString(response, [component baseURL]);
	      GSWResponse_appendContentCharacter(response,'/');
	      GSWResponse_appendContentString(response, srcValue);
	      GSWResponse_appendContentCharacter(response, '"');
	    }
	}
      else
	{
	  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, @"src", srcValue, NO);
	}
    }
  else if (_data != nil && _mimeType != nil)
    {
      [GSWURLValuedElementData _appendDataURLAttributeToResponse: response
			       inContext: context
			       key: _key
			       data: _data
			       mimeType: _mimeType
			       urlAttributeName: @"src"
			       inComponent: component];
    }
  else
    {
      NSLog(@"%s: 'src' or 'data' or 'name' attribute evaluated to nil.", __PRETTY_FUNCTION__);
    }
}

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  BOOL isInForm = NO;

  if ([self disabledInComponent:component])
    {
      GSWResponse_appendContentAsciiString(response, @"<img");
    }
  else
    {
      isInForm = [context isInForm];
      if (isInForm)
	GSWResponse_appendContentAsciiString(response, @"<input");
      else
	{
	  GSWResponse_appendContentAsciiString(response, @"<a");
	  if (_file == nil
	      && (_actionClass != nil 
		  || _directActionName != nil))
	    {
	      [self _appendCGIActionURLToResponse: response
		    inContext: context];
	    }
	  else 
	    {
	      BOOL secure = (_secure != nil ? [_secure boolValueInComponent:component] : NO);
	      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, @"href",
									    [context _componentActionURLIsSecure:secure],
									    NO);      
	      
	    }
	  [self appendConstantAttributesToResponse:response
		inContext:context];
	  
	  [super _appendNameAttributeToResponse:response
		 inContext:context];
	  
	  [self appendNonURLAttributesToResponse:response
		inContext:context];
	  
	  if (_target != nil)
	    {
	      NSString* targetValue = NSStringWithObject([_target valueInComponent:component]);
	      if (targetValue != nil)
		GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, @"target", targetValue, YES);
	    }
	  GSWResponse_appendContentAsciiString(response, @"><img");
	  [self appendAttributesToResponse:response
		inContext:context];
	  GSWResponse_appendContentAsciiString(response, @"></a>");
	  return;
	}
    }
  [self appendConstantAttributesToResponse:response
	inContext:context];
  
  [super _appendNameAttributeToResponse:response
	 inContext:context];
  
  [self appendNonURLAttributesToResponse:response
	inContext:context];
  
  [self appendAttributesToResponse:response
	inContext:context];
  GSWResponse_appendContentCharacter(response,'>');
}

//--------------------------------------------------------------------
-(void) _appendCGIActionURLToResponse:(GSWResponse*) response
                            inContext:(GSWContext*) context
{
  NSDictionary* queryDictionary = nil;
  
  NSString * actionStr = [self computeActionStringWithActionClassAssociation: _actionClass
                                                 directActionNameAssociation: _directActionName
                                                                   inContext: context];
  
  queryDictionary = [self computeQueryDictionaryWithRequestHandlerPath: actionStr 
                                            queryDictionaryAssociation: nil
                                                otherQueryAssociations: _sessionIDQueryAssociations 
                                                             inContext: context];
  
  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, 
								@"href", 
								[context _directActionURLForActionNamed:actionStr
									 queryDictionary:queryDictionary
									 isSecure:[self secureInContext:context]
									 port:0
									 escapeQueryDictionary:YES], NO);  
}



@end
