/** GSWElement.m - <title>GSWeb: Class GSWElement</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

BYTE ElementsMap_htmlBareString	=	(BYTE)0x53;
BYTE ElementsMap_gswebElement	=	(BYTE)0x57;
BYTE ElementsMap_dynamicElement	=	(BYTE)0x43;
BYTE ElementsMap_attributeElement = (BYTE)0x41;

//====================================================================
@implementation GSWElement

#ifndef NDEBBUG
//--------------------------------------------------------------------
-(void)saveAppendToResponseElementIDInContext:(id)context
{
  if(GSDebugSet(@"saveAppendToResponseElementID"))
    {
      NSString* elementID=nil;
      LOGObjectFnStartC("GSWElement");
      elementID=[context elementID];
      /*  if ([elementID length]==0)
          elementID=@"MARKER";*/
      NSDebugMLLog(@"GSWElement",@"self=%p declarationName=%@ elementID=%@ %p",self,[self declarationName],elementID,elementID);
      ASSIGNCOPY(_appendToResponseElementID,elementID);
      NSDebugMLLog(@"GSWElement",@"self=%p declarationName=%@ _appendToResponseElementID=%@ %p",self,[self declarationName],_appendToResponseElementID,_appendToResponseElementID);
      GSWAssertIsElementID(context);
      LOGObjectFnStopC("GSWElement");
    };
};

//--------------------------------------------------------------------
-(void)assertCorrectElementIDInContext:(id)context
                                method:(SEL)method
                                  file:(const char*)file
                                  line:(int)line
{
  LOGObjectFnStartC("GSWElement");  
  [self assertIsElementIDInContext:context
        method:method
        file:file
        line:line];
  if ([_appendToResponseElementID length]>0)
    {
      NSString* elementID=[context elementID];
      BOOL appendToResponseElementIDIsFirst=NO;
      BOOL elementIDIsFirst=NO;
      BOOL OK=YES;
      appendToResponseElementIDIsFirst=([_appendToResponseElementID length]==0 || [_appendToResponseElementID isEqualToString:@"0"]);
      elementIDIsFirst=([elementID length]==0 || [elementID isEqualToString:@"0"]);
      if (!appendToResponseElementIDIsFirst || appendToResponseElementIDIsFirst!=elementIDIsFirst)
        {
          OK=[_appendToResponseElementID isEqualToString:elementID];
          NSDebugMLLog(@"GSWElement",@"[context elementID]=%@ _appendToResponseElementID=%@ [_appendToResponseElementID length]=%d OK=%d [context isInLoop]=%d",
                       [context elementID],_appendToResponseElementID,[_appendToResponseElementID length],OK,[context isInLoop]);
        };
      if (!OK && ![context isInLoop])
        {
          NSString* msg=[NSString stringWithFormat:@"In Object %p Class %@ declarationName=%@ (file %s line %d), id '%@' (%p) in %@ is not the same than in appendToResponse '%@' (%p)",
                                  self,
                                  [self class],
                                  [self declarationName],
                                  file,
                                  line,
                                  [context elementID],
                                  [context elementID],
                                  NSStringFromSelector(method),
                                  _appendToResponseElementID,
                                  _appendToResponseElementID];
          //No: we may have multiple occurences NSAssert1(OK,@"%@",msg);
          NSDebugMLog(@"ELEMENT ID WARNING %@",msg);
        };
    };
  LOGObjectFnStopC("GSWElement");
};

//--------------------------------------------------------------------
-(void)assertIsElementIDInContext:(id)context
                           method:(SEL)method
                             file:(const char*)file
                             line:(int)line
{
  LOGObjectFnStartC("GSWElement");
/*  NSDebugMLLog(@"GSWElement",@"self=%p declarationName=%@ _appendToResponseElementID=%@ %p / [context elementID]=%@",
              self,
              [self declarationName],
              _appendToResponseElementID,_appendToResponseElementID,[context elementID]);
*/
  if (_appendToResponseElementID && [_appendToResponseElementID length]==0 && [[context elementID] length]>0)
    {
      NSString* msg=[NSString stringWithFormat:@"In Object %p Class %@ declarationName=%@ (file %s line %d), in %@ _appendToResponseElementID '%@' (%p) is not set",
                              self,
                              [self class],
                              [self declarationName],
                              file,
                              line,
                              NSStringFromSelector(method),
                              _appendToResponseElementID,
                              _appendToResponseElementID];
      NSAssert1(NO,@"%@",msg);
    };
  LOGObjectFnStopC("GSWElement");
};

//--------------------------------------------------------------------
-(void)logElementInContext:(id)context
                    method:(SEL)method
                      file:(const char*)file
                      line:(int)line
                 startFlag:(BOOL)start
                  stopFlag:(BOOL)stop
{
  NSString* senderID=[context senderID];
  if (start)
    [context addToDocStructureElement:self];
  NSDebugMLLog(@"GSWElement",@"%s:.%d - %@ %s ELEMENT self=%p class=%@ defName=%@ id=%@ appendID:%@ %s%@",
               file,line,NSStringFromSelector(method),
               (start ? "START" : (stop ? "STOP" : "")),
               self,
               [self class],
               [self declarationName],
               [context elementID],
               _appendToResponseElementID,
               (senderID ? "senderID:" : ""),
               (senderID ? senderID : @""));
};

#endif

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogAssertGood(self);
  GSWLogC("Dealloc GSWElement");
  GSWLogC("Dealloc GSWElement: name");
  DESTROY(_declarationName);
  GSWLogC("Dealloc GSWElement Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWElement");
}

//--------------------------------------------------------------------
-(NSString*)declarationName
{
  return _declarationName;
};

//--------------------------------------------------------------------
//TODO: obsolete: remove it
-(NSString*)definitionName
{
  return _declarationName;
};

//--------------------------------------------------------------------
-(void)setDeclarationName:(NSString*)declarationName
{
  NSDebugMLLog(@"gswdync",@"setDeclarationName1 in %p: %p %@",
               self,declarationName,declarationName);
  ASSIGN(_declarationName,declarationName);
  NSDebugMLLog(@"gswdync",@"setDeclarationName2 in %p: %p %@",
               self,_declarationName,_declarationName);
};
@end

//====================================================================
@implementation GSWElement (GSWRequestHandling)

//--------------------------------------------------------------------
//	takeValuesFromRequest:inContext:

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  GSWStartElement(context);
  GSWAddElementToDocStructure(context);
  GSWAssertCorrectElementID(context);// Debug Only
  //Does Nothing
  GSWStopElement(context);
};

//--------------------------------------------------------------------
//	invokeActionForRequest:inContext:

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request
                           inContext:(GSWContext*)context
{
  GSWStartElement(context);
  GSWAddElementToDocStructure(context);
  GSWAssertCorrectElementID(context);// Debug Only
  //Does Nothing
  GSWStopElement(context);
  return nil;
};

//--------------------------------------------------------------------
//	appendToResponse:inContext:

-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  GSWSaveAppendToResponseElementID(context);//Debug Only
  GSWAddElementToDocStructure(context);
  //Does Nothing
};

//--------------------------------------------------------------------
//NDFN
-(BOOL)prefixMatchSenderIDInContext:(GSWContext*)context
{
  BOOL match=NO;
  NSString* senderID=[context senderID];
  NSString* elementID=[context elementID];
  NSDebugMLLog(@"gswdync",@" senderID=%@",senderID);
  NSDebugMLLog(@"gswdync",@"elementID=%@",elementID);
  match=([elementID hasPrefix:senderID] || [senderID hasPrefix:elementID]);
  NSDebugMLLog(@"gswdync",@"match=%s",(match ? "YES" : "NO"));
  return match;
};

@end
