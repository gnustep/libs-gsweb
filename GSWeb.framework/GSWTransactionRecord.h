/* GSWTransactionRecord.h - GSWeb: Class GSWTransactionRecord
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

// $Id$

#ifndef _GSWTransactionRecord_h__
	#define _GSWTransactionRecord_h__


//====================================================================
@interface GSWTransactionRecord : NSObject
{
  GSWComponent* responsePage;
  NSString* requestSignature;
};

-(id)initWithResponsePage:(GSWComponent*)responsePage_
				  context:(GSWContext*)context_;
-(void)dealloc;

-(id)initWithCoder:(NSCoder*)code_;
-(void)encodeWithCoder:(NSCoder*)code_;

-(NSString*)description;
-(BOOL)isMatchingContextID:(NSString*)contextID_
		   requestSenderID:(NSString*)requestSenderID;
-(void)setResponsePage:(GSWComponent*)responsePage_;
-(GSWComponent*)responsePage;

@end

#endif //_GSWTransactionRecord_h__
