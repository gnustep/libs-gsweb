/** GSWGenericContainer.m - <title>GSWeb: Class GSWGenericContainer</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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

//====================================================================
@implementation GSWGenericContainer

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement
{
  NSMutableDictionary* tmpAssociations=[NSMutableDictionary dictionaryWithDictionary:associations];
  LOGObjectFnStartC("GSWForm");
  NSDebugMLLog(@"gswdync",@"aName=%@ associations:%@ templateElement=%@",aName,associations,templateElement);

  _elementName = [[associations objectForKey:elementName__Key
                           withDefaultObject:[_elementName autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWGenericContainer: elementName=%@",_elementName);

  _otherTagString = [[associations objectForKey:otherTagString__Key
                         withDefaultObject:[_otherTagString autorelease]] retain];
  NSDebugMLLog(@"gswdync",@"GSWGenericContainer: otherTagString=%@",_otherTagString);

  [tmpAssociations removeObjectForKey:elementName__Key];
  [tmpAssociations removeObjectForKey:otherTagString__Key];

  if (!WOStrictFlag)
    {
      _omitElement = [[associations objectForKey:omitElement__Key
                                    withDefaultObject:[_omitElement autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWGenericContainer: omitElement=%@",_omitElement);

      [tmpAssociations removeObjectForKey:omitElement__Key];
    };


  if ((self=[super initWithName:aName
                   associations:tmpAssociations
                   template:templateElement]))
    {
      if ([tmpAssociations count]>0)
        ASSIGN(_associations,tmpAssociations);
      ASSIGN(_element,templateElement);
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_elementName);
  DESTROY(_otherTagString);
  DESTROY(_omitElement);
  DESTROY(_associations);
  DESTROY(_element);
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  //TODOFN
  return [super description];
};

//--------------------------------------------------------------------

-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  NSEnumerator *assocEnumer=nil;
  id currentAssocKey=nil;
  id component = GSWContext_component(aContext);
  id theValue=nil;
  id otherTag = nil;
  id tag = nil;
  BOOL omitElement = NO;

  if (!WOStrictFlag && _omitElement)
    {
      omitElement=[self evaluateCondition:_omitElement
                        inContext:aContext
                        noConditionAssociationDefault:NO
                        noConditionDefault:NO];
    };

  if (!omitElement)
    {
      tag = [_elementName valueInComponent:component];
      
      GSWResponse_appendContentCharacter(aResponse,'<');
      GSWResponse_appendContentString(aResponse,tag);
      
      if ((otherTag = [_otherTagString valueInComponent:component])) 
        {
          GSWResponse_appendContentCharacter(aResponse,' ');
          GSWResponse_appendContentString(aResponse,otherTag);
        }
    
      assocEnumer = [_associations keyEnumerator];
      while ((currentAssocKey = [assocEnumer nextObject])) 
        {
          theValue = NSStringWithObject([[_associations objectForKey:currentAssocKey] 
                                          valueInComponent:component]);

          GSWResponse_appendContentCharacter(aResponse,' ');
          GSWResponse_appendContentString(aResponse,currentAssocKey);
          GSWResponse_appendContentAsciiString(aResponse,@"=\"");
          GSWResponse_appendContentString(aResponse,theValue);
          GSWResponse_appendContentCharacter(aResponse,'"');
        }

      GSWResponse_appendContentCharacter(aResponse,'>');
    };
  
  [_element appendToResponse:aResponse
            inContext:aContext];

  if (!omitElement)
    {
      GSWResponse_appendContentAsciiString(aResponse,@"</");
      GSWResponse_appendContentString(aResponse,tag);
      GSWResponse_appendContentCharacter(aResponse,'>');
    };
};

//--------------------------------------------------------------------

-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext
{
  return [_element invokeActionForRequest:aRequest
                   inContext:aContext];
};

//--------------------------------------------------------------------

-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext
{
  [_element takeValuesFromRequest:aRequest 
	    inContext:aContext];
};

//-------------------------------------------------------------------- 

@end

