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
  contentElements:(NSArray*)elements;
{
  //OK
  NSMutableDictionary* tmpAssociations=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ elements=%@",
               aName,associations,elements);
  tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
  [tmpAssociations removeObjectForKey:imageMapFileName__Key];
  if (!WOStrictFlag)
    {
      [tmpAssociations removeObjectForKey:imageMapString__Key];
      [tmpAssociations removeObjectForKey:imageMapRegions__Key];
      [tmpAssociations removeObjectForKey:cidStore__Key];
      [tmpAssociations removeObjectForKey:cidKey__Key];
    };
  [tmpAssociations removeObjectForKey:action__Key];
  [tmpAssociations removeObjectForKey:actionClass__Key];
  [tmpAssociations removeObjectForKey:directActionName__Key];
  [tmpAssociations removeObjectForKey:x__Key];
  [tmpAssociations removeObjectForKey:y__Key];
  [tmpAssociations removeObjectForKey:filename__Key];
  [tmpAssociations removeObjectForKey:framework__Key];
  [tmpAssociations removeObjectForKey:src__Key];
  [tmpAssociations removeObjectForKey:data__Key];
  [tmpAssociations removeObjectForKey:mimeType__Key];
  [tmpAssociations removeObjectForKey:key__Key];
  if ((self=[super initWithName:aName
                   associations:tmpAssociations
                   contentElements:elements]))
    {
      int imageMapDefNb=0;
      _action = [[associations objectForKey:action__Key
                               withDefaultObject:[_action autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"action=%@",_action);
      if ([_action isValueConstant])
        {
          ExceptionRaise0(@"GSWImageButton",@"'Action' parameter can't be a constant association");
        };
	  
      _imageMapFileName = [[associations objectForKey:imageMapFileName__Key
                                         withDefaultObject:[_imageMapFileName autorelease]] retain];
      if (_imageMapFileName)
        imageMapDefNb++;
      NSDebugMLLog(@"gswdync",@"imageMapFileName=%@",_imageMapFileName);

      if (!WOStrictFlag)
        {
          _imageMapString = [[associations objectForKey:imageMapString__Key
                                           withDefaultObject:[_imageMapString autorelease]] retain];
          if (_imageMapString)
            imageMapDefNb++;
              
          _imageMapRegions = [[associations objectForKey:imageMapRegions__Key
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

          _cidStore = [[associations objectForKey:cidStore__Key
                                     withDefaultObject:[_cidStore autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"cidStore=%@",_cidStore);
          
          _cidKey = [[associations objectForKey:cidKey__Key
                                   withDefaultObject:[_cidKey autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"cidKey=%@",_cidKey);
        };
      _actionClass = [[associations objectForKey:actionClass__Key
                                    withDefaultObject:[_actionClass autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"actionClass=%@",_actionClass);
	  
      _directActionName = [[associations objectForKey:directActionName__Key
                                         withDefaultObject:[_directActionName autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"directActionName=%@",_directActionName);
      
      _xAssoc = [[associations objectForKey:x__Key
                               withDefaultObject:[_xAssoc autorelease]] retain];

      _yAssoc = [[associations objectForKey:y__Key
                               withDefaultObject:[_yAssoc autorelease]] retain];
	  
      _filename = [[associations objectForKey:filename__Key
                                 withDefaultObject:[_filename autorelease]] retain];

      _framework = [[associations objectForKey:framework__Key
                                  withDefaultObject:[_framework autorelease]] retain];

      _src = [[associations objectForKey:src__Key
                            withDefaultObject:[_src autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"src=%@",_src);

      _data = [[associations objectForKey:data__Key
                             withDefaultObject:[_data autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"data=%@",_data);
      
      _mimeType = [[associations objectForKey:mimeType__Key
                                 withDefaultObject:[_mimeType autorelease]] retain];

      _key = [[associations objectForKey:key__Key
                            withDefaultObject:[_key autorelease]] retain];
    };
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
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return nil;//@"ELEMENTCHOSENBYCONTEXT";//TODO
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
@implementation GSWImageButton (GSWImageButtonA)
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
@implementation GSWImageButton (GSWImageButtonB)

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext
{
  //OK
  NSString* urlValue=nil;
  NSString* name=nil;
  BOOL disabledInContext=NO;
  GSWComponent* component=nil;
  GSWResourceManager* resourceManager=nil;
  GSWURLValuedElementData* dataValue=nil;
  NSString* keyValue=nil;
  id cidStoreValue=nil;

  LOGObjectFnStart();

  disabledInContext=[self disabledInContext:aContext];

  GSWResponse_appendContentAsciiString(aResponse,@" type=image");

  name=[self nameInContext:aContext];
  NSDebugMLLog(@"gswdync",@"declarationName=%@ name=%@",
               [self declarationName],name);
  GSWResponse_appendContentAsciiString(aResponse,@" name=\"");

  GSWResponse_appendContentHTMLAttributeValue(aResponse,name);
  GSWResponse_appendContentCharacter(aResponse,'"');

  component=GSWContext_component(aContext);

  cidStoreValue=[_cidStore valueInComponent:component];
  NSDebugMLLog(@"gswdync",@"cidStoreValue=%@",cidStoreValue);

  resourceManager=[[GSWApplication application]resourceManager];

  if (_src)
    {
      urlValue=[_src valueInComponent:component];
      if (cidStoreValue)
        {
          urlValue=[self addURL:urlValue
                         forCIDKeyAssociation:_cidKey
                         CIDStoreAssociation:_cidStore
                         inContext:aContext];
          NSDebugMLLog(@"gswdync",@"urlValue=%@",urlValue);
        };
    }
  else
    {
      if (_key)
        {
          keyValue=[_key valueInComponent:component];
          dataValue=[resourceManager _cachedDataForKey:keyValue];
          if (cidStoreValue && dataValue)
            {
              urlValue=[self addURLValuedElementData:dataValue
                             forCIDKeyAssociation:_cidKey
                             CIDStoreAssociation:_cidStore
                             inContext:aContext];
              NSDebugMLLog(@"gswdync",@"urlValue=%@",urlValue);
            }
        };
      if (!dataValue && _data)
        {
          id tmpDataValue=[_data valueInComponent:component];
          id mimeTypeValue=[_mimeType valueInComponent:component];
          dataValue=[[[GSWURLValuedElementData alloc] initWithData:tmpDataValue
                                                      mimeType:mimeTypeValue
                                                      key:keyValue] autorelease];
          [resourceManager setURLValuedElementData:dataValue];
          if (cidStoreValue && dataValue)
            {
              urlValue=[self addURLValuedElementData:dataValue
                             forCIDKeyAssociation:_cidKey
                             CIDStoreAssociation:_cidStore
                             inContext:aContext];
              NSDebugMLLog(@"gswdync",@"urlValue=%@",urlValue);
            }
        }
      else if (_filename)
        {
          id filenameValue=nil;
          id frameworkValue=nil;
          GSWRequest* request=nil;
          NSArray* languages=nil;
          NSDebugMLLog(@"gswdync",@"filename=%@",_filename);
          filenameValue=[_filename valueInComponent:component];
          NSDebugMLLog(@"gswdync",@"filenameValue=%@",filenameValue);
          frameworkValue=[self frameworkNameInContext:aContext];
          NSDebugMLLog(@"gswdync",@"frameworkValue=%@",frameworkValue);
          request=[aContext request];
          languages=[aContext languages];
          if (cidStoreValue)
            {
              NSString* path=[resourceManager pathForResourceNamed:filenameValue
                                              inFramework:frameworkValue
                                              languages:languages];
              urlValue=[self addPath:path
                             forCIDKeyAssociation:_cidKey
                             CIDStoreAssociation:_cidStore
                             inContext:aContext];
              NSDebugMLLog(@"gswdync",@"urlValue=%@",urlValue);
            }
          else
            {
              urlValue=[resourceManager urlForResourceNamed:filenameValue
                                        inFramework:frameworkValue
                                        languages:languages
                                        request:request];
            };
        };
    };

  GSWResponse_appendContentAsciiString(aResponse,@" src=\"");
  if (_src)
    {
      GSWResponse_appendContentString(aResponse,urlValue);
    }
  else
    {
      if (_key || _data)
        {
          if (cidStoreValue)
            GSWResponse_appendContentString(aResponse,urlValue);
          else
            [dataValue appendDataURLToResponse:aResponse
                       inContext:aContext];
        }
      else if (_filename)
        {
          GSWResponse_appendContentString(aResponse,urlValue);
        }
      else
        {
          GSWDynamicURLString* componentActionURL=[aContext componentActionURL];
          NSDebugMLLog(@"gswdync",@"componentActionURL=%@",componentActionURL);
          GSWResponse_appendContentString(aResponse,(NSString*)componentActionURL);
        };
    };
  GSWResponse_appendContentCharacter(aResponse,'"');
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(id)_imageURLInContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  //OK
  //GSWRequest* request=[aContext request];
  //Unused now BOOL isFromClientComponent=[request isFromClientComponent];
  BOOL disabledInContext=[self disabledInContext:aContext];
  GSWSaveAppendToResponseElementID(aContext);//Debug Only
  if (disabledInContext)
    {
      //TODO
    };
  GSWResponse_appendContentAsciiString(aResponse,@"<INPUT");
  [super appendToResponse:aResponse
		 inContext:aContext];
};

//--------------------------------------------------------------------
-(void)_appendDirectActionToResponse:(GSWResponse*)response
                           inContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext
{
  LOGObjectFnStart();
  GSWAssertCorrectElementID(aContext);// Debug Only
  //Does nothing ?
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
  NSDebugMLog(@"declarationName=%@ elementID=%@",
              [self declarationName],elementID);
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
/*
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
inContext:(GSWContext*)aContext
{
  GSWElement* _element=nil;
  BOOL disabledInContext=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@",
  [self class],GSWContext_elementID(aContext),GSWContext_senderID(aContext));
  GSWAssertCorrectElementID(aContext);// Debug Only
  disabledInContext=[self disabledInContext:aContext];
  if (!disabledInContext)
  {
  NSString* senderID=nil;
  NSString* elementID=nil;
  BOOL XYValues=NO;
  GSWComponent* component=nil;
	  BOOL wasFormSubmitted=NO;
	  int x=0;
	  int y=0;
	  GSWAssociation* actionAssociation=nil;
	  NSArray* regions=nil;
	  
	  component=GSWContext_component(aContext);
	  wasFormSubmitted=[aContext _wasFormSubmitted];
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
			}
		  else
			{
			  //TODO
			};

		  if (_imageMapFileName)
			{
			  id imageMapFileNameValue=[imageMapFileName valueInComponent:component];
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
			  if (element)
				{
				  if (![element isKindOfClass:[GSWComponent class]]) //TODO GSWComponent or Element ?
					{
					  ExceptionRaise0(@"GSWHyperlink",@"Invoked element return a not GSWComponent element");
					} else {
						// call awakeInContext when _element is sleeping deeply
						[element ensureAwakeInContext:aContext];
//
//						if (![element context]) {
//		  					NSDebugMLLog(@"gswdync",@"_element sleeps, awake it = %@",_element);
//							[element awakeInContext:aContext];
//						}

					}
				}
			}
		  else
			{
			  NSDebugMLLog0(@"gswdync",@"GSWActiveImage Couldn't trigger action.");
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
*/
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



//====================================================================
@implementation GSWImageButton (GSWImageButtonC)

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
