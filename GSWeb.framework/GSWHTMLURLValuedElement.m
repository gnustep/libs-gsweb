/* GSWHTMLURLValuedElement.m - GSWeb: Class GSWHTMLURLValuedElement
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

#include <gsweb/GSWeb.framework/GSWeb.h>

//====================================================================
@implementation GSWHTMLURLValuedElement

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_
{
  NSString* _urlAttributeName=nil;
  NSString* _valueAttributeName=nil;
  NSMutableDictionary* _associations=nil;
  LOGObjectFnStartC("GSWHTMLURLValuedElement");
  _urlAttributeName=[self urlAttributeName];//so what ?
  _valueAttributeName=[self valueAttributeName];//so what ?

  _associations=[NSMutableDictionary dictionaryWithDictionary:associations_];

  src = [[associations_ objectForKey:src__Key
						   withDefaultObject:[src autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"src=%@",src);

  value = [[associations_ objectForKey:value__Key
							 withDefaultObject:[value autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"value=%@",value);

  pageName = [[associations_ objectForKey:pageName__Key
								withDefaultObject:[pageName autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"pageName=%@",pageName);

  filename = [[associations_ objectForKey:filename__Key
								withDefaultObject:[filename autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"filename=%@",filename);

  framework = [[associations_ objectForKey:framework__Key
								 withDefaultObject:[framework autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"framework=%@",framework);

  data = [[associations_ objectForKey:data__Key
							 withDefaultObject:[data autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"data=%@",data);

  mimeType = [[associations_ objectForKey:mimeType__Key
							 withDefaultObject:[mimeType autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"mimeType=%@",mimeType);

  key = [[associations_ objectForKey:key__Key
							 withDefaultObject:[key autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"key=%@",key);

  actionClass = [[associations_ objectForKey:actionClass__Key
							 withDefaultObject:[actionClass autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"actionClass=%@",actionClass);

  directActionName = [[associations_ objectForKey:directActionName__Key
							 withDefaultObject:[directActionName autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"directActionName=%@",directActionName);

  queryDictionary = [[associations_ objectForKey:queryDictionary__Key
							 withDefaultObject:[queryDictionary autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"queryDictionary=%@",queryDictionary);

  [_associations removeObjectForKey:src__Key];
  [_associations removeObjectForKey:value__Key];
  [_associations removeObjectForKey:pageName__Key];
  [_associations removeObjectForKey:filename__Key];
  [_associations removeObjectForKey:framework__Key];
  [_associations removeObjectForKey:data__Key];
  [_associations removeObjectForKey:mimeType__Key];
  [_associations removeObjectForKey:key__Key];
  [_associations removeObjectForKey:actionClass__Key];
  [_associations removeObjectForKey:directActionName__Key];
  [_associations removeObjectForKey:queryDictionary__Key];
#if !GSWEB_STRICT
  //pageSetVarAssociations//GNUstepWeb only
  {
	NSDictionary* _pageSetVarAssociations=[associations_ associationsWithoutPrefix:pageSetVar__Prefix__Key
														 removeFrom:_associations];
	if ([_pageSetVarAssociations count]>0)
	  pageSetVarAssociations=[_pageSetVarAssociations retain];

	pageSetVarAssociationsDynamic=[[associations_ objectForKey:pageSetVars__Key
									   withDefaultObject:[pageSetVarAssociationsDynamic autorelease]] retain];
	NSDebugMLLog(@"gswdync",@"pageSetVarAssociationsDynamic=%@",pageSetVarAssociationsDynamic);
	[_associations removeObjectForKey:pageSetVars__Key];
  };
#endif

  if ((self=[super initWithName:[self elementName]//NEW
				   attributeAssociations:_associations
				   contentElements:elements_]))
	{
	};
  LOGObjectFnStopC("GSWHTMLURLValuedElement");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(src);
  DESTROY(value);
  DESTROY(pageName);
#if !GSWEB_STRICT
  DESTROY(pageSetVarAssociations);//GNUstepWeb only
  DESTROY(pageSetVarAssociationsDynamic);
#endif
  DESTROY(filename);
  DESTROY(framework);
  DESTROY(data);
  DESTROY(mimeType);
  DESTROY(key);
  DESTROY(actionClass);
  DESTROY(directActionName);
  DESTROY(queryDictionary);
  DESTROY(otherQueryAssociations);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)valueAttributeName
{
  //Does nothing
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)urlAttributeName
{
  //Does nothing
  return nil;
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
@implementation GSWHTMLURLValuedElement (GSWHTMLURLValuedElementA)

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  //OK
  GSWElement* _element=nil;
  NSString* _senderID=nil;
  NSString* _elementID=nil;
  LOGObjectFnStartC("GSWHTMLURLValuedElement");
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  _senderID=[context_ senderID];
  _elementID=[context_ elementID];
  NSDebugMLLog(@"gswdync",@"_senderID=%@",_senderID);
  NSDebugMLLog(@"gswdync",@"_elementID=%@",_elementID);
  NSDebugMLLog(@"gswdync",@"[_elementID isEqualToString:_senderID]=%d",(int)[_elementID isEqualToString:_senderID]);
  if ([_elementID isEqualToString:_senderID])
	{
	  GSWComponent* _component=[context_ component];
	  if (value)
		_element=[value valueInComponent:_component];
	  else if (pageName)
		{
		  NSString* _pageNameValue=[pageName valueInComponent:_component];
		  _element=[GSWApp pageWithName:_pageNameValue
						   inContext:context_];
#if !GSWEB_STRICT
		  if (_element)//GNUstepWeb only
			{
			  if (pageSetVarAssociations)
				{
				  [pageSetVarAssociations associationsSetValuesFromObject:_component
										  inObject:(GSWComponent*)_element];
				};
			  if (pageSetVarAssociationsDynamic)
				{
				  NSDictionary* _assocs=[pageSetVarAssociationsDynamic valueInComponent:_component];
				  if (_assocs)
					{
					  if (![_assocs isKindOfClass:[NSDictionary class]])
						{
						  ExceptionRaise(@"GSWHTMLURLValuedElement",@"%@ (%@) must return a Dictionary, not a %@ like %@",
										 pageSetVars__Key,
										 pageSetVarAssociationsDynamic,
										 [_assocs class],
										 _assocs);
						}
					  else
						{
						  [_assocs associationsSetValuesFromObject:_component
								   inObject:(GSWComponent*)_element];
						};
					};
				};
			};
#endif
		};
	  NSDebugMLLog(@"gswdync",@"GSWHTMLURLValuedElement invoke _element=%@",_element);
	  //the end ?
	  //TODOV
	  if (!_element)
		_element=[context_ page];
	}
  else
	{
	  _element=[super invokeActionForRequest:request_
					  inContext:context_];
	};
  NSDebugMLLog(@"gswdync",@"GSWHTMLURLValuedElement invoke _element=%@",_element);
  NSDebugMLLog(@"gswdync",@"_senderID=%@",[context_ senderID]);
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[context_ elementID]);
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
  LOGObjectFnStopC("GSWHTMLURLValuedElement");
  return _element;
};


//====================================================================
@implementation GSWHTMLURLValuedElement (GSWHTMLURLValuedElementB)

//--------------------------------------------------------------------
//NDFN
-(void)appendURLToResponse:(GSWResponse*)response_
				 inContext:(GSWContext*)context_
{
  //OK
  NSString* _urlAttributeName=nil;
  NSString* _url=nil;
  GSWComponent* _component=nil;
  NSString* _keyValue=nil;
  id _data=nil;
  id _mimeTypeValue=nil;
  GSWURLValuedElementData* _dataValue=nil;
  GSWResourceManager* _resourceManager=nil;
  LOGObjectFnStartC("GSWHTMLURLValuedElement");
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[context_ elementID]);
  _component=[context_ component];
  NSDebugMLLog(@"gswdync",@"data=%@",data);
  NSDebugMLLog(@"gswdync",@"filename=%@",filename);
  NSDebugMLLog(@"gswdync",@"pageName=%@",pageName);
  _resourceManager=[[GSWApplication application]resourceManager];
  if (src)
	_url=[src  valueInComponent:_component];
  else
	{
	  if (key)
		{
		  _keyValue=[key valueInComponent:_component];
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
		  [_resourceManager setURLValuedElementData:_dataValue];
		}
	  else if (filename)
		{
		  //Exemple: Body with filename
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
		};
	};
  [response_ appendContentCharacter:' '];
  _urlAttributeName=[self urlAttributeName];
  if (_urlAttributeName)
	{
	  [response_ _appendContentAsciiString:_urlAttributeName];
	  [response_ _appendContentAsciiString:@"=\""];
	};
  if (src)
	{
	  [response_ appendContentString:_url];
	}
  else
	{	
	  if (key || data)
		{
		  [_dataValue appendDataURLToResponse:response_
					  inContext:context_];
		}
	  else if (filename)
		{
		  [response_ appendContentString:_url];
		}
	  else
		{
		  GSWDynamicURLString* _componentActionURL=[context_ componentActionURL];
		  NSDebugMLLog(@"gswdync",@"_componentActionURL=%@",_componentActionURL);
		  [response_ appendContentString:(NSString*)_componentActionURL];
		};
	};
  if (_urlAttributeName)
	[response_ appendContentCharacter:'"'];
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[context_ elementID]);
  LOGObjectFnStopC("GSWHTMLURLValuedElement");
};

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
									  inContext:(GSWContext*)context_
{
  //OK
  LOGObjectFnStartC("GSWHTMLURLValuedElement");
  [self appendURLToResponse:response_
		inContext:context_];
  LOGObjectFnStopC("GSWHTMLURLValuedElement");
};

//--------------------------------------------------------------------
-(void)_appendCGIActionURLToResponse:(GSWResponse*)response_
						   inContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(id)computeActionStringInContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)computeQueryDictionaryInContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
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
@end
