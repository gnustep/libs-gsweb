/** GSWTemplateParser - <title>GSWeb: Class GSWTemplateParser</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
  
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
  GSWTemplateParserType_ANTLR
} GSWTemplateParserType;

//====================================================================
@interface GSWTemplateParser : NSObject
{
  NSString*		_templateName;
  NSString*		_frameworkName;
  NSString*		_string;
  NSStringEncoding _stringEncoding;
  NSString*	   _stringPath;
  NSString*	   _definitionsString;
  NSArray*	   _languages;
  NSString*	   _definitionFilePath;
  NSMutableSet*    _processedDefinitionFilePaths;
  GSWElement*   _template;
  NSDictionary* _definitions;
  NSMutableArray* _errorMessages;   /** Template/definition errors. If non empty, raise an exception **/
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
          definitionsString:(NSString*)pageDefString
                  languages:(NSArray*)someLanguages
             definitionPath:(NSString*)aDefinitionPath;
+(GSWElement*)templateNamed:(NSString*)aName
           inFrameworkNamed:(NSString*)aFrameworkName
             withParserType:(GSWTemplateParserType)parserType
                parserClass:(Class)parserClass
                 withString:(NSString*)HTMLString
                   encoding:(NSStringEncoding)encoding
                   fromPath:(NSString*)HTMLPath
          definitionsString:(NSString*)pageDefString
                  languages:(NSArray*)someLanguages
             definitionPath:(NSString*)aDefinitionPath;
+(GSWTemplateParserType)templateParserTypeFromString:(NSString*)string;
+(GSWTemplateParserType)defaultTemplateParserType;
-(id)initWithTemplateName:(NSString*)aName
          inFrameworkName:(NSString*)aFrameworkName
               withString:(NSString*)HTMLString
                 encoding:(NSStringEncoding)anEncoding
                 fromPath:(NSString*)HTMLPath
    withDefinitionsString:(NSString*)pageDefString
                 fromPath:(NSString*)aDefinitionPath
             forLanguages:(NSArray*)someLanguages;
-(void)dealloc;
-(NSString*)logPrefix;
-(void)addErrorMessage:(NSString*)errorMessage;
-(void)addErrorMessageFormat:(NSString*)format
                   arguments:(va_list)arguments;
-(void)addErrorMessageFormat:(NSString*)format,...;
-(NSMutableArray*)errorMessages;
-(NSString*)errorMessagesAsText;
-(GSWElement*)template;
-(NSArray*)templateElements;
-(NSDictionary*)definitions;

-(NSDictionary*)parseDefinitionsString:(NSString*)localDefinitionstring
                                 named:(NSString*)localDefinitionName
                      inFrameworkNamed:(NSString*)localFrameworkName
                        processedFiles:(NSMutableSet*)processedFiles;

-(NSDictionary*)parseDefinitionInclude:(NSString*)includeName
                    fromFrameworkNamed:(NSString*)fromFrameworkName
                        processedFiles:(NSMutableSet*)processedFiles;

-(NSDictionary*)processIncludes:(NSArray*)definitionsIncludes
                          named:(NSString*)localDefinitionsName
               inFrameworkNamed:(NSString*)localFrameworkName
                 processedFiles:(NSMutableSet*)processedFiles;

@end

#endif //_GSWTemplateParser_h__

