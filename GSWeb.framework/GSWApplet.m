/** GSWApplet.m - <title>GSWeb: Class GSWApplet</title>

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
@implementation GSWApplet

-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------

-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------

-(id)	  paramWithName:(id)name
                  value:(id)value
                 target:(id)target
                    key:(id)key
 treatNilValueAsGSWNull:(BOOL)treatNilValueAsGSWNull
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
-(id)contextID
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)setContextID:(id)contextID
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------

-(id)url
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)setURL:(id)url
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(NSString*)elementID
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)setElementID:(NSString*)elementID
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
@end

//====================================================================
@implementation GSWApplet (GSWAppletA)
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------

-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------

-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//-------------------------------------------------------------------- 
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)aResponse
                                      inContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_computeAgcArchiveStringInContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(id)_agcArchiveURLsListInContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)_archiveURLsListInContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)_agcArchiveNamesListInContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(id)_archiveNamesListInContext:(GSWContext*)aContext
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(void)_deallocForComponent:(id)aComponent
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)_awakeForComponent:(id)aComponent
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------

+(BOOL)hasGSWebObjectsAssociations
{
  return YES;
};

//--------------------------------------------------------------------
@end

