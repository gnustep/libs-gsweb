/** GSWDirectAction.h - <title>GSWeb: Class GSWDirectAction</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
   
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

#ifndef _GSWDirectAction_h__
	#define _GSWDirectAction_h__


//====================================================================
@interface GSWDirectAction : GSWAction
{
};
-(id)initWithRequest:(GSWRequest*)aRequest;
-(id <GSWActionResults>)performActionNamed:(NSString*)actionName;
-(id)defaultAction;
-(NSString*)sessionIDForRequest:(GSWRequest*)aRequest;
@end

//====================================================================
@interface GSWDirectAction (GSWTakeValuesConvenience)
-(NSArray*)additionalRequestPathArray;
-(void)takeFormValueArraysForKeyArray:(NSArray*)keys;
-(void)takeFormValuesForKeyArray:(NSArray*)keys;
-(void)takeFormValueArraysForKeys:(NSString*)firstKey,...;
-(void)takeFormValuesForKeys:(NSString*)firstKey,...;
@end

#endif //_GSWDirectAction_h__

