/* GSWTemplateParser.h - GSWeb: Class GSWTemplateParser
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Mar 1999
   
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

#ifndef _GSWTemplateParser_h__
	#define _GSWTemplateParser_h__

#include <gsantlr/ANTLRCommon.h>
#include <gsantlr/ANTLRTextStreams.h>
#include "GSWHTMLTokenTypes.h"
#include "GSWPageDefLexer.h"
#include "GSWPageDefParser.h"
#include "GSWPageDefParserExt.h"
#include "GSWHTMLAttrLexer.h"
#include "GSWHTMLAttrParser.h"
#include "GSWHTMLAttrParserExt.h"


//====================================================================
@interface GSWTemplateParser : NSObject
+(GSWElement*)templateNamed:(NSString*)name_
		   inFrameworkNamed:(NSString*)frameworkName_
			 withHTMLString:(NSString*)HTMLString
				   htmlPath:(NSString*)HTMLPath
		  declarationString:(NSString*)pageDefString
				  languages:(NSArray*)languages_
			declarationPath:(NSString*)declarationPath_;
+(BOOL)parseTag:(ANTLRDefAST)_AST
//  withTagStream:(ANTLRTextInputStreamString*)_tagStream
//	withTagParser:(GSWHTMLAttrParser*)_tagParser
  withTagsNames:(NSMutableDictionary*)tagsNames
  withTagsAttrs:(NSMutableDictionary*)tagsAttrs;
+(NSString*)getTagNameFor:(ANTLRDefAST)_AST
//			withTagStream:(ANTLRTextInputStreamString*)_tagStream
//			withTagParser:(GSWHTMLAttrParser*)_tagParser
			withTagsNames:(NSMutableDictionary*)tagsNames
			withTagsAttrs:(NSMutableDictionary*)tagsAttrs;
+(NSDictionary*)getTagAttrsFor:(ANTLRDefAST)_AST
//				 withTagStream:(ANTLRTextInputStreamString*)_tagStream
//				 withTagParser:(GSWHTMLAttrParser*)_tagParser
				 withTagsNames:(NSMutableDictionary*)tagsNames
				 withTagsAttrs:(NSMutableDictionary*)tagsAttrs;
+(GSWElement*)createElementsStartingWithAST:(ANTLRDefAST*)_AST
							stopOnTagNamed:(NSString*)_stopTagName
						   withDefinitions:(NSDictionary*)pageDefElements
							 withLanguages:(NSArray*)languages_
//							 withTagStream:(ANTLRTextInputStreamString*)_tagStream
//							 withTagParser:(GSWHTMLAttrParser*)_tagParser
							 withTagsNames:(NSMutableDictionary*)tagsNames
							  withTagsAttr:(NSMutableDictionary*)tagsAttrs
							  templateNamed:(NSString*)templateName_;


+(BOOL)parseDeclarationInclude:(NSString*)includeName_
			fromFrameworkNamed:(NSString*)fromFrameworkName_
			   declarationPath:(NSString*)declarationPath_
					 languages:(NSArray*)languages_
						  into:(NSMutableDictionary*)pageDefElements_;
+(BOOL)parseDeclarationString:(NSString*)pageDefString
					languages:(NSArray*)languages_
						named:(NSString*)name_
			 inFrameworkNamed:(NSString*)frameworkName_
			  declarationPath:(NSString*)declarationPath_
						 into:(NSMutableDictionary*)pageDefElements_;
+(BOOL)processIncludes:(NSArray*)pageDefIncludes_
			 languages:(NSArray*)languages_
				 named:(NSString*)name_
	  inFrameworkNamed:(NSString*)frameworkName_
	   declarationPath:(NSString*)declarationPath_
				  into:(NSMutableDictionary*)pageDefElements_;
@end

#endif //_GSWTemplateParser_h__
