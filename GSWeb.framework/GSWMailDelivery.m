/* GSWMailDelivery.m - GSWeb: Class GSWMailDelivery
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

#include <gsweb/GSWeb.framework/GSWeb.h>

//====================================================================
@implementation GSWMailDelivery

+(GSWMailDelivery*)sharedInstance
{
  LOGClassFnNotImplemented();	//TODOFN
  return [[GSWMailDelivery new] autorelease];
};

-(NSString*)composeEmailFrom:(NSString*)sender_
						  to:(NSArray*)to_
						  cc:(NSArray*)cc_
					 subject:(NSString*)subject_
				   plainText:(NSString*)plainTextMessage_
						send:(BOOL)sendNow_
{
  NSDebugMLog(@"sender_=%@",sender_);
  NSDebugMLog(@"to_=%@",to_);
  NSDebugMLog(@"cc_=%@",cc_);
  NSDebugMLog(@"subject_=%@",subject_);
  NSDebugMLog(@"plainTextMessage_=%@",plainTextMessage_);
  NSDebugMLog(@"sendNow_=%d",(int)sendNow_);
  return [self composeEmailFrom:sender_
			   to:to_
			   cc:cc_
			   bcc:nil
			   subject:subject_
			   plainText:plainTextMessage_
			   send:sendNow_];
};

-(NSString*)composeEmailFrom:(NSString*)sender_
						  to:(NSArray*)to_
						  cc:(NSArray*)cc_
					 subject:(NSString*)subject_
				   component:(GSWComponent*)component_
						send:(BOOL)sendNow_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//NDFN
-(NSString*)composeEmailFrom:(NSString*)sender_
						  to:(NSArray*)to_
						  cc:(NSArray*)cc_
						  bcc:(NSArray*)bcc_
					 subject:(NSString*)subject_
				   plainText:(NSString*)plainTextMessage_
						send:(BOOL)sendNow_
{
  NSString* _msg=nil;
  NSMutableString* _to=nil;
  int i=0;
  int _count=0;
  _count=[to_ count];
  NSDebugMLog(@"sender_=%@",sender_);
  NSDebugMLog(@"to_=%@",to_);
  NSDebugMLog(@"cc_=%@",cc_);
  NSDebugMLog(@"bcc_=%@",bcc_);
  NSDebugMLog(@"subject_=%@",subject_);
  NSDebugMLog(@"plainTextMessage_=%@",plainTextMessage_);
  NSDebugMLog(@"sendNow_=%d",(int)sendNow_);
  for(i=0;i<_count;i++)
	{
	  if (!_to)
		_to=(NSMutableString*)[NSMutableString stringWithFormat:@"%@",[to_ objectAtIndex:i]];
	  else
		[_to appendFormat:@", %@",[to_ objectAtIndex:i]];
	};
  NSDebugMLog(@"_to=%@",_to);
  _msg=[NSString stringWithFormat:@"From: %@\nTo: %@\n",sender_,_to];
  NSDebugMLog(@"_msg=%@",_msg);
  _count=[cc_ count];
  if (_count)
	{
	  NSMutableString* _cc=nil;
	  for(i=0;i<_count;i++)
		{
		  if (!_cc)
			_cc=(NSMutableString*)[NSMutableString stringWithFormat:@"%@",[cc_ objectAtIndex:i]];
		  else
			[_cc appendFormat:@", %@",[cc_ objectAtIndex:i]];
		};
	  NSDebugMLog(@"_cc=%@",_cc);
	  _msg=[_msg stringByAppendingFormat:@"Cc: %@\n",_cc];
	  NSDebugMLog(@"_msg=%@",_msg);
	};
  _count=[bcc_ count];
  if (_count)
	{
	  NSMutableString* _bcc=nil;
	  for(i=0;i<_count;i++)
		{
		  if (!_bcc)
			_bcc=(NSMutableString*)[NSMutableString stringWithFormat:@"%@",[bcc_ objectAtIndex:i]];
		  else
			[_bcc appendFormat:@", %@",[bcc_ objectAtIndex:i]];
		};
	  NSDebugMLog(@"_bcc=%@",_bcc);
	  _msg=[_msg stringByAppendingFormat:@"Bcc: %@\n",_bcc];
	  NSDebugMLog(@"_msg=%@",_msg);
	};
  _msg=[_msg stringByAppendingFormat:@"Subject: %@\n\n%@",subject_,plainTextMessage_];
  NSDebugMLog(@"_msg=%@",_msg);
  if (sendNow_)
	[self sendEmail:_msg];
  return _msg;
};

//NDFN
-(NSString*)composeEmailFrom:(NSString*)sender_
						  to:(NSArray*)to_
						  cc:(NSArray*)cc_
						  bcc:(NSArray*)bcc_
					 subject:(NSString*)subject_
				   component:(GSWComponent*)component_
						send:(BOOL)sendNow_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

-(void)sendEmail:(NSString*)emailString_
{
  NSString* _command=nil;
  NSString* _emailString=nil;
  LOGObjectFnNotImplemented();	//TODOFN
  NSDebugMLog(@"emailString_=%@",emailString_);
  _emailString=[emailString_ stringByReplacingString:@"&"
							 withString:@"\\&"];
  NSDebugMLog(@"_emailString=%@",_emailString);
  _command=[NSString stringWithFormat:@"echo \"%@\" | /usr/sbin/sendmail manu@sbuilders.com",_emailString];
  system([_command cString]);
};

-(void)_invokeGSWSendMailAt:(id)at_
				 withEmail:(id)email_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

