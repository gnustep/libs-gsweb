/* GSWSimpleFormComponent.m - GSWeb: Class GSWSimpleFormComponent
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Sept 1999
   
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
#include <GSWeb/GSWeb.h>
#include "GSWSimpleFormComponent.h"
//====================================================================
@implementation GSWSimpleFormComponent

//--------------------------------------------------------------------
-(id)init
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)awake
{
  LOGObjectFnStart();
  [super awake];
  tmpErrorMessage=nil;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)sleep
{
  LOGObjectFnStart();
  tmpErrorMessage=nil;
  [super sleep];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)dealloc
{
  [super dealloc];
};

//--------------------------------------------------------------------
-(BOOL)synchronizesVariablesWithBindings
{
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)validateFormFields:(id)fields
	 withFieldsDscription:(NSDictionary*)fieldsDscription_
	   errorMessagePrefix:(NSString*)errorMessagePrefix_
	   errorMessageSuffix:(NSString*)errorMessageSuffix_
{
  NSEnumerator* _enum=nil;
  NSMutableString* _missingFields=nil;
  id _key=nil;
  NSString* _dscrValue=nil;
  NSString* _value=nil;
  LOGObjectFnStart();
  _enum=[fieldsDscription_ keyEnumerator];
  while((_key=[_enum nextObject]))
	{
	  _dscrValue=[fieldsDscription_ objectForKey:_key];
	  _value=[fields  objectForKey:_key];
	  if (!_value || [_value length]==0)
		{
		  if (_missingFields)
			[_missingFields appendFormat:@", %@",_dscrValue];
		  else
			_missingFields=(NSMutableString*)[NSMutableString stringWithFormat:@"%@",_dscrValue];
		};
	};
  if (_missingFields)
	{
	  tmpErrorMessage=[NSString stringWithFormat:@"%@ %@ %@",
								(errorMessagePrefix_ ? errorMessagePrefix_ : @""),
								_missingFields,
								(errorMessageSuffix_ ? errorMessageSuffix_ : @"")];
	  NSDebugMLog(@"tmpErrorMessage=%@",tmpErrorMessage);
	};
  LOGObjectFnStop();
  return !_missingFields;
};

//--------------------------------------------------------------------
-(BOOL)isErrorMessage
{
  return [tmpErrorMessage length]>0;
};

//--------------------------------------------------------------------
-(GSWComponent*)sendAction
{
  return [[self parent]sendActionFromComponent:self];
};

//--------------------------------------------------------------------
-(GSWComponent*)sendFields:(id)fields
	  withFieldsDscription:(NSDictionary*)fieldsDscription_
				  byMailTo:(NSString*)to_
					  from:(NSString*)from_
			   withSubject:(NSString*)subject_
			 messagePrefix:(NSString*)messagePrefix_
			 messageSuffix:(NSString*)messageSuffix_
			  sentPageName:(NSString*)sentPageName_
{
  NSEnumerator* _enum=nil;
  GSWComponent* _page=nil;
  NSMutableString* _mailText=[NSMutableString string];
  id _key=nil;
  NSString* _dscrValue=nil;
  NSString* _value=nil;
  NSString* _msg=nil;
  LOGObjectFnStart();
  _enum=[fieldsDscription_ keyEnumerator];
  while((_key=[_enum nextObject]))
	{
	  _dscrValue=[fieldsDscription_ objectForKey:_key];
	  _value=[fields  objectForKey:_key];
	  [_mailText appendFormat:@"%@:\t%@\n",_dscrValue,_value];
	};
  NSDebugMLog(@"to_=%@",to_);
  NSDebugMLog(@"from_=%@",from_);
  if (from_ && to_)
	{
	  NSString* _text=[NSString stringWithFormat:@"%@%@%@",
								(messagePrefix_ ? messagePrefix_ : @""),
								_mailText,
								(messageSuffix_ ?  messageSuffix_ : @"")];
	  NSDebugMLog(@"_text=%@",_text);
	  _msg=[[GSWMailDelivery sharedInstance] composeEmailFrom:from_
											 to:[NSArray arrayWithObject:to_]
											 cc:nil
											 subject:subject_
											 plainText:_text
											 send:YES];
	  NSDebugMLog(@"_msg=%@",_msg);
	}
  else
	{
	  //TODO
	  LOGError(@"No From or To address (from_=%@ , to_=%@)",from_,to_);
	};
  _page=[self pageWithName:sentPageName_];
  LOGObjectFnStop();
  return _page;
};
@end


