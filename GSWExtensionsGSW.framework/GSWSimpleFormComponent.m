/** GSWSimpleFormComponent.m - <title>GSWeb: Class GSWSimpleFormComponent</title>
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Sept 1999
   
   $Revision$
   $Date$
   
   <abstract></abstract>

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
*/

static char rcsId[] = "$Id$";

#include "GSWExtGSWWOCompatibility.h"
#include "GSWSimpleFormComponent.h"
//====================================================================
@implementation GSWSimpleFormComponent

//--------------------------------------------------------------------
-(id)init
{
  LOGObjectFnStart();
  if ((self=[super init]))
	{
	};
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)awake
{
  LOGObjectFnStart();
  [super awake];
  _tmpErrorMessage=nil;
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)sleep
{
  LOGObjectFnStart();
  _tmpErrorMessage=nil;
  [super sleep];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)dealloc
{
  [super dealloc];
};

//--------------------------------------------------------------------
-(BOOL)synchronizesVariablesWithBindings
{
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)validateFormFields:(id)fields
     withFieldsDscription:(NSDictionary*)fieldsDscription
       errorMessagePrefix:(NSString*)errorMessagePrefix
       errorMessageSuffix:(NSString*)errorMessageSuffix
{
  NSEnumerator* anEnum=nil;
  NSMutableString* missingFields=nil;
  id key=nil;
  NSString* dscrValue=nil;
  NSString* value=nil;
  LOGObjectFnStart();
  anEnum=[fieldsDscription keyEnumerator];
  while((key=[anEnum nextObject]))
    {
      dscrValue=[fieldsDscription objectForKey:key];
      value=[fields  objectForKey:key];
      if (!value || [value length]==0)
        {
          if (missingFields)
            [missingFields appendFormat:@", %@",dscrValue];
          else
            missingFields=(NSMutableString*)[NSMutableString stringWithFormat:@"%@",dscrValue];
        };
    };
  if (missingFields)
    {
      _tmpErrorMessage=[NSString stringWithFormat:@"%@ %@ %@",
                                 (errorMessagePrefix ? errorMessagePrefix : @""),
                                 missingFields,
                                 (errorMessageSuffix ? errorMessageSuffix : @"")];
      NSDebugMLog(@"_tmpErrorMessage=%@",_tmpErrorMessage);
    };
  LOGObjectFnStop();
  return !missingFields;
};

//--------------------------------------------------------------------
-(BOOL)isErrorMessage
{
  return [_tmpErrorMessage length]>0;
};

//--------------------------------------------------------------------
-(GSWComponent*)sendAction
{
  return [[self parent]sendActionFromComponent:self];
};

//--------------------------------------------------------------------
-(GSWComponent*)sendFields:(id)fields
      withFieldsDscription:(NSDictionary*)fieldsDscription
                  byMailTo:(NSString*)to
                      from:(NSString*)from
               withSubject:(NSString*)subject
             messagePrefix:(NSString*)messagePrefix
             messageSuffix:(NSString*)messageSuffix
              sentPageName:(NSString*)sentPageName
{
  NSEnumerator* anEnum=nil;
  GSWComponent* page=nil;
  NSMutableString* mailText=[NSMutableString string];
  id key=nil;
  NSString* dscrValue=nil;
  NSString* value=nil;
  NSString* msg=nil;
  LOGObjectFnStart();
  anEnum=[fieldsDscription keyEnumerator];
  while((key=[anEnum nextObject]))
    {
      dscrValue=[fieldsDscription objectForKey:key];
      value=[fields  objectForKey:key];
      [mailText appendFormat:@"%@:\t%@\n",dscrValue,value];
    };
  NSDebugMLog(@"to=%@",to);
  NSDebugMLog(@"from=%@",from);
  if (from && to)
    {
      NSString* text=[NSString stringWithFormat:@"%@%@%@",
                               (messagePrefix ? messagePrefix : @""),
                               mailText,
                               (messageSuffix ?  messageSuffix : @"")];
      NSDebugMLog(@"text=%@",text);
      msg=[[GSWMailDelivery sharedInstance] composeEmailFrom:from
                                            to:[NSArray arrayWithObject:to]
                                            cc:nil
                                            subject:subject
                                            plainText:text
                                            send:YES];
      NSDebugMLog(@"msg=%@",msg);
    }
  else
    {
      //TODO
      LOGError(@"No From or To address (from=%@ , to=%@)",from,to);
    };
  page=[self pageWithName:sentPageName];
  LOGObjectFnStop();
  return page;
};
@end


