/** GSWInput.m - <title>GSWeb: Class GSWInput</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
   
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
@implementation GSWInput

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  NSMutableDictionary* attributedAssociations=[[associations mutableCopy] autorelease];
  LOGObjectFnStartC("GSWInput");
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ elements=%@",aName,associations,elements);
  [attributedAssociations removeObjectForKey:disabled__Key];
  [attributedAssociations removeObjectForKey:enabled__Key];//??
  [attributedAssociations removeObjectForKey:value__Key];//??
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
  //OK
  GSWComponent* component=nil;
  NSString* nameValue=nil;
  LOGObjectFnStartC("GSWInput");
  if (_name)
    {
      component=[context component];
      nameValue=[_name valueInComponent:component];
    }
  else
    {
      nameValue=[context elementID];
      NSDebugMLLog(@"gswdync",@"elementID=%@",[context elementID]);
    };
  LOGObjectFnStopC("GSWInput");
  return nameValue;
};

static int countAutoValue = 0;

//--------------------------------------------------------------------
-(NSString*)valueInContext:(GSWContext*)context
{
  //OK
  GSWComponent *component=nil;
  NSString *valueValue=nil;

  LOGObjectFnStartC("GSWInput");
  countAutoValue++;
  if(_value)
    {
      component=[context component];
      valueValue=[_value valueInComponent:component];
    }
  else
    {
      valueValue=[NSString stringWithFormat:@"%@.%d", [context elementID], countAutoValue];
      NSDebugMLLog(@"gswdync",@"elementID=%@ _countAutoValue",[context elementID], countAutoValue);
    }
  LOGObjectFnStopC("GSWInput");
  return valueValue;
}

//--------------------------------------------------------------------
- (void)resetAutoValue
{
  LOGObjectFnStartC("GSWInput");

  countAutoValue = 0;

  LOGObjectFnStopC("GSWInput");
}

//--------------------------------------------------------------------
-(BOOL)disabledInContext:(GSWContext*)context
{
  //OK
  if (!WOStrictFlag && _enabled)
    return ![self evaluateCondition:_enabled
                  inContext:context];
  else
    return [self evaluateCondition:_disabled
                 inContext:context];
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
  GSWAssertCorrectElementID(context);// Debug Only
  disabledInContext=[self disabledInContext:context]; //return 0
  if (!disabledInContext)
    {
      BOOL wasFormSubmitted=[context _wasFormSubmitted];
      if (wasFormSubmitted)
        {
          GSWComponent* component=[context component];
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
  LOGObjectFnStopC("GSWInput");
};

@end

//====================================================================
@implementation GSWInput (GSWInputC)

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response
                                      inContext:(GSWContext*)context
{
  //OK
  BOOL disabledInContext=NO;
  LOGObjectFnStartC("GSWInput");
  disabledInContext=[self disabledInContext:context]; //return 0
  if (disabledInContext)
    [response _appendContentAsciiString:@" disabled"];
  [self appendValueToResponse:response
        inContext:context];
  [self appendNameToResponse:response
        inContext:context];
  LOGObjectFnStopC("GSWInput");
};

//--------------------------------------------------------------------
-(void)appendValueToResponse:(GSWResponse*)response
                   inContext:(GSWContext*)context
{
  //OK
  GSWComponent* component=nil;
  LOGObjectFnStartC("GSWInput");
  GSWSaveAppendToResponseElementID(context);//Debug Only
  component=[context component];
  if (_value)
    {
      id valueValue=[_value valueInComponent:component];
      NSDebugMLLog(@"gswdync",@"valueValue=%@",valueValue);
      if (valueValue)
        {
          [response appendContentCharacter:' '];
          [response _appendContentAsciiString:@"value"];
          [response appendContentCharacter:'='];
          [response appendContentCharacter:'"'];
          if (_tcEscapeHTML && [self evaluateCondition:_tcEscapeHTML 
                                     inContext:context] == NO)
            {
              [response appendContentString:valueValue];
            }
          else
            {
              [response appendContentHTMLAttributeValue:valueValue];
            };
          [response appendContentCharacter:'"'];
        };
    };
  LOGObjectFnStopC("GSWInput");
};

//--------------------------------------------------------------------
-(void)appendNameToResponse:(GSWResponse*)response
                  inContext:(GSWContext*)context
{
  //OK
  NSString* name=nil;
  LOGObjectFnStartC("GSWInput");
  name=[self nameInContext:context];
  NSDebugMLLog(@"gswdync",@"name=%@",name);
  if (name)
    {
      [response appendContentCharacter:' '];
      [response _appendContentAsciiString:@"name"];
      [response appendContentCharacter:'='];
      [response appendContentCharacter:'"'];
      [response appendContentHTMLAttributeValue:name];
      [response appendContentCharacter:'"'];
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
                       inContext:(GSWContext*)context
{
  BOOL isValidationException=[exception isValidationException];
  BOOL raise=YES;
  LOGObjectFnStartC("GSWInput");
  if (isValidationException)
    {				  
      GSWComponent* component=[context component];
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
