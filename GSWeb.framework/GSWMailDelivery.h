/* GSWMailDelivery.h - GSWeb: Class GSWMailDelivery
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

// $Id$

#ifndef _GSWMailDelivery_h__
	#define _GSWMailDelivery_h__


//====================================================================
@interface GSWMailDelivery : NSObject
{
  NSString *sender;
};

+(GSWMailDelivery*)sharedInstance;
-(NSString*)composeEmailFrom:(NSString*)sender_
						  to:(NSArray*)to_
						  cc:(NSArray*)cc_
					 subject:(NSString*)subject_
				   plainText:(NSString*)plainTextMessage_
						send:(BOOL)sendNow_;
-(NSString*)composeEmailFrom:(NSString*)sender_
						  to:(NSArray*)to_
						  cc:(NSArray*)cc_
					 subject:(NSString*)subject_
				   component:(GSWComponent*)component_
						send:(BOOL)sendNow_;
//NDFN
-(NSString*)composeEmailFrom:(NSString*)sender_
						  to:(NSArray*)to_
						  cc:(NSArray*)cc_
						  bcc:(NSArray*)bcc_
					 subject:(NSString*)subject_
				   plainText:(NSString*)plainTextMessage_
						send:(BOOL)sendNow_;
//NDFN
-(NSString*)composeEmailFrom:(NSString*)sender_
						  to:(NSArray*)to_
						  cc:(NSArray*)cc_
						  bcc:(NSArray*)bcc_
					 subject:(NSString*)subject_
				   component:(GSWComponent*)component_
						send:(BOOL)sendNow_;
-(void)sendEmail:(NSString*)emailString_;
-(void)_invokeGSWSendMailAt:(id)at_
				 withEmail:(id)email_;
@end




#endif //GSWMailDelivery
