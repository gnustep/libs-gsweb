/* GSWForm.m - GSWeb: Class GSWForm
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
@implementation GSWForm

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_
{
  NSMutableDictionary* _associations=[NSMutableDictionary dictionaryWithDictionary:associations_];
  LOGObjectFnStartC("GSWForm");
  NSDebugMLLog(@"gswdync",@"name_=%@ associations_:%@ elements_=%@",name_,associations_,elements_);
  if (![_associations objectForKey:@"method"])
	{
	  if ([_associations objectForKey:@"get"])
		[_associations setObject:[GSWAssociation associationWithValue:@"get"]
					   forKey:@"method"];
	  else
		[_associations setObject:[GSWAssociation associationWithValue:@"post"]
					   forKey:@"method"];
	};
  [_associations removeObjectForKey:action__Key];
  [_associations removeObjectForKey:href__Key];
  [_associations removeObjectForKey:multipleSubmit__Key];
  [_associations removeObjectForKey:actionClass__Key];
  if (directActionName) [_associations removeObjectForKey:directActionName];
#if !GSWEB_STRICT
  [_associations removeObjectForKey:disabled__Key];
  [_associations removeObjectForKey:enabled__Key];
#endif
  [_associations removeObjectForKey:queryDictionary__Key];

  //call isValueSettable sur value (return YES)
  action = [[associations_ objectForKey:action__Key
							  withDefaultObject:[action autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm: action=%@",action);
  href = [[associations_ objectForKey:href__Key
							withDefaultObject:[href autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm: href=%@",href);
  multipleSubmit = [[associations_ objectForKey:multipleSubmit__Key
									  withDefaultObject:[multipleSubmit autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm: multipleSubmit=%@",multipleSubmit);
  actionClass = [[associations_ objectForKey:actionClass__Key
								   withDefaultObject:[actionClass autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm: actionClass=%@",actionClass);
  directActionName = [[associations_ objectForKey:directActionName__Key
										withDefaultObject:[directActionName autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm: directActionName=%@",directActionName);

#if !GSWEB_STRICT
  disabled = [[associations_ objectForKey:disabled__Key
							 withDefaultObject:[disabled autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm disabled=%@",disabled);
  enabled = [[associations_ objectForKey:enabled__Key
							 withDefaultObject:[enabled autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm enabled=%@",enabled);
  if (disabled && enabled)
	{
	  ExceptionRaise(@"GSWForm",@"You can't specify 'disabled' and 'enabled' together. componentAssociations:%@",
					 associations_);
	};
#endif

  queryDictionary = [[associations_ objectForKey:queryDictionary__Key
									   withDefaultObject:[queryDictionary autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm: queryDictionary=%@",queryDictionary);

  if ((self=[super initWithName:name_
				   attributeAssociations:_associations
				   contentElements:elements_]))
	{
	};
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(action);
  DESTROY(href);
  DESTROY(multipleSubmit);
  DESTROY(actionClass);
  DESTROY(directActionName);
  DESTROY(queryDictionary);
#if !GSWEB_STRICT
  DESTROY(disabled);
  DESTROY(enabled);
#endif
  DESTROY(otherQueryAssociations);
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)description
{
  return [NSString stringWithFormat:@"<%s %p>",
				   object_get_class_name(self),
				   (void*)self];
};

//--------------------------------------------------------------------
-(id)elementName
{
  //OK
  return @"form";
};

@end

//====================================================================
@implementation GSWForm (GSWFormA)

#if !GSWEB_STRICT
//--------------------------------------------------------------------
-(BOOL)disabledInContext:(GSWContext*)_context
{
  //OK
  if (enabled)
	return ![self evaluateCondition:enabled
				  inContext:_context];
  else
	return [self evaluateCondition:disabled
				 inContext:_context];
};
#endif
//--------------------------------------------------------------------
-(BOOL)compactHTMLTags
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(void)_appendHiddenFieldsToResponse:(GSWResponse*)response_
						   inContext:(GSWContext*)context_
{
  //OK
  NSDictionary* _hiddenFields=nil;
  GSWRequest* _request=nil;
  NSString* _gswsid=nil;

  _hiddenFields=[self computeQueryDictionaryInContext:context_];
  if (_hiddenFields)
	{
	  //TODO
	};
  _request=[context_ request];
  _gswsid=[_request formValueForKey:GSWKey_SessionID];
  if (_gswsid)
	{
	  //TODO
	};
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(NSDictionary*)computeQueryDictionaryInContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _component=[context_ component];
  GSWSession* _session=[context_ existingSession];
  NSString* _sessionID=[_session sessionID];
  LOGObjectFnNotImplemented();	//TODOFN
  return [[NSDictionary new] autorelease];
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
#if !GSWEB_STRICT
  BOOL _disabledInContext=NO;
#endif
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStartC("GSWForm");
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);

  GSWSaveAppendToResponseElementID(context_);//Debug Only

#if !GSWEB_STRICT
  _disabledInContext=[self disabledInContext:context_];
  [context_ setInForm:!_disabledInContext];
#else
  [context_ setInForm:YES];
#endif
  [self appendToResponse:response_
		inContext:context_
		elementsFromIndex:0
		toIndex:[elementsMap length]-2];
  [self _appendHiddenFieldsToResponse:response_
		inContext:context_];
  [self appendToResponse:response_
		inContext:context_
		elementsFromIndex:[elementsMap length]-1
		toIndex:[elementsMap length]-1];
  [context_ setInForm:NO];
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWForm appendToResponse: bad elementID");
#endif
  LOGObjectFnStopC("GSWForm");
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  //OK
  GSWElement* _element=nil;
  NSString* _senderID=nil;
  NSString* _elementID=nil;
  BOOL _isFormSubmited=NO;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  BOOL _multipleSubmit=NO;
  int i=0;
  LOGObjectFnStartC("GSWForm");
  _senderID=[context_ senderID];
  _elementID=[context_ elementID];
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@",[self class],_elementID,_senderID);
  NS_DURING
	{
	  GSWAssertCorrectElementID(context_);// Debug Only
	  if ([self prefixMatchSenderIDInContext:context_]) //Avoid trying to find action if we are not the good component
		{
		  _isFormSubmited=[_elementID isEqualToString:_senderID];
		  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@ _isFormSubmited=%s",
					   [self class],
					   _elementID,
					   _senderID,
					   (_isFormSubmited ? "YES" : "NO"));
#if !GSWEB_STRICT
		  if (_isFormSubmited && [self disabledInContext:context_])
			_isFormSubmited=NO;
#endif
		  if (_isFormSubmited)
			{
			  [context_ setInForm:YES];
			  [context_ _setFormSubmitted:YES];
			  _multipleSubmit=[self evaluateCondition:multipleSubmit
									inContext:context_];
			  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@ _multipleSubmit=%s",
						   [self class],
						   _elementID,
						   _senderID,
						   (_multipleSubmit ? "YES" : "NO"));
			  [context_ _setIsMultipleSubmitForm:_multipleSubmit];
			};
		  [context_ appendZeroElementIDComponent];
		  for(i=0;!_element && i<[dynamicChildren count];i++)
			{
			  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[[dynamicChildren objectAtIndex:i] class],[context_ elementID]);
			  _element=[[dynamicChildren objectAtIndex:i] invokeActionForRequest:request_
														  inContext:context_];
			  [context_ incrementLastElementIDComponent];
			};
		  [context_ deleteLastElementIDComponent];
		  if (_isFormSubmited)
			{
			  if ([context_ _wasActionInvoked])
				  [context_ _setIsMultipleSubmitForm:NO];
			  else
				{
				  NSDebugMLLog0(@"gswdync",@"formSubmitted but no action was invoked!");
				};
			  [context_ setInForm:NO];
			  [context_ _setFormSubmitted:NO];
			};
		  _elementID=[context_ elementID];
		  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],_elementID);
#ifndef NDEBBUG
		  NSAssert(elementsNb==[(GSWElementIDString*)_elementID elementsNb],@"GSWForm invokeActionForRequest: bad elementID");
#endif
		};
	}
  NS_HANDLER
	{
	  LOGException0(@"exception in GSWForm invokeActionForRequest:inContext");
	  LOGException(@"exception=%@",localException);
	  localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
															  @"In GSWForm invokeActionForRequest:inContext");
	  LOGException(@"exception=%@",localException);
	  [localException raise];
	}
  NS_ENDHANDLER;
  _senderID=[context_ senderID];
  _elementID=[context_ elementID];
  if (![context_ _wasActionInvoked] && [_elementID compare:_senderID]!=NSOrderedAscending)
	{
	  LOGError(@"Action not invoked at the end of %@ (id=%@) senderId=%@",
			   [self class],
			   _elementID,
			   _senderID);
	};
  LOGObjectFnStopC("GSWForm");
  return _element; 
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //OK
  NSString* _senderID=nil;
  NSString* _elementID=nil;
  BOOL _isFormSubmited=NO;
  int i=0;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStartC("GSWForm");
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  GSWAssertCorrectElementID(context_);// Debug Only
  _senderID=[context_ senderID];
  _elementID=[context_ elementID];
  NSDebugMLLog(@"gswdync",@"_senderID=%@",_senderID);
  NSDebugMLLog(@"gswdync",@"_elementID=%@",_elementID);
  if ([self prefixMatchSenderIDInContext:context_]) //Avoid taking values if we are not the good form
	{
	  _isFormSubmited=[_elementID isEqualToString:_senderID];
	  NSDebugMLLog(@"gswdync",@"_isFormSubmited=%d",(int)_isFormSubmited);
#if !GSWEB_STRICT
	  if (_isFormSubmited && [self disabledInContext:context_])
		_isFormSubmited=NO;
#endif
	  
	  NSDebugMLLog(@"gswdync",@"Starting GSWForm TV ET=%@ id=%@",[self class],[context_ elementID]);
	  if (_isFormSubmited)
		{
		  [context_ setInForm:YES];
		  [context_ _setFormSubmitted:YES];
		};
	  [context_ appendZeroElementIDComponent];
	  NSDebugMLLog(@"gswdync",@"\n\ndynamicChildren=%@",dynamicChildren);
	  NSDebugMLLog(@"gswdync",@"[dynamicChildren count]=%d",[dynamicChildren count]);
	  for(i=0;i<[dynamicChildren count];i++)
		{
		  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[[dynamicChildren objectAtIndex:i] class],[context_ elementID]);
		  NSDebugMLLog(@"gswdync",@"\n[dynamicChildren objectAtIndex:i]=%@",[dynamicChildren objectAtIndex:i]);
		  [[dynamicChildren objectAtIndex:i] takeValuesFromRequest:request_
											 inContext:context_];
		  [context_ incrementLastElementIDComponent];
		};
	  [context_ deleteLastElementIDComponent];
	  if (_isFormSubmited)
		{
		  [context_ setInForm:NO];
		  [context_ _setFormSubmitted:NO];
		};
	};
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWForm takeValuesFromRequest: bad elementID");
#endif
  LOGObjectFnStopC("GSWForm");
};

@end

//====================================================================
@implementation GSWForm (GSWFormB)

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
						   inContext:(GSWContext*)context_
{
  //OK//TODOV
#if !GSWEB_STRICT
  BOOL _disabledInContext=NO;
#endif
  LOGObjectFnStartC("GSWForm");
#if !GSWEB_STRICT
  _disabledInContext=[self disabledInContext:context_];
  NSDebugMLLog(@"gswdync",@"_disabledInContext=%s",(_disabledInContext ? "YES" : "NO"));
  if (!_disabledInContext)
	{
#endif
	  GSWComponent* _component=[context_ component];
	  id _actionValue=nil;
	  if (href)
		_actionValue=[href valueInComponent:_component];
	  else
		_actionValue=[context_ componentActionURL];
	  [response_ appendContentCharacter:' '];
	  [response_ _appendContentAsciiString:@"action"];
	  [response_ appendContentCharacter:'='];
	  [response_ appendContentCharacter:'"'];
	  [response_ appendContentString:_actionValue];
	  [response_ appendContentCharacter:'"'];
#if !GSWEB_STRICT
	};
#endif
  LOGObjectFnStopC("GSWForm");
};

//--------------------------------------------------------------------
-(void)_appendCGIActionToResponse:(GSWResponse*)response_
						   inContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWForm (GSWFormC)

//--------------------------------------------------------------------
+(BOOL)hasGSWebObjectsAssociations
{
  return YES;
};

@end

