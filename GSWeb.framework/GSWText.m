/** GSWText.m - <title>GSWeb: Class GSWText</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWText

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  if ((self=[super initWithName:name
                   associations:associations
                   contentElements:nil]))
    {
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  [super dealloc];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
                   object_get_class_name(self),
                   (void*)self];
};

//--------------------------------------------------------------------
-(NSString*)elementName
{
  return @"TEXTAREA";
};

@end

//====================================================================
@implementation GSWText (GSWTextA)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context
{
  if (_value && [_value isValueSettable])
    {
      GSWComponent* component=[context component];
      id formValue=[request formValueForKey:[context elementID]];
      NS_DURING
        {
          [_value setValue:formValue
                  inComponent:component];
        }
      NS_HANDLER
        {
          LOGException(@"GSWText _value=%@ resultValue=%@ exception=%@",
                       _value,resultValue,localException);
          if (WOStrictFlag)
            {
              [localException raise];
            }
          else
            {
              [self handleValidationException:localException
                    inContext:context];
            };
        }
      NS_ENDHANDLER;
    };
  [super takeValuesFromRequest:request
         inContext:context];
};


//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  //OK
  GSWRequest* request=[context request];
  NSString* valueValue=nil;
  NSString* valueValueFiltered=nil;
  BOOL isFromClientComponent=[request isFromClientComponent];
  GSWComponent* component=[context component];
  [super appendToResponse:response
		 inContext:context];
  valueValue=[_value valueInComponent:component];
  valueValueFiltered=[self _filterSoftReturnsFromString:valueValue];
  [response appendContentHTMLString:valueValueFiltered];
  [response _appendContentAsciiString:@"</TEXTAREA>"];
};

//--------------------------------------------------------------------
-(NSString*)_filterSoftReturnsFromString:(NSString*)string
{
  LOGObjectFnNotImplemented();	//TODOFN
  return string;
};

@end

//====================================================================
@implementation GSWText (GSWTextB)
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

@end
