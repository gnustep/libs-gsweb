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

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWRepetition

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  //OK
  LOGObjectFnStart();
  if ((self=[super initWithName:name
                   associations:nil
                   template:nil]))
    {
      _list=[[associations objectForKey:list__Key
                           withDefaultObject:[_list autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"list=%@",_list);
      _item=[[associations objectForKey:item__Key
                            withDefaultObject:[_item autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"item=%@",_item);
      if (_item && ![_item isValueSettable])
        {
          ExceptionRaise0(@"GSWCheckBox",@"'item' parameter must be settable");
        };
      _identifier=[[associations objectForKey:identifier__Key
                                  withDefaultObject:[_identifier autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"identifier=%@",_identifier);
      _count=[[associations objectForKey:count__Key
                            withDefaultObject:[_count autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"count=%@",_count);
      _index=[[associations objectForKey:index__Key
                            withDefaultObject:[_index autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"index=%@",_index);
      if (_index && ![_index isValueSettable])
        {
          ExceptionRaise0(@"GSWCheckBox",@"'index' parameter must be settable");
        };
      if (elements)
        {
          _childrenGroup=[[GSWHTMLStaticGroup alloc]initWithContentElements:elements];
        };
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement
{
  LOGObjectFnStart();
  self=[self initWithName:name
             associations:associations
             contentElements:templateElement ? [NSArray arrayWithObject:templateElement] : nil];
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_list);
  DESTROY(_item);
  DESTROY(_identifier);
  DESTROY(_count);
  DESTROY(_index);
  DESTROY(_childrenGroup);
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
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  //OK
  GSWComponent* component=nil;
  NSArray* listValue=nil;
  int i=0;
  int countValue=0;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context elementID]);
  component=[context component];
  if (_list)
    {
      listValue=[_list valueInComponent:component];
      NSAssert2(!listValue || [listValue respondsToSelector:@selector(count)],
                @"The list (%@) (of class:%@) doesn't  respond to 'count'",
                _list,
                [listValue class]);
      countValue=[listValue count];
    };
  if (_count)
    {
      id tmpCountValue=[_count valueInComponent:component];
      int tmpCount=0;
      NSAssert3(!tmpCountValue || [tmpCountValue respondsToSelector:@selector(intValue)],
                @"The 'count' (%@) value %@ (of class:%@) doesn't  respond to 'intValue'",
                _count,
                tmpCountValue,
                [tmpCountValue class]);
      tmpCount=[tmpCountValue intValue];
      NSDebugMLog(@"tmpCount=%d",tmpCount);
      if (_list)
        countValue=min(tmpCount,countValue);
      else
        countValue=tmpCount;
    };
  
  NSDebugMLLog(@"gswdync",@"countValue=%d",countValue);
  for(i=0;i<countValue;i++)
    {
#ifndef NDEBUG
      GSWElementIDString* debugElementID=[context elementID];
#endif
      [self startOneIterationWithIndex:i
            list:listValue
            inContext:context];
      [context appendZeroElementIDComponent];
      [_childrenGroup appendToResponse:response
                      inContext:context];
      [context deleteLastElementIDComponent];
      [self stopOneIterationWithIndex:i
            count:countValue
            isLastOne:NO
            inContext:context];
#ifndef NDEBUG
      if (![debugElementID isEqualToString:[context elementID]])
        {
          NSDebugMLLog(@"gswdync",@"class=%@ debugElementID=%@ [context elementID]=%@",[self class],debugElementID,[context elementID]);
          
        };
#endif
    };
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],@"GSWRepetion appendToResponse: bad elementID");
#endif
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
{
  //OK
  GSWElement* element=nil;
  BOOL isInForm=NO;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context elementID]);
  isInForm=[context isInForm];
  NSDebugMLLog(@"gswdync",@"isInForm=%s",isInForm ? "YES" : "NO");
  if (isInForm)
    element=[self _slowInvokeActionForRequest:request
                  inContext:context];
  else
    element=[self _fastInvokeActionForRequest:request
                  inContext:context];
  NSDebugMLLog(@"gswdync",@"element=%@",element);
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],@"GSWRepetion invokeActionForRequest: bad elementID");
#endif
  LOGObjectFnStop();
  return element;
};


//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //OK
  GSWComponent* component=nil;
  NSArray* listValue=nil;
  int i=0;
  int countValue=0;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context elementID]);
  component=[context component];
  if (_list)
    {
      listValue=[_list valueInComponent:component];
      NSAssert2(!listValue || [listValue respondsToSelector:@selector(count)],
                @"The list (%@) (of class:%@) doesn't  respond to 'count'",
                _list,
                [listValue class]);
	  countValue=[listValue count];
    };
  if (_count)
    {
      id tmpCountValue=[_count valueInComponent:component];
      int tmpCount=0;
      NSAssert2(!tmpCountValue || [tmpCountValue respondsToSelector:@selector(intValue)],
                @"The 'count' (%@) (of class:%@) doesn't  respond to 'intValue'",
                _count,
                [tmpCountValue class]);
      tmpCount=[tmpCountValue intValue];
      if (_list)
        countValue=min(tmpCount,countValue);
      else
        countValue=tmpCount;
    };
  for(i=0;i<countValue;i++)
    {
#ifndef NDEBUG
      GSWElementIDString* debugElementID=[context elementID];
#endif
      [self startOneIterationWithIndex:i
            list:listValue
            inContext:context];
      [context appendZeroElementIDComponent];
      [_childrenGroup takeValuesFromRequest:request
                      inContext:context];
	  [context deleteLastElementIDComponent];
	  [self stopOneIterationWithIndex:i
                count:countValue
                isLastOne:NO
                inContext:context];
#ifndef NDEBUG
	  if (![debugElementID isEqualToString:[context elementID]])
            {
              NSDebugMLLog(@"gswdync",@"class=%@ debugElementID=%@ [context elementID]=%@",[self class],debugElementID,[context elementID]);
              
            };
#endif
    };
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],@"GSWRepetion takeValuesFromRequest: bad elementID");
#endif
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)_slowInvokeActionForRequest:(GSWRequest*)request
                                inContext:(GSWContext*)context
{
  //OK
  GSWElement* element=nil;
  GSWComponent* component=nil;
  NSArray* listValue=nil;
  int i=0;
  int countValue=0;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context elementID]);
  component=[context component];
  if (_list)
    {
      listValue=[_list valueInComponent:component];
      NSAssert2(!listValue || [listValue respondsToSelector:@selector(count)],
                @"The list (%@) (of class:%@) doesn't  respond to 'count'",
                _list,
                [listValue class]);
      countValue=[listValue count];
    };
  if (_count)
    {
      id tmpCountValue=[_count valueInComponent:component];
      int tmpCount=0;
      NSAssert2(!tmpCountValue || [tmpCountValue respondsToSelector:@selector(intValue)],
                @"The 'count' (%@) (of class:%@) doesn't  respond to 'intValue'",
                _count,
                [tmpCountValue class]);
      tmpCount=[tmpCountValue intValue];
      if (_list)
        countValue=min(tmpCount,countValue);
      else
        countValue=tmpCount;
    };
  for(i=0;!element && i<countValue;i++)
    {
#ifndef NDEBUG
      GSWElementIDString* debugElementID=[context elementID];
#endif
      [self startOneIterationWithIndex:i
            list:listValue
            inContext:context];
      [context appendZeroElementIDComponent];
      element=[_childrenGroup invokeActionForRequest:request
                             inContext:context];
      [context deleteLastElementIDComponent];
      [self stopOneIterationWithIndex:i
            count:countValue
            isLastOne:(element!=nil)
            inContext:context];
#ifndef NDEBUG
      if (![debugElementID isEqualToString:[context elementID]])
        {
          NSDebugMLLog(@"gswdync",@"class=%@ debugElementID=%@ [context elementID]=%@",[self class],debugElementID,[context elementID]);
        };
#endif
    };
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],@"GSWRepetion _slowInvokeActionForRequest: bad elementID");
#endif
  LOGObjectFnStop();
  return element;
};

//--------------------------------------------------------------------
-(GSWElement*)_fastInvokeActionForRequest:(GSWRequest*)request
                                inContext:(GSWContext*)context
{
  //OK
  GSWElement* element=nil;
  NSString* senderID=nil;
  NSString* elementID=nil;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context elementID]);
  senderID=[context senderID];
  NSDebugMLLog(@"gswdync",@"senderID=%@",senderID);
  elementID=[context elementID];
  NSDebugMLLog(@"gswdync",@"elementID=%@",elementID);
  if ([senderID hasPrefix:elementID])
    {
#ifndef NDEBUG
      GSWElementIDString* debugElementID=[context elementID];
#endif
      int countValue=0;
      NSArray* listValue=nil;
      int i=0;
      GSWComponent* component=[context component];
      if (_list)
        {
          listValue=[_list valueInComponent:component];
          NSAssert2(!listValue || [listValue respondsToSelector:@selector(count)],
                    @"The list (%@) (of class:%@) doesn't  respond to 'count'",
                    _list,
                    [listValue class]);
          countValue=[listValue count];
        };
      if (_count)
        {
          id tmpCountValue=[_count valueInComponent:component];
          int tmpCount=0;
          NSAssert2(!tmpCountValue || [tmpCountValue respondsToSelector:@selector(intValue)],
                    @"The 'count' (%@) (of class:%@) doesn't  respond to 'intValue'",
                    _count,
                    [tmpCountValue class]);
          tmpCount=[tmpCountValue intValue];
          if (_list)
            countValue=min(tmpCount,countValue);
          else
            countValue=tmpCount;
        };
      for(i=0;!element && i<countValue;i++)
        {
          [self startOneIterationWithIndex:i
                list:listValue
                inContext:context];
          [context appendZeroElementIDComponent];
          element=[_childrenGroup invokeActionForRequest:request
                                  inContext:context];
          NSDebugMLLog(@"gswdync",@"element=%@",element);
          [context deleteLastElementIDComponent];
          [self stopOneIterationWithIndex:i
                count:countValue
                isLastOne:(element!=nil)
                inContext:context];
#ifndef NDEBUG
          if (![debugElementID isEqualToString:[context elementID]])
            {
              NSDebugMLLog(@"gswdync",@"class=%@ debugElementID=%@ [context elementID]=%@",[self class],debugElementID,[context elementID]);
            };
#endif
        };
    };
  NSDebugMLLog(@"gswdync",@"element=%@",element);
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],@"GSWRepetion _fastInvokeActionForRequest: bad elementID");
#endif
  LOGObjectFnStop();
  return element;
};

//--------------------------------------------------------------------
-(void)stopOneIterationWithIndex:(int)currentIndex
                           count:(int)count
                       isLastOne:(BOOL)isLastOne
                       inContext:(GSWContext*)context
{
  //OK
  LOGObjectFnStart();
  if (currentIndex==(count-1) || isLastOne)
    {
      NS_DURING
        {
          GSWComponent* component=[context component];
          if (_list && _item)
            [_item setValue:nil //??
                   inComponent:component];
          if (_index)
            [_index setValue:[NSNumber numberWithShort:0]
                    inComponent:component];
          [context deleteLastElementIDComponent];
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
-(void)startOneIterationWithIndex:(unsigned int)currentIndex
                             list:(NSArray*)list
                        inContext:(GSWContext*)context
{
  //OK
  GSWComponent* component=nil;
  LOGObjectFnStart();
  NS_DURING
    {
      component=[context component];
      NSDebugMLLog(@"gswdync",@"_item=%@",_item);

      if (_list && _item) {
	if ([list count]>currentIndex) { 
          [_item setValue:[list objectAtIndex:currentIndex]
              inComponent:component];
	} else {
	//NSLog(@"startOneIterationWithIndex SKIPPING setValue:inComponent index=%d list.count=%d",currentIndex, [list count]);
	}
      }

      NSDebugMLLog(@"gswdync",@"currentIndex=%d",currentIndex);
      NSDebugMLLog(@"gswdync",@"_index=%@",_index);
      if (_index) {
        [_index setValue:[NSNumber numberWithShort:currentIndex]
             inComponent:component];
      }
      if (currentIndex==0) {
        [context appendZeroElementIDComponent];
      } else {
        [context incrementLastElementIDComponent];
      }     
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
