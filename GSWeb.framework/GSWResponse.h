/** GSWResponse.h - <title>GSWeb: Class GSWResponse</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
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

#ifndef _GSWResponse_h__
	#define _GSWResponse_h__

//====================================================================
@protocol GSWActionResults
-(GSWResponse*)generateResponse;
@end

//====================================================================
@interface GSWResponse : GSWMessage
{
@private
  unsigned int _status;
  NSMutableArray* _contentFaults;
  NSFileHandle* _contentStreamFileHandle;
  unsigned int _contentStreamBufferSize;
  unsigned long _contentStreamBufferLength;
  NSArray* _acceptedEncodings;
  BOOL _canDisableClientCaching;
  BOOL _isClientCachingDisabled;
  BOOL _contentFaultsHaveBeenResolved;
  BOOL _isFinalizeInContextHasBeenCalled;
};

-(void)willSend;//NDFN
-(void)forceFinalizeInContext;
-(void)setStatus:(unsigned int)status;
-(void)setAcceptedEncodings:(NSArray*)acceptedEncodings;
-(NSArray*)acceptedEncodings;
-(unsigned int)status;
-(NSString*)description;

-(void)disableClientCaching;

// should be called before finalizeInContext
-(void)setCanDisableClientCaching:(BOOL)yn;

@end

//====================================================================
@interface GSWResponse (GSWResponseA)
-(BOOL)isFinalizeInContextHasBeenCalled;//NDFN
-(void)_finalizeInContext:(GSWContext*)context;
-(void)_appendTagAttribute:(NSString*)attributeName
                     value:(id)value
escapingHTMLAttributeValue:(BOOL)escape;

@end

//====================================================================
@interface GSWResponse (GSWResponseB)
-(void)_resolveContentFaultsInContext:(GSWContext*)context;
-(void)_appendContentFault:(id)unknown;

@end

//====================================================================
@interface GSWResponse (GSWResponseC)
-(BOOL)_isClientCachingDisabled;
-(unsigned int)_contentDataLength;
@end

//====================================================================
@interface GSWResponse (GSWResponseD)
-(BOOL)_responseIsEqual:(GSWResponse*)response;
@end

//====================================================================
@interface GSWResponse (GSWActionResults) <GSWActionResults>

-(GSWResponse*)generateResponse;

@end

//====================================================================
@interface GSWResponse (Stream)
-(void)setContentStreamFileHandle:(NSFileHandle*)fileHandle
                       bufferSize:(unsigned int)bufferSize
                           length:(unsigned long)length;
@end

//====================================================================
@interface GSWResponse (GSWResponseError)

//NDFN
//Last cHance Response
+(GSWResponse*)responseWithMessage:(NSString*)message
			 inContext:(GSWContext*)context
			forRequest:(GSWRequest*)request;

+(GSWResponse*)responseWithMessage:(NSString*)message
			 inContext:(GSWContext*)context
			forRequest:(GSWRequest*)request
                     forceFinalize:(BOOL)forceFinalize;
@end

//====================================================================
@interface GSWResponse (GSWResponseRefused)

//--------------------------------------------------------------------
//
//Refuse Response
+(GSWResponse*)generateRefusingResponseInContext:(GSWContext*)context
                                      forRequest:(GSWRequest*)request;
@end

//====================================================================
@interface GSWResponse (GSWResponseRedirected)

-(void)_generateRedirectResponseWithMessage:(NSString*)message
                                   location:(NSString*)location
                               isDefinitive:(BOOL)isDefinitive;

+(GSWResponse*)generateRedirectResponseWithMessage:(NSString*)message
                                          location:(NSString*)location
                                      isDefinitive:(BOOL)isDefinitive
                                         inContext:(GSWContext*)aContext
                                        forRequest:(GSWRequest*)aRequest;

+(GSWResponse*)generateRedirectResponseWithMessage:(NSString*)message
                                          location:(NSString*)location
                                      isDefinitive:(BOOL)isDefinitive;

+(GSWResponse*)generateRedirectDefaultResponseWithLocation:(NSString*)location
                                              isDefinitive:(BOOL)isDefinitive
                                                 inContext:(GSWContext*)aContext
                                                forRequest:(GSWRequest*)aRequest;

+(GSWResponse*)generateRedirectDefaultResponseWithLocation:(NSString*)location
                                              isDefinitive:(BOOL)isDefinitive;
@end




#endif //_GSWResponse_h__
