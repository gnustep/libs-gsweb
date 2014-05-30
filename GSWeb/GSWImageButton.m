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

#include "GSWeb.h"
#include <GNUstepBase/NSObject+GNUstepBase.h>

//====================================================================
@implementation GSWImageButton

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  if ((self = [super initWithName:@"input"
		     associations:associations
		     template: nil]))
    {
      int imageMapDefNb=0;
      if ([_associations objectForKey: type__Key])
	{
	  [_associations removeObjectForKey: type__Key];
	  NSLog(@"ImageButton: 'type' attribute ignored");
	}

      GSWAssignAndRemoveAssociation(&_action,_associations,action__Key);
      if (GSWAssignAndRemoveAssociation(&_imageMapFileName,_associations,imageMapFileName__Key))
	imageMapDefNb++;
      GSWAssignAndRemoveAssociation(&_actionClass,_associations,actionClass__Key);
      GSWAssignAndRemoveAssociation(&_directActionName,_associations,directActionName__Key);
      GSWAssignAndRemoveAssociation(&_xAssoc,_associations,x__Key);
      GSWAssignAndRemoveAssociation(&_yAssoc,_associations,y__Key);
      if (GSWAssignAndRemoveAssociation(&_filename,_associations,filename__Key))
	{
	  GSWAssignAndRemoveAssociation(&_width,_associations,width__Key);
	  GSWAssignAndRemoveAssociation(&_height,_associations,height__Key);
	}  

      GSWAssignAndRemoveAssociation(&_framework,_associations,framework__Key);
      GSWAssignAndRemoveAssociation(&_src,_associations,src__Key);
      GSWAssignAndRemoveAssociation(&_data,_associations,data__Key);
      GSWAssignAndRemoveAssociation(&_mimeType,_associations,mimeType__Key);
      GSWAssignAndRemoveAssociation(&_key,_associations,key__Key);

      if (!WOStrictFlag)
	{
	  if (GSWAssignAndRemoveAssociation(&_imageMapString,_associations,imageMapString__Key))
	    imageMapDefNb++;
	  
	  if (GSWAssignAndRemoveAssociation(&_imageMapRegions,_associations,imageMapRegions__Key))
	    imageMapDefNb++;    
  
	  if (imageMapDefNb>0)
	    {   // sure that this is 0 and not 1? dw
	      ExceptionRaise(@"ImageButton",@"you can't specify %@, %@ and %@",
			     imageMapFileName__Key,
			     imageMapString__Key,
			     imageMapRegions__Key);
	    }
	  GSWAssignAndRemoveAssociation(&_cidStore,_associations,cidStore__Key);
	  GSWAssignAndRemoveAssociation(&_cidKey,_associations,cidKey__Key);
	} // (!WOStrictFlag)

      if (_action != nil)
	{
	  if (_actionClass != nil
	      || _directActionName != nil)
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: Neither 'directActionName' nor 'actionClass' should be specified if 'action' is specified.",
			   __PRETTY_FUNCTION__];
	    }
	  if ([_action isValueConstant])
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: 'action' must be a setable value and not a contant.",
			   __PRETTY_FUNCTION__];
	    }
	}
      else if (_actionClass == nil
	       && _directActionName == nil)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Either a 'action' or a direct action must be specified.",
		       __PRETTY_FUNCTION__];
	}

      if (_filename != nil)
	{
	  if (_src != nil
	      || _data != nil
	      || _value != nil)
	    {
	      [NSException raise:NSInvalidArgumentException
			   format:@"%s: If 'filename' is specified, 'value', 'data', and 'src' must be nil.",
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
  
      if (_xAssoc != nil && _yAssoc != nil)
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
-(id)_imageURLInContext:(GSWContext*)aContext
{
  [self notImplemented: _cmd];	//TODOFN
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

  if (![self disabledInComponent: component])
    {
      GSWResponse_appendContentAsciiString(response, @" type=\"image\"");
      NSString * nameCtx = [self nameInContext:context];
      if (nameCtx != nil)
	{
	  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, 
									name__Key, 
									nameCtx, 
									YES);
	}
    }
  if (_value != nil)
    {
      BOOL secure = (_secure != nil ? [_secure boolValueInComponent:component] : NO);
      GSWContext_appendZeroElementIDComponent(context);
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response, 
								    src__Key, 
								    [context _componentActionURLIsSecure:secure],
								    NO);
      GSWContext_deleteLastElementIDComponent(context);
    }
  else if (_data != nil
	   && _mimeType != nil)
    {
      [GSWURLValuedElementData  _appendDataURLAttributeToResponse: response
				inContext: context
				key: _key
				data: _data
				mimeType: _mimeType
				urlAttributeName: src__Key
				inComponent: component];
    }
  else if (_filename != nil)
    {      
      [GSWImage _appendFilenameToResponse: response
		inContext: context
		framework: _framework
		filename: _filename
		width: _width 
		height: _height];
      
    }
  else
    {
      NSString * srcValue = [_src valueInComponent:component];
      if (srcValue == nil)
	{
          srcValue = [resourcemanager errorMessageUrlForResourceNamed:@"/nil"
				      inFramework:@"nil"];
	  
	  NSLog(@"%s: 'src' (full url) evaluated to nil in component '%@'. Inserted error resource in html tag.",
                __PRETTY_FUNCTION__, component);
        }
      GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(response,
								    @"src",
								    srcValue,
								      NO);
    }
}

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*) response
              inContext:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);

  if ([self disabledInComponent: component])
    GSWResponse_appendContentAsciiString(response,@"<img");
  else
    GSWResponse_appendContentAsciiString(response,@"<input");

  [self appendAttributesToResponse:response 
                         inContext:context];

  GSWResponse_appendContentCharacter(response,'>');

  if (_directActionName != nil
      || _actionClass != nil)
    {
      GSWResponse_appendContentAsciiString(response,
					   @"<input type=\"hidden\" name=\"GSWSubmitAction\" value=\"");
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

//--------------------------------------------------------------------
// todo: check if 100% compatible
-(id <GSWActionResults>)invokeActionForRequest:(GSWRequest*)request
                                    inContext:(GSWContext*)aContext
{
  NSObject <GSWActionResults>* element=nil;
  GSWComponent* component=GSWContext_component(aContext);

  NSString* senderID=nil;
  NSString* elementID=nil;
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
      GSWContext_deleteLastElementIDComponent(aContext);
      if (_value != nil)
	element=[_value valueInComponent:component];
    }
  else
    {
      GSWContext_deleteLastElementIDComponent(aContext);
      elementID=GSWContext_elementID(aContext);

      if (![self disabledInComponent: component])
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
		      //thisOne=YES;//??
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
	      if (_imageMapFileName)
		{
		  id imageMapFileNameValue=[_imageMapFileName valueInComponent:component];
		  NSString* imageMapFilePath;
		  
		  imageMapFilePath=[[GSWApp resourceManager] pathForResourceNamed:imageMapFileNameValue
							     inFramework:nil
							     languages:[aContext languages]];                  
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
		  element=[actionAssociation valueInComponent:component];
		  
		  if (element
		      && [element isKindOfClass:[GSWComponent class]])
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
		      //NSDebugMLLog0(@"gswdync",@"GSWActiveImage Couldn't trigger action.");
		    };
		};
	      if (!element)
		element=[aContext page];
	    }
	  else
	    element = (id <GSWActionResults, NSObject>) [super invokeActionForRequest:request
							       inContext:aContext];
	}
      else
	element = (id <GSWActionResults, NSObject>) [super invokeActionForRequest:request
							   inContext:aContext];
    }
  return element;
};



@end
