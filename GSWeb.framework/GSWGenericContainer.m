/* GSWGenericContainer.m - GSWeb: Class GSWGenericContainer
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

//====================================================================
@implementation GSWGenericContainer

-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
		 template:(GSWElement*)templateElement_
{
	self = [super init];
	associations=[associations_ retain];
	element=[templateElement_ retain];
    return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
    [associations release];
    [element release];
    [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
//TODOFN
  return [super description];
};

//--------------------------------------------------------------------

-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
    NSEnumerator *assocEnumer;
    id currentAssocKey;
    id component = [context_ component];
    id theValue;
    id otherTag = nil;
	id tag = [[associations objectForKey:@"elementName"] valueInComponent:component];

    [response_ appendContentString:[NSString stringWithFormat:@"<%@",tag]];

    if (otherTag = [[associations objectForKey:@"otherTagString"] valueInComponent:component]) {
        [response_ appendContentString:[NSString stringWithFormat:@" %@",otherTag]];
    }

    
    assocEnumer = [associations keyEnumerator];
    while (currentAssocKey = [assocEnumer nextObject]) {
        theValue = [[associations objectForKey:currentAssocKey] valueInComponent:component];
        if (([currentAssocKey isEqualToString:@"elementName"] == NO) && ([currentAssocKey isEqualToString:@"otherTagString"] == NO)) {
            [response_ appendContentString:[NSString stringWithFormat:@" %@=\"%@\"",currentAssocKey,theValue]];
        }
    }

    [response_ appendContentString:@">"];
    [element appendToResponse:response_ inContext:context_];
	[response_ appendContentString:[NSString stringWithFormat:@"</%@>",tag]];
};

//--------------------------------------------------------------------

-(GSWElement*)invokeActionForRequest:(GSWRequest*)request_
						  inContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------

-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//-------------------------------------------------------------------- 

@end

