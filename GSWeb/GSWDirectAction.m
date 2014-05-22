/** GSWDirectAction.m - <title>GSWeb: Class GSWDirectAction</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Feb 1999
   
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

//====================================================================
@implementation GSWDirectAction

//--------------------------------------------------------------------
-(id <GSWActionResults>)performActionNamed:(NSString*)actionName
{
  id<GSWActionResults> actionResult=nil;
  SEL actionSel=NULL;
  actionSel=[self _selectorForActionNamed:actionName];

  if (!actionSel)
    {
      [NSException raise:NSInvalidArgumentException 
                   format:@"No such method: %@ in class named %@.",
                   actionName,[self className]];
    }
  else
    {
      NS_DURING
        {
          actionResult=[self performSelector:actionSel];
        }
      NS_HANDLER
        {
          localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                                  @"In performSelector: class: %@ actionName: %@",
                                                                  [self class],actionName);
          [localException raise];
        };
      NS_ENDHANDLER;
    };
  return actionResult;
};

//--------------------------------------------------------------------
-(NSString*)sessionIDForRequest:(GSWRequest*)aRequest
{
  NSString* sessionID = nil;
  sessionID = [aRequest sessionIDFromValuesOrCookieByLookingForCookieFirst:NO];

  return sessionID;
}

//--------------------------------------------------------------------
-(id<GSWActionResults>)defaultAction
{
  GSWComponent* component=[self pageWithName:nil];
  GSWResponse* response=[component generateResponse];
  [response disableClientCaching];
  return response;
}


// GSWTakeValuesConvenience

//--------------------------------------------------------------------
//NDFN: return additional path elements
-(NSArray*)additionalRequestPathArray
{
  return [GSWDirectActionRequestHandler 
           additionalRequestPathArrayFromRequest:[self request]];
};

//--------------------------------------------------------------------
-(void)takeFormValueArraysForKeyArray:(NSArray*)keyArray
{
  GSWRequest* request=[self request];
  if (request)
    {
      NSUInteger count=[keyArray count];
      NSUInteger i=0;
      IMP oaiIMP=NULL;
      
      for(i=0;i<count;i++)
        {
          NSString* key=GSWeb_objectAtIndexWithImpPtr(keyArray,&oaiIMP,i);
          NSArray* v=[request formValuesForKey:key];
          [self setValue:v
                forKey:key];
        };      
    }
};

//--------------------------------------------------------------------
-(void)takeFormValuesForKeyArray:(NSArray*)keyArray
{
  GSWRequest* request=[self request];
  if (request)
    {
      NSUInteger count=[keyArray count];
      NSUInteger i=0;
      IMP oaiIMP=NULL;
      
      for(i=0;i<count;i++)
        {
          NSString* key=GSWeb_objectAtIndexWithImpPtr(keyArray,&oaiIMP,i);
          id v=[request formValueForKey:key];
          [self setValue:v
                forKey:key];
        }
    };
};

//--------------------------------------------------------------------
-(void)takeFormValueArraysForKeys:(NSString*)firstKey,...
{
  GSWRequest* request=[self request];
  if (request)
    {
      va_list ap;
      id key=nil;
      va_start(ap, firstKey);
      key = firstKey;
      while(key)
        {
          NSArray* v=[request formValuesForKey:key];
          [self setValue:v
                forKey:key];
          key = va_arg(ap,id);
        };
      va_end(ap);
    }
};

//--------------------------------------------------------------------
-(void)takeFormValuesForKeys:(NSString*)firstKey,...
{
  GSWRequest* request=[self request];
  if (request)
    {
      va_list ap;
      id key=nil;
      va_start(ap, firstKey);
      key = firstKey;
      while(key)
        {
          id v=[request formValueForKey:key];
          [self setValue:v
                forKey:key];
          key = va_arg(ap,id);
        };
      va_end(ap);
    }
};

@end

