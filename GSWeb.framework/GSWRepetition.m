/** GSWRepetition.m - <title>GSWeb: Class GSWRepetition</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
   $Revision$
   $Date$
   
   <abstract></abstract>

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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

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
          ExceptionRaise0(@"GSWRepetition",@"'item' parameter must be settable");
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
          ExceptionRaise0(@"GSWRepetition",@"'index' parameter must be settable");
        };

      if (!WOStrictFlag)
        {
          _startIndex=[[associations objectForKey:startIndex__Key
                                     withDefaultObject:[_startIndex autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"startIndex=%@",_startIndex);

          _stopIndex=[[associations objectForKey:stopIndex__Key
                                     withDefaultObject:[_stopIndex autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"stopIndex=%@",_stopIndex);
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
  DESTROY(_startIndex);
  DESTROY(_stopIndex);
  DESTROY(_childrenGroup);
  [super dealloc];
}

//--------------------------------------------------------------------
-(void)setDefinitionName:(NSString*)definitionName
{
  [super setDefinitionName:definitionName];
  if (definitionName && _childrenGroup)
    [_childrenGroup setDefinitionName:[NSString stringWithFormat:@"%@-StaticGroup",definitionName]];
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
@implementation GSWRepetition (GSWRepetitionA)

-(void)getParameterValuesReturnList:(NSArray**)listValuePtr
                              count:(int*)countValuePtr
                         startIndex:(int*)startIndexValuePtr
                          stopIndex:(int*)stopIndexValuePtr
                      withComponent:(GSWComponent*)component
{
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"_list=%@",_list);
  if (_list)
    {
      *listValuePtr=[_list valueInComponent:component];
      NSAssert2(!(*listValuePtr) || [(*listValuePtr) respondsToSelector:@selector(count)],
                @"The list (%@) (of class:%@) doesn't  respond to 'count'",
                _list,
                [(*listValuePtr) class]);
      *countValuePtr=[(*listValuePtr) count];
      NSDebugMLLog(@"gswdync",@"list count=%d",*countValuePtr);
    };
  NSDebugMLLog(@"gswdync",@"_count=%@",_count);
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
      NSDebugMLLog(@"gswdync",@"tmpCount=%d",tmpCount);
      if (_list)
        *countValuePtr=min(tmpCount,(*countValuePtr));
      else
        *countValuePtr=tmpCount;
    };
  if (WOStrictFlag)
    *stopIndexValuePtr=(*countValuePtr)-1;
  else
    {
      NSDebugMLLog(@"gswdync",@"_startIndex=%@",_startIndex);
      if (_startIndex)
        {
          id tmpStartIndexValue=[_startIndex valueInComponent:component];
          NSAssert3(!tmpStartIndexValue || [tmpStartIndexValue respondsToSelector:@selector(intValue)],
                @"The 'startIndex' (%@) value %@ (of class:%@) doesn't  respond to 'intValue'",
                _count,
                tmpStartIndexValue,
                [tmpStartIndexValue class]);
          *startIndexValuePtr=[tmpStartIndexValue intValue];
          *startIndexValuePtr=max(0,(*startIndexValuePtr));
        }
      else
        *startIndexValuePtr=0;
      NSDebugMLLog(@"gswdync",@"*startIndexValuePtr=%d",(*startIndexValuePtr));
      NSDebugMLLog(@"gswdync",@"_stopIndex=%@",_stopIndex);
      if (_stopIndex)  
        {
          id tmpStopIndexValue=[_stopIndex valueInComponent:component];
          NSAssert3(!tmpStopIndexValue || [tmpStopIndexValue respondsToSelector:@selector(intValue)],
                @"The 'startIndex' (%@) value %@ (of class:%@) doesn't  respond to 'intValue'",
                _count,
                tmpStopIndexValue,
                [tmpStopIndexValue class]);
          *stopIndexValuePtr=[tmpStopIndexValue intValue];
          NSDebugMLLog(@"gswdync",@"*stopIndexValuePtr=%d",(*stopIndexValuePtr));
          if (_count) // if not count, just take start and stop index
            {
              if ((*countValuePtr)>((*stopIndexValuePtr)+1))
                *countValuePtr=(*stopIndexValuePtr)+1;
              else
                *stopIndexValuePtr=(*countValuePtr)-1;
            }
          else
            *countValuePtr=(*stopIndexValuePtr)+1;
          NSDebugMLLog(@"gswdync",@"*stopIndexValuePtr=%d",(*stopIndexValuePtr));
          NSDebugMLLog(@"gswdync",@"*countValuePtr=%d",(*countValuePtr));
        }
      else
        *stopIndexValuePtr=(*countValuePtr)-1;
      NSDebugMLLog(@"gswdync",@"*stopIndexValuePtr=%d",(*stopIndexValuePtr));
    };
  NSDebugMLLog(@"gswdync",@"PARAMETERS: list: %p startIndex: %d stopIndex: %d count: %d",
               *listValuePtr,
               *startIndexValuePtr,
               *stopIndexValuePtr,
               *countValuePtr);
  LOGObjectFnStop();
};
//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  //OK
  GSWComponent* component=nil;
  NSArray* listValue=nil;
  int i=0;
  int countValue=0;
  int startIndexValue = 0;
  int stopIndexValue = 0;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStart();
  GSWStartElement(context);
  GSWSaveAppendToResponseElementID(context);
  component=[context component];
  [self getParameterValuesReturnList:&listValue
        count:&countValue
        startIndex:&startIndexValue
        stopIndex:&stopIndexValue
        withComponent:component];

  NSDebugMLLog(@"gswdync",@"countValue=%d",countValue);
  [context incrementLoopLevel];
  for(i=startIndexValue;i<=stopIndexValue;i++)
    {
#ifndef NDEBUG
      GSWElementIDString* debugElementID=[context elementID];
#endif
      [self startOneIterationWithIndex:i
            startIndex:startIndexValue
            list:listValue
            inContext:context];
      [context appendZeroElementIDComponent];
      [_childrenGroup appendToResponse:response
                      inContext:context];
      [context deleteLastElementIDComponent];
      [self stopOneIterationWithIndex:i
            stopIndex:stopIndexValue
            count:countValue
            isLastOne:NO
            inContext:context];
#ifndef NDEBUG
      if (![debugElementID isEqualToString:[context elementID]])
        {
          NSDebugMLLog(@"gswdync",@"class=%@ debugElementID=%@ [context elementID]=%@",
                       [self class],debugElementID,[context elementID]);
          
        };
#endif
    };
  [context decrementLoopLevel];
  GSWStopElement(context);
#ifndef NDEBBUG
  NSAssert4(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],
           @"GSWRepetion %p appendToResponse: bad elementID %d!=%d (%@)",
            self,
            elementsNb,
            [(GSWElementIDString*)[context elementID]elementsNb],
            [context elementID]);
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
  GSWStartElement(context);
  isInForm=[context isInForm];
  NSDebugMLLog(@"gswdync",@"isInForm=%s",isInForm ? "YES" : "NO");
  if (isInForm)
    element=[self _slowInvokeActionForRequest:request
                  inContext:context];
  else
    element=[self _fastInvokeActionForRequest:request
                  inContext:context];
  NSDebugMLLog(@"gswdync",@"element=%@",element);
  GSWStopElement(context);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],
           @"GSWRepetion invokeActionForRequest: bad elementID");
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
  int startIndexValue = 0;
  int stopIndexValue = 0;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStart();
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);
  component=[context component];
  [self getParameterValuesReturnList:&listValue
        count:&countValue
        startIndex:&startIndexValue
        stopIndex:&stopIndexValue
        withComponent:component];
  [context incrementLoopLevel];
  for(i=startIndexValue;i<=stopIndexValue;i++)
    {
#ifndef NDEBUG
      GSWElementIDString* debugElementID=[context elementID];
#endif
      [self startOneIterationWithIndex:i
            startIndex:startIndexValue
            list:listValue
            inContext:context];
      [context appendZeroElementIDComponent];
      [_childrenGroup takeValuesFromRequest:request
                      inContext:context];
      [context deleteLastElementIDComponent];
      [self stopOneIterationWithIndex:i
            stopIndex:stopIndexValue
            count:countValue
            isLastOne:NO
            inContext:context];
#ifndef NDEBUG
      if (![debugElementID isEqualToString:[context elementID]])
        {
          NSDebugMLLog(@"gswdync",@"class=%@ debugElementID=%@ [context elementID]=%@",
                       [self class],debugElementID,[context elementID]);
          
        };
#endif
    };
  [context decrementLoopLevel];
  GSWStopElement(context);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],
           @"GSWRepetion takeValuesFromRequest: bad elementID");
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
  int startIndexValue = 0;
  int stopIndexValue = 0;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStart();
  GSWStartElement(context);
  component=[context component];
  [self getParameterValuesReturnList:&listValue
        count:&countValue
        startIndex:&startIndexValue
        stopIndex:&stopIndexValue
        withComponent:component];
  [context incrementLoopLevel];
  for(i=startIndexValue;!element && i<=stopIndexValue;i++)
    {
#ifndef NDEBUG
      GSWElementIDString* debugElementID=[context elementID];
#endif
      [self startOneIterationWithIndex:i
            startIndex:startIndexValue
            list:listValue
            inContext:context];
      [context appendZeroElementIDComponent];
      element=[_childrenGroup invokeActionForRequest:request
                             inContext:context];
      NSAssert3(!element || [element isKindOfClass:[GSWElement class]],
                @"_childrenGroup=%@ Element is a %@ not a GSWElement: %@",
                _childrenGroup,
                [element class],
                element);
      [context deleteLastElementIDComponent];
      [self stopOneIterationWithIndex:i
            stopIndex:stopIndexValue
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
  [context decrementLoopLevel];
  GSWStopElement(context);
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
  GSWStartElement(context);
  senderID=[context senderID];
  NSDebugMLLog(@"gswdync",@"senderID=%@",senderID);
  elementID=[context elementID];
  if ([senderID hasPrefix:elementID])
    {
#ifndef NDEBUG
      GSWElementIDString* debugElementID=[context elementID];
#endif
      int countValue=0;
      NSArray* listValue=nil;
      int startIndexValue = 0;
      int stopIndexValue = 0;
      int i=0;
      GSWComponent* component=[context component];
      [self getParameterValuesReturnList:&listValue
            count:&countValue
            startIndex:&startIndexValue
            stopIndex:&stopIndexValue
            withComponent:component];
      [context incrementLoopLevel];
      for(i=startIndexValue;!element && i<=stopIndexValue;i++)
        {
          [self startOneIterationWithIndex:i
                startIndex:startIndexValue
                list:listValue
                inContext:context];
          [context appendZeroElementIDComponent];
          element=[_childrenGroup invokeActionForRequest:request
                                  inContext:context];
          NSDebugMLLog(@"gswdync",@"element=%@",element);
          [context deleteLastElementIDComponent];
          [self stopOneIterationWithIndex:i
                stopIndex:stopIndexValue
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
      [context decrementLoopLevel];
    };
  GSWStopElement(context);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],@"GSWRepetion _fastInvokeActionForRequest: bad elementID");
#endif
  LOGObjectFnStop();
  return element;
};

//--------------------------------------------------------------------
-(void)stopOneIterationWithIndex:(int)currentIndex
                       stopIndex:(int)stopIndex
                           count:(int)count
                       isLastOne:(BOOL)isLastOne
                       inContext:(GSWContext*)context
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"gswdync",@"self=%p currentIndex=%d stopIndex=%d count=%d isLastOne=%s [context elementID]=%@",
               self,currentIndex,stopIndex,count,(isLastOne ? "YES" : "NO"),
               [context elementID]);
  if (currentIndex==(count-1) || currentIndex==stopIndex ||isLastOne)
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
                       startIndex:(unsigned int)startIndex
                             list:(NSArray*)list
                        inContext:(GSWContext*)context
{
  //OK
  GSWComponent* component=nil;
  LOGObjectFnStart();
  NS_DURING
    {
      component=[context component];
      NSDebugMLLog(@"gswdync",@"currentIndex=%d startIndex=%d",currentIndex,startIndex);
      NSDebugMLLog(@"gswdync",@"_index=%@",_index);
      NSDebugMLLog(@"gswdync",@"_item=%@",_item);
      if (_list && _item) {
	if ([list count]>currentIndex) { 
          NSDebugMLLog(@"gswdync",@"[list objectAtIndex:%d]=%@",currentIndex,[list objectAtIndex:currentIndex]);
          [_item setValue:[list objectAtIndex:currentIndex]
              inComponent:component];
	} else {
	//NSLog(@"startOneIterationWithIndex SKIPPING setValue:inComponent index=%d list.count=%d",currentIndex, [list count]);
	}
      }

      if (_index)
        [_index setValue:[NSNumber numberWithShort:currentIndex]
                inComponent:component];
      if (currentIndex==startIndex)
        [context appendZeroElementIDComponent];
      else
        [context incrementLastElementIDComponent];
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

