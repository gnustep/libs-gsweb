/** GSWGenericContainer.m - <title>GSWeb: Class GSWGenericContainer</title>

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

//====================================================================
@implementation GSWGenericContainer

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)templateElement
{
  if ((self = [super init]))
    {
      ASSIGN(_associations,associations);
      ASSIGN(_element,templateElement);
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
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
  id component = [aContext component];
  id theValue=nil;
  id otherTag = nil;
  id tag = [[_associations objectForKey:@"elementName"] valueInComponent:component];
  
  [aResponse appendContentString:[NSString stringWithFormat:@"<%@",tag]];

  if ((otherTag = [[_associations objectForKey:@"otherTagString"] valueInComponent:component])) 
    {
      [aResponse appendContentString:[NSString stringWithFormat:@" %@",otherTag]];
    }
    
  assocEnumer = [_associations keyEnumerator];
  while ((currentAssocKey = [assocEnumer nextObject])) 
    {
      theValue = [[_associations objectForKey:currentAssocKey] valueInComponent:component];
      if (([currentAssocKey isEqualToString:@"elementName"] == NO) 
          && ([currentAssocKey isEqualToString:@"otherTagString"] == NO)) 
        {
          [aResponse appendContentString:[NSString stringWithFormat:@" %@=\"%@\"",currentAssocKey,theValue]];
        }
    }
  
  [aResponse appendContentString:@">"];
  [_element appendToResponse:aResponse inContext:aContext];
  [aResponse appendContentString:[NSString stringWithFormat:@"</%@>",tag]];
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

