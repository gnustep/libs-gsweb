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
     associations:(NSDictionary*)Xassociations
  contentElements:(NSArray*)elements
{
  //OK
  NSMutableDictionary* tmpAssociations=nil;
  LOGObjectFnStart();
  NSDebugMLog(@"name=%@ Xassociations:%@ elements_=%@",
              aName,Xassociations,elements);
  tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:Xassociations];
  [tmpAssociations removeObjectForKey:imageMapFileName__Key];
  if (!WOStrictFlag)
    {
      [tmpAssociations removeObjectForKey:imageMapString__Key];
      [tmpAssociations removeObjectForKey:imageMapRegions__Key];
    };
  [tmpAssociations removeObjectForKey:action__Key];
  [tmpAssociations removeObjectForKey:href__Key];
  [tmpAssociations removeObjectForKey:src__Key];
  [tmpAssociations removeObjectForKey:x__Key];
  [tmpAssociations removeObjectForKey:y__Key];
  [tmpAssociations removeObjectForKey:target__Key];
  [tmpAssociations removeObjectForKey:filename__Key];
  [tmpAssociations removeObjectForKey:framework__Key];
  [tmpAssociations removeObjectForKey:data__Key];
  [tmpAssociations removeObjectForKey:mimeType__Key];
  [tmpAssociations removeObjectForKey:key__Key];

  if ((self=[super initWithName:aName
                   associations:tmpAssociations
                   contentElements:elements]))
    {
      int imageMapDefNb=0;
      _imageMapFileName = [[Xassociations objectForKey:imageMapFileName__Key
                                         withDefaultObject:[_imageMapFileName autorelease]] retain];
      if (_imageMapFileName)
        imageMapDefNb++;
      
      if (!WOStrictFlag)
        {
          _imageMapString = [[Xassociations objectForKey:imageMapString__Key
                                           withDefaultObject:[_imageMapString autorelease]] retain];
          if (_imageMapString)
            imageMapDefNb++;
          
          _imageMapRegions = [[Xassociations objectForKey:imageMapRegions__Key
                                            withDefaultObject:[_imageMapRegions autorelease]] retain];
          if (_imageMapRegions)
            imageMapDefNb++;
          if (imageMapDefNb>0)
            {
              ExceptionRaise(@"GSWActiveImage",@"you can't specify %@, %@ and %@",
                             imageMapFileName__Key,
                             imageMapString__Key,
                             imageMapRegions__Key);
            };
        };	  
      _action = [[Xassociations objectForKey:action__Key
                                withDefaultObject:[_action autorelease]] retain];
      
      _href = [[Xassociations objectForKey:href__Key
                              withDefaultObject:[_href autorelease]] retain];
      
      _src = [[Xassociations objectForKey:src__Key
                             withDefaultObject:[_src autorelease]] retain];
      
      _xAssoc = [[Xassociations objectForKey:x__Key
                                withDefaultObject:[_xAssoc autorelease]] retain];
      if (_xAssoc && ![_xAssoc isValueSettable])
        {
          ExceptionRaise0(@"GSWActiveImage",@"'x' parameter must be settable");
        };
      
      _yAssoc = [[Xassociations objectForKey:y__Key
                                withDefaultObject:[_yAssoc autorelease]] retain];
      if (_yAssoc && ![_yAssoc isValueSettable])
        {
          ExceptionRaise0(@"GSWActiveImage",@"'y' parameter must be settable");
        };
      
      _target = [[Xassociations objectForKey:target__Key
                                withDefaultObject:[_target autorelease]] retain];
      
      _filename = [[Xassociations objectForKey:filename__Key
                                  withDefaultObject:[_filename autorelease]] retain];
      
      _framework = [[Xassociations objectForKey:framework__Key
                                   withDefaultObject:[_framework autorelease]] retain];
      
      _data = [[Xassociations objectForKey:data__Key
                             withDefaultObject:[_data autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"_data=%@",_data);
      _action = [[Xassociations objectForKey:action__Key
                               withDefaultObject:[_action autorelease]] retain];
      
      _mimeType = [[Xassociations objectForKey:mimeType__Key
                                 withDefaultObject:[_mimeType autorelease]] retain];
      
      _key = [[Xassociations objectForKey:key__Key
                            withDefaultObject:[_key autorelease]] retain];
      
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_imageMapFileName);
  DESTROY(_imageMapString);
  DESTROY(_imageMapRegions);
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

@end

//====================================================================
@implementation GSWActiveImage (GSWActiveImageA)
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
@end


//====================================================================
@implementation GSWActiveImage (GSWActiveImageB)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext
{
  LOGObjectFnStart();
  //Does nothing
  LOGObjectFnStop();
};

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
  disabledInContext=[self disabledInContext:aContext];
  if (!disabledInContext)
    {
      isInForm=[aContext isInForm];
      if (isInForm)
        {
          BOOL wasFormSubmitted=[aContext _wasFormSubmitted];
          if (wasFormSubmitted)
            {
              NSString* nameInContext=[self nameInContext:aContext];
              NSString* formValueX=[request formValueForKey:[NSString stringWithFormat:@"%@.x",
                                                                      nameInContext]];
              NSString* formValueY=[request formValueForKey:[NSString stringWithFormat:@"%@.y",
                                                                       nameInContext]];
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
          if (_imageMapFileName)
            {
              id imageMapFileNameValue=[_imageMapFileName valueInComponent:component];
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

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  //OK
  //GSWRequest* _request=[aContext request];
  //Unused now BOOL isFromClientComponent=[_request isFromClientComponent];
  BOOL disabledInContext=[self disabledInContext:aContext];
  BOOL isInForm=NO;
  isInForm=[aContext isInForm]; //TODO
  if (isInForm)
    {
      if (!disabledInContext)
        GSWResponse_appendContentAsciiString(aResponse,@"<INPUT ");
      else
        GSWResponse_appendContentAsciiString(aResponse,@"<IMG ");
    }
  else
    {
      if (!disabledInContext)
        {
          NSString* hrefValue=nil;
          GSWResponse_appendContentAsciiString(aResponse,@"<A HREF=\"");
          if (_href)
            hrefValue=[self hrefInContext:aContext];
          else
            hrefValue=(NSString*)[aContext componentActionURL];
          GSWResponse_appendContentString(aResponse,hrefValue);
          GSWResponse_appendContentAsciiString(aResponse,@"\">");
        };
      GSWResponse_appendContentAsciiString(aResponse,@"<IMG");
    };
  [super appendToResponse:aResponse
         inContext:aContext];
  if (!isInForm)
    {
      if (!disabledInContext)
        {
          GSWResponse_appendContentAsciiString(aResponse,@"</A>");
        };
    };
};

//--------------------------------------------------------------------
-(NSString*)frameworkNameInContext:(GSWContext*)aContext
{
  //OK
  NSString* frameworkName=nil;  
  GSWComponent* component=GSWContext_component(aContext);
  NSDebugMLog(@"_framework=%@",_framework);
  if (_framework)
    frameworkName=[_framework valueInComponent:component];
  else
    frameworkName=[component frameworkName];
  return frameworkName;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)imageSourceInContext:(GSWContext*)aContext
{
  GSWComponent* component=nil;
  NSString* imageSource=nil;
  component=GSWContext_component(aContext);
  imageSource=[_src valueInComponent:component];
  return imageSource;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)hrefInContext:(GSWContext*)aContext
{
  GSWComponent* component=nil;
  NSString* hrefValue=nil;
  component=GSWContext_component(aContext);
  hrefValue=[_href valueInComponent:component];
  return hrefValue;
};
@end

//====================================================================
@implementation GSWActiveImage (GSWActiveImageC)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext
{
  //OK
  NSString* url=nil;
  GSWComponent* component=nil;
  id data=nil;
  id mimeTypeValue=nil;
  GSWURLValuedElementData* dataValue=nil;
  GSWResourceManager* resourceManager=nil;
  BOOL disabledInContext=NO;
  BOOL isInForm=NO;
  LOGObjectFnStartC("GSWActiveImage");
  NSDebugMLLog(@"gswdync",@"elementID=%@",GSWContext_elementID(aContext));
  component=GSWContext_component(aContext);
  disabledInContext=[self disabledInContext:aContext];
  isInForm=[aContext isInForm];

  if (!disabledInContext)
    {
      if (isInForm)
	{
	  NSString* nameInContext=[self nameInContext:aContext];
	  GSWResponse_appendContentAsciiString(aResponse,@" type=image");
	  GSWResponse_appendContentAsciiString(aResponse,@" name=\"");
	  GSWResponse_appendContentHTMLAttributeValue(aResponse,nameInContext);
	  GSWResponse_appendContentCharacter(aResponse,'"');
	}
      else
	{
	  GSWResponse_appendContentAsciiString(aResponse,@" ismap");
	};
    }

  NSDebugMLLog(@"gswdync",@"_data=%@",_data);
  NSDebugMLLog(@"gswdync",@"_filename=%@",_filename);
  if (_key)
    {
      NSString* keyValue=[_key valueInComponent:component];
      dataValue=[resourceManager _cachedDataForKey:keyValue];
    };
  if (!dataValue && _data)
    {
      data=[_data valueInComponent:component];  
      NSDebugMLLog(@"gswdync",@"data=%@",data);
      mimeTypeValue=[_mimeType valueInComponent:component];
      NSDebugMLLog(@"gswdync",@"_mimeType=%@",_mimeType);
      NSDebugMLLog(@"gswdync",@"mimeTypeValue=%@",mimeTypeValue);
      dataValue=[[[GSWURLValuedElementData alloc] initWithData:data
                                                  mimeType:mimeTypeValue
                                                  key:nil] autorelease];
      NSDebugMLLog(@"gswdync",@"dataValue=%@",dataValue);
    };
  resourceManager=[[GSWApplication application]resourceManager];
  if (_key || _data)
    {
      [resourceManager setURLValuedElementData:dataValue];
    }
  else if (_filename)
    {
      id filenameValue=nil;
      id frameworkValue=nil;
      GSWRequest* aRequest=nil;
      NSArray* languages=nil;
      NSDebugMLLog(@"gswdync",@"_filename=%@",_filename);
      filenameValue=[_filename valueInComponent:component];
      NSDebugMLLog(@"gswdync",@"filenameValue=%@",filenameValue);
      frameworkValue=[self frameworkNameInContext:aContext];
      NSDebugMLLog(@"gswdync",@"frameworkValue=%@",frameworkValue);
      aRequest=[aContext request];
      languages=[aContext languages];
      url=[resourceManager urlForResourceNamed:filenameValue
                           inFramework:frameworkValue
                           languages:languages
                           request:aRequest];
      if (!url)
        {
          LOGSeriousError(@"No URL for resource named: %@ in framework named: %@ for languages: %@",
                          filenameValue,
                          frameworkValue,
                          languages);
        };
    };
  GSWResponse_appendContentAsciiString(aResponse,@" src=\"");
  if (_key || _data)
    {
      [dataValue appendDataURLToResponse:aResponse
                 inContext:aContext];
    }
  else if (_filename)
    {
      GSWResponse_appendContentString(aResponse,url);
    }
  else if (_src)
    {
      NSString* srcValue=[self imageSourceInContext:aContext];
      GSWResponse_appendContentString(aResponse,srcValue);
    }
  else
    {
      GSWDynamicURLString* componentActionURL=[aContext componentActionURL];
      NSDebugMLLog(@"gswdync",@"componentActionURL=%@",componentActionURL);
      GSWResponse_appendContentString(aResponse,(NSString*)componentActionURL);
    };
  GSWResponse_appendContentCharacter(aResponse,'"');
  NSDebugMLLog(@"gswdync",@"elementID=%@",GSWContext_elementID(aContext));
  LOGObjectFnStopC("GSWActiveImage");
};


@end


//====================================================================
@implementation GSWActiveImage (GSWActiveImageD)

//--------------------------------------------------------------------
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)appendStringAtLeft:(id)unkwnon
              withMapping:(char*)mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};
@end

