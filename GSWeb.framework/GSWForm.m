/** GSWForm.m - <title>GSWeb: Class GSWForm</title>

   Copyright (C) 1999-2005 Free Software Foundation, Inc.
   
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

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWForm

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWForm class])
    {
      standardClass=[GSWForm class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

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
  [tmpAssociations removeObjectForKey:directActionName__Key];

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

      _fragmentIdentifier = [[associations objectForKey:fragmentIdentifier__Key
                                           withDefaultObject:[_fragmentIdentifier autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"fragmentIdentifier=%@",_fragmentIdentifier);

      [tmpAssociations removeObjectForKey:fragmentIdentifier__Key];

      _displayDisabled = [[associations objectForKey:displayDisabled__Key
                                        withDefaultObject:[_displayDisabled autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"displayDisabled=%@",_displayDisabled);
      [tmpAssociations removeObjectForKey:displayDisabled__Key];
      
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
  DESTROY(_fragmentIdentifier);
  DESTROY(_displayDisabled);
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
  if (_enabled)
    {
      return !GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                       standardEvaluateConditionInContextIMP,
                                                       _enabled,context);
    }
  else
    {
      return GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                      standardEvaluateConditionInContextIMP,
                                                      _disabled,context);
    };
};
// }
//--------------------------------------------------------------------
-(BOOL)compactHTMLTags
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(void)_appendHiddenFieldsToResponse:(GSWResponse*)aResponse
                           inContext:(GSWContext*)aContext
{
  NSDictionary* hiddenFields = nil;
  LOGObjectFnStart();

  hiddenFields = [self computeQueryDictionaryInContext:aContext];
  if([hiddenFields count]>0)
    {
      NSEnumerator* enumerator=[hiddenFields keyEnumerator];
      id key=nil;
      while((key=[enumerator nextObject]))
        {
          id value=[hiddenFields objectForKey:key];
          GSWResponse_appendContentAsciiString(aResponse,@"<input type=hidden");
          GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(aResponse,
                                                                        @"name",
                                                                        key,
                                                                        NO);//Don't escape name
          GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(aResponse,
                                                                        @"value",
                                                                        value,
                                                                        NO);//Don't escape value (should be escaped before !)
          GSWResponse_appendContentCharacter(aResponse,'>');
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
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  //OK
  BOOL disabledInContext=NO;
  BOOL displayDisabledValue=YES;
  GSWDeclareDebugElementIDsCount(aContext);

  LOGObjectFnStartC("GSWForm");

  GSWStartElement(aContext);
  GSWSaveAppendToResponseElementID(aContext);

  GSWResponse_appendDebugCommentContentString(aResponse,
                                              ([NSString stringWithFormat:@"declarationName=%@ ID=%@",
                                                         [self declarationName],
                                                         GSWContext_elementID(aContext)]));

  if (!WOStrictFlag)
    {
      disabledInContext=[self disabledInContext:aContext];
      [aContext setInForm:!disabledInContext];
      if (!disabledInContext)
        {
          if ([aContext isInEnabledForm])
            {
              NSWarnLog(@"Enabled Form %@ ID=%@ in an enbled form. This usually doesn't works well",
                        [self declarationName],
                        GSWContext_elementID(aContext));
              //GSWResponse_appendContentString(aResponse,@"FORM in a FORM"];//TEMP
              [aContext setInEnabledForm:YES];
            };
        };
      if (disabledInContext && _displayDisabled)
        {
          displayDisabledValue=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                                        standardEvaluateConditionInContextIMP,
                                                                        _displayDisabled,aContext);
        };
    }
  else
    [aContext setInForm:YES];

  if (!disabledInContext || displayDisabledValue)
    {
      [self appendToResponse:aResponse
            inContext:aContext
            elementsFromIndex:0
            toIndex:[_elementsMap length]-2];

      [self _appendHiddenFieldsToResponse:aResponse
            inContext:aContext];

      [self appendToResponse:aResponse
            inContext:aContext
            elementsFromIndex:[_elementsMap length]-1
            toIndex:[_elementsMap length]-1];

      [aContext setInForm:NO];
    }
  else
    {
      if ([_elementsMap length]>2)
        {
          [self appendToResponse:aResponse
                inContext:aContext
                elementsFromIndex:1 // omit <form>
                toIndex:[_elementsMap length]-2]; // omit </form>
        };
    };
  if (!disabledInContext)
    {
      [aContext setInForm:NO];
      [aContext setInEnabledForm:NO];
    };

  GSWStopElement(aContext);
  GSWAssertDebugElementIDsCount(aContext);

  LOGObjectFnStopC("GSWForm");
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)aContext
{
  //OK
  GSWElement* element=nil;
  NSString* senderID=nil;
  NSString* elementID=nil;
  BOOL isFormSubmited=NO;
  BOOL multipleSubmitValue=NO;
  GSWDeclareDebugElementIDsCount(aContext);

  LOGObjectFnStartC("GSWForm");

  GSWStartElement(aContext);

  senderID=GSWContext_senderID(aContext);
  elementID=GSWContext_elementID(aContext);
  NSDebugMLLog(@"gswdync",@"senderId=%@",senderID);

  NS_DURING
    {
      GSWAssertCorrectElementID(aContext);// Debug Only
      if ([self prefixMatchSenderIDInContext:aContext]) //Avoid trying to find action if we are not the good component
        {
          isFormSubmited=[elementID isEqualToString:senderID];
          NSDebugMLLog(@"gswdync",@"ET=%@ declarationName=%@ \n      id=%@ \nsenderId=%@ \nisFormSubmited=%s",
                       [self class],
                       [self declarationName],
                       elementID,                           
                       senderID,
                       (isFormSubmited ? "YES" : "NO"));
          if (!WOStrictFlag && isFormSubmited && [self disabledInContext:aContext])
            isFormSubmited=NO;
          
          if (isFormSubmited)
            {
              [aContext setInForm:YES];
              [aContext setInEnabledForm:YES];
              [aContext _setFormSubmitted:YES];
              multipleSubmitValue=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                                           standardEvaluateConditionInContextIMP,
                                                                           _multipleSubmit,aContext);
              NSDebugMLLog(@"gswdync",@"ET=%@ declarationName=%@ \n      id=%@ \nsenderId=%@ \nmultipleSubmit=%s",
                           [self class],
                           [self declarationName],
                           elementID,                           
                           senderID,
                           (multipleSubmitValue ? "YES" : "NO"));
              [aContext _setIsMultipleSubmitForm:multipleSubmitValue];
            };

          NSDebugMLLog(@"gswdync",@"isFormSubmited=%d",isFormSubmited);

          element=[super invokeActionForRequest:request
                         inContext:aContext];
          NSAssert2(!element || [element isKindOfClass:[GSWElement class]],
                    @"Element is a %@ not a GSWElement: %@",
                    [element class],
                    element);

          NSDebugMLLog(@"gswdync",@"isFormSubmited=%d",isFormSubmited);
          NSDebugMLLog(@"gswdync",@"[aContext _wasActionInvoked]=%d",[aContext _wasActionInvoked]);

          if (isFormSubmited)
            {
              NSDebugMLLog(@"gswdync",@"ET=%@ declarationName=%@ \n      id=%@ \nsenderId=%@ \nmultipleSubmit=%s \n[aContext _wasActionInvoked]=%d",
                           [self class],
                           [self declarationName],
                           elementID,                           
                           senderID,
                           (multipleSubmitValue ? "YES" : "NO"),
                           [aContext _wasActionInvoked]);
              if (_action && ![aContext _wasActionInvoked])
                {
                  GSWComponent* component=GSWContext_component(aContext);
                    element = (GSWElement*)[_action valueInComponent:component];
                    [aContext _setActionInvoked:YES];
                };
              [aContext setInForm:NO];
              [aContext setInEnabledForm:NO];
              [aContext _setFormSubmitted:NO];
              [aContext _setIsMultipleSubmitForm:NO];
            };
          elementID=GSWContext_elementID(aContext);
          GSWStopElement(aContext);
        };

      GSWAssertDebugElementIDsCount(aContext);
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

  if (![aContext _wasActionInvoked] && GSWContext_isSenderIDSearchOver(aContext))
    {
      LOGError(@"Action not invoked at the end of %@ (declarationName=%@) (id=%@) senderId=%@",
               [self class],
               [self declarationName],
               GSWContext_elementID(aContext),
               GSWContext_senderID(aContext));
    };

  LOGObjectFnStopC("GSWForm");

  return element; 
};

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)aContext
{
  //OK
  NSString* senderID=nil;
  NSString* elementID=nil;
  BOOL isFormSubmited=NO;
  GSWDeclareDebugElementIDsCount(aContext);

  LOGObjectFnStartC("GSWForm");

  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);

  senderID=GSWContext_senderID(aContext);
  elementID=GSWContext_elementID(aContext);
  NSDebugMLLog(@"gswdync",@"senderID=%@",senderID);
  if ([self prefixMatchSenderIDInContext:aContext]) //Avoid taking values if we are not the good form
    {
      isFormSubmited=[elementID isEqualToString:senderID];
      NSDebugMLLog(@"gswdync",@"isFormSubmited=%d",(int)isFormSubmited);
      if (!WOStrictFlag && isFormSubmited && [self disabledInContext:aContext])
        isFormSubmited=NO;
	  
      NSDebugMLLog(@"gswdync",@"Starting GSWForm TV ET=%@ id=%@",[self class],GSWContext_elementID(aContext));
      if (isFormSubmited)
        {
          [aContext setInForm:YES];
          [aContext setInEnabledForm:YES];
          [aContext _setFormSubmitted:YES];
        };
      NSDebugMLLog(@"gswdync",@"\n\ndynamicChildren=%@",_dynamicChildren);
      NSDebugMLLog(@"gswdync",@"[dynamicChildren count]=%d",[_dynamicChildren count]);

      [super takeValuesFromRequest:request
             inContext:aContext];

      if (isFormSubmited)
        {
          [aContext setInForm:NO];
          [aContext setInEnabledForm:NO];
          [aContext _setFormSubmitted:NO];
        };
    };

  GSWStopElement(aContext);
  GSWAssertDebugElementIDsCount(aContext);

  LOGObjectFnStopC("GSWForm");
};

@end

//====================================================================
@implementation GSWForm (GSWFormB)

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext
{
  BOOL disabledInContext=NO;
  LOGObjectFnStartC("GSWForm");
  if (!WOStrictFlag)
    {
      disabledInContext=[self disabledInContext:aContext];
      NSDebugMLLog(@"gswdync",@"disabledInContext=%s",(disabledInContext ? "YES" : "NO"));
    };
  if (disabledInContext)
    {
      // Mainly for debugginf purpose as it is not 
      // handled by browsers
      GSWResponse_appendContentAsciiString(aResponse,@" disabled");
    }
  else
    {
      GSWComponent* component=GSWContext_component(aContext);
      if (_href)
        {
          id actionValue=[_href valueInComponent:component];
          if (_fragmentIdentifier)
            {
              id fragment=[_fragmentIdentifier valueInComponent:component];
              NSDebugMLLog(@"gswdync",@"fragment=%@",fragment);
              if (fragment)
                {
                  if (actionValue)
                    actionValue=[NSStringWithObject(actionValue) stringByAppendingString:@"#"];
                  else
                    actionValue=@"#";
                  actionValue=[actionValue stringByAppendingString:NSStringWithObject(fragment)];
                };
            };
          NSDebugMLLog(@"gswdync",@"actionValue=%@",actionValue);
          //TODO emit a warning !
          GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(aResponse,
                                                                        @"action",
                                                                        actionValue,
                                                                        NO);
        }
      else if (_directActionName || _actionClass)
        {
          [self _appendCGIActionToResponse:aResponse
                inContext:aContext];
        }
      else
        {
          id actionValue=[aContext componentActionURL];
          if (_fragmentIdentifier)
            {
              id fragment=[_fragmentIdentifier valueInComponent:component];
              NSDebugMLLog(@"gswdync",@"fragment=%@",fragment);
              if (fragment)
                actionValue=[NSString stringWithFormat:@"%@#%@",
                                      actionValue,fragment];
            };
          NSDebugMLLog(@"gswdync",@"actionValue=%@",actionValue);
          GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(aResponse,
                                                                        @"action",
                                                                        actionValue,
                                                                        NO);
        };
    };
  LOGObjectFnStopC("GSWForm");
};

//--------------------------------------------------------------------
-(void)_appendCGIActionToResponse:(GSWResponse*)aResponse
                        inContext:(GSWContext*)aContext
{
  NSString* actionString=nil;
  NSString* anUrl=nil;
  LOGObjectFnStartC("GSWForm");

  actionString=[self computeActionStringInContext:aContext];
  NSDebugMLLog(@"gswdync",@"actionString=%@",actionString);

  anUrl=(NSString*)[aContext directActionURLForActionNamed:actionString
                             queryDictionary:nil];
  NSDebugMLLog(@"gswdync",@"anUrl=%@",anUrl);

  if (_fragmentIdentifier)
    {
      id fragment=[_fragmentIdentifier valueInComponent:GSWContext_component(aContext)];
      NSDebugMLLog(@"gswdync",@"fragment=%@",fragment);
      if (fragment)
        {
          if (anUrl)
            anUrl=[NSStringWithObject(anUrl) stringByAppendingString:@"#"];
          else
            anUrl=@"#";
          anUrl=[anUrl stringByAppendingString:NSStringWithObject(fragment)];
        };
    };
  NSDebugMLLog(@"gswdync",@"anUrl=%@",anUrl);

  GSWResponse_appendTagAttributeValueEscapingHTMLAttributeValue(aResponse,
                                                                @"action",
                                                                anUrl,
                                                                NO);

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

