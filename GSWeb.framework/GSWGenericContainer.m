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

#include <gsweb/GSWeb.framework/GSWeb.h>

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
	id component = [context_ page];
//	id pageElement = [context_ pageElement];
	id tag = [[associations objectForKey:@"elementName"] valueInComponent:component];
    //NSLog(@"elmentName/tag\n%@/%@\n",[associations objectForKey:@"elementName"],tag);
    [response_ appendContentString:[NSString stringWithFormat:@"<%@",tag]];
    {
        id theList = [associations allKeys];
        int x;
        x= [theList count];
        while (x--) {
            id theKey = [theList objectAtIndex:x];
            id theValue = [[associations objectForKey:theKey] valueInComponent:component];
            if ([theKey isEqualToString:@"elementName"]) continue;
            [response_ appendContentString:[NSString stringWithFormat:@" %@=\"%@\"",theKey,theValue]];
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

