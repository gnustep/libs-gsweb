/* GSWRepetition.m - GSWeb: Class GSWRepetition
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
@implementation GSWRepetition

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_
{
  //OK
  LOGObjectFnStart();
  if ((self=[super initWithName:name_
				   associations:nil
				   template:nil]))
	{
	  list=[[associations_ objectForKey:list__Key
							  withDefaultObject:[list autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"list=%@",list);
	  item=[[associations_ objectForKey:item__Key
							  withDefaultObject:[item autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"item=%@",item);
	  if (item && ![item isValueSettable])
		{
		  ExceptionRaise0(@"GSWCheckBox",@"'item' parameter must be settable");
		};
	  identifier=[[associations_ objectForKey:identifier__Key
									withDefaultObject:[identifier autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"identifier=%@",identifier);
	  count=[[associations_ objectForKey:count__Key
							   withDefaultObject:[count autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"count=%@",count);
	  index=[[associations_ objectForKey:index__Key
							   withDefaultObject:[index autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"index=%@",index);
	  if (index && ![index isValueSettable])
		{
		  ExceptionRaise0(@"GSWCheckBox",@"'index' parameter must be settable");
		};
	  if (elements_)
		{
		  childrenGroup=[[GSWHTMLStaticGroup alloc]initWithContentElements:elements_];
		};
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
		 template:(GSWElement*)templateElement_
{
  LOGObjectFnStart();
  self=[self initWithName:name_
			 associations:associations_
			 contentElements:templateElement_ ? [NSArray arrayWithObject:templateElement_] : nil];
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(list);
  DESTROY(item);
  DESTROY(identifier);
  DESTROY(count);
  DESTROY(index);
  DESTROY(childrenGroup);
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
@implementation GSWRepetition (GSWRepetitionA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _component=nil;
  NSArray* _listValue=nil;
  int i=0;
  int _count=INT_MAX;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  _component=[context_ component];
  if (list)
	{
	  _listValue=[list valueInComponent:_component];
	  NSAssert2(!_listValue || [_listValue respondsToSelector:@selector(count)],
				@"The list (%@) (of class:%@) doesn't  respond to 'count'",
				list,
				[_listValue class]);
	  _count=[_listValue count];
	};
  if (count)
	{
	  id _tmpCountValue=[count valueInComponent:_component];
	  int _tmpCount=0;
	  NSAssert2([_tmpCountValue respondsToSelector:@selector(intValue)],
				@"The 'count' (%@) (of class:%@) doesn't  respond to 'intValue'",
				count,
				[_tmpCountValue class]);
	  _tmpCount=[_tmpCountValue intValue];
	  _count=min(_tmpCount,_count);
	};
  
  NSDebugMLLog(@"gswdync",@"_count=%d",_count);
  for(i=0;i<_count;i++)
	{
#ifndef NDEBUG
	  GSWElementIDString* debugElementID=[context_ elementID];
#endif
	  [self startOneIterationWithIndex:i
			list:_listValue
			inContext:context_];
	  [context_ appendZeroElementIDComponent];
	  [childrenGroup appendToResponse:response_
					 inContext:context_];
	  [context_ deleteLastElementIDComponent];
	  [self stopOneIterationWithIndex:i
			count:_count
			isLastOne:NO
			inContext:context_];
#ifndef NDEBUG
	  if (![debugElementID isEqualToString:[context_ elementID]])
		{
		  NSDebugMLLog(@"gswdync",@"class=%@ debugElementID=%@ [context_ elementID]=%@",[self class],debugElementID,[context_ elementID]);
		  
		};
#endif
	};
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWRepetion appendToResponse: bad elementID");
#endif
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  //OK
  GSWElement* _element=nil;
  BOOL _isInForm=NO;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  _isInForm=[context_ isInForm];
  NSDebugMLLog(@"gswdync",@"_isInForm=%s",_isInForm ? "YES" : "NO");
  if (_isInForm)
	_element=[self _slowInvokeActionForRequest:request_
				   inContext:context_];
  else
	_element=[self _fastInvokeActionForRequest:request_
				   inContext:context_];
  NSDebugMLLog(@"gswdync",@"_element=%@",_element);
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWRepetion invokeActionForRequest: bad elementID");
#endif
  LOGObjectFnStop();
  return _element;
};


//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _component=nil;
  NSArray* _listValue=nil;
  int i=0;
  int _count=INT_MAX;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  _component=[context_ component];
  if (list)
	{
	  _listValue=[list valueInComponent:_component];
	  NSAssert2(!_listValue || [_listValue respondsToSelector:@selector(count)],
				@"The list (%@) (of class:%@) doesn't  respond to 'count'",
				list,
				[_listValue class]);
	  _count=[_listValue count];
	};
  if (count)
	{
	  id _tmpCountValue=[count valueInComponent:_component];
	  int _tmpCount=0;
	  NSAssert2(!_tmpCountValue || [_tmpCountValue respondsToSelector:@selector(intValue)],
				@"The 'count' (%@) (of class:%@) doesn't  respond to 'intValue'",
				count,
				[_tmpCountValue class]);
	  _tmpCount=[_tmpCountValue intValue];
	  _count=min(_tmpCount,_count);
	};
  for(i=0;i<_count;i++)
	{
#ifndef NDEBUG
	  GSWElementIDString* debugElementID=[context_ elementID];
#endif
	  [self startOneIterationWithIndex:i
			list:_listValue
			inContext:context_];
	  [context_ appendZeroElementIDComponent];
	  [childrenGroup takeValuesFromRequest:request_
					 inContext:context_];
	  [context_ deleteLastElementIDComponent];
	  [self stopOneIterationWithIndex:i
			count:_count
			isLastOne:NO
			inContext:context_];
#ifndef NDEBUG
	  if (![debugElementID isEqualToString:[context_ elementID]])
		{
		  NSDebugMLLog(@"gswdync",@"class=%@ debugElementID=%@ [context_ elementID]=%@",[self class],debugElementID,[context_ elementID]);
		  
		};
#endif
	};
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWRepetion takeValuesFromRequest: bad elementID");
#endif
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)_slowInvokeActionForRequest:(GSWRequest*)request_
							   inContext:(GSWContext*)context_
{
  //OK
  GSWElement* _element=nil;
  GSWComponent* _component=nil;
  NSArray* _listValue=nil;
  int i=0;
  int _count=INT_MAX;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context_ elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  _component=[context_ component];
  if (list)
	{
	  _listValue=[list valueInComponent:_component];
	  NSAssert2(!_listValue || [_listValue respondsToSelector:@selector(count)],
				@"The list (%@) (of class:%@) doesn't  respond to 'count'",
				list,
				[_listValue class]);
	  _count=[_listValue count];
	};
  if (count)
	{
	  id _tmpCountValue=[count valueInComponent:_component];
	  int _tmpCount=0;
	  NSAssert2(!_tmpCountValue || [_tmpCountValue respondsToSelector:@selector(intValue)],
				@"The 'count' (%@) (of class:%@) doesn't  respond to 'intValue'",
				count,
				[_tmpCountValue class]);
	  _tmpCount=[_tmpCountValue intValue];
	  _count=min(_tmpCount,_count);
	};
  for(i=0;!_element && i<_count;i++)
	{
#ifndef NDEBUG
	  GSWElementIDString* debugElementID=[context_ elementID];
#endif
	  [self startOneIterationWithIndex:i
			list:_listValue
			inContext:context_];
	  [context_ appendZeroElementIDComponent];
	  _element=[childrenGroup invokeActionForRequest:request_
							  inContext:context_];
	  [context_ deleteLastElementIDComponent];
	  [self stopOneIterationWithIndex:i
			count:_count
			isLastOne:(_element!=nil)
			inContext:context_];
#ifndef NDEBUG
	  if (![debugElementID isEqualToString:[context_ elementID]])
		{
		  NSDebugMLLog(@"gswdync",@"class=%@ debugElementID=%@ [context_ elementID]=%@",[self class],debugElementID,[context_ elementID]);
		  
		};
#endif
	};
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWRepetion _slowInvokeActionForRequest: bad elementID");
#endif
  LOGObjectFnStop();
  return _element;
};

//--------------------------------------------------------------------
-(GSWElement*)_fastInvokeActionForRequest:(GSWRequest*)request_
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
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context_ elementID]);
  _senderID=[context_ senderID];
  NSDebugMLLog(@"gswdync",@"_senderID=%@",_senderID);
  _elementID=[context_ elementID];
  NSDebugMLLog(@"gswdync",@"_elementID=%@",_elementID);
  if ([_senderID hasPrefix:_elementID])
	{
#ifndef NDEBUG
	  GSWElementIDString* debugElementID=[context_ elementID];
#endif
	  int _count=INT_MAX;
	  NSArray* _listValue=nil;
	  int i=0;
	  GSWComponent* _component=[context_ component];
	  if (list)
		{
		  _listValue=[list valueInComponent:_component];
		  NSAssert2(!_listValue || [_listValue respondsToSelector:@selector(count)],
					@"The list (%@) (of class:%@) doesn't  respond to 'count'",
					list,
					[_listValue class]);
		  _count=[_listValue count];
		};
	  if (count)
		{
		  id _tmpCountValue=[count valueInComponent:_component];
		  int _tmpCount=0;
		  NSAssert2(!_tmpCountValue || [_tmpCountValue respondsToSelector:@selector(intValue)],
					@"The 'count' (%@) (of class:%@) doesn't  respond to 'intValue'",
					count,
					[_tmpCountValue class]);
		  _tmpCount=[_tmpCountValue intValue];
		  _count=min(_tmpCount,_count);
		};
	  for(i=0;!_element && i<_count;i++)
		{
		  [self startOneIterationWithIndex:i
				list:_listValue
				inContext:context_];
		  [context_ appendZeroElementIDComponent];
		  _element=[childrenGroup invokeActionForRequest:request_
								  inContext:context_];
		  NSDebugMLLog(@"gswdync",@"_element=%@",_element);
		  [context_ deleteLastElementIDComponent];
		  [self stopOneIterationWithIndex:i
				count:_count
				isLastOne:(_element!=nil)
				inContext:context_];
#ifndef NDEBUG
		  if (![debugElementID isEqualToString:[context_ elementID]])
			{
			  NSDebugMLLog(@"gswdync",@"class=%@ debugElementID=%@ [context_ elementID]=%@",[self class],debugElementID,[context_ elementID]);
			  
			};
#endif
		};
	};
  NSDebugMLLog(@"gswdync",@"_element=%@",_element);
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context_ elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context_ elementID]elementsNb],@"GSWRepetion _fastInvokeActionForRequest: bad elementID");
#endif
  LOGObjectFnStop();
  return _element;
};

//--------------------------------------------------------------------
-(void)stopOneIterationWithIndex:(int)index_
						   count:(int)count_
					   isLastOne:(BOOL)isLastOne_
					   inContext:(GSWContext*)context_
{
  //OK
  LOGObjectFnStart();
  if (index_==(count_-1) || isLastOne_)
	{
	  NS_DURING
		{
		  GSWComponent* _component=[context_ component];
		  if (list && item)
			[item setValue:nil //??
				  inComponent:_component];
		  if (index)
			[index setValue:[NSNumber numberWithShort:0]
				   inComponent:_component];
		  [context_ deleteLastElementIDComponent];
		}
	  NS_HANDLER
		{
		  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In stopOneIterationWithIndex");
		  [localException raise];
		}
	  NS_ENDHANDLER;
	};
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)startOneIterationWithIndex:(unsigned int)index_
							 list:(NSArray*)list_
						inContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _component=nil;
  LOGObjectFnStart();
  NS_DURING
	{
	  _component=[context_ component];
	  NSDebugMLLog(@"gswdync",@"item=%@",item);
	  if (list && item)
		[item setValue:[list_ objectAtIndex:index_]
			  inComponent:_component];
	  NSDebugMLLog(@"gswdync",@"index_=%d",index_);
	  NSDebugMLLog(@"gswdync",@"index=%@",index);
	  if (index)
		[index setValue:[NSNumber numberWithShort:index_]
			   inComponent:_component];
	  if (index_==0)
		[context_ appendZeroElementIDComponent];
	  else
		[context_ incrementLastElementIDComponent];
	}
  NS_HANDLER
	{
	  localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,@"In startOneIterationWithIndex");
	  [localException raise];
	}
  NS_ENDHANDLER;
  LOGObjectFnStop();
};

@end
