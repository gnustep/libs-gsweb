/** GSWDynamicURLString.h - <title>GSWeb: Class GSWDynamicURLString</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 1999
   
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

#ifndef _GSWDynamicURLString_h__
	#define _GSWDynamicURLString_h__


//====================================================================
@interface GSWDynamicURLString : NSObject <NSCoding,NSCopying/*,NSMutableString*/>
{
  NSMutableString* _url;
  NSString* _protocol;//NDFN
  NSString* _host;//NDFN
  int _port;//NDFN
  NSString* _prefix;
  NSString* _applicationName;
  NSString* _applicationNumberString;
  NSString* _requestHandlerKey;
  NSString* _queryString;
  NSString* _requestHandlerPath;
  int _applicationNumber;
  BOOL _composed;
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

-(id)initWithCoder:(NSCoder*)coder;
-(void)encodeWithCoder:(NSCoder*)coder;

-(id)copyWithZone:(NSZone*)zone;

-(NSString*)description;
-(void)forwardInvocation:(NSInvocation*)invocation;
-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector;
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
-(void)setURLRequestHandlerPath:(NSString*)aString;
-(void)setURLQueryString:(NSString*)aString;
-(void)setURLRequestHandlerKey:(NSString*)aString;
-(void)setURLApplicationNumber:(int)applicationNumber;
-(void)setURLApplicationName:(NSString*)aString;
-(void)setURLPrefix:(NSString*)aString;
-(void)setURLProtocol:(NSString*)aString;//NDFN
-(void)setURLHost:(NSString*)aString;//NDFN
-(void)setURLPortString:(NSString*)aString;//NDFN
-(void)setURLPort:(int)port_;//NDFN
@end

#endif //_GSWDynamicURLString_h__
