/* GSWCookie.h - GSWeb: Class GSWCookie
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

#ifndef _GSWCookie_h__
	#define _GSWCookie_h__


//====================================================================
@interface GSWCookie : NSObject
{
@private
  NSString* name;
  NSString* value;
  NSString* domain;
  NSString* path;
  NSDate* expires;
  BOOL isSecure;
};

+(GSWCookie*)cookieWithName:(NSString*)name_
					 value:(NSString*)value_;
+(GSWCookie*)cookieWithName:(NSString*)name_
					 value:(NSString*)value_
					  path:(NSString*)path_
					domain:(NSString*)domain_
				   expires:(NSDate*)expireDate_
				  isSecure:(BOOL)isSecure_;
-(id)initWithName:(NSString*)name_
			value:(NSString*)value_
			 path:(NSString*)path_
		   domain:(NSString*)domain_
		  expires:(NSDate*)expireDate_
		 isSecure:(BOOL)isSecure_;
-(NSString*)description;
-(NSString*)name;
-(void)setName:(NSString*)name_;
-(NSString*)value;
-(void)setValue:(NSString*)value_;
-(NSString*)domain;
-(void)setDomain:(NSString*)domain_;
-(NSString*)path;
-(void)setPath:(NSString*)path_;
-(NSDate*)expires;
-(void)setExpires:(NSDate*)expireDate_;
-(BOOL)isSecure;
-(void)setIsSecure:(BOOL)isSecure_;
-(NSString*)headerString;
-(NSString*)headerKey;
-(NSString*)headerValue;
@end

#endif //_GSWCookie_h__
