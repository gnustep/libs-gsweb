/* GSWCookie.m - GSWeb: Class GSWCookie
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

static char rcsId[] = "$Id$";

#include <gsweb/GSWeb.framework/GSWeb.h>

//====================================================================
@implementation GSWCookie

//--------------------------------------------------------------------
//	cookieWithName:value:
+(GSWCookie*)cookieWithName:(NSString*)name_
					 value:(NSString*)value_
{
  return [GSWCookie cookieWithName:name_
				   value:value_
				   path:nil
				   domain:nil
				   expires:nil
				   isSecure:NO];
};

//--------------------------------------------------------------------
//	cookieWithName:value:path:domain:expires:isSecure:
+(GSWCookie*)cookieWithName:(NSString*)name_
					 value:(NSString*)value_
					  path:(NSString*)path_
					domain:(NSString*)domain_
				   expires:(NSDate*)expireDate_
				  isSecure:(BOOL)isSecure_
{
  return [[[GSWCookie alloc] initWithName:name_
							 value:value_
							 path:path_
							 domain:domain_
							 expires:expireDate_
							 isSecure:isSecure_]
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
-(id)initWithName:(NSString*)name_
			value:(NSString*)value_
			 path:(NSString*)path_
		   domain:(NSString*)domain_
		  expires:(NSDate*)expireDate_
		 isSecure:(BOOL)isSecure_
{
  LOGObjectFnStart();
  if ((self=[self init]))
	{
	  NSDebugMLLog(@"low",@"name_:%@",name_);
	  NSDebugMLLog(@"low",@"value_:%@",value_);
	  NSDebugMLLog(@"low",@"path_:%@",path_);
	  NSDebugMLLog(@"low",@"domain_:%@",domain_);
	  NSDebugMLLog(@"low",@"expireDate_:%@",expireDate_);
	  NSDebugMLLog(@"low",@"isSecure:%d",isSecure);
	  [self setName:name_];
	  [self setValue:value_];
	  [self setPath:path_];
	  [self setDomain:domain_];
	  [self setExpires:expireDate_];
	  [self setIsSecure:isSecure_];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(name);
  DESTROY(value);
  DESTROY(domain);
  DESTROY(path);
  DESTROY(expires);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"name=%@; value=%@; expires=%@; path=%@; domain=%@; %@",
				   name,
				   value,
				   [expires htmlDescription],
				   path,
				   domain,
				   (isSecure ? @"secure;" : @"")];
};

//--------------------------------------------------------------------
-(NSString*)name { return name; };
-(void)setName:(NSString*)name_ { ASSIGNCOPY(name,name_); };
-(NSString*)value { return value; };
-(void)setValue:(NSString*)value_ { ASSIGNCOPY(value,value_); };
-(NSString*)domain { return domain; };
-(void)setDomain:(NSString*)domain_ { ASSIGNCOPY(domain,domain_); };
-(NSString*)path { return path; };
-(void)setPath:(NSString*)path_ { ASSIGNCOPY(path,path_); };
-(NSDate*)expires { return expires; };
-(void)setExpires:(NSDate*)expireDate_ { ASSIGNCOPY(expires,expireDate_); };
-(BOOL)isSecure { return isSecure; };
-(void)setIsSecure:(BOOL)isSecure_ { isSecure=isSecure_; };

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
  NSString* _header=nil;
  NSString* _domainString=nil;
  NSString* _pathString=nil;
  NSDate* _expires=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"name:%@",name);
  NSDebugMLLog(@"low",@"value:%@",value);
  NSDebugMLLog(@"low",@"path:%@",path);
  NSDebugMLLog(@"low",@"domain:%@",domain);
  NSDebugMLLog(@"low",@"expires:%@",expires);
  NSDebugMLLog(@"low",@"isSecure:%d",isSecure);
  if (domain)
	_domainString=[NSString stringWithFormat:@" domain=%@;",domain];
  else
	_domainString=@"";
  if (path)
	_pathString=[NSString stringWithFormat:@" path=%@;",path];
  else
	_pathString=@"/";
  if (expires)
	_expires=expires;
  else
	_expires=[NSDate dateWithTimeIntervalSinceNow:24L*60L*60L*365L];//1 Year
  NSDebugMLLog(@"low",@"_pathString:%@",_pathString);
  NSDebugMLLog(@"low",@"_domainString:%@",_domainString);
  NSDebugMLLog(@"low",@"_expires:%@",_expires);
  _header=[NSString stringWithFormat:@"%@=%@; expires=%@;%@%@%@",
					name,
					(value ? value : @""),
					[_expires  htmlDescription],
					_pathString,
					_domainString,
					(isSecure ? @" secure;" : @"")];
  NSDebugMLLog(@"low",@"_header=%@",_header);
  LOGObjectFnStop();
  return _header;
};

@end

