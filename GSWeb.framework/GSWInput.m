/* GSWInput.m - GSWeb: Class GSWInput
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Feb 1999
   
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
@implementation GSWInput

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_
{
  NSMutableDictionary* _attributedAssociations=[[associations_ mutableCopy] autorelease];
  LOGObjectFnStartC("GSWInput");
  NSDebugMLLog(@"gswdync",@"name_=%@ associations_:%@ elements_=%@",name_,associations_,elements_);
  [_attributedAssociations removeObjectForKey:disabled__Key];
  [_attributedAssociations removeObjectForKey:enabled__Key];//??
  [_attributedAssociations removeObjectForKey:value__Key];//??
  if (!WOStrictFlag)    
  [_attributedAssociations removeObjectForKey:handleValidationException__Key];
  value = [[associations_ objectForKey:value__Key
							 withDefaultObject:[value autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWInput: value=%@",value);
  if ((self=[super initWithName:name_
				   attributeAssociations:_attributedAssociations
				   contentElements:elements_]))
	{
	  disabled = [[associations_ objectForKey:disabled__Key
								 withDefaultObject:[disabled autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWInput: disabled=%@",disabled);
          if (!WOStrictFlag)
            {
              enabled = [[associations_ objectForKey:enabled__Key
                                        withDefaultObject:[enabled autorelease]] retain];
              NSDebugMLLog(@"gswdync",@"GSWInput: enabled=%@",enabled);
              if (disabled && enabled)
		{
		  ExceptionRaise0(@"GSWInput",@"You can't use 'diabled' and 'enabled' parameters at the same time.");
		};
            };
	  name = [[associations_ objectForKey:name__Key
									  withDefaultObject:[name autorelease]] retain];
	  NSDebugMLLog(@"gswdync",@"GSWInput: name=%@",name);

          if (!WOStrictFlag)
            {
              handleValidationException = [[associations_ objectForKey:handleValidationException__Key
                                                          withDefaultObject:[handleValidationException autorelease]] retain];
              NSDebugMLLog(@"gswdync",@"GSWInput: handleValidationException=%@",handleValidationException);

 	    // Turbocat Additions
 	    //  [_attributedAssociations removeObjectForKey: escapeHTML__Key];
 	    if ([associations_ objectForKey: escapeHTML__Key])
              {
                tcEscapeHTML = [[associations_ objectForKey:escapeHTML__Key withDefaultObject:nil] retain];
              };
            };
	};
  LOGObjectFnStopC("GSWInput");
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(disabled);
  DESTROY(enabled);//GSWeb Only
  DESTROY(name);
  DESTROY(value);
  DESTROY(handleValidationException);//GSWeb Only
  DESTROY(tcEscapeHTML);//GSWeb Only
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
-(NSString*)nameInContext:(GSWContext*)_context
{
  //OK
  GSWComponent* _component=nil;
  NSString* _name=nil;
  LOGObjectFnStartC("GSWInput");
  if (name)
	{
	  _component=[_context component];
	  _name=[name valueInComponent:_component];
	}
  else
	{
	  _name=[_context elementID];
	  NSDebugMLLog(@"gswdync",@"_elementID=%@",[_context elementID]);
	};
  LOGObjectFnStopC("GSWInput");
  return _name;
};

static int countAutoValue = 0;

//--------------------------------------------------------------------
- (NSString *)valueInContext:(GSWContext *)_context
{
  //OK
  GSWComponent *_component=nil;
  NSString *_value=nil;

  LOGObjectFnStartC("GSWInput");
  countAutoValue++;
  if(value)
    {
      _component=[_context component];
      _value=[value valueInComponent:_component];
    }
  else
    {
      _value=[NSString stringWithFormat:@"%@.%d", [_context elementID], countAutoValue];
      NSDebugMLLog(@"gswdync",@"_elementID=%@ _countAutoValue",[_context elementID], countAutoValue);
    }
  LOGObjectFnStopC("GSWInput");
  return _value;
}

//--------------------------------------------------------------------
- (void)resetAutoValue
{
  LOGObjectFnStartC("GSWInput");

  countAutoValue = 0;

  LOGObjectFnStopC("GSWInput");
}

//--------------------------------------------------------------------
-(BOOL)disabledInContext:(GSWContext*)_context
{
  //OK
  if (!WOStrictFlag && enabled)
    return ![self evaluateCondition:enabled
                  inContext:_context];
  else
    return [self evaluateCondition:disabled
                 inContext:_context];
};

@end

//==============================================================================
@implementation GSWInput (GSWInputB)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  //OK
  BOOL _disabledInContext=NO;
  LOGObjectFnStartC("GSWInput");
  GSWAssertCorrectElementID(context_);// Debug Only
  _disabledInContext=[self disabledInContext:context_]; //return 0
  if (!_disabledInContext)
	{
	  BOOL _wasFormSubmitted=[context_ _wasFormSubmitted];
	  if (_wasFormSubmitted)
		{
		  GSWComponent* _component=[context_ component];
		  NSString* _nameInContext=[self nameInContext:context_];
		  NSString* _value=[request_ formValueForKey:_nameInContext];
		  NSDebugMLLog(@"gswdync",@"_nameInContext=%@",_nameInContext);
		  NSDebugMLLog(@"gswdync",@"_value=%@",_value);
                  if (!WOStrictFlag)
                    {
                      NS_DURING
			{
			  [value setValue:_value
                                 inComponent:_component];
			};
                      NS_HANDLER
			{
			  [self handleValidationException:localException
                                inContext:context_];
			}
                      NS_ENDHANDLER;
                    }
                  else
                    [value setValue:_value
                           inComponent:_component];
		};
	  
	};
  LOGObjectFnStopC("GSWInput");
};

@end

//====================================================================
@implementation GSWInput (GSWInputC)

//--------------------------------------------------------------------
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response_
									inContext:(GSWContext*)context_
{
  //OK
  BOOL _disabledInContext=NO;
  LOGObjectFnStartC("GSWInput");
  _disabledInContext=[self disabledInContext:context_]; //return 0
  if (_disabledInContext)
	[response_ _appendContentAsciiString:@" disabled"];
  [self appendValueToResponse:response_
		inContext:context_];
  [self appendNameToResponse:response_
		inContext:context_];
  LOGObjectFnStopC("GSWInput");
};

//--------------------------------------------------------------------
-(void)appendValueToResponse:(GSWResponse*)response_
				   inContext:(GSWContext*)context_
{
  //OK
  GSWComponent* _component=nil;
  LOGObjectFnStartC("GSWInput");
  GSWSaveAppendToResponseElementID(context_);//Debug Only
  _component=[context_ component];
  if (value)
	{
	  id _value=[value valueInComponent:_component];
	  NSDebugMLLog(@"gswdync",@"_value=%@",_value);
	  if (_value)
		{
		  [response_ appendContentCharacter:' '];
		  [response_ _appendContentAsciiString:@"value"];
		  [response_ appendContentCharacter:'='];
		  [response_ appendContentCharacter:'"'];
 	  	  if (tcEscapeHTML && [self evaluateCondition:tcEscapeHTML inContext:context_] == NO)
                    {
                      [response_ appendContentString:_value];
                    }
                  else
                    {
                      [response_ appendContentHTMLAttributeValue:_value];
                    };
		  [response_ appendContentCharacter:'"'];
		};
	};
  LOGObjectFnStopC("GSWInput");
};

//--------------------------------------------------------------------
-(void)appendNameToResponse:(GSWResponse*)response_
				  inContext:(GSWContext*)context_
{
  //OK
  NSString* _name=nil;
  LOGObjectFnStartC("GSWInput");
  _name=[self nameInContext:context_];
  NSDebugMLLog(@"gswdync",@"_name=%@",_name);
  if (_name)
	{
	  [response_ appendContentCharacter:' '];
	  [response_ _appendContentAsciiString:@"name"];
	  [response_ appendContentCharacter:'='];
	  [response_ appendContentCharacter:'"'];
	  [response_ appendContentHTMLAttributeValue:_name];
	  [response_ appendContentCharacter:'"'];
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
-(void)handleValidationException:(NSException*)exception_
					   inContext:(GSWContext*)context_
{
  BOOL _isValidationException=[exception_ isValidationException];
  BOOL _raise=YES;
  LOGObjectFnStartC("GSWInput");
  if (_isValidationException)
	{				  
	  GSWComponent* _component=[context_ component];
	  id _handleValidationException=[handleValidationException valueInComponent:_component];
	  BOOL _handle=NO;
	  if (!_handleValidationException)
		{
		  _handleValidationException = [_component handleValidationExceptionDefault];
		};
	  if (_handleValidationException)
		{
		  if ([_handleValidationException isEqualToString:@"handleAndRaise"])
			{
			  _handle=YES;
			  _raise=YES;
			}
		  else if ([_handleValidationException isEqualToString:@"handle"])
			{
			  _handle=YES;
			  _raise=NO;
			}
		  else if ([_handleValidationException isEqualToString:@"raise"])
			{
			  _handle=NO;
			  _raise=YES;
			}
		  else
			{
			  NSDebugMLog(@"Unknown case for handleValidationException  %@",_handleValidationException);
			};
		};
	  if (_handle)
		{
		  NSDebugMLog(@"Handled validation exception %@",exception_);
		  [_component setValidationFailureMessage:[[exception_ userInfo]objectForKey:@"message"]
					  forElement:self];
		}
	  else
		{
		  NSDebugMLog(@"Unhandled validation exception %@",exception_);
		};
	};
  if (_raise)
	{
	  NSDebugMLog(@"Raise exception %@",exception_);
	  exception_=ExceptionByAddingUserInfoObjectFrameInfo0(exception_,@"handleValidationException:inContext");
	  [exception_ raise];
	};
  LOGObjectFnStopC("GSWInput");
};
// }
@end
