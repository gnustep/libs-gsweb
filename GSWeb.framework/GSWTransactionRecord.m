/** GSWTransactionRecord.m - <title>GSWeb: Class GSWTransactionRecord</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
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

//--------------------------------------------------------------------
-(id)initWithResponsePage:(GSWComponent*)aResponsePage
                  context:(GSWContext*)aContext
{
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      NSString* contextID=nil;
      NSString* senderID=nil;
      NSString* requestSignature=nil;
      [self setResponsePage:aResponsePage];
      NSDebugMLLog(@"low",@"responsePage=%@",_responsePage);
      contextID=[aContext contextID];//Really from here ? Use aContext _requestContextID instead ? //TODO
      NSDebugMLLog(@"low",@"contextID=%@",contextID);
      senderID=[aContext senderID];
      NSDebugMLLog(@"low",@"senderID=%@",senderID);
      requestSignature=[NSString stringWithFormat:@"%@.%@",contextID,senderID];
      ASSIGN(_requestSignature,requestSignature);
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
  GSWLogC("Dealloc GSWTransactionRecord: requestSignature");
  DESTROY(_requestSignature);
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
             at:&_requestSignature];
    };
  return self;
};

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder
{
  [coder encodeObject:_responsePage];
  [coder encodeObject:_requestSignature];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - responsePage Name=%@ requestSignature=%@>",
				   object_get_class_name(self),
				   (void*)self,
				   [_responsePage name],
				   _requestSignature];
};

//--------------------------------------------------------------------
-(BOOL)isMatchingContextID:(NSString*)aContextID
           requestSenderID:(NSString*)aRequestSenderID
{
  //OK?
  BOOL matching=NO;
  NSString* testSignature=[NSString stringWithFormat:@"%@.%@",aContextID,aRequestSenderID];
  matching=[testSignature isEqualToString:_requestSignature];
  return matching;
};

//--------------------------------------------------------------------
-(void)setResponsePage:(GSWComponent*)aResponsePage
{
  ASSIGN(_responsePage,aResponsePage);
};

//--------------------------------------------------------------------
-(GSWComponent*)responsePage
{
  GSWLogAssertGood(self);
  return _responsePage;
};

@end

