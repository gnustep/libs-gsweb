/** GSWConditional.m - <title>GSWeb: Class GSWConditional</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWConditional

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
  DESTROY(_negate);
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
  condition=[self evaluateCondition:_condition
                  inContext:aContext];
  negate=[self evaluateCondition:_negate
               inContext:aContext];
  doIt=condition;
  NSDebugMLLog(@"gswdync",@"elementID=%@",[aContext elementID]);
  if (negate)
    doIt=!doIt;
  NSDebugMLLog(@"gswdync",@"defname=%@ condition=%@ negate=%@ evaluatedCondition=%s evaluatedNegate=%s doIt=%s",
               [self definitionName],
               _condition,
               _negate,
               (condition ? "YES" : "NO"),
               (negate ? "YES" : "NO"),
               (doIt ? "YES" : "NO"));
  if (doIt)
    {
      GSWRequest* _request=[aContext request];
      BOOL isFromClientComponent=[_request isFromClientComponent];
      [aContext appendZeroElementIDComponent];
      [_childrenGroup takeValuesFromRequest:aRequest
                     inContext:aContext];
      [aContext deleteLastElementIDComponent];
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
  condition=[self evaluateCondition:_condition
                  inContext:aContext];
  negate=[self evaluateCondition:_negate
               inContext:aContext];
  doIt=condition;
  if (negate)
    doIt=!doIt;
  NSDebugMLLog(@"gswdync",@"defname=%@ condition=%@ negate=%@ evaluatedCondition=%s evaluatedNegate=%s doIt=%s",
               [self definitionName],
               _condition,
               _negate,
               (condition ? "YES" : "NO"),
               (negate ? "YES" : "NO"),
               (doIt ? "YES" : "NO"));
  if (doIt)
    {
      GSWRequest* request=[aContext request];
      BOOL isFromClientComponent=[request isFromClientComponent];
      [aContext appendZeroElementIDComponent];
      NSDebugMLLog(@"gswdync",@"childrenGroup=%@",_childrenGroup);
      element=[_childrenGroup invokeActionForRequest:aRequest
                             inContext:aContext];
      NSDebugMLLog(@"gswdync",@"element=%@",element);
      [aContext deleteLastElementIDComponent];
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
  condition=[self evaluateCondition:_condition
                  inContext:aContext];
  NSDebugMLLog(@"gswdync",@"condition=%s",condition ? "YES" : "NO");
  negate=[self evaluateCondition:_negate
               inContext:aContext];
  NSDebugMLLog(@"gswdync",@"negate=%s",negate ? "YES" : "NO");
  doIt=condition;
  if (negate)
    doIt=!doIt;
  NSDebugMLLog(@"gswdync",@"defname=%@ condition=%@ negate=%@ evaluatedCondition=%s evaluatedNegate=%s doIt=%s",
               [self definitionName],
               _condition,
               _negate,
               (condition ? "YES" : "NO"),
               (negate ? "YES" : "NO"),
               (doIt ? "YES" : "NO"));
  if (doIt)
    {
      GSWRequest* request=[aContext request];
      BOOL isFromClientComponent=[request isFromClientComponent];
      [aContext appendZeroElementIDComponent];
      [_childrenGroup appendToResponse:aResponse
                      inContext:aContext];
      [aContext deleteLastElementIDComponent];
    };
  GSWStopElement(aContext);
  GSWAssertIsElementID(aContext);
  LOGObjectFnStop();
};

@end
