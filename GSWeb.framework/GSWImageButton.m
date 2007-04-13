/** GSWImageButton.m - <title>GSWeb: Class GSWImageButton</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

//====================================================================
@implementation GSWImageButton

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
  if ([_associations objectForKey: type__Key]) {
    [_associations removeObjectForKey: type__Key];
    NSLog(@"ImageButton: 'type' attribute ignored");
  }

  ASSIGN(_action, [_associations objectForKey: action__Key]);
  if (_action != nil) {
    [_associations removeObjectForKey: action__Key];
  }
  ASSIGN(_imageMapFileName, [_associations objectForKey: imageMapFileName__Key]);
  if (_imageMapFileName != nil) {
    imageMapDefNb++;
    [_associations removeObjectForKey: imageMapFileName__Key];
  }
  ASSIGN(_actionClass, [_associations objectForKey: actionClass__Key]);
  if (_actionClass != nil) {
    [_associations removeObjectForKey: actionClass__Key];
  }
  ASSIGN(_directActionName, [_associations objectForKey: directActionName__Key]);
  if (_directActionName != nil) {
    [_associations removeObjectForKey: directActionName__Key];
  }
  ASSIGN(_xAssoc, [_associations objectForKey: x__Key]);
  if (_xAssoc != nil) {
    [_associations removeObjectForKey: x__Key];
  }
  ASSIGN(_yAssoc, [_associations objectForKey: y__Key]);
  if (_yAssoc != nil) {
    [_associations removeObjectForKey: y__Key];
  }
  ASSIGN(_filename, [_associations objectForKey: filename__Key]);
  if (_filename != nil) {
    [_associations removeObjectForKey: filename__Key];
  }
  if (_filename != nil) {
    ASSIGN(_width, [_associations objectForKey: width__Key]);
    if (_width != nil) {
      [_associations removeObjectForKey: width__Key];
    }
    ASSIGN(_height, [_associations objectForKey: height__Key]);
    if (_height != nil) {
      [_associations removeObjectForKey: height__Key];
    }
  }  
  ASSIGN(_framework, [_associations objectForKey: framework__Key]);
  if (_framework != nil) {
    [_associations removeObjectForKey: framework__Key];
  }
  ASSIGN(_src, [_associations objectForKey: src__Key]);
  if (_src != nil) {
    [_associations removeObjectForKey: src__Key];
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

  if (!WOStrictFlag) {
    ASSIGN(_imageMapString, [_associations objectForKey: imageMapString__Key]);
    if (_imageMapString != nil) {
      imageMapDefNb++;    
      [_associations removeObjectForKey: imageMapString__Key];
    }
    ASSIGN(_imageMapRegions, [_associations objectForKey: imageMapRegions__Key]);
    if (_imageMapRegions != nil) {
      imageMapDefNb++;    
      [_associations removeObjectForKey: imageMapRegions__Key];
    }
  
    if (imageMapDefNb>0) {   // sure that this is 0 and not 1? dw
        ExceptionRaise(@"ImageButton",@"you can't specify %@, %@ and %@",
                       imageMapFileName__Key,
                       imageMapString__Key,
                       imageMapRegions__Key);
    }
    ASSIGN(_cidStore, [_associations objectForKey: cidStore__Key]);
    if (_cidStore != nil) {
      [_associations removeObjectForKey: cidStore__Key];
    }
    ASSIGN(_cidKey, [_associations objectForKey: cidKey__Key]);
    if (_cidKey != nil) {
      [_associations removeObjectForKey: cidKey__Key];
    }
  } // (!WOStrictFlag)

  if (_action != nil) {
    if (_actionClass != nil || _directActionName != nil) {
      [NSException raise:NSInvalidArgumentException
                  format:@"%s: Neither 'directActionName' nor 'actionClass' should be specified if 'action' is specified.",
                              __PRETTY_FUNCTION__];
    }
    if ([_action isValueConstant]) {
      [NSException raise:NSInvalidArgumentException
                  format:@"%s: 'action' must be a setable value and not a contant.",
                              __PRETTY_FUNCTION__];
    }
  } else {
    if (_actionClass == nil && _directActionName == nil) {
      [NSException raise:NSInvalidArgumentException
                  format:@"%s: Either a 'action' or a direct action must be specified.",
                              __PRETTY_FUNCTION__];
    }
  }
  if (_filename != nil) {
    if (_src != nil || _data != nil || _value != nil) {
      [NSException raise:NSInvalidArgumentException
                  format:@"%s: If 'filename' is specified, 'value', 'data', and 'src' must be nil.",
                              __PRETTY_FUNCTION__];
     }
  } else { // _filename 
    if (_framework != nil) {
      [NSException raise:NSInvalidArgumentException
                  format:@"%s: 'framework' should not be specified if 'filename' is nil.",
                              __PRETTY_FUNCTION__];    
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
  }
  if (_xAssoc != nil && _yAssoc != nil) {
    if ((![_xAssoc isValueSettable]) || (![_yAssoc isValueSettable])) {
          [NSException raise:NSInvalidArgumentException
                      format:@"%s: 'x' and 'y' can not be constants.",
                                  __PRETTY_FUNCTION__];            
    }
  } else
  if (_xAssoc != nil || _yAssoc != nil) {
          [NSException raise:NSInvalidArgumentException
                      format:@"%s: 'x' and 'y' must both be specified or both be nil.",
                                  __PRETTY_FUNCTION__];              
  }



  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_imageMapFileName);
  DESTROY(_imageMapString);//GSWeb only
  DESTROY(_imageMapRegions);//GSWeb Only
  DESTROY(_cidStore);//GSWeb only
  DESTROY(_cidKey);//GSWeb only
  DESTROY(_action);
  DESTROY(_actionClass);
  DESTROY(_directActionName);
  DESTROY(_xAssoc);
  DESTROY(_yAssoc);
  DESTROY(_filename);
  DESTROY(_framework);
  DESTROY(_src);
  DESTROY(_data);
  DESTROY(_mimeType);
  DESTROY(_key);
  DESTROY(_width);
  DESTROY(_height);
  
  [super dealloc];
};

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

//--------------------------------------------------------------------
-(id)_imageURLInContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------

-(void)_appendDirectActionToResponse:(GSWResponse*) response
                           inContext:(GSWContext*) context
{
   NSString * actionStr = [self computeActionStringWithActionClassAssociation: _actionClass
                                                  directActionNameAssociation: _directActionName
                                                                    inContext: context];

    GSWResponse_appendContentString(response, actionStr);
};

//--------------------------------------------------------------------

-(void)appendAttributesToResponse:(GSWResponse*) response
                        inContext:(GSWContext*) context
{
  GSWResourceManager * resourcemanager = [GSWApp resourceManager];
  GSWComponent       * component = GSWContext_component(context);

  [self appendConstantAttributesToResponse:response
                                 inContext:context];

  [self appendNonURLAttributesToResponse:response
                               inContext:context];

  [self appendURLAttributesToResponse:response
                            inContext:context];

  if (! [self disabledInComponent: component]) {
    GSWResponse_appendContentAsciiString(response, @" type=\"image\"");
    NSString * nameCtx = [self nameInContext:context];
    if (nameCtx != nil) {
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, name__Key, nameCtx, YES);      
    }
  }
  if (_value != nil) {
    [context appendZeroElementIDComponent];
    GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, src__Key, [context componentActionURL], NO);          
    [context deleteLastElementIDComponent];
  } else {
    if (_data != nil && _mimeType != nil) {
      [GSWURLValuedElementData  _appendDataURLToResponse: response
                        inContext: context
                              key: _key
                             data: _data
                         mimeType: _mimeType
                 urlAttributeName: src__Key
                      inComponent: component];
    } else {
      if (_filename != nil) {
      
         [GSWImage _appendFilenameToResponse: response
                                   inContext: context
                                   framework: _framework
                                    filename: _filename
                                       width: _width 
                                      height: _height];

      } else {
        NSString * srcValue = [_src valueInComponent:component];
        if (srcValue == nil) {
          srcValue = [resourcemanager errorMessageUrlForResourceNamed:@"/nil"
                                                          inFramework:@"nil"];

         NSLog(@"%s: 'src' (full url) evaluated to nil in component '%@'. Inserted error resource in html tag.",
                __PRETTY_FUNCTION__, component);
        }
        [response _appendTagAttribute:@"src"
                                value:srcValue
           escapingHTMLAttributeValue:NO];
      }
    }
  }
}


-(void)appendToResponse:(GSWResponse*) response
              inContext:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);

  if ([self disabledInComponent: component]) {
    GSWResponse_appendContentAsciiString(response,@"<img");
  } else {
    GSWResponse_appendContentAsciiString(response,@"<input");
  }

  [self appendAttributesToResponse:response 
                         inContext:context];

  GSWResponse_appendContentCharacter(response,'>');

  if (_directActionName != nil || _actionClass != nil) {
    GSWResponse_appendContentAsciiString(response,@"<input type=\"hidden\" name=\"GSWSubmitAction\" value=\"");
    [self _appendDirectActionToResponse:response
                              inContext:context];
    GSWResponse_appendContentCharacter(response,'>');
  }
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext
{
  //Does nothing!
};



// todo: check if 100% compatible
//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)aContext
{
  GSWElement* element=nil;
  NSString* senderID=nil;
  NSString* elementID=nil;
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
  NSDebugMLog(@"declarationName=%@ elementID=%@",
              [self declarationName],elementID);
  if ([elementID isEqualToString:senderID])
    {
      //TODO
    };
  GSWContext_deleteLastElementIDComponent(aContext);
  if (! [self disabledInComponent: component])
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
                  //thisOne=YES;//??
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
          if (_imageMapFileName)
            {
              id imageMapFileNameValue=[_imageMapFileName valueInComponent:component];
              NSString* imageMapFilePath=[component
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

              if (element && [element isKindOfClass:[GSWComponent class]])
                {
                  // call awakeInContext when _element is sleeping deeply
                  [(GSWComponent*)element ensureAwakeInContext:aContext];
                }
            }
          else
            {
              /*			  if (href)
                                          {
                                          [aContext _setActionInvoked:YES];
                                          //TODO redirect to href
                                          }
                                          else*/ 
              if (_action)
                {
                  [aContext _setActionInvoked:YES];
                  element=[_action valueInComponent:component];
                  
                  if (element && [element isKindOfClass:[GSWComponent class]])
                    {
                      // call awakeInContext when _element is sleeping deeply
                      [(GSWComponent*)element ensureAwakeInContext:aContext];
                    }
                }
              else
                {				
                  NSDebugMLLog0(@"gswdync",@"GSWActiveImage Couldn't trigger action.");
                };
            };
          if (!element)
            element=[aContext page];
        }
      else
        element=[super invokeActionForRequest:request
                       inContext:aContext];
    }
  else
    element=[super invokeActionForRequest:request
                   inContext:aContext];
  LOGObjectFnStop();
  return element;
};


//--------------------------------------------------------------------
-(NSString*)frameworkNameInContext:(GSWContext*)aContext
{
  //OK
  NSString* frameworkName=nil;  
  GSWComponent* component=GSWContext_component(aContext);
  NSDebugMLog(@"framework=%@",_framework);
  if (_framework)
    frameworkName=[_framework valueInComponent:component];
  else
    frameworkName=[component frameworkName];
  return frameworkName;
};


@end
