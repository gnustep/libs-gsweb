/** GSWCacheElement.m - <title>GSWeb: Class GSWCacheElement</title>

   Copyright (C) 2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 2004
   
   $Revision$
   $Date$
   $Id$

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

#include "GSWExtGSWWOCompatibility.h"
#include "GSWCacheElement.h"

/**
GSWCacheElement is an object childrens
There's 2 modes: cachedObject or cache.
Bindings

        cachedObject		Evaluated with valueInComponent to get cached data , evaluated with setValue:inComponent: te cache data.

        cache			Evaluated to get a GSWCache object used to store and retrieve data using key, key0,keyN...
        duration		Evaluated when puting data in a GSWCache to set cache duration. Not allowed when using 'cachedObject' binding)
        uniqID			A string unique used to replace contextual data (session id, context and element id when storing data in cache.
       					it should be unique in children caches.
        disabled		If evaluated to yes, caching is disabled

        enabled			If evaluated to no, caching is disabled

        key,key0,keyN...	(key|key0), key1, key2,... are keys which will be used to put data in a GSWCache. You need at list one key (called 
       					key or key0).
**/

//====================================================================
@implementation GSWCacheElement

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  LOGObjectFnStart();
  if ((self=[super initWithName:aName
                   associations:nil
                   template:nil]))
    {
      if (elements)
        _childrenGroup=[[GSWHTMLStaticGroup alloc]initWithContentElements:elements];

      _cachedObject = [[associations objectForKey:@"cachedObject"
                                     withDefaultObject:[_cachedObject autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"cachedObject=%@",_cachedObject);
      
      _cache = [[associations objectForKey:@"cache"
                              withDefaultObject:[_cache autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"cache=%@",_cache);

      _duration = [[associations objectForKey:@"duration"
                                 withDefaultObject:[_duration autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"duration=%@",_duration);
      
      _uniqID = [[associations objectForKey:@"uniqID"
                               withDefaultObject:[_uniqID autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"uniqID=%@",_uniqID);
      
      _disabled = [[associations objectForKey:disabled__Key
                                 withDefaultObject:[_disabled autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"disabled=%@",_disabled);
      
      _enabled = [[associations objectForKey:enabled__Key
                                withDefaultObject:[_enabled autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"enabled=%@",_enabled);
      
      if (_disabled && _enabled)
        {
          ExceptionRaise(@"GSWCacheElement",@"You can't specify 'disabled' and 'enabled' together. componentAssociations:%@",
                         associations);
        }
      else if (_cachedObject && _cache)
        {
          ExceptionRaise(@"GSWCacheElement",@"You can't specify 'cachedObject' and 'cache' together. componentAssociations:%@",
                         associations);
        }
      else
        {
          if (_cachedObject)
            {
              if ([_cachedObject isValueConstant])
                {
                  ExceptionRaise0(@"GSWCacheElement",
                                  @"'cachedObject' parameter can't be a constant");
                };
            }
          else if (_cache)
            {
              // Get keys associations
              int keyIndex=0;
              NSMutableArray* keysArray=(NSMutableArray*)[NSMutableArray array];
              GSWAssociation* aKeyAssociation=nil;
              do
                {
                  if (keyIndex==0)
                    {
                      aKeyAssociation=[associations objectForKey:@"key"];
                      if (!aKeyAssociation)
                        {
                          aKeyAssociation=[associations objectForKey:@"key0"];
                        }
                    }
                  else
                    {
                      aKeyAssociation=[associations objectForKey:[NSString stringWithFormat:@"key%d",keyIndex]];
                    };
                  if (aKeyAssociation)
                    [keysArray addObject:aKeyAssociation];
                  keyIndex++;
                }
              while(aKeyAssociation);

              if ([keysArray count]>0)
                ASSIGN(_keys,([NSArray arrayWithArray:keysArray]));
              else
                {
                  ExceptionRaise(@"GSWCacheElement",@"You have to define keys (like key=...; key1=...; ... componentAssociations:%@",
                                 associations);
                };
            }
          else
            {
              ExceptionRaise(@"GSWCacheElement",@"You have to define  'cachedObject' or 'cache' together. componentAssociations:%@",
                             associations);
            };
        };
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)someAssociations
         template:(GSWElement*)templateElement
{
  LOGObjectFnStart();
  if ((self=[self initWithName:aName
                  associations:someAssociations
                  contentElements:templateElement ? [NSArray arrayWithObject:templateElement] : nil]))
    {
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_childrenGroup);
  DESTROY(_cachedObject);
  DESTROY(_cache);
  DESTROY(_duration);
  DESTROY(_keys);
  DESTROY(_uniqID);
  DESTROY(_disabled);
  DESTROY(_enabled);
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
@implementation GSWCacheElement (GSWCacheElementA)

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  GSWComponent* component=nil;
  BOOL isDisabled=NO;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[aContext elementID]elementsNb];
#endif

  LOGObjectFnStart();

  component=[aContext component];

  NS_DURING
    {
      BOOL cacheUsed=NO;
      NSString* contextAndElementID=nil;
      NSString* elementID=nil;
      NSString* uniqID=nil;
      NSString* sessionID=nil;
      NSString* contextAndElementIDCacheKey=nil;
      NSString* elementIDCacheKey=nil;
      GSWCache* cache=nil;
      int keysCount=[_keys count];
      id keys[keysCount];
      int i=0;
      GSWStartElement(aContext);
      GSWSaveAppendToResponseElementID(aContext);

      NSLog(@"GSWCacheElement Start Date=%@",[NSDate date]);

      if (_disabled)
        isDisabled=[self evaluateCondition:_disabled
                         inContext:aContext];
      else if (_enabled)
        isDisabled=![self evaluateCondition:_enabled
                          inContext:aContext];
      
      uniqID=[_uniqID valueInComponent:component];

      // Append an element to elementID So all children elementIDs will start with the same prefix
      [aContext appendElementIDComponent:[NSString stringWithFormat:@"CacheElement-%@",uniqID]];

      contextAndElementID=[aContext contextAndElementID];
      NSDebugMLog(@"contextAndElementID=%@",contextAndElementID);

      elementID=[[[aContext elementID] copy]autorelease]; // because elementID is mutable (and varying)
      NSDebugMLog(@"elementID=%@",elementID);

      sessionID=[[aContext session] sessionID];
      NSDebugMLog(@"sessionID=%@",sessionID);
      
      NSDebugMLLog(@"gswdync",@"isDisabled=%d",isDisabled);

      if (!isDisabled)
        {
          id cachedObject=nil;
          if (_cachedObject)
            cachedObject=[_cachedObject valueInComponent:component];
          else
            {
              cache=[_cache valueInComponent:component];
              for(i=0;i<keysCount;i++)
                {
                  GSWAssociation* assoc=[_keys objectAtIndex:i];
                  keys[i]=[assoc valueInComponent:component];
                  NSDebugMLLog(@"gswdync",@"keys[%d]=%@",i,keys[i]);
                  if (!keys[i])
                    {
                      keysCount=i; // change count and stop
                      break;
                    };
                };
              cachedObject=[cache objectForKeys:keys
                                  count:keysCount];
            };
          NSDebugMLLog(@"gswdync",@"cachedObject=%p",cachedObject);

          contextAndElementIDCacheKey=[NSString stringWithFormat:@"##CONTEXT_ELEMENT_ID-%@##",
                                                uniqID];
          elementIDCacheKey=[NSString stringWithFormat:@"##ELEMENT_ID-%@##",
                                      uniqID];

          if (cachedObject)
            {
              cacheUsed=YES;
              cachedObject=[[cachedObject mutableCopy] autorelease];
              //NSLog(@"GSWCacheElement: cachedObject found=%@",cachedObject);
              if ([cachedObject isKindOfClass:[NSString class]])
                {
                  NSDebugMLog(@"cachedObject=%@",cachedObject);
                  
                  [(NSMutableString*)cachedObject replaceOccurrencesOfString:contextAndElementIDCacheKey
                                     withString:contextAndElementID
                                     options:0
                                     range:NSMakeRange(0,[cachedObject length])];

                  [(NSMutableString*)cachedObject replaceOccurrencesOfString:elementIDCacheKey
                                     withString:elementID
                                     options:0
                                     range:NSMakeRange(0,[cachedObject length])];

                  [(NSMutableString*)cachedObject replaceOccurrencesOfString:@"##SESSION_ID##"
                                     withString:sessionID
                                     options:0
                                     range:NSMakeRange(0,[cachedObject length])];

                  NSDebugMLog(@"cachedObject result=%@",cachedObject);
                  [aResponse appendContentString:(NSString*)cachedObject];
                }
              else
                {
                  [(NSMutableData*)cachedObject replaceOccurrencesOfData:[contextAndElementIDCacheKey dataUsingEncoding:[aResponse contentEncoding]]
                                   withData:[contextAndElementID dataUsingEncoding:[aResponse contentEncoding]]
                                   range:NSMakeRange(0,[cachedObject length])];

                  [(NSMutableData*)cachedObject replaceOccurrencesOfData:[elementIDCacheKey dataUsingEncoding:[aResponse contentEncoding]]
                                   withData:[elementID dataUsingEncoding:[aResponse contentEncoding]]
                                   range:NSMakeRange(0,[cachedObject length])];

                  [(NSMutableData*)cachedObject replaceOccurrencesOfData:[@"##SESSION_ID##" dataUsingEncoding:[aResponse contentEncoding]]
                                   withData:[sessionID dataUsingEncoding:[aResponse contentEncoding]]
                                   range:NSMakeRange(0,[cachedObject length])];
                  [aResponse appendContentData:(NSData*)cachedObject];
                }
            }
          else
            {
              _cacheIndex=[aResponse startCache];              
              NSDebugMLLog(@"gswdync",@"cacheIndex=%d",_cacheIndex);
            };
        };

      NSDebugMLLog(@"gswdync",@"cacheUsed=%d",cacheUsed);
      if (!cacheUsed)
        {
          NSLog(@"GSWCacheElement Children Start Date=%@",[NSDate date]);
          [_childrenGroup appendToResponse:aResponse
                          inContext:aContext];
          NSLog(@"GSWCacheElement Children Stop Date=%@",[NSDate date]);
        };

      if (!cacheUsed && !isDisabled)
        {
          id cachedObject=[aResponse stopCacheOfIndex:_cacheIndex];
          NSDebugMLLog(@"gswdync",@"cachedObject=%p",cachedObject);
          if ([cachedObject isKindOfClass:[NSMutableString class]])
            {
              NSDebugMLog(@"cachedObject=%@",cachedObject);
              [(NSMutableString*)cachedObject replaceOccurrencesOfString:contextAndElementID
                                 withString:contextAndElementIDCacheKey
                                 options:0
                                 range:NSMakeRange(0,[cachedObject length])];

              [(NSMutableString*)cachedObject replaceOccurrencesOfString:elementID
                                 withString:elementIDCacheKey
                                 options:0
                                 range:NSMakeRange(0,[cachedObject length])];
              
              [(NSMutableString*)cachedObject replaceOccurrencesOfString:sessionID
                                 withString:@"##SESSION_ID##"
                                 options:0
                                 range:NSMakeRange(0,[cachedObject length])];                            
              NSDebugMLLog(@"gswdync",@"cachedObject=%@",cachedObject);
            }
          else
            {
              [(NSMutableData*)cachedObject replaceOccurrencesOfData:[contextAndElementID dataUsingEncoding:[aResponse contentEncoding]]
                               withData:[contextAndElementIDCacheKey dataUsingEncoding:[aResponse contentEncoding]]
                               range:NSMakeRange(0,[cachedObject length])];

              [(NSMutableData*)cachedObject replaceOccurrencesOfData:[elementID dataUsingEncoding:[aResponse contentEncoding]]
                               withData:[elementIDCacheKey dataUsingEncoding:[aResponse contentEncoding]]
                               range:NSMakeRange(0,[cachedObject length])];

              [(NSMutableData*)cachedObject replaceOccurrencesOfData:[sessionID dataUsingEncoding:[aResponse contentEncoding]]
                               withData:[@"##SESSION_ID##" dataUsingEncoding:[aResponse contentEncoding]]
                               range:NSMakeRange(0,[cachedObject length])];
            };
          if (_cachedObject)
            [_cachedObject setValue:cachedObject
                           inComponent:component];
          else
            {
              id duration=[_duration valueInComponent:component];
              NSDebugMLLog(@"gswdync",@"duration=%@",duration);
              if (duration)
                {
                  NSTimeInterval ts=0;
                  if ([duration respondsToSelector:@selector(floatValue)])
                    ts=[duration floatValue];
                  else if ([duration respondsToSelector:@selector(intValue)])
                    ts=[duration floatValue];
                  else
                    ExceptionRaise(@"GSWCacheElement",@"Don't know how to get a timeinterval from %@ of class %@",
                                   duration,[duration class]);
                  [cache setObject:cachedObject
                         withDuration:ts
                         forKeys:keys
                         count:keysCount];
                }
              else
                {
                  [cache setObject:cachedObject
                         forKeys:keys
                         count:keysCount];
                };
            };
        };

      [aContext deleteLastElementIDComponent];

      NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[aContext elementID]);

      NSLog(@"GSWCacheElement Stop Date=%@",[NSDate date]);

#ifndef NDEBBUG
      NSAssert(elementsNb==[(GSWElementIDString*)[aContext elementID]elementsNb],@"GSWCacheElement appendToResponse: bad elementID");
#endif
    }
  NS_HANDLER
    {
      LOGException0(@"exception in GSWCacheElement appendToResponse:inContext");
      LOGException(@"exception=%@",localException);
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"In GSWForm appendToResponse:inContext");
      LOGException(@"exception=%@",localException);
      [localException raise];
    }
  NS_ENDHANDLER;

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext
{
  NSString* uniqID=nil;

  LOGObjectFnStart();

  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);

  uniqID=[_uniqID valueInComponent:[aContext component]];

  // Append an element to elementID So all children elementIDs will start with the same prefix
  [aContext appendElementIDComponent:[NSString stringWithFormat:@"CacheElement-%@",uniqID]];

  [_childrenGroup takeValuesFromRequest:aRequest
                  inContext:aContext];
  [aContext deleteLastElementIDComponent];

  GSWStopElement(aContext);
  GSWAssertIsElementID(aContext);

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext
{
  GSWElement* element=nil;
  NSString* uniqID=nil;

  LOGObjectFnStart();

  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);

  uniqID=[_uniqID valueInComponent:[aContext component]];

  // Append an element to elementID So all children elementIDs will start with the same prefix
  [aContext appendElementIDComponent:[NSString stringWithFormat:@"CacheElement-%@",uniqID]];

  element=[_childrenGroup invokeActionForRequest:aRequest
                          inContext:aContext];

  NSDebugMLLog(@"gswdync",@"element=%@",element);
  NSAssert2(!element || [element isKindOfClass:[GSWElement class]],
            @"Element is a %@ not a GSWElement: %@",
            [element class],
            element);

  [aContext deleteLastElementIDComponent];

  GSWStopElement(aContext);
  GSWAssertIsElementID(aContext);

  LOGObjectFnStop();

  return element;
};



@end
