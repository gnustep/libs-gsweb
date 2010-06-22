/** GSWDynamicURLString.m - <title>GSWeb: Class GSWDynamicURLString</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"
#include <GNUstepBase/NSObject+GNUstepBase.h>
#include <GNUstepBase/NSString+GNUstepBase.h>

static SEL appendStringSel = NULL;

//====================================================================
@implementation GSWDynamicURLString

+ (void) initialize
{
  if (self == [GSWDynamicURLString class])
  {
    appendStringSel = @selector(appendString:);
  }
}

+ (id) string
{
  return [[[self alloc] init] autorelease];
}

+ (id)stringWithString:(NSString *)aString
{
  return [[[self alloc] initWithString:aString] autorelease];
}

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
  {
    _url=[NSMutableString new];
  }
  
  return self;
}

//--------------------------------------------------------------------
-(id)initWithCharactersNoCopy:(unichar*)chars
                       length:(NSUInteger)length
                 freeWhenDone:(BOOL)flag
{
  _url=[(NSMutableString*) [NSMutableString alloc] initWithCharactersNoCopy:chars
                                                                     length:length
                                                               freeWhenDone:flag];
  if (chars) {
    [self _parse];
  }
  return self;
}


//--------------------------------------------------------------------
-(id)initWithCharacters:(const unichar*)chars
                 length:(NSUInteger)length
{
  _url = [(NSMutableString*)[NSMutableString alloc] initWithCharacters:chars
                                                                length:length];
  if (chars) {
    [self _parse];
  }
  return self;
}

//--------------------------------------------------------------------
-(id)initWithCStringNoCopy:(char*)byteString
                    length:(NSUInteger)length
              freeWhenDone:(BOOL)flag
{
  _url = [(NSMutableString*) [NSMutableString alloc] initWithCStringNoCopy:byteString
                                                                    length:length
                                                              freeWhenDone:flag];
  if (byteString) {
    [self _parse];
  }
  return self;
}

//--------------------------------------------------------------------
-(id)initWithCString:(const char*)byteString
              length:(NSUInteger)length;
{
  _url = [(NSMutableString*) [NSMutableString alloc] initWithCString:byteString
                                                              length:length];
  if (byteString) {
    [self _parse];
  }
  
  return self;
}

//--------------------------------------------------------------------
-(id)initWithCString:(const char*)byteString;
{
  _url = [[NSMutableString alloc] initWithCString:byteString];
  if (byteString) {
    [self _parse];
  }
  
  return self;
}

//--------------------------------------------------------------------
-(id)initWithString:(NSString*)string
{
  _url = [[NSMutableString alloc] initWithString:string];
  if (string) {
    [self _parse];
  }
  return self;
}

//--------------------------------------------------------------------
-(id)initWithFormat:(NSString*)format,...
{
  va_list ap;
  va_start(ap,format);
  _url = [[NSMutableString alloc] initWithFormat:format
                                       arguments:ap];
  va_end(ap);
  [self _parse];
  
  return self;
}

//--------------------------------------------------------------------
-(id)initWithFormat:(NSString*)format
          arguments:(va_list)argList
{
  _url = [[NSMutableString alloc] initWithFormat:format
                                       arguments:argList];
  [self _parse];
  
  return self;
}

//--------------------------------------------------------------------
-(id)initWithData:(NSData*)data
         encoding:(NSStringEncoding)encoding
{
  _url = [[NSMutableString alloc] initWithData:data
                                      encoding:encoding];
  if (data) {
    [self _parse];
  }
  return self;
}

//--------------------------------------------------------------------
-(id)initWithContentsOfFile:(NSString*)path
{
  _url=[[NSMutableString alloc]initWithContentsOfFile:path];
  [self _parse];
  
  return self;
}

//--------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*)coder
{
  [coder decodeValueOfObjCType:@encode(id)
                            at:&_url];
  _urlASImp=NULL;
  _flags.composed=YES;
  [self _parse];
  
  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_urlBeginning);
  DESTROY(_url);
  DESTROY(_prefix);
  DESTROY(_applicationName);
  DESTROY(_applicationNumberString);
  DESTROY(_requestHandlerKey);
  DESTROY(_queryString);
  DESTROY(_requestHandlerPath);

  _urlASImp=NULL;
  _urlBeginningASImp=NULL;
  _flags.composed=NO;
  
  [super dealloc];
};

//--------------------------------------------------------------------

- (NSData*) dataUsingEncoding: (NSStringEncoding)encoding allowLossyConversion: (BOOL)flag
{
  if (!_flags.composed)
  {
    [self _compose];
  }

  return [_url dataUsingEncoding: encoding allowLossyConversion: flag];
}

//--------------------------------------------------------------------
-(void)encodeWithCoder:(NSCoder*)coder
{
  [self _compose];
  [coder encodeObject:_url];
};

//--------------------------------------------------------------------
- (NSUInteger) length
{
  if (!_flags.composed)
  {
    [self _compose];
  }
  return [_url length];
};

//--------------------------------------------------------------------
- (unichar) characterAtIndex: (unsigned)index
{
  if (!_flags.composed)
  {
    [self _compose];
  }
  return [_url characterAtIndex:index];
};

//--------------------------------------------------------------------
- (void) replaceCharactersInRange: (NSRange)range 
		       withString: (NSString*)aString
{
  if (!_flags.composed)
  {
    [self _compose];
  }
  [_url replaceCharactersInRange:range
        withString:aString];
}

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWDynamicURLString* clone = nil;
  //NSDebugMLLog(@"low",@"url class=%@",[_url class]);
  clone=[[isa allocWithZone:zone] init];
  //NSDebugMLLog(@"low",@"new clone GSWDynamicURLString %p => %p",self,clone);
  if (clone)
    {
      DESTROY(_urlBeginning);
      clone->_urlBeginning=[_urlBeginning mutableCopyWithZone:zone];
      clone->_urlBeginningASImp=NULL;
      DESTROY(clone->_url);
      clone->_url=[_url mutableCopyWithZone:zone];
      clone->_urlASImp=NULL;
      //NSDebugMLLog(@"low",@"clone->_url class=%@",[clone->_url class]);
      ASSIGNCOPY(clone->_protocol,_protocol);
      ASSIGNCOPY(clone->_host,_host);
      clone->_port=_port;
      ASSIGNCOPY(clone->_prefix,_prefix);
      ASSIGNCOPY(clone->_applicationName,_applicationName);
      ASSIGNCOPY(clone->_applicationNumberString,_applicationNumberString);
      ASSIGNCOPY(clone->_requestHandlerKey,_requestHandlerKey);
      ASSIGNCOPY(clone->_queryString,_queryString);
      ASSIGNCOPY(clone->_requestHandlerPath,_requestHandlerPath);
      clone->_applicationNumber=_applicationNumber;
      clone->_flags.composed=_flags.composed;
      clone->_flags.beginningComposed=_flags.beginningComposed;
    };
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  if (!_flags.composed) {
    [self _compose];
  }
  return _url;
};

//--------------------------------------------------------------------
-(void)forwardInvocation:(NSInvocation*)invocation
{
  NSString* urlBackup=nil;
  if (!_flags.composed)
    [self _compose];
  urlBackup=[_url copy];
  [invocation invokeWithTarget:_url];
  if (![_url isEqualToString:urlBackup])
    [self _parse];
  [urlBackup release];
};

//--------------------------------------------------------------------
-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
  return [_url methodSignatureForSelector:selector];
};


-(void)_compose
{
  if (!_flags.composed)
    {
      NSString * tmpUrl = [[NSMutableString new] autorelease];

      if (!_flags.beginningComposed)
        {
          if (_urlBeginning)
            {
              int length=[_urlBeginning length];
              if (length>0)
                [_urlBeginning deleteCharactersInRange:NSMakeRange(0,length)];
            }
          else
            {
              _urlBeginning=[NSMutableString new];
              _urlBeginningASImp=NULL;
            };

          if (!_urlBeginningASImp)
            _urlBeginningASImp = [_urlBeginning methodForSelector:appendStringSel];
          if (_protocol)
            {
              if (_host)
                {
                  (*_urlBeginningASImp)(_urlBeginning,appendStringSel,_protocol);
                  (*_urlBeginningASImp)(_urlBeginning,appendStringSel,@"://");
                }
              else if (_port)
                {
                  (*_urlBeginningASImp)(_urlBeginning,appendStringSel,_protocol);
                  (*_urlBeginningASImp)(_urlBeginning,appendStringSel,@"://localhost");
                }
              else if (_prefix)
                {
                  (*_urlBeginningASImp)(_urlBeginning,appendStringSel,_protocol);
                  (*_urlBeginningASImp)(_urlBeginning,appendStringSel,@":/");
                }
              else
                {
                  (*_urlBeginningASImp)(_urlBeginning,appendStringSel,_protocol);
                  (*_urlBeginningASImp)(_urlBeginning,appendStringSel,@"://");
                }
            };
          if (_host)
            (*_urlBeginningASImp)(_urlBeginning,appendStringSel,_host);
          if (_port)
            {
              (*_urlBeginningASImp)(_urlBeginning,appendStringSel,@":");
              (*_urlBeginningASImp)(_urlBeginning,appendStringSel,GSWIntToNSString(_port));
              //[_urlBeginning appendFormat:@":%d",_port];              
            };
          if (_prefix)
            {
              (*_urlBeginningASImp)(_urlBeginning,appendStringSel,_prefix);
              (*_urlBeginningASImp)(_urlBeginning,appendStringSel,@"/");
            };
          if (_applicationName)
            {
              (*_urlBeginningASImp)(_urlBeginning,appendStringSel,_applicationName);
              (*_urlBeginningASImp)(_urlBeginning,appendStringSel,@".");
              (*_urlBeginningASImp)(_urlBeginning,appendStringSel,GSWApplicationSuffix[GSWebNamingConv]);
              (*_urlBeginningASImp)(_urlBeginning,appendStringSel,@"/");
            };
          if (_applicationNumber>=0)
            {
              (*_urlBeginningASImp)(_urlBeginning,appendStringSel,GSWIntToNSString(_applicationNumber));
              (*_urlBeginningASImp)(_urlBeginning,appendStringSel,@"/");
              //[_urlBeginning  appendFormat:@"%d/",_applicationNumber];          
            };
        };

      if (!_urlASImp)
        _urlASImp = [tmpUrl methodForSelector:appendStringSel];

      (*_urlASImp)(tmpUrl,appendStringSel,_urlBeginning);

      if (_requestHandlerKey)
        {
          (*_urlASImp)(tmpUrl,appendStringSel,_requestHandlerKey);
          (*_urlASImp)(tmpUrl,appendStringSel,@"/");
        };
      if (_requestHandlerPath)
        {
          (*_urlASImp)(tmpUrl,appendStringSel,_requestHandlerPath);
        };
      if (_queryString)
        {
          (*_urlASImp)(tmpUrl,appendStringSel,@"?");
          (*_urlASImp)(tmpUrl,appendStringSel,_queryString);
        };
        _flags.composed=YES;
      
      if (([tmpUrl length]==0)) {
        //NSLog(@"%s:cannot parse '%@'", __PRETTY_FUNCTION__, _url);
      } else {
        [_url release];
        _url = [tmpUrl retain];
      }

      //NSDebugMLLog(@"low",@"url %@ class=%@",_url,[_url class]);
    };
};

//--------------------------------------------------------------------
-(void)_parse
{
  DESTROY(_prefix);
  DESTROY(_applicationName);
  DESTROY(_applicationNumberString);
  DESTROY(_requestHandlerKey);
  DESTROY(_queryString);
  DESTROY(_requestHandlerPath);

  _applicationNumber=-1;
  _flags.composed=NO; //??
  _flags.beginningComposed=NO;

  if (_url)
    {
      NSArray* components=nil;
      int componentsCount=0;
      NSString* Left=_url;
      int index=0;
      int tmpIndex=0;
      NSRange protocolEndRange;
      NSRange queryStringStartRange=[Left rangeOfString:@"?"];
      
      if (queryStringStartRange.length>0)
        {
          if (queryStringStartRange.location+1<[Left length])
            {
              ASSIGN(_queryString,[Left substringFromIndex:queryStringStartRange.location+queryStringStartRange.length]);
            };
          Left=[Left substringToIndex:queryStringStartRange.location];
        };
      //NSDebugMLLog(@"low",@"Left [%@]",Left);
      //NSDebugMLLog(@"low",@"queryString [%@]",_queryString);
      
      //Protocol
      protocolEndRange=[Left rangeOfString:@"://"];
      if (protocolEndRange.length>0)
        {
          ASSIGN(_protocol,[Left substringToIndex:protocolEndRange.location]);
          //NSDebugMLLog(@"low",@"protocol [%@]",_protocol);
          if (protocolEndRange.location+protocolEndRange.length<[Left length])
            Left=[Left substringFromIndex:protocolEndRange.location+protocolEndRange.length];
          else
            Left=nil;
          //NSDebugMLLog(@"low",@"Left [%@]",Left);
          //Host
          if ([Left length]>0)
            {
              NSRange hostEndRangePort=[Left rangeOfString:@":"];			  
              if (hostEndRangePort.length>0)
                {
                  ASSIGN(_host,[Left substringToIndex:hostEndRangePort.location]);
                  //NSDebugMLLog(@"low",@"host [%@]",_host);
                  if (hostEndRangePort.location+hostEndRangePort.length<[Left length])
                    Left=[Left substringFromIndex:hostEndRangePort.location+hostEndRangePort.length];
                  else
                    Left=nil;
                  //NSDebugMLLog(@"low",@"Left [%@]",Left);
                  if (Left)
                    {
                      NSRange portEndRange=[Left rangeOfString:@"/"];
                      if (portEndRange.length>0)
                        {
                          NSString* portString=[Left substringToIndex:portEndRange.location];
                          //NSDebugMLLog(@"low",@"portString [%@]",Left);
                          _port=[portString intValue];
                          //NSDebugMLLog(@"low",@"port [%d]",_port);
                          if (portEndRange.location+portEndRange.length<[Left length])
                            Left=[Left substringFromIndex:portEndRange.location+portEndRange.length-1]; //Keep the '/'
                          else
                            Left=nil;
                          //NSDebugMLLog(@"low",@"Left [%@]",Left);
                        }
                      else
                        {
                          _port=[Left intValue];
                          //NSDebugMLLog(@"low",@"port [%d]",_port);
                          Left=nil;
                          //NSDebugMLLog(@"low",@"Left [%@]",Left);
                        };
                    };
                }
              else
                {
                  NSRange hostEndRangeSlash=[Left rangeOfString:@"/"];
                  if (hostEndRangeSlash.length>0)
                    {
                      ASSIGN(_host,[Left substringToIndex:hostEndRangeSlash.location]);
                      //NSDebugMLLog(@"low",@"host [%@]",_host);
                      if (hostEndRangeSlash.location+hostEndRangeSlash.length<[Left length])
                      {                        
                        Left=[Left substringFromIndex:hostEndRangeSlash.location+hostEndRangeSlash.length-1];//Keep the '/'
                      } else
                        Left=nil;
                      //NSDebugMLLog(@"low",@"Left [%@]",Left);
                    }
                  else
                    {
                      ASSIGN(_host,Left);
                      //NSDebugMLLog(@"low",@"host [%@]",_host);
                      Left=nil;
                      //NSDebugMLLog(@"low",@"Left [%@]",Left);
                    };
                };
            };
        };
      
      //NSDebugMLLog(@"low",@"Left [%@]",Left);
      //prefix
      //NSDebugMLLog(@"low",@"prefix: components [%@]",components);
      components=[Left componentsSeparatedByString:@"/"];
      componentsCount=[components count];
      for(tmpIndex=index;!_prefix && tmpIndex<componentsCount;tmpIndex++)
        {
          NSString* tmp=[components objectAtIndex:tmpIndex];
          if ([tmp hasSuffix:GSWApplicationPSuffix[GSWNAMES_INDEX]]
              || [tmp hasSuffix:GSWApplicationPSuffix[WONAMES_INDEX]])
            {
              if (tmpIndex-index>1)
                {
                  ASSIGN(_prefix,[[components subarrayWithRange:NSMakeRange(index,tmpIndex-index)]componentsJoinedByString:@"/"]);
                  index=tmpIndex;//Stay on ApplicationName !
                };
            };
        };	  
      if (!_prefix)
        {
          //TODO Erreur
          //NSDebugMLLog(@"low",@"No prefix in [%@]",_url);
        }
      else
        {
          //applicationName
          if (index>=componentsCount)
            {
              //TODO Erreur
              //NSDebugMLLog(@"low",@"No applicationName in [%@]",_url);
            }
          else
            {
              /*NSDebugMLLog(@"low",@"applicationName: components [%@]",
              [components subarrayWithRange:NSMakeRange(index,componentsCount-index)]);
              */
              for(tmpIndex=index;!_applicationName && tmpIndex<componentsCount;tmpIndex++)
                {
                  NSString* tmp=[components objectAtIndex:tmpIndex];
                  NSString* appSuffix=nil;
                  if ([tmp hasSuffix:GSWApplicationPSuffix[GSWNAMES_INDEX]])
                    appSuffix=GSWApplicationPSuffix[GSWNAMES_INDEX];
                  else if ([tmp hasSuffix:GSWApplicationPSuffix[WONAMES_INDEX]])
                    appSuffix=GSWApplicationPSuffix[WONAMES_INDEX];
                  if (appSuffix)
                    {
                      ASSIGN(_applicationName,[[[components subarrayWithRange:NSMakeRange(index,tmpIndex-index+1)] 
                                                 componentsJoinedByString:@"/"]
                                                stringByDeletingSuffix:appSuffix]);
                      index=tmpIndex+1;
                    };
                };
              if (!_applicationName)
                {
                  NSString* tmp=[[components subarrayWithRange:NSMakeRange(index,componentsCount-index)]
                                  componentsJoinedByString:@"/"];
                  if ([tmp hasSuffix:GSWApplicationPSuffix[GSWNAMES_INDEX]])
                    tmp=[tmp stringByDeletingSuffix:GSWApplicationPSuffix[GSWNAMES_INDEX]];
                  else if ([tmp hasSuffix:GSWApplicationPSuffix[WONAMES_INDEX]])
                    tmp=[tmp stringByDeletingSuffix:GSWApplicationPSuffix[WONAMES_INDEX]];
                  ASSIGN(_applicationName,tmp);
                  index=componentsCount;
                };
              
              //Application Number
              if (index<componentsCount)
                {
                  /*NSDebugMLLog(@"low",@"applicationNumber: components [%@]",
                    [components subarrayWithRange:NSMakeRange(index,componentsCount-index)]);
                  */
                  ASSIGN(_applicationNumberString,[components objectAtIndex:index]);
                  _applicationNumber=[_applicationNumberString intValue];
                  index++;
                  //requestHandlerKey
                  if (index<componentsCount)
                    {
                      /*NSDebugMLLog(@"low",@"requestHandlerKey: _components [%@]",
                        [components subarrayWithRange:NSMakeRange(index,componentsCount-index)]);
                      */
                      ASSIGN(_requestHandlerKey,[components objectAtIndex:index]);
                      index++;
                      //requestHandlerPath
                      if (index<componentsCount)
                        {
                          /* NSDebugMLLog(@"low",@"requestHandlerPath: components [%@]",
                             [components subarrayWithRange:NSMakeRange(index,componentsCount-index)]);
                          */
                          ASSIGN(_requestHandlerPath,[[components subarrayWithRange:NSMakeRange(index,componentsCount-index)]componentsJoinedByString:@"/"]);
                          index++;
                        };
                    };
                };
            };
        };
    };
  //  NSLog(@"%s %d _url:'%@'",__PRETTY_FUNCTION__, __LINE__, _url);
  //  NSLog(@"%s %d _prefix:'%@'",__PRETTY_FUNCTION__, __LINE__, _prefix);
  //  NSLog(@"%s %d _applicationName:'%@'",__PRETTY_FUNCTION__, __LINE__, _applicationName);
  //  NSLog(@"%s %d _applicationNumberString:'%@'",__PRETTY_FUNCTION__, __LINE__, _applicationNumberString);
  //  NSLog(@"%s %d _requestHandlerKey:'%@'",__PRETTY_FUNCTION__, __LINE__, _requestHandlerKey);
  //  NSLog(@"%s %d _queryString:'%@'",__PRETTY_FUNCTION__, __LINE__, _queryString);
  //  NSLog(@"%s %d _requestHandlerPath:'%@'",__PRETTY_FUNCTION__, __LINE__, _requestHandlerPath);
};

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
  return _requestHandlerPath;
};

-(NSString*)requestHandlerPath
{
  return _requestHandlerPath;
};

//--------------------------------------------------------------------
-(NSString*)urlQueryString
{
  return _queryString;
}

-(NSString*)queryString
{
  return _queryString;
}

//--------------------------------------------------------------------
-(NSString*)urlRequestHandlerKey
{
  return _requestHandlerKey;
};

//--------------------------------------------------------------------
-(int)urlApplicationNumber
{
  return _applicationNumber;
};

// wo5?
- (NSString*) applicationNumber
{
  // parse? compose?
  return GSWIntToNSString(_applicationNumber);
}

- (void) setApplicationNumber: (NSString*) newNr
{
  int intVal = [newNr intValue];
  
  if (intVal != _applicationNumber) {    
    _applicationNumber = intVal;
    _flags.beginningComposed = NO;
    _flags.composed = NO;
  }
}


//--------------------------------------------------------------------
-(NSString*)urlApplicationName
{
  return _applicationName;
};

//--------------------------------------------------------------------
-(NSString*)urlPrefix
{
  return _prefix;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlProtocol
{
  return _protocol;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlHost
{
  return _host;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlPortString
{
  return GSWIntToNSString(_port);
};

//--------------------------------------------------------------------
//NDFN
-(int)urlPort
{
  return _port;
};

//--------------------------------------------------------------------
//NDFN
-(NSString*)urlProtocolHostPort
{
  NSMutableString* url=[NSMutableString string];
  IMP imp=[url methodForSelector:appendStringSel];

  if (_protocol)
    {
      if (_host)
        {
          (*imp)(url,appendStringSel,_protocol);
          (*imp)(url,appendStringSel,@"://");
        }
      else if (_port)
        {
          (*imp)(url,appendStringSel,_protocol);
          (*imp)(url,appendStringSel,@"://localhost");
        }
      else if (_prefix)
        {
          (*imp)(url,appendStringSel,_protocol);
          (*imp)(url,appendStringSel,@":/");
        }
      else
        {
          (*imp)(url,appendStringSel,_protocol);
          (*imp)(url,appendStringSel,@"://");
        }
    };
  if (_host)
    (*imp)(url,appendStringSel,_host);
  if (_port)
    {
      (*imp)(url,appendStringSel,@":");
      (*imp)(url,appendStringSel,GSWIntToNSString(_port));
    };

  return [NSString stringWithString:url];
};

// CHECKME: depricate?
-(void)setURLRequestHandlerPath:(NSString*)aString
{
  ASSIGN(_requestHandlerPath,aString);
  _flags.composed=NO;
};

-(void)setRequestHandlerPath:(NSString*)aString
{
  ASSIGN(_requestHandlerPath,aString);
  _flags.composed=NO;
}

//--------------------------------------------------------------------
// CHECKME: depricate?
-(void)setURLQueryString:(NSString*)aString
{
  ASSIGN(_queryString,aString);
  _flags.composed=NO;
};

-(void)setQueryString:(NSString*)aString
{
  ASSIGN(_queryString,aString);
  _flags.composed=NO;
}

//--------------------------------------------------------------------
// CHECKME: rename to setRequestHandlerKey: ?? -- dw

-(void)setURLRequestHandlerKey:(NSString*)aString
{
  ASSIGN(_requestHandlerKey,aString);
  _flags.composed=NO;
};

-(void)setRequestHandlerKey:(NSString*)aString
{
  ASSIGN(_requestHandlerKey,aString);
  _flags.composed=NO;
}

//--------------------------------------------------------------------
-(void)setURLApplicationNumber:(int)applicationNumber
{
  _applicationNumber=applicationNumber;
  _flags.beginningComposed=NO;
  _flags.composed=NO;
};

//--------------------------------------------------------------------
-(void)setURLApplicationName:(NSString*)aString
{
  if (_applicationName==aString) {
    return;
  }

  ASSIGN(_applicationName,aString);
  _flags.beginningComposed=NO;
  _flags.composed=NO;
};

//--------------------------------------------------------------------
-(void)setURLPrefix:(NSString*)aString
{
  if (_prefix==aString) {
    return;
  }

  ASSIGN(_prefix,aString);
  _flags.beginningComposed=NO;
  _flags.composed=NO;
};

//--------------------------------------------------------------------
//NDFN
-(void)setURLProtocol:(NSString*)aString
{
  if (_protocol==aString) {
    return;
  }

  ASSIGN(_protocol,aString);
  _flags.beginningComposed=NO;
  _flags.composed=NO;
};

//--------------------------------------------------------------------
//NDFN
-(void)setURLHost:(NSString*)aString
{
  if (_host==aString) {
    return;
  }

  ASSIGN(_host,aString);
  _flags.beginningComposed=NO;
  _flags.composed=NO;
};

//--------------------------------------------------------------------
//NDFN
-(void)setURLPortString:(NSString*)aString
{
  int myport = [aString intValue];

  if (_port==myport) {
    return;
  }
  _port=myport;
  _flags.beginningComposed=NO;
  _flags.composed=NO;
};

//--------------------------------------------------------------------
//NDFN
-(void)setURLPort:(int)port
{
  if (_port==port) {
  return;
  }
  
  _port=port;
  _flags.beginningComposed=NO;
  _flags.composed=NO;
};

@end


