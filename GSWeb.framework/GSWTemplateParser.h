/** GSWTemplateParser - <title>GSWeb: Class GSWTemplateParser</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 1999
   
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

#ifndef _GSWTemplateParser_h__
	#define _GSWTemplateParser_h__


//====================================================================
typedef enum _GSWTemplateParserType 
{
  GSWTemplateParserType_Default,
  GSWTemplateParserType_XMLHTML,
  GSWTemplateParserType_XMLHTMLNoOmittedTags,
  GSWTemplateParserType_XML,
  GSWTemplateParserType_ANTLR,
  GSWTemplateParserType_RawHTML
} GSWTemplateParserType;

typedef enum _GSWHTMLRawParserTagType 
{
  GSWHTMLRawParserTagType_unknown,
  GSWHTMLRawParserTagType_gsweb,
  GSWHTMLRawParserTagType_wo,
  GSWHTMLRawParserTagType_oog,
  GSWHTMLRawParserTagType_comment
} GSWHTMLRawParserTagType;


static inline BOOL _parserIsDynamicTagType(GSWHTMLRawParserTagType tagType)
{
  switch(tagType)
    {
    case GSWHTMLRawParserTagType_gsweb:
    case GSWHTMLRawParserTagType_wo:
    case GSWHTMLRawParserTagType_oog:
      return YES;
      break;
    default:
      return NO;
      break;
    };
};

static inline BOOL _parserIsDynamicOrCommentTagType(GSWHTMLRawParserTagType tagType)
{
  switch(tagType)
    {
    case GSWHTMLRawParserTagType_gsweb:
    case GSWHTMLRawParserTagType_wo:
    case GSWHTMLRawParserTagType_oog:
    case GSWHTMLRawParserTagType_comment:
      return YES;
      break;
    default:
      return NO;
      break;
    };
};

static inline BOOL _parserIsCommentTagType(GSWHTMLRawParserTagType tagType)
{
  switch(tagType)
    {
    case GSWHTMLRawParserTagType_comment:
      return YES;
      break;
    default:
      return NO;
      break;
    };
};

//====================================================================
/** Template Parsing protocol for new parsers **/
@protocol GSWTemplateParserDelegate

/** Called by parser when it has parsed raw text
Creates a GSWHTMLBareString element with the text
**/
-(void)parser:(GSWBaseParser*)parser
 didParseText:(NSString*)text;


/** Called by parser when it has opened  a dynamic tag 
Creates a GSWTemporaryElement element, waiting for tag end
**/
-(void)				parser:(GSWBaseParser*)parser
       didParseOpeningDynamicTagOfType:(GSWHTMLRawParserTagType)tagType
                        withProperties:(NSDictionary*)tagProperties
                          templateInfo:(NSString*)templateInfo;

/** Called by parser when it has closed  a dynamic tag 
Creates a dynamic element from current temporary element element
**/
-(void)				parser:(GSWBaseParser*)parser
       didParseClosingDynamicTagOfType:(GSWHTMLRawParserTagType)tagType
                      withTemplateInfo:(NSString*)templateInfo;

/** Called by parser when it has parsed a comment
Creates a GSWHTMLComment with the comment text
**/
-(void)		parser:(GSWBaseParser*)parser
       didParseComment:(NSString*)text;
@end


//====================================================================
/** Base template parser **/
@interface GSWTemplateParser : NSObject<GSWDeclarationParserPragmaDelegate>
{
  NSString*		_templateName;
  NSString*		_frameworkName;
  NSString*		_string;
  NSStringEncoding _stringEncoding;
  NSString*	   _stringPath;
  NSString*	   _declarationsString;
  NSArray*	   _languages;
  NSString*	   _declarationsFilePath;
  NSMutableSet*    _processedDeclarationsFilePaths;
  GSWElement*   _template;
  NSDictionary* _declarations;
  NSMutableArray* _errorMessages;   /** Template/declaration errors. If non empty, raise an exception **/
  int gswebTagN;
  int tagN;
}

+(GSWElement*)templateNamed:(NSString*)aName
           inFrameworkNamed:(NSString*)aFrameworkName
             withParserType:(GSWTemplateParserType)parserType
            parserClassName:(NSString*)parserClassName
                 withString:(NSString*)HTMLString
                   encoding:(NSStringEncoding)encoding
                   fromPath:(NSString*)HTMLPath
         declarationsString:(NSString*)declarationsString
                  languages:(NSArray*)someLanguages
           declarationsPath:(NSString*)aDeclarationsPath;
+(GSWElement*)templateNamed:(NSString*)aName
           inFrameworkNamed:(NSString*)aFrameworkName
             withParserType:(GSWTemplateParserType)parserType
                parserClass:(Class)parserClass
                 withString:(NSString*)HTMLString
                   encoding:(NSStringEncoding)encoding
                   fromPath:(NSString*)HTMLPath
         declarationsString:(NSString*)declarationsString
                  languages:(NSArray*)someLanguages
           declarationsPath:(NSString*)aDeclarationsPath;
+(GSWTemplateParserType)templateParserTypeFromString:(NSString*)string;
+(GSWTemplateParserType)defaultTemplateParserType;
-(id)initWithTemplateName:(NSString*)aName
          inFrameworkName:(NSString*)aFrameworkName
               withString:(NSString*)HTMLString
                 encoding:(NSStringEncoding)anEncoding
                 fromPath:(NSString*)HTMLPath
   withDeclarationsString:(NSString*)declarationsString
                 fromPath:(NSString*)aDeclarationsPath
             forLanguages:(NSArray*)someLanguages;

-(NSString*)logPrefix;
-(void)addErrorMessage:(NSString*)errorMessage;
-(void)addErrorMessageFormat:(NSString*)format
                   arguments:(va_list)arguments;
-(void)addErrorMessageFormat:(NSString*)format,...;
-(NSMutableArray*)errorMessages;
-(NSString*)errorMessagesAsText;
-(GSWElement*)template;
-(NSArray*)templateElements;

//GSWDeclarationParserPragmaDelegate protocol
-(NSDictionary*)includedDeclarationsFromFilePath:(NSString*)file
                              fromFrameworkNamed:(NSString*)frameworkName;

-(NSDictionary*)declarations;
-(void)parseDeclarations;

-(NSDictionary*)parseDeclarationsString:(NSString*)declarationsString
                                  named:(NSString*)declarationsName
                       inFrameworkNamed:(NSString*)declarationsFrameworkName;
@end

#endif //_GSWTemplateParser_h__

