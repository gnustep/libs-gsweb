/* GSWContext.h - GSWeb: Class GSWContext
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
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

#ifndef _GSWContext_h__
	#define _GSWContext_h__


//====================================================================
@interface GSWContext : NSObject <NSCopying>
{
@private
  unsigned contextID;
 NSString* senderID;
 NSString* requestSessionID;
 GSWElementIDString* elementID;
 GSWSession* session;
 GSWRequest* request;
 GSWResponse* response;
 GSWElement* pageElement;
 GSWComponent* pageComponent;
 GSWComponent* currentComponent;
 GSWDynamicURLString* url;
 NSMutableArray* awakePageComponents;
 int urlApplicationNumber;
 int isClientComponentRequest;
 BOOL distributionEnabled;
 BOOL pageChanged;
 BOOL pageReplaced;
 BOOL generateCompleteURLs;
 BOOL isInForm;
 BOOL actionInvoked;
 BOOL formSubmitted;
 BOOL isMultipleSubmitForm;
 BOOL isValidate;
};

-(id)init;
-(void)dealloc;
+(GSWContext*)contextWithRequest:(GSWRequest*)request_;

-(id)copyWithZone:(NSZone*)zone_;

-(void)setInForm:(BOOL)_flag;
-(BOOL)isInForm;
-(GSWElementIDString*)elementID;
-(GSWComponent*)component;
-(GSWComponent*)page;
-(GSWResponse*)response;
-(GSWRequest*)request;
-(GSWSession*)session;
-(BOOL)hasSession;
-(NSString*)senderID;
-(NSString*)contextID;
-(id)initWithRequest:(GSWRequest*)_request;

@end

//====================================================================
@interface GSWContext (GSWURLGeneration)
-(GSWDynamicURLString*)directActionURLForActionNamed:(NSString*)actionName_
									 queryDictionary:(NSDictionary*)queryDictionary_;
-(GSWDynamicURLString*)componentActionURL;
-(GSWDynamicURLString*)urlWithRequestHandlerKey:(NSString*)requestHandlerKey_
										   path:(NSString*)requestHandlerPath_
									queryString:(NSString*)queryString_;
//NDFN
-(GSWDynamicURLString*)completeURLWithRequestHandlerKey:(NSString*)requestHandlerKey_
												   path:(NSString*)requestHandlerPath_
											queryString:(NSString*)queryString_;
-(GSWDynamicURLString*)completeURLWithRequestHandlerKey:(NSString*)requestHandlerKey_
												   path:(NSString*)requestHandlerPath_
											queryString:(NSString*)queryString_
											   isSecure:(BOOL)isSecure_
												   port:(int)port_;
@end

//====================================================================
@interface GSWContext (GSWContextA)
-(id)_initWithContextID:(unsigned int)context_ID;
@end

//====================================================================
@interface GSWContext (GSWContextB)
-(BOOL)_isMultipleSubmitForm;
-(void)_setIsMultipleSubmitForm:(BOOL)_flag;
-(BOOL)_wasActionInvoked;
-(void)_setActionInvoked:(BOOL)_flag;
-(BOOL)_wasFormSubmitted;
-(void)_setFormSubmitted:(BOOL)_flag;
-(void)_putAwakeComponentsToSleep;
-(void)_generateCompleteURLs;
-(GSWDynamicURLString*)_directActionURLForActionNamed:(NSString*)_actionName
									 queryDictionary:(NSDictionary*)_dict
												 url:(id)_url;
-(NSArray*)languages;
-(GSWComponent*)_pageComponent;
-(GSWElement*)_pageElement;
-(void)_setPageElement:(GSWElement*)_element;
-(void)_setPageComponent:(GSWComponent*)_component;
-(void)_setResponse:(GSWResponse*)response_;
-(void)_setRequest:(GSWRequest*)_request;
-(void)_setSession:(GSWSession*)_session;
-(void)_setSenderID:(NSString*)_senderID;
-(void)_synchronizeForDistribution;
-(void)_incrementContextID;
-(GSWSession*)existingSession;
-(void)_setCurrentComponent:(GSWComponent*)_component;
-(void)_setPageReplaced:(BOOL)_flag;
-(BOOL)_pageReplaced; 
-(void)_setPageChanged:(BOOL)_flag;
-(BOOL)_pageChanged; 
-(void)_setRequestSessionID:(NSString*)_sessionID;
-(NSString*)_requestSessionID;
-(void)_takeAwakeComponentsFromArray:(id)_unknwon;
-(void)_takeAwakeComponent:(GSWComponent*)_component;

@end

//====================================================================
@interface GSWContext (GSWContextC)
-(void)deleteAllElementIDComponents;
-(void)deleteLastElementIDComponent;
-(void)incrementLastElementIDComponent;
-(void)appendElementIDComponent:(NSString*)string_;
-(void)appendZeroElementIDComponent;
@end

//====================================================================
@interface GSWContext (GSWContextD)
-(NSString*)url;
-(NSString*)urlSessionPrefix;
-(GSWApplication*)application;
-(void)setDistributionEnabled:(BOOL)flag_;
-(BOOL)isDistributionEnabled;
@end

//====================================================================
@interface GSWContext (GSWContextGSWeb)
-(BOOL)isValidate;
-(void)setValidate:(BOOL)isValidate_;
@end

#endif //_GSWContext_h__


