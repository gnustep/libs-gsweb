/* GSWDirectAction.h - GSWeb: Class GSWDirectAction
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Feb 1999
   
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

// $Id$

#ifndef _GSWDirectAction_h__
	#define _GSWDirectAction_h__


//====================================================================
@interface GSWDirectAction : NSObject
{
  @private
    GSWContext* context;
};
-(void)dealloc;
-(id)initWithRequest:(GSWRequest*)request_;
-(GSWRequest*)request;
-(GSWSession*)existingSession;
-(GSWSession*)session;
-(GSWApplication*)application;//NDFN
-(GSWComponent*)pageWithName:(NSString*)pageName_;
-(id <GSWActionResults>)performActionNamed:(NSString*)actionName_;
-(id)defaultAction;
-(id)existingSession;
-(void)_initializeRequestSessionIDInContext:(GSWContext*)context_;
@end

//====================================================================
@interface GSWDirectAction (GSWDirectActionA)
-(GSWContext*)_context;
-(GSWSession*)_session;
@end
//====================================================================
@interface GSWDirectAction (GSWTakeValuesConvenience)
-(void)takeFormValueArraysForKeyArray:(NSArray*)keys_;
-(void)takeFormValuesForKeyArray:(NSArray*)keys_;
-(void)takeFormValueArraysForKeys:(NSString*)firstKey_, ...;
-(void)takeFormValuesForKeys:(NSString*)firstKey_, ...;
@end

//====================================================================
@interface GSWDirectAction (GSWDebugging)
-(void)logWithString:(NSString*)string_;
-(void)logWithFormat:(NSString*)format_,...;
+(void)logWithFormat:(NSString*)format_,...;
-(void)_debugWithString:(NSString*)string_;
-(void)debugWithFormat:(NSString*)format_,...;
@end

#endif //_GSWDirectAction_h__
