/** GSWElement.h - <title>GSWeb: Class GSWElement</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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
-(void)saveAppendToResponseElementIDInContext:(id)context;
-(void)assertCorrectElementIDInContext:(id)context
                               inCLass:(Class)class
                                method:(SEL)method
                                  file:(const char*)file
                                  line:(int)line;
#endif

-(NSString*)definitionName; //return nil (for non dynamic element)
@end

#ifdef NDEBBUG
#define GSWSaveAppendToResponseElementID(context_);		{};
#define GSWAssertCorrectElementID(context_); 			{};
#else
#define GSWSaveAppendToResponseElementID(context_);		[self saveAppendToResponseElementIDInContext:context_];
#define GSWAssertCorrectElementID(context_); 			\
	([self assertCorrectElementIDInContext:context_ inCLass:[self class] method:_cmd file:__FILE__ line:__LINE__]);
#endif


//====================================================================
@interface GSWElement (GSWRequestHandling)

-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context;

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context;

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context; 
-(BOOL)prefixMatchSenderIDInContext:(GSWContext*)context;
@end

#endif //_GSWElement_h__
