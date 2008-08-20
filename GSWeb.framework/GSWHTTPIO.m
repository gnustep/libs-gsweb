/** GSWHTTPIO.m - GSWeb: Class GSWHTTPIO
 
 Copyright (C) 2007 Free Software Foundation, Inc.
 
 Written by:	David Wetzel <dave@turbocat.de>
 Date: 	12.11.2007
 
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
 **/

#include "GSWHTTPIO.h"
#include <Foundation/NSString.h>
#include <Foundation/NSFileHandle.h>
#include <Foundation/NSData.h>
#include <GNUstepBase/GSFileHandle.h>
#include <Foundation/NSError.h>
#include <Foundation/NSException.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/Foundation.h>

#include "GSWDefines.h"
#include "GSWConstants.h"
#include "GSWUtils.h"
#include "GSWDebug.h"

#include "GSWMessage.h"
#include "GSWResponse.h"
#include "GSWRequest.h"

#define READ_SIZE 2048

static NSString *URIResponseString = @" GNUstep Web\r\n";
static NSString *CONTENT_LENGTH = @"content-length";
static NSString *CONTENT_LENGTHCOLON = @"content-length: ";
static NSString *GET = @"GET";
static NSString *POST = @"POST";
static NSString *HEAD = @"HEAD";
static NSString *SPACE = @" ";
static NSString *HEADERSEP = @": ";
static NSString *NEWLINE = @"\r\n";
static NSString *NEWLINE2 = @"\r\n";
static NSString *HTTP11 = @"HTTP/1.1";
static NSString *CONNECTION = @"connection";
static NSString *KEEP_ALIVE = @"keep-alive";
//static NSString *CLOSE = @"close";


/* Get error information.
 */
@interface	NSError (GSCategories)
+ (NSError*) _last;
@end

@interface NSFileHandle (GSWFileHandleExtensions)
//- (void) setNonBlocking: (BOOL)flag;

- (NSData*) readDataLine;
@end

@implementation NSFileHandle (GSWFileHandleExtensions)

- (NSData*) readDataLine
{
  NSMutableData	*d;
  int		got,pos=0;
  char		buf[READ_SIZE];
  int   fileDescriptor = [(GSFileHandle*)self fileDescriptor];
  
  d = [NSMutableData dataWithCapacity: READ_SIZE];
  do {
    got = recv(fileDescriptor, &buf[pos], 1, 0);
    if (got > 0) {
      if (buf[pos] != 0xd) {           // CR
        if (buf[pos] == 0xa) {         // NL
           break;
        }
        pos++;
      }
    } else if (got < 0) {
      [NSException raise: NSFileHandleOperationException
                  format: @"unable to read from descriptor - %@",
       [NSError _last]];
    }
  } while ((got > 0) && (pos < READ_SIZE));
  
  if (pos>0) {
    [d appendBytes: buf length: pos];
  }
  return d;
}

@end


@implementation GSWHTTPIO


// PRIVATE
void _unpackHeaderLineAddToDict(NSString *line, NSMutableDictionary* headers)
{
  NSArray   * components = [line componentsSeparatedByString:HEADERSEP];
  NSString  * value      = nil;
  NSArray   * newValue   = nil;
  NSString  * key        = nil;
  NSArray   * prevValue  = nil;
  
  if ((components) && ([components count] == 2)) {
    value = [components objectAtIndex:1];
    key = [components objectAtIndex:0];
    key = [[key stringByTrimmingSpaces] lowercaseString];
    
    if ([key isEqualToString:GSWHTTPHeader_AdaptorVersion[GSWNAMES_INDEX]]
        || [key isEqualToString:GSWHTTPHeader_ServerName[GSWNAMES_INDEX]]) {
//      _requestNamingConv=GSWNAMES_INDEX;
      goto keyDone;
    }
    if ([key isEqualToString:GSWHTTPHeader_AdaptorVersion[WONAMES_INDEX]]
        || [key isEqualToString:GSWHTTPHeader_ServerName[WONAMES_INDEX]]) {
//      _requestNamingConv=WONAMES_INDEX;
      goto keyDone;
    }
    
  keyDone:
    
    prevValue=[headers objectForKey:key];
    if (prevValue) {
      newValue=[prevValue arrayByAddingObject:value];
    } else {
      newValue=[NSArray arrayWithObject:value];
    }
    
    [headers setObject: newValue
                forKey: key];
  }
  
}

//PRIVATE

void _appendMessageHeaders(GSWMessage * message,NSMutableString * headers)
{
  NSMutableDictionary * headerDict = [message headers];
  NSArray             * keyArray = nil;
  int                   i = 0;
  
  if (headerDict != nil) {
    int count = 0;
    if (![headerDict isKindOfClass:[NSMutableDictionary class]]) {
      headerDict = [[headerDict mutableCopy] autorelease];
    }
    [headerDict removeObjectForKey:CONTENT_LENGTH];
    keyArray = [headerDict allKeys];
    count = [keyArray count];

    for (; i < count; i++) {
      NSString    * currentKey = [keyArray objectAtIndex:i];
      NSArray     * currentValueArray = [headerDict objectForKey:currentKey];
      if ([currentValueArray isKindOfClass:[NSArray class]]) {
        int x = 0;
        int valueCount = [currentValueArray count];
        for (; x < valueCount; x++) {
          [headers appendString:currentKey];
          [headers appendString:HEADERSEP];
          [headers appendString:[currentValueArray objectAtIndex:x]];
          [headers appendString:NEWLINE];
        }
      } else {
        NSString * myStrValue = (NSString*) currentValueArray;
        [headers appendString:currentKey];
        [headers appendString:HEADERSEP];
        [headers appendString:myStrValue];
        [headers appendString:NEWLINE];        
      }
    }
    
  }
}

//PRIVATE
void _sendMessage(GSWMessage * message, NSFileHandle* fh, NSString * httpVersion, GSWRequest * request, NSMutableString * headers)
{
  int  contentLength = 0;
  BOOL keepAlive = NO;
  BOOL requestIsHead = NO;
  
  if (message) {
    contentLength = [message _contentLength];
  }
  
  if (request) {
    NSString * connectionValue = [request headerForKey:CONNECTION];
    if (connectionValue) {
      keepAlive = [connectionValue isEqualToString:KEEP_ALIVE];
    }
    requestIsHead = [[request method] isEqualToString:HEAD];
  }

  _appendMessageHeaders(message,headers);
 
  if ([httpVersion isEqualToString:HTTP11]) {
    if (keepAlive == NO) {
      [headers appendString:@"connection: close\r\n"];        
    } else {
      [headers appendString:@"connection: keep-alive\r\n"];        
    }
  }

  if (contentLength > 0) {
    [headers appendString:CONTENT_LENGTHCOLON];        
    [headers appendString:[NSString stringWithFormat:@"%d\r\n", contentLength]];        
  }
  [headers appendString:NEWLINE2];        

  [fh writeData: [headers dataUsingEncoding:NSISOLatin1StringEncoding
                       allowLossyConversion:YES]];
  
  if ((requestIsHead == NO) && (contentLength > 0)) {
    [fh writeData: [message content]];    
  }
}


+ (NSDictionary*) readHeadersFromHandle:(NSFileHandle*) fh
{
  NSData                *currentLineData = nil;
  unsigned int          length = 0;
  NSMutableDictionary   *headers   = [NSMutableDictionary dictionary];
  NSString * tmpString = nil;
  
  NS_DURING {
    while (YES) {
        currentLineData = [fh readDataLine];
        length = [currentLineData length];
        if (length == 0) {
          break;
        }
        tmpString=[[NSString alloc] initWithData: currentLineData
                                        encoding:NSASCIIStringEncoding];
        
        _unpackHeaderLineAddToDict(tmpString,headers);
  
        [tmpString release]; tmpString = nil;      
    }
  } NS_HANDLER {
    NSLog(@"%s -- %@",__PRETTY_FUNCTION__, localException);
    if (tmpString != nil) {
      [tmpString release]; tmpString = nil;
    }
    headers = nil;
  } NS_ENDHANDLER;
  
  return headers;
}

// GET /infotext.html HTTP/1.1
// Host: www.example.net
+ (NSArray*) readRequestLineFromHandle:(NSFileHandle*) fh
{
  NSString * tmpString = nil;
  NSArray  * components = nil;
  NSData   * currentLineData = nil;
  int        length = 0;

  NS_DURING {
    currentLineData = [fh readDataLine];
    length = [currentLineData length];

    if (length > 0) {
      tmpString=[[NSString alloc] initWithData: currentLineData
                                      encoding:NSASCIIStringEncoding];
      
      components = [tmpString componentsSeparatedByString:@" "];
  
      [tmpString release]; tmpString = nil;
    }
  } NS_HANDLER {
    NSLog(@"%s -- %@",__PRETTY_FUNCTION__, localException);
    if (tmpString != nil) {
      [tmpString release]; tmpString = nil;
    }
    components = nil;
  } NS_ENDHANDLER;
  return components;
}

+ (NSData*) readContentFromFromHandle: fh 
                               method: (NSString *) method
                               length: (int) length
{
  NSData* data = nil;
  
  if ((([method isEqualToString:GET]) || ([method isEqualToString:HEAD])) || 
    ([method isEqualToString:POST] == NO || (length <1))) {
    return nil;
  }

  data = [fh readDataOfLength: length];

  return data;
}



+ (GSWRequest*) readRequestFromFromHandle:(NSFileHandle*) fh
{
  NSDictionary  * headers;
  NSArray       * requestArray;
  int             contentLength = 0;
  NSArray       * tmpValue = nil;
  NSString      * method = nil;
  NSData        * contentData = nil;
  GSWRequest    * request = nil;

  [(GSFileHandle*) fh setNonBlocking: NO];

  requestArray = [self readRequestLineFromHandle:fh];
  if ((!requestArray) || ([requestArray count] <3)) { 
    return nil; 
  }
  
  headers = [self readHeadersFromHandle:fh];
  if (!headers) { 
    return nil; 
  }

  method = [requestArray objectAtIndex:0];

  if ((tmpValue = [headers objectForKey:CONTENT_LENGTH]) && ([tmpValue count])) {
    NSString      * tmpString = [tmpValue objectAtIndex:0];
    
    contentLength = [tmpString intValue];
    contentData = [self readContentFromFromHandle: fh 
                                           method: [requestArray objectAtIndex:0] 
                                           length: contentLength];
  }

  request = [[GSWRequest alloc] initWithMethod:method
                                           uri:[requestArray objectAtIndex:1]
                                   httpVersion:[requestArray objectAtIndex:2]
                                       headers:headers
                                       content:contentData
                                      userInfo:nil];

  return [request autorelease];
}

+ (void) sendResponse:(GSWResponse*) response
             toHandle:(NSFileHandle*) fh
              request:(GSWRequest*) request
{
  NSString        * httpVersion = [response httpVersion];
  NSMutableString * bufferStr = [NSMutableString string];
  
  [bufferStr appendString:httpVersion];
  [bufferStr appendString:SPACE];
  [bufferStr appendString:GSWIntToNSString([response status])];
  [bufferStr appendString:URIResponseString];

  _sendMessage(response, fh, httpVersion, request, bufferStr);
  
}
      

@end
