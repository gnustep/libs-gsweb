/* GSWActiveImage.m - GSWeb: Class GSWActiveImage
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
   This file is part of the GNUstep Web Library.
   
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
*/

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWActiveImage

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_
{
  //OK
  NSMutableDictionary* _associations=nil;
  LOGObjectFnStart();
  NSDebugMLog(@"name_=%@ associations_:%@ elements_=%@",name_,associations_,elements_);
  _associations=[NSMutableDictionary dictionaryWithDictionary:associations_];
  [_associations removeObjectForKey:imageMapFileName__Key];
  if (!WOStrictFlag)
    {
      [_associations removeObjectForKey:imageMapString__Key];
      [_associations removeObjectForKey:imageMapRegions__Key];
    };
  [_associations removeObjectForKey:action__Key];
  [_associations removeObjectForKey:href__Key];
  [_associations removeObjectForKey:src__Key];
  [_associations removeObjectForKey:x__Key];
  [_associations removeObjectForKey:y__Key];
  [_associations removeObjectForKey:target__Key];
  [_associations removeObjectForKey:filename__Key];
  [_associations removeObjectForKey:framework__Key];
  [_associations removeObjectForKey:data__Key];
  [_associations removeObjectForKey:mimeType__Key];
  [_associations removeObjectForKey:key__Key];

  if ((self=[super initWithName:name_
				   associations:_associations
				   contentElements:elements_]))
	{
	  int _imageMapDefNb=0;
	  imageMapFileName = [[associations_ objectForKey:imageMapFileName__Key
									 withDefaultObject:[imageMapFileName autorelease]] retain];
	  if (imageMapFileName)
		_imageMapDefNb++;

          if (!WOStrictFlag)
            {
              imageMapString = [[associations_ objectForKey:imageMapString__Key
                                               withDefaultObject:[imageMapString autorelease]] retain];
              if (imageMapString)
		_imageMapDefNb++;
              
              imageMapRegions = [[associations_ objectForKey:imageMapRegions__Key
                                                withDefaultObject:[imageMapRegions autorelease]] retain];
              if (imageMapRegions)
		_imageMapDefNb++;
              if (_imageMapDefNb>0)
		{
		  ExceptionRaise(@"GSWActiveImage",@"you can't specify %@, %@ and %@",
                                 imageMapFileName__Key,
                                 imageMapString__Key,
                                 imageMapRegions__Key);
		};
            };	  
	  action = [[associations_ objectForKey:action__Key
								  withDefaultObject:[action autorelease]] retain];

	  href = [[associations_ objectForKey:href__Key
							 withDefaultObject:[href autorelease]] retain];

	  src = [[associations_ objectForKey:src__Key
							withDefaultObject:[src autorelease]] retain];

	  xAssoc = [[associations_ objectForKey:x__Key
							   withDefaultObject:[xAssoc autorelease]] retain];
	  if (xAssoc && ![xAssoc isValueSettable])
		{
		  ExceptionRaise0(@"GSWActiveImage",@"'x' parameter must be settable");
		};

	  yAssoc = [[associations_ objectForKey:y__Key
							   withDefaultObject:[yAssoc autorelease]] retain];
	  if (yAssoc && ![yAssoc isValueSettable])
		{
		  ExceptionRaise0(@"GSWActiveImage",@"'y' parameter must be settable");
		};

	  target = [[associations_ objectForKey:target__Key
							   withDefaultObject:[target autorelease]] retain];

	  filename = [[associations_ objectForKey:filename__Key
								 withDefaultObject:[filename autorelease]] retain];
	  
	  framework = [[associations_ objectForKey:framework__Key
								  withDefaultObject:[framework autorelease]] retain];

	  data = [[associations_ objectForKey:data__Key
							 withDefaultObject:[data autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"data=%@",data);
	  action = [[associations_ objectForKey:action__Key
							   withDefaultObject:[action autorelease]] retain];

	  mimeType = [[associations_ objectForKey:mimeType__Key
								 withDefaultObject:[mimeType autorelease]] retain];

	  key = [[associations_ objectForKey:key__Key
							withDefaultObject:[key autorelease]] retain];

	};
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(imageMapFileName);
  DESTROY(imageMapString);
  DESTROY(imageMapRegions);
  DESTROY(action);
  DESTROY(href);
  DESTROY(src);
  DESTROY(xAssoc);
  DESTROY(yAssoc);
  DESTROY(target);
  DESTROY(filename);
  DESTROY(framework);
  DESTROY(data);
  DESTROY(mimeType);
  DESTROY(key);
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

//====================================================================
@implementation GSWActiveImage (GSWActiveImageA)
-(GSWAssociation*)hitTestX:(int)x_
						 y:(int)y_
				 inRegions:(NSArray*)regions_
{
  GSWAssociation* _assoc=nil;
  GSWGeometricRegion* _region=[GSWGeometricRegion hitTestX:x_
												  y:y_
												  inRegions:regions_];
  if (_region)
	_assoc=[GSWAssociation associationWithKeyPath:[_region userDefinedString]];
  else
	_assoc=action;
  return _assoc;
};
@end


//====================================================================
@implementation GSWActiveImage (GSWActiveImageB)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  LOGObjectFnStart();
  //Does nothing
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  GSWElement* _element=nil;
  NSString* _senderID=nil;
  NSString* _elementID=nil;
  BOOL _disabledInContext=NO;
  BOOL _isInForm=NO;
  BOOL _XYValues=NO;
  BOOL _thisOne=NO;
  GSWComponent* _component=nil;
  int _x=0;
  int _y=0;
  LOGObjectFnStart();
  _component=[context_ component];
  [context_ appendZeroElementIDComponent];
  _senderID=[context_ senderID];
  NSDebugMLog(@"_senderID=%@",_senderID);
  _elementID=[context_ elementID];
  NSDebugMLog(@"_elementID=%@",_elementID);
  if ([_elementID isEqualToString:_senderID])
	{
	  //TODO
	};
  [context_ deleteLastElementIDComponent];
  _disabledInContext=[self disabledInContext:context_];
  if (!_disabledInContext)
	{
	  _isInForm=[context_ isInForm];
	  if (_isInForm)
		{
		  BOOL _wasFormSubmitted=[context_ _wasFormSubmitted];
		  if (_wasFormSubmitted)
			{
			  NSString* _nameInContext=[self nameInContext:context_];
			  NSString* _formValueX=[request_ formValueForKey:[NSString stringWithFormat:@"%@.x",
																		_nameInContext]];
			  NSString* _formValueY=[request_ formValueForKey:[NSString stringWithFormat:@"%@.y",
																		_nameInContext]];
			  NSDebugMLLog(@"gswdync",@"_formValueX=%@",_formValueX);
			  NSDebugMLLog(@"gswdync",@"_formValueY=%@",_formValueY);
			  if (_formValueX && _formValueY)
				{
				  _x=[_formValueX intValue];
				  _y=[_formValueY intValue];
				  _XYValues=YES;
				  _thisOne=YES;
				}
			  else
				{
				  //TODO
				};
			};
		}
	  else
		{
		  _elementID=[context_ elementID];
		  NSDebugMLog(@"_elementID=%@",_elementID);
		  if ([_elementID isEqualToString:_senderID])
			{
			  id _param=[request_ formValueForKey:GSWKey_IsmapCoords[GSWebNamingConv]];
			  NSDebugMLLog(@"gswdync",@"_param=%@",_param);
			  if (_param)
				{
				  if ([_param ismapCoordx:&_x
							  y:&_y])
					_XYValues=YES;
				  else
					{
					  //TODO
					};
				};
			  _thisOne=YES;
			};
		};
	  if (_thisOne)
		{
		  GSWAssociation* _actionAssociation=nil;
		  NSArray* _regions=nil;
		  if (imageMapFileName)
			{
			  id _imageMapFileNameValue=[imageMapFileName valueInComponent:_component];
			  NSString* _imageMapFilePath=[[context_ component]
											pathForResourceNamed:_imageMapFileNameValue
											ofType:nil];
			  if (!_imageMapFilePath)
				{
				  GSWResourceManager* _resourceManager=[[GSWApplication application]resourceManager];
				  NSArray* _languages=[context_ languages];
				  _imageMapFilePath=[_resourceManager pathForResourceNamed:_imageMapFileNameValue
													  inFramework:nil
													  languages:_languages];
			  
				};
			  if (_imageMapFilePath)
				_regions=[GSWGeometricRegion geometricRegionsWithFile:_imageMapFilePath];
			  else
				{
				  NSDebugMLLog0(@"gswdync",@"GSWActiveImage No image Map.");
				};
			}
		  else if (!WOStrictFlag && imageMapString)
			{
			  id _imageMapValue=[imageMapString valueInComponent:_component];
			  _regions=[GSWGeometricRegion geometricRegionsWithString:_imageMapValue];
			}
		  else if (!WOStrictFlag && imageMapRegions)
			{
			  _regions=[imageMapRegions valueInComponent:_component];
			};
		  if (xAssoc)
			[xAssoc setValue:[NSNumber numberWithInt:_x]
					inComponent:_component];
		  if (yAssoc)
			[yAssoc setValue:[NSNumber numberWithInt:_y]
					inComponent:_component];
	  
		  _actionAssociation=[self hitTestX:_x
								   y:_y
								   inRegions:_regions];
		  if (_actionAssociation)
			{
			  [context_ _setActionInvoked:YES];
			  _element=[_actionAssociation valueInComponent:_component];
			}
		  else
			{
			  if (href)
				{
				  [context_ _setActionInvoked:YES];
				  //TODO redirect to href
				}
			  else if (action)
				{
				  [context_ _setActionInvoked:YES];
				  _element=[action valueInComponent:_component];
				}
			  else
				{				
				  NSDebugMLLog0(@"gswdync",@"GSWActiveImage Couldn't trigger action.");
				};
			};
		  if (!_element)
			_element=[context_ page];
		}
	  else
		_element=[super invokeActionForRequest:request_
						inContext:context_];
	}
  else
	_element=[super invokeActionForRequest:request_
					inContext:context_];
  LOGObjectFnStop();
  return _element;
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
  GSWRequest* _request=[context_ request];
  BOOL _isFromClientComponent=[_request isFromClientComponent];
  BOOL _disabledInContext=[self disabledInContext:context_];
  BOOL _isInForm=NO;
  _isInForm=[context_ isInForm]; //TODO
  if (_isInForm)
	{
	  if (!_disabledInContext)
	    [response_ _appendContentAsciiString:@"<INPUT "];
	  else
	    [response_ _appendContentAsciiString:@"<IMG "];
	}
  else
	{
	  if (!_disabledInContext)
		{
		  NSString* _href=nil;
		  [response_ _appendContentAsciiString:@"<A HREF=\""];
		  if (href)
			_href=[self hrefInContext:context_];
		  else
			_href=(NSString*)[context_ componentActionURL];
		  [response_ appendContentString:_href];
		  [response_ _appendContentAsciiString:@"\">"];
		};
	  [response_ _appendContentAsciiString:@"<IMG"];
	};
  [super appendToResponse:response_
		 inContext:context_];
  if (!_isInForm)
	{
	  if (!_disabledInContext)
		{
		  [response_ _appendContentAsciiString:@"</A>"];
		};
	};
};

//--------------------------------------------------------------------
-(NSString*)frameworkNameInContext:(GSWContext*)context_
{
  //OK
  NSString* _frameworkName=nil;  
  GSWComponent* _component=[context_ component];
  NSDebugMLog(@"framework=%@",framework);
  if (framework)
	_frameworkName=[framework valueInComponent:_component];
  else
	_frameworkName=[_component frameworkName];
  return _frameworkName;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)imageSourceInContext:(GSWContext*)context_
{
  GSWComponent* _component=nil;
  NSString* _imageSource=nil;
  _component=[context_ component];
  _imageSource=[src valueInComponent:_component];
  return _imageSource;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)hrefInContext:(GSWContext*)context_
{
  GSWComponent* _component=nil;
  NSString* _href=nil;
  _component=[context_ component];
  _href=[href valueInComponent:_component];
  return _href;
};
@end

//====================================================================
@implementation GSWActiveImage (GSWActiveImageC)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
									  inContext:(GSWContext*)context_
{
  //OK
  NSString* _url=nil;
  GSWComponent* _component=nil;
  id _data=nil;
  id _mimeTypeValue=nil;
  GSWURLValuedElementData* _dataValue=nil;
  GSWResourceManager* _resourceManager=nil;
  BOOL _disabledInContext=NO;
  BOOL _isInForm=NO;
  LOGObjectFnStartC("GSWActiveImage");
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[context_ elementID]);
  _component=[context_ component];
  _disabledInContext=[self disabledInContext:context_];
  _isInForm=[context_ isInForm];

  if (!_disabledInContext)
    {
      if (_isInForm)
	{
	  NSString* _nameInContext=[self nameInContext:context_];
	  [response_ _appendContentAsciiString:@" type=image"];
	  [response_ _appendContentAsciiString:@" name=\""];
	  [response_ appendContentHTMLAttributeValue:_nameInContext];
	  [response_ appendContentCharacter:'"'];
	}
      else
	{
	  [response_ _appendContentAsciiString:@" ismap"];
	};
    }

  NSDebugMLLog(@"gswdync",@"data=%@",data);
  NSDebugMLLog(@"gswdync",@"filename=%@",filename);
  if (key)
	{
	  NSString* _keyValue=[key valueInComponent:_component];
	  _dataValue=[_resourceManager _cachedDataForKey:_keyValue];
	};
  if (!_dataValue && data)
	{
	  _data=[data valueInComponent:_component];  
	  NSDebugMLLog(@"gswdync",@"_data=%@",_data);
	  _mimeTypeValue=[mimeType valueInComponent:_component];
	  NSDebugMLLog(@"gswdync",@"mimeType=%@",mimeType);
	  NSDebugMLLog(@"gswdync",@"_mimeTypeValue=%@",_mimeTypeValue);
	  _dataValue=[[[GSWURLValuedElementData alloc] initWithData:_data
												   mimeType:_mimeTypeValue
												   key:nil] autorelease];
	  NSDebugMLLog(@"gswdync",@"_dataValue=%@",_dataValue);
	};
  _resourceManager=[[GSWApplication application]resourceManager];
  if (key || data)
	{
	  [_resourceManager setURLValuedElementData:_dataValue];
	}
  else if (filename)
	{
	  id _filenameValue=nil;
	  id _frameworkValue=nil;
	  GSWRequest* _request=nil;
	  NSArray* _languages=nil;
	  NSDebugMLLog(@"gswdync",@"filename=%@",filename);
	  _filenameValue=[filename valueInComponent:_component];
	  NSDebugMLLog(@"gswdync",@"_filenameValue=%@",_filenameValue);
	  _frameworkValue=[self frameworkNameInContext:context_];
	  NSDebugMLLog(@"gswdync",@"_frameworkValue=%@",_frameworkValue);
	  _request=[context_ request];
	  _languages=[context_ languages];
	  _url=[_resourceManager urlForResourceNamed:_filenameValue
							 inFramework:_frameworkValue
							 languages:_languages
							 request:_request];
	  if (!_url)
		{
		  LOGSeriousError(@"No URL for resource named: %@ in framework named: %@ for languages: %@",
						  _filenameValue,
						  _frameworkValue,
						  _languages);
		};
	};
  [response_ _appendContentAsciiString:@" src=\""];
  if (key || data)
	{
	  [_dataValue appendDataURLToResponse:response_
				  inContext:context_];
	}
  else if (filename)
	{
	  [response_ appendContentString:_url];
	}
  else if (src)
	{
	  NSString* _src=[self imageSourceInContext:context_];
	  [response_ appendContentString:_src];	  
	}
  else
	{
	  GSWDynamicURLString* _componentActionURL=[context_ componentActionURL];
	  NSDebugMLLog(@"gswdync",@"_componentActionURL=%@",_componentActionURL);
	  [response_ appendContentString:(NSString*)_componentActionURL];
	};
  [response_ appendContentCharacter:'"'];
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[context_ elementID]);
  LOGObjectFnStopC("GSWActiveImage");
};


@end


//====================================================================
@implementation GSWActiveImage (GSWActiveImageD)

//--------------------------------------------------------------------
-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)appendStringAtLeft:(id)_unkwnon
			  withMapping:(char*)_mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};
@end

