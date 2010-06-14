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
  self = [super initWithName:nil associations:nil template: templateElement];
  if (!self) {
    return nil;
  }  

  // here, we do not need to remove associations
  ASSIGN(_condition, [someAssociations objectForKey: condition__Key]);
  ASSIGN(_negate, [someAssociations objectForKey: negate__Key]);

  if (_condition == nil) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: Missing 'condition' attribute.",
                            __PRETTY_FUNCTION__];      
  }
  return self;
};


//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_condition);
  DESTROY(_negate);

  [super dealloc];
}

-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p condition: %@ negate: %@>",
				   object_getClassName(self),
				   (void*)self, _condition, _negate];
};


-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  GSWComponent * component = GSWContext_component(context);
  BOOL conVal = [_condition boolValueInComponent:component];
  BOOL doNegate = NO;
  if (_negate != nil) {
    doNegate = [_negate boolValueInComponent:component];
  }
  if ((conVal && !doNegate) || (!conVal && doNegate)) {
    [super takeValuesFromRequest:request inContext:context];
  }
}

-(GSWElement*)invokeActionForRequest:(GSWRequest*) request
                           inContext:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);
  BOOL conVal = [_condition boolValueInComponent:component];
  BOOL doNegate = NO;
  if (_negate != nil) {
    doNegate = [_negate boolValueInComponent:component];
  }
  if ((conVal && !doNegate) || (!conVal && doNegate)) {
    return [super invokeActionForRequest:request inContext:context];
  } else {
    return nil;
  }
}

-(void)appendToResponse:(GSWResponse*) response
              inContext:(GSWContext*) context
{
  GSWComponent * component = GSWContext_component(context);
  BOOL conVal = [_condition boolValueInComponent:component];
  BOOL doNegate = NO;
  if (_negate != nil) {
    doNegate = [_negate boolValueInComponent:component];
  }
//  GSWResponse_appendContentAsciiString(response,@"<!-- CON ( -->");
//  NSLog(@"%@ doNegate:%d conVal:%d", self, doNegate, conVal);
  if ((conVal && (!doNegate)) || ((!conVal) && doNegate)) {
//  NSLog(@"append!");
  
    [super appendChildrenToResponse:response inContext:context];
  }
//  GSWResponse_appendContentAsciiString(response,@"<!-- CON ) -->");  
}

@end

