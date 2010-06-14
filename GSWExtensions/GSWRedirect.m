/** GSWRedirect.m - <title>GSWeb: Class GSWRedirect</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Apr 1999
   
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
   <*license>
**/

#include "config.h"

RCS_ID("$Id$")

#include "GSWExtWOCompatibility.h"
#include "GSWRedirect.h"

//===================================================================================
@implementation GSWRedirect

-(void)awake
{
  [super awake];
};

-(void)sleep
{
  [super sleep];
};

-(void)dealloc
{
  DESTROY(_url);
  [super dealloc];
};

-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)aContext
{
//  [response_ appendContentHTMLAttributeValue:url];
  [response  setHeader:_url
             forKey:@"location"];
  if (_permanent)
    [response setStatus:301];
  else
    [response setStatus:302];
};

-(void)setURL:(NSString*)url
{
  ASSIGN(_url,url);
};

-(NSString*)url
{
  return _url;
};

-(void)setPermanent:(BOOL)permanent
{
  _permanent = permanent;
};

-(BOOL)permanent
{
  return _permanent;
};

@end
