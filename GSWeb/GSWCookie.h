/** GSWCookie.h - <title>GSWeb: Class GSWResponse</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 1999
   
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

#ifndef _GSWCookie_h__
	#define _GSWCookie_h__


//====================================================================
@interface GSWCookie : NSObject
{
@private
  NSString* _name;
  NSString* _value;
  NSString* _domain;
  NSString* _path;
  NSDate* _expires;
  BOOL _isSecure;
};

+(GSWCookie*)cookieWithName:(NSString*)aName
                      value:(NSString*)aValue;
+(GSWCookie*)cookieWithName:(NSString*)aName
                      value:(NSString*)aValue
                       path:(NSString*)aPath
                     domain:(NSString*)aDomain
                    expires:(NSDate*)anExpireDate
                   isSecure:(BOOL)isSecureFlag;
-(id)initWithName:(NSString*)aName
            value:(NSString*)aValue
             path:(NSString*)aPath
           domain:(NSString*)aDomain
          expires:(NSDate*)anExpireDate
         isSecure:(BOOL)isSecureFlag;
-(NSString*)description;
-(NSString*)name;
-(void)setName:(NSString*)aName;
-(NSString*)value;
-(void)setValue:(NSString*)aValue;
-(NSString*)domain;
-(void)setDomain:(NSString*)aDomain;
-(NSString*)path;
-(void)setPath:(NSString*)aPath;
-(NSDate*)expires;
-(void)setExpires:(NSDate*)anExpireDate;
-(BOOL)isSecure;
-(void)setIsSecure:(BOOL)isSecureFlag;
-(NSString*)headerString;
-(NSString*)headerKey;
-(NSString*)headerValue;
@end

#endif //_GSWCookie_h__
