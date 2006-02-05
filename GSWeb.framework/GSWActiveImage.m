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

RCS_ID("$Id$")

#include "GSWeb.h"

//====================================================================
@implementation GSWActiveImage

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  int imageMapDefNb=0;

  self = [super initWithName:@"input" associations:associations template: nil];
  if (!self) {
    return nil;
  }

  ASSIGN(_file, [_associations objectForKey: imageMapFileName__Key]);
  if (_file != nil) {
    [_associations removeObjectForKey: imageMapFileName__Key];
  }
  
  if (!WOStrictFlag) {
      ASSIGN(_imageMapString, [_associations objectForKey: imageMapString__Key]);
      if (_imageMapString != nil) {
        [_associations removeObjectForKey: imageMapString__Key];
      }
      ASSIGN(_imageMapRegions, [_associations objectForKey: imageMapRegions__Key]);
      if (_imageMapRegions != nil) {
        [_associations removeObjectForKey: imageMapRegions__Key];
      }
  };
    
  ASSIGN(_action, [_associations objectForKey: action__Key]);
  if (_action != nil) {
    [_associations removeObjectForKey: action__Key];
  }
  ASSIGN(_href, [_associations objectForKey: href__Key]);
  if (_href != nil) {
    [_associations removeObjectForKey: href__Key];
  }
  ASSIGN(_src, [_associations objectForKey: src__Key]);
  if (_src != nil) {
    [_associations removeObjectForKey: src__Key];
  }
  ASSIGN(_xAssoc, [_associations objectForKey: x__Key]);
  if (_xAssoc != nil) {
    [_associations removeObjectForKey: x__Key];
  }
  ASSIGN(_yAssoc, [_associations objectForKey: y__Key]);
  if (_yAssoc != nil) {
    [_associations removeObjectForKey: y__Key];
  }
  ASSIGN(_target, [_associations objectForKey: target__Key]);
  if (_target != nil) {
    [_associations removeObjectForKey: target__Key];
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
  
  if (_file != nil && _imageMapString != nil && _imageMapRegions != nil) {
     [NSException raise:NSInvalidArgumentException
                  format:@"%s: you can't specify %@, %@ and %@",
                         __PRETTY_FUNCTION__,
                         imageMapFileName__Key,
                         imageMapString__Key,
                         imageMapRegions__Key];
  };

  if (_action != nil) {
    if (_actionClass != nil || _directActionName != nil || _href != nil) {
      [NSException raise:NSInvalidArgumentException
                  format:@"%s: If 'action' is specified, 'directActionName', 'actionClass', and 'href' must be nil.",
                              __PRETTY_FUNCTION__];
    }
    if ([_action isValueConstant]) {
      [NSException raise:NSInvalidArgumentException
                  format:@"%s: 'action' must not be a constant.",
                              __PRETTY_FUNCTION__];
    }
  } else {
    if (_href != nil) {
      if (_actionClass != nil || _directActionName != nil) {
        [NSException raise:NSInvalidArgumentException
                    format:@"%s: If 'directActionName' or 'actionClass' is specified, 'action' and 'href' must be nil.",
                                __PRETTY_FUNCTION__];
      }
    } else {
      if (_actionClass == nil && _directActionName == nil) {
        [NSException raise:NSInvalidArgumentException
                    format:@"%s: Either a component action or a direct action or 'href' must be specified.",
                                __PRETTY_FUNCTION__];
      }
    }
  }
  if (_filename != nil) {
    if (_src != nil || _data != nil || _value != nil) {
        [NSException raise:NSInvalidArgumentException
                    format:@"%s: If 'filename' is specified, 'src', 'data', and 'value' must be nil.",
                                __PRETTY_FUNCTION__];
    }
  } else {
    if (_framework != nil) {
       [NSException raise:NSInvalidArgumentException
                   format:@"%s: 'framework' should not be specified if 'filename' is nil.",
                               __PRETTY_FUNCTION__];
    }                           
  }
  if (_data != nil) {
    if (_mimeType == nil) {
       [NSException raise:NSInvalidArgumentException
                   format:@"%s: 'mimeType' must be specified if 'data' is specified.",
                               __PRETTY_FUNCTION__];
    }
    if (_src != nil || _value != nil) {
       [NSException raise:NSInvalidArgumentException
                   format:@"%s: If 'data' is specified, 'src', 'filename', and 'value' must be nil.",
                               __PRETTY_FUNCTION__];
    }
  } else
  if (_value != nil) {
    if ([_value isValueConstant]) {
       [NSException raise:NSInvalidArgumentException
                   format:@"%s: 'value' must not be constant.",
                               __PRETTY_FUNCTION__];
    }
    if (_src != nil) {
       [NSException raise:NSInvalidArgumentException
                   format:@"%s: If 'value' is specified, 'data', 'filename', and 'src' must be nil.",
                               __PRETTY_FUNCTION__];    
    }
  } else {
    if (_src == nil) {
       [NSException raise:NSInvalidArgumentException
                   format:@"%s: One of 'filename', 'src', 'data', or 'value' must be specified.",
                               __PRETTY_FUNCTION__];        
    }
  }
  if (_xAssoc != nil && _yAssoc != nil) {
    if ((![_xAssoc isValueSettable]) || (![_yAssoc isValueSettable])) {
        [NSException raise:NSInvalidArgumentException
                    format:@"%s: 'x' and 'y' can not be constants.",
                                __PRETTY_FUNCTION__];        
    }
  } else {
    if (_xAssoc != nil || _yAssoc != nil) {
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
  DESTROY(_secure);
  DESTROY(_actionClass);
  DESTROY(_directActionName);

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
                   object_get_class_name(self),
                   (void*)self];
};

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
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)aContext
{
  GSWElement* element=nil;
  NSString* senderID=nil;
  NSString* elementID=nil;
  BOOL disabledInContext=NO;
  BOOL isInForm=NO;
  BOOL XYValues=NO;
  BOOL thisOne=NO;
  GSWComponent* component=nil;
  int x=0;
  int y=0;

  LOGObjectFnStart();

  component=GSWContext_component(aContext);

  GSWContext_appendZeroElementIDComponent(aContext);

  senderID=GSWContext_senderID(aContext);
  NSDebugMLog(@"senderID=%@",senderID);

  elementID=GSWContext_elementID(aContext);
  NSDebugMLog(@"elementID=%@",elementID);

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
              NSDebugMLLog(@"gswdync",@"formValueX=%@",formValueX);
              NSDebugMLLog(@"gswdync",@"formValueY=%@",formValueY);
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
          NSDebugMLog(@"elementID=%@",elementID);
          if ([elementID isEqualToString:senderID])
            {
              id param=[request formValueForKey:GSWKey_IsmapCoords[GSWebNamingConv]];
              NSDebugMLLog(@"gswdync",@"param=%@",param);
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
              NSString* imageMapFilePath=[GSWContext_component(aContext)
                                           pathForResourceNamed:imageMapFileNameValue
                                           ofType:nil];
              if (!imageMapFilePath)
                {
                  GSWResourceManager* resourceManager=[[GSWApplication application]resourceManager];
                  NSArray* languages=[aContext languages];
                  imageMapFilePath=[resourceManager pathForResourceNamed:imageMapFileNameValue
                                                    inFramework:nil
                                                    languages:languages];
			  
                };
              if (imageMapFilePath)
                regions=[GSWGeometricRegion geometricRegionsWithFile:imageMapFilePath];
              else
                {
                  NSDebugMLLog0(@"gswdync",@"GSWActiveImage No image Map.");
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
              element=[actionAssociation valueInComponent:component];
              NSAssert4(!element || [element isKindOfClass:[GSWElement class]],
                        @"actionAssociation=%@, component=%@ Element is a %@ not a GSWElement: %@",
                        actionAssociation,
                        component,
                        [element class],
                        element);
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
                  element=[_action valueInComponent:component];
                  NSAssert4(!element || [element isKindOfClass:[GSWElement class]],
                            @"_action=%@, component=%@ Element is a %@ not a GSWElement: %@",
                            _action,
                            component,
                            [element class],
                            element);
                }
              else
                {				
                  NSDebugMLLog0(@"gswdync",@"GSWActiveImage Couldn't trigger action.");
                };
            };
          if (!element)
            {
              element=[aContext page];
              NSAssert2(!element || [element isKindOfClass:[GSWElement class]],
                        @"Element is a %@ not a GSWElement: %@",
                        [element class],
                        element);
            };
        }
      else
        {
          element=[super invokeActionForRequest:request
                         inContext:aContext];
          NSAssert2(!element || [element isKindOfClass:[GSWElement class]],
                    @"Element is a %@ not a GSWElement: %@",
                    [element class],
                    element);
        };
    }
  else
    {
      element=[super invokeActionForRequest:request
                     inContext:aContext];
      NSAssert2(!element || [element isKindOfClass:[GSWElement class]],
                @"Element is a %@ not a GSWElement: %@",
                [element class],
                element);
    };
  LOGObjectFnStop();
  return element;
};

-(void)appendAttributesToResponse:(GSWResponse*) response
                        inContext:(GSWContext*) context
{
  NSString           * srcValue = nil;
  GSWComponent       * component = GSWContext_component(context);
  GSWResourceManager * resourcemanager = [GSWApp resourceManager];
  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, @"border", @"0", NO);      

  [self appendURLAttributesToResponse:response
                            inContext:context];
                            
  if (![self disabledInComponent:component]) {
    if ([context isInForm]) {
      GSWResponse_appendContentString(response, @" type=image");
    } else {
      GSWResponse_appendContentCharacter(response,' ');
      GSWResponse_appendContentAsciiString(response,@"ismap");
    }
  }
  if (_src != nil) {
    srcValue = [_src valueInComponent:component];
  }
  if (_filename == nil) {
    [GSWImage _appendImageSizetoResponse: response
                               inContext: context
                                   width: _width
                                  height: _height];
  }
  if (_filename != nil) {
    [GSWImage _appendFilenameToResponse: response
                         inContext: context
                         framework: _framework
                          filename: _filename
                             width: _width 
                            height: _height];
  } else
  if (_value != nil) {
    [context appendZeroElementIDComponent];
    GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, 
                                                                  @"src", 
                                                                  [context componentActionURL], 
                                                                  NO);
    [context deleteLastElementIDComponent];
  } else
  if (srcValue != nil) {
    if (([srcValue isRelativeURL]) && (! [srcValue isFragmentURL])) {
      NSString * url = [context _urlForResourceNamed: srcValue 
                                         inFramework: nil];
      if (url != nil) {
        GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, @"src", url, NO);      
      } else {
        GSWResponse_appendContentAsciiString(response, @" src=\"");
        GSWResponse_appendContentAsciiString(response, [component baseURL]);
        GSWResponse_appendContentCharacter(response,'/');
        GSWResponse_appendContentString(response, srcValue);
        GSWResponse_appendContentCharacter(response, '"');
      }
    } else {
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, @"src", srcValue, NO);
    }
  } else {
    if (_data != nil && _mimeType != nil) {

    [GSWURLValuedElementData _appendDataURLToResponse: response
                                            inContext: context
                                                  key: _key
                                                 data: _data
                                             mimeType: _mimeType
                                     urlAttributeName: @"src"
                                          inComponent: component];
    } else {
      NSLog(@"%s: 'src' or 'data' or 'name' attribute evaluated to nil.", __PRETTY_FUNCTION__);
    }
  }
}

-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  BOOL isInForm = NO;
  if ([self disabledInComponent:component]) {
    GSWResponse_appendContentAsciiString(response, @"<img");
  } else {
    isInForm = [context isInForm];
    if (isInForm) {
      GSWResponse_appendContentAsciiString(response, @"<input");
    } else {
      GSWResponse_appendContentAsciiString(response, @"<a");
      if (_file == nil && (_actionClass != nil || _directActionName != nil)) {
        [self _appendCGIActionURLToResponse: response
                                  inContext: context];
      } else {
        if (_secure != nil) {
          [context _generateCompleteURLs];
        }
        GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, @"href",
                                       // pass this to _componentActionURL?
                                       // (_secure != nil && [_secure boolValueInComponent: [context component]]) 
                                                          [context _componentActionURL],
                                                          NO);      

        if (_secure != nil) {
          [context _generateRelativeURLs];
        }
      }
      [self appendConstantAttributesToResponse:response
                                     inContext:context];
      
      [super _appendNameAttributeToResponse:response
                                  inContext:context];
                                  
      [self appendNonURLAttributesToResponse:response
                                   inContext:context];

      if (_target != nil) {
        NSString * targetValue = [_target valueInComponent:component];
        if (targetValue != nil) {
          GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, @"target", targetValue, YES);
        }
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

-(void) _appendCGIActionURLToResponse:(GSWResponse*) response
                            inContext:(GSWContext*) context
{

  NSString * actionStr = [self computeActionStringWithActionClassAssociation: _actionClass
                                                 directActionNameAssociation: _directActionName
                                                                   inContext: context];

  if (_secure != nil) {
    [context _generateCompleteURLs];
  }
  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, @"href",
                               // pass this to _componentActionURL?
                               // (_secure != nil && [_secure boolValueInComponent: [context component]]) 
                                                  [context _componentActionURL],
                                                  NO);      
  if (_secure != nil) {
    [context _generateRelativeURLs];  
  }
}



@end
