/** GSWParam.m - <title>GSWeb: Class GSWParam</title>

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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWParam

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
           target:(id)target
              key:(NSString*)key
treatNilValueAsGSWNull:(BOOL)treatNilValueAsGSWNull
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

-(void)dealloc
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------

-(NSString*)description
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------

@end

//====================================================================
@implementation GSWParam (GSWParamA)
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
@end

//====================================================================
@implementation GSWParam (GSWParamB)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------

-(id)valueInComponent:(id)component
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
@end

//====================================================================
@implementation GSWParam (GSWParamC)
+(BOOL)escapeHTML
{
  LOGClassFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
+(BOOL)hasGSWebObjectsAssociations
{
  return YES;
};

//--------------------------------------------------------------------
@end
