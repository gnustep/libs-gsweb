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

static int dontTraceComponentActionURL=0;

static SEL componentSEL=NULL;
static SEL elementIDSEL=NULL;
static SEL senderIDSEL=NULL;
static SEL contextAndElementIDSEL=NULL;
static SEL isParentSenderIDSearchOverSEL=NULL;
static SEL isSenderIDSearchOverSEL=NULL;

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
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      GetGSWContextIMPs(&_selfIMPs,self);
      [self _initWithContextID:(unsigned int)-1];
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogAssertGood(self);
  NSDebugFLog(@"Dealloc GSWContext %p. %@",
	      (void*)self, GSCurrentThread());
  NSDebugFLog0(@"Release GSWContext senderID");
  DESTROY(_senderID);
  NSDebugFLog0(@"Release GSWContext requestSessionID");
  DESTROY(_requestSessionID);
  NSDebugFLog0(@"Release GSWContext requestContextID");
  DESTROY(_requestContextID);
  NSDebugFLog0(@"Release GSWContext elementID");
  DESTROY(_elementID);
  if (_session)
    {
      NSDebugFLog(@"sessionCount=%u",[_session retainCount]);
    };
  NSDebugFLog0(@"Release GSWContext session");
  DESTROY(_session);
  NSDebugFLog0(@"Release GSWContext request");
  DESTROY(_request);
  NSDebugFLog0(@"Release GSWContext Response");
  DESTROY(_response);
  NSDebugFLog0(@"Release GSWContext pageElement");
  DESTROY(_pageElement);
  NSDebugFLog0(@"Release GSWContext pageComponent");
  DESTROY(_pageComponent);
  NSDebugFLog0(@"Release GSWContext currentComponent");
  DESTROY(_currentComponent);
  NSDebugFLog0(@"Release GSWContext url");
  DESTROY(_url);
  NSDebugFLog0(@"Release GSWContext awakePageComponents");
  DESTROY(_awakePageComponents);
#ifndef NDEBUG
  DESTROY(_docStructure);
  DESTROY(_docStructureElements);
#endif
  NSDebugFLog0(@"Release GSWContext userInfo");
  DESTROY(_userInfo);
  DESTROY(_languages);
  NSDebugFLog0(@"Dealloc GSWContext super");
  [super dealloc];
  NSDebugFLog0(@"end Dealloc GSWContext");
}

//--------------------------------------------------------------------
-(id)initWithRequest:(GSWRequest*)aRequest
{
  //OK
  LOGObjectFnStart();
  if ((self=[self init]))
    {
      [self _setRequest:aRequest];
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
+(GSWContext*)contextWithRequest:(GSWRequest*)aRequest
{
  //OK
  GSWContext* context=nil;
  LOGObjectFnStart();
  context=[[[self alloc]
             initWithRequest:aRequest]
            autorelease];
  LOGObjectFnStop();
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
      NSLog(@"self=%p clone=%p _elementID=%p",
                self,clone,_elementID);
      if (_elementID)
        {
          ASSIGNCOPY(clone->_elementID,_elementID);
          NSLog(@"self=%p clone=%p _elementID=%p clone->_elementID=%p",
                self,clone,_elementID,clone->_elementID);
          NSAssert(clone->_elementID,@"No clone elementID");
          
          GetGSWElementIDIMPs(&clone->_elementIDIMPs,clone->_elementID);
          NSLog(@"self=%p clone=%p _elementID=%p clone->_elementID=%p _elementIDIMPs._deleteAllElementIDComponentsIMP=%p",
                self,clone,_elementID,clone->_elementID,_elementIDIMPs._deleteAllElementIDComponentsIMP);
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
      clone->_isInForm=_isInForm;
      clone->_actionInvoked=_actionInvoked;
      clone->_formSubmitted=_formSubmitted;
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
                  object_get_class_name(self),
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
-(void)setInForm:(BOOL)flag
{
  _isInForm=flag;
};

//--------------------------------------------------------------------
-(BOOL)isInForm
{
  return _isInForm;
};

//--------------------------------------------------------------------
-(void)setInEnabledForm:(BOOL)flag
{
  _isInEnabledForm=flag;
};

//--------------------------------------------------------------------
-(BOOL)isInEnabledForm
{
  return _isInEnabledForm;
};

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
  LOGObjectFnStart();

  _isSessionDisabled=yn;
  NSDebugMLLog(@"sessions",@"_isSessionDisabled=%d",_isSessionDisabled);

  LOGObjectFnStop();
}

//--------------------------------------------------------------------
-(GSWSession*)_session
{
  if ([self isSessionDisabled])
    return nil;
  else
    return _session;
};

//--------------------------------------------------------------------
-(GSWSession*)session
{
  GSWSession* session=nil;

  LOGObjectFnStart();

  if (![self isSessionDisabled])
    {
      if (!_session)
        {
          NSString* requestSessionID=[self _requestSessionID];
          NSDebugMLLog(@"sessions",@"requestSessionID=%@",requestSessionID);
          if (requestSessionID)
            [GSWApp restoreSessionWithID:requestSessionID
                    inContext:self];//Application call context _setSession
        };
      if (!_session)
        [GSWApp _initializeSessionInContext:self]; //Application call context _setSession

      NSAssert(_session,@"Unable to create new session");

      session=_session;
    };
  NSDebugMLLog(@"sessions",@"session=%p",session);

  LOGObjectFnStop();

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

@end

//====================================================================
@implementation GSWContext (GSWURLGeneration)

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                           urlPrefix:(NSString*)urlPrefix
                                     queryDictionary:(NSDictionary*)queryDictionary
{
  GSWDynamicURLString* url=nil;

  LOGObjectFnStart();

  url=[self directActionURLForActionNamed:actionName
            urlPrefix:urlPrefix
            queryDictionary:queryDictionary
            isSecure:[[self request]isSecure]];

  LOGObjectFnStop();

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary
{
  GSWDynamicURLString* url=nil;

  LOGObjectFnStart();

  url=[self directActionURLForActionNamed:actionName
            urlPrefix:nil
            queryDictionary:queryDictionary];

  LOGObjectFnStop();

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                           urlPrefix:(NSString*)urlPrefix
                                     queryDictionary:(NSDictionary*)queryDictionary
                                 pathQueryDictionary:(NSDictionary*)pathQueryDictionary
{
  GSWDynamicURLString* url=nil;

  LOGObjectFnStart();

  url=[self directActionURLForActionNamed:actionName
            urlPrefix:urlPrefix
            queryDictionary:queryDictionary
            pathQueryDictionary:pathQueryDictionary
            isSecure:[[self request]isSecure]];

  LOGObjectFnStop();

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary
                                 pathQueryDictionary:(NSDictionary*)pathQueryDictionary
{
  GSWDynamicURLString* url=nil;

  LOGObjectFnStart();

  url=[self directActionURLForActionNamed:actionName
               urlPrefix:nil
               queryDictionary:queryDictionary
               pathQueryDictionary:pathQueryDictionary];

  LOGObjectFnStop();

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                           urlPrefix:(NSString*)urlPrefix
                                     queryDictionary:(NSDictionary*)queryDictionary
                                            isSecure:(BOOL)isSecure
{
  GSWDynamicURLString* url=nil;

  LOGObjectFnStart();

  url=[self directActionURLForActionNamed:actionName
            urlPrefix:urlPrefix
            queryDictionary:queryDictionary
            pathQueryDictionary:nil
            isSecure:isSecure];

  LOGObjectFnStop();

  return url;
};

//--------------------------------------------------------------------
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary
                                            isSecure:(BOOL)isSecure
{
  GSWDynamicURLString* url=nil;

  LOGObjectFnStart();

  url=[self directActionURLForActionNamed:actionName
            urlPrefix:nil
            queryDictionary:queryDictionary
            isSecure:isSecure];

  LOGObjectFnStop();

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

  LOGObjectFnStart();

  url=[self _directActionURLForActionNamed:actionName
            urlPrefix:urlPrefix
            queryDictionary:queryDictionary
            pathQueryDictionary:pathQueryDictionary
            isSecure:isSecure
            url:url];

  NSDebugMLLog(@"GSWContext",@"url=%@",url);

  LOGObjectFnStop();

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

  LOGObjectFnStartCond(dontTraceComponentActionURL==0);

  url=[self componentActionURLIsSecure:[[self request]isSecure]];

  LOGObjectFnStopCond(dontTraceComponentActionURL==0);

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
  LOGObjectFnStartCond(dontTraceComponentActionURL==0);
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"contextID=%u",_contextID);
/*
  url=[[url copy] autorelease];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"url=%@",url);
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"urlApplicationNumber=%d",_urlApplicationNumber);
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"[url urlApplicationNumber]=%d",[url urlApplicationNumber]);
  session=[self session]; //OK
  NSDebugMLLogCond(dontTraceComponentActionURL==0,@"sessions",@"session=%@",session);
  NSDebugMLLogCond(dontTraceComponentActionURL==0,@"sessions",@"sessionID=%@",[session sessionID]);
  elementID=[self elementID];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"elementID=%@",elementID);
  componentRequestHandlerKey=[GSWApplication componentRequestHandlerKey];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"componentRequestHandlerKey=%@",componentRequestHandlerKey);
  [url setURLRequestHandlerKey:componentRequestHandlerKey];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"url=%@",url);
  //call application pageCacheSize
  storesIDsInURLs=[session storesIDsInURLs];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"storesIDsInURLs=%s",(storesIDsInURLs ? "YES" : "NO"));
  if (storesIDsInURLs)
	{
	  NSString* sessionID=[session sessionID];
	  NSDebugMLogCond(dontTraceComponentActionURL==0,@"sessionID=%@",sessionID);
	  [url setURLRequestHandlerPath:[NSString stringWithFormat:@"%@/%u.%@",
          sessionID,
          contextID,
          elementID]];
	  NSDebugMLogCond(dontTraceComponentActionURL==0,@"url=%@",url);
	}
  else
	{
	  [url setURLRequestHandlerPath:[NSString stringWithFormat:@"/%u.%@", //??
											   _contextID,
											   elementID]];
	  NSDebugMLogCond(dontTraceComponentActionURL==0,@"url=%@",url);
	};
  [url setURLQueryString:nil]; //???
*/
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"urlApplicationNumber=%d",_urlApplicationNumber);
  session=[self session]; //OK
  NSDebugMLLogCond(dontTraceComponentActionURL==0,@"sessions",@"session=%@",session);
  NSDebugMLLogCond(dontTraceComponentActionURL==0,@"sessions",@"sessionID=%@",[session sessionID]);
  elementID=[self elementID];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"elementID=%@",elementID);
  componentRequestHandlerKey=[GSWApplication componentRequestHandlerKey];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"componentRequestHandlerKey=%@",componentRequestHandlerKey);
  
  requestHandlerKey=componentRequestHandlerKey;
  storesIDsInURLs=[session storesIDsInURLs];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"storesIDsInURLs=%s",(storesIDsInURLs ? "YES" : "NO"));

  if (storesIDsInURLs)
    {
      NSString* sessionID=[_session sessionID];
      NSDebugMLogCond(dontTraceComponentActionURL==0,@"sessionID=%@",sessionID);
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

  NSDebugMLogCond(dontTraceComponentActionURL==0,@"requestHandlerPath=%@",requestHandlerPath);
  url=[self urlWithRequestHandlerKey:requestHandlerKey
            path:requestHandlerPath
            queryString:nil
            isSecure:isSecure];
  NSDebugMLogCond(dontTraceComponentActionURL==0,@"url=%@",url);
  LOGObjectFnStopCond(dontTraceComponentActionURL==0);
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

  LOGObjectFnStartCond(dontTraceComponentActionURL==0);

  NSDebugMLLog(@"GSWContext",@"urlPrefix=%@",urlPrefix);
  NSDebugMLLog(@"GSWContext",@"requestHandlerKey=%@",requestHandlerKey);
  NSDebugMLLog(@"GSWContext",@"requestHandlerPath=%@",requestHandlerPath);
  NSDebugMLLog(@"GSWContext",@"queryString=%@",queryString);
  NSDebugMLLog(@"GSWContext",@"isSecure=%d",isSecure);
  NSDebugMLogCond(dontTraceComponentActionURL==0,
                  @"generateCompleteURLs=%s",
                  (_generateCompleteURLs ? "YES" : "NO"));

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

  NSDebugMLogCond(dontTraceComponentActionURL==0,
                  @"url=%@",url);

  LOGObjectFnStopCond(dontTraceComponentActionURL==0);

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

  LOGObjectFnStartCond(dontTraceComponentActionURL==0);

  url=[self urlWithURLPrefix:urlPrefix
              requestHandlerKey:requestHandlerKey
              path:requestHandlerPath
              queryString:queryString
              isSecure:[[self request]isSecure]];
  LOGObjectFnStopCond(dontTraceComponentActionURL==0);

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
  LOGObjectFnStartCond(dontTraceComponentActionURL==0);
  NSDebugMLogCond(dontTraceComponentActionURL==0,
                  @"generateCompleteURLs=%s",
                  (_generateCompleteURLs ? "YES" : "NO"));
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
  NSDebugMLogCond(dontTraceComponentActionURL==0,
                  @"url=%@",url);
  LOGObjectFnStopCond(dontTraceComponentActionURL==0);
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

  LOGObjectFnStartCond(dontTraceComponentActionURL==0);

  request=[self request];

  url=[self completeURLWithURLPrefix:urlPrefix
            requestHandlerKey:requestHandlerKey
            path:requestHandlerPath
            queryString:queryString
            isSecure:[request isSecure]
            port:[request urlPort]];

  LOGObjectFnStopCond(dontTraceComponentActionURL==0);

  return url;
};

//--------------------------------------------------------------------
//NDFN
-(GSWDynamicURLString*)completeURLWithRequestHandlerKey:(NSString*)requestHandlerKey
                                                   path:(NSString*)requestHandlerPath
                                            queryString:(NSString*)queryString
{
  GSWDynamicURLString* url=nil;

  LOGObjectFnStartCond(dontTraceComponentActionURL==0);

  url=[self completeURLWithURLPrefix:nil
            requestHandlerKey:requestHandlerKey
            path:requestHandlerPath
            queryString:queryString];

  LOGObjectFnStopCond(dontTraceComponentActionURL==0);

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

  LOGObjectFnStart();

  NSDebugMLLog(@"low",@"urlPrefix=%@",urlPrefix);
  NSDebugMLLog(@"low",@"requestHandlerKey=%@",requestHandlerKey);
  NSDebugMLLog(@"low",@"requestHandlerPath=%@",requestHandlerPath);
  NSDebugMLLog(@"low",@"queryString=%@",queryString);
  NSDebugMLLog(@"low",@"isSecure=%d",isSecure);

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

  NSDebugMLLog(@"low",@"url=%@",url);

  [url setURLApplicationNumber:_urlApplicationNumber];

  if (isSecure)
    [url setURLProtocol:GSWProtocol_HTTPS];
  else
    [url setURLProtocol:GSWProtocol_HTTP];

  if (port)
    [url setURLPort:port];
  NSDebugMLLog(@"low",@"url=%@",url);

  host=[request urlHost];
  NSAssert1(host,@"No host in request %@",request);
  NSDebugMLLog(@"low",@"host=%@",host);

  [url setURLHost:host];

  NSDebugMLLog(@"low",@"url=%@",url);

  LOGObjectFnStop();

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

  LOGObjectFnStart();

  url=[self completeURLWithURLPrefix:nil
            requestHandlerKey:requestHandlerKey
            path:requestHandlerPath
            queryString:queryString
            isSecure:isSecure
            port:port];

  LOGObjectFnStop();

  return url;
};
@end

//====================================================================
@implementation GSWContext (GSWContextA)

//--------------------------------------------------------------------
-(id)_initWithContextID:(unsigned int)contextID
{
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"contextID=%u",contextID);
  _contextID=contextID;
  DESTROY(_url);
  _url=[GSWDynamicURLString new];
  DESTROY(_awakePageComponents);
  _awakePageComponents=[NSMutableArray new];
  _urlApplicationNumber=-1;
  LOGObjectFnStop();
  return self;
};

@end

//====================================================================
@implementation GSWContext (GSWContextB)

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
  NSDebugMLLog(@"gswdync",@"Set Action invoked:%d",flag);
  _actionInvoked=flag;
};

//--------------------------------------------------------------------
-(BOOL)_wasFormSubmitted
{
  return _formSubmitted;
};

//--------------------------------------------------------------------
-(void)_setFormSubmitted:(BOOL)flag
{
  _formSubmitted=flag;
};

//--------------------------------------------------------------------
-(void)_putAwakeComponentsToSleep
{
  int i=0;
  int count=0;
  GSWComponent* component=nil;

  LOGObjectFnStart();

  NSDebugMLLog(@"low",@"awakePageComponents=%@",_awakePageComponents);
  count=[_awakePageComponents count];

  for(i=0;i<count;i++)
    {
      component=[_awakePageComponents objectAtIndex:i];
      [component sleepInContext:self];
    };
  LOGObjectFnStop();
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

  LOGObjectFnStart();

  url=[self _directActionURLForActionNamed:actionName
            urlPrefix:urlPrefix
            queryDictionary:dict
            pathQueryDictionary:nil
            url:anURL];

  LOGObjectFnStop();

  return url;
};

//--------------------------------------------------------------------
//_url is a semi complete one: line /cgi/WebObjects.exe/ObjCTest3.woa
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                      queryDictionary:(NSDictionary*)dict
                                                  url:(id)anURL
{
  GSWDynamicURLString* url=nil;

  LOGObjectFnStart();

  url=[self _directActionURLForActionNamed:actionName
            urlPrefix:nil
            queryDictionary:dict
            url:anURL];

  LOGObjectFnStop();
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

  LOGObjectFnStart();

  url=[self _directActionURLForActionNamed:actionName
            urlPrefix:urlPrefix
            queryDictionary:dict
            pathQueryDictionary:pathQueryDictionary
            isSecure:[[self request]isSecure]
            url:anURL];

  LOGObjectFnStop();

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

  LOGObjectFnStart();

  url=[self _directActionURLForActionNamed:actionName
            urlPrefix:nil
            queryDictionary:dict
            pathQueryDictionary:pathQueryDictionary
            url:anURL];

  LOGObjectFnStop();

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

  LOGObjectFnStart();

  url=[self _directActionURLForActionNamed:actionName
              urlPrefix:urlPrefix
              queryDictionary:dict
              pathQueryDictionary:nil
              isSecure:isSecure
              url:anURL];

  LOGObjectFnStop();

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

  LOGObjectFnStart();

  url=[self _directActionURLForActionNamed:actionName
            urlPrefix:nil
            queryDictionary:dict
            isSecure:isSecure
            url:anURL];

  LOGObjectFnStop();

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

  LOGObjectFnStart();

  NSDebugMLLog(@"GSWContext",@"actionName=%@",actionName);
  NSDebugMLLog(@"GSWContext",@"urlPrefix=%@",urlPrefix);
  NSDebugMLLog(@"GSWContext",@"dict=%@",dict);
  NSDebugMLLog(@"GSWContext",@"pathQueryDictionary=%@",pathQueryDictionary);
  NSDebugMLLog(@"GSWContext",@"isSecure=%d",isSecure);

  NSDebugMLogCond(dontTraceComponentActionURL==0,
                  @"anURL=%@",anURL);


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
      NSDebugMLLog(@"gswdync",@"pathQueryDictionary=%@",pathQueryDictionary);

      // append each key/value pair as /key=value
      for(i=0;i<count;i++)
        {
          id key = [keys objectAtIndex:i];
          id value = [pathQueryDictionary valueForKey:key];
          NSDebugMLLog(@"gswdync",@"key=%@",key);
          NSDebugMLLog(@"gswdync",@"value=%@",value);
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

  NSDebugMLogCond(dontTraceComponentActionURL==0,
                  @"url=%@",anURL);

  LOGObjectFnStop();

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

//--------------------------------------------------------------------
/** Returns array of languages 
First try  session languages, if none, try self language
If none, try request languages
**/
-(NSArray*)languages
{
  NSArray* languages=nil;

  LOGObjectFnStart();
  
  languages=[[self _session] languages];
  NSDebugMLLog(@"GSWContext",@"_session %p languages=%@",_session,languages);

  if ([languages count]==0)
    {
      languages=_languages;
      NSDebugMLLog(@"GSWContext",@"context %p languages=%@",self,languages);

      if ([languages count]==0)
        {
          languages=[[self request]browserLanguages];
          NSDebugMLLog(@"GSWContext",@"resquest %p browserLanguages=%@",[self request],languages);
        }
    };

  NSDebugMLLog(@"GSWContext",@"context %p ==> languages=%@",self,languages);

  //GSWeb specific: It enable application languages filtering
  languages=[GSWApp filterLanguages:languages];
  NSDebugMLLog(@"GSWContext",@"context %p ==> filtered languages=%@",self,languages);

  LOGObjectFnStop();

  return languages;
};

//--------------------------------------------------------------------
-(void)_setLanguages:(NSArray*)languages
{
  LOGObjectFnStart();

  NSDebugMLLog(@"GSWContext",@"languages=%@",languages);

  ASSIGNCOPY(_languages,languages);

  LOGObjectFnStop();
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
  LOGObjectFnStart();
  if (_pageElement!=element)
    {
      ASSIGN(_pageElement,element);

      [self _setPageComponent:nil];
      
      if ([element isKindOfClass:[GSWComponent class]])
        [self _setPageComponent:(GSWComponent*)element];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setPageComponent:(GSWComponent*)component
{
  LOGObjectFnStart();
  ASSIGN(_pageComponent,component);
  if (component)
    [self _takeAwakeComponent:component];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setResponse:(GSWResponse*)aResponse
{
  //OK
  LOGObjectFnStart();
  ASSIGN(_response,aResponse);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setRequest:(GSWRequest*)aRequest
{
  //OK
  NSString* adaptorPrefix=nil;
  NSString* applicationName=nil;

  LOGObjectFnStart();

  if (_request!=aRequest)
    {
      NSDebugMLLog(@"low",@"aRequest=%@",aRequest);
      ASSIGN(_request,aRequest);

      [_request _setContext:self];

      NSDebugMLLog(@"low",@"url=%@",_url);

      adaptorPrefix=[aRequest adaptorPrefix];
      NSDebugMLLog(@"low",@"adaptorPrefix=%@",adaptorPrefix);
      [_url setURLPrefix:adaptorPrefix];

      NSDebugMLLog(@"low",@"url=%@",_url);

      applicationName=[aRequest applicationName];
      NSDebugMLLog(@"low",@"applicationName=%@",applicationName);
      [_url setURLApplicationName:applicationName];

      NSDebugMLLog(@"low",@"url=%@",_url);

      [self _synchronizeForDistribution];
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setSession:(GSWSession*)aSession
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"sessions",@"aSession ID:%@",[aSession sessionID]);
  if (_session!=aSession)
    {
      ASSIGN(_session,aSession);
      [self _synchronizeForDistribution];
    };
  if (_session)
    {
      NSDebugMLLog(@"low",@"contextID=%u",_contextID);
      _contextID=[_session _contextCounter];
      NSDebugMLLog(@"low",@"contextID=%u",_contextID);
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_setSenderID:(NSString*)aSenderID
{
  LOGObjectFnStart();
  ASSIGNCOPY(_senderID,aSenderID);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_synchronizeForDistribution
{
  int instance=-1;

  LOGObjectFnStart();

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
          
          NSDebugMLLog(@"GSWContext",@"storesIDsInURLs=%d",storesIDsInURLs);
          NSDebugMLLog(@"GSWContext",@"isDistributionEnabled=%d",isDistributionEnabled);
          
          NSDebugMLLog(@"GSWContext",@"_session=%p",_session);
          NSDebugMLLog(@"GSWContext",@"_request=%p",_request);
          
          sessionID=[_request sessionID];
        };

      instance=[_request applicationNumber];

      NSDebugMLLog(@"GSWContext",@"instance=%d",instance);
      NSDebugMLLog(@"GSWContext",@"sessionID=%@",sessionID);

      // Set instance to -1 
      // if we don't store IDs in URLs and distribution is enabled
      // or if we don't have session nor session id
      if ((isDistributionEnabled && !storesIDsInURLs)
          || (!session && !sessionID))
        instance=-1;
    };

  NSDebugMLLog(@"GSWContext",@"instance=%d",instance);

  _urlApplicationNumber = instance;
  [_url setURLApplicationNumber:instance];

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_incrementContextID
{
  _contextID++;
  [_session _contextDidIncrementContextID];
};

//--------------------------------------------------------------------
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
  //OK
  LOGObjectFnStart();
  ASSIGN(_currentComponent,component);
  LOGObjectFnStop();
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
  LOGObjectFnStart();
  ASSIGNCOPY(_requestSessionID,aSessionID);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSString*)_requestSessionID
{
  return _requestSessionID;
};

//--------------------------------------------------------------------
-(void)_takeAwakeComponentsFromArray:(NSArray*)components
{
  LOGObjectFnStart();
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
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)_takeAwakeComponent:(GSWComponent*)component
{
  //OK
  LOGObjectFnStart();
  NSDebugMLLog(@"low",@"component: %@",[component class]);
  if (!_awakePageComponents)
    _awakePageComponents=[NSMutableArray new];
  if (![_awakePageComponents containsObject:component])
    [_awakePageComponents addObject:component];
  LOGObjectFnStop();
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

//--------------------------------------------------------------------
// context can add key/values in query dictionary
-(NSDictionary*)computeQueryDictionary:(NSDictionary*)queryDictionary
{
  //Do nothing
  return queryDictionary;
};

//--------------------------------------------------------------------
// context can add key/values in query dictionary
-(NSDictionary*)computePathQueryDictionary:(NSDictionary*)queryDictionary
{
  //Do nothing
  return queryDictionary;
};

@end

//====================================================================
@implementation GSWContext (GSWContextElementID)

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

@end

//====================================================================
@implementation GSWContext (GSWContextD)
//--------------------------------------------------------------------
-(NSString*)url
{
  //OK
  GSWDynamicURLString* componentActionURL=nil;
  LOGObjectFnStart();
  componentActionURL=[self componentActionURL];
  LOGObjectFnStop();
  return (NSString*)componentActionURL;
};

//--------------------------------------------------------------------
//	urlSessionPrefix

// return http://my.host.org/cgi-bin/GSWeb/MyApp.ApplicationSuffix/123456789012334567890123456789
-(NSString*)urlSessionPrefix 
{
  LOGObjectFnNotImplemented();	//TODOFN
  NSDebugMLLog(@"low",@"[request urlProtocolHorstPort]=%@",[_request urlProtocolHostPort]);
  NSDebugMLLog(@"low",@"[request adaptorPrefix]=%@",[_request adaptorPrefix]);
  NSDebugMLLog(@"low",@"[request applicationName]=%@",[_request applicationName]);
  NSDebugMLLog(@"low",@"[session sessionID]=%@",[[self _session] sessionID]);
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

@end

//====================================================================
@implementation GSWContext (GSWContextGSWeb)
-(BOOL)isValidate
{
  return _isValidate;
};

//--------------------------------------------------------------------
-(void)setValidate:(BOOL)isValidate
{
  _isValidate = isValidate;
  NSDebugMLLog(@"low",@"isValidate=%d",(int)isValidate);
};

@end

