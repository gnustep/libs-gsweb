/** GSWActionURL.m - <title>GSWeb: Class GSWActionURL</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Sep 1999
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"
#include "GSWPrivate.h"

//====================================================================
@implementation GSWActionURL

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context
{
  if (_directActionName != nil
     || _actionClass != nil)
    {
      [self _appendCGIActionURLToResponse:response
	    inContext:context]; 
    }
  else if (_action != nil 
	  || _pageName != nil)
    {
      NSString * actionURL = [context _componentActionURLIsSecure:[self secureInContext:context]];
      GSWResponse_appendContentString(response,actionURL);
      
      [self _appendQueryStringToResponse:response
	    inContext:context
	    requestHandlerPath:nil
	    htmlEscapeURL:NO];
      
      [self _appendFragmentToResponse: response
	    inContext:context];
    }
  else 
    {
      GSWComponent* component = [context component];
    
      NSString* url = NSStringWithObject([_href valueInComponent:component]);
      if (url != nil)
	{        
	  if ([url isRelativeURL] 
	      && ![url isFragmentURL])
	    {
	      NSString* path = [context _urlForResourceNamed:url
					inFramework:nil];
	      if(path != nil)
		GSWResponse_appendContentString(response,path);
	      else
		{
		  GSWResponse_appendContentAsciiString(response, [component baseURL]);
		  GSWResponse_appendContentCharacter(response,'/');
		  GSWResponse_appendContentString(response,url);
		}
	    }
	  else
	    {
	      GSWResponse_appendContentString(response,url);
	    }
	  [self _appendQueryStringToResponse:response
		inContext:context
		requestHandlerPath:nil
		htmlEscapeURL:NO];
	  
	  [self _appendFragmentToResponse: response
		inContext:context];
	}
      else if(_fragmentIdentifier != nil)
        {
          NSString* fragment = [_fragmentIdentifier valueInComponent:component];
          if (fragment != nil)
	    {
	      GSWResponse_appendContentString(response,NSStringWithObject(fragment));
	      [self _appendQueryStringToResponse:response
		    inContext: context
		    requestHandlerPath:@""
		    htmlEscapeURL:NO];
	    }
        }
    }
}


@end

