/** GSWTemplateParserANTLR.h - <title>GSWeb: Class GSWTemplateParserANTLR</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:       Mar 1999
   
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

#ifndef _GSWTemplateParserANTLR_h__
	#define _GSWTemplateParserANTLR_h__

#include <gsantlr/ANTLRCommon.h>
#include <gsantlr/ANTLRTextStreams.h>
#include "GSWTemplateParser.h"
#include "GSWHTMLTokenTypes.h"
#include "GSWHTMLAttrLexer.h"
#include "GSWHTMLAttrParser.h"
#include "GSWHTMLAttrParserExt.h"


//====================================================================
@interface GSWTemplateParserANTLR : GSWTemplateParser
{
  NSMutableDictionary* _tagsNames;
  NSMutableDictionary* _tagsAttrs;
};
-(void)dealloc;
-(NSArray*)templateElements;
-(NSArray*)createElementsStartingWithAST:(ANTLRDefAST*)AST
                          stopOnTagNamed:(NSString*)stopTagName;

-(BOOL)parseTag:(ANTLRDefAST)AST;
-(NSString*)getTagNameFor:(ANTLRDefAST)AST;
-(NSDictionary*)getTagAttrsFor:(ANTLRDefAST)AST;
@end

#endif //_GSWTemplateParserANTLR_h__
