/** GSWContext.h - <title>GSWeb: Class GSWContext</title>

   Copyright (C) 1999-2005 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
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

#ifndef _GSWContext_h__
	#define _GSWContext_h__

@class GSWContext;

typedef struct _GSWContextIMPs
{
  IMP _incrementLastElementIDComponentIMP;
  IMP _appendElementIDComponentIMP;
  IMP _appendZeroElementIDComponentIMP;
  IMP _deleteAllElementIDComponentsIMP;
  IMP _deleteLastElementIDComponentIMP;
  IMP _elementIDIMP;
  IMP _componentIMP;
  IMP _senderIDIMP;
  IMP _contextAndElementIDIMP;
  GSWIMP_BOOL _isParentSenderIDSearchOverIMP;
  GSWIMP_BOOL _isSenderIDSearchOverIMP;
} GSWContextIMPs;

/** Fill impsPtr structure with IMPs for context **/
GSWEB_EXPORT void GetGSWContextIMPs(GSWContextIMPs* impsPtr,GSWContext* context);

/** functions to accelerate calls of frequently used GSWContext methods **/
GSWEB_EXPORT void GSWContext_incrementLastElementIDComponent(GSWContext* aContext);
GSWEB_EXPORT void GSWContext_appendElementIDComponent(GSWContext* aContext,NSString* component);
GSWEB_EXPORT void GSWContext_appendZeroElementIDComponent(GSWContext* aContext);
GSWEB_EXPORT void GSWContext_deleteAllElementIDComponents(GSWContext* aContext);
GSWEB_EXPORT void GSWContext_deleteLastElementIDComponent(GSWContext* aContext);
GSWEB_EXPORT NSString* GSWContext_elementID(GSWContext* aContext);
GSWEB_EXPORT GSWComponent* GSWContext_component(GSWContext* aContext);
GSWEB_EXPORT NSString* GSWContext_senderID(GSWContext* aContext);
GSWEB_EXPORT NSString* GSWContext_contextAndElementID(GSWContext* aContext);
GSWEB_EXPORT BOOL GSWContext_isParentSenderIDSearchOver(GSWContext* aContext);
GSWEB_EXPORT BOOL GSWContext_isSenderIDSearchOver(GSWContext* aContext);

//====================================================================
@interface GSWContext : NSObject <NSCopying>
{
@private
 GSWResourceManager* _resourceManager;
  unsigned _contextID;
 NSString* _senderID;
 NSString* _requestSessionID;
 NSString* _requestContextID;
 NSString* _componentName;
 GSWComponentDefinition* _tempComponentDefinition; 
 GSWElementID* _elementID;
 GSWSession* _session;
 GSWRequest* _request;
 GSWResponse* _response;
 GSWElement* _pageElement;
 GSWComponent* _pageComponent;
 GSWComponent* _currentComponent;
 GSWDynamicURLString* _url;
 NSMutableArray* _awakePageComponents;
 int _urlApplicationNumber;
 int _isClientComponentRequest;
 BOOL _distributionEnabled;
 BOOL _pageChanged;
 BOOL _pageReplaced;
 BOOL _generateCompleteURLs;
 BOOL _inForm;
 BOOL _isInEnabledForm;
 BOOL _actionInvoked;
 BOOL _formSubmitted;
 BOOL _isMultipleSubmitForm;
 BOOL _isValidate;
#ifndef NDEBUG
 int _loopLevel; //ForDebugging purpose: each repetition increment and next decrement it
 NSMutableString* _docStructure; //ForDebugging purpose: array of all objects if the document during appendResponse, takeValues, invokeAction
 NSMutableSet* _docStructureElements;
#endif
 NSMutableDictionary* _userInfo;
 NSArray* _languages;
 BOOL _isRefusingThisRequest;
 BOOL _isSessionDisabled;
 
 // IMPs for elementID manipulations
 // As there's not many GSWContext objects, using some extra memory is not a problem
 GSWElementIDIMPs _elementIDIMPs;
@public // So we can use it in functions
 GSWContextIMPs _selfIMPs;
};

/** Set GSWContext standard class (so we can use pre-build GSWContextIMPs) **/
+(void)setStandardClass:(Class)standardClass;

+(GSWContext*)contextWithRequest:(GSWRequest*)aRequest;

-(void)setInForm:(BOOL)flag;
-(BOOL)isInForm;
-(void)setInEnabledForm:(BOOL)flag;
-(BOOL)isInEnabledForm;
- (GSWDynamicURLString*) _url;
-(void)_createElementID;
-(NSString*)elementID;
-(NSString*)contextAndElementID;
-(GSWComponent*)component;
-(NSString*) _componentName;
- (void) _setComponentName:(NSString*) newValue;
- (GSWComponentDefinition*) _tempComponentDefinition;
- (void) _setTempComponentDefinition:(GSWComponentDefinition*) newValue;

-(GSWComponent*)page;
-(GSWResponse*)response;
-(GSWRequest*)request;
-(GSWSession*)_session;
-(GSWSession*)session;
-(BOOL)hasSession;

/** return YES is session creation|restoration is disabled **/
-(BOOL)isSessionDisabled;

/** pass YES as argument to disable  session creation|restoration **/
-(void)setIsSessionDisabled:(BOOL)yn;

-(NSString*)senderID;
-(NSString*)contextID;
-(id)initWithRequest:(GSWRequest*)aRequest;
-(BOOL)_isRefusingThisRequest;
-(void)_setIsRefusingThisRequest:(BOOL)yn;

#ifndef NDEBUG
-(void)incrementLoopLevel; //ForDebugging purpose: each repetition increment and next decrement it
-(void)decrementLoopLevel;
-(BOOL)isInLoop;
-(void)addToDocStructureElement:(id)element;
-(void)addDocStructureStep:(NSString*)stepLabel;
-(NSString*)docStructure;
#endif

-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                           urlPrefix:(NSString*)urlPrefix
                                     queryDictionary:(NSDictionary*)queryDictionary;
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary;

-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                           urlPrefix:(NSString*)urlPrefix
                                     queryDictionary:(NSDictionary*)queryDictionary
                                 pathQueryDictionary:(NSDictionary*)pathQueryDictionary;

-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary
                                 pathQueryDictionary:(NSDictionary*)pathQueryDictionary;

-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                           urlPrefix:(NSString*)urlPrefix
                                     queryDictionary:(NSDictionary*)queryDictionary
                                            isSecure:(BOOL)isSecure;

-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary
                                            isSecure:(BOOL)isSecure;

-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                           urlPrefix:(NSString*)urlPrefix
                                     queryDictionary:(NSDictionary*)queryDictionary
                                 pathQueryDictionary:(NSDictionary*)pathQueryDictionary
                                            isSecure:(BOOL)isSecure;

-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary
                                 pathQueryDictionary:(NSDictionary*)pathQueryDictionary
                                            isSecure:(BOOL)isSecure;
-(GSWDynamicURLString*)componentActionURL;
-(GSWDynamicURLString*)componentActionURLIsSecure:(BOOL)isSecure;

-(GSWDynamicURLString*)urlWithURLPrefix:(NSString*)urlPrefix
                      requestHandlerKey:(NSString*)requestHandlerKey
                                   path:(NSString*)requestHandlerPath
                            queryString:(NSString*)queryString
                               isSecure:(BOOL)isSecure
                                   port:(int)port;

-(GSWDynamicURLString*)urlWithRequestHandlerKey:(NSString*)requestHandlerKey
                                           path:(NSString*)requestHandlerPath
                                    queryString:(NSString*)queryString
                                       isSecure:(BOOL)isSecure
                                           port:(int)port;

-(GSWDynamicURLString*)urlWithURLPrefix:(NSString*)urlPrefix
                      requestHandlerKey:(NSString*)requestHandlerKey
                                   path:(NSString*)requestHandlerPath
                            queryString:(NSString*)queryString;

-(GSWDynamicURLString*)urlWithURLPrefix:(NSString*)urlPrefix
                      requestHandlerKey:(NSString*)requestHandlerKey
                                   path:(NSString*)requestHandlerPath
                            queryString:(NSString*)queryString
                               isSecure:(BOOL)isSecure;

-(GSWDynamicURLString*)urlWithRequestHandlerKey:(NSString*)requestHandlerKey
                                           path:(NSString*)requestHandlerPath
                                    queryString:(NSString*)queryString;

//NDFN
-(GSWDynamicURLString*)completeURLWithURLPrefix:(NSString*)urlPrefix
                              requestHandlerKey:(NSString*)requestHandlerKey
                                           path:(NSString*)requestHandlerPath
                                    queryString:(NSString*)queryString;

//NDFN
-(GSWDynamicURLString*)urlWithRequestHandlerKey:(NSString*)requestHandlerKey
                                           path:(NSString*)requestHandlerPath
                                    queryString:(NSString*)queryString
                                       isSecure:(BOOL)isSecure;

//NDFN
-(GSWDynamicURLString*)completeURLWithRequestHandlerKey:(NSString*)requestHandlerKey
                                                   path:(NSString*)requestHandlerPath
                                            queryString:(NSString*)queryString;

-(GSWDynamicURLString*)completeURLWithURLPrefix:(NSString*)urlPrefix
                              requestHandlerKey:(NSString*)requestHandlerKey
                                           path:(NSString*)requestHandlerPath
                                    queryString:(NSString*)queryString
                                       isSecure:(BOOL)isSecure
                                           port:(int)port;

-(GSWDynamicURLString*)completeURLWithRequestHandlerKey:(NSString*)requestHandlerKey
                                                   path:(NSString*)requestHandlerPath
                                            queryString:(NSString*)queryString
                                               isSecure:(BOOL)isSecure
                                                   port:(int)port;

-(id)_initWithContextID:(unsigned int)contextID;

-(BOOL)_isMultipleSubmitForm;
-(void)_setIsMultipleSubmitForm:(BOOL)flag;
-(BOOL)_wasActionInvoked;
-(void)_setActionInvoked:(BOOL)flag;
-(BOOL)_wasFormSubmitted;
-(void)_setFormSubmitted:(BOOL)flag;
-(void)_putAwakeComponentsToSleep;
-(BOOL)_generateCompleteURLs;
-(BOOL)_generateRelativeURLs;
-(BOOL)isGeneratingCompleteURLs;
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                            urlPrefix:(NSString*)urlPrefix
                                      queryDictionary:(NSDictionary*)dict
                                                  url:(id)anURL;

-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                      queryDictionary:(NSDictionary*)dict
                                             isSecure:(BOOL)isSecure
                                                  url:(id)anURL;

-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                            urlPrefix:(NSString*)urlPrefix
                                      queryDictionary:(NSDictionary*)dict
                                  pathQueryDictionary:(NSDictionary*)pathQueryDictionary
                                                  url:(id)anURL;

-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                            urlPrefix:(NSString*)urlPrefix
                                      queryDictionary:(NSDictionary*)dict
                                             isSecure:(BOOL)isSecure
                                                  url:(id)anURL;

-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                            urlPrefix:(NSString*)urlPrefix
                                      queryDictionary:(NSDictionary*)dict
                                  pathQueryDictionary:(NSDictionary*)pathQueryDictionary
                                             isSecure:(BOOL)isSecure
                                                  url:(id)anURL;

-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                      queryDictionary:(NSDictionary*)dict
                                  pathQueryDictionary:(NSDictionary*)pathQueryDictionary
                                             isSecure:(BOOL)isSecure
                                                  url:(id)anURL;
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                      queryDictionary:(NSDictionary*)dict
                                                  url:(id)url;
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                      queryDictionary:(NSDictionary*)dict
                                  pathQueryDictionary:(NSDictionary*)pathQueryDictionary
                                                  url:(id)url;

-(GSWDynamicURLString*) _componentActionURL;
                                                  
/** Returns array of languages 
First try  session languages, if none, try self language
If none, try request languages
**/
-(NSArray*)languages;

-(void)_setLanguages:(NSArray*)languages;

-(GSWComponent*)_pageComponent;
-(GSWElement*)_pageElement;
-(void)_setPageElement:(GSWElement*)element;
-(void)_setPageComponent:(GSWComponent*)component;
-(void)_setResponse:(GSWResponse*)aResponse;
-(void)_setRequest:(GSWRequest*)aRequest;
-(void)_setSession:(GSWSession*)aSession;
-(void)_setSenderID:(NSString*)aSenderID;
-(void)_synchronizeForDistribution;
-(void)_incrementContextID;
-(GSWSession*)existingSession;
-(void)_setCurrentComponent:(GSWComponent*)aComponent;
-(void)_setPageReplaced:(BOOL)flag;
-(BOOL)_pageReplaced; 
-(void)_setPageChanged:(BOOL)flag;
-(BOOL)_pageChanged; 
-(void)_setRequestContextID:(NSString*)contextID;
-(NSString*)_requestContextID;
-(void)_setRequestSessionID:(NSString*)sessionID;
-(NSString*)_requestSessionID;
-(void)_takeAwakeComponentsFromArray:(NSArray*)components;
-(void)_takeAwakeComponent:(GSWComponent*)aComponent;
-(NSMutableDictionary*)userInfo;
-(NSMutableDictionary*)_userInfo;
-(void)_setUserInfo:(NSMutableDictionary*)userInfo;

// context can add key/values in query dictionary
-(NSDictionary*)computeQueryDictionary:(NSDictionary*)queryDictionary;
-(NSDictionary*)computePathQueryDictionary:(NSDictionary*)queryDictionary;

-(void)deleteAllElementIDComponents;
-(void)deleteLastElementIDComponent;
-(void)incrementLastElementIDComponent;
-(void)appendElementIDComponent:(NSString*)string;
-(void)appendZeroElementIDComponent;

-(BOOL)isParentSenderIDSearchOver;
-(BOOL)isSenderIDSearchOver;
-(int)elementIDElementsCount;

-(NSString*)url;
-(NSString*)urlSessionPrefix;
-(int)urlApplicationNumber;
-(GSWApplication*)application;
-(void)setDistributionEnabled:(BOOL)flag;
-(BOOL)isDistributionEnabled;

- (NSString*) _urlForResourceNamed: (NSString*)aName 
                       inFramework: (NSString*)frameworkName;

-(BOOL)isValidate;
-(void)setValidate:(BOOL)isValidate;
@end

#endif //_GSWContext_h__


