/** GSWElement.m - <title>GSWeb: Class GSWElement</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

BYTE ElementsMap_htmlBareString	=	(BYTE)0x53;
BYTE ElementsMap_gswebElement	=	(BYTE)0x57;
BYTE ElementsMap_dynamicElement	=	(BYTE)0x43;
BYTE ElementsMap_attributeElement = (BYTE)0x41;

//====================================================================
@implementation GSWElement

#ifndef NDEBBUG
-(void)saveAppendToResponseElementIDInContext:(id)context
{
  NSString* elementID=[context elementID];
  ASSIGN(_appendToResponseElementID,elementID);
};

-(void)assertCorrectElementIDInContext:(id)context
                               inCLass:(Class)class
                                method:(SEL)method
                                  file:(const char*)file
                                  line:(int)line
{
  if ([_appendToResponseElementID length]>0)
    {
      NSString* elementID=[context elementID];
      BOOL appendToResponseElementIDIsFirst=NO;
      BOOL elementIDIsFirst=NO;
      BOOL OK=YES;
      appendToResponseElementIDIsFirst=([_appendToResponseElementID length]==0 || [_appendToResponseElementID isEqualToString:@"0"]);
      elementIDIsFirst=([elementID length]==0 || [elementID isEqualToString:@"0"]);
      if (appendToResponseElementIDIsFirst!=elementIDIsFirst)
        {
          OK=[_appendToResponseElementID isEqualToString:elementID];
        };
      if (!OK)
        {
          NSString* msg=[NSString stringWithFormat:@"In Class %@ (file %s line %d), id %@ in %@ is not the same than in appendToResponse %@",
                                  NSStringFromClass(class),
                                  file,
                                  line,
                                  [context elementID],
                                  NSStringFromSelector(method),
                                  _appendToResponseElementID];
          NSAssert1(OK,@"%@",msg);
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

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  GSWAssertCorrectElementID(context);// Debug Only
  //Does Nothing
};

//--------------------------------------------------------------------
//	invokeActionForRequest:inContext:

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
{
  NSDebugMLLog(@"gswdync",@"ET=%@ id=%@ senderId=%@",
               [self class],[context elementID],[context senderID]);
  GSWAssertCorrectElementID(context);// Debug Only
  //Does Nothing
  return nil;
};

//--------------------------------------------------------------------
//	appendToResponse:inContext:

-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  GSWSaveAppendToResponseElementID(context);//Debug Only
  //Does Nothing
};

//--------------------------------------------------------------------
//NDFN
-(BOOL)prefixMatchSenderIDInContext:(GSWContext*)context
{
  NSString* senderID=[context senderID];
  NSString* elementID=[context elementID];
  NSDebugMLLog(@"gswdync",@"senderID=%@",senderID);
  NSDebugMLLog(@"gswdync",@"elementID=%@",elementID);
  return ([elementID hasPrefix:senderID] || [senderID hasPrefix:elementID]);
};

@end


