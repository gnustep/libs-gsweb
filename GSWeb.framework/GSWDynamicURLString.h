/* GSWDynamicURLString.h - GSWeb: Class GSWDynamicURLString
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

// $Id$

#ifndef _GSWDynamicURLString_h__
	#define _GSWDynamicURLString_h__


//====================================================================
@interface GSWDynamicURLString : NSObject <NSCoding,NSCopying,NSMutableString>
{
  NSMutableString* url;
  NSString* protocol;//NDFN
  NSString* host;//NDFN
  int port;//NDFN
  NSString* prefix;
  NSString* applicationName;
  NSString* applicationNumberString;
  NSString* requestHandlerKey;
  NSString* queryString;
  NSString* requestHandlerPath;
  int applicationNumber;
  BOOL composed;
};

-(id)init;
-(id)initWithCharactersNoCopy:(unichar*)chars
					   length:(unsigned int)length
				 freeWhenDone:(BOOL)flag;
-(id)initWithCharacters:(const unichar*)chars
				 length:(unsigned int)length;
-(id)initWithCStringNoCopy:(char*)byteString
					length:(unsigned int)length
			  freeWhenDone:(BOOL)flag;
-(id)initWithCString:(const char*)byteString
			  length:(unsigned int)length;
-(id)initWithCString:(const char*)byteString;
-(id)initWithString:(NSString*)string;
-(id)initWithFormat:(NSString*)format,...;
-(id)initWithFormat:(NSString*)format
		  arguments:(va_list)argList;
-(id)initWithData:(NSData*)data
		 encoding:(NSStringEncoding)encoding;
-(id)initWithContentsOfFile:(NSString*)path;
-(void)dealloc;

-(id)initWithCoder:(NSCoder*)coder_;
-(void)encodeWithCoder:(NSCoder*)coder_;

-(id)copyWithZone:(NSZone*)zone_;

-(NSString*)description;
-(void)forwardInvocation:(NSInvocation*)invocation_;
-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector_;
@end

//====================================================================
@interface GSWDynamicURLString (GSWDynamicURLStringParsing)
-(void)_compose;
-(void)_parse;
@end

//====================================================================
@interface GSWDynamicURLString (GSWDynamicURLStringGet)
-(NSString*)urlRequestHandlerPath;
-(NSString*)urlQueryString;
-(NSString*)urlRequestHandlerKey;
-(int)urlApplicationNumber;
-(NSString*)urlApplicationName;
-(NSString*)urlPrefix;
-(NSString*)urlProtocol;//NDFN
-(NSString*)urlHost;//NDFN
-(NSString*)urlPortString;//NDFN
-(int)urlPort;//NDFN
-(NSString*)urlProtocolHostPort;//NDFN
-(void)checkURL;
@end

//====================================================================
@interface GSWDynamicURLString (GSWDynamicURLStringSet)
-(void)setURLRequestHandlerPath:(NSString*)string_;
-(void)setURLQueryString:(NSString*)string_;
-(void)setURLRequestHandlerKey:(NSString*)string_;
-(void)setURLApplicationNumber:(int)applicationNumber_;
-(void)setURLApplicationName:(NSString*)string_;
-(void)setURLPrefix:(NSString*)string_;
-(void)setURLProtocol:(NSString*)string_;//NDFN
-(void)setURLHost:(NSString*)string_;//NDFN
-(void)setURLPortString:(NSString*)string_;//NDFN
-(void)setURLPort:(int)port_;//NDFN
@end

#endif //_GSWDynamicURLString_h__
