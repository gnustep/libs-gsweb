/* GSWSubmitButton.m - GSWeb: Class GSWSubmitButton
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
@implementation GSWSubmitButton

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)_elements
{
  NSMutableDictionary* _associations=[NSMutableDictionary dictionaryWithDictionary:associations_];
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"name_=%@ associations_:%@ _elements=%@",name_,associations_,_elements);
  [_associations setObject:[GSWAssociation associationWithValue:@"submit"]
				 forKey:@"type"];
  [_associations removeObjectForKey:action__Key];
  [_associations removeObjectForKey:actionClass__Key];
  if (directActionName) [_associations removeObjectForKey:directActionName];

  if (![_associations objectForKey:value__Key])
	[_associations setObject:[GSWAssociation associationWithValue:@"submit"]
				   forKey:value__Key];

  if ((self=[super initWithName:name_
				   associations:_associations
				   contentElements:nil]))
	{
	  action = [[associations_ objectForKey:action__Key
									  withDefaultObject:[action autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWSumbitButton: action=%@",action);
	  actionClass = [[associations_ objectForKey:actionClass__Key
									  withDefaultObject:[actionClass autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWSumbitButton: actionClass=%@",actionClass);
	  directActionName = [[associations_ objectForKey:directActionName__Key
									  withDefaultObject:[directActionName autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWSumbitButton: directActionName=%@",directActionName);
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(action);
  DESTROY(actionClass);
  DESTROY(directActionName);
  [super dealloc];
};

@end

//====================================================================
@implementation GSWSubmitButton (GSWSubmitButtonA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
  LOGObjectFnStart();
  GSWSaveAppendToResponseElementID(context_);//Debug Only
  [super appendToResponse:response_
		 inContext:context_];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  //OK
  GSWElement* _element=nil;
  BOOL _disabled=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@",[self class],[context_ elementID],[context_ senderID]);
  NS_DURING
	{
	  GSWAssertCorrectElementID(context_);// Debug Only
	  _disabled=[self disabledInContext:context_];
	  NSDebugMLLog(@"gswdync",@"_disabled=%s",(_disabled ? "YES" : "NO"));
	  if (!_disabled)
		{
		  BOOL _wasFormSubmitted=[context_ _wasFormSubmitted];
		  if (_wasFormSubmitted)
			{
			  BOOL _invoked=NO;
			  GSWComponent* _component=[context_ component];
			  BOOL _isMultipleSubmitForm=[context_ _isMultipleSubmitForm];
			  if (_isMultipleSubmitForm)
				{
				  NSString* _nameInContext=[self nameInContext:context_];
				  NSString* _formValue=[request_ formValueForKey:_nameInContext];
				  NSDebugMLLog(@"gswdync",@"_formValue=%@",_formValue);
				  if (_formValue)
					_invoked=YES;
				  else
					{
					  NSDebugMLLog(@"gswdync",@"[request_ formValueKeys]=%@",[request_ formValueKeys]);
					};
				}
			  else
				_invoked=YES;
			  if (_invoked)
				{
				  id _actionValue=nil;
				  NSDebugMLLog0(@"gswdync",@"Invoked Object Found !!");
				  [context_ _setActionInvoked:1];
				  NS_DURING
					{
					  NSDebugMLLog(@"gswdync",@"Invoked Object Found: action=%@",action);
					  _actionValue=[action valueInComponent:_component];
					}
				  NS_HANDLER
					{
					  LOGException0(@"exception in GSWSubmitButton invokeActionForRequest:inContext action");
					  LOGException(@"exception=%@",localException);
					  localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
																			  @"In GSWSubmitButton invokeActionForRequest:inContext action %@",action);
					  LOGException(@"exception=%@",localException);
					  [localException raise];
					}
				  NS_ENDHANDLER;
				  if (_actionValue)
					_element=_actionValue;
				  if (_element)
                                    {
                                      if (![_element isKindOfClass:[GSWComponent class]]) //TODO GSWComponent or Element ?
                                        {
                                          ExceptionRaise0(@"GSWHyperlink",@"Invoked element return a not GSWComponent element");
                                        } 
                                      else 
                                        {
                                          // call awakeInContext when _element is sleeping deeply
                                          [_element ensureAwakeInContext:context_];
                                          /*
                                            if (![_element context]) {
                                            NSDebugMLLog(@"gswdync",@"_element sleeps, awake it = %@",_element);
                                            [_element awakeInContext:context_];
                                            } else {
                                            [_element awakeInContext:context_];
                                            }
                                          */
                                        }
                                    }
                                  /* ???
				  if (!_element)
					_element=[context_ page];
                                  */
				};
			};
		};
	}
  NS_HANDLER
	{
	  LOGException0(@"exception in GSWSubmitButton invokeActionForRequest:inContext");
	  LOGException(@"exception=%@",localException);
	  localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
															  @"In GSWSubmitButton invokeActionForRequest:inContext");
	  LOGException(@"exception=%@",localException);
	  [localException raise];
	}
  NS_ENDHANDLER;
  //if (![context_ _wasActionInvoked] && [[[context_ elementID] parentElementIDString] compare:[context_ senderID]]!=NSOrderedAscending)
    if (![context_ _wasActionInvoked] && [[[context_ elementID] parentElementIDString] isSearchOverForSenderID:[context_ senderID]])
	{
	  LOGError(@"Action not invoked at the end of %@ (id=%@) senderId=%@",
			   [self class],
			   [context_ elementID],
			   [context_ senderID]);
	};
  LOGObjectFnStop();
  return _element;
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //Does Nothing ?
  GSWAssertCorrectElementID(context_);// Debug Only
};
 
//--------------------------------------------------------------------
-(void)appendNameToResponse:(GSWResponse*)_response
				   inContext:(GSWContext*)_context
{
  //OK
  //Here we call parent (GSWInput) method instead of doing it by ourself (as GSW)
  [super appendNameToResponse:_response
		 inContext:_context];
};

//--------------------------------------------------------------------
-(void)_appendActionClassAndNameToResponse:(GSWResponse*)_response
								 inContext:(GSWContext*)_context
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

