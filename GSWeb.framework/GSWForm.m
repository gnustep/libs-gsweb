/** GSWForm.m - <title>GSWeb: Class GSWForm</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
   $Revision$
   $Date$

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
@implementation GSWForm

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  NSMutableDictionary* tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
  LOGObjectFnStartC("GSWForm");
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ elements=%@",aName,associations,elements);
  if (![tmpAssociations objectForKey:@"method"])
    {
      if ([tmpAssociations objectForKey:@"get"])
        [tmpAssociations setObject:[GSWAssociation associationWithValue:@"get"]
                         forKey:@"method"];
      else
        [tmpAssociations setObject:[GSWAssociation associationWithValue:@"post"]
                         forKey:@"method"];
    };
  [tmpAssociations removeObjectForKey:action__Key];
  [tmpAssociations removeObjectForKey:href__Key];
  [tmpAssociations removeObjectForKey:multipleSubmit__Key];
  [tmpAssociations removeObjectForKey:actionClass__Key];
  if (_directActionName)
    [tmpAssociations removeObjectForKey:_directActionName];

  if (!WOStrictFlag)
    {
      [tmpAssociations removeObjectForKey:disabled__Key];
      [tmpAssociations removeObjectForKey:enabled__Key];
    };
  [tmpAssociations removeObjectForKey:queryDictionary__Key];

  //call isValueSettable sur value (return YES)
  _action = [[associations objectForKey:action__Key
                           withDefaultObject:[_action autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm: action=%@",_action);

  _href = [[associations objectForKey:href__Key
                         withDefaultObject:[_href autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm: href=%@",_href);

  _multipleSubmit = [[associations objectForKey:multipleSubmit__Key
                                   withDefaultObject:[_multipleSubmit autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm: multipleSubmit=%@",_multipleSubmit);

  _actionClass = [[associations objectForKey:actionClass__Key
                                withDefaultObject:[_actionClass autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm: actionClass=%@",_actionClass);

  _directActionName = [[associations objectForKey:directActionName__Key
                                     withDefaultObject:[_directActionName autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm: directActionName=%@",_directActionName);

  if (!WOStrictFlag)
    {
      _disabled = [[associations objectForKey:disabled__Key
                                 withDefaultObject:[_disabled autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWForm disabled=%@",_disabled);
      _enabled = [[associations objectForKey:enabled__Key
                                withDefaultObject:[_enabled autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWForm enabled=%@",_enabled);
      if (_disabled && _enabled)
	{
	  ExceptionRaise(@"GSWForm",@"You can't specify 'disabled' and 'enabled' together. componentAssociations:%@",
                         associations);
	};
    };

  _queryDictionary = [[associations objectForKey:queryDictionary__Key
                                    withDefaultObject:[_queryDictionary autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWForm: queryDictionary=%@",_queryDictionary);

  if ([tmpAssociations count]>0)
    {
      ASSIGN(_otherQueryAssociations,([tmpAssociations extractObjectsForKeysWithPrefix:@"?"
                                                       removePrefix:YES]));
      if ([_otherQueryAssociations count]==0)
        DESTROY(_otherQueryAssociations);

      if (!WOStrictFlag)
        {
          ASSIGN(_otherPathQueryAssociations,([tmpAssociations extractObjectsForKeysWithPrefix:@"!"
                                                               removePrefix:YES]));
          if ([_otherPathQueryAssociations count]==0)
            DESTROY(_otherPathQueryAssociations);
        };
    };

  NSDebugMLLog(@"gswdync",@"_otherQueryAssociations=%@",_otherQueryAssociations);
  NSDebugMLLog(@"gswdync",@"_otherPathQueryAssociations=%@",_otherPathQueryAssociations);

  if ((self=[super initWithName:aName
                   attributeAssociations:tmpAssociations
                   contentElements:elements]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_action);
  DESTROY(_href);
  DESTROY(_multipleSubmit);
  DESTROY(_actionClass);
  DESTROY(_directActionName);
  DESTROY(_queryDictionary);
  DESTROY(_disabled);
  DESTROY(_enabled);
  DESTROY(_otherQueryAssociations);
  DESTROY(_otherPathQueryAssociations);
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

//GSWeb Additions {
//--------------------------------------------------------------------
-(BOOL)disabledInContext:(GSWContext*)context
{
  //OK
  if (_enabled)
    return ![self evaluateCondition:_enabled
                  inContext:context];
  else
    return [self evaluateCondition:_disabled
                 inContext:context];
};
// }
//--------------------------------------------------------------------
-(BOOL)compactHTMLTags
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(void)_appendHiddenFieldsToResponse:(GSWResponse*)response
                           inContext:(GSWContext*)context
{
  NSDictionary* hiddenFields = nil;
  LOGObjectFnStart();

  hiddenFields = [self computeQueryDictionaryInContext:context];
  if([hiddenFields count]>0)
    {
      NSEnumerator* enumerator=[hiddenFields keyEnumerator];
      id key=nil;
      while((key=[enumerator nextObject]))
        {
          id value=[hiddenFields objectForKey:key];
          [response _appendContentAsciiString:@"<input type=hidden"];
          [response _appendTagAttribute:@"name"
                    value:key
                    escapingHTMLAttributeValue:NO];//Don't escape name
          [response _appendTagAttribute:@"value"
                    value:value
                    escapingHTMLAttributeValue:NO];//Don't escape value (should be escaped before !)
        };
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSDictionary*)computeQueryDictionaryInContext:(GSWContext*)context
{
  NSDictionary* queryDictionary=nil;
  LOGObjectFnStart();
  queryDictionary=[self computeQueryDictionaryWithActionClassAssociation:_actionClass
                        directActionNameAssociation:_directActionName
                        queryDictionaryAssociation:_queryDictionary
                        otherQueryAssociations:_otherQueryAssociations
                        inContext:context];
  LOGObjectFnStop();
  return queryDictionary;
};

//--------------------------------------------------------------------
-(NSString*)computeActionStringInContext:(GSWContext*)context
{
  NSString* actionString=nil;
  LOGObjectFnStart();
  actionString=[self computeActionStringWithActionClassAssociation:_actionClass
                     directActionNameAssociation:_directActionName
                     otherPathQueryAssociations:_otherPathQueryAssociations
                     inContext:context];
  LOGObjectFnStop();
  return actionString;
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  //OK
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStartC("GSWForm");
  GSWStartElement(context);
  GSWSaveAppendToResponseElementID(context);
  [response appendDebugCommentContentString:[NSString stringWithFormat:@"defName=%@ ID=%@",
                                                      [self definitionName],
                                                      [context elementID]]];

  if (!WOStrictFlag)
    {
      BOOL disabledInContext=NO;
      disabledInContext=[self disabledInContext:context];
      [context setInForm:!disabledInContext];
    }
  else
    [context setInForm:YES];

  [self appendToResponse:response
        inContext:context
        elementsFromIndex:0
        toIndex:[_elementsMap length]-2];
  [self _appendHiddenFieldsToResponse:response
        inContext:context];
  [self appendToResponse:response
        inContext:context
        elementsFromIndex:[_elementsMap length]-1
        toIndex:[_elementsMap length]-1];
  [context setInForm:NO];
  GSWStopElement(context);
#ifndef NDEBBUG
  NSAssert3(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],
           @"GSWForm appendToResponse: bad elementID: elementsNb=%d [context elementID]=%@ [(GSWElementIDString*)[context elementID]elementsNb]=%d",
           elementsNb,[context elementID],[(GSWElementIDString*)[context elementID]elementsNb]);
#endif
  LOGObjectFnStopC("GSWForm");
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
{
  //OK
  GSWElement* element=nil;
  NSString* senderID=nil;
  GSWElementIDString* elementID=nil;
  BOOL isFormSubmited=NO;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  BOOL multipleSubmitValue=NO;
  LOGObjectFnStartC("GSWForm");
  GSWStartElement(context);
  senderID=[context senderID];
  elementID=[context elementID];
  NSDebugMLLog(@"gswdync",@"senderId=%@",senderID);
  NS_DURING
    {
      GSWAssertCorrectElementID(context);// Debug Only
      if ([self prefixMatchSenderIDInContext:context]) //Avoid trying to find action if we are not the good component
        {
          isFormSubmited=[elementID isEqualToString:senderID];
          NSDebugMLLog(@"gswdync",@"ET=%@ defName=%@ \n      id=%@ \nsenderId=%@ \nisFormSubmited=%s",
                       [self class],
                       [self definitionName],
                       elementID,                           
                       senderID,
                       (isFormSubmited ? "YES" : "NO"));
          if (!WOStrictFlag && isFormSubmited && [self disabledInContext:context])
            isFormSubmited=NO;
          
          if (isFormSubmited)
            {
              [context setInForm:YES];
              [context _setFormSubmitted:YES];
              multipleSubmitValue=[self evaluateCondition:_multipleSubmit
                                        inContext:context];
              NSDebugMLLog(@"gswdync",@"ET=%@ defName=%@ \n      id=%@ \nsenderId=%@ \nmultipleSubmit=%s",
                           [self class],
                           [self definitionName],
                           elementID,                           
                           senderID,
                           (multipleSubmitValue ? "YES" : "NO"));
              [context _setIsMultipleSubmitForm:multipleSubmitValue];
            };
/*
          for(i=0;!element && !searchIsOver && i<[_dynamicChildren count];i++)
            {
              NSDebugMLLog(@"gswdync",@"i=%d",i);
              element=[[_dynamicChildren objectAtIndex:i] invokeActionForRequest:request
                                                          inContext:context];

//              if (![context _wasFormSubmitted] && [[context elementID] compare:senderID]==NSOrderedDescending)
              if (![context _wasFormSubmitted] && [[context elementID] isSearchOverForSenderID:senderID])
                {
                  NSDebugMLLog(@"gswdync",@"id=%@ senderid=%@ => search is over",
                               [context elementID],
                               senderID);
                  searchIsOver=YES;
                };
              [context incrementLastElementIDComponent];
            };
*/

          NSDebugMLLog(@"gswdync",@"isFormSubmited=%d",isFormSubmited);

          element=[super invokeActionForRequest:request
                         inContext:context];
          NSAssert2(!element || [element isKindOfClass:[GSWElement class]],
                    @"Element is a %@ not a GSWElement: %@",
                    [element class],
                    element);

          NSDebugMLLog(@"gswdync",@"isFormSubmited=%d",isFormSubmited);
          NSDebugMLLog(@"gswdync",@"[context _wasActionInvoked]=%d",[context _wasActionInvoked]);

          if (isFormSubmited)
            {
              NSDebugMLLog(@"gswdync",@"ET=%@ defName=%@ \n      id=%@ \nsenderId=%@ \nmultipleSubmit=%s \n[context _wasActionInvoked]=%d",
                           [self class],
                           [self definitionName],
                           elementID,                           
                           senderID,
                           (multipleSubmitValue ? "YES" : "NO"),
                           [context _wasActionInvoked]);
              if (_action && ![context _wasActionInvoked])
                {
                  GSWComponent* component=[context component];
                    element = (GSWElement*)[_action valueInComponent:component];
                    [context _setActionInvoked:YES];
                };
              [context setInForm:NO];
              [context _setFormSubmitted:NO];
              [context _setIsMultipleSubmitForm:NO];
            };
          elementID=[context elementID];
          GSWStopElement(context);
        };
#ifndef NDEBBUG
      NSAssert3(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],
                @"GSWForm invokeActionForRequest: bad elementID: elementsNb=%d [context elementID]=%@ [(GSWElementIDString*)[context elementID]elementsNb]=%d",
                elementsNb,[context elementID],[(GSWElementIDString*)[context elementID]elementsNb]);
#endif
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
  senderID=[context senderID];
  elementID=[context elementID];
  //if (![context _wasActionInvoked] && [_elementID compare:senderID]!=NSOrderedAscending)
  if (![context _wasActionInvoked] && [elementID isSearchOverForSenderID:senderID])
    {
      LOGError(@"Action not invoked at the end of %@ (def name=%@) (id=%@) senderId=%@",
               [self class],
               [self definitionName],
               elementID,
               senderID);
    };
  LOGObjectFnStopC("GSWForm");
  return element; 
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //OK
  NSString* senderID=nil;
  NSString* elementID=nil;
  BOOL isFormSubmited=NO;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStartC("GSWForm");
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);

  senderID=[context senderID];
  elementID=[context elementID];
  NSDebugMLLog(@"gswdync",@"senderID=%@",senderID);
  if ([self prefixMatchSenderIDInContext:context]) //Avoid taking values if we are not the good form
    {
      isFormSubmited=[elementID isEqualToString:senderID];
      NSDebugMLLog(@"gswdync",@"isFormSubmited=%d",(int)isFormSubmited);
      if (!WOStrictFlag && isFormSubmited && [self disabledInContext:context])
        isFormSubmited=NO;
	  
      NSDebugMLLog(@"gswdync",@"Starting GSWForm TV ET=%@ id=%@",[self class],[context elementID]);
      if (isFormSubmited)
        {
          [context setInForm:YES];
          [context _setFormSubmitted:YES];
        };
      NSDebugMLLog(@"gswdync",@"\n\ndynamicChildren=%@",_dynamicChildren);
      NSDebugMLLog(@"gswdync",@"[dynamicChildren count]=%d",[_dynamicChildren count]);

      [super takeValuesFromRequest:request
             inContext:context];

      if (isFormSubmited)
        {
          [context setInForm:NO];
          [context _setFormSubmitted:NO];
        };
    };
  GSWStopElement(context);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],
           @"GSWForm takeValuesFromRequest: bad elementID");
#endif
  LOGObjectFnStopC("GSWForm");
};

@end

//====================================================================
@implementation GSWForm (GSWFormB)

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response
                                      inContext:(GSWContext*)context
{
  BOOL disabledInContext=NO;
  LOGObjectFnStartC("GSWForm");
  if (!WOStrictFlag)
    {
      disabledInContext=[self disabledInContext:context];
      NSDebugMLLog(@"gswdync",@"disabledInContext=%s",(disabledInContext ? "YES" : "NO"));
    };
  if (!disabledInContext)
    {
      GSWComponent* component=[context component];
      if (_href)
        {
          id actionValue=[_href valueInComponent:component];
          //TODO emit a warning !
          [response _appendTagAttribute:@"action"
                    value:actionValue
                    escapingHTMLAttributeValue:NO];
        }
      else if (_directActionName || _actionClass)
        {
          [self _appendCGIActionToResponse:response
                inContext:context];
        }
      else
        {
          id actionValue=[context componentActionURL];
          [response _appendTagAttribute:@"action"
                    value:actionValue
                    escapingHTMLAttributeValue:NO];
        };
    };
  LOGObjectFnStopC("GSWForm");
};

//--------------------------------------------------------------------
-(void)_appendCGIActionToResponse:(GSWResponse*)response
                        inContext:(GSWContext*)context
{
  NSString* actionString=nil;
  NSString* anUrl=nil;
  LOGObjectFnStartC("GSWForm");

  actionString=[self computeActionStringInContext:context];
  NSDebugMLLog(@"gswdync",@"actionString=%@",actionString);

  anUrl=(NSString*)[context directActionURLForActionNamed:actionString
                            queryDictionary:nil
                            isSecure:NO];
  NSDebugMLLog(@"gswdync",@"anUrl=%@",anUrl);

  [response _appendTagAttribute:@"action"
            value:anUrl
            escapingHTMLAttributeValue:NO];

  LOGObjectFnStopC("GSWForm");
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

