/** GSWForm.m - <title>GSWeb: Class GSWForm</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

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
  //OK
  NSDictionary* hiddenFields=nil;
  GSWRequest* request=nil;
  NSString* gswsid=nil;

  hiddenFields=[self computeQueryDictionaryInContext:context];
  if (hiddenFields)
    {
      //TODO
    };
  request=[context request];
  gswsid=[request formValueForKey:GSWKey_SessionID[GSWebNamingConv]];
  if (gswsid)
    {
      //TODO
    };
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(NSDictionary*)computeQueryDictionaryInContext:(GSWContext*)context
{
  //OK
  //GSWComponent* component=[context component];
  //GSWSession* session=[context existingSession];
  //NSString* sessionID=[session sessionID];
  LOGObjectFnNotImplemented();	//TODOFN
  return [[NSDictionary new] autorelease];
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
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context elementID]);

  GSWSaveAppendToResponseElementID(context);//Debug Only

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
        toIndex:[elementsMap length]-2];
  [self _appendHiddenFieldsToResponse:response
        inContext:context];
  [self appendToResponse:response
		inContext:context
		elementsFromIndex:[elementsMap length]-1
		toIndex:[elementsMap length]-1];
  [context setInForm:NO];
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context elementID]);
#ifndef NDEBBUG
  NSAssert(elementsNb==[(GSWElementIDString*)[context elementID]elementsNb],
           @"GSWForm appendToResponse: bad elementID");
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
  int i=0;
  LOGObjectFnStartC("GSWForm");
  senderID=[context senderID];
  elementID=[context elementID];
  NSDebugMLLog(@"gswdync",@"ET=%@ definition name=%@ id=%@ senderId=%@",
               [self class],[self definitionName],elementID,senderID);
  NS_DURING
    {
      GSWAssertCorrectElementID(context);// Debug Only
      if ([self prefixMatchSenderIDInContext:context]) //Avoid trying to find action if we are not the good component
        {
          BOOL searchIsOver=NO;
          isFormSubmited=[elementID isEqualToString:senderID];
          NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@ _isFormSubmited=%s",
                       [self class],
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
              NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@ multipleSubmit=%s",
                           [self class],
                           elementID,
                           senderID,
                           (multipleSubmitValue ? "YES" : "NO"));
              [context _setIsMultipleSubmitForm:multipleSubmitValue];
            };
          [context appendZeroElementIDComponent];
          for(i=0;!element && !searchIsOver && i<[dynamicChildren count];i++)
            {
              NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",
                           [[dynamicChildren objectAtIndex:i] class],
                           [context elementID]);
              element=[[dynamicChildren objectAtIndex:i] invokeActionForRequest:request
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
          [context deleteLastElementIDComponent];
          if (isFormSubmited)
            {
              if ([context _wasActionInvoked])
                [context _setIsMultipleSubmitForm:NO];
              else
                {
                  NSDebugMLLog0(@"gswdync",@"formSubmitted but no action was invoked!");
                };
              [context setInForm:NO];
              [context _setFormSubmitted:NO];
            };
          elementID=[context elementID];
          NSDebugMLLog(@"gswdync",@"END ET=%@ def name=%@ id=%@",
                       [self class],
                       [self definitionName],
                       elementID);
#ifndef NDEBBUG
          NSAssert(elementsNb==[(GSWElementIDString*)elementID elementsNb],
                   @"GSWForm invokeActionForRequest: bad elementID");
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
  int i=0;
#ifndef NDEBBUG
  int elementsNb=[(GSWElementIDString*)[context elementID]elementsNb];
#endif
  LOGObjectFnStartC("GSWForm");
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[self class],[context elementID]);
  GSWAssertCorrectElementID(context);// Debug Only
  senderID=[context senderID];
  elementID=[context elementID];
  NSDebugMLLog(@"gswdync",@"senderID=%@",senderID);
  NSDebugMLLog(@"gswdync",@"elementID=%@",elementID);
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
      [context appendZeroElementIDComponent];
      NSDebugMLLog(@"gswdync",@"\n\ndynamicChildren=%@",dynamicChildren);
      NSDebugMLLog(@"gswdync",@"[dynamicChildren count]=%d",[dynamicChildren count]);
      for(i=0;i<[dynamicChildren count];i++)
        {
          NSDebugMLLog(@"gswdync",@"ET=%@ id=%@",[[dynamicChildren objectAtIndex:i] class],[context elementID]);
          NSDebugMLLog(@"gswdync",@"\n[dynamicChildren objectAtIndex:i]=%@",[dynamicChildren objectAtIndex:i]);
          [[dynamicChildren objectAtIndex:i] takeValuesFromRequest:request
                                             inContext:context];
          [context incrementLastElementIDComponent];
        };
      [context deleteLastElementIDComponent];
      if (isFormSubmited)
        {
          [context setInForm:NO];
          [context _setFormSubmitted:NO];
        };
    };
  NSDebugMLLog(@"gswdync",@"END ET=%@ id=%@",[self class],[context elementID]);
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
  //OK//TODOV
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
      id actionValue=nil;
      if (_href)
        actionValue=[_href valueInComponent:component];
      else
        actionValue=[context componentActionURL];
      [response appendContentCharacter:' '];
      [response _appendContentAsciiString:@"action"];
      [response appendContentCharacter:'='];
      [response appendContentCharacter:'"'];
      [response appendContentString:actionValue];
      [response appendContentCharacter:'"'];
    };
  LOGObjectFnStopC("GSWForm");
};

//--------------------------------------------------------------------
-(void)_appendCGIActionToResponse:(GSWResponse*)response
                        inContext:(GSWContext*)context
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

