/* GSWDynamicURLString.m - GSWeb: Class GSWDynamicURLString
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Mar 1999
   
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
@implementation GSWDynamicURLString

//--------------------------------------------------------------------
-(id)init
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  url=[NSMutableString new];
	  NSDebugMLLog(@"low",@"url class=%@",[url class]);
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithCharactersNoCopy:(unichar*)chars
					   length:(unsigned int)length
				 freeWhenDone:(BOOL)flag
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  url=[[NSMutableString alloc]initWithCharactersNoCopy:chars
								  length:length
								  freeWhenDone:flag];
	  if (chars)
		[self _parse];
	};
  LOGObjectFnStop();
  return self;
};


//--------------------------------------------------------------------
-(id)initWithCharacters:(const unichar*)chars
				 length:(unsigned int)length
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  url=[[NSMutableString alloc]initWithCharacters:chars
								  length:length];
	  if (chars)
		[self _parse];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithCStringNoCopy:(char*)byteString
					length:(unsigned int)length
			  freeWhenDone:(BOOL)flag
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  url=[[NSMutableString alloc]initWithCStringNoCopy:byteString
						   length:length
						   freeWhenDone:flag];
	  if (byteString)
		[self _parse];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithCString:(const char*)byteString
			  length:(unsigned int)length;
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  url=[[NSMutableString alloc]initWithCString:byteString
						   length:length];
	  NSDebugMLLog(@"low",@"url=%@",url);
	  NSDebugMLLog(@"low",@"url class=%@",[url class]);
	  if (byteString)
		[self _parse];
	  NSDebugMLLog(@"low",@"url=%@",url);
	  NSDebugMLLog(@"low",@"url class=%@",[url class]);
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithCString:(const char*)byteString;
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  NSDebugMLLog(@"low",@"byteString=%s",byteString);
	  url=[[NSMutableString alloc]initWithCString:byteString];
	  if (byteString)
		[self _parse];
	  NSDebugMLLog(@"low",@"url=%@",url);
	  NSDebugMLLog(@"low",@"url class=%@",[url class]);
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithString:(NSString*)string
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  url=[[NSMutableString alloc]initWithString:string];
	  if (string)
		[self _parse];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithFormat:(NSString*)format,...
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  va_list ap;
	  va_start(ap,format);
	  url=[[NSMutableString alloc]initWithFormat:format
						   arguments:ap];
	  va_end(ap);
	  [self _parse];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithFormat:(NSString*)format
		  arguments:(va_list)argList
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  url=[[NSMutableString alloc]initWithFormat:format
						   arguments:argList];
	  [self _parse];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithData:(NSData*)data
		 encoding:(NSStringEncoding)encoding
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  url=[[NSMutableString alloc]initWithData:data
						   encoding:encoding];
	  if (data)
		[self _parse];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithContentsOfFile:(NSString*)path
{
  //OK
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	  url=[[NSMutableString alloc]initWithContentsOfFile:path];
	  [self _parse];
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(url);
  DESTROY(prefix);
  DESTROY(applicationName);
  DESTROY(applicationNumberString);
  DESTROY(requestHandlerKey);
  DESTROY(queryString);
  DESTROY(requestHandlerPath);
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*)coder_
{
  if ((self = [super initWithCoder:coder_]))
	{
	  [coder_ decodeValueOfObjCType:@encode(id)
			  at:&url];
	  composed=YES;
	  [self _parse];
	};
  return self;
};

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder_
{
  [super encodeWithCoder: coder_];
  [self _compose];
  [coder_ encodeObject:url];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone_
{
  GSWDynamicURLString* clone = nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"url class=%@",[url class]);
  clone=[[isa allocWithZone:zone_] init];
  if (clone)
	{
	  DESTROY(clone->url);
	  clone->url=[url mutableCopyWithZone:zone_];
	  NSDebugMLLog(@"low",@"clone->url class=%@",[clone->url class]);
	  ASSIGNCOPY(clone->protocol,protocol);
	  ASSIGNCOPY(clone->host,host);
	  clone->port=port;
	  ASSIGNCOPY(clone->prefix,prefix);
	  ASSIGNCOPY(clone->applicationName,applicationName);
	  ASSIGNCOPY(clone->applicationNumberString,applicationNumberString);
	  ASSIGNCOPY(clone->requestHandlerKey,requestHandlerKey);
	  ASSIGNCOPY(clone->queryString,queryString);
	  ASSIGNCOPY(clone->requestHandlerPath,requestHandlerPath);
	  clone->applicationNumber=applicationNumber;
	  clone->composed=composed;
	};
  LOGObjectFnStop();
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  //OK
  [self _compose];
  return url;
};

//--------------------------------------------------------------------
-(void)forwardInvocation:(NSInvocation*)invocation_
{
  NSString* _urlBackup=nil;
  if (!composed)
	[self _compose];
  _urlBackup=[url copy];
  [invocation_ invokeWithTarget:url];
  if (![url isEqualToString:_urlBackup])
	[self _parse];
  [_urlBackup release];
};

//--------------------------------------------------------------------
-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector_
{
  return [url methodSignatureForSelector:selector_];
};

@end

//====================================================================
@implementation GSWDynamicURLString (GSWDynamicURLStringParsing)
-(void)_compose
{
  if (!composed)
	{
	  if (url)
		{
		  int _length=[url length];
		  NSDebugMLLog(@"low",@"url class=%@",[url class]);
		  if (_length>0)
			[url deleteCharactersInRange:NSMakeRange(0,_length)];
		}
	  else
		url=[NSMutableString new];
	  if (protocol)
		{
		  if (host)
			[url appendFormat:@"%@://",protocol];
		  else if (port)
			[url appendFormat:@"%@://localhost",protocol];
		  else if (prefix)
			[url appendFormat:@"%@:/",protocol];
		  else
			[url appendFormat:@"%@://",protocol];
		};
	  if (host)
		[url appendString:host];
	  if (port)
		[url appendFormat:@":%d",port];
	  if (prefix)
		[url appendFormat:@"%@/",prefix];
	  if (applicationName)
		[url  appendFormat:@"%@.%@/",applicationName,GSWApplicationSuffix];
	  if (applicationNumber>=0)
		[url  appendFormat:@"%d/",applicationNumber];
	  if (requestHandlerKey)
		[url  appendFormat:@"%@/",requestHandlerKey];
	  if (requestHandlerPath)
		[url  appendFormat:@"%@",requestHandlerPath];
	  if (queryString)
		[url  appendFormat:@"?%@",queryString];
	};
};

//--------------------------------------------------------------------
-(void)_parse
{
  DESTROY(prefix);
  DESTROY(applicationName);
  DESTROY(applicationNumberString);
  DESTROY(requestHandlerKey);
  DESTROY(queryString);
  DESTROY(requestHandlerPath);
  applicationNumber=-1;
  composed=NO; //??
  if (url)
	{
	  NSArray* _components=nil;
	  NSString* Left=url;
	  int index=0;
	  int tmpIndex=0;
	  NSRange protocolEndRange;
	  NSRange queryStringStartRange=[Left rangeOfString:@"?"];
	  if (queryStringStartRange.length>0)
		{
		  if (queryStringStartRange.location+1<[Left length])
			{
			  ASSIGN(queryString,[Left substringFromIndex:queryStringStartRange.location+queryStringStartRange.length]);
			};
		  Left=[Left substringToIndex:queryStringStartRange.location];
		};
	  NSDebugMLLog(@"low",@"Left [%@]",Left);
	  NSDebugMLLog(@"low",@"queryString [%@]",queryString);
	  
	  //Protocol
	  protocolEndRange=[Left rangeOfString:@"://"];
	  if (protocolEndRange.length>0)
		{
		  ASSIGN(protocol,[Left substringToIndex:protocolEndRange.location]);
		  NSDebugMLLog(@"low",@"protocol [%@]",protocol);
		  if (protocolEndRange.location+protocolEndRange.length<[Left length])
			Left=[Left substringFromIndex:protocolEndRange.location+protocolEndRange.length];
		  else
			Left=nil;
		  NSDebugMLLog(@"low",@"Left [%@]",Left);
		  //Host
		  if ([Left length]>0)
			{
			  NSRange hostEndRangePort=[Left rangeOfString:@":"];			  
			  if (hostEndRangePort.length>0)
				{
				  ASSIGN(host,[Left substringToIndex:hostEndRangePort.location]);
				  NSDebugMLLog(@"low",@"host [%@]",host);
				  if (hostEndRangePort.location+hostEndRangePort.length<[Left length])
					Left=[Left substringFromIndex:hostEndRangePort.location+hostEndRangePort.length];
				  else
					Left=nil;
				  NSDebugMLLog(@"low",@"Left [%@]",Left);
				  if (Left)
					{
					  NSRange portEndRange=[Left rangeOfString:@"/"];
					  if (portEndRange.length>0)
						{
						  NSString* portString=[Left substringToIndex:portEndRange.location];
						  NSDebugMLLog(@"low",@"portString [%@]",Left);
						  port=[portString intValue];
						  NSDebugMLLog(@"low",@"port [%d]",port);
						  if (portEndRange.location+portEndRange.length<[Left length])
							Left=[Left substringFromIndex:portEndRange.location+portEndRange.length-1]; //Keep the '/'
						  else
							Left=nil;
						  NSDebugMLLog(@"low",@"Left [%@]",Left);
						}
					  else
						{
						  port=[Left intValue];
						  NSDebugMLLog(@"low",@"port [%d]",port);
						  Left=nil;
						  NSDebugMLLog(@"low",@"Left [%@]",Left);
						};
					};
				}
			  else
				{
				  NSRange hostEndRangeSlash=[Left rangeOfString:@"/"];
				  if (hostEndRangeSlash.length>0)
					{
					  ASSIGN(host,[Left substringToIndex:hostEndRangeSlash.location]);
					  NSDebugMLLog(@"low",@"host [%@]",host);
					  if (hostEndRangeSlash.location+hostEndRangeSlash.length<[Left length])
						Left=[Left substringFromIndex:hostEndRangeSlash.location+hostEndRangeSlash.length-1];//Keep the '/'
					  else
						Left=nil;
					  NSDebugMLLog(@"low",@"Left [%@]",Left);
					}
				  else
					{
					  ASSIGN(host,Left);
					  NSDebugMLLog(@"low",@"host [%@]",host);
					  Left=nil;
					  NSDebugMLLog(@"low",@"Left [%@]",Left);
					};
				};
			};
		};

	  NSDebugMLLog(@"low",@"Left [%@]",Left);
	  //prefix
	  NSDebugMLLog(@"low",@"prefix: _components [%@]",_components);
	  _components=[Left componentsSeparatedByString:@"/"];
/*
	  for(tmpIndex=index;!prefix && tmpIndex<[_components count];tmpIndex++)
		{
		  if ([[_components objectAtIndex:tmpIndex]hasPrefix:GSWURLPrefix])
			{
			  ASSIGN(prefix,[[_components subarrayWithRange:NSMakeRange(index,tmpIndex-index+1)]componentsJoinedByString:@"/"]);
			  index=tmpIndex+1;
			};
		};
*/
	  for(tmpIndex=index;!prefix && tmpIndex<[_components count];tmpIndex++)
		{
		  if ([[_components objectAtIndex:tmpIndex]hasSuffix:GSWApplicationPSuffix])
			{
			  if (tmpIndex-index>1)
				{
				  ASSIGN(prefix,[[_components subarrayWithRange:NSMakeRange(index,tmpIndex-index)]componentsJoinedByString:@"/"]);
				  index=tmpIndex;//Stay on ApplicationName !
				};
			};
		};	  
	  if (!prefix)
		{
		  //TODO Erreur
		  NSDebugMLLog(@"low",@"No prefix in [%@]",url);
		}
	  else
		{
		  //applicationName
		  if (index>=[_components count])
			{
			  //TODO Erreur
			  NSDebugMLLog(@"low",@"No applicationName in [%@]",url);
			}
		  else
			{
			  NSDebugMLLog(@"low",@"applicationName: _components [%@]",[_components subarrayWithRange:NSMakeRange(index,[_components count]-index)]);
			  for(tmpIndex=index;!applicationName && tmpIndex<[_components count];tmpIndex++)
				{
				  if ([[_components objectAtIndex:tmpIndex]hasSuffix:GSWApplicationPSuffix])
					{
					  ASSIGN(applicationName,[[[_components subarrayWithRange:NSMakeRange(index,tmpIndex-index+1)]componentsJoinedByString:@"/"]stringWithoutSuffix:GSWApplicationPSuffix]);
					  index=tmpIndex+1;
					};
				};
			  if (!applicationName)
				{
				  NSString* tmp=[[_components subarrayWithRange:NSMakeRange(index,[_components count]-index)]componentsJoinedByString:@"/"];
				  if ([tmp hasSuffix:GSWApplicationPSuffix])
					tmp=[tmp stringWithoutSuffix:GSWApplicationPSuffix];
				  ASSIGN(applicationName,tmp);
				  index=[_components count];
				};

			  //Application Number
			  if (index<[_components count])
				{
				  NSDebugMLLog(@"low",@"applicationNumber: _components [%@]",
						  [_components subarrayWithRange:NSMakeRange(index,[_components count]-index)]);
				  ASSIGN(applicationNumberString,[_components objectAtIndex:index]);
				  applicationNumber=[applicationNumberString intValue];
				  index++;
				  //requestHandlerKey
				  if (index<[_components count])
					{
					  NSDebugMLLog(@"low",@"requestHandlerKey: _components [%@]",
							  [_components subarrayWithRange:NSMakeRange(index,[_components count]-index)]);
					  ASSIGN(requestHandlerKey,[_components objectAtIndex:index]);
					  index++;
					  //requestHandlerPath
					  if (index<[_components count])
						{
						  NSDebugMLLog(@"low",@"requestHandlerPath: _components [%@]",
								  [_components subarrayWithRange:NSMakeRange(index,[_components count]-index)]);
						  ASSIGN(requestHandlerPath,[[_components subarrayWithRange:NSMakeRange(index,[_components count]-index)]componentsJoinedByString:@"/"]);
						  index++;
						};
					};
				};
			};
		};
	};
  NSDebugMLLog(@"low",@"url=%@",url);
  NSDebugMLLog(@"low",@"prefix=%@",prefix);
  NSDebugMLLog(@"low",@"applicationName=%@",applicationName);
  NSDebugMLLog(@"low",@"applicationNumberString=%@",applicationNumberString);
  NSDebugMLLog(@"low",@"requestHandlerKey=%@",requestHandlerKey);
  NSDebugMLLog(@"low",@"queryString=%@",queryString);
  NSDebugMLLog(@"low",@"requestHandlerPath=%@",requestHandlerPath);
};

@end

//====================================================================
@implementation GSWDynamicURLString (GSWDynamicURLStringGetGet)
/*
//--------------------------------------------------------------------
-(NSArray*)urlRequestHandlerPath
{
  NSArray* _path=[urlrequestHandlerPath componentsSeparatedByString:@"/"];
  return _path;
};
*/
//--------------------------------------------------------------------
-(NSString*)urlRequestHandlerPath
{
  return requestHandlerPath;
};

//--------------------------------------------------------------------
-(NSString*)urlQueryString
{
  return queryString;
};

//--------------------------------------------------------------------
-(NSString*)urlRequestHandlerKey
{
  return requestHandlerKey;
};

//--------------------------------------------------------------------
-(int)urlApplicationNumber
{
  return applicationNumber;
};

//--------------------------------------------------------------------
-(NSString*)urlApplicationName
{
  return applicationName;
};

//--------------------------------------------------------------------
-(NSString*)urlPrefix
{
  return prefix;
};

//--------------------------------------------------------------------
-(void)checkURL
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlProtocol
{
  return protocol;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlHost
{
  return host;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlPortString
{
  return [NSString stringWithFormat:@"%d",port];
};

//--------------------------------------------------------------------
//NDFN
-(int)urlPort
{
  return port;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlProtocolHostPort
{
  NSMutableString* _url=[NSMutableString string];
  if (protocol)
	{
	  if (host)
		[_url appendFormat:@"%@://",protocol];
	  else if (port)
		[_url appendFormat:@"%@://localhost",protocol];
	  else
		[_url appendFormat:@"%@://",protocol];
	};
  if (host)
	[_url appendString:host];
  if (port)
	[_url appendFormat:@":%d",port];
  return [NSString stringWithString:_url];
};

@end

//====================================================================
@implementation GSWDynamicURLString (GSWDynamicURLStringSet)
-(void)setURLRequestHandlerPath:(NSString*)string_
{
  LOGObjectFnStart();
  ASSIGN(requestHandlerPath,string_);
  composed=NO;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)setURLQueryString:(NSString*)string_
{
  LOGObjectFnStart();
  ASSIGN(queryString,string_);
  composed=NO;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)setURLRequestHandlerKey:(NSString*)string_
{
  LOGObjectFnStart();
  ASSIGN(requestHandlerKey,string_);
  composed=NO;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)setURLApplicationNumber:(int)applicationNumber_
{
  LOGObjectFnStart();
  applicationNumber=applicationNumber_;
  composed=NO;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)setURLApplicationName:(NSString*)string_
{
  LOGObjectFnStart();
  ASSIGN(applicationName,string_);
  composed=NO;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)setURLPrefix:(NSString*)string_
{
  LOGObjectFnStart();
  ASSIGN(prefix,string_);
  composed=NO;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)setURLProtocol:(NSString*)string_
{
  LOGObjectFnStart();
  ASSIGN(protocol,string_);
  composed=NO;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)setURLHost:(NSString*)string_
{
  LOGObjectFnStart();
  ASSIGN(host,string_);
  composed=NO;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)setURLPortString:(NSString*)string_
{
  LOGObjectFnStart();
  port=[string_ intValue];
  composed=NO;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//NDFN
-(void)setURLPort:(int)port_
{
  LOGObjectFnStart();
  port=port_;
  composed=NO;
  LOGObjectFnStop();
};

@end


