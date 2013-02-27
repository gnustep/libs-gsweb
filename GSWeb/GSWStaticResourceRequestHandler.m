/** GSWStaticResourceRequestHandler.m - <title>GSWeb: Class GSWStaticResourceRequestHandler</title>

   Copyright (C) 2003 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jul 2003
   
   $Revision$
   $Date$
   $Id$

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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

//====================================================================
@implementation GSWStaticResourceRequestHandler

-(void)dealloc
{
  DESTROY(_documentRoot);
  [super dealloc];
};

//--------------------------------------------------------------------
-(GSWResponse*)handleRequest:(GSWRequest*)aRequest
{
  GSWResponse* response=nil;
  NSString* uri=nil;
  NSFileHandle* resourceFileHandle = nil;
  unsigned long resourceLength=0;
  NSString* contentType = nil;
  uri = [aRequest uri];
  if ([uri hasPrefix:@"/"])
    {
      NSMutableString* resourcePath=nil;
      GSWResourceManager* rmanager = [[GSWApplication application] resourceManager];
      NSString* documentRoot = [self _documentRoot];
      [resourcePath appendString:documentRoot];
      [resourcePath appendString:uri];
        NSError *error = nil;
        
      NS_DURING
        {
          NSDictionary* fileAttributes=[[NSFileManager defaultManager] attributesOfItemAtPath:resourcePath
                                                                                       error:&error];
          resourceLength=(unsigned long)[fileAttributes fileSize];
          
          resourceFileHandle=[NSFileHandle fileHandleForReadingAtPath:resourcePath];
          contentType = [rmanager contentTypeForResourcePath:resourcePath];
        }
      NS_HANDLER
        {
          localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                                   @"globalLock loggedlockBeforeDate");
          [localException raise];
        }
      NS_ENDHANDLER;
    }
  response = [self _generateResponseForFileHandle:resourceFileHandle
                   length:resourceLength
                   contentType:contentType];
  [[NSNotificationCenter defaultCenter]postNotificationName:@"DidHandleRequestNotification"
                                       object:response];
  [response _finalizeInContext:nil];
  return response;
};

-(GSWResponse*)_generateResponseForFileHandle:(NSFileHandle*)fileHandle
                                       length:(unsigned long)length
                                  contentType:(NSString*)contentType
{
  GSWResponse* response = [[GSWApplication application]createResponseInContext:nil];
  if (fileHandle)
    {
      if(length>0)
        [response setContentStreamFileHandle:fileHandle
                  bufferSize:4096
                  length:length];
    } 
  else
    {
      // Not found ==> 404
      [response setStatus:404];
    }
  if (contentType)
    [response setHeader:contentType
              forKey:GSWHTTPHeader_ContentType];
  
  [response setHeader:[NSString stringWithFormat:@"%lu",(unsigned long)length]
            forKey:GSWHTTPHeader_ContentLength];
  return response;
}

-(NSString*)_documentRoot
{
  if (!_documentRoot)
    {
      NSString* configFilePath=[[[GSWApplication application] resourceManager]
                                 pathForResourceNamed:@"WebServerConfig.plist"
                                 inFramework:nil];
      if (configFilePath)
        {
          NSDictionary* config=[NSDictionary dictionaryWithContentsOfFile:configFilePath];
          ASSIGN(_documentRoot,[config objectForKey:@"DocumentRoot"]);
        };
    };
  return _documentRoot;
}


@end

//====================================================================
@implementation GSWStaticResourceRequestHandler (GSWRequestHandlerClassA)

//--------------------------------------------------------------------
+(id)handler
{
  return [[GSWStaticResourceRequestHandler new] autorelease];
};

@end
