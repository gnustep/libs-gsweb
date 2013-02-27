/** GSWApplication+Defaults.h - <title>GSWeb: GSWApplication+Defaults.h</title>

   Copyright (C) 2013 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de>
   
   $Revision: 30698 $
   $Date: 2010-06-13 21:19:25 -0700 (So, 13 Jun 2010) $

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

// $Id: GSWToggle.h 30698 2010-06-14 04:19:25Z dwetzel $

#ifndef _GSWApplication_Defaults_h__
	#define _GSWApplication_Defaults_h__


@interface GSWApplication (GSWApplicationDefaults)

+(void)_initUserDefaultsKeys;
+(void)_initRegistrationDomainDefaults;
-(void)_initAdaptorsWithUserDefaults:(NSUserDefaults*)userDefault;

-(NSDictionary*)_argsDictionaryWithUserDefaults:(NSUserDefaults*)userDefault;

-(void)setResponseClassName:(NSString*)className;

-(NSString*)responseClassName;

-(void)setRequestClassName:(NSString*)className;
-(NSString*)requestClassName;

-(void)setContextClassName:(NSString*)className;
-(NSString*)contextClassName;


@end

#endif //_GSWApplication_Defaults_h__

