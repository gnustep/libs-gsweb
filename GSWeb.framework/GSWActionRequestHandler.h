/** GSWActionRequestHandler.h - <title>GSWeb: Class GSWActionRequestHandler</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 1999
   
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

#ifndef _GSWActionRequestHandler_h__
	#define _GSWActionRequestHandler_h__


@interface GSWActionRequestHandler: GSWRequestHandler
{
  NSString* _actionClassName;
  NSString* _defaultActionName;
  Class _actionClassClass;
  BOOL _shouldAddToStatistics;  
};

-(NSString*)defaultActionClassName;
-(NSString*)defaultDefaultActionName;
-(BOOL)defaultShouldAddToStatistics;

-(id)initWithDefaultActionClassName:(NSString*)defaultActionClassName
                  defaultActionName:(NSString*)defaultActionName
              shouldAddToStatistics:(BOOL)shouldAddToStatistics;

-(void)registerWillHandleActionRequest;
-(void)registerDidHandleActionRequestWithActionNamed:(NSString*)actionName;

-(GSWResponse*)handleRequest:(GSWRequest*)aRequest;
-(NSArray*)getRequestHandlerPathForRequest:(GSWRequest*)aRequest;
+(Class)_actionClassForName:(NSString*)name;
-(void)getRequestActionClassNameInto:(NSString**)actionClassNamePtr
                           classInto:(Class*)actionClassPtr
                            nameInto:(NSString**)actionNamePtr
                             forPath:(NSArray*)path;
-(GSWResponse*)_handleRequest:(GSWRequest*)aRequest;


-(GSWResponse*)generateNullResponse;
-(GSWResponse*)generateRequestRefusalResponseForRequest:(GSWRequest*)aRequest;
-(GSWResponse*)generateErrorResponseWithException:(NSException*)error
                                        inContext:(GSWContext*)aContext;

@end

//====================================================================
@interface GSWActionRequestHandler (GSWRequestHandlerClassA)
+(id)handler;
+(GSWActionRequestHandler*)handlerWithDefaultActionClassName:(NSString*)defaultActionClassName
                                           defaultActionName:(NSString*)defaultActionName
                                       shouldAddToStatistics:(BOOL)shouldAddToStatistics;
@end




#endif //GSWActionRequestHandler
