/* GSWToggle.m - GSWeb: Class GSWToggle
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
@implementation GSWToggle

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)someAssociations
		 template:(GSWElement*)templateElement_
{
  //OK
  NSMutableDictionary* _otherAssociations=nil;
  LOGObjectFnStart();
  ASSIGN(children,templateElement_);
  action = [[someAssociations objectForKey:action__Key
							  withDefaultObject:[action autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"action=%@",action);

  actionYes = [[someAssociations objectForKey:actionYes__Key
							  withDefaultObject:[actionYes autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"actionYes=%@",actionYes);

  actionNo = [[someAssociations objectForKey:actionNo__Key
							  withDefaultObject:[actionNo autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"actionNo=%@",actionNo);

  condition = [[someAssociations objectForKey:condition__Key
								withDefaultObject:[condition autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"condition=%@",condition);

  disabled = [[someAssociations objectForKey:disabled__Key
								withDefaultObject:[disabled autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"disabled=%@",disabled);

  _otherAssociations=[NSMutableDictionary dictionaryWithDictionary:someAssociations];
  [_otherAssociations removeObjectForKey:action__Key];
  [_otherAssociations removeObjectForKey:actionYes__Key];
  [_otherAssociations removeObjectForKey:actionNo__Key];
  [_otherAssociations removeObjectForKey:condition__Key];
  [_otherAssociations removeObjectForKey:disabled__Key];
  if ([_otherAssociations count]>0)
	  otherAssociations=[[NSDictionary dictionaryWithDictionary:_otherAssociations] retain];

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
  DESTROY(actionYes);
  DESTROY(actionNo);
  DESTROY(condition);
  DESTROY(disabled);
  DESTROY(otherAssociations);
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
@implementation GSWToggle (GSWToggleA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK (condition/action/directActionName)
  GSWComponent* _component=[context_ component];
  BOOL _disabled=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[context_ elementID]);
  if (disabled)
	_disabled=[self evaluateCondition:disabled
					inContext:context_];
  if (!_disabled)
	{
	  NSString* _url=nil;
	  [response_ _appendContentAsciiString:@"<A "];
	  [response_ _appendContentAsciiString:@"href"];
	  [response_ appendContentCharacter:'='];
	  [response_ appendContentCharacter:'"'];
	  _url=(NSString*)[context_ componentActionURL];
	  NSDebugMLLog(@"gswdync",@"_url=%@",_url);
	  [response_ appendContentString:_url];
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
  [children appendToResponse:response_
			inContext:context_];
  if (!_disabled)//??
	{
	  [response_ _appendContentAsciiString:@"</a>"];
	};
  NSDebugMLLog(@"gswdync",@"_senderID=%@",[context_ senderID]);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  //OK
  GSWElement* _element=nil;
  NSString* _senderID=nil;
  NSString* _elementID=nil;
  LOGObjectFnStart();
  _senderID=[context_ senderID];
  NSDebugMLLog(@"gswdync",@"_senderID=%@",_senderID);
  _elementID=[context_ elementID];
  NSDebugMLLog(@"gswdync",@"_elementID=%@",_elementID);
  if ([_elementID isEqualToString:_senderID])
	{
	  GSWComponent* _component=[context_ component];
	  BOOL _conditionValue=[self evaluateCondition:condition
								 inContext:context_];
	  _conditionValue=!_conditionValue;
	  if (action)
		[action setValue:[NSNumber numberWithBool:_conditionValue]
				inComponent:_component];
	  else
		{
		  if (actionYes && _conditionValue)
			[actionYes valueInComponent:_component];
		  else if (actionNo && !_conditionValue)
			[actionNo valueInComponent:_component];
		  else
			{
			  //TODO ERROR
			};
		};
	  //TODOV
	  if (!_element)
		_element=[context_ page];
	}
  else
	{
	  _element=[children invokeActionForRequest:request_
						 inContext:context_];
	  NSDebugMLLog(@"gswdync",@"_element=%@",_element);
	};
  NSDebugMLLog(@"gswdync",@"_senderID=%@",[context_ senderID]);
  NSDebugMLLog(@"gswdync",@"_elementID=%@",[context_ elementID]);
  LOGObjectFnStop();
  return _element;
};


@end
