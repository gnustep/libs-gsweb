/* GSWHyperlink.m - GSWeb: Class GSWHyperlink
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
@implementation GSWHyperlink

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
		 template:(GSWElement*)templateElement
{
  //OK
  NSMutableDictionary* _otherAssociations=nil;
  LOGObjectFnStart();
  ASSIGN(children,templateElement);
  action = [[associations_ objectForKey:action__Key
							  withDefaultObject:[action autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"action=%@",action);

  string = [[associations_ objectForKey:string__Key
							  withDefaultObject:[string autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"string=%@",string);

  pageName = [[associations_ objectForKey:pageName__Key
							 withDefaultObject:[pageName autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"pageName=%@",pageName);

  href = [[associations_ objectForKey:href__Key
						 withDefaultObject:[href autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"href=%@",href);

  disabled = [[associations_ objectForKey:disabled__Key
							 withDefaultObject:[disabled autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"disabled=%@",disabled);

  fragmentIdentifier = [[associations_ objectForKey:fragmentIdentifier__Key
									   withDefaultObject:[fragmentIdentifier autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"fragmentIdentifier=%@",fragmentIdentifier);

  queryDictionary = [[associations_ objectForKey:queryDictionary__Key
							  withDefaultObject:[queryDictionary autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"queryDictionary=%@",queryDictionary);

  actionClass = [[associations_ objectForKey:actionClass__Key
							withDefaultObject:[actionClass autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"actionClass=%@",actionClass);

  directActionName = [[associations_ objectForKey:directActionName__Key
							withDefaultObject:[directActionName autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"directActionName=%@",directActionName);

#if !GSWEB_STRICT
  enabled = [[associations_ objectForKey:enabled__Key
							withDefaultObject:[enabled autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"enabled=%@",enabled);
  if (disabled && enabled)
	{
	  ExceptionRaise(@"GSWHyperlink",@"You can't specify 'disabled' and 'enabled' together. componentAssociations:%@",
					 associations_);
	};

  displayDisabled = [[associations_ objectForKey:displayDisabled__Key
									withDefaultObject:[displayDisabled autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"displayDisabled=%@",displayDisabled);

  redirectURL = [[associations_ objectForKey:redirectURL__Key
								withDefaultObject:[redirectURL autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"redirectURL=%@",redirectURL);
#endif

#if !GSWEB_STRICT
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
#endif

  _otherAssociations=[NSMutableDictionary dictionaryWithDictionary:associations_];
  [_otherAssociations removeObjectForKey:action__Key];
  [_otherAssociations removeObjectForKey:string__Key];
  [_otherAssociations removeObjectForKey:pageName__Key];
  [_otherAssociations removeObjectForKey:href__Key];
  [_otherAssociations removeObjectForKey:disabled__Key];
  [_otherAssociations removeObjectForKey:fragmentIdentifier__Key];
  [_otherAssociations removeObjectForKey:queryDictionary__Key];
  [_otherAssociations removeObjectForKey:actionClass__Key];
  [_otherAssociations removeObjectForKey:directActionName__Key];
#if !GSWEB_STRICT
  [_otherAssociations removeObjectForKey:enabled__Key];
  [_otherAssociations removeObjectForKey:redirectURL__Key];
#endif

#if !GSWEB_STRICT
  [_otherAssociations removeObjectForKey:filename__Key];
  [_otherAssociations removeObjectForKey:framework__Key];
  [_otherAssociations removeObjectForKey:data__Key];
  [_otherAssociations removeObjectForKey:mimeType__Key];
  [_otherAssociations removeObjectForKey:key__Key];
#endif

#if !GSWEB_STRICT
  //pageSetVarAssociations//GNUstepWeb only
  {
	NSDictionary* _pageSetVarAssociations=[associations_ associationsWithoutPrefix:pageSetVar__Prefix__Key
														 removeFrom:_otherAssociations];
	if ([_pageSetVarAssociations count]>0)
	  pageSetVarAssociations=[_pageSetVarAssociations retain];

	pageSetVarAssociationsDynamic=[[associations_ objectForKey:pageSetVars__Key
									   withDefaultObject:[pageSetVarAssociationsDynamic autorelease]] retain];
	NSDebugMLLog(@"gswdync",@"pageSetVarAssociationsDynamic=%@",pageSetVarAssociationsDynamic);
	[_otherAssociations removeObjectForKey:pageSetVars__Key];
  };
#endif

  if ([_otherAssociations count]>0)
	  otherAssociations=[[NSDictionary dictionaryWithDictionary:_otherAssociations] retain];

  //TODO NSDictionary* otherQueryAssociations;

  if ((self=[super initWithName:name_
				   associations:nil
				   template:nil]))
	{
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(action);
  DESTROY(string);
  DESTROY(pageName);
  DESTROY(href);
  DESTROY(disabled);
  DESTROY(fragmentIdentifier);
  DESTROY(queryDictionary);
  DESTROY(actionClass);
  DESTROY(directActionName);
#if !GSWEB_STRICT
  DESTROY(enabled);
  DESTROY(displayDisabled);
  DESTROY(redirectURL);
  DESTROY(pageSetVarAssociations);//GNUstepWeb only
  DESTROY(pageSetVarAssociationsDynamic);
#endif
  DESTROY(otherQueryAssociations);
  DESTROY(otherAssociations);
#if !GSWEB_STRICT
  DESTROY(filename);
  DESTROY(framework);
  DESTROY(data);
  DESTROY(mimeType);
  DESTROY(key);
#endif
  DESTROY(children);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
				   object_get_class_name(self),
				   (void*)self];
};

@end

//====================================================================
@implementation GSWHyperlink (GSWHyperlinkA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK (pageName/action/directActionName)
  GSWComponent* _component=[context_ component];
  BOOL _disabled=NO;
#if !GSWEB_STRICT
  BOOL _displayDisabled=YES;
#endif
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  GSWSaveAppendToResponseElementID(context_);//Debug Only
  if (disabled)
	_disabled=[self evaluateCondition:disabled
					inContext:context_];
  else if (enabled)
	_disabled=![self evaluateCondition:enabled
					 inContext:context_];
#if !GSWEB_STRICT
  if (disabled && displayDisabled)
	{
	  _displayDisabled=[self evaluateCondition:displayDisabled
							 inContext:context_];
	};
#endif
  if (!_disabled)
	{
	  [response_ _appendContentAsciiString:@"<A "];
	  [response_ _appendContentAsciiString:@"href"];
	  [response_ appendContentCharacter:'='];
	  [response_ appendContentCharacter:'"'];
	  if (directActionName)
		{
		  //OK
		  [self _appendCGIActionURLToResponse:response_
				inContext:context_];
		}
	  else if (action || pageName || redirectURL)
		{
		  NSString* _url=[context_ componentActionURL];
		  NSDebugMLLog(@"gswdync",@"_url=%@",_url);
		  [response_ appendContentString:_url];
		  [self _appendQueryStringToResponse:response_
				inContext:context_];
		}
	  else if (href)
		{
		  NSString* _hrefValue=[self hrefInContext:context_];
		  [response_ appendContentString:_hrefValue];
		  if (!_hrefValue)
			{
			  LOGSeriousError(@"href=%@ shouldn't return a nil value",href);
			};
		  NSDebugMLLog(@"gswdync",@"href=%@",href);
		  NSDebugMLLog(@"gswdync",@"_hrefValue=%@",_hrefValue);
		}
#if !GSWEB_STRICT
	  else if (filename || data)
		{
		  NSString* _url=nil;
		  NSString* _keyValue=nil;
		  id _data=nil;
		  id _mimeTypeValue=nil;
		  GSWURLValuedElementData* _dataValue=nil;
		  GSWResourceManager* _resourceManager=nil;
		  _resourceManager=[[GSWApplication application]resourceManager];
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
		  if (key || data)
			{
			  [_dataValue appendDataURLToResponse:response_
						  inContext:context_];
			}
		  else if (filename)
			{
			  [response_ appendContentString:_url];
			};
#endif
		}
	  else
		{		  
		  LOGObjectFnNotImplemented();	//TODOFN
		};
	  [response_ appendContentCharacter:'"'];
	  NSDebugMLLog(@"gswdync",@"otherAssociations=%@",otherAssociations);
	  if (otherAssociations)
		{
		  NSEnumerator *enumerator = [otherAssociations keyEnumerator];
		  id _key=nil;
		  id _oaValue=nil;
		  while ((_key = [enumerator nextObject]))
			{
			  NSDebugMLLog(@"gswdync",@"_key=%@",_key);
			  _oaValue=[[otherAssociations objectForKey:_key] valueInComponent:_component];
			  NSDebugMLLog(@"gswdync",@"_oaValue=%@",_oaValue);
			  [response_ appendContentCharacter:' '];
			  [response_ _appendContentAsciiString:_key];
			  [response_ appendContentCharacter:'='];
			  [response_ appendContentCharacter:'"'];
			  [response_ appendContentHTMLString:_oaValue];
			  [response_ appendContentCharacter:'"'];
			};
		};
	  [response_ appendContentCharacter:'>'];
	};
  if (!_disabled || _displayDisabled)
	{
	  if (string)
		{
		  id _stringValue=nil;
		  NSDebugMLLog(@"gswdync",@"string=%@",string);
		  _stringValue=[string valueInComponent:_component];
		  NSDebugMLLog(@"gswdync",@"_stringValue=%@",_stringValue);
		  if (_stringValue)
			[response_ appendContentHTMLString:_stringValue];
		};
	  if (children)
		{
		  [context_ appendZeroElementIDComponent];
		  [children appendToResponse:response_
					inContext:context_];
		  [context_ deleteLastElementIDComponent];
		};
	};
  if (!_disabled)//??
	{
	  [response_ _appendContentAsciiString:@"</a>"];
	};
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWHyperlink appendToResponse: bad elementID");
#endif
  LOGObjectFnStop();
};

#if !GSWEB_STRICT
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
#endif
//--------------------------------------------------------------------
-(void)_appendCGIActionURLToResponse:(GSWResponse*)response_
						   inContext:(GSWContext*)context_
{
  //OK
  NSString* _actionString=nil;
  NSDictionary* _queryDictionary=nil;
  NSString* _url=nil;
  LOGObjectFnStart();
  _actionString=[self computeActionStringInContext:context_];
  NSDebugMLLog(@"gswdync",@"_actionString=%@",_actionString);
  _queryDictionary=[self computeQueryDictionaryInContext:context_];
  NSDebugMLLog(@"gswdync",@"_queryDictionary=%@",_queryDictionary);
  _url=(NSString*)[context_ directActionURLForActionNamed:_actionString
							queryDictionary:_queryDictionary];
  NSDebugMLLog(@"gswdync",@"_url=%@",_url);
  [response_ appendContentString:_url];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(id)computeActionStringInContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _component=nil;
  id _directActionString=nil;
  id _directActionName=nil;
  id _actionClass=nil;
  LOGObjectFnStart();
  _component=[context_ component];
  if (directActionName)
	_directActionName=[directActionName valueInComponent:_component];
  if (actionClass)
	_actionClass=[actionClass valueInComponent:_component];

  if (_actionClass)
	{
	  if (_directActionName)
		_directActionString=[NSString stringWithFormat:@"%@/%@",
									  _actionClass,
									  _directActionName];
	  else
		_directActionString=_actionClass;
	}
  else if (_directActionName)
	_directActionString=_directActionName;
  else
	{
	  LOGSeriousError(@"No actionClass (for %@) and no directActionName (for %@)",
					  actionClass,
					  directActionName);
	};

  NSDebugMLLog(@"gswdync",@"_directActionString=%@",_directActionString);
  LOGObjectFnStop();
  return _directActionString;
};

//--------------------------------------------------------------------
-(void)_appendQueryStringToResponse:(GSWResponse*)response_
						   inContext:(GSWContext*)context_
{
  //OK
  NSDictionary* _queryDictionary=nil;
  LOGObjectFnStart();
  _queryDictionary=[self computeQueryDictionaryInContext:context_];

  //TODOV
  if (_queryDictionary && [_queryDictionary count]>0)
	{
	  NSEnumerator* _enumerator = [_queryDictionary keyEnumerator];
	  id _key=nil;
	  id _value=nil;
	  BOOL first=YES;
	  [response_ appendContentCharacter:'?'];
	  while ((_key = [_enumerator nextObject]))
		{
		  if (first)
			first=NO;
		  else
			[response_ appendContentCharacter:'&'];
		  [response_ appendContentHTMLString:_key];
		  _value=[_queryDictionary objectForKey:_key];
		  _value=[_value description];
		  if ([_value length]>0)
			{
			  [response_ appendContentCharacter:'='];
			  [response_ appendContentHTMLString:_value];
			};
		};
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSDictionary*)computeQueryDictionaryInContext:(GSWContext*)context_
{
  //OK
  NSMutableDictionary* _queryDictionary=nil;
  GSWComponent* _component=nil;
  GSWSession* _session=nil;
  LOGObjectFnStart();
  _queryDictionary=[NSMutableDictionary dictionary];
  _component=[context_ component];
  _session=[context_ existingSession];
  if (_session)
	{
	  if (!action && !pageName
#if !GSWEB_STRICT
		  && !redirectURL) //??
#endif
		{
		  NSString* _sessionID=[_session sessionID];
		  [_queryDictionary setObject:_sessionID
							forKey:GSWKey_SessionID];
		};
	};
  //TODOV
  if (otherQueryAssociations)
	{
	  NSEnumerator *enumerator = [otherAssociations keyEnumerator];
	  id _oaKey=nil;
	  while ((_oaKey = [enumerator nextObject]))
		{
		  id _oaValue=[[otherAssociations objectForKey:_oaKey] valueInComponent:_component];
		  if (!_oaValue)
			_oaValue=[[NSString new]autorelease];
		  [_queryDictionary setObject:_oaValue
							forKey:_oaKey];
		};
	};
  //TODO finished ??
  LOGObjectFnStop();
  return _queryDictionary;
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
@implementation GSWHyperlink (GSWHyperlinkB)
//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  //OK
  GSWElement* _element=nil;
  NSString* _senderID=nil;
  NSString* _elementID=nil;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@",[self class],[context_ elementID],[context_ senderID]);
  GSWAssertCorrectElementID(context_);// Debug Only
  _senderID=[context_ senderID];
  _elementID=[context_ elementID];
  if ([_elementID isEqualToString:_senderID])
	{
	  GSWComponent* _component=[context_ component];
	  if (action)
		{
		  NSDebugMLLog(@"gswdync",@"GSWHTMLURLValuedElement invoke action=%@",action);
		  _element=[action valueInComponent:_component];
		  if (_element)
			{
			  if (![_element isKindOfClass:[GSWComponent class]]) //TODO GSWComponent or Element ?
				{
				  ExceptionRaise0(@"GSWHyperlink",@"Invoked element return a not GSWComponent element");
				};
			};
		}
	  else if (pageName)
		{
		  id _pageNameValue=nil;
		  _pageNameValue=[pageName valueInComponent:_component];
		  _element=[GSWApp pageWithName:_pageNameValue
						  inContext:context_];
		  NSDebugMLLog(@"gswdync",@"_element=%@",_element);
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
						  ExceptionRaise(@"GSWHyperlink",@"%@ (%@) must return a Dictionary, not a %@ like %@",
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
		}
#if !GSWEB_STRICT
	  else if (redirectURL) //GNUstepWeb only
		{
		  NSString* _url=[redirectURL valueInComponent:_component];
		  id _redirectComponent = [GSWApp pageWithName:@"GSWRedirect"
										 inContext:context_];
		  [_redirectComponent setURL:_url];
		  _element=_redirectComponent;
		}
#endif
	  else if (href)
		{
		  LOGSeriousError(@"We shouldn't come here (href=%@)",href);
		}
	  else
		{
		  //TODO
		};
	  NSDebugMLLog(@"gswdync",@"GSWHTMLURLValuedElement invoke _element=%@",_element);
	  //TODOV
	  if (!_element)
		_element=[context_ page];
	  //the end ?
	}
  else
	{
	  if (children)
		{
		  [context_ appendZeroElementIDComponent];
		  _element=[children invokeActionForRequest:request_
							 inContext:context_];
		  [context_ deleteLastElementIDComponent];
		};
	};
  NSDebugMLLog(@"gswdync",@"GSWHTMLURLValuedElement invoke _element=%@",_element);
  NSDebugMLLog(@"gswdync",@"_senderID=%@",[context_ senderID]);
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[context_ elementID]);
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWHyperlink invokeActionForRequest: bad elementID");
#endif
  LOGObjectFnStop();
  return _element;
};


@end
