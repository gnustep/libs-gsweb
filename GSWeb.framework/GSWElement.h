/** GSWElement.h - <title>GSWeb: Class GSWElement</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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

GSWEB_EXPORT BYTE ElementsMap_htmlBareString;
GSWEB_EXPORT BYTE ElementsMap_gswebElement;
GSWEB_EXPORT BYTE ElementsMap_dynamicElement;
GSWEB_EXPORT BYTE ElementsMap_attributeElement;

#ifndef NDEBBUG
#define GSWELEMENT_HAS_DECLARATION_NAME
#endif

//====================================================================
@interface GSWElement : NSObject
#ifdef GSWELEMENT_HAS_DECLARATION_NAME
{
  NSString* _appendToResponseElementID;
  NSString* _declarationName; // Name of element in def file (.gswd) - Mainly for debugging purpose
};
#endif

#if defined(GSWDEBUG_ELEMENTSIDS) && defined(GSWELEMENT_HAS_DECLARATION_NAME)
-(void)saveAppendToResponseElementIDInContext:(id)context;
-(void)assertCorrectElementIDInContext:(id)context
                                method:(SEL)method
                                  file:(const char*)file
                                  line:(int)line;
-(void)assertIsElementIDInContext:(id)context
                           method:(SEL)method
                             file:(const char*)file
                             line:(int)line;
-(void)logElementInContext:(id)context
                    method:(SEL)method
                      file:(const char*)file
                      line:(int)line
                 startFlag:(BOOL)start
                  stopFlag:(BOOL)stop;
#endif

//Do nothing ifndef GSWELEMENT_HAS_DECLARATION_NAME
-(NSString*)declarationName;
-(void)setDeclarationName:(NSString*)declarationName;
@end

#if !defined(GSWDEBUG_ELEMENTSIDS) || defined(NDEBBUG)

#define GSWSaveAppendToResponseElementID(TheContext);		{};
#define GSWAssertCorrectElementID(TheContext); 			{};
#define GSWAssertIsElementID(TheContext); 			{};
#define GSWStartElement(TheContext); 				{};
#define GSWStopElement(TheContext); 				{};
#define GSWAddElementToDocStructure(TheContext); 		{};
#define GSWDeclareDebugElementID(TheContext); 			{};
#define GSWAssignDebugElementID(TheContext); 			{};
#define GSWAssertDebugElementID(TheContext); 			{};
#define GSWDeclareDebugElementIDsCount(TheContext); 		{};
#define GSWAssertDebugElementIDsCount(TheContext); 		{};

#else

#define GSWSaveAppendToResponseElementID(TheContext);		[self saveAppendToResponseElementIDInContext:(TheContext)];

#define GSWAssertCorrectElementID(TheContext); 			\
	([self assertCorrectElementIDInContext:TheContext method:_cmd file:__FILE__ line:__LINE__]);

#define GSWAssertIsElementID(TheContext); 			\
	([self assertIsElementIDInContext:TheContext method:_cmd file:__FILE__ line:__LINE__]);

#define GSWStartElement(TheContext); 			\
	([self logElementInContext:TheContext method:_cmd file:__FILE__ line:__LINE__ startFlag:YES stopFlag:NO]);

#define GSWStopElement(TheContext); 			\
	([self logElementInContext:TheContext method:_cmd file:__FILE__ line:__LINE__ startFlag:NO stopFlag:YES]);

#define GSWLogElement(TheContext); 			\
	([self logElementInContext:TheContext method:_cmd file:__FILE__ line:__LINE__ startFlag:NO stopFlag:NO]);

#define GSWAddElementToDocStructure(TheContext); 	\
	[TheContext addToDocStructureElement:self];

#define GSWDeclareDebugElementID(TheContext); 			\
	NSString* debugElementID=[TheContext elementID];

#define GSWAssignDebugElementID(TheContext); 			\
	debugElementID=[TheContext elementID];

#define GSWAssertDebugElementID(TheContext); 			\
        if (![debugElementID isEqualToString:[(TheContext) elementID]])	\
            {									\
              NSDebugMLLog(@"gswdync",						\
                           @"class=%@ debugElementID=%@ [context elementID]=%@",\
			   [self class],debugElementID,[(TheContext) elementID]); \
            };

#define GSWDeclareDebugElementIDsCount(TheContext); 		\
	int debugElementsCount=[(TheContext) elementIDElementsCount];

#define GSWAssertDebugElementIDsCount(TheContext); 		\
  NSAssert4(debugElementsCount==[(TheContext) elementIDElementsCount], \
           @"Object %p bad elementID %d!=%d (%@)",		\
            self,						\
            debugElementsCount,					\
            [(TheContext) elementIDElementsCount],		\
            [(TheContext) elementID]);

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
