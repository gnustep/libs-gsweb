/** GSWCookie.m - <title>GSWeb: Class GSWResponse</title>

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

static char rcsId[] = "$Id$";

#include "GSWeb.h"

//====================================================================
@implementation GSWCookie

//--------------------------------------------------------------------
//	cookieWithName:value:
+(GSWCookie*)cookieWithName:(NSString*)aName
                      value:(NSString*)aValue
{
  return [GSWCookie cookieWithName:aName
                    value:aValue
                    path:nil
                    domain:nil
                    expires:nil
                    isSecure:NO];
};

//--------------------------------------------------------------------
//	cookieWithName:value:path:domain:expires:isSecure:
+(GSWCookie*)cookieWithName:(NSString*)aName
                      value:(NSString*)aValue
                       path:(NSString*)aPath
                     domain:(NSString*)aDomain
                    expires:(NSDate*)anExpireDate
                   isSecure:(BOOL)isSecureFlag
{
  return [[[GSWCookie alloc] initWithName:aName
                             value:aValue
                             path:aPath
                             domain:aDomain
                             expires:anExpireDate
                             isSecure:isSecureFlag]
           autorelease];
};

//--------------------------------------------------------------------
//init
-(id)init
{
  if ((self=[super init]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
//	initWithName:value:path:domain:expires:isSecure:
-(id)initWithName:(NSString*)aName
            value:(NSString*)aValue
             path:(NSString*)aPath
           domain:(NSString*)aDomain
          expires:(NSDate*)anExpireDate
         isSecure:(BOOL)isSecureFlag
{
  LOGObjectFnStart();
  if ((self=[self init]))
    {
      NSDebugMLLog(@"low",@"aName:%@",aName);
      NSDebugMLLog(@"low",@"aValue:%@",aValue);
      NSDebugMLLog(@"low",@"aPath:%@",aPath);
      NSDebugMLLog(@"low",@"aDomain:%@",aDomain);
      NSDebugMLLog(@"low",@"anExpireDate:%@",anExpireDate);
      NSDebugMLLog(@"low",@"isSecure:%d",isSecureFlag);
      [self setName:aName];
      [self setValue:aValue];
      [self setPath:aPath];
      [self setDomain:aDomain];
      [self setExpires:anExpireDate];
      [self setIsSecure:isSecureFlag];
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_name);
  DESTROY(_value);
  DESTROY(_domain);
  DESTROY(_path);
  DESTROY(_expires);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"name=%@; value=%@; expires=%@; path=%@; domain=%@; %@",
                   _name,
                   _value,
                   [_expires htmlDescription],
                   _path,
                   _domain,
                   (_isSecure ? @"secure;" : @"")];
};

//--------------------------------------------------------------------
-(NSString*)name { return _name; };
-(void)setName:(NSString*)aName { ASSIGNCOPY(_name,aName); };
-(NSString*)value { return _value; };
-(void)setValue:(NSString*)aValue { ASSIGNCOPY(_value,aValue); };
-(NSString*)domain { return _domain; };
-(void)setDomain:(NSString*)aDomain { ASSIGNCOPY(_domain,aDomain); };
-(NSString*)path { return _path; };
-(void)setPath:(NSString*)aPath { ASSIGNCOPY(_path,aPath); };
-(NSDate*)expires { return _expires; };
-(void)setExpires:(NSDate*)anExpireDate { ASSIGNCOPY(_expires,anExpireDate); };
-(BOOL)isSecure { return _isSecure; };
-(void)setIsSecure:(BOOL)isSecureFlag { _isSecure=isSecureFlag; };

//--------------------------------------------------------------------
-(NSString*)headerString
{
  return [NSString stringWithFormat:@"%@: %@",
                   [self headerKey],
                   [self headerValue]];
};

//--------------------------------------------------------------------
-(NSString*)headerKey
{
  return GSWHTTPHeader_SetCookie;
};

//--------------------------------------------------------------------
-(NSString*)headerValue
{
  NSString* header=nil;
  NSString* domainString=nil;
  NSString* pathString=nil;
  NSDate* expires=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"name:%@",_name);
  NSDebugMLLog(@"low",@"value:%@",_value);
  NSDebugMLLog(@"low",@"path:%@",_path);
  NSDebugMLLog(@"low",@"domain:%@",_domain);
  NSDebugMLLog(@"low",@"expires:%@",_expires);
  NSDebugMLLog(@"low",@"isSecure:%d",_isSecure);
  if (_domain)
    domainString=[NSString stringWithFormat:@" domain=%@;",_domain];
  else
    domainString=@"";
  if (_path)
    pathString=[NSString stringWithFormat:@" path=%@;",_path];
  else
    pathString=@"/";
  if (_expires)
    expires=_expires;
  else
    expires=[NSDate dateWithTimeIntervalSinceNow:24L*60L*60L*365L];//1 Year
  NSDebugMLLog(@"low",@"pathString:%@",pathString);
  NSDebugMLLog(@"low",@"domainString:%@",domainString);
  NSDebugMLLog(@"low",@"expires:%@",expires);
  header=[NSString stringWithFormat:@"%@=%@; expires=%@;%@%@%@",
                   _name,
                   (_value ? _value : @""),
                   [expires  htmlDescription],
                   pathString,
                   domainString,
                   (_isSecure ? @" secure;" : @"")];
  NSDebugMLLog(@"low",@"header=%@",header);
  LOGObjectFnStop();
  return header;
};

@end

