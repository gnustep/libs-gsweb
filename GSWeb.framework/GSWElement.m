/* GSWElement.m - GSWeb: Class GSWElement
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
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

#include <GSWeb/GSWeb.h>

BYTE ElementsMap_htmlBareString	=	(BYTE)0x53;
BYTE ElementsMap_gswebElement	=	(BYTE)0x57;
BYTE ElementsMap_dynamicElement	=	(BYTE)0x43;
BYTE ElementsMap_attributeElement = (BYTE)0x41;

//====================================================================
@implementation GSWElement

#ifndef NDEBBUG
-(void)saveAppendToResponseElementIDInContext:(id)context_
{
  NSString* _elementID=[context_ elementID];
  ASSIGN(_appendToResponseElementID,_elementID);
};

-(void)assertCorrectElementIDInContext:(id)context_
							   inCLass:(Class)class_
								method:(SEL)method_
								  file:(const char*)file_
								  line:(int)line_
{
  if ([_appendToResponseElementID length]>0)
	{
	  NSString* _elementID=[context_ elementID];
	  BOOL _appendToResponseElementIDIsFirst=NO;
	  BOOL _elementIDIsFirst=NO;
	  BOOL _OK=YES;
	  _appendToResponseElementIDIsFirst=[_appendToResponseElementID length]==0 || [_appendToResponseElementID isEqualToString:@"0"];
	  _elementIDIsFirst=[_elementID length]==0 || [_elementID isEqualToString:@"0"];
	  if (_appendToResponseElementIDIsFirst!=_elementIDIsFirst)
		{
		  _OK=[_appendToResponseElementID isEqualToString:_elementID];
		};
	  if (!_OK)
		{
		  NSString* _msg=[NSString stringWithFormat:@"In Class %@ (file %s line %d), id %@ in %@ is not the same than in appendToResponse %@",
								   NSStringFromClass(class_),
								   file_,
								   line_,
								   [context_ elementID],
								   NSStringFromSelector(method_),
								   _appendToResponseElementID];
		  NSAssert1(_OK,@"%@",_msg);
		};
	};
};
#endif

-(NSString*)definitionName
{
  return nil; //return nil (for non dynamic element)
};
@end

//====================================================================
@implementation GSWElement (GSWRequestHandling)

//--------------------------------------------------------------------
//	takeValuesFromRequest:inContext:

-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_ 
{
  GSWAssertCorrectElementID(context_);// Debug Only
  //Does Nothing
};

//--------------------------------------------------------------------
//	invokeActionForRequest:inContext:

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@",[self class],[context_ elementID],[context_ senderID]);
  GSWAssertCorrectElementID(context_);// Debug Only
  //Does Nothing
  return nil;
};

//--------------------------------------------------------------------
//	appendToResponse:inContext:

-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  GSWSaveAppendToResponseElementID(context_);//Debug Only
  //Does Nothing
};

//--------------------------------------------------------------------
//NDFN
-(BOOL)prefixMatchSenderIDInContext:(GSWContext*)context_
{
  NSString* _senderID=[context_ senderID];
  NSString* _elementID=[context_ elementID];
  NSDebugMLLog(@"gswdync",@"_senderID=%@",_senderID);
  NSDebugMLLog(@"gswdync",@"_elementID=%@",_elementID);
  return ([_elementID hasPrefix:_senderID] || [_senderID hasPrefix:_elementID]);
};

@end


