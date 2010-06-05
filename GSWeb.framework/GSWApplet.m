/** GSWApplet.m - <title>GSWeb: Class GSWApplet</title>

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
#include <GNUstepBase/NSObject+GNUstepBase.h>

//====================================================================
@implementation GSWApplet

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  [super dealloc];
}

//--------------------------------------------------------------------

-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping
{
  [self notImplemented: _cmd];	//TODOFN
  return NO;
};

//--------------------------------------------------------------------

-(id)	  paramWithName:(id)name
                  value:(id)value
                 target:(id)target
                    key:(id)key
 treatNilValueAsGSWNull:(BOOL)treatNilValueAsGSWNull
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------

-(NSString*)elementName
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)contextID
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)setContextID:(id)contextID
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------

-(id)url
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)setURL:(id)url
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(NSString*)elementID
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)setElementID:(NSString*)elementID
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
@end

//====================================================================
@implementation GSWApplet (GSWAppletA)
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------

-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------

-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext
{
  [self notImplemented: _cmd];	//TODOFN
};

//-------------------------------------------------------------------- 
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(void)_computeAgcArchiveStringInContext:(GSWContext*)aContext
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(id)_agcArchiveURLsListInContext:(GSWContext*)aContext
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)_archiveURLsListInContext:(GSWContext*)aContext
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)_agcArchiveNamesListInContext:(GSWContext*)aContext
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)_archiveNamesListInContext:(GSWContext*)aContext
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)_deallocForComponent:(id)aComponent
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(void)_awakeForComponent:(id)aComponent
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------

+(BOOL)hasGSWebObjectsAssociations
{
  return YES;
};

//--------------------------------------------------------------------
@end

