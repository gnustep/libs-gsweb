/* GSWText.h - GSWeb: Class GSWText
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>

//====================================================================
@implementation GSWText

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)name_
	 associations:(NSDictionary*)associations_
  contentElements:(NSArray*)elements_
{
  if ((self=[super initWithName:name_
				   associations:associations_
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
-(void)takeValuesFromRequest:(GSWRequest*)request_
				   inContext:(GSWContext*)context_
{
  if (value && [value isValueSettable])
	{
	  GSWComponent* _component=[context_ component];
	  id _formValue=[request_ formValueForKey:[context_ elementID]];
#if !GSWEB_STRICT
	  NS_DURING
		{
		  [value setValue:_formValue
				 inComponent:_component];
		};
	  NS_HANDLER
		{
		  [self handleValidationException:localException
				inContext:context_];
		}
	  NS_ENDHANDLER;
#else
	  [value setValue:_formValue
			 inComponent:_component];		  
#endif
	};
  [super takeValuesFromRequest:request_
		 inContext:context_];
};


//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_
{
  //OK
  GSWRequest* _request=[context_ request];
  NSString* _valueValue=nil;
  NSString* _valueValueFiltered=nil;
  BOOL _isFromClientComponent=[_request isFromClientComponent];
  GSWComponent* _component=[context_ component];
  [super appendToResponse:response_
		 inContext:context_];
  _valueValue=[value valueInComponent:_component];
  _valueValueFiltered=[self _filterSoftReturnsFromString:_valueValue];
  [response_ appendContentHTMLString:_valueValueFiltered];
  [response_ _appendContentAsciiString:@"</TEXTAREA>"];
};

//--------------------------------------------------------------------
-(NSString*)_filterSoftReturnsFromString:(NSString*)string_
{
  LOGObjectFnNotImplemented();	//TODOFN
  return string_;
};

@end

//====================================================================
@implementation GSWText (GSWTextB)
-(BOOL)appendStringAtRight:(id)_unkwnon
			   withMapping:(char*)_mapping
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

@end
