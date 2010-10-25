/** GSWContext.m - <title>GSWeb: Class GSWContext</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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
#include "GSWPrivate.h"
#include <GNUstepBase/NSObject+GNUstepBase.h>

static int dontTraceComponentActionURL=0;

static SEL componentSEL=NULL;
static SEL elementIDSEL=NULL;
static SEL senderIDSEL=NULL;
static SEL contextAndElementIDSEL=NULL;
static SEL isParentSenderIDSearchOverSEL=NULL;
static SEL isSenderIDSearchOverSEL=NULL;
static Class GSWComponentClass = Nil;

// 'Standard' GSWContext class. Used to get IMPs from standardElementIDIMPs
static Class standardClass=Nil;

// List of standardClass IMPs
static GSWContextIMPs standardContextIMPs;

//====================================================================
/** Fill impsPtr structure with IMPs for context **/
void GetGSWContextIMPs(GSWContextIMPs* impsPtr,GSWContext* context)
{
  if ([context class]==standardClass)
    {
      memcpy(impsPtr,&standardContextIMPs,sizeof(GSWContextIMPs));
    }
  else
    {
      memset(impsPtr,0,sizeof(GSWContextIMPs));

      impsPtr->_incrementLastElementIDComponentIMP = 
        [context methodForSelector:incrementLastElementIDComponentSEL];

      impsPtr->_appendElementIDComponentIMP 
        = [context methodForSelector:appendElementIDComponentSEL];

      impsPtr->_appendZeroElementIDComponentIMP = 
        [context methodForSelector:appendZeroElementIDComponentSEL];

      impsPtr->_deleteAllElementIDComponentsIMP = 
        [context methodForSelector:deleteAllElementIDComponentsSEL];

      impsPtr->_deleteLastElementIDComponentIMP = 
        [context methodForSelector:deleteLastElementIDComponentSEL];

      impsPtr->_elementIDIMP = 
        [context methodForSelector:elementIDSEL];

      impsPtr->_componentIMP = 
        [context methodForSelector:componentSEL];

      impsPtr->_senderIDIMP = 
        [context methodForSelector:senderIDSEL];

      impsPtr->_contextAndElementIDIMP =
        [context methodForSelector:contextAndElementIDSEL];

      impsPtr->_isParentSenderIDSearchOverIMP = 
        (GSWIMP_BOOL)[context methodForSelector:isParentSenderIDSearchOverSEL];
      
      impsPtr->_isSenderIDSearchOverIMP = 
        (GSWIMP_BOOL)[context methodForSelector:isSenderIDSearchOverSEL];
    };
};

//====================================================================
/** functions to accelerate calls of frequently used GSWContext methods **/

//--------------------------------------------------------------------
void GSWContext_incrementLastElementIDComponent(GSWContext* aContext)
{
  if (aContext)
    (*(aContext->_selfIMPs._incrementLastElementIDComponentIMP))
      (aContext,incrementLastElementIDComponentSEL);
};

//--------------------------------------------------------------------
void GSWContext_appendElementIDComponent(GSWContext* aContext,NSString* component)
{
  if (aContext)
    (*(aContext->_selfIMPs._appendElementIDComponentIMP))
      (aContext,appendElementIDComponentSEL,component);
};

//--------------------------------------------------------------------
void GSWContext_appendZeroElementIDComponent(GSWContext* aContext)
{
  if (aContext)
    (*(aContext->_selfIMPs._appendZeroElementIDComponentIMP))
      (aContext,appendZeroElementIDComponentSEL);
};

//--------------------------------------------------------------------
void GSWContext_deleteAllElementIDComponents(GSWContext* aContext)
{
  if (aContext)
    (*(aContext->_selfIMPs._deleteAllElementIDComponentsIMP))
      (aContext,deleteAllElementIDComponentsSEL);
};

//--------------------------------------------------------------------
void GSWContext_deleteLastElementIDComponent(GSWContext* aContext)
{
  if (aContext)
    (*(aContext->_selfIMPs._deleteLastElementIDComponentIMP))
      (aContext,deleteLastElementIDComponentSEL);
};

//--------------------------------------------------------------------
NSString* GSWContext_elementID(GSWContext* aContext)
{
  if (aContext)
    return (*(aContext->_selfIMPs._elementIDIMP))
      (aContext,elementIDSEL);
  else
    return nil;
};

//--------------------------------------------------------------------
NSString* GSWContext_senderID(GSWContext* aContext)
{
  if (aContext)
    return (*(aContext->_selfIMPs._senderIDIMP))
      (aContext,senderIDSEL);
  else
    return nil;
};

//--------------------------------------------------------------------
NSString* GSWContext_contextAndElementID(GSWContext* aContext)
{
  if (aContext)
    return (*(aContext->_selfIMPs._contextAndElementIDIMP))
      (aContext,contextAndElementIDSEL);
  else
    return nil;
};

//--------------------------------------------------------------------
GSWComponent* GSWContext_component(GSWContext* aContext)
{
  if (aContext)
    return (GSWComponent*)(*(aContext->_selfIMPs._componentIMP))
      (aContext,componentSEL);
  else
    return nil;
};

//--------------------------------------------------------------------
GSWEB_EXPORT BOOL GSWContext_isParentSenderIDSearchOver(GSWContext* aContext)
{
  if (aContext)
    return (*(aContext->_selfIMPs._isParentSenderIDSearchOverIMP))
      (aContext,isParentSenderIDSearchOverSEL);
  else
    return NO;
}

//--------------------------------------------------------------------
GSWEB_EXPORT BOOL GSWContext_isSenderIDSearchOver(GSWContext* aContext)
{
  if (aContext)
    return (*(aContext->_selfIMPs._isSenderIDSearchOverIMP))
      (aContext,isSenderIDSearchOverSEL);
  else
    return NO;
}

@implementation NSMutableDictionary (GSWContextAdditions)

// sessionIDInQueryDictionary
- (id) sessionID
{
  id value = nil;
  
  value = [self objectForKey:[GSWApp sessionIdKey]];
  if (!value) {
    value = [self objectForKey:@"wosid"];
  }
  return value;
}

@end

@interface NSMutableDictionary (GSWContextAdditions)
- (id) sessionID;
@end

//====================================================================
@implementation GSWContext

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWContext class])
    {
      componentSEL=@selector(component);
      elementIDSEL=@selector(elementID);
      senderIDSEL=@selector(senderID);
      contextAndElementIDSEL=@selector(contextAndElementID);
      isParentSenderIDSearchOverSEL=@selector(isParentSenderIDSearchOver);
      isSenderIDSearchOverSEL=@selector(isSenderIDSearchOver);
      GSWComponentClass = [GSWComponent class];
      [self setStandardClass:[GSWContext class]];
    };
};

//--------------------------------------------------------------------
+(void)setStandardClass:(Class)aStandardClass
{
  // TODO MultiThread protection
  standardClass=aStandardClass;

  memset(&standardContextIMPs,0,sizeof(GSWContextIMPs));

  InitializeGSWElementIDSELs();

  standardContextIMPs._incrementLastElementIDComponentIMP = 
    [self instanceMethodForSelector:incrementLastElementIDComponentSEL];

  standardContextIMPs._appendElementIDComponentIMP = 
    [self instanceMethodForSelector:appendElementIDComponentSEL];

  standardContextIMPs._appendZeroElementIDComponentIMP = 
    [self instanceMethodForSelector:appendZeroElementIDComponentSEL];

  standardContextIMPs._deleteAllElementIDComponentsIMP = 
    [self instanceMethodForSelector:deleteAllElementIDComponentsSEL];

  standardContextIMPs._deleteLastElementIDComponentIMP = 
    [self instanceMethodForSelector:deleteLastElementIDComponentSEL];

  standardContextIMPs._elementIDIMP = 
    [self instanceMethodForSelector:elementIDSEL];

  standardContextIMPs._componentIMP = 
    [self instanceMethodForSelector:componentSEL];

  standardContextIMPs._senderIDIMP = 
    [self instanceMethodForSelector:senderIDSEL];

  standardContextIMPs._contextAndElementIDIMP = 
    [self instanceMethodForSelector:contextAndElementIDSEL];

  standardContextIMPs._componentIMP = 
    [self instanceMethodForSelector:componentSEL];

  standardContextIMPs._isParentSenderIDSearchOverIMP = 
    (GSWIMP_BOOL)[self instanceMethodForSelector:isParentSenderIDSearchOverSEL];

  standardContextIMPs._isSenderIDSearchOverIMP = 
    (GSWIMP_BOOL)[self instanceMethodForSelector:isSenderIDSearchOverSEL];
};

//--------------------------------------------------------------------
//	init

-(id)init 
{
  //OK
  if ((self=[super init]))
    {
      GetGSWContextIMPs(&_selfIMPs,self);
      [self _initWithContextID:(unsigned int)-1];
      _tempComponentDefinition = nil;
      _componentName = nil;
      _formSubmitted = NO;
      _inForm = NO;
      _secureMode = -2;
      _markupType = WOUndefinedMarkup;
      
      DESTROY(_resourceManager);
      _resourceManager = RETAIN([GSWApp resourceManager]);
      
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_resourceManager);
  DESTROY(_senderID);
  DESTROY(_requestSessionID);
  DESTROY(_requestContextID);
  DESTROY(_elementID);
  DESTROY(_session);
  DESTROY(_request);
  DESTROY(_response);
  DESTROY(_pageElement);
  DESTROY(_pageComponent);
  DESTROY(_currentComponent);
  DESTROY(_url);
  DESTROY(_awakePageComponents);
#ifndef NDEBUG
  DESTROY(_docStructure);
  DESTROY(_docStructureElements);
#endif
  DESTROY(_userInfo);
  DESTROY(_languages);
  DESTROY(_componentName);
  DESTROY(_tempComponentDefinition);

  [super dealloc];
}

//--------------------------------------------------------------------
-(id)initWithRequest:(GSWRequest*)aRequest
{
  if ((self=[self init]))
    {
      [self _setRequest:aRequest];
    };
  return self;
};

//--------------------------------------------------------------------
+(GSWContext*)contextWithRequest:(GSWRequest*)aRequest
{
  GSWContext* context=nil;

  context=[[[self alloc]
             initWithRequest:aRequest]
            autorelease];
            
  return context;
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWContext* clone = [[isa allocWithZone:zone] init];

  if (clone)
    {
      clone->_contextID=_contextID;
      ASSIGNCOPY(clone->_senderID,_senderID);
      ASSIGNCOPY(clone->_requestSessionID,_requestSessionID);
      ASSIGNCOPY(clone->_requestContextID,_requestContextID);

      if (_elementID) {
          ASSIGNCOPY(clone->_elementID,_elementID);
          NSAssert(clone->_elementID,@"No clone elementID");
          
          GetGSWElementIDIMPs(&clone->_elementIDIMPs,clone->_elementID);
      };

      ASSIGN(clone->_session,_session); //TODOV
      ASSIGN(clone->_request,_request); //TODOV
      ASSIGN(clone->_response,_response); //TODOV
      ASSIGN(clone->_pageElement,_pageElement);
      ASSIGN(clone->_pageComponent,_pageComponent);
      ASSIGN(clone->_currentComponent,_currentComponent);
      ASSIGNCOPY(clone->_url,_url);
      if (_awakePageComponents)
        clone->_awakePageComponents=[_awakePageComponents mutableCopy];
      if (_userInfo)
        clone->_userInfo=[_userInfo  mutableCopy];
      clone->_urlApplicationNumber=_urlApplicationNumber;
      clone->_isClientComponentRequest=_isClientComponentRequest;
      clone->_distributionEnabled=_distributionEnabled;
      clone->_pageChanged=_pageChanged;
      clone->_pageReplaced=_pageReplaced;
      clone->_generateCompleteURLs=_generateCompleteURLs;
      clone->_inForm=_inForm;
      clone->_actionInvoked=_actionInvoked;
      clone->_isMultipleSubmitForm=_isMultipleSubmitForm;
      clone->_isSessionDisabled=_isSessionDisabled;
    };
  return clone;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  //OK
  NSString* desc=nil;
  dontTraceComponentActionURL++;
  desc= [NSString stringWithFormat:
                    @"%s: %p contextID=%@ senderID=%@ elementID=%@ session=%p request=%p response=%p pageElement=%p pageComponent=%p currentComponent=%p url=%@ urlApplicationNumber=%d isClientComponentRequest=%s distributionEnabled=%s isSessionDisabled=%s pageChanged=%s pageReplaced=%s",
                  object_getClassName(self),
                  (void*)self,
                  [self contextID],
                  [self senderID],
                  [self elementID],
                  (void*)[self existingSession],
                  (void*)[self request],
                  (void*)[self response],
                  (void*)_pageElement,
                  (void*)_pageComponent,
                  (void*)_currentComponent,
                  _url,
                  _urlApplicationNumber,
                  _isClientComponentRequest ? "YES" : "NO",
                  _distributionEnabled ? "YES" : "NO",
                  _isSessionDisabled ? "YES" : "NO",
                  _pageChanged ? "YES" : "NO",
                  _pageReplaced ? "YES" : "NO"];
  dontTraceComponentActionURL--;
  return desc;
};

- (BOOL) _sessionIDInURL
{
  GSWRequest * aReq = [self request];
  
  return ((aReq != nil) && ([aReq stringFormValueForKey:[GSWApp sessionIdKey]] != nil));
}


//--------------------------------------------------------------------
-(BOOL)_isRefusingThisRequest
{
  return _isRefusingThisRequest;
}

//--------------------------------------------------------------------
-(void)_setIsRefusingThisRequest:(BOOL)yn
{
  _isRefusingThisRequest = yn;
}

//--------------------------------------------------------------------

// wo4
-(void)setInForm:(BOOL)flag
{
  _inForm=flag;
}

//--------------------------------------------------------------------
// wo4
-(BOOL)isInForm
{
  return _inForm;
}

//--------------------------------------------------------------------
-(void)setInEnabledForm:(BOOL)flag
{
  _isInEnabledForm=flag;
};

//--------------------------------------------------------------------
-(BOOL)isInEnabledForm
{
  return _isInEnabledForm;
}

- (GSWDynamicURLString*) _url
{
  if(_url == nil) {
    _url = [GSWDynamicURLString new];
  }
  
  return _url;
}

//--------------------------------------------------------------------
// Create the elementID and set IMPs
-(void)_createElementID
{
  if (!_elementID)
    _elementID=[GSWElementID new];

  GetGSWElementIDIMPs(&_elementIDIMPs,_elementID);
};

//--------------------------------------------------------------------
//	elementID
-(NSString*)elementID 
{  
  if (_elementID)
    {
      NSAssert(_elementIDIMPs._elementIDStringIMP,
               @"No _elementIDIMPs._elementIDStringIMP");
      return (*_elementIDIMPs._elementIDStringIMP)(_elementID,elementIDStringSEL);
    }
  else
    return nil;
};

//--------------------------------------------------------------------
//	returns contextID.ElementID
-(NSString*)contextAndElementID 
{
  static NSString* preBuiltNumPlusDot[] = {
    @"0.", @"1.", @"2.", @"3.", @"4.", @"5.", @"6.", @"7.", @"8.", @"9.", 
    @"10.", @"11.", @"12.", @"13.", @"14.", @"15.", @"16.", @"17.", @"18.", @"19.", 
    @"20.", @"21.", @"22.", @"23.", @"24.", @"25.", @"26.", @"27.", @"28.", @"29.", 
    @"30.", @"31.", @"32.", @"33.", @"34.", @"35.", @"36.", @"37.", @"38.", @"39.", 
    @"40.", @"41.", @"42.", @"43.", @"44.", @"45.", @"46.", @"47.", @"48.", @"49.", 
    @"50.", @"51.", @"52.", @"53.", @"54.", @"55.", @"56.", @"57.", @"58.", @"59.", 
    @"60.", @"61.", @"62.", @"63.", @"64.", @"65.", @"66.", @"67.", @"68.", @"69." };
  static int preBuiltNumPlusDotCount = sizeof(preBuiltNumPlusDot)/sizeof(NSString*);
  if (_contextID>=0 && _contextID<preBuiltNumPlusDotCount)
    {
      if (_elementID)
        return [preBuiltNumPlusDot[_contextID] stringByAppendingString:
                                    (*_elementIDIMPs._elementIDStringIMP)(_elementID,elementIDStringSEL)];
      else
        return preBuiltNumPlusDot[_contextID];
    }
  else
    {      
      if (_elementID)
        return [NSString stringWithFormat:@"%u.%@",
                         _contextID,
                         (*_elementIDIMPs._elementIDStringIMP)(_elementID,elementIDStringSEL)];
      else
        return [NSString stringWithFormat:@"%u.%@",
                         _contextID,
                         GSWContext_elementID(self)];
    };
};

//--------------------------------------------------------------------
-(GSWComponent*)component
{
  return _currentComponent;
};

// this is used from GSWComponentDefinition, GSWComponent
-(NSString*) _componentName
{
  return _componentName;
}

// this is used from GSWComponentDefinition
- (void) _setComponentName:(NSString*) newValue
{
  ASSIGN(_componentName, newValue);
}

// this is used from GSWComponentDefinition, GSWComponent
- (GSWComponentDefinition*) _tempComponentDefinition
{
  GSWComponentDefinition * componentdefinition = AUTORELEASE(RETAIN(_tempComponentDefinition));
  [self _setTempComponentDefinition:nil];

  return componentdefinition;
}

// this is used from GSWComponentDefinition
- (void) _setTempComponentDefinition:(GSWComponentDefinition*) newValue
{
  ASSIGN(_tempComponentDefinition, newValue);
}

//--------------------------------------------------------------------
-(NSString*)contextID
{
  if (_contextID==(unsigned int)-1)
    return nil;
  else
    return GSWIntToNSString((int)_contextID);
};

//--------------------------------------------------------------------
-(GSWComponent*)page
{
  if ([_pageComponent _isPage])
    return _pageComponent;
  else
    return nil;
};

//--------------------------------------------------------------------
-(GSWRequest*)request
{
  return _request;
};

//--------------------------------------------------------------------
-(GSWResponse*)response
{ 
  return _response;
};

//--------------------------------------------------------------------
-(BOOL)hasSession
{
  return (_session!=nil);
};

//--------------------------------------------------------------------
/** return YES is session creation|restoration is disabled **/
-(BOOL)isSessionDisabled
{
  return _isSessionDisabled;
}

//--------------------------------------------------------------------
/** pass YES as argument to disable  session creation|restoration **/
-(void)setIsSessionDisabled:(BOOL)yn
{
  _isSessionDisabled=yn;
}

//--------------------------------------------------------------------
-(GSWSession*)_session
{
  return _session;
};

//--------------------------------------------------------------------
-(GSWSession*)session
{
  GSWSession* session=nil;

  if (![self isSessionDisabled])
    {
      if (!_session)
        {
          NSString* requestSessionID=[self _requestSessionID];

          if (requestSessionID)
            [GSWApp restoreSessionWithID:requestSessionID
                    inContext:self];//Application call context _setSession
        };
      if (!_session)
        [GSWApp _initializeSessionInContext:self]; //Application call context _setSession

      NSAssert(_session,@"Unable to create new session");

      session=_session;
    };

  return session;
};

//--------------------------------------------------------------------
-(NSString*)senderID
{
  return _senderID;
};

#ifndef NDEBUG
//--------------------------------------------------------------------
-(void)incrementLoopLevel //ForDebugging purpose: each repetition increment and next decrement it
{
  _loopLevel++;
};

//--------------------------------------------------------------------
-(void)decrementLoopLevel
{
  _loopLevel--;
};

//--------------------------------------------------------------------
-(BOOL)isInLoop
{
  return _loopLevel>0;
};

//--------------------------------------------------------------------
-(void)addToDocStructureElement:(id)element
{
  if(GSDebugSet(@"GSWDocStructure"))
    {
      NSString* string=nil;
      int elementIDNb=[_elementID elementsCount];
      NSMutableData* data=[NSMutableData dataWithCapacity:elementIDNb+1];
      char* ptab=(char*)[data bytes];
      if (!_docStructure)
        _docStructure=[NSMutableString new];
      if (!_docStructureElements)
        _docStructureElements=[NSMutableSet new];
      memset(ptab,'\t',elementIDNb);
      ptab[elementIDNb]='\0';
      string=[NSString stringWithFormat:@"%s %@ Element %p Class %@ declarationName=%@\n",
                       ptab,
                       [self elementID],
                       element,
                       [element class],
                       [element declarationName]];
      if (![_docStructureElements containsObject:string])
        {
          [_docStructure appendString:string];
          [_docStructureElements addObject:string];
        };
    };
}

//--------------------------------------------------------------------
-(void)addDocStructureStep:(NSString*)stepLabel
{
  if(GSDebugSet(@"GSWDocStructure"))
    {
      if (!_docStructure)
        _docStructure=[NSMutableString new];
      [_docStructureElements removeAllObjects];
      [_docStructure appendFormat:@"===== %@ =====\n",stepLabel];
    };
}

//--------------------------------------------------------------------
-(NSString*)docStructure
{
  if(GSDebugSet(@"GSWDocStructure"))
    return _docStructure;
  else
    return nil;
}
#endif

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                           urlPrefix:(NSString*)urlPrefix
                                     queryDictionary:(NSDictionary*)queryDictionary
{
  GSWDynamicURLString* url=nil;

  url=[self directActionURLForActionNamed:actionName
            urlPrefix:urlPrefix
            queryDictionary:queryDictionary
            isSecure:[[self request]isSecure]];

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary
{
  GSWDynamicURLString* url=nil;

  url=[self directActionURLForActionNamed:actionName
            urlPrefix:nil
            queryDictionary:queryDictionary];

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                           urlPrefix:(NSString*)urlPrefix
                                     queryDictionary:(NSDictionary*)queryDictionary
                                 pathQueryDictionary:(NSDictionary*)pathQueryDictionary
{
  GSWDynamicURLString* url=nil;

  url=[self directActionURLForActionNamed:actionName
            urlPrefix:urlPrefix
            queryDictionary:queryDictionary
            pathQueryDictionary:pathQueryDictionary
            isSecure:[[self request]isSecure]];

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary
                                 pathQueryDictionary:(NSDictionary*)pathQueryDictionary
{
  GSWDynamicURLString* url=nil;

  url=[self directActionURLForActionNamed:actionName
               urlPrefix:nil
               queryDictionary:queryDictionary
               pathQueryDictionary:pathQueryDictionary];

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                           urlPrefix:(NSString*)urlPrefix
                                     queryDictionary:(NSDictionary*)queryDictionary
                                            isSecure:(BOOL)isSecure
{
  GSWDynamicURLString* url=nil;

  url=[self directActionURLForActionNamed:actionName
            urlPrefix:urlPrefix
            queryDictionary:queryDictionary
            pathQueryDictionary:nil
            isSecure:isSecure];

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary
                                            isSecure:(BOOL)isSecure
{
  GSWDynamicURLString* url=nil;

  url=[self directActionURLForActionNamed:actionName
            urlPrefix:nil
            queryDictionary:queryDictionary
            isSecure:isSecure];

  return url;
}

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                           urlPrefix:(NSString*)urlPrefix
                                     queryDictionary:(NSDictionary*)queryDictionary
                                 pathQueryDictionary:(NSDictionary*)pathQueryDictionary
                                            isSecure:(BOOL)isSecure
{
  GSWDynamicURLString* url=nil;

  url=[self _directActionURLForActionNamed:actionName
            urlPrefix:urlPrefix
            queryDictionary:queryDictionary
            pathQueryDictionary:pathQueryDictionary
            isSecure:isSecure
            url:url];

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary
                                 pathQueryDictionary:(NSDictionary*)pathQueryDictionary
                                            isSecure:(BOOL)isSecure
{
  return [self directActionURLForActionNamed:actionName
               urlPrefix:nil
               queryDictionary:queryDictionary
               pathQueryDictionary:pathQueryDictionary
               isSecure:isSecure];
}

//--------------------------------------------------------------------
-(GSWDynamicURLString*)componentActionURL
{
  GSWDynamicURLString* url=nil;

  url=[self componentActionURLIsSecure:[[self request]isSecure]];

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)componentActionURLIsSecure:(BOOL)isSecure
{
  BOOL storesIDsInURLs=NO;
  GSWDynamicURLString* url=nil;
  GSWSession* session=nil;
  NSString* elementID=nil;
  NSString* componentRequestHandlerKey=nil;
  NSString* requestHandlerKey=nil;
  NSString* requestHandlerPath=nil;

  session=[self session]; //OK

  elementID=[self elementID];

  componentRequestHandlerKey=[GSWApplication componentRequestHandlerKey];
  
  requestHandlerKey=componentRequestHandlerKey;
  storesIDsInURLs=[session storesIDsInURLs];
  
  if (storesIDsInURLs)
    {
      NSString* sessionID=[_session sessionID];
      // requestHandlerPath as sessionID/_contextID.elementID
      if (sessionID)
        {
          requestHandlerPath=[[sessionID stringByAppendingString:@"/"]
                               stringByAppendingString:GSWContext_contextAndElementID(self)];
        }
      else
        {
          requestHandlerPath=[@"/" stringByAppendingString:GSWContext_contextAndElementID(self)];
        };
    }
  else
    {
      // requestHandlerPath as /_contextID.elementID
      requestHandlerPath=[@"/" stringByAppendingString:GSWContext_contextAndElementID(self)];
    };

  url=[self urlWithRequestHandlerKey:requestHandlerKey
            path:requestHandlerPath
            queryString:nil
            isSecure:isSecure];

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)urlWithURLPrefix:(NSString*)urlPrefix
                      requestHandlerKey:(NSString*)requestHandlerKey
                                   path:(NSString*)requestHandlerPath
                            queryString:(NSString*)queryString
                               isSecure:(BOOL)isSecure
                                   port:(int)port
{
  GSWDynamicURLString* url=nil;
  GSWRequest* request=[self request];

  // Try to avoid complete URLs
  if (_generateCompleteURLs
      || (isSecure!=[request isSecure])
      || (port!=0 && port!=[request urlPort]))
    url=[self completeURLWithURLPrefix:urlPrefix
              requestHandlerKey:requestHandlerKey
              path:requestHandlerPath
              queryString:queryString
              isSecure:isSecure
              port:port];
  else    
    url=[request _urlWithURLPrefix:urlPrefix
                 requestHandlerKey:requestHandlerKey
                 path:requestHandlerPath
                 queryString:queryString];

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)urlWithRequestHandlerKey:(NSString*)requestHandlerKey
                                           path:(NSString*)requestHandlerPath
                                    queryString:(NSString*)queryString
                                       isSecure:(BOOL)isSecure
                                           port:(int)port
{
  return [self urlWithURLPrefix:nil
               requestHandlerKey:requestHandlerKey
               path:requestHandlerPath
               queryString:queryString
               isSecure:isSecure
               port:port];
}

//--------------------------------------------------------------------
-(GSWDynamicURLString*)urlWithURLPrefix:(NSString*)urlPrefix
                      requestHandlerKey:(NSString*)requestHandlerKey
                                   path:(NSString*)requestHandlerPath
                            queryString:(NSString*)queryString
{
  GSWDynamicURLString* url=nil;

  url=[self urlWithURLPrefix:urlPrefix
              requestHandlerKey:requestHandlerKey
              path:requestHandlerPath
              queryString:queryString
              isSecure:[[self request]isSecure]];

  return url;
};

//--------------------------------------------------------------------
//TODO rewrite to avoid request call
-(GSWDynamicURLString*)urlWithURLPrefix:(NSString*)urlPrefix
                      requestHandlerKey:(NSString*)requestHandlerKey
                                   path:(NSString*)requestHandlerPath
                            queryString:(NSString*)queryString
                                isSecure:(BOOL)isSecure
{
  GSWDynamicURLString* url=nil;
  GSWRequest* request=[self request];

  if (_generateCompleteURLs)
    url=[self completeURLWithRequestHandlerKey:requestHandlerKey
              path:requestHandlerPath
              queryString:queryString
              isSecure:isSecure
              port:0];
  else
    {
      url=[request _urlWithRequestHandlerKey:requestHandlerKey
                   path:requestHandlerPath
                   queryString:queryString];
      [url setURLApplicationNumber:_urlApplicationNumber];
    };

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)urlWithRequestHandlerKey:(NSString*)requestHandlerKey
                                           path:(NSString*)requestHandlerPath
                                    queryString:(NSString*)queryString
{
  return [self urlWithURLPrefix:nil
               requestHandlerKey:requestHandlerKey
               path:requestHandlerPath
               queryString:queryString
               isSecure:[[self request]isSecure]];
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)urlWithRequestHandlerKey:(NSString*)requestHandlerKey
                                           path:(NSString*)requestHandlerPath
                                    queryString:(NSString*)queryString
                                       isSecure:(BOOL)isSecure
{
  return [self urlWithURLPrefix:nil
               requestHandlerKey:requestHandlerKey
               path:requestHandlerPath
               queryString:queryString
               isSecure:isSecure];
};

//--------------------------------------------------------------------
//NDFN
-(GSWDynamicURLString*)completeURLWithURLPrefix:(NSString*)urlPrefix
                              requestHandlerKey:(NSString*)requestHandlerKey
                                           path:(NSString*)requestHandlerPath
                                    queryString:(NSString*)queryString
{
  GSWDynamicURLString* url=nil;
  GSWRequest* request=nil;

  request=[self request];

  url=[self completeURLWithURLPrefix:urlPrefix
            requestHandlerKey:requestHandlerKey
            path:requestHandlerPath
            queryString:queryString
            isSecure:[request isSecure]
            port:[request urlPort]];

  return url;
};

//--------------------------------------------------------------------
//NDFN
-(GSWDynamicURLString*)completeURLWithRequestHandlerKey:(NSString*)requestHandlerKey
                                                   path:(NSString*)requestHandlerPath
                                            queryString:(NSString*)queryString
{
  GSWDynamicURLString* url=nil;

  url=[self completeURLWithURLPrefix:nil
            requestHandlerKey:requestHandlerKey
            path:requestHandlerPath
            queryString:queryString];

  return url;
};


//--------------------------------------------------------------------
//TODO: rewrite. We have to decide if we use mainly request or _uri
-(GSWDynamicURLString*)completeURLWithURLPrefix:(NSString*)urlPrefix
                              requestHandlerKey:(NSString*)requestHandlerKey
                                           path:(NSString*)requestHandlerPath
                                    queryString:(NSString*)queryString
                                       isSecure:(BOOL)isSecure
                                           port:(int)port
{
  NSString* host=nil;
  GSWDynamicURLString* url=nil;
  GSWRequest* request=nil;

  request=[self request];

  if (urlPrefix)
    url=[_request _urlWithURLPrefix:urlPrefix
                  requestHandlerKey:requestHandlerKey
                  path:requestHandlerPath
                  queryString:queryString];
  else
    url=[_request _urlWithRequestHandlerKey:requestHandlerKey
                  path:requestHandlerPath
                  queryString:queryString];

  [url setURLApplicationNumber:_urlApplicationNumber];

  if (isSecure)
    [url setURLProtocol:GSWProtocol_HTTPS];
  else
    [url setURLProtocol:GSWProtocol_HTTP];

  if (port)
    [url setURLPort:port];

  host=[request urlHost];
  NSAssert1(host,@"No host in request %@",request);

  [url setURLHost:host];

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)completeURLWithRequestHandlerKey:(NSString*)requestHandlerKey
                                                   path:(NSString*)requestHandlerPath
                                            queryString:(NSString*)queryString
                                               isSecure:(BOOL)isSecure
                                                   port:(int)port
{
  GSWDynamicURLString* url=nil;

  url=[self completeURLWithURLPrefix:nil
            requestHandlerKey:requestHandlerKey
            path:requestHandlerPath
            queryString:queryString
            isSecure:isSecure
            port:port];

  return url;
};


//--------------------------------------------------------------------
-(id)_initWithContextID:(unsigned int)contextID
{
  _contextID=contextID;
  DESTROY(_url);
  _url=[GSWDynamicURLString new];
  DESTROY(_awakePageComponents);
  _awakePageComponents=[NSMutableArray new];
  _urlApplicationNumber=-1;

  return self;
};


//--------------------------------------------------------------------
-(BOOL)_isMultipleSubmitForm
{
  return _isMultipleSubmitForm;
};

//--------------------------------------------------------------------
-(void)_setIsMultipleSubmitForm:(BOOL)flag
{
  _isMultipleSubmitForm=flag;
};

//--------------------------------------------------------------------
-(BOOL)_wasActionInvoked
{
  return _actionInvoked;
};

//--------------------------------------------------------------------
-(void)_setActionInvoked:(BOOL)flag
{
  _actionInvoked=flag;
};

//--------------------------------------------------------------------
// wo5?
-(BOOL)_wasFormSubmitted
{
  return _formSubmitted;
};

//--------------------------------------------------------------------
-(void)_setFormSubmitted:(BOOL)flag
{
  _formSubmitted = flag;
};

//--------------------------------------------------------------------
-(void)_putAwakeComponentsToSleep
{
  int i=0;
  int count=0;
  GSWComponent* component=nil;

  count=[_awakePageComponents count];

  for(i=0;i<count;i++)
    {
      component=[_awakePageComponents objectAtIndex:i];
      [component sleepInContext:self];
    };
};

//--------------------------------------------------------------------
-(BOOL)_generateCompleteURLs
{
  BOOL previousState=_generateCompleteURLs;
  _generateCompleteURLs=YES;
  return previousState;
};

//--------------------------------------------------------------------
-(BOOL)_generateRelativeURLs
{
  BOOL previousState=!_generateCompleteURLs;
  _generateCompleteURLs=NO;
  return previousState;
};

//--------------------------------------------------------------------
-(BOOL)isGeneratingCompleteURLs
{
  return _generateCompleteURLs;
};

//--------------------------------------------------------------------
//_url is a semi complete one: line /cgi/WebObjects.exe/ObjCTest3.woa
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                            urlPrefix:(NSString*)urlPrefix
                                      queryDictionary:(NSDictionary*)dict
                                                  url:(id)anURL
{
  GSWDynamicURLString* url=nil;

  url=[self _directActionURLForActionNamed:actionName
            urlPrefix:urlPrefix
            queryDictionary:dict
            pathQueryDictionary:nil
            url:anURL];

  return url;
};

//--------------------------------------------------------------------
//_url is a semi complete one: line /cgi/WebObjects.exe/ObjCTest3.woa
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                      queryDictionary:(NSDictionary*)dict
                                                  url:(id)anURL
{
  GSWDynamicURLString* url=nil;

  url=[self _directActionURLForActionNamed:actionName
            urlPrefix:nil
            queryDictionary:dict
            url:anURL];

  return url;
};

//--------------------------------------------------------------------
//_url is a semi complete one: line /cgi/WebObjects.exe/ObjCTest3.woa
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                            urlPrefix:(NSString*)urlPrefix
                                      queryDictionary:(NSDictionary*)dict
                                  pathQueryDictionary:(NSDictionary*)pathQueryDictionary
                                                  url:(id)anURL
{
  GSWDynamicURLString* url=nil;

  url=[self _directActionURLForActionNamed:actionName
            urlPrefix:urlPrefix
            queryDictionary:dict
            pathQueryDictionary:pathQueryDictionary
            isSecure:[[self request]isSecure]
            url:anURL];

  return url;
};

//--------------------------------------------------------------------
//_url is a semi complete one: line /cgi/WebObjects.exe/ObjCTest3.woa
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                      queryDictionary:(NSDictionary*)dict
                                  pathQueryDictionary:(NSDictionary*)pathQueryDictionary
                                                  url:(id)anURL
{
  GSWDynamicURLString* url=nil;

  url=[self _directActionURLForActionNamed:actionName
            urlPrefix:nil
            queryDictionary:dict
            pathQueryDictionary:pathQueryDictionary
            url:anURL];

  return url;
};

//--------------------------------------------------------------------
//_url is a semi complete one: line /cgi/WebObjects.exe/ObjCTest3.woa
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                            urlPrefix:(NSString*)urlPrefix
                                      queryDictionary:(NSDictionary*)dict
                                             isSecure:(BOOL)isSecure
                                                  url:(id)anURL
{
  GSWDynamicURLString* url=nil;

  url=[self _directActionURLForActionNamed:actionName
              urlPrefix:urlPrefix
              queryDictionary:dict
              pathQueryDictionary:nil
              isSecure:isSecure
              url:anURL];

  return url;
};

//--------------------------------------------------------------------
//_url is a semi complete one: line /cgi/WebObjects.exe/ObjCTest3.woa
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                      queryDictionary:(NSDictionary*)dict
                                             isSecure:(BOOL)isSecure
                                                  url:(id)anURL
{
  GSWDynamicURLString* url=nil;

  url=[self _directActionURLForActionNamed:actionName
            urlPrefix:nil
            queryDictionary:dict
            isSecure:isSecure
            url:anURL];

  return url;
};

//--------------------------------------------------------------------
//_url is a semi complete one: line /cgi/WebObjects.exe/ObjCTest3.woa
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                            urlPrefix:(NSString*)urlPrefix
                                      queryDictionary:(NSDictionary*)dict
                                  pathQueryDictionary:(NSDictionary*)pathQueryDictionary
                                             isSecure:(BOOL)isSecure
                                                  url:(id)anURL
{
  NSMutableString* queryString=nil;
  NSEnumerator* enumerator =nil;
  id key=nil;
  NSString* path=nil;
  IMP queryString_appendStringIMP=NULL;

//  _url=[[_url copy] autorelease];
  //TODOV
  enumerator = [dict keyEnumerator];
  // Build queryString as key=value[&key=value]..
  while ((key = [enumerator nextObject]))
    {
      if (!queryString)
        queryString=(NSMutableString*)[NSMutableString string];
      else
        {
          GSWeb_appendStringWithImpPtr(queryString,
                                       &queryString_appendStringIMP,
                                       @"&");
        }
      GSWeb_appendStringWithImpPtr(queryString,
                                   &queryString_appendStringIMP,
                                   NSStringWithObject(key));
      GSWeb_appendStringWithImpPtr(queryString,
                                   &queryString_appendStringIMP,
                                   @"=");
      GSWeb_appendStringWithImpPtr(queryString,
                                   &queryString_appendStringIMP,
                                   NSStringWithObject([dict objectForKey:key]));
    };
  /*
    [anURL setURLRequestHandlerKey:GSWDirectActionRequestHandlerKey[GSWebNamingConv]];
  [anURL setURLRequestHandlerPath:actionName];
  [anURL setURLQueryString:queryString];
*/

/*  anURL=[self completeURLWithRequestHandlerKey:GSWDirectActionRequestHandlerKey[GSWebNamingConv]
              path:actionName
              queryString:queryString
              isSecure:isSecure
              port:0];
*/
  if ([pathQueryDictionary count]>0)
    {
      IMP tmpPath_appendStringIMP=NULL;
      NSMutableString* tmpPath=(NSMutableString*)[NSMutableString stringWithString:actionName];
      // We sort keys so URL are always the same for same parameters
      NSArray* keys=[[pathQueryDictionary allKeys]sortedArrayUsingSelector:@selector(compare:)];
      int count=[keys count];
      int i=0;

      // append each key/value pair as /key=value
      for(i=0;i<count;i++)
        {
          id key = [keys objectAtIndex:i];
          id value = [pathQueryDictionary valueForKey:key];
          if (!value)
            value=[NSString string];
          GSWeb_appendStringWithImpPtr(tmpPath,&tmpPath_appendStringIMP,
                                       @"/");
          GSWeb_appendStringWithImpPtr(tmpPath,&tmpPath_appendStringIMP,
                                       NSStringWithObject(key));
          GSWeb_appendStringWithImpPtr(tmpPath,&tmpPath_appendStringIMP,
                                       @"=");
          GSWeb_appendStringWithImpPtr(tmpPath,&tmpPath_appendStringIMP,
                                       NSStringWithObject(value));
        };
      path=tmpPath;
    }
  else
    path=actionName;

  if (urlPrefix)
    anURL=[self urlWithURLPrefix:urlPrefix
                requestHandlerKey:GSWDirectActionRequestHandlerKey[GSWebNamingConv]
                path:path
                queryString:queryString
                isSecure:isSecure
                port:0];
  else
    anURL=[self urlWithRequestHandlerKey:GSWDirectActionRequestHandlerKey[GSWebNamingConv]
                path:path
                queryString:queryString
                isSecure:isSecure
                port:0];

  return anURL;
};

//--------------------------------------------------------------------
//_url is a semi complete one: line /cgi/WebObjects.exe/ObjCTest3.woa
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                      queryDictionary:(NSDictionary*)dict
                                  pathQueryDictionary:(NSDictionary*)pathQueryDictionary
                                             isSecure:(BOOL)isSecure
                                                  url:(id)anURL
{
  return [self _directActionURLForActionNamed:actionName
               urlPrefix:nil
               queryDictionary:dict
               pathQueryDictionary:pathQueryDictionary
               isSecure:isSecure
               url:anURL];
}

-(GSWDynamicURLString*) _componentActionURL
{
  GSWSession * session = [self session];
  NSString * s = [self contextID];
  NSString * s1 = [self elementID];
  NSMutableString * actionURL = [NSMutableString string];
  
  if ([GSWApp pageCacheSize] == 0) {
    if ([session storesIDsInURLs]) {
      [actionURL appendString:[[self page] name]];
      [actionURL appendString:@"/"];
      [actionURL appendString:[session sessionID]];
      [actionURL appendString:@"/"];
      [actionURL appendString:s];
      [actionURL appendString:@"."];
      [actionURL appendString:s1];
    } else {
      [actionURL appendString:[[self page] name]];
      [actionURL appendString:@"/"];
      [actionURL appendString:s];
      [actionURL appendString:@"."];
      [actionURL appendString:s1];
    }
  } else {
    if ([session storesIDsInURLs]) {
      [actionURL appendString:[session sessionID]];
      [actionURL appendString:@"/"];
      [actionURL appendString:s];
      [actionURL appendString:@"."];
      [actionURL appendString:s1];
    } else {
      [actionURL appendString:s];
      [actionURL appendString:@"."];
      [actionURL appendString:s1];
    }
  }
  return [self urlWithRequestHandlerKey:[[GSWApp class] componentRequestHandlerKey]
                                   path: actionURL
                            queryString: nil];

}


// new 
//_directActionURL in wo 5

-(GSWDynamicURLString*) _directActionURLForActionNamed:(NSString*) anActionName
                                       queryDictionary:(NSDictionary*)queryDictionary
                                              isSecure:(BOOL)isSecure
                                                  port:(int)port
                                 escapeQueryDictionary:(BOOL)escapeQueryDict
{
  GSWDynamicURLString * url = nil;
  NSString * aQueryString = nil;
  
  BOOL forceLoadBalancing;
  NSString *savedApplicationNumber;
  BOOL isInDevelopment = ((_request) && ([_request applicationNumber] < -1));
  
  forceLoadBalancing = ((_session == nil) && ((_requestSessionID == nil)) && (!isInDevelopment));
  savedApplicationNumber = [[self _url] applicationNumber];
  
  if (forceLoadBalancing) {
    [_url setApplicationNumber:@"-1"];
  }
  
  if ((queryDictionary != nil) && ([queryDictionary count] > 0)) {
    aQueryString = [queryDictionary encodeAsCGIFormValuesEscapeAmpersand:escapeQueryDict];
  }
  
  url = [self _urlWithRequestHandlerKey:[[GSWApp class] directActionRequestHandlerKey]
                     requestHandlerPath:anActionName
                            queryString:aQueryString
                               isSecure:isSecure
                                   port:port];
  
  if(forceLoadBalancing) {
    [_url setApplicationNumber:savedApplicationNumber];
  }
  
  return url;
}


//--------------------------------------------------------------------
/** Returns array of languages 
First try  session languages, if none, try self language
If none, try request languages
**/
-(NSArray*)languages
{
  NSArray* languages=nil;
  
  languages=[[self _session] languages];

  if ([languages count]==0)
    {
      languages=_languages;

      if ([languages count]==0)
        {
          languages=[[self request]browserLanguages];
        }
    };

  //GSWeb specific: It enable application languages filtering
  languages=[GSWApp filterLanguages:languages];

  return languages;
};

//--------------------------------------------------------------------
-(void)_setLanguages:(NSArray*)languages
{

  ASSIGNCOPY(_languages,languages);

};

//--------------------------------------------------------------------
-(GSWComponent*)_pageComponent
{
  return _pageComponent;
};

//--------------------------------------------------------------------
-(GSWElement*)_pageElement
{
  return _pageElement;
};

//--------------------------------------------------------------------

-(void)_setPageElement:(GSWElement*)element
{
  if (element != _pageElement) {
    DESTROY(_pageComponent);
    ASSIGN(_pageElement,element);
    if (_pageElement != nil) {
      if ([_pageElement isKindOfClass:[GSWComponent class]]) {
        [self _setPageComponent:(GSWComponent*) _pageElement];
      }
    }
  }
}


//--------------------------------------------------------------------
-(void)_setPageComponent:(GSWComponent*)component
{
  ASSIGN(_pageComponent,component);
  if (_pageComponent)
    [self _takeAwakeComponent: _pageComponent];
};

//--------------------------------------------------------------------
-(void)_setResponse:(GSWResponse*)aResponse
{
  ASSIGN(_response,aResponse);
};

//--------------------------------------------------------------------
-(void)_setRequest:(GSWRequest*)aRequest
{
  NSString* adaptorPrefix=nil;
  NSString* applicationName=nil;

  if (_request!=aRequest)
    {
      ASSIGN(_request,aRequest);

      [_request _setContext:self];

      adaptorPrefix=[aRequest adaptorPrefix];
      [_url setURLPrefix:adaptorPrefix];

      applicationName=[aRequest applicationName];
      [_url setURLApplicationName:applicationName];

      [self _synchronizeForDistribution];
    };
};

//--------------------------------------------------------------------
-(void)_setSession:(GSWSession*)aSession
{
  if (_session!=aSession)
    {
      ASSIGN(_session,aSession);
      [self _synchronizeForDistribution];
    };
  if (_session)
    {
      _contextID=[_session _contextCounter];
    };
};

//--------------------------------------------------------------------
-(void)_setSenderID:(NSString*)aSenderID
{
  ASSIGNCOPY(_senderID,aSenderID);
};

//--------------------------------------------------------------------
-(void)_synchronizeForDistribution
{
  int instance=-1;

  if (_request)
    {
      BOOL storesIDsInURLs=NO;
      BOOL isDistributionEnabled=NO;
      NSString* sessionID=nil;
      GSWSession* session=nil;

      if (![self isSessionDisabled])
        {
          session=[self _session];

          storesIDsInURLs=[session storesIDsInURLs];
          isDistributionEnabled=[session isDistributionEnabled];
                              
          sessionID=[_request sessionID];
        };

      instance=[_request applicationNumber];

      // Set instance to -1 
      // if we don't store IDs in URLs and distribution is enabled
      // or if we don't have session nor session id
      if ((isDistributionEnabled && !storesIDsInURLs)
          || (!session && !sessionID))
        instance=-1;
    };

  _urlApplicationNumber = instance;
  [_url setURLApplicationNumber:instance];

};

//--------------------------------------------------------------------
-(void)_incrementContextID
{
  _contextID++;
  [_session _contextDidIncrementContextID];
};

//--------------------------------------------------------------------
// I am not so sure if that exists here in WO. davew.
-(GSWSession*)existingSession
{
  if ([self isSessionDisabled])
    return nil;
  else
    return _session;
};

//--------------------------------------------------------------------
-(void)_setCurrentComponent:(GSWComponent*)component
{
  ASSIGN(_currentComponent,component);
};

//--------------------------------------------------------------------
-(void)_setPageReplaced:(BOOL)flag
{
  _pageReplaced=flag;
};
  
//--------------------------------------------------------------------
-(BOOL)_pageReplaced
{
  return _pageReplaced;
};

//--------------------------------------------------------------------
-(void)_setPageChanged:(BOOL)flag
{
  _pageChanged=flag;
};

//--------------------------------------------------------------------
-(BOOL)_pageChanged
{
  return _pageChanged;
};

//--------------------------------------------------------------------
-(void)_setRequestContextID:(NSString*)contextID
{
  ASSIGN(_requestContextID,contextID);
}

//--------------------------------------------------------------------
-(NSString*)_requestContextID
{
  return _requestContextID;
}

//--------------------------------------------------------------------
-(void)_setRequestSessionID:(NSString*)aSessionID
{
  ASSIGNCOPY(_requestSessionID,aSessionID);
};

//--------------------------------------------------------------------
-(NSString*)_requestSessionID
{
  return _requestSessionID;
};

//--------------------------------------------------------------------
-(void)_takeAwakeComponentsFromArray:(NSArray*)components
{
  if ([components count]>0)
    {
      NSEnumerator* enumerator = nil;
      GSWComponent* component = nil;
      if (!_awakePageComponents)
        _awakePageComponents=[NSMutableArray new];
      
      enumerator = [components objectEnumerator];
      while ((component = [enumerator nextObject]))
        {
          if (![_awakePageComponents containsObject:component])
            [_awakePageComponents addObject:component];
        };
    };
};

//--------------------------------------------------------------------
-(void)_takeAwakeComponent:(GSWComponent*)component
{
  //OK
  if (!_awakePageComponents)
    _awakePageComponents=[NSMutableArray new];
  if (![_awakePageComponents containsObject:component])
    [_awakePageComponents addObject:component];
};

//--------------------------------------------------------------------
-(NSMutableDictionary*)userInfo
{
  return [self _userInfo];
};

//--------------------------------------------------------------------
-(NSMutableDictionary*)_userInfo
{
  if (!_userInfo)
    _userInfo=[NSMutableDictionary new];
  return _userInfo;
};

//--------------------------------------------------------------------
-(void)_setUserInfo:(NSMutableDictionary*)userInfo
{
  NSAssert2(!userInfo || [userInfo isKindOfClass:[NSMutableDictionary class]],
            @"userInfo is not a NSMutableDictionary but a %@: %@",
            [userInfo class],
            userInfo);
  ASSIGN(_userInfo,userInfo);
};


-(void) _stripSessionIDFromURL
{
  NSString * handlerPath = [[self _url] requestHandlerPath];
  if ((!handlerPath) || ([handlerPath isEqual:@""])) {
    return;
  }
  
  NSRange  range;
  unsigned handlerPathlength;
  
  range = [handlerPath rangeOfString:[GSWApp sessionIdKey]];
  
  if (range.location > 0) {
    NSRange endRange;
    NSRange totalRange;
    
    handlerPathlength = [handlerPath length];
    
    totalRange = NSMakeRange(range.location, handlerPathlength-range.location);
    
    endRange = [handlerPath rangeOfString:@"&"
                                  options:0 
                                    range:totalRange];
    
    if(endRange.location == NSNotFound) {
      [[self _url] setRequestHandlerPath: [handlerPath substringWithRange:NSMakeRange(0, range.location)]];
    } else {
      [[self _url] setRequestHandlerPath:[[handlerPath substringWithRange:NSMakeRange(0, range.location)] 
                                          stringByAppendingString:[handlerPath substringWithRange:NSMakeRange(range.location + 1, handlerPathlength)]]];
    }
  }
}


//--------------------------------------------------------------------
// context can add key/values in query dictionary
//-(NSDictionary*)computeQueryDictionary:(NSDictionary*)queryDictionary
//{
//  //Do nothing
//  return queryDictionary;
//};

// computeQueryDictionary
-(NSDictionary*) computeQueryDictionaryWithPath:(NSString*) aRequestHandlerPath
                                queryDictionary:(NSDictionary*) queryDictionary
                           otherQueryDictionary:(NSDictionary*) otherQueryDictionary
{
  NSMutableDictionary * newQueryDictionary;
  NSString            * sessionId = nil;
  GSWSession          * sess = nil;
  if (queryDictionary != nil) {
    newQueryDictionary = [[queryDictionary mutableCopy] autorelease];
  } else {
    newQueryDictionary = [NSMutableDictionary dictionary];
  }
  
  if ([self hasSession]) {
    sess = [self session];
    if ((![sess isTerminating]) && [sess storesIDsInURLs]) {
      sessionId = [sess sessionID]; 
    }
  } else {
    if ([self _sessionIDInURL]) {
      sessionId = _requestSessionID;
    }
  }
  
  if ((sessionId != nil) && ([[newQueryDictionary sessionID] boolValue])) {
    [newQueryDictionary setObject:sessionId
                           forKey:[GSWApp sessionIdKey]];
  } else {
    if ([newQueryDictionary count] > 0) {
      [newQueryDictionary removeObjectForKey:[GSWApp sessionIdKey]];
      [newQueryDictionary removeObjectForKey:@"wosid"];
    }
  }
  if (otherQueryDictionary != nil) {
    NSEnumerator * keyEnumerator = [otherQueryDictionary keyEnumerator];
    NSString * aKey = nil;
    
    while ((aKey = [keyEnumerator nextObject])) {        
      id aValue = [otherQueryDictionary objectForKey:aKey];
      
      if (([aKey isEqual:[GSWApp sessionIdKey]]) || ([aKey isEqual:@"wosid"])) {
        // CHECKME!
        if ([aValue boolValue] == NO) {
          [newQueryDictionary removeObjectForKey:aKey];
        }
      } else {
        [newQueryDictionary setObject:aValue forKey:aKey];
      }
    }
    
  }
  sessionId = [newQueryDictionary objectForKey:[GSWApp sessionIdKey]];
  
  if (sessionId) {
    NSRange range;
    NSRange range2;
    
    range = [aRequestHandlerPath rangeOfString:sessionId];
    range2 = [aRequestHandlerPath rangeOfString:[GSWApp sessionIdKey]];
    
    if ((range.location != NSNotFound) || (range.location != NSNotFound))
    {
      [newQueryDictionary removeObjectForKey:[GSWApp sessionIdKey]];
      [newQueryDictionary removeObjectForKey:@"wosid"];
    }
  } else {
    [self _stripSessionIDFromURL];
  }
  return newQueryDictionary;
}

//--------------------------------------------------------------------
// context can add key/values in query dictionary
-(NSDictionary*)computePathQueryDictionary:(NSDictionary*)queryDictionary
{
  //Do nothing
  return queryDictionary;
};


//--------------------------------------------------------------------
//	incrementLastElementIDComponent
-(void)incrementLastElementIDComponent 
{
  if (!_elementID)
    [self _createElementID];
  
  NSAssert(_elementIDIMPs._incrementLastElementIDComponentIMP,
           @"No _elementIDIMPs._incrementLastElementIDComponentIMP");
  (*_elementIDIMPs._incrementLastElementIDComponentIMP)(_elementID,incrementLastElementIDComponentSEL);
};



//--------------------------------------------------------------------
//	appendElementIDComponent:
-(void)appendElementIDComponent:(NSString*)string
{
  if (!_elementID)
    [self _createElementID];

  NSAssert(_elementIDIMPs._appendElementIDComponentIMP,
           @"No _elementIDIMPs._appendElementIDComponentIMP");

  (*_elementIDIMPs._appendElementIDComponentIMP)(_elementID,appendElementIDComponentSEL,string);
};

//--------------------------------------------------------------------
//	appendZeroElementIDComponent
-(void)appendZeroElementIDComponent 
{
  if (!_elementID)
    [self _createElementID];

  NSAssert(_elementIDIMPs._appendZeroElementIDComponentIMP,
           @"No _elementIDIMPs._appendZeroElementIDComponentIMP");

  (*_elementIDIMPs._appendZeroElementIDComponentIMP)(_elementID,appendZeroElementIDComponentSEL);
};

//--------------------------------------------------------------------
//	deleteAllElementIDComponents
-(void)deleteAllElementIDComponents 
{
  if (!_elementID)
    [self _createElementID];
  
  NSAssert(_elementIDIMPs._deleteAllElementIDComponentsIMP,
           @"No _elementIDIMPs._deleteAllElementIDComponentsIMP");

  (*_elementIDIMPs._deleteAllElementIDComponentsIMP)(_elementID,deleteAllElementIDComponentsSEL);
};

//--------------------------------------------------------------------
//	deleteLastElementIDComponent
-(void)deleteLastElementIDComponent 
{
  if (!_elementID)
    [self _createElementID];

  NSAssert(_elementIDIMPs._deleteLastElementIDComponentIMP,
           @"No _elementIDIMPs._deleteLastElementIDComponentIMP");

  (*_elementIDIMPs._deleteLastElementIDComponentIMP)(_elementID,deleteLastElementIDComponentSEL);
};

//--------------------------------------------------------------------
-(BOOL)isParentSenderIDSearchOver
{
  if (_elementID)
    {
      NSAssert(_elementIDIMPs._isParentSearchOverForSenderIDIMP,
               @"No _elementIDIMPs._isParentSearchOverForSenderIDIMP");
      return (*_elementIDIMPs._isParentSearchOverForSenderIDIMP)(_elementID,isParentSearchOverForSenderIDSEL,_senderID);
    }
  else
    return NO;
};

//--------------------------------------------------------------------
-(BOOL)isSenderIDSearchOver
{
  if (_elementID)
    {
      NSAssert(_elementIDIMPs._isSearchOverForSenderIDIMP,
               @"No _elementIDIMPs._isSearchOverForSenderIDIMP");
      return (*_elementIDIMPs._isSearchOverForSenderIDIMP)(_elementID,isSearchOverForSenderIDSEL,_senderID);
    }
  else
    return NO;
};

//--------------------------------------------------------------------
-(int)elementIDElementsCount
{
  return [_elementID elementsCount];
};

//--------------------------------------------------------------------
-(NSString*)url
{
  //OK
  GSWDynamicURLString* componentActionURL=nil;

  componentActionURL=[self componentActionURL];

  return (NSString*)componentActionURL;
};

//--------------------------------------------------------------------
//	urlSessionPrefix

// return http://my.host.org/cgi-bin/GSWeb/MyApp.ApplicationSuffix/123456789012334567890123456789
-(NSString*)urlSessionPrefix 
{
  [self notImplemented: _cmd];	//TODOFN

  return [NSString stringWithFormat:@"%@%@/%@.%@/%@",
				   [_request urlProtocolHostPort],
				   [_request adaptorPrefix],
				   [_request applicationName],
				   GSWApplicationSuffix[GSWebNamingConv],
				   [[self _session] sessionID]];
};


//--------------------------------------------------------------------
-(int)urlApplicationNumber
{
  return _urlApplicationNumber;
};

//--------------------------------------------------------------------
-(GSWApplication*)application
{
  return [GSWApplication application];
};

//--------------------------------------------------------------------
//	isDistributionEnabled

-(BOOL)isDistributionEnabled 
{
  return _distributionEnabled;
};

//--------------------------------------------------------------------
//	setDistributionEnabled:

-(void)setDistributionEnabled:(BOOL)isDistributionEnabled
{
  _distributionEnabled=isDistributionEnabled;
};


- (NSString*) _urlForResourceNamed: (NSString*)aName 
                       inFramework: (NSString*)frameworkName
{
  return [_resourceManager urlForResourceNamed: aName
                                   inFramework: frameworkName
                                     languages: _languages
                                       request: _request];
}

-(BOOL)isValidate
{
  return _isValidate;
};

//--------------------------------------------------------------------
-(void)setValidate:(BOOL)isValidate
{
  _isValidate = isValidate;
}

- (BOOL) secureRequest
{
  BOOL isSecure = NO;

  if (_request != nil) {
    isSecure = [_request isSecure];
  }

  return isSecure;
}

- (BOOL) secureMode
{
  if ((_secureMode == -2)) {
    return [self secureRequest];
  }
  return ((_secureMode == YES));
}

- (void) setSecureMode:(BOOL) value
{
  _secureMode = (int) value;
}


- (GSWDynamicURLString*) relativeURLWithRequestHandlerKey:(NSString*) requestHandlerKey
                                                     path:(NSString*) requestHandlerPath
                                              queryString:(NSString*) queryString
{
  GSWDynamicURLString * url = [self _url];
  
  // CHECKME: rename to setRequestHandlerKey: ?? -- dw
  [url setURLRequestHandlerKey:requestHandlerKey];
  [url setRequestHandlerPath:requestHandlerPath];
  [url setQueryString:queryString];

  return url;
}


- (GSWDynamicURLString*) _urlWithRequestHandlerKey:(NSString*) requestHandlerKey
                                requestHandlerPath:(NSString*) aRequestHandlerPath
                                       queryString:(NSString*) aQueryString
                                          isSecure:(BOOL) isSecure
                                              port:(int) somePort
{
  GSWDynamicURLString * url = nil;
  
  if (_generateCompleteURLs || ((_request != nil) && (isSecure != [_request isSecure]))) {
    url = [self completeURLWithRequestHandlerKey:requestHandlerKey
                                            path:aRequestHandlerPath
                                     queryString:aQueryString
                                        isSecure:isSecure
                                            port:somePort];
  } else {
    url = [self relativeURLWithRequestHandlerKey:requestHandlerKey
                                            path:aRequestHandlerPath
                                     queryString:aQueryString];
    
  }
  return url;
}


- (GSWDynamicURLString*) _urlWithRequestHandlerKey:(NSString*) requestHandlerKey
                                requestHandlerPath:(NSString*) requestHandlerPath
                                       queryString:(NSString*) queryString
                                          isSecure:(BOOL) isSecure
{
  return [self _urlWithRequestHandlerKey:requestHandlerKey 
                      requestHandlerPath:requestHandlerPath 
                             queryString:queryString
                                isSecure:isSecure
                                    port:0];
}

- (WOMarkupType) markupType
{
  if ((_markupType == WOUndefinedMarkup))
  {
    GSWComponent* thePage = [self page];
    if (thePage) {
      _markupType = [thePage markupType];
    }
  }
  return _markupType;
}

@end

