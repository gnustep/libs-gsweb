/** GSWConditional.m - <title>GSWeb: Class GSWConditional</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        Jan 1999
   
   $Revision$
   $Date$
   $Id$
   
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

/**
Bindings

	condition	if evaluated to YES (or NO if negate evaluted to YES), the enclosed code is emitted/used

        value		if evaluated value is equal to conditionValue evaluated value, the enclosed code is 
        			emitted/used (or not equal if negate evaluated to YES);

        conditionValue	if evaluated value is equal to conditionValue evaluated value, the enclosed code is 
        			emitted/used (or not equal if negate evaluated to YES);

        negate		If evaluated to yes, negate the condition (defaut=NO)
**/

static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWConditional

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWConditional class])
    {
      standardClass=[GSWConditional class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)someAssociations
         template:(GSWElement*)templateElement
{
  //OK
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

      _condition = [[associations objectForKey:condition__Key
                                  withDefaultObject:[_condition autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWConditional condition=%@",_condition);

      if (!WOStrictFlag)
        {
          _value = [[associations objectForKey:value__Key
                                  withDefaultObject:[_value autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"GSWConditional value=%@",_value);
          
          _conditionValue  = [[associations objectForKey:conditionValue__Key
                                            withDefaultObject:[_conditionValue autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"GSWConditional conditionValue=%@",_conditionValue);
          
          if (_conditionValue && !_value)
            ExceptionRaise0(@"GSWConditional",
                            @"'conditionValue' parameter need 'value' parameter");
          
          if (_value && !_conditionValue)
            ExceptionRaise0(@"GSWConditional",
                            @"'value' parameter need 'conditionValue' parameter");
          
          if (_conditionValue && _condition)
            ExceptionRaise0(@"GSWConditional",
                            @"You can't have 'condition' parameter with 'value' and 'conditionValue' parameters");
        };
      _negate = [[associations objectForKey:negate__Key
                               withDefaultObject:[_negate autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWConditional negate=%@",_negate);
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_condition);
  DESTROY(_value);
//GSWeb Additions {
  DESTROY(_conditionValue);
  DESTROY(_negate);
// }
  DESTROY(_childrenGroup);
  [super dealloc];
}

//--------------------------------------------------------------------
-(void)setDeclarationName:(NSString*)declarationName
{
  [super setDeclarationName:declarationName];
  if (declarationName && _childrenGroup)
    [_childrenGroup setDeclarationName:[NSString stringWithFormat:@"%@-StaticGroup",declarationName]];
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
@implementation GSWConditional (GSWConditionalA)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext
{
  //OK
  BOOL condition=NO;
  BOOL negate=NO;
  BOOL doIt=NO;
  LOGObjectFnStart();
  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);
  if (!WOStrictFlag && _conditionValue)
    {
      GSWComponent* component=GSWContext_component(aContext);
      id conditionValueValue=[_conditionValue valueInComponent:component];
      id valueValue=[_value valueInComponent:component];
      NSDebugMLog(@"_conditionValue=%@ conditionValueValue=%@",
                  _conditionValue,conditionValueValue);
      NSDebugMLog(@"_value=%@ valueValue=%@",
                  _value,valueValue);
      condition=SBIsValueEqual(conditionValueValue,valueValue);
    }
  else    
    {
      condition=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                         standardEvaluateConditionInContextIMP,
                                                         _condition,aContext);
    };

  if (_negate)
    {
      negate=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                      standardEvaluateConditionInContextIMP,
                                                      _negate,aContext);
    };

  doIt=condition;
  NSDebugMLLog(@"gswdync",@"elementID=%@",GSWContext_elementID(aContext));
  if (negate)
    doIt=!doIt;
  NSDebugMLLog(@"gswdync",@"declarationName=%@ condition=%@ negate=%@ evaluatedCondition=%s evaluatedNegate=%s doIt=%s",
               [self declarationName],
               _condition,
               _negate,
               (condition ? "YES" : "NO"),
               (negate ? "YES" : "NO"),
               (doIt ? "YES" : "NO"));
  if (doIt)
    {
      //GSWRequest* _request=[aContext request];
      //Deprecated  BOOL isFromClientComponent=[_request isFromClientComponent];
      GSWContext_appendZeroElementIDComponent(aContext);
      [_childrenGroup takeValuesFromRequest:aRequest
                     inContext:aContext];
      GSWContext_deleteLastElementIDComponent(aContext);
    };
  GSWStopElement(aContext);
  GSWAssertIsElementID(aContext);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext
{
  //OK
  GSWElement* element=nil;
  BOOL condition=NO;
  BOOL negate=NO;
  BOOL doIt=NO;
  LOGObjectFnStart();
  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);
  if (!WOStrictFlag && _conditionValue)
    {
      GSWComponent* component=GSWContext_component(aContext);
      id conditionValueValue=[_conditionValue valueInComponent:component];
      id valueValue=[_value valueInComponent:component];
      NSDebugMLog(@"_conditionValue=%@ conditionValueValue=%@",
                  _conditionValue,conditionValueValue);
      NSDebugMLog(@"_value=%@ valueValue=%@",
                  _value,valueValue);
      condition=SBIsValueEqual(conditionValueValue,valueValue);
    }
  else    
    {
      condition=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                         standardEvaluateConditionInContextIMP,
                                                         _condition,aContext);
    };

  if (_negate)
    {
      negate=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                      standardEvaluateConditionInContextIMP,
                                                      _negate,aContext);
    };

  doIt=condition;
  if (negate)
    doIt=!doIt;
  NSDebugMLLog(@"gswdync",@"declarationName=%@ condition=%@ negate=%@ evaluatedCondition=%s evaluatedNegate=%s doIt=%s",
               [self declarationName],
               _condition,
               _negate,
               (condition ? "YES" : "NO"),
               (negate ? "YES" : "NO"),
               (doIt ? "YES" : "NO"));
  if (doIt)
    {
      //GSWRequest* request=[aContext request];
      //Deprecated  BOOL isFromClientComponent=[request isFromClientComponent];
      GSWContext_appendZeroElementIDComponent(aContext);
      NSDebugMLLog(@"gswdync",@"childrenGroup=%@",_childrenGroup);
      element=[_childrenGroup invokeActionForRequest:aRequest
                             inContext:aContext];
      NSDebugMLLog(@"gswdync",@"element=%@",element);
      NSAssert2(!element || [element isKindOfClass:[GSWElement class]],
                @"Element is a %@ not a GSWElement: %@",
                [element class],
                element);
      GSWContext_deleteLastElementIDComponent(aContext);
    };
  GSWStopElement(aContext);
  GSWAssertIsElementID(aContext);
  LOGObjectFnStop();
  return element;
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  //OK
  BOOL condition=NO;
  BOOL negate=NO;
  BOOL doIt=NO;
  LOGObjectFnStart();
  GSWStartElement(aContext);
  GSWSaveAppendToResponseElementID(aContext);

  if (!WOStrictFlag && _conditionValue)
    {
      GSWComponent* component=GSWContext_component(aContext);
      id conditionValueValue=[_conditionValue valueInComponent:component];
      id valueValue=[_value valueInComponent:component];
      NSDebugMLog(@"_conditionValue=%@ conditionValueValue=%@",
                  _conditionValue,conditionValueValue);
      NSDebugMLog(@"_value=%@ valueValue=%@",
                  _value,valueValue);
      condition=SBIsValueEqual(conditionValueValue,valueValue);
    }
  else    
    {
      condition=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                         standardEvaluateConditionInContextIMP,
                                                         _condition,aContext);
    };

  NSDebugMLLog(@"gswdync",@"condition=%s",condition ? "YES" : "NO");

  if (_negate)
    {
      negate=GSWDynamicElement_evaluateValueInContext(self,standardClass,
                                                      standardEvaluateConditionInContextIMP,
                                                      _negate,aContext);
    };

  NSDebugMLLog(@"gswdync",@"negate=%s",negate ? "YES" : "NO");
  doIt=condition;
  if (negate)
    doIt=!doIt;
  NSDebugMLLog(@"gswdync",@"declarationName=%@ condition=%@ negate=%@ evaluatedCondition=%s evaluatedNegate=%s doIt=%s",
               [self declarationName],
               _condition,
               _negate,
               (condition ? "YES" : "NO"),
               (negate ? "YES" : "NO"),
               (doIt ? "YES" : "NO"));
  if (doIt)
    {
      //GSWRequest* request=[aContext request];
      //Deprecated  BOOL isFromClientComponent=[request isFromClientComponent];
      GSWContext_appendZeroElementIDComponent(aContext);
      [_childrenGroup appendToResponse:aResponse
                      inContext:aContext];
      GSWContext_deleteLastElementIDComponent(aContext);
    };
  GSWStopElement(aContext);
  GSWAssertIsElementID(aContext);
  LOGObjectFnStop();
};

@end
