/** GSWTransactionRecord.m - <title>GSWeb: Class GSWTransactionRecord</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        Apr 1999
   
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
@implementation GSWTransactionRecord

+(GSWTransactionRecord*)transactionRecordWithResponsePage:(GSWComponent*)aResponsePage
                                                  context:(GSWContext*)aContext
{
  return [[[self alloc]initWithResponsePage:aResponsePage
                       context:aContext]autorelease];
};

//--------------------------------------------------------------------
-(id)initWithResponsePage:(GSWComponent*)aResponsePage
                  context:(GSWContext*)aContext
{
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      [self setResponsePage:aResponsePage];
      NSDebugMLLog(@"low",@"responsePage=%@",_responsePage);

      ASSIGN(_contextID,([aContext _requestContextID]));
      ASSIGN(_senderID,GSWContext_senderID(aContext));
      ASSIGN(_formValues,([[aContext request] formValues]));

      NSDebugMLLog(@"low",@"contextID=%@",[aContext _requestContextID]);
      NSDebugMLLog(@"low",@"senderID=%@",_senderID);
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWTransactionRecord");
  GSWLogC("Dealloc GSWTransactionRecord: responsePage");
  DESTROY(_responsePage);
  GSWLogC("Dealloc GSWTransactionRecord: contextID");
  DESTROY(_contextID);
  GSWLogC("Dealloc GSWTransactionRecord: senderID");
  DESTROY(_senderID);
  GSWLogC("Dealloc GSWTransactionRecord: formValues");
  DESTROY(_formValues);
  GSWLogC("Dealloc GSWTransactionRecord super");
  [super dealloc];
  GSWLogC("End Dealloc GSWTransactionRecord");
};

//--------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*)coder
{
  if ((self = [super init]))
    {
      [coder decodeValueOfObjCType:@encode(id)
             at:&_responsePage];
      [coder decodeValueOfObjCType:@encode(id)
             at:&_contextID];
      [coder decodeValueOfObjCType:@encode(id)
             at:&_senderID];
      [coder decodeValueOfObjCType:@encode(id)
             at:&_formValues];
    };
  return self;
};

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder
{
  [coder encodeObject:_responsePage];
  [coder encodeObject:_contextID];
  [coder encodeObject:_senderID];
  [coder encodeObject:_formValues];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - responsePage Name=%@ contextID=%@ senderID=%@>",
                   object_get_class_name(self),
                   (void*)self,
                   [_responsePage name],
                   _contextID,
                   _senderID];
};

//--------------------------------------------------------------------
-(BOOL)isMatchingContextID:(NSString*)aContextID
           requestSenderID:(NSString*)aRequestSenderID
{
  NSAssert(NO,@"Deprecated. use isMatchingIDsInContext:");
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)isMatchingIDsInContext:(GSWContext*)aContext
{
  BOOL match=NO;
  if ([_contextID isEqualToString:[aContext _requestContextID]]
      && [_senderID isEqualToString:GSWContext_senderID(aContext)])
    {
      NSDictionary* requestFormValues=[[aContext request] formValues];
      match=((!_formValues && !requestFormValues)
             || [_formValues isEqual:requestFormValues]);
    }
  return match;
}
//--------------------------------------------------------------------
-(void)setResponsePage:(GSWComponent*)aResponsePage
{
  if (aResponsePage!=_responsePage)
    ASSIGN(_responsePage,aResponsePage);
};

//--------------------------------------------------------------------
-(GSWComponent*)responsePage
{
  GSWLogAssertGood(self);
  return _responsePage;
};

@end

