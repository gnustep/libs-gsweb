/* GSWTransactionRecord.m - GSWeb: Class GSWTransactionRecord
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Apr 1999
   
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

#include <gsweb/GSWeb.framework/GSWeb.h>

//====================================================================
@implementation GSWTransactionRecord

//--------------------------------------------------------------------
-(id)initWithResponsePage:(GSWComponent*)responsePage_
				  context:(GSWContext*)context_
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  NSString* _contextID=nil;
	  NSString* _senderID=nil;
	  NSString* _requestSignature=nil;
	  [self setResponsePage:responsePage_];
	  NSDebugMLLog(@"low",@"responsePage=%@",responsePage);
	  _contextID=[context_ contextID];//Really from here ?
	  NSDebugMLLog(@"low",@"_contextID=%@",_contextID);
	  _senderID=[context_ senderID];
	  NSDebugMLLog(@"low",@"_senderID=%@",_senderID);
	  _requestSignature=[NSString stringWithFormat:@"%@.%@",_contextID,_senderID];
	  ASSIGN(requestSignature,_requestSignature);
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWTransactionRecord");
  GSWLogC("Dealloc GSWTransactionRecord: responsePage");
  DESTROY(responsePage);
  GSWLogC("Dealloc GSWTransactionRecord: requestSignature");
  DESTROY(requestSignature);
  GSWLogC("Dealloc GSWTransactionRecord super");
  [super dealloc];
  GSWLogC("End Dealloc GSWTransactionRecord");
};

//--------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*)coder_
{
  if ((self = [super initWithCoder:coder_]))
	{
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&responsePage];
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&requestSignature];
	};
  return self;
};

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder_
{
  [super encodeWithCoder: coder_];
  [coder_ encodeObject:responsePage];
  [coder_ encodeObject:requestSignature];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p - responsePage Name=%@ requestSignature=%@>",
				   object_get_class_name(self),
				   (void*)self,
				   [responsePage name],
				   requestSignature];
};

//--------------------------------------------------------------------
-(BOOL)isMatchingContextID:(NSString*)contextID_
		   requestSenderID:(NSString*)requestSenderID_
{
  //OK?
  BOOL _matching=NO;
  NSString* _testSignature=[NSString stringWithFormat:@"%@.%@",contextID_,requestSenderID_];
  _matching=[_testSignature isEqualToString:requestSignature];
  return _matching;
};

//--------------------------------------------------------------------
-(void)setResponsePage:(GSWComponent*)responsePage_
{
  ASSIGN(responsePage,responsePage_);
};

//--------------------------------------------------------------------
-(GSWComponent*)responsePage
{
  LOGAssertGood(self);
  return responsePage;
};

@end

