/** GSWContext.h - <title>GSWeb: Class GSWContext</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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


//====================================================================
@interface GSWContext : NSObject <NSCopying>
{
@private
  unsigned _contextID;
 NSString* _senderID;
 NSString* _requestSessionID;
 NSString* _requestContextID;
 GSWElementIDString* _elementID;
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
 BOOL _isInForm;
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
};

-(id)init;
-(void)dealloc;
+(GSWContext*)contextWithRequest:(GSWRequest*)aRequest;

-(id)copyWithZone:(NSZone*)zone;

-(void)setInForm:(BOOL)flag;
-(BOOL)isInForm;
-(GSWElementIDString*)elementID;
-(GSWComponent*)component;
-(GSWComponent*)page;
-(GSWResponse*)response;
-(GSWRequest*)request;
-(GSWSession*)_session;
-(GSWSession*)session;
-(BOOL)hasSession;
-(NSString*)senderID;
-(NSString*)contextID;
-(id)initWithRequest:(GSWRequest*)aRequest;

#ifndef NDEBUG
-(void)incrementLoopLevel; //ForDebugging purpose: each repetition increment and next decrement it
-(void)decrementLoopLevel;
-(BOOL)isInLoop;
-(void)addToDocStructureElement:(id)element;
-(void)addDocStructureStep:(NSString*)stepLabel;
-(NSString*)docStructure;
#endif
@end

//====================================================================
@interface GSWContext (GSWURLGeneration)
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary;
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName
                                     queryDictionary:(NSDictionary*)queryDictionary
                                            isSecure:(BOOL)isSecure;
-(GSWDynamicURLString*)componentActionURL;
-(GSWDynamicURLString*)componentActionURLIsSecure:(BOOL)isSecure;
-(GSWDynamicURLString*)urlWithRequestHandlerKey:(NSString*)requestHandlerKey
                                           path:(NSString*)requestHandlerPath
                                    queryString:(NSString*)queryString
                                       isSecure:(BOOL)isSecure
                                           port:(int)port;
-(GSWDynamicURLString*)urlWithRequestHandlerKey:(NSString*)requestHandlerKey
                                           path:(NSString*)requestHandlerPath
                                    queryString:(NSString*)queryString;
//NDFN
-(GSWDynamicURLString*)completeURLWithRequestHandlerKey:(NSString*)requestHandlerKey
                                                   path:(NSString*)requestHandlerPath
                                            queryString:(NSString*)queryString;
-(GSWDynamicURLString*)completeURLWithRequestHandlerKey:(NSString*)requestHandlerKey
                                                   path:(NSString*)requestHandlerPath
                                            queryString:(NSString*)queryString
                                               isSecure:(BOOL)isSecure
                                                   port:(int)port;
@end

//====================================================================
@interface GSWContext (GSWContextA)
-(id)_initWithContextID:(unsigned int)contextID;
@end

//====================================================================
@interface GSWContext (GSWContextB)
-(BOOL)_isMultipleSubmitForm;
-(void)_setIsMultipleSubmitForm:(BOOL)flag;
-(BOOL)_wasActionInvoked;
-(void)_setActionInvoked:(BOOL)flag;
-(BOOL)_wasFormSubmitted;
-(void)_setFormSubmitted:(BOOL)flag;
-(void)_putAwakeComponentsToSleep;
-(BOOL)_generateCompleteURLs;
-(BOOL)_generateRelativeURLs;
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                      queryDictionary:(NSDictionary*)dict
                                             isSecure:(BOOL)isSecure
                                                  url:(id)anURL;
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)actionName
                                      queryDictionary:(NSDictionary*)dict
                                                  url:(id)url;
-(NSArray*)languages;
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
@end

//====================================================================
@interface GSWContext (GSWContextC)
-(void)deleteAllElementIDComponents;
-(void)deleteLastElementIDComponent;
-(void)incrementLastElementIDComponent;
-(void)appendElementIDComponent:(NSString*)string;
-(void)appendZeroElementIDComponent;
@end

//====================================================================
@interface GSWContext (GSWContextD)
-(NSString*)url;
-(NSString*)urlSessionPrefix;
-(GSWApplication*)application;
-(void)setDistributionEnabled:(BOOL)flag;
-(BOOL)isDistributionEnabled;
@end

//====================================================================
@interface GSWContext (GSWContextGSWeb)
-(BOOL)isValidate;
-(void)setValidate:(BOOL)isValidate;
@end

#endif //_GSWContext_h__


