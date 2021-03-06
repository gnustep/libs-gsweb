/* GSWSimpleFormComponent.h - GSWeb: Class GSWSimpleFormComponent
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Sept 1999
   
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
#ifndef _GSWSimpleFormComponent_h__
	#define _GSWSimpleFormComponent_h__

//====================================================================
@interface GSWSimpleFormComponent : GSWComponent
{
  NSString* _tmpErrorMessage;
};
-(id)init;
-(void)dealloc;
-(void)awake;
-(void)sleep;
-(BOOL)synchronizesVariablesWithBindings;
-(BOOL)isErrorMessage;
-(GSWComponent*)sendAction;
-(GSWComponent*)sendFields:(id)fields
      withFieldsDscription:(NSDictionary*)fieldsDscription
                  byMailTo:(NSString*)to
                      from:(NSString*)from
               withSubject:(NSString*)subject
             messagePrefix:(NSString*)messagePrefix
             messageSuffix:(NSString*)messageSuffix
              sentPageName:(NSString*)sentPageName;
-(GSWComponent*)sendFields:(id)fields
      withFieldsDscription:(NSDictionary*)fieldsDscription
                  byMailTo:(NSString*)to
                      from:(NSString*)from
               withSubject:(NSString*)subject
             messagePrefix:(NSString*)messagePrefix
             messageSuffix:(NSString*)messageSuffix
              sentPageName:(NSString*)sentPageName;
@end


#endif //_GSWSimpleFormComponent_h__
