/* GSWElement.h - GSWeb: Class GSWElement
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

// $Id$

#ifndef _GSWElement_h__
	#define _GSWElement_h__

extern BYTE ElementsMap_htmlBareString;
extern BYTE ElementsMap_gswebElement;
extern BYTE ElementsMap_dynamicElement;
extern BYTE ElementsMap_attributeElement;


//====================================================================
@interface GSWElement : NSObject
#ifndef NDEBBUG
{
  NSString* _appendToResponseElementID;
};
#endif

#ifndef NDEBBUG
-(void)saveAppendToResponseElementIDInContext:(id)context_;
-(void)assertCorrectElementIDInContext:(id)context_
							   inCLass:(Class)class_
							  method:(SEL)method_
								file:(const char*)file_
								line:(int)line_;
#endif
@end

#ifdef NDEBBUG
#define GSWSaveAppendToResponseElementID(context_);		{};
#define GSWAssertCorrectElementID(context_); 	{};
#else
#define GSWSaveAppendToResponseElementID(context_);		[self saveAppendToResponseElementIDInContext:context_];
#define GSWAssertCorrectElementID(context_); 			([self assertCorrectElementIDInContext:context_ inCLass:[self class] method:_cmd file:__FILE__ line:__LINE__]);
#endif


//====================================================================
@interface GSWElement (GSWRequestHandling)

-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_;

-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_; 
-(BOOL)prefixMatchSenderIDInContext:(GSWContext*)context_;
@end

#endif //_GSWElement_h__
