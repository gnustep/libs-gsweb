/** GSWImageButton.m - <title>GSWeb: Class GSWImageButton</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

static char rcsId[] = "$Id$";

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
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response
                                      inContext:(GSWContext*)context
{
  //OK
  NSString* urlValue=nil;
  NSString* name=nil;
  BOOL disabledInContext=NO;
  GSWComponent* component=nil;
  GSWResourceManager* resourceManager=nil;
  GSWURLValuedElementData* dataValue=nil;
  NSString* keyValue=nil;
  LOGObjectFnStart();
  disabledInContext=[self disabledInContext:context];
  [response _appendContentAsciiString:@" type=image"];
  name=[self nameInContext:context];
  NSDebugMLLog(@"gswdync",@"definition name=%@ name=%@",
               [self definitionName],name);
  [response _appendContentAsciiString:@" name=\""];
  [response appendContentHTMLAttributeValue:name];
  [response appendContentCharacter:'"'];
  component=[context component];
  resourceManager=[[GSWApplication application]resourceManager];
  if (_src)
    urlValue=[_src valueInComponent:component];
  else
    {
      if (_key)
        {
          keyValue=[_key valueInComponent:component];
          dataValue=[resourceManager _cachedDataForKey:keyValue];
        };
      if (!dataValue && _data)
        {
          id tmpDataValue=[_data valueInComponent:component];
          id mimeTypeValue=[_mimeType valueInComponent:component];
          dataValue=[[[GSWURLValuedElementData alloc] initWithData:tmpDataValue
                                                      mimeType:mimeTypeValue
                                                      key:keyValue] autorelease];
          [resourceManager setURLValuedElementData:dataValue];
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
          frameworkValue=[self frameworkNameInContext:context];
          NSDebugMLLog(@"gswdync",@"frameworkValue=%@",frameworkValue);
          request=[context request];
          languages=[context languages];
          urlValue=[resourceManager urlForResourceNamed:filenameValue
                                    inFramework:frameworkValue
                                    languages:languages
                                    request:request];
        };
    };

  [response _appendContentAsciiString:@" src=\""];
  if (_src)
    {
      [response appendContentString:urlValue];
    }
  else
    {
      if (_key || _data)
        {
          [dataValue appendDataURLToResponse:response
                     inContext:context];
        }
      else if (_filename)
        {
          [response appendContentString:urlValue];
        }
      else
        {
          GSWDynamicURLString* componentActionURL=[context componentActionURL];
          NSDebugMLLog(@"gswdync",@"componentActionURL=%@",componentActionURL);
          [response appendContentString:(NSString*)componentActionURL];
        };
    };
  [response appendContentCharacter:'"'];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(id)_imageURLInContext:(GSWContext*)context
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  //OK
  GSWRequest* request=[context request];
  BOOL isFromClientComponent=[request isFromClientComponent];
  BOOL disabledInContext=[self disabledInContext:context];
  GSWSaveAppendToResponseElementID(context);//Debug Only
  if (disabledInContext)
    {
      //TODO
    };
  [response _appendContentAsciiString:@"<INPUT"];
  [super appendToResponse:response
		 inContext:context];
};

//--------------------------------------------------------------------
-(void)_appendDirectActionToResponse:(GSWResponse*)response
                           inContext:(GSWContext*)context
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  LOGObjectFnStart();
  GSWAssertCorrectElementID(context);// Debug Only
  //Does nothing ?
  LOGObjectFnStop();
};




//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
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
  component=[context component];
  [context appendZeroElementIDComponent];
  senderID=[context senderID];
  NSDebugMLog(@"senderID=%@",senderID);
  elementID=[context elementID];
  NSDebugMLog(@"definition name=%@ elementID=%@",
              [self definitionName],elementID);
  if ([elementID isEqualToString:senderID])
    {
      //TODO
    };
  [context deleteLastElementIDComponent];
  disabledInContext=[self disabledInContext:context];
  if (!disabledInContext)
    {
      isInForm=[context isInForm];
      if (isInForm)
        {
          BOOL wasFormSubmitted=[context _wasFormSubmitted];
          if (wasFormSubmitted)
            {
              NSString* nameInContext=[self nameInContext:context];
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
          elementID=[context elementID];
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
              NSString* imageMapFilePath=[[context component]
                                           pathForResourceNamed:imageMapFileNameValue
                                           ofType:nil];
              if (!imageMapFilePath)
                {
                  GSWResourceManager* resourceManager=[[GSWApplication application]resourceManager];
                  NSArray* languages=[context languages];
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
            [_xAssoc setValue:[NSNumber numberWithInt:x]
                     inComponent:component];
          if (_yAssoc)
            [_yAssoc setValue:[NSNumber numberWithInt:y]
                     inComponent:component];
	  
          actionAssociation=[self hitTestX:x
                                  y:y
                                  inRegions:regions];
          if (actionAssociation)
            {
              [context _setActionInvoked:YES];
              element=[actionAssociation valueInComponent:component];

              if (element && [element isKindOfClass:[GSWComponent class]])
                {
                  // call awakeInContext when _element is sleeping deeply
                  [element ensureAwakeInContext:context];
                }
            }
          else
            {
              /*			  if (href)
                                          {
                                          [context _setActionInvoked:YES];
                                          //TODO redirect to href
                                          }
                                          else*/ 
              if (_action)
                {
                  [context _setActionInvoked:YES];
                  element=[_action valueInComponent:component];
                  
                  if (element && [element isKindOfClass:[GSWComponent class]])
                    {
                      // call awakeInContext when _element is sleeping deeply
                      [element ensureAwakeInContext:context];
                    }
                }
              else
                {				
                  NSDebugMLLog0(@"gswdync",@"GSWActiveImage Couldn't trigger action.");
                };
            };
          if (!element)
            element=[context page];
        }
      else
        element=[super invokeActionForRequest:request
                       inContext:context];
    }
  else
    element=[super invokeActionForRequest:request
                   inContext:context];
  LOGObjectFnStop();
  return element;
};


//--------------------------------------------------------------------
/*
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
inContext:(GSWContext*)context
{
  GSWElement* _element=nil;
  BOOL disabledInContext=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@",
  [self class],[context elementID],[context senderID]);
  GSWAssertCorrectElementID(context);// Debug Only
  disabledInContext=[self disabledInContext:context];
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
	  
	  component=[context component];
	  wasFormSubmitted=[context _wasFormSubmitted];
	  if (wasFormSubmitted)
		{
		  NSString* nameInContext=[self nameInContext:context];
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
			  NSString* imageMapFilePath=[[context component]
                          pathForResourceNamed:imageMapFileNameValue
                          ofType:nil];
			  if (!imageMapFilePath)
				{
				  GSWResourceManager* resourceManager=[[GSWApplication application]resourceManager];
				  NSArray* languages=[context languages];
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
			[_xAssoc setValue:[NSNumber numberWithInt:x]
					inComponent:component];
		  if (_yAssoc)
			[_yAssoc setValue:[NSNumber numberWithInt:y]
					inComponent:component];
		  
		  actionAssociation=[self hitTestX:x
								   y:y
								   inRegions:regions];
		  if (actionAssociation)
			{
			  [context _setActionInvoked:YES];
			  element=[actionAssociation valueInComponent:component];
			  if (element)
				{
				  if (![element isKindOfClass:[GSWComponent class]]) //TODO GSWComponent or Element ?
					{
					  ExceptionRaise0(@"GSWHyperlink",@"Invoked element return a not GSWComponent element");
					} else {
						// call awakeInContext when _element is sleeping deeply
						[element ensureAwakeInContext:context];
//
//						if (![element context]) {
//		  					NSDebugMLLog(@"gswdync",@"_element sleeps, awake it = %@",_element);
//							[element awakeInContext:context];
//						}

					}
				}
			}
		  else
			{
			  NSDebugMLLog0(@"gswdync",@"GSWActiveImage Couldn't trigger action.");
			};
		  if (!element)
			element=[context page];
		}
	  else
		element=[super invokeActionForRequest:request
						inContext:context];
	}
  else
	element=[super invokeActionForRequest:request
					inContext:context];
  LOGObjectFnStop();
  return element;
};
*/
//--------------------------------------------------------------------
-(NSString*)frameworkNameInContext:(GSWContext*)context
{
  //OK
  NSString* frameworkName=nil;  
  GSWComponent* component=[context component];
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
