/** GSWInput.m - <title>GSWeb: Class GSWInput</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
   
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

#include "GSWeb.h"

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWInput

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWInput class])
    {
      standardClass=[GSWInput class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  NSMutableDictionary* attributedAssociations=[[associations mutableCopy] autorelease];
  LOGObjectFnStartC("GSWInput");
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ elements=%@",aName,associations,elements);
  [attributedAssociations removeObjectForKey:disabled__Key];
  [attributedAssociations removeObjectForKey:enabled__Key];
  [attributedAssociations removeObjectForKey:value__Key];
  [attributedAssociations removeObjectForKey:name__Key];
  if (!WOStrictFlag)    
    [attributedAssociations removeObjectForKey:handleValidationException__Key];
  _value = [[associations objectForKey:value__Key
                          withDefaultObject:[_value autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWInput: value=%@",_value);
  if ((self=[super initWithName:aName
                   attributeAssociations:attributedAssociations
                   contentElements:elements]))
    {
      _disabled = [[associations objectForKey:disabled__Key
                                 withDefaultObject:[_disabled autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWInput: disabled=%@",_disabled);
      if (!WOStrictFlag)
        {
          _enabled = [[associations objectForKey:enabled__Key
                                    withDefaultObject:[_enabled autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"GSWInput: enabled=%@",_enabled);
          if (_disabled && _enabled)
            {
              ExceptionRaise0(@"GSWInput",@"You can't use 'diabled' and 'enabled' parameters at the same time.");
            };
        };
      _name = [[associations objectForKey:name__Key
                             withDefaultObject:[_name autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWInput: name=%@",_name);
      
      if (!WOStrictFlag)
        {
          _handleValidationException = [[associations objectForKey:handleValidationException__Key
                                                      withDefaultObject:[_handleValidationException autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"GSWInput: handleValidationException=%@",_handleValidationException);
          
          // Turbocat Additions
 	    //  [attributedAssociations removeObjectForKey: escapeHTML__Key];
          if ([associations objectForKey: escapeHTML__Key])
            {
              _tcEscapeHTML = [[associations objectForKey:escapeHTML__Key
                                             withDefaultObject:nil] retain];
            };
        };
    };
  LOGObjectFnStopC("GSWInput");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_disabled);
  DESTROY(_enabled);//GSWeb Only
  DESTROY(_name);
  DESTROY(_value);
  DESTROY(_handleValidationException);//GSWeb Only
  DESTROY(_tcEscapeHTML);//GSWeb Only
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return @"INPUT";
};

@end

//==============================================================================
@implementation GSWInput (GSWInputA)

//--------------------------------------------------------------------
-(NSString*)nameInContext:(GSWContext*)context
{
  GSWComponent* component=nil;
  NSString* nameValue=nil;
  LOGObjectFnStartC("GSWInput");
  GSWAssertIsElementID(context);
  if (_name)
    {
      component=GSWContext_component(context);
      nameValue=NSStringWithObject([_name valueInComponent:component]);
    }
  else
    {
      nameValue=GSWContext_elementID(context);
    };
  NSDebugMLLog(@"gswdync",@"nameValue=%@",nameValue);
  GSWAssertIsElementID(context);
  LOGObjectFnStopC("GSWInput");
  return nameValue;
};

//--------------------------------------------------------------------
/** return the value used in appendValueToResponse:inContext: **/
-(id)valueInContext:(GSWContext*)context
{
  id value=nil;
  LOGObjectFnStartC("GSWInput");
  if (_value)
    {
      GSWComponent* component=nil;
      component=GSWContext_component(context);
      value=[_value valueInComponent:component];
      NSDebugMLLog(@"gswdync",@"value=%@",value);
    };
  LOGObjectFnStopC("GSWInput");
  return value;
};

//--------------------------------------------------------------------
-(BOOL)disabledInContext:(GSWContext*)context
{
  BOOL isDisabled=NO;

  LOGObjectFnStartC("GSWInput");

  NSDebugMLLog(@"gswdync",@"_enabled=%@ _disabled=%@",_enabled,_disabled);

  if (!WOStrictFlag && _enabled)
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

  NSDebugMLLog(@"gswdync",@"isDisabled=%d",isDisabled);

  LOGObjectFnStopC("GSWInput");

  return isDisabled;
};

@end

//==============================================================================
@implementation GSWInput (GSWInputB)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  //OK
  BOOL disabledInContext=NO;
  LOGObjectFnStartC("GSWInput");
  GSWStartElement(context);
  GSWAssertCorrectElementID(context);
  disabledInContext=[self disabledInContext:context]; //return 0
  if (!disabledInContext)
    {
      BOOL wasFormSubmitted=[context _wasFormSubmitted];
      if (wasFormSubmitted)
        {
          GSWComponent* component=GSWContext_component(context);
          NSString* nameInContext=[self nameInContext:context];
          NSString* valueValue=[request formValueForKey:nameInContext];
          NSDebugMLLog(@"gswdync",@"nameInContext=%@",nameInContext);
          NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
          NS_DURING
            {
              [_value setValue:valueValue
                      inComponent:component];
            };
          NS_HANDLER
            {
              LOGException(@"GSWInput _value=%@ valueValue=%@ exception=%@",
                           _value,valueValue,localException);
              if (!WOStrictFlag)
                {
                  [self handleValidationException:localException
                        inContext:context];
                }
              else
                {
                  [localException raise];
                };
            }
          NS_ENDHANDLER;
        };	  
    };
  GSWAssertIsElementID(context);
  LOGObjectFnStopC("GSWInput");
};

@end

//====================================================================
@implementation GSWInput (GSWInputC)

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext
{
  BOOL disabledInContext=NO;
  LOGObjectFnStartC("GSWInput");
  disabledInContext=[self disabledInContext:aContext]; //return 0
  if (disabledInContext)
    GSWResponse_appendContentAsciiString(aResponse,@" disabled");
  [self appendNameToResponse:aResponse
        inContext:aContext];
  [self appendValueToResponse:aResponse
        inContext:aContext];
  LOGObjectFnStopC("GSWInput");
};

//--------------------------------------------------------------------
-(void)appendValueToResponse:(GSWResponse*)aResponse
                   inContext:(GSWContext*)aContext
{
  //OK
  id valueValue=nil;
  LOGObjectFnStartC("GSWInput");
  valueValue=[self valueInContext:aContext];
  NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
  if (valueValue)
    {
      GSWResponse_appendContentCharacter(aResponse,' ');
      GSWResponse_appendContentAsciiString(aResponse,@"value");
      GSWResponse_appendContentCharacter(aResponse,'=');
      GSWResponse_appendContentCharacter(aResponse,'"');
      if (_tcEscapeHTML
          && GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                      standardEvaluateConditionInContextIMP,
                                                      _tcEscapeHTML,aContext) == NO)
        {
          GSWResponse_appendContentString(aResponse,valueValue);
        }
      else
        {
          GSWResponse_appendContentHTMLAttributeValue(aResponse,valueValue);
        };
      GSWResponse_appendContentCharacter(aResponse,'"');
    };
  LOGObjectFnStopC("GSWInput");
};

//--------------------------------------------------------------------
-(void)appendNameToResponse:(GSWResponse*)aResponse
                  inContext:(GSWContext*)aContext
{
  //OK
  NSString* name=nil;
  LOGObjectFnStartC("GSWInput");
  name=[self nameInContext:aContext];
  NSDebugMLLog(@"gswdync",@"name=%@",name);
  if (name)
    {
      GSWResponse_appendContentCharacter(aResponse,' ');
      GSWResponse_appendContentAsciiString(aResponse,@"name");
      GSWResponse_appendContentCharacter(aResponse,'=');
      GSWResponse_appendContentCharacter(aResponse,'"');
      GSWResponse_appendContentHTMLAttributeValue(aResponse,name);
      GSWResponse_appendContentCharacter(aResponse,'"');
    };
  LOGObjectFnStopC("GSWInput");
};

@end

//====================================================================
@implementation GSWInput (GSWInputD)

//--------------------------------------------------------------------
+(BOOL)hasGSWebObjectsAssociations
{
  return YES;
};

@end

//====================================================================
@implementation GSWInput (GSWInputE)

//GSWeb additions {
-(void)handleValidationException:(NSException*)exception
                       inContext:(GSWContext*)aContext
{
  BOOL isValidationException=[exception isValidationException];
  BOOL raise=YES;
  LOGObjectFnStartC("GSWInput");
  if (isValidationException)
    {				  
      GSWComponent* component=GSWContext_component(aContext);
      id handleValidationException=[handleValidationException valueInComponent:component];
      BOOL handle=NO;
      if (!handleValidationException)
        {
          handleValidationException = [component handleValidationExceptionDefault];
        };
      if (handleValidationException)
        {
          if ([handleValidationException isEqualToString:@"handleAndRaise"])
            {
              handle=YES;
              raise=YES;
            }
          else if ([handleValidationException isEqualToString:@"handle"])
            {
              handle=YES;
              raise=NO;
            }
          else if ([handleValidationException isEqualToString:@"raise"])
            {
              handle=NO;
              raise=YES;
            }
          else
            {
              NSDebugMLog(@"Unknown case for handleValidationException  %@",handleValidationException);
            };
        };
      if (handle)
        {
          NSDebugMLog(@"Handled validation exception %@",exception);
          [component setValidationFailureMessage:[[exception userInfo]objectForKey:@"message"]
                     forElement:self];
        }
      else
        {
          NSDebugMLog(@"Unhandled validation exception %@",exception);
        };
    };
  if (raise)
    {
      NSDebugMLog(@"Raise exception %@",exception);
      exception=ExceptionByAddingUserInfoObjectFrameInfo0(exception,@"handleValidationException:inContext");
      [exception raise];
    };
  LOGObjectFnStopC("GSWInput");
};
// }
@end
