/* GSWConditional.m - GSWeb: Class GSWConditional
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
@implementation GSWConditional

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)someAssociations
		 template:(GSWElement*)templateElement_
{
  //OK
  LOGObjectFnStart();
  self=[self initWithName:name_
			 associations:someAssociations
			 contentElements:templateElement_ ? [NSArray arrayWithObject:templateElement_] : nil];
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)_elements
{
  LOGObjectFnStart();
  if ((self=[super initWithName:name_
				   associations:nil
				   template:nil]))
	{
	  if (_elements)
		childrenGroup=[[GSWHTMLStaticGroup alloc]initWithContentElements:_elements];
	  condition = [[associations_ objectForKey:condition__Key
									 withDefaultObject:[condition autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWConditional condition=%@",condition);
	  negate = [[associations_ objectForKey:negate__Key
								  withDefaultObject:[negate autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWConditional negate=%@",negate);
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(condition);
  DESTROY(negate);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
				   object_get_class_name(self),
				   (void*)self];
};

//====================================================================
@implementation GSWConditional (GSWConditionalA)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //OK
  BOOL _condition=NO;
  BOOL _negate=NO;
  BOOL _doIt=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  GSWAssertCorrectElementID(context_);// Debug Only
  _condition=[self evaluateCondition:condition
				   inContext:context_];
  _negate=[self evaluateCondition:negate
				inContext:context_];
  _doIt=_condition;
  NSDebugMLLog(@"gswdync",@"elementID=%@",[context_ elementID]);
  if (_negate)
	_doIt=!_doIt;
  if (_doIt)
	{
	  GSWRequest* _request=[context_ request];
	  BOOL _isFromClientComponent=[_request isFromClientComponent];
	  [context_ appendZeroElementIDComponent];
	  [childrenGroup takeValuesFromRequest:request_
				   inContext:context_];
	  [context_ deleteLastElementIDComponent];
	};
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  //OK
  GSWElement* _element=nil;
  BOOL _condition=NO;
  BOOL _negate=NO;
  BOOL _doIt=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@",[self class],[context_ elementID],[context_ senderID]);
  GSWAssertCorrectElementID(context_);// Debug Only
  _condition=[self evaluateCondition:condition
						inContext:context_];
  _negate=[self evaluateCondition:negate
					 inContext:context_];
  _doIt=_condition;
  if (_negate)
	_doIt=!_doIt;
  NSDebugMLLog(@"gswdync",@"_doIt=%s",_doIt ? "YES" : "NO");
  if (_doIt)
	{
	  GSWRequest* _request=[context_ request];
	  BOOL _isFromClientComponent=[_request isFromClientComponent];
	  [context_ appendZeroElementIDComponent];
	  NSDebugMLLog(@"gswdync",@"childrenGroup=%@",childrenGroup);
	  _element=[childrenGroup invokeActionForRequest:request_
							  inContext:context_];
	  NSDebugMLLog(@"gswdync",@"_element=%@",_element);
	  [context_ deleteLastElementIDComponent];
	};
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
  LOGObjectFnStop();
  return _element;
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
  BOOL _condition=NO;
  BOOL _negate=NO;
  BOOL _doIt=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  GSWSaveAppendToResponseElementID(context_);//Debug Only
  _condition=[self evaluateCondition:condition
						inContext:context_];
  NSDebugMLLog(@"gswdync",@"_condition=%s",_condition ? "YES" : "NO");
  _negate=[self evaluateCondition:negate
					 inContext:context_];
  NSDebugMLLog(@"gswdync",@"_negate=%s",_negate ? "YES" : "NO");
  _doIt=_condition;
  if (_negate)
	_doIt=!_doIt;
  NSDebugMLLog(@"gswdync",@"_doIt=%s",_doIt ? "YES" : "NO");
  if (_doIt)
	{
	  GSWRequest* _request=[context_ request];
	  BOOL _isFromClientComponent=[_request isFromClientComponent];
	  [context_ appendZeroElementIDComponent];
	  [childrenGroup appendToResponse:response_
					 inContext:context_];
	  [context_ deleteLastElementIDComponent];
	};
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
  LOGObjectFnStop();
};

@end
